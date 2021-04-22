
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogRobotInformation = class("QUIDialogRobotInformation", QUIDialog)

local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetRobotAward = import("..widgets.QUIWidgetRobotAward")
local QUIWidgetRobotInvasionAward = import("..widgets.QUIWidgetRobotInvasionAward")
local QUIWidgetRobotTargetItem = import("..widgets.QUIWidgetRobotTargetItem")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogMystoryStoreAppear = import("..dialogs.QUIDialogMystoryStoreAppear")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogRobotInformation:ctor(options)
    local ccbFile = "ccb/Dialog_RobotInformation.ccbi";
    local callBacks = 
    {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerStop", callback = handler(self, self._onTriggerStop)},
        {ccbCallbackName = "onTriggerGotoInvasion", callback = handler(self, self._onTriggerGotoInvasion)},
    }
    QUIDialogRobotInformation.super.ctor(self,ccbFile,callBacks,options)

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
    
    self._ccbOwner.touch_button:setVisible(false)
    self._ccbOwner.frame_tf_title:setString("一键扫荡")

    self._titleStringFormat = options.titleStringFormat or "第%s次"

    -- self._energyItemIds = { 25, 26, 27 }
    -- self._intrusionTokenId = QStaticDatabase:sharedDatabase():getConfiguration()["INTRUSION_TOKEN_ITEM_ID"].value or 201
    -- self._list = options.list 
    -- self._robotType = options.robotType 
    -- self._curReplayCount = 0

    -- QPrintTable(self._list)

    -- by 李泽  去掉按钮
    self._ccbOwner.node_btn:setVisible(false)
    self._ccbOwner.btn_close:setVisible(false)

    self:_init()
end

function QUIDialogRobotInformation:_init()
    -- local tbl = { id = value.map.id, dungeonId = value.map.dungeon_id, dungeonType = value.map.dungeon_type, itemId = value.targetId, needNum = value.needNum }
    self._moveIndex = 1
    self._numY = 0
    self._offsetMoveH = 80
    self._moveTime = 0.2
    self._totalHeight = 0
    self._panelWidth = 640
    self._panelHeight = 0

    self._isShowEnd = false
    self._isAnimation = true
    self._isEnding = false

    self._isGetAllLeftAward = false -- 是否获取剩余的所有奖励
    self._isShowAllLeftAward = false -- 是否显示剩余的所有奖励

    self._awardPanels = {}
    self._awardItems = {} -- 保存所有物品奖励，在结束之后，增加itembox的tips功能

    self._ccbOwner.tf_btnName:setString("停止扫荡")

    self._ccbOwner.node_invasion_tips:setVisible(false)
end

function QUIDialogRobotInformation:start()
    -- -- 是否手动停止
    if remote.robot:isStopRobot() then
        -- QPrintTable(remote.robot._awardList)
        self._isGetAllLeftAward = true
        return
    end

    -- 准备扫荡副本
    local oldLevel = remote.user.level
    remote.robot:robotForDungeon(function(data)
            if data.shops ~= nil and data.userIntrusionResponse == nil then
                for _, value in pairs(data.shops) do 
                    if value.id == tonumber(SHOP_ID.goblinShop) and oldLevel >= app.unlock:getConfigByKey("UNLOCK_SHOP_1").team_level then
                        app.tip:addUnlockTips(QUIDialogMystoryStoreAppear.FIND_GOBLIN_SHOP)
                    elseif value.id == tonumber(SHOP_ID.blackShop) and oldLevel >= app.unlock:getConfigByKey("UNLOCK_SHOP_2").team_level then
                        app.tip:addUnlockTips(QUIDialogMystoryStoreAppear.FIND_BLACK_MARKET_SHOP)
                    end
                end
            end
            if not self._isShowAwarding then
                self:showAwards()
            end
        end, function()
            self:start()
        end)
end

