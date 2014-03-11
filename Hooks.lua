
-- This file implements all the hook handlers.





function OnTakeDamage(a_Receiver, a_TDI)
	-- The receiver isn't an player. Don't even bother
	if (not a_Receiver:IsPlayer()) then
		return false
	end
	
	local Receiver = tolua.cast(a_Receiver, "cPlayer")
	local ReceiverName = Receiver:GetName()
	
	-- The player hasn't joined an arena. Lets bail out.
	if (ARENAJOINED[ReceiverName] == nil) then
		return false
	end
	
	if ((a_TDI.Attacker == nil) or (a_TDI.DamageType ~= dtRangedAttack)) then
		return true
	end
	
	-- The attacker isn't an projectile wich means it can't be an snowball.
	if (not a_TDI.Attacker:IsProjectile()) then
		return true
	end
	
	local Projectile = tolua.cast(a_TDI.Attacker, "cProjectileEntity")
	if (Projectile:GetProjectileKind() ~= cProjectileEntity.pkSnowball) then
		return true
	end
	
	local Creator = Projectile:GetCreator()
	if (not Creator:IsPlayer()) then
		return true
	end
	
	local Attacker = tolua.cast(Creator, "cPlayer")
	local AttackerName = Attacker:GetName()
	
	if (ARENAJOINED[AttackerName] == nil) then -- Don't let other players who are not in an arena affect playing people.
		return true
	end
	
	if (ARENAJOINED[ReceiverName] ~= ARENAJOINED[AttackerName]) then -- Wut?? Somebody from another arena attacked this player. Let's stop it.
		return true
	end
	
	local Arena = ARENAJOINED[ReceiverName]
		
	
	local Coords = nil
	-- Check wich team the player is in, give him snowballs and teleport him to one of their spawn points
	if (ARENAS[Arena].Teams.Blue[ReceiverName]) then
		Coords = ARENAS[Arena].SpawnPointsBlue[math.random(1, #ARENAS[Arena].SpawnPointsBlue)]
		GiveSnowballs(Receiver)
		
		-- Update the player information.
		ARENAS[Arena].Teams.Red[AttackerName].Kills = ARENAS[Arena].Teams.Red[AttackerName].Kills + 1
		ARENAS[Arena].Teams.Blue[ReceiverName].Deaths = ARENAS[Arena].Teams.Blue[ReceiverName].Deaths + 1
		
		BroadcastToArena(Arena, cChatColor.Rose .. AttackerName .. " hit " .. ReceiverName .. " [" .. ARENAS[Arena].Teams.Red[AttackerName].Kills .. "]") 
	end
	
	if (ARENAS[Arena].Teams.Red[ReceiverName]) then
		Coords = ARENAS[Arena].SpawnPointsRed[math.random(1, #ARENAS[Arena].SpawnPointsRed)]
		GiveSnowballs(Receiver)
		
		-- Update the player information.
		ARENAS[Arena].Teams.Blue[AttackerName].Kills = ARENAS[Arena].Teams.Blue[AttackerName].Kills + 1
		ARENAS[Arena].Teams.Red[ReceiverName].Deaths = ARENAS[Arena].Teams.Red[ReceiverName].Deaths + 1
		
		BroadcastToArena(Arena, cChatColor.Blue .. AttackerName .. " hit " .. ReceiverName .. " [" .. ARENAS[Arena].Teams.Blue[AttackerName].Kills .. "]")
	end
	
	if ((ARENAS[Arena].Teams.Red[ReceiverName] or ARENAS[Arena].Teams.Blue[ReceiverName]).Deaths >= g_DeathsNeeded) then
		(ARENAS[Arena].Teams.Red[ReceiverName] or ARENAS[Arena].Teams.Blue[ReceiverName]).IsPlaying = false
		Coords = ARENAS[Arena].SpawnPointLobby
		Receiver:SendMessage(cChatColor.Rose .. "You died.")
		
		-- There are not enough players left to have a proper match. Lets stop the arena.
		local TotalPlayers = GetNumPlayersInArena(Arena)
		if (TotalPlayers < MINPLAYERSNEEDED) then
			StopArena(Arena)
			return false
		end
	end
	
	Receiver:TeleportToCoords(Coords.x, Coords.y, Coords.z)
end





function OnPlayerDestroyed(a_Player)
	-- The player didn't join an arena. Wen can just leave.
	if (not ARENAJOINED[a_Player:GetName()]) then
		return false
	end
	
	
	local Arena = ARENAJOINED[a_Player:GetName()]
	local PlayerName = a_Player:GetName()
	
	local LobbyCoords = ARENAS[Arena].SpawnPointLobby
	
	-- There are not enough players left to have a proper match. Lets stop the arena.
	local TotalPlayers = GetNumPlayersInArena(Arena)
	if (TotalPlayers < MINPLAYERSNEEDED) then
		StopArena(Arena)
		return false
	end
	
	-- Remove the player from the team he was on.
	if (ARENAS[Arena].Teams.Red[PlayerName]) then
		ARENAS[Arena].Teams.Red[PlayerName] = nil
	elseif (ARENAS[Arena].Teams.Blue[PlayerName]) then
		ARENAS[Arena].Teams.Blue[PlayerName] = nil
	elseif (ARENAS[Arena].Teams.Spectator[PlayerName]) then
		ARENAS[Arena].Teams.Red[PlayerName] = nil
	end
	
	ARENAJOINED[a_Player:GetName()] = nil
end




function OnPlayerMoving(a_Player)
	if (not ARENAJOINED[a_Player:GetName()]) then
		return false
	end
	
	a_Player:Heal(20)
	a_Player:Feed(20, 20)
end





function OnBlockInteraction(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
	if (a_BlockFace == BLOCK_FACE_NONE) then
		return false
	end
	
	if (not ARENAJOINED[a_Player:GetName()]) then
		return false
	end
	
	a_Player:GetWorld():SendBlockTo(a_BlockX, a_BlockY, a_BlockZ, a_Player)
	return true
end