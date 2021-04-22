--
-- Author: wkwang
-- Date: 2014-07-14 16:04:20 
--
local QUIDialog = import(".QUIDialog")
local QUIDialogEliteBattleAgain = class("QUIDialogEliteBattleAgain", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetEliteBattleAgain = import("..widgets.QUIWidgetEliteBattleAgain")
local QUIWidgetEliteBattleAgainTargetItem = import("..widgets.QUIWidgetEliteBattleAgainTargetItem")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogEliteBattleAgain:ctor(options)

	local ccbFile = "ccb/Dialog_EliteBattleAgain.ccbi"
	local callBacks = {
						{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerNext)},
                        {ccbCallbackName = "onTriggerQuickFightOne", callback = handler(self, self._onTriggerQuickFightTen)},
                        {ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
					}
    QUIDialogEliteBattleAgain.super.ctor(self,ccbFile,callBacks,options)
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
    self._ccbOwner.frame_tf_title:setString("扫 荡")

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_contain, self._size.width, self._size.height, 0, layerColor:getPositionY(), handler(self, self._onEvent))

    self._ccbOwner.frame_btn_close:setVisible(false)
    self._awardPanels = {}
    self._awardItems = {}
    self._isAnimation = true
    self._isEliteBattleAgain = false
    self._ccbOwner.touch_button:setVisible(false)

    self._extraExpItem = options.extraExpItem or {}
    local prizeWheelMoneyGot = options.prizeWheelMoneyGot or 0
    if prizeWheelMoneyGot > 0 then
        table.insert(self._extraExpItem, {type = ITEM_TYPE.PRIZE_WHEEL_MONEY, count = prizeWheelMoneyGot, isActivity = true})
    end
    self._targetItem = options.targetItem
    self._inPackCount = options.targetItem.inPackCount
    self._invasion = options.invasion
    self._titleStringFormat = options.titleStringFormat or "第%s次"
    self._totalHeight = 0
    self._awards = {}
    self.info = options.info
    self.config = options.config
    self._isFromHeroInfo = options.isFromHeroInfo
    self._callBack = options.callBack

	if options.awards ~= nil then
        self._awards = options.awards
        self._offsetMoveH = 60
        self._isShowEnd = false
		self:setAwards(options.awards)
    else
        self._isShowEnd = true
        self:_autoMoveEnd()
	end
    self._ccbOwner.label_name:setString(self.info.number.." "..self.config.name)
end

function QUIDialogEliteBattleAgain:viewDidAppear()
	QUIDialogEliteBattleAgain.super.viewDidAppear(self)

    self._touchLayer:setAttachSlide(true)
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onEvent))
    self._touchLayer:disable()
end

function QUIDialogEliteBattleAgain:viewWillDisappear()
    QUIDialogEliteBattleAgain.super.viewWillDisappear(self)
    
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end

function QUIDialogEliteBattleAgain:setAwards(awards)
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
        panel:setDungeonType(self.info.dungeon_type)
		panel:setInfo(award.awards)
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
    self._noticeTip = QUIWidgetEliteBattleAgainTargetItem.new({inPackCount = self._inPackCount})
    self._ccbOwner.noticeTips:addChild(self._noticeTip)
    self:setTenButton()
	self:autoMove()
end

function QUIDialogEliteBattleAgain:setTenButton()
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

function QUIDialogEliteBattleAgain:showGotoButton()
    local targetNumber = self:getTargetNumber(self._moveIndex)
    if self._targetItem.count and targetNumber >= self._targetItem.count then
        self._ccbOwner.node_btn_goto:setVisible(true)
        if self._isFromHeroInfo then
            local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._targetItem.id)
            if itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
                self._ccbOwner.tf_goto:setString("前往升星")
            end
        end
        self._ccbOwner.btn_one:setPositionX(-150)
    else
        self._ccbOwner.btn_one:setPositionX(0)
    end
