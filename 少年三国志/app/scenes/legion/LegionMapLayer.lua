--LegionMapLayer.lua

require("app.cfg.corps_dungeon_chapter_info")
require("app.cfg.corps_dungeon_info")
require("app.cfg.corps_dungeon_tips_info")

local EffectNode = require "app.common.effects.EffectNode"
local LegionMapLayer = class("LegionMapLayer", UFCCSNormalLayer)

function LegionMapLayer.create( chapterIndex )
	return LegionMapLayer.new("ui_layout/legion_DungeonMap.json", nil, chapterIndex)
end

function LegionMapLayer:ctor( ... )
	self._posy = 0
	self._posx = 0
	self._countDownTime = 0
	self._timer = nil
	self._touchStartY = 0
	self._totalMoveDist = 0
	self._clickValid = true
	self._screenSize = CCDirector:sharedDirector():getWinSize()
	self._backSize = self._screenSize
	self._chapterIndex = 0

	self._hasEnter = false
	self.super.ctor(self, ...)
end

function LegionMapLayer:onLayerLoad( _, _, chapterIndex )
	self._chapterIndex = chapterIndex or 1
	self:registerTouchEvent(false,true,0)

	self:enableLabelStroke("Label_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_progress_text", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_status", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_treasure_tip", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_1_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_2_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_3_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_4_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_5_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_6_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_1", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_2", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_3", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_4", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_5", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_6", Colors.strokeBrown, 1)
	self:registerBtnClickEvent("Button_help", handler(self, self._onHelpClick))
	self:registerBtnClickEvent("Button_add", handler(self, self._onAddFightCount))
	self:registerWidgetClickEvent("Image_count_back", handler(self, self._onAddFightCount))

    self:registerBtnClickEvent("Button_return", handler(self, self._onBackClick))
    self:registerBtnClickEvent("Button_treasure", handler(self, self._onTreasureClick))

    -- self:registerBtnClickEvent("Button_1", function ( ... )
    -- 	self:_onDungeonLevelClick( 1 )
    -- end)
    -- self:registerBtnClickEvent("Button_2", function ( ... )
    -- 	self:_onDungeonLevelClick( 2 )
    -- end)

    self:registerBtnClickEvent("Button_damage_rank", handler(self, self._onMemberRankClick))
    self:registerBtnClickEvent("Button_treasure_preview", handler(self, self._onTreasurePreviewClick))
    
    local widget = self:getWidgetByName("Image_back")
    self._backSize = widget:getSize()

    local chapterInfo = corps_dungeon_chapter_info.get(self._chapterIndex)
    if chapterInfo then 
    	self:showTextWithLabel("Label_name", G_lang:get("LANG_LEGION_DUNGEON_MAP_TITLE_FORMAT", 
    		{chapterIndex = self._chapterIndex, chapterName = chapterInfo.name}))
    end

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		local effect  = EffectNode.new("effect_ST")
    	effect:play()
    	local widget = self:getWidgetByName("Button_treasure")
    	if widget then 
    		effect:setPositionXY(0, 70)
    		widget:addNode(effect)
    	end
    end
    
    G_HandlersManager.legionHandler:sendGetCorpDungeonInfo(self._chapterIndex)
end

function LegionMapLayer:onLayerEnter( ... )
	self:_refreshDungeonInfo()
	self:_onChapterUpdate()
	self:_initCountDonwTime()

	if G_Me.legionData:haveFinishChapter() then
    	G_HandlersManager.legionHandler:sendGetDungeonAwardList()
    end

    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_CHATER_INFO, self._onChapterUpdate, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_DUNGEON_AWARD_LIST, self._onAwardListUpdate, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EXECUTE_CORP_DUNGEON, self._onExecuteDungeonResult, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_DUNGEON_INFO, self._onChapterDungeonUpdate, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_FLUSH_CORP_DUNGEON, self._onDungeonFlush, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
        G_HandlersManager.legionHandler:disposeCorpDismiss(dismiss)
    end, self)

    if self._hasEnter then
    	self:callAfterFrameCount(1, function ( ... )
    		local widget = self:getWidgetByName("Image_back")
    		if widget then 
    			widget:setPositionXY(self._posx, self._posy)
    		end
    	end)
	end
    self._hasEnter = true
end

function LegionMapLayer:onLayerExit( ... )
	self:_removeTimer()
	local widget = self:getWidgetByName("Image_back")
	self._posx, self._posy = widget:getPosition()
end

function LegionMapLayer:_onBackClick( ... )
	if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionDungeionScene").new())
	end
end

function LegionMapLayer:_onHelpClick( ... )
	require("app.scenes.legion.LegionHelpLayer").show(G_lang:get("LANG_LEGION_HELP_DUNGEON_TITLE"), G_lang:get("LANG_LEGION_HELP_DUNGEON"))
end

function LegionMapLayer:_onAddFightCount( ... )
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

function LegionMapLayer:_onBuyFightCount( ... )
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

function LegionMapLayer:_onBuyFightCountRet( ... )
	G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT"))
end

function LegionMapLayer:onTouchBegin( xpos, ypos )
	self._touchStartY = ypos
	self._clickValid = true
	self._totalMoveDist = 0

	return true
end

function LegionMapLayer:onTouchMove( xpos, ypos )
	local moveOffset = ypos - self._touchStartY

	self:_scrollWithOffset(moveOffset*3)
	self._touchStartY = ypos

	if self._clickValid then
		self._totalMoveDist = self._totalMoveDist + moveOffset
		if math.abs(self._totalMoveDist) >= 10 then 
			self._clickValid = false
		end
	end
end

function LegionMapLayer:_scrollWithOffset( offset )
	offset = offset or 0
	local effectMoveOffset = function ( offset )
		local backImg = self:getWidgetByName("Image_back")
		local posx, posy = backImg:getPosition()
		
		if offset > 0 then
			if posy - self._backSize.height/2 < 0 then 
				return (offset > self._backSize.height/2 - posy) and (self._backSize.height/2 - posy) or offset
			else
				return 0
			end
		elseif offset < 0 then
			if posy + self._backSize.height/2 > self._screenSize.height - 50 then 
				return (offset < self._screenSize.height - 50 - posy - self._backSize.height/2) and 
				(self._screenSize.height - 50 - posy - self._backSize.height/2) or offset
			else
				return 0
			end
		end	

		return offset
	end

	local effectOffset = effectMoveOffset(offset)

	--__Log("offset:%f, effectOffset:%f", offset, effectOffset)
	if effectOffset ~= 0 then
		self:_doScrollWithOffset("Image_back", effectOffset/4)
	end
end

function LegionMapLayer:_doScrollWithOffset( name, offset, animation )
	if type(name) ~= "string" or not offset or offset == 0 then 
		return 
	end

	animation = animation or false
	local widget = self:getWidgetByName(name)
	if not widget then 
		return 
	end

	local posx, posy = widget:getPosition()
	widget:setPosition(ccp(posx, posy + offset))
end

function LegionMapLayer:_onDungeonLevelClick( dungeonInfo )
	levelIndex = levelIndex or 1

-- 	local buffer = {
-- 	dungeon = G_Me.legionData:getCorpDungeonInfoByIndex(1),
-- 	name = "sdsjfdsaf",
-- 	last_hit = true,
-- 	harm = 50,
-- 	ret = 1,
-- }
-- 	self:_flyDungeonRet( buffer )
	require("app.scenes.legion.LegionLevelLayer").show(dungeonInfo)
end

function LegionMapLayer:_onMemberRankClick( ... )
	require("app.scenes.legion.LegionDamageRankLayer").show()
end

function LegionMapLayer:_onTreasurePreviewClick( ... )
	require("app.scenes.legion.LegionTreasurePreviewLayer").show()
