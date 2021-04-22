--
-- Author: Kumo
-- 大富翁获奖文本提示
--
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogFloatAward = class("QUIDialogFloatAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogFloatAward:ctor(options)
  local ccbFile = "ccb/Dialog_Float_Award.ccbi"
  local callbacks = {}
  QUIDialogFloatAward.super.ctor(self, ccbFile, callbacks, options)
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
function QUIDialogFloatAward:_init()
  local oldWordSize = self._ccbOwner.words1:getContentSize()
  self._ccbOwner.words1:setString(self.tipWord)
  
  local changeSize = self._ccbOwner.words1:getContentSize().width - oldWordSize.width

  local bg1 = self._ccbOwner.float_tips_1
  bg1:setContentSize(CCSize(bg1:getContentSize().width + changeSize/2, bg1:getContentSize().height))
  local bg2 = self._ccbOwner.float_tips_2
  bg2:setContentSize(CCSize(bg2:getContentSize().width + changeSize/2, bg2:getContentSize().height))
  local bg3 = self._ccbOwner.float_tips_3
  bg3:setContentSize(CCSize(bg3:getContentSize().width + changeSize/2, bg3:getContentSize().height))
  local bg4 = self._ccbOwner.float_tips_4
  bg4:setContentSize(CCSize(bg4:getContentSize().width + changeSize/2, bg4:getContentSize().height))
end
--浮动提示延迟一秒后淡出
function QUIDialogFloatAward:tipAction(fadeTime)
  local time = fadeTime or 1.1
  
  -- makeNodeCascadeOpacityEnabled(self._ccbOwner.parent_node, true)
  
  local delayTime = CCDelayTime:create(time)
  local fadeOut = CCFadeOut:create(time)
  local func = CCCallFunc:create(function() 
    self:removeSelf()
  end)
  local fadeAction = CCArray:create()
  fadeAction:addObject(delayTime)
  -- fadeAction:addObject(fadeOut)
  fadeAction:addObject(func)
  local bg_ccsequence = CCSequence:create(fadeAction)
  
  self._ccbOwner.parent_node:runAction(bg_ccsequence)
end

function QUIDialogFloatAward:removeSelf()
    if self:getView() ~= nil then
      app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
    end
end

return QUIDialogFloatAward
