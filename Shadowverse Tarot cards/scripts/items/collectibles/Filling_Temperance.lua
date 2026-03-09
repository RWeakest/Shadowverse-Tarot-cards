local mod = shadowverse_tarot_cards

local Filling_Temperance = {}
Filling_Temperance.name = "Filling Temperance"
Filling_Temperance.ID = Isaac.GetItemIdByName("Filling Temperance")

function mod:OnRoomClear(rng, spawnPosition)
    local itemCount = 0
    local probability = 30

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        itemCount = itemCount + player:GetCollectibleNum(Filling_Temperance.ID)
    end

    if itemCount > 0 then
        local chance = math.min(100, itemCount * probability)

        if rng:RandomInt(100) <= chance then
            local room = Game():GetRoom()
            local safePos = room:FindFreePickupSpawnPosition(spawnPosition, 0, true)

            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_TAROTCARD,
                Card.CARD_TEMPERANCE,
                safePos,
                Vector(0, 0),
                nil
            )
        end
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear)

function mod:OnNewRoom()
    local room = Game():GetRoom()

    if room:IsClear() then return end

    local totalCharges = 0
    local playerRef = nil

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(Filling_Temperance.ID) then
            playerRef = player
            local maxHearts = player:GetMaxHearts()
            local redHearts = player:GetHearts()

            local emptyContainers = math.floor((maxHearts - redHearts) / 2)
            if emptyContainers > 0 then
                totalCharges = totalCharges + (emptyContainers * 1)
            end
        end
    end

    if totalCharges <= 0 or not playerRef then return end

    local enemies = {}
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        
        -- 添加骷髅检测
        local isHidingEnemy = (ent.Type == EntityType.ENTITY_HOST or 
                               ent.Type == EntityType.ENTITY_MOBILE_HOST or 
                               ent.Type == EntityType.ENTITY_FLESH_MOBILE_HOST or 
                               ent.Type == EntityType.ENTITY_FLOATING_HOST 
                               )

        if ent:IsActiveEnemy() and (ent:IsVulnerableEnemy() or isHidingEnemy) then
            table.insert(enemies, ent)
        end
    end

    if #enemies == 0 then return end

    local rng = playerRef:GetCollectibleRNG(Filling_Temperance.ID)
    for i = #enemies, 2, -1 do
        local j = rng:RandomInt(i) + 1
        enemies[i], enemies[j] = enemies[j], enemies[i]
    end

    local currentEnemyIndex = 1

    for i = 1, totalCharges do
        if currentEnemyIndex > #enemies then
            break
        end

        local enemy = enemies[currentEnemyIndex]

        if enemy:IsBoss() then
            enemy:TakeDamage(30, 0, EntityRef(playerRef), 0)

            if enemy.HitPoints <= 0 or enemy:IsDead() then
                currentEnemyIndex = currentEnemyIndex + 1
            end
        else
            enemy:Kill()

            currentEnemyIndex = currentEnemyIndex + 1
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.OnNewRoom)

return Filling_Temperance
