-- @Author: xurui
-- @Date:   2019-01-10 15:13:29
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-05 16:02:45
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogInvasionFastFightAward = class("QUIDialogInvasionFastFightAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("...ui.QUIGestureRecognizer")
local QUIWidgetInvasionFastFightAwardClient = import("..widgets.QUIWidgetInvasionFastFightAwardClient")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogInvasionFastFightAward:ctor(options)
	local ccbFile = "ccb/Dialog_society_fuben_zidong2.ccbi"
    local callBacks = { 
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerStop", callback = handler(self, self._onTriggerStop)},
    }
    QUIDialogInvasionFastFightAward.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
        self._fightResult = options.fightResult
        self._oldInvasionInfo = options.oldInvasionInfo
        self._newInvasionInfo = options.newInvasionInfo
        self._bossInfo = options.bossInfo
        self._userComeBackRatio = options.userComeBackRatio
    end

    self._ccbOwner.frame_tf_title:setString("扫 荡")
    self._totalDamage = 0               --累计伤害
    self._totalAwards = 0               --累计奖励
    self._awardItems = {}
    self._isStopAnimation = false
    self._isShowEnd = false

    self._ccbOwner.tf_tips:setVisible(false)
    self._ccbOwner.node_btn_stop:setVisible(false)

    self:init()
end

function QUIDialogInvasionFastFightAward:viewDidAppear()
	QUIDialogInvasionFastFightAward.super.viewDidAppear(self)

    self._touchLayer:setAttachSlide(true)
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onEvent))
    self._touchLayer:disable()

	self:showAwardsAnimation()
end

function QUIDialogInvasionFastFightAward:viewWillDisappear()
  	QUIDialogInvasionFastFightAward.super.viewWillDisappear(self)

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    if self._moveScheduler then
        scheduler.unscheduleGlobal(self._moveScheduler)
        self._moveScheduler = nil
    end
end

function QUIDialogInvasionFastFightAward:init()
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
    
    self._ccbOwner.touch_button:setVisible(false)

    self._titleStringFormat = "第%s次"

    self._awardPanels = {}
	self._index = 1 -- 攻击第几个boss
    self._count = 0 -- 攻击了几次
    self._moveIndex = 1
    self._numY = 0
    self._offsetMoveH = 60
    self._moveTime = 0.15
    self._totalHeight = 0
    self._panelWidth = 640
    self._panelHeight = 0
end

function QUIDialogInvasionFastFightAward:showAwardsAnimation()
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

        self:setAwards(awards, damage)
    end

    self:autoMove()
end

function QUIDialogInvasionFastFightAward:setAwards(award, damage)
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

function QUIDialogInvasionFastFightAward:autoMove()
    if #self._awardPanels == 1 then
        self._content:setPositionY(0)
        self._touchLayer:disable()
        self._ccbOwner.touch_button:setVisible(true)
        self._awardPanels[self._moveIndex]:setVisible(true)
        self._awardPanels[self._moveIndex]:startAnimation(function()
            self._moveIndex = self._moveIndex + 1
            self:autoMoveOver()
        end)
    else
        if self._isStopAnimation then
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
            self._content:runAction(CCMoveBy:create(0, ccp(0, (#self._awardPanels - num) * self._panelHeight + 170)))
            self:_autoMoveWithFinishedAnimation(70)
            self._count = #self._awardPanels
            self._ccbOwner.tf_tips:setString(string.format("消耗攻击次数：%s／%s", self._count, self._robotCount))
            -- self._ccbOwner.tf_tips2:setString(string.format("消耗攻击次数：%s／%s", self._count, self._robotCount))
        elseif self._moveIndex <= #self._awardPanels then
            self._touchLayer:disable()
            self._awardPanels[self._moveIndex]:setVisible(true)
            self._awardPanels[self._moveIndex]:startAnimation(function()
                local rate = 1
                if self._moveIndex < 2 then
                    rate = 0
                end
                local actionArrayIn = CCArray:create()
                actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, rate * self._panelHeight)))
                actionArrayIn:addObject(CCCallFunc:create(function () 
                    self:_removeAction()
                    self:autoMove()
                end))
                local ccsequence = CCSequence:create(actionArrayIn)
                self.actionHandler = self._content:runAction(ccsequence)
                self._moveIndex = self._moveIndex + 1
            end)
        else
            self:autoMoveOver()
        end
    end
end

function QUIDialogInvasionFastFightAward:autoMoveOver()
	self:_autoMoveWithFinishedAnimation()
end

function QUIDialogInvasionFastFightAward:_autoMoveWithFinishedAnimation(offset)
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local node, owner = CCBuilderReaderLoad("ccb/effects/saodangwancheng.ccbi", ccbProxy, ccbOwner)
    self._content:addChild(node)
    node:setPosition(self._panelWidth * 0.5, -self._totalHeight - self._panelHeight/4)
    self._touchLayer:disable()
    local actionArrayIn = CCArray:create()
    -- actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, self._offsetMoveH + offset)))
    actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, self._offsetMoveH + 70)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
        self:_removeAction()
        self:_autoMoveWithALLReward()
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self._content:runAction(ccsequence)
    self._totalHeight = self._totalHeight + self._panelHeight/2
end

function QUIDialogInvasionFastFightAward:_autoMoveWithALLReward()
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

    -- remote.trailer:updateTaskProgressByTaskId("4000019", info.fightCount)
end

function QUIDialogInvasionFastFightAward:_autoMoveEnd()
    self._touchLayer:enable()

    self._moveScheduler = scheduler.performWithDelayGlobal(function ()
        self._ccbOwner.touch_button:setVisible(true)
        self._isShowEnd = true
        self._ccbOwner.tf_btnStop:setString("关  闭")
        self._ccbOwner.node_btn_stop:setVisible(true)
    end, 0.2)
    
    for _, value in pairs(self._awardItems) do
        value:setPromptIsOpen(true)
    end
end

-- 移除动作
function QUIDialogInvasionFastFightAward:_removeAction()
    if self._actionHandler ~= nil then
        self._content:stopAction(self._actionHandler)
        self._actionHandler = nil
    end
end

function QUIDialogInvasionFastFightAward:moveTo(time,x,y,callback)
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

function QUIDialogInvasionFastFightAward:_onEvent(event)
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

function QUIDialogInvasionFastFightAward:_backClickHandler()
    if self._isShowEnd == false then
        self._isStopAnimation = true
    else
        self:_onTriggerClose()
    end
end

function QUIDialogInvasionFastFightAward:_onTriggerStop(event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_stop) == false then return end
    self:_onTriggerClose()
end
function QUIDialogInvasionFastFightAward:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogInvasionFastFightAward:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_EXIT_FROM_QUICKBATTLE, options = {isQuick = true}})

	if callback then
		callback()
	end
end

return QUIDialogInvasionFastFightAward
