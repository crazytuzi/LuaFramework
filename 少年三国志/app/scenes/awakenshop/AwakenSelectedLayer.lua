local FunctionLevelConst = require "app.const.FunctionLevelConst"
local BagConst = require("app.const.BagConst")
local AwakenSelectedLayer = class("AwakenSelectedLayer", UFCCSModelLayer)

function AwakenSelectedLayer.create(...)
	return AwakenSelectedLayer.new("ui_layout/awaken_SelectedItemsLayer.json", Colors.modelColor, ...)
end

function AwakenSelectedLayer:ctor(json, param, ...)
	self._itemsListView = nil
	self._itemsListData = G_Me.shopData:getAwakenTags()
	self._noItemsLabel = self:getLabelByName("Label_noItems")
	self._labelNum = self:getLabelByName("Label_num")
	self._labelText = self:getLabelByName("Label_text")
	self.super.ctor(self, json, param, ...)
	self:_updateLabels()

end

function AwakenSelectedLayer:_updateLabels()

	if self._itemsListData and #self._itemsListData > 0 then 
		self._noItemsLabel:setVisible(false)
	else 
		self._noItemsLabel:setVisible(true)
		self._noItemsLabel:setText(G_lang:get("LANG_NO_ITEM_TAGS"))
	end
	self._labelNum:setText(tostring(#self._itemsListData) .. "/" .. tostring(BagConst.AWAKEN_ITEM_MAXTAG))
	if #self._itemsListData >= BagConst.AWAKEN_ITEM_MAXTAG then 
		self._labelNum:setColor(ccc3(0xf2, 0x79, 0x0d))
		self._labelText:setColor(ccc3(0xf2, 0x79, 0x0d))
	else
		self._labelNum:setColor(ccc3(0xe1, 0xb2, 0x7c))
		self._labelText:setColor(ccc3(0xe1, 0xb2, 0x7c))
	end 
end 

function AwakenSelectedLayer:_updateData()
	self._itemsListData = G_Me.shopData:getAwakenTags()
	self:_updateLabels()
	self._itemsListView:reloadWithLength(#self._itemsListData,self._itemsListView:getShowStart()) 
end 

function AwakenSelectedLayer:onLayerEnter()
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DelShopTag, self._updateData , self)

	self:showAtCenter(true)
	self:closeAtReturn(true)
	
	self:_initWidgets()
	self:_initItemsListView()
end

function AwakenSelectedLayer:_initWidgets()
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseWindow))
    self:registerBtnClickEvent("Button_Close2", handler(self, self._onCloseWindow))
end

function AwakenSelectedLayer:_onCloseWindow()
	self:animationToClose()
end

function AwakenSelectedLayer:_initItemsListView()

	if not self._itemsListView then
		local panel = self:getPanelByName("Panel_ListView_Items")
		self._itemsListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._itemsListView:setCreateCellHandler(function(list, index)
			return require("app.scenes.awakenshop.AwakenSelectedItem").new()
		end)

		self._itemsListView:setUpdateCellHandler(function(list, index, cell)

			local itemData = self._itemsListData[index+1]
			cell:updateItem(itemData)
			cell:registerBtnClickEvent("Button_delete",function() 
		        G_HandlersManager.awakenShopHandler:sendDelShopTag(itemData.id)
    		end)
		end)

	end
	self._itemsListView:reloadWithLength(#self._itemsListData )
end

return AwakenSelectedLayer