--
-- Author: Kumo
-- Date: 2016-06-24 11:07:55
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSocietyDungeonRule = class("QUIDialogSocietyDungeonRule", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QScrollContain = import("..QScrollContain")

function QUIDialogSocietyDungeonRule:ctor(options)
  local ccbFile = "ccb/Dialog_SocietyDungeon_Rule.ccbi"
  local callBacks = {
      {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyDungeonRule._onTriggerClose)}
  }
  QUIDialogSocietyDungeonRule.super.ctor(self, ccbFile, callBacks, options)
  self.isAnimation = true
  
  -- self:getView():setPosition(ccp(display.width/2 + 35, display.height/2 ))
  
  self._infoContain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY})
  self._infoContain:setIsCheckAtMove(true)
  self._ccbOwner.touch_sheet:retain()
  self._ccbOwner.touch_sheet:removeFromParent()
  self._infoContain:addChild(self._ccbOwner.touch_sheet)
  local size = self._infoContain:getContentSize()
  size.height = 630
  self._infoContain:setContentSize(size.width, size.height)
end

function QUIDialogSocietyDungeonRule:viewDidAppear()
    QUIDialogSocietyDungeonRule.super.viewDidAppear(self)
    self._backTouchLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)
    self._backTouchLayer:setPosition(-display.width/2, -display.height/2)
    self._backTouchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._backTouchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIDialogSocietyDungeonRule._onTouchEnable))
    self._backTouchLayer:setTouchEnabled(true)
    self:getView():addChild(self._backTouchLayer,-1)
end

function QUIDialogSocietyDungeonRule:viewWillDisappear()
    QUIDialogSocietyDungeonRule.super.viewWillDisappear(self)
    if self._infoContain ~= nil then 
        self._infoContain:disappear()
        self._infoContain = nil
    end
end

function QUIDialogSocietyDungeonRule:viewAnimationOutHandler()
    self:removeSelfFromParent()
end

function QUIDialogSocietyDungeonRule:_onTouchEnable(event)
  if event.name == "began" then
    return true
    elseif event.name == "moved" then
        
    elseif event.name == "ended" then
        scheduler.performWithDelayGlobal(function()
            self:_onTriggerClose()
            end,0)
    elseif event.name == "cancelled" then
        
  end
end

function QUIDialogSocietyDungeonRule:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogSocietyDungeonRule:removeSelfFromParent()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogSocietyDungeonRule
