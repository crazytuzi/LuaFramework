require"Lang"
require "net"
require "cocos.init"

SDK = { }

SDK.cbPay = nil
SDK.cbLogin = nil
SDK.cbLogout = nil

SDK.notifyUri = nil
SDK.sdkUserId = nil

SDK.firstCreate = 0

local CLASS_NAME = "org/cocos2dx/lua/SDK"

function SDK.init(string)
    if not string then string = "" end
    if device.platform == "windows" then

    elseif device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoInit", { string })
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoInit", { })
        SDK.notifyTDActivate()
    end
end

function SDK.saveId(string)
    SDK.sdkUserId = string
    if device.platform == "windows" then

    elseif device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "saveId", { string })
    end
end

function SDK.getUserId()
    return SDK.sdkUserId
end

-- For kupai
function SDK.saveTokenAndId(string)
    if not string then string = "" end
    if device.platform == "windows" then

    elseif device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "saveTokenAndId", { string })
    end
end

function SDK.saveNotifyUri(string)
    SDK.notifyUri = string
    if device.platform == "windows" then

    elseif device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "saveNotifyUri", { string })
    elseif device.platform == "ios" then
    end
end

function SDK.getNotifyUri()
    return SDK.notifyUri
end

function SDK.free(string)
    if not string then string = "" end
    if device.platform == "windows" then

    elseif device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoFree", { string })
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoFree", { })
    end
end

function SDK.getChannel()
    if device.platform == "windows" then
    elseif device.platform == "android" then
        local b, ret = require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkGetChannel", { }, "()Ljava/lang/String;")
        if b then
            return ret
        end
    elseif device.platform == "ios" then
        local b, ret = require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkGetChannel", { })
        if b then
            return ret
        end
    end
    return "dev"
end
--腾讯特殊处理订单
function SDK.doSendOrderId( string )
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sendOrderId", string)
    end
end

function SDK.getDeviceInfo()
    if device.platform == "android" then
        local b, ret = require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkGetDeviceInfo", { }, "()Ljava/lang/String;")
        if b then
            local _deviceInfo = { }
            local _temp = utils.stringSplit(ret, "#")
            for key, obj in pairs(_temp) do
                local _data = utils.stringSplit(obj, "=")
                _deviceInfo[_data[1]] =(_data[2] and _data[2] or "")
            end
            return _deviceInfo
        end
    elseif device.platform == "ios" then
        local b, ret = require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkGetDeviceInfo", { })
cclog( "packageName1:" .. ret.packageName )
        if b then
            return ret
        end
    end
    return { errorCode = 1, }
end

function SDK.getActivationCodeUrl()
    if device.platform == "windows" then
    elseif device.platform == "android" then
        local b, ret = require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkGetActivationCodeUrl", { }, "()Ljava/lang/String;")
        if b then
            return ret
        end
    end
    return "http://www.huayigame.com/"
end

function SDK.doPay(table, callback)
    if not table then table = { } end
    SDK.cbPay = callback
    if device.platform == "windows" then
        SDK.onPay("")
    elseif device.platform == "android" then
        if SDK.getChannel() == "qq" then
            local function savePay1( str )
                local payStr = cc.UserDefault:getInstance():getStringForKey("qqPayData1")
                if payStr ~= "" then
                    payStr = payStr .. "^" .. str
                else
                    payStr = str
                end
                cc.JNIUtils:logAndroid( "save do pay :" .. payStr )
                cc.UserDefault:getInstance():setStringForKey("qqPayData1", payStr)
            end
            savePay1( table[3].."|"..table[2].."|".. dp.getUserData().serverId )
        end
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoPay", table)
       
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoPay", table)
    end
end

function SDK.doUserTD(table)
    if not table then table = { } end
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoUserTD", table)
    elseif device.platform == "ios" then
        local t = { accountId = table[1] .. "_" .. SDK.getChannel() .. "_" .. table[2], accountName = table[3] or "" }
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoUserTD", t)
    end
end

function SDK.doPayTD(table)
    if not table then table = { } end
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoPayTD", table)
    elseif device.platform == "ios" then
        local t = { productName = table[1] or "", orderId = table[2] or "", price = table[3] or "" }
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoPayTD", t)
    end
end

function SDK.doPaySuccessTD(orderId)
    orderId = orderId and orderId or ""
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoPaySuccessTD", { orderId })
    elseif device.platform == "ios" then
        local t = { orderId = orderId }
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoPaySuccessTD", t)
    end
end

