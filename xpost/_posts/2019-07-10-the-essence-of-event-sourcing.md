---
layout: post
title: The essence of Event Sourcing
date: 2019-07-10
excerpt: >-
    Event Sourcing is a somewhat trending topic, and you can find a lot of blog posts on what event sourcing supposedly is.
    I’ll throw my wrench in the works and try to explain what I see as “Event Sourcing”.
canonical_url: https://blog.10pines.com/2019/07/10/the-essence-of-event-sourcing/
---

_Original post can be found in the [10Pines blog]({{ page.canonical_url }})._

Event Sourcing is a somewhat trending topic, but by no accounts a new one. Right now you can find a lot of stories on how to event Source in Rust, Kafka or PostgreSQL, but I've found a lack of high concept blog posts on what **is** event sourcing… or rather, I've found an overwhelming amount of supposedly event sourcing posts, all talking about a lot of different things (I’m looking at you CQRS).

<script type="text/javascript" src="https://ssl.gstatic.com/trends_nrtr/2431_RC04/embed_loader.js"></script>
<script type="text/javascript">trends.embed.renderExploreWidget("TIMESERIES", {"comparisonItem":[{"keyword":"Event Sourcing","geo":"","time":"today 5-y"}],"category":0,"property":""}, {"exploreQuery":"date=today%205-y&q=Event%20Sourcing","guestPath":"https://trends.google.com:443/trends/embed/"});</script>


So, I’ll throw my wrench in the works and try to explain what I see as “Event Sourcing”, not by actually going into any technical details, but rather into how we solve a problem on that subject.

## Backstory (Sourcing Events)

We had a small internal app that we used in big meetings to serialize conversations. Think of it as an over-complicated, over-designed queue. The app had a backend and a frontend, both which shared the particular state that the app should show to the user.

Basically: Who was talking, and who comes next.

The app kept all of our smartphones in sync. Whenever someone, say Joe, pushed the “I want to talk next” button, the backend did all the computations to add him to the end of the queue, and all of our smartphones got the message with the new state to display. Joe was now on the queue. Waiting.

This was good enough for several meetings but we, as a tech savvy company, wanted more! So, of course, we added features like emoji support to 👍, 👎 and ask that the speaker would wrap up (🌯).

So far, no Events to be Sourced whatsoever.

After a new round of emoji-enhanced meetings, I wondered: How many 👍 did I had when I spoke last week?

I had no way of knowing. The backend was *updating* the list of reactions every time a new speaker’s turn was up. And therein laid my problem. I never considered that after the meeting I might want to know something as simple as that.

So we put on our thinking hats and settled on a simple heuristic:

**No Updates. No Deletes.**

## The actual potato (Eventing Source)

No Updates, no deletes might look like a daunting feat. How would we [reflect reality](https://blog.10pines.com/2019/05/27/reifying-problems-in-our-software/) without the basic premise that **things change**. Luckily, we have functional programing close to our hearts here at 10Pines, and we can imagine a world where “things are immutable”.

So we had a frontend that was sending the intentions. What the user wanted to do. I will call this intentions **Events**.

We had 3 major events:

  - “I want to talk” event.
  - “I don’t want to talk anymore” event
  - “I want to react with a 👍” event

Notice this were not _“Add me to the queue”_, or _“Now the speaker has 5 👍”_, but rather the intention the user had.

Now, the backend had to receive these events, and instead of **updating** its state, saving it and broadcasting it; we were saving the event and computing a new state (based on the previous state and this new event)

| Previous state | Event | Current state |
|---|---|---|
| `{ currentSpeaker: Joaco, queue: [] }` | Dave wants to talk | `{ currentSpeaker: Joaco, queue: [Dave] }` |
 	 	

And, you guessed it: the previous state was **itself** computed with its previous state plus the last event before this new one. So on and so forth.

| Previous-previous state | Event | Previous state |
|---|---|---|
| `{ currentSpeaker: nil, queue: [] }` | Joaco wants to talk | `{ currentSpeaker: Joaco, queue: [] }` |

We changed from a state that was being updated, to adding onto a list events, and finding out the new state computing every event and how they changed the state. No information can be lost. Ever. **No updates. No deletes.**


## Back to the original question (Source Event)

How many reactions did I have. Well, now I could figure this out. I just needed to replay all the events, but now, instead of having a state that had the whole queue, I’d use the events to transform a different, more useful state:

| A state | Event | New state |
|---|---|---|
| `{ reactions_joaco_had: 0 }` | Joaco wants to talk | `{ reactions_joaco_had: 0 }` |

| A state | Event | New state |
|---|---|---|
| `{ reactions_joaco_had: 0 }` | I want to react with a 👍 | `{ reactions_joaco_had: 1 }` |

_*This is an oversimplification because we would still need to know who was talking at the time to know if we had to increment the reaction counter or not._

This is called a projection, and it is the way we can “fold” our events into relevant information.

## Lets recap (Evented Source)

We changed the way we thought of our storage. Rather than update what we know, we add to an infinite list the events that change our domain.

This way, we can _replay_ those events and answer questions we never thought we wanted to ask at the time of writing the code.

## Food for thought:

I wanted to keep this post short and high-concept; but I’ll let the reader think of some interesting things that steam from this kind of approach:

  - If we ever botched the part of the system that computed new states; we could rollout a fixed version, and replay the whole history of the application, and the error would cease to exist.
  - Structural changes to the database stop being something to worry about. We are only storing events, and those don’t change often. Rolling back and replaying the history is the fabric of event sourcing.
  - The new state doesn't need to be computed from the first initial state, along with all the events thereafter. We can periodically take “snapshots” of events, and compute newer events from that saved state.
  - The same stream of events can be used by many applications, each having their own projection to answer a wildly different set of questions.

