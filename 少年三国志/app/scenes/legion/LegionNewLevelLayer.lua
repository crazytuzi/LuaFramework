--LegionLevelLayer.lua

require("app.cfg.monster_team_info")
require("app.cfg.corps_dungeon_info")
require("app.cfg.monster_info")
require("app.cfg.corps_dungeon_tips_info")

local LegionNewLevelLayer = class("LegionLevelLayer", UFCCSModelLayer)

function LegionNewLevelLayer.show( ... )
	local legionLayer = LegionNewLevelLayer.new("ui_layout/legion_DungeonNewLevel.json", Colors.modelColor, ...)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer)
	end
end

function LegionNewLevelLayer:ctor( ... )
	self.super.ctor(self, ...)

	self:enableLabelStroke("Label_level_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_hpTitle", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_hp", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_awardName", Colors.strokeBrown, 1 )
	self:showTextWithLabel("Label_hpTitle", G_lang:get("LANG_NEW_LEGION_HP"))

end

function LegionNewLevelLayer:onLayerLoad( _, _, dungeonInfo )
	self:registerWidgetClickEvent("Button_buzheng", function ( ... )
		require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer( function ( ... )
    	end)
	end)
	self:registerWidgetClickEvent("Button_close", handler(self, self._onCloseClick))
	--self:registerWidgetClickEvent("Button_fight", handler(self, self._onFightClick))

	self:_initMonsters( dungeonInfo )

	self:_initLevelInfo()
end

function LegionNewLevelLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RESET_NEW_DUNGEON_COUNT, self._initLevelInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_CHATER_INFO, self._initLevelInfo, self)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function LegionNewLevelLayer:_initLevelInfo( ... )
	self:showTextWithLabel("Label_fight_count", G_lang:get("LANG_NEW_LEGION_FIGHT_MAX_FORMAT")..G_Me.legionData:getNewBuyTimes())
end

function LegionNewLevelLayer:_onCloseClick( ... )
	self:animationToClose()
end

function LegionNewLevelLayer:_initMonsters( corpDungeon )
	local monsterIndex = corpDungeon.id 
	local dungeonInfo = corps_dungeon_info.get(monsterIndex) 
	local countyId = dungeonInfo.country

	self:showTextWithLabel("Label_level_name", dungeonInfo.dungeon_name_1)
	local dungeonTipInfo = corps_dungeon_tips_info.get(countyId)
	self:showTextWithLabel("Label_desc", dungeonTipInfo and dungeonTipInfo.tips or "")

	self:showTextWithLabel("Label_tip", G_lang:get("LANG_LEGION_CORP_LASTFIGHT_TIP", {expCount = dungeonInfo.corps_exp}))

	local img = self:getImageViewByName("Image_zhengyin")
	if img then 
	 	img:loadTexture(G_Path.getKnightGroupIcon(dungeonTipInfo and dungeonTipInfo.icon or 1))
	end

	local progress = corpDungeon.max_hp > 0 and (corpDungeon.hp*100)/corpDungeon.max_hp or 0
	self:showTextWithLabel("Label_progress_text", string.format("%.0f%%", progress))
	local progressBar = self:getLoadingBarByName("ProgressBar_hp")
	if progressBar then 
		progressBar:runToPercent(progress, 0.2)
	end
	self:showTextWithLabel("Label_hp", corpDungeon.hp.."/"..corpDungeon.max_hp)
	local labelHpTitle = self:getLabelByName("Label_hpTitle")
	local labelHp = self:getLabelByName("Label_hp")
	local width1 = labelHpTitle:getContentSize().width
	local width2 = labelHp:getContentSize().width
	labelHpTitle:setPositionXY(-width2/2-8,-2)
	labelHp:setPositionXY(width1/2+8,-2)

	self:showTextWithLabel("Label_awardTitle1", G_lang:get("LANG_NEW_LEGION_FIGHT_AWARD_TITLE1"))
	self:showTextWithLabel("Label_awardTitle2", G_lang:get("LANG_NEW_LEGION_FIGHT_AWARD_TITLE2"))
	self:showTextWithLabel("Label_awardValue1", G_lang:get("LANG_NEW_LEGION_FIGHT_AWARD_VALUE1",{exp=dungeonInfo.corps_exp}))

	local g = G_Goods.convert(20, 0)
	self:showTextWithLabel("Label_awardName", g.name)
	self:getLabelByName("Label_awardName"):setColor(Colors.qualityColors[g.quality])
	self:showTextWithLabel("Label_awardNum", G_lang:get("LANG_NEW_LEGION_FIGHT_AWARD_NUM",{min=dungeonInfo.min_award,max=dungeonInfo.max_award}))
	local imgBorder = self:getImageViewByName("Image_border")
	if imgBorder then 
	 	imgBorder:loadTexture(G_Path.getEquipColorImage(g.quality))
	end
	local imgItem = self:getImageViewByName("Image_awardItem")
	if imgItem then 
	 	imgItem:loadTexture(g.icon)
	end

	local award = G_Goods.convert(dungeonInfo.final_award_type, dungeonInfo.final_award_value)
	local txt = G_lang:get("LANG_NEW_LEGION_FIGHT_AWARD_DESC", 
		{texturePath=award.icon_mini, textureType=award.texture_type,num=dungeonInfo.final_award_size}) 
	if self._richLabel then
		self._richLabel:clearRichElement()
		self._richLabel:appendContent(txt, Colors.darkColors.DESCRIPTION)
		self._richLabel:reloadData()
	else
		local label = self:getLabelByName("Label_tip")
		label:setVisible(false)
		local size = label:getSize()
		local parent = label:getParent()
		local richLabel = CCSRichText:create(size.width+100, size.height+20)
		richLabel:setFontName(label:getFontName())
		richLabel:setFontSize(label:getFontSize())
		richLabel:setShowTextFromTop(true)
		local posx,posy = label:getPosition()
		richLabel:setPositionXY(posx+75,posy)
		parent:addChild(richLabel, 5)
		richLabel:setClippingEnabled(true)
		self._richLabel = richLabel
		self._richLabel:clearRichElement()
		self._richLabel:appendContent(txt, Colors.darkColors.DESCRIPTION)
		self._richLabel:reloadData()
	end

	self:registerWidgetClickEvent("Button_fight", function ( ... )
		local dungeonData = G_Me.legionData:getNewDungeonInfo(dungeonInfo.id)

		if dungeonData and dungeonData.hp < 1 then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DUNGEON_FINISH_BATTLE",
			 {levelName=dungeonInfo and dungeonInfo.dungeon_name_1 or ""}))
		end

		if G_Me.legionData:getNewBuyTimes() < 1 then 
			return self:_onAddFightCount()
			--return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DUNGEON_NO_BATTLE_COUNT"))
		end

		G_HandlersManager.legionHandler:sendExecuteNewCorpDungeon(dungeonInfo.id)
		self:animationToClose()
	end)
end
 

function LegionNewLevelLayer:_onAddFightCount( ... )
	
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

function LegionNewLevelLayer:_onBuyFightCount( ... )

	if G_Me.legionData:getNewNextGold() > G_Me.userData.gold then 
		return require("app.scenes.shop.GoldNotEnoughDialog").show()
	end

	G_HandlersManager.legionHandler:sendResetNewDungeonCount()
end

return LegionNewLevelLayer

