-- Filename: FormationModel.lua
-- Author: k
-- Date: 2013-07-01
-- Purpose: 该文件用于阵型数据模型

module ("FormationModel", package.seeall)

local formation = nil

-- 结构
--[[
 array
 {
 0:hid
 2:hid
 5:hid
 }

--]]

function getFormationInfo()
    if (formation == nil) then
        CCLuaLog (GetLocalizeStringBy("key_2124"))
        return nil
    end
    return formation
end

function setFormationInfo(pformationInfo)
    formation = pformationInfo
    DataCache.setFormationInfo(formation)
end


