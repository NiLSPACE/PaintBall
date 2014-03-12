function GetSizeTable(a_Table)
	local Count = 0
	for Idx, Value in pairs(a_Table) do
		Count = Count + 1
	end
	return Count
end





function StartArena(a_Arena)
	ARENAS[a_Arena].HasStarted = true
	local World = cRoot:Get():GetWorld(ARENAS[a_Arena].WorldName)
	if not World then
		return
	end
		
	for PlayerName, _ in pairs(ARENAS[a_Arena].Teams.Red) do
		World:DoWithPlayer(PlayerName, function(a_Player)
			local Coords = ARENAS[a_Arena].SpawnPointsRed[math.random(1, #ARENAS[a_Arena].SpawnPointsRed)]
			a_Player:TeleportToCoords(Coords.x, Coords.y, Coords.z)
			GiveSnowballs(a_Player)
			ARENAS[a_Arena].Teams.Red[PlayerName].IsPlaying = true
			a_Player:SendMessage(cChatColor.Rose .. "Game started.")
		end)
	end
	
	for PlayerName, _ in pairs(ARENAS[a_Arena].Teams.Blue) do
		World:DoWithPlayer(PlayerName, function(a_Player)
			local Coords = ARENAS[a_Arena].SpawnPointsBlue[math.random(1, #ARENAS[a_Arena].SpawnPointsBlue)]
			a_Player:TeleportToCoords(Coords.x, Coords.y, Coords.z)
			GiveSnowballs(a_Player)
			ARENAS[a_Arena].Teams.Blue[PlayerName].IsPlaying = true
			a_Player:SendMessage(cChatColor.Blue .. "Game started.")
		end)
	end
	
	for PlayerName, _ in pairs(ARENAS[a_Arena].Teams.Spectator) do
		World:DoWithPlayer(PlayerName, function(a_Player)
			local Coords = ARENAS[a_Arena].SpawnPointsBlue[math.random(1, #ARENAS[a_Arena].SpawnPointsSpectator)]
			a_Player:TeleportToCoords(Coords.x, Coords.y, Coords.z)
			GiveSnowballs(a_Player)
			ARENAS[a_Arena].Teams.Spectator[PlayerName].IsPlaying = true
			a_Player:SendMessage(cChatColor.Yellow .. "Game started.")
		end)
	end
end





function StopArena(a_Arena)
	if (not ARENAS[a_Arena].HasStarted) then
		return
	end
	
	local LobbyCoords = ARENAS[a_Arena].SpawnPointLobby
	
	local World = cRoot:Get():GetWorld(ARENAS[a_Arena].WorldName)
	for Team, Data in pairs(ARENAS[a_Arena].Teams) do
		for PlayerName, _ in pairs(Data) do
			World:DoWithPlayer(PlayerName, function(a_Player)
				a_Player:SendMessage(cChatColor.Rose .. "Arena stopped. The match is over.")
				a_Player:TeleportToCoords(LobbyCoords.x, LobbyCoords.y, LobbyCoords.z)
				local State = GetPlayerState(a_Player)
				State:JoinArena(nil)
			end)
		end
	end
	
	ARENAS[a_Arena].Teams = {Blue = {}, Red = {}, Spectator = {}}
	ARENAS[a_Arena].HasStarted = false
end





function BroadcastToArena(a_Arena, a_Message)
	local World = cRoot:Get():GetWorld(ARENAS[a_Arena].WorldName)	
	for Team, Data in pairs(ARENAS[a_Arena].Teams) do
		for PlayerName, _ in pairs(Data) do
			World:DoWithPlayer(PlayerName, function(a_Player)
				a_Player:SendMessage(a_Message)
			end)
		end
	end
end





function GiveSnowballs(a_Player)
	local Inventory = a_Player:GetInventory()
	Inventory:Clear()
	local Item = cItem(E_ITEM_SNOWBALL, SnowballAmount)
	Inventory:AddItem(Item)
end





-- Returns the amount of players who are actualy playing.
function GetNumPlayersInArena(a_Arena)
	if (not ARENAS[a_Arena]) then
		return
	end
	
	local res = 0
	for PlayerName, Data in pairs(ARENAS[a_Arena].Teams.Red) do
		if (Data.IsPlaying) then
			res = res + 1
		end
	end
	
	for PlayerName, Data in pairs(ARENAS[a_Arena].Teams.Blue) do
		if (Data.IsPlaying) then
			res = res + 1
		end
	end
	
	return res
end