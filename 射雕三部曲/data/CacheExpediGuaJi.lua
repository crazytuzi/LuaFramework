--[[
文件名:CacheExpediGuaJi.lua
描述：守卫光明顶挂机数据抽象类型
创建人：chenzhogn
创建时间：2018.01.08
--]]

-- 挂机数据说明
--[[
    服务器返回的挂机的数据格式为：
    {
         NodeInfo:
        {
            NodeModelId：节点Id
            IsDrawFirstReward：是否领取首通奖励,
            BuffId:buffID
        },
        TeamInfo:
        {
            参考其他接口TeamInfo信息
        }
        GuajiInfo:
        {
            IsGuaji：是否是在挂机
            EndTime：预计时间,
            Num:已经完成次数
            RewardList:按次的奖励字符串
            TotalNum:需要的总次数
            RewardStatus:是否可以领取奖励
        },
    },
]]

local CacheExpediGuaJi = class("CacheExpediGuaJi", {})

--[[
]]
function CacheExpediGuaJi:ctor()
    -- 当前挂机信息
    self.mExpediGuaJiInfo = nil 
    self.IsGuaJi = false
end

-- 重置挂机信息
function CacheExpediGuaJi:reset()
    -- 当前挂机信息
    self.mExpediGuaJiInfo = nil 
    self.IsGuaJi = false
end

-- 获取领取下一次奖励的时间
function CacheExpediGuaJi:getNextCooledTime()
    if not self.mExpediGuaJiInfo then
        return 0
    end
    if not next(self.mExpediGuaJiInfo) then
        return 0
    end

    local currTime = Player:getCurrentTime()
    return self.mExpediGuaJiInfo.EndTime - currTime
end

-- 获取是否在挂机
function CacheExpediGuaJi:getIsGuaJi( )
    return self.IsGuaJi
end

function CacheExpediGuaJi:getGuaJiInfo( )
    return self.mExpediGuaJiInfo
end

function CacheExpediGuaJi:setIsGuaJi(isGuaJi)
    self.IsGuaJi = isGuaJi
end

function CacheExpediGuaJi:setGuaJiInfo(guaJiInfo)
    self.mExpediGuaJiInfo = guaJiInfo
end

-- =================== 挂机服务器请求相关接口 ===================

-- 获取玩家挂机信息的服务器数据请求
--[[
-- 参数
    callback: 获取到信息后的回调 callback(response)
]]
function CacheExpediGuaJi:requestExpediGuaJiInfo(callback)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ExpeditionNode",
        methodName = "AllChapterInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            
            self.mExpediGuaJiInfo = response.Value.GuajiInfo or {}
            Notification:postNotification(EventsName.eExpeditionGuaJi)
            if callback then
                callback(response)
            end
        end,
    })
end

return CacheExpediGuaJi