local INQUIRE_URL = "/platform/pay/queryOrder?"
local ORDER_URL = "/platform/pay/generateOrder?"
local TDREQUEST_URL = "/platform/pay/tdRequestLog?"
local loadingLayer = require("utility.LoadingLayer")
local IapRequest = {}
function IapRequest.sendInquire(param)
	local orderId = param.orderId
	local callback = param.callback
	local _tokentype = param.tokentype or 0
	local url = common:getLoginUrl() .. INQUIRE_URL .. "token=" .. tostring(orderId) .. "&tokentype=" .. _tokentype
	dump(url)
	local iapNetwork = require("network.IapHttpNetwork").new()
	iapNetwork:sendRequest({
	url = url,
	callback = function (data)
		if callback ~= nil then
			callback(data)
		end
	end,
	errorCallback = function ()
		loadingLayer.hide(function ()
			show_tip_label(common:getLanguageString("@wangluoyc"))
		end)
	end
	})
end
function IapRequest.getOrderID(param)
	local callback = param.callback
	local payitemId = param.payitemId
	local serverId = param.serverId
	local acc = param.acc or game.player.m_uid
	local pf = param.pf or CSDKShell.getChannelID()
	local chn_flag = game.player.chn_flag or ""
	local payway = param.payway or ""
	print("IapRequest.getOrderID payway is " .. payway)
	local paywayStr = "&payway=" .. tostring(payway)
	local accStr = "acc=" .. tostring(acc)
	local serverIdStr = "&serverId=" .. tostring(serverId)
	local payitemStr = "&payitem=" .. tostring(payitemId)
	local pfStr = "&pf=" .. tostring(pf)
	local chn_flag = "&chn_flag=" .. tostring(chn_flag)
	local lacStr = "&lac=" .. string.urlencode(game.player.m_loginName)
	local title = "&title=" .. string.urlencode(param.title)
	local desc = "&desc=" .. string.urlencode(param.desc)
	local money = "&money=" .. string.urlencode(param.money)
	local extendInfo = "&extendInfo=" .. string.urlencode(param.extendInfo)
	local url = common:getLoginUrl() .. ORDER_URL .. accStr .. serverIdStr .. payitemStr .. paywayStr .. pfStr .. chn_flag .. lacStr .. title .. desc .. money .. extendInfo
	dump(url)
	local iapNetwork = require("network.IapHttpNetwork").new()
	iapNetwork:sendRequest({
	url = url,
	callback = function (data)
		loadingLayer.hide()
		if callback ~= nil then
			callback(data)
		end
	end,
	errorCallback = function ()
		loadingLayer.hide(function ()
			show_tip_label(common:getLanguageString("@wangluoyc"))
		end)
	end
	})
	loadingLayer.start()
end
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
	local iapurl = common:getLoginUrl()
	local url = iapurl .. TDREQUEST_URL .. accStr .. gameSeverStr .. orderIdStr .. iapIdStr .. currencyAmountStr .. currencyTypeStr .. virtualCurrencyAmountStr .. paymentTypeStr
	dump(url)
	local iapNetwork = require("network.IapHttpNetwork").new()
	iapNetwork:sendRequest({
	url = url,
	callback = function (data)
		dump(data)
		if callback ~= nil then
			callback(data)
		end
	end
	})
end
return IapRequest