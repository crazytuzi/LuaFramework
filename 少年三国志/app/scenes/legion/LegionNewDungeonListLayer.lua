--LegionNewDungeonListLayer.lua

require("app.cfg.corps_dungeon_chapter_info")


local LegionNewDungeonListLayer = class("LegionNewDungeonListLayer", UFCCSNormalLayer)

LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT = 1140

function LegionNewDungeonListLayer.create( ... )
	return LegionNewDungeonListLayer.new("ui_layout/legion_DungeonNewLayerCopy.json")
end

function LegionNewDungeonListLayer:ctor( ... )
	self._dungeonList = nil
	self._curChapterIndex = 1
	self._validChapterCount = 1
	self.super.ctor(self, ...)
end

function LegionNewDungeonListLayer:onLayerLoad( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_progress_text", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_status", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_time", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_txt1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_txt2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_tips", Colors.strokeBrown, 1 )
	
	self:showTextWithLabel("Label_count_tip", G_lang:get("LANG_NEW_LEGION_FIGHT_MAX_FORMAT"))
	self:showTextWithLabel("Label_count_num", "")
	-- self:showTextWithLabel("Label_name", "")
	-- self:showTextWithLabel("Label_progress_text", "")

	self._timeLabel = self:getLabelByName("Label_time")
	self._txtLabel1 = self:getLabelByName("Label_txt1")
	self._txtLabel2 = self:getLabelByName("Label_txt2")
	self._timePanel = self:getPanelByName("Panel_time")
	
	self:registerBtnClickEvent("Button_return",function (  widget, param )
	    	if CCDirector:sharedDirector():getSceneCount() > 1 then 
			uf_sceneManager:popScene()
		else
			uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
		end
	end)
	self:registerBtnClickEvent("Button_help",function (  widget, param )
		require("app.scenes.common.CommonHelpLayer").show({
			{title=G_lang:get("LANG_NEW_LEGION_HELP_TITLE1"), content=G_lang:get("LANG_NEW_LEGION_HELP_CONTENT1")},
			{title=G_lang:get("LANG_NEW_LEGION_HELP_TITLE2"), content=G_lang:get("LANG_NEW_LEGION_HELP_CONTENT2")},})
		
	end)
	self:registerBtnClickEvent("Button_award",function (  widget, param )
		require("app.scenes.legion.LegionNewChapterRewardLayer").show()
	end)
	self:registerBtnClickEvent("Button_task",function (  widget, param )
		require("app.scenes.legion.LegionNewDamageRankLayer").show()
	end)
	self:registerBtnClickEvent("Button_add",function (  widget, param )
		self:_onAddFightCount()
	end)
	self:registerWidgetClickEvent("Image_count_back",function (  widget, param )
		self:_onAddFightCount()
	end)
	self:registerBtnClickEvent("Button_rollBack",function (  widget, param )
		require("app.scenes.legion.LegionNewRollBackChooseLayer").show()
	end)
	-- self:_initChapterBase()
end

function LegionNewDungeonListLayer:onLayerEnter( ... )
	self:_initCountDonwTime()
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_CORP_CHATER_INFO, self._onChapterUpdate, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RESET_NEW_DUNGEON_COUNT, self._onBuyFightCountRet, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_CHAPER_AWARD, self._onChapterUpdate, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        		G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    	end, self)
	    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
	        G_HandlersManager.legionHandler:disposeCorpDismiss(dismiss)
	    end, self)

	 G_HandlersManager.legionHandler:sendGetNewCorpChapter()

end

function LegionNewDungeonListLayer:_initDungeonList( ... )
	self._showChapterMax = self._curChapterIndex + 1
	self._validChapterCount  = self._showChapterMax - 1
	local cellMax = (self._showChapterMax % 4 ~= 0) and (self._showChapterMax/4 + 1) or self._showChapterMax/4
	cellMax = cellMax > 0 and cellMax or 1
	cellMax = math.floor(cellMax)
	__Log("_curChapterIndex:%d, showChapterMax:%d, cellMax:%d, validChapterCount:%d",
 		self._curChapterIndex, self._showChapterMax, cellMax, self._validChapterCount)

	self._cellMaxCount = cellMax
	if not self._dungeonList then 
		local listPanel = self:getPanelByName("Panel_dungeon_list")
		if listPanel then
			self._dungeonList = CCSListViewEx:createWithPanel(listPanel, LISTVIEW_DIR_VERTICAL)
			self._dungeonList:setCreateCellHandler(function ( list, index)
    	    	return require("app.scenes.legion.LegionNewDungeonItem").new(list, index)
    		end)
    		self._dungeonList:setUpdateCellHandler(function ( list, index, cell)
    			if cell and cell.updateItem then 
    				cell:updateItem(self._cellMaxCount - index - 1, self._curChapterIndex, self._showChapterMax - 1, corps_dungeon_chapter_info.getLength())
    			end
    		end)
    		self._dungeonList:setBouncedEnable(false)
		self._dungeonList:setClippingEnabled(false)
    		self._dungeonList:setSpaceBorder(0, 40) 
		end 
	end


    self._dungeonList:reloadWithLength(cellMax)
    local moveOffset = self:countMoveOffset()

	self._dungeonList:scrollToTopLeftCellIndex(0, moveOffset, 0, function() end)
	self._dungeonList:setScrollSpace(self:countScrollSpace(), 0)
	-- local cell = self._dungeonList:getShowCellByIndex(0)
	-- if cell then 
	-- 	local topPos = cell:getTopInParent()
	-- 	local size = self._dungeonList:getSize()
	-- 	local spaceBoder = topPos - size.height
	-- 	if spaceBoder > 0 then 
	-- 		self._dungeonList:setScrollSpace(-spaceBoder, 0)
	-- 	end
	-- end

    -- self._dungeonList:scrollToShowCell(cellMax - 1, 0)
    -- self._dungeonList:scrollToTopLeftCellIndex(math.floor(self._curChapterIndex/4), self:countScrollSpace(), 0, function ( ... )
    -- 	-- body
    -- end)
