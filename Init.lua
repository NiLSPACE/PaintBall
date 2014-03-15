g_Plugin = nil

function Initialize(a_Plugin)
	a_Plugin:SetVersion(1)
	a_Plugin:SetName("PaintBall")
	g_Plugin = a_Plugin
	
	LoadConfig()
	
	-- Load the InfoReg library file for registering the Info.lua command table:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua");
	
	-- Initialize in-game commands:
	RegisterPluginInfoCommands();
	
	cPluginManager:AddHook(cPluginManager.HOOK_TAKE_DAMAGE, OnTakeDamage);           -- Needed for the teleporting.
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerDestroyed)  -- Needed to mark the player as "Not joined any arena's" and to check if there are enough players left to play a match.
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_MOVING, OnPlayerMoving)        -- Needed to heal the players when they are playing.
	cPluginManager:AddHook(cPluginManager.HOOK_SPAWNED_ENTITY, OnSpawnedEntity)      -- Needed to see how many shots were fired in a match.
	
	-- Anti Griefing.
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnBlockInteraction) -- We don't want other players placing blocks
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK, OnBlockInteraction)
	
	LoadArenas()
	
	LOG("Initialized Paintball v" .. a_Plugin:GetVersion())
	return true
end





-- The plugin is disabling. Stop all the arena's and save them.
function OnDisable()
	-- Stop all the current arena's.
	ForEachArena(
		function(a_ArenaState)
			a_ArenaState:StopArena(true)
		end
	)
	
	-- Save all the arenas
	SaveArenas()
	
	LOG("Disabling Paintball.")
end





