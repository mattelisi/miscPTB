## miscPTB

Set of miscellaneous functions to create visual stimuli using Matlab and the Psychtoolbox. 

They generally assume that `scr` is a matlab structure containing information about the visual display. In particular `scr.main` is the pointer to the open onscreen window, which should have been opened with something like:

```scr.allScreens = Screen('Screens');
scr.expScreen  = max(scr.allScreens);
[scr.main,scr.rect] = Screen('OpenWindow',scr.expScreen, [0.5 0.5 0.5],[],32,2,0,0);
```
The eye tracking functions also refer to a logical flag `const.TEST`, which is set to 1 when the eyewink is launched in dummy mode.