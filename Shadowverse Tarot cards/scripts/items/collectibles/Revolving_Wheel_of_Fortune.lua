local mod = shadowverse_tarot_cards
local save = require("scripts.save")

local Revolving_Wheel_of_Fortune = {}
Revolving_Wheel_of_Fortune.name = "Revolving Wheel of Fortune"
Revolving_Wheel_of_Fortune.ID = Isaac.GetItemIdByName("Revolving Wheel of Fortune")

function mod:OnRoomClear(rng, spawnPosition)
    local itemCount = 0
    local probability = 30

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        itemCount = itemCount + player:GetCollectibleNum(Revolving_Wheel_of_Fortune.ID)
    end

    if itemCount > 0 then
        local chance = math.min(100, itemCount * probability)

        if rng:RandomInt(100) <= chance then
            local room = Game():GetRoom()
            local safePos = room:FindFreePickupSpawnPosition(spawnPosition, 0, true)

            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_TAROTCARD,
                Card.CARD_WHEEL_OF_FORTUNE,
                safePos,
                Vector(0, 0),
                nil
            )
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear)

local function GetWheelStats()
    if not save.elses.wheelStats then
        save.elses.wheelStats = { speed = 0, range = 0, tears = 0, shotSpeed = 0, damage = 0, luck = 0 }
    end
    return save.elses.wheelStats
end

local function TriggerWheelEffect(player)
    local rng = player:GetDropRNG()
    local roll = rng:RandomInt(22) + 1
    local pos = player.Position
    local room = Game():GetRoom()
    local safePos = room:FindFreePickupSpawnPosition(pos, 0, true)

    SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false, 1)

    local stats = GetWheelStats()

    if roll == 1 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, safePos, Vector(0, 0), nil)
    elseif roll == 2 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, safePos, Vector(0, 0), nil)
    elseif roll == 3 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, safePos, Vector(0, 0), nil)
    elseif roll == 4 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, safePos, Vector(0, 0), nil)
    elseif roll == 5 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, safePos, Vector(0, 0), nil)
    elseif roll == 6 then
        stats.speed = stats.speed + 0.02
    elseif roll == 7 then
        stats.speed = stats.speed + 0.01
    elseif roll == 8 then
        stats.range = stats.range + 0.40
    elseif roll == 9 then
        stats.range = stats.range + 0.20
    elseif roll == 10 then
        stats.range = stats.range + 0.10
    elseif roll == 11 then
        stats.tears = stats.tears + 0.30
    elseif roll == 12 then
        stats.tears = stats.tears + 0.20
    elseif roll == 13 then
        stats.tears = stats.tears + 0.05
    elseif roll == 14 then
        stats.shotSpeed = stats.shotSpeed + 0.03
    elseif roll == 15 then
        stats.shotSpeed = stats.shotSpeed + 0.02
    elseif roll == 16 then
        stats.shotSpeed = stats.shotSpeed + 0.01
    elseif roll == 17 then
        stats.damage = stats.damage + 0.5
    elseif roll == 18 then
        stats.damage = stats.damage + 0.1
    elseif roll == 19 then
        stats.damage = stats.damage + 0.02
    elseif roll == 20 then
        stats.luck = stats.luck + 1
    elseif roll == 21 then
        stats.luck = stats.luck + 0.1
    end

    if roll >= 6 and roll <= 21 then
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end

function mod:OnPlayerUpdate_Wheel(player)
    save.elses.playerPreviousCoins = save.elses.playerPreviousCoins or {}

    local currentCoins = player:GetNumCoins()
    local playerKey = tostring(player.InitSeed)

    if save.elses.playerPreviousCoins[playerKey] and save.elses.playerPreviousCoins[playerKey] > currentCoins then
        if player:HasCollectible(Revolving_Wheel_of_Fortune.ID) then
            TriggerWheelEffect(player)
        end
    end
    
    save.elses.playerPreviousCoins[playerKey] = currentCoins
end

function mod:OnCache_Wheel(player, cacheFlag)
    if not player:HasCollectible(Revolving_Wheel_of_Fortune.ID) then return end
    local stats = GetWheelStats()

    if cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + stats.speed
    elseif cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + (stats.range * 40)
    elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
        local currentTears = 30 / (player.MaxFireDelay + 1)
        local newTears = currentTears + stats.tears
        if newTears > 0 then player.MaxFireDelay = math.max(0, (30 / newTears) - 1) end
    elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + stats.shotSpeed
    elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + stats.damage
    elseif cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + stats.luck
    end
end
 
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.OnPlayerUpdate_Wheel)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.OnCache_Wheel)

return Revolving_Wheel_of_Fortune
