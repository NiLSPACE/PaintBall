

-- The table that contains all the player states.
g_PlayerStates = {}





function CreatePlayerState(a_Player)
	local self = {}
	
	local SelectedArena = nil
	local JoinedArena   = nil
	
	do -- The functions for managing the selected arena.
		-- Returns true if the player has an arena selected.
		function self:HasArenaSelected()
			return (SelectedArena ~= nil)
		end
		
		-- Changes the arena wich the player has selected.
		function self:SelectArena(a_Arena)
			if (ArenaStateExists(a_Arena)) then
				SelectedArena = a_Arena
				return true
			end
			return false
		end
		
		-- Returns the name of the selected arena.
		function self:GetSelectedArena()
			return SelectedArena
		end
	end
	
	do -- The functions managing the joined arena.
		-- Returns true if the player joined an arena.
		function self:HasJoinedArena()
			return (JoinedArena ~= nil)
		end
		
		-- Changes the arena that the player has joined.
		function self:JoinArena(a_Arena)
			JoinedArena = a_Arena
		end
		
		-- returns the name of the joined arena.
		function self:GetJoinedArena()
			return JoinedArena
		end
	end
	
	return self
end





-- This function returns the playerstate of a player. If it doesn't exist it creates it first and then returns it.
function GetPlayerState(a_Player)
	local Name = a_Player:GetName()
	local PlayerState = g_PlayerStates[Name]
	if (PlayerState ~= nil) then
		return PlayerState
	end
	
	PlayerState = CreatePlayerState(a_Player)
	g_PlayerStates[Name] = PlayerState
	return PlayerState
end