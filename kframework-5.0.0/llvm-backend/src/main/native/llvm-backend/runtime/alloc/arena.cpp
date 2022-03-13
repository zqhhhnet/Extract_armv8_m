#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include "jemalloc/jemalloc.h"

#include "runtime/arena.h"
#include "runtime/header.h"
#include "runtime/alloc.h"
 
typedef struct {
  char* next_block;
  char* next_superblock;
  char semispace;
} memory_block_header;

const size_t BLOCK_SIZE = 1024 * 1024;

#define mem_block_header(ptr) \
  ((memory_block_header *)(((uintptr_t)(ptr)) & ~(BLOCK_SIZE-1)))

#define mem_block_start(ptr) \
  ((char *)(((uintptr_t)(ptr)) & ~(BLOCK_SIZE-1)))

__attribute__ ((always_inline))
void arenaReset(struct arena *Arena) {
  char id = Arena->allocation_semispace_id;
  if (id < 0) {
    id = ~Arena->allocation_semispace_id;
  }
  Arena->first_block = 0;
  Arena->block = 0;
  Arena->block_start = 0;
  Arena->block_end = 0;
  Arena->first_collection_block = 0;
  Arena->allocation_semispace_id = id;
}

__attribute__ ((always_inline))
char getArenaAllocationSemispaceID(const struct arena *Arena) {
  return Arena->allocation_semispace_id;
}

__attribute__ ((always_inline))
char getArenaCollectionSemispaceID(const struct arena *Arena) {
  return ~Arena->allocation_semispace_id;
}

__attribute__ ((always_inline)) char getArenaSemispaceIDOfObject(void *ptr) {
  return mem_block_header(ptr)->semispace;
}

static void* first_superblock_ptr = 0;
static void* superblock_ptr = 0;
static char** next_superblock_ptr = 0;
static unsigned blocks_left = 0;

static void* megabyte_malloc() {
  if (blocks_left == 0) {
    blocks_left = 15;
    posix_memalign(&superblock_ptr, BLOCK_SIZE, BLOCK_SIZE * 15);
    if (!first_superblock_ptr) {
      first_superblock_ptr = superblock_ptr;
    }
    if (next_superblock_ptr) {
      *next_superblock_ptr = (char *)superblock_ptr;
    }
    memory_block_header *hdr = (memory_block_header *)superblock_ptr;
    next_superblock_ptr = &hdr->next_superblock;
    hdr->next_superblock = 0;
  }
  blocks_left--;
  void* result = superblock_ptr;
  superblock_ptr = (char *)superblock_ptr + BLOCK_SIZE;
  return result;
}

static void freshBlock(struct arena *Arena) {
    char *nextBlock;
    if (Arena->block_start == 0) {
      nextBlock = (char *)megabyte_malloc();
      Arena->first_block = nextBlock;
      memory_block_header *nextHeader = (memory_block_header *)nextBlock;
      nextHeader->next_block = 0;
      nextHeader->semispace = Arena->allocation_semispace_id;
    } else {
      nextBlock = *(char**)Arena->block_start;
      if (Arena->block != Arena->block_end) {
        if (Arena->block_end - Arena->block == 8) {
          *(uint64_t *)Arena->block = NOT_YOUNG_OBJECT_BIT; // 8 bit sentinel value
        } else {
          *(uint64_t *)Arena->block = Arena->block_end - Arena->block - 8; // 16-bit or more sentinel value
        }
      }
      if (!nextBlock) {
        MEM_LOG("Allocating new block for the first time in arena %d\n", Arena->allocation_semispace_id);
        nextBlock = (char *)megabyte_malloc();
        *(char **)Arena->block_start = nextBlock;
        memory_block_header *nextHeader = (memory_block_header *)nextBlock;
        nextHeader->next_block = 0;
        nextHeader->semispace = Arena->allocation_semispace_id;
      }
    }
    Arena->block = nextBlock + sizeof(memory_block_header);
    Arena->block_start = nextBlock;
    Arena->block_end = nextBlock + BLOCK_SIZE;
    MEM_LOG("New block at %p (remaining %zd)\n", Arena->block, BLOCK_SIZE - sizeof(memory_block_header));
}

static __attribute__ ((noinline))
void *doAllocSlow(size_t requested, struct arena *Arena) {
  MEM_LOG("Block at %p too small, %zd remaining but %zd needed\n", Arena->block, Arena->block_end-Arena->block, requested);
  if (requested > BLOCK_SIZE - sizeof(memory_block_header)) {
    return malloc(requested);
  } else {
    freshBlock(Arena);
    void* result = Arena->block;
    Arena->block += requested;
    MEM_LOG("Allocation at %p (size %zd), next alloc at %p (if it fits)\n", result, requested, Arena->block);
    return result;
  }
}

__attribute__ ((always_inline))
void *arenaAlloc(struct arena *Arena, size_t requested) {
  if (Arena->block + requested > Arena->block_end) {
    return doAllocSlow(requested, Arena);
  }
  void* result = Arena->block;
  Arena->block += requested;
  MEM_LOG("Allocation at %p (size %zd), next alloc at %p (if it fits)\n", result, requested, Arena->block);
  return result;
}

__attribute__ ((always_inline))
void *arenaResizeLastAlloc(struct arena *Arena, ssize_t increase) {
  if (Arena->block + increase <= Arena->block_end) {
    Arena->block += increase;
    return Arena->block;
  }
  return 0;
}

__attribute__ ((always_inline)) void arenaSwapAndClear(struct arena *Arena) {
  char *tmp = Arena->first_block;
  Arena->first_block = Arena->first_collection_block;
  Arena->first_collection_block = tmp;
  Arena->allocation_semispace_id = ~Arena->allocation_semispace_id;
  arenaClear(Arena);
}

__attribute__ ((always_inline)) void arenaClear(struct arena *Arena) {
  Arena->block = Arena->first_block ? Arena->first_block + sizeof(memory_block_header) : 0;
  Arena->block_start = Arena->first_block;
  Arena->block_end = Arena->first_block ? Arena->first_block + BLOCK_SIZE : 0;
}

__attribute__ ((always_inline)) char *arenaStartPtr(const struct arena *Arena) {
  return Arena->first_block ? Arena->first_block + sizeof(memory_block_header) : 0;
}

__attribute__ ((always_inline)) char **arenaEndPtr(struct arena *Arena) {
  return &Arena->block;
}

char *movePtr(char *ptr, size_t size, const char *arena_end_ptr) {
  char *next_ptr = ptr + size;
  if (next_ptr == arena_end_ptr) {
    return 0;
  }
  if (next_ptr != mem_block_start(ptr) + BLOCK_SIZE) {
    return next_ptr;
  }
  char *next_block = *(char **)mem_block_start(ptr);
  if (!next_block) {
    return 0;
  }
  return next_block + sizeof(memory_block_header);
}

void freeAllMemory() {
  memory_block_header *superblock = (memory_block_header *)first_superblock_ptr;
  while (superblock) {
    memory_block_header* next_superblock = (memory_block_header *)superblock->next_superblock;
    free(superblock);
    superblock = next_superblock;
  }
  first_superblock_ptr = 0;
  superblock_ptr = 0;
  next_superblock_ptr = 0;
  blocks_left = 0;
}
