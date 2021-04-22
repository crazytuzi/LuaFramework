-- @Author: xurui
-- @Date:   2019-06-04 17:32:26
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-26 10:28:02
local QBaseModel = import("...models.QBaseModel")
local QBindingPhone = class("QBindingPhone", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local http = require 'socket.http'
local socket = require "socket"

QBindingPhone.EVENT_UPDATE_BINDINGPHONE = "EVENT_UPDATE_BINDINGPHONE"

QBindingPhone.URL = "https://gt-game.xxx.com/channel"
QBindingPhone.KEY = "5cc41de46a55caae02decb774828216e"

function QBindingPhone:ctor()
    QBindingPhone.super.ctor(self)

    self._countdownTime = 0  --发送验证码时间

end

function QBindingPhone:didappear()
	-- body
end

function QBindingPhone:disappear()
	-- body
end

function QBindingPhone:loginEnd(success)
	-- body
    if success then
        success()
    end
end

function QBindingPhone:checkOpenBindingPhone()
    if CHANNEL_RES and CHANNEL_RES["gameOpId"] and CHANNEL_RES["gameOpId"] == "3001" then
        if app.unlock:checkLock("UNLOCK_BINDING_PHONE") then
            return true
        end
        return false
    end

    return false
end

function QBindingPhone:checkCanGetAwards( ... )
    local phoneInfo = remote.user.userTelephoneInfo or {}
    
    if phoneInfo.phoneNum == nil or phoneInfo.phoneNum == "" then
        return true
    end

    return false
end

function QBindingPhone:checkRedTips( ... )
    if not self:checkOpenBindingPhone() then
        return false
    end

	if self:checkCanGetAwards() and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.IOS_BINDING_PHONE) then
		return true
	end

	return false
end


function QBindingPhone:getBindingPhoneAwards( ... )
    local configValue = QStaticDatabase:sharedDatabase():getConfigurationValue("text_reward")

    return {typeName = ITEM_TYPE.TOKEN_MONEY, count = tonumber(configValue)}
end

function QBindingPhone:setCountdownTime(time)
    self._countdownTime = time
end

function QBindingPhone:getCountdownTime(time)
    return self._countdownTime or 0
end

function QBindingPhone:updateEvent(time)
    self:dispatchEvent({name = QBindingPhone.EVENT_UPDATE_BINDINGPHONE})
end

----------------------------- request handler -------------------------------

--[[
message TelephoneVerifyCodeGetRequest {
    required string phoneNum = 1; // 手机号
}
]]
--请求手机验证码
function QBindingPhone:getPhoneVerifyCode(phoneNum, success, fail, status)
    local telephoneVerifyCodeGetRequest = {phoneNum = tostring(phoneNum)}
    local request = {api = "TELEPHONE_VERIFY_CODE_GET", telephoneVerifyCodeGetRequest = telephoneVerifyCodeGetRequest}
    app:getClient():requestPackageHandler("TELEPHONE_VERIFY_CODE_GET", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
message TelephoneVerifyCodeCheckRequest {
    required string phoneNum = 1; // 手机号
    required string verifyCode = 2; // 验证码
}
]]
--手机验证码校验
function QBindingPhone:checkPhoneVerifyCode(phoneNum, verifyCode, success, fail, status)
    local telephoneVerifyCodeCheckRequest = {phoneNum = tostring(phoneNum), verifyCode = tostring(verifyCode)}
    local request = {api = "TELEPHONE_VERIFY_CODE_CHECK", telephoneVerifyCodeCheckRequest = telephoneVerifyCodeCheckRequest}
    app:getClient():requestPackageHandler("TELEPHONE_VERIFY_CODE_CHECK", request, function (response)
        self:responseHandler(response, success, nil, true)
        self:updateEvent()
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--请求手机验证码
function QBindingPhone:getYWPhoneVerifyCode(phoneNum, success, fail, status)
    local telephoneVerifyCodeGetRequest = {phoneNum = tostring(phoneNum)}
    local request = {api = "TELEPHONE_VERIFY_CODE_GET", telephoneVerifyCodeGetRequest = telephoneVerifyCodeGetRequest}
    app:getClient():requestPackageHandler("TELEPHONE_VERIFY_CODE_GET", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 验证阅文用户是否已经绑定过了
-- 参数阅文openID和渠道号
function QBindingPhone:getYWUserBindPhone(openId, channel)
    local reqTab = {}
    reqTab.openId = openId
    reqTab.channel = channel
    reqTab.timestamp = os.time()
    local sign = self:sortParam(reqTab)
    sign = crypto.md5(sign)
    sign = string.upper(sign)
    reqTab.sign = sign
    local param = string.format("openId=%s&channel=%s&timestamp=%s&sign=%s",reqTab.openId, reqTab.channel, reqTab.timestamp, reqTab.sign)
    local response = self:sendPostApi("/getUserBindPhone", param)
    return response
end

-- 发送验证码，阅文
-- 参数阅文openID和渠道号
function QBindingPhone:getCodeByYw(openId, channel, phone)
    local reqTab = {}
    reqTab.openId = openId
    reqTab.channel = channel
    reqTab.phone = phone
    reqTab.timestamp = os.time()
    local sign = self:sortParam(reqTab)
    sign = crypto.md5(sign)
    sign = string.upper(sign)
    reqTab.sign = sign
    local param = string.format("openId=%s&channel=%s&phone=%s&timestamp=%s&sign=%s",reqTab.openId, reqTab.channel, reqTab.phone, reqTab.timestamp, reqTab.sign)
    local response = self:sendPostApi("/sendCheckCode", param)
    return response
end

-- 绑定阅文openid，
-- 参数阅文openID和渠道号
function QBindingPhone:bindingYwOpenid(openId, channel, phone, code)
    local reqTab = {}
    reqTab.openId = openId
    reqTab.channel = channel
    reqTab.phone = phone
    reqTab.code = code
    reqTab.timestamp = os.time()
    local sign = self:sortParam(reqTab)
    sign = crypto.md5(sign)
    sign = string.upper(sign)
    reqTab.sign = sign
    local param = string.format("openId=%s&channel=%s&phone=%s&code=%s&timestamp=%s&sign=%s",reqTab.openId, reqTab.channel, reqTab.phone, reqTab.code, reqTab.timestamp, reqTab.sign)
    local response = self:sendPostApi("/bindPhone", param)
    return response
end

function QBindingPhone:sortParam(params)
    local sorted_tbl = {}
    for i,v in pairs(params) do
        table.insert(sorted_tbl,i)
    end
    table.sort(sorted_tbl)
    local to_param = ""
    for k,v in pairs(sorted_tbl) do
        if v ~= nil and v ~= "" then
            to_param = to_param..v.."="..params[v].."&"
        end
    end
    to_param = to_param.."key="..QBindingPhone.KEY
    return to_param
end

function QBindingPhone:sendPostApi(api, param)
    local respbody = {}
    local result, respcode, respheaders, respstatus = http.request {
        create=function ()
            local t = socket.tcp()
            t:settimeout(2, "t")
            return t
        end,
        method = "POST",
        url = QBindingPhone.URL..api,
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

return QBindingPhone