function SDK.onPay(string)
    if not string then string = "" end
    if SDK.cbPay then
        SDK.cbPay(string)
    elseif device.platform == "ios" then
        UIGiftRecharge.onPay(string)
    end
    if SDK.getChannel() == "qq" then
        local t1 = utils.stringSplit( string , "&" )
                local t2 = utils.stringSplit( t1[7] , "=" )
                local t3 = utils.stringSplit( t1[5] , "=" )
                local t1 = utils.stringSplit( t1[1] , "=" )
                if tonumber( t1[ 2 ] ) == 2 then
                    UIGiftRecharge.checkPay()
                    return
                end
        local function savePay( str )
            local payStr = cc.UserDefault:getInstance():getStringForKey("qqPayData")
            if payStr ~= "" then
                payStr = payStr .. "^" .. str
            else
                payStr = str
            end
            cc.UserDefault:getInstance():setStringForKey("qqPayData", payStr)
        end
        savePay( string )
        
                local payStr1 = cc.UserDefault:getInstance():getStringForKey("qqPayData1")
                cc.JNIUtils:logAndroid( "save do pay111 :" .. payStr1 )

                if payStr1 ~= "" then
                    local newPay = { }
                    local pay = utils.stringSplit(payStr1, "%^")
                    for i = 1, #pay do
                        if pay[i] ~= t2[2].."|"..t3[2] .. "|" .. dp.getUserData().serverId then
                            table.insert(newPay, pay[i])
                        end
                    end                   
                    payStr1 = table.concat(newPay, "^", 1, #newPay)
                    cc.JNIUtils:logAndroid( "save do pay1112222 :" .. payStr1 .. " curStr:" .. t2[2].."|"..t3[2] .. "|" .. dp.getUserData().serverId )
                    cc.UserDefault:getInstance():setStringForKey("qqPayData1", payStr1)
                end
                cc.JNIUtils:logAndroid( "save do pay1112222 -------------------------:"..payStr1)
                
                http = nil
        http = cc.XMLHttpRequest:new()
        if http then
            http.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
            http:registerScriptHandler( function()
                cc.JNIUtils:logAndroid( "save do pay1114444111555 -------------------------:"..http.status)
                if http.status == 200 then
                    local payStr = cc.UserDefault:getInstance():getStringForKey("qqPayData")
                    cc.JNIUtils:logAndroid( "save do pay1114444111 -------------------------:"..payStr)
                    if payStr ~= "" then
                        local newPay = { }
                        local pay = utils.stringSplit(payStr, "%^")
                        for i = 1, #pay do
                            if pay[i] ~= string then
                                table.insert(newPay, pay[i])
                            end
                        end
                        payStr = table.concat(newPay, "^", 1, #newPay)
                        cc.UserDefault:getInstance():setStringForKey("qqPayData", payStr)
                        UIGiftRecharge.checkPay()
                    end
                    cc.JNIUtils:logAndroid( "save do pay1114444 -------------------------:"..payStr)
                elseif http.status == 0 then
                elseif netIsConnected() then
                    UIGiftRecharge.checkPay()
                end
            end )
            http:open("POST", string)
            http:send()
        end
    end
end

SDKOnPay = SDK.onPay

function SDK.doLogin(string, callback)
    if not string then string = "" end
    SDK.cbLogin = callback
    if device.platform == "windows" or SDK.getChannel() == "dev" then
        SDK.onLogin(string)
    elseif device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoLogin", { string })
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoLogin", { })
    end
end

function SDK.onLogin(string)
    if not string then string = "" end
    if SDK.cbLogin then
        SDK.cbLogin(string)
    end
end

SDKOnLogin = SDK.onLogin

function SDK.doLogout(string, callback)
    if not string then string = "" end
    SDK.cbLogout = callback
    if device.platform == "windows" then
        SDK.onLogout(string)
    elseif device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoLogout", { string })
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoLogout", { })
    end
end

function SDK.onLogout(string)
    if not string then string = "" end
    if SDK.cbLogout then
        SDK.cbLogout(string)
    end
end

SDKOnLogout = SDK.onLogout

function SDK.doSubmitExtendData(string)
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoSubmitExtendData", string)
    elseif device.platform == "ios" then
        if SDK.getDeviceInfo().packageName == "com.dpdl.20161009.zy" then
            -- cclog("zhangyue.." .. string[2] .. "  " .. string[3] .. "  " .. string[5] .. "  " .. string[6])
            require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoSubmitExtendData", {roleId = string[2] , roleName = string[3] , roleServerId = string[5] , roleServerName = string[6]})
        end

    end
end

function SDK.onSubmitExtendData(string)
end

SDKOnSubmitExtendData = SDK.onSubmitExtendData

function SDK.doChangeAccount(string)
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoChangeAccount", string)
    end
end

function SDK.onChangeAccount(string)
    dp.Logout()
end

SDKOnChangeAccount = SDK.onChangeAccount

-- For oppo 提交用户信息到sdk，包括用户所在服，用户名称，用户等级
function SDK.doSubmitUserInfo(string)
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoSubmitUserInfo", string)
    end
end

function SDK.doUserCenter(string)
    if not string then string = "" end
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoUserCenter", { string })
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoUserCenter", { })
    end
end
function SDK.onUserCenter(string)

end

SDKOnUserCenter = SDK.onUserCenter
function SDK.doUpgradeEvent(string)
    if not string then string = "" end
    if device.platform == "android" then
        if SDK.getChannel() =="360" then
            local role = dp.getUserData()
            local params = {"levelUp" , tostring(role.serverId) ,role.serverName , tostring(role.roleId), role.roleName ,"0" ,"无","无",tostring(role.roleLevel) ,tostring(utils.getFightValue()) , tostring(role.vipLevel) ,"0","元宝",tostring(net.InstPlayer.int["5"]),"0","无","0","无","无"}
            SDK.doSubmitExtendData(params)     
        end
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoUpgradeEvent", { string })
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoUpgradeEvent", { level = string })
    end
end

function SDK.doEnterLevel(string)
    if not string then string = "" end
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoEnterLevel", { string })
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoEnterLevel", { missionId = string })
    end
end

function SDK.doLevelFightResult(string)
    if not string then string = "" end
    if device.platform == "android" then
        require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoLevelFightResult", { string })
    elseif device.platform == "ios" then
        local strs = utils.stringSplit(string, "_")
        if (not strs) or #strs < 2 then return end
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "sdkDoEnterLevel", { missionId = strs[1], type = strs[2] })
    end
end

function SDK.onSubmitUserInfo(string)
end

SDKOnSubmitUserInfo = SDK.onSubmitUserInfo


-- td消耗统计
function SDK.tdDoOnPurchase(string)
    cclog("至尊.." .. string[1] .. "  " .. string[2] .. "  " .. string[3])
    if device.platform == "android" then
        if SDK.getChannel() == "qq" then
        else
            require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoOnPurchase", { string[1], string[2], string[3] }, "Ljava/lang/String;ID)V")
        end
    end
