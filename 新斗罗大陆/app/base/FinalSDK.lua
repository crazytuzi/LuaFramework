local json = require("framework.json")


PLATFORM = {
	['NORMAL'] = 'normal', --归纳的方法
    ['YUEWEN'] = 'ywmb',
    ['HUIXUAN'] = 'hx',
}

CUR_PLATFORM = QDeliveryWrapper:getDeliveryName()
print("deliveryName==",CUR_PLATFORM)

FinalSDK = {}
local logins = {}
local logouts = {}
local initializes = {}
local pays = {}
local sendGameEventForJsons = {}
local openGameCenter = {}
local realNameResults = {}

FinalSDK.isDeliveryIntegrated = function()
    return CUR_PLATFORM ~= "Default" and CUR_PLATFORM ~= "";
end

FinalSDK.isDeliverySDKInitialzed = function()
    if FinalSDK.isDeliveryIntegrated() then
        return QDeliveryWrapper:isSDKInitialzied()
    else
        return false
    end
end

FinalSDK.getDeliveryName = function()
    return CUR_PLATFORM
end

FinalSDK.getAccoundID = function(default)
    return QDeliveryWrapper:getUserId() or default
end

FinalSDK.getSessionId = function()
    return QDeliveryWrapper:getSessionId()
end

FinalSDK.getDeviceUUID = function()
    return QDeliveryWrapper:getDeviceUUID() or ""
end

FinalSDK.getChannelID = function()
    return QDeliveryWrapper:getChannelID() or 0
end

FinalSDK.getSubChannelID = function()
    return QDeliveryWrapper:getSubChannelID() or 0
end

FinalSDK.isHXShenhe = function()
    -- if DEBUG_EXTEND_GAMEOPID and FinalSDK.getChannelID() == "27" then
    --     return true
    -- else
    return false
    -- end
end

FinalSDK.isFromGameCenter = function()
    if QDeliveryWrapper.isFromGameCenter then
        if FinalSDK.getChannelID() == "7" or FinalSDK.getChannelID() == "8" then
            return QDeliveryWrapper:isFromGameCenter()
        else
            return false
        end
    else
        return false
    end
end

--得到实名认证结果
FinalSDK.getRealNameResult = function()
    if QDeliveryWrapper.isRealName then
        return QDeliveryWrapper:isRealName()
    end
end

-- 查看app是否存在 1 微信   2 微博   3 QQ
FinalSDK.checkAppExist = function(app)
    if QDeliveryWrapper.checkAppExist then
        return QDeliveryWrapper:checkAppExist(app)
    end
end

--分享图片
FinalSDK.shareImage = function(shareType,path,cb) -- SHARE_IMAGE_TYPE
    if QDeliveryWrapper.shareImage then
        QDeliveryWrapper:shareImage(shareType,path,cb)
    end
end

--是否显示分享安按钮
FinalSDK.showShare = function()
    if FinalSDK.getChannelID() == "40" and device.platform == "android" then
        return true
    elseif FinalSDK.getChannelID() == "101" and device.platform == "ios" then
        return true
    else
        return false
    end
end

FinalSDK.showLogo = function()
    if FinalSDK.getChannelID() == "28" or FinalSDK.getChannelID() == "59" then
        return false
    else
        return true
    end
end

FinalSDK.showLoginTip = function()
    if FinalSDK.getChannelID() == "28" or FinalSDK.getChannelID() == "59" then
        return false
    else
        return true
    end
end

FinalSDK.isHasLogoutBtn = function()
    if FinalSDK.getChannelID() == "4" or FinalSDK.getChannelID() == "6" or FinalSDK.getChannelID() == "7" or FinalSDK.getChannelID() == "8" 
            or FinalSDK.getChannelID() == "9" or FinalSDK.getChannelID() == "11" or FinalSDK.getChannelID() == "13" or FinalSDK.getChannelID() == "21"
            or FinalSDK.getChannelID() == "22" or FinalSDK.getChannelID() == "24" or FinalSDK.getChannelID() == "26" or FinalSDK.getChannelID() == "29" 
            or FinalSDK.getChannelID() == "41" then
        return false
    else
        return true
    end
end

FinalSDK.isYYB = function()
    if FinalSDK.getChannelID() == "5" then
        return true
    end
    return false
end

-- 判断是否是Android小包
FinalSDK.isAndroidLetter = function ()
    if CHANNEL_RES and CHANNEL_RES["gameOpId"] and CHANNEL_RES["gameOpId"] == "3001" then
        if FinalSDK.getChannelID() ~= "101" and device.platform == "android" then
            return true
        end
    end
    return false
