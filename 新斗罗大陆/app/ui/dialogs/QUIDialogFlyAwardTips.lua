--
-- Author: Kumo
-- 大富翁获奖文本提示
--
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogFlyAwardTips = class("QUIDialogFlyAwardTips", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")


function QUIDialogFlyAwardTips:ctor(options)
  local ccbFile = "ccb/Dialog_FlyAward_Tips.ccbi"
  local callbacks = {}
  QUIDialogFlyAwardTips.super.ctor(self, ccbFile, callbacks, options)
  self._isTouchSwallow = false
  self._enableDialogEvent = false
  if options.content ~= nil then 
    self.content = options.content
  end
  
  self:_init()
  if options.time then
    self:tipAction(options.time)
  else
    self:tipAction()
  end
  if options.callback ~= nil then 
    self._callback = options.callback
  end
  if options and (options.offsetX or options.offsetY) then
    self:getView():setPosition(ccp(self:getView():getPositionX() + (options.offsetX or 0), self:getView():getPositionY() + (options.offsetY or 0)))
  end
end

--初始化浮动框
function QUIDialogFlyAwardTips:_init()
  self._ccbOwner.tf_num:setString(self.tipWord)
 
  local scaleIcon = 0.4
  local itemType = remote.items:getItemType(self.content.typeName or self.content.type)

  local itemBox = QUIWidgetItemsBox.new()
  itemBox:setScale(scaleIcon)
  itemBox:setGoodsInfo(self.content.id,itemType , 0)
  self._ccbOwner.node_icon:addChild(itemBox)

  local width = scaleIcon * 100 * 0.5

  self._ccbOwner.tf_zuanshi:setString(itemBox:getItemName())
  self._ccbOwner.tf_zuanshi:setPositionX(width)

  width = width + self._ccbOwner.tf_zuanshi:getContentSize().width

  self._ccbOwner.tf_num:setPositionX(width)
  self._ccbOwner.tf_num:setString("X"..self.content.count)
  width = width + self._ccbOwner.tf_num:getContentSize().width

  self._ccbOwner.node_pos:setPositionX(-width * 0.5)
  for i=1,4 do
     self._ccbOwner["float_tips_"..i]:setContentSize(CCSize(width + 100 , 50))
  end

end
--浮动提示延迟一秒后淡出
function QUIDialogFlyAwardTips:tipAction(fadeTime)
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

function QUIDialogFlyAwardTips:removeSelf()
    if self:getView() ~= nil then
      app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
        if self._callback then
          self._callback()
        end
    end
end

return QUIDialogFlyAwardTips
