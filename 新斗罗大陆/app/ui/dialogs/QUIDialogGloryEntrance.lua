--[[	
	文件名称：QUIDialogGloryEntrance.lua
	创建时间：2016-08-22 11:52:14
	作者：nieming
	描述：QUIDialogGloryEntrance
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogGloryEntrance = class("QUIDialogGloryEntrance", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QGloryDefenseArrangement = import("...arrangement.QGloryDefenseArrangement")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QUIWidgetSkeletonEffect = import("..widgets.actorDisplay.QUIWidgetSkeletonEffect")

function QUIDialogGloryEntrance:ctor(options)
	local ccbFile = "Dialog_GloryArena_xuanze.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTiers", callback = handler(self, QUIDialogGloryEntrance._onTriggerTiers)},
		{ccbCallbackName = "onTriggerFight", callback = handler(self, QUIDialogGloryEntrance._onTriggerFight)},
		{ccbCallbackName = "onTriggerTeam", callback = handler(self, QUIDialogGloryEntrance._onTriggerTeam)},
	}
	QUIDialogGloryEntrance.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.topBar then page.topBar:showWithTower() end
    if page.setScalingVisible then page:setScalingVisible(false) end
    
    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

  	self:createLiusuAnimation()

	self:setInfo()

	setShadow5(self._ccbOwner.describle1)
	setShadow5(self._ccbOwner.describle2)
	setShadow5(self._ccbOwner.time1)
	setShadow5(self._ccbOwner.time2)
	
    self:checkTutorial()
end

function QUIDialogGloryEntrance:checkTutorial()
	if app.tutorial and app.tutorial:isTutorialFinished() == false then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		if page.buildLayer then page:buildLayer() end
		
		local haveTutorial = false
		if app.tutorial:getStage().gloryTower == app.tutorial.Guide_Start and app.unlock:getUnlockGloryTower() then
			haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_GloryTower)
		end
		if haveTutorial == false and page.cleanBuildLayer then
			page:cleanBuildLayer()
		end
	end
end

function QUIDialogGloryEntrance:createLiusuAnimation()
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

function QUIDialogGloryEntrance:setInfo(  )
	self._curState,self._isEnd, self._leftTime, self._nextOpenTiersTime, self._nextOpenFightTime = remote.tower:updateTowerTime()
	if self._curState == 1 then
		if self._isEnd then
			self._ccbOwner.fightEffect1:setVisible(false)
			self._ccbOwner.time1:setString(q.timeToDayHourMinute(self._leftTime))
			self._ccbOwner.hot1:setVisible(false)
			self._ccbOwner.wait1:setVisible(false)
			self._ccbOwner.award1:setVisible(true)
			self._ccbOwner.describle1:setString("距离结算奖励结束：")
		else
			self._ccbOwner.fightEffect1:setVisible(true)
			self._ccbOwner.time1:setString(q.timeToDayHourMinute(self._leftTime))
			self._ccbOwner.describle1:setString("距离段位赛结束：")
			self._ccbOwner.hot1:setVisible(true)
			self._ccbOwner.wait1:setVisible(false)
			self._ccbOwner.award1:setVisible(false)
		end
		self._ccbOwner.fightEffect2:setVisible(false)
		self._ccbOwner.describle2:setString("距离争霸赛开始：")
		self._ccbOwner.time2:setString(q.timeToDayHourMinute(self._nextOpenFightTime))
		self._ccbOwner.hot2:setVisible(false)
		self._ccbOwner.wait2:setVisible(true)
		self._ccbOwner.award2:setVisible(false)
		self._ccbOwner.effect1:setVisible(true)
		self._ccbOwner.effect2:setVisible(false)

		local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	    if animationManager ~= nil then 
			animationManager:runAnimationsForSequenceNamed("timeline1")
	    end
	    QSetDisplayFrameByPath(self._ccbOwner.sp_GloryArena_bg, QResPath("tower_bg")[1])
	    
	    self._zhengba_liusu_left_effct:stopAnimation()
	    self._zhengba_liusu_right_effect:stopAnimation()
	elseif self._curState == 2 then
		if self._isEnd then
			self._ccbOwner.fightEffect2:setVisible(false)
			self._ccbOwner.time2:setString(q.timeToDayHourMinute(self._leftTime))
			self._ccbOwner.hot2:setVisible(false)
			self._ccbOwner.wait2:setVisible(false)
			self._ccbOwner.award2:setVisible(true)
			self._ccbOwner.describle2:setString("距离结算奖励结束：")
		else
			self._ccbOwner.fightEffect2:setVisible(true)
			self._ccbOwner.time2:setString(q.timeToDayHourMinute(self._leftTime))
			self._ccbOwner.describle2:setString("距离争霸赛结束：")
			self._ccbOwner.hot2:setVisible(true)
			self._ccbOwner.award2:setVisible(false)
			self._ccbOwner.wait2:setVisible(false)
		end
		self._ccbOwner.fightEffect1:setVisible(false)
		self._ccbOwner.describle1:setString("距离段位赛开始：")
		self._ccbOwner.time1:setString(q.timeToDayHourMinute(self._nextOpenTiersTime))
		self._ccbOwner.hot1:setVisible(false)
		self._ccbOwner.wait1:setVisible(true)
		self._ccbOwner.award1:setVisible(false)
		self._ccbOwner.effect1:setVisible(false)
		self._ccbOwner.effect2:setVisible(true)
		local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	    if animationManager ~= nil then 
			animationManager:runAnimationsForSequenceNamed("timeline2")
	    end

	    QSetDisplayFrameByPath(self._ccbOwner.sp_GloryArena_bg, QResPath("tower_bg")[2])

	    self._duanwei_liusu_left_effct:stopAnimation()
	    self._duanwei_liusu_right_effect:stopAnimation()
	end
