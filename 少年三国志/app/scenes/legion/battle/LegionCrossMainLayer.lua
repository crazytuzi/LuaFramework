--LegionCrossMainLayer.lua


local LegionCrossMainLayer = class("LegionCrossMainLayer", UFCCSNormalLayer)


function LegionCrossMainLayer.create( ... )
	return LegionCrossMainLayer.new("ui_layout/Legion_CrossBattleLayer.json")
end

function LegionCrossMainLayer:ctor( ... )
	self._touchStartY = 0
	self._totalMoveDist = 0
	self._clickValid = true
	self._screenSize = CCDirector:sharedDirector():getWinSize()
	self._backSize = self._screenSize

	self._legionCrossCount = 0
	self._legionCrossTimer = nil

	self._legionFreeCount = 0
	self._legionFreeTimer = nil
	self.super.ctor(self, ...)
end

function LegionCrossMainLayer:onLayerLoad( ... )
	self:registerTouchEvent(false,true,0)
	self:enableLabelStroke("Label_level_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_legion_name_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_server_name_1", Colors.strokeBrown, 1 )

	self:enableLabelStroke("Label_level_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_legion_name_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_server_name_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_exp_tip_3", Colors.strokeBrown, 1)

	self:enableLabelStroke("Label_level_4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_legion_name_4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_server_name_4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_exp_tip_4", Colors.strokeBrown, 1)

	self:enableLabelStroke("Label_level_24", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_legion_name_24", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_server_name_24", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_exp_tip_24", Colors.strokeBrown, 1)

	self:enableLabelStroke("Label_level_34", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_legion_name_34", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_server_name_34", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_exp_tip_34", Colors.strokeBrown, 1)

	self:enableLabelStroke("Label_district_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_kill_count", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_acquire_exp", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_legion_contribution", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_kill_count_value", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_acquire_exp_value", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_legion_contribution_value", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_free_title", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_count_down", Colors.strokeBrown, 1)

	self:enableLabelStroke("Label_count_down_cross", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_free_title_cross", Colors.strokeBrown, 1)

	self:registerBtnClickEvent("Button_back", handler(self, self._onBackClick))
	self:registerBtnClickEvent("Button_choose_aim", handler(self, self._onChooseAimClick))
	self:registerBtnClickEvent("Button_member_ret", handler(self, self._onMemberResultClick))
	self:registerBtnClickEvent("Button_clear", handler(self, self._onClearFreeTimeClick))
	self:registerBtnClickEvent("Button_help", handler(self, self._onHelpClick))

	local widget = self:getWidgetByName("Image_back")
    self._backSize = widget:getSize()

	self:_initMainLegionInfo()
	self:_initEnemyLegionInfo()

	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	self:showWidgetByName("Button_choose_aim", detailCorp and detailCorp.position > 0)

	G_HandlersManager.legionHandler:sendGetCrossBattleField()
end

function LegionCrossMainLayer:onLayerEnter( ... )
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVP)
	self:showTextWithLabel("Label_legion_contribution_value", G_Me.userData.corp_point or 0)
	self:showWidgetByName("Image_title", false)
	self:showWidgetByName("Panel_Top", false)
	self:callAfterFrameCount(1, function ( ... )
		self:showWidgetByName("Image_title", true)
		self:showWidgetByName("Panel_Top", true)
		GlobalFunc.flyIntoScreenLR( { self:getWidgetByName("Image_title") }, true, 0.4, 2, 100)
		GlobalFunc.flyIntoScreenLR( { self:getWidgetByName("Panel_Top") }, false, 0.4, 2, 100)	
	end)	

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_MEMBER_INFO, self._onFlushMemberInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_FIRE_ON, self._onChangeFireCorp, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_SET_BATTLE_FIRE_ON, self._onChangeFireCorp, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_FIELD, self._onRefreshBettleFieldInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_RESET_CHALLENGE_CD, self._onResetBattleFreeTime, self)
	--uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_CHALLENGE_ENEMY, self._initBattleFreeTimer, self)

	self:_initBattleFreeTimer()
	self:_initCountDown()
end

function LegionCrossMainLayer:onLayerExit( ... )
	self:_removeLegionCrossTimer()
	self:_removeBattleFreeTimer()
end

function LegionCrossMainLayer:_onBackClick( ... )
    if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end
end

function LegionCrossMainLayer:_onChooseAimClick( ... )
	require("app.scenes.legion.battle.LegionCrossChooseAimLayer").show()
end

function LegionCrossMainLayer:_onMemberResultClick( ... )
    require("app.scenes.legion.battle.LegionCrossResultLayer").show()
end

function LegionCrossMainLayer:_onClearFreeTimeClick( ... )
	if self._legionFreeCount < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_NO_NEED_FREE"))
	end

	local freeCost = G_Me.legionData:getBattleFreshCost()
	if freeCost > G_Me.userData.gold then 
		return require("app.scenes.shop.GoldNotEnoughDialog").show()
	end

	local box = require("app.scenes.tower.TowerSystemMessageBox")
    box.showMessage( box.TypeLegionCross,
            freeCost, 1,
            self._onSureClearFreeTimeCD,
        nil, 
        self )
end

function LegionCrossMainLayer:_onHelpClick( ... )
	require("app.scenes.common.CommonHelpLayer").show({
		{title=G_lang:get("LANG_LEGION_CROSS_HELP_TITLE_1"), content=G_lang:get("LANG_LEGION_CROSS_HELP_CONTENT_1")},
		{title=G_lang:get("LANG_LEGION_CROSS_HELP_TITLE_2"), content=G_lang:get("LANG_LEGION_CROSS_HELP_CONTENT_2")},})
end

function LegionCrossMainLayer:_onSureClearFreeTimeCD( ... )
	if self._legionFreeCount < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_NO_NEED_FREE"))
	end

	G_HandlersManager.legionHandler:sendResetCrossBattleChallengeCD()
end

function LegionCrossMainLayer:_onResetBattleFreeTime( ... )
	self:_initBattleFreeTimer()
	return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_RESET_BATTLE_CD_SUCCESS"))
end


function LegionCrossMainLayer:_onRefreshBettleFieldInfo( ... )
	self:_initEnemyLegionInfo()
end

function LegionCrossMainLayer:_onChangeFireCorp( ... )
	local count = G_Me.legionData:getBattleFieldCount()

	local _initFireInfo = function ( postfix, enemyIndex )
		 if type(enemyIndex) ~= "number" or enemyIndex < 1 or enemyIndex > count then 
		 	return 
		 end

		local enemyInfo = G_Me.legionData:getBattleFieldInfoByIndex(enemyIndex)
		if type(enemyInfo) ~= "table" then 
			return 
		end

		self:showWidgetByName("Image_flag_"..postfix, enemyInfo.fire_on)
	end

	if count == 2 then 
		_initFireInfo("24", 2)
	elseif count == 3 then
		_initFireInfo("34", 2)
		_initFireInfo("3", 3)
	elseif count == 4 then
		_initFireInfo("34", 2)
		_initFireInfo("4", 3)
		_initFireInfo("24", 4)
	end
end

function LegionCrossMainLayer:_initMainLegionInfo( ... )
	local detailCorp = G_Me.legionData:getCorpDetail() or {}

	self:showTextWithLabel("Label_level_1", detailCorp and detailCorp.level or 1)
	self:showTextWithLabel("Label_legion_name_1", detailCorp and detailCorp.name or "")
	self:showTextWithLabel("Label_legion_contribution_value", G_Me.userData.corp_point or 0)
	self:showTextWithLabel("Label_district_name", G_lang:get("LANG_LEGION_CROSS_DISTRICT_FORMAT", {index=G_Me.legionData:getCrossField()}))

	self:registerBtnClickEvent("Button_legion_1", function ( ... )
		G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_CANOT_ATTACK_SELF"))
	end)


end

function LegionCrossMainLayer:_initEnemyLegionInfo( ... )
	local count = G_Me.legionData:getBattleFieldCount()

	self:showWidgetByName("Button_legion_24", (count == 2 or count == 4))
	self:showWidgetByName("Button_legion_34", (count == 3 or count == 4))
	self:showWidgetByName("Button_legion_4", count == 4)
	self:showWidgetByName("Button_legion_3", count == 3)

	local enemyInfo = G_Me.legionData:getBattleFieldInfoByIndex(1)
	if type(enemyInfo) == "table" then 
		self:showTextWithLabel("Label_server_name_1", "["..enemyInfo.sname.."]")
	end

	local _initEnemyInfo = function ( postfix, enemyIndex )
		 if type(enemyIndex) ~= "number" or enemyIndex < 1 or enemyIndex > G_Me.legionData:getBattleFieldCount() then 
		 	return 
		 end

		local enemyInfo = G_Me.legionData:getBattleFieldInfoByIndex(enemyIndex)
		--enemyInfo = G_Me.legionData:getCorpDetail()
		if type(enemyInfo) ~= "table" then 
			return 
		end

		self:registerBtnClickEvent("Button_legion_"..postfix, function ( ... )
			self:_onEnemyLegionClick(enemyIndex)
		end)

		self:showTextWithLabel("Label_server_name_"..postfix, "["..enemyInfo.sname.."]")
		self:showTextWithLabel("Label_legion_name_"..postfix, enemyInfo.name)
		self:showTextWithLabel("Label_exp_tip_"..postfix, G_lang:get("LANG_LEGION_CROSS_EXP_CAN_ROB", {expValue=enemyInfo.each_exp}))
		self:showTextWithLabel("Label_level_"..postfix, enemyInfo.level)
		self:showWidgetByName("Image_flag_"..postfix, enemyInfo.fire_on)
	end

	if count == 2 then 
		_initEnemyInfo("24", 2)
	elseif count == 3 then
		_initEnemyInfo("34", 2)
		_initEnemyInfo("3", 3)
	elseif count == 4 then
		_initEnemyInfo("34", 2)
		_initEnemyInfo("4", 3)
		_initEnemyInfo("24", 4)
	end

	self:_initBattleFreeTimer()
	self:_initMyBattleInfo()
end

function LegionCrossMainLayer:_onFlushMemberInfo( ... )
	self:_initMyBattleInfo()
end

function LegionCrossMainLayer:_initMyBattleInfo( ... )
	local fieldInfo = G_Me.legionData:getBattleFieldInfo()

	self:showTextWithLabel("Label_kill_count_value", fieldInfo and fieldInfo.kill_count or 0)
	self:showTextWithLabel("Label_acquire_exp_value", fieldInfo and fieldInfo.rob_exp or 0)
end

function LegionCrossMainLayer:_initCountDown( ... )
	local crossSectionIndex, countDownTime = G_Me.legionData:getLegionSectionAndCountDown()

	if crossSectionIndex == 5 then
		return self:_onLegionCrossFightEnd()
	elseif crossSectionIndex ~= 4 then
		return __LogError("[LegionCrossMainLayer] wrong cross section index:%d", crossSectionIndex or 0)
	end

	self._legionCrossCount = countDownTime
	self:_removeLegionCrossTimer()
	local _updateLegionCrossTimer = function ( ... )
		if self._legionCrossCount < 0 then 
			self._legionCrossCount = 0
			self:_onLegionCrossFightEnd()
		end
		local min = math.floor((self._legionCrossCount%3600)/60)
		local sec = self._legionCrossCount%60
		self:showTextWithLabel("Label_count_down_cross",
			 G_lang:get("LANG_LEGION_CROSS_PIPEI_FORMAT", 
			 	{minValue=min, secValue=sec}) )
		self._legionCrossCount = self._legionCrossCount - 1	
	end
	if self._legionCrossCount > 0 then
		self._legionCrossTimer = G_GlobalFunc.addTimer( 1, function()
			_updateLegionCrossTimer()
		end)
	end
	_updateLegionCrossTimer()
end

function LegionCrossMainLayer:_removeLegionCrossTimer( ... )
	if self._legionCrossTimer then 
		G_GlobalFunc.removeTimer(self._legionCrossTimer)
        self._legionCrossTimer = nil
	end
end

function LegionCrossMainLayer:_initBattleFreeTimer( ... )
	self:_removeBattleFreeTimer()

	self:showTextWithLabel("Label_count_down",
			 G_lang:get("LANG_LEGION_CROSS_FREE_FORMAT", 
			 	{secValue=0}) )

	local freeCD = G_Me.legionData:getBattleFreeTimeCD()
	--local time = G_ServerTime:getTime()
	if type(freeCD) ~= "number" then 
		return 
	end

	self._legionFreeCount = freeCD
	local _updateBattleFreeTimer = function ( ... )
		if self._legionFreeCount < 0 then 
			self._legionFreeCount = 0
			self:_removeBattleFreeTimer()
			self:showWidgetByName("Label_free_title", self._legionFreeCount > 0 )
			self:showWidgetByName("Label_click_to_battle", self._legionFreeCount < 1 )
		end
		self:showTextWithLabel("Label_count_down",
			 G_lang:get("LANG_LEGION_CROSS_FREE_FORMAT", 
			 	{secValue=self._legionFreeCount}) )
		self._legionFreeCount = self._legionFreeCount - 1	
	end
	if self._legionFreeCount > 0 then
		self._legionFreeTimer = G_GlobalFunc.addTimer(1, function ( ... )
			_updateBattleFreeTimer()
		end)
		_updateBattleFreeTimer()
	end	

	self:showWidgetByName("Label_free_title", self._legionFreeCount > 0 )
	self:showWidgetByName("Label_click_to_battle", self._legionFreeCount < 1 )
end

function LegionCrossMainLayer:_removeBattleFreeTimer( ... )
	if self._legionFreeTimer then 
		G_GlobalFunc.removeTimer(self._legionFreeTimer)
        self._legionFreeTimer = nil
	end
end

function LegionCrossMainLayer:_onLegionCrossFightEnd( ... )
	self:_removeLegionCrossTimer()

	G_HandlersManager.legionHandler:sendGetCorpCrossBattleInfo()
	uf_sceneManager:replaceScene(require("app.scenes.legion.battle.LegionCrossDateScene").new())
end

function LegionCrossMainLayer:_onEnemyLegionClick( enemyIndex )
	if not self._clickValid then 
		return 
	end

    require("app.scenes.legion.battle.LegionCrossChooseEnemyLayer").show(enemyIndex)
end

function LegionCrossMainLayer:onTouchBegin( xpos, ypos )
	self._touchStartY = ypos
	self._clickValid = true
	self._totalMoveDist = 0

	return true
end

function LegionCrossMainLayer:onTouchMove( xpos, ypos )
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

function LegionCrossMainLayer:_scrollWithOffset( offset )
	offset = offset or 0
	local effectMoveOffset = function ( offset )
		local backImg = self:getWidgetByName("Image_back")
		local posx, posy = backImg:getPosition()
		
		if offset > 0 then
			if posy - self._backSize.height/2 + 100 < 0 then 
				return (offset > self._backSize.height/2 - posy - 100) and (self._backSize.height/2 - posy - 100) or offset
			else
				return 0
			end
		elseif offset < 0 then
			if posy + self._backSize.height/2 > self._screenSize.height - 80 then 
				return (offset < self._screenSize.height - 80 - posy - self._backSize.height/2) and 
				(self._screenSize.height - 80 - posy - self._backSize.height/2) or offset
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

function LegionCrossMainLayer:_doScrollWithOffset( name, offset, animation )
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

return LegionCrossMainLayer
