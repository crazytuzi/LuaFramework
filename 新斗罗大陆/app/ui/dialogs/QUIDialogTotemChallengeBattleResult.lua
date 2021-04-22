-- @Author: liaoxianbo
-- @Date:   2020-02-12 10:44:07
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-19 12:05:40
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTotemChallengeBattleResult = class("QUIDialogTotemChallengeBattleResult", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QBattleDialogFightEndRecord = import("...ui.battle.QBattleDialogFightEndRecord")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QPVPMultipleFightInfo = import("...ui.battle.QPVPMultipleFightInfo")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogTotemChallengeBattleResult:ctor(options)
	local ccbFile = "ccb/Dialog_StormArena_fightwin.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, self._onTriggerNext)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, self._onTriggerData)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
    }
    QUIDialogTotemChallengeBattleResult.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._callBack = options.callback

    local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
    CalculateUIBgSize(self._ccbOwner.ly_bg)
	if self._ccbOwner.node_star ~= nil then
		self._ccbOwner.node_star:setVisible(false)
	end
	self._ccbOwner.node_title_win:setVisible(options.isWin)
	self._ccbOwner.node_title_lose:setVisible(not options.isWin)
	self._ccbOwner.node_detail:setVisible(false)

	self._isWin = options.isWin
	self.info = options.info
	self._scoreList = self.info.scoreList
	self._replayInfo = self.info.replayInfo

	self._ccbOwner.firstnumber:setString(self.info.team1Score)
	self._ccbOwner.secondnumber:setString(self.info.team2Score)

	self._ccbOwner.team1Name:setString(self.info.team1Name or "")
	self._ccbOwner.team2Name:setString(self.info.team2Name or "")

	local team1avatar = QUIWidgetAvatar.new(self.info.team1avatar)
	local team2avatar = QUIWidgetAvatar.new(self.info.team2avatar)
    self._ccbOwner.team1Head:addChild(team1avatar)
    self._ccbOwner.team2Head:addChild(team2avatar)

    self.rankInfo = {}
	if options.rankInfo ~= nil then
	   self.rankInfo = options.rankInfo
	end
	
	

 	self._itemsBox = {}
	local awards = {}
	local rewardTbl = {}
	remote.items:analysisServerItem(self.info.reward or "", rewardTbl)
	for i, value in pairs(rewardTbl) do
		table.insert(awards, {id = value.id or 0, type = value.typeName, count = value.count or 0})
	end
	local yield = 1
	local itemCount = 0
	for index,value in ipairs(awards) do
    	self._itemsBox[index] = QUIWidgetItemsBox.new()
    	self._itemsBox[index]:setPromptIsOpen(true)
		self._ccbOwner.node_item1:addChild(self._itemsBox[index])
		self._itemsBox[index]:setPositionX((index-1) * 100)
		itemCount = math.ceil((value.count or 0) / yield)
		self._itemsBox[index]:setGoodsInfo(value.id, value.type or value.typeName, itemCount)
		if self.info.activityYield and self.info.activityYield > 1 and value.type == ITEM_TYPE.MARITIME_MONEY then
			self._itemsBox[index]:setRateActivityState(true, self.info.activityYield)
		end
	end

	local awardsNum = #awards
	if awardsNum < 5 and awardsNum > 0 then
		self._ccbOwner.node_item:setPositionX(-(awardsNum - 1) * 50)
	end
	self._isWin = options.isWin
	if self._isWin == true and options.rivalId and options.isFriend ~= true then
		remote.stormArena:setTopRankUpdate(self.rankInfo, options.rivalId)
	else
		remote.stormArena:stormArenaRefresh(self.rankInfo)
	end
  	
  	if self._isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
	else
		self._audioHandler = app.sound:playSound("battle_failed")
	end

	if options and options.isQuickPass then
		self._ccbOwner.node_data:setVisible(false)
	end
    audio.stopBackgroundMusic()
	
	self._openTime = q.time()		
end

function QUIDialogTotemChallengeBattleResult:viewDidAppear()
	QUIDialogTotemChallengeBattleResult.super.viewDidAppear(self)

	self:addBackEvent(true)
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)

end

function QUIDialogTotemChallengeBattleResult:viewWillDisappear()
  	QUIDialogTotemChallengeBattleResult.super.viewWillDisappear(self)

	self:removeBackEvent()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
    if self._yieldScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._yieldScheduler)
    	self._yieldScheduler = nil
    end	
end

function QUIDialogTotemChallengeBattleResult:setItemBoxShakeEffect(node)
	local time = 0.032
	local ccArray = CCArray:create()
	ccArray:addObject(CCScaleTo:create(time, 0.96))
	ccArray:addObject(CCScaleTo:create(time, 1))
	node:runAction(CCSequence:create(ccArray))
end

function QUIDialogTotemChallengeBattleResult:_onTriggerNext(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
  	app.sound:playSound("common_item")
	self:_onTriggerClose()
end

function QUIDialogTotemChallengeBattleResult:_onTriggerData(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_data) == false then return end
    app.sound:playSound("common_small")
    -- QBattleDialogFightEndRecord.new() 

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightEndRecord", 
     	options = {info = self.info}}, {isPopCurrentDialog = false})

end

function QUIDialogTotemChallengeBattleResult:_backClickHandler()
	if q.time() - self._openTime > 3.5 then
		self:_onTriggerClose()
  	end
end

function QUIDialogTotemChallengeBattleResult:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogTotemChallengeBattleResult:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if self._isWin then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_EXIT_FROM_BATTLE})
	end
	
	if callback then
		callback()
	end
end

return QUIDialogTotemChallengeBattleResult