end

function QUIDialogGloryEntrance:updateTime(  )
	if not self:safeCheck() then
		return
	end

	if self._nextOpenTiersTime > 0 then
		self._nextOpenTiersTime = self._nextOpenTiersTime -1
	end
	if self._leftTime > 0 then
		self._leftTime = self._leftTime -1
	end

	if self._nextOpenFightTime > 0 then
		self._nextOpenFightTime = self._nextOpenFightTime -1
	end

	if self._curState == 1 then
		if self._isEnd then	
			self._ccbOwner.time1:setString(q.timeToDayHourMinute(self._leftTime))		
		else
			self._ccbOwner.time1:setString(q.timeToDayHourMinute(self._leftTime))
		end
		self._ccbOwner.time2:setString(q.timeToDayHourMinute(self._nextOpenFightTime))
	elseif self._curState == 2 then
		if self._isEnd then	
			self._ccbOwner.time2:setString(q.timeToDayHourMinute(self._leftTime))
		else
			self._ccbOwner.time2:setString(q.timeToDayHourMinute(self._leftTime))
		end
		self._ccbOwner.time1:setString(q.timeToDayHourMinute(self._nextOpenTiersTime))
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

function QUIDialogGloryEntrance:_onTriggerTiers()
	if remote.tower:isTowerTiresOpen() then
		remote.tower:requestTowerInfo(function (data)
			-- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
            return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryTowerNew"})
        end)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryEntranceTips",options = {time = self._nextOpenTiersTime, state = 0}},{isPopCurrentDialog = false})

	end
end

function QUIDialogGloryEntrance:_onTriggerFight()
	if remote.tower:isTowerFightOpen() then

		remote.tower:requestGloryArenaInfo(nil, function(data)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryArena"})
		end)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGloryEntranceTips",options = {time = self._nextOpenFightTime, state = 1}},{isPopCurrentDialog = false})

	end

end

function QUIDialogGloryEntrance:_onTriggerTeam(event)
	if event ~= nil then
    	app.sound:playSound("common_small")
    end
   
	local arenaArrangement = QGloryDefenseArrangement.new({teamKey = remote.teamManager.GLORY_DEFEND_TEAM})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
		options = {arrangement = arenaArrangement, isBattle = true}})

end

function QUIDialogGloryEntrance:close( )
	self:playEffectOut()
end


function QUIDialogGloryEntrance:viewDidAppear()
	QUIDialogGloryEntrance.super.viewDidAppear(self)
	self:addBackEvent(false)

	self._towerEventProxy = cc.EventProxy.new(remote.tower)
	self._towerEventProxy:addEventListener(remote.tower.EVENT_TOWER_STATE_STATUS_CHANGE, handler(self, self.setInfo))

	self._timeUpdateScheduler = scheduler.scheduleGlobal(handler(self, self.updateTime),1)

end

function QUIDialogGloryEntrance:viewWillDisappear()
	QUIDialogGloryEntrance.super.viewWillDisappear(self)
	self:removeBackEvent()
	self._towerEventProxy:removeAllEventListeners()
	if self._timeUpdateScheduler then
		scheduler.unscheduleGlobal(self._timeUpdateScheduler)
	end
end

function QUIDialogGloryEntrance:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogGloryEntrance:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogGloryEntrance
