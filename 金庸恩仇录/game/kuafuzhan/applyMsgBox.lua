local applyMsgBox = class("applyMsgBox", function(param)
  return require("utility.ShadeLayer").new()
end)
function applyMsgBox:ctor(param)
  local leftBtnFunc = param.leftBtnFunc
  local midBtnFunc = param.midBtnFunc
  local rightBtnFunc = param.rightBtnFunc
  local showType = param.showType
  local rootProxy = CCBProxy:create()
  self._rootnode = {}
  local rootnode = CCBuilderReaderLoad("kuafu/kuafu_apply_msgBox.ccbi", rootProxy, self._rootnode)
  self:addChild(rootnode, 1)
  rootnode:setPosition(display.width / 2, display.height / 2)
  if showType == 1 then
    self._rootnode.knockout_node:setVisible(false)
  else
    self._rootnode.apply_node:setVisible(false)
    self._rootnode.content3:setString(common:getLanguageString("@kuafuApplyTip3", param.count))
    self._rootnode.content4:setString(common:getLanguageString("@kuafuApplyTip4"))
    self._rootnode.content5:setString(common:getLanguageString("@kuafuApplyTip5"))
  end
  self._rootnode.backBtn:addHandleOfControlEvent(function(eventName, sender)
    self:removeSelf()
  end, CCControlEventTouchDown)
  self._rootnode.setting_btn:addHandleOfControlEvent(function(eventName, sender)
    if leftBtnFunc then
      leftBtnFunc()
    end
    self:removeSelf()
  end, CCControlEventTouchDown)
  self._rootnode.knowBtn:addHandleOfControlEvent(function(eventName, sender)
    if midBtnFunc then
      midBtnFunc()
    end
    self:removeSelf()
  end, CCControlEventTouchDown)
  self._rootnode.confirm_btn:addHandleOfControlEvent(function(eventName, sender)
    if rightBtnFunc then
      rightBtnFunc()
    end
    self:removeSelf()
  end, CCControlEventTouchDown)
end
return applyMsgBox
