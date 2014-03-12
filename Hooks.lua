
-- This file implements all the hook handlers.





function OnTakeDamage(a_Receiver, a_TDI)
	-- The receiver isn't an player. Don't even bother
	if (not a_Receiver:IsPlayer()) then
		return false
	end
	
	local Receiver = tolua.cast(a_Receiver, "cPlayer")
	local ReceiverName = Receiver:GetName()
	local ReceiverState = GetPlayerState(Receiver)
	
	-- The player hasn't joined an arena. Lets bail out.
	if (not ReceiverState:HasJoinedArena()) then
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
	local AttackerState = GetPlayerState(Attacker)
	
	-- Don't let other players who are not in an arena affect playing people.
	if (not AttackerState:HasJoinedArena()) then
		return true
	end
	
	if (ReceiverState:GetJoinedArena() ~= AttackerState:GetJoinedArena()) then -- Wut?? Somebody from another arena attacked this player. Let's stop it.
		return true
	end
	
	local Arena = ReceiverState:GetJoinedArena()
	local ArenaState = GetArenaState(Arena)
	local Teams = ArenaState:GetTeams()
	
	local Coords = nil
	-- Check wich team the player is in, give him snowballs and teleport him to one of their spawn points
	if (Teams.Blue[ReceiverName]) then
		Coords = ArenaState:GetRandomBlueSpawn()
		GiveSnowballs(Receiver)
		
		-- Update the player information.
		Teams.Red[AttackerName].Kills = Teams.Red[AttackerName].Kills + 1
		Teams.Blue[ReceiverName].Deaths = Teams.Blue[ReceiverName].Deaths + 1
		
		ArenaState:BroadcastMessage(cChatColor.Rose .. AttackerName .. " hit " .. ReceiverName .. " [" .. Teams.Red[AttackerName].Kills .. "]") 
	end
	
	if (Teams.Red[ReceiverName]) then
		Coords = ArenaState:GetRandomRedSpawn()
		GiveSnowballs(Receiver)
		
		-- Update the player information.
		Teams.Blue[AttackerName].Kills = Teams.Blue[AttackerName].Kills + 1
		Teams.Red[ReceiverName].Deaths = Teams.Red[ReceiverName].Deaths + 1
		
		ArenaState:BroadcastMessage(cChatColor.Blue .. AttackerName .. " hit " .. ReceiverName .. " [" .. Teams.Blue[AttackerName].Kills .. "]")
	end
	
	if ((Teams.Red[ReceiverName] or Teams.Blue[ReceiverName]).Deaths >= g_DeathsNeeded) then
		(Teams.Red[ReceiverName] or Teams.Blue[ReceiverName]).IsPlaying = false
		Coords = SpawnPointLobby
		Receiver:SendMessage(cChatColor.Rose .. "You died.")
		
		-- There are not enough players left to have a proper match. Lets stop the arena.
		local TotalPlayers = ArenaState:GetNumPlayingPlayers()
		if (TotalPlayers < MINPLAYERSNEEDED) then
			ArenaState:StopArena()
			return false
		end
	end
	
	Receiver:TeleportToCoords(Coords.x, Coords.y, Coords.z)
end





function OnPlayerDestroyed(a_Player)
	local State = GetPlayerState(a_Player)
	
	-- The player didn't join an arena. We can just leave.
	if (not State:HasJoinedArena()) then
		return false
	end
	
	local ArenaState = GetArenaState(State:GetJoinedArena())
	
	State:JoinArena(nil)
	
	-- Remove the player from the team he was on.
	ArenaState:LeaveArena(a_Player:GetName())
	
	-- There are not enough players left to have a proper match. Lets stop the arena.
	local TotalPlayers = ArenaState:GetNumPlayingPlayers()
	if (TotalPlayers < MINPLAYERSNEEDED) then
		ArenaState:StopArena()
		return false
	end
end




function OnPlayerMoving(a_Player)
	-- Get the playerstate.
	local State = GetPlayerState(a_Player)
	
	-- Check if the player has joined any arena's.
	if (not State:HasJoinedArena()) then
		return false
	end
	
	-- Heal and feed the player.
	a_Player:Heal(20)
	a_Player:Feed(20, 20)
end





function OnBlockInteraction(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
	if (a_BlockFace == BLOCK_FACE_NONE) then
		return false
	end
	
	local State = GetPlayerState(a_Player)
	
	if (not State:HasJoinedArena()) then
		return false
	end
	
	-- Resend the block.
	a_Player:GetWorld():SendBlockTo(a_BlockX, a_BlockY, a_BlockZ, a_Player)
	return true
end