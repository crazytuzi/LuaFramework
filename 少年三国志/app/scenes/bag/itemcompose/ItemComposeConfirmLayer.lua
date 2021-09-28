-- 道具合成确认弹窗

local ItemComposeConfirmLayer = class("ItemComposeConfirmLayer", UFCCSModelLayer)


function ItemComposeConfirmLayer.show( targetItemInfo, canComposeNum, totalCostMoney, composeId )
	local layer = ItemComposeConfirmLayer.new("ui_layout/bag_ItemComposeConfirmLayer.json", Colors.modelColor, targetItemInfo, canComposeNum, totalCostMoney, composeId)
	uf_sceneManager:getCurScene():addChild(layer)
end

function ItemComposeConfirmLayer:ctor( json, color, targetItemInfo, canComposeNum, totalCostMoney , composeId )
	self._targetItemInfo = targetItemInfo
	self._canComposeNum = canComposeNum
	self._totalCostMoney = totalCostMoney
	self._composeId = composeId

	self.super.ctor(self, json)
end

-- function ItemComposeConfirmLayer:onLayerLoad(  )
-- 	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ITEM_COMPOSE_RESULT, self._onComposeResult, self)
-- end

function ItemComposeConfirmLayer:onLayerEnter(  )
	self:closeAtReturn(true)
	self:showAtCenter(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

	self:registerBtnClickEvent("Button_Cancel", function (  )
		self:animationToClose()
	end)
	self:registerBtnClickEvent("Button_Confirm", function (  )
		G_HandlersManager.bagHandler:sendItemCompose(self._composeId)
		self:animationToClose()
	end)
	self:registerBtnClickEvent("Button_Close", function (  )
		self:animationToClose()
	end)
	self:registerBtnClickEvent("Button_Target_Item", function (  )
		self:_showTargetItemInfo()
	end)

	self:_initWidgets()
end


function ItemComposeConfirmLayer:_initWidgets(  )
	-- 目标道具图标
	local targetItemImg = self:getImageViewByName("ImageView_Target_Item")
	local targetItemQualityBorderImg = self:getImageViewByName("ImageView_Target_Item_Bg")
    local targetItemButton = self:getButtonByName("Button_Target_Item")

	targetItemImg:loadTexture(G_Path.getItemIcon(self._targetItemInfo.res_id), UI_TEX_TYPE_LOCAL)
	targetItemQualityBorderImg:loadTexture(G_Path.getEquipIconBack(self._targetItemInfo.quality))
	targetItemButton:loadTextureNormal(G_Path.getEquipColorImage(self._targetItemInfo.quality,G_Goods.TYPE_ITEM))
	targetItemButton:loadTexturePressed(G_Path.getEquipColorImage(self._targetItemInfo.quality,G_Goods.TYPE_ITEM))

	local targetItemNameLabel = self:getLabelByName("Label_Name")
	targetItemNameLabel:setText(self._targetItemInfo.name)

	local canComposeNumLabel = self:getLabelByName("Label_Compose_Num")
	canComposeNumLabel:setText(G_lang:get("LANG_ITEM_COMPOSE_CAN_COMPOSE_COUNT_2", {num = self._canComposeNum}))

	local costLabel = self:getLabelByName("Label_Cost")
	costLabel:createStroke(Colors.strokeBrown, 1)
	costLabel:setText(self._totalCostMoney)
end

function ItemComposeConfirmLayer:_showTargetItemInfo(  )
	if self._targetItemInfo then
		require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_ITEM, self._targetItemInfo.id) 
	end
end

return ItemComposeConfirmLayer