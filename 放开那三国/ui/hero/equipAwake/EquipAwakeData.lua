-- Filename: EquipAwakeData.lua
-- Author: FQQ
-- Date: 2016-01-05
-- Purpose:装备觉醒数据层

module ("EquipAwakeData",package.seeall)

local _equipAwakeInfo = {}
--[[
    @des    : 设置可装备觉醒id列表
    @param  : 
    @return : 
--]]  
function setEquipAwakeInfo( pInfo )
    _equipAwakeInfo = pInfo
end

--[[
    @des    : 获取可装备觉醒id列表
    @param  : 
    @return : 
--]] 
function getEquipAwakeInfo( ... )
    return _equipAwakeInfo
end

--[[
    @des    : 主角可以装备的觉醒能力列表
    @param  : 
    @return : 
--]]
function getEquipAwakeArry( ... )

    local hid = UserModel.getUserHid()
    local awakeId_1 = HeroModel.getMasterTalentId(hid,1)
    local awakeId_2 = HeroModel.getMasterTalentId(hid,2)
    local awakeId_3 = HeroModel.getMasterTalentId(hid,3)
    local arryInfo = {}
    local equipAwakeArry = getEquipAwakeInfo()
    for k,v in pairs(equipAwakeArry) do
        if(awakeId_1 ~= tonumber(v) and awakeId_2 ~= tonumber(v) and awakeId_3 ~= tonumber(v))then
            local arry = {}
            arry.id = tonumber(k)
            arry.EquipId = tonumber(v)
            table.insert(arryInfo,arry)
        end
    end
    local function keySort ( dataCache1, dataCache2 )
        return tonumber(dataCache1.id) > tonumber(dataCache2.id)
    end
    table.sort( arryInfo, keySort)
    return arryInfo
end