end

function LegionNewDungeonListLayer:_onAddFightCount( ... )

	if G_Me.legionData:getNewNextGold() < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT_MAX"))
	end
	
	local box = require("app.scenes.tower.TowerSystemMessageBox")
	    box.showMessage( box.TypeLegion,
	            G_Me.legionData:getNewNextGold(), 1,
	            self._onBuyFightCount,
	        nil, 
	        self )
end

function LegionNewDungeonListLayer:_onBuyFightCount( ... )

	if G_Me.legionData:hasFinishDungeonChapter() then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT_NONEED"))
	end

	if G_Me.legionData:getNewNextGold() > G_Me.userData.gold then 
		return require("app.scenes.shop.GoldNotEnoughDialog").show()
	end

	G_HandlersManager.legionHandler:sendResetNewDungeonCount()
end

function LegionNewDungeonListLayer:_onBuyFightCountRet( ... )
	self:_updateChapterBase()
	G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT"))
end

function LegionNewDungeonListLayer:_onChapterUpdate( ... )
	self:_updateChapterBase()
	self:_initDungeonList()
end

function LegionNewDungeonListLayer:_updateChapterBase( ... )
	self._curChapterIndex = G_Me.legionData:getNewCurrentChapter()
	self:showTextWithLabel("Label_count_num", G_Me.legionData:getNewBuyTimes())
	if self._curChapterIndex <= 0 then
		return 
	end
	local chapterInfo = corps_dungeon_chapter_info.get(self._curChapterIndex)
	if chapterInfo then 
		self:showTextWithLabel("Label_name", G_lang:get("LANG_LEGION_DUNGEON_MAP_TITLE_FORMAT", 
			{chapterIndex = self._curChapterIndex, chapterName = chapterInfo.name}))
	end
	local curInfo = G_Me.legionData:getNewChapterInfo(self._curChapterIndex)
	local progress = curInfo.max_hp > 0 and (curInfo.hp*100)/curInfo.max_hp or 0
	progress = 100 - progress
	self:showTextWithLabel("Label_progress_text", string.format("%.0f%%", progress))
	local progressBar = self:getLoadingBarByName("ProgressBar_attack_progress")
	if progressBar then 
		progressBar:runToPercent(progress, 0.2)
	end
	self:showWidgetByName("Image_awardTip", G_Me.legionData:getNewChapterFinishNeedTip())

	self:showWidgetByName("Button_rollBack",G_Me.legionData:getMaxFinishDungeon()>0)
end

function LegionNewDungeonListLayer:_initCountDonwTime( ... )
	-- self._countDownTime = G_Me.legionData:getDugeonEndTime()
	local _updateTime = function ( ... )
		self._countDownTime = G_Me.legionData:getDugeonEndTime()
		if self._countDownTime == 0 then 
			-- self._countDownTime = 0
			self:_onCountDownFinish()
		end
		self:showWidgetByName("Image_count_back", self._countDownTime >= 0)
		self:showWidgetByName("Panel_time", self._countDownTime >= 0)
		self:showWidgetByName("Image_barBg", self._countDownTime >= 0)
		self:showWidgetByName("Label_status", self._countDownTime >= 0)
		self:showWidgetByName("Label_tips", self._countDownTime < 0)
		if self._countDownTime < 0 then
			self:showTextWithLabel("Label_tips",
				 G_lang:get("LANG_NEW_LEGION_TIME_HAS_FINISHED"))
		else
			local hour = math.floor(self._countDownTime/3600)
			local hour2 = hour%2
			local min = math.floor((self._countDownTime%3600)/60)
			local sec = self._countDownTime%60
			if hour2==0 and min==0 and sec==0 then 
				self:_onCountDownFinish2()
			end

			self:showTextWithLabel("Label_status",
				 G_lang:get("LANG_LEGION_CHAPTER_RESET_COUNT_DOWN_FORMAT", 
				 	{countDown = string.format("%02d:%02d:%02d", hour, min, sec),id=G_Me.legionData:getTargetChapter()}) )
			-- self:showTextWithLabel("Label_time",G_lang:get("LANG_NEW_LEGION_FIGHT_REVERSE", 
			-- 	 	{time =string.format(G_lang:get("LANG_NEW_LEGION_FIGHT_REVERSE_FORMAT"), hour2, min, sec)}))
			self:_updateTimeLabel(string.format(G_lang:get("LANG_NEW_LEGION_FIGHT_REVERSE_FORMAT"), hour2, min, sec))
		end
		-- self._countDownTime = self._countDownTime -1	
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

