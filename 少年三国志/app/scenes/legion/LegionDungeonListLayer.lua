--LegionDungeonListLayer.lua

require("app.cfg.corps_dungeon_chapter_info")


local LegionDungeonListLayer = class("LegionDungeonListLayer", UFCCSNormalLayer)

LegionDungeonListLayer.DUNGEON_CELL_HEIGHT = 1140

function LegionDungeonListLayer.create( ... )
	return LegionDungeonListLayer.new("ui_layout/legion_DungeonLayerCopy.json")
end

function LegionDungeonListLayer:ctor( ... )
	self._dungeonList = nil
	self._curChapterIndex = 1
	self._validChapterCount = 1
	self.super.ctor(self, ...)
end

function LegionDungeonListLayer:onLayerLoad( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress", Colors.strokeBrown, 1 )

	self:registerBtnClickEvent("Button_return", handler(self, self._onBackClick))
	self:registerBtnClickEvent("Button_help", handler(self, self._onHelpClick))
	self:registerBtnClickEvent("Button_attack", handler(self, self._onAttackClick))
	self:registerBtnClickEvent("Button_add", handler(self, self._onAddFightCount))
	self:registerWidgetClickEvent("Image_count_back", handler(self, self._onAddFightCount))
	
	self:_initChapterBase()

	G_HandlersManager.legionHandler:sendGetCorpChapter()
end

function LegionDungeonListLayer:onLayerEnter( ... )
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_CHATER_INFO, self._onChapterUpdate, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_DETAIL, self._updateCorpDetail, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RESET_DUNGEON_COUNT, self._onBuyFightCountRet, self)
	--self:callAfterFrameCount(1, function ( ... )
	self:_updateCorpDetail()
	--end)

		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
        G_HandlersManager.legionHandler:disposeCorpDismiss(dismiss)
    end, self)
end

function LegionDungeonListLayer:calcShowChapterMax( ... )
	local showChapterMax = self._curChapterIndex + 1
	local corpChapters = G_Me.legionData:getCorpChapters()
	local detailCorp = G_Me.legionData:getCorpDetail()

	if not corpChapters or not detailCorp then 
		return showChapterMax 
	end

	local maxLength = corps_dungeon_chapter_info.getLength()
	for loopi = self._curChapterIndex + 1, maxLength, 1 do 
		showChapterMax = loopi
		local chapterInfo = corps_dungeon_chapter_info.get(loopi)
		if chapterInfo then 
			local lock = false
			if detailCorp.level < chapterInfo.open_level then
				lock = true
			end
			if chapterInfo.open_id > 0 and (not corpChapters.chapters[chapterInfo.open_id]) then 
				lock = true
			end

			if lock then 
				return showChapterMax
			end
		end
	end

	return showChapterMax
end

function LegionDungeonListLayer:_initDungeonList( ... )
	self._showChapterMax = self:calcShowChapterMax()
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
    	    	return require("app.scenes.legion.LegionDungeonItem").new(list, index)
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

function LegionDungeonListLayer:_onBackClick( ... )
    if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end
end

function LegionDungeonListLayer:_onHelpClick( ... )
	require("app.scenes.common.CommonHelpLayer").show({
		{title=G_lang:get("LANG_LEGION_HELP_DUNGEON_TITLE"), content=G_lang:get("LANG_LEGION_HELP_DUNGEON")},})
	--require("app.scenes.legion.LegionHelpLayer").show(G_lang:get("LANG_LEGION_HELP_DUNGEON_TITLE"), G_lang:get("LANG_LEGION_HELP_DUNGEON"))
end

function LegionDungeonListLayer:_onAttackClick( ... )
	require("app.scenes.legion.LegionAttackAimLayer").show()
end

function LegionDungeonListLayer:_onAddFightCount( ... )
	if G_Me.legionData:hasFinishDungeonChapter() then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT_NONEED"))
	end
	local chapterInfo = G_Me.legionData:getCorpChapters()
	if not chapterInfo then
		return 
	end

	if chapterInfo.reset_cost < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT_MAX"))
	end

	local box = require("app.scenes.tower.TowerSystemMessageBox")
    box.showMessage( box.TypeLegion,
            chapterInfo.reset_cost, 1,
            self._onBuyFightCount,
        nil, 
        self )
end

function LegionDungeonListLayer:_onBuyFightCount( ... )
	local chapterInfo = G_Me.legionData:getCorpChapters()
	if not chapterInfo then
		return 
	end
	
	if G_Me.legionData:hasFinishDungeonChapter() then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT_NONEED"))
	end

	if chapterInfo.reset_cost > G_Me.userData.gold then 
		return require("app.scenes.shop.GoldNotEnoughDialog").show()
	end

	G_HandlersManager.legionHandler:sendResetDungeonCount()
