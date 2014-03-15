g_Plugin = nil

function Initialize(a_Plugin)
	a_Plugin:SetVersion(1)
	a_Plugin:SetName("PaintBall")
	g_Plugin = a_Plugin
	
	LoadConfig()
	
	cPluginManager:BindCommand("/pb", "", HandlePBCommand, " - The paintball command.")
	
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





function HandlePBCommand(a_Split, a_Player)
	if (#a_Split < 2) then
		a_Player:SendMessage(cChatColor.Blue .. "Usage:")
		if (a_Player:HasPermission("paintball.select")) then a_Player:SendMessage(cChatColor.Blue .. "/pb select") end
		if (a_Player:HasPermission("paintball.create")) then a_Player:SendMessage(cChatColor.Blue .. "/pb create") end
		if (a_Player:HasPermission("paintball.lobby"))  then a_Player:SendMessage(cChatColor.Blue .. "/pb lobby")  end
		if (a_Player:HasPermission("paintball.add"))    then a_Player:SendMessage(cChatColor.Blue .. "/pb add")    end
		if (a_Player:HasPermission("paintball.join"))   then a_Player:SendMessage(cChatColor.Blue .. "/pb join")   end
		if (a_Player:HasPermission("paintball.leave"))  then a_Player:SendMessage(cChatColor.Blue .. "/pb leave")  end
		if (a_Player:HasPermission("paintball.list"))   then a_Player:SendMessage(cChatColor.Blue .. "/pb list")   end
		return true
	end
	
	local Operation = a_Split[2]:upper()
	if ((Operation == "SELECT") and a_Player:HasPermission("paintball.select")) then
		HandleSelectCommand(a_Split, a_Player)
		return true
	end
	
	if ((Operation == "CREATE") and a_Player:HasPermission("paintball.create")) then
		HandleCreateCommand(a_Split, a_Player)
		return true
	end
	
	if ((Operation == "LOBBY") and a_Player:HasPermission("paintball.lobby")) then
		HandleLobbyCommand(a_Split, a_Player)
		return true
	end
	
	if ((Operation == "ADD") and a_Player:HasPermission("paintball.add")) then
		HandleAddCommand(a_Split, a_Player)
		return true
	end
	
	if ((Operation == "JOIN") and a_Player:HasPermission("paintball.join")) then
		HandleJoinCommand(a_Split, a_Player)
		return true
	end
	
	if ((Operation == "LEAVE") and a_Player:HasPermission("paintball.leave")) then
		HandleLeaveCommand(a_Split, a_Player)
		return true
	end
	
	if ((Operation == "LIST") and a_Player:HasPermission("paintball.list")) then
		HandleListCommand(a_Split, a_Player)
		return true
	end
	
	a_Player:SendMessage(cChatColor.Blue .. "Unknown parameter " .. a_Split[2])
	return true
end


