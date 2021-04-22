-- @qinyuanji
-- A class to wrap recharge operation
-- A successful recharge operation is not relied on the response of SDK pay callback, but on the notification from server
-- So when you are recharging, the screen will be locked and wait unitl the server notifies you the result.

local QPayUtil = class("QPayUtil")
local QLogFile = import(".QLogFile")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QVIPUtil = import("..utils.QVIPUtil")
local http = require 'socket.http'
local socket = require 'socket'

QPayUtil.HX_ORDER_URL = 'https://gt-game.xxx.com/ChargeHuixuan'
QPayUtil.HX_PAY_URL = 'http://open.douyouzhiyu.com/v2/douluo/choice'

QPayUtil.HJ_ORDER_URL = 'https://gt-game.xxx.com/ChargeMaja'
QPayUtil.HJ_PAY_URL = 'http://pay-center.fxdl.iiiuuuyyy.com/pay-center.jsp'

local payProgress = 0
function QPayUtil:_successCallback(success, data, currentRecharged, currentVIPLevel)
    data = data or {}
    data.rechargeTokenResponse = data.rechargeTokenResponse or {}
    QPrintTable(data)
    local rechargeInfo = data.rechargeTokenResponse.rechargeInfo or {}
    local cash = rechargeInfo.cash or 0
    local cashType = rechargeInfo.cashType or 0
    local itemId = rechargeInfo.itemId or nil
    local rechargeDataId = rechargeInfo.rechargeDataId or nil
    print(QVIPUtil:recharged(), currentRecharged)
    -- if itemId then
    --     remote.gradePackage:updateRechargeData(cash,itemId)
    -- end
    if QVIPUtil:recharged() > currentRecharged  then
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.VIP_RECHARGED, amount = cash,type = cashType})
        remote.task:checkAllTask() -- Monthly recharge has a daily task, check it when recharged
        remote.activity:updateRechargeData(cash,cashType,itemId ,rechargeDataId)
    end
    if QVIPUtil:VIPLevel() > currentVIPLevel then
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.VIP_LEVELUP})
    end

    if success then
        success(data)
    end
end
 
-- 线下充值 回调
function QPayUtil.successCallBackByOffine( data )
    -- body
    if data and data.rechargeTokenResponse and data.rechargeTokenResponse.rechargeInfo then
        remote.recharge = data.rechargeTokenResponse.rechargeInfo
        local rechargeInfo = data.rechargeTokenResponse.rechargeInfo or {}
        local cash = rechargeInfo.cash or 0
        local cashType = rechargeInfo.cashType or 0
        local itemId = rechargeInfo.itemId or nil
        local rechargeDataId = rechargeInfo.rechargeDataId or nil
        QLogFile:info(function ( ... )
            return string.format("successCallBackByOffine    ", cash)
        end)
        if itemId then
            remote.gradePackage:updateRechargeData(cash,itemId)
        end
        if cash > 0 then
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.VIP_RECHARGED, amount = cash,type = cashType})
            remote.task:checkAllTask() -- Monthly recharge has a daily task, check it when recharged
            remote.activity:updateRechargeData(cash,cashType,itemId,rechargeDataId)
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.VIP_LEVELUP})
        end
    end
end


-- 线下充值 
function QPayUtil.payOffine(rechargeCash , rechargeType,itemId)
    -- body
    local t = {}
    t.nickname = remote.user.nickname or ""
    t.user_id = remote.user.userId or ""
    
    if remote.selectServerInfo then
        t.zone_id = remote.selectServerInfo.zoneId
        t.server_name = remote.selectServerInfo.name
    else
        t.zone_id = ""
        t.server_name = ""
    end
    local tp = rechargeType
    local cash = rechargeCash
    t.item = tp == 1 and string.format("%d钻石", cash*10) or string.format("%d元月卡", cash)
    t.cash = cash

    local jsonStr = json.encode(t) or ""
    local buffer = crypto.encryptXXTEA(jsonStr, "WOW-PAY=VERIFY111") or ""
    buffer = crypto.encodeBase64(buffer) or ""

    if QUtility.openURL then
         QUtility:openURL(CHARGE_WEB_URL.."?payToken="..string.urlencode(buffer))
    end
end


-- 欢极线下支付
function QPayUtil:hjPayOffline( price, type, id ,itemId)
    local openId = FinalSDK.getSessionId()
    local gameId = 200657
    local serverId = remote.selectServerInfo.serverId
    local zone_id = remote.selectServerInfo.zoneId
    local channel = FinalSDK.getChannelID()

    local userId = remote.user.userId
    local productId = "n/a"
    local productName = ""
    local platform = (device.platform == "android" and 2 or 1)
    local products = db:getRecharge()
    local rechargeId = ""
    if id then
        productId = id
        if type==7 or type==6 then
            for _, product in ipairs(products) do
                if product.RMB == price and product.type == type then
                    rechargeId = product["ID"]
                    break
                end
            end
        end    
    else
        if type==4 and itemId then
            local level_re = db:getLevelRewardInfoById(itemId)
            productId = level_re.recharge_product_id
        else
            for _, product in ipairs(products) do
                if product.RMB == price and product.type == type then
                    productId = product["Product ID"]
                    break
                end
            end
        end   
    end
    for _, product in ipairs(products) do
        if type == 4 then
            if productId == product["level_productid"] and platform == product["platform"] then
                productId = product["Product ID"]
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        elseif type==7 or type==8 or type==9 then
            if productId == product["recharge_buy_productid"] and product.RMB == price and product.type == type and platform == product["platform"] then
                productId = product["Product ID"]
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        elseif type==6 then
            if productId == product["recharge_buy_productid"] and product.RMB == price and product.type == type and platform == product["platform"] then
                productId = product["Product ID"]
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        else
            if productId == product["Product ID"] and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        end
    end

    local cpOrderId = userId.."_"..serverId.."_"..math.floor(q.serverTime() * 1000).."_"..zone_id.."_"..rechargeId
    local amount = price*100
    math.randomseed(math.floor(q.serverTime()))
    local nonce = math.random(10000000, 100000000)
    local timestamp = math.floor(q.serverTime())
    local key = 'fc4b3771113ced2d29ad7538e5bc56c5'
    local params = string.format("amount=%s&channel=%s&cpOrderId=%s&gameId=%s&nonce=%s&openId=%s&productId=%s&productName=%s&serverId=%s&timestamp=%s&key=%s",
        amount, channel, cpOrderId, gameId, nonce, openId, productId, productName, serverId, timestamp, key)
    local sign = crypto.md5(params)
    sign = string.upper(sign)
    local productNameStr = string.urlencode(productName)
    local param = string.format("openId=%s&gameId=%s&serverId=%s&channel=%s&cpOrderId=%s&productId=%s&productName=%s&amount=%s&nonce=%s&timestamp=%s&sign=%s",
        openId, gameId, serverId, channel, cpOrderId, productId,productNameStr,amount,nonce,timestamp,sign)
    local orderResp = self:payofflinePost(QPayUtil.HJ_ORDER_URL,param)
    if orderResp and tonumber(orderResp.code) == 0 and orderResp.body and orderResp.body.orderId then
        local orderid = orderResp.body.orderId
        local t = {}
        t.order_id = orderid
        t.server_id = serverId
        t.game_area = zone_id
        t.server_name = remote.selectServerInfo.name
        t.role_id = userId
        t.role_name = remote.user.nickname
        t.item = productName
        t.cash = price
        t.op_id = channel
        t.account = remote.user.name
        local idfa = ""
        if QUtility.getIDFA then
            idfa = QUtility:getIDFA()
        end
        t.idfa = idfa
        local jsonStr = json.encode(t) or ""
        local buffer = crypto.encryptXXTEA(jsonStr, "DLDL-PAY-CENTER=VERIFY20200217") or ""
        buffer = crypto.encodeBase64(buffer) or ""
        -- print(QPayUtil.HJ_PAY_URL.."?payToken="..string.urlencode(buffer))
        device.openURL(QPayUtil.HJ_PAY_URL.."?payToken="..string.urlencode(buffer))
    end
end

