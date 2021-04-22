--
-- Author: Kumo
-- 大富翁获奖文本提示
--
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogSkyFallFloatAward = class("QUIDialogSkyFallFloatAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")

function QUIDialogSkyFallFloatAward:ctor(options)
  local ccbFile = "ccb/Dialog_skyFll_Float_Award.ccbi"
  local callbacks = {}
  QUIDialogSkyFallFloatAward.super.ctor(self, ccbFile, callbacks, options)
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
function QUIDialogSkyFallFloatAward:_init()
  self._ccbOwner.tf_num:setString(self.tipWord)
  local nodes = {}
  table.insert(nodes,self._ccbOwner.sp_resoure)
  table.insert(nodes,self._ccbOwner.tf_zuanshi)
  table.insert(nodes,self._ccbOwner.tf_num)
  q.autoLayerNode(nodes, "x", 0)
end
--浮动提示延迟一秒后淡出
function QUIDialogSkyFallFloatAward:tipAction(fadeTime)
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

function QUIDialogSkyFallFloatAward:removeSelf()
    if self:getView() ~= nil then
      app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
    end
end

return QUIDialogSkyFallFloatAward
