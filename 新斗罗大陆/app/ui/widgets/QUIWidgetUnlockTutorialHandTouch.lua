local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUnlockTutorialHandTouch = class("QUIWidgetUnlockTutorialHandTouch", QUIWidget)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTips = import("...utils.QTips")

QUIWidgetUnlockTutorialHandTouch.UNLOCK_TUTORIAL_EVENT_CLICK = "UNLOCK_TUTORIAL_EVENT_CLICK"

function QUIWidgetUnlockTutorialHandTouch:ctor(options)
  local ccbFile = nil

  if options.direction == nil or options.direction == "up" or options.direction == "down" then

     ccbFile = "ccb/Widget_NewBuilding_open.ccbi"
  elseif options.direction == "left" or options.direction == "right" then
     ccbFile = "ccb/Widget_NewBuilding_open2.ccbi"
  end
  local callbacks = {
    {ccbCallbackName = "onTirggerClick", callback = handler(self, QUIWidgetUnlockTutorialHandTouch._onTirggerClick)}
  }
  QUIWidgetUnlockTutorialHandTouch.super.ctor(self, ccbFile, callbacks, options)

  cc.GameObject.extend(self)
  self:addComponent("components.behavior.EventProtocol"):exportMethods()
  
  if options.word ~= nil then
   self._word = options.word
  end
  self._ccbOwner.word:setString(self._word or "")
  
  print("QUIWidgetUnlockTutorialHandTouch self._word = "..self._word)
  print("QUIWidgetUnlockTutorialHandTouch options.direction = "..options.direction)

  if options.direction == "left" then
    self:getView():setScaleX(-1)
    self._ccbOwner.word:setScaleX(-1)
  end
  if options.direction == "down" then
    self:getView():setScaleY(-1)
    self._ccbOwner.word:setScaleY(-1)
  end
  self.isClick = true
  if options.typeInfo ~= nil then
    self.type = options.typeInfo
  end
  
end

function QUIWidgetUnlockTutorialHandTouch:setHandTouch(word, direction)
  self._ccbOwner.word:setString(word or "")
  if direction == "right" or direction == "up" then
    self:getView():setScaleX(1)
  elseif direction == "left" or direction == "down" then
    self:getView():setScaleX(-1)
  end
end

function QUIWidgetUnlockTutorialHandTouch:_onTirggerClick()
  local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
  if page._isMoveing == true then return end
  app.tip:unlockTutorialClose(self.type)
  self:dispatchEvent({name = QUIWidgetUnlockTutorialHandTouch.UNLOCK_TUTORIAL_EVENT_CLICK, type = self.type})
end

return QUIWidgetUnlockTutorialHandTouch