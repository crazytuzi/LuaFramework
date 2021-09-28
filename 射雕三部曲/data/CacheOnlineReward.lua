--[[
文件名:CacheOnlineReward.lua
描述：在线奖励数据抽象类型
创建人：liaoyuangang
创建时间：2016.07.02
--]]

-- 在线奖励数据说明
--[[
    服务器返回的在线奖励的数据格式为：
    {
        OnlineRewardInfo:
        {
           	NeedReachedNum:奖励所需达到的分钟数
           	CooledTime:冷却后的时间(可领取奖励的时间)
           	ResourceList:
            [
                {
                    ResourceTypeSub:资源类型
                    ModelId:模型Id	
                    Num:数量	
                }
                ......
            ]
        }
    },
]]

local CacheOnlineReward = class("CacheOnlineReward", {})

--[[
]]
function CacheOnlineReward:ctor()
	-- 当前在线奖励信息
    self.mOnlineRewardInfo = nil 
end

-- 重置在线奖励信息
function CacheOnlineReward:reset()
    -- 当前在线奖励信息
    self.mOnlineRewardInfo = nil 
end

-- 获取在线奖励的状态
--[[
-- 返回值，参考 Enums.lua文件的Enums.OnlineRewardStatus 定义
]]
function CacheOnlineReward:getRewardStatus()
	if not self.mOnlineRewardInfo then
		return Enums.OnlineRewardStatus.eGetSvrData  -- 需要获取服务器数据
	else
		if next(self.mOnlineRewardInfo) then
			return Enums.OnlineRewardStatus.eHaveInfo -- 已有服务器数据，并且有在线奖励
		else
			return Enums.OnlineRewardStatus.eFinish -- 已有服务器数据，在线奖励已结束
		end
	end
end

-- 获取领取下一次奖励的时间
function CacheOnlineReward:getNextCooledTime()
	if not self.mOnlineRewardInfo then
		return 0
	end
	if not next(self.mOnlineRewardInfo) then
		return 0
	end

	local currTime = Player:getCurrentTime()
	return self.mOnlineRewardInfo.CooledTime - currTime
end

-- 获取当前在线奖励的预览信息
--[[
-- 返回值
	预览物品列表，如果为nil表示没有奖励预览
]]
function CacheOnlineReward:getResourceList()
	return self.mOnlineRewardInfo and self.mOnlineRewardInfo.ResourceList
end

-- 判断奖励是否可以领取
function CacheOnlineReward:allowReward()
	if not self.mOnlineRewardInfo then
		return false
	end
	if not next(self.mOnlineRewardInfo) then
		return false
	end
	local currTime = Player:getCurrentTime()
	return currTime >= self.mOnlineRewardInfo.CooledTime
end

-- =================== 在线奖励服务器请求相关接口 ===================

-- 获取玩家在线奖励信息的服务器数据请求
--[[
-- 参数
	callback: 获取到信息后的回调 callback(response)
]]
function CacheOnlineReward:requestOnlineRewardInfo(callback)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "OnlineReward",
        methodName = "OnlineRewardInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status == 0 then 
                self.mOnlineRewardInfo = response.Value.OnlineRewardInfo or {}
                Notification:postNotification(EventsName.eRedDotPrefix .. tostring(ModuleSub.eOnlineReward))
            end

            if callback then
            	callback(response)
            end
        end,
    })
end

-- 领取玩家在线奖励的服务器数据请求
--[[
-- 参数
	callback: 获取到信息后的回调 callback(response)
]]
function CacheOnlineReward:requestDrawOnlineReward(callback)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "OnlineReward",
        methodName = "DrawOnlineReward",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status == 0 then 
                self.mOnlineRewardInfo = response.Value.OnlineRewardInfo or {}
                Notification:postNotification(EventsName.eRedDotPrefix .. tostring(ModuleSub.eOnlineReward))
            end

            if callback then
            	callback(response)
            end
        end,
    })
end

return CacheOnlineReward