end

FinalSDK.isHXIOS = function()
    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "whjx_239" then
        return true
    end

    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "dljxol_238" then
        return true
    end

    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "dljxol_266" then
        return true
    end

    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "dljxol_267" then
        return true
    end

    return false
end

-- 判断是否是慧选渠道
FinalSDK.isHx = function()
    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "whjx_239" then
        return true
    end

    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "dljxol_238" then
        return true
    end

    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "lianyun_huixuan" then
        return true
    end

    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "dljxol_266" then
        return true
    end

    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "dljxol_267" then
        return true
    end

    return false
end

FinalSDK.needHideActivity = function()
    return false
end

FinalSDK.hasLogoutBtn = function ()
    if QDeliveryWrapper.hasLogoutBtn then
        return QDeliveryWrapper:hasLogoutBtn()
    end

    return false
end

FinalSDK.isLenovo = function ()
    if FinalSDK.getChannelID() == "11" then
        return true
    else
        return false
    end
end

FinalSDK.getDeviceIDFA = function()
    if QDeliveryWrapper.getDeviceIDFA then
        return QDeliveryWrapper:getDeviceIDFA()
    else
        return ""
    end
end

FinalSDK.getDeviceIMEID = function()
    if QDeliveryWrapper.getDeviceIMEID then
        return QDeliveryWrapper:getDeviceIMEID()
    else
        return ""
    end
end



-- print("QDeliveryWrapper.onEventWithGameDataForJson===",QDeliveryWrapper:isHideLogout())

function FinalSDK:login(cb)
	print("login ", CUR_PLATFORM, logins[CUR_PLATFORM])
    if FinalSDK.isDeliverySDKInitialzed() then
    	logins[CUR_PLATFORM](cb)
    else
        if cb then
            cb()
        end
    end
end

function FinalSDK:logout(cb)
	print("logout ", CUR_PLATFORM, logouts[CUR_PLATFORM])
    if FinalSDK.isDeliverySDKInitialzed() then
    	logouts[CUR_PLATFORM](cb)
    else
        if cb then
            cb()
        end
    end
end

--前往实名认证
function FinalSDK:gotoRealName(cb) 
    if FinalSDK.isDeliverySDKInitialzed() then
        realNameResults[CUR_PLATFORM](cb)
    end
end

function FinalSDK:initialize(cb)
	print("initialize ", CUR_PLATFORM, initializes[CUR_PLATFORM])
	initializes[CUR_PLATFORM](cb)
end

-- tokenNum用于统计事件中统计钻石消耗
function FinalSDK:sendGameEventForJson(eventKey, tokenNum)
	print("sendGameEventForJson ", CUR_PLATFORM, sendGameEventForJsons[CUR_PLATFORM])
    if FinalSDK.isDeliverySDKInitialzed() then
    	sendGameEventForJsons[CUR_PLATFORM](eventKey, tokenNum)
    end
end

function FinalSDK:pay(price,type,productId)
    print("pay ", CUR_PLATFORM, pays[CUR_PLATFORM])
    if FinalSDK.isDeliverySDKInitialzed() then
        pays[CUR_PLATFORM](price,type,productId)
    end
end

function FinalSDK:openGameCenter()
    if FinalSDK.isDeliverySDKInitialzed() and (FinalSDK.getChannelID() == "7" or FinalSDK.getChannelID() == "8") then
        openGameCenter[CUR_PLATFORM]()
    end
end

openGameCenter[PLATFORM.NORMAL] = function ()
    if QDeliveryWrapper.openGameCenter then
        QDeliveryWrapper:openGameCenter()
    end
end

realNameResults[PLATFORM.NORMAL] = function (cb)
    if QDeliveryWrapper.gotoRealName then
        QDeliveryWrapper:gotoRealName(function(errorCode)
            print("实名认证CallBack")
            if cb then
                cb(errorCode)
            end
        end)
    end
end

logins[PLATFORM.NORMAL] = function(cb)
	QDeliveryWrapper:login(function ()
        if cb then
            cb()
        end
    end)
end

logouts[PLATFORM.NORMAL] = function(cb)
	QDeliveryWrapper:logout(function ()
	    print("_logoutCallback")
	    if cb then
	        cb()
	    end
	end)
end

initializes[PLATFORM.NORMAL] = function(cb)
	QDeliveryWrapper:initialize(function ()
	    print("_initializesCallback")
	    if cb then
	        cb()
	    end
	end)
