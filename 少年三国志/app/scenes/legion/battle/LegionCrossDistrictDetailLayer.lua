--LegionCrossDistrictDetailLayer.lua



local LegionCrossDistrictDetailLayer = class("LegionCrossDistrictDetailLayer", UFCCSModelLayer)

function LegionCrossDistrictDetailLayer.show( ... )
	local legionLayer = LegionCrossDistrictDetailLayer.new("ui_layout/legion_CrossDistrictDetail.json", Colors.modelColor)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionCrossDistrictDetailLayer:ctor( ... )
	self._legionList = nil
	self.super.ctor(self, ...)
end

function LegionCrossDistrictDetailLayer:onLayerLoad( ... )
	self:registerBtnClickEvent("Button_TopClose", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("closebtn", handler(self, self._onCancelClick))

	G_HandlersManager.legionHandler:sendGetCrossBattleField()

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_FIELD, self._onRefreshBettleFieldInfo, self)
end

function LegionCrossDistrictDetailLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("bg"), "smoving_bounce")

	self:_initLegionList()
end

function LegionCrossDistrictDetailLayer:_onCancelClick( ... )
	self:animationToClose()
end

function LegionCrossDistrictDetailLayer:_initLegionList( ... )
	if not self._legionList then 
		local panel = self:getPanelByName("legion_list")
		if panel == nil then
			return 
		end

		self._legionList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._legionList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.battle.LegionCrossDistrictItem").new(list, index)
    	end)
    	self._legionList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1)
    		end
    	end)
    	self._legionList:setSelectCellHandler(function ( cell, index )
    	end)
	end
	self._legionList:reloadWithLength(G_Me.legionData:getBattleFieldCount())

	self:showWidgetByName("Label_no_apply_tip", G_Me.legionData:getCorpApplyLength() < 1)

end

function LegionCrossDistrictDetailLayer:_onRefreshBettleFieldInfo( ... )
	self:_initLegionList()
end


return LegionCrossDistrictDetailLayer
