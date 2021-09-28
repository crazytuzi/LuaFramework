--[[
文件名:CacheTimeLimit.lua
描述：“限时赏金” 数据抽象类型
创建人：liaoyuangang
创建时间：2016.07.02
--]]

-- 限时赏金信息的数据格式为
--[[
	{
		TriggerLv:当前触发等级
    	EndTime:领取结束时间
	}
]]

local CacheTimeLimit = class("CacheTimeLimit", {})

--[[
]]
function CacheTimeLimit:ctor()
	-- 限时赏金信息
    self.mLimitthebountyInfo = nil 
end

-- 重置限时赏金信息
function CacheTimeLimit:reset()
    -- 限时赏金
    self.mLimitthebountyInfo = nil 
end

-- 获取限时赏金信息
function CacheTimeLimit:getTimeLimitInfo()
    return self.mLimitthebountyInfo
end

-- 获取当前触发等级的限时赏金配置数据
--[[
-- 返回值为 LimitthebountyModel 配置表中的条目, 如果没有找到对应数据，则返回nil
]]
function CacheTimeLimit:getConfigItem()
    -- 玩家属性信息
    local playerInfo = PlayerAttrObj:getPlayerInfo()
    
    -- 没有限时赏金
    if not playerInfo.TriggerLv or playerInfo.TriggerLv == 0  then
        return 
    end

    for _, item in pairs(LimitthebountyModel.items) do
        if item.triggerLV == playerInfo.TriggerLv then
            return item
        end
    end
end

-- 获取限时赏金的状态
--[[
-- 返回值，参考 Enums.lua文件的Enums.TimeLimitStatus 定义
]]
function CacheTimeLimit:getRewardStatus()
    -- 玩家属性信息
    local playerInfo = PlayerAttrObj:getPlayerInfo()
    if not playerInfo.TriggerLv or playerInfo.TriggerLv == 0 or playerInfo.TriggerLv > playerInfo.Lv or 
        playerInfo.IsTriggerReceived and playerInfo.IsTriggerReceived ~= 0 or 
        RedDotInfoObj:isValid(ModuleSub.eTimeLimitTheBounty) == false then
        -- 没有限时赏金

        return Enums.TimeLimitStatus.eNoneInfo
    end

    if not self.mLimitthebountyInfo or self.mLimitthebountyInfo.TriggerLv ~= playerInfo.TriggerLv then  
        -- 需要获取服务器数据
        return Enums.TimeLimitStatus.eGetSvrData 
    end

    return Enums.TimeLimitStatus.eHaveInfo  -- 有限时赏金信息
end

-- =================== 在线奖励服务器请求相关接口 ===================

-- 玩家限时赏金信息的服务器数据请求
--[[
-- 参数
	callback: 获取到信息后的回调 callback(response)
]]
function CacheTimeLimit:requestGetInfo(callback)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Limitthebounty",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status == 0 then 
                self.mLimitthebountyInfo = response.Value or {}
                -- 通知显示赏金数据改变
                Notification:postNotification(EventsName.eRedDotPrefix .. tostring(ModuleSub.eTimeLimitTheBounty))
            elseif response and response.Status == -8305 then  -- 奖励过期, 手动设置小红点的状态
                RedDotInfoObj:setSocketRedDotInfo({[tostring(ModuleSub.eTimeLimitTheBounty)] = {Default=false}})
            end

            if callback then
            	callback(response)
            end
        end,
    })
end

-- 玩家领取奖励的服务器数据请求
--[[
-- 参数
	callback: 获取到信息后的回调 callback(response)
]]
function CacheTimeLimit:requestReceivedReward(callback)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Limitthebounty",
        methodName = "ReceivedReward",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status == 0 then 
                -- 通知显示赏金数据改变
                Notification:postNotification(EventsName.eRedDotPrefix .. tostring(ModuleSub.eTimeLimitTheBounty))
            end

            if callback then
            	callback(response)
            end
        end,
    })
end

return CacheTimeLimit