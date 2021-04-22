local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetThunder = class("QUIWidgetThunder", QUIWidget)
local QUIWidgetThunderFighter = import("..widgets.QUIWidgetThunderFighter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIWidgetThunder:ctor(options)
	local ccbFile = "ccb/Widget_ThunderKing.ccbi"
  	local callBacks = {
		{ccbCallbackName = "onTriggerShop", callback = handler(self, QUIWidgetThunder._onTriggerShop)},  
		{ccbCallbackName = "onTriggerElite", callback = handler(self, QUIWidgetThunder._onTriggerElite)},  
		{ccbCallbackName = "onTriggerBox", callback = handler(self, QUIWidgetThunder._onTriggerBox)},   
		{ccbCallbackName = "onTriggerConditionInfo", callback = handler(self, QUIWidgetThunder._onTriggerConditionInfo)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, QUIWidgetThunder._onTriggerRank)},
		{ccbCallbackName = "onTriggerFighter1", callback = handler(self, QUIWidgetThunder._onTriggerFighter1)},    
		{ccbCallbackName = "onTriggerFighter2", callback = handler(self, QUIWidgetThunder._onTriggerFighter2)},    
		{ccbCallbackName = "onTriggerFighter3", callback = handler(self, QUIWidgetThunder._onTriggerFighter3)},   
		{ccbCallbackName = "onTriggerQuickFightOne", callback = handler(self, QUIWidgetThunder._onTriggerQuickFightOne)},
		{ccbCallbackName = "onTriggerFail", callback = handler(self, QUIWidgetThunder._onTriggerFail)},   
  	}
	QUIWidgetThunder.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	-- setShadow6(self._ccbOwner.tf_condition)
  	-- setShadow6(self._ccbOwner.name_condition)
  	setShadow6(self._ccbOwner.prop_name)
  	setShadow6(self._ccbOwner.use_label)
  	local i = 1
  	while self._ccbOwner["tf_name_"..i] do
  		setShadow6(self._ccbOwner["tf_name_"..i])
  		setShadow6(self._ccbOwner["tf_value_"..i])
  		i = i + 1
  	end

  	self._fighters = {}
  	for i=1,3 do
  		local fighter = QUIWidgetThunderFighter.new()
  		self._ccbOwner["fighter"..i]:addChild(fighter)
  		table.insert(self._fighters, fighter)
  	end

	-- local node = self._ccbOwner.node_top
	-- node:setPositionY(node:getPositionY() + (UI_DESIGN_WIDTH * display.height / display.width - UI_DESIGN_HEIGHT) / 2)
	-- local node = self._ccbOwner.node_bottom
	-- node:setPositionY(node:getPositionY() - (UI_DESIGN_WIDTH * display.height / display.width - UI_DESIGN_HEIGHT) / 2)

	-- 屏蔽一键扫荡
	-- self._ccbOwner.btn_quick_fight:setVisible(false)
	
	if FinalSDK.isHXShenhe() then
		self._ccbOwner.btn_paihang:setVisible(false)
		self._ccbOwner.btn_quick_fight:setVisible(false)
	end
end

function QUIWidgetThunder:onEnter()
	QUIWidgetThunder.super.onEnter(self)
	self:initPanel()
end

function QUIWidgetThunder:onExit()
	QUIWidgetThunder.super.onExit(self)
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
	end
end

function QUIWidgetThunder:initPanel()
	self.thunderFighter, self._layerConfig, self._lastIndex = remote.thunder:getThunderFighter()
	if q.isEmpty(self.thunderFighter) then
		return
	end
	self:showPropHandler()
	self:showFighter()
	if self._lastIndex == 3 then
		if remote.thunder:getIsBattle() and remote.thunder:getIsFast() ~= true then
			self._isAnimation = true
			self._schedulerHandler = scheduler.performWithDelayGlobal(function ()
				self._schedulerHandler = nil
				self:boxEffect("opening")
				remote.thunder:openAwardDialog()
			end,0.5)
		else
			self:boxEffect("open")
		end
	else
		self:boxEffect("close")
	end
	self:setRedTip()
  	local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
	self._resetCount = globalConfig.THUNDER_RESET_LIMIT.value - (self.thunderFighter.thunderResetCount or 0)
	if self._resetCount > 0 then
		self._ccbOwner.tf_reset:setString("剩余可重置"..self._resetCount.."次")
	else
		self._ccbOwner.tf_reset:setString("重置次数已用完")
	end

	self.fastBattleLayer = remote.thunder:getFastBattleLayer()
	self.canFast =  self.fastBattleLayer >= self._layerConfig.thunder_floor and self._lastIndex ~= 3 --是否可以扫荡

	--xurui:检查扫荡功能解锁提示
	self._ccbOwner.node_reduce_effect:setVisible(app.tip:checkReduceUnlokState("thunderFastBattle"))
