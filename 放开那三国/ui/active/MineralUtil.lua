-- Filename：	MineralUtil.lua
-- Author：		bzx
-- Date：		2014-05-22
-- Purpose：		资源矿相关的工具

module ("MineralUtil", package.seeall)

require "script/model/user/UserModel"
require "db/DB_Res"
require "script/ui/tip/SingleTip"
require "db/DB_Normal_config"
require "script/utils/LuaUtil"

MY_MINERAL_MAX_COUNT = 2

PossessType = {
    occupy  = 1,    -- 占领
    guard   = 2,    -- 守卫
    all_not = 3     -- 都不是
}

function getMaxCount()
    return 2
end

-- 两个矿是不是同一个矿
function isEqual(mineral1, mineral2)
    local ret = true
    if mineral1 == nil or mineral2 == nil then
        ret = false
    end
    if ret then
        ret = mineral1.domain_id == mineral2.domain_id and mineral1.pit_id == mineral2.pit_id
    end
    return ret
end

function getPossessType(mineral)
    local possess_type = PossessType.all_not
    if tonumber(mineral.uid) == UserModel.getUserUid() then
        possess_type = PossessType.occupy
    else
        local guards = mineral.guards
        for i = 1, #guards do
            if UserModel.getUserUid() == tonumber(guards[i].uid) then
                possess_type = PossessType.guard
                break
            end
        end
    end
    return possess_type
end

-- 是否是我的矿
function isMyMineral(mineral)
    local possess_type = getPossessType(mineral)
    return PossessType.occupy == possess_type or PossessType.guard == possess_type
end


function isMyOccupyMineral(mineral)
    local possess_type = getPossessType(mineral)
    return possess_type == PossessType.occupy
end

function isMyGuardMineral(mineral)
    local possess_type = getPossessType(mineral)
    return possess_type == PossessType.guard
end

-- 刷新我的矿的缓存数据
function updateMyMineral(my_minerals, mineral)
    print("刷新")
    if tonumber(mineral.uid) > 0 then
        mineral.expireTime = BTUtil:getSvrTimeInterval() + tonumber(mineral.due_time)
    end
    --[[
    if mineral.protect_time ~= nil then
        mineral.protectExpireTime = BTUtil:getSvrTimeInterval() + tonumber(mineral.protect_time)
    end
    --]]
    my_minerals.guard_begin_time = tonumber(my_minerals.guard_start_time)
    local user_uid = UserModel.getUserUid()
    local updated = false
   
    for k, v in pairs(my_minerals) do
        local my_mineral = v
        if isEqual(my_mineral, mineral) then
            print("相等")
            updated = true
            if isMyMineral(mineral) then
                my_minerals[k] = mineral
            else
                my_minerals[k] = nil
            end
        end
    end
   
    --[[ new
    local i = 1
    while i <= #my_minerals do
        local my_mineral = my_minerals[i]
        if isEqual(my_mineral, mineral) then
            print("相等")
            updated = true
            table.remove(my_minerals, i)
            if isMyMineral(mineral)  then
                table.insert(my_minerals, mineral)
            else
                i = i - 1
            end
        end
        i = i + 1
    end
    --]]
    if not updated then
        if isMyGuardMineral(mineral) or isMyOccupyMineral(mineral) then
            print("新矿")
            if mineral.domain_type == "3" then
                my_minerals["2"] = mineral
            else
                my_minerals["1"] = mineral
            end
            --[[ new
            table.insert(my_minerals, mineral)
            --]]
            updated = true
        end
    end
    --[[
    if #my_minerals >= 2 and updated then
        table.sort(my_minerals, compareMineral)
    end
    --]]
    print("更新了", updated)
end

--[[
function compareMineral(mineral2, mineral1)
    local guard_weight = 1000
    local due_time_weight = 100
    local total_weight2 = 0
    local total_weight1 = 0
    if isMyGuardMineral(mineral2) then
        total_weight2 = total_weight2 + guard_weight
    end
    if isMyGuardMineral(mineral1) then
        total_weight1 = total_weight1 + guard_weight
    end
    if isMyOccupyMineral(mineral2) and isMyOccupyMineral(mineral1) then
        if mineral1.due_time < mineral2.due_time then
            total_weight1 = total_weight1 + due_time_weight
        end
    end
    return total_weight1 < total_weight2  + due_time_weight
end
--]]

function guardIsFull(mineral)
    local mineral_db = DB_Res.getDataById(tonumber(mineral.domain_id))
    local res_attr = mineral_db["res_attr" .. mineral.pit_id]
    local res_attr_arry = string.split(res_attr, ",")
    local guard_limit = tonumber(res_attr_arry[5])
    if #mineral.guards >= guard_limit then
        return true
    else
        return false
    end
end

function checkAddTime(mineral)
    local could_add_time = true
    local add_time_str = DB_Normal_config.getDataById(1).resAddTime
    local add_time_array = strToTable(add_time_str, {"n", "n", "n"})
    local add_time_limit = #add_time_array
    local current_add_times = tonumber(mineral.delay_times)
    local tip_text = nil
    local next_add_times = current_add_times + 1
    if UserModel.getGoldNumber() < add_time_array[ next_add_times][2] then
        could_add_time = false
        tip_text = GetLocalizeStringBy("key_8067")
    elseif UserModel.getEnergyValue() < add_time_array[ next_add_times][3] then
        require "script/ui/item/EnergyAlertTip"
        EnergyAlertTip.showTip(MineralLayer.refreshTopUI)
        return false
    end
    if not could_add_time then
        SingleTip.showTip(tip_text)
    end
    return could_add_time
end

function getAddTimeArray(mineral)
    
end

function checkGrabGuard(mineral)
    local could_grab = true
    local my_minerals = MineralLayer.getMyMineralInfo()
    local tip_text = nil
    if my_minerals["1"] == nil then
        could_grab = false
        tip_text = GetLocalizeStringBy("key_8069")
    else
        local my_mineral = my_minerals["1"]
        if isMyOccupyMineral(my_mineral) then
            if guardIsFull(my_mineral) then
                could_grab = false
                tip_text = GetLocalizeStringBy("key_8070")
            end
        else
            could_grab = false
            tip_text = GetLocalizeStringBy("key_8071")
        end
    end
    
    if could_grab then
        if isMyGuardMineral(mineral) then
            could_grab = false
            tip_text = GetLocalizeStringBy("key_8072")
        else
            if isMyOccupyMineral(mineral) then
                could_grab = false
                tip_text = GetLocalizeStringBy("key_8073")
            end
        end
    end
    
    if could_grab then
        if #mineral.guards == 0 then
            could_grab = false
            tip_text = GetLocalizeStringBy("key_8074")

        end
    end
    
    
    
    if not could_grab then
        SingleTip.showTip(tip_text)
    end
    return could_grab
end

function getUnionAddition( ... )
    require "script/ui/star/loyalty/LoyaltyData"
    require "db/DB_Hall_loyalty"
    local addition = 0
    -- 聚义堂额外积分
    local dataArray = DB_Hall_loyalty.getArrDataByField("type", 3)
    for i = 1, #dataArray do
        if LoyaltyData.isFunOpen(3, dataArray[i].id) then
            local additionTemp = tonumber(dataArray[i].num)
            addition = addition + additionTemp
        end
    end

    return addition
end
