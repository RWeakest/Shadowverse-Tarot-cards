local json = require("json")

local item = {
	pre_ToCall = {},
	ToCall = {},
	post_ToCall = {},
	pre_myToCall = {},
	myToCall = {},
	post_myToCall = {},
	own_key = "SaveData_",
	over_unlock_info = {
	},
	Unlock_info = {
		UnlocksTemplate = {
			MomsHeart = {Unlock = false, Hard = false},
			Isaac = {Unlock = false, Hard = false},
			Satan = {Unlock = false, Hard = false},
			BlueBaby = {Unlock = false, Hard = false},
			Lamb = {Unlock = false, Hard = false},
			BossRush = {Unlock = false, Hard = false},
			Hush = {Unlock = false, Hard = false},
			MegaSatan = {Unlock = false, Hard = false},
			Delirium = {Unlock = false, Hard = false},
			Mother = {Unlock = false, Hard = false},
			Beast = {Unlock = false, Hard = false},
			GreedMode = {Unlock = false, Hard = false},
			FullCompletion = {Unlock = false, Hard = false},
		},
	},
}

local modReference
local Continue = false
local SAVE_STATE = {}
item.PERSISTENT_PLAYER_DATA = {}
item.elses = {}
item.base = {}
item.UnlockData = {}

function item.check_all_exists(ent)
	return (ent and type(ent) ~= "function" and ent.Exists and ent:Exists() and ent.IsDead and not ent:IsDead()) == true
end

function item.deepCopy(tb)
    if tb == nil then
        return nil
    end
    local copy = {}
    for k, v in pairs(tb) do
        if type(v) == 'table' then
            copy[k] = item.deepCopy(v)
        else
            copy[k] = v
        end
    end
    setmetatable(copy, item.deepCopy(getmetatable(tb)))
    return copy
end

function item.realrealdeepCopy(tb)	
	if type(tb) ~= 'table' then return tb end
    local copy = {}
    for k, v in pairs(tb) do
		if type(k) == 'number' or type(v) == 'table' then
		else copy[k] = v end
    end
    for k, v in pairs(tb) do
		if type(k) == 'number' or type(v) == 'table' then
			table.insert(copy,#copy + 1,{_r = k,_v = item.realrealdeepCopy(v),})
		end
    end
    setmetatable(copy, item.realrealdeepCopy(getmetatable(tb)))
    return copy
end

function item.irealrealdeepCopy(tb)
	if type(tb) ~= 'table' then return tb end
    local copy = {}
    for k, v in pairs(tb) do
		if type(v) == 'table' then
			local val = v._r or k
			copy[val] = item.irealrealdeepCopy(v._v or v)
		else
			copy[k] = v
		end
    end
    setmetatable(copy, item.irealrealdeepCopy(getmetatable(tb)))
    return copy
end

function item.get_achievement_init(name,init)
	local ret = {}
	for i, v in pairs(item.Unlock_info[name]) do ret[i] = {} for uu,vv in pairs(v) do ret[i][uu] = init end end
	return ret
end

function item.make_all_data(init)
	local ret = {}
	for u,v in pairs(item.over_unlock_info) do ret[u] = item.get_achievement_init(v,init) end
	return ret
end

function item.LockAll()
	for u,v in pairs(item.over_unlock_info) do item.UnlockData[u] = item.get_achievement_init(v,false) end
	--Achievement_Display_holder.PlayAchievement("gfx/ui/Some achievements/achievement_All_Locked.png")
end

function item.UnLockAll()
	for u,v in pairs(item.over_unlock_info) do item.UnlockData[u] = item.get_achievement_init(v,true) end
	--Achievement_Display_holder.PlayAchievement("gfx/ui/Some achievements/achievement_All_Unlocked.png")
end

function item.CheckAchievementAll()
	local tmp = item.make_all_data(false)
	for u,v in pairs(tmp) do 
		for uu,vv in pairs(v) do
			item.UnlockData[u][uu] = item.UnlockData[u][uu] or item.deepCopy(tmp[u][uu])
		end
	end
end

function item.SaveModData()
	SAVE_STATE.PERSISTENT_PLAYER_DATA = item.PERSISTENT_PLAYER_DATA
	SAVE_STATE.UNLOCK_DATA = item.realrealdeepCopy(item.UnlockData)
	--for u,v in pairs(item.over_unlock_info) do SAVE_STATE[u] = item.UnlockData[u] end
	SAVE_STATE.MODCONFIG = item.ModConfigSettings
	SAVE_STATE.ELSES = item.realrealdeepCopy(item.elses)
	SAVE_STATE.BASE = item.realrealdeepCopy(item.base)
	modReference:SaveData(json.encode(SAVE_STATE))
end

function item.LoadModData(continue)
	if Isaac.HasModData(modReference) then
		local dec = modReference:LoadData()
		local succ = pcall(function() SAVE_STATE = json.decode(dec) end)
		if not succ or type(SAVE_STATE) ~= "table" then
			print("Error: Failed to load Mod data. They will be re-initialized again.")
			SAVE_STATE = {}
		end
	else
		SAVE_STATE.ELSES = {}
		SAVE_STATE.PERSISTENT_PLAYER_DATA = {} 
	end
	if continue ~= true then 
		SAVE_STATE.ELSES = {}
		SAVE_STATE.PERSISTENT_PLAYER_DATA = {} 
	end
	item.PERSISTENT_PLAYER_DATA = SAVE_STATE.PERSISTENT_PLAYER_DATA or {}
	item.UnlockData = item.irealrealdeepCopy(SAVE_STATE.UNLOCK_DATA) or {}
	--for u,v in pairs(item.over_unlock_info) do item.UnlockData[u] = SAVE_STATE[u] or {} end
	item.ModConfigSettings = SAVE_STATE.MODCONFIG
	item.elses = item.irealrealdeepCopy(SAVE_STATE.ELSES) or {}
	item.base = item.irealrealdeepCopy(SAVE_STATE.BASE) or {}
	item.CheckAchievementAll()
end

if REPENTOGON then
table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_MAIN_MENU_RENDER, params = nil,
Function = function(_)
	if item.loaded == nil then 
		item.loaded = true
		item.LoadModData(true)
	end
end,
})
end

