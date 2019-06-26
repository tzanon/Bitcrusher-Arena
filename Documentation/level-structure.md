# Level Structure

Describes the required nodes and scripts for an arena level

## Nodes
Several different nodes are used for grouping similar scene instances, organizing the level, and ensuring that visual elements are rendered in the correct order.

Every level must have *at least* the nodes listed below. The hierarchy may be augmented (i.e. adding additional children to Layout or Ground) but the structure as displayed by list indentation must be preserved.

* Level: root, basic node. Has script `level.gd`.
	* Layout: structure of playable space
		* Ground: sprite for the level's ground
		* PlayerManager: has script `player_manager.gd` and spawn points as children --check this
		* WeaponSpawner: has script `weapon_spawner.gd` and spawn points as children --check this
		* Pickups: parent node for objects that the player can pick up. It initially has the level's pickup spawn points (red squares) as children, which are hidden as the game starts
		* Structure: static boundaries, walls, and obstacles in the level
		* Players: parent node for the game's player avatars. Has player spawn points (light green squares) as children, which are hidden at the start of the game. Also has a timer node, which gives a few seconds of delay after the game ends before changing to the results screen.
		* Projectiles: parent node for any projectiles that are spawned
		* Effects: parent node for visual effects like explosions, muzzle flash, etc.
	* UI: display player health and any other UI elements that may be added in the future


## Scripts

### level.gd
Only function is to check for an escape key press, on which the current game will be abandoned and the program will return to the main menu. Was put in as a way to reset the game at Level-Up if the game crashed so we wouldn't have to restart the program, might remove it in the future.

### player_manager.gd
Handles spawning of players, tracking of their status, and ending the game.

#### Spawning Players
Players are spawned immediately when the game scene (and therefore the PlayerManager node) is loaded. If the spawn_keyboard_player flag is set (in code or the inspector), a keyboard-controllable grey robot will be spawned to be used for easy debugging without a controller.

The spawning code itself involves `player_manager.gd` and `game_info.gd` (belonging to the GameInfo singleton)


#### HUD
TODO

#### Ending the Game
Under the current, sole "deathmatch" game mode the game ends when there is only one player remaining in the arena. Whenever a player dies, the player manager checks how many are left. If only one remains, the game end timer begins and the program will switch to the "game over" results screen upon its timeout.

### weapon_spawner.gd

#### Spawning Weapons
