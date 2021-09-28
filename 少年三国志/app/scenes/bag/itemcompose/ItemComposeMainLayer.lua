-- 道具合成

local ItemComposeMainLayer = class("ItemComposeMainLayer", UFCCSNormalLayer)

require "app.cfg.compose_info"
local FunctionLevelConst = require("app.const.FunctionLevelConst")

local COMPOSE_ITEM_TYPE_EQUIP_REFINE = 11
local COMPOSE_ITEM_TYPE_PET_FOOD	 = 26
local COMPOSE_ITEM_TYPE_PET_REFINE	 = 27

function ItemComposeMainLayer.create(composeType, packScene )
	return ItemComposeMainLayer.new("ui_layout/bag_ItemComposeMainLayer.json", nil, composeType, packScene)
end


function ItemComposeMainLayer:ctor( json, func, composeType, packScene )
	
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._checkedCallback, self._uncheckedCallback)

	self._composeType = composeType or COMPOSE_ITEM_TYPE_EQUIP_REFINE

	self._equipRefineItemListView = nil
	self._petFoodItemListView = nil
	self._petRefineItemListView = nil

	self._equipRefineInfoNum = 0
	self._petFoodInfoNum = 0
	self._petRefineInfoNum = 0

	self._equipRefineComposeInfoList = {}
	self._petFoodComposeInfoList = {}
	self._petRefineComposeInfoList = {}

	for i=1, compose_info.getLength() do
		local composeInfo = compose_info.indexOf(i)
		if composeInfo and composeInfo.item_type == COMPOSE_ITEM_TYPE_EQUIP_REFINE then
			table.insert(self._equipRefineComposeInfoList, composeInfo)
		elseif composeInfo and composeInfo.item_type == COMPOSE_ITEM_TYPE_PET_FOOD then
			table.insert(self._petFoodComposeInfoList, composeInfo)
		else
			table.insert(self._petRefineComposeInfoList, composeInfo)
		end
	end

	GlobalFunc.savePack(self, packScene)

	self.super.ctor(self, json)
end

function ItemComposeMainLayer:onLayerLoad( ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ITEM_COMPOSE_RESULT, self._onComposeResult, self)
end

function ItemComposeMainLayer:onLayerEnter( ... )
	self:registerKeypadEvent(true)
	self:registerBtnClickEvent("Button_Back", function (  )
		self:_onBackClicked()
	end)

	self:_initTabs()
end


function ItemComposeMainLayer:onLayerExit( ... )
	-- body
end

function ItemComposeMainLayer:_initTabs( ... )
	self._tabs:add("CheckBox_Equip_Refine_Item", self:getPanelByName("Panel_Equip_Refine_Item"), "Label_Equip_Refine_Tag")
	self._tabs:add("CheckBox_Pet_Food_Item", self:getPanelByName("Panel_Pet_Food_Item"), "Label_Pet_Food_Tag")
	self._tabs:add("CheckBox_Pet_Refine_Item", self:getPanelByName("Panel_Pet_Refine_Item"), "Label_Pet_Refine_Tag")

	if self._composeType == COMPOSE_ITEM_TYPE_PET_FOOD then
		self._tabs:checked("CheckBox_Pet_Food_Item")
	elseif self._composeType == COMPOSE_ITEM_TYPE_PET_REFINE then
		self._tabs:checked("CheckBox_Pet_Refine_Item")
	else		
		self._tabs:checked("CheckBox_Equip_Refine_Item")
	end

	self:showWidgetByName("CheckBox_Pet_Food_Item", G_moduleUnlock:isModuleUnlock(FunctionLevelConst.PET))
	self:showWidgetByName("CheckBox_Pet_Refine_Item", G_moduleUnlock:isModuleUnlock(FunctionLevelConst.PET))
end

function ItemComposeMainLayer:_resetEquipRefineItemListView( ... )
	if not self._equipRefineItemListView then

		for i=1, compose_info.getLength() do
			local composeInfo = compose_info.indexOf(i)
			if composeInfo and composeInfo.item_type == COMPOSE_ITEM_TYPE_EQUIP_REFINE then
				self._equipRefineInfoNum = self._equipRefineInfoNum + 1
			end
		end

		self._equipRefineItemListView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_Equip_Refine_Item_List"), LISTVIEW_DIR_VERTICAL)
		self._equipRefineItemListView:setCreateCellHandler(function ( list, index )
			return require("app.scenes.bag.itemcompose.ItemComposeListItem").new(COMPOSE_ITEM_TYPE_EQUIP_REFINE)
		end)
		self._equipRefineItemListView:setUpdateCellHandler(function ( list, index, cell )
			cell:updateCell(self._equipRefineComposeInfoList[index + 1])
		end)

		-- self._equipRefineItemListView:initChildWithDataLength(self._equipRefineInfoNum)
	end

	self._equipRefineItemListView:reloadWithLength(self._equipRefineInfoNum)