end

-- For IOS TalkingData Analytics begin
-- !!!所有接口请参考TalkingData.h

-- !!!禁止lua使用
function SDK.tdSessionStarted(appKey, channelId)
    -- string,[string]
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdSessionStarted", { appKey = appKey, channelId = channelId })
    end
end

function SDK.tdInitWithWatch(appKey)
    -- string
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdInitWithWatch", { appKey = appKey })
    end
end

function SDK.tdGetDeviceID()
    -- RETURN:string
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        local b, ret = require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdGetDeviceID", { })
        if b then
            return ret
        end
    end
    return "_nil_"
end

-- !!!禁止lua使用
function SDK.tdSetExceptionReportEnabled(enable)
    -- boolean
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdSetExceptionReportEnabled", { enable = enable })
    end
end

-- !!!禁止lua使用
function SDK.tdSetSignalReportEnabled(enable)
    -- boolean
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdSetSignalReportEnabled", { enable = enable })
    end
end

function SDK.tdSetLatitude(latitude, longitude)
    -- float经度,float纬度
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdSetLatitude", { latitude = latitude, longitude = longitude })
    end
end

function SDK.tdSetLogEnabled(enable)
    -- boolean
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdSetLogEnabled", { enable = enable })
    end
end

function SDK.tdTrackEvent(eventId, eventLabel, parameters)
    -- string[,string[,table]] --table = {key1="value1"[,keyN="valueN"]} --支持最多10个key=value
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        local table = { eventId = eventId, eventLabel = eventLabel }
        local index = 1
        if parameters and type(parameters) == "table" then
            for key, val in pairs(parameters) do
                table[tostring(index)] = key
                table[tostring(- index)] = val
                index = index + 1
                if index > 10 then
                    -- 最多支持10个key、value
                    break
                end
            end
        end
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdTrackEvent", table)
    end
end

function SDK.tdTrackPageBegin(pageName, pageType)
    -- string[,number] --number可选区间为[1,3]
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdTrackPageBegin", { pageName = pageName, pageType = pageType })
    end
end

function SDK.tdTrackPageEnd(pageName)
    -- string
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdTrackPageEnd", { pageName = pageName })
    end
end

function SDK.tdSetGlobalKV(key, value)
    -- string,string
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdSetGlobalKV", { key = key, value = value })
    end
end

function SDK.tdRemoveGlobalKV(key)
    -- string
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdRemoveGlobalKV", { key = key })
    end
end

-- For IOS TalkingData Analytics end

-- For TalkingDataAdTracking begin
-- !!!所有接口请参考TalkingDataAppCpa.h

