--[[
    文件名：ShengyuanWarsStatusHelper.lua
    描述：天河海之战状态Helper
    创建人：xiongyuhao
    创建时间：2016.11.16
-- ]]
ShengyuanWarsStatusHelper = {
    eGodDomainTeamState = 0,   -- 0.初始状态 1.组队中 2.匹配中 3.战场中
    eGodDomainLeaderId = EMPTY_ENTITY_ID,     -- 队长ID，初始为EMPTY_ENTITY_ID
    eGodDomainTeamModuleId = 0,   -- 模块ID，天河海队伍和圣元队伍不能共存
    eIsFirstToGame = true,
}

-- 清空缓存数据
function ShengyuanWarsStatusHelper:resetCache()
    self.eGodDomainTeamState = 0
    self.eGodDomainLeaderId = EMPTY_ENTITY_ID
    self.eGodDomainTeamModuleId = 0
    self.eIsFirstToGame = true
end

-- 设置进入状态是否为第一次进入
--[[
    params: 
        p: boolean false: 不是 true: 是
--]]
function ShengyuanWarsStatusHelper:setIsFirstToGame(b)
    if b == nil or type(b) ~= "boolean" then
        return
    end
    self.eIsFirstToGame = b
end

function ShengyuanWarsStatusHelper:getIsFirstToGame()
    return self.eIsFirstToGame 
end

-- 设置状态
function ShengyuanWarsStatusHelper:setGodDomainTeamState(status)
    if status ~= nil then
        self.eGodDomainTeamState = status
    end
end

-- 获取状态
function ShengyuanWarsStatusHelper:getGodDomainTeamState()
    return self.eGodDomainTeamState
end

-- 设置队长ID
function ShengyuanWarsStatusHelper:setGodDomainLeaderId(leaderId)
    if leaderId ~= nil then
        self.eGodDomainLeaderId = leaderId
    end
end

-- 获取队长ID
function ShengyuanWarsStatusHelper:getGodDomainLeaderId()
    return self.eGodDomainLeaderId
end

-- 设置模块ID
function ShengyuanWarsStatusHelper:setGodDomainTeamModuleId(moduleId)
    if moduleId ~= nil then
        self.eGodDomainTeamModuleId = moduleId
    end
end

-- 获取队长ID
function ShengyuanWarsStatusHelper:getGodDomainTeamModuleId()
    return self.eGodDomainTeamModuleId
end