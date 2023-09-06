App start
===============
Nothing special, just clone the project or download zip, build and run it on your device or simulator.

Auth
===========
Access token is baked in + refresh token keeps it nice and shiny, so you don't need to change anything.

Architecture
===========
The project is quite small, so no fancy stuff, just plain MVP for main module. Also didn't bother with presenters for detailed views of photo and video. I chose MVP over MVC because frankly MVP is just an MVC of a healthy human :)

Features
===========
- Caching of both previews and full files were implemented.
- Pagination for better user experience
- Pull to refresh
- Working video player
- In both photo and video viewers you can tap info icon in the top right corner for details.
- Adaptive UI programatically, works great in both orientations and reacts to changes.