end

sendGameEventForJsons[PLATFORM.NORMAL] = function(eventKey, tokenNum)
	if nil == eventKey or eventKey == "" then return end
    print("EventData eventKey = ", eventKey)
    if QDeliveryWrapper.onEventWithGameDataForJson then
        local default = ""
        local serverInfo = remote.selectServerInfo
        local serverId = default
        local serverName = default
        if serverInfo then
            serverId = serverInfo.serverId
            serverName = serverInfo.name
        end
        local account = FinalSDK.getAccoundID()
        local userId = remote.user.userId or default
        local nickName = remote.user.nickname or default
        local level = remote.user.level or default
        level = tostring(level)
        local createAt = remote.user.userCreatedAt or (q.serverTime() * 1000)
        local tbl = {}
        tbl.userId = userId
        tbl.nickName = nickName
        tbl.level = level
        tbl.vip = app.vipUtil:VIPLevel()
        tbl.serverId = serverId
        tbl.serverName = serverName
        tbl.account = account
        --UC等渠道要求参数
        tbl.createAt = math.floor(createAt/1000) --必传，创角时间，必须为服务器时间，必须为10位数字，如1498043738
        --奇虎360渠道要求参数
        tbl.professionid = "0" -- 必传，职业ID，必须为数字，如果有则必传，如果没有，请说明原因
        tbl.profession = "" -- 必传，职业名称，如果有则必传，如果没有，请说明原因
        tbl.gender = "" -- 必传，性别，只能传"男"、"女"，如果有则必传，如果没有，请说明原因
        tbl.power = "" -- 必传，战力数值，必须为数字，如果有则必传，如果没有，请说明原因
        tbl.balance = "" -- 必传，帐号余额，必须为数字，如果有则必传，如果没有，请说明原因
        tbl.partyid = "" -- 必传，所属帮派帮派ID，必须为数字，如果有则必传，如果没有，请说明原因
        tbl.partyname = "" -- 必传，所属帮派名称，如果有则必传，如果没有，请说明原因
        tbl.partyroleid = "" -- 必传，帮派称号ID，必须为数字，帮主/会长必传1，其他可自定义，如果有则必传，如果没有，请说明原因
        tbl.partyrolename = "" -- 必传，帮派称号名称，如果有则必传，如果没有，请说明原因
        tbl.friendlist = "" -- 必传，好友关系，如果有则必传，如果没有，请说明原因
        tbl.channelUserid = ""
        --A站渠道要求参数
        tbl.isNewPlayer = "true" -- 必传，是否为第一次创角，只能传"true"、"false"。
        --乐赢渠道要求参数
        tbl.roleGold = remote.user.token
        tbl.roleMoney = remote.user.money
        if tokenNum then
            tbl.tokenNum = tokenNum -- 用于统计钻石消耗事件
        end
        print("tbl.vip=====",tbl.vip)
        local jsonStr = json.encode(tbl)
        QDeliveryWrapper:onEventWithGameDataForJson(eventKey,jsonStr)
    end
end

pays[PLATFORM.NORMAL] = function(price,type2,productId)
    local products = db:getRecharge()
    local productName = ""
    local rechargeId = ""
    local platform = (device.platform == "android" and 2 or 1)
    for _, product in ipairs(products) do
        if type2 == 4 then
            if productId == product["level_productid"] and platform == product["platform"] then
                productId = product["Product ID"]
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            elseif productId == product["Product ID2"] and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        elseif type2 == 6 then
            if productId == product["recharge_buy_productid"] and product.type == type2 and platform == product["platform"] then
                productId = product["Product ID"]
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            elseif productId == product["Product ID2"] and product.type == type2 and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        elseif type2 == 7 or type2 == 8 or type2 == 9 then
            if productId == product["recharge_buy_productid"] and product.type == type2 and platform == product["platform"] then
                productId = product["Product ID"]
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            elseif productId == product["Product ID2"] and product.type == type2 and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        else
            if productId == product["Product ID"] and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            elseif productId == product["Product ID2"] and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        end
    end
    local roleName = remote.user.nickname
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
    local roleVip = app.vipUtil:VIPLevel()
    local partyName = "宗门"
    local productDesc = "官方指定流通货币"
    local tbl = {}
    if FinalSDK.getChannelID() == "21" or FinalSDK.getChannelID() == "35" or FinalSDK.getChannelID() == "54" or FinalSDK.getChannelID() == "55" then
        roleName = remote.user.nickname or ""
    end
    cpOrderId = userId.."_"..serverId.."_"..(q.serverTime() * 1000).."_"..zone_id.."_"..rechargeId
    tbl.price = price
    tbl.productId = productId
    tbl.serverId = serverId
    tbl.userId = userId
    tbl.productName = productName
    tbl.productDesc = productDesc
    tbl.roleName = roleName
    tbl.userLevel = userLevel
    tbl.serverName = serverName
    tbl.roleBalance = roleBalance
    tbl.roleVip = roleVip
    tbl.partyName = partyName
    tbl.cpOrderId = cpOrderId
    local jsonStr = json.encode(tbl)
    QDeliveryWrapper:pay(function (ret, param)
        app:hideLoading()
        if ret == 1 then
            print(string.format("Pay %s id %s with orderId %s successfully", tostring(price), productId, tostring(orderId)))
        else
            local errorMsg = param
            print(string.format("Pay %s id %s with orderId %s failed. Code %s, Message %s", tostring(price), productId, tostring(orderId), tostring(ret), errorMsg))
        end
    end,function (ret, param)
        if ret ~= 1 then
            app:hideLoading()
            local errorMsg = param
            print(string.format("Pay %s id %s with orderId %s failed. Code %s, Message %s", tostring(price), productId, tostring(orderId), tostring(ret), errorMsg))
        end
    end,jsonStr)
