local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetQuestionAvatar = class("QUIWidgetQuestionAvatar", QUIWidget)

local QUIWidgetActorActivityDisplay = import("...widgets.actorDisplay.QUIWidgetActorActivityDisplay")
local QUIViewController = import("...QUIViewController")

function QUIWidgetQuestionAvatar:ctor(options)
	QUIWidgetQuestionAvatar.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetQuestionAvatar:onEnter()
	QUIWidgetQuestionAvatar.super.onEnter(self)
	self._questionProxy = cc.EventProxy.new(remote.question)
	self._questionProxy:addEventListener(remote.question.EVENT_UPDATE, function ()
		self:showAvatar()
	end)
	self:showAvatar()
end

function QUIWidgetQuestionAvatar:onExit()
	QUIWidgetQuestionAvatar.super.onExit(self)
	self:_removeAvatar()
	self._questionProxy:removeAllEventListeners()
end

function QUIWidgetQuestionAvatar:showAvatar()
	if remote.question:checkCanQuestion() == true then
		self:_initAvatar()
	else
		self:_removeAvatar()
	end
end

function QUIWidgetQuestionAvatar:_initAvatar()
	if self._actorScheduleHandle == nil then
		self._actorScheduleHandle = scheduler.scheduleGlobal(handler(self, self._updateActors), 0.5)
	end
end

function QUIWidgetQuestionAvatar:_removeAvatar()
	if self._actorScheduleHandle ~= nil then
		scheduler.unscheduleGlobal(self._actorScheduleHandle)
		self._actorScheduleHandle = nil
	end
	if self._avatarWidget ~= nil then
		self._avatarWidget:removeAllEventListeners()
		self._avatarWidget:stopWalking()
		self._avatarWidget:stopDisplay()
		self._avatarWidget:removeFromParentAndCleanup(true)
		self._avatarWidget = nil
	end
end

function QUIWidgetQuestionAvatar:_updateActors()
	if self._avatarWidget == nil then
		local range = {x1 = -140, x2 = 60}
		self._avatarWidget = QUIWidgetActorActivityDisplay.new(1001, {isSelf = true})
		self._avatarWidget:getActor():setScale(0.7)
		local extra_scale = display.height / display.width * UI_DESIGN_WIDTH / UI_DESIGN_HEIGHT
		self._avatarWidget:setScale(0.73 * extra_scale)
		self._avatarWidget:setPositionY(100 - display.height/2)
		self._avatarWidget:setPositionX(math.random(range.x1, range.x2))
		-- self._avatarWidget:setPositionX(0)
		self._avatarWidget:setWalkRange(range)
		self._avatarWidget:addEventListener(self._avatarWidget.EVENT_CLICK, handler(self, self._actorClickHandler))
		self:getView():addChild(self._avatarWidget)

		local widget = QUIWidget.new("ccb/effects/gantanhao.ccbi")
		widget:setPositionY(130)
		self._avatarWidget:addChild(widget)
	end
	if self._avatarWidget.nextOrderTime == nil then
		self._avatarWidget.nextOrderTime = q.time()
	end
	if self._avatarWidget.nextOrderTime <= q.time() then
		if not self._avatarWidget:isWalking() and not self._avatarWidget:isActorPlaying() then
			local roll = math.random(1, 100)
			if roll < 50 then
				-- walk
				local distance
				local x, y = self._avatarWidget:getPosition()
				local moveDistance = self._avatarWidget:getWalkRange().x2 - self._avatarWidget:getWalkRange().x1
				distance = math.random(50, distance)
				if x - distance < self._avatarWidget:getWalkRange().x1 then
					x = x + distance
				elseif x + distance > self._avatarWidget:getWalkRange().x2 then
					x = x - distance
				else
					x = math.random(0, 100) < 50 and (x + distance) or (x - distance)
				end
				if x > self._avatarWidget:getWalkRange().x2 then
					x = self._avatarWidget:getWalkRange().x2
				elseif x < self._avatarWidget:getWalkRange().x1 then
					x = self._avatarWidget:getWalkRange().x1
				end
				self._avatarWidget:walkto({x = x, y = y})
			elseif roll < 75 then
				-- victory
				self._avatarWidget:displayWithBehavior(ANIMATION_EFFECT.VICTORY)
			else
				-- standby
				self._avatarWidget:stopWalking()
				self._avatarWidget:stopDisplay()
			end
			self._avatarWidget.nextOrderTime = q.time() + math.random(350, 450) / 100
		end
	end
end

--点击人物 打开问答界面
function QUIWidgetQuestionAvatar:_actorClickHandler()
	if remote.question:checkCanQuestion() == true then 
		local questionInfo = remote.question:getQuestion()
		if questionInfo.answerCount < #questionInfo.puzzleIdList then
    		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionQuestion"})
		-- elseif questionInfo.hasTakenFinalReward == false and questionInfo.correctCount > 0 then
  --   		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionQuestionAwards"})
		end
    end
end

return QUIWidgetQuestionAvatar