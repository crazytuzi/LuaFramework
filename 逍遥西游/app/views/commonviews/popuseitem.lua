CPopUseItem = class("CPopUseItem", CcsSubView)
function CPopUseItem:ctor(para)
  CPopUseItem.super.ctor(self, "views/pop_useitem.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  text = para.text or nil
  btnTextList = para.btnTextList or {"确定"}
  funcList = para.funcList or {}
  self.m_btnTextList = btnTextList
  self.m_funcList = funcList
  local btnBatchListener = {
    btn_1 = {
      listener = handler(self, self.OnBtn_1),
      variName = "m_Btn_1"
    },
    btn_2 = {
      listener = handler(self, self.OnBtn_2),
      variName = "m_Btn_2"
    },
    btn_3 = {
      listener = handler(self, self.OnBtn_3),
      variName = "m_Btn_3"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  for i = 1, 3 do
    local btn = self[string.format("m_Btn_%d", i)]
    btn:setVisible(false)
  end
  local index = 1
  for _, btnText in pairs(self.m_btnTextList) do
    local btn = self[string.format("m_Btn_%d", index)]
    btn:setTitleText(btnText)
    btn:setVisible(true)
    index = index + 1
  end
  local textSize = self:getNode("list_text"):getSize()
  if text == nil then
    self:getNode("list_text"):setEnabled(false)
  else
    self.m_TextBox = CRichText.new({
      width = textSize.width,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 25,
      color = ccc3(255, 255, 255)
    })
    self.m_TextBox:addRichText(text)
    self:getNode("list_text"):pushBackCustomItem(self.m_TextBox)
  end
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
  g_TouchEvent:setCanTouch(false)
  return self
end
function CPopUseItem:OnBtn_1()
  local func = self.m_funcList[1]
  self:OnClose()
  if func then
    func()
  end
end
function CPopUseItem:OnBtn_2()
  local func = self.m_funcList[2]
  self:OnClose()
  if func then
    func()
  end
end
function CPopUseItem:OnBtn_3()
  local func = self.m_funcList[3]
  self:OnClose()
  if func then
    func()
  end
end
function CPopUseItem:OnClose()
  self:removeFromParent()
end
function CPopUseItem:Clear()
  self.m_funcList = nil
  g_TouchEvent:setCanTouch(true)
end
