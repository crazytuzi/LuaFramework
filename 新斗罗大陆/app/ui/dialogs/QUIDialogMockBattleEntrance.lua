--[[	
	文件名称：QUIDialogMockBattleEntrance.lua
	创建时间：2020-02-25 10:57:14
	作者：qinsiyang
	描述：QUIDialogMockBattleEntrance
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogMockBattleEntrance = class("QUIDialogMockBattleEntrance", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QGloryDefenseArrangement = import("...arrangement.QGloryDefenseArrangement")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QUIWidgetSkeletonEffect = import("..widgets.actorDisplay.QUIWidgetSkeletonEffect")
local QMockBattle = import("..network.models.QMockBattle")

function QUIDialogMockBattleEntrance:ctor(options)
	local ccbFile = "Dialog_MockBattle_Entrance.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTiers", callback = handler(self, self._onTriggerTiers)},
		{ccbCallbackName = "onTriggerFight", callback = handler(self, self._onTriggerFight)},
	}
	QUIDialogMockBattleEntrance.super.ctor(self,ccbFile,callBacks,options)
	
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page and page.topBar and page.topBar.showWithMockBattle2 then
        page.topBar:showWithMockBattle2()
    end
    if page.setScalingVisible then page:setScalingVisible(false) end
    CalculateUIBgSize(self._ccbOwner.sp_bg)
    self._timeRequestUpdateScheduler = nil
  	self:createLiusuAnimation()
	self:setInfo()

	setShadow5(self._ccbOwner.describle1)
	setShadow5(self._ccbOwner.describle2)
	setShadow5(self._ccbOwner.time1)
	setShadow5(self._ccbOwner.time2)
	
end

function QUIDialogMockBattleEntrance:createLiusuAnimation()
    local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
    local zhengba_liusu_left_effect = skeletonViewController:createSkeletonEffectWithFile("effect/rongyaozhita_zhenbasai", nil, nil, false)
    local zhengba_liusu_right_effect = skeletonViewController:createSkeletonEffectWithFile("effect/rongyaozhita_zhenbasai", nil, nil, false)
    self._ccbOwner.zhengba_liusu_left:addChild(zhengba_liusu_left_effect)
    self._ccbOwner.zhengba_liusu_right:addChild(zhengba_liusu_right_effect)
    zhengba_liusu_left_effect:playAnimation(EFFECT_ANIMATION, true)
    zhengba_liusu_right_effect:playAnimation(EFFECT_ANIMATION, true)
    zhengba_liusu_left_effect:setScaleX(-1)
    zhengba_liusu_left_effect:setPositionX(zhengba_liusu_left_effect:getPositionX() + 130)
    zhengba_liusu_left_effect:setPositionY(zhengba_liusu_left_effect:getPositionY() - 240)
    zhengba_liusu_right_effect:setPositionX(zhengba_liusu_right_effect:getPositionX() - 130)
    zhengba_liusu_right_effect:setPositionY(zhengba_liusu_right_effect:getPositionY() - 244)
    zhengba_liusu_right_effect:updateAnimation(math.random(0, 4000) / 10000)
    self._zhengba_liusu_left_effct = zhengba_liusu_left_effect
    self._zhengba_liusu_right_effect = zhengba_liusu_right_effect
    zhengba_liusu_left_effect:setAnimationScale(math.random(8000, 12000) / 10000)
    zhengba_liusu_right_effect:setAnimationScale(math.random(8000, 12000) / 10000)

    local duanwei_liusu_left_effect = skeletonViewController:createSkeletonEffectWithFile("effect/rongyaozhita_duanweisai", nil, nil, false)
    local duanwei_liusu_right_effect = skeletonViewController:createSkeletonEffectWithFile("effect/rongyaozhita_duanweisai", nil, nil, false)
    self._ccbOwner.duanwei_liusu_left:addChild(duanwei_liusu_left_effect)
    self._ccbOwner.duanwei_liusu_right:addChild(duanwei_liusu_right_effect)
    duanwei_liusu_left_effect:playAnimation("stand", true)
    duanwei_liusu_right_effect:playAnimation("stand", true)
    duanwei_liusu_left_effect:setScaleX(-1)
    duanwei_liusu_left_effect:setPositionX(duanwei_liusu_left_effect:getPositionX() + 130)
    duanwei_liusu_left_effect:setPositionY(duanwei_liusu_left_effect:getPositionY() - 236)
    duanwei_liusu_right_effect:setPositionX(duanwei_liusu_right_effect:getPositionX() - 130)
    duanwei_liusu_right_effect:setPositionY(duanwei_liusu_right_effect:getPositionY() - 235)
    duanwei_liusu_right_effect:updateAnimation(math.random(0, 4000) / 10000)
    self._duanwei_liusu_left_effct = duanwei_liusu_left_effect
    self._duanwei_liusu_right_effect = duanwei_liusu_right_effect
    duanwei_liusu_left_effect:setAnimationScale(math.random(8000, 12000) / 10000)
    duanwei_liusu_right_effect:setAnimationScale(math.random(8000, 12000) / 10000)

    skeletonViewController:removeSkeletonEffect(zhengba_liusu_left_effect)
    skeletonViewController:removeSkeletonEffect(zhengba_liusu_right_effect)
    skeletonViewController:removeSkeletonEffect(duanwei_liusu_left_effect)
    skeletonViewController:removeSkeletonEffect(duanwei_liusu_right_effect)
end

function QUIDialogMockBattleEntrance:setDoubleEffectVisible(  _isVisible)
	for i=1,8 do
		self._ccbOwner["node_ccp_"..i]:setVisible(_isVisible)
	end
end


function QUIDialogMockBattleEntrance:setInfo(  )
	self._seasonType = remote.mockbattle:getMockBattleSeasonType() -- 赛季类型
	local endTime = remote.mockbattle:getMockBattleSeasonInfo().endAt or 0
	endTime = endTime / 1000
	local currTime = q.serverTime()

	self._lastTime = endTime - currTime
	self._ccbOwner.time2:setVisible(true)
	if endTime == 0 or endTime - currTime < 0 then
		self._ccbOwner.time1:setString("赛季时间错误")		
		self._ccbOwner.time2:setString("赛季时间错误")
	else
		self._ccbOwner.time1:setString(q.timeToDayHourMinute(self._lastTime))		
		self._ccbOwner.time2:setString(q.timeToDayHourMinute(self._lastTime))
	end

	if self._seasonType == QMockBattle.SEASON_TYPE_SINGLE then
		self._ccbOwner.fightEffect1:setVisible(true)
		self._ccbOwner.describle1:setString("距离单队战结束：")
		self._ccbOwner.hot1:setVisible(true)
		self._ccbOwner.effect1:setVisible(true)
		self._ccbOwner.wait1:setVisible(false)
		self._ccbOwner.award1:setVisible(false)
		--

		self._ccbOwner.describle2:setString("距离双队战开始：")
		self._ccbOwner.fightEffect2:setVisible(false)
		self._ccbOwner.hot2:setVisible(false)
		self._ccbOwner.effect2:setVisible(false)
		self._ccbOwner.wait2:setVisible(true)
		self._ccbOwner.award2:setVisible(false)
		--
		local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	    if animationManager ~= nil then 
			animationManager:runAnimationsForSequenceNamed("timeline1")
	    end
	    
	    self._zhengba_liusu_left_effct:stopAnimation()
	    self._zhengba_liusu_right_effect:stopAnimation()
	else
		self._ccbOwner.fightEffect1:setVisible(false)	
		self._ccbOwner.describle1:setString("距离单队战开始：")
		self._ccbOwner.hot1:setVisible(false)
		self._ccbOwner.effect1:setVisible(false)

		self._ccbOwner.wait1:setVisible(true)
		self._ccbOwner.award1:setVisible(false)
		--
		self._ccbOwner.describle2:setString("距离双队战结束：")
		self._ccbOwner.fightEffect2:setVisible(true)
		self._ccbOwner.hot2:setVisible(true)
		self._ccbOwner.effect2:setVisible(true)

		self._ccbOwner.wait2:setVisible(false)
		self._ccbOwner.award2:setVisible(false)


		local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	    if animationManager ~= nil then 
			animationManager:runAnimationsForSequenceNamed("timeline2")
	    end

	    self._duanwei_liusu_left_effct:stopAnimation()
	    self._duanwei_liusu_right_effect:stopAnimation()

	end
	if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE2", false)  then
		makeNodeFromNormalToGray(self._ccbOwner.node_right_text) 
		makeNodeFromNormalToGray(self._ccbOwner.node_right) 
		self._ccbOwner.fightEffect2:setVisible(false)
		self._ccbOwner.effect2:setVisible(false)
		self._ccbOwner.hot2:setVisible(false)
		local config_ = app.unlock:getConfigByKey("UNLOCK_MOCK_BATTLE2") or {}
		local unlockLevel = config_.team_level or 99
		self._ccbOwner.describle2:setString(unlockLevel.."级开启")
		self._ccbOwner.time2:setVisible(false)
		self:setDoubleEffectVisible(false)
	else
		self:setDoubleEffectVisible(true)
	end


	if self._timeRequestUpdateScheduler then
		scheduler.unscheduleGlobal(self._timeRequestUpdateScheduler)
	end
end

function QUIDialogMockBattleEntrance:updateTime()
	if not self:safeCheck() then
		return
	end

	if self._lastTime > 0  then
		self._lastTime = self._lastTime - 1
		self._ccbOwner.time1:setString(q.timeToDayHourMinute(self._lastTime))		
		self._ccbOwner.time2:setString(q.timeToDayHourMinute(self._lastTime))
	else
		self:requestMockBattleInfo()
		self._timeRequestUpdateScheduler = scheduler.scheduleGlobal(handler(self, self.requestMockBattleInfo),10)
	end

    local zhengba_liusu_left_effect = self._zhengba_liusu_left_effct
    local zhengba_liusu_right_effect = self._zhengba_liusu_right_effect
    zhengba_liusu_left_effect:setAnimationScale(math.random(8000, 12000) / 10000)
    zhengba_liusu_right_effect:setAnimationScale(math.random(8000, 12000) / 10000)
    local duanwei_liusu_left_effect = self._duanwei_liusu_left_effct
    local duanwei_liusu_right_effect = self._duanwei_liusu_right_effect
    duanwei_liusu_left_effect:setAnimationScale(math.random(8000, 12000) / 10000)
    duanwei_liusu_right_effect:setAnimationScale(math.random(8000, 12000) / 10000)
end


function QUIDialogMockBattleEntrance:requestMockBattleInfo()
    remote.mockbattle:mockBattleGetMainInfoRequest()
end


function QUIDialogMockBattleEntrance:_onTriggerTiers()
	if remote.mockbattle:checkMockBattleIsUnLockByType(true,1) then
		if self._seasonType == QMockBattle.SEASON_TYPE_SINGLE  then
			remote.mockbattle:openMockBattleDialog()
		else
			app.tip:floatTip("赛季未开启")
		end
	end
end

function QUIDialogMockBattleEntrance:_onTriggerFight()
	if remote.mockbattle:checkMockBattleIsUnLockByType(true,2) then
		if self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE  then
			remote.mockbattle:openMockBattleDialog()
		else
			app.tip:floatTip("赛季未开启")
		end
	end
end

function QUIDialogMockBattleEntrance:close( )
	self:playEffectOut()
end


function QUIDialogMockBattleEntrance:viewDidAppear()
	QUIDialogMockBattleEntrance.super.viewDidAppear(self)
	self:addBackEvent(false)

	self._mockbattleEventProxy = cc.EventProxy.new(remote.mockbattle)
	self._mockbattleEventProxy:addEventListener(remote.mockbattle.EVENT_MOCK_BATTLE_SEASON_INFO, handler(self, self.setInfo))

	self._timeUpdateScheduler = scheduler.scheduleGlobal(handler(self, self.updateTime),1)

end

function QUIDialogMockBattleEntrance:viewWillDisappear()
	QUIDialogMockBattleEntrance.super.viewWillDisappear(self)
	self:removeBackEvent()
	self._mockbattleEventProxy:removeAllEventListeners()
	if self._timeUpdateScheduler then
		scheduler.unscheduleGlobal(self._timeUpdateScheduler)
	end
	if self._timeRequestUpdateScheduler then
		scheduler.unscheduleGlobal(self._timeRequestUpdateScheduler)
	end	
end

function QUIDialogMockBattleEntrance:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMockBattleEntrance:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogMockBattleEntrance
