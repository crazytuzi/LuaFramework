-- @Author: liaoxianbo
-- @Date:   2019-11-20 19:23:11
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-23 18:26:04
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCollegeTrainMain = class("QUIDialogCollegeTrainMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetIconAniTips = import("..widgets.QUIWidgetIconAniTips")

-- local function _converFun(time)
-- 	local str = ""
-- 	local day = math.floor(time/DAY)
-- 	time = time%DAY
-- 	local hour = math.floor(time/HOUR)
-- 	hour = hour < 10 and "0"..hour or hour
-- 	time = time%HOUR
-- 	local min = math.floor(time/MIN)
-- 	min = min < 10 and "0"..min or min
-- 	time = time%MIN
-- 	local sec = math.floor(time)
-- 	sec = sec < 10 and "0"..sec or sec
-- 	if day > 0 then
-- 		str = day.."天 "..hour..":"..min..":"..sec
-- 	else
-- 		str = hour..":"..min..":"..sec
-- 	end
-- 	return str
-- end

function QUIDialogCollegeTrainMain:ctor(options)
	local ccbFile = "ccb/Dialog_CollegeTrain_main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
	}
    QUIDialogCollegeTrainMain.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false 
    
    CalculateUIBgSize(self._ccbOwner.sp_bg)

    -- UNLOCK_COLLEGE_TRAIN
    self._isSeasonOpen = false
    self._mockbattleTips = nil
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	app:getUserOperateRecord():recordeCurrentTime("college_train_tips")

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
end



function QUIDialogCollegeTrainMain:viewDidAppear()
	QUIDialogCollegeTrainMain.super.viewDidAppear(self)
	self:setInfo()
	self:addBackEvent(false)

	--makeNodeFromNormalToGray(self._ccbOwner.node_right) 
end

function QUIDialogCollegeTrainMain:viewWillDisappear()
  	QUIDialogCollegeTrainMain.super.viewWillDisappear(self)
    if self._seasonScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._seasonScheduler)
    	self._seasonScheduler = nil
    end
	self:removeBackEvent()
end

function QUIDialogCollegeTrainMain:resetAll()
	self._ccbOwner.node_season_timer:setVisible(false)
	self._ccbOwner.shop_is_lock:setVisible(false)

end

function QUIDialogCollegeTrainMain:setInfo()
	self:resetAll()


	if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE", false) then
		local config_ = app.unlock:getConfigByKey("UNLOCK_MOCK_BATTLE") or {}
  		local unlockLevel = config_.team_level or 99
		if unlockLevel - 5 > remote.user.level then
			makeNodeFromNormalToGray(self._ccbOwner.node_right) 
		else
			makeNodeFromNormalToGray(self._ccbOwner.node_right_title) 
		end
	end

	-- if remote.mockbattle:getMockBattleSeasonTypeIsSingle() then
	-- 	if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE", false) then
	-- 		local config_ = app.unlock:getConfigByKey("UNLOCK_MOCK_BATTLE") or {}
	--   		local unlockLevel = config_.team_level or 99
	-- 		if unlockLevel - 5 > remote.user.level then
	-- 			makeNodeFromNormalToGray(self._ccbOwner.node_right) 
	-- 		else
	-- 			makeNodeFromNormalToGray(self._ccbOwner.node_right_title) 
	-- 		end
	-- 	end
	-- else
	-- 	if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE2", false) then
	-- 		local config_ = app.unlock:getConfigByKey("UNLOCK_MOCK_BATTLE2") or {}
	--   		local unlockLevel = config_.team_level or 99
	-- 		if unlockLevel - 5 > remote.user.level then
	-- 			makeNodeFromNormalToGray(self._ccbOwner.node_right) 
	-- 		else
	-- 			makeNodeFromNormalToGray(self._ccbOwner.node_right_title) 
	-- 		end
	-- 	end		
	-- end
	local endTime = remote.mockbattle:getCurSeasonEndCountDown() or 0
	if endTime <= 0 then
		self:handlerTimer()
    	self._isSeasonOpen = false
	else
    	self._isSeasonOpen = true
	end

	self:addRedTips()

