function HandleSelectCommand(a_Split, a_Player)
	-- /pb select {ArenaName}
	
	-- Not enough parameters
	if (a_Split[3] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /pb select {ArenaName}")
		return true
	end
	
	-- Arena doesn't exist.
	if (ARENAS[a_Split[3]] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Arena doesn't exist.")
		return true
	end
	
	ARENASELECTED[a_Player:GetName()] = a_Split[3]
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
	if (ARENAS[a_Split[3]] ~= nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Arena already exist.")
		return true
	end
	
	
	-- Create and select the new arena.
	ARENAS[a_Split[3]] = 
	{
		WorldName = a_Player:GetWorld():GetName(),
		HasStarted = false,
		SpawnPointsBlue = {},
		SpawnPointsRed = {},
		SpawnPointSpectator = {}, 
		SpawnPointLobby = Vector3f(a_Player:GetPosition()), 
		Teams = 
		{
			Blue = {}, 
			Red = {}, 
			Spectator = {}
		}
	}
	
	ARENASELECTED[a_Player:GetName()] = a_Split[3]
	
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
	if (ARENAS[a_Split[3]] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Arena doesn't exist.")
		return true
	end
	
	-- Teleport to the lobby.
	local Coords = ARENAS[a_Split[3]].SpawnPointLobby
	a_Player:TeleportToCoords(Coords.x, Coords.y, Coords.z)
end





function HandleAddCommand(a_Split, a_Player)
	-- /pb add {Red/Blue/Spectator}
	
	local SelectedArena = ARENASELECTED[a_Player:GetName()]
	
	-- The player doesn't have an area selected.
	if (SelectedArena == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "You don't have any arena selected. Use /pb select {ArenaName} to select an arena.")
		return true
	end
	
	-- Not enough parameters.
	if (a_Split[3] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /pb add [Team]")
		a_Player:SendMessage(cChatColor.Rose .. "Available teams: Red, Blue, Spectator")
		return true
	end
	
	local Team = a_Split[3]:upper()
	if (Team == "RED") then
		table.insert(ARENAS[SelectedArena].SpawnPointsRed, Vector3f(a_Player:GetPosition()))
		a_Player:SendMessage(cChatColor.Rose .. "Added new spawnpoint for team red.")
		return true
	end
	
	if (Team == "BLUE") then
		table.insert(ARENAS[SelectedArena].SpawnPointsBlue, Vector3f(a_Player:GetPosition()))
		a_Player:SendMessage(cChatColor.Blue .. "Added new spawnpoint for team blue.")
		return true
	end
	
	if (Team == "SPECTATOR") then
		table.insert(ARENAS[SelectedArena].SpawnPointSpectator, Vector3f(a_Player:GetPosition()))
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
	if (ARENAS[Arena] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Arena doesn't exist.")
		return true
	end
	
	-- Check if the player already joined an arena.
	if (ARENAJOINED[a_Player:GetName()] ~= nil) then
		a_Player:SendMessage(cChatColor.Rose .. "You already joined an arena. Use /pb leave to leave the arena.")
		return true
	end
	
	ARENAJOINED[a_Player:GetName()] = Arena
	
	-- Get the lobby coordinates and teleport the player to it.
	local ArenaLobby = ARENAS[Arena].SpawnPointLobby
	a_Player:TeleportToCoords(ArenaLobby.x, ArenaLobby.y, ArenaLobby.z)
	
	local NumPlayersTeamRed = GetSizeTable(ARENAS[Arena].Teams.Red)
	local NumPlayersTeamBlue = GetSizeTable(ARENAS[Arena].Teams.Blue)
	
	local PlayerInfo = 
	{
		Kills = 0,
		Deaths = 0,
		IsPlaying = false,
	}
	
	-- Choose a team. choose the team with the lowest players, and if the amount of players is equal then choose randomly.
	if (NumPlayersTeamRed > NumPlayersTeamBlue) then
		ARENAS[Arena].Teams.Blue[a_Player:GetName()] = PlayerInfo
	elseif (NumPlayersTeamRed < NumPlayersTeamBlue) then
		ARENAS[Arena].Teams.Red[a_Player:GetName()] = PlayerInfo
	else
		local Team = math.random(1, 2)
		if (Team == 1) then -- Red team
			ARENAS[Arena].Teams.Red[a_Player:GetName()] = PlayerInfo
		elseif (Team == 2) then -- Blue team
			ARENAS[Arena].Teams.Blue[a_Player:GetName()] = PlayerInfo
		end
	end
	
	a_Player:SendMessage(cChatColor.Blue .. "You joined " .. a_Split[3])
	
	local TotalPlayers = NumPlayersTeamRed + NumPlayersTeamBlue + 1 -- Don't forget the new player.
	-- Check if we have enough players to start the arena.
	if (TotalPlayers >= MAXPLAYERSNEEDED) then
		StartArena(Arena)
	end
end





function HandleLeaveCommand(a_Split, a_Player)
	-- /pb leave
	
	-- The player hasn't joined any arena's
	if (ARENAJOINED[a_Player:GetName()] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "You haven't joined an arena.")
		return true
	end
	
	local ArenaJoined = ARENAJOINED[a_Player:GetName()]
	local LobbyPosition = ARENAS[ArenaJoined].SpawnPointLobby
	local PlayerName = a_Player:GetName()
	
	-- Remove the player from the arena's player list.
	if (ARENAS[ArenaJoined].Teams.Red[PlayerName]) then
		ARENAS[ArenaJoined].Teams.Red[PlayerName] = nil
	elseif (ARENAS[ArenaJoined].Teams.Blue[PlayerName]) then
		ARENAS[ArenaJoined].Teams.Blue[PlayerName] = nil
	elseif (ARENAS[ArenaJoined].Teams.Spectator[PlayerName]) then
		ARENAS[ArenaJoined].Teams.Spectator[PlayerName] = nil
	end
	
	ARENAJOINED[a_Player:GetName()] = nil
	
	-- Teleport to the lobby.
	a_Player:TeleportToCoords(LobbyPosition.x, LobbyPosition.y, LobbyPosition.z)
	a_Player:SendMessage(cChatColor.Blue .. "You left the arena.")
	return true
end





function HandleListCommand(a_Split, a_Player)
	-- /pb list
	
	a_Player:SendMessage(cChatColor.LightBlue .. "There are " .. GetSizeTable(ARENAS) .. " arena(s).")
	for ArenaName, _ in pairs(ARENAS) do
		a_Player:SendMessage(cChatColor.Blue .. ArenaName)
	end
end