end

function QUIWidgetThunder:setRedTip()
  	self._ccbOwner.elite_tips:setVisible(false)
  	self._ccbOwner.shop_tips:setVisible(false)

    local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
    if tonumber(configuration["THUNDER_ELITE_DEFAULT"].value) + tonumber(self.thunderFighter.thunderEliteChallengeBuyCount) - tonumber(self.thunderFighter.thunderEliteChallengeTimes) > 0 and 
        self.thunderFighter.thunderHistoryMaxFloor >= 1 then
  		self._ccbOwner.elite_tips:setVisible(true)
  	end
  	
  	if remote.stores:checkFuncShopRedTips(SHOP_ID.thunderShop) then
  		self._ccbOwner.shop_tips:setVisible(true)
  	end
end

function QUIWidgetThunder:showPropHandler()
	self._ccbOwner.tf_star_num:setString(self.thunderFighter.thunderCurrentStar - self.thunderFighter.thunderCurrentUsed)
	self._ccbOwner.tf_history_star:setString(self.thunderFighter.thunderHistoryMaxStar)
	self._ccbOwner.tf_current_star:setString(self.thunderFighter.thunderCurrentStar)
	-- self._ccbOwner.tf_condition:setString(self._layerConfig.pass_tiaojian)
	self._ccbOwner.tf_nil:setVisible(true)
	local prop = {}

	local buffs = remote.thunder:getAllBuff()
	for _,buff in pairs(buffs) do
		local buffConfig = QStaticDatabase:sharedDatabase():getThunderBuffById(buff)
		if prop[buffConfig.buff_type] == nil then
			prop[buffConfig.buff_type] = 0
		end
		prop[buffConfig.buff_type] = prop[buffConfig.buff_type] + buffConfig.buff_num
		self._ccbOwner.tf_nil:setVisible(false)
	end
	for i=1,8 do
		self._ccbOwner["tf_name_"..i]:setString("")
		self._ccbOwner["tf_value_"..i]:setString("")
	end
	self._index = nil
	self:setBuffInfo("生命", "+%d%%", (prop["生命"] or 0))
	self:setBuffInfo("攻击", "+%d%%", (prop["攻击"] or 0))
	-- self:setBuffInfo("物防", "+%d%%", (prop["物防"] or 0))
	-- self:setBuffInfo("法防", "+%d%%", (prop["法防"] or 0))
	self:setBuffInfo("防御", "+%d%%", (prop["防御"] or 0))
	self:setBuffInfo("命中", "+%d%%", (prop["命中"] or 0))
	self:setBuffInfo("闪避", "+%d%%", (prop["闪避"] or 0))
	self:setBuffInfo("暴击", "+%d%%", (prop["暴击"] or 0))
	self:setBuffInfo("格挡", "+%d%%", (prop["格挡"] or 0))
	self:setBuffInfo("攻速", "+%d%%", (prop["攻速"] or 0))
end

function QUIWidgetThunder:getTopForce()
	local count = remote.herosUtil:getUnlockTeamNum()
	local heros = remote.herosUtil:getHaveHero()
	local heroForces = {}
	local topForce = 0
	for index,actorId in pairs(heros) do
		local heroModel = remote.herosUtil:createHeroPropById(actorId) 
		table.insert(heroForces, {index = index, force = heroModel:getBattleForce()})
	end
	table.sort(heroForces, function (a,b)
		if a.force ~= b.force then
			return a.force > b.force
		end
		return a.index < b.index
	end )
	for index,value in pairs(heroForces) do
		if index > count then
			break
		end
		topForce = topForce + value.force
	end

	return topForce
end

function QUIWidgetThunder:setBuffInfo(name, str, value)
	if self._index == nil then self._index = 1 end
	if value > 0 then
		self._ccbOwner["tf_name_"..self._index]:setString(name)
		self._ccbOwner["tf_value_"..self._index]:setString(string.format(str, value))
		self._index = self._index + 1
	end
