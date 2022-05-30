local FormZhuZhenBuyMsgBox = class("FormZhuZhenBuyMsgBox", function (param)
	return require("utility.ShadeLayer").new()
end)

function FormZhuZhenBuyMsgBox:ctor(param)
	self:previewInit(param)
end

function FormZhuZhenBuyMsgBox:sendBuy()
	HelpLineModel:openHelp({
	pos = self._pos,
	callback = function (data)
		--show_tip_label()  --九-零-一-起玩-w-w-w-.9-0-1-7-5-.-com
		HelpLineModel:addHelp(data)
		if self.removeListener then
			self.removeListener(self._pos)
		end
		self:removeSelf()
	end
	})
end

function FormZhuZhenBuyMsgBox:previewInit(param)
	self.removeListener = param.removeListener
	self._pos = param.pos
	local rowZeroTable = {}
	local isBuy = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@IsCost")
	})
	rowZeroTable[#rowZeroTable + 1] = isBuy
	local goldType, expend = HelpLineModel:getCost(param.pos)
	local text = common:getLanguageString("@SilverLabel")
	if goldType == 2 then
		text = common:getLanguageString("@Goldlabel")
	end
	local goldNum = ResMgr.createShadowMsgTTF({
	text = tostring(expend) .. text,
	color = ccc3(255, 210, 0)
	})
	rowZeroTable[#rowZeroTable + 1] = goldNum
	local buyOne = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@zhuzhen_open")
	})
	rowZeroTable[#rowZeroTable + 1] = buyOne
	local rowOneTable = {}
	local fubenName = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@zhuzhen_open_name"),
	color = ccc3(255, 210, 0)
	})
	rowOneTable[#rowOneTable + 1] = fubenName
	local rowAll = {rowZeroTable, rowOneTable}
	local msg = require("utility.MsgBoxEx").new({
	resTable = rowAll,
	confirmFunc = function ()
		self:onConfirm()
	end,
	closeFunc = function ()
		self:onClose()
	end
	})
	self:addChild(msg)
end

function FormZhuZhenBuyMsgBox:onConfirm()
	local goldType, expend = HelpLineModel:getCost(self._pos)
	if goldType == 1 then
		if expend > game.player.m_silver then
			ResMgr.showMsg(8)
			return
		end
	elseif expend > game.player.m_gold then
		ResMgr.showMsg(7)
		return
	end
	self:sendBuy()
end

function FormZhuZhenBuyMsgBox:onClose()
	self:removeSelf()
end

return FormZhuZhenBuyMsgBox