end

logins[PLATFORM.HUIXUAN] = function(cb)
    QDeliveryWrapper:hxLogin(function ()
        if cb then
            cb()
        end
    end)
end

logouts[PLATFORM.HUIXUAN] = function(cb)
    QDeliveryWrapper:hxLogout(function ()
        print("_logoutCallback")
        if cb then
            cb()
        end
    end)
end

initializes[PLATFORM.HUIXUAN] = function(cb)
    QDeliveryWrapper:hxInitialize(function ()
        print("_initializesCallback")
        if cb then
            cb()
        end
    end)
end

sendGameEventForJsons[PLATFORM.HUIXUAN] = function(eventKey, tokenNum)
    if nil == eventKey or eventKey == "" then return end
    print("EventData eventKey = ", eventKey)
    if QDeliveryWrapper.onEventWithGameDataForJson then
        local default = ""
        local serverInfo = remote.selectServerInfo
        local serverId = default
        local serverName = default
        if serverInfo then
            serverId = serverInfo.serverId
            serverName = serverInfo.name
        end
        local account = FinalSDK.getAccoundID()
        local userId = remote.user.userId or default
        local nickName = remote.user.nickname or default
        local level = remote.user.level or default
        level = tostring(level)
        local createAt = remote.user.userCreatedAt or (q.serverTime() * 1000)
        local tbl = {}
        tbl.userId = userId
        tbl.nickName = nickName
        tbl.level = level
        tbl.vip = "1"
        tbl.serverId = serverId
        tbl.serverName = serverName
        tbl.account = account
        --UC等渠道要求参数
        tbl.createAt = math.floor(createAt/1000) --必传，创角时间，必须为服务器时间，必须为10位数字，如1498043738
        --奇虎360渠道要求参数
        tbl.professionid = "0" -- 必传，职业ID，必须为数字，如果有则必传，如果没有，请说明原因
        tbl.profession = "" -- 必传，职业名称，如果有则必传，如果没有，请说明原因
        tbl.gender = "" -- 必传，性别，只能传"男"、"女"，如果有则必传，如果没有，请说明原因
        tbl.power = "" -- 必传，战力数值，必须为数字，如果有则必传，如果没有，请说明原因
        tbl.balance = "" -- 必传，帐号余额，必须为数字，如果有则必传，如果没有，请说明原因
        tbl.partyid = "" -- 必传，所属帮派帮派ID，必须为数字，如果有则必传，如果没有，请说明原因
        tbl.partyname = "" -- 必传，所属帮派名称，如果有则必传，如果没有，请说明原因
        tbl.partyroleid = "" -- 必传，帮派称号ID，必须为数字，帮主/会长必传1，其他可自定义，如果有则必传，如果没有，请说明原因
        tbl.partyrolename = "" -- 必传，帮派称号名称，如果有则必传，如果没有，请说明原因
        tbl.friendlist = "" -- 必传，好友关系，如果有则必传，如果没有，请说明原因
        tbl.channelUserid = ""
        --A站渠道要求参数
        tbl.isNewPlayer = "true" -- 必传，是否为第一次创角，只能传"true"、"false"。
        --乐赢渠道要求参数
        tbl.roleGold = remote.user.token
        tbl.roleMoney = remote.user.money 
        local jsonStr = json.encode(tbl)
        QDeliveryWrapper:hxOnEventWithGameDataForJson(eventKey,jsonStr)
    end
