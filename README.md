# Tinker

A clone of [Microsoft Tinker](https://en.wikipedia.org/wiki/Microsoft_Tinker) that I wrote as my high school final project.

The goal of the game is to move the robot through various obstacles, until it reaches the flag so that it can continue to the next level.

Download: [**Tinker-v1.0-windows-x86.zip**](https://github.com/antiufo/tinker/releases/download/1.0/Tinker-v1.0-windows-x86.zip)

![Screenshot 1](https://raw.githubusercontent.com/antiufo/tinker/master/images/screenshot1.png)

## Object types
Image | Name | Description
--- | --- | ---
![Robot](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image002.png) | Robot | The main character, you have to guide it towards the goal.
![Goal](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image003.png) | Goal | When the robot reaches this cell, you pass to the next level.
![Battery](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image004.png) | Battery | Recharges the robot by 10 units (advancing the robot by one cell consumes 1 unit).
![Cog](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image005.png) | Cog | If you collect all the cogs in a level, the level is marked as _completely_ passed.
![Teleport](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image006.png) | Teleport | If you reach this cell, you're teleported to the other portal with the same number. If something already exists at the destination, a swap will be performed.
![Teleport](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image007.png) | Elevator | If you place an object (or the robot itself) on this cell, the elevator will move up or down (depending on its previous state).
![Conveyor belt](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image008.png) | Conveyor belt | When enabled, objects (or the robot itself) placed on it will move towards the indicated direction.
![Door](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image009.png) | Door | Prevents objects or the robot from passing through that cell. Doors can be opened or closed by toggling the switch with the same color.
![Bomb](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image010.png) | Bomb | Destroys the adjacent ice blocks, and moves the adjacent movable blocks.
![Manual switch](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image011.png) | Manual switch | Toggles its state when the robot interacts with it (press ENTER).
![Pressure switch](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image012.png) | Pressure switch | Remains enabled as long as a movable block or the robot is placed on it.
![Puzzle switch](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image013.png) | Puzzle switch | Remains enabled as long as a movable block _of the same color_ is placed on it.
![Fixed block](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image014.png) | Fixed block | Cannot be moved or destroyed.
![Ice block](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image015.png) | Ice block | Can be destroyed by an adjacent bomb, but cannot be moved.
![Movable block](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image016.png) | Movable block | Can be moved by the robot.
![Puzzle block](https://raw.githubusercontent.com/antiufo/tinker/master/images/elements/image017.png) | Puzzle block | Can be moved by the robot, and is able to toggle a _puzzle switch_ of the same color.

## Keyboard commands
Key | Command
--- | ---
Arrow up | Go forward
Arrow left | Turn 90° left
Arrow right | Turn 90° right
Arrow down | Turn 180°
Enter | Toggle manual switch
Rotate checkboard | + or - (numeric keypad)
Toggle windowed/full-screen | ALT-ENTER
Menu | ESC
Restart level | R

## Notes
* The source code is in Italian, as this was the coding convention we used in our class.