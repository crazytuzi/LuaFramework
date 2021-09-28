--[[
 --
 -- add by vicky
 -- 2014.10.22 
 --
 --]]

 local INQUIRE_URL = "/platform/pay/queryOrder?" 
 local ORDER_URL = "/platform/pay/generateOrder?" 
 local TDREQUEST_URL = "/platform/pay/tdRequestLog?"

 local loadingLayer = require("utility.LoadingLayer")

 local IapRequest = {} 

 -- 查询订单 
 function IapRequest.sendInquire(param) 
 	local orderId = param.orderId 
    local callback = param.callback 

 	local url = CSDKShell:getIapUrlByChannelId() .. INQUIRE_URL .. "token=" .. tostring(orderId) 
 	dump(url) 

    local iapNetwork = require("network.IapHttpNetwork").new()
    iapNetwork:sendRequest({
        url = url, 
        callback = function(data)
            -- loadingLayer.hide()
            if callback ~= nil then 
                callback(data) 
            end 
        end,
        errorCallback = function()
            loadingLayer.hide(function()
                show_tip_label("请重试,网络异常... ... ")
            end)
        end
        })

    -- loadingLayer.start()
 end


 -- 生成订单
 function IapRequest.getOrderID(param)
    local callback = param.callback 
    local payitemId = param.payitemId 
    local serverId = param.serverId 
    local acc = param.acc or game.player.m_uid 
    local pf = param.pf or CSDKShell.getChannelID()

    local accStr = "acc=" .. tostring(acc) 
    local serverIdStr = "&serverId=" .. tostring(serverId) 
    local payitemStr = "&payitem=" .. tostring(payitemId) 
    local pfStr = "&pf=" .. tostring(pf) 
    local lacStr = "&lac=" .. string.urlencode(game.player.m_loginName) 

    local title = "&title=" .. string.urlencode(param.title)
    local desc = "&desc=" .. string.urlencode(param.desc) 
    local money = "&money=" .. string.urlencode(param.money)

    local url = CSDKShell:getIapUrlByChannelId() .. ORDER_URL .. accStr .. serverIdStr .. payitemStr .. pfStr .. lacStr .. title .. desc .. money
    dump(url)

    local iapNetwork = require("network.IapHttpNetwork").new()
    iapNetwork:sendRequest({
        url = url, 
        callback = function(data)
            loadingLayer.hide()
            if callback ~= nil then 
                callback(data) 
            end 
        end, 
        errorCallback = function()
            loadingLayer.hide(function()
                show_tip_label("请重试,网络异常... ... ")
            end)
        end
        })

    loadingLayer.start() 
 end 


 -- talkingdata 充值请求数据  
 function IapRequest.tdRequestLog(param) 
    local callback = param.callback 
    local acc = param.acc or game.player.m_uid 
    local accStr = "accountId=" .. tostring(acc) 
    local gameSeverStr = "&gameServer=" .. tostring(game.player.m_serverID) 
    local orderIdStr = "&orderId=" .. tostring(param.orderId) 
    local iapIdStr = "&iapId=" .. string.urlencode(param.productName) 
    local currencyAmountStr = "&currencyAmount=" .. tostring(param.price) 
    local currencyTypeStr = "&currencyType=" .. tostring(param.currencyType) 
    local virtualCurrencyAmountStr = "&virtualCurrencyAmount=" .. tostring(param.price) 
    local paymentTypeStr = "&paymentType=" .. tostring(param.paymentType) 

    -- TODO
    -- local tkID = SDKTkData.getTkID()
    -- local tkIDStr = "&tkID=" .. tkID

    local iapurl = CSDKShell:getIapUrlByChannelId()

    local url = iapurl .. TDREQUEST_URL .. accStr .. gameSeverStr .. orderIdStr .. iapIdStr .. currencyAmountStr .. currencyTypeStr .. virtualCurrencyAmountStr .. paymentTypeStr

    dump(url) 

    local iapNetwork = require("network.IapHttpNetwork").new()
    iapNetwork:sendRequest({
        url = url, 
        callback = function(data)
            dump(data) 
            if callback ~= nil then 
                callback(data) 
            end 
        end
        }) 
 end



 return IapRequest 

