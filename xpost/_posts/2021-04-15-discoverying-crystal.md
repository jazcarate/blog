---
layout: post
title: Discovering Crystal
date: 2021-04-15
canonical: https://apiumhub.com/tech-blog-barcelona/discovering-crystal-language/
---

_Original post can be found in the [ApiumHub blog]({{ page.canonical }})._

Another in the series. Check out other languages we’ve explored in the past at:

  - [Discovering Vue 3](https://apiumhub.com/tech-blog-barcelona/discovering-vue-3-features/)
  - [Analyzing functionalities in Rust](https://apiumhub.com/tech-blog-barcelona/discovering-rust/)

A bit of background about me before we begin our exploration of a new programming language.


I’ve been in love with programing languages for a couple of years now. I’m very interested in their semantics, the reasoning of why their designers chose to do `X` over `Y`, and why they outright discarded `Z`. I’ve done my fair share of DSLs in my tenure as a software developer for both fun and profit; so programming languages are the reasonable “step up” to be interested in.

As such I’m always in the lookout of up-and-coming languages.


## Why Crystal?

Long time ago, far far away I was working with Ruby on Rails on a project with other very skilled Ruby and Rails developers. As many others working with Ruby, we liked it’s syntax, it’s ease of use, it’s dependencies (gems) but had some issues with it. Every programming language does.


Honestly, performance was not my main driver to look to other programming languages, even though in many [benchmarks](https://github.com/kostya/benchmarks#readme) Crystal does excel.

I was more concerned with safety and documentation. Let me explain.

## Safety

Whilst programming in Ruby, I many times had an error where an object I thought was a `Hash` was actually a block, or a string was in fact a number. Many times a test would just fail or panic, and it took a minute to look at the trace, maybe put a breakpoint. Pry open the execution. Realize there was a branch of the code that did not set a key in an `options` parameter that got passed along and I did not account for. Fix it and continue coding.
`undefined method ‘foo’ for nil:NilClass` was particularly recurring in my development cycle.

## Documentation

Here I’m not referring to the actual docs I can find in Ruby Doc but rather how much information can the IDE help me out with. I’m a big proponent of making tools to help development, but having to hydrate an `options` hash to send to a gem’s method and having to yield to look at the gem’s code to understand what values are even available, is a big reason why I enjoy typed programing languages so much.

```java
class FooConfiguration {
    String bar;
    Integer biz = 3
}

void foo(FooConfiguration options) { … }
```

At a glance (and with IDE support), one can deduce that `foo`’s options have a required `bar` string, and a `biz` that defaults to 3. Where as a similar code in Ruby could look like this:

```ruby
def foo(options):
  # …
  enc = options.bar.encoding #Oh, so `bar` is a string. Gotcha!
  # ... 
  (options.biz || 3).times { puts enc } # if `biz` is falsey, then `3`. Can I send a boolean? Oh, no, it `#.times` it, so it is a number. 🤕 
  # ...
end
```

Both these pain points were addressed, interestingly enough, by the same approach: *Types*.

In Crystal there is a very smart, very competent compiler that keeps track of the busy work of knowing what methods any reference might have, if it is `nil` or what can and can’t be done to an object. This was a godsend.

As luck would have it, I was also in close contact with some very vociferous advocate of Crystal. You can imagine, with the tagline: _“Fast as C, Slick as Ruby”_, I was hooked.

My breakout project, the moment I really “got” Crystal was when we needed some dashboard like solution. We realized we had built too many internal tools and no one place to cluster them all. For whatever reason we didn’t want some static lame webpage. We decided to roll out our own. Some YAML parsing, some macro goodness and a lot of type safety later we had it running. Adding apps was simple and a CI build made sure that all the things were correctly wired. It was a small project, probably way overengineered; but onboarding another Ruby developer was incredibly simple. That was a good selling point.

## Why Crystal now?

_That’s leading the subject, your honor!_

Recently™ the nice people of Crystal announced [the release of Crystal 1.0](https://crystal-lang.org/2021/03/22/crystal-1.0-what-to-expect.html) - Production ready, stable and useful standard library all in a tight little bundle; so if it was ever the time to seriously look at Crystal; I would say today is the day.
Other awesome features
Type ergonomics

We talked about type safety, and some might have rolled your eyes expecting a very verbose way of writing the code; but let’s not forget one of the key drivers of Crystal is to have a similar syntax to Ruby. A dynamically typed language. So both:

```ruby
class Foo                                                                  	 
  def biz
    puts "foo"
  end
end

class Bar
  def biz
    puts "bar"
  end
end

def invoke_biz(x)
  x.biz
end

invoke_biz(Foo.new) # => foo
invoke_biz(Bar.new) # => bar
```

Is both valid Ruby and Crystal. You can try that out in your browser in [the crystal playground here!](https://play.crystal-lang.org/#/r/apl0) No type to be seen, thanks to the incredible type inference that comes with Crystal’s compiler. There is much cool things about it that I would need entire new blog posts to write, luckily [Crystal’s book](https://crystal-lang.org/reference/index.html) does a good job covering the basics: [Type inference](https://crystal-lang.org/reference/syntax_and_semantics/type_inference.html).


## YAML / JSON / XML

It’s amazing how useful it is to have such a robust parsing library already in the standard library, no need to deal with extraneous dependencies to read a configuration file, or write one out.

```crystal
require "yaml"

class Bar
  include YAML::Serializable
  property biz : Float64
end

class Foo
  include YAML::Serializable
  property foo : String
  property bar : Bar?
end
```

That’s all the code needed to parse something like

```yaml
foo: hi!
bar:
  biz: 3.2
```

The same holds for JSON and XML.
I find it baffling how, when reading and writing configuration is so easy, much more customization I allow when developing tools with Crystal.

## De-centralized shards

Maybe as I’m getting older, I’m getting more paranoid about where my dependencies (which run, for all intents and purposes, arbitrary code that gets deployed on my behalf) are fetched; but I can’t/won’t wait for a cabal to approve a new dependency. Being able to choose either a local file or any `git` provider gives me a bit more peace of mind.

## The logo… It’s alive, it’s moving, it’s alive, it’s alive!

The black logo in the [Crystal’s home page](https://crystal-lang.org/) is interactive. You can click and spin it around.
At first glance, one can brush off that fact, thinking it is superfluous and useless; but I would urge you to wander: Would a *bad language*[^1] such a polished home page, such well [written tutorials](https://crystal-lang.org/reference/getting_started/), such [active community](https://crystal-lang.org/community/)? 🤔

## Where to now?

If you are interested, you can keep learning Crystal with [the book](https://crystal-lang.org/reference/getting_started/) and the [online playground](https://play.crystal-lang.org/#/cr). Have a look at the [awesome-crystal](https://github.com/veelenga/awesome-crystal) compiled list of things, some might inspire you in your current or next project. [Reach out](https://crystal-lang.org/community/).

---
[^1]: reader’s interpretation of what a bad language might be.
