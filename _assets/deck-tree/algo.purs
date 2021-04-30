module Main where

import Prelude

import Effect.Console (log)
import TryPureScript (render, withConsole, text)
import Data.List.Lazy (fromFoldable, repeat, replicate, length, zipWith, List(..), fromFoldable, groupBy, (:), singleton, snoc, filter, concat)
import Data.List as Strict
import Data.List.Lazy.Types (toList)
import Data.Function (on)
import Data.Foldable (fold)
import Control.Monad.Rec.Class (Step(..), tailRec)
import Data.Semigroup ((<>))
import TryPureScript (Doc(..), h1, h2, p, text, list, indent, link, render, code)

data Tree a = One (List a) | Many (List (Tree a))

leaf :: forall a. List a -> Tree a
leaf = One 

node :: forall a. List (Tree a) -> Tree a
node = Many

instance showTree :: (Show a) => Show (Tree a) where
  show (Many ts) = show ts
  show (One a) = show a

classifyOn :: forall a b. Ord b => (a -> b) -> List a -> List (List a)
classifyOn field l = groupAllBy (eq `on` field) (fromFoldable (Strict.sortBy (compare `on` field) (Strict.fromFoldable l)))

groupAllBy :: forall a. (a -> a -> Boolean) -> List a -> List (List a)
groupAllBy p t = toList <$> groupBy p t


clasify :: forall a b. Ord b => (a -> b) -> Tree a -> Tree a
clasify field (One leaves) = Many $ One <$> classifyOn field leaves
clasify f (Many ts) = Many $ clasify f <$> ts

type Card = { color :: String, cmc :: String, name :: String }

deck :: List Card
deck = fromFoldable $
       [ { color: "g", cmc: "1", name: "Arboreal Grazer" }
       , { color: "g", cmc: "1", name: "Arboreal Grazer" }
       , { color: "g", cmc: "1", name: "Arboreal Grazer" }
       , { color: "g", cmc: "1", name: "Arboreal Grazer" }
       , { color: "g", cmc: "3", name: "Azusa, Lost but Seeking" }
       , { color: "g", cmc: "3", name: "Azusa, Lost but Seeking" }
       , { color: "g", cmc: "3", name: "Dryad of the Ilysian Grove" }
       , { color: "g", cmc: "3", name: "Dryad of the Ilysian Grove" }
       , { color: "g", cmc: "3", name: "Dryad of the Ilysian Grove" }
       , { color: "g", cmc: "3", name: "Dryad of the Ilysian Grove" }
       , { color: "g", cmc: "3", name: "Tireless Tracker" }
       , { color: "g", cmc: "6", name: "Primeval Titan" }
       , { color: "g", cmc: "6", name: "Primeval Titan" }
       , { color: "g", cmc: "6", name: "Primeval Titan" }
       , { color: "g", cmc: "6", name: "Primeval Titan" }
       , { color: "g", cmc: "0", name: "Summoner's Pact" }
       , { color: "g", cmc: "0", name: "Summoner's Pact" }
       , { color: "g", cmc: "0", name: "Summoner's Pact" }
       , { color: "g", cmc: "0", name: "Summoner's Pact" }
       , { color: "c", cmc: "0", name: "Engineered Explosives" }
       , { color: "c", cmc: "1", name: "Amulet of Vigor" }
       , { color: "c", cmc: "1", name: "Amulet of Vigor" }
       , { color: "c", cmc: "1", name: "Amulet of Vigor" }
       , { color: "c", cmc: "1", name: "Amulet of Vigor" }
       , { color: "u", cmc: "0", name: "Pact of negation" }
       ]

unlines :: List String -> String
unlines ls = fold $ (_ <> "\n") <$> ls

pre :: List String -> List String
pre l = zipWith (<>) prefix l
  where
    prefix = if length l < 2 then repeat "──" else singleton ("┌─") <> replicate (length l - 2) "│ " <> singleton "└─"

renderTree :: forall a. (Show a) => Tree a -> List String
renderTree (One leaves) = pre $ show <$> leaves
renderTree (Many ts) = pre $ concat $ intersperse (singleton "") (renderTree <$> ts)

intersperse ::  forall a. a -> List a -> List a
intersperse sep = fromFoldable <<< intersperse' sep <<< Strict.fromFoldable

intersperse' :: forall a. a -> Strict.List a -> Strict.List a
intersperse' _   Strict.Nil      = Strict.Nil
intersperse' sep (Strict.Cons x xs)  = Strict.Cons x (prependToAll sep xs)


prependToAll :: forall a. a -> Strict.List a -> Strict.List a
prependToAll _   Strict.Nil     = Strict.Nil
prependToAll sep (Strict.Cons x xs) = Strict.Cons sep $ Strict.Cons x (prependToAll sep xs)

dt :: Tree Card
dt = leaf deck # clasify _.cmc # clasify _.color

main = render =<< withConsole do
  log $ unlines $ renderTree dt