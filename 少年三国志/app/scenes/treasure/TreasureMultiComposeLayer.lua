-- 宝物批量合成

local TreasureMultiComposeLayer = class("TreasureMultiComposeLayer", UFCCSModelLayer)

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.treasure_info")
local MAX_COMPOSE_NUM = 300

function TreasureMultiComposeLayer.show( composeInfo, canComposeNum, maxNum, currNum, callBack, ... )
 	local layer = TreasureMultiComposeLayer.new("ui_layout/equipment_MultiCompose.json", Colors.modelColor, composeInfo, canComposeNum, maxNum, currNum, callBack, ...)
 	uf_sceneManager:getCurScene():addChild(layer)
 end

-- @param composeInfo         需要合成的宝物
function TreasureMultiComposeLayer:ctor( json, color, composeInfo, canComposeNum, maxNum, currNum, callBack, ... )
	self._composeInfo = composeInfo

	self._resultCount = 0
	self._treasureInfo = treasure_info.get(composeInfo.id)

	self._treasureCanComposeNum = canComposeNum 
	self._maxLimit = maxNum
	self._currNum = currNum
	self._callBack = callBack

	self._totalBg = self:getImageViewByName("Image_Bg")
	self._treasureImgBg = self:getImageViewByName("ImageView_Item_Bg")
	self._treasureImg = self:getImageViewByName("ImageView_Item")
    self._treasureButton = self:getButtonByName("Button_Item")

	self._countLabel = self:getLabelByName("Label_Use_Count")
	self._treasureNameLabel = self:getLabelByName("Label_Item_Name")
	self._treasureCanComposeNumLabel = self:getLabelByName("Label_Item_Num")

	self:_initWidgets()

	self.super.ctor(self, json)

	-- 默认就给到最大可能合成的数量
	self:_checkUseNumDiff(currNum)
end

function TreasureMultiComposeLayer:_initWidgets(  )
	if self._treasureInfo then
		-- icon
		self._treasureImgBg:loadTexture(G_Path.getEquipIconBack(self._treasureInfo.quality))
		self._treasureImg:loadTexture(G_Path.getTreasureIcon(self._treasureInfo.res_id), UI_TEX_TYPE_LOCAL)
    	self._treasureButton:loadTextureNormal(G_Path.getEquipColorImage(self._treasureInfo.quality, G_Goods.TYPE_ITEM))
    	self._treasureButton:loadTexturePressed(G_Path.getEquipColorImage(self._treasureInfo.quality, G_Goods.TYPE_ITEM))

    	-- label
		self._countLabel:setText("1")
		self._treasureCanComposeNumLabel:setText(G_lang:get("LANG_GOODS_NUM", {num = self._treasureCanComposeNum}))

		self._treasureNameLabel:setText(self._treasureInfo.name)
		self._treasureNameLabel:setColor(Colors.qualityColors[self._treasureInfo.quality])

		-- init buttons
		self:registerBtnClickEvent("Button_Item", handler(self, self._onFragIconClicked))

		self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
		self:registerBtnClickEvent("Button_Add_One", function () self:_onClickChangeNum(1) end)
		self:registerBtnClickEvent("Button_Add_Ten", function () self:_onClickChangeNum(MAX_COMPOSE_NUM) end)
		self:registerBtnClickEvent("Button_Sub_One", function () self:_onClickChangeNum(-1) end)
		self:registerBtnClickEvent("Button_Sub_Ten", function () self:_onClickChangeNum(-10) end)
		self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
		self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickCancel))

		-- strokes
		self:getLabelByName("Label_Sub_Ten"):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_Sub_One"):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_Add_Ten"):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_Add_One"):createStroke(Colors.strokeBrown, 1)
		self._treasureNameLabel:createStroke(Colors.strokeBrown, 1)
		
	end
end

function TreasureMultiComposeLayer:onLayerEnter( ... )
	
	EffectSingleMoving.run(self._totalBg, "smoving_bounce")
	self:showAtCenter(true)
	self:closeAtReturn(true)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_COMPOSE, self._onComposeFinished, self)
end

function TreasureMultiComposeLayer:_checkUseNumDiff( num )
	if self._treasureInfo then
		-- 使用“+10”按钮时
		-- if num == 10 and self._resultCount == 1 then
		-- 	num = 9
		-- end

		-- 最少合成1次
		local newComposeCount = math.max(self._resultCount + num, 1)
		-- 如果合成这么多次最后会有多少个产出
		local newResultCount = newComposeCount + self._currNum

		-- __Log("[TreasureMultiComposeLayer:_checkUseNumDiff] newResultCount = %d", newResultCount)
		-- __Log("[TreasureMultiComposeLayer:_checkUseNumDiff] self._currNum = %d", self._currNum)
		-- __Log("[TreasureMultiComposeLayer:_checkUseNumDiff] self._maxLimit = %d", self._maxLimit)		

		-- 如果最终的产出物品大于玩家可拥有的上限
		if newResultCount > self._maxLimit then
			newComposeCount = math.floor((self._maxLimit - self._currNum))
		end
		
		-- 再和当前拥有的数量取最小值
		newComposeCount = math.min(self._treasureCanComposeNum, newComposeCount)

		self._resultCount = newComposeCount
		self._countLabel:setText(self._resultCount)
	end
end

function TreasureMultiComposeLayer:_onClickChangeNum( diff )
	self:_checkUseNumDiff(diff)
end

function TreasureMultiComposeLayer:_onFragIconClicked(  )
	require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_TREASURE, self._treasureInfo.id) 
end

function TreasureMultiComposeLayer:_onClickClose(  )
	self:animationToClose()
end

function TreasureMultiComposeLayer:_onClickCancel(  )
	self:animationToClose()
end

function TreasureMultiComposeLayer:_onClickConfirm(  )
	if self._treasureInfo then
		if self._callBack then
			self._callBack()
		end
		G_HandlersManager.treasureRobHandler:sendComposeTreasure(self._composeInfo.id, self._resultCount)
	end
end

function TreasureMultiComposeLayer:_onComposeFinished( data )
	self:animationToClose()
end


return TreasureMultiComposeLayer