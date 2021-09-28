-- 道具批量使用（目前仅支持体力丹和精力丹）

local BagUseItemMultiTimesLayer = class("BagUseItemMultiTimesLayer", UFCCSModelLayer)

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function BagUseItemMultiTimesLayer.show( isFromBag, itemNum, itemInfo, currResultNum, maxLimit, ... )
 	local layer = BagUseItemMultiTimesLayer.new("ui_layout/bag_ItemUseMultiTimesLayer.json", Colors.modelColor, isFromBag, itemNum, itemInfo, currResultNum, maxLimit, ...)
 	uf_sceneManager:getCurScene():addChild(layer)
 end

-- @param isFromBag         是否从包裹中打开的这个界面
-- @param itemNum    		当前拥有该道具的数量
-- @param itemInfo   		item_info表中对应的该道具信息
-- @param currResultNum 	当前拥有的该道具使用后产出物的数量
-- @param maxLimit 			该道具产出物可拥有数量的上限值
function BagUseItemMultiTimesLayer:ctor( json, color, isFromBag, itemNum, itemInfo, currResultNum, maxLimit, ... )
	self._isFromBag = isFromBag
	self._useCount = 0
	self._itemNum = itemNum
	self._itemInfo = itemInfo
	self._maxLimit = maxLimit
	self._currResultNum = currResultNum

	self._itemImgBg = self:getImageViewByName("ImageView_Item_Bg")
	self._itemImg = self:getImageViewByName("ImageView_Item")
    self._itemButton = self:getButtonByName("Button_Item")

	self._countLabel = self:getLabelByName("Label_Use_Count")
	self._itemNameLabel = self:getLabelByName("Label_Item_Name")
	self._itemNumLabel = self:getLabelByName("Label_Item_Num")

	self:_initWidgets()

	self.super.ctor(self, json)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_USE_ITEM, self._useBagItem, self)

	self:_checkUseNumDiff(1)
end

function BagUseItemMultiTimesLayer:_initWidgets(  )
	if self._itemInfo then
		-- icon
		self._itemImgBg:loadTexture(G_Path.getEquipIconBack(self._itemInfo.quality))
		self._itemImg:loadTexture(G_Path.getItemIcon(self._itemInfo.res_id), UI_TEX_TYPE_LOCAL)
    	self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(self._itemInfo.quality, G_Goods.TYPE_ITEM))
    	self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(self._itemInfo.quality, G_Goods.TYPE_ITEM))

    	-- label
		self._countLabel:setText("1")
		self._itemNumLabel:setText(G_lang:get("LANG_GOODS_NUM", {num = self._itemNum}))

		self._itemNameLabel:setText(self._itemInfo.name)
		self._itemNameLabel:setColor(Colors.qualityColors[self._itemInfo.quality])

		-- init buttons
		self:registerBtnClickEvent("Button_Item", handler(self, self._onItemIconClicked))

		self:getButtonByName("Button_Add_One"):setTag(1)
		self:getButtonByName("Button_Add_Ten"):setTag(20)
		if self._itemInfo.item_type == 16 then
			-- 征讨令最多一次加10个
			self:getButtonByName("Button_Add_Ten"):setTag(10)
			self:getLabelByName("Label_Add_Ten"):setText("+10")
		end
		self:getButtonByName("Button_Sub_One"):setTag(-1)
		self:getButtonByName("Button_Sub_Ten"):setTag(-10)

		self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
		self:registerBtnClickEvent("Button_Add_One", handler(self, self._onClickChangeNum))
		self:registerBtnClickEvent("Button_Add_Ten", handler(self, self._onClickChangeNum))
		self:registerBtnClickEvent("Button_Sub_One", handler(self, self._onClickChangeNum))
		self:registerBtnClickEvent("Button_Sub_Ten", handler(self, self._onClickChangeNum))
		self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
		self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickCancel))

		-- strokes
		self:getLabelByName("Label_Sub_Ten"):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_Sub_One"):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_Add_Ten"):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_Add_One"):createStroke(Colors.strokeBrown, 1)
		self._itemNameLabel:createStroke(Colors.strokeBrown, 1)

		self:showWidgetByName("Label_Use_Tips", not self._isFromBag)
		local useTipsLabel = self:getLabelByName("Label_Use_Tips")
		if not self._isFromBag then 
			local tipsTxt = ""
			if self._itemInfo.item_type == 8 then
				tipsTxt = G_lang:get("LANG_PURCHASE_POWER_TILI_TIPS")
			elseif self._itemInfo.item_type == 9 then
				tipsTxt = G_lang:get("LANG_PURCHASE_POWER_JINGLI_TIPS")
			elseif self._itemInfo.item_type == 16 then
				tipsTxt = G_lang:get("LANG_PURCHASE_POWER_CHUZHENGLING_TIPS")
			end
			useTipsLabel:setText(tipsTxt)
		end
	end
end

function BagUseItemMultiTimesLayer:onLayerEnter( ... )
	
	EffectSingleMoving.run(self, "smoving_bounce")
	self:showAtCenter(true)
	self:closeAtReturn(true)
end

function BagUseItemMultiTimesLayer:_checkUseNumDiff( num )
	if self._itemInfo then
		-- 使用“+10”按钮时
		if self._itemInfo.item_type == 16 and num == 10 and self._useCount == 1 then
			num = 9
		end

		-- 最少使用1次
		local newUseCount = math.max(self._useCount + num, 1)
		-- 如果使用这么多次最后会有多少个产出物品
		local newResultCount = newUseCount * self._itemInfo.item_value + self._currResultNum
		-- 如果最终的产出物品大于玩家可拥有的上限
		if newResultCount > self._maxLimit then
			newUseCount = math.floor((self._maxLimit - self._currResultNum) / self._itemInfo.item_value)
		end
		
		-- 再和当前拥有的数量取最小值
		newUseCount = math.min(self._itemNum, newUseCount)

		self._useCount = newUseCount
		self._countLabel:setText(self._useCount)
	end
end

function BagUseItemMultiTimesLayer:onLayerExit( ... )
	-- body
end


function BagUseItemMultiTimesLayer:_onClickChangeNum( widget )
	local diff = widget:getTag()

	self:_checkUseNumDiff(tonumber(diff))
end

function BagUseItemMultiTimesLayer:_onItemIconClicked(  )
	require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_ITEM, self._itemInfo.id) 
end

function BagUseItemMultiTimesLayer:_onClickClose(  )
	self:animationToClose()
end

function BagUseItemMultiTimesLayer:_onClickCancel(  )
	self:animationToClose()
end

function BagUseItemMultiTimesLayer:_onClickConfirm(  )
	if self._itemInfo then
		G_HandlersManager.bagHandler:sendUseItemInfo(self._itemInfo.id, nil, self._useCount)
	end
end


function BagUseItemMultiTimesLayer:_useBagItem( data )
	if data.ret == 1 then
        local item = item_info.get(data.id)
        if item ~= nil then
            -- 如果是征讨令则特殊处理一下，在BagUseItemMultiTimesLayer.lua中
            if item.id == 36 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_USE_BATTLE_TOKEN_TIPS", {num = self._useCount}))
            end
        end
    end
	self:animationToClose()
end


return BagUseItemMultiTimesLayer