table.insert(item.pre_ToCall,#item.pre_ToCall + 1,{CallBack = ModCallbacks.MC_POST_PLAYER_INIT, params = nil,
Function = function(_,player)
	local TotPlayers = #Isaac.FindByType(EntityType.ENTITY_PLAYER)
	if TotPlayers == 0 and item.renewer ~= true then
		local continue = true
		if Game():GetFrameCount() == 0 then continue = false end
		item.LoadModData(continue)
		if continue ~= true then item.SaveModData() end
		item.renewer = true
	end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_GAME_STARTED, params = nil,
Function = function(_,continue)
	item.Started = true
	if continue ~= true then item.SaveModData() end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_NEW_LEVEL, params = nil,
Function = function()		--新下层
	item.SaveModData()
end,
})

table.insert(item.post_ToCall,#item.post_ToCall + 1,{CallBack = ModCallbacks.MC_PRE_GAME_EXIT, params = nil,
Function = function(_,shouldSave)		--离开游戏
	item.Started = nil
	item.renewer = nil
	if shouldSave == false then item.elses = {} end
	item.SaveModData()
end,
})

function item.add_player(player,tp)
	local pData = {
		__INDEX = #item.PERSISTENT_PLAYER_DATA + 1,
		__META = {
			Index = player.ControllerIndex,
			Seed = player.InitSeed,
			PlayerType = player:GetPlayerType(),
			player = player,		--有点危险
		}
	}
	table.insert(item.PERSISTENT_PLAYER_DATA, pData)
	player:GetData().__Index = #item.PERSISTENT_PLAYER_DATA
	--print("Add player "..player.InitSeed.." "..player:GetPlayerType().." "..player.ControllerIndex.." "..player:GetData().__Index.." "..(tp or ""))
end

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PLAYER_INIT, params = nil,		--小红罐、里拉萨路会让角色的种子反复变化，这点异常诡异。所以需要使用额外的策略来保证其正确。 此外，小红罐还会导致角色生成时类型变为0。
Function = function(_,player)
	local tp = player:GetPlayerType()
	if player:GetData().__Index then
		local idx = player:GetData().__Index
		item.PERSISTENT_PLAYER_DATA[idx] = {
			__INDEX = idx,
			__META = {
				Index = player.ControllerIndex,
				Seed = player.InitSeed,
				PlayerType = player:GetPlayerType(),
				player = player,
			}
		}
		return
	end
	for i, plyr in ipairs(item.PERSISTENT_PLAYER_DATA) do
		if player.ControllerIndex == plyr.__META.Index and player.InitSeed == plyr.__META.Seed and tp == plyr.__META.PlayerType then
			player:GetData().__Index = i
			plyr.__META.player = player
			return
		end
	end
	if Game():GetFrameCount() ~= 0 and item.Started ~= true then
		for i, plyr in ipairs(item.PERSISTENT_PLAYER_DATA) do		--小红罐
			if player.ControllerIndex == plyr.__META.Index and ((tp == plyr.__META.PlayerType) or (tp == 0 and plyr.__META.Once_type == 0)) and item.check_all_exists(plyr.__META.player) ~= true then
				player:GetData().__Index = i
				plyr.__META.Seeded = plyr.__META.Seed
				plyr.__META.Seed = player.InitSeed
				plyr.__META.player = player
				player:GetData()[item.own_key.."check"] = true
				return
			end
		end
	end
	if player:GetData().__Index == nil then item.add_player(player,"Init") end
