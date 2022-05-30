--Ñº×¢½çÃæ
local raceBetLayer = class("raceBetLayer", function(param)
	return require("utility.ShadeLayer").new()
end)

local kuafuMsg = {
setRaceStake = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossStake",
	targetAcc = param.targetAcc,
	targetIdx = param.targetIdx,
	type = param.type
	}
	RequestHelper.request(msg, _callback, param.errback)
end
}

function raceBetLayer:ctor(param)
	self.userInfo = {}
	self.userInfo[1] = param.leftPlayer
	self.userInfo[2] = param.rightPlayer
	self.betType = param.betType
	self.listener = param.listener
	local rootProxy = CCBProxy:create()
	self._rootnode = {}
	local rootnode = CCBuilderReaderLoad("kuafu/detain_Msgbox.ccbi", rootProxy, self._rootnode)
	self:addChild(rootnode, 1)
	rootnode:setPosition(display.width / 2, display.height / 2)
	self._rootnode.closeBtn:addHandleOfControlEvent(function(eventName, sender)
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.left_bet_btn:addHandleOfControlEvent(function(sender, eventName)
		self:betUser(1)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.right_bet_btn:addHandleOfControlEvent(function(sender, eventName)
		self:betUser(2)
	end,
	CCControlEventTouchUpInside)
	
	self:updateUserInfo()
	local data_kuafu_configelse_kuafu_configelse = require("data.data_kuafu_configelse_kuafu_configelse")
	self._cost = data_kuafu_configelse_kuafu_configelse[9].num
	self._rootnode.detain_text:setString(common:getLanguageString("@DetainText", self._cost))
	for key = 1, 2 do
		setTTFLabelOutline({
		label = self._rootnode["player_name_" .. key]
		})
		setTTFLabelOutline({
		label = self._rootnode["player_server_" .. key]
		})
		setTTFLabelOutline({
		label = self._rootnode["player_Battle_" .. key]
		})
	end
end

function raceBetLayer:updateUserInfo()
	for index, user in pairs(self.userInfo) do
		self._rootnode["player_name_" .. index]:setString(user.name)
		self._rootnode["player_server_" .. index]:setString(tostring(user.serverName))
		self._rootnode["player_Battle_" .. index]:setString(user.point)
		ResMgr.refreshIcon({
		id = 1,
		itemBg = self._rootnode["player_icon_" .. index],
		resType = ResMgr.HERO,
		cls = 5
		})
	end
end

function raceBetLayer:betUser(side)
	if self._cost > game.player:getSilver() then
		show_tip_label(common:getLanguageString("@SilverCoinEnough"))
		return
	end
	local user = self.userInfo[side]
	local layer = require("utility.MsgBox").new({
	size = cc.size(500, 250),
	content = common:getLanguageString("@BetTip1", user.name),
	rightBtnFunc = function()
		self.listener(side)
		self:removeSelf()
	end,
	directclose = true,
	rightBtnName = common:getLanguageString("@Confirm"),
	leftBtnName = common:getLanguageString("@NO"),
	leftBtnFunc = function()
		dump("left")
	end
	})
	self:addChild(layer, 11)
end

return raceBetLayer