-- @Author: xurui
-- @Date:   2019-07-02 16:36:12
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-07-02 17:54:54
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityPlayerRecallAlert = class("QUIDialogActivityPlayerRecallAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogActivityPlayerRecallAlert:ctor(options)
	local ccbFile = "ccb/Dialog_playerRecall_alert.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    QUIDialogActivityPlayerRecallAlert.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callback = options.callback
    end
    self._isEnd = false
    self._timeScheduler = scheduler.performWithDelayGlobal(function()
            self._isEnd = true
        end, 1.5)
end

function QUIDialogActivityPlayerRecallAlert:viewDidAppear()
	QUIDialogActivityPlayerRecallAlert.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogActivityPlayerRecallAlert:viewWillDisappear()
  	QUIDialogActivityPlayerRecallAlert.super.viewWillDisappear(self)
    if self._timeScheduler ~= nil then
        scheduler.unscheduleGlobal(self._timeScheduler)
        self._timeScheduler = nil
    end
    if self._maskActionList then
        for index, action in ipairs(self._maskActionList) do
            local mask = self["_mask"..index]
            if mask then
                mask:stopAction(action)
                action = nil
            end
        end
    end
end

function QUIDialogActivityPlayerRecallAlert:_getMask(nodeList)
    local width = 0
    local height = nodeList[1]:getContentSize().height
    for _, node in ipairs(nodeList) do
        width = width + node:getContentSize().width
    end
    local clippingNode = CCClippingNode:create()
    local stencil = CCLayerColor:create(ccc4(0,0,0,150), width, height)
    stencil:ignoreAnchorPointForPosition(false)
    stencil:setAnchorPoint(nodeList[1]:getAnchorPoint())
    clippingNode:setStencil(stencil)

    local parent = nodeList[1]:getParent()
    parent:addChild(clippingNode)
    clippingNode:setPosition(ccp(nodeList[1]:getPosition()))
    stencil:setPosition(ccp(-width, 0))

    for _, node in ipairs(nodeList) do
        node:retain()
        node:removeFromParent()
        clippingNode:addChild(node)
        node:setPosition(ccp(0, 0))
        node:release()
    end
    q.autoLayerNode(nodeList, "x")

    return stencil
end

function QUIDialogActivityPlayerRecallAlert:setInfo()
	local day = remote.playerRecall:getLeaveDays()
	-- local richText1 = QRichText.new(nil, 500)
 --    richText1:setString({
 --        {oType = "font", content = "已经",size = 22,color = COLORS.j},
 --        {oType = "font", content = day, size = 22,color = COLORS.M},
 --        {oType = "font", content = "天不见了诶~", size = 22,color = COLORS.j},
 --    })
 --    richText1:setAnchorPoint(ccp(0, 1))
 --    self._ccbOwner.node_text_1:addChild(richText1)

	-- local richText2 = QRichText.new(nil, 260)
 --    richText2:setString({
 --        {oType = "font", content = "我们为您准备了",size = 22,color = COLORS.j},
 --        {oType = "font", content = "丰厚的回归大礼", size = 22,color = COLORS.M},
 --        {oType = "font", content = "。", size = 22,color = COLORS.j},
 --    })
 --    richText2:setAnchorPoint(ccp(0, 1))
 --    self._ccbOwner.node_text_2:addChild(richText2)

    self._ccbOwner.tf_day1:setString("已经")
    self._ccbOwner.tf_day2:setString(day)
    self._ccbOwner.tf_day3:setString("天不见了诶，")
    q.autoLayerNode({self._ccbOwner.tf_day1, self._ccbOwner.tf_day2, self._ccbOwner.tf_day3}, "x")

    self._ccbOwner.tf_reward1:setString("我们为您准备了")
    self._ccbOwner.tf_reward2:setString("丰厚的回归大礼，")
    q.autoLayerNode({self._ccbOwner.tf_reward1, self._ccbOwner.tf_reward2}, "x")

    self._mask1 = self:_getMask({self._ccbOwner.tf_info1})
    self._mask2 = self:_getMask({self._ccbOwner.tf_day1, self._ccbOwner.tf_day2, self._ccbOwner.tf_day3})
    self._mask3 = self:_getMask({self._ccbOwner.tf_info2})
    self._mask4 = self:_getMask({self._ccbOwner.tf_reward1, self._ccbOwner.tf_reward2})
    self._mask5 = self:_getMask({self._ccbOwner.tf_info3})

    self:_startTypewriterEffect()
end

function QUIDialogActivityPlayerRecallAlert:_startTypewriterEffect()
    self._maskActionList = {}
    self._maskActionStateList = {}
    local index = 1
    local delayTime = 0.5
    local moveTime = 0
    while true do
        local mask = self["_mask"..index]
        if mask then
            delayTime = delayTime + moveTime
            moveTime = 0.0025 * mask:getContentSize().width
            local array = CCArray:create()
            array:addObject(CCDelayTime:create(delayTime))
            array:addObject(CCMoveTo:create(moveTime, ccp(0, 0)))
            array:addObject(CCCallFunc:create(function()
                    self._maskActionStateList[index] = false
                end))
            local action = CCSequence:create(array)
            self._maskActionStateList[index] = true
            self._maskActionList[index] = mask:runAction(action)
            index = index + 1
        else
            break
        end
    end
end

function QUIDialogActivityPlayerRecallAlert:_stopTypewriterEffect()
    self._maskActionStateList = {}
    if self._maskActionList then
        for index, action in ipairs(self._maskActionList) do
            local mask = self["_mask"..index]
            if mask then
                mask:stopAction(action)
                mask:setPosition(ccp(0, 0))
                action = nil
            end
        end
    end
end

function QUIDialogActivityPlayerRecallAlert:_onTriggerGo(event)
    if self._isEnd == false then 
        return 
    end
	if q.buttonEventShadow(event, self._ccbOwner.btn_goto) == false then return end
	self:popSelf()
	remote.playerRecall:openDialog()
end

function QUIDialogActivityPlayerRecallAlert:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogActivityPlayerRecallAlert:_onTriggerClose()
    -- local isEffectEnd = true
    -- if self._maskActionStateList then
    --     for _, state in ipairs(self._maskActionStateList) do
    --         if state then
    --             isEffectEnd = false
    --             break
    --         end
    --     end 
    -- end
    -- if not isEffectEnd then
    --     self:_stopTypewriterEffect()
    --     return
    -- end
    if self._isEnd == false then 
        return 
    end
	self:playEffectOut()
end

function QUIDialogActivityPlayerRecallAlert:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogActivityPlayerRecallAlert
