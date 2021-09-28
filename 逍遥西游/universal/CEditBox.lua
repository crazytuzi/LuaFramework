kKeyboardReturnTypeDefault = 0
kKeyboardReturnTypeDone = 1
kKeyboardReturnTypeSend = 2
kKeyboardReturnTypeSearch = 3
kKeyboardReturnTypeGo = 4
CEditBox = class("CEditBox", function()
  return Widget:create()
end)
function CEditBox:ctor(param)
  param.image = param.image or "views/pic/pic_keyboardbg.png"
  param.size = param.size or CCSize(100, 40)
  local _listener = function()
  end
  param.listener = param.listener or _listener
  self.m_EditBox = ui.newEditBox(param)
  self:addNode(self.m_EditBox)
  self.m_EditBox:setAnchorPoint(ccp(0, 0))
  if param.maxLength ~= nil then
    self.m_EditBox:setMaxLength(param.maxLength)
  end
  if param.fontName ~= nil then
    self.m_EditBox:setFontName(param.fontName)
  else
    self.m_EditBox:setFontName(KANG_TTF_FONT)
  end
  if param.fontSize ~= nil then
    self.m_EditBox:setFontSize(param.fontSize)
  else
    self.m_EditBox:setFontSize(20)
  end
  local funcs = {
    "setDelegate",
    "setText",
    "getText",
    "setFont",
    "setFontName",
    "setFontSize",
    "setFontColor",
    "setPlaceholderFont",
    "setPlaceholderFontName",
    "setPlaceholderFontSize",
    "setPlaceholderFontColor",
    "setPlaceHolder",
    "getPlaceHolder",
    "setInputMode",
    "setMaxLength",
    "getMaxLength",
    "setInputFlag",
    "setReturnType",
    "getReturnType",
    "setContentSize",
    "getContentSize",
    "registerScriptEditBoxHandler",
    "unregisterScriptEditBoxHandler"
  }
  for i, f in ipairs(funcs) do
    self[f] = function(obj, ...)
      local func = self.m_EditBox[f]
      if func then
        return func(self.m_EditBox, ...)
      end
    end
  end
end
