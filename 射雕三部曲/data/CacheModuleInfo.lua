--[[
文件名:CacheModuleInfo.lua
描述：模块数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 模块信息数据说明
--[[
-- 单个模块数据json数据格式为：
    {
        SubModuleId = 2702,  -- 子模块Id
        OrderNum = 1,        -- 模块显示优先级
        IfOpen = 1,          -- 模块在服务器是否已开启，1:开启； 0:未开启
    }
]]

local CacheModuleInfo = class("CacheModuleInfo", {})

function CacheModuleInfo:ctor()
	self.mModuleInfo = {}
end

-- 清空管理对象中的数据
function CacheModuleInfo:reset()
	self.mModuleInfo = {}
end

--- 更新模块信息的缓存数据
function CacheModuleInfo:updateModuleInfo(moduleInfo)
    for index, item in pairs(moduleInfo or {}) do
        self.mModuleInfo[item.SubModuleId] = item
    end
end

--- 获取模块信息
--[[
-- 参数：
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的技能列表,如果为false，则不能对返回值做任何修改
-- 返回值：
 ]]
function CacheModuleInfo:getModulesInfo(needClone)
	return needClone and clone(self.mModuleInfo) or self.mModuleInfo
end

--- 根据模块Id获取其模块信息
--[[
-- 参数
    moduleId： 模块Id，在 EnumsConfig.lua 文件的 ModuleSub 枚举中定义
-- 返回值：
    {
        模块信息数据说明
    }
 ]]
function CacheModuleInfo:getModuleInfoById(moduleId)
    local ret = self.mModuleInfo[moduleId or 0]

    return ret
end

--- 获取某服务器是否已开启
--[[
-- 参数
    moduleId： 模块Id，在 EnumsConfig.lua 文件的 ModuleSub 枚举中定义
-- 返回值：true表示已开启，false表示没有开启
 ]]
function CacheModuleInfo:moduleIsOpenInServer(moduleId)
    local tempItem = self.mModuleInfo[moduleId or 0]
    if not tempItem then
        return true
    end
    return tempItem.IfOpen
end

--- 判断玩家某模块是否达到开放等级
--[[
-- 参数
    moduleId: 模块Id，取值在 “EnumsConfig.lua” 文件的 “ModuleSub”中定义
    needShowMsg: 当没有开启时是否需要飘窗提示
-- 返回值
    第一个返回值：玩家当前模块是否已开启，true表示已开启，false表示未开启
    第二个返回值：是一个表，包含玩家该模块开启的相关信息
        {
            openLv: 普通玩家的开启等级
            advancedOpenVIPLv: VIP玩家开启的VIP等级
            VIPNeedLv: VIP玩家开启的玩家等级
            openMessage: 玩家模块开启的提示信息
        }
 ]]
function CacheModuleInfo:modulePlayerIsOpen(moduleId, needShowMsg)
    if not moduleId then
        return false, {openMessage = "ModuleSub Id is nil"}
    end
    local moduleSubItem = ModuleSubModel.items[moduleId]
    if not moduleSubItem then
        return false, {openMessage = TR("非法的 ModuleSub: ") .. tostring(moduleId)}
    end
    local ret, retTable = false, {}
    retTable.openLv = moduleSubItem.openLv
    retTable.advancedOpenVIPLv = moduleSubItem.advancedOpenVIPLv
    retTable.VIPNeedLv = moduleSubItem.VIPNeedLv
    retTable.openMessage = ""
    
    local playerInfo = PlayerAttrObj:getPlayerInfo()
    if playerInfo.Vip < moduleSubItem.advancedOpenVIPLv or moduleSubItem.advancedOpenVIPLv == 0 then    -- 当普通玩家处理
        if playerInfo.Lv < moduleSubItem.openLv then
            -- 玩家最高等级
            local maxPlayerLv = PlayerConfig.items[1].maxPlayerLV

            -- 判断服务器是否已开启VIP模块
            local tempStr
            if self:moduleIsOpenInServer(ModuleSub.eVIP) and moduleSubItem.advancedOpenVIPLv ~= 0 then
                if retTable.openLv >= maxPlayerLv then  -- 玩家最高等级为
                    if playerInfo.Lv >= moduleSubItem.VIPNeedLv then
                        retTable.openMessage = TR("VIP%d玩家开启", moduleSubItem.advancedOpenVIPLv)
                    else
                        retTable.openMessage = TR("VIP%d %d级开启", moduleSubItem.advancedOpenVIPLv, moduleSubItem.VIPNeedLv)
                    end
                else
                    if playerInfo.Lv >= moduleSubItem.VIPNeedLv then 
                        retTable.openMessage = TR("玩家等级达到%d级或VIP%d开启", retTable.openLv, moduleSubItem.advancedOpenVIPLv) 
                    else
                        retTable.openMessage = TR("%d级开启该模块或VIP%d %d级开启", retTable.openLv, moduleSubItem.advancedOpenVIPLv, moduleSubItem.VIPNeedLv) 
                    end
                end
            else
                if retTable.openLv >= maxPlayerLv then
                    retTable.openMessage = TR("%s暂未开放", moduleSubItem.name)
                else
                    retTable.openMessage = TR("%d级开启%s", retTable.openLv, moduleSubItem.name)
                end
            end
        else
            ret = true
            retTable.openMessage = TR("%s已开启", moduleSubItem.name)
        end
    else -- 达到开启的Vip等级
        if playerInfo.Lv < moduleSubItem.VIPNeedLv then
            retTable.openMessage = TR("%d级开启%s", moduleSubItem.VIPNeedLv, moduleSubItem.name)
        else
            ret = true
            retTable.openMessage = TR("%s已开启", moduleSubItem.name)
        end
    end

    if not ret and needShowMsg then
        ui.showFlashView(retTable.openMessage)
    end

    return ret, retTable
end

-- 判断模块是否已经开启，包括判断服务器是否已开启和玩家等级是否已达到开启等级
--[[
-- 参数
    moduleId: 模块Id，取值在 “EnumsConfig.lua” 文件的 “ModuleSub”中定义
    needShowMsg: 当没有开启时是否需要飘窗提示, 默认为false
-- 返回值
    玩家当前模块是否已开启，true表示已开启，false表示未开启
 ]]
function CacheModuleInfo:moduleIsOpen(moduleId, needShowMsg)
    local serverIsOpen = self:moduleIsOpenInServer(moduleId)
    if not serverIsOpen then
        if needShowMsg then
            ui.showFlashView(TR("暂未开启"))
        end
        return false
    end

    return self:modulePlayerIsOpen(moduleId, needShowMsg)
end

return CacheModuleInfo