end

function QUIDialogEliteBattleAgain:getTargetNumber(index)
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

function QUIDialogEliteBattleAgain:autoMove()
    self._moveTime = 0.15

    if #self._awardPanels == 1 then
        self._content:setPositionY(0)
        self._touchLayer:disable()
        self._ccbOwner.touch_button:setVisible(true)
        self._awardPanels[self._moveIndex]:setVisible(true)
        self._awardPanels[self._moveIndex]:startAnimation(function()
            self._noticeTip:setInfo(self._targetItem.id, self:getTargetNumber(self._moveIndex), self._targetItem.count)
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
                self._noticeTip:setInfo(self._targetItem.id, self:getTargetNumber(self._moveIndex), self._targetItem.count)
                self._moveIndex = self._moveIndex + 1
            end)
        elseif self._isAnimation == false then
            self._touchLayer:disable()
            local num = self._moveIndex
            for i = self._moveIndex, #self._awardPanels, 1 do
                self._awardPanels[i]:setVisible(true)
                self._noticeTip:setInfo(self._targetItem.id, self:getTargetNumber(self._moveIndex), self._targetItem.count)
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
    	    -- self._awardPanels[self._moveIndex]:setVisible(true)
    	    -- self._awardPanels[self._moveIndex]:startAnimation(function()
         --        self._content:setPositionY(self._totalHeight - self._size.height)
         --        self._touchLayer:disable()
         --        self:_autoMoveWithFinishedAnimation()
         --    end)
            self:_autoMoveWithFinishedAnimation(70)
    	end
    end
end

function QUIDialogEliteBattleAgain:_autoMoveWithFinishedAnimation(offset)
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
        self:_autoMoveWithExtraReward()
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self._content:runAction(ccsequence)
    self._totalHeight = self._totalHeight + self._panelHeight/2
end

function QUIDialogEliteBattleAgain:_autoMoveWithExtraReward()
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

function QUIDialogEliteBattleAgain:_autoMoveEnd()
    self._touchLayer:enable()
    local oldUserLevel = remote.oldUser ~= nil and remote.oldUser.level or 100000
    local isTeamUp = remote.user:checkTeamUp()
    self._ccbOwner.frame_btn_close:setVisible(true)
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
    
    for _, value in pairs(self._awardItems) do
      value:setPromptIsOpen(true)
    end
end

function QUIDialogEliteBattleAgain:countDropNumByItem(itemId)
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
function QUIDialogEliteBattleAgain:_removeAction()
	if self._actionHandler ~= nil then
		self._content:stopAction(self._actionHandler)
		self._actionHandler = nil
	end
end

function QUIDialogEliteBattleAgain:moveTo(time,x,y,callback)
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

function QUIDialogEliteBattleAgain:_onTriggerQuickFightTen(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_fight) == false then return end
    self._isEliteBattleAgain = true
    self:_onTriggerClose()
end

function QUIDialogEliteBattleAgain:_onTriggerGoto(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_goto) == false then return end
    self._isCloseDialog = true

    self:_onTriggerClose()
end

function QUIDialogEliteBattleAgain:_backClickHandler()
    if self._isShowEnd == true then 
        self:_onTriggerClose()
    elseif self._isAnimation then
        self._isAnimation = false
        self._ccbOwner.touch_button:setVisible(true)
    end
end

function QUIDialogEliteBattleAgain:_onTriggerClose()
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogEliteBattleAgain:_onTriggerNext(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    if self._isShowEnd == true then 
        self:_onTriggerClose()
    end
end

function QUIDialogEliteBattleAgain:viewAnimationOutHandler()
    local callback = self._callBack

    self:popSelf()

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
        end
    else
        if callback then
            callback({isCloseDialog = self._isCloseDialog})
        end
    end
end

function QUIDialogEliteBattleAgain:_onEvent(event)
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

return QUIDialogEliteBattleAgain