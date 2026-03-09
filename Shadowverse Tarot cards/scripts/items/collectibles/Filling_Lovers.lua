local mod = shadowverse_tarot_cards

local Filling_Lovers = {}
Filling_Lovers.name = "Filling Lovers"
Filling_Lovers.ID = Isaac.GetItemIdByName("Filling Lovers")

function mod:OnRoomClear(rng, spawnPosition)
    local itemCount = 0
    local probability = 30

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        itemCount = itemCount + player:GetCollectibleNum(Filling_Lovers.ID)
    end

    if itemCount > 0 then
        local chance = math.min(100, itemCount * probability)

        if rng:RandomInt(100) <= chance then
            local room = Game():GetRoom()
            local safePos = room:FindFreePickupSpawnPosition(spawnPosition, 0, true)

            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_TAROTCARD,
                Card.CARD_LOVERS,
                safePos,
                Vector(0, 0),
                nil
            )
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear)

function mod:OnHeartInit(pickup)
    -- 获取实体的自定义数据表，用来做标记
    local data = pickup:GetData()
    
    if data.loversProcessed then return end
    data.loversProcessed = true

    local hasItem = false
    local playerRng = nil
    
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(Filling_Lovers.ID) then
            hasItem = true
            playerRng = player:GetCollectibleRNG(Filling_Lovers.ID)
            break
        end
    end
    
    if hasItem and playerRng then
        local subtype = pickup.SubType
        local newSubtype = subtype
        
        if subtype == HeartSubType.HEART_SOUL or subtype == HeartSubType.HEART_HALF_SOUL then
            newSubtype = HeartSubType.HEART_BLACK
        elseif subtype == HeartSubType.HEART_FULL or subtype == HeartSubType.HEART_HALF then
            local roll = playerRng:RandomInt(100) 
            if roll < 70 then newSubtype = HeartSubType.HEART_DOUBLEPACK
            elseif roll < 80 then newSubtype = HeartSubType.HEART_SOUL
            elseif roll < 86 then newSubtype = HeartSubType.HEART_BLACK
            elseif roll < 92 then newSubtype = HeartSubType.HEART_BONE
            elseif roll < 98 then newSubtype = HeartSubType.HEART_GOLDEN
            else newSubtype = HeartSubType.HEART_ETERNAL end
        end
        
        if newSubtype ~= subtype then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, newSubtype, true, true, false)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.OnHeartInit, PickupVariant.PICKUP_HEART)

return Filling_Lovers
