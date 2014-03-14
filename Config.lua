
MAXPLAYERSNEEDED = 2

SnowballAmount = 48
g_DeathsNeeded = 3 -- When a player has reached this amount of deaths he will be kicked from the arena.
g_CanChooseTeam = false


function LoadConfig()
	local IniFile = cIniFile()
	IniFile:ReadFile(g_Plugin:GetLocalFolder() .. "/Config.ini")
	
	-- General
	MAXPLAYERSNEEDED = IniFile:GetValueSetI("General", "MaxPlayersNeeded", 2)
	
	-- In-game
	SnowballAmount   = IniFile:GetValueSetI("Game", "AmountGivenSnowballs", 48)
	g_DeathsNeeded   = IniFile:GetValueSetI("Game", "DeathsNeeded", 3)
	g_CanChooseTeam  = IniFile:GetValueSetB("Game", "PlayerCanChooseTeam", false)
	
	IniFile:WriteFile(g_Plugin:GetLocalFolder() .. "/Config.ini")
end