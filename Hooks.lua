
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
	
	local Succes = false
	local World = Projectile:GetWorld()
	local CreatorID = Projectile:GetCreatorUniqueID()
	World:DoWithEntityByID(CreatorID,
		function(a_Creator)
			if (not a_Creator:IsPlayer()) then
				return true
			end
			
			local Attacker = tolua.cast(a_Creator, "cPlayer")
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
			
			ArenaState:HitPlayer(Attacker, Receiver)
			Succes = true
		end
	)
	return Succes
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





function OnSpawnedEntity(a_World, a_Entity)
	if (not a_Entity:IsProjectile()) then
		return false
	end
	
	local Projectile = tolua.cast(a_Entity, "cProjectileEntity")
	local ProjectileType = Projectile:GetProjectileKind()
	
	if (not ProjectileType == cProjectileEntity.pkSnowball) then
		return false
	end
	
	local PlayerState;
	local World = Projectile:GetWorld()
	local CreatorID = Projectile:GetCreatorID()
	World:DoWithEntityByID(CreatorID,
		function(a_Creator)
			if (a_Creator == nil) then
				return false
			end
			
			if (not a_Creator:IsPlayer()) then
				return false
			end
			
			PlayerState = GetPlayerState(a_Creator)
		end
	)
	
	if (not PlayerState) then
		return false
	end
	
	if (not PlayerState:HasJoinedArena()) then
		return false
	end
	
	local JoinedArena = PlayerState:GetJoinedArena()
	
	-- Weird. The playerstate says we joined an arena but the arena doesn't exist. Lets "leave" that arena.
	if (not ArenaStateExists(JoinedArena)) then
		PlayerState:JoinArena(nil)
		return false
	end
	
	local ArenaState = GetArenaState(JoinedArena)
	ArenaState:AddStatsShotsFired()
	return false
end



	
