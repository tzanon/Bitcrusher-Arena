#Level Structure

Describes the required nodes and scripts for an arena level

##Nodes
Several different nodes are used for grouping similar scene instances, organizing the level, and ensuring that visual elements are rendered in the correct order.

Every level must have *at least* the nodes listed below. The hierarchy may be added to (i.e. adding additional children to Layout or Ground) but the structure as displayed by list indentation must be preserved.

* Level: root, basic node. Has script `level.gd`.
	* Layout: structure of playable space
		* Ground: sprite for the level's ground
		* PlayerManager: has script `player_manager.gd`;
		* WeaponSpawner: has script `weapon_spawner.gd`;
		* Pickups: parent node for objects that the player can pick up. It initially has the level's pickup spawn points (red squares) as children, which are hidden as the game starts
		* Structure: static boundaries, walls, and obstacles in the level
		* Players: parent node for the game's player avatars. Has player spawn points (light green squares) as children, which are hidden at the start of the game. Also has a timer node, which gives a few seconds of delay after the game ends before changing to the results screen.
		* Projectiles: parent node for any projectiles that are spawned
		* Effects: parent node for visual effects like explosions, muzzle flash, etc.
	* UI: display player health and any other UI elements that may be added in the future


##Scripts

###level.gd
Only function is to check for an escape key press, on which the current game will be abandoned and the program will return to the main menu.

###player_manager.gd
Handles spawning of players, tracking of their status, and ending the game.

####Spawning
Players are spawned immediately when the game scene (and therefore the PlayerManager) is loaded. If the spawn_keyboard_player flag is set, a keyboard-controllable grey robot will be spawned to be used for easy debugging without a controller.

####HUD


####Ending the Game


###weapon_spawner.gd
TBD