function LegionNewDungeonListLayer:_updateTimeLabel( time)
	self._timeLabel:setText(time)
	local widgetList = {self._txtLabel1,self._timeLabel,self._txtLabel2}
	local maxWidth = 0
	for k , v in pairs(widgetList) do 
		maxWidth = maxWidth + v:getContentSize().width
	end
	local totalWidth = self._timePanel:getContentSize().width
	local curWidth = (totalWidth - maxWidth)/2
	for k , v in pairs(widgetList) do 
		curWidth = curWidth + v:getContentSize().width/2
		v:setPositionX(curWidth)
		curWidth = curWidth + v:getContentSize().width/2
	end
end

function LegionNewDungeonListLayer:_onCountDownFinish( )
	-- self:_removeTimer()
	-- self:_updateChapterBase()
	-- uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
end

function LegionNewDungeonListLayer:_onCountDownFinish2( )
	G_HandlersManager.legionHandler:sendGetNewCorpChapter()
end

function LegionNewDungeonListLayer:_removeTimer( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        		self._timer = nil
	end
end

function LegionNewDungeonListLayer:onLayerExit( ... )
	self:_removeTimer()
end

function LegionNewDungeonListLayer:countMoveOffset()
	--local maxLength = corps_dungeon_chapter_info.getLength()
	local showChapterMax = self._validChapterCount + 1
	local cellMax = (showChapterMax % 4 ~= 0) and (showChapterMax/4 + 1) or showChapterMax/4
	cellMax = cellMax > 0 and cellMax or 1
	cellMax = math.floor(cellMax)

	local moveOffset = 0
	if showChapterMax%4 == 1 then
		moveOffset = LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT*0.75
	elseif showChapterMax%4 == 3 then
		moveOffset = LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
	elseif showChapterMax%4 == 0 then
		--moveOffset = LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
	elseif showChapterMax%4 == 2 then
		moveOffset = LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT*0.5
	end

	if showChapterMax%4 ~= 0 then
		--__Log("moveOffset 1:%d", moveOffset)
		moveOffset = moveOffset + (self._validChapterCount - self._curChapterIndex)*LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
		--__Log("moveOffset 2:%d, chapterOffset:%d", moveOffset, self._validChapterCount - self._curChapterIndex)
	else
		moveOffset = moveOffset + (cellMax*4 - self._curChapterIndex - 1)*LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
		--__Log("moveOffset 3:%d", moveOffset)
	end
	__Log("cellMax:%d, moveOffset:%d",cellMax, moveOffset)

	return moveOffset
end

function LegionNewDungeonListLayer:countScrollSpace( ... )
	local maxShowChapterCount = self._validChapterCount + 1
	local scrollSpace = 0
	local cellMax = (maxShowChapterCount % 4 ~= 0) and (maxShowChapterCount/4 + 1) or maxShowChapterCount/4
	cellMax = cellMax > 0 and cellMax or 1
	cellMax = math.floor(cellMax)

	if maxShowChapterCount%4 == 1 then 
		scrollSpace = -LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT*0.75
	elseif maxShowChapterCount%4 == 2 then
		scrollSpace = -LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT*0.5
	elseif maxShowChapterCount%4 == 3 then
		scrollSpace = -LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
	elseif maxShowChapterCount%4 == 0 then
	end

	local bottomPosY = cellMax*LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT + scrollSpace 
	if cellMax == 1 and bottomPosY > 0 and scrollSpace < 0 then 
		local winSize = CCDirector:sharedDirector():getWinSize()
		scrollSpace = winSize.height - cellMax*LegionNewDungeonListLayer.DUNGEON_CELL_HEIGHT
	end
	__Log("cellMax:%d, countOffset:%d, _scrollSpace:%d", cellMax, maxShowChapterCount%4, scrollSpace)
	return scrollSpace
end

return LegionNewDungeonListLayer

--moveOffset = moveOffset + (self._validChapterCount - self._curChapterIndex)*LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25