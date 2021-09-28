--LegionNewMapLayer.lua

require("app.cfg.corps_dungeon_chapter_info")
require("app.cfg.corps_dungeon_info")
require("app.cfg.corps_dungeon_tips_info")

local EffectNode = require "app.common.effects.EffectNode"
local LegionNewMapLayer = class("LegionNewMapLayer", UFCCSNormalLayer)

function LegionNewMapLayer.create( chapterIndex )
	return LegionNewMapLayer.new("ui_layout/legion_DungeonNewMap.json", nil, chapterIndex)
end

function LegionNewMapLayer:ctor( ... )
	self._countDownTime = 0
	self._timer = nil
	self._chapterIndex = 0

	self.super.ctor(self, ...)
end

function LegionNewMapLayer:onLayerLoad( _, _, chapterIndex )
	self._chapterIndex = chapterIndex or 1

	self:enableLabelStroke("Label_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_progress_text", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_status", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_treasure_tip", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_time", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_txt1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_txt2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_1_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_2_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_3_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_4_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_1", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_2", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_3", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_fighter_4", Colors.strokeBrown, 1)
	self:registerWidgetClickEvent("Image_count_back", handler(self, self._onAddFightCount))

    self:registerBtnClickEvent("Button_return", handler(self, self._onBackClick))
    self:registerBtnClickEvent("Button_treasure", handler(self, self._onTreasureClick))

    self._timeLabel = self:getLabelByName("Label_time")
    self._txtLabel1 = self:getLabelByName("Label_txt1")
    self._txtLabel2 = self:getLabelByName("Label_txt2")
    self._timePanel = self:getPanelByName("Panel_time")

    	self:registerBtnClickEvent("Button_help",function (  widget, param )
    		require("app.scenes.common.CommonHelpLayer").show({
    			{title=G_lang:get("LANG_NEW_LEGION_HELP_TITLE1"), content=G_lang:get("LANG_NEW_LEGION_HELP_CONTENT1")},
    			{title=G_lang:get("LANG_NEW_LEGION_HELP_TITLE2"), content=G_lang:get("LANG_NEW_LEGION_HELP_CONTENT2")},})
    	end)
    	self:registerBtnClickEvent("Button_add",function (  widget, param )
    		self:_onAddFightCount()
    	end)
    	self:registerWidgetClickEvent("Image_count_back",function (  widget, param )
    		self:_onAddFightCount()
    	end)
    	self:registerBtnClickEvent("Button_return",function (  widget, param )
    		if CCDirector:sharedDirector():getSceneCount() > 1 then 
    			uf_sceneManager:popScene()
    		else
    			uf_sceneManager:replaceScene(require("app.scenes.legion.LegionNewDungeionScene").new())
    		end
    	end)
    	self:registerBtnClickEvent("Button_treasure",function (  widget, param )
    		uf_sceneManager:pushScene(require("app.scenes.legion.LegionNewHigEggScene").new(self._chapterIndex))
    	end)
    	self:registerBtnClickEvent("Button_award",function (  widget, param )
    		require("app.scenes.legion.LegionNewChapterRewardLayer").show()
    	end)
    	self:registerBtnClickEvent("Button_task",function (  widget, param )
    		require("app.scenes.legion.LegionNewDamageRankLayer").show()
    	end)
    	self:registerBtnClickEvent("Button_rollBack",function (  widget, param )
    		require("app.scenes.legion.LegionNewRollBackChooseLayer").show()
    	end)


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
    
    G_HandlersManager.legionHandler:sendGetNewCorpDungeonInfo(self._chapterIndex)
end

function LegionNewMapLayer:onLayerEnter( ... )
	-- self:_refreshDungeonInfo()
	self:_onChapterUpdate()
	self:_initCountDonwTime()
	self:_updateAwardTip()
	
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_CORP_CHATER_INFO, self._onChapterUpdate, self)
    -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_DUNGEON_AWARD_LIST, self._onAwardListUpdate, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EXECUTE_NEW_CORP_DUNGEON, self._onExecuteDungeonResult, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_CORP_DUNGEON_INFO, self._onChapterDungeonUpdate, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_FLUSH_NEW_CORP_DUNGEON, self._onDungeonFlush, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RESET_NEW_DUNGEON_COUNT, self._onBuyFightCountRet, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_NEW_CHAPER_AWARD, self._onAwardListUpdate, self)
	
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
        G_HandlersManager.legionHandler:disposeCorpDismiss(dismiss)
    end, self)

