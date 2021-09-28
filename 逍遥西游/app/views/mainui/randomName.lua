local CRandomName = class("CRandomName", CcsSubView)
function CRandomName:ctor(params)
  CRandomName.super.ctor(self, "views/rdName.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  self.m_Listener = params.listener
  self.m_RandomFunc = params.randomFunc
  local btnBatchListener = {
    btn_random = {
      listener = handler(self, self.OnBtn_Random),
      variName = "btn_random"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    },
    btn_ok = {
      listener = handler(self, self.OnBtn_Ok),
      variName = "btn_ok"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_NameInputBg = self:getNode("input_bg")
  self.m_NameInput = self:getNode("input_box")
  local size = self.m_NameInput:getContentSize()
  TextFieldEmoteExtend.extend(self.m_NameInput, nil, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
  if self.m_RandomFunc == nil then
    self.btn_random:setEnabled(false)
    local size = self:getContentSize()
    local offx = size.width / 2
    local _, y1 = self.m_NameInputBg:getPosition()
    self.m_NameInputBg:setPosition(ccp(offx, y1))
    local _, y2 = self.m_NameInput:getPosition()
    self.m_NameInput:setPosition(ccp(offx, y2))
  end
  if params.title ~= nil then
    self:getNode("title"):setText(params.title)
  end
  self.m_NameInput:SetFieldText("")
  self.m_CharNumMinLimit = params.minLimit or MinLengthOfName
  self.m_CharNumMaxLimit = params.maxLimit or MaxLengthOfName
  self.m_NameInput:setMaxLength(self.m_CharNumMaxLimit)
end
function CRandomName:OnBtn_Random(btnObj, touchType)
  if self.m_RandomFunc then
    local rdText = self.m_RandomFunc()
    self.m_NameInput:setMaxLengthEnabled(false)
    self.m_NameInput:SetFieldText(rdText)
    self.m_NameInput:setMaxLengthEnabled(true)
    self.m_LastRandomName = rdText
  end
end
function CRandomName:OnBtn_Cancel(btnObj, touchType)
  self:CloseSelf()
end
function CRandomName:OnBtn_Ok(btnObj, touchType)
  local text = self.m_NameInput:GetFieldText()
  if string.len(text) < self.m_CharNumMinLimit then
    ShowNotifyTips(string.format("名字不能少于%d个字", self.m_CharNumMinLimit))
  else
    if string.find(text, " ") ~= nil then
      ShowNotifyTips("名字不能包含空格")
      return
    end
    if string.find(text, "#") ~= nil then
      ShowNotifyTips("名字不能包含#")
      return
    end
    if self.m_LastRandomName == text or checkText_DFAFilter(text) then
      if self.m_Listener then
        self.m_Listener(text)
      end
      self:CloseSelf()
    else
      ShowNotifyTips("名字不合法")
    end
  end
end
function CRandomName:Clear()
  self.m_Listener = nil
  self.m_RandomFunc = nil
  self.m_NameInput:CloseTheKeyBoard()
  self.m_NameInput:ClearTextFieldExtend()
end
function ShowNameBox(params)
  local dlg = CRandomName.new(params)
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.popView
  })
  local size = dlg:getContentSize()
  dlg:setPosition(ccp(display.width / 2 - size.width / 2, display.height / 2 - size.height / 2))
end
