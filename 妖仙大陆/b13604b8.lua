local ServerTime = require "Zeus.Logic.ServerTime"

local Model = {}


function Model.requestFeeItem(cb)
    Pomelo.PrepaidHandler.prepaidListRequest(function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(data.s2c_items)
    end)
end

function Model.requestPayAwards(cb)
    Pomelo.PrepaidHandler.prepaidAwardRequest(function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(data.s2c_items, data.s2c_isGet == 1)
    end)
end

function Model.requestPayOrder(dataStr, cb)
    Pomelo.PrepaidHandler.prepaidSDKRequest(dataStr, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(data.s2c_data)
    end)
end

function Model.prepaidOrderIdRequest(productId,type, cb)
    local channelId = SDKWrapper.Instance:GetChannel()
    local deviceId = SDKWrapper.Instance.udid
    local osType = PublicConst.OSType
    Pomelo.PrepaidHandler.prepaidOrderIdRequest(productId,type,channelId, deviceId, osType, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        
        cb(data.s2c_orderId,data.app_notify_url or "")
    end)
end

function Model.prepaidFirstAwardRequest(cb)
    Pomelo.PrepaidHandler.prepaidFirstAwardRequest(function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb(data)
    end)
end

function Model.initial()
    
end

function Model.InitNetWork()
end


return Model