end

function LegionMapLayer:_onTreasureClick( ... )
	uf_sceneManager:pushScene(require("app.scenes.legion.LegionHigEggScene").new())
end

function LegionMapLayer:_initCountDonwTime( ... )
	self._countDownTime = G_Me.legionData:getLeftDungeonTime()
	local _updateTime = function ( ... )
		if self._countDownTime < 0 then 
			self._countDownTime = 0
			self:_onCountDownFinish()
		end
		local hour = math.floor(self._countDownTime/3600)
		local min = math.floor((self._countDownTime%3600)/60)
		local sec = self._countDownTime%60
		self:showTextWithLabel("Label_status",
			 G_lang:get("LANG_LEGION_CHAPTER_RESET_COUNT_DOWN_FORMAT", 
			 	{countDown = string.format("%02d:%02d:%02d", hour, min, sec)}) )
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

function LegionMapLayer:_onCountDownFinish( ... )
	self:_removeTimer()

	local corpChapters = G_Me.legionData:getCorpChapters()
	if corpChapters then
		self._chapterIndex = corpChapters.chapter_id
		G_HandlersManager.legionHandler:sendGetCorpChapter()
		G_HandlersManager.legionHandler:sendGetCorpDungeonInfo(self._chapterIndex)
	end
end

function LegionMapLayer:_removeTimer( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
	end
end

function LegionMapLayer:_updateAwardTip( ... )
	self:showWidgetByName("Image_treasure_tip", G_Me.legionData:canHitEgg() or G_Me.legionData:hasAcquireFinishAward())
end

local _findCorpDungeonIndex = function ( dungeonId, chapterIndex )
		if type(dungeonId) ~= "number" then
			return 0
		end

		local chapters = corps_dungeon_chapter_info.get(chapterIndex)
		for loopi = 1, 6, 1 do 
			if chapters["dungeon_"..loopi] == dungeonId then 	
				return loopi
			end
		end

		return 0		
	end

function LegionMapLayer:_refreshDungeonInfo( ... )
	local corpDungeon = G_Me.legionData:getCorpDungeonInfo()
	local isValidCorpInfo = (corpDungeon and corpDungeon.chapter_id == self._chapterIndex) and true or false
	self:showWidgetByName("Button_1", isValidCorpInfo)
	self:showWidgetByName("Button_2", isValidCorpInfo)
	self:showWidgetByName("Button_3", isValidCorpInfo)
	self:showWidgetByName("Button_4", isValidCorpInfo)
	self:showWidgetByName("Button_5", isValidCorpInfo)
	self:showWidgetByName("Button_6", isValidCorpInfo)

	self:_updateAwardTip()
	
	if not isValidCorpInfo then 
		return 
	end

	local chapterInfo = corps_dungeon_chapter_info.get(self._chapterIndex)
	local corpsDungeInfo = corpDungeon.dungeon
	if type(corpsDungeInfo) ~= "table" or not chapterInfo then 
		return 
	end

	self:showTextWithLabel("Label_treasure_tip", chapterInfo.award_name)

	for key, value in pairs(corpsDungeInfo) do 

		local corpIndex = _findCorpDungeonIndex(value.id or 0, self._chapterIndex)
		if corpIndex > 0 then 
			local zhengyinIndex = 1
			local countyId = 1
			local dungeonInfo = corps_dungeon_info.get(value.id)
			if dungeonInfo and value.info_id > 0 and value.info_id < 5 then 
				countyId = dungeonInfo["country_"..value.info_id]
				local dungeonTipInfo = corps_dungeon_tips_info.get(countyId)
				countyId = dungeonTipInfo and dungeonTipInfo.icon or 1
			end

			local name = self:getLabelByName("Label_"..corpIndex.."_name")
			if name then 
				name:setColor(Colors.qualityColors[dungeonInfo and dungeonInfo.quality or 1])
				name:setText(dungeonInfo and dungeonInfo.dungeon_name_1 or "")
			end

			local progress = value.max_hp > 0 and (value.hp*100)/value.max_hp or 0
			progress = math.ceil(progress)
			self:showWidgetByName("Image_blood_"..corpIndex, progress > 0)
			if progress > 0 then
				self:showTextWithLabel("ProgressBar_"..corpIndex, progress.."%")
				local progressBar = self:getLoadingBarByName("ProgressBar_"..corpIndex)
				if progressBar then 
					progressBar:runToPercent(progress, 0.2)
				end
			end
			
			self:showWidgetByName("Image_arrow_"..corpIndex, progress > 0)
			self:showWidgetByName("Image_zy_"..corpIndex, progress > 0)
			self:showWidgetByName("Image_complete_"..corpIndex, progress <= 0)

			local _clickFz = function ( ... )
				if value.hp < 1 then 
					return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DUNGEON_FINISH_BATTLE", {levelName=dungeonInfo and dungeonInfo.dungeon_name_1 or ""}))
				end
    			self:_onDungeonLevelClick( value )
			end
			self:registerBtnClickEvent("Button_"..corpIndex, _clickFz)
			self:registerBtnClickEvent("Panel_fz_"..corpIndex, _clickFz)

			local panelRoot = self:getWidgetByName("Panel_fz_"..corpIndex)
			local btn = self:getButtonByName("Button_"..corpIndex)
			
			if progress <= 0 then
				if panelRoot then 
					panelRoot:removeAllNodes()
				end
				if btn then 
					btn:setVisible(true)
				end
				local iconPath = G_Path.getLegionDungeonIcon(dungeonInfo.image)
				btn:loadTextureNormal(iconPath, UI_TEX_TYPE_LOCAL)
    			if btn then 
    				btn:showAsGray(true)
    			end
    			local fighter = value.kill_name or ""
    			self:showTextWithLabel("Label_fighter_"..corpIndex, 
    				#fighter > 0 and G_lang:get("LANG_LEGION_LEVEL_FIGHTER_NAME", {fightName=fighter}) or "")
    		else
    			if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
    				if panelRoot then
    					local effect = EffectNode.new(dungeonInfo.image == 1 and "effect_fz_xiaobing" or 
							(dungeonInfo.image == 2 and "effect_fz_qibing" or "effect_fz_jiangjun"))
						effect:play()
						panelRoot:removeAllNodes()
						panelRoot:addNode(effect)
						local panelSize = panelRoot:getSize()
						effect:setPositionXY(panelSize.width/2, panelSize.height/2)
					end
					if btn then 
						btn:setVisible(false)
					end
				else
					if btn then 
						btn:setVisible(true)
						local iconPath = G_Path.getLegionDungeonIcon(dungeonInfo.image)
						btn:loadTextureNormal(iconPath, UI_TEX_TYPE_LOCAL)
					end
    			end
    			local img = self:getImageViewByName("Image_zy_"..corpIndex)
				if img then 
					img:loadTexture(G_Path.getKnightGroupIcon(countyId))
				end
    		end
		end
	end
end

function LegionMapLayer:_onChapterUpdate( ... )

	local corpChapters = G_Me.legionData:getCorpChapters()
	self:showWidgetByName("Label_count_tip", corpChapters and true or false)
	if corpChapters then
		self:showTextWithLabel("Label_count_tip", G_lang:get("LANG_LEGION_FIGHT_MAX_FORMAT", 
				{maxCount = corpChapters.chapter_count}))

		local progress = corpChapters.max_hp > 0 and (corpChapters.hp*100)/corpChapters.max_hp or 0
		progress = 100 - progress
		self:showTextWithLabel("Label_progress_text", string.format("%.0f%%", progress))
		local progressBar = self:getLoadingBarByName("ProgressBar_attack_progress")
		if progressBar then 
			progressBar:runToPercent(progress, 0.2)
		end
	end
end

function LegionMapLayer:_onChapterDungeonUpdate(  )
	self:_refreshDungeonInfo()
	self:_onChapterUpdate()
end

function LegionMapLayer:_onDungeonFlush( buffer )
	self:_onChapterDungeonUpdate()
	self:_flyDungeonRet(buffer)
end

function LegionMapLayer:_flyDungeonRet( buffer )
	if type(buffer) ~= "table" then 
		return 
	end

    local dungeonInfo = corps_dungeon_info.get(buffer.dungeon and buffer.dungeon.id or 0 )
    if not dungeonInfo then 
    	return 
    end
    local corpIndex = _findCorpDungeonIndex(buffer.dungeon.id or 0, self._chapterIndex)
    if corpIndex < 1 then 
    	return 
    end

    local text = ""
    if not buffer.last_hit then
    	text = G_lang:get("LANG_LEGION_DUNGEON_FLUSH_FORMAT_1", 
    		{userName = buffer.name, levelName = dungeonInfo.dungeon_name_1, 
    		levelClr = Colors.getDecimalQuality(dungeonInfo and dungeonInfo.quality or 1), 
    		hurtValue = buffer.harm})
    else
    	text = G_lang:get("LANG_LEGION_DUNGEON_FLUSH_FORMAT_2", 
    		{userName = buffer.name, levelName = dungeonInfo.dungeon_name_1, 
    		levelClr = Colors.getDecimalQuality(dungeonInfo and dungeonInfo.quality or 1)})
    end

    local label = self:getLabelByName("Label_scroll_tip")
	local size = label:getSize()
    local parent = label:getParent()
	local richLabel = CCSRichText:create(size.width, size.height)
    richLabel:setFontName(label:getFontName())
    richLabel:setFontSize(label:getFontSize())
    richLabel:setShowTextFromTop(true)
    richLabel:enableStroke(Colors.strokeBrown)
    richLabel:setPosition(ccp(label:getPosition()))
    --parent:addChild(richLabel, 5)
    richLabel:appendContent(text, Colors.darkColors.DESCRIPTION)
    richLabel:reloadData()
    richLabel:setClippingEnabled(true)

    local btn = self:getButtonByName("Button_"..corpIndex)
    if btn then 
    	btn:addChild(richLabel)
    end

    local arr = CCArray:create()
    arr:addObject(CCEaseIn:create(CCMoveBy:create(0.5, ccp(0, 150)), 0.5))
    arr:addObject(CCDelayTime:create(1))
    arr:addObject(CCEaseIn:create(CCFadeOut:create(0.5), 0.5))
    arr:addObject(CCCallFunc:create(function ( ... )
    	if richLabel then 
    		richLabel:removeFromParentAndCleanup(true)
    	end
    	end))
    richLabel:runAction(CCSequence:create(arr))
end

function LegionMapLayer:_onAwardListUpdate( ... )
	self:_updateAwardTip()
end

function LegionMapLayer:_onExecuteDungeonResult( battleResult )
-- 	message S2C_ExecuteCorpDungeon {
--   required uint32 ret = 1;
--   required uint32 id = 2;
--   required uint32 info_id = 3;
--   optional BattleReport info = 4;
--   repeated Award awards = 5;
--   optional uint32 final_attack = 6;
--   optional CorpDungeon dungeon = 7;
-- }
	local scene = nil
    G_Loading:showLoading(function ( ... )
        	scene = require("app.scenes.legion.LegionBattleScene").new({
        		data = battleResult,
        		func = callback,
            	bg = "pic/dungeonbattle_map/31008.png", })
        	--uf_sceneManager:replaceScene(scene)
        	uf_sceneManager:pushScene(scene)
    	end,
    	function ( ... )
        	if scene ~= nil then
        	    scene:play()
        	end
    	end)
end

return LegionMapLayer