function QPayUtil:payofflinePost(url, param)
    local respbody = {}
    local result, respcode, respheaders, respstatus = http.request {
        create=function ()
            local t = socket.tcp()
            t:settimeout(2, "t")
            return t
        end,
        method = "POST",
        url = url,
        source = ltn12.source.string(param),
        headers = {
            ["content-type"] = "application/x-www-form-urlencoded",
            ["content-length"] = tostring(#param),
            ["Accept-Encoding"] = "gzip",
        },
        sink = ltn12.sink.table(respbody),
        protocol = "tlsv1",
    }
    respbody = table.concat(respbody)
    respbody = json.decode(respbody)
    return respbody
end

function QPayUtil:hxCanPayOffline()
    if CHANNEL_RES and CHANNEL_RES["envName"] and (CHANNEL_RES["envName"] == "dljxol_266" or CHANNEL_RES["envName"] == "dljxol_267") then
        return true
    else
        return false
    end
end

function QPayUtil:pay(price, type, id,itemId)
    if not ENABLE_GAME_CHARGE then
        app.tip:floatTip("魂师大人，充值暂未开放")
        return
    end
    local platform = (device.platform == "android" and 2 or 1)
    local m_price = price
    local m_type = type
    local rechargeId = 0
    if ENABLE_CHARGE() then
        local orderId = nil
        -- local price = 1 -- uncomment if recharge 1rmb for testing
        -- For android, some platform has predefined product with productId, 
        -- So we specify them in extend4 in format id:price|id:price|id:price|
        local productId = "n/a"
        -- productId 
        local products = db:getRecharge()
        if id then
            productId = id
            if type==7 or type== 8 or type== 9 then
                for _, product in ipairs(products) do
                    if productId == product["recharge_buy_productid"] and product.RMB == price and product.type == type and platform == product["platform"] then
                        rechargeId = product["ID"]
                        break
                    end
                end
            elseif type==6 then
                for _, product in ipairs(products) do
                    if productId == product["recharge_buy_productid"] and product.RMB == price and product.type == type and platform == product["platform"] then
                        rechargeId = product["ID"]
                        break
                    end
                end
            end
        else
            if type==4 and itemId then
                local level_re = db:getLevelRewardInfoById(itemId)
                productId = level_re.recharge_product_id
            else
                for _, product in ipairs(products) do
                    if product.RMB == price and product.type == type then
                        productId = product["Product ID"]
                        break
                    end
                end
            end
        end
        --  果盘做特殊处理，取ID2
        if FinalSDK.getChannelID() == "21" and productId then
            for _, product in ipairs(products) do
                if type == 4 then
                    if productId == product["level_productid"] and platform == product["platform"] then
                        productId = product["Product ID2"]
                    end
                elseif type==7 or type== 8 or type== 9 then
                    if productId == product["recharge_buy_productid"] and product.RMB == price and product.type == type and platform == product["platform"] then
                        productId = product["Product ID2"]
                    end
                elseif type==6 then
                    if productId == product["recharge_buy_productid"] and product.RMB == price and product.type == type and platform == product["platform"] then
                        productId = product["Product ID2"]
                        productName = product["Display Name"]
                        rechargeId = product["ID"]
                        break
                    end
                else
                    if productId == product["Product ID"]then
                        productId = product["Product ID2"]
                        break
                    end
                end
            end
        end
        print("productId====",productId)
        print("rechargeId ===="..rechargeId)
        print("type====",type)
        if FinalSDK.isDeliverySDKInitialzed() and (device.platform == "android" or device.platform == "ios") then
            print("type====",type)
            FinalSDK:pay(price,type,productId)
        else
            local currentRecharged = QVIPUtil:recharged()
            local currentVIPLevel = QVIPUtil:VIPLevel()
            app:getClient():recharge(price, type, itemId,rechargeId,function (data)
                payProgress = 1
                scheduler.performWithDelayGlobal(function ( ... )
                    app.tip:floatTip("充值成功")
                    QPayUtil:_successCallback(success, data, currentRecharged, currentVIPLevel)
                end, 1)
            end) 
        end  
    end
end

-- function QPayUtil:patForYuewenAndroid(price,type, id)   
--     -- local orderTitle = "支付"
--     -- local extra = string.format("%s|%s", tostring(type), tostring(price))
-- end

-- function QPayUtil:payForIos(productId,price)
--     local gssid = remote.selectServerInfo.serverId
--     local userId = remote.user.userId
--     QDeliveryWrapper:ywCreatOrder(productId,gssid,userId,price)
-- end

function QPayUtil:payForAndroid(productId,price,type)
    local amount = price
    local productName = type == 1 and string.format("%d钻石", price*10) or string.format("%d元月卡", price)
    local roleName = remote.user.name
    local userId = remote.user.userId 
    local userLevel = remote.user.level
    local extend = "beifen" --备份字段
    local cpOrderId = ""
    local productCount = "1"
    local serverId = remote.selectServerInfo.serverId
    local zone_id = remote.selectServerInfo.zoneId
    local serverName = remote.selectServerInfo.name
    local rate = "10"
    local gameMoneyName = "钻石"
    -- local balance = remote.user.token--虚拟币余额
    local  roleBalance = remote.user.token
    -- remote.user.vip
    local roleVip = 1
    local partyName = "宗门"
    local productDesc = "官方指定流通货币"
    local priceComb = price.."|"..productName.."|"..productDesc.."|"..roleName.."|"..userLevel.."|"..serverName.."|"..roleBalance.."|"..roleVip.."|"..partyName
    print("priceComb = "..priceComb)
    QDeliveryWrapper:ywCreatOrder(productId,serverId,userId,priceComb)
end

return {pay = QPayUtil.pay, hxCanPayOffline = QPayUtil.QPayUtil, successCallBackByOffine = QPayUtil.successCallBackByOffine, hjPayOffline = QPayUtil.hjPayOffline, payofflinePost = QPayUtil.payofflinePost}
