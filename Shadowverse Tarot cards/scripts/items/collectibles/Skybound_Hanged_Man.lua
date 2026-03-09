local mod = shadowverse_tarot_cards
local save = require("scripts.save")

local Skybound_Hanged_Man = {}
Skybound_Hanged_Man.name = "Skybound Hanged Man"
Skybound_Hanged_Man.ID = Isaac.GetItemIdByName("Skybound Hanged Man")

function mod:OnRoomClear(rng, spawnPosition)
    local itemCount = 0
    local probability = 30

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        itemCount = itemCount + player:GetCollectibleNum(Skybound_Hanged_Man.ID)
    end

    if itemCount > 0 then
        local chance = math.min(100, itemCount * probability)

        if rng:RandomInt(100) <= chance then
            local room = Game():GetRoom()
            local safePos = room:FindFreePickupSpawnPosition(spawnPosition, 0, true)

            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_TAROTCARD,
                Card.CARD_HANGED_MAN,
                safePos,
                Vector(0, 0),
                nil
            )
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear)

local validPools = {
    0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 
    14, 15, 23, 24, 25, 26, 27, 28, 29, 30
}

local PoolNames = {
    [0] = "Treasure", [1] = "Shop", [2] = "Boss", [3] = "Devil", [4] = "Angel",
    [5] = "Secret", [6] = "Library", [8] = "Gold Chest", [9] = "Red Chest",
    [10] = "Beggar", [11] = "Demon Beggar", [12] = "Curse", [13] = "Key Master",
    [14] = "Battery Bum", [15] = "Mom Chest", [23] = "Crane Game",
    [24] = "Ultra Secret", [25] = "Bomb Bum", [26] = "Planetarium",
    [27] = "Old Chest", [28] = "Baby Shop", [29] = "Wood Chest", [30] = "Rotten Beggar"
}

local function GetPoolName(poolID)
    return PoolNames[poolID] or ("Unknown(" .. tostring(poolID) .. ")")
end


-- 飞行状态跨帧追踪 
function mod:OnPlayerUpdate_HangedManTracker(player)
    player:GetData().WasFlyingLastFrame = player.CanFly
end

function mod:OnNewRoom_HangedMan()
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player.CanFly or player:GetData().WasFlyingLastFrame then
            player:GetData().EnteredRoomFlying = true
        else
            player:GetData().EnteredRoomFlying = false
        end
    end
end

-- 混沌随机并记账
function mod:OnPreGetCollectible_HangedMan(pool, decrease, seed)
    if mod.IsChaoticRolling then return end

    local shouldChaos = false
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        
        if player:HasCollectible(Skybound_Hanged_Man.ID) then
            if player.CanFly or player:GetData().WasFlyingLastFrame or player:GetData().EnteredRoomFlying then
                shouldChaos = true
                break
            end
        end
    end

    if shouldChaos then
        local rng = RNG()
        rng:SetSeed(seed, 35)
        local randomPool = validPools[rng:RandomInt(#validPools) + 1]

        mod.IsChaoticRolling = true
        local itemID = Game():GetItemPool():GetCollectible(randomPool, decrease, seed)
        mod.IsChaoticRolling = false

        save.elses.itemToPoolMap = save.elses.itemToPoolMap or {}
        save.elses.itemToPoolMap[tostring(itemID)] = randomPool

        return itemID
    end
end

-- 处理没有混沌的正常道具
function mod:OnPostGetCollectible_HangedMan(selectedCollectible, pool, decrease, seed)
    if mod.IsChaoticRolling then return end 

    save.elses.itemToPoolMap = save.elses.itemToPoolMap or {}
    
    if not save.elses.itemToPoolMap[tostring(selectedCollectible)] then
        save.elses.itemToPoolMap[tostring(selectedCollectible)] = pool
    end
end

-- 查表计算唯一道具池
local DamageMultiplier = 0.15
function mod:OnEvaluateCache_HangedMan(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        if player:HasCollectible(Skybound_Hanged_Man.ID) then
            local map = save.elses.itemToPoolMap or {}
            
            local uniquePools = {}
            local poolCount = 0
            local collectedPoolNames = {}

            for i = 1, 2048 do
                if player:HasCollectible(i) then
                    local pID = map[tostring(i)]
                    
                    if pID then 
                        if not uniquePools[pID] then
                            uniquePools[pID] = true
                            poolCount = poolCount + 1
                            table.insert(collectedPoolNames, GetPoolName(pID))
                        end
                    end
                end
            end
            
            player:GetData().HangedManPoolCount = poolCount
            player:GetData().HangedManPoolNames = table.concat(collectedPoolNames, ", ")
            
            player.Damage = player.Damage + (poolCount * DamageMultiplier)
        end
    end
end

-- 显示数值与列表
function mod:OnRender_HangedMan()
    local hasItem = false
    local currentPoolCount = 0
    local poolNamesStr = "None"

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(Skybound_Hanged_Man.ID) then
            hasItem = true
            currentPoolCount = player:GetData().HangedManPoolCount or 0
            if player:GetData().HangedManPoolNames and player:GetData().HangedManPoolNames ~= "" then
                poolNamesStr = player:GetData().HangedManPoolNames
            end
            break
        end
    end

    if hasItem then
        local expectedDamage = currentPoolCount * DamageMultiplier
        local text1 = "Hanged Man Pools: " .. currentPoolCount .. " (Damage +" .. string.format("%.2f", expectedDamage) .. ")"
        local text2 = "Pool List: " .. poolNamesStr

        Isaac.RenderText(text1, 50, 50, 1, 1, 1, 1)
        Isaac.RenderText(text2, 50, 65, 1, 1, 1, 1) 
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.OnPlayerUpdate_HangedManTracker)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.OnNewRoom_HangedMan)
mod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, mod.OnPreGetCollectible_HangedMan)
mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, mod.OnPostGetCollectible_HangedMan)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.OnEvaluateCache_HangedMan)
-- mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.OnRender_HangedMan)

return Skybound_Hanged_Man