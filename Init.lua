g_Plugin = nil
ARENAS = {}

function Initialize(a_Plugin)
	a_Plugin:SetVersion(1)
	a_Plugin:SetName("PaintBall")
	g_Plugin = a_Plugin
	
	LoadConfig()
	
	cPluginManager:BindCommand("/pb", "", HandlePBCommand, "")
	
	cPluginManager:AddHook(cPluginManager.HOOK_TAKE_DAMAGE, OnTakeDamage);           -- Needed for the teleporting.
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerDestroyed)  -- Needed to mark the player as "Not joined any arena's" and to check if there are enough players left to play a match.
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_MOVING, OnPlayerMoving)        -- Needed to heal the players when they are playing.
	
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
	for Arena, Data in pairs(ARENAS) do
		StopArena(Arena)
	end
	
	-- Save all the arenas
	SaveArenas()
	
	LOG("Disabling Paintball.")
end





function HandlePBCommand(a_Split, a_Player)
	if (#a_Split < 2) then
		a_Player:SendMessage(cChatColor.Blue .. "Usage:")
		a_Player:SendMessage(cChatColor.Blue .. "/pb select")
		a_Player:SendMessage(cChatColor.Blue .. "/pb create")
		a_Player:SendMessage(cChatColor.Blue .. "/pb lobby")
		a_Player:SendMessage(cChatColor.Blue .. "/pb add")
		a_Player:SendMessage(cChatColor.Blue .. "/pb join")
		a_Player:SendMessage(cChatColor.Blue .. "/pb leave")
		a_Player:SendMessage(cChatColor.Blue .. "/pb list")
		return true
	end
	
	local Operation = a_Split[2]:upper()
	if (Operation == "SELECT") then
		HandleSelectCommand(a_Split, a_Player)
		return true
	end
	
	if (Operation == "CREATE") then
		HandleCreateCommand(a_Split, a_Player)
		return true
	end
	
	if (Operation == "LOBBY") then
		HandleLobbyCommand(a_Split, a_Player)
		return true
	end
	
	if (Operation == "ADD") then
		HandleAddCommand(a_Split, a_Player)
		return true
	end
	
	if (Operation == "JOIN") then
		HandleJoinCommand(a_Split, a_Player)
		return true
	end
	
	if (Operation == "LEAVE") then
		HandleLeaveCommand(a_Split, a_Player)
		return true
	end
	
	if (Operation == "LIST") then
		HandleListCommand(a_Split, a_Player)
		return true
	end
	
	a_Player:SendMessage(cChatColor.Blue .. "Unknown parameter " .. a_Split[2])
	return true
end


