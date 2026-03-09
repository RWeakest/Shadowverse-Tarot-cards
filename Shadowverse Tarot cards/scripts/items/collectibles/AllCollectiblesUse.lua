local mod = shadowverse_tarot_cards
local game = Game() 
local sfx = SFXManager()

--触发属性计算器
function mod:AllItemAfterPickUp(player)
	local d = player:GetData()
	
	d["OldItemCount"] = d["OldItemCount"] or 0
	d["NewItemCount"] = d["NewItemCount"] or 0
	
	d["OldItemCount"] = player:GetCollectibleCount()
	
	if d["OldItemCount"] ~= d["NewItemCount"] then
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
	
	d["NewItemCount"] = player:GetCollectibleCount()

end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.AllItemAfterPickUp)

--拾取道具通用
function mod:WhenPickUp(player)
	
	local idx = player:GetData().__Index
	local d = player:GetData()
	
	d["WhenPickUp_GET"] = d["WhenPickUp_GET"] or false
	d["WhenPickUp_itemid"] = d["WhenPickUp_itemid"] or 0
	
	if not player:IsItemQueueEmpty() then
		local itemid = player.QueuedItem.Item.ID
		--分辨拾取道具
		if not player.QueuedItem.Touched then
			
			-- 玩家拾取了道具，触发自定义事件
			d["WhenPickUp__GET"] = true
			d["WhenPickUp_itemid"] = itemid
			
		end	
		
	else
		
		if d["WhenPickUp__GET"] and d["WhenPickUp_itemid"] ~= 0 then
			-- print("test")
			local Collectibles_callback_function = tostring(d["WhenPickUp_itemid"]).."_CallBack"
			Isaac.RunCallback(Collectibles_callback_function,player)
			d["WhenPickUp__GET"] = false
		end
		
	end

end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.WhenPickUp)
