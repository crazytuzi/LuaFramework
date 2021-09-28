--LegionLevelLayer.lua

require("app.cfg.monster_team_info")
require("app.cfg.corps_dungeon_info")
require("app.cfg.monster_info")
require("app.cfg.corps_dungeon_tips_info")

local LegionLevelLayer = class("LegionLevelLayer", UFCCSModelLayer)

function LegionLevelLayer.show( ... )
	local legionLayer = LegionLevelLayer.new("ui_layout/legion_DungeonLevel.json", Colors.modelColor, ...)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionLevelLayer:ctor( ... )
	self.super.ctor(self, ...)

	self:enableLabelStroke("Label_level_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_progress_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_5", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_6", Colors.strokeBrown, 1 )
end

function LegionLevelLayer:onLayerLoad( _, _, dungeonInfo )
	self:registerWidgetClickEvent("Button_buzheng", function ( ... )
		require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer( function ( ... )
    	end)
	end)
	self:registerWidgetClickEvent("Button_close", handler(self, self._onCloseClick))
	--self:registerWidgetClickEvent("Button_fight", handler(self, self._onFightClick))

	self:_initMonsters( dungeonInfo )

	self:_initLevelInfo()
end

function LegionLevelLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_CHATER_INFO, self._initLevelInfo, self)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function LegionLevelLayer:_initLevelInfo( ... )
	self:showTextWithLabel("Label_fight_count", G_lang:get("LANG_LEGION_FIGHT_MAX_FORMAT", 
				{maxCount = G_Me.legionData:getChapterCount()}))
end

function LegionLevelLayer:_onCloseClick( ... )
	self:animationToClose()
end

function LegionLevelLayer:_initMonsters( corpDungeon )
	local monsterIndex = corpDungeon.id 
	local monsterGroup = corpDungeon.info_id 
	local monster = corpDungeon.monster
	if type(monsterIndex) ~= "number" or type(monsterGroup) ~= "number" or type(monster) ~= "table" then 
		return 
	end

	if monsterGroup > 4 or monsterGroup < 1 then 
		monsterGroup = 1
	end

	local monsterGroupId = 0
	local countyId = 0
	local dungeonInfo = corps_dungeon_info.get(monsterIndex)
	if dungeonInfo then 
		countyId = dungeonInfo["country_"..monsterGroup]
		monsterGroupId = dungeonInfo["monster_group_"..monsterGroup]
	end
	local monsterArr = monster_team_info.get(monsterGroupId, 1)
	if not monsterArr then 
		return __LogError("[_initMonsters] wrong monsterGroupId for monsterGroup index:%d, monsterGroupId:%d", 
			monsterGroup or 0, monsterGroupId or 0)
	end

	self:showTextWithLabel("Label_level_name", dungeonInfo.dungeon_name_1)
	local dungeonTipInfo = corps_dungeon_tips_info.get(countyId)
	self:showTextWithLabel("Label_desc", dungeonTipInfo and dungeonTipInfo.tips or "")

	self:showTextWithLabel("Label_tip", G_lang:get("LANG_LEGION_CORP_LASTFIGHT_TIP", {expCount = dungeonInfo.corps_exp}))

	local img = self:getImageViewByName("Image_zhengyin")
	if img then 
	 	img:loadTexture(G_Path.getKnightGroupIcon(dungeonTipInfo and dungeonTipInfo.icon or 1))
	end

	local corpChapter = G_Me.legionData:getCorpChapters()
	local chapterInfo = nil
	if corpChapter then 
		local chapterId = corpChapter.today_chid or 1
		chapterInfo = corps_dungeon_chapter_info.get(chapterId)
	end
	
	self:showTextWithLabel("Label_tip", G_lang:get("LANG_LEGION_DUNGEON_LEVEL_AWARD", 
		{contriValue=chapterInfo and chapterInfo.corps_integral or 0, expValue=dungeonInfo and dungeonInfo.corps_exp or 0}) )

	local monsterFlag = {}
	for key, value in pairs(monster) do 
		local index = value.index or 0

		self:showWidgetByName("Label_dead_"..index, value.hp < 1)
		self:showWidgetByName("Image_progress_"..index, value.hp > 0)
		self:showWidgetByName("Label_progress_"..index, value.hp > 0)

		if value.hp > 0 then
			local progress = value.max_hp > 0 and (value.hp*100)/value.max_hp or 0
			self:showTextWithLabel("Label_progress_"..index, string.format("%.0f%%", progress))
			local progressBar = self:getLoadingBarByName("ProgressBar_"..index)
			if progressBar then 
				progressBar:setPercent(0)
				progressBar:runToPercent(progress, 0.2)
			end
		end	

		local monsterId = monsterArr["monster"..index] or 0
		local monsterInfo = monster_info.get(monsterId)
		if monsterInfo then 
			monsterFlag[value.index] = true
			local icon = self:getImageViewByName("Image_icon_"..index)
			if icon ~= nil then
				local heroPath = G_Path.getKnightIcon(monsterInfo.res_id)
    			icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
    			if value.hp < 1 then 
    				icon:showAsGray(true)
    			end
			end

			local pingji = self:getImageViewByName("Image_pingji_"..index)
			if pingji then
    			pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightBaseInfo and knightBaseInfo.quality or 1))  
    		end

    		self:registerWidgetClickEvent("Image_enemy_"..index, function ( ... )
    			--require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, monsterId)
    		end)
    	else
    		self:showWidgetByName("Image_pingji_"..index, false)
    		self:showWidgetByName("Image_icon_"..index, false)
    		self:showTextWithLabel("Label_dead_"..index, G_lang:get("LANG_LEGION_CHAPTER_LEVEL_NOKIGHT"))
		end
	end

	for loopi = 1, 6, 1 do 
		if not monsterFlag[loopi] then
			self:showWidgetByName("Label_dead_"..loopi, true)
			self:showWidgetByName("Image_progress_"..loopi, false)
			self:showWidgetByName("Label_progress_"..loopi, false)
			self:showWidgetByName("Image_pingji_"..loopi, false)
    		self:showWidgetByName("Image_icon_"..loopi, false)
    		self:showTextWithLabel("Label_dead_"..loopi, G_lang:get("LANG_LEGION_CHAPTER_LEVEL_NOKIGHT"))
		end
	end

	self:registerWidgetClickEvent("Button_fight", function ( ... )
		local dungeonData = G_Me.legionData:getCorpDungeonInfoById(dungeonInfo.id)

		if dungeonData and dungeonData.hp < 1 then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DUNGEON_FINISH_BATTLE",
			 {levelName=dungeonInfo and dungeonInfo.dungeon_name_1 or ""}))
		end

		if G_Me.legionData:getChapterCount() < 1 then 
			return self:_onAddFightCount()
			--return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DUNGEON_NO_BATTLE_COUNT"))
		end

		G_HandlersManager.legionHandler:sendExecuteCorpDungeon(monsterIndex, monsterGroup)
		self:animationToClose()
	end)
end
 

function LegionLevelLayer:_onAddFightCount( ... )
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

function LegionLevelLayer:_onBuyFightCount( ... )
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

return LegionLevelLayer