function SDK.notifyTDActivate()
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
	    local di = SDK.getDeviceInfo()
        local appID = "bf6951c07ae240a48e329a9be762fe68" -- 旧的 3a3ba201cce94b5aa779fcbcda556df6 --新的 bf6951c07ae240a48e329a9be762fe68
        if di.packageName == "com.y2game.doupocangqiong"then 
            appID = "ceaf80f0dc334ff295ce56b3b243cca2"
        elseif di.packageName == "com.dpdl.20161009.zy"  then
            appID = "99132a20302945e5ab5cd586440c9fe2"
        end
        
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdOnActivate", { appID = appID, channelID = "AppStore" })
    end
end

function SDK.notifyTDRegister()
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdOnRegister", { accountID = "accountID" })
    end
end

function SDK.notifyTDLogin()
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdOnLogin", { accountID = "accountID" })
    end
end

function SDK.notifyTDCreateRole(params)
    if device.platform == "windows" then
    elseif device.platform == "android" then
        if SDK.getChannel() ~= "qq" then
            require("cocos.cocos2d.luaj").callStaticMethod(CLASS_NAME, "sdkDoADCreateRole", { tostring(params.roleName) })
        end
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdOnCreateRole", params)
    end
end

function SDK.notifyTDPay()
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdOnPay", { accountID = "1", orderID = "2", amount = 0, currencyType = "4", payType = "5" })
    end
end

function SDK.share( params ) --zhenyi
    if device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "shareWeiXin", { name  = tostring( params.name ), description = tostring(params.description) , url="http://dpcq.y2game.cn/" })
    end
end
function SDK.onShare( params )
   if device.platform == "ios" then
       UIShare.getResuilt()
   end
end
OnShare = SDK.onShare
function SDK.showShareInfo()
    UIManager.showToast(Lang.SDK1)
end
ShowShareInfo = SDK.showShareInfo

-- TD_EVENT_IDs
SDK_TD_EVENT_1 = 1	--
SDK_TD_EVENT_2 = 2	--
SDK_TD_EVENT_3 = 3	--
SDK_TD_EVENT_4 = 4	--
SDK_TD_EVENT_5 = 5	--
SDK_TD_EVENT_6 = 6	--
SDK_TD_EVENT_7 = 7	--
SDK_TD_EVENT_8 = 8	--
SDK_TD_EVENT_9 = 9	--
SDK_TD_EVENT_10 = 10	--

function SDK.notifyTDEvent()
    if device.platform == "windows" then
    elseif device.platform == "android" then
    elseif device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "tdOnCustEvent", { eventID = 1 })
    end
end

-- For TalkingDataAdTracking end


-- For YVSDK

function SDK.onYVCPLoginListern(result, msg, userid, thirdUserId, thirdUserName)
    cclog("SDK.onYVCPLoginListern(%d, '%s', %d, '%s', '%s')", result, msg, userid, thirdUserId, thirdUserName)
end

function SDK.onYVStopRecordListern(time, localPath, ext)
    cclog("SDK.onYVStopRecordListern(%d, '%s', '%s')", time, localPath, ext)
end

function SDK.onYVFinishPlayListern(result, describe, urlPath, ext)
    cclog("SDK.onYVFinishPlayListern(%d, '%s', '%s', '%s')", result, describe, urlPath, ext)
end

function SDK.onYVUpLoadFileListern(result, msg, fileid, fileurl, percent)
    cclog("SDK.onYVUpLoadFileListern(%d, '%s', '%s', '%s', %d)", result, msg, fileid, fileurl, percent)
end

function SDK.onYVDownLoadFileListern(localPath)
    cclog("SDK.onYVDownLoadFileListern('%s')", localPath)
end

--For ReYun

function SDK.reYunOnRegister( params )
    if device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "reYunOnRegister", { accountID = params.roleId })
    end
end

function SDK.reYunOnLogin( params )
    if device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "reYunOnLogin", { accountID = params.roleId })
    end
end

function SDK.reYunOnPay( params )
    if device.platform == "ios" then
        require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "reYunOnPay", { accountID = params.roleId , orderID = params.orderId , amount = params.amount , currencyType = "CNY", payType = Lang.SDK2 })
    end
end

--For zhangyue统计
function SDK.zhangYueOnPay(params)
    if device.platform == "ios" then
        if SDK.getDeviceInfo().packageName == "com.dpdl.20161009.zy" then
            require("cocos.cocos2d.luaoc").callStaticMethod("SDK", "zhangYueOnPay", { accountID = params.roleId , roleName = params.roleName ,orderID = params.orderId ,  relateOrderId = params.orderId  , amount = params.amount , actualCost = params.amount , productId = "" , productName = Lang.SDK3 , currencyType = "1", status = "1" , createTime = ""})
        end
    end
end

return SDK

