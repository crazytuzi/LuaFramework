--
-- Author: Your Name
-- Date: 2014-10-21 18:30:20
--
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogFloatForce = class("QUIDialogFloatForce", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

function QUIDialogFloatForce:ctor(options)
    local ccbFile = "ccb/Dialog_Float_Force.ccbi"
    local callbacks = {}
    QUIDialogFloatForce.super.ctor(self, ccbFile, callbacks, options)

    self._time = options.time
    
    self._startForce = tonumber(options.startForce) or remote.user.localForce
    self._endForce = tonumber(options.endForce) or 0
    self._addForce = self._endForce - (self._startForce or 0)
    -- print("[Kumo] QUIDialogFloatForce:ctor() ", self._startForce, self._endForce, self._addForce)
    self._totalForceNumWidth = 0
    self._totalAddForceNumWidth = 0
    self._gap = 10 -- 间隔
    self._s9sWidthOffset = 70 -- 考虑背景的渐变

    self.isAnimation = true --是否动画显示

    self:_init()

    if options and (options.offsetX or options.offsetY) then
        self:getView():setPosition(ccp(self:getView():getPositionX() + (options.offsetX or 0), self:getView():getPositionY() + (options.offsetY or 0)))
    end
end

--初始化浮动框
function QUIDialogFloatForce:_init()
    -- print("[Kumo] QUIDialogFloatForce:_init() ", self._startForce, self._addForce)
    -- remote.user.localForce = self._endForce
    if self._addForce > 0 and self._startForce then
        self:showAddForce()
        self:onForceUpdate(self._startForce)
        self._forceUpdate = QTextFiledScrollUtils.new()
        self._isShowing = true
        self._updateScheduler = scheduler.performWithDelayGlobal(function()
                self._forceUpdate:addUpdate(self._startForce, self._endForce, handler(self, self.onForceUpdate), 15/30, handler(self, self.endForceUpdate))
            end, 0)
    end
end

function QUIDialogFloatForce:onForceUpdate(value)
    -- print("[Kumo] QUIDialogFloatForce:onForceUpdate()  ", math.ceil(value))
    self._ccbOwner.node_force:removeAllChildren()
    self._totalForceNumWidth = 0
    local forceStr = tostring(math.ceil(value))
    local strLen = string.len(forceStr)
    for i = 1, strLen, 1 do
        local num = tonumber(string.sub(forceStr, i, i))
        if num == 0 then num = 10 end
        local paths = QResPath("floatForceNum")
        -- print("[Kumo] QUIDialogFloatForce:onForceUpdate() ", num)
        local spNum = CCSprite:create(paths[num])
        self._ccbOwner.node_force:addChild(spNum)
        local width = spNum:getContentSize().width
        spNum:setPosition(self._totalForceNumWidth + width/2, 0)
        self._totalForceNumWidth = self._totalForceNumWidth + width
    end
    self._ccbOwner.sp_force_title:setPosition(self._ccbOwner.sp_force_title:getContentSize().width/2, 0)
    self._ccbOwner.node_force:setPosition(self._ccbOwner.sp_force_title:getContentSize().width + self._gap, 0)
    self._ccbOwner.node_addForce:setPosition(self._ccbOwner.sp_force_title:getContentSize().width + self._gap + self._totalForceNumWidth + self._gap, 0)

    local totalWidth = self._ccbOwner.sp_force_title:getContentSize().width + self._gap + self._totalForceNumWidth + self._gap + self._totalAddForceNumWidth
    self._ccbOwner.node_all:setPosition(-totalWidth/2, 0)
    self._ccbOwner.s9s_bg_left:setPreferredSize(CCSize(totalWidth/2 + self._s9sWidthOffset, 80))
    self._ccbOwner.s9s_bg_right:setPreferredSize(CCSize(totalWidth/2 + self._s9sWidthOffset, 80))
end

function QUIDialogFloatForce:endForceUpdate()
    -- print("[Kumo] QUIDialogFloatForce:endForceUpdate()")
    self._isShowing = false
    if self._time then
        self:tipAction(self._time)
    else
        self:tipAction()
    end
end

function QUIDialogFloatForce:showAddForce()
    self._ccbOwner.node_addForce:removeAllChildren()

    local path = QResPath("floatForceAddSp")
    local spJia = CCSprite:create(path)
    local width = spJia:getContentSize().width
    self._ccbOwner.node_addForce:addChild(spJia)
    spJia:setPosition(width/2, 0)
    self._totalAddForceNumWidth = self._totalAddForceNumWidth + width

    local addForceStr = tostring(self._addForce)
    local strLen = string.len(addForceStr)
    for i = 1, strLen, 1 do
        local num = tonumber(string.sub(addForceStr, i, i))
        if num == 0 then num = 10 end
        local paths = QResPath("floatForceAddNum")
        -- print("[Kumo] QUIDialogFloatForce:showAddForce() ", num)
        local spNum = CCSprite:create(paths[num])
        self._ccbOwner.node_addForce:addChild(spNum)
        local width = spNum:getContentSize().width
        spNum:setPosition(self._totalAddForceNumWidth + width/2, 0)
        self._totalAddForceNumWidth = self._totalAddForceNumWidth + width
    end

    self._ccbOwner.sp_force_title:setPosition(self._ccbOwner.sp_force_title:getContentSize().width/2, 0)
    self._ccbOwner.node_force:setPosition(self._ccbOwner.sp_force_title:getContentSize().width + self._gap, 0)
    self._ccbOwner.node_addForce:setPosition(self._ccbOwner.sp_force_title:getContentSize().width + self._gap + self._totalForceNumWidth + self._gap, 0)

    local totalWidth = self._ccbOwner.sp_force_title:getContentSize().width + self._gap + self._totalForceNumWidth + self._gap + self._totalAddForceNumWidth
    self._ccbOwner.node_all:setPosition(-totalWidth/2, 0)
    self._ccbOwner.s9s_bg_left:setPreferredSize(CCSize(totalWidth/2 + self._s9sWidthOffset, 80))
    self._ccbOwner.s9s_bg_right:setPreferredSize(CCSize(totalWidth/2 + self._s9sWidthOffset, 80))
end

function QUIDialogFloatForce:showEndForce()
    if self._updateScheduler ~= nil then
        scheduler.unscheduleGlobal(self._updateScheduler)
        self._updateScheduler = nil
    end

    if self._forceUpdate then
        self._forceUpdate:stopUpdate()
        self._forceUpdate = nil
    end
    self:showAddForce()
    self:onForceUpdate(self._endForce)
end

--浮动提示延迟一秒后淡出
function QUIDialogFloatForce:tipAction(fadeTime)
    -- print("[Kumo] QUIDialogFloatForce:tipAction()", fadeTime)
    local time = fadeTime or 1.0

    makeNodeCascadeOpacityEnabled(self._ccbOwner.parent_node, true)

    local delayTime = CCDelayTime:create(time)
    local fadeOut = CCFadeOut:create(time)
    local func = CCCallFunc:create(function() 
        self:removeSelf()
    end)
    local fadeAction = CCArray:create()
    fadeAction:addObject(delayTime)
    fadeAction:addObject(fadeOut)
    fadeAction:addObject(func)
    local bg_ccsequence = CCSequence:create(fadeAction)

    self._ccbOwner.parent_node:runAction(bg_ccsequence)
end

function QUIDialogFloatForce:removeSelf()
    -- print("QUIDialogFloatForce:removeSelf() ", self:getView())
    if self:getView() ~= nil then
        app.floatForceNode:removeAllChildren()
        -- app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
    end
end

function QUIDialogFloatForce:exit()
    -- print("QUIDialogFloatForce:exit() ")
    if self._updateScheduler ~= nil then
        scheduler.unscheduleGlobal(self._updateScheduler)
        self._updateScheduler = nil
    end

    if self._forceUpdate then
        self._forceUpdate:stopUpdate()
        self._forceUpdate = nil
    end
end

return QUIDialogFloatForce
