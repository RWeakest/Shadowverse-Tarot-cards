local mod = shadowverse_tarot_cards
local save = require("scripts.save")

local Inspiring_Strength = {}
Inspiring_Strength.name = "Inspiring Strength"
Inspiring_Strength.ID = Isaac.GetItemIdByName("Inspiring Strength")

function mod:OnRoomClear(rng, spawnPosition)
    local itemCount = 0
    local probability = 30

    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        itemCount = itemCount + player:GetCollectibleNum(Inspiring_Strength.ID)
    end

    if itemCount > 0 then
        local chance = math.min(100, itemCount * probability)

        if rng:RandomInt(100) <= chance then
            local room = Game():GetRoom()
            local safePos = room:FindFreePickupSpawnPosition(spawnPosition, 0, true)

            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_TAROTCARD,
                Card.CARD_STRENGTH,
                safePos,
                Vector(0, 0),
                nil
            )
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear)

-- 辅助函数：安全地获取或初始化存档数据
local function GetStrengthBonus(playerKey)
    if not save.elses.strengthBonus then 
        save.elses.strengthBonus = {} 
    end
    if not save.elses.strengthBonus[playerKey] then
        save.elses.strengthBonus[playerKey] = { damage = 0, speed = 0, range = 0, tears = 0, shotSpeed = 0, luck = 0 }
    end
    return save.elses.strengthBonus[playerKey]
end

-- 获取玩家上一帧的真实属性
local function GetPrevStats(playerKey)
    if not save.elses.prevPlayerStats then 
        save.elses.prevPlayerStats = {} 
    end
    return save.elses.prevPlayerStats
end

-- 获取触发过效果的房间账本
local function GetRoomRecords()
    if not save.elses.strengthRooms then 
        save.elses.strengthRooms = {} 
    end
    return save.elses.strengthRooms
end


-- 核心逻辑：剔除加成，获取玩家真实的“基础属性”
local function GetActualStats(player, bonus)
    local tps = 0
    if player.MaxFireDelay > -1 then
        tps = 30 / (player.MaxFireDelay + 1)
    end
    
    return {
        damage = player.Damage - bonus.damage,
        speed = player.MoveSpeed - bonus.speed,
        range = player.TearRange - bonus.range,
        tears = tps - bonus.tears,
        shotSpeed = player.ShotSpeed - bonus.shotSpeed,
        luck = player.Luck - bonus.luck
    }
end


-- 1. 玩家更新：监测属性变动
function mod:OnPlayerUpdate_Strength(player)
    local playerKey = tostring(player.InitSeed)
    local hasItem = player:HasCollectible(Inspiring_Strength.ID)
    
    -- 获取玩家当前的额外加成
    local bonustimes = 0.10
    local bonus = { damage = 0, speed = 0, range = 0, tears = 0, shotSpeed = 0, luck = 0 }
    if hasItem then
        bonus = GetStrengthBonus(playerKey)
    end

    local actualStats = GetActualStats(player, bonus)
    local prevStatsTable = GetPrevStats(playerKey)

    if not prevStatsTable[playerKey] then
        prevStatsTable[playerKey] = actualStats
        return
    end

    local prevStats = prevStatsTable[playerKey]

    -- 只有当拥有道具时，才判定是否给予加成
    if hasItem then
        local roomIndex = tostring(Game():GetLevel():GetCurrentRoomIndex())
        local roomRecords = GetRoomRecords()
        local statIncreased = false
        
        -- 防止以撒浮点数精度误差导致误判
        local epsilon = 0.001 

        if not roomRecords[roomIndex] then
            if actualStats.damage > prevStats.damage + epsilon then
                bonus.damage = bonus.damage + (actualStats.damage - prevStats.damage) * bonustimes
                statIncreased = true
            end
            if actualStats.speed > prevStats.speed + epsilon then
                bonus.speed = bonus.speed + (actualStats.speed - prevStats.speed) * bonustimes
                statIncreased = true
            end
            if actualStats.range > prevStats.range + epsilon then
                bonus.range = bonus.range + (actualStats.range - prevStats.range) * bonustimes
                statIncreased = true
            end
            if actualStats.tears > prevStats.tears + epsilon then
                bonus.tears = bonus.tears + (actualStats.tears - prevStats.tears) * bonustimes
                statIncreased = true
            end
            if actualStats.shotSpeed > prevStats.shotSpeed + epsilon then
                bonus.shotSpeed = bonus.shotSpeed + (actualStats.shotSpeed - prevStats.shotSpeed) * bonustimes
                statIncreased = true
            end
            if actualStats.luck > prevStats.luck + epsilon then
                bonus.luck = bonus.luck + (actualStats.luck - prevStats.luck) * bonustimes
                statIncreased = true
            end

            -- 如果这个房间内触发了任何属性提升
            if statIncreased then
                -- 记录该房间，此后即使退房重进/光环反复叠加，也不会再给加成
                roomRecords[roomIndex] = true
                
                -- (可选) 播放圣光音效给予正反馈
                SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1)

                -- 强制刷新玩家面板
                player:AddCacheFlags(CacheFlag.CACHE_ALL)
                player:EvaluateItems()
                
                -- 因为面板刚刚刷新，我们需要更新一下当前循环的 actualStats，防止下一帧误判
                actualStats = GetActualStats(player, bonus)
            end
        end
    end

    -- 无论是否有道具，永远保持对玩家真实属性的记录
    prevStatsTable[playerKey] = actualStats
end

-- 2：将加成应用到实际属性上
function mod:OnEvaluateCache_Strength(player, cacheFlag)
    if not player:HasCollectible(Inspiring_Strength.ID) then return end

    local playerKey = tostring(player.InitSeed)
    local bonus = GetStrengthBonus(playerKey)

    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + bonus.damage
    elseif cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + bonus.speed
    elseif cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + bonus.range
    elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
        local currentTPS = 30 / (player.MaxFireDelay + 1)
        local newTPS = currentTPS + bonus.tears
        if newTPS > 0 then
            player.MaxFireDelay = math.max(0, (30 / newTPS) - 1)
        end
    elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + bonus.shotSpeed
    elseif cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + bonus.luck
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.OnPlayerUpdate_Strength)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.OnEvaluateCache_Strength)

return Inspiring_Strength