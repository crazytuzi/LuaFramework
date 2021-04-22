local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderFastBattle = class("QUIDialogThunderFastBattle", QUIDialog)

local QUIWidgetThunderFastBattle = import("..widgets.QUIWidgetThunderFastBattle")
local QUIWidgetThunderFastBattleBuff = import("..widgets.QUIWidgetThunderFastBattleBuff")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIDialogThunderFastBattle:ctor(options)
	local ccbFile = "ccb/Dialog_EliteBattleAgain_thunderking.ccbi"
	local callBacks = {
                {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogThunderFastBattle._onTriggerNext)},
                {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogThunderFastBattle._onTriggerNext)},
            }
    QUIDialogThunderFastBattle.super.ctor(self,ccbFile,callBacks,options)
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

    self._ccbOwner.frame_tf_title:setString("扫荡结算")
    
    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_contain, self._size.width, self._size.height, 0, layerColor:getPositionY(), handler(self, self._onEvent))

    self._ccbOwner.btn_close:setVisible(false)
    self._awardPanels = {}
    self._awardItems = {}
    self._allAwards = {}
    self._isAnimation = true
    self._isEliteBattleAgain = false
    self._ccbOwner.touch_button:setVisible(false)

    self.isAllStar = options.isAllStar or false
    -- self._targetItem = options.targetItem
    -- self._inPackCount = options.targetItem.inPackCount
    self._result = remote.thunder:getFastResult()
    self._chestAwards = remote.thunder:getLuckDraw()
    self.thunderInfo, self._layerConfig, self._lastIndex = remote.thunder:getThunderFighter()
    
    self._layerStars = {}
    if self.thunderInfo.thunderEveryWaveStar ~= nil then
        self._layerStars = string.split(self.thunderInfo.thunderEveryWaveStar, ";")
    end
    self._totalHeight = 0
	self._moveIndex = 1
	local numY = 0
    self._startIndex = (self._layerConfig.thunder_floor-1)*3+self._lastIndex - #self._result
    if #self._result == 1 then
        local count = #self._result
        local star = tonumber(self._layerStars[self._lastIndex] or 1)
        local title = q.numToWord(star).."星扫荡"
        self._ccbOwner.tf_title1:setString(title)
        self._ccbOwner.tf_title2:setString(title)
    end
    local startIndex = self._startIndex+1
    local endIndex = self._startIndex+#self._result
    local label = ""
    if startIndex == endIndex then
        label = string.format("第%s关",endIndex)
    else
        label = string.format("%s-%s关",startIndex,endIndex)
    end
    self._ccbOwner.label_name:setString(label)

    local activityYield = remote.activity:getActivityMultipleYield(607) 
    local userComeBackRatio = remote.thunder:getFastUserComeBackRatio() 
    local floorIndex = 1
    for index,value in pairs(self._result) do
        numY = self:addWidget("第"..self._startIndex+index.."关", value.prize, value.yield, activityYield, numY, userComeBackRatio)
        --每满三关设置一个宝箱奖励和buff加成
        if (self._startIndex+index)%3 == 0 then
            if self._chestAwards[floorIndex] ~= nil then
                numY = self:addWidget("宝箱奖励", self._chestAwards[floorIndex].prizes, nil, 1, numY)
            end
            floorIndex = floorIndex + 1
            local buffIndex = remote.thunder:getBuffByLayer(math.ceil((self._startIndex+index)/3))
            if buffIndex ~= nil then
                numY = self:addBuffWidget("加成选择", buffIndex, numY)
            end
        end
    end
	self._totalHeight = math.abs(numY)
	self:autoMove()
end

function QUIDialogThunderFastBattle:addWidget(title, awards, yield, activityYield, numY, userComeBackRatio)
    local widget = QUIWidgetThunderFastBattle.new()
    widget:setInfo(awards, yield, activityYield, userComeBackRatio)
    widget:setPositionY(numY)
    widget:setTitle(title)
    --将所有奖励物品保存起来
    for _, box in pairs(widget._itemsBox) do
      table.insert(self._awardItems,box)
    end
    self._content:addChild(widget)
    table.insert(self._awardPanels, widget)
    numY = numY - widget:getHeight()
    self._panelWidth = widget:getWidth()
    self._panelHeight = widget:getHeight()
    for _,v in ipairs(awards) do
        local id = v.id
        if id == nil or id == 0 then
            id = v.type
        end
        if self._allAwards[id] == nil then
            self._allAwards[id] = v
        else
            self._allAwards[id].count = self._allAwards[id].count + v.count
        end
    end
    return numY
end

function QUIDialogThunderFastBattle:addBuffWidget(title, buffIndex, numY)
    local widget = QUIWidgetThunderFastBattleBuff.new()
    widget:setTitle(title)
    widget:setInfo(buffIndex)
    widget:setPositionY(numY)
    self._content:addChild(widget)
    table.insert(self._awardPanels, widget)
    numY = numY - widget:getHeight()
    self._panelWidth = widget:getWidth()
    self._panelHeight = widget:getHeight()
    return numY
end

function QUIDialogThunderFastBattle:viewDidAppear()
	QUIDialogThunderFastBattle.super.viewDidAppear(self)

    self._touchLayer:enable()
    self._touchLayer:setAttachSlide(true)
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onEvent))

    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QUIDialogThunderFastBattle:viewWillDisappear()
    QUIDialogThunderFastBattle.super.viewWillDisappear(self)
    
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
    if self._nextFrameHandler then 
        scheduler.unscheduleGlobal( self._nextFrameHandler  ) 
        self._nextFrameHandler = nil
    end
    
    self.prompt:removeItemEventListener()

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end