function QUIDialogRobotInformation:showAwards()
    -- {info = awards, isInvasion = false, index = self._index}
    local award = {}
    local awardList = {}
    if self._isGetAllLeftAward then
        awardList = remote.robot:getLeftAwardList()
    else
        award = remote.robot:getNextAward()
    end
    -- print(remote.robot:isStopRobot(), self._isGetAllLeftAward, self._isShowAllLeftAward, remote.robot._showKey)
    -- QPrintTable(award)
    -- QPrintTable(awardList)

    if self._schedulerShowAwards then
        self:getScheduler().unscheduleGlobal(self._schedulerShowAwards)
        self._schedulerShowAwards = nil
    end

    if award and table.nums(award) > 0 then
        -- 奖励信息显示
        self._isShowAwarding = true
        if award.isInvasion then
            self:setInvasionAwards(award.info)
        else
            self:setAwards(award.info, award.index, nil, award.dungeonType)
        end
    elseif remote.robot:isStopRobot() then
        if awardList and table.nums(awardList) > 0 then
            self._isShowAwarding = true

            for _, info in pairs(awardList) do
                if info.isInvasion then
                    self:setInvasionAwards(info.info)
                else
                    self:setAwards(info.info, info.index, nil, info.dungeonType)
                end
            end

            self._isShowAllLeftAward = true 
            -- self:autoMove()
        else
            -- 奖励信息显示完毕，并且扫荡停止，显示结尾信息
            self:_showEnd()
        end
    else
        -- 等待奖励信息录入
        if not self._schedulerShowAwards then
            self._schedulerShowAwards = self:getScheduler().scheduleGlobal(function()
                self:showAwards()
            end, 1)
        end
    end
end

function QUIDialogRobotInformation:_showEnd()
    self._isShowAwarding = false
    if self._schedulerShowAwards then
        self:getScheduler().unscheduleGlobal(self._schedulerShowAwards)
        self._schedulerShowAwards = nil
    end
    self:_autoMoveWithFinishedAnimation(70)
end

