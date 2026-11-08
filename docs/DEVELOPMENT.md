# Developer configuration — local Rev. 1.0

Technical documentation for maintainers, not player-facing help.

## Rules laboratory

The standard build hides and disables its menu entry and removes the lab-specific
help line. To enable a technical build, set this project setting in project.godot:

```ini
[developer]
rules_lab_enabled=true
```

Restart the project or rebuild using the existing pipeline. The distributed
value is false. There is no player settings toggle or secret key sequence.
This is project configuration, not a personal-profile preference.

When enabled, the menu restores the lab and navigation through New game,
Laboratory and About. Its R/reset and rule-selector help is then included in
About. When disabled, the button is invisible, disabled, out of keyboard focus,
and its handler refuses to open the lab. New game and About are connected directly.
The scene and its regression tests remain available for maintenance. Tests that
exercise the technical menu enable the setting in memory and restore it afterwards;
they do not change the distributed default.

In the lab, R resets; the rule selector pauses and resets the board, P pauses/
resumes and Esc returns to the menu. This configuration is for maintainers, not the player-facing menu.
