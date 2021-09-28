local CrossWarMessageBox = class("CrossWarMessageBox", UFCCSModelLayer)

require("app.cfg.contest_points_buff_info")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")

function CrossWarMessageBox.show(type, value, callback, ...)
	local box = CrossWarMessageBox.new("ui_layout/crosswar_MessageBox.json", Colors.modelColor, type, value, callback, ...)
	box:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(box)
end

-- message types
CrossWarMessageBox.BUY_CHALLENGE = 1
CrossWarMessageBox.JOIN_GROUP	 = 2

-- #param type: 1-buy challenge  2-join group
-- #param cost: if type == 1 - cost gold
--				   type == 2 - group id
-- #param callback: confirmation callback
function CrossWarMessageBox:ctor(json, color, type, value, callback, ...)
	self._type = type
	self._value = value
	self._callback = callback

	self.super.ctor(self, json, color, ...)
end

function CrossWarMessageBox:onLayerLoad(...)
	-- create strokes
	self:enableLabelStroke("Label_Cost_Num", Colors.strokeBrown, 1)

	-- initialize message
	self:_initMessage()

	-- register button events
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickCancel))
end

function CrossWarMessageBox:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)
end

function CrossWarMessageBox:_initMessage()
	if self._type == CrossWarMessageBox.BUY_CHALLENGE then
		-- show the "buy" message panel
		local panelBuyMsg = self:getPanelByName("Panel_Buy_Msg")
		local panelTip = self:getLabelByName("Label_Bottom_Tip")
		panelBuyMsg:setVisible(true)
		panelTip:setVisible(true)

		-- set cost and remain count
		self:getLabelByName("Label_Cost_Num"):setText(tostring(self._value))
		panelTip:setText(G_lang:get("LANG_CROSS_WAR_REMAIN_BUY_COUNT", {num = G_Me.crossWarData:getRemainBuyChallengeCount()}))

		-- adjust message panel position
		CrossWarCommon.centerContent(panelBuyMsg)
	elseif self._type == CrossWarMessageBox.JOIN_GROUP then
		-- show the "join group" message panel
		local panelJoinGroup = self:getPanelByName("Panel_JoinGroup")
		panelJoinGroup:setVisible(true)

		-- create a richtext label
		local template = self:getLabelByName("Label_JoinGroup")

		local groupInfo = contest_points_buff_info.get(self._value)
		local content = GlobalFunc.formatText(G_lang:get("LANG_CROSS_WAR_JOIN_GROUP_TIP"),
											  {
											   group = groupInfo.name,
											   desc = groupInfo.tips .. "%" --前面一句话最后一个字符是%，所以要多加一个%
											  })

		CrossWarCommon.createRichTextFromTemplate(template, panelJoinGroup, content)
	end
end

function CrossWarMessageBox:_onClickConfirm()
	-- check if gold is enough
	if self._type ==  CrossWarMessageBox.BUY_CHALLENGE then
		if G_Me.userData.gold < self._value then
			G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_REBORN_GOLD_EMPTY"))
			self:animationToClose()
			return
		end
	end

	if self._callback then
		self._callback()
	end

	self:animationToClose()
end

function CrossWarMessageBox:_onClickCancel()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

return CrossWarMessageBox