local mod = shadowverse_tarot_cards
local save = require("scripts.save")

local Governing_Justice = {}
Governing_Justice.name = "Governing Justice"
Governing_Justice.ID = Isaac.GetItemIdByName("Governing Justice")

-- 获取本层的房间掉落物账本
local function GetRoomPickups()
    if not save.elses.roomPickups then
        save.elses.roomPickups = {}
    end
    return save.elses.roomPickups
end

-- 获取玩家的攻击力加成表
local function GetDamageBonuses()
    if not save.elses.justiceDamageBonuses then
        save.elses.justiceDamageBonuses = {}
    end
    return save.elses.justiceDamageBonuses
end

-- 价值函数
local function GetPickupValue(variant, subtype)
    if variant == PickupVariant.PICKUP_HEART then
        if subtype == HeartSubType.HEART_SOUL or subtype == HeartSubType.HEART_HALF_SOUL then return 4
        elseif subtype == HeartSubType.HEART_BLACK then return 5
        elseif subtype == HeartSubType.HEART_ETERNAL then return 5
        elseif subtype == HeartSubType.HEART_GOLDEN then return 5
        elseif subtype == HeartSubType.HEART_BONE then return 5
        elseif subtype == HeartSubType.HEART_ROTTEN then return 1
        elseif subtype == HeartSubType.HEART_DOUBLEPACK then return 2
        else return 1 end
    elseif variant == PickupVariant.PICKUP_COIN then
        if subtype == CoinSubType.COIN_NICKEL or subtype == CoinSubType.COIN_STICKYNICKEL then return 3
        elseif subtype == CoinSubType.COIN_DIME then return 5
        elseif subtype == CoinSubType.COIN_LUCKYPENNY then return 8
        elseif subtype == CoinSubType.COIN_GOLDEN then return 7
        elseif subtype == CoinSubType.COIN_DOUBLEPACK then return 2
        else return 1 end
    elseif variant == PickupVariant.PICKUP_KEY then
        if subtype == KeySubType.KEY_GOLDEN then return 7
        elseif subtype == KeySubType.KEY_CHARGED then return 5
        else return 2 end
    elseif variant == PickupVariant.PICKUP_BOMB then
        if subtype == BombSubType.BOMB_GOLDEN then return 7
        elseif subtype == BombSubType.BOMB_GIGA then return 10
        elseif subtype == BombSubType.BOMB_DOUBLEPACK then return 2
        else return 1 end
    elseif variant == PickupVariant.PICKUP_LIL_BATTERY then
        if subtype == BatterySubType.BATTERY_MICRO then return 2
        elseif subtype == BatterySubType.BATTERY_NORMAL then return 4
        elseif subtype == BatterySubType.BATTERY_MEGA then return 8
        elseif subtype == BatterySubType.BATTERY_GOLDEN then return 7
        else return 2 end
    elseif variant == PickupVariant.PICKUP_TAROTCARD then
        if (subtype >= 32 and subtype <= 42) or (subtype >= 80 and subtype <= 97) then return 4
        elseif subtype == 49 then return 4
        elseif subtype == 78 then return 2
        else return 2 end
    elseif variant == PickupVariant.PICKUP_PILL then
        if subtype == 14 then return 7
        else return 2 end
    end
    return 0 
end

function mod:OnRoomClear_Justice(rng, spawnPosition)
    local itemCount = 0
    local probability = 30

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        itemCount = itemCount + player:GetCollectibleNum(Governing_Justice.ID)
    end

    if itemCount > 0 then
        local chance = math.min(100, itemCount * probability)
        if rng:RandomInt(100) <= chance then
            local room = Game():GetRoom()
            local safePos = room:FindFreePickupSpawnPosition(spawnPosition, 0, true)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_JUSTICE, safePos, Vector(0, 0), nil)
        end
    end
end


-- 拾取掉落物获得无敌
function mod:OnPickupCollision_Justice(pickup, collider, low)
    local player = collider:ToPlayer()
    local invincibletime = 48 -- 48帧 = 0.8秒
    if player == nil then return nil end

    if player:HasCollectible(Governing_Justice.ID) then
        local variant = pickup.Variant
        local isValidPickup = (
            variant == PickupVariant.PICKUP_COIN or
            variant == PickupVariant.PICKUP_HEART or
            variant == PickupVariant.PICKUP_KEY or
            variant == PickupVariant.PICKUP_BOMB
        )

        if isValidPickup then
            if pickup.Price == 0 or player:GetNumCoins() >= pickup.Price then
                player:SetMinDamageCooldown(invincibletime)
            end
        end
    end
end

-- 3：每帧记录房间内的掉落物
function mod:OnPostUpdate_Justice()
    local roomIndex = Game():GetLevel():GetCurrentRoomIndex()
    if roomIndex < 0 then return end 

    local pickups = {}
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP then
            local pickup = entity:ToPickup()
            if pickup and pickup.Price == 0 and not pickup:IsShopItem()
                and pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE
                and pickup.Variant ~= PickupVariant.PICKUP_TRINKET then
                table.insert(pickups, { variant = pickup.Variant, subtype = pickup.SubType })
            end
        end
    end
    
    local roomPickups = GetRoomPickups()
    roomPickups[tostring(roomIndex)] = pickups 
end

-- 4：结算伤害并清空账本
function mod:OnNewLevel_Justice()
    local totalValue = 0
    local roomPickups = GetRoomPickups()

    -- 翻看上一层记录的所有房间
    for roomIdx, pickups in pairs(roomPickups) do
        for _, p in ipairs(pickups) do
            totalValue = totalValue + GetPickupValue(p.variant, p.subtype)
        end
    end

    local damageBonus = totalValue * 0.01
    local bonuses = GetDamageBonuses()

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(Governing_Justice.ID) then
            -- 使用掉落种子区分玩家
            local playerKey = tostring(player.InitSeed)
            bonuses[playerKey] = (bonuses[playerKey] or 0) + damageBonus

            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
    end

    save.elses.roomPickups = {}
end

-- 5：将攻击力加给玩家面板
function mod:OnEvaluateCache_Justice(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        if player:HasCollectible(Governing_Justice.ID) then
            local playerKey = tostring(player.InitSeed)
            local bonuses = GetDamageBonuses()
            
            if bonuses[playerKey] and bonuses[playerKey] > 0 then
                player.Damage = player.Damage + bonuses[playerKey]
            end
        end
    end
end

-- 6：UI 渲染：实时显示当前层累计价值 (用于测试)
function mod:OnRender_Justice()
    local hasItem = false
    for i = 0, Game():GetNumPlayers() - 1 do
        if Isaac.GetPlayer(i):HasCollectible(Governing_Justice.ID) then
            hasItem = true
            break
        end
    end

    if hasItem then
        local currentTotalValue = 0
        local roomPickups = GetRoomPickups()
        for roomIdx, pickups in pairs(roomPickups) do
            for _, p in ipairs(pickups) do
                currentTotalValue = currentTotalValue + GetPickupValue(p.variant, p.subtype)
            end
        end
        local expectedDamage = currentTotalValue * 0.01
        local text = "Floor Value: " .. currentTotalValue .. " (Next Floor +" .. string.format("%.2f", expectedDamage) .. " DMG)"

        Isaac.RenderText(text, 50, 50, 1, 1, 1, 1)
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear_Justice)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.OnPickupCollision_Justice)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.OnPostUpdate_Justice)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.OnNewLevel_Justice)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.OnEvaluateCache_Justice)
-- mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.OnRender_Justice)

return Governing_Justice