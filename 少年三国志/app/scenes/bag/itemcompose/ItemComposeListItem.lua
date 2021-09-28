-- 道具合成列表条目

local ItemComposeListItem = class("ItemComposeListItem", function (  )
	return CCSItemCellBase:create("ui_layout/bag_ItemComposeListItem.json")
end)

require "app.cfg.compose_info"
require "app.cfg.item_info"
local EffectNode = require "app.common.effects.EffectNode"

function ItemComposeListItem:ctor( composeType )
	__Log("ItemComposeListItem:ctor")

	self._composeType = composeType 
	self._composeInfo = nil
	self._canComposeNum = 0
	self._totalCostMoney = 0
	self._effectLight = nil
	self._targetItemInfo = nil

	-- self._composeInfoList = {}

	-- for i=1, compose_info.getLength() do
	-- 	local composeInfo = compose_info.indexOf(i)
	-- 	if composeInfo and composeInfo.item_type == composeType then
	-- 		table.insert(self._composeInfoList, composeInfo)
	-- 	end
	-- end

	self:_initWidgets()

	self:registerBtnClickEvent("Button_Compose", function (  )
		self:_composeItem()
	end)
	self:registerBtnClickEvent("Button_Target_Item", function (  )
		self:_showTargetItemInfo()
	end)
	self:registerBtnClickEvent("Button_Source_Item", function (  )
		self:_showSourceItemInfo()
	end)
end

function ItemComposeListItem:_initWidgets(  )
	self._targetItemNameLabel = self:getLabelByName("Label_Target_Item_Name")
	self._sourceItemNameLabel = self:getLabelByName("Label_Source_Item_Name")

	self._targetItemCurrentNumLabel = self:getLabelByName("Label_Target_Item_Current_Num")
	-- TODO: delete this label
	self:showWidgetByName("Label_Target_Item_Current_Num", false)
	self._sourceItemCurrentNumLabel = self:getLabelByName("Label_Source_Item_Num")
	self._sourceItemCostPerComposeNumLabel = self:getLabelByName("Label_Source_Item_Cost_Num")
	self._canComposeNumLabel = self:getLabelByName("Label_Can_Compose_Num")
	self._totalCostMoneyLabel = self:getLabelByName("Label_Total_Cost")

	self._canComposeNumLabel:createStroke(Colors.strokeBrown, 1)
	self._targetItemCurrentNumLabel:createStroke(Colors.strokeBrown, 1)
	self._sourceItemCurrentNumLabel:createStroke(Colors.strokeBrown, 1)
	self._sourceItemCostPerComposeNumLabel:createStroke(Colors.strokeBrown, 1)

	self._targetItemImg = self:getImageViewByName("ImageView_Target_Item")
	self._targetItemQualityBorderImg = self:getImageViewByName("ImageView_Target_Item_Bg")
    self._targetItemButton = self:getButtonByName("Button_Target_Item")

    self._sourceItemImg = self:getImageViewByName("ImageView_Source_Item")
	self._sourceItemQualityBorderImg = self:getImageViewByName("ImageView_Source_Item_Bg")
    self._sourceItemButton = self:getButtonByName("Button_Source_Item")

    -- 添加特效
    if not self._effectLight then
		self._effectLight = EffectNode.new("effect_around1")
		self._targetItemQualityBorderImg:addNode(self._effectLight, 1)
		self._effectLight:setPositionXY(3, -3)
		self._effectLight:setScale(1.6)
		self._effectLight:play()
	end

    self._imageMoney = self:getImageViewByName("Image_Money")
end