end

function QUIWidgetThunder:showFighter()
	self._layerStars = {}
	if self.thunderFighter.thunderEveryWaveStar ~= nil then
		self._layerStars = string.split(self.thunderFighter.thunderEveryWaveStar, ";")
	end
	self._currentIndex = self._lastIndex + 1
	local perStar = nil
	local maxFloor = self.thunderFighter.thunderHistoryMaxFloor or 0
  	for i=1,3 do
  		self._fighters[i]:setInfo(i, self._layerConfig, self._currentIndex, tonumber(self._layerStars[i]), perStar)
  		perStar = tonumber(self._layerStars[i])
  		
  		local currentFloor = (self._layerConfig.thunder_floor-1)*3+i
		self._fighters[i]:setLockState(false)
  		if currentFloor%3 == 0 and currentFloor/3 > maxFloor then
  			--self._fighters[i]:setLockState(true)
  		end
  	end
end

function QUIWidgetThunder:boxEffect(type)
	if type == "open" or type == "opening" then
		self._ccbOwner.node_gold_open:setVisible(true)
		self._ccbOwner.node_gold_close:setVisible(false)
		if remote.thunder:getIsFast() == false and remote.thunder:getIsBattle() == true then
			remote.thunder:openAwardDialog()
		end
	-- elseif type == "opening" then
	-- 	self._ccbOwner.node_gold_open:setVisible(false)
	-- 	self._ccbOwner.node_gold_close:setVisible(false)
	-- 	if self._boxEffect == nil then
	-- 		self._boxEffect = QUIWidgetAnimationPlayer.new()
	-- 		self._ccbOwner.node_gold_effect:addChild(self._boxEffect)
	-- 		self._boxEffect:playAnimation("ccb/effects/thunder_baoxiang_open.ccbi", nil,function()
	--         	self._boxEffect:removeFromParentAndCleanup(true)
	--         	self._boxEffect = nil
	--         	self:boxEffect("open")
	-- 			self._isAnimation = false
	--         end)
	-- 	end
	elseif type =="close" then
		self._ccbOwner.node_gold_open:setVisible(false)
		self._ccbOwner.node_gold_close:setVisible(true)
	end
end

function QUIWidgetThunder:openChoose(index)
	if self._currentIndex == index then
		remote.thunder:openChooseDilaog(index, self._layerConfig, self.thunderFighter.thunderHistoryEveryWaveStar[(self._layerConfig.thunder_floor - 1) * 3 + self._currentIndex])
	end
end

function QUIWidgetThunder:_onTriggerShop()
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.thunderShop)
end

function QUIWidgetThunder:_onTriggerElite()
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderElite"})
end

function QUIWidgetThunder:_onTriggerBox()
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderRewardPreview", options = {floor = self._layerConfig.thunder_floor}})
end

function QUIWidgetThunder:_onTriggerConditionInfo()
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderHelp"})
end

function QUIWidgetThunder:_onTriggerRank() 
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", options = {initRank = "thunder"}}, {isPopCurrentDialog = false})
end

function QUIWidgetThunder:_onTriggerFighter1()
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	self:openChoose(1)
end

function QUIWidgetThunder:_onTriggerFighter2()
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	self:openChoose(2)
end

function QUIWidgetThunder:_onTriggerFighter3()
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	self:openChoose(3)
end

