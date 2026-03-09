local mod = shadowverse_tarot_cards
local save = require("scripts.save")

local Wandering_Fool = {}
Wandering_Fool.name = "Wandering Fool"
Wandering_Fool.ID = Isaac.GetItemIdByName("Wandering Fool")

function mod:OnRoomClear(rng, spawnPosition)
    local itemCount = 0
    local probability = 30
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        itemCount = itemCount + player:GetCollectibleNum(Wandering_Fool.ID)
    end
    if itemCount > 0 then
        local chance = math.min(100, itemCount * probability)
        if rng:RandomInt(100) <= chance then
            local room = Game():GetRoom()
            local safePos = room:FindFreePickupSpawnPosition(spawnPosition, 0, true)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_FOOL, safePos, Vector(0, 0), nil)
        end
    end
end

-- 监测玩家动作
function mod:OnPlayerUpdate(player)
    if player:HasCollectible(Wandering_Fool.ID) then
        local sprite = player:GetSprite()
        if sprite:IsPlaying("TeleportUp") and sprite:GetFrame() == 0 then
            -- 如果是第一次传送，初始化为0再加1
            save.elses.teleportCount = (save.elses.teleportCount or 0) + 1
        end
    end
end

-- 敌人初始化
function mod:OnNPCInit(npc)
    local currentTeleports = save.elses.teleportCount or 0
    if currentTeleports <= 0 then return end

    if npc:IsEnemy()
        and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
        and npc.MaxHitPoints > 0
        and npc.Type ~= EntityType.ENTITY_SHOPKEEPER 
        and npc.Type ~= EntityType.ENTITY_FIREPLACE  
        and npc.Type ~= EntityType.ENTITY_MOVABLE_TNT 
    then
        local newMaxHP = math.max(1, npc.MaxHitPoints - currentTeleports)
        local newHP = math.max(0, npc.HitPoints - currentTeleports)

        npc.MaxHitPoints = newMaxHP
        npc.HitPoints = newHP

        if npc.HitPoints <= 0 then
            npc:Die()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.OnPlayerUpdate)
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.OnNPCInit)

return Wandering_Fool