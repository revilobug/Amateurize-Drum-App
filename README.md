# Amateurize: Drum App

An app that simplifies drum sheet music. Inputting a MIDI File results in a guitar-hero style game where notes scroll to the side of the screen. Comes with the ability to slow down beats to work on complex rhythms or speed up beats to challenge yourself. 

![Simulator Screen Shot - iPhone 13 Pro - 2023-08-22 at 00 53 48](https://github.com/revilobug/Amateurize-Drum-App/assets/61512660/853d0e8a-0c3e-431a-942d-44cbb7ed8839)

I started learning to play the drums a year ago. I had some experience playing the saxophone in a jazz band in high school, but I wasn't good enough to play by ear when it came to the drums. What I started doing was finding the sheet music to songs that I already knew and practicing playing the drum tracks. With 4/4 time pieces, counting was relatively straightforward--one e and a two e and a--but when it came to even slightly more complex time signatures like 7/8, I was lost. I looked online but the counting methods were all messy and made learning pieces feel like homework instead of a hobby.

![gif1](https://github.com/revilobug/Amateurize-Drum-App/assets/61512660/29875a32-007f-40b8-9633-4c8ce8499bed)

I ventured to create this app because how I ended up learning the Amen Break was by slowing down a YouTube video until all sense of rhythm and cohesion was broken. When the song was slowed down enough, I didn't need to think about timing, but instead, just smack the drum when the time was right. 

![gif2](https://github.com/revilobug/Amateurize-Drum-App/assets/61512660/217993f7-4fd1-4e2b-9dab-8e2c891600c1)

My envisioned usage of this app is the same. Load up a track. Slow it down. And simply smack when the note falls in place. Then gradually speed the track up after a few repititions.

## Key Elements

- MIDI Parser in Swift 
- Buffered Binary Stream Reader
- Sidescroller graphics rendering

## To-do Agenda

- Find sprites and assets
- Time Reversal (5s, 10s, 15s...)
- Loop Markers (Create an infinite loop by setting two markers)
- Audio On/Off
