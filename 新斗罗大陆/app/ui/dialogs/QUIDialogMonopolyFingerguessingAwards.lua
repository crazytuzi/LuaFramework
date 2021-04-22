-- @Author: xurui
-- @Date:   2018-10-25 12:14:17
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-04-29 15:57:04
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyFingerguessingAwards = class("QUIDialogMonopolyFingerguessingAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogMonopolyFingerguessingAwards:ctor(options)
	local ccbFile = "ccb/Widget_monopoly_reward4.ccbi"
    local callBacks = { 
		{ccbCallbackName = "onTriggerContinue", callback = handler(self, self._onTriggerContinue)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGetAward", callback = handler(self, self._onTriggerGetAward)},
    }
    QUIDialogMonopolyFingerguessingAwards.super.ctor(self, ccbFile, callBacks, options)

    self.isAnimation = true
	q.setButtonEnableShadow(self._ccbOwner.btn_getAward)
	q.setButtonEnableShadow(self._ccbOwner.btn_continue)

	
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end

    self._gameIsDone = false
end

function QUIDialogMonopolyFingerguessingAwards:viewDidAppear()
	QUIDialogMonopolyFingerguessingAwards.super.viewDidAppear(self)

	self:setAwardsInfo()
end

function QUIDialogMonopolyFingerguessingAwards:viewWillDisappear()
  	QUIDialogMonopolyFingerguessingAwards.super.viewWillDisappear(self)
end

function QUIDialogMonopolyFingerguessingAwards:setAwardsInfo()
	self._ccbOwner.reward1:setVisible(false)
	self._ccbOwner.reward2:setVisible(false)

	if remote.monopoly.fingerGuessWinCount >= 3 then
		self._ccbOwner.reward2:setVisible(true)
		self:setFinalAwards()
	elseif remote.monopoly.fingerGuessWinCount == 0 then
		-- By Kumo 解决由于3胜拿解药，正好领取大奖，大奖领完又自动弹出这个界面
		self:popSelf()
	else
		self._ccbOwner.reward1:setVisible(true)
		self:setWinAwards()
	end
end

function QUIDialogMonopolyFingerguessingAwards:setWinAwards()
	self._ccbOwner.tf_title_1:setString(string.format("恭喜您，获得了%s胜！", remote.monopoly.fingerGuessWinCount or 1))

	local currentAwards = remote.monopoly:getFingerAwards()
	local nextAwards = remote.monopoly:getFingerAwards(remote.monopoly.fingerGuessWinCount+1)

	local totalWidth = 0
	local positionX = 0
	for _, value in pairs(currentAwards) do
		local itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item_1:addChild(itemBox)
		local contentSize = itemBox:getContentSize()
		itemBox:setPositionX(positionX)
		itemBox:setScale(0.8)
		itemBox:setPromptIsOpen(true)
		local itemType = remote.items:getItemType(value.typeName)
		itemBox:setGoodsInfo(value.id, itemType, value.count)

		positionX = positionX + contentSize.width + 5
	end

	self._ccbOwner.node_award_2:setPositionX(self._ccbOwner.node_award_2:getPositionX() + positionX)
	totalWidth = totalWidth + positionX
	positionX = 0
	for _, value in pairs(nextAwards) do
		local itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item_2:addChild(itemBox)
		local contentSize = itemBox:getContentSize()
		itemBox:setPositionX(positionX)
		itemBox:setScale(0.8)
		itemBox:setPromptIsOpen(true)
		local itemType = remote.items:getItemType(value.typeName)
		itemBox:setGoodsInfo(value.id, itemType, value.count)

		positionX = positionX + contentSize.width + 5
	end
	totalWidth = totalWidth + positionX
	self._ccbOwner.node_awards:setPositionX(-totalWidth/2)
end

function QUIDialogMonopolyFingerguessingAwards:setFinalAwards()
	app.taskEvent:updateTaskEventProgress(app.taskEvent.MONOPOLY_REFINE_MEDICINE_SUCCESS_EVENT, 1)
	self._ccbOwner.tf_title_2:setString(string.format("恭喜您，获得了3胜！您获得了八瓣仙兰的青睐，只见它突然飞了起来，旋转后落入您的手中，同时孤独博的毒也解掉了一个！", remote.monopoly.fingerGuessWinCount or 1))

	local awards = remote.monopoly:getFingerAwards()

	local width = 0
	local i = 0
	for _, value in pairs(awards) do
		local itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:addChild(itemBox)
		local contentSize = itemBox:getContentSize()
		itemBox:setPositionX(width)
		itemBox:setScale(0.8)
		itemBox:setPromptIsOpen(true)
		local itemType = remote.items:getItemType(value.typeName)
		itemBox:setGoodsInfo(value.id, itemType, value.count)

		width = width + contentSize.width + 5
		i = i + 1
	end

	self._ccbOwner.node_btn_continue:setVisible(false)
	self._ccbOwner.node_btn_getAward:setPositionX(0)
	self._ccbOwner.btn_tf_getAward:setString("获得大奖")

	if i > 1 then
		self._ccbOwner.node_item:setPositionX(-width/2)
	end
end

-- function QUIDialogMonopolyFingerguessingAwards:getAwards(awardCount)
-- 	local awards = {}
-- 	if awardCount then
-- 		awards = QStaticDatabase:sharedDatabase():getluckyDrawById("finger_win"..awardCount)
-- 	else
-- 		for i = 1, remote.monopoly.fingerGuessWinCount do
-- 			local data = QStaticDatabase:sharedDatabase():getluckyDrawById("finger_win"..i)
-- 			for _, value in ipairs(data) do
-- 				awards[#awards+1] = value
-- 			end
-- 		end
-- 	end

-- 	--去重
-- 	local finalAwards = {}
-- 	for _, value in ipairs(awards) do
-- 		local index = value.id
-- 		if index == nil then
-- 			index = value.typeName
-- 		end
-- 		if finalAwards[index] then
-- 			finalAwards[index].count = finalAwards[index].count + value.count
-- 		else
-- 			finalAwards[index] = value
-- 		end
-- 	end

-- 	return finalAwards
-- end

function QUIDialogMonopolyFingerguessingAwards:_onTriggerContinue()
  	app.sound:playSound("common_small")

  	self._gameIsDone = false
  	self:_onTriggerClose()
end

function QUIDialogMonopolyFingerguessingAwards:_onTriggerGetAward()
  	app.sound:playSound("common_small")

  	remote.monopoly:monopolyGetFingerRewardRequest(remote.monopoly.fingerGuessWinCount, function()
  			if self:safeCheck() then
	  			remote.monopoly.fingerGuessWinCount = 0
				self._gameIsDone = true
				self:_onTriggerClose()
			end
  		end)
end

function QUIDialogMonopolyFingerguessingAwards:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogMonopolyFingerguessingAwards:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if self._gameIsDone == false then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonopolyFingerguessing"})
	end
end

return QUIDialogMonopolyFingerguessingAwards
