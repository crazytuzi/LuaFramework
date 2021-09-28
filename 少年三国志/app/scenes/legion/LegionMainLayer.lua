--LegionMainLayer.lua

require("app.cfg.corps_info")
require("app.const.ShopType")

local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local LegionMainLayer = class("LegionMainLayer", UFCCSNormalLayer)

function LegionMainLayer.create( ... )
	return LegionMainLayer.new("ui_layout/legion_LegionMainLayer.json")
end

function LegionMainLayer:ctor( ... )
	self._touchStartY = 0
	self._totalMoveDist = 0
	self._clickValid = true
	self._screenSize = CCDirector:sharedDirector():getWinSize()
	self._backSize = self._screenSize
	self._tipPosList = {}
	self.super.ctor(self, ...)
end

function LegionMainLayer:onLayerLoad( _, _, scenePack )
	G_GlobalFunc.savePack(self, scenePack)

	self:registerTouchEvent(false,true,0)
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_gongxian", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_gongxian_value", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress", Colors.strokeBrown, 1 )

	self:registerBtnClickEvent("Button_hall", handler(self, self._onHallClick))
	self:registerBtnClickEvent("Button_hall_copy", handler(self, self._onHallClick))

	self:registerBtnClickEvent("Button_shop", handler(self, self._onShopClick))
	self:registerBtnClickEvent("Button_shop_copy", handler(self, self._onShopClick))
	self:registerBtnClickEvent("Button_shop_copy2", handler(self, self._onShopClick))

	self:registerBtnClickEvent("Button_Sacrifice", handler(self, self._onSacrificeClick))
	self:registerBtnClickEvent("Button_Sacrifice_copy", handler(self, self._onSacrificeClick))
	self:registerBtnClickEvent("Button_Sacrifice_award_copy", handler(self, self._onSacrificeClick))

	self:registerBtnClickEvent("Button_dungeon", handler(self, self._onDungeonClick))
	self:registerBtnClickEvent("Button_dungeon_copy", handler(self, self._onDungeonClick))

	self:registerBtnClickEvent("Button_tiaoxin", handler(self, self._onTiaoxinClick))
	self:registerBtnClickEvent("Button_tiaoxin_copy", handler(self, self._onTiaoxinClick))
	self:registerBtnClickEvent("Button_battle", handler(self, self._onLegionBattleClick))

	self:registerBtnClickEvent("Button_levelUp", handler(self, self._onLevelUpClick))

	self:registerBtnClickEvent("Button_back", handler(self, self._onBackClick))
	self:registerBtnClickEvent("Button_order_list", handler(self, self._onLegionOrderListClick))

	self:registerBtnClickEvent("Button_tipBtn", handler(self, self._onTrumpetClick))
	self:registerBtnClickEvent("Button_help", function ( ... )
		require("app.scenes.common.CommonHelpLayer").show({{title=G_lang:get("LANG_LEGION_HELP_MAIN_TITLE"), content=G_lang:get("LANG_LEGION_HELP_MAIN")},})
		--require("app.scenes.legion.LegionHelpLayer").show(G_lang:get("LANG_LEGION_HELP_MAIN_TITLE"), G_lang:get("LANG_LEGION_HELP_MAIN"))
	end)

	local widget = self:getWidgetByName("Image_back")
    self._backSize = widget:getSize()
	--self:showWidgetByName("Image_tip", false)	

	self:_updateCorpDetail()

	self:_updateBtnFlag()

	G_HandlersManager.legionHandler:sendGetCorpJoinMember()
	G_HandlersManager.legionHandler:sendGetCorpWorship()

	if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		local effect  = EffectNode.new("effect_juntuan")
    	effect:play()
    	local widget = self:getWidgetByName("Image_back")
    	if widget then 
    		widget:addNode(effect)
    	end

    	effect  = EffectNode.new("effect_talei")
    	effect:play()
    	local widget = self:getWidgetByName("Button_dungeon")
    	if widget then 
    		widget:addNode(effect)
    	end
    end
    G_HandlersManager.legionHandler:sendGetCorpDetail()
end

