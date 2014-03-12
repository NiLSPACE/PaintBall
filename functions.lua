function GetSizeTable(a_Table)
	local Count = 0
	for Idx, Value in pairs(a_Table) do
		Count = Count + 1
	end
	return Count
end





function GiveSnowballs(a_Player)
	local Inventory = a_Player:GetInventory()
	Inventory:Clear()
	local Item = cItem(E_ITEM_SNOWBALL, SnowballAmount)
	Inventory:AddItem(Item)
end
