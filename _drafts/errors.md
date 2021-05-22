---
layout: post
title: errors
date: 2021-05-07 17:16
categories: design
excerpt_separator: <!--more--> 
enable_mathjax: true
---

I've had discussions with several colleagues about this idea of _"errors"_. What I think qualifies as an _error_. How to deal with them. How to simply avoid them for quick prototyping.

<!--more-->
So I though I should write down my thoughts in a more eloquent and persistent fashion.

Most of the times, we use the word _error_ to reference many different things. Throughout this post I'll be specific on some terminology to, hopefully, avoid further confusion.

I take this categories from multiple sources. I would think that there should be a definitive source from where I got this second hand information; but I could not find it.

## Glossary

> **Error**: An error is a mistake, misconception, or misunderstanding on the part of a software developer
> — IEEE[^error_cite]

An error leads to a defect (variance between expected and actual results), which in turn leads to a failure (the observable incorrect behavior of the system).
But I don't particularly care about _that_ part of the process. I'm more interested in what we come to except of an error.
So from now on every time I write _error_ think not of your intuition of an _error_ but to this original definition[^communication].

## The non-errors

I've come to find that the best way to reach my understanding of an error, is though an explorations of things that I don't consider them as so.

The "original sin", so to speak. The quintessential misguided error: `3 / 0`.
Is it `NaN`? `Infinity`? panic[^panic] and terminate abruptly?
As one René Magritte might put it: This is not an error[^trahison]. This is programers being lazy. The second argument (_denominators_ for maths people) of the division (`/`) can't be zero. It is simply not defined. With denominators close to zero, the value skyrockets. But **at** zero, it is simply not defined. `3 / 0` simply can't happen[^problem_space].
But we are lazy as programmers, and we usually don't use the rich types math has to offer (e.g. $$\mathbb{N}$$) so language designers have to figure out, with absolutely no context what they should do in a `3 / 0` situation.

Javascript or Haskell yields `Infinity`[^why_finity], where Java or Ruby panic.

I'm certainly not as smart as the people that decided this behavior, but I can understand each language's implementation of these behavior.

---
[^error_cite]: IEEE Standard Glossary of Software Engineering Terminology," in IEEE Std 610.12-1990 , vol., no., pp.1-84, 31 Dec. 1990, doi: 10.1109/IEEESTD.1990.101064.
[^communication]: I understand communication is a two way process, and me writing the word _error_ with my own definition might clash with your view of what an is in the essence of an **error**. So I ask you that you read the post, lookup in your own knowledge base what word best maps with what I'm trying to describe, and let me know so we, collectively, can come to a better word for something as precise as an _error_.
[^trahison]: _Ceci n'est pas une pipe_. A famous inscription in a René Magritte painting: [La Trahison des images](https://en.wikipedia.org/wiki/The_Treachery_of_Images).
[^problem_space]: I go more in depth into how to, practically, solve these sort of things in another post: [Limit the Problem Space!](https://blog.florius.com.ar/xpost/2018/08/14/limit-problem-space/#maths).
[^panic]: Panic (go-lang, rust), throw (Java, C++), raise (Ruby), error/undefined (Haskell) are all syntax for the idea of a bottom (`⊥`). A computation that will never complete successfully. I like the use of `panic` as I feel is the most technology-agnostic.
[^why_finity]: Which is all fun and good when dealing with $$\lim$$ and differential equation. But not for everyday maths. But it is, after all in the standard: "IEEE Standard for Floating-Point Arithmetic," in IEEE Std 754-2019 (Revision of IEEE 754-2008) , vol., no., pp.1-84, 22 July 2019, doi: 10.1109/IEEESTD.2019.8766229.