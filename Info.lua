
-- Info.lua

-- Implements the g_PluginInfo standard plugin description




g_PluginInfo =
{
	Name = "PaintBall",
	Date = "2014-3-15",
	SourceLink = "https://github.com/STRWarrior/PaintBall",
	Description =
[[
This allows you to create arena's. In there two teams of players battle each other by throwing snowballs to each other. 
When a player gets hit by a snowball from another team member the player will be teleported to a spawnpoint wich is set up by the server admin.
]],
	Commands =
	{
		["/pb"] =
		{
			Permission = "",
			HelpString = "",
			Handler = nil,
			Subcommands =
			{
				select =
				{
					HelpString = "used to select an arena. In the selected arena you can add spawnpoints.",
					Permission = "paintball.select",
					Handler = HandleSelectCommand,
					ParameterCombinations =
					{
						{
							Params = "ArenaName",
							Help = "The name of the arena you would like to select.",
						},
					},
				},
				
				create =
				{
					HelpString = "Creates an new arena. The coordinates where you are will be the position for the lobby.",
					Permission = "paintball.create",
					Handler = HandleCreateCommand,
					ParameterCombinations =
					{
						{
							Params = "ArenaName",
							Help = "The name of the new arena you want to create.",
						},
					},
				},
				
				lobby =
				{
					HelpString = "Teleports you to the given arena lobby.",
					Permission = "paintball.lobby",
					Handler = HandleLobbyCommand,
					ParameterCombinations =
					{
						{
							Params = "ArenaName",
							Help = "The name of the arena you want to go to.",
						},
					},
				},
				
				add = 
				{
					HelpString = "Adds a new spawnpoint for the given team.",
					Permission = "paintball.add",
					Handler = HandleAddCommand,
					ParameterCombinations =
					{
						{
							Params = "red",
							Help = "Adds a spawnpoint for team red.",
						},
						
						{
							Params = "blue",
							Help = "Adds a spawnpoint for team blue.",
						},
						
						{
							Params = "spectator",
							Help = "Adds a spawnpoint for the spectators.",
						},
					},
				},
				
				join =
				{
					HelpString = "Join arena. Optional you can give the team you want to join.",
					Permission = "paintball.join",
					Handler = HandleJoinCommand,
					ParameterCombinations =
					{
						{
							Params = "ArenaName",
							Help = "The name of the arena you want to join.",
						},
					},
				},
				
				leave =
				{
					HelpString = "The player leaves the given arena. He also gets teleported to the lobby of the arena.",
					Permission = "paintball.leave",
					Handler = HandleLeaveCommand,
				},
				
				list =
				{
					HelpString = "Lists all the available arenas.",
					Permission = "paintball.list",
					Handler = HandleListCommand,
				},
			},
		},
	},
	
	AditionalInfo =
	{
		{
			Title = "Configurating",
			Contents =
[[
General
    MaxPlayersNeeded
    The value given will be halved and each time a player joins an arena the plugin checks if each team has at least that amount of players.
	
Game
    AmountGivenSnowballs
    When an arena starts all the players will receive an certain amount of snowballs that is set here.
    DeathsNeeded
    When a player is hit by a snowball he will "Die". When he died a certain amount of time he will be teleported to the lobby and won't be able to play until the arena restarts.
    PlayerCanChooseTeam
    If this is set to false a player can't choose between teams and always join a random team. Otherwise a player can give another parameter to the "/pb join" command. This can be Red, Blue or spectator.
]],
		},
	},
}