function ItemComposeListItem:updateCell( composeInfo )
	-- local composeInfo = self._composeInfoList[index + 1]
	self._composeInfo = composeInfo

	if composeInfo then
		-- 目标道具名称
		self._targetItemNameLabel:setText(composeInfo.name)

		-- 目标道具当前总数
		local targetCurrNum = G_Me.bagData:getItemCount(composeInfo.item_id)
		self._targetItemCurrentNumLabel:setText(targetCurrNum)

		local targetItemInfo = item_info.get(composeInfo.item_id)
		local sourceItemInfo = item_info.get(composeInfo.son_id)
		self._targetItemInfo = targetItemInfo
		-- 源道具名称
		self._sourceItemNameLabel:setText(sourceItemInfo.name)

		-- 源道具当前总数/合成一个需要的个数
		local sourceCurrNum = G_Me.bagData:getItemCount(composeInfo.son_id)
		-- 每合成一个目标道具所需的源道具数量
		local sourceCostNum = composeInfo.son_size
		assert(sourceCostNum > 0 ,"sourceCostNum is zero or negative")
		self._sourceItemCurrentNumLabel:setText(sourceCurrNum)
		self._sourceItemCostPerComposeNumLabel:setText("/" .. sourceCostNum)	
		if sourceCurrNum < sourceCostNum then
			self._sourceItemCurrentNumLabel:setColor(Colors.qualityColors[6])
		else
			self._sourceItemCurrentNumLabel:setColor(Colors.darkColors.DESCRIPTION)
		end			

		-- 当前拥有的源道具可以合成多少个目标道具
		self._canComposeNum = math.floor(sourceCurrNum / sourceCostNum)
		self._canComposeNumLabel:setText(G_lang:get("LANG_ITEM_COMPOSE_CAN_COMPOSE_COUNT", {num = self._canComposeNum}))

		-- 后来加了最大合成个数限制
		self._canComposeNum = math.min(self._canComposeNum, composeInfo.max_compose)

		-- 总共需要消耗多少银两
		self._totalCostMoney = math.min(self._canComposeNum * composeInfo.compose_cost, composeInfo.max_cost)
		self._totalCostMoneyLabel:setText(self._totalCostMoney)
		self._totalCostMoneyLabel:setVisible(self._totalCostMoney > 0)
		self._totalCostMoneyLabel:setColor(G_Me.userData.money >= self._totalCostMoney and Colors.lightColors.DESCRIPTION or Colors.qualityColors[6])
		self._imageMoney:setVisible(self._totalCostMoney > 0)

		-- 目标道具图标
		self._targetItemImg:loadTexture(G_Path.getItemIcon(targetItemInfo.res_id), UI_TEX_TYPE_LOCAL)
		self._targetItemQualityBorderImg:loadTexture(G_Path.getEquipIconBack(targetItemInfo.quality))
    	self._targetItemButton:loadTextureNormal(G_Path.getEquipColorImage(targetItemInfo.quality,G_Goods.TYPE_ITEM))
    	self._targetItemButton:loadTexturePressed(G_Path.getEquipColorImage(targetItemInfo.quality,G_Goods.TYPE_ITEM))

    	-- 源道具图标
		self._sourceItemImg:loadTexture(G_Path.getItemIcon(sourceItemInfo.res_id), UI_TEX_TYPE_LOCAL)
		self._sourceItemQualityBorderImg:loadTexture(G_Path.getEquipIconBack(sourceItemInfo.quality))
    	self._sourceItemButton:loadTextureNormal(G_Path.getEquipColorImage(sourceItemInfo.quality,G_Goods.TYPE_ITEM))
    	self._sourceItemButton:loadTexturePressed(G_Path.getEquipColorImage(sourceItemInfo.quality,G_Goods.TYPE_ITEM))

    	-- 如果合成条件不满足则不显示特效
    	if self._effectLight and (self._canComposeNum <= 0 or (self._totalCostMoney > G_Me.userData.money)) then
    		self._effectLight:removeFromParent()
    		self._effectLight = nil
    	end
	end
end


function ItemComposeListItem:_composeItem(  )
	-- TEST PROTOCAL
	-- dump(self._composeInfo)
	-- G_HandlersManager.bagHandler:sendItemCompose(self._composeInfo.id)

    ---[[
	if (self._composeInfo and G_Me.userData.level >= self._composeInfo.compose_level
			and self._canComposeNum > 0 and G_Me.userData.money >= self._totalCostMoney) then
		-- G_HandlersManager.bagHandler:sendItemCompose(self._composeInfo.id)
		require("app.scenes.bag.itemcompose.ItemComposeConfirmLayer").show(self._targetItemInfo, self._canComposeNum, self._totalCostMoney, self._composeInfo.id)
	elseif self._canComposeNum <= 0 then
		-- 这里传 _ 作为参数为解决pc上正常，设备上却出错的问题
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, self._composeInfo.son_id,
    			GlobalFunc.sceneToPack("app.scenes.bag.itemcompose.ItemComposeScene", {_, _, self._composeType}))
	elseif G_Me.userData.money < self._totalCostMoney then
		-- 这里传 _ 作为参数为解决pc上正常，设备上却出错的问题
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
    			GlobalFunc.sceneToPack("app.scenes.bag.itemcompose.ItemComposeScene", {_, _, self._composeType}))
	end
    --]]
end


function ItemComposeListItem:_showTargetItemInfo(  )
	if self._composeInfo then
		require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_ITEM, self._composeInfo.item_id) 
	end
end


function ItemComposeListItem:_showSourceItemInfo(  )
	if self._composeInfo then
		require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_ITEM, self._composeInfo.son_id) 
	end
end






return ItemComposeListItem