end

function ItemComposeMainLayer:_resetPetFoodItemListView( ... )
	if not self._petFoodItemListView then

		for i=1, compose_info.getLength() do
			local composeInfo = compose_info.indexOf(i)
			if composeInfo and composeInfo.item_type == COMPOSE_ITEM_TYPE_PET_FOOD then
				self._petFoodInfoNum = self._petFoodInfoNum + 1
			end
		end

		self._petFoodItemListView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_Pet_Food_Item_List"), LISTVIEW_DIR_VERTICAL)
		self._petFoodItemListView:setCreateCellHandler(function ( list, index )
			return require("app.scenes.bag.itemcompose.ItemComposeListItem").new(COMPOSE_ITEM_TYPE_PET_FOOD)
		end)
		self._petFoodItemListView:setUpdateCellHandler(function ( list, index, cell )
			cell:updateCell(self._petFoodComposeInfoList[index + 1])
		end)

		-- self._petFoodItemListView:initChildWithDataLength(self._petFoodInfoNum)
	end

	self._petFoodItemListView:reloadWithLength(self._petFoodInfoNum)
end

function ItemComposeMainLayer:_resetPetRefineItemListView( ... )
	if not self._petRefineItemListView then

		for i=1, compose_info.getLength() do
			local composeInfo = compose_info.indexOf(i)
			if composeInfo and composeInfo.item_type == COMPOSE_ITEM_TYPE_PET_REFINE then
				self._petRefineInfoNum = self._petRefineInfoNum + 1
			end
		end

		self._petRefineItemListView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_Pet_Refine_Item_List"), LISTVIEW_DIR_VERTICAL)
		self._petRefineItemListView:setCreateCellHandler(function ( list, index )
			return require("app.scenes.bag.itemcompose.ItemComposeListItem").new(COMPOSE_ITEM_TYPE_PET_REFINE)
		end)
		self._petRefineItemListView:setUpdateCellHandler(function ( list, index, cell )
			cell:updateCell(self._petRefineComposeInfoList[index + 1])
		end)

		-- self._petRefineItemListView:initChildWithDataLength(self._petRefineInfoNum)
	end

	self._petRefineItemListView:reloadWithLength(self._petRefineInfoNum)
end

function ItemComposeMainLayer:_checkedCallback( btnName )
	__Log("checked " .. btnName)
	if btnName == "CheckBox_Equip_Refine_Item" then
		self:_resetEquipRefineItemListView()
	elseif btnName == "CheckBox_Pet_Food_Item" then
		self:_resetPetFoodItemListView()
	elseif btnName == "CheckBox_Pet_Refine_Item" then
		self:_resetPetRefineItemListView()
	end
end

function ItemComposeMainLayer:_uncheckedCallback( btnName )
	-- body
end

function ItemComposeMainLayer:_onComposeResult( data )
	if rawget(data, "index") then
		local composeInfoId = data.index
		local composeInfo = compose_info.get(composeInfoId)

		if composeInfo.item_type == COMPOSE_ITEM_TYPE_EQUIP_REFINE then
			self:_resetEquipRefineItemListView()
		elseif composeInfo.item_type == COMPOSE_ITEM_TYPE_PET_FOOD then
			self:_resetPetFoodItemListView()
		elseif composeInfo.item_type == COMPOSE_ITEM_TYPE_PET_REFINE then
			self:_resetPetRefineItemListView()
		end
	end

	if rawget(data, "item") then
		local composedItem = data.item

		local tips = G_lang:get("LANG_ITEM_COMPOSE_RESULT_TIPS")
		local itemPopupLayer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(composedItem, nil, tips)
        uf_sceneManager:getCurScene():addChild(itemPopupLayer)
	end
end

function ItemComposeMainLayer:onBackKeyEvent(  )
	self:_onBackClicked()
	return true
end

function ItemComposeMainLayer:_onBackClicked(  )
	__Log("ItemComposeMainLayer:_onBackClicked")
	local packScene = G_GlobalFunc.createPackScene(self)
	if not packScene then
		packScene = require("app.scenes.bag.BagScene").new()
	end	
	uf_sceneManager:replaceScene(packScene)
end

return ItemComposeMainLayer