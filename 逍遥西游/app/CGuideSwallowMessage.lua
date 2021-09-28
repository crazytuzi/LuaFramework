CGuideSwallowMessage = class("CGuideSwallowMessage", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  widget:setSize(CCSize(display.width, display.height))
  return widget
end)
function CGuideSwallowMessage:ctor(data)
  self.m_data = data
  if data.isUnfocus == true then
    self:setTouchEnabled(false)
  else
    self:setTouchEnabled(true)
    self:addTouchEventListener(handler(self, self.Touch))
  end
end
function CGuideSwallowMessage:dealWithGuideFunc()
  print("CGuideSwallowMessage:dealWithGuideFunc")
  if self.m_data then
    local dealFun = self.m_data.clickfun
    if dealFun and type(dealFun) == "function" and self.m_data.isUnfocus ~= true then
      local m_param = self.m_data.param or {}
      local viewObj = g_MissionMgr:getRegisterClassObj(m_param.className, self.m_data.mid)
      local pointObj
      if viewObj ~= nil then
        pointObj = viewObj[m_param.objName]
      end
      dealFun(viewObj, pointObj)
    end
  end
end
function CGuideSwallowMessage:Touch(touchObj, t)
  return true
end