end

function LegionDungeonListLayer:_onBuyFightCountRet( ... )
	G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT"))
end

function LegionDungeonListLayer:_onChapterUpdate( ... )
	local curChapterIndex = self._curChapterIndex
	self:_initChapterBase()

	if curChapterIndex ~= self._curChapterIndex then 
		self:_initDungeonList()
	end
end

function LegionDungeonListLayer:_initChapterBase( ... )
	local chapterInfo = G_Me.legionData:getCorpChapters()
	if chapterInfo then 
		self._curChapterIndex = chapterInfo.today_chid or 1
	end
	self:showWidgetByName("Label_count_tip", chapterInfo and true or false)
	if chapterInfo then
		self:showTextWithLabel("Label_count_tip", G_lang:get("LANG_LEGION_FIGHT_MAX_FORMAT", 
				{maxCount = chapterInfo.chapter_count}))
	end
end

function LegionDungeonListLayer:_updateCorpDetail( ... )
	local detailCorp = G_Me.legionData:getCorpDetail() or {}

	self:showTextWithLabel("Label_level", detailCorp.level or 1)
	self:showTextWithLabel("Label_name", detailCorp.name or "")
	local maxExp = 0
	local curExp = 0
	if detailCorp then 
		local corpsInfo = corps_info.get(detailCorp.level)
		maxExp = corpsInfo and corpsInfo.exp or 0
        curExp = detailCorp.exp
	end
	self:showTextWithLabel("Label_progress", curExp.."/"..maxExp)
	local progressBar = self:getLoadingBarByName("ProgressBar_progrss")
	if progressBar then 
		progressBar:setPercent(0)
		progressBar:runToPercent(maxExp > 0 and (curExp*100)/maxExp or 0, 0.2)
	end

	self:_initDungeonList()
end

function LegionDungeonListLayer:countMoveOffset()
	--local maxLength = corps_dungeon_chapter_info.getLength()
	local showChapterMax = self._validChapterCount + 1
	local cellMax = (showChapterMax % 4 ~= 0) and (showChapterMax/4 + 1) or showChapterMax/4
	cellMax = cellMax > 0 and cellMax or 1
	cellMax = math.floor(cellMax)

	local moveOffset = 0
	if showChapterMax%4 == 1 then
		moveOffset = LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.75
	elseif showChapterMax%4 == 3 then
		moveOffset = LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
	elseif showChapterMax%4 == 0 then
		--moveOffset = LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
	elseif showChapterMax%4 == 2 then
		moveOffset = LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.5
	end

	if showChapterMax%4 ~= 0 then
		--__Log("moveOffset 1:%d", moveOffset)
		moveOffset = moveOffset + (self._validChapterCount - self._curChapterIndex)*LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
		--__Log("moveOffset 2:%d, chapterOffset:%d", moveOffset, self._validChapterCount - self._curChapterIndex)
	else
		moveOffset = moveOffset + (cellMax*4 - self._curChapterIndex - 1)*LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
		--__Log("moveOffset 3:%d", moveOffset)
	end
	__Log("cellMax:%d, moveOffset:%d",cellMax, moveOffset)

	return moveOffset
end

function LegionDungeonListLayer:countScrollSpace( ... )
	local maxShowChapterCount = self._validChapterCount + 1
	local scrollSpace = 0
	local cellMax = (maxShowChapterCount % 4 ~= 0) and (maxShowChapterCount/4 + 1) or maxShowChapterCount/4
	cellMax = cellMax > 0 and cellMax or 1
	cellMax = math.floor(cellMax)

	if maxShowChapterCount%4 == 1 then 
		scrollSpace = -LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.75
	elseif maxShowChapterCount%4 == 2 then
		scrollSpace = -LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.5
	elseif maxShowChapterCount%4 == 3 then
		scrollSpace = -LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25
	elseif maxShowChapterCount%4 == 0 then
	end

	local bottomPosY = cellMax*LegionDungeonListLayer.DUNGEON_CELL_HEIGHT + scrollSpace 
	if cellMax == 1 and bottomPosY > 0 and scrollSpace < 0 then 
		local winSize = CCDirector:sharedDirector():getWinSize()
		scrollSpace = winSize.height - cellMax*LegionDungeonListLayer.DUNGEON_CELL_HEIGHT
	end
	__Log("cellMax:%d, countOffset:%d, _scrollSpace:%d", cellMax, maxShowChapterCount%4, scrollSpace)
	return scrollSpace
end

return LegionDungeonListLayer

--moveOffset = moveOffset + (self._validChapterCount - self._curChapterIndex)*LegionDungeonListLayer.DUNGEON_CELL_HEIGHT*0.25