end,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_POST_PLAYER_UPDATE, params = nil,
Function = function(_,player)
	local idx = player:GetData().__Index
	if idx and item.PERSISTENT_PLAYER_DATA[idx] and item.PERSISTENT_PLAYER_DATA[idx].__INDEX == idx then
		if item.PERSISTENT_PLAYER_DATA[idx].__META.Index == player.ControllerIndex and player.InitSeed == item.PERSISTENT_PLAYER_DATA[idx].__META.Seed then
			local pt = player:GetPlayerType()
			if item.PERSISTENT_PLAYER_DATA[idx].__META.PlayerType ~= pt then 
				if item.PERSISTENT_PLAYER_DATA[idx].__META.PlayerType == 0 then item.PERSISTENT_PLAYER_DATA[idx].__META.Once_type = 0 end
				item.PERSISTENT_PLAYER_DATA[idx].__META.PlayerType = pt 
			end
			return
		end
	end
	item.add_player(player,"Update")
end,
})
--针对沙漏的修复
function item.collect_data()
    Isaac.DebugString("Data Collected")
	--print("Test001")
    if item.should_load then
        item.should_load = nil
        if item.lst then
            local data = item.deepCopy(item.lst)
            local desc = item.elses
            item.elses = data
            --callback_manager.work("POST_REWIND",function(funct,params) funct(nil,"Glass",desc) end)
        end
        if item.lst3 then
            local data = item.deepCopy(item.lst3)
            local desc = item.base
            item.base = data
            --callback_manager.work("POST_REWIND",function(funct,params) funct(nil,"Glass",desc) end)
           item.base.RECORD_CONSOLE_HISTORY = item.deepCopy(desc.RECORD_CONSOLE_HISTORY)
            --callback_manager.work("POST_REWIND",function(funct,params) funct(nil,"Glass",desc) end)
        end
    end
    if item.should_load2 then
        Isaac.DebugString("Accept Reload")
        --print("Test002")
        item.should_load2 = nil
        local tg = item.lst2 
        if REPNETOGON then tg = item.lst end
        if tg then
            local data = item.deepCopy(tg)
            local desc = item.elses
            item.elses = data
            --callback_manager.work("POST_REWIND",function(funct,params) funct(nil,"Rewind",desc) end)
        end
        local tg = item.lst4 
        if REPNETOGON then tg = item.lst3 end
        if tg then
            local data = item.deepCopy(tg)
            local desc = item.base
            item.base = data
            item.base.RECORD_CONSOLE_HISTORY = item.deepCopy(desc.RECORD_CONSOLE_HISTORY)
            --callback_manager.work("POST_REWIND",function(funct,params) funct(nil,"Rewind",desc) end)
        end
    end
    local should_save = true
    local level = Game():GetLevel()
    if level:GetStage() == LevelStage.STAGE1_2 and (level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B) then
        local desc = level:GetCurrentRoomDesc()
        if desc.Data.Type == RoomType.ROOM_DEFAULT and desc.Data.Variant >= 10000 and desc.Data.Variant <= 10500 then        --镜子房间，不进行存储。
            should_save = false
        end
    end
    if should_save then
        item.lst2 = item.deepCopy(item.lst) or item.deepCopy(item.elses)
        item.lst = item.deepCopy(item.elses)
        item.lst4 = item.deepCopy(item.lst3) or item.deepCopy(item.base)
        item.lst3 = item.deepCopy(item.base)
    end
end
--针对沙漏的修复
table.insert(item.pre_ToCall,#item.pre_ToCall + 1,{CallBack = "UNIQUE_PRE_NEW_ROOM", params = nil,
Function = item.collect_data,
})

table.insert(item.ToCall,#item.ToCall + 1,{CallBack = ModCallbacks.MC_USE_ITEM, params = CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS,
Function = function(_, colid, rng, player, flags, slot, data)
	item.should_load = true
end,
})

local manager = {
	items = {},
	t_order = {"pre_","","post_",},
	t_priority = {-100,0,100,},
}

function item.Init(mod)
	modReference = mod
	for uk = 1,3 do
		if item[manager.t_order[uk].."ToCall"] then
			for j = 1,#(item[manager.t_order[uk].."ToCall"]) do
				if item[manager.t_order[uk].."ToCall"][j] ~= nil and item[manager.t_order[uk].."ToCall"][j].Function ~= nil and item[manager.t_order[uk].."ToCall"][j].CallBack ~= nil then
					local tg = item[manager.t_order[uk].."ToCall"][j]
					modReference:AddPriorityCallback(tg.CallBack,(tg.priority or 0) + manager.t_priority[uk],tg.Function,tg.params)
				end
			end
		end
	end
end

return item