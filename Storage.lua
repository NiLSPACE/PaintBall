
-- this file manages the saving and loading of the arenas.





-- Loads the arenas to Plugins/Paintball/Arenas.ini
function LoadArenas()
	local IniFile = cIniFile()
	
	-- We can't even read the Arenas.ini file. Lets bail out.
	if (not IniFile:ReadFile(g_Plugin:GetLocalFolder() .. "/Arenas.ini")) then
		return
	end
	
	for I = 0, IniFile:GetNumKeys() - 1 do
		local ArenaName = IniFile:GetKeyName(I)
		local LobbySpawn = StringSplit(IniFile:GetValue(ArenaName, "SpawnPointLobby"), ",")
		
		local ArenaState = InitializeArenaState(ArenaName, IniFile:GetValue(ArenaName, "WorldName"), Vector3f(LobbySpawn[1], LobbySpawn[2], LobbySpawn[3]))
		
		-- Load the spawn point for the blue team.
		local SpawnPointsBlue = StringSplit(IniFile:GetValue(ArenaName, "SpawnPointsBlue"), ";")
		for Idx, SpawnPoint in pairs(SpawnPointsBlue) do
			local Coords = StringSplit(SpawnPoint, ",")
			ArenaState:AddSpawnPointBlue(Vector3f(Coords[1], Coords[2], Coords[3]))
		end
		
		-- Load the spawn point for the red team.
		local SpawnPointsRed = StringSplit(IniFile:GetValue(ArenaName, "SpawnPointsRed"), ";")
		for Idx, SpawnPoint in pairs(SpawnPointsRed) do
			local Coords = StringSplit(SpawnPoint, ",")
			ArenaState:AddSpawnPointRed(Vector3f(Coords[1], Coords[2], Coords[3]))
		end
		
		-- Load the spawn point for the spectators.
		local SpawnPointsSpectator = StringSplit(IniFile:GetValue(ArenaName, "SpawnPointsSpectator"), ";")
		for Idx, SpawnPoint in pairs(SpawnPointsSpectator) do
			local Coords = StringSplit(SpawnPoint, ",")
			ArenaState:AddSpawnPointSpectator(Vector3f(Coords[1], Coords[2], Coords[3]))
		end		
	end
end





-- Saves all the arena's to a file.
function SaveArenas()
	local IniFile = cIniFile()
	for ArenaName, Data in pairs(g_ArenaStates) do
		-- For all teams create one big string with the x, y and z coordinates specated with an ',' and the spawnpoints seperated with an ';'
		local SpawnPointString = ""
		for Idx, SpawnPoint in pairs(Data["GetBlueSpawnpoints"]()) do
			SpawnPointString = SpawnPointString .. SpawnPoint.x .. "," .. SpawnPoint.y .. "," .. SpawnPoint.z .. ";"
		end
		IniFile:SetValue(ArenaName, "SpawnPointsBlue", SpawnPointString)
		
		local SpawnPointString = ""
		for Idx, SpawnPoint in pairs(Data["GetRedSpawnpoints"]()) do
			SpawnPointString = SpawnPointString .. SpawnPoint.x .. "," .. SpawnPoint.y .. "," .. SpawnPoint.z .. ";"
		end
		IniFile:SetValue(ArenaName, "SpawnPointsRed", SpawnPointString)
		
		local SpawnPointString = ""
		for Idx, SpawnPoint in pairs(Data["GetSpectatorSpawnpoints"]()) do
			SpawnPointString = SpawnPointString .. SpawnPoint.x .. "," .. SpawnPoint.y .. "," .. SpawnPoint.z .. ";"
		end
		IniFile:SetValue(ArenaName, "SpawnPointsSpectator", SpawnPointString)
		
		-- Save the worldname
		IniFile:SetValue(ArenaName, "WorldName", Data["GetWorldName"]())
		
		-- Save the spawn point for the lobby.
		IniFile:SetValue(ArenaName, "SpawnPointLobby", Data["GetLobbySpawn"]().x .. "," .. Data["GetLobbySpawn"]().y .. "," .. Data["GetLobbySpawn"]().z)
	end
	IniFile:WriteFile(g_Plugin:GetLocalFolder() .. "/Arenas.ini")
end