{- |
Copyright   : (c) Runtime Verification, 2018
License     : NCSA

-}
module Kore.Step.Simplification.Or
    ( simplifyEvaluated
    , simplify
    ) where

import Control.Applicative
    ( Alternative (..)
    )

import Kore.Internal.Conditional as Conditional
import qualified Kore.Internal.MultiOr as MultiOr
import Kore.Internal.OrPattern
    ( OrPattern
    )
import qualified Kore.Internal.OrPattern as OrPattern
import Kore.Internal.Pattern as Pattern
import Kore.Internal.TermLike
import Kore.Predicate.Predicate
    ( makeOrPredicate
    )
import qualified Kore.Predicate.Predicate as Syntax.Predicate

-- * Driver

{- | 'simplify' simplifies an 'Or' pattern into an 'OrPattern'.

'simplify' is the driver responsible for breaking down an @\\or@ pattern and
merging its children.

-}
simplify
    :: InternalVariable variable
    => Or Sort (OrPattern variable)
    -> OrPattern variable
simplify Or { orFirst = first, orSecond = second } =
    simplifyEvaluated first second

{- | Simplify an 'Or' given its two 'OrPattern' children.

See also: 'simplify'

-}
simplifyEvaluated
    :: InternalVariable variable
    => OrPattern variable
    -> OrPattern variable
    -> OrPattern variable

{-

__TODO__ (virgil): Preserve pattern sorts under simplification.
One way to preserve the required sort annotations is to make 'simplifyEvaluated'
take an argument of type

@
CofreeF (Or Sort) (Attribute.Pattern variable) (OrPattern variable)
@

instead of two 'OrPattern' arguments. The type of 'makeEvaluate' may
be changed analogously. The 'Attribute.Pattern' annotation will eventually cache
information besides the pattern sort, which will make it even more useful to
carry around.

-}

{-
__TODO__ (virgil): This should do all possible mergings, not just the first term
with the second.
-}

simplifyEvaluated first second

  | (head1 : tail1) <- MultiOr.extractPatterns first
  , (head2 : tail2) <- MultiOr.extractPatterns second
  , Just result <- simplifySinglePatterns head1 head2
  = OrPattern.fromPatterns $ result : (tail1 ++ tail2)

  | otherwise =
    MultiOr.merge first second

  where
    simplifySinglePatterns first' second' =
        disjoinPredicates first' second' <|> topAnnihilates first' second'

-- * Disjoin predicates

{- | Merge two configurations by the disjunction of their predicates.

This simplification case is only applied if the configurations have the same
'term'.

When two configurations have the same substitution, it may be possible to
simplify the pair by disjunction of their predicates.

@
(             t???, p???, s) ??? (             t???, p???, s)
([t??? ??? ??t???] ??? t???, p???, s) ??? ([t??? ??? ??t???] ??? t???, p???, s)

(t??? ??? t???, p??? ??? p???, s) ??? (??t??? ??? t???, p???, s) ??? (??t??? ??? t???, p???, s)
@

It is useful to apply the above equality when

@
??t??? ??? t??? = ??t??? ??? t??? = ???
t??? = t???
@

so that

@
(t???, p???, s) ??? (t???, p???, s) = (t??? ??? t???, p??? ??? p???, s)
  where
    t??? = t???.
@

 -}

{- __NOTE__: [Weakening predicates]

Phillip: It is not clear that we should *ever* apply this simplification.  We
attempt to refute the conditions on configurations using an external solver to
reduce the configuration space for execution.  The solver operates best when it
has the most information, and the predicate `p??? ??? p???` is strictly weaker than
either `p???` or `p???`.

Virgil: IIRC the main reason for having this was to be able to use some
assumptions on the pattern form at a time when it wasn't obvious that we needed
full generality.

That being said: for now, it's obvious that we want to split the configuration
when we have an or between terms or substitutions (though that might change at
some point), but, for predicates, it might be better to let the external solver
handle this than for us to handle one more configuration, that will potentially
be split into many other configurations. Or it may be worse, I don't know.

To make it short: I agree with this, but I wanted to say the above in case it's
useful.
-}
disjoinPredicates
    :: InternalVariable variable
    => Pattern variable
    -- ^ Configuration
    -> Pattern variable
    -- ^ Disjunction
    -> Maybe (Pattern variable)
disjoinPredicates
    predicated1@Conditional
        { term = term1
        , predicate = predicate1
        , substitution = substitution1
        }
    Conditional
        { term = term2
        , predicate = predicate2
        , substitution = substitution2
        }

  | term1 == term2 && substitution1 == substitution2 =
    Just predicated1
        { predicate =
            Syntax.Predicate.markSimplified
            $ makeOrPredicate predicate1 predicate2
        }
  | otherwise =
    Nothing

-- * Top annihilates Or

{- | 'Top' patterns are the annihilator of 'Or'.

@???@ is the annihilator of @???@; when two configurations have the same
substitution, it may be possible to use this property to simplify the pair by
annihilating the lesser term.

@
(???,              p???, s) ??? (t???,              p???, s)
(???, [p??? ??? ??p???] ??? p???, s) ??? (t???, [p??? ??? ??p???] ??? p???, s)

(???, p??? ??? p???, s) ??? (???, p??? ??? ??p???, s) ??? (t???, ??p??? ??? p???, s)
@

It is useful to apply the above equality when

@
??p??? ??? p??? = ??p??? ??? p??? = ???
p??? = p???
@

so that

@
(???, p???, s) ??? (t???, p???, s) = (???, p??? ??? p???, s)
  where
    p??? = p???.
@
 -}
topAnnihilates
    :: InternalVariable variable
    => Pattern variable
    -- ^ Configuration
    -> Pattern variable
    -- ^ Disjunction
    -> Maybe (Pattern variable)
topAnnihilates
    predicated1@Conditional
        { term = term1
        , predicate = predicate1
        , substitution = substitution1
        }
    predicated2@Conditional
        { term = term2
        , predicate = predicate2
        , substitution = substitution2
        }

  -- The 'term's are checked first because checking the equality of predicates
  -- and substitutions could be expensive.

  | isTop term1
  , predicate1    == predicate2
  , substitution1 == substitution2
  = Just predicated1

  | isTop term2
  , predicate1    == predicate2
  , substitution1 == substitution2
  = Just predicated2

  | otherwise =
    Nothing
