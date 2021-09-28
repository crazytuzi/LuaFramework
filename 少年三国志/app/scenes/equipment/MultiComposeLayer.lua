-- 批量合成（目前支持武将和装备）

local BagConst = require("app.const.BagConst")

local MultiComposeLayer = class("MultiComposeLayer", UFCCSModelLayer)

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.fragment_info")
local MAX_COMPOSE_NUM = 300

function MultiComposeLayer.show( fragment, maxNum, currNum, ... )
 	local layer = MultiComposeLayer.new("ui_layout/equipment_MultiCompose.json", Colors.modelColor, fragment, maxNum, currNum, ...)
 	uf_sceneManager:getCurScene():addChild(layer)
 end

-- @param fragment         需要合成的碎片
function MultiComposeLayer:ctor( json, color, fragment, maxNum, currNum, ... )

	self._resultCount = 0
	self._fragInfo = fragment_info.get(fragment.id)
	self._fragCanComposeNum = math.floor(fragment.num / self._fragInfo.max_num)
	self._maxLimit = maxNum
	self._currNum = currNum

	self._totalBg = self:getImageViewByName("Image_Bg")
	self._fragImgBg = self:getImageViewByName("ImageView_Item_Bg")
	self._fragImg = self:getImageViewByName("ImageView_Item")
    self._fragButton = self:getButtonByName("Button_Item")

	self._countLabel = self:getLabelByName("Label_Use_Count")
	self._fragNameLabel = self:getLabelByName("Label_Item_Name")
	self._fragCanComposeNumLabel = self:getLabelByName("Label_Item_Num")

	self:_initWidgets()

	self.super.ctor(self, json)

	self:_checkUseNumDiff(1)
end

function MultiComposeLayer:_initWidgets(  )
	if self._fragInfo then
		-- icon
		self._fragImgBg:loadTexture(G_Path.getEquipIconBack(self._fragInfo.quality))
		if self._fragInfo.fragment_type == BagConst.FRAGMENT_TYPE_KNIGHT then
			self._fragImg:loadTexture(G_Path.getKnightIcon(self._fragInfo.res_id), UI_TEX_TYPE_LOCAL)
		elseif self._fragInfo.fragment_type == BagConst.FRAGMENT_TYPE_EQUIPMENT then
			self._fragImg:loadTexture(G_Path.getEquipmentIcon(self._fragInfo.res_id), UI_TEX_TYPE_LOCAL)
		elseif self._fragInfo.fragment_type == BagConst.FRAGMENT_TYPE_PET then
			self._fragImg:loadTexture(G_Path.getPetIcon(self._fragInfo.res_id), UI_TEX_TYPE_LOCAL)
		end
    	self._fragButton:loadTextureNormal(G_Path.getEquipColorImage(self._fragInfo.quality, G_Goods.TYPE_ITEM))
    	self._fragButton:loadTexturePressed(G_Path.getEquipColorImage(self._fragInfo.quality, G_Goods.TYPE_ITEM))

    	-- label
		self._countLabel:setText("1")
		self._fragCanComposeNumLabel:setText(G_lang:get("LANG_GOODS_NUM", {num = self._fragCanComposeNum}))

		self._fragNameLabel:setText(self._fragInfo.name)
		self._fragNameLabel:setColor(Colors.qualityColors[self._fragInfo.quality])

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
		self._fragNameLabel:createStroke(Colors.strokeBrown, 1)
		
	end
end

function MultiComposeLayer:onLayerEnter( ... )
	
	EffectSingleMoving.run(self._totalBg, "smoving_bounce")
	self:showAtCenter(true)
	self:closeAtReturn(true)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BAG_FRAGMENT_COMPOUND, self._onComposeFinished, self)
end

function MultiComposeLayer:_checkUseNumDiff( num )
	if self._fragInfo then
		-- 使用“+10”按钮时
		-- if num == 10 and self._resultCount == 1 then
		-- 	num = 9
		-- end

		-- 最少合成1次
		local newComposeCount = math.max(self._resultCount + num, 1)
		-- 如果合成这么多次最后会有多少个产出
		local newResultCount = newComposeCount + self._currNum

		-- __Log("[MultiComposeLayer:_checkUseNumDiff] newResultCount = %d", newResultCount)
		-- __Log("[MultiComposeLayer:_checkUseNumDiff] self._currNum = %d", self._currNum)
		-- __Log("[MultiComposeLayer:_checkUseNumDiff] self._maxLimit = %d", self._maxLimit)		

		-- 如果最终的产出物品大于玩家可拥有的上限
		if newResultCount > self._maxLimit then
			newComposeCount = math.floor((self._maxLimit - self._currNum))
		end
		
		-- 再和当前拥有的数量取最小值
		newComposeCount = math.min(self._fragCanComposeNum, newComposeCount)

		self._resultCount = newComposeCount
		self._countLabel:setText(self._resultCount)
	end
end

function MultiComposeLayer:_onClickChangeNum( diff )
	self:_checkUseNumDiff(diff)
end

function MultiComposeLayer:_onFragIconClicked(  )
	require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_FRAGMENT, self._fragInfo.id) 
end

function MultiComposeLayer:_onClickClose(  )
	self:animationToClose()
end

function MultiComposeLayer:_onClickCancel(  )
	self:animationToClose()
end

function MultiComposeLayer:_onClickConfirm(  )
	if self._fragInfo then
		G_HandlersManager.bagHandler:sendFragmentCompoundMsg(self._fragInfo.id, self._resultCount)
	end
end

function MultiComposeLayer:_onComposeFinished( data )
	self:animationToClose()
end


return MultiComposeLayer