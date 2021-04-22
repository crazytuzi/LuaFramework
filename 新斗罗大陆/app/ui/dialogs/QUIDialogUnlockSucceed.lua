local QUIDialog = import(".QUIDialog")
local QUIDialogUnlockSucceed = class("QUIDialogUnlockSucceed", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTips = import("...utils.QTips")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogUnlockSucceed:ctor(options)
  local ccbFile = "ccb/Dialog_UnlockSucceed.ccbi"
  local callBacks = {}
  QUIDialogUnlockSucceed.super.ctor(self, ccbFile, callBacks, options)
  
  self._isTouchSwallow = false
  QTips.UNLOCK_TIP_ISTRUE = true
  self._ccbOwner.parent_node:setScale(0)
  self:getView():setPosition(ccp(display.width/2, display.height/2 - 90))
  QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTips.UNLOCK_EVENT, event = options.type})
  self:setContent(options.type)
  self:fadeOut()
end

function QUIDialogUnlockSucceed:setContent(type)
  self.type = type
    local itemBox = QUIWidgetItemsBox.new()
    self._ccbOwner.head_node:addChild(itemBox)

    local unlockInfo = app.unlock:getConfigByKey(type)

    if unlockInfo and unlockInfo.icon ~= nil then
      self.icon = CCSprite:create(unlockInfo.icon)
      self.icon:setVisible(true)
      self.icon:setScale(0.8)
      self._ccbOwner.head_node:addChild(self.icon)
    end

    self._ccbOwner.unlock_name:setString(unlockInfo.name)
    self._ccbOwner.unlock_dec:setString(unlockInfo.description or "")
end

function QUIDialogUnlockSucceed:fadeOut()
    local time = UNLOCK_DELAY_TIME
    
--    makeNodeCascadeOpacityEnabled(self._ccbOwner.parent_node, true)

    local delayTime = CCDelayTime:create(time)
    local scale = CCScaleTo:create(0.2, 1.2)
    local scale1 = CCScaleTo:create(0, 1)
    local fadeOut = CCFadeOut:create(time)
    local callFunc = CCCallFunc:create(function()
      self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        QTips.UNLOCK_TIP_ISTRUE = false
        app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
        app.tip._unlockTip = nil
        app.tip:showNextTip()
      end, 0.5)
    end)
    local fadeAction = CCArray:create()
    fadeAction:addObject(scale)
    fadeAction:addObject(scale1)
    fadeAction:addObject(delayTime)
--    fadeAction:addObject(fadeOut)
    fadeAction:addObject(callFunc)
    local ccsequence = CCSequence:create(fadeAction)
    self._ccbOwner.parent_node:runAction(ccsequence)
    
end

return QUIDialogUnlockSucceed