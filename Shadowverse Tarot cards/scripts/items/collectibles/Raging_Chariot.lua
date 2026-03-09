local mod = shadowverse_tarot_cards

local Raging_Chariot = {}
Raging_Chariot.name = "Raging Chariot"
Raging_Chariot.ID = Isaac.GetItemIdByName("Raging Chariot")

function mod:OnRoomClear(rng, spawnPosition)
    local itemCount = 0
    local probability = 30

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        itemCount = itemCount + player:GetCollectibleNum(Raging_Chariot.ID)
    end

    if itemCount > 0 then
        local chance = math.min(100, itemCount * probability)

        if rng:RandomInt(100) <= chance then
            local room = Game():GetRoom()
            local safePos = room:FindFreePickupSpawnPosition(spawnPosition, 0, true)

            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_TAROTCARD,
                Card.CARD_CHARIOT,
                safePos,
                Vector(0, 0),
                nil
            )
        end
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear)

local function IsValidEnemy(entity)
    return entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
end

function mod:OnPlayerCollision(player, collider, low)
    if not player:HasCollectible(Raging_Chariot.ID) then return nil end
    if not IsValidEnemy(collider) then return nil end

    local data = player:GetData()
    local currentFrame = Game():GetFrameCount()

    data.LastChariotCollisionFrame = currentFrame

    if data.RagingChariotReady == nil then
        data.RagingChariotReady = true
    end

    if data.RagingChariotReady then
        data.RagingChariotReady = false

        local rng = player:GetCollectibleRNG(Raging_Chariot.ID)

        if rng:RandomInt(100) < 77 then
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if IsValidEnemy(entity) then
                    entity:TakeDamage(77, 0, EntityRef(player), 0)
                end
            end

            player:AddHearts(2)
            player:SetMinDamageCooldown(60)
        else
            player:TakeDamage(4, 0, EntityRef(collider), 60)
        end
    end

    return false
end

mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, CallbackPriority.LATE, mod.OnPlayerCollision)

function mod:OnPlayerUpdate(player)
    if not player:HasCollectible(Raging_Chariot.ID) then return end

    local data = player:GetData()
    local currentFrame = Game():GetFrameCount()
    local lastCol = data.LastChariotCollisionFrame or 0

    if currentFrame - lastCol > 5 then
        data.RagingChariotReady = true
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.OnPlayerUpdate)

return Raging_Chariot
