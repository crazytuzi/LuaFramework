local ZhenShenBuyMsgBox = class("ZhenShenBuyMsgBox", function(param)
	return require("utility.ShadeLayer").new()
end)

function ZhenShenBuyMsgBox:sendBuy()
	RequestHelper.buyActTimes({
	aid = 7,
	act = 2,
	-- RequestHelper.buyZhenShenTimes({
	callback = function(data)
		ZhenShenModel.buySuccess(data)
		if self.removeListener then
			self.removeListener()
		end
		self:removeSelf()
	end
	})
end

function ZhenShenBuyMsgBox:previewInit()
	local rowOneTable = {}
	local isBuy = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@IsCost")
	})
	rowOneTable[#rowOneTable + 1] = isBuy
	local goldNum = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@Money", ZhenShenModel.getCost()),
	color = ccc3(255, 210, 0)
	})
	rowOneTable[#rowOneTable + 1] = goldNum
	local buyOne = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@BuyOne")
	})
	rowOneTable[#rowOneTable + 1] = buyOne
	local fubenName = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@zhenshenfuben"),
	color = ccc3(255, 210, 0)
	})
	rowOneTable[#rowOneTable + 1] = fubenName
	local atkTime = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@AttackNumber")
	})
	rowOneTable[#rowOneTable + 1] = atkTime
	local rowTwoTable = {}
	local todayBuy = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@AlreadyBuy")
	})
	rowTwoTable[#rowTwoTable + 1] = todayBuy
	local buyNume = ResMgr.createShadowMsgTTF({
	text = ZhenShenModel.getBuyCnt(),
	color = ccc3(58, 209, 73)
	})
	rowTwoTable[#rowTwoTable + 1] = buyNume
	local buytime = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@Next")
	})
	rowTwoTable[#rowTwoTable + 1] = buytime
	local rowAll = {rowOneTable, rowTwoTable}
	local msg = require("utility.MsgBoxEx").new({
	resTable = rowAll,
	confirmFunc = function()
		self:onConfirm()
	end,
	closeFunc = function()
		self:onClose()
	end
	})
	self:addChild(msg)
end

function ZhenShenBuyMsgBox:onConfirm()
	if ZhenShenModel.getGold() < ZhenShenModel.getCost() then
		ResMgr.showMsg(7)
	else
		self:sendBuy()
	end
end

function ZhenShenBuyMsgBox:onClose()
	self:removeSelf()
end

function ZhenShenBuyMsgBox:ctor(param)
	self.removeListener = param.removeListener
	self:previewInit()
end

return ZhenShenBuyMsgBox