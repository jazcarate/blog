---
layout: post
title: Deckchecks, Heuristics, and Decision Trees
date: 2021-04-11 15:45
categories: mtg
enable_mathjax: true
excerpt: >-
    One of the tools judges employ to thwart attempts to cheat is to require players to write down what cards they will be playing within a particular tournament, and routinely check them.
    Judges must perform these checks the fastest way possible to not delay the tournament. As such, they developed a myriad of techniques.
    I feel we under-use the availability of the decklist, so having a clear plan ahead of actually getting the deck in our hands can prove highly effective.
    In this post, I would like to explore some techniques' inner workings. Propose a hypothesis on why they might work in some situations but not others. Consider unexplored alternatives. And build a heuristic on what method is better for each circumstance.
    Join me!
---

Recently I had the pleasure of attending an online conference[^covid]: **Practical Deck Checks with Oli Bird** where they talked about the specifics of when, why we do deckchecks[^deckchecks], and how. The latter point sparked some ideation.

> How do we chose the strategy by which we deck check?

Are we consciously choosing the best strategy for each deck check? Are we leveraging all the tools at our disposal to make such a decision?

In this post, I want to explore such questions; as at first glance, the answer seems to be: **no**.

## TL;DR
Play around with the **[Deck Partitioner](https://jazcarate.github.io/deck-partitioner/)** tool. Paste a deck. See the cost of each partition strategy and see if your heuristic matches my hypothesis of costs.

## What _are_ deck checks

_Feel free to skip this section if you are already versed in what they are_

In Magic: The Gathering™'s tournaments, players are expected not to cheat.
And there are people (called _judges_) that train to, in addition to other more noble and customer-caring actions, prevent that from happening.
One of the tools judges employ to thwart attempts to cheat is to require players to write down what cards they will be playing within a particular tournament or section of the tournament, and routinely checked that the cards they are playing with are those that they settled from the start. 

Judges must perform these checks the fastest way possible to not delay the tournament. As such, they developed a myriad of techniques.
In this blog post, I would like to explore their inner workings, propose a hypothesis on why they might work in some situations but not others, consider unexplored alternatives, and hopefully build a heuristic on what method is better for each circumstance.

_Side note: It feels so weird writing about a deck check amidst a pandemic; when the last one I did was well over a year ago, and who knows how we'll perform them in the future. The mere thought of manipulating other human being's cards is bizarre. Time will tell..._

## Techniques
I'll briefly go through two ways I know judges do deck checks.
I highly recommend watching the video from Federico Donner where he goes in-depth with a visual aide on many other techniques _(even though it is in Spanish, it has subtitles)_.

<div class='embed-container'>
    <iframe title="YouTube video - Técnicas de deckcheck" src='https://www.youtube.com/embed/EovGP2dB6QU' frameborder='0' allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

### 1. Type separation
Split the deck by dividing it into two piles: lands and non-lands.
Then proceed to split each pile by card name.
Afterward go through the decklist in order and verify the quantity is correct.

![land / non-land](/assets/image/deck-partition/land-non-land.png)

### 2. Mana value[^mana_value] separation
Split the deck into piles, categorized by mana value.
Then go through the decklist and retrieve the cards with the required quantity from the appropriate pile.

![by mana value](/assets/image/deck-partition/all.png)

This got me thinking, to perform a deck check, there are two **critical** pieces of information that we need:

1. A sorted deck
1. and a decklist.

Technique number 1 starts with a sorted deck and then uses the list. Technique number 2 starts to sort a deck, and then uses the decklist to make the remaining sorting easier.
Thus I wondered: Is there something we can do with just the list? Considering we have unlimited access to a list, and _(baring the opportunity cost of not being on the floor)_ looking at the list has no impact on the timings of a tournament.

It then dawned upon me that I know some judges that do a different permutation when checking [Modern's Tron](https://www.mtggoldfish.com/archetype/tron) than [Modern's Burn](https://www.mtggoldfish.com/archetype/burn-a2dd1132-5301-4882-907a-7b668da3b58a) for example.

Their heuristics tell them that separating Burn by `type` is less efficient than separating by `mana value`. And separating by `color` is all but useless.
Most lists run four copies of each card, and the mana values are very tightly packed. Whereas Tron benefits greatly by doing the first split by `lands / non-lands`, and then `color`.

This got me thinking, it would be great to devise a mathematical model of deck sorting to figure out what the best approach to separating a deck is. I feel we **under-use** the availability of the decklist, so having a clear plan ahead of actually getting the deck in our hands can prove highly effective.

## Defining the problem statement
I want to find a mathematical formula to aid me in minimizing the time of performing a deck check.
As I'm not a good mathematician. But I know a thing or two about _coding_. I reckon I can compute for a deck every single permutation of partition strategy; and with a way of putting a numeric value on the _cost_ of each arrangement, select the optimal.

To do so, we'll have to establish some common names and operations, and abstract away some details like “how much desk space does each technique use up”, or how to deal with a sideboard-ed deck.

Given those abstractions, we can reframe the problem of checking a deck, to one much closer to ~botanics~programming: Constructing a tree.
In my model, the process of deck checking is equivalent to building a tree, where each node holds an intermediate pile of cards that have been split by some criteria. And the leaves are piles of same-name cards ready to be cross-checked with a decklist.

To construct the procedure tree you start with a **node** with all the cards. Then for each category you want to **classify**[^partition] them, you split into **sub-nodes** with the cards that match that criteria. This way you _learn_ more about each pile.

This test may be binary (e.g.: land vs non-land) or not (e.g.: by mana value, or by color).
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

Remember you can _play along_ in the [Deck Partitioner](https://jazcarate.github.io/deck-partitioner/) web.

### 1. Type separation tree
Start with the whole deck.

![no classification](/assets/image/deck-partition/none.png)

We'll represent this deck, unclassified, like so:
```
┌──a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
└──a card
```

We know nothing about these cards yet. So we proceed by the deck into a lands and a non-lands pile.

![land / non-land](/assets/image/deck-partition/land-non-land.png)

```
┌──┌──Non-Land
│  │  Non-Land
│  │  Non-Land
│  │  Non-Land
│  │  Non-Land
│  │  Non-Land
│  │  Non-Land
│  │  Non-Land
│  │  Non-Land
│  └──Non-Land
│  
│  ┌──Land
│  │  Land
│  │  Land
│  │  Land
│  │  Land
└──└──Land
```

We now know more about each pile, but not enough to verify the deck. So we continue to split each pile by card name.

![by name](/assets/image/deck-partition/all.png)

```
┌──┌──┌──Non-Land   Primeval Titan
│  │  │  Non-Land   Primeval Titan
│  │  │  Non-Land   Primeval Titan
│  │  └──Non-Land   Primeval Titan
│  │  
│  │  ┌──Non-Land   Azusa, Lost but Seeking
│  │  └──Non-Land   Azusa, Lost but Seeking
│  │  
│  │  ┌──Non-Land   Amulet of Vigor
│  │  │  Non-Land   Amulet of Vigor
│  │  │  Non-Land   Amulet of Vigor
│  └──└──Non-Land   Amulet of Vigor
│  
│  ┌──┌──Land       Valakut, the Molten Pinnacle
│  │  └──Land       Valakut, the Molten Pinnacle
│  │  
│  │  ┌──Land       Simic Growth Chamber
│  │  │  Land       Simic Growth Chamber
│  │  │  Land       Simic Growth Chamber
└──└──└──Land       Simic Growth Chamber
```

### 2. Type separation tree
Again start with the whole deck.

![no classification](/assets/image/deck-partition/none.png)

And once more, the same text representation, with no information whatsoever:
```
┌──a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
│  a card
└──a card
```

Afterward, split each pile by type.

![by type](/assets/image/deck-partition/type.png)

```
┌──┌──Creature
│  │  Creature
│  │  Creature
│  │  Creature
│  │  Creature
│  └──Creature
│  
│  ┌──Artifact
│  │  Artifact
│  │  Artifact
│  └──Artifact
│  
│  ┌──Land
│  │  Land
│  │  Land
│  │  Land
│  │  Land
└──└──Land
```

And finally each by card name.

![by name](/assets/image/deck-partition/all.png)

```
┌──┌──┌──Creature   Primeval Titan
│  │  │  Creature   Primeval Titan
│  │  │  Creature   Primeval Titan
│  │  └──Creature   Primeval Titan
│  │ 
│  │  ┌──Creature   Azusa, Lost but Seeking
│  └──└──Creature   Azusa, Lost but Seeking
│   
│  ┌──┌──Artifact   Amulet of Vigor
│  │  │  Artifact   Amulet of Vigor
│  │  │  Artifact   Amulet of Vigor
│  └──└──Artifact   Amulet of Vigor
│   
│  ┌──┌──Land       Valakut, the Molten Pinnacle
│  │  └──Land       Valakut, the Molten Pinnacle
│  │   
│  │  ┌──Land       Simic Growth Chamber
│  │  │  Land       Simic Growth Chamber
│  │  │  Land       Simic Growth Chamber
└──└──└──Land       Simic Growth Chamber
```

The result is, as to be expected, the same.

## Evaluation
Now that we know how to construct any strategy of partitions, we need to decide which is **the best**.

In my model, I pose that the cost of each classification **is** associated with the number of _piles_[^partition] generated by the test.
It is faster to decide
 - `land`
 - `non-land`
 
than
 - `mana value=0` 
 - `mana value=1`
 - `mana value=2`
 - etc.

Not only there is much more brainpower needed to parse a card into these categories, but the physical act of placing the card in the appropriate pile is costly. This action of deciding each pile is then multiplied for how many cards need to be sorted. It does not take the same time to sort 10 cards as 100. But I reckon that the cost is linearly proportional, as it is just doing the same classification over and over again.

So to go from
```
┌──a card  >>  ┌──┌──Non-Land
│  a card  >>  │  │  Non-Land
│  a card  >>  │  │  Non-Land
│  a card  >>  │  │  Non-Land
│  a card  >>  │  │  Non-Land
│  a card  >>  │  │  Non-Land
│  a card  >>  │  │  Non-Land
│  a card  >>  │  │  Non-Land
│  a card  >>  │  │  Non-Land
│  a card  >>  │  └──Non-Land
│              │  
│  a card  >>  │  ┌──Land
│  a card  >>  │  │  Land
│  a card  >>  │  │  Land
│  a card  >>  │  │  Land
│  a card  >>  │  │  Land
└──a card  >>  └──└──Land
```

We need to go through each card ($$16$$) and with each one decide between one of two buckets. Thus the total cost is $$16 \times 2 = 32$$.
Whereas to classify like this:

```
┌──a card  >>  ┌──┌──Creature
│  a card  >>  │  │  Creature
│  a card  >>  │  │  Creature
│  a card  >>  │  │  Creature
│  a card  >>  │  │  Creature
│  a card  >>  │  └──Creature
│              │  
│  a card  >>  │  ┌──Artifact
│  a card  >>  │  │  Artifact
│  a card  >>  │  │  Artifact
│  a card  >>  │  └──Artifact
│              │
│  a card  >>  │  ┌──Land
│  a card  >>  │  │  Land
│  a card  >>  │  │  Land
│  a card  >>  │  │  Land
│  a card  >>  │  │  Land
└──a card  >>  └──└──Land
```

we again have to decide $$16$$ times, but now on four possible classifications, so the cost is much higher (_twice as high_): $$16  \times 4 = 64$$. But we end with smaller buckets.

The entire cost of a sorting technique then is adding up all the costs of each node's classification cost _(in the [web](https://jazcarate.github.io/deck-partitioner/) you can mouse over each tree section to get the drill of the cost. And the total cost at the bottom of the page)_.

I did not add a cost associated with how many levels of the classification there are, as I think it is small enough to be ignored. Though in my limited testing, it does cause fatigue if above a certain number of classifications.

Going back to the Modern Burn, the math seems to agree with their heuristic, and the most cost-efficient partition is `by mana value > by name`; whereas for Tron, the most efficient way of splitting is `by land/non-land > by color > by type > by name`.

## Request for help

I would **love** other people to experiment and time themselves to figure out if my hypothesis does hold; or if the cost of further sub-partitions is not, in fact, negligible. But rather scales exponentially each new level. I'm very curious.

If you want to help me out fine-tuning my _cost_ function costs to find a better heuristic you can very much do so by classifying some cards and measuring the time it took in [this form](https://docs.google.com/forms/d/e/1FAIpQLSffb1aN8cVwAQz6gDcjToL4EYtdIhBjYKBg58WlPBzjegChAw/viewform?usp=sf_link).

If you instead do a different classification strategy, I would be very interested in learning about it. So please feel free to comment on the [application issue list](https://github.com/jazcarate/deck-partitioner/issues).

## Playground
As I said before, I write code for a living and very much enjoy it, so I came up with a small program to do these simulations.
You can input any deck, and it will figure out all the possible ways of splitting and sorting it, and then choose the one with the least cost.

You can try it out [here](https://jazcarate.github.io/deck-partitioner/).

---

[^covid]: It's 2021 and we are still in lockdown because of the [COVID-19](https://es.wikipedia.org/wiki/COVID-19), hence why the conference was virtual.
[^deckchecks]: [Deck Check Procedures in Wizard's article page](https://magic.wizards.com/en/articles/archive/deck-check-procedures-2000-02-29).
[^mana_value]: Previously known as “casting cost”, “total casting cost” or “converted mana cost” (cmc).
[^shuffle]: I don't particularly agree that is reasonable to expect a player and their opponent to _trust_ that the deck order has not been altered.
[^absurdum]: [Reductio ad absurdum](https://en.wikipedia.org/wiki/Reductio_ad_absurdum)
[^equivalence]: [Equivalence classes](https://en.wikipedia.org/wiki/Equivalence_class) are, roughly speaking, a set of elements that belong to a class, and no other class. So an element can't be part of two different Equivalence classes.
[^partition]: For those interested in the math, I can point you in the right direction of the formalization of this: Generating a [Equivalence relation](https://en.wikipedia.org/wiki/Equivalence_relation) that yields a [partition](https://en.wikipedia.org/wiki/Partition_of_a_set).