function QUIDialogThunderFastBattle:autoMove()
    if #self._awardPanels == 1 then
        self._content:setPositionY(0)
        self._touchLayer:disable()
        self._ccbOwner.touch_button:setVisible(true)
        self._awardPanels[self._moveIndex]:setVisible(true)
        self._awardPanels[self._moveIndex]:startAnimation(function()
            self:_autoMoveWithFinishedAnimation(100)
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
                -- if self._moveIndex < #self._awardPanels then
	                local actionArrayIn = CCArray:create()
	                actionArrayIn:addObject(CCMoveBy:create(0.3, ccp(0,rate * self._panelHeight)))
	                actionArrayIn:addObject(CCCallFunc:create(function () 
	                    self:_removeAction()
	                    self:autoMove()
	                end))
	                local ccsequence = CCSequence:create(actionArrayIn)
	                self.actionHandler = self._content:runAction(ccsequence)
                	self._moveIndex = self._moveIndex + 1
             --    else
             --    	self._moveIndex = self._moveIndex + 1
             --        self:_removeAction()
             --        self:autoMove()
	            -- end
            end)
        elseif self._isAnimation == false then
            self._touchLayer:disable()
            local num = self._moveIndex
            for i = self._moveIndex, #self._awardPanels, 1 do
                self._awardPanels[i]:setVisible(true)
                self._awardPanels[i]:showByNoAnimation()
                self._moveIndex = self._moveIndex + 1
            end
            self._content:runAction(CCMoveBy:create(0, ccp(0,self._totalHeight - self._content:getPositionY() - self._panelHeight/2)))
            self:_autoMoveWithFinishedAnimation(0)
    	else
            self:_autoMoveWithFinishedAnimation(190)
    	end
    end
end

function QUIDialogThunderFastBattle:_autoMoveWithFinishedAnimation(offset)
    local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local node = CCBuilderReaderLoad("ccb/effects/saodangwancheng.ccbi", ccbProxy, ccbOwner)
    self._content:addChild(node)
    node:setPosition(self._panelWidth * 0.5, -self._totalHeight - self._panelHeight/4)
    self._touchLayer:disable()
    if remote.thunder:getLuckDraw() ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCMoveBy:create(0.3, ccp(0, 60 + offset)))
        actionArrayIn:addObject(CCCallFunc:create(function () 
            self:_removeAction()
            self:_autoMoveWithExtraReward()
        end))
        local ccsequence = CCSequence:create(actionArrayIn)
        self.actionHandler = self._content:runAction(ccsequence)
        self._totalHeight = self._totalHeight + self._panelHeight/2
    else
        self:_autoMoveEnd()
    end
end

function QUIDialogThunderFastBattle:_autoMoveWithExtraReward()
    local items = {}
    for _,item in pairs(self._allAwards) do
        local typeName = remote.items:getItemType(item.type)
        table.insert(items, {type = typeName, id = item.id, count = item.count})
    end

    local totalStar = 0
    local count = #self._result
    if self.isAllStar == true then
        totalStar = count * 3
    else
        for i=(3-count+1),3 do
            totalStar = totalStar + (tonumber(self._layerStars[i]) or 0)
        end
    end
    local panel = QUIWidgetThunderFastBattle.new()
    panel:setPositionY(-self._totalHeight)

    local startIndex = self._startIndex+1
    local endIndex = self._startIndex+#self._result
    local label = "累计奖励"
    -- if startIndex == endIndex then
    --     label = string.format("恭喜你在%s关中，共获得%s星，累计奖励",endIndex,totalStar)
    -- else
    --     label = string.format("恭喜你在%s-%s关中，共获得%s星，累计奖励",startIndex,endIndex,totalStar)
    -- end
    panel:setTitleExtra(label)
    panel:setInfo(items)
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

function QUIDialogThunderFastBattle:_autoMoveEnd()
    self._touchLayer:enable()
    self._ccbOwner.btn_close:setVisible(true)
    self._nextFrameHandler = scheduler.performWithDelayGlobal(function ()
       self._nextFrameHandler =  scheduler.performWithDelayGlobal(function ()
            self._nextFrameHandler = nil
            self._isShowEnd = true
            self._ccbOwner.touch_button:setVisible(true)
        end, 0.2)
    end, 0)
    
    for _, value in pairs(self._awardItems) do
      value:setPromptIsOpen(true)
    end
end

-- 移除动作
function QUIDialogThunderFastBattle:_removeAction()
	if self._actionHandler ~= nil then
		self._content:stopAction(self._actionHandler)
		self._actionHandler = nil
	end
end

function QUIDialogThunderFastBattle:_backClickHandler()
    if self._isShowEnd == true then 
        self:_onTriggerClose()
    elseif self._isAnimation then
        self._isAnimation = false
        self._ccbOwner.touch_button:setVisible(true)
    end
end

function QUIDialogThunderFastBattle:_onTriggerClose()
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogThunderFastBattle:_onTriggerNext(event)
    if q.buttonEventShadow(event,self._ccbOwner.button_one) == false then return end
    self:_onTriggerClose()
end

function QUIDialogThunderFastBattle:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
    remote.thunder:setIsFast(false,true)
end

function QUIDialogThunderFastBattle:_onEvent(event)
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

function QUIDialogThunderFastBattle:moveTo(time,x,y,callback)
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


return QUIDialogThunderFastBattle