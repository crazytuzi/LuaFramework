--
-- Author: Your Name
-- Date: 2014-10-21 18:30:20
--
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogFloatTip = class("QUIDialogFloatTip", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogFloatTip:ctor(options)
  local ccbFile = "ccb/Dialog_Float_Tips.ccbi"
  local callbacks = {}
  QUIDialogFloatTip.super.ctor(self, ccbFile, callbacks, options)
  self._isTouchSwallow = false
  self._enableDialogEvent = false
  if options.words ~= nil then 
    self.tipWord = options.words
  end
  
  self:_init()
  if options then
    self:tipAction(options.time)
  else
    self:tipAction()
  end

  if options and (options.offsetX or options.offsetY) then
    self:getView():setPosition(ccp(self:getView():getPositionX() + (options.offsetX or 0), self:getView():getPositionY() + (options.offsetY or 0)))
  end
end

--初始化浮动框
function QUIDialogFloatTip:_init()
  local oldWordSize = self._ccbOwner.words1:getContentSize()
  self._ccbOwner.words1:setString(self.tipWord)
  
  local changeSize = self._ccbOwner.words1:getContentSize().width - oldWordSize.width
  self.tipSize = self._ccbOwner.float_tips:getContentSize()

  self._ccbOwner.float_tips:setContentSize(CCSize(self.tipSize.width+changeSize, self.tipSize.height))
end
--浮动提示延迟一秒后淡出
function QUIDialogFloatTip:tipAction(fadeTime)
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

function QUIDialogFloatTip:removeSelf()
    if self:getView() ~= nil then
      app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
    end
end

return QUIDialogFloatTip