end


function QUIDialogCollegeTrainMain:addRedTips()

	if not self._mockbattleTips then
		self._mockbattleTips = QUIWidgetIconAniTips.new()
		self._mockbattleTips:setInfo(1, 4, "", "down")
		self._ccbOwner.node_fight_tips_right:removeAllChildren()
		self._ccbOwner.node_fight_tips_right:addChild(self._mockbattleTips)
	end
	self._mockbattleTips:setVisible(remote.mockbattle:checkRedTips())
end


function QUIDialogCollegeTrainMain:handlerTimer()
	if self._fun == nil then
	    self._fun = function ()
	    	local endTime = remote.mockbattle:getNextSeasonStartCountDown()or 0
			if endTime > 0 then
	    		self._ccbOwner.tf_season_timer:setString(q.converFun(endTime))
	    	else
    			self._isSeasonOpen = true
	    		if self._seasonScheduler then
	    			scheduler.unscheduleGlobal(self._seasonScheduler)
	    			self._seasonScheduler = nil
	    		end
				self._ccbOwner.node_season_timer:setVisible(false)
	    	end
	    end
	end
	self._ccbOwner.node_season_timer:setVisible(true)
	if self._seasonScheduler == nil then
    	self._seasonScheduler = scheduler.scheduleGlobal(self._fun, 1)
	end
    self._fun()
end



function QUIDialogCollegeTrainMain:_onTriggerLeft(event)
	if q.buttonEvent(event, self._ccbOwner.sp_icon_left) == false then return end
    app.sound:playSound("common_small")

    remote.collegetrain:openCollegeTrainDialog()
end

function QUIDialogCollegeTrainMain:_onTriggerRight(event)
	-- if remote.mockbattle:getMockBattleSeasonTypeIsSingle() then
	-- 	if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE", true) then
	-- 		local config_ = app.unlock:getConfigByKey("UNLOCK_MOCK_BATTLE") or {}
	--   		local unlockLevel = config_.team_level or 99
	-- 		if unlockLevel - 5 > remote.user.level then
	-- 			if q.buttonEventShadow(event, self._ccbOwner.sp_icon_right) == false then return end
	-- 		else
	-- 			if q.buttonEvent(event, self._ccbOwner.sp_icon_right) == false then return end
	-- 		end
	--     	return 
	-- 	end
	-- else
	-- 	if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE2", true) then
	-- 		local config_ = app.unlock:getConfigByKey("UNLOCK_MOCK_BATTLE2") or {}
	--   		local unlockLevel = config_.team_level or 99
 --  			local str = "本周为双队赛季，%s级开启，单队赛季下周开启"
	-- 		app.tip:floatTip(string.format(str, unlockLevel))
	-- 		if unlockLevel - 5 > remote.user.level then
	-- 			if q.buttonEventShadow(event, self._ccbOwner.sp_icon_right) == false then return end
	-- 		else
	-- 			if q.buttonEvent(event, self._ccbOwner.sp_icon_right) == false then return end
	-- 		end
	--     	return 
	-- 	end		
	-- end
	-- if q.buttonEvent(event, self._ccbOwner.sp_icon_right) == false then return end
 --    app.sound:playSound("common_small")
 --    remote.mockbattle:openMockBattleDialog()


    if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE", true) then
    	return
    end
	if q.buttonEvent(event, self._ccbOwner.sp_icon_right) == false then return end
    app.sound:playSound("common_small")
    remote.mockbattle:mockBattleGetMainInfoRequest(function()
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMockBattleEntrance"})
    end)

end

function QUIDialogCollegeTrainMain:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogCollegeTrainMain:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogCollegeTrainMain
