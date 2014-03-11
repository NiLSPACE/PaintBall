function LoadArenas()
	local IniFile = cIniFile()
	
	-- We can't even read the Arenas.ini file. Lets bail out.
	if (not IniFile:ReadFile(g_Plugin:GetLocalFolder() .. "/Arenas.ini")) then
		return
	end
	
	for I = 0, IniFile:GetNumKeys() - 1 do
		local ArenaName = IniFile:GetKeyName(I)
		local LobbySpawn = StringSplit(IniFile:GetValue(ArenaName, "SpawnPointLobby"), ",")
		ARENAS[ArenaName] = 
		{
			WorldName = IniFile:GetValue(ArenaName, "WorldName"),
			HasStarted = false,
			SpawnPointsBlue = {}, 
			SpawnPointsRed = {}, 
			SpawnPointsSpectator = {}, 
			SpawnPointLobby = Vector3f(LobbySpawn[1], LobbySpawn[2], LobbySpawn[3]),
			Teams = {Blue = {}, Red = {}, Spectator = {}}
		}
		
		-- Load the spawn point for the blue team.
		local SpawnPointsBlue = StringSplit(IniFile:GetValue(ArenaName, "SpawnPointsBlue"), ";")
		for Idx, SpawnPoint in pairs(SpawnPointsBlue) do
			local Coords = StringSplit(SpawnPoint, ",")
			table.insert(ARENAS[ArenaName].SpawnPointsBlue, Vector3f(Coords[1], Coords[2], Coords[3]))
		end
		
		-- Load the spawn point for the red team.
		local SpawnPointsRed = StringSplit(IniFile:GetValue(ArenaName, "SpawnPointsRed"), ";")
		for Idx, SpawnPoint in pairs(SpawnPointsRed) do
			local Coords = StringSplit(SpawnPoint, ",")
			table.insert(ARENAS[ArenaName].SpawnPointsRed, Vector3f(Coords[1], Coords[2], Coords[3]))
		end
		
		-- Load the spawn point for the spectators.
		local SpawnPointsSpectator = StringSplit(IniFile:GetValue(ArenaName, "SpawnPointsSpectator"), ";")
		for Idx, SpawnPoint in pairs(SpawnPointsSpectator) do
			local Coords = StringSplit(SpawnPoint, ",")
			table.insert(ARENAS[ArenaName].SpawnPointsSpectator, Vector3f(Coords[1], Coords[2], Coords[3]))
		end		
	end
end

function SaveArenas()
	local IniFile = cIniFile()
	for ArenaName, Data in pairs(ARENAS) do
		-- For all teams create one big string with the x, y and z coordinates specated with an ',' and the spawnpoints seperated with an ';'
		local SpawnPointString = ""
		for Idx, SpawnPoint in pairs(Data.SpawnPointsBlue) do
			SpawnPointString = SpawnPointString .. SpawnPoint.x .. "," .. SpawnPoint.y .. "," .. SpawnPoint.z .. ";"
		end
		IniFile:SetValue(ArenaName, "SpawnPointsBlue", SpawnPointString)
		
		local SpawnPointString = ""
		for Idx, SpawnPoint in pairs(Data.SpawnPointsRed) do
			SpawnPointString = SpawnPointString .. SpawnPoint.x .. "," .. SpawnPoint.y .. "," .. SpawnPoint.z .. ";"
		end
		IniFile:SetValue(ArenaName, "SpawnPointsRed", SpawnPointString)
		
		local SpawnPointString = ""
		for Idx, SpawnPoint in pairs(Data.SpawnPointsSpectator) do
			SpawnPointString = SpawnPointString .. SpawnPoint.x .. "," .. SpawnPoint.y .. "," .. SpawnPoint.z .. ";"
		end
		IniFile:SetValue(ArenaName, "SpawnPointSpectator", SpawnPointString)
		
		-- Save the worldname
		IniFile:SetValue(ArenaName, "WorldName", Data.WorldName)
		
		-- Save the spawn point for the lobby.
		IniFile:SetValue(ArenaName, "SpawnPointLobby", Data.SpawnPointLobby.x .. "," .. Data.SpawnPointLobby.y .. "," .. Data.SpawnPointLobby.z)
	end
	IniFile:WriteFile(g_Plugin:GetLocalFolder() .. "/Arenas.ini")
end