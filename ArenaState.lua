

-- The table that contains all the player states.
g_ArenaStates = {}





function CreateArenaState(a_WorldName, a_LobbySpawn)
	assert(cRoot:Get():GetWorld(a_WorldName) ~= nil)
	assert(tolua.type(a_LobbySpawn) == 'Vector3<float>')
	
	local WorldName = a_WorldName
	local LobbySpawn = a_LobbySpawn
	
	local HasStarted = false
	
	local SpawnPointsBlue = {}
	local SpawnPointsRed = {}
	local SpawnPointsSpectator = {}
	
	local Teams = 
	{
		Blue = {}, 
		Red = {}, 
		Spectator = {}
	}
	
	-- Create the object with all the functions.
	local self = {}
	
	-- Loops through each player and calls the given callback with the player object as parameter.
	function self:ForEachPlayer(a_Callback)
		assert(type(a_Callback) == 'function')
		local World = cRoot:Get():GetWorld(WorldName)
		local ShouldStop = false
		
		for TeamName, PlayerList in pairs(Teams) do
			for PlayerName, _ in pairs(PlayerList) do
				if (ShouldStop) then
					return
				end
				
				World:DoWithPlayer(PlayerName, 
					function(a_Player)
						if (a_Callback(a_Player)) then
							ShouldStop = true
						end
					end
				)
			end
		end
	end
	
	
	
	
	
	-- Returns the coordinates of the lobby.
	function self:GetLobbySpawn()
		return LobbySpawn
	end
	
	
	
	
	
	-- Returns if the arena has started or not.
	function self:HasStarted()
		return HasStarted
	end
	
	
	
	
	
	-- Starts the arena and teleports all the players to one of the spawn points of their team.
	function self:StartArena()
		HasStarted = true
		
		local World = cRoot:Get():GetWorld(WorldName)
		
		-- Teleport everyone to one of the spawnpoints of their team. 
		-- The red players
		for PlayerName, _ in pairs(Teams.Red) do
			World:DoWithPlayer(PlayerName, 
				function(a_Player)
					local Coords = SpawnPointsRed[math.random(1, #SpawnPointsRed)]
					a_Player:TeleportToCoords(Coords.x, Coords.y, Coords.z)
					GiveSnowballs(a_Player)
					Teams.Red[PlayerName].IsPlaying = true
					a_Player:SendMessage(cChatColor.Rose .. "Game started.")
				end
			) -- cWorld:DoWithPlayer
		end
		
		-- The blue players
		for PlayerName, _ in pairs(Teams.Blue) do
			World:DoWithPlayer(PlayerName, 
				function(a_Player)
					local Coords = SpawnPointsBlue[math.random(1, #SpawnPointsBlue)]
					a_Player:TeleportToCoords(Coords.x, Coords.y, Coords.z)
					GiveSnowballs(a_Player)
					Teams.Blue[PlayerName].IsPlaying = true
					a_Player:SendMessage(cChatColor.Rose .. "Game started.")
				end
			) -- cWorld:DoWithPlayer
		end
		
		-- The spectators
		for PlayerName, _ in pairs(Teams.Spectator) do
			World:DoWithPlayer(PlayerName, 
				function(a_Player)
					local Coords = SpawnPointsSpectator[math.random(1, #SpawnPointsSpectator)]
					a_Player:TeleportToCoords(Coords.x, Coords.y, Coords.z)
					Teams.Spectator[PlayerName].IsPlaying = true
					a_Player:SendMessage(cChatColor.Rose .. "Game started.")
				end
			) -- cWorld:DoWithPlayer
		end
	end
	
	
	
	
	
	-- Stops the arena and teleports all the players who were in the arena to the lobby.
	function self:StopArena()
		HasStarted = false
		
		-- Teleport everyone to the lobby.
		self:ForEachPlayer(
			function(a_Player)
				a_Player:SendMessage(cChatColor.Rose .. "Arena stopped. The match is over.")
				a_Player:TeleportToCoords(LobbySpawn.x, LobbySpawn.y, LobbySpawn.z)
				local State = GetPlayerState(a_Player)
				State:JoinArena(nil)
			end
		) -- self:ForEachPlayer
		
		-- Reset the teams.
		Teams = 
		{
			Blue = {}, 
			Red = {}, 
			Spectator = {}
		}
	end
	
	
	
	
	
	-- Sends an message to all the players who have joined 
	function self:BroadcastMessage(a_Message)
		local World = cRoot:Get():GetWorld(a_WorldName)
		
		self:ForEachPlayer(
			function(a_Player)
				a_Player:SendMessage(a_Message)
			end
		)
	end
	
	
	
	
	
	-- This part adds spawnpoints to the teams.
	do
		-- Adds one spawnpoint to the blue team.
		function self:AddSpawnPointBlue(a_Pos)
			assert(tolua.type(a_Pos) == 'Vector3<float>')
			
			table.insert(SpawnPointsBlue, a_Pos)
		end
		
		-- Add one spawnpoint to the red team.
		function self:AddSpawnPointRed(a_Pos)
			assert(tolua.type(a_Pos) == 'Vector3<float>')
			
			table.insert(SpawnPointsRed, a_Pos)
		end
		
		-- Add one spawnpoint to the spectators.
		function self:AddSpawnPointSpectator(a_Pos)
			assert(tolua.type(a_Pos) == 'Vector3<float>')
			
			table.insert(SpawnPointsSpectator, a_Pos)
		end
	end
	
	
	
	
	
	-- This part manages the Get spawnpoint functions
	do
		-- Returns one of the spawnpoints from the red team randomly:
		function self:GetRandomRedSpawn()
			return SpawnPointsRed[math.random(1, #SpawnPointsRed)]
		end
		
		-- Returns one of the spawnpoints from the red team randomly:
		function self:GetRandomBlueSpawn()
			return SpawnPointsBlue[math.random(1, #SpawnPointsBlue)]
		end
		
		-- Returns one of the spawnpoints from the spectators randomly:
		function self:GetRandomSpectatorSpawn()
			return SpawnPointsSpectator[math.random(1, #SpawnPointsSpectator)]
		end
		
		-- Returns the table where all the red spawnpoints are in.
		function self:GetRedSpawnpoints()
			return SpawnPointsRed
		end
		
		-- Returns the table where all the blue spawnpoints are in.
		function self:GetBlueSpawnpoints()
			return SpawnPointsBlue
		end
		
		-- Returns the table where all the spectator spawnpoints are in.
		function self:GetSpectatorSpawnpoints()
			return SpawnPointsSpectator
		end
		
		-- returns the amount of spawnpoints team red has.
		function self:GetNumRedSpawnpoints()
			return #SpawnPointsRed
		end
		
		-- returns the amount of spawnpoints team blue has.
		function self:GetNumBlueSpawnpoints()
			return #SpawnPointsBlue
		end
		
		-- returns the amount of spawnpoints the spectators have.
		function self:GetNumSpectatorSpawnpoints()
			return #SpawnPointsSpectator
		end
	end
	
	
	
	
	
	-- This part returns the amount of playing players.
	do
		-- Amount of red players.
		function self:GetNumPlayingRedPlayers()
			local Count = 0
			for PlayerName, Data in pairs(Teams.Red) do
				if (Data.IsPlaying) then
					Count = Count + 1
				end
			end
			
			return Count
		end
		
		-- Amount of blue players
		function self:GetNumPlayingBluePlayers()
			local Count = 0
			for PlayerName, Data in pairs(Teams.Blue) do
				if (Data.IsPlaying) then
					Count = Count + 1
				end
			end
			
			return Count
		end
		
		-- Amount of playing players.
		function self:GetNumPlayingPlayers()
			return (self:GetNumPlayingRedPlayers() + self:GetNumPlayingBluePlayers())
		end
		
		
		
		
		function self:GetNumRedPlayers()
			local Count = 0
			for PlayerName, Data in pairs(Teams.Red) do
				Count = Count + 1
			end
			
			return Count
		end
		
		
		function self:GetNumBluePlayers()
			local Count = 0
			for PlayerName, Data in pairs(Teams.Blue) do
				Count = Count + 1
			end
			
			return Count
		end
		
		
		
		function self:GetNumPlayers()
			return (self:GetNumRedPlayers() + self:GetNumBluePlayers())
		end
	end
	
	
	
	
	
	-- JoinTeam functions.
	do
		-- Join red team.
		function self:JoinRedTeam(a_PlayerName)
			Teams.Red[a_PlayerName] = 
			{
				Kills = 0,
				Deaths = 0,
				IsPlaying = false,
				Team = "Red",
			}
		end
		
		-- Join blue team.
		function self:JoinBlueTeam(a_PlayerName)
			Teams.Blue[a_PlayerName] = 
			{
				Kills = 0,
				Deaths = 0,
				IsPlaying = false,
				Team = "Blue",
			}
		end
		
		-- Join spectator. A spectator doesn't have any kills or deaths so we just mark him as "There"
		function self:JoinSpectators(a_PlayerName)
			Teams.Spectator[a_PlayerName] = true
		end
		
		-- Joins one of the teams. If blue has less then red you join blue and the other way around. If they have an equal amount of players you will join one randomly
		function self:JoinArena(a_Player)
			local NumPlayersTeamRed = self:GetNumRedPlayers()
			local NumPlayersTeamBlue = self:GetNumBluePlayers()
			
			-- Choose a team. choose the team with the lowest players, and if the amount of players is equal then choose randomly.
			if (NumPlayersTeamRed < NumPlayersTeamBlue) then
				self:JoinRedTeam(a_Player)
			elseif (NumPlayersTeamRed > NumPlayersTeamBlue) then
				self:JoinBlueTeam(a_Player)
			else
				local Team = math.random(1, 2)
				if (Team == 1) then -- Red team
					self:JoinRedTeam(a_Player)
				elseif (Team == 2) then -- Blue team
					self:JoinBlueTeam(a_Player)
				end
			end
		end
	end	
	
	
	
	
	
	-- Just teleport the player to the lobby and remove the player from all the teams.
	function self:LeaveArena(a_PlayerName)
		local World = cRoot:Get():GetWorld(WorldName)
		
		World:DoWithPlayer(a_PlayerName,
			function(a_Player)
				a_Player:TeleportToCoords(LobbySpawn.x, LobbySpawn.y, LobbySpawn.z)
			end
		)
		
		Teams.Red[a_PlayerName] = nil
		Teams.Blue[a_PlayerName] = nil
		Teams.Spectator[a_PlayerName] = nil
		
		self:CheckIfEnoughPlayers()
	end
	
	
	
	
	
	-- Returns the the table wich contains all the teams
	function self:GetTeams()
		return Teams
	end
	
	
	
	
	
	-- Returns the name wich the arena is in.
	function self:GetWorldName()
		return WorldName
	end
	
	
	
	
	
	-- Checks if one of the teams doesn't have enough players to keep playing.
	function self:CheckIfEnoughPlayers()
		local NumBluePlayers = self:GetNumPlayingBluePlayers()
		local NumRedPlayers  = self:GetNumPlayingRedPlayers()
		
		if (NumBluePlayers <= 0) then
			self:BroadcastMessage(cChatColor.Rose .. "Red team wins.")
			self:StopArena()
			return true
		elseif (NumRedPlayers <= 0) then
			self:BroadcastMessage(cChatColor.Blue .. "Blue team wins.")
			self:StopArena()
			return true
		end
		return false
	end
	
	
	
	
	
	-- Returns the player info of a player. false if it doesn't exist.
	function self:GetPlayerInfo(a_PlayerName)
		return (Teams.Red[a_PlayerName] or Teams.Blue[a_PlayerName] or false)
	end
	
	
	
	
	
	-- Checks if it was friendly fire, plays a nice Pop sound and stops the arena if there are not enough players left.
	function self:HitPlayer(a_Attacker, a_Receiver)
		local ColorPrefix = cChatColor.Blue
		local AttackerName = a_Attacker:GetName()
		local ReceiverName = a_Receiver:GetName()
		
		if (Teams.Red[AttackerName]) then
			ColorPrefix = cChatColor.Rose
		end
		
		local ReceiverInfo = self:GetPlayerInfo(ReceiverName)
		local AttackerInfo = self:GetPlayerInfo(AttackerName)
		
		if (ReceiverInfo.Team == AttackerInfo.Team) then
			return
		end
		
		ReceiverInfo.Deaths = ReceiverInfo.Deaths + 1
		AttackerInfo.Kills = AttackerInfo.Kills + 1
		
		local World = a_Receiver:GetWorld()
		World:BroadcastSoundEffect("random.pop", a_Receiver:GetPosX() * 8, a_Receiver:GetPosY() * 8, a_Receiver:GetPosZ() * 8, 1, 126)
		World:BroadcastSoundEffect("random.pop", a_Attacker:GetPosX() * 8, a_Attacker:GetPosY() * 8, a_Attacker:GetPosZ() * 8, 1, 126)
		
		local Coords = nil
		if (ReceiverInfo.Team == "Blue") then
			Coords = self:GetRandomBlueSpawn()
			self:BroadcastMessage(cChatColor.Rose .. AttackerName .. " hit " .. ReceiverName .. " [" .. AttackerInfo.Kills .. "]")
		else
			Coords = self:GetRandomRedSpawn()
			self:BroadcastMessage(cChatColor.Blue .. AttackerName .. " hit " .. ReceiverName .. " [" .. AttackerInfo.Kills .. "]")
		end

		if (ReceiverInfo.Deaths >= g_DeathsNeeded) then
			ReceiverInfo.IsPlaying = false
			a_Receiver:SendMessage(cChatColor.Rose .. "You died. You had " .. ReceiverInfo.Kills .. " kills.")
			if (not self:CheckIfEnoughPlayers()) then
				Coords = LobbyCoords
			end
			return
		end
		
		a_Receiver:TeleportToCoords(Coords.x, Coords.y, Coords.z)
	end
	
	
	return self
end





-- Returns the arenastate.
function GetArenaState(a_Arena)
	if (g_ArenaStates[a_Arena] == nil) then
		return false
	end
	
	return g_ArenaStates[a_Arena]
end





-- Creates an arenastate and adds it to the g_ArenaStates table. Returns false if the arenastate already exists.
function InitializeArenaState(a_ArenaName, a_WorldName, a_LobbySpawn)
	assert(type(a_ArenaName) == 'string')
	assert(cRoot:Get():GetWorld(a_WorldName) ~= nil)
	assert(tolua.type(a_LobbySpawn) == 'Vector3<float>')
	
	if (g_ArenaStates[a_ArenaName]) then
		return false
	end
	
	local ArenaState = CreateArenaState(a_WorldName, a_LobbySpawn)
	g_ArenaStates[a_ArenaName] = ArenaState
	
	return ArenaState
end





-- Returns true if the state exists.
function ArenaStateExists(a_Arena)
	if (g_ArenaStates[a_Arena]) then
		return true
	end
	
	return false
end





-- Loops through each arena and calls the given callback. The parameters are: a_ArenaState, a_ArenaName
function ForEachArena(a_Callback)
	assert(type(a_Callback) == 'function')
	
	for ArenaName, _ in pairs(g_ArenaStates) do
		if (a_Callback(GetArenaState(ArenaName), ArenaName)) then
			return true
		end
	end
	
	return false
end