function LegionMainLayer:onLayerEnter( ... )
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
	local corpCrossOpen = (G_Setting:get("corp_cross_open") == "1")
	if G_Me.legionData:hasCorpCrossValid() and corpCrossOpen then 
		if not G_Me.legionData:isBattleTimeReady() then 
			G_HandlersManager.legionHandler:sendGetCorpCrossBattleTime()	
		end

		G_HandlersManager.legionHandler:sendGetCorpCrossBattleInfo()	
	end
	-- local detailCorp = G_Me.legionData:getCorpDetail() or {}
	-- if detailCorp and detailCorp.notification and #detailCorp.notification > 0 then 
	-- 	self:callAfterDelayTime(1.0, nil, function ( ... )
	-- 		self:_onTrumpetClick()
	-- 	end)
	-- end	

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, self._onNotifyCorpDismiss, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_DETAIL, self._updateCorpDetail, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_UPLEVEL, self._updateCorpDetail, self)
	
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_FLAG_CAN_WORSHIP, self._udpateSacrificeFlag, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_WORSHIP_AWARD, self._udpateSacrificeFlag, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_FLAG_CAN_HIT_EGGS, self._udpateDungeonCorpFlag, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_APPLY, self._udpateCorpHallFlag, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_TIMES, self._udpateTiaoxinFlag, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
        G_HandlersManager.legionHandler:disposeCorpDismiss(obj, dismiss)
    end, self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_LEVEL_BROADCAST, self._updateCorpDetail, self)

	self:_udpateCorpShopFlag()
end

function LegionMainLayer:_onHallClick( ... )
	if not self._clickValid then
		return 
	end
	uf_sceneManager:replaceScene(require("app.scenes.legion.LegionHallScene").new())
end

function LegionMainLayer:_onSacrificeClick( ... )
	if not self._clickValid then
		return 
	end
	uf_sceneManager:replaceScene(require("app.scenes.legion.LegionSacrificeScene").new())
end

function LegionMainLayer:_onDungeonClick( ... )
	if not self._clickValid then
		return 
	end
	if not G_Me.legionData:getDungeonOpen(1) then
		G_MovingTip:showMovingTip(G_lang:get("LANG_NEW_LEGION_DUNGEON_NOT_OPEN"))
		return 
	end
	uf_sceneManager:replaceScene(require("app.scenes.legion.LegionNewDungeionScene").new())
end

function LegionMainLayer:_onTiaoxinClick( ... )
	if not self._clickValid then
		return 
	end

	local corpCrossOpen = (G_Setting:get("corp_cross_open") == "1")
	if not corpCrossOpen then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_HOPEFUL_MODULE"))
	end

	if not G_Me.legionData:isBattleTimeReady() and G_Me.legionData:hasCorpCrossValid() then 
		G_HandlersManager.legionHandler:sendGetCorpCrossBattleTime()
		-- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_TIMES, self._onTiaoxinClick, self)
		
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_NOT_OPEN"))
	end

	local crossState,crossTime = G_Me.legionData:getLegionSectionAndCountDown()
	if crossState == 5 and crossTime < 0 then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_NOT_OPEN"))
	end

	if not G_Me.legionData:hasCorpCrossValid() then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_LOCKED"))
	end

	if G_Me.legionData:isOnBattle() and G_Me.legionData:hasApply() then
		uf_sceneManager:replaceScene(require("app.scenes.legion.battle.LegionCrossMainScene").new())
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.battle.LegionCrossDateScene").new())
	end
end

function LegionMainLayer:_onLegionBattleClick( ... )
	if not self._clickValid then
		return 
	end
	if not G_Me.legionData:isTechFunctionOpen() then
		G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TECH_NOT_OPEN"))
		return 
	end
	-- return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_HOPEFUL_MODULE"))
	uf_sceneManager:replaceScene(require("app.scenes.legion.LegionTechScene").new())
end

function LegionMainLayer:_onLevelUpClick( ... )
	if not self._clickValid then
		return 
	end

	local layer = require("app.scenes.legion.LegionLevelUpLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)
end

function LegionMainLayer:_onShopClick( ... )
	-- body
	if not self._clickValid then
		return 
	end
	uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.JUN_TUAN))
end

