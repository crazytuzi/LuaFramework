module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_Divination = i3k_class("wnd_Divination", ui.wnd_base)

function wnd_Divination:ctor()
	self._touchMoveFlag = false
	self.divitation = {}
	self._movePoint = {}
	self._color = cc.c4f(150 /255, 104 /255, 86 / 255, 1)
end

function wnd_Divination:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseBtn)
	widgets.define:onClick(self, self.onDefineBtn)
	widgets.help:onClick(self, self.onHelpBtn)
	self.root = widgets.root
	self.coin = widgets.coin
	self.coinNum = widgets.coinNum
	self.des = widgets.des
	self.textArea = widgets.textArea
	self.textArea:setText(i3k_get_string(17161))
end

function wnd_Divination:refresh()
	self.divitation = i3k_db_Divinationcfg
	self.coin:setImage(g_i3k_db.i3k_db_get_base_item_cfg(self.divitation.coinType).icon)
	self.coinNum:setText(self.divitation.coinNum)
	self.des:setText(i3k_get_string(17143))
end

function wnd_Divination:onShow()
	local widgets = self._layout.vars
	local nodeSize = widgets.scroll:getContentSize()
	local posX = widgets.scroll:getPositionX() -- 相对于父控件的锚点位置
	local posY = widgets.scroll:getPositionY()

	self._minX = posX - nodeSize.width / 2
	self._minY = posY - nodeSize.height / 2
	self._maxX = posX + nodeSize.width / 2
	self._maxY = posY + nodeSize.height / 2

	local layerFarm = cc.Layer:create()
	widgets.scroll:addChild(layerFarm)
	self._layerFarm = layerFarm
	widgets.scroll:onTouchEvent(self, self.onScrollBtn)
end

function wnd_Divination:onScrollBtn(sender, event)
	if event == ccui.TouchEventType.began then
		local mousePos = g_i3k_ui_mgr:GetMousePos()
		local pos = sender:convertToNodeSpace(mousePos)
		self._prePos = pos
		self._movePoint = {[1] = pos}
		self._tempNodes = {}
	elseif event == ccui.TouchEventType.moved then
		local mousePos = g_i3k_ui_mgr:GetMousePos()
		local pos = sender:convertToNodeSpace(mousePos)

		local node = cc.DrawNode:create()
		node:drawSegment(self._prePos, pos, 1, self._color)
		self._prePos = pos
		self._layerFarm:addChild(node)
		table.insert(self._tempNodes, node)

		table.insert(self._movePoint, pos)
		self._touchMoveFlag = true

		if self.textArea:isVisible() then
			self.textArea:hide()
		end
	elseif event == ccui.TouchEventType.ended then

		for k, v in ipairs(self._tempNodes) do
			self._layerFarm:removeChild(v)
		end

		local node = cc.DrawNode:create()
		node:drawCatmullRom(self._movePoint, #self._movePoint, self._color)
		self._layerFarm:addChild(node)
		self._movePoint = {}

	end

end

function wnd_Divination:onHide()

end

function wnd_Divination:onCloseBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_Divination)
end

function wnd_Divination:onDefineBtn()
	if not self._touchMoveFlag then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17162))
		return
	end

	if g_i3k_game_context:GetCommonItemCanUseCount(self.divitation.coinType) < self.divitation.coinNum then
		g_i3k_ui_mgr:PopupTipMessage("货币不足")
		return
	end

	i3k_sbean.conduct_divination()
	self:onCloseBtn()
end

function wnd_Divination:onHelpBtn()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17144))
end

function wnd_create(layout)
	local wnd = wnd_Divination.new();
	wnd:create(layout);
	return wnd;
end