end

pays[PLATFORM.HUIXUAN] = function(price,type2,productId)
    local products = db:getRecharge()
    local productName = ""
    local rechargeId = ""
    local platform = (device.platform == "android" and 2 or 1)
    for _, product in ipairs(products) do
        if type2 == 4 then
            if productId == product["level_productid"] and platform == product["platform"] then
                productId = product["Product ID"]
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            elseif productId == product["Product ID2"] and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        elseif type2 == 6  then
            if productId == product["recharge_buy_productid"] and product.type == type2 and platform == product["platform"] then
                productId = product["Product ID"]
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            elseif productId == product["Product ID2"] and product.type == type2 and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        elseif type2 == 7 or type2 == 8 or type2 == 9 then
            if productId == product["recharge_buy_productid"] and product.type == type2 and platform == product["platform"] then
                productId = product["Product ID"]
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            elseif productId == product["Product ID2"] and product.type == type2 and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        else
            if productId == product["Product ID"] and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            elseif productId == product["Product ID2"] and platform == product["platform"] then
                productName = product["Display Name"]
                rechargeId = product["ID"]
                break
            end
        end
    end
    local roleName = remote.user.nickname
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
    local roleVip = app.vipUtil:VIPLevel()
    local partyName = "宗门"
    local productDesc = "官方指定流通货币"
    local tbl = {}
    if FinalSDK.getChannelID() == "21" then
        roleName = remote.user.nickname or ""
    end
    cpOrderId = userId.."_"..serverId.."_"..(q.serverTime() * 1000).."_"..zone_id.."_"..rechargeId
    tbl.price = price
    tbl.productId = productId
    tbl.serverId = serverId
    tbl.userId = userId
    tbl.productName = productName
    tbl.productDesc = productDesc
    tbl.roleName = roleName
    tbl.userLevel = userLevel
    tbl.serverName = serverName
    tbl.roleBalance = roleBalance
    tbl.roleVip = roleVip
    tbl.partyName = partyName
    tbl.cpOrderId = cpOrderId
    local jsonStr = json.encode(tbl)
    QDeliveryWrapper:hxPay(function (ret, param)
        app:hideLoading()
        if ret == 1 then
            print(string.format("Pay %s id %s with orderId %s successfully", tostring(price), productId, tostring(orderId)))
        else
            local errorMsg = param
            print(string.format("Pay %s id %s with orderId %s failed. Code %s, Message %s", tostring(price), productId, tostring(orderId), tostring(ret), errorMsg))
        end
    end,function (ret, param)
        if ret ~= 1 then
            app:hideLoading()
            local errorMsg = param
            print(string.format("Pay %s id %s with orderId %s failed. Code %s, Message %s", tostring(price), productId, tostring(orderId), tostring(ret), errorMsg))
        end
    end,jsonStr)
end


initializes[PLATFORM.YUEWEN] = initializes[PLATFORM.NORMAL]
logins[PLATFORM.YUEWEN] = logins[PLATFORM.NORMAL]
logouts[PLATFORM.YUEWEN] = logouts[PLATFORM.NORMAL]
sendGameEventForJsons[PLATFORM.YUEWEN] = sendGameEventForJsons[PLATFORM.NORMAL]
pays[PLATFORM.YUEWEN] = pays[PLATFORM.NORMAL]
openGameCenter[PLATFORM.YUEWEN] = openGameCenter[PLATFORM.NORMAL]
realNameResults[PLATFORM.YUEWEN] = realNameResults[PLATFORM.NORMAL]

initializes[PLATFORM.HUIXUAN] = initializes[PLATFORM.HUIXUAN]
logins[PLATFORM.HUIXUAN] = logins[PLATFORM.HUIXUAN]
logouts[PLATFORM.HUIXUAN] = logouts[PLATFORM.HUIXUAN]
sendGameEventForJsons[PLATFORM.HUIXUAN] = sendGameEventForJsons[PLATFORM.HUIXUAN]
pays[PLATFORM.HUIXUAN] = pays[PLATFORM.HUIXUAN]
openGameCenter[PLATFORM.YUEWEN] = openGameCenter[PLATFORM.NORMAL]
realNameResults[PLATFORM.YUEWEN] = realNameResults[PLATFORM.NORMAL]

return FinalSDK