--
-- Author: Your Name
-- Date: 2016-02-01 18:11:55
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderEliteFastBattle = class("QUIDialogThunderEliteFastBattle", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetEliteBattleAgain = import("..widgets.QUIWidgetEliteBattleAgain")
local QUIWidgetEliteBattleAgainTargetItem = import("..widgets.QUIWidgetEliteBattleAgainTargetItem")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogThunderEliteFastBattle:ctor(options)
    local ccbFile = "ccb/Dialog_EliteBattleAgain.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerNext)},
        {ccbCallbackName = "onTriggerQuickFightOne", callback = handler(self, self._onTriggerQuickFight)}
    }
    QUIDialogThunderEliteFastBattle.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true

    self._size = self._ccbOwner.layer_content:getContentSize()
    self._content = CCNode:create()
    local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._size.width,self._size.height)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionY(-self._size.height)
    ccclippingNode:setStencil(layerColor)
    ccclippingNode:addChild(self._content)
    self._ccbOwner.node_contain:addChild(ccclippingNode)

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_contain, self._size.width, self._size.height, 0, layerColor:getPositionY(), handler(self, self._onEvent))

    self._ccbOwner.frame_btn_close:setVisible(false)
    self._awardPanels = {}
    self._awardItems = {}
    self._isAnimation = true
    self._isEliteBattleAgain = false
    self._ccbOwner.touch_button:setVisible(false)

    if options ~= nil then
        self._currentFloor = options.floor
        self._callBack = options.fightCallBack
        self._titleStringFormat = options.titleStringFormat or "第%s次"
        if options.awards ~= nil then
            self._awards = options.awards
            self._offsetMoveH = 60
            self._isShowEnd = false
            self:setAwards(options.awards)
        else
            self:_autoMoveEnd()
        end
        local label = string.format("第%s关", self._currentFloor)
        self._ccbOwner.frame_tf_title:setString(label)
    end 
    q.setButtonEnableShadow(self._ccbOwner.btn_fight)
    q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)
end

function QUIDialogThunderEliteFastBattle:viewDidAppear()
    QUIDialogThunderEliteFastBattle.super.viewDidAppear(self)

    -- self._touchLayer:enable()
    self._touchLayer:setAttachSlide(true)
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onEvent))
    self._touchLayer:disable()
end

function QUIDialogThunderEliteFastBattle:viewWillDisappear()
    QUIDialogThunderEliteFastBattle.super.viewWillDisappear(self)
    
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    if self._endScheduler ~= nil then
        scheduler.unscheduleGlobal(self._endScheduler)
        self._endScheduler = nil
    end
end

function QUIDialogThunderEliteFastBattle:setAwards(awards)
    self._awardPanels = {}
    self._awardItems = {}
    self._moveIndex = 1
    local numY = 0

    local panel = QUIWidgetEliteBattleAgain.new()
    self._awardPanels[#self._awardPanels+1] = panel
    panel:setPositionY(numY)
    -- panel:setPositionX(self._size.width/2)
    panel:setTitle(string.format(self._titleStringFormat, 1))
    panel:setInfo(awards)
    panel:setVisible(false)
    self._content:addChild(panel)
    
    --将所有奖励物品保存起来
    for _, value in pairs(panel._itemsBox) do
      table.insert(self._awardItems,value)
    end

    numY = numY - panel:getHeight()
    self._panelWidth = panel:getWidth()
    self._panelHeight = panel:getHeight()
    
    self._totalHeight = math.abs(numY)
    local tenBtnTF = "再扫1次"
    self._ccbOwner.tf_one:setString(tenBtnTF)
    self:autoMove()
end

function QUIDialogThunderEliteFastBattle:autoMove()
    if #self._awardPanels == 1 then
        self._content:setPositionY(0)
        self._touchLayer:disable()
        self._ccbOwner.touch_button:setVisible(true)
        self._awardPanels[self._moveIndex]:setVisible(true)
        self._awardPanels[self._moveIndex]:startAnimation(function()
            self:_autoMoveWithFinishedAnimation(0)
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
                actionArrayIn:addObject(CCMoveBy:create(0.3, ccp(0,rate * self._panelHeight)))
                actionArrayIn:addObject(CCCallFunc:create(function () 
                    self:_removeAction()
                    self:autoMove()
                end))
                local ccsequence = CCSequence:create(actionArrayIn)
                self.actionHandler = self._content:runAction(ccsequence)
                self._moveIndex = self._moveIndex + 1
            end)
        elseif self._isAnimation == false then
            self._touchLayer:disable()
            local num = self._moveIndex
            for i = self._moveIndex, #self._awardPanels, 1 do
                self._awardPanels[i]:setVisible(true)
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
            self:_autoMoveWithFinishedAnimation(0)
        end
    end
end

function QUIDialogThunderEliteFastBattle:_autoMoveWithFinishedAnimation(offset)
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local node = CCBuilderReaderLoad("ccb/effects/saodangwancheng.ccbi", ccbProxy, ccbOwner)
    self._content:addChild(node)
    node:setPosition(self._panelWidth * 0.5, -self._totalHeight - self._panelHeight/4)
    self._touchLayer:disable()
    local actionArrayIn = CCArray:create()
    -- actionArrayIn:addObject(CCMoveBy:create(0.3, ccp(0, self._offsetMoveH + offset)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
        self:_removeAction()
        self:_autoMoveEnd()
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self._content:runAction(ccsequence)
    self._totalHeight = self._totalHeight + self._panelHeight/2
end

function QUIDialogThunderEliteFastBattle:_autoMoveEnd()
    self._touchLayer:enable()

    self._endScheduler = scheduler.performWithDelayGlobal(function()
            self._isShowEnd = true
            self._ccbOwner.frame_btn_close:setVisible(true)
            self._ccbOwner.btn_one:setVisible(true)
            self._ccbOwner.touch_button:setVisible(true)
        end, 0)

    
    for _, value in pairs(self._awardItems) do
        value:setPromptIsOpen(true)
    end
end

-- 移除动作
function QUIDialogThunderEliteFastBattle:_removeAction()
    if self._actionHandler ~= nil then
        self._content:stopAction(self._actionHandler)
        self._actionHandler = nil
    end
end

function QUIDialogThunderEliteFastBattle:moveTo(time,x,y,callback)
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

function QUIDialogThunderEliteFastBattle:_onTriggerQuickFight()
    if self._isShowEnd == false then return end
    self._isEliteBattleAgain = true
    self:viewAnimationOutHandler()
    if self._callBack ~= nil then
        self._callBack()
    end
end

function QUIDialogThunderEliteFastBattle:_backClickHandler()
    if self._isShowEnd == true then 
        self:_onTriggerClose()
    elseif self._isAnimation then
        self._isAnimation = false
        self._ccbOwner.touch_button:setVisible(true)
    end
end

function QUIDialogThunderEliteFastBattle:_onTriggerClose()
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogThunderEliteFastBattle:_onTriggerNext()
    self:_onTriggerClose()
end

function QUIDialogThunderEliteFastBattle:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

function QUIDialogThunderEliteFastBattle:_onEvent(event)
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

return QUIDialogThunderEliteFastBattle