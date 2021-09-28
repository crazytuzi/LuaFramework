--LegionCrossChooseAimLayer.lua


local LegionCrossChooseAimLayer = class("LegionCrossChooseAimLayer", UFCCSModelLayer)

function LegionCrossChooseAimLayer.show( ... )
	local legionLayer = LegionCrossChooseAimLayer.new("ui_layout/legion_CrossChooseAim.json", Colors.modelColor)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionCrossChooseAimLayer:ctor( ... )
	self._legionList = nil
	self.super.ctor(self, ...)
end

function LegionCrossChooseAimLayer:onLayerLoad( ... )
	self:registerBtnClickEvent("Button_close", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_close_1", handler(self, self._onCancelClick))

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_SET_BATTLE_FIRE_ON, self._onChangeFireCorp, self)	
end

function LegionCrossChooseAimLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")

	self:_initLegionList()
end

function LegionCrossChooseAimLayer:_onCancelClick( ... )
	self:animationToClose()
end

function LegionCrossChooseAimLayer:_onChangeFireCorp( ... )
	if self._legionList then 
		self._legionList:refreshAllCell()
	end
end

function LegionCrossChooseAimLayer:_initLegionList( ... )
	if not self._legionList then 
		local panel = self:getPanelByName("Panel_list")
		if panel == nil then
			return 
		end

		self._legionList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._legionList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.battle.LegionCrossChooseAimItem").new(list, index)
    	end)
    	self._legionList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 2)
    		end
    	end)
    	self._legionList:setSelectCellHandler(function ( cell, index )
    	end)
	end
	local fieldCount = G_Me.legionData:getBattleFieldCount()
	self._legionList:reloadWithLength(fieldCount > 0 and (fieldCount - 1) or 0)

	self:showWidgetByName("Label_no_apply_tip", G_Me.legionData:getCorpApplyLength() < 1)

end


return LegionCrossChooseAimLayer

