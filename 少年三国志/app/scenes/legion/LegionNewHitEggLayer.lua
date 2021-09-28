--LegionNewHitEggLayer.lua
require("app.cfg.corps_dungeon_info")
require("app.cfg.corps_dungeon_award_info")

local LegionNewHitEggLayer = class("LegionNewHitEggLayer", UFCCSNormalLayer)

function LegionNewHitEggLayer.create( ... )
	return LegionNewHitEggLayer.new("ui_layout/legion_DungeonNewHitEgg.json",...)
end

function LegionNewHitEggLayer:ctor( ... )
	self._eggItemList = nil
	self._normalText = {}
	self._hitEggText = {}
	self._dugeonId = 0
	self._timeLabel = self:getLabelByName("Label_time")
	self._timeTitleLabel = self:getLabelByName("Label_time_title")
	self._tipsLabel = self:getLabelByName("Label_tips")

	self.super.ctor(self, ...)
end

function LegionNewHitEggLayer:onLayerLoad(_, chapterIndex )
	
	self._chapterIndex = chapterIndex
	self:initTabs()
	self:enableLabelStroke("Label_time", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_time_title", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_title1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_title2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_title3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_title4", Colors.strokeBrown, 1 )
	-- self:showTextWithLabel("Label_time_title", G_lang:get("LANG_NEW_LEGION_TIME_TITLE"))

	self:registerBtnClickEvent("Button_return", function ( )
		if CCDirector:sharedDirector():getSceneCount() > 1 then 
			uf_sceneManager:popScene()
		else
			uf_sceneManager:replaceScene(require("app.scenes.legion.LegionNewMapScene").new())
		end
	end)
	self:registerBtnClickEvent("Button_preview", function ( )
		require("app.scenes.legion.LegionNewTreasurePreviewLayer").show(self._chapterIndex)
	end)

end

function LegionNewHitEggLayer:onLayerEnter( ... )
	self:callAfterFrameCount(1, function ( ... )
		-- self:adapterWidgetHeight("Panel_content", "", "", 0, 0)
		self:adapterWidgetHeight("Panel_bottom", "Panel_top", "", 76, -50)
		self:adapterWidgetHeight("Panel_egg_list", "Panel_top", "", 15, 0)
		self:_initEggList()
		
	end)	

	self:_initCountDonwTime()

	-- local array = CCArray:create()
 --    array:addObject(CCRotateTo:create(100,180))
 --    array:addObject(CCRotateTo:create(100,360))
 --    self:getImageViewByName("Image_22"):runAction(CCRepeatForever:create(CCSequence:create(array)))
 uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_DUNGEON_AWARD_LIST, self._onAwardListUpdate, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_DUNGEON_AWARD, self._onGetDungeonAward, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_FLUSH_NEW_DUNGEON_AWARD, self._onFlushDungeonAward, self)
 	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
        G_HandlersManager.legionHandler:disposeCorpDismiss(dismiss)
    end, self)

end

-- function LegionNewHitEggLayer:updateView( chapterIndex)
-- 	self._chapterIndex = chapterIndex
-- end

function LegionNewHitEggLayer:onLayerExit( ... )
	
	self:_removeTimer()
end

function LegionNewHitEggLayer:_initCountDonwTime( ... )
	self._countDownTime = G_Me.legionData:getAwardEndTime()
	local _updateTime = function ( ... )
		if self._countDownTime < 0 then 
			self._countDownTime = 0
			self:_onCountDownFinish()
		end
		local hour = math.floor(self._countDownTime/3600)
		local min = math.floor((self._countDownTime%3600)/60)
		local sec = self._countDownTime%60
		self:showTextWithLabel("Label_time",
			 string.format(G_lang:get("LANG_NEW_LEGION_FIGHT_REVERSE_FORMAT"), hour, min, sec))
		
		self._countDownTime = self._countDownTime -1	
	end
	_updateTime()
	if not self._timer then 
		self._timer = G_GlobalFunc.addTimer(1,function()
			if _updateTime then 
				_updateTime()
			end
		end)
	end
end

function LegionNewHitEggLayer:_onCountDownFinish( ... )
	self:_removeTimer()
	uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
end

