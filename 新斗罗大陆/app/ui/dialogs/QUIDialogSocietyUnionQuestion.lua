-- 宗门答题
local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogSocietyUnionQuestion = class("QUIDialogSocietyUnionQuestion", QUIDialogBaseUnion)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSocirtyUnionQuestion = import("..widgets.question.QUIWidgetSocirtyUnionQuestion")
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogSocietyUnionQuestion:ctor(options)
	self._options = options
	local ccbFile = "ccb/Dialog_wenjuandati1.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSocietyUnionQuestion.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._awardItem = {}
	self._awardCount = {}
	self._awardType = {}
	self._itemApartDistance = 105
	self._globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
	self:refreshQuestion()
end

function QUIDialogSocietyUnionQuestion:refreshQuestion()
	self._questionInfo = remote.question:getQuestion()
	self:showAllCorrectAwards()

	if self._questionInfo then
		if self._questionInfo.hasTakenFinalReward then
			app.tip:floatTip("宗门答题已结束，请改日再来~")			
		else
			self:showQuestion()
		end
	end
end

--显示答题
function QUIDialogSocietyUnionQuestion:showQuestion()
	self._questionId = self._questionInfo.puzzleIdList[self._questionInfo.answerCount+1]
	self._questionConfig = QStaticDatabase:sharedDatabase():getQuestionById(self._questionId)
	self._ccbOwner.tf_question:setString(self._questionConfig.subject)
	self:showQuestionAnswerCount()
	self:showNowAwards()

	if self._optionWidgets == nil then
		self._optionWidgets = {}
	end
	for index, option in ipairs(self._questionInfo.answerList) do
		if not self._optionWidgets[index] then
			local widget = QUIWidgetSocirtyUnionQuestion.new()
			widget:addEventListener(QUIWidgetSocirtyUnionQuestion.EVENT_SELECT, handler(self, self._selectHandler))
			self._ccbOwner["node_"..index]:addChild(widget)
			self._optionWidgets[index] = widget
		end
		self._optionWidgets[index]:setInfo(index, option)
	end
end

--显示答题
function QUIDialogSocietyUnionQuestion:showRightAnswer(index, callback)
	for _,widget in ipairs(self._optionWidgets) do
		widget:setRightAnswer(self._questionConfig.right_answers, index)
	end

	local isRight = tostring(self._optionWidgets[index]:getWidgetOption()) == tostring(self._questionConfig.right_answers)
    app.taskEvent:updateTaskEventProgress(app.taskEvent.UNION_QUESTION_EVENT, 1, false, isRight)
	if isRight then
        local position = ccp(self._ccbOwner.awardsNode:getPosition())

		local effect = QUIWidgetAnimationPlayer.new()
    	self:getView():addChild(effect)
    	effect:playAnimation("ccb/Widget_union_question.ccbi", function(ccbOwner)
				local itemInfo1 = remote.items:getWalletByType(self._awardType[1])
				if itemInfo1 then
    				ccbOwner.tf_desc1:setString(string.format("%s +%s", itemInfo1.nativeName or "", self._awardCount[1]))
    			end
				local itemInfo2 = remote.items:getWalletByType(self._awardType[2])
				if itemInfo2 then
    				ccbOwner.tf_desc2:setString(string.format("%s +%s", itemInfo2.nativeName or "", self._awardCount[2]))
    			end
    		end, function()
				local arr = CCArray:create()
		    	arr:addObject(CCCallFunc:create(function()
						for i, value in ipairs(self._awardItem) do
					    	if self._itemBoxNowAwards[i] then
					    		self._itemBoxNowAwards[i]:scrollItemAddNum(self._awardCount[i])
					    	end

					    	local effect = QUIWidgetAnimationPlayer.new()
					    	effect:setPositionX((i-1) * self._itemApartDistance - 10)
					    	self._ccbOwner.awardsNode:addChild(effect, 10)
					    	effect:playAnimation("ccb/effects/UseItem2.ccbi", nil, function()
					                effect:removeFromParentAndCleanup(true)
					            end)
					    end
		    		end))
		    	arr:addObject(CCDelayTime:create(17/30))
		    	arr:addObject(CCCallFunc:create(function()
		    			if callback then
		    				callback()
		    			end
		    		end))
    			self:getView():runAction(CCSequence:create(arr))
            end)

    else
		local arr = CCArray:create()
    	arr:addObject(CCDelayTime:create(1))
    	arr:addObject(CCCallFunc:create(function()
			if callback then
				callback()
			end
		end))
    	self:getView():runAction(CCSequence:create(arr))
	end
