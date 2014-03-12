
MAXPLAYERSNEEDED = 2
MINPLAYERSNEEDED = 2

SnowballAmount = 48
g_DeathsNeeded = 3 -- When a player has reached this amount of deaths he will be kicked from the arena.


function LoadConfig()
	local IniFile = cIniFile()
	IniFile:ReadFile(g_Plugin:GetLocalFolder() .. "/Config.ini")
	
	-- General
	MAXPLAYERSNEEDED = IniFile:GetValueSetI("General", "MaxPlayersNeeded", 2)
	MINPLAYERSNEEDED = IniFile:GetValueSetI("General", "MinPlayersNeeded", 2)
	
	-- In-game
	SnowballAmount   = IniFile:GetValueSetI("Game", "AmountGivenSnowballs", 48)
	g_DeathsNeeded     = IniFile:GetValueSetI("Game", "DeathsNeeded", 3)
	
	IniFile:WriteFile(g_Plugin:GetLocalFolder() .. "/Config.ini")
end