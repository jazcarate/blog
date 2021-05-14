---
layout: post
title: Desire Driven Development
date: 2021-05-12 20:45
categories: rambling coding
---

> **Desire** _verb [ T not continuous ] /dɪˈzaɪər/_
>
> to want something, especially strongly.
>
> — [Cambridge dictionary](https://dictionary.cambridge.org/dictionary/english/desire)

Long have I heard and reaped the benefits of TDD (_Test Driven Development_).
But I'm starting to see that much of the material written and explained about TDD is by fanatics.
Don't get me wrong. I see the value when learning a new tool to _overcompensate_.
If you have never written a test before coding, then I'm all in for trying for a month or two to **always** write a test before, write the least amount of code, and iterate.

As with most tools, the implementation is as important as to knowing when to use it, and when not to[^hammers].

I like the analogy of this learning as an infection. It may be because I'm writing this amid a pandemic, or that the experience was explained to me as being “test-infected”. But either way, I think that **TDD is a bacteria**.

Not all bacteria are bad. Some are cute and cuddly[^acidophilus] and helps in our digestion. But some are mean and make out belly ache. In order to protect yourself, you need to build up an immunity. And there are, broadly speaking, two approaches:

  - The risky way is to contract the infection. Set out to TDD **all the things** for a while. Don't question it, just do it.
  - The hard way is to develop and apply a vaccine. Analyze when to apply the technique; how to simplify a problem or a part of the problem to attack it with TDD. This is **difficult** to do right, but you can work at it little by little until you develop a potent response.

You **can** have too much of a good thing.

I've come to terms with the idea that I no longer do TDD, but my take of it: **Desire Driven Development**.
When discussing this blog entry, many people did agree that they also find a middle ground between strict TDD and testing[^testing] code.

## Desire-Driven Development by Example

If I want to become a famous author, I need to distill the idea down to a few, simple, easy to comprehend steps. Bonus points if they form an acronym.

1. Start with your <span style="font-size: 1.3em">S</span>cratchpad. This can be a new test suite. extending an existing one. If your language/technology allows for an interactive workspace or REPL, those too can work. Anywhere where you can code, and it can eventually be run.
2. <span style="font-size: 1.3em">A</span>ssume that all the code is done already. All features implemented. No bugs. Well-designed, neat, and functional.
3. <span style="font-size: 1.3em">W</span>rite down the acceptance criteria and what the expected outcome should be. Remember, all the classes, methods, functions that you want *exist* already, and work exactly as you expect.
4. <span style="font-size: 1.3em">F</span>ollow down the compile errors, missing methods, classes, runtime checks, et al. until your scratchpad does indeed work as you intended.
    - It might come the time where you'll need to update the criteria written in step 3. You are allowed to do so **but** you need to first think hard about the change.
5. _(unchanged[^beck])_ <span style="font-size: 1.3em">R</span>efactor as needed.

### S.A.W.F.R.

The linchpin of this technique is that I usually want to write and read code in the same way.
There is no feasible way that I can know what other people will understand when, in the future, they reason about my code. But I am constant[^theseus]. Then I should strive to produce code that astonished me the least[^POLA]. Hopefully, like minded individuals will be equally un-astonished.

And bare in mind, this original code in step 3 has no concept of the inner workings, the details, the implementation. Pure and unadulterated issue-resolving code.

If I gave you my 5 letter acronym[^acronym], I can top it of with a 5 words summary:
> TDD, but lightweight


## The same, but different too

The major distinction between TDD and Desire Driven Development is that the latter focuses on the _outer most_ implementation. The technique spends a lot of time thinking, contemplating, and in awe of what the final implementation will feel like.
Anything that is needed to make step 3 possible, I don't care about testing, or developing. I'll go so far as to say, I would like to have the most freedom of changing it at a whim. Writing tests for this inner layer makes change harder.

## Hairy step 4.

It might come a time where I have a complicated piece of logic that I wished was already there. Then I usually _Shahrazad_[^shahrazad] and DDD again from that point onwards. But this is a conscious decision I make. I don't zealously write tests for each intermediate abstraction.

Sometimes, I need to change the beautiful code written in step 3. That is because my squishy human brain[^cognitive_dissonance] can cope with the inherent vagueness of my desires, without considering the minutia required for it to be codable, but more often than not; when I realize that additional contextual information is needed (like an extra parameter; or a fatter way of building the environment), I look back at my original assumption and try to make that the default behavior, with as minimal code change to the original desire.

## The water shapes the rock, and the rock shapes the water

Whilst writing this, I realized that I, personally, am a big fan of writing my custom DSL[^DSL]s.
I like languages that allow me to express these DSL with little to no extra syntax and I gravitate to statically typed languages with good inference and tooling.

Bonus points when the language's bottom[^perp] helps the compiler insert error messages which are more appropriate to the context in which it appears[^undefined], or in runtime when `throw Error()` caries with it the stack trace.

These all are great characteristics to have for DDD.

## Closing thoughts

Maybe DDD is not for everyone or every use case, but it is how I usually code 😺.

---
[^acidophilus]: I'm not affiliated with Giant Microbes, but [this plush](https://www.giantmicrobes.com/us/products/acidophilus.html) just too cute to pass up.
[^testing]: I don't think that putting “testing” and “TDD” at the two ends of the spectrum of writing code is a newfangled idea.
[^POLA]: [Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment)
[^DSL]: [Domain-specific language](https://en.wikipedia.org/wiki/Domain-specific_language)
[^shahrazad]: There is a card in Magic: The Gathering™ called [Shahrazad](https://gatherer.wizards.com/pages/card/details.aspx?name=Shahrazad) that represents a function call, with its stack and return point. It states: “Players play a Magic subgame, using their libraries as their decks. Each player who doesn't win the subgame loses half their life, rounded up.”
[^perp]: Bottom (&perp;) refers to a computation that never completes successfully. 
[^undefined]: Almost verbatim [Haskell's Prelude `undefined` docs](https://hackage.haskell.org/package/base-4.15.0.0/docs/Prelude.html#v:undefined)
[^cognitive_dissonance]: Cognitive dissonance occurs when a person holds contradictory ideas. — (Wikipedia)[https://en.wikipedia.org/wiki/Cognitive_dissonance]
[^theseus]: The Ship of Theseus is a thought experiment that raises the question of whether an object that has had all of its components replaced remains fundamentally the same object — (Wikipedia)[https://en.wikipedia.org/wiki/Ship_of_Theseus]. I reckon for this particular aspect of my code reasoning abilities: I'll always be the same, or more knowledgeable.
[^hammers]:  “If the only tool you have is a hammer, to treat everything as if it were a nail.” — [Wikipedia](https://en.wikipedia.org/wiki/Law_of_the_instrument)
[^beck]: _“““inspired”””_ by Kent Beck's Test-Driven Development by Example step 5: Refactor as needed.
[^acronym]: Yes. It is an [acronym](https://en.wikipedia.org/wiki/Acronym). It should be pronounced as a word. I won't have another /gɪf/ vs /dʒɪf/ pronunciation battle. So I'm deciding that the pronunciation of SAWFR is: /bɑb/
