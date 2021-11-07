---
layout: post
title: Dataloader, from the ground up
date: 2021-11-03 19:16
categories: design
excerpt_separator: <!--more--> 
---

Ever heard of "dataloader"? From the simplest implementation, to a batch'ing and cache'ing design pattern. Let's dive into a brief tour of understanding this useful device.

<!--more-->
## Background
Feel free to skip this section if you feel you have a good grasp on what `DataLoader` is meant to solve.

Recently, I had a very insightful talk with a colleague. Their team knew they wanted a GraphQL API, and they also wanted to develop the service in Java. So they were prototyping different wats to bootstrap  the service with and without spring. It was not long before they encountered the `N+1 query` problem. Talking about possible solutions, and the _shape_ of them was interesting enough I wanted to write a blog-post with some of the enlightening _pearls_ we found along the way.

Let's start by talking a bit about GraphQL, although it is not very interesting for the bigger picture, it helps frame a concrete example of then the broader concepts can be applied.
Implementing a GraphQL API means providing a way to _resolve_ a piece of information. Like transforming a user id into a user entity that holds it's name `java_graphql`.
For example:

```kotlin
class SingleUserDatabase(
    private val repo: UserRepository) : DataLoader<String, User?>() {

    override fun load(id: String): User? {
        return repo.findById(id)
    }
}
```

How does the code above deal with fetching multiple users? `findById` goes from one `id` to one `User`. There is no other way than running the `SingleUserDatabase#load` method over and over, for each user we need to get.
Probably the `UserRepository` already has a method to bundle more than one id, and get multiple users. But `DataLoader<KEY, VALUE>`'s API is meant to be run once for each user that it encounters in the process of resolving the bigger query. So the library burdens us, the _resolver_ writer on how to group (or not) these queries.
And maybe, at first, you would be tempted to be angry at the libraries API. After all, this all could be done on their end, and require the `DataLoader` to work with a collection, rather than a single one. I would argue that if that were the case; then I would be equally exited to implement a `DataLoader` that can be fed a method that works with collection and de-batches them to single queries.
There is just no way that GraphQL library can make a good decision on how or if it should group resolvers. So the onerous is on the application developer. You and I.

And I would dare say that this pattern of different pieces of code, needing some information of the same kind; but are wofully unaware of one another is a design choice we should strive. If we can abstract away the performance of batching and caching, and each piece of code assume it can load whatever they need, and not need to coordinate with others, but also don't incur in a performance penalty with high latency.

## A life of collections
The first task in our journey to batch requests, is to move from the single retrieving function, to a one that accepts a collection and returns a collection. DataLoader implementations will deal with errors in a much smarter and robust way; but in this blog post I'll shrug off any and all error handling.

```kotlin
class MultipleUserDatabase(
    private val repo: UserRepository) {

    override fun loadMany(ids: List<String>): List<User?> {
        return repo.findMay(ids)
    }
}
```

But we need a way to transform this method going from `List<String> → List<User?>` to `String → User?` to feed the `DataLoader` API, or any use case where we want to batch.

## Naïve
I find that doing a naïve implementation helps understand the problem. So how would we make that transformation? Ignoring batching and caching.

```kotlin
class Naive<KEY, VALUE>(
    private val inner: (List<KEY>) -> List<VALUE?>,
) : DataLoader<KEY, VALUE> {

    override fun load(key: KEY): VALUE? {
        return inner(listOf(key)[0])
    }
}

naive = Naive(multipleUserDatabase::loadMany)
```

