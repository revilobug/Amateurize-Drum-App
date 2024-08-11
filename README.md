# Amateurize: Drum App

![full_title](https://github.com/user-attachments/assets/1ff33b68-c18c-47c9-9595-229e250d38f7)

## Overview
This project offers an alternative representation of music to conventional score notation. Inputting any percussive MIDI file yields a Guitar Hero-style interface where notes spawn and scroll down the screen in rhythm. Drummers can use the app to learn new songs simply by timing their real-world strikes with in-game notes.

![ezgif-7-b15ada0cbe](https://github.com/user-attachments/assets/d07bb311-8084-410b-9a8e-bb02e80e4abc)

## Background and Motivation
I began developing this app last summer when I took my first serious foray into the drumming world. I was spending the summer on campus working a research internship, and on the less busy days, I would take the trek down from my apartment to the music building where a drum kit lay tucked in the basement. I learned by covering the songs I liked. First "Smells Like Teen Spirit," then "Californication," then the likes of "Santeria" and "Can't Stop." 

But it was when I had committed myself to learning the piece from Whiplash that I ran into the problem which inspired this app. Whereas all the songs I had learned previously followed 4/4 time, "Whiplash" was in 7/8 time. This meant that the congenial "one-e-and-a" counting pattern which had taken me through the songs of prior no longer cut it. Instead, counting in 7/8 requires breaking measures down into uneven 3-4 or 3-2-2 patterns; in other words, counting in 7/8 time was a cut above my paygrade. I was frustrated. The intuitive and almost primitive nature of the drums--creating rhythm by striking various objects on beat--was what drew me to the instrument to begin with. Diving into music theory and learning 7/8 time just to play a song made drumming feel more like homework than a relaxing hobby. 

Furthermore, knowing that some of the greatest players like Chad Smith and Buddy Rich never learned to read music altogether further radicalized me that good drumming came from grasping the feel of the rhythm rather than formalizing it into rigid time signatures. I felt like scored notation was hindering and limiting rather than assisting my understanding of music. It was in this state of mind that I first envisioned this project: a complete reduction of music into as simple of a representation as I could imagine. Mechanically following the app by playing note by note could in theory produce a faithful reproduction of a given song. Though in practice, this app is only meant to be the first step in learning a groove. It provides a low-cost entry to any rhythm by bridging the gap between technical proficiency and musical intuition, allowing players to develop their rhythm naturally without being bogged down by the intricacies of music theory. 

## Video Demo and Features
^ Click for a video demo:
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/ylDtQ4UvGfE/0.jpg)](https://www.youtube.com/watch?v=ylDtQ4UvGfE)

### Features:
- Pause and Play
- Rewind/Fast forward capabilities
- BPM Changing
- Custom sprites and UI

### Under-the-hood features:
- Native Swift MIDI Parser
- Native Swift rewindable stream reader
- Unified and comprehensive render loop

## To-do Agenda

### Quick fixes
- Update/play around with parallax backgrounds
- Add a slider/scrubber on screen to move to specific parts of song
- Looking into upgrading the drum audio one-shots

### Long term goals
- Adding a library of pre-installed songs
- Support connecting to a electric drum kit
