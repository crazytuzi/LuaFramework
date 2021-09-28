--LegionOrderListLayer.lua


local LegionOrderListLayer = class("LegionOrderListLayer", UFCCSModelLayer)


function LegionOrderListLayer.show( ... )
	local legionLayer = LegionOrderListLayer.new("ui_layout/legion_DungeonOrderList.json", Colors.modelColor)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionOrderListLayer:ctor( ... )
	self._levelRankList = nil 
	self._dungeonRankList = nil 
	self._isShowLevelRank = true
	self.super.ctor(self, ...)
end

function LegionOrderListLayer:onLayerLoad( ... )
	self:addCheckBoxGroupItem(1, "CheckBox_level")
    self:addCheckBoxGroupItem(1, "CheckBox_dungeon")

	self:enableLabelStroke("Label_level_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_dungeon_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_rank_name", Colors.strokeBrown, 2 )

	self:addCheckNodeWithStatus("CheckBox_level", "Label_level_check", true)
    self:addCheckNodeWithStatus("CheckBox_level", "Label_level_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_dungeon", "Label_dungeon_check", true)
    --self:addCheckNodeWithStatus("CheckBox_dungeon", "Panel_dungeon", true)
    self:addCheckNodeWithStatus("CheckBox_dungeon", "Label_dungeon_uncheck", false)

    self:registerCheckboxEvent("CheckBox_level", handler(self, self._onLevelRankCheck))
	self:registerCheckboxEvent("CheckBox_dungeon", handler(self, self._onDungeonRankCheck))
	
	self:registerBtnClickEvent("Button_TopClose", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("closebtn", handler(self, self._onCancelClick))

	G_Me.legionData:clearCorpList()
	self:setCheckStatus(1, "CheckBox_level")

	self:showWidgetByName("Panel_dungeon", false)
end

function LegionOrderListLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)

	G_HandlersManager.legionHandler:sendGetCorpList(1, 20)
	G_HandlersManager.legionHandler:sendGetNewCorpChapterRank()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_LIST, self._onSwitchLevelRank, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_GET_CORP_CHAPER_RANK, self._onSwitchDungeonRank, self)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("bg"), "smoving_bounce")
end

function LegionOrderListLayer:_onCancelClick( ... )
	self:animationToClose()
end

function LegionOrderListLayer:_onLevelRankCheck( ... )
	self._isShowLevelRank  = true
	self:_onSwitchLevelRank()
end

function LegionOrderListLayer:_onDungeonRankCheck( ... )
	self._isShowLevelRank  = false
	self:_onSwitchDungeonRank()
end

function LegionOrderListLayer:_onSwitchLevelRank( ... )
	if not self._isShowLevelRank then 
		return
	end

	local count = G_Me.legionData:getCorpLength()
	self:showWidgetByName("Label_tip", count < 1)
	if count < 1 then 
		return 
	end

	if not self._levelRankList  then 		
		self:_onCreateLevelRankList()
		self._levelRankList:reloadWithLength(count, self._levelRankList:getShowStart(), 0.2)
	end


	local myRank = G_Me.legionData:getMyCorpLevelRankIndex()
	self:showWidgetByName("BitmapLabel_rank_value", myRank > 0)
	self:showWidgetByName("Label_rank_value", myRank < 1)
	if myRank > 0 then
			local rankLabel = self:getLabelBMFontByName("BitmapLabel_rank_value")
			if rankLabel then
				rankLabel:setText(myRank > 0 and myRank or 0)
			end
	else
		self:showTextWithLabel("Label_rank_value", G_lang:get("LANG_LEGION_RANK_NUMBER_NULL"))	
	end
end

function LegionOrderListLayer:_onSwitchDungeonRank( ... )
	if self._isShowLevelRank then 
		return 
	end

	local count = G_Me.legionData:getCorpChapterRankCount()
	self:showWidgetByName("Label_tip", count < 1)
	if count < 1 then 
		return 
	end

	if not self._dungeonRankList then 
		self:_onCreateDungeonRankList()
		self._dungeonRankList:reloadWithLength(count, 0, 0.2)
	end

	local myRank = G_Me.legionData:getMyCorpDungeonRankIndex()
	self:showWidgetByName("BitmapLabel_rank_value", myRank > 0)
	self:showWidgetByName("Label_rank_value", myRank < 1)
	if myRank > 0 then
			local rankLabel = self:getLabelBMFontByName("BitmapLabel_rank_value")
			if rankLabel then
				rankLabel:setText(myRank > 0 and myRank or 0)
			end
	else
		self:showTextWithLabel("Label_rank_value", G_lang:get("LANG_LEGION_RANK_NUMBER_NULL"))	
	end
	--self:showTextWithLabel("Label_rank_value", myRank > 0 and myRank or G_lang:get("LANG_LEGION_RANK_NUMBER_NULL")) 
end

function LegionOrderListLayer:_onCreateLevelRankList( ... )
	if not self._levelRankList then
		local panel = self:getPanelByName("level_ranklist")
		if panel == nil then
			return 
		end

		self._levelRankList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self:addCheckNodeWithStatus("CheckBox_level", "level_ranklist", true)
    	self._levelRankList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionOrderItem").new(list, index)
    	end)
    	self._levelRankList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			local corpInfo =  G_Me.legionData:getCorpByIndex(index + 1)
    			cell:updateItem(corpInfo, index + 1, self._isShowLevelRank)
    		end
    	end)    
	end
end

function LegionOrderListLayer:_onCreateDungeonRankList( ... )
	if not self._dungeonRankList then
		local panel = self:getPanelByName("dungeon_ranklist")
		if panel == nil then
			return 
		end

		self._dungeonRankList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self:addCheckNodeWithStatus("CheckBox_dungeon", "dungeon_ranklist", true)
    	self._dungeonRankList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.LegionOrderItem").new(list, index)
    	end)
    	self._dungeonRankList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			local corpInfo = G_Me.legionData:getCorpChapterRankByIndex(index + 1)
    			cell:updateItem(corpInfo, index + 1, self._isShowLevelRank)
    		end
    	end)    
	end
end
return LegionOrderListLayer