end

--显示答题数量和正确次数
function QUIDialogSocietyUnionQuestion:showQuestionAnswerCount()
	local maxCount = self._globalConfig.everyday_answer_num.value
	local answerCount = self._questionInfo.answerCount
	local correctCount = self._questionInfo.correctCount
	self._ccbOwner.questionTotalCount:setString("第"..(answerCount + 1).."/"..maxCount.."题")
	self._ccbOwner.questionRightCount:setString("答对："..correctCount.."/"..maxCount)
end

--显示累计奖励
function QUIDialogSocietyUnionQuestion:showNowAwards()
	local correctCount = self._questionInfo.correctCount
	local awardString = self._globalConfig.GHDT_REWARD_GOLD.value
	if not self._itemBoxNowAwards then
		self._itemBoxNowAwards = {}
	end
	local awards = string.split(awardString, ";")
	local index = 0
	for _,value in ipairs(awards) do
		local awardCell = string.split(value, "^")
		local item = awardCell[1]
		local count = tonumber(awardCell[2]) or 0
		local itemType = nil
		if tonumber(item) then
			itemType = ITEM_TYPE.ITEM
		else
			itemType = item
		end

		self._awardItem[index + 1] = item
		self._awardCount[index + 1] = count
		self._awardType[index + 1] = itemType

		local itemBox = QUIWidgetItemsBox.new()
		itemBox:setGoodsInfo(item, itemType, count*correctCount)
		itemBox:setPositionX(index * self._itemApartDistance)
		itemBox:setPromptIsOpen(true)
		index = index + 1
		if self._itemBoxNowAwards and self._itemBoxNowAwards[index] then
			self._itemBoxNowAwards[index]:removeFromParent()
		end
		self._itemBoxNowAwards[index] = itemBox
		self._ccbOwner.awardsNode:addChild(self._itemBoxNowAwards[index])
	end
end

--显示全部答对奖励
function QUIDialogSocietyUnionQuestion:showAllCorrectAwards()
	if self._globalConfig == nil then
		self._globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
	end
	local awardString = self._globalConfig.GHDT_REWARD_ALLRIGHT.value
	local awards = string.split(awardString, ";")
	for _,value in ipairs(awards) do
		local awardCell = string.split(value, "^")
		local item = awardCell[1]
		local count = tonumber(awardCell[2]) or 0
		local itemType = nil
		if tonumber(item) then
			itemType = ITEM_TYPE.ITEM
		else
			itemType = item
		end

		local itemBox = QUIWidgetItemsBox.new()
		itemBox:setGoodsInfo(item, itemType, count)
		itemBox:setPromptIsOpen(true)
		if self._itemBoxFinalAwards then
			self._itemBoxFinalAwards:removeFromParent()
		end
		self._itemBoxFinalAwards = itemBox
		self._ccbOwner.finalAwardNode:addChild(itemBox)
	end
end

function QUIDialogSocietyUnionQuestion:_selectHandler(event)
	if app.unlock:checkLock("UNION_ANSWER") == false then
		app.tip:floatTip("宗门条件不足，无法答题~")
		self:playEffectOut()
		return
	end
	if not remote.question:checkTime() then
		app.tip:floatTip("答题时间已过，等待下次答题~")
		self:playEffectOut()
		return
	end

	self:enableTouchSwallowTop()
	remote.question:consortiaSolveQuestionRequest(self._questionId, event.index, function (data)
		local response = data.consortiaSolveQuestionResponse
		if response and response.userQuestionInfo then
			if self:safeCheck() then
				self:showRightAnswer(event.index, function()
					if response.userQuestionInfo.hasTakenFinalReward then
						local correctCount = response.userQuestionInfo.correctCount or 0
						local multipleCount = response.multiple or 1
						local awards = response.awardStr or ""
						if correctCount == 0 then
							app.tip:floatTip("答题已结束，很可惜没有答对任何题目~")
							self:playEffectOut()
						else
							self:popSelf()
							app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionQuestionFinalAward", 
								options = {correctCount = correctCount, awards = awards, multipleCount = multipleCount}}, {isPopCurrentDialog = true})	
						end
					else
						self:disableTouchSwallowTop()
						self:refreshQuestion()
					end
				end)
			end
		end
	end,function ()
	end)
end

function QUIDialogSocietyUnionQuestion:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSocietyUnionQuestion