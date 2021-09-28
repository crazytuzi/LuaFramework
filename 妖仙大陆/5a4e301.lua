local ServerTime = require "Zeus.Logic.ServerTime"
local Util = require "Zeus.Logic.Util"
local VipUtil = require "Zeus.UI.Vip.VipUtil"
local CACHE_TIME = 15

local Model = {}
local cacheMap = {}


function Model.clearCache()
    cacheMap = {}
end

function Model.requestVipInfo(cb)
    Pomelo.VipHandler.vipInfoRequest(function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(data)
    end)
end

function Model.requestDailyReward(vipType, cb)
    Pomelo.VipHandler.getEveryDayGiftRequest(vipType, function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb()
    end)
end

function Model.buyDailyGift(vipLv, cb)
    Pomelo.VipHandler.buyEveryDayGiftRequest(vipLv, function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb()
    end)
end

function Model.buyVipCard(itypeId, itemId, isUse, cb)
    Pomelo.VipHandler.buyVipCardRequest(itypeId, itemId, (isUse and 1) or 2, function (ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(tonumber(data.s2c_vipTime) / 1000, data.s2c_getData, data.s2c_buyData)
    end)
end

function Model.initial()
    VipUtil.setUtil(Util)
end

function Model.fin(relogin)

end

function Model.InitNetWork()
    
end


return Model
