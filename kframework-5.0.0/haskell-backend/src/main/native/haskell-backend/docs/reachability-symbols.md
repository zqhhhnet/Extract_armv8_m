Reachability symbols
====================

Below is a list of LTL/CTL/Reachability Logic symbols and their translation to mML.

For further reference, consult the LICS ML paper and the corresponding technical report.

### One-path next `â¢`
---------------------

One path next is a reserved symbol in any mML signature used for representing ð definitions,
used to express possibility of transition and thus to encode ð transition rules.

for example, a ð rule
```
rule a => b
```
is represented in mML as 
```
axiom a â â¢b
```

Semantically, `â¢b` comprises the set of all elements which can transition to `b` in one step.

Hence, `a â â¢b` is read as `a` __can__ transition to `b` in one step.

(Strong) Eventually (LTL) `â` or `<>` or Exists Finally (CTLâ) `EF`
-------------------------------------------------------------------

`â Ï` says that there exists a finite path leading to `Ï`.

`Ï â â Ï` says that any state satisfying `Ï` can transition in a finite number of steps to 
a state satisfying `Ï`.

In mML `â` is defined as a smallest fixpoint (guaranteeing finite paths) by the alias formula
```
â Ï := Î¼X.Ï â¨ â¢X
```

(Weak) Eventually (One-path reachability) `âw` or `wEF`
-------------------------------------------------------

`âw Ï` says that there exists an infinite path or a finite path leading to `Ï`

`Ï â âw Ï` says that any state satisfying `Ï` can either transition indefinitely,
or transition in a finite number of steps to a state satisfying `Ï`.

In mML `âw ` is defined as a greatest fixpoint by the alias formula
```
âw  Ï := Î½X.Ï â¨ â¢X
```


All-path next `â`
-----------------

All-path next is the dual of one-path next.  It is defined as an alias formula by:
```
â Ï := Â¬â¢Â¬Ï
```

Semantically, `â A` comprises those elements which, if they can transition,
then they __must__ transition to `A`.

Hence, `Ï â â Ï` is read as "all possible continuations of `Ï` in one step must satisfy `Ï`".

Note that the above holds even if `Ï` is "stuck", i.e., cannot transition anymore.
Therefore, an useful formula, stating that `Ï` __must__ transition to `Ï` in one step
(hence, it is aditionally not stuck) is:
```
Ï â â Ï â§ â¢â¤
```

(Strong) Always (LTL) `â¡` or `[]` or Always Globally (CTLâ) `AG`
----------------------------------------------------------------

`â¡ Ï` says that `Ï` always holds (on all paths, at all times).

In mML `â¡` is defined as a greatest fixpoint by the alias formula
```
â¡ Ï := Î½X.Ï â§ â X
```

(Weak) Always Finally (All-Path reachability) `[w]` or `wAF`
------------------------------------------------------------

`wAF Ï` says that paths either contain a state in which `Ï` holds, or they are
infinite.

Hence `Ï â wAF Ï` states that for any state satisfying `Ï`, there are no
finite paths on which `Ï` does not eventually hold.

In mML `wAF` is defined as a greatest fixpoint by the alias formula
```
wAF  Ï := Î½X.Ï â¨ (â¢T â§ â X)
```

Well foundness (termination) `WF`
---------------------------------

`WF` expresses that there are no infinite paths.

Hence `Ï â WF` says that there are no infinite paths starting from `Ï`.

`WF` is defined in mML by the least fixpoint alias
```
WF := Î¼X.â X
```
