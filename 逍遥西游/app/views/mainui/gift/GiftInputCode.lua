local CGiftInputCode = class("CGiftInputCode", CcsSubView)
function CGiftInputCode:ctor(giftId)
  CGiftInputCode.super.ctor(self, "views/giftinputcode.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_ok = {
      listener = handler(self, self.OnBtn_Ok),
      variName = "btn_ok"
    },
    btn_paste = {
      listener = handler(self, self.OnBtn_Pause),
      variName = "btn_paste"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_GiftId = giftId
  self.m_NameInputBg = self:getNode("input_bg")
  self.m_NameInput = self:getNode("input_box")
  local size = self.m_NameInput:getContentSize()
  TextFieldEmoteExtend.extend(self.m_NameInput, nil, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
  self.m_NameInput:SetFieldText("")
  self.m_CharNumMinLimit = 1
  self.m_CharNumMaxLimit = 30
  self.m_NameInput:setMaxLength(self.m_CharNumMaxLimit)
  self:ListenMessage(MsgID_Device)
  self:flushPasteBtn()
end
function CGiftInputCode:OnMessage(msgSID, ...)
  if msgSID == MsgID_EnterForeground then
    self:flushPasteBtn()
  end
end
function CGiftInputCode:flushPasteBtn()
  self.btn_paste:setEnabled(false)
  SyNative.getPasteboardText(50, function(paste)
    print("flushPasteBtn:", paste)
    if paste == nil or type(paste) ~= "string" then
      print("接口出错")
      self.btn_paste:setEnabled(false)
    elseif string.len(paste) > 0 then
      self.btn_paste:setTouchEnabled(true)
      self.btn_paste:setBright(true)
      self.btn_paste:setEnabled(true)
    else
      self.btn_paste:setBright(false)
      self.btn_paste:setTouchEnabled(false)
    end
  end)
end
function CGiftInputCode:OnBtn_Ok(btnObj, touchType)
  local text = self.m_NameInput:GetFieldText()
  text = string.lower(text)
  if string.len(text) > self.m_CharNumMaxLimit + 1 then
    ShowNotifyTips("请输入正确的礼品码")
    return
  else
    local len = string.len(text)
    local okFlag = true
    for i = 1, len do
      local char = string.byte(text, i)
      if char < 48 or char > 57 and char < 97 or char > 122 then
        okFlag = false
        break
      end
    end
    if okFlag == false then
      ShowNotifyTips("请输入正确的礼品码")
      return
    end
    if self.m_GiftId == nil then
      netsend.netgift.reqGetGiftOfIdentify(nil, text)
    else
      netsend.netgift.reqGetGiftOfIdentify(tonumber(self.m_GiftId), text)
    end
    self:CloseSelf()
  end
end
function CGiftInputCode:OnBtn_Pause(btnObj, touchType)
  SyNative.getPasteboardText(50, function(paste)
    if type(paste) == "string" and string.len(paste) > 0 then
      self.m_NameInput:SetFieldText(paste)
    end
  end)
end
function CGiftInputCode:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CGiftInputCode:Clear()
  self.m_NameInput:CloseTheKeyBoard()
  self.m_NameInput:ClearTextFieldExtend()
end
function ShowInputCodeView(giftId)
  local dlg = CGiftInputCode.new(giftId)
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.menuView
  })
end
