local SubMapBuyMsgBox = class("SubMapBuyMsgBox", function(param)
	return require("utility.ShadeLayer").new()
end)

function SubMapBuyMsgBox:sendPreview()
	SubMapModel.sendPreview({
	callback = function()
		self:previewInit()
	end,
	errorCB = function(...)
		self.errorCallBack()
		self:onClose()
	end
	})
end

function SubMapBuyMsgBox:sendBuy()
	SubMapModel.sendBuy({
	callback = function()
		self.removeListener()
		self:onClose()
	end,
	errorCB = function(...)
		self.errorCallBack()
		self:onClose()
	end
	})
end

function SubMapBuyMsgBox:previewInit()
	local rowOneTable = {}
	local isBuy = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@Cost")
	})
	rowOneTable[#rowOneTable + 1] = isBuy
	local goldNum = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@Gold", SubMapModel.getCost()),
	color = cc.c3b(255, 210, 0)
	})
	rowOneTable[#rowOneTable + 1] = goldNum
	local buyOne = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@orConsume")
	})
	rowOneTable[#rowOneTable + 1] = buyOne
	local fubenName = ResMgr.createShadowMsgTTF({
	text = "1" .. common:getLanguageString("@GuildShopItemUnit"),
	color = cc.c3b(58, 209, 73)
	})
	rowOneTable[#rowOneTable + 1] = fubenName
	local itemIcon = display.newSprite("#icon_qianggongling.png")
	rowOneTable[#rowOneTable + 1] = itemIcon
	local curNumTTF = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@CurrentOwn"),
	color = cc.c3b(58, 209, 73)
	})
	rowOneTable[#rowOneTable + 1] = curNumTTF
	local curNum = ResMgr.createShadowMsgTTF({
	text = SubMapModel.getQiangGongNum() .. common:getLanguageString("@GuildShopItemUnit") .. ")",
	color = cc.c3b(58, 209, 73)
	})
	rowOneTable[#rowOneTable + 1] = curNum
	local rowTwoTable = {}
	local todayBuy = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@CurrentStageResetTime")
	})
	rowTwoTable[#rowTwoTable + 1] = todayBuy
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

function SubMapBuyMsgBox:onConfirm()
	if SubMapModel.isEnoughQiangGong() then
		self:sendBuy()
	elseif SubMapModel.isEnoughGold() then
		self:sendBuy()
	else
		show_tip_label(common:getLanguageString("GoldCoinEnough"))
	end
end

function SubMapBuyMsgBox:onClose()
	self:removeSelf()
end

function SubMapBuyMsgBox:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	self.removeListener = param.removeListener
	self.errorCallBack = param.errorCallBack
	self:sendPreview()
end

return SubMapBuyMsgBox