With this code, `naive.load("foo")` would call the inner `MultipleUserDatabase::loadMany` with a list of one, and get the first element _(to reiterate: I'm not particularly concerned in handling errors)_.

### And then?
Now that we have this simple implementation, one problem might become apparent. There is no way that whoever calls the `DataLoader::load` will be able to *wait*. The calls to the `inner` _listicle_ `loadMany` happens immediately.

Implementing a blocking-naive `DataLoader` wouldn't be so difficult:
```kotlin
class Blocking<KEY, VALUE>(
    private val inner: (List<KEY>) -> List<VALUE?>
    ) : DataLoader<KEY, VALUE>  {
    private val lock: Object = Object()

    fun load(key: KEY): VALUE? {
        synchronized(lock) {
            lock.wait()
            return inner(listOf(key))[0]
        }
    }
}
```

With this new blocking `DataLoader`, hopefully it is apparent that we need a way to _un-wait_. A way to allow the execution to continue.
```kotlin
class Blocking<KEY, VALUE>(...) {
    fun dispatch() {
        synchronized(lock) {
            lock.notifyAll()
        }
    }
```

I don't know about you, but writing locks, and `synchronized` I can never be sure that my code is correct. So let's bit the bullet now, and implement the same logic, but with some other concurrency model. Rather than locking, let's make explicit when things need to happen one after another. Rather than writing:
```kotlin
val user = naive.load(5)
println("The user name is: ${user.name}")
```

let's try to write something like this:
```kotlin
naive.load(5).andThen { user ->
  println("The user name is: ${user.name}")
}
```

If this starts to look like `Promise` in JavaScript, or `Future` in Java or `flatMap` or `bind` or `>>=`; it is no coincidence. But in order to keep this entry concise, let's implement our own `AndThenable` where:
```kotlin
interface AndThenable<A> {
    fun <B> andThen(next: (A) -> AndThenable<B>): AndThenable<B>
}
```

And again, let's implement the most simple `AndThenable` possible:
```kotlin
class Sync<T>(private val value: T) : AndThenable<T> {
    override fun <B> andThen(next: (T) -> AndThenable<B>): AndThenable<B> {
        return next(value)
    }
}
```

`Sync` is created with a value, and calling `.andThen` with a function, would merely call that function with the provided value at creation.

This way, our `DataLoader` and `Naive` would change to reflect this new interface return way:
```kotlin
class Naive<KEY, VALUE>(
    private val inner: (List<KEY>) -> AndThenable<List<VALUE?>>,
) : DataLoader<KEY, VALUE> {

    override fun load(key: KEY): AndThenable<VALUE?> {
        return inner(listOf(key)).andThen { Sync(it[0]) }
    }

    override fun dispatch() {
        // Do nothing interesting
    }
}
```

At this point, we haven't made much progress, as we are not "waiting". We are worst off that when we started going for a blocking implementation. But it is easily fixable:
```kotlin
class Deferred<KEY, VALUE>(
    private val inner: (List<KEY>) -> AndThenable<List<VALUE?>>,
) : DataLoader<KEY, VALUE> {
    private val queue: MutableList<Pair<VALUE?, Defer<VALUE?>>> = mutableListOf()

    override fun load(key: KEY): AndThenable<VALUE?> {
        val defer = Defer<VALUE?>()
        inner(listOf(key)).andAccept { queue.add(it[0] to defer) }
        return defer
    }

    override fun dispatch() {
        queue.forEach { (value, defer) -> defer.push(value) }
        queue.clear()
    }
}
```

The *heavy lifting* here is being done by the idea of an `AndThenable` that can defer a computation (this `Defer`). Luckily, the code is not very long, but it is a bit dense:
```kotlin
class Defer<T> : AndThenable<T> {
    private var dependency: (T) -> Unit = { println("WARN: There was nothing depending on this Defer") }

    fun push(value: T) {
        dependency(value)
    }

    override fun <B> andThen(next: (T) -> AndThenable<B>): AndThenable<B> {
        val defer = Defer<B>()
        this.dependency = { t -> next(t).andThen(defer::push) }
        return defer
    }
}
```

A `Defer`, unlike `Sync` has no value on creation, rather a consumer of a value. It knows what to do when a new value comes along (called here a _dependency_). When such a value is then provided, via the `.push`, then the function passed on the `andThen(next)` gets called. With a handy warning if a value is pushed to a `Defer` that no one cares about[^existance_conundrum].


When asked to load, we do the naive loading, but we return a `Defer` `AndThenable`. And on dispatch, we push a value onto each `Defer` we created and clean the queue. It is a bit silly to fetch a value with `inner(listOf(key))` and store it in a queue, and afterwards (on the call to `.dispatch`) push the value on the deferred; but this implementation helps illustrate a problem that is very hard to spot. Did you spot it?
Let's take this example:
```
loader.load(6).andThen { user ->
    loader.load(user.invitedBy).andThen { invitedBy ->
        println("${user.name} was invited by ${invitedBy.name}")
    }
}

loader.dispatch()
```

Running this example has *two* problems:
We would queue the first `load(6)` with the result, but not invoke the first `.andThen` until the `.dispatch()` call. Once we `dispatch`, the first `.load(6).andThen` would try to resolve, we would queue the `.load(user.invitedBy)`; and this triggers a handy exception that we have just mutated out `queue` list whilst doing a `.forEach`. TO add insult to injury, that defer _(the second)_ `.andThen` would never resolve, as no other `.dispatch` call will ever be made. So, given that resolution of data loaders, might trigger other loads, we need to call dispatch after resolving each known action. The base case of the recursion would be when no action is left in the queue; then no more `.dispatch`es will be called; so to not enter an infinite loop.
```kotlin
override fun dispatch() {
    val cloneQueue = ArrayList(queue)
    queue.clear()
    cloneQueue.forEach { (value, defer) ->
        defer.push(value)
        dispatch()
    }
}
```

Cloning gets us out of the mutation whilst processing, and the successive `dispatch` **after** resolving the defer `.push` ensures that we run all of the `.andThen`, chained as they may be.

## Batch
At this point, looking at our naïve implementation, the one line of code that is dictating _when_ the information if being fetch, and the one preventing batching is that we are doing
```kotlin
inner(listOf(key)).andAccept { queue.add(it[0] to defer) }
```

Rather than waiting, we are fetching the information and then waiting to _return_ it to whatever dependency of the defer. That would yeild a code like this:
```kotlin
class Batch<KEY, VALUE>(private val inner: (List<KEY>) -> AndThenable<List<VALUE?>>) : DataLoader<KEY, VALUE> {
    private val queue: MutableMap<KEY, Defer<VALUE?>> = mutableMapOf()

    override fun load(key: KEY): AndThenable<VALUE?> {
        val defer = Defer<VALUE?>()
        queue[key] = defer
        return defer
    }

    override fun dispatch() {
        if (queue.isEmpty()) return
        
        inner(queue.keys.toList()).andAccept {
            val results = mapOf(*queue.keys.zip(it).toTypedArray())
            results.forEach { (key, value) ->
                queue.remove(key)!!.push(value)
            }
            dispatch()
        }
    }
}
```

So now `.load` that very little, and is the `dispatch` that does the heavy lifting. So let's look mor in depth at the `.dispatch`:
First, the base case where there is nothing to dispatch, just `return`. Then, fetch every key in the queue we have collected. Once we have the result, there is some _magic_ to find what result was for which key, and then push the result to the appropriate `Defer`. As we are cycling though the results, we don't have the problem of mutation that needed a clone. So that's good. And we are recursively calling `dispatch()` on the last line.

We got very close! but there is tiny wrinkle. We made the assumption that there would be just one `Defer` for every key we looked at. Therefore code like this would not work as we want. The first chain of `.andThen`s is utterly ignored.
```kotlin
loader.load(6).andThen { user ->
    loader.load(user.invitedBy).andThen { invitedBy ->
        println("1: ${user.name} was invited by ${invitedBy.name}")
    }
}

loader.load(6).andThen { user ->
    loader.load(user.invitedBy).andThen { invitedBy ->
        println("2: ${user.name} was invited by ${invitedBy.name}")
    }
}

loader.dispatch()
```

So, with the help of a small utility `MultiMap` (a map of multiple values for a single key), we can change the code ever so slightly to:
```kotlin
class Batch<KEY, VALUE>(private val inner: (List<KEY>) -> AndThenable<List<VALUE?>>) : DataLoader<KEY, VALUE> {
    private val queue: MultiMap<KEY, Defer<VALUE?>> = MultiMap() // Now a MultiMap

    override fun load(key: KEY): AndThenable<VALUE?> {
        val defer = Defer<VALUE?>()
        queue.addOne(key, defer) // was just a `.set`
        return defer
    }

    override fun dispatch() {
        if (queue.isEmpty()) return

        inner(queue.keys.toList()).andAccept {
            val results = mapOf(*queue.keys.zip(it).toTypedArray())
            results.forEach { (key, value) ->
                queue.remove(key)!!.forEach { defer -> defer.push(value) }  // was a single `.push`
            }
            dispatch()
        }
    }
}
```

## Cache
We are so close! We have the ability to batch requests, but there is still one very minor inconvenience:

```kotlin
loader.load(5).andThen { user ->
    loader.load(5).andAccept { user2 ->
        println("${user!!.name} == ${user2!!.name}")
    }
}
```

Would fetch `5` **twice**. There is simply no way that we can batch fetches that are inside `andThen` with ones outside it. But not all hope is lost. We can, in some very specific circumstances, bypass the fetching altogether. If we had made the call to the `inner` before. So what if we, before calling `inner`, check in a local cache if we already have the value, and just provide it:

```kotlin
class BatchCache<KEY, VALUE>(private val inner: (List<KEY>) -> AndThenable<List<VALUE?>>) : DataLoader<KEY, VALUE> {
    private val queue: MultiMap<KEY, Defer<VALUE?>> = MultiMap()
    private val cache: MutableMap<KEY, VALUE?> = mutableMapOf()
    
    // .load is the same

    override fun dispatch() {
        if (queue.isEmpty()) return

        queue.filterKeys(cache::containsKey)
            .forEach { (key, _) -> queue.remove(key)!!.forEach { it.push(cache[key]) } }

        inner(queue.keys.toList().minus(cache.keys)).andAccept {
            cache.putAll(results)
            // ... 
        }
    }

}
```

This can even have the upshot that cached requests might enqueue even _more_ new dependencies, and we would be bundling them all together in a single bigger request.

## Don't use this code on production!!
I found it very enlightening trying to re-implement this pattern, and how I got to this solution. But as I stated, this code is very much not production ready. It was never it's intention. For a production application of a DataLoader in Java, there is [java-dataloader](https://github.com/graphql-java/java-dataloader), which deals with a lot of things, is very tested, and has a lot of useful comments. Or even going to the source: [dataloader](https://github.com/graphql/dataloader). The code is not that long to spelunk, and is gain tested and commented.

All the code explained here, and some playground can be fount in this repo: [GitHub :: simplest-data-loader](https://github.com/jazcarate/simplest-data-loader).


---
[^existance_conundrum]: [If a tree falls in a forest…](https://en.wikipedia.org/wiki/If_a_tree_falls_in_a_forest).