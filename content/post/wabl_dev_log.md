---
title: "Waabl"
date: 2023-12-30T15:29:38-08:00
draft: false
tags: ["ios"]
summary: a rarely updated and poorly organized account of my progress on my first iOS app
---


* [Download Waabl](https://apps.apple.com/us/app/waabl/id1671041620). 

At the beggining of 2023 I started working on a Chinese Word of the Day
application in hopes of improving my iOS skills. A friend of mine
and I were sitting in a coffee shop and I asked him to name my app. He
came up with the name "Wobble".... but that was taken so I ended up having to 
name it [Waabl](https://apps.apple.com/us/app/waabl/id1671041620). 
It's a silly name devoid of meaning and yet I have ground fond of it.

Apple accepted Waabl to the all mighty app 
store during WWDC23. Getting the app published was a major milestone but I 
still have a long ways to go until I'm happy with it.

## 2025 March 24th.
- Can't believe I am still working on this app.
- I want to ship this update before my birthday. 

## Update to dev branch 10/19
The app now has the following features
* Cloud sync with de-duplication.
* Basic widget
* An ugly green button that you press to update word status.

It has taken quite a while to get here. In the end I had a realization when
I sat down with a notepad and thought about why the widget was not updating.
It was because the widget was doing a fetch request that relied on cloud kit
yet I had set up the widget to only use a local version of the store. So
it was not getting notified about the updates. 

At that point I decided maybe my widget doesn't even need to do a fetch 
request at all. Instead I decided to make use of `UserDefaults`. 

So now, whenever the main app updates the current word I 
1) encode and write the current word to `UserDefaults`
2) reload the widget timeline.

I'm not sure why I resisted this solution originally. Next steps are to
refactor the code for this current commit and get ready to publish to the 
app store :)