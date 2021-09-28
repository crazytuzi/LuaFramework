--LegionCrossChooseEnemyLayer.lua


require("app.cfg.knight_info")
require("app.cfg.corps_value_info")

local knightPic = require("app.scenes.common.KnightPic")
local LegionCrossChooseEnemyLayer = class("LegionCrossChooseEnemyLayer", UFCCSModelLayer)

function LegionCrossChooseEnemyLayer.show( ... )
	local legionLayer = LegionCrossChooseEnemyLayer.new("ui_layout/Legion_CrossChooseEnemy.json", Colors.modelColor, ...)
	if legionLayer then 
		uf_sceneManager:getCurScene():addChild(legionLayer, 1, 0)
	end
end

function LegionCrossChooseEnemyLayer:ctor( ... )
	self._enemyCorpIndex = 0
	self._legionList = nil
	self._legionFreeCount = 0
	self._challegeCD = 0
	self._refreshCD = 0
	self._corpSid = 0
	self._corpId = 0
	self._refreshCDTimer = nil
	self.super.ctor(self, ...)

	self:enableLabelStroke("Label_self_level", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_self_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_enemy_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_enemy_level", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_tip", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_title", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_count_down", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_free_time", Colors.strokeBrown, 1 )

	self:enableLabelStroke("Label_server_name_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_power_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_fight_times_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_fightTitle1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_fightValue1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_server_name_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_power_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_fight_times_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_fightTitle2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_fightValue2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_server_name_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_power_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_fight_times_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_fightTitle3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_fightValue3", Colors.strokeBrown, 1 )
end

function LegionCrossChooseEnemyLayer:onLayerLoad( _, _, enemyIndex )
	self:registerBtnClickEvent("Button_close", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_clear", handler(self, self._onClearFreeTimeClick))
	self:registerBtnClickEvent("Button_change", handler(self, self._onRefreshEnemyClick))

	self:_initMyLegion()
	
	self:_initEnemyLegion(enemyIndex or 2)
	self:closeAtReturn(true)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_BATTLE_INFO, self._onCorpInfoChange, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_ENEMYS, self._onReceiveRefreshEnemyResult, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_RESET_CHALLENGE_CD, self._onResetChallengeCD, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_CHALLENGE_ENEMY, self._onExecuteBattleResult, self)
end

function LegionCrossChooseEnemyLayer:onLayerEnter( ... )
	self:showAtCenter(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")

	self:_onCorpInfoChange()
	self:_initRefreshBtn()
	self:_initBattleFreeTimer()
	self:_onRefreshBattleEnemys()
end

function LegionCrossChooseEnemyLayer:onLayerExit( ... )
	self:_removeBattleFreeTimer()
	self:_removeRefreshCD()
end

function LegionCrossChooseEnemyLayer:_onCancelClick( ... )
	self:animationToClose()
end

function LegionCrossChooseEnemyLayer:_initMyLegion( ... )
	local enemyInfo = G_Me.legionData:getBattleFieldInfoByIndex(1)
	if not enemyInfo then 
		return 
	end

    self:showTextWithLabel("Label_self_level", G_lang:get("LANG_LEGION_CROSS_LEVEL_FORMAT", {levelValue=enemyInfo.level or 1}) )
    self:showTextWithLabel("Label_self_name", enemyInfo.name or "")
    self:showTextWithLabel("Label_self_server", "["..(enemyInfo.sname or "").."]")
    self:showTextWithLabel("Label_self_acquire_tip", G_lang:get("LANG_LEGION_CROSS_ROB_EXP_TITLE1"))
    self:showTextWithLabel("Label_self_exp", G_lang:get("LANG_LEGION_CROSS_ROB_EXP_FORMAT", {expValue=enemyInfo.rob_exp}))

    local img = self:getImageViewByName("Image_self_icon")
    if img then 
        img:loadTexture(G_Path.getLegionIconByIndex(enemyInfo.icon_pic))
    end
    img = self:getImageViewByName("Image_self_icon_back")
    if img then 
        img:loadTexture(G_Path.getLegionIconBackByIndex(enemyInfo.icon_frame))
    end
end

function LegionCrossChooseEnemyLayer:_onCorpInfoChange( ... )
	local enemyInfo = G_Me.legionData:getBattleFieldInfoByIndex(self._enemyCorpIndex)
	if enemyInfo then 
		self:showTextWithLabel("Label_enemy_exp", G_lang:get("LANG_LEGION_CROSS_ROB_EXP_FORMAT", {expValue=enemyInfo.rob_exp}))
		self:showTextWithLabel("Label_self_exp", G_lang:get("LANG_LEGION_CROSS_ROB_EXP_FORMAT", {expValue=enemyInfo.robbed_exp}))
	end
end

function LegionCrossChooseEnemyLayer:_initEnemyLegion( enemyIndex )
	if type(enemyIndex) ~= "number" or enemyIndex < 1 then 
		return 
	end

	local enemyInfo = G_Me.legionData:getBattleFieldInfoByIndex(enemyIndex)
	if not enemyInfo then
		return	
	end

	self._enemyCorpIndex = enemyIndex
	self._corpSid = enemyInfo.sid
	self._corpId = enemyInfo.corp_id

	if not G_Me.legionData:hasBattleEnemysBySid(enemyInfo.sid, enemyInfo.corp_id) then
		G_HandlersManager.legionHandler:sendGetCrossBattleEnemyCorp(enemyInfo.sid, enemyInfo.corp_id, false)
	end

    self:showTextWithLabel("Label_enemy_level", G_lang:get("LANG_LEGION_CROSS_LEVEL_FORMAT", {levelValue=enemyInfo.level or 1}) )
    self:showTextWithLabel("Label_enemy_name", enemyInfo.name or "")
    self:showTextWithLabel("Label_enemy_server", "["..(enemyInfo.sname or "").."]")
    self:showTextWithLabel("Label_enemy_acquire_tip", G_lang:get("LANG_LEGION_CROSS_ROB_EXP_TITLE2"))
    self:showTextWithLabel("Label_enemy_exp", G_lang:get("LANG_LEGION_CROSS_ROB_EXP_FORMAT", {expValue=enemyInfo.rob_exp}))
    --self:showTextWithLabel("Label_tip", enemyInfo.)

    self:showTextWithLabel("Label_tip", G_lang:get("LANG_LEGION_CROSS_EXP_CAN_ROB_WHEN_SUCCESS", {expValue=enemyInfo.each_exp}))
    local img = self:getImageViewByName("Image_enemy_icon")
    if img then 
        img:loadTexture(G_Path.getLegionIconByIndex(enemyInfo.icon_pic))
    end
    img = self:getImageViewByName("Image_enemy_icon_back")
    if img then 
        img:loadTexture(G_Path.getLegionIconBackByIndex(enemyInfo.icon_frame))
    end
end

function LegionCrossChooseEnemyLayer:_onClearFreeTimeClick( ... )
	if self._legionFreeCount < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_NO_NEED_FREE"))
	end

	local freeCost = G_Me.legionData:getBattleFreshCost()
	if freeCost == 0 then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_MAX_FREE"))
	end
	if freeCost > G_Me.userData.gold then 
		return require("app.scenes.shop.GoldNotEnoughDialog").show(nil, 2)
	end

	local box = require("app.scenes.tower.TowerSystemMessageBox")
    box.showMessage( box.TypeLegionCross,
            freeCost, 1,
            self._onSureClearFreeTimeCD,
        nil, 
        self )
end

function LegionCrossChooseEnemyLayer:_onReceiveRefreshEnemyResult( ret, isRefresh, isFinish )
	self:_onRefreshBattleEnemys()
	self:_initRefreshBtn()

	if isFinish then 
		G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_ALL_ENEMYS_DEAD"))
	elseif isRefresh then 
		G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_REFRESH_SUCCESS"))
	end
end

function LegionCrossChooseEnemyLayer:_onRefreshBattleEnemys( ... )
	local battleEnemys = G_Me.legionData:getBattleEnemysBySid(self._corpSid, self._corpId)
	if not battleEnemys then 
		return 
	end

	local loopi = 1
	for key, value in pairs(battleEnemys) do 

		self:showWidgetByName("Image_enemy_"..loopi, true)
		self:showTextWithLabel("Label_server_name_"..loopi, value.name)
		self:showTextWithLabel("Label_power_"..loopi, G_lang:get("LANG_MOSHEN_ATTACK_VALUE", 
			{rank=GlobalFunc.ConvertNumToCharacter(value.fight_value)}) )

		local valueInfo = corps_value_info.get(22)
		self:showTextWithLabel("Label_fight_times_"..loopi,
		 G_lang:get("LANG_LEGION_CROSS_CHALLOGE_TIMES_FORMAT", 
		 	{curValue=value.times, maxValue=valueInfo and valueInfo.value or 20}) )

		local panel = self:getWidgetByName("Panel_knight_"..loopi)
		local knightInfo = knight_info.get(value.main_role)
		if knightInfo and panel then
			panel:removeAllChildren()

			local enemyName = self:getLabelByName("Label_server_name_"..loopi)
			if enemyName then 
				enemyName:setColor(Colors.qualityColors[knightInfo and knightInfo.quality or 1])
			end

			local resId = knightInfo.res_id
			resId = G_Me.dressData:getDressedResidWithClidAndCltm(value.main_role, value.dress_id,
				value.clid,value.cltm,value.clop)

			local knightBtn = knightPic.createKnightButton(resId, panel, "enemy_"..loopi, self, function ( ... )
				self:_onEnemyClick(value.id, value.times, valueInfo.value or 20)
			end, true)

			if rawget(value,"score") then
				self:showTextWithLabel("Label_fightTitle"..loopi, G_lang:get("LANG_LEGION_CROSS_ROB_GET"))
				self:showTextWithLabel("Label_fightValue"..loopi, value.score)
				self:showWidgetByName("Label_fightTitle"..loopi, true)
				self:showWidgetByName("Label_fightValue"..loopi, true)
			else
				self:showWidgetByName("Label_fightTitle"..loopi, false)
				self:showWidgetByName("Label_fightValue"..loopi, false)
			end
		end

		loopi = loopi + 1
	end

	for loopj = loopi, 3 do 
		self:showWidgetByName("Image_enemy_"..loopj, false)
	end
end

function LegionCrossChooseEnemyLayer:_onEnemyClick( userId, curTimes, maxTimes )
	if self._legionFreeCount > 0 then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_BATTLE_IN_CD"))
	end

	if type(curTimes) == "number" and type(maxTimes) == "number" and curTimes >= maxTimes then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_MAX_CHALLAGE_TIMES"))
	end

	G_HandlersManager.legionHandler:sendCrossBattleChallengeEnemy(self._corpSid, self._corpId, userId)
end

function LegionCrossChooseEnemyLayer:_onSureClearFreeTimeCD( ... )
	if self._legionFreeCount < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_NO_NEED_FREE"))
	end

	G_HandlersManager.legionHandler:sendResetCrossBattleChallengeCD()
end

function LegionCrossChooseEnemyLayer:_onResetChallengeCD( ... )
	self:_initBattleFreeTimer()
end

function LegionCrossChooseEnemyLayer:_initBattleFreeTimer( ... )
	self:_removeBattleFreeTimer()

	self:showTextWithLabel("Label_count_down",
			 G_lang:get("LANG_LEGION_CROSS_FREE_FORMAT", 
			 	{secValue=0}) )

	local freeCD = G_Me.legionData:getBattleFreeTimeCD()
	if type(freeCD) ~= "number" then 
		return 
	end

	self._legionFreeCount = freeCD
	local _updateBattleFreeTimer = function ( ... )
		if self._legionFreeCount < 0 then 
			self._legionFreeCount = 0
			self:_removeBattleFreeTimer()
		end
		self:showTextWithLabel("Label_count_down",
			 G_lang:get("LANG_LEGION_CROSS_FREE_FORMAT", 
			 	{secValue=self._legionFreeCount}) )
		self._legionFreeCount = self._legionFreeCount - 1	
	end
	self._legionFreeTimer = G_GlobalFunc.addTimer(1, function ( ... )
		_updateBattleFreeTimer()
	end)
	_updateBattleFreeTimer()
end

function LegionCrossChooseEnemyLayer:_removeBattleFreeTimer( ... )
	if self._legionFreeTimer then 
		G_GlobalFunc.removeTimer(self._legionFreeTimer)
        self._legionFreeTimer = nil
	end
end

function LegionCrossChooseEnemyLayer:_onRefreshEnemyClick( ... )
	if self._refreshCD > 0 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_REFRESH_IN_CD"))
	end

	G_HandlersManager.legionHandler:sendGetCrossBattleEnemyCorp(self._corpSid, self._corpId, true)
end

function LegionCrossChooseEnemyLayer:_initRefreshBtn( ... )
	local refreshCDTime = G_Me.legionData:getBattleFreshTimeCD() or 0
	local valueInfo = corps_value_info.get(20)
	if valueInfo and refreshCDTime > valueInfo.value then 
		refreshCDTime = valueInfo.value
	end
	--self:enableWidgetByName("Button_change", refreshCDTime < 1)
	local btn = self:getButtonByName("Button_change")
	if btn then 
		btn:showAsGray(refreshCDTime > 0)
	end
	local img = self:getImageViewByName("Image_148")
	if img then 
		img:showAsGray(refreshCDTime > 0)
	end
	self:showWidgetByName("Label_free_time", refreshCDTime > 0)
	self:showTextWithLabel("Label_free_time", refreshCDTime)
	self._refreshCD = refreshCDTime

	-- local _doUpdateTime = nil
	-- local _delaySecond = function ( ... )
	-- 	if not self:isRunning() then 
	-- 		return 
	-- 	end
	-- 	self:callAfterDelayTime(1, nil, function ( ... )
	-- 		if _doUpdateTime then
	-- 			_doUpdateTime()
	-- 		end
	-- 	end)
	-- end

	-- local canChat = self._refreshCD < 1
	-- _doUpdateTime = function ( ... )
	-- 	self._refreshCD = self._refreshCD - 1
	-- 	canChat = self._refreshCD < 1
	-- 	if not canChat then 
	-- 		self:showTextWithLabel("Label_free_time", self._refreshCD)
	-- 		if _delaySecond then
	-- 			_delaySecond()
	-- 		end
	-- 	else
	-- 		self:_initRefreshBtn()
	-- 	end
	-- end

	-- if not canChat then 
	-- 	_delaySecond()
	-- end

	local _updateRefreshCD = function ( ... )
		if self._refreshCD < 0 then 
			self._refreshCD = 0
			self:_initRefreshBtn()
		end
		self:showTextWithLabel("Label_free_time", self._refreshCD)
		self._refreshCD = self._refreshCD - 1	
	end
	self:_removeRefreshCD()
	if self._refreshCD > 0 then
		self._refreshCDTimer = G_GlobalFunc.addTimer(1, function ( ... )
			_updateRefreshCD()
		end)
	end
	_updateRefreshCD()
end

function LegionCrossChooseEnemyLayer:_removeRefreshCD( ... )
	if self._refreshCDTimer then 
		G_GlobalFunc.removeTimer(self._refreshCDTimer)
		self._refreshCDTimer = nil
	end
end

function LegionCrossChooseEnemyLayer:_loadEnemysInfo( ... )
	-- body
end

function LegionCrossChooseEnemyLayer:_onExecuteBattleResult( battleResult )
	if not battleResult or battleResult.ret ~= 1 then
		return 
	end

	local scene = nil
    G_Loading:showLoading(function ( ... )
        	scene = require("app.scenes.legion.battle.LegionCrossBattleScene").new({
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
return LegionCrossChooseEnemyLayer
