-- @Author: liaoxianbo
-- @Date:   2020-08-05 14:30:37
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-21 17:07:39
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreEventFinger = class("QUIDialogMazeExploreEventFinger", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogMazeExploreEventFinger:ctor(options)
	local ccbFile = "ccb/Widget_monopoly_hammer.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClick1)},
		{ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClick2)},
		{ccbCallbackName = "onTriggerClick3", callback = handler(self, self._onTriggerClick3)},
		{ccbCallbackName = "onTriggerStart", callback = handler(self, self._onTriggerStart)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMazeExploreEventFinger.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
	q.setButtonEnableShadow(self._ccbOwner.btn_action)
	q.setButtonEnableShadow(self._ccbOwner.btn_close)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._callBack = options.callBack
    self._gridInfo = options.gridInfo or {}
    self._ccbOwner.node_btn_close:setVisible(true) 
    self._ccbOwner.btn_one:setPositionX(213)
    self._power = options.power or 0
    --1, 是剪刀；2，是拳；3，是布
    self._chooseFinger = 1
    if q.isEmpty(self._gridInfo) == false then
    	self._ccbOwner.tf_des:setString(self._gridInfo.des)
    end
    self._loseTimes = 0
    self._maxWintimes = db:getConfigurationValue("max_win_times_1") or 6
end

function QUIDialogMazeExploreEventFinger:viewDidAppear()
	QUIDialogMazeExploreEventFinger.super.viewDidAppear(self)

	self:setChooseStated()
end

function QUIDialogMazeExploreEventFinger:viewWillDisappear()
  	QUIDialogMazeExploreEventFinger.super.viewWillDisappear(self)
end

function QUIDialogMazeExploreEventFinger:setChooseStated()
	self._ccbOwner.sp_normal_1:setVisible(not (self._chooseFinger == 1))
	self._ccbOwner.sp_normal_2:setVisible(not (self._chooseFinger == 2))
	self._ccbOwner.sp_normal_3:setVisible(not (self._chooseFinger == 3))
end

function QUIDialogMazeExploreEventFinger:playFigerguessEffect()
	math.randomseed(q.OSTime())
	local enemyFinger = math.random(1, 3)

	-- 1，是赢；2，是输；3，是平局
	local isWin = 3
	if self._chooseFinger ~= enemyFinger then
		if self._chooseFinger == 1 then
			if enemyFinger == 2 then
				isWin = 2
			else
				isWin = 1
			end
		elseif self._chooseFinger == 2 then
			if enemyFinger == 1 then
				isWin = 1
			else
				isWin = 2
			end
		elseif self._chooseFinger == 3 then
			if enemyFinger == 1 then
				isWin = 2
			else
				isWin = 1
			end
		end
	end
	--1, 是剪刀；2，是拳；3，是布
	if self._loseTimes > self._maxWintimes then
		if self._chooseFinger == 1 then
			enemyFinger = 3
		elseif self._chooseFinger == 2 then
			enemyFinger = 1
		elseif self._chooseFinger == 3 then
			enemyFinger = 2
		end
		isWin = 1
	end

	if self._fingerEffcet == nil then
		self._fingerEffcet = QUIWidgetAnimationPlayer.new()
		self:getView():addChild(self._fingerEffcet)
	end

	self._fingerEffcet:playAnimation("effects/Widget_monopoly_caiquan.ccbi", function(ccbOwner)
			ccbOwner.sp_win:setVisible(false)
			ccbOwner.sp_lose:setVisible(false)
			ccbOwner.sp_perfect:setVisible(false)
			ccbOwner.node_win_effect:setVisible(false)
			if isWin == 1 then
				ccbOwner.sp_win:setVisible(true)
				ccbOwner.node_win_effect:setVisible(true)
			elseif isWin == 2 then
				ccbOwner.sp_lose:setVisible(true)
			end

			local enemyPath = QResPath("monopolyFinger")[enemyFinger]
			local myPath = QResPath("monopolyFinger")[self._chooseFinger]
			if enemyPath then
				QSetDisplayFrameByPath(ccbOwner.sp_enemy, enemyPath)
			end
			if myPath then
				QSetDisplayFrameByPath(ccbOwner.sp_my, myPath)
			end
		end, function()

			if isWin == 3 or isWin == 2 then
				self._ccbOwner.node_parent:setVisible(true)
				self:setChooseStated()
				self._ccbOwner.tf_des:setString(self._gridInfo.answer_des or "")
				self._ccbOwner.buttonText:setString("再试一次")
			else
				app.tip:floatTip("你猜拳获胜，可以继续前进了")
				self:showWinAward()
			end
			if isWin == 2 then
				self._loseTimes = self._loseTimes+1
			end
			if isWin == 2 or isWin == 1 then
				if self._callBack then
					self._callBack(isWin == 1)
				end
			end
		end)
end

function QUIDialogMazeExploreEventFinger:showWinAward()
	self._showAwards = true
	self:playEffectOut()
end

function QUIDialogMazeExploreEventFinger:_onTriggerClick1()
	if self._chooseFinger == 1 then return end

	self._chooseFinger = 1
	self:setChooseStated()
end

function QUIDialogMazeExploreEventFinger:_onTriggerClick2()
	if self._chooseFinger == 2 then return end

	self._chooseFinger = 2
	self:setChooseStated()
end

function QUIDialogMazeExploreEventFinger:_onTriggerClick3()
	if self._chooseFinger == 3 then return end

	self._chooseFinger = 3
	self:setChooseStated()
end

function QUIDialogMazeExploreEventFinger:_onTriggerStart()
	app.sound:playSound("common_small")

	if self._chooseFinger < 1 and self._chooseFinger > 3 then
		return
	end
    if self._gridInfo.energy and self._power < self._gridInfo.energy then
        app.tip:floatTip("精神力不足。")
        self:_onTriggerClose()
        return
    end
	self._ccbOwner.node_parent:setVisible(false)

	self:playFigerguessEffect()
end

function QUIDialogMazeExploreEventFinger:_onTriggerClose( )
	app.sound:playSound("common_small")
	self._closeTag = true
	self:playEffectOut()
end

function QUIDialogMazeExploreEventFinger:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	-- if callback then
	-- 	callback(self._backIsWin == 1,self._closeTag)
	-- end
end


return QUIDialogMazeExploreEventFinger
