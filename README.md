# Runner game changes

Side-by-side demo of two ways to bring items down a 3-lane road.

Open `index.html` to play. The top view steps items down the screen in even jumps. The bottom view brings the same items in from the horizon. Both roads stay still. Arrow keys, or either side of a view, change lanes. The speed control is on the lower view.

`horizon-vs-screen-spawn.pdf` is the technical note for the two projections, written for a Flutter and Flame developer.

`flame_depth.dart` is the Flame version of the two projections in the demo. Both sprites share one distance and one speed. Only the scale function differs.

To run it locally with the images loading the same way as the page:

```
node server.js
```

Then open http://127.0.0.1:8734/