function QUIWidgetThunder:_onTriggerQuickFightOne(event)
	if q.buttonEventShadow(event, self._ccbOwner.quick_fight) == false then return end
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	if app.unlock:checkLock("UNLOCK_THUNDER_QUICK_FIGHT") == false then
		app.unlock:tipsLock("UNLOCK_THUNDER_QUICK_FIGHT", "杀戮之都扫荡", true)
		return
	end

	--xurui:设置扫荡功能解锁提示
	if app.tip:checkReduceUnlokState("thunderFastBattle") then
		app.tip:setReduceUnlockState("thunderFastBattle", 2)
		self._ccbOwner.node_reduce_effect:setVisible(false)
	end

	--xurui:设置扫荡功能解锁提示
	if (app.unlock:checkLock("UNLOCK_THUNDER_QUICK_FIGHT") or app.unlock:checkLock("UNLOCK_THUNDER_QUICK_FIGHT_ALL")) and app.tip:checkReduceUnlokState("thunderFastBattle") then
		app.tip:setReduceUnlockState("thunderFastBattle", 2)
		self._ccbOwner.node_reduce_effect:setVisible(false)
	end

	local thunderHistoryEveryWaveStar = remote.thunder.thunderInfo.thunderHistoryEveryWaveStar or {}
	local curWaveIndex = remote.thunder:getIndexByLayer(remote.thunder.thunderInfo.thunderLastWinFloor, remote.thunder.thunderInfo.thunderLastWinWave)
	local advanceIndex = #thunderHistoryEveryWaveStar
	if curWaveIndex >= advanceIndex then
		app.tip:floatTip("当前没有关卡可以扫荡，请继续向前挑战吧～")
		return
	end

	local tmpIndex = 0
	for _, star in ipairs(thunderHistoryEveryWaveStar) do
		if star == 3 then
			tmpIndex = tmpIndex + 1
		else
			break
		end
	end
	local normalIndex = math.floor(tmpIndex/3) * 3
	local isFreeTime = self._resetCount >= 2 -- 重置2次之后才可以一星扫荡
	print("[Kumo] QUIWidgetThunder:_onTriggerQuickFightOne() ", self._resetCount, isFreeTime)
	-- print("curWaveIndex = ", curWaveIndex, " advanceIndex = ", advanceIndex, " normalIndex = ", normalIndex, " isFreeTime = ", isFreeTime)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderRobot", options = {
		normalIndex = normalIndex, advanceIndex = advanceIndex, curWaveIndex = curWaveIndex, isFreeTime = isFreeTime,
		callback = function()
			remote.flag:set(remote.flag.FLAG_FRIST_THUNDER_FAST, 1)
			-- local isSelectedNormal = app:getUserOperateRecord():getThunderRobot( "normal" ) -- 是否勾选三星扫荡
			local isSelectedAdvance = app:getUserOperateRecord():getThunderRobot( "advance" ) -- 是否勾选一星扫荡
			if isSelectedAdvance then
				-- if curWaveIndex >= advanceIndex then
				-- 	app.tip:floatTip("当前没有关卡可以扫荡，请继续向前挑战吧～")
				-- else
					-- remote.thunder:thunderLevelWaveFastFight(2, false)
					remote.thunder:thunderLevelWaveFastFight(2, false)
				-- end
			else
				if self.canFast == false then
					app.tip:floatTip("没有关卡可以三星扫荡，请选择别的扫荡方式或继续向前挑战吧～")
				else
					-- remote.thunder:thunderLevelWaveFastFight(1, false)
					remote.thunder:thunderLevelWaveFastFight(1, false)
				end
				
			end
		end}}, {isPopCurrentDialog = false})

	-- if self.canFast == false then
	-- 	-- 满足开启条件，但战力不足
	-- 	app.tip:floatTip("通关本层三个关卡的困难难度后可以使用三星扫荡功能")
	-- else
	-- 	local index = remote.thunder:getIndexByLayer(self.fastBattleLayer,3)

	-- 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNpcPrompt", 
	-- 		options = {content ="当前可自动帮您三星扫荡至"..index.."关，系统会自动帮您选择加成BUFF，确定扫荡？",comfirmCallback = function ( )
	-- 			remote.flag:set(remote.flag.FLAG_FRIST_THUNDER_FAST,1)
	-- 			remote.thunder:thunderLevelWaveFastFight()
	-- 		end}}, {isPopCurrentDialog = false})
	-- end
end

function QUIWidgetThunder:_onTriggerFail(event)
	if q.buttonEventShadow(event, self._ccbOwner.reset_btn) == false then return end
	if self._layerConfig.thunder_floor == 1 and self._lastIndex == 0 then
		app.tip:floatTip("魂师大人，您已经重置过了，快去战斗吧~")
		return
	end
	if self._isAnimation == true then return end
    app.sound:playSound("common_small")
	-- if self._resetCount == 0 then 
 --    	app.tip:floatTip("当日重置次数已用完！")
	-- 	return
	-- end
	app:alert({content="确定重新开始新一轮的杀戮之都挑战吗？",title="系统提示",callback=function (state)
		if state == ALERT_TYPE.CONFIRM then
			remote.thunder:setIsBattle(true, false)
			remote.thunder:thunderQuickEnd()
		end
	end})
end

return QUIWidgetThunder