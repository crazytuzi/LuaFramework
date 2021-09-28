RequestJiehunOrJieqi = class("RequestJiehunOrJieqi", CcsSubView)
RequestJiehunOrJieqi.__ins = nil
function RequestJiehunOrJieqi:ctor(jsonFile, name, zs, lv, listener)
  RequestJiehunOrJieqi.super.ctor(self, jsonFile, {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  if RequestJiehunOrJieqi.__ins ~= nil then
    RequestJiehunOrJieqi.__ins:removeFromParent()
  end
  RequestJiehunOrJieqi.__ins = self
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "m_Btn_Confirm"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "m_Btn_Cancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_callbackListener = listener
  self:getNode("txt_name"):setText(name)
  self:getNode("txt_lv"):setText(string.format("%d转%d级", zs, lv))
  local totalTime = 30
  self.m_Btn_Cancel:setTitleText(string.format("拒绝 %ds", totalTime))
  local actList = {}
  for i = totalTime - 1, 1, -1 do
    do
      local time = i
      actList[#actList + 1] = CCDelayTime:create(1)
      actList[#actList + 1] = CCCallFunc:create(function()
        self.m_Btn_Cancel:setTitleText(string.format("拒绝 %ds", time))
      end)
    end
  end
  actList[#actList + 1] = CCDelayTime:create(1)
  actList[#actList + 1] = CCCallFunc:create(function()
    self:OnBtn_Cancel()
  end)
  self:runAction(transition.sequence(actList))
end
function RequestJiehunOrJieqi:Clear()
  self.m_callbackListener = nil
  if RequestJiehunOrJieqi.__ins == self then
    RequestJiehunOrJieqi.__ins = nil
  end
end
function RequestJiehunOrJieqi:OnBtn_Confirm(obj, t)
  if self.m_callbackListener then
    self.m_callbackListener(true)
  end
  self:CloseSelf()
end
function RequestJiehunOrJieqi:OnBtn_Cancel(obj, t)
  if self.m_callbackListener then
    self.m_callbackListener(false)
  end
  self:CloseSelf()
end
