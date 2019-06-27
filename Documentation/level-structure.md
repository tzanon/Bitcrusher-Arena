# Level Structure

This document details the required nodes and scripts for an arena level.

## Nodes
Several different nodes are used for grouping similar scene instances, organizing the level, and ensuring that visual elements are rendered in the correct order.

Every level must have *at least* the nodes listed below. The hierarchy may be augmented (i.e. adding additional children to Layout or Ground) but the structure as displayed by list indentation must be preserved.

* Level: root, basic node. Has script `level.gd`.
	* Layout: structure of playable space
		* Ground: sprite for the level's ground
		* PlayerManager: has script `player_manager.gd`. Has player spawn points (light green squares) as children, which are hidden at the start of the game. Also has a timer node, which gives a few seconds of delay after the game ends before changing to the results screen.
		* WeaponSpawner: has script `weapon_spawner.gd`. It initially has the level's pickup spawn points (red squares) as children, which are hidden as the game starts
		* Pickups: parent node for objects that the player can pick up
		* Structure: static boundaries, walls, and obstacles in the level
		* Players: parent node for the game's player avatars.
		* Projectiles: parent node for any projectiles that are spawned
		* Effects: parent node for visual effects like explosions, muzzle flash, etc.
	* UI: display player health and any other UI elements that may be added in the future

## Scripts

### level.gd
Only function is to check for an escape key press, on which the current game will be abandoned and the program will return to the main menu. Was put in as a way to reset the game at Level-Up if the game crashed so we wouldn't have to restart the program, might remove it in the future.

### player_manager.gd
Handles spawning of players, tracking of their status, and ending the game.

##### Spawning Players
Players are spawned immediately when the game scene (and therefore the PlayerManager node) is loaded. If the spawn_keyboard_player flag is set (in code or the inspector), a keyboard-controllable grey robot will be spawned to be used for easy debugging without a controller.

The spawning code itself involves `player_manager.gd` and `game_info.gd` (belonging to the GameInfo singleton). Once it is loaded, the player manager creates a dictionary associating each player (distinguished by colour) with a spawn position, sprite, and the position of its status bar in the UI.

The manager then gets the properties for the registered players from GameInfo and for each player:
* enables its UI bar displaying its icon and health
* spawns the player and sets its name to its colour
* sets the player's sprite and position according to the aforementioned spawn info dictionary
* adds the player as a child to the Players node
* sets the player's gamepad ID
* adds a reference to the player to `_match_player_refs`, a dictionary used to track the players currently "alive" in the level

##### HUD
The heads-up display UI for a game consists of status bars for each player in the game, which show an icon representing the player and a health bar. When a player dies, its icon is changed to a generic grey "dead" icon.

##### Ending the Game
Under the current, sole "deathmatch" game mode the game ends when there is only one player remaining in the arena. Whenever a player dies, the player manager checks how many player references are left in the `_match_player_refs` dictionary. If only one remains, the game end timer begins and the program will switch to the "game over" results screen upon its timeout.

### weapon_spawner.gd
Handles initial spawning and continued respawning of weapons for the duration of the game.

##### Spawning Weapons
The weapon spawner initially has several spawn points as children, placed around the level as desired. Upon the start of the game, these points are hidden and are kept in a list for use in the script. At a set interval, the currently spawned weapons will be removed and replaced with new ones according to a set spawning method.

The spawner has 4 different methods for spawning weapons:
* static fixed: at each spawn point in the level, spawn the point's default weapon
* static random: at each spawn point in the level, spawn a random weapon
* select fixed: at each spawn point in a random subset of all points, spawn the point's default weapon
* select random: at each spawn point in a random subset of all points, spawn a random weapon

