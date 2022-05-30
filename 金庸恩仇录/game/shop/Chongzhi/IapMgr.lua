local json = require("framework.json")
local WAIT_CHECK_TIME = 25
local WAIT_TIME = 5
local REQ_COUNT = 5
local loadingLayer = require("utility.LoadingLayer")
local iapRequest = require("network.IapRequest")
local scheduler = require("framework.scheduler")

local IapMgr = class("IapMgr")

function IapMgr:buyGoldIos()
	iapRequest.getOrderID({
	payitemId = self._itemData.payitemId,
	payway = CurrentPayWay or "",
	serverId = tostring(game.player.m_serverID),
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
			dump(data.err)
		else
			self._orderId = data.rtnObj.token
			if self._orderId == nil or self._orderId == "" then
				dump(self._orderId)
				return
			end
			dump("订单号:==" .. self._orderId)
			local param = {}
			param.account = game.player.m_uid
			param.orderId = self._orderId
			param.total = self._itemData.price * 100
			param.currencyType = "CNY"
			SDKTKData.onPlaceOrder(param)
			iapRequest.tdRequestLog({
			orderId = self._orderId,
			productName = self._itemData.productName,
			price = self._itemData.price,
			currencyType = "CNY",
			paymentType = CSDKShell.getYAChannelID()
			})
			local isMonthCard = "0"
			if self._itemData.isMonthCard == true then
				isMonthCard = "1"
			end
			local parampay = {}
			parampay.account = game.player.m_uid
			parampay.orderId = self._orderId
			parampay.amount = checknumber(self._itemData.price * 100)
			parampay.currencyType = "CNY"
			parampay.payType = CSDKShell.getYAChannelID()
			SDKTKData.onPay(parampay)
			loadingLayer.start(0)
			local function hidePanel(dt)
				loadingLayer.hide()
				scheduler.unscheduleGlobal(self._schedule)
				self._schedule = nil
			end
			self._schedule = scheduler.scheduleGlobal(hidePanel, 5, false)
			dump("orderId:" .. self._orderId .. "::" .. tostring(game.player.m_serverID) .. "##" .. isMonthCard .. "##" .. game.player.m_uid .. "price:" .. self._itemData.price .. "productId:" .. self._itemData.payitemId)
			local ret = CSDKShell.payForCoins({
			orderId = self._orderId,
			payDescription = tostring(game.player.m_serverID) .. "##" .. isMonthCard .. "##" .. game.player.m_uid,
			coins = self._itemData.price,
			productId = self._itemData.payitemId,
			productName = self._itemData.productName
			})
		end
	end
	})
end

local function getExtendInfo()
	local t = {
	name = game.player.getPlayerName(),
	level = game.player.getLevel(),
	serverId = tostring(game.player.m_serverID),
	serverName = game.player.m_serverName,
	newZoneId = game.player.m_zoneID
	}
	return json.encode(t)
end

function IapMgr:buyGold(param)
	self._reqCount = 0
	self._itemData = param.itemData
	self._callback = param.callback
	self._orderId = -1
	self:buyGoldIos()
	local function event_call(event, orderId)
		dump("########### event_call ###########")
		print(event)
		print(tostring(orderId))
		if self._orderId and self._orderId == -1 and orderId then
			self._orderId = orderId
		end
		local orderItem = {}
		orderItem.orderId = self._orderId
		orderItem.itemData = clone(self._itemData)
		orderItem.checkTime = 0
		orderItem.callback = self._callback
		common:insertOrder(orderItem)
		if event == "SDKDOSDKCOM_PAY_SUCCESS" then
			iapRequest.sendInquire({
			orderId = self._orderId,
			tokentype = 1
			})
		elseif event == "SDKDOSDKCOM_PAY_CANCEL" then
			iapRequest.sendInquire({
			orderId = self._orderId,
			tokentype = 3
			})
		elseif event == "SDKDOSDKCOM_PAY_FAILED" then
			loadingLayer.hide()
			iapRequest.sendInquire({
			orderId = self._orderId,
			tokentype = 2
			})
		end
		loadingLayer.hide()
	end
	CSDKShell.addEventCallBack("payEvent", event_call)
end

function IapMgr:waitReqOrder(time)
	loadingLayer.start()
	game.runningScene:runAction(transition.sequence({
	CCDelayTime:create(time),
	CCCallFunc:create(function()
		self:checkInquire()
	end)
	}))
end

function IapMgr:checkInquire()
	iapRequest.sendInquire({
	orderId = self._orderId,
	callback = function(data)
		dump(common:getLanguageString("@qingqiujg"))
		dump(data)
		if data.err ~= "" then
			if CSDKShell.getYAChannelID() == CHANNELID.IOS_91 then
				if self._reqCount < REQ_COUNT then
					self._reqCount = self._reqCount + 1
					self:waitReqOrder(WAIT_TIME)
				else
					loadingLayer.hide()
				end
			else
				dump(data.err)
			end
		elseif data.rtnObj.status == "0" or data.rtnObj.status == "1" then
			if self._reqCount < REQ_COUNT then
				self._reqCount = self._reqCount + 1
				self:waitReqOrder(WAIT_TIME)
			else
				loadingLayer.hide()
			end
		elseif data.rtnObj.status == "2" then
			dump(common:getLanguageString("@chongzhicg"))
			local parampay = {}
			parampay.account = game.player.m_uid
			parampay.orderId = self._orderId
			parampay.amount = checknumber(self._itemData.price * 100)
			parampay.currencyType = "CNY"
			parampay.payType = "1"
			SDKTKData.onOrderPaySucc(parampay)
			if TargetPlatForm ~= PLATFORMS.TW or device.platform == "ios" then
			elseif CSDKShell.purchase then
				CSDKShell.purchase(self._itemData.price)
			end
			if device.platform == "ios" then
				CSDKShell.submitExtData({isPaySuc = true})
			end
			loadingLayer.hide()
			if self._callback ~= nil then
				self._callback(data)
			end
		end
	end
	})
end

return IapMgr