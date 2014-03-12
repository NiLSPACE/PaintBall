function HandleSelectCommand(a_Split, a_Player)
	-- /pb select {ArenaName}
	
	-- Not enough parameters
	if (a_Split[3] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /pb select {ArenaName}")
		return true
	end
	
	local ArenaState = GetArenaState(a_Split[3])
	-- Arena doesn't exist.
	if (not ArenaState) then
		a_Player:SendMessage(cChatColor.Rose .. "Arena doesn't exist.")
		return true
	end
	
	local PlayerState = GetPlayerState(a_Player)
	PlayerState:SelectArena(a_Split[3])
	
	a_Player:SendMessage(cChatColor.Blue .. "You selected arena " .. a_Split[3])
end




function HandleCreateCommand(a_Split, a_Player)
	-- /pb create {ArenaName}
	
	-- Not enough parameters.
	if (a_Split[3] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /pb create {ArenaName}")
		return true
	end
	
	-- Don't create an new arena when there is already one with the same name.
	if (ArenaStateExists(a_Split[3])) then
		a_Player:SendMessage(cChatColor.Rose .. "Arena already exist.")
		return true
	end
	
	
	-- Create and select the new arena.
	InitializeArenaState(a_Split[3], a_Player:GetWorld():GetName(), Vector3f(a_Player:GetPosition()))
	
	local State = GetPlayerState(a_Player)
	State:SelectArena(a_Split[3])
	
	a_Player:SendMessage(cChatColor.Blue .. "You created arena " .. a_Split[3] .. ". You can now create waypoints.")
end





function HandleLobbyCommand(a_Split, a_Player)
	-- /pb lobby {ArenaName}
	
	-- Not enough parameters.
	if (a_Split[3] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /pb lobby {ArenaName}")
		return true
	end
	
	-- We can't teleport to the lobby when the arena doesn't exist.
	if (not ArenaStateExists(a_Split[3])) then
		a_Player:SendMessage(cChatColor.Rose .. "Arena doesn't exist.")
		return true
	end
	
	-- Get the arenastate
	local ArenaState = GetArenaState(a_Split[3])
	
	-- Get the coordinates of the lobby.
	local Coords = ArenaState:GetLobbySpawn()
	
	-- Teleport to the lobby.
	a_Player:TeleportToCoords(Coords.x, Coords.y, Coords.z)
end





function HandleAddCommand(a_Split, a_Player)
	-- /pb add {Red/Blue/Spectator}
	
	local State = GetPlayerState(a_Player)
	
	-- The player doesn't have an area selected.
	if (not State:HasArenaSelected()) then
		a_Player:SendMessage(cChatColor.Rose .. "You don't have any arena selected. Use /pb select {ArenaName} to select an arena.")
		return true
	end
	local SelectedArena = State:GetSelectedArena()
	
	-- Not enough parameters.
	if (a_Split[3] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /pb add [Team]")
		a_Player:SendMessage(cChatColor.Rose .. "Available teams: Red, Blue, Spectator")
		return true
	end
	
	local ArenaState = GetArenaState(SelectedArena)
	local Team = a_Split[3]:upper()
	if (Team == "RED") then
		ArenaState:AddSpawnPointRed(Vector3f(a_Player:GetPosition()))
		a_Player:SendMessage(cChatColor.Rose .. "Added new spawnpoint for team red.")
		return true
	end
	
	if (Team == "BLUE") then
		ArenaState:AddSpawnPointBlue(Vector3f(a_Player:GetPosition()))
		a_Player:SendMessage(cChatColor.Blue .. "Added new spawnpoint for team blue.")
		return true
	end
	
	if (Team == "SPECTATOR") then
		ArenaState:AddSpawnPointSpectator(Vector3f(a_Player:GetPosition()))
		a_Player:SendMessage(cChatColor.Yellow .. "Added new spawnpoint for the spectators.")
		return true
	end
	
	a_Player:SendMessage(cChatColor.Rose .. "Unknown team. You can use: red, blue and spectator.")
end





function HandleJoinCommand(a_Split, a_Player)
	-- /pb join {ArenaName}
	
	-- Not enough parameters.
	if (a_Split[3] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /pb join {ArenaName}")
		return true
	end
	
	-- Check if the arena exists.
	local Arena = a_Split[3]
	if (not ArenaStateExists(Arena)) then
		a_Player:SendMessage(cChatColor.Rose .. "Arena doesn't exist.")
		return true
	end
	
	local State = GetPlayerState(a_Player)
	
	-- Check if the player already joined an arena.
	if (State:HasJoinedArena()) then
		a_Player:SendMessage(cChatColor.Rose .. "You already joined an arena. Use /pb leave to leave the arena.")
		return true
	end
	
	-- Mark the player as "Has joined <ArenaName>"
	State:JoinArena(Arena)
	
	local ArenaState = GetArenaState(Arena)
	
	-- Get the lobby coordinates and teleport the player to it.
	local ArenaLobby = ArenaState:GetLobbySpawn()
	a_Player:TeleportToCoords(ArenaLobby.x, ArenaLobby.y, ArenaLobby.z)
	
	local NumPlayersTeamRed = ArenaState:GetNumRedPlayers()
	local NumPlayersTeamBlue = ArenaState:GetNumBluePlayers()
	
	-- Choose a team. choose the team with the lowest players, and if the amount of players is equal then choose randomly.
	if (NumPlayersTeamRed < NumPlayersTeamBlue) then
		ArenaState:JoinRedTeam(a_Player:GetName())
	elseif (NumPlayersTeamRed > NumPlayersTeamBlue) then
		ArenaState:JoinBlueTeam(a_Player:GetName())
	else
		local Team = math.random(1, 2)
		if (Team == 1) then -- Red team
			ArenaState:JoinRedTeam(a_Player:GetName())
		elseif (Team == 2) then -- Blue team
			ArenaState:JoinBlueTeam(a_Player:GetName())
		end
	end
	
	a_Player:SendMessage(cChatColor.Blue .. "You joined " .. a_Split[3])
	
	local TotalPlayers = NumPlayersTeamRed + NumPlayersTeamBlue + 1 -- Don't forget the new player.
	-- Check if we have enough players to start the arena.
	if (TotalPlayers >= MAXPLAYERSNEEDED) then
		ArenaState:StartArena()
	end
end





function HandleLeaveCommand(a_Split, a_Player)
	-- /pb leave
	
	-- The player hasn't joined any arena's
	local PlayerState = GetPlayerState(a_Player)
	if (not PlayerState:HasJoinedArena()) then
		a_Player:SendMessage(cChatColor.Rose .. "You haven't joined an arena.")
		return true
	end
	
	local ArenaState = GetArenaState(PlayerState:GetJoinedArena())
	local LobbyPosition = ArenaState:GetLobbySpawn()
	local PlayerName = a_Player:GetName()
	
	-- Remove the player from the arena's player list.
	ArenaState:LeaveArena(PlayerName)
	
	-- Leave the arena.
	PlayerState:JoinArena(nil)
	
	a_Player:SendMessage(cChatColor.Blue .. "You left the arena.")
	return true
end





function HandleListCommand(a_Split, a_Player)
	-- /pb list
	
	a_Player:SendMessage(cChatColor.LightBlue .. "There are " .. GetSizeTable(g_ArenaStates) .. " arena(s).")
	ForEachArena(
		function(a_ArenaState, a_ArenaName)
			a_Player:SendMessage(cChatColor.Blue .. a_ArenaName)
		end
	)
end