function LegionMainLayer:_onBackClick( ... )
	if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		local packScene = G_GlobalFunc.createPackScene(self)
    	if not packScene then 
    	    packScene = require("app.scenes.mainscene.MainScene").new()
    	end
    	uf_sceneManager:replaceScene(packScene)
	end
end

function LegionMainLayer:_onLegionOrderListClick( ... )
	require("app.scenes.legion.LegionOrderListLayer").show()
end

function LegionMainLayer:_onTrumpetClick( ... )
	local widget = self:getWidgetByName("Image_tip")
	if not widget then 
		return 
	end

	widget:stopAllActions()
	if widget:isVisible() then 
		widget:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.2, 0), CCCallFunc:create(function ( ... )
			widget:setVisible(false)
		end)))
	else
		widget:setScale(0)
		widget:setVisible(true)
		local arr = CCArray:create()
		arr:addObject(CCScaleTo:create(0.2, 1))
		arr:addObject(CCDelayTime:create(5.0))
		arr:addObject(CCCallFunc:create(function ( ... )
			self:_onTrumpetClick()
		end))
		widget:runAction(CCSequence:create(arr))
	end
end

function LegionMainLayer:_updateCorpDetail( ... )

	local detailCorp = G_Me.legionData:getCorpDetail() or {}

	self:showTextWithLabel("Label_level", detailCorp.level or 1)
	self:showTextWithLabel("Label_name", detailCorp.name or "")

	self:showTextWithLabel("Label_gongxian_value", G_Me.userData.corp_point or 0)
	--self:showTextWithLabel("Label_gongxian", G_lang:get("LANG_LEGION_CORP_CONTRIBUTION", {contribution=G_Me.userData.corp_point or 0}) )
	self:showTextWithLabel("Label_notice_content", detailCorp.notification or "")
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
		local percent = curExp > maxExp and maxExp or curExp
		local percent = maxExp > 0 and (percent*100)/maxExp or 0
		progressBar:runToPercent(percent, 0.2)
	end

	local info = corps_info.get(G_Me.legionData:getCorpDetail().level)
	local state1 = info.exp <= G_Me.legionData:getCorpDetail().exp
	local state2 = (corps_info.get(G_Me.legionData:getCorpDetail().level+1) ~= nil)
	local state3 = G_Me.legionData:getCorpDetail().position > 0
	self:getButtonByName("Button_levelUp"):setVisible(state1 and state2 and state3)
	if state1 and state2 and not self._tEff1 then
	    self._tEff1 = EffectNode.new("effect_jtzc_dengji", function(event, frameIndex) end)
	    self._tEff1:setScale(1)
	    self._tEff1:setPositionXY(0,0)
	    self:getImageViewByName("Image_24"):addNode(self._tEff1, 1)
	    self._tEff1:play()
	    self._tEff2 = EffectNode.new("effect_jtzc_loading", function(event, frameIndex) end)
	    self._tEff2:setScale(1)
	    self._tEff2:setPositionXY(5,-5)
	    self:getImageViewByName("Image_progress_back"):addNode(self._tEff2, 0)
	    self._tEff2:play()
	end
	if self._tEff1 and not (state1 and state2) then 
		self._tEff1:stop()
		self._tEff1:removeFromParentAndCleanup(true)
		self._tEff1 = nil
		self._tEff2:stop()
		self._tEff2:removeFromParentAndCleanup(true)
		self._tEff2 = nil
	end
end

function LegionMainLayer:_updateBtnFlag( ... )
	self:_udpateSacrificeFlag()
	self:_udpateDungeonCorpFlag()
	self:_udpateCorpHallFlag()
	self:_udpateCorpShopFlag()
	self:_udpateTiaoxinFlag()
end

function LegionMainLayer:_udpateSacrificeFlag( ... )
	local canWorship = G_Me.legionData:canWorship()
	local haveWorshipAward = G_Me.legionData:haveWorshipAward()

	self:showWidgetByName("Image_sacrifice_award_tip", haveWorshipAward)
	self:showWidgetByName("Image_sacrifice_tip", not haveWorshipAward and canWorship)
	self:tipMove("Image_sacrifice_award_tip")
	self:tipMove("Image_sacrifice_tip")
end