function QUIDialogRobotInformation:setAwards(award, index, isPreset, dungeonType)
    local panel = QUIWidgetRobotAward.new()
    self._awardPanels[#self._awardPanels + 1] = panel
    panel:setPositionY(self._numY)
    panel:setTitle(string.format(self._titleStringFormat, index))
    panel:setDungeonType(dungeonType)
    panel:setInfo(award)
    panel:setVisible(false)
    self._content:addChild(panel)
    
    --将所有奖励物品保存起来
    for _, value in pairs(panel._itemsBox) do
      table.insert(self._awardItems, value)
    end

    self._numY = self._numY - panel:getHeight()
    self._panelWidth = panel:getWidth()
    self._panelHeight = panel:getHeight()

    self._totalHeight = math.abs(self._numY)
    if not self._noticeTip then
        local inPackCount = remote.items:getItemsNumByID( remote.robot:getItemId() ) or 0
        self._noticeTip = QUIWidgetRobotTargetItem.new({ inPackCount = inPackCount })
        self._ccbOwner.noticeTips:addChild(self._noticeTip)
    end

    if not isPreset then
        self:autoMove()
    end
end

function QUIDialogRobotInformation:setInvasionAwards(invasion, isPreset)
    local panel = QUIWidgetRobotInvasionAward.new()
    self._awardPanels[#self._awardPanels + 1] = panel
    panel:setPositionY(self._numY)
    panel:setInfo(invasion)
    self._invasion = nil
    panel:setVisible(false)
    self._content:addChild(panel)

    self._numY = self._numY - panel:getHeight()
    self._panelWidth = panel:getWidth()
    self._panelHeight = panel:getHeight()

    self._totalHeight = math.abs(self._numY)
    if not self._noticeTip then
        local inPackCount = remote.items:getItemsNumByID( remote.robot:getItemId() ) or 0
        self._noticeTip = QUIWidgetRobotTargetItem.new({ inPackCount = inPackCount })
        self._ccbOwner.noticeTips:addChild(self._noticeTip)
    end

    if not isPreset then
        self:autoMove()
    end
end

function QUIDialogRobotInformation:autoMove()
    local inPackCount = remote.items:getItemsNumByID( remote.robot:getItemId() ) or 0
    if #self._awardPanels == 1 then
        self._content:setPositionY(0)
        self._touchLayer:disable()
        self._ccbOwner.touch_button:setVisible(true)
        self._awardPanels[self._moveIndex]:setVisible(true)
        self._awardPanels[self._moveIndex]:startAnimation(function()
            self._noticeTip:setInfo(remote.robot:getItemId(), inPackCount, remote.robot:getNeedNum())
            self._moveIndex = self._moveIndex + 1
            if self._isShowAllLeftAward then
                self:_showEnd()
            else
                self:autoMoveOver()
            end
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
                actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, rate * self._panelHeight)))
                actionArrayIn:addObject(CCCallFunc:create(function () 
                    self:_removeAction()
                    self:autoMove()
                end))
                local ccsequence = CCSequence:create(actionArrayIn)
                self.actionHandler = self._content:runAction(ccsequence)
                self._noticeTip:setInfo(remote.robot:getItemId(), inPackCount, remote.robot:getNeedNum())
                self._moveIndex = self._moveIndex + 1
            end)
        elseif self._isAnimation == false then
            self._touchLayer:disable()
            local num = self._moveIndex
            local height = 0
            for i = self._moveIndex, #self._awardPanels, 1 do
                self._awardPanels[i]:setVisible(true)
                self._noticeTip:setInfo(remote.robot:getItemId(), inPackCount, remote.robot:getNeedNum())
                if #self._awardPanels[i]._itemsBox == 0 then
                    if self._awardPanels[i]._ccbOwner.tf_tips then
                        self._awardPanels[i]._ccbOwner.tf_tips:setVisible(true)
                    end
                else
                    for j = 1, #self._awardPanels[i]._itemsBox, 1 do
                        self._awardPanels[i]._itemsBox[j]:setVisible(true)
                    end
                end
                self._moveIndex = self._moveIndex + 1
                height = height + self._awardPanels[i]:getHeight()
            end
            -- self._content:runAction(CCMoveBy:create(0, ccp(0,(#self._awardPanels - num + 1.3) * self._panelHeight)))
            self._content:runAction(CCMoveBy:create(0, ccp(0, height)))
            if self._isShowAllLeftAward then
                self:_showEnd()
            else
                self:autoMoveOver()
            end
        else
            if self._isShowAllLeftAward then
                self:_showEnd()
            else
                self:autoMoveOver()
            end
        end
    end
end

function QUIDialogRobotInformation:autoMoveOver()
    self:showAwards()
    -- self._content:setPositionY(self._totalHeight - self._size.height)
end

function QUIDialogRobotInformation:_autoMoveWithFinishedAnimation(offset)
    if self._isEnding then return end
    self._isEnding = true
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local node = CCBuilderReaderLoad("ccb/effects/saodangwancheng.ccbi", ccbProxy, ccbOwner)
    self._content:addChild(node)
    local height = 200
    node:setPosition(self._panelWidth * 0.5, -self._totalHeight - height/2)
    self._touchLayer:disable()
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, height)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
        self:_removeAction()
        self:_autoMoveWithALLReward()
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self._content:runAction(ccsequence)
    self._totalHeight = self._totalHeight + height
end

function QUIDialogRobotInformation:_autoMoveWithALLReward()
    local reward = remote.robot:getAwardShowAtEnd()   
    local panel = QUIWidgetRobotAward.new()
    panel:setPositionY(-self._totalHeight)
    panel:setTitleExtra()
    panel:setInfo(reward)
    panel:setInvasionMoney( remote.robot:getAllInvasionMoney() )
    self._content:addChild(panel)
    panel:startAnimation()

    self._panelWidth = panel:getWidth()
    self._panelHeight = panel:getHeight()
    self._totalHeight = self._totalHeight + self._panelHeight

    self:_autoMoveWithReplayInfo()
end

function QUIDialogRobotInformation:_autoMoveWithReplayInfo()
    local panel = QUIWidgetRobotAward.new()
    panel:setPositionY(-self._totalHeight)
    panel:setTitleReplay()
    panel:setReplay(remote.robot:getTotalReplayCount(), remote.robot:getTotalReplayPrice())
    self._content:addChild(panel)
    self._panelWidth = panel:getWidth()
    self._panelHeight = panel:getHeight()

    panel:startAnimation(function()
        -- --当动画结束时给物品添加悬浮提示
        -- for _, value in pairs(panel._itemsBox) do
        --     table.insert(self._awardItems, value)
        -- end
        -- self:checkShowInvasion()
    end)

    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, self._panelHeight)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
        --当动画结束时给物品添加悬浮提示
        for _, value in pairs(panel._itemsBox) do
            table.insert(self._awardItems, value)
        end
        self:checkShowInvasion()
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self._content:runAction(ccsequence)

    self._totalHeight = self._totalHeight + self._panelHeight
end

--检查是否显示要塞boss
function QUIDialogRobotInformation:checkShowInvasion()
    if remote.robot:isShowGotoInvasion() then
        self._ccbOwner.tf_invasion_name:setString(remote.robot:getGotoInvasionName())
        self._ccbOwner.node_invasion_tips:setVisible(true)
        local actionArrayIn = CCArray:create()
        self._totalHeight = self._totalHeight + 50
        actionArrayIn:addObject(CCMoveBy:create(self._moveTime, ccp(0, self._offsetMoveH)))
        actionArrayIn:addObject(CCCallFunc:create(function () 
            self:_removeAction()
            self:_autoMoveEnd()
        end))
        local ccsequence = CCSequence:create(actionArrayIn)
        self.actionHandler = self._content:runAction(ccsequence)
    else
        self:_autoMoveEnd()
    end
end

function QUIDialogRobotInformation:_autoMoveEnd()
    self._touchLayer:enable()

    self:getScheduler().performWithDelayGlobal(function ()
        self:getScheduler().performWithDelayGlobal(function ()
            self._ccbOwner.touch_button:setVisible(true)
            self._isShowEnd = true
            -- 1，钻石不足。2，体力不足。
            if remote.robot:getStopType() == 1 then
                self._ccbOwner.tf_btnName:setString("继续扫荡")
            elseif remote.robot:getStopType() == 2 then
                self._ccbOwner.tf_btnName:setString("继续扫荡")
            else
                self._ccbOwner.tf_btnName:setString("关  闭")
            end
            self._ccbOwner.node_btn:setVisible(true)
            self._ccbOwner.btn_close:setVisible(true)
        end, 0.2)
    end, 0)
    
    remote.user:checkTeamUp( true )
    
    for _, value in pairs(self._awardItems) do
        value:setPromptIsOpen(true)
    end


    -- self:_onEvent({name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = {x = 0, y = 0}})
    self._content:setPositionY(self._totalHeight - self._size.height)
    print("=====> E N D <===== ", self._totalHeight)

    if remote.robot.floatTipStr then
        app.tip:floatTip(remote.robot.floatTipStr)
        remote.robot.floatTipStr = nil
    end
end

-- 移除动作
function QUIDialogRobotInformation:_removeAction()
    if self.actionHandler ~= nil then
        self._content:stopAction(self.actionHandler)
        self.actionHandler = nil
    end
end

function QUIDialogRobotInformation:moveTo(time,x,y,callback)
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

function QUIDialogRobotInformation:_backClickHandler()
    if self._isShowEnd == true then 
        -- self:_onTriggerClose()
    elseif remote.robot:isStopRobot() and self._isAnimation and self._isShowAllLeftAward then
        self._isAnimation = false
        -- self._ccbOwner.touch_button:setVisible(true)
        -- self._ccbOwner.tf_btnName:setString("关  闭")
        -- self._ccbOwner.btn_close:setVisible(true)
        -- self._ccbOwner.node_btn:setVisible(true)
    end
end

function QUIDialogRobotInformation:viewDidAppear()
    QUIDialogRobotInformation.super.viewDidAppear(self)

    self._touchLayer:setAttachSlide(true)
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onEvent))
    self._touchLayer:disable()
