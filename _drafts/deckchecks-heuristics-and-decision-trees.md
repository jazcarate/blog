---
layout: post
title: Deckchecks, Heuristics and Decision Trees
date: 2021-04-11 15:45
categories: mtg
excerpt: >-
    One of the tools judges employ to thwart attempts to cheat is to require players to write down what cards they will be playing with in a particular tournament, and and routinely check them.
    It is important that judges perform these checks the fastest way possible so as to not delay the tournament. As such, they developed a myriad of techniques.
    In this blog post I would like to explore some techniques' inner workings. Propose a hypothesis on why they might work in some situations but not others. Consider unexplored alternatives. And hopefully build a heuristic on what method is better for each circumstance.
    Join me!
---

Recently I had the pleasure of attending an online conference[^covid]: **Practical Deck Checks with Oli Bird** where they talked about the specifics of when, why we do deckchecks[^deckchecks] and, the thing I want to focus now: how.

## TL;DR
Play around with the **[Deck Partitioner](https://jazcarate.github.io/deck-partitioner/)**, inputting decks, seeing the cost of each partition strategy and see if your heuristic matches my hypothesis of costs.

## What _are_ deck checks
In Magic: The Gathering™'s tournaments, players are expected not to cheat.
And there are people (here on called _judges_) that train to, in addition to other more noble and customer-caring actions, prevent that from happening.
One of the tools judges employ to thwart attempts to cheat is to require players to write down what cards they will be playing with in a particular tournament, or section of tournament; and and routinely checked that the cards they are playing with are in fact those that they settled from the start. 

It is important that judges perform these checks the fastest way possible so as to not delay the tournament. As such, they developed a myriad of techniques.
In this blog post I would like to explore their inner workings, propose a hypothesis on why they might work in some situations but not others, consider unexplored alternatives, and hopefully build a heuristic on what method is better for each circumstance.

_Side note: It feels so weird writing about a deckcheck amidst a pandemic; when the last one I did was well over a year ago, and who knows how we'll perform them in the future. The mere though of manipulating other human being's cards is bizarre. Time will tell..._

## Techniques
I'll briefly go though two ways I know judges do deckchecks.
I highly recommend watching the video from Federico Donner where he goes in depth with visual aide on many other techniques _(even though it is in spanish, it has subtitles)_.

<div class='embed-container'>
    <iframe title="YouTube video - Técnicas de deckcheck" src='https://www.youtube.com/embed/EovGP2dB6QU' frameborder='0' allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

### 1. Type separation
Split the deck by dividing it into two piles: lands and non-lands.
Then proceed to split each pile by card name.
Afterwards go through the deck list in order and verify the quantity is correct.

{% asset deck-partition/type.jpg alt='no classification' magick:resize='840x' magick:format='.png' %}

### 2. Mana value[^mana_value] separation
Split the deck into piles, categorized by mana value.
Then go though the deck list and retrieve the cards with the required quantity from the appropriate pile.

{% asset deck-partition/type-cmc.jpg alt='no classification' magick:resize='840x' magick:format='.png' %}

This got me thinking, to perform a deckcheck, there are two pieces of information that we need:

1. A sorted deck
1. and a deck list.

Technique number 1 starts with a sorted deck and then uses the list. Technique number 2 starts to sort a deck, and then uses the decklist to make the remaining sorting easier.
Thus I wondered: Is there something we can do with just the list? Considering we have unlimited access to a list, and (bar the opportunity cost of not being in the floor) looking at the list has no impact to the overall timing of a tournament.

It then dawned upon me that I do a different permutation when checking [Modern's Tron](https://www.mtggoldfish.com/archetype/tron) than [Modern's Burn](https://www.mtggoldfish.com/archetype/burn-a2dd1132-5301-4882-907a-7b668da3b58a). Based on my perception of the density of cards on each mana value.
My heuristic tells me that separating burn by type is less efficient that separating by mana value. And separating by color is all but useless. As most lists run four copies of each card, and the mana values are very tightly packed. But my heuristic is more of fa gut feeling than a hard proof that this is more efficient.
So I spend some time devising a mathematical model of deck sorting to figure out what the best approach to separating a deck is; and this process can be done with the list alone!

## Defining the problem statement
I want to find a mathematical formula to aid me in minimizing the time of performing a deck check.
As I'm not a very good mathematician, but I know a thing or two about coding. I reckon I can compute for a deck every single permutation of partition strategy; and with a way of putting a numeric value on the cost of each arrangement, select the optimal.

In order to do so, we'll have to establish some common names and operations, and abstract away some details like “how much desk-space does each technique use up”, or how to deal with a sideboard-ed deck.

Given those abstractions, we can reframe the problem of checking a deck, to a one much closer to ~botanics~programming: Constructing a tree.
In my model, the process of deck checking is equivalent to building a tree, where each node holds a intermediate pile of cards that have been split by some criteria. And the leaves are piles of same-name cards ready to be cross checked with a deck list.

To construct the procedure tree you start with a **node** with all the cards. Then for each category you want to **classify**[^partition] them, you split into **sub-nodes** with the cards that match that criteria. This test may be binary (e.g.: land vs non-land) or not (e.g.: by mana value, or by color).
This process is repeated until cards are **classified** by name. Further sub-classifications are pointless, as cards with the same name will _(by definition)_ have the same attributes.

### Example
We'll be using just a deck of 16 cards to make things concise:
```
4 Primeval Titan
2 Azusa, Lost but Seeking
4 Amulet of Vigor
2 Valakut, the Molten Pinnacle
4 Simic Growth Chamber
```

### 1. Type separation tree
Start with the whole deck.

{% asset deck-partition/none.jpg alt='no classification' magick:resize='420x' magick:format='.png' %}

We'll represent this deck, unclassified, like so:
```
┌──Primeval Titan
│  Primeval Titan
│  Primeval Titan
│  Primeval Titan
│  Valakut, the Molten Pinnacle
│  Valakut, the Molten Pinnacle
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Azusa, Lost but Seeking
│  Azusa, Lost but Seeking
│  Amulet of Vigor
│  Amulet of Vigor
│  Amulet of Vigor
└──Amulet of Vigor
```

Split the deck into a lands and a non-lands pile.

{% asset deck-partition/type.jpg alt='land-nonland' magick:resize='420x' magick:format='.png' %}

```
┌──┌──Primeval Titan
│  │  Primeval Titan
│  │  Primeval Titan
│  │  Primeval Titan
│  │  Azusa, Lost but Seeking
│  │  Azusa, Lost but Seeking
│  │  Amulet of Vigor
│  │  Amulet of Vigor
│  │  Amulet of Vigor
│  └──Amulet of Vigor
│  
│  ┌──Valakut, the Molten Pinnacle
│  │  Valakut, the Molten Pinnacle
│  │  Simic Growth Chamber
│  │  Simic Growth Chamber
│  │  Simic Growth Chamber
└──└──Simic Growth Chamber
```

Then proceed to split each pile by card name.

{% asset deck-partition/all.jpg alt='by name' magick:resize='420x' magick:format='.png' %}

```
┌──┌──┌──Primeval Titan
│  │  │  Primeval Titan
│  │  │  Primeval Titan
│  │  └──Primeval Titan
│  │  
│  │  ┌──Azusa, Lost but Seeking
│  │  └──Azusa, Lost but Seeking
│  │  
│  │  ┌──Amulet of Vigor
│  │  │  Amulet of Vigor
│  │  │  Amulet of Vigor
│  └──└──Amulet of Vigor
│  
│  ┌──┌──Valakut, the Molten Pinnacle
│  │  └──Valakut, the Molten Pinnacle
│  │  
│  │  ┌──Simic Growth Chamber
│  │  │  Simic Growth Chamber
│  │  │  Simic Growth Chamber
└──└──└──Simic Growth Chamber
```

### 2. Mana value separation tree
Again start with the whole deck.

{% asset deck-partition/none.jpg alt='no classification' magick:resize='420x' magick:format='.png' %}

And once more, the same text representation:
```
┌──Primeval Titan
│  Primeval Titan
│  Primeval Titan
│  Primeval Titan
│  Valakut, the Molten Pinnacle
│  Valakut, the Molten Pinnacle
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Azusa, Lost but Seeking
│  Azusa, Lost but Seeking
│  Amulet of Vigor
│  Amulet of Vigor
│  Amulet of Vigor
└──Amulet of Vigor
```

Afterwards split each pile by mana value.

{% asset deck-partition/type-cmc.jpg alt='by mana value' magick:resize='420x' magick:format='.png' %}

```
┌──┌──Primeval Titan
│  │  Primeval Titan
│  │  Primeval Titan
│  └──Primeval Titan
│  
│  ┌──Valakut, the Molten Pinnacle
│  │  Valakut, the Molten Pinnacle
│  │  Simic Growth Chamber
│  │  Simic Growth Chamber
│  │  Simic Growth Chamber
│  └──Simic Growth Chamber
│  
│  ┌──Azusa, Lost but Seeking
│  └──Azusa, Lost but Seeking
│  
│  ┌──Amulet of Vigor
│  │  Amulet of Vigor
│  │  Amulet of Vigor
└──└──Amulet of Vigor
```

And finally each by card name.

{% asset deck-partition/all.jpg alt='no classification' magick:resize='840x' magick:format='.png' %}

```
┌──┌──┌──Primeval Titan
│  │  │  Primeval Titan
│  │  │  Primeval Titan
│  └──└──Primeval Titan
│  
│  ┌──┌──Valakut, the Molten Pinnacle
│  │  └──Valakut, the Molten Pinnacle
│  │  
│  │  ┌──Simic Growth Chamber
│  │  │  Simic Growth Chamber
│  │  │  Simic Growth Chamber
│  └──└──Simic Growth Chamber
│  
│  ┌──┌──Azusa, Lost but Seeking
│  └──└──Azusa, Lost but Seeking
│  
│  ┌──┌──Amulet of Vigor
│  │  │  Amulet of Vigor
│  │  │  Amulet of Vigor
└──└──└──Amulet of Vigor
```

## Evaluation
Now that we know how to construct any strategy of partitions, we need to decide which is _the best_.

In my model, I pose that the cost of each classification **is** associated with the amount of _piles_[^partition] generated by the test.
It is faster to decide "land" vs "non-land", than "mana value 0" vs "mana value 1" vs "mana value 2" etc. Not only there is much more brain power needed to parse a card into these categories, but the physical action of placing the card in the appropriate pile is costly. This action of deciding each pile is then multiplied for how many cards need to be sorted. It does not take the same time to sort 10 cards than 100. But I reckon that the cost is linearly proportional, as it is just doing the same classification over and over again.

So to go from
```
┌──Primeval Titan
│  Primeval Titan
│  Primeval Titan
│  Primeval Titan
│  Valakut, the Molten Pinnacle
│  Valakut, the Molten Pinnacle
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Azusa, Lost but Seeking
│  Azusa, Lost but Seeking
│  Amulet of Vigor
│  Amulet of Vigor
│  Amulet of Vigor
└──Amulet of Vigor
```

to

```
┌──┌──Primeval Titan
│  │  Primeval Titan
│  │  Primeval Titan
│  │  Primeval Titan
│  │  Azusa, Lost but Seeking
│  │  Azusa, Lost but Seeking
│  │  Amulet of Vigor
│  │  Amulet of Vigor
│  │  Amulet of Vigor
│  └──Amulet of Vigor
│  
│  ┌──Valakut, the Molten Pinnacle
│  │  Valakut, the Molten Pinnacle
│  │  Simic Growth Chamber
│  │  Simic Growth Chamber
│  │  Simic Growth Chamber
└──└──Simic Growth Chamber
```

We need to go though each card ($$16$$) and with each one decide between one of two buckets. Thus the total cost is $$16x2=32$$.
Whereas to go from:

```
┌──Primeval Titan
│  Primeval Titan
│  Primeval Titan
│  Primeval Titan
│  Valakut, the Molten Pinnacle
│  Valakut, the Molten Pinnacle
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Simic Growth Chamber
│  Azusa, Lost but Seeking
│  Azusa, Lost but Seeking
│  Amulet of Vigor
│  Amulet of Vigor
│  Amulet of Vigor
└──Amulet of Vigor
```

to 

```
┌──┌──Primeval Titan
│  │  Primeval Titan
│  │  Primeval Titan
│  └──Primeval Titan
│  
│  ┌──Valakut, the Molten Pinnacle
│  │  Valakut, the Molten Pinnacle
│  │  Simic Growth Chamber
│  │  Simic Growth Chamber
│  │  Simic Growth Chamber
│  └──Simic Growth Chamber
│  
│  ┌──Azusa, Lost but Seeking
│  └──Azusa, Lost but Seeking
│  
│  ┌──Amulet of Vigor
│  │  Amulet of Vigor
│  │  Amulet of Vigor
└──└──Amulet of Vigor
```

We again have to decide $$16$$ times, but now on four possible classifications, so the cost is much higher (_twice as high_): $$16 x 4 =  64$$. But we end with smaller buckets.

Going back to the Modern Burn, I know that mana values will be small and dense (this means, no mana value gets skipped. You have your 1 mana value spells, 2s, 3s and maybe 4s) where in tron the mana values are all over the place, and are sparse.
So whereas I only do piles of mana value with Burn, for Tron I split first by type, and then again by mana value.

The entire cost of a sorting technique then is adding up all the costs of each node's classification cost. I did not add a cost associated with how many levels of classification there are, as I think it is small enough to be ignored. Though in my limited testing, it does cause fatigue if above a certain number of classifications.

I would love other people to experiment and time themselves to figure out if this cost is negligible or not. Maybe it is small, but scales exponentially each new level. I'm curious.

If you want to help me out fine tuning my hypothesis of costs to find a better heuristic, you can very much do so classifing some cards and measuring the time it took in [this form](https://docs.google.com/forms/d/e/1FAIpQLSffb1aN8cVwAQz6gDcjToL4EYtdIhBjYKBg58WlPBzjegChAw/viewform?usp=sf_link).

## Playground
As I said before, I write code for a living, and very much enjoy it, so I came up with a small program to do these simulations.
You can input any deck, and it will figure out all the possible ways of splitting and sorting it, and then choose the one with the least cost. You can try it out [here](https://jazcarate.github.io/deck-partitioner/).

---

[^covid]: Its 2021 and we are still in lockdown because of the [COVID-19](https://es.wikipedia.org/wiki/COVID-19), hence why the conference was virtual in nature.
[^deckchecks]: https://magic.wizards.com/en/articles/archive/deck-check-procedures-2000-02-29
[^mana_value]: Previously known as “casting cost”, “total casting cost” or “converted mana cost” (cmc).
[^shuffle]: I don't particulartly agree that is reasonable to expect a player and their opponent to _trust_ that the deck order has not been altered.
[^absurdum]: [Reductio ad absurdum](https://en.wikipedia.org/wiki/Reductio_ad_absurdum)
[^equivalence]: [Equivalence classes](https://en.wikipedia.org/wiki/Equivalence_class) are, roughly speaking, set of elements that belong to a class, and no other class. So an element can't be part of two different Equivalence classes.
[^partition]: For those really interested in the math, I can point you in the right direction of the formalization of this: Generating a [Equivalence relation](https://en.wikipedia.org/wiki/Equivalence_relation) that yields a [partition](https://en.wikipedia.org/wiki/Partition_of_a_set).