end

function LegionNewMapLayer:onLayerExit( ... )
	self:_removeTimer()
end

function LegionNewMapLayer:_onAddFightCount( ... )

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

function LegionNewMapLayer:_onBuyFightCount( ... )

	if G_Me.legionData:hasFinishDungeonChapter() then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT_NONEED"))
	end

	if G_Me.legionData:getNewNextGold() > G_Me.userData.gold then 
		return require("app.scenes.shop.GoldNotEnoughDialog").show()
	end

	G_HandlersManager.legionHandler:sendResetNewDungeonCount()
end

function LegionNewMapLayer:_onBuyFightCountRet( ... )
	self:_onChapterUpdate()
	G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_BUY_DUNGEON_FIGHT_COUNT"))
end

function LegionNewMapLayer:_onDungeonLevelClick( dungeonInfo )
	levelIndex = levelIndex or 1

-- 	local buffer = {
-- 	dungeon = G_Me.legionData:getCorpDungeonInfoByIndex(1),
-- 	name = "sdsjfdsaf",
-- 	last_hit = true,
-- 	harm = 50,
-- 	ret = 1,
-- }
-- 	self:_flyDungeonRet( buffer )
	require("app.scenes.legion.LegionNewLevelLayer").show(dungeonInfo)
end

function LegionNewMapLayer:_initCountDonwTime( ... )
	local state = G_Me.legionData:getNewChapterInfo(self._chapterIndex).hp > 0 and G_Me.legionData:getDugeonEndTime() > 0
	self._countDownTime = state and G_Me.legionData:getDugeonEndTime() or G_Me.legionData:getAwardEndTime()
	local _updateTime = function ( ... )
		if self._countDownTime < 0 then 
			self._countDownTime = 0
			self:_onCountDownFinish()
		end
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
		-- self:showTextWithLabel("Label_time",G_lang:get( state and "LANG_NEW_LEGION_FIGHT_REVERSE" or "LANG_NEW_LEGION_CLOSE_TIME", 
		-- 	 	{time =string.format(G_lang:get("LANG_NEW_LEGION_FIGHT_REVERSE_FORMAT"), hour2, min, sec)}))
		self:_updateTimeLabel(string.format(G_lang:get("LANG_NEW_LEGION_FIGHT_REVERSE_FORMAT"), hour2, min, sec))
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

function LegionNewMapLayer:_updateTimeLabel( time)
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

function LegionNewMapLayer:_onCountDownFinish( )
	self:_removeTimer()

	uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
end

function LegionNewMapLayer:_onCountDownFinish2( )
	G_HandlersManager.legionHandler:sendGetNewCorpChapter()
end