function LegionMainLayer:_udpateDungeonCorpFlag( ... )
	if self.tips == nil then
	    self.tips = EffectNode.new("effect_knife", 
	        function(event, frameIndex)
	            if event == "finish" then
	         
	            end
	        end
	    )
	    self.tips:play()
	    self.tips:setVisible(false)
	    self:getButtonByName("Button_dungeon"):addNode(self.tips) 
	    self.tips:setZOrder(10)
	    self.tips:setPosition(ccp(self:getWidgetByName("Image_dungeon_tip"):getPosition()))
	end
	local fightTip = G_Me.legionData:getNewChapterFightTip()
	local awardTip = G_Me.legionData:getNewChapterMapNeedTip()
	self:showWidgetByName("Image_dungeon_tip", awardTip)
	self:tipMove("Image_dungeon_tip")
	self.tips:setVisible(not awardTip and fightTip)
end

function LegionMainLayer:_udpateTiaoxinFlag( ... )
	local crossState = G_Me.legionData:getLegionSectionAndCountDown()
	local state = G_Me.legionData:isBattleTimeReady() and G_Me.legionData:hasCorpCrossValid() and crossState > 1 and crossState < 5
	self:showWidgetByName("Image_tiaoxin_tip", state)
	self:tipMove("Image_tiaoxin_tip")
end

function LegionMainLayer:_udpateCorpHallFlag( ... )
	self:showWidgetByName("Image_hall_tip", G_Me.legionData:hasCorpApply())
	self:tipMove("Image_hall_tip")
end

function LegionMainLayer:_udpateCorpShopFlag( ... )
	self:showWidgetByName("Image_shop_tip", G_Me.shopData:checkAwardTipsByType(6))
	self:showWidgetByName("Image_shop_tip2",not G_Me.shopData:checkAwardTipsByType(6) and G_Me.shopData:getJunTuanHasNewData() )
	self:tipMove("Image_shop_tip")
	self:tipMove("Image_shop_tip2")
end
function LegionMainLayer:_onNotifyCorpDismiss( dismiss )
	if type(dismiss) ~= "number" then 
		dismiss = 0 
	end

	if dismiss == 0 then 
		G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_NOTIFY_DISMISS_MEMBER"))
	elseif dismiss == 1 then 
		G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_NOTIFY_DISMISS_CORP"))
	end
	uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new())
end


function LegionMainLayer:onTouchBegin( xpos, ypos )
	self._touchStartY = ypos
	self._clickValid = true
	self._totalMoveDist = 0

	return true
end

function LegionMainLayer:onTouchMove( xpos, ypos )
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

function LegionMainLayer:_scrollWithOffset( offset )
	offset = offset or 0
	local effectMoveOffset = function ( offset )
		local backImg = self:getWidgetByName("Image_back")
		local posx, posy = backImg:getPosition()
		
		if offset > 0 then
			if posy - self._backSize.height/2 + 50 < 0 then 
				return (offset > self._backSize.height/2 - posy - 50) and (self._backSize.height/2 - posy - 50) or offset
			else
				return 0
			end
		elseif offset < 0 then
			if posy + self._backSize.height/2 > self._screenSize.height - 100 then 
				return (offset < self._screenSize.height - 100 - posy - self._backSize.height/2) and 
				(self._screenSize.height - 100 - posy - self._backSize.height/2) or offset
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

function LegionMainLayer:_doScrollWithOffset( name, offset, animation )
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

function LegionMainLayer:tipMove( name, move )
	local widget = self:getWidgetByName(name)
	move = move or widget:isVisible()
	widget:stopAllActions()
	if self._tipPosList[name] then
		local pos = self._tipPosList[name]
		widget:setPosition(ccp(pos.x, pos.y))
	else
		local posx,posy = widget:getPosition()
		self._tipPosList[name] = {x=posx,y=posy}
	end
	if move then
		widget:setScale(0.38)
		widget:runAction(CCSequence:createWithTwoActions(CCEaseBounceOut:create(CCScaleTo:create(0.5, 1)), CCCallFunc:create(function()
		    widget:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(0.4, ccp(0, 5)), CCMoveBy:create(0.4, ccp(0, -5)))))
		end)))
	end
end


return LegionMainLayer