end

function QUIDialogRobotInformation:viewWillDisappear()
    QUIDialogRobotInformation.super.viewWillDisappear(self)

    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    if self._schedulerShowAwards then
        self:getScheduler().unscheduleGlobal(self._schedulerShowAwards)
        self._schedulerShowAwards = nil
    end
end

function QUIDialogRobotInformation:_onTriggerStop(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_stop) == false then return end
    app.sound:playSound("common_close")
    if self._isShowEnd == true then
        -- 1，钻石不足。2，体力不足。
        if remote.robot:getStopType() == 1 then
            QQuickWay:addToken()
        elseif remote.robot:getStopType() == 2 then
            QQuickWay:energyQuickWay()
        else
            self:_onTriggerClose()
        end
    -- elseif remote.robot:isStopRobot() then
    --     -- app.tip:floatTip("点击空白处可跳过奖励展示～")
    -- else
    --     remote.robot:stopRobot()
    --     -- app.tip:floatTip("点击空白处可跳过奖励展示～")
    --     self._ccbOwner.tf_btnName:setString("关  闭")
    end
end

function QUIDialogRobotInformation:_onTriggerGotoInvasion()
    remote.invasion:getInvasionRequest(function(data)
        app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TO_CURRENT_PAGE)
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TO_CURRENT_PAGE)
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
        remote.stores:getShopInfoFromServerById(SHOP_ID.invasionShop)
        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasion", options = {}})
    end)
end

function QUIDialogRobotInformation:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    if event then
        app.sound:playSound("common_close")
    end
    if self._isShowEnd == true then 
        self:playEffectOut()
    -- elseif remote.robot:isStopRobot() then
    --     -- app.tip:floatTip("点击空白处可跳过奖励展示～")
    -- else
    --     remote.robot:stopRobot()
    --     -- app.tip:floatTip("点击空白处可跳过奖励展示～")
    --     self._ccbOwner.tf_btnName:setString("关  闭")
    end
end

function QUIDialogRobotInformation:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogRobotInformation:viewAnimationInHandler()
    if remote.robot:getStopType() == 1 or remote.robot:getStopType() == 2 then
        remote.robot:continueRobot()
    end
    self:start()
end

function QUIDialogRobotInformation:_onEvent(event)
    if event.name == "began" then
        self:_removeAction()
        self._lastSlidePositionY = event.y
        return true
    elseif event.name == "moved" then
        local deltaY = event.y - self._lastSlidePositionY
        local positionY = self._content:getPositionY()
        self._content:setPositionY(positionY + deltaY * 0.5)
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

return QUIDialogRobotInformation