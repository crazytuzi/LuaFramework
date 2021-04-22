-- @Author: liaoxianbo
-- @Date:   2020-02-17 16:53:40
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-05-01 12:23:26
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnityFastBattle = class("QUIDialogUnityFastBattle", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIViewController = import("..QUIViewController")
local QUIWidgetEliteBattleAgain = import("..widgets.QUIWidgetEliteBattleAgain")
local QUIWidgetEliteBattleAgainTargetItem = import("..widgets.QUIWidgetEliteBattleAgainTargetItem")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetInvasionFastFightAwardClient = import("..widgets.QUIWidgetInvasionFastFightAwardClient")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogUnityFastBattle:ctor(options)
	local ccbFile = "ccb/Dialog_EliteBattleAgain.ccbi"
	local callBacks = {
						{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerNext)},
                        {ccbCallbackName = "onTriggerQuickFightOne", callback = handler(self, self._onTriggerQuickFightTen)},
                        {ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
					}
    QUIDialogUnityFastBattle.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)
    self._size = self._ccbOwner.layer_content:getContentSize()

    self._content = CCNode:create()
    local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._size.width,self._size.height)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionY(-self._size.height)
    ccclippingNode:setStencil(layerColor)
    ccclippingNode:addChild(self._content)
    self._ccbOwner.node_contain:addChild(ccclippingNode)
    self._ccbOwner.frame_tf_title:setString(options.name or "扫 荡")

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_contain, self._size.width, self._size.height, 0, layerColor:getPositionY(), handler(self, self._onEvent))

    self._ccbOwner.frame_btn_close:setVisible(false)
    self._awardPanels = {}
    self._awardItems = {}
    self._isAnimation = true
    self._isEliteBattleAgain = false
    self._ccbOwner.touch_button:setVisible(false)
	self._titleStringFormat = options.titleStringFormat or "第%s次"
	self._callBack = options.callback

	self._isOnlyClose = options.isOnlyClose or false

	if options.labelName then
		self._ccbOwner.label_name:setString(options.labelName)
	end
    if options.isCanFast == true then
        self._ccbOwner.tf_one:setString("再扫一次")
    else
        self._ccbOwner.tf_one:setString("确定")
    end
    self._fastType = options.fast_type
	self:initData(options)  


    self._totalHeight = 0
    self._awards = {}

	if options.awards ~= nil then
        self._awards = options.awards
        self._offsetMoveH = 60
        self._isShowEnd = false
		self:setAwards(options.awards)
    else
        self._isShowEnd = true
        self:_autoMoveEnd()
	end
end

function QUIDialogUnityFastBattle:initData(options)
	if self._fastType == FAST_FIGHT_TYPE.DUNGEON_FAST then
	    self._extraExpItem = options.extraExpItem or {}
	    local prizeWheelMoneyGot = options.prizeWheelMoneyGot or 0
	    if prizeWheelMoneyGot > 0 then
	        table.insert(self._extraExpItem, {type = ITEM_TYPE.PRIZE_WHEEL_MONEY, count = prizeWheelMoneyGot, isActivity = true})
	    end		
	    self._targetItem = options.targetItem or {}
	    self._inPackCount = options.targetItem and options.targetItem.inPackCount or 0
	    self._invasion = options.invasion	
	    self.info = options.info
	    self.config = options.config
	    self._isFromHeroInfo = options.isFromHeroInfo

	elseif self._fastType == FAST_FIGHT_TYPE.RANK_FAST then
		self._yield = options.yield
	    self._yieldType = options.yieldType or "arena_money_crit"
	    self._activityYield = options.activityYield or 1
	    self._userComeBackRatio = options.userComeBackRatio or 1
	    self._score = options.score or 0		
	    self._yieldLevel = 0
	    if self._yield ~= nil and self._yield > 1 and self._yieldType then
	        self._yieldLevel = db:getYieldLevelByYieldData(self._yield, self._yieldType)
	    end
	elseif self._fastType == FAST_FIGHT_TYPE.BOSS_FAST then
	    self._totalDamage = 0               --累计伤害
    	self._totalAwards = 0               --累计奖励
    	self._numY = 0
    	self._count = 0 -- 攻击了几次
    	self._offsetMoveH = 60
        self._fightResult = options.fightResult
        self._oldInvasionInfo = options.oldInvasionInfo
        self._newInvasionInfo = options.newInvasionInfo
        self._bossInfo = options.bossInfo
        self._userComeBackRatio = options.userComeBackRatio
    elseif self._fastType == FAST_FIGHT_TYPE.METALCITY_FAST then
    	self._info = options.info
        self._userComeBackRatio = options.userComeBackRatio
	end