function LegionNewHitEggLayer:_removeTimer( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        		self._timer = nil
	end
end

function LegionNewHitEggLayer:initTabs( )
	self._tabs = require("app.common.tools.Tabs").new(1, self, self.onCheckCallback)
	self._tabs:add("CheckBox_team1")
	self._tabs:add("CheckBox_team2")
	self._tabs:add("CheckBox_team3")
	self._tabs:add("CheckBox_team4")

	local info = corps_dungeon_chapter_info.get(self._chapterIndex)
	self._tabList = {CheckBox_team1=info.dungeon_1,CheckBox_team2=info.dungeon_2,CheckBox_team3=info.dungeon_3,CheckBox_team4=info.dungeon_4}
	self._tabs:checked("CheckBox_team1")
end

function LegionNewHitEggLayer:updateCheckBox( index )
	local enemyImg = self:getImageViewByName("Image_enemy"..index)
	local barBg = self:getImageViewByName("Image_barBg"..index)
	local bar = self:getLoadingBarByName("ProgressBar_hp"..index)
	local titleLabel = self:getLabelByName("Label_title"..index)
	local stateImg = self:getImageViewByName("Image_state"..index)
	local awardImg = self:getImageViewByName("Image_award"..index)
	local boardImg = self:getImageViewByName("Image_board"..index)
	local itemImg = self:getImageViewByName("Image_item"..index)

	local dungeonId = self._tabList["CheckBox_team"..index]
	local info = G_Me.legionData:getNewDungeonInfo(dungeonId)
	local dungeonInfo = corps_dungeon_info.get(dungeonId)
	if not G_Me.legionData:haveNewFinishDungeon(dungeonId) or not G_Me.legionData:getNewDungeonAwardCanGet(dungeonId) then
		barBg:setVisible(true)
		local progress = info.max_hp > 0 and (info.hp*100)/info.max_hp or 0
		bar:setPercent(progress)
		local iconPath = G_Path.getLegionDungeonMiniIcon(dungeonInfo.image)
		enemyImg:loadTexture(iconPath, UI_TEX_TYPE_LOCAL)
		titleLabel:setText(dungeonInfo.dungeon_name_1)
		stateImg:setVisible(false)
		awardImg:setVisible(false)
	elseif G_Me.legionData:getNewDungeonAwardHasGet(dungeonId) then
		barBg:setVisible(false)
		local iconPath = G_Path.getLegionDungeonMiniIcon(5)
		enemyImg:loadTexture(iconPath, UI_TEX_TYPE_LOCAL)
		titleLabel:setText(dungeonInfo.dungeon_name_1)
		-- stateImg:setVisible(true)
		-- stateImg:loadTexture("ui/text/txt/jt_yilingjiang.png")
		stateImg:setVisible(false)
		awardImg:setVisible(true)
		local awardId = G_Me.legionData:getNewDungeonMyAward(dungeonId)
		local awardInfo =  corps_dungeon_award_info.get(awardId)
		local g = G_Goods.convert(awardInfo.item_type, awardInfo.item_value, awardInfo.item_size)
		itemImg:loadTexture(g.icon, UI_TEX_TYPE_LOCAL)
		boardImg:loadTexture(G_Path.getAddtionKnightColorImage(g.quality))
	else
		barBg:setVisible(false)
		local iconPath = G_Path.getLegionDungeonMiniIcon(4)
		enemyImg:loadTexture(iconPath, UI_TEX_TYPE_LOCAL)
		titleLabel:setText(dungeonInfo.dungeon_name_1)
		stateImg:setVisible(true)
		stateImg:loadTexture("ui/text/txt/jt_kelingjiang.png")
		awardImg:setVisible(false)
	end
end

function LegionNewHitEggLayer:onCheckCallback( btnName )
	self._checkedId = self._tabList[btnName]
	local info = G_Me.legionData:getNewDungeonInfo(self._checkedId)
	if info then
		if not G_Me.legionData:haveNewFinishDungeon(self._checkedId) then
			self._timeLabel:setVisible(true)
			self._timeTitleLabel:setVisible(true)
			self._tipsLabel:setVisible(false)
			self._timeTitleLabel:setText(G_lang:get("LANG_NEW_LEGION_TIME_TITLE"))
		elseif G_Me.legionData:getNewDungeonAwardHasGet(self._checkedId) then
			self._timeLabel:setVisible(false)
			self._timeTitleLabel:setVisible(false)
			self._tipsLabel:setVisible(true)
			self._tipsLabel:setText(G_lang:get("LANG_NEW_LEGION_TIME_TIPS"))
		elseif G_Me.legionData:getNewDungeonAwardCanGet(self._checkedId) then
			self._timeLabel:setVisible(true)
			self._timeTitleLabel:setVisible(true)
			self._tipsLabel:setVisible(false)
			self._timeTitleLabel:setText(G_lang:get("LANG_NEW_LEGION_TIME_TITLE2"))
		else
			self._timeLabel:setVisible(false)
			self._timeTitleLabel:setVisible(false)
			self._tipsLabel:setVisible(true)
			self._tipsLabel:setText(G_lang:get("LANG_NEW_LEGION_TIME_TIPS2"))
		end
	end
	G_HandlersManager.legionHandler:sendGetNewDungeonAwardList(self._checkedId)
end

function LegionNewHitEggLayer:refreshTabs( ... )
	for i = 1 , 4 do 
		self:updateCheckBox(i)
	end
end

function LegionNewHitEggLayer:_onAwardListUpdate(data)
	self._eggItemList:reloadWithLength(16)
	self:refreshTabs()
end

function LegionNewHitEggLayer:_initEggList( ... )
	if not self._eggItemList then 
		local panel = self:getPanelByName("Panel_egg_list")
		if panel == nil then
			return 
		end

		self._eggItemList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	    	self._eggItemList:setCreateCellHandler(function ( list, index)
	    	    return require("app.scenes.legion.LegionNewHitEggItem").new(list, index)
	    	end)
	    	self._eggItemList:setUpdateCellHandler(function ( list, index, cell)
	    		if cell then 
	    			cell:updateItem(self._checkedId,index + 1)
	    		end
	    	end)
	    	self._eggItemList:setSpaceBorder(0, 140)
	end

    	self._eggItemList:reloadWithLength(16)
end

function LegionNewHitEggLayer:_onGetDungeonAward( ret, awards )

	if self._eggItemList then 
		self._eggItemList:refreshAllCell()
	end

	self:refreshTabs()

	local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards, function ( ... )
		
	end)
	self:addChild(_layer)
end

function LegionNewHitEggLayer:_onFlushDungeonAward( ... )
	if self._eggItemList then 
		self._eggItemList:refreshAllCell()
	end
end

return LegionNewHitEggLayer
