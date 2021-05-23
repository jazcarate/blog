---
layout: post
title: Limit the Problem Space!
date: 2018-08-14
canonical_url: https://blog.10pines.com/2018/08/14/limit-problem-space/
tag: design
excerpt: >-
    Simply put, the “problem space” is the entire spectrum of inputs that exists in the process of finding a solution to a problem.
    How can we make our code less error-prone? In this post I explore some of the ways we can do so. Join me!
---

_Original post can be found in the [10Pines blog]({{ page.canonical_url }})._

## Write less error-prone code.

First things first: What is the problem space?
Simply put, it is the entire spectrum of inputs that exists in the process of finding a solution to a problem.
Say you want to buy a soda from a vending machine. You now have a problem to solve: “Decide what beverage to purchase”. Every button is part of the problem space; yet you can narrow it down to just buttons that get you a can.

## Down to business

In order to present my idea, let’s take a somewhat simple example. a TennisMatch object, that represents just that: a tennis match.

{% highlight java %}
TennisMatch williamsVsPetrova = new TennisMatch(...);
{% endhighlight %}


One thing that a `TennisMatch` should keep track of is its score. Let’s assume the match is responsible of doing this with a `score` method. We have several design options:

  1. `williamsVsPetrova.score('williams')` / `williamsVsPetrova.score('player1')`
  2. `williamsVsPetrova.score(0)`
  3. `williamsVsPetrova.scorePlayer1()`

Most of the times, we’d go for alternative 1 or 2. This makes our code look something like this:

_Please bear with me for the sake of this example, because we are going to be using a dictionary with the player (whichever their representation: `String`, `Integer` or `Player`) as the key, and their score as the value. This decision in and of itself is not important, but rather a way to scaffold the point I’m trying to get across._

{% highlight java %}
public class TennisMatch {
    private Map<String, Point> points;
    ...
    
    public void score(String player) {
        points.get(player).scoreAPoint();
    }
}
{% endhighlight %}

Which would lead to several unwanted ramifications:
What if...

  - the `player` parameter is not in our `Map`?
  - the player is null?
  - the player key is in the `Map`, but the value of the map is `null`?

Before talking about how can we can improve our code, let’s take a minute to think how the latter in particular might be easily fixed.

We could avoid it altogether (and maybe the other ones) by forcing the `TennisMatch` creation to have two players and making those players have a valid starting score.

## Maths!

Let's jump briefly to another situation.

Suppose that we wanted to solve the following problem:

    If we have 3 minutes for a presentation,
    and we need to equally divide them between n students,
    how many minutes would each student get?

A method that would solve this problem might look something like this:


{% highlight java %}
superDivide(Object amountOfStudents) { 
  return 3 / ((Integer) amountOfStudents);
}
{% endhighlight %}

Of course, it doesn’t make much sense to accept an `Object` in the method signature, since we already know we are going to be dealing with numbers. And, mind you, because [downcasting](https://en.wikipedia.org/wiki/Downcasting) stinks.

So, based on what we already know, we could avoid downcasting, limiting the possible inputs from `Object` to `Integer`:

{% highlight java %}
superDivide(Integer amountOfStudents) {
  return 3 / amountOfStudents;
}
{% endhighlight %}

I'd ponder this is not much better.
With a keen eye for finding problems, one might realize that if the parameter were `0`, the program would explode.
Say this is not what we want, because we know that we are dealing with an amount of students, `n`. And `n` should never be zero. _Nor should it be less than zero_.
This suggests to me that our method is accepting a problem space much much larger than what we actually can and should be able to handle.

We could take two paths to fix this:

  - Preparing for the worse and checking for this restrictions to be met inside our method

{% highlight java %}
superDivide(Integer amountOfStudents) {
  if( amountOfStudents <= 0 )
    throw new InvalidAmountOfStudents(amountOfStudents);
  return 3 / amountOfStudents;
}
{% endhighlight %}


  - Deal with the problem head on, and limit the problem space!

Math has a name for this kind of numbers: [Natural numbers](https://en.wikipedia.org/wiki/Natural_number). Java does not. At least not out-of-the-box. But we can create the `NaturalNumber` class!

This way, we wouldn’t need to be prepared for those edge cases, since we’d have limited the input of our method, and deal only with valid numbers:

{% highlight java %}
superDivide(NaturalNumber amountOfStudents) {
  return 3 / amountOfStudents;
}
{% endhighlight %}

Java does not have an object to handle the filter for unauthorized users on a rest API call either, yet we are eager to create `UnauthorizedUserFilter implements RESTFilter`. I don’t usually see simple _problem limiting_ classes like `NaturalNumber`. It baffles me.

## Argumentative

Back to `williamsVsPetrova.score`. Let's think about this problem as a math _function_. Its [domain](https://en.wikipedia.org/wiki/Domain_of_a_function) **should be only two** values. One for each player.
Now, lets analyze the parameter types we mentioned above:

  1. `public void score(` `String` `player)`: The `String` type is infinitely _(disregard limited memory problem)_ large. So it might not be the best type.
    If we do go for this option, we will be forced to do some assertions if the name is one of the player participating in the `TennisMatch`.
  2. `public void score(` `Integer` `player)`: Same as 1., but with added obfuscation. Please don't.
  3. `public void scorePlayer1()`: No parameter means the domain size is only one. We are half way there!
    We re now forced to implement public void scorePlayer2(). The code for these two methods might be conspicuously similar, so we might refactor them like so:

{% highlight java %}
public void scorePlayer1() {
    scoreFor('player1');
}
public void scorePlayer2() {
    scoreFor('player2');
}
private void scoreFor(String scorer) {
    ...
}
{% endhighlight %}

  Although we are using a `String` with its infinitely large domain space, the method is private and we are sure that the only possible calls are with one of two valid values.

  4. public void score( Bool player): In spite of the fact that the the Boolean type might fit our domain-length restrictions; think about how it will look like when used:

{% highlight java %}
williamsVsPetrova.score(false); //Ball for Petrova ?!
{% endhighlight %}

## A side note on the language

I used Java throughout the post, and although I took advantage of the fact that Java is [strongly and explicitly typed with static type checking](https://en.wikipedia.org/wiki/Type_system#Static_type_checking), this principles are not language-specific.

## Bonus: Make the problem space explicit!

Since a method can have its argument either `null` or an actual value; rather than have a comment, use a `type` that represents both cases _(`Optionals` in the case of Java)_.

## Recap

  - [Constructors](https://en.wikipedia.org/wiki/Constructor_(object-oriented_programming)) are important. If you can't build invalid objects, then you can write code assuming the objects you interact with are valid. This can save you many headaches.
  - Don't be afraid of creating classes with the sole purpose of delimiting your problem space.
  - Thinking about the domain space of a method, albeit a good technique, is not the only one. Think of it as an extra tool in your tool belt.