function LegionNewMapLayer:_removeTimer( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        		self._timer = nil
	end
end

function LegionNewMapLayer:_updateAwardTip( ... )
	self:showWidgetByName("Image_treasure_tip", G_Me.legionData:getNewChapterAwardNeedTip(self._chapterIndex) )
	self:showWidgetByName("Image_awardTip", G_Me.legionData:getNewChapterFinishNeedTip())
end

local _findCorpDungeonIndex = function ( dungeonId, chapterIndex )
		if type(dungeonId) ~= "number" then
			return 0
		end

		local chapters = corps_dungeon_chapter_info.get(chapterIndex)
		for loopi = 1, 4, 1 do 
			if chapters["dungeon_"..loopi] == dungeonId then 	
				return loopi
			end
		end

		return 0		
	end

function LegionNewMapLayer:_refreshDungeonInfo( ... )

	local corpDungeon = G_Me.legionData:getNewDungeonData(self._chapterIndex)
	-- if #corpDungeon < 1 or not rawget(corpDungeon[1],"hp") or not rawget(corpDungeon[1],"max_hp") then
	-- 	return
	-- end
	for k , v in pairs(corpDungeon) do 
		if not rawget(v,"hp") or not rawget(v,"max_hp") then
			return
		end
	end
	
	self:getPanelByName("Panel_fz_1"):setVisible(true)
	self:getPanelByName("Panel_fz_2"):setVisible(true)
	self:getPanelByName("Panel_fz_3"):setVisible(true)
	self:getPanelByName("Panel_fz_4"):setVisible(true)

	self:_updateAwardTip()

	local chapterInfo = corps_dungeon_chapter_info.get(self._chapterIndex)
	local corpsDungeInfo = corpDungeon
	if type(corpsDungeInfo) ~= "table" or not chapterInfo then 
		return 
	end

	self:showTextWithLabel("Label_treasure_tip", chapterInfo.award_name)

	for key, value in pairs(corpsDungeInfo) do 

		local corpIndex = _findCorpDungeonIndex(value.id or 0, self._chapterIndex)
		if corpIndex > 0 then 
			local dungeonInfo = corps_dungeon_info.get(value.id)
			local countyId = dungeonInfo.country
			local dungeonTipInfo = corps_dungeon_tips_info.get(countyId)
			countyId = dungeonTipInfo and dungeonTipInfo.icon or 1

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
					progressBar:setPercent(progress)
				end
			end
			
			self:showWidgetByName("Image_arrow_"..corpIndex, progress > 0)
			self:showWidgetByName("Image_zy_"..corpIndex, progress > 0)
			self:showWidgetByName("Image_complete_"..corpIndex, progress <= 0)

			local _clickFz = function ( ... )
				if value.hp < 1 then 
					return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DUNGEON_FINISH_BATTLE", {levelName=dungeonInfo and dungeonInfo.dungeon_name_1 or ""}))
				end
				if G_Me.legionData:getDugeonEndTime() < 0 then
					return G_MovingTip:showMovingTip(G_lang:get("LANG_NEW_LEGION_AWARD_TIME_TIP"))
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

function LegionNewMapLayer:_onChapterUpdate( ... )

	local corpChapters = G_Me.legionData:getNewChapterInfo(self._chapterIndex)
	self:showWidgetByName("Label_count_tip", corpChapters and true or false)
	self:showWidgetByName("Label_count_num", corpChapters and true or false)
	if corpChapters then
		self:showTextWithLabel("Label_count_tip", G_lang:get("LANG_NEW_LEGION_FIGHT_MAX_FORMAT"))
		self:showTextWithLabel("Label_count_num", G_Me.legionData:getNewBuyTimes())

		local progress = corpChapters.max_hp > 0 and (corpChapters.hp*100)/corpChapters.max_hp or 0
		progress = 100 - progress
		self:showTextWithLabel("Label_progress_text", string.format("%.0f%%", progress))
		local progressBar = self:getLoadingBarByName("ProgressBar_attack_progress")
		if progressBar then 
			progressBar:setPercent(progress)
		end
		self:showWidgetByName("Image_progressDi", corpChapters.hp > 0)

		self:showWidgetByName("Button_rollBack",G_Me.legionData:getMaxFinishDungeon()>0)
		self:showWidgetByName("Image_count_back", corpChapters.hp > 0)
	end
end

function LegionNewMapLayer:_onChapterDungeonUpdate(  )
	self:_refreshDungeonInfo()
	self:_onChapterUpdate()
end

function LegionNewMapLayer:_onDungeonFlush( buffer )
	self:_onChapterDungeonUpdate()
	self:_flyDungeonRet(buffer)
end

function LegionNewMapLayer:_flyDungeonRet( buffer )
	-- dump(buffer)
	if type(buffer) ~= "table" then 
		return 
	end

    local dungeonInfo = corps_dungeon_info.get(buffer.dungeon and buffer.dungeon.id or 0 )
    if not dungeonInfo then 
    	return 
    end
    -- print("dungeonId "..buffer.dungeon.id)
    local corpIndex = _findCorpDungeonIndex(buffer.dungeon.id or 0, self._chapterIndex)
    -- print("corpIndex "..corpIndex)
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
    -- richLabel:setPosition(ccp(label:getPosition()))
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

function LegionNewMapLayer:_onAwardListUpdate( ... )
	self:_updateAwardTip()
end

function LegionNewMapLayer:_onExecuteDungeonResult( battleResult )
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
        	scene = require("app.scenes.legion.LegionNewBattleScene").new({
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

return LegionNewMapLayer

