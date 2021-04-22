-- @Author: liaoxianbo
-- @Date:   2020-05-18 15:50:26
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-29 15:03:42
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFastSweepBase = class("QUIDialogFastSweepBase", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetEliteBattleAgain = import("..widgets.QUIWidgetEliteBattleAgain")

function QUIDialogFastSweepBase:ctor(options)
	local ccbFile = "ccb/Dialog_EliteBattleAgain.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerNext)},
        {ccbCallbackName = "onTriggerQuickFightOne", callback = handler(self, self._onTriggerQuickFightTen)},
        {ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
	}
    QUIDialogFastSweepBase.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_contain, self._size.width, self._size.height, 0, layerColor:getPositionY(), handler(self, self._onEvent))

end

function QUIDialogFastSweepBase:viewDidAppear()
	QUIDialogFastSweepBase.super.viewDidAppear(self)

    self._touchLayer:setAttachSlide(true)
    self._touchLayer:setSlideRate(0.3)
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onEvent))
    self._touchLayer:disable()

end

function QUIDialogFastSweepBase:viewWillDisappear()
  	QUIDialogFastSweepBase.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogFastSweepBase:autoMove()
    if #self._awardPanels == 1 then
        self._content:setPositionY(0)
        self._touchLayer:disable()
        self._ccbOwner.touch_button:setVisible(true)
        self._awardPanels[self._moveIndex]:setVisible(true)
        self._awardPanels[self._moveIndex]:startAnimation(function()
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
            self:_autoMoveWithFinishedAnimation(70)
    	end
    end
end

function QUIDialogFastSweepBase:_autoMoveEnd()
    self._touchLayer:enable()
    remote.user:checkTeamUp()
    self._ccbOwner.btn_one:setVisible(true)
    self._ccbOwner.frame_btn_close:setVisible(true)
    self._isShowEnd = true
    for _, value in pairs(self._awardItems) do
      value:setPromptIsOpen(true)
    end
end

function QUIDialogFastSweepBase:_autoMoveWithFinishedAnimation(offset)
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
        if q.isEmpty(self._extraExpItem) == false then
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

function QUIDialogFastSweepBase:_autoMoveWithExtraReward()
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

-- 移除动作
function QUIDialogFastSweepBase:_removeAction()
	if self._actionHandler ~= nil then
		self._content:stopAction(self._actionHandler)
		self._actionHandler = nil
	end
end

function QUIDialogFastSweepBase:moveTo(time,x,y,callback)
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


function QUIDialogFastSweepBase:_onEvent(event)
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

function QUIDialogFastSweepBase:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogFastSweepBase:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogFastSweepBase:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogFastSweepBase
