local TreasureRobAllHint = class("TreasureRobAllHint", UFCCSModelLayer)

require("app.cfg.treasure_info")
local ShopVipConst = require("app.const.ShopVipConst")
local TreasureConst = require("app.const.TreasureConst")
local TreasureRobAllScene = require("app.scenes.treasure.TreasureRobAllScene")

function TreasureRobAllHint.show(treasureID)
	local layer = TreasureRobAllHint.new("ui_layout/treasure_TreasureRobAllHint.json", Colors.modelColor, treasureID)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function TreasureRobAllHint:ctor(json, color, treasureID)
	self._treasureID = treasureID 	-- 一键夺宝的目标宝物ID
	self._autoUseEnergy = true 		-- 精力不够时，是否自动使用精力丹

	self.super.ctor(self, json, color)
end

function TreasureRobAllHint:onLayerLoad()
	-- set treasure name
	local info = treasure_info.get(self._treasureID)
	local nameLabel = self:getLabelByName("Label_TreasureName")
	nameLabel:setText(info.name)
	nameLabel:setColor(Colors.qualityColors[info.quality])
	nameLabel:createStroke(Colors.strokeBrown, 1)

	-- adjust the message content to let it at center
	local msgPanel = self:getPanelByName("Panel_Msg")
	GlobalFunc.centerContent(msgPanel)

	-- check the checkbox defaultly
	self:setSelectStatus("CheckBox_Choose", self._autoUseEnergy)

	-- register button events
	self:registerCheckboxEvent("CheckBox_Choose", handler(self, self._onCheckBox))
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickCancel))
end

function TreasureRobAllHint:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
end

function TreasureRobAllHint:_onCheckBox(widget, type, isCheck)
	self._autoUseEnergy = isCheck
end

function TreasureRobAllHint:_onClickConfirm()
	local spirit = G_Me.userData.spirit
	if spirit >= TreasureConst.SPIRITS_COST_PER_ROB then
		__LogTag(TAG, "----精力足够，去夺宝")
		self:_goToRobAllScene()
	else
		__LogTag(TAG, "----精力单数量：" .. G_Me.bagData:getItemCount(4))
		if self._autoUseEnergy and G_Me.bagData:getItemCount(4) > 0 then
			__LogTag(TAG, "----精力不够，自动使用精力去夺宝")
			self:_goToRobAllScene()
		else
			GlobalFunc.showPurchasePowerDialog(2)
		end
	end
end

function TreasureRobAllHint:_onClickCancel()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

function TreasureRobAllHint:_goToRobAllScene()
	local scene = TreasureRobAllScene.new(self._treasureID, self._autoUseEnergy)
	uf_sceneManager:popToRootAndReplaceScene(scene)
end

return TreasureRobAllHint