end

function QUIDialogUnityFastBattle:viewDidAppear()
	QUIDialogUnityFastBattle.super.viewDidAppear(self)

    self._touchLayer:setAttachSlide(true)
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onEvent))
    self._touchLayer:disable()

    if self._fastType == FAST_FIGHT_TYPE.BOSS_FAST then
    	self:showAwardsAnimation()
    end
end

function QUIDialogUnityFastBattle:viewWillDisappear()
  	QUIDialogUnityFastBattle.super.viewWillDisappear(self)

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)

end

function QUIDialogUnityFastBattle:setAwards(awards)
	self._awardPanels = {}
    self._awardItems = {}
	self._moveIndex = 1
	local numY = 0
	local index = 1
	for _,award in pairs(awards) do
		local panel = QUIWidgetEliteBattleAgain.new()
		self._awardPanels[#self._awardPanels+1] = panel
		panel:setPositionY(numY)
		panel:setTitle(string.format(self._titleStringFormat, index))
		panel:setScore(self._score)
		if self._fastType == FAST_FIGHT_TYPE.DUNGEON_FAST then
        	panel:setDungeonType(self.info.dungeon_type)
        end
		-- panel:setInfo(award.awards)
		panel:setInfo(award.awards, self._yield, self._yieldLevel, self._activityYield, self._userComeBackRatio)
		panel:setVisible(false)
		self._content:addChild(panel)
		
		--将所有奖励物品保存起来
		for _, value in pairs(panel._itemsBox) do
		  table.insert(self._awardItems,value)
        end

		numY = numY - panel:getHeight()
        self._panelWidth = panel:getWidth()
        self._panelHeight = panel:getHeight()
		index = index + 1
	end
	self._totalHeight = math.abs(numY)
	if self._fastType == FAST_FIGHT_TYPE.DUNGEON_FAST then
	    self._noticeTip = QUIWidgetEliteBattleAgainTargetItem.new({inPackCount = self._inPackCount})
	    self._ccbOwner.noticeTips:addChild(self._noticeTip)
    	self:setTenButton()
    end
	self:autoMove()
end
function QUIDialogUnityFastBattle:showAwardsAnimation()
	self._moveIndex = 1
 	for _, fightInfo in ipairs(self._fightResult) do
        local damage = fightInfo.hurt or 0
        local awards = {}
        -- local totalAward = remote.user.consortiaMoney - oldConsortiaMoney
        local baseAward = fightInfo.baseIntrusionMoney or 0
        local hurtAward = fightInfo.addIntrusionMoney or 0
        local award = baseAward + hurtAward
    
        if award > 0 then
            table.insert(awards, 1, {type = ITEM_TYPE.INTRUSION_MONEY, count = award})
            table.insert(awards, 2, {type = ITEM_TYPE.INTRUSION_MONEY, count = hurtAward})
            table.insert(awards, 3, {type = ITEM_TYPE.INTRUSION_MONEY, count = baseAward})
        end
        self._totalDamage = self._totalDamage + damage
        self._totalAwards = self._totalAwards + award

        self:setBossAwards(awards, damage)
    end

    self:autoMove()
end

function QUIDialogUnityFastBattle:setBossAwards(award, damage)
    local panel = QUIWidgetInvasionFastFightAwardClient.new()

    local info = {}
    info.award = award
    info.bossId = self._bossId
    info.damage = damage

    self._awardPanels[#self._awardPanels + 1] = panel
    panel:setPositionY(self._numY)
    self._count = self._count + 1
    panel:setTitle(string.format(self._titleStringFormat, self._count))
    panel:setInfo(info, self._bossInfo, self._userComeBackRatio)
    panel:setVisible(false)
    self._content:addChild(panel)

    --将所有奖励物品保存起来
    for _, value in pairs(panel._itemsBox) do
        table.insert(self._awardItems, value)
    end

    local conetentSize = panel:getContentSize()
    self._numY = self._numY - conetentSize.height
    self._panelWidth = conetentSize.width
    self._panelHeight = conetentSize.height

    self._totalHeight = math.abs(self._numY)
end
function QUIDialogUnityFastBattle:setTenButton()
    self._ccbOwner.btn_one:setVisible(false) 
    self._ccbOwner.node_btn_goto:setVisible(false)

    local tenBtnTF = ""
    local perNum = 10

    if self.info.dungeon_type == DUNGEON_TYPE.WELFARE then
        if remote.welfareInstance:canBattle() then
            perNum = 1
        else
            -- perNum = 0
            perNum = 1
        end
    elseif self.info.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or self.info.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE then
        perNum = 1
    else
        local fightCount = remote.instance:getFightCountBydungeonId(self.info.dungeon_id)
        if #self._awardPanels == 1 then
            perNum = 1
        else
            if fightCount < perNum then
                perNum = fightCount
            end
            local num = math.floor(remote.user.energy/self.config.energy)
            if num < perNum then
                perNum = num
            end
            if perNum == 0 then 
                perNum = 10
                if self.info.attack_num < 10 then
                    perNum = 3
                end
            end
        end
    end

    tenBtnTF = "再扫"..perNum.."次"
    self._ccbOwner.tf_one:setString(tenBtnTF)
end 

function QUIDialogUnityFastBattle:showGotoButton()
    local targetNumber = self:getTargetNumber(self._moveIndex)
    if self._targetItem.count and targetNumber >= self._targetItem.count then
        self._ccbOwner.node_btn_goto:setVisible(true)
        if self._isFromHeroInfo then
            local itemConfig = db:getItemByID(self._targetItem.id)
            if itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
                self._ccbOwner.tf_goto:setString("前往升星")
            end
        end
        self._ccbOwner.btn_one:setPositionX(-150)
    else
        self._ccbOwner.btn_one:setPositionX(0)
    end
end

function QUIDialogUnityFastBattle:getTargetNumber(index)
    local count = 0
    for i = 1, index do
        if self._awards[i] then
            for _, value in ipairs(self._awards[i].awards) do
                if value.id == self._targetItem.id then
                    count = count + value.count or 0
                end
            end
        end
    end

    return count + (self._inPackCount or 0)
end

function QUIDialogUnityFastBattle:autoMove()
    self._moveTime = 0.15
    if #self._awardPanels == 1 then
        self._content:setPositionY(0)
        self._touchLayer:disable()
        self._ccbOwner.touch_button:setVisible(true)
        self._awardPanels[self._moveIndex]:setVisible(true)
        self._awardPanels[self._moveIndex]:startAnimation(function()
        	if self._noticeTip then
            	self._noticeTip:setInfo(self._targetItem.id, self:getTargetNumber(self._moveIndex), self._targetItem.count)
            end
            self:_autoMoveWithFinishedAnimation(70)
        end)
    else
    	if self._moveIndex <= #self._awardPanels and self._isAnimation then
    	    self._touchLayer:disable()
    	    self._awardPanels[self._moveIndex]:setVisible(true)
    	    self._awardPanels[self._moveIndex]:startAnimation(function()
                local rate = 1
                if self._moveIndex < 2 then
                    rate = 0
                end
                local actionArrayIn = CCArray:create()
                actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0,rate * self._panelHeight)))
                actionArrayIn:addObject(CCCallFunc:create(function () 
                    self:_removeAction()
                    self:autoMove()
                end))
                local ccsequence = CCSequence:create(actionArrayIn)
                self.actionHandler = self._content:runAction(ccsequence)
                if self._noticeTip then
                	self._noticeTip:setInfo(self._targetItem.id, self:getTargetNumber(self._moveIndex), self._targetItem.count)
                end
                self._moveIndex = self._moveIndex + 1
            end)
        elseif self._isAnimation == false then
            self._touchLayer:disable()
            local num = self._moveIndex
            for i = self._moveIndex, #self._awardPanels, 1 do
                self._awardPanels[i]:setVisible(true)
                if self._noticeTip then
                	self._noticeTip:setInfo(self._targetItem.id, self:getTargetNumber(self._moveIndex), self._targetItem.count)
                end
                if #self._awardPanels[i]._itemsBox == 0 then
                    self._awardPanels[i]._ccbOwner.tf_tips:setVisible(true)
                else
                    for j = 1, #self._awardPanels[i]._itemsBox, 1 do
                        self._awardPanels[i]._itemsBox[j]:setVisible(true)
                    end
                end
                self._moveIndex = self._moveIndex + 1
            end
            self._content:runAction(CCMoveBy:create(0, ccp(0,(#self._awardPanels - num + 1.3) * self._panelHeight)))
            self:_autoMoveWithFinishedAnimation(0)
    	else
            self:_autoMoveWithFinishedAnimation(70)
    	end
    end
end

function QUIDialogUnityFastBattle:_autoMoveWithFinishedAnimation(offset)
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local node = CCBuilderReaderLoad("ccb/effects/saodangwancheng.ccbi", ccbProxy, ccbOwner)
    self._content:addChild(node)
    node:setPosition(self._panelWidth * 0.5, -self._totalHeight - self._panelHeight/4)
    self._touchLayer:disable()
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, self._offsetMoveH + offset)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
        self:_removeAction()
        if self._fastType == FAST_FIGHT_TYPE.DUNGEON_FAST then
        	self:_autoMoveWithExtraReward()
        elseif self._fastType == FAST_FIGHT_TYPE.BOSS_FAST then
        	self:_autoMoveWithALLReward()
       	else 
       		self:_autoMoveEnd()
        end
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self._content:runAction(ccsequence)
    self._totalHeight = self._totalHeight + self._panelHeight/2
end

function QUIDialogUnityFastBattle:_autoMoveWithExtraReward()
    local reward = self._extraExpItem
    local panel = QUIWidgetEliteBattleAgain.new()
    panel:setPositionY(-self._totalHeight)
    panel:setTitleExtra()
    panel:setInfo(reward)
    self._content:addChild(panel)
    panel:startAnimation(function()
        --当动画结束时给物品添加悬浮提示
        for _, value in pairs(panel._itemsBox) do
          table.insert(self._awardItems,value)
        end
        self:_autoMoveEnd()
    end)
    
    self._totalHeight = self._totalHeight + self._panelHeight
end

function QUIDialogUnityFastBattle:_autoMoveWithALLReward()
    local info = {}
    local award = {}
    table.insert(award, 1, {type = ITEM_TYPE.INTRUSION_MONEY, count = self._totalAwards})
    info.award = award
    info.fightCount = self._count or 1
    info.totalDamage = self._totalDamage or 0
    local panel = QUIWidgetInvasionFastFightAwardClient.new()
    panel:setPositionY(-self._totalHeight)
    panel:setTitle("奖励结算")
    panel:setAllAwardInfo(info, self._oldInvasionInfo, self._newInvasionInfo)
    self._content:addChild(panel)
    panel:startAnimation(function()
        --当动画结束时给物品添加悬浮提示
        for _, value in pairs(panel._itemsBox) do
            table.insert(self._awardItems, value)
        end
        self:_autoMoveEnd()
    end)

    local conetentSize = panel:getContentSize()
    self._panelWidth = conetentSize.width
    self._panelHeight = conetentSize.height

    self._totalHeight = self._totalHeight + self._panelHeight
end

function QUIDialogUnityFastBattle:_autoMoveEnd()
    self._touchLayer:enable()
    local oldUserLevel = remote.oldUser ~= nil and remote.oldUser.level or 100000
    local isTeamUp = remote.user:checkTeamUp()
    self._ccbOwner.frame_btn_close:setVisible(true)
    if self._fastType == FAST_FIGHT_TYPE.DUNGEON_FAST then
	    scheduler.performWithDelayGlobal(function ()
	        scheduler.performWithDelayGlobal(function ()
	            self._ccbOwner.btn_one:setVisible(true)
	            self._ccbOwner.touch_button:setVisible(true)
	            self:showGotoButton()

	            --@qinyuanji wow-6314 
	            if self._invasion and self._invasion.bossId and self._invasion.bossId > 0 and remote.user.haveTutorial == false then
	                local unlockLevel = app.unlock:getConfigByKey("UNLOCK_FORTRESS").team_level
	                local isUnlockInvasion = oldUserLevel < unlockLevel and remote.user.level >= unlockLevel

	                --xurui: 要塞解锁时不弹要塞跳转界面，先拉取要塞完整信息
	                if isUnlockInvasion == false then
	                    local level = self._invasion.fightCount + 1
	                    local maxLevel = db:getIntrusionMaximumLevel(self._invasion.bossId)
	                    level = math.min(level, maxLevel)
	                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasionEncounter", 
	                        options = {actorId = self._invasion.bossId, isTeamUp = isTeamUp, level = level, cancelCallback = function ( ... )
	                            local page  = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	                            page:_checkUnlock()
	                            self._isShowEnd = true
	                        end, fightCallback = function ( ... )
	                            self._isShowEnd = true
	                        end}}, {isPopCurrentDialog = false})
	                else
	                    self._isShowEnd = true
	                    remote.invasion:getInvasionRequest()
	                end
	            else
	                self._isShowEnd = true
	                local page  = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	                page:_checkUnlock()
	            end
	        end, 0.2)
	    end, 0)
	else
		self._isShowEnd = true
    end
    for _, value in pairs(self._awardItems) do
      value:setPromptIsOpen(true)
    end
end

function QUIDialogUnityFastBattle:countDropNumByItem(itemId)
    local count = 0
    for _,award in pairs(self._awards) do
        for _,value in pairs(award.awards) do
            if value.id == itemId then
                count = count + value.count or 0
            end
        end
    end
    return count
end

-- 移除动作
function QUIDialogUnityFastBattle:_removeAction()
	if self._actionHandler ~= nil then
		self._content:stopAction(self._actionHandler)
		self._actionHandler = nil
	end
end

function QUIDialogUnityFastBattle:moveTo(time,x,y,callback)
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveBy:create(time, ccp(x,y)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
    	self:_removeAction()
    	if callback ~= nil then
    		callback()
    	end
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self._content:runAction(ccsequence)
end

function QUIDialogUnityFastBattle:_onTriggerQuickFightTen(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_fight) == false then return end
    self._isEliteBattleAgain = true
    self:_onTriggerClose()
end

function QUIDialogUnityFastBattle:_onTriggerGoto(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_goto) == false then return end
    self._isCloseDialog = true

    self:_onTriggerClose()
end

function QUIDialogUnityFastBattle:_backClickHandler()
    if self._isShowEnd == true then 
        self._btnClickClose = true
        self:_onTriggerClose()
    elseif self._isAnimation then
        self._isAnimation = false
        self._ccbOwner.touch_button:setVisible(true)
    end
end

function QUIDialogUnityFastBattle:_onTriggerClose()
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogUnityFastBattle:_onTriggerNext(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    self._btnClickClose = true
    if self._isShowEnd == true then 
        self:_onTriggerClose()
    end
end

function QUIDialogUnityFastBattle:viewAnimationOutHandler()
    local callback = self._callBack
    self:popSelf()

    local closeCallBack = function( )
        if callback then
            if self._isEliteBattleAgain then
                callback(self._isEliteBattleAgain)
            elseif self._btnClickClose and not self._isOnlyClose then 
                callback(self._isEliteBattleAgain)
            elseif self._isCloseDialog then 
                callback({isCloseDialog = self._isCloseDialog})
            end
        end
    end
    if self._fastType == FAST_FIGHT_TYPE.DUNGEON_FAST then
	    local page  = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	    page:checkGuiad()
	    page:_checkShopRedTips()
	    if self._isEliteBattleAgain then
	        local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	        if dialog ~= nil and dialog.class.__cname == "QUIDialogDungeon" then
	            if #self._awardPanels == 1 then
	                dialog:_onTriggerQuickFightOne()
	            else
	                dialog:_onTriggerQuickFightTen()
	            end
            else
                closeCallBack()
	        end
	    else
	        closeCallBack()
	    end
	else
		if self._fastType == FAST_FIGHT_TYPE.BOSS_FAST then
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_EXIT_FROM_QUICKBATTLE, options = {isQuick = true}})
		end
 
        closeCallBack()
	end
end

function QUIDialogUnityFastBattle:_onEvent(event)
	if event.name == "began" then
    	self:_removeAction()
    	self._lastSlidePositionY = event.y
        return true
    elseif event.name == "moved" then
    	local deltaY = event.y - self._lastSlidePositionY
    	local positionY = self._content:getPositionY()
    	self._content:setPositionY(positionY + deltaY * .5)
        self._lastSlidePositionY = event.y
    elseif event.name == "ended" or event.name == "cancelled" then
    elseif event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		local offset = event.distance.y
        if self._content:getPositionY() + offset > self._totalHeight - self._size.height  then
            if self._totalHeight - self._size.height > 0 then
    		    offset = self._totalHeight - self._size.height - self._content:getPositionY()
            else
                offset = 0 - self._content:getPositionY()
            end
        elseif self._content:getPositionY() + offset < 0 then
    		offset = 0 - self._content:getPositionY()
        end
        self:moveTo(0.3,0,offset)
    end
end
return QUIDialogUnityFastBattle
