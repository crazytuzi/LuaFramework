CFreePetConfirmView = class("CFreePetConfirmView", CcsSubView)
function CFreePetConfirmView:ctor(params)
  CFreePetConfirmView.super.ctor(self, "views/freepet.json", {isAutoCenter = true, opacityBg = 100})
  local des = params.des
  self.m_objId = params.objId
  self.m_randNum = params.randNum or 0
  self.m_MaxInputNum = params.InputNum or 3
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.Btn_Confirm),
      variName = "btn_confirm"
    },
    btn_cancel = {
      listener = handler(self, self.Btn_Cancel),
      variName = "btn_cancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.input_box = self:getNode("input_box")
  local size = self.input_box:getContentSize()
  TextFieldEmoteExtend.extend(self.input_box, self.m_UINode, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
  self.input_box:setMaxLengthEnabled(false)
  self.input_box:SetMaxInputLength(self.m_MaxInputNum)
  self:setTips(des)
end
function CFreePetConfirmView:setTips(des)
  local des_node = self:getNode("txt_pos")
  local descSize = des_node:getContentSize()
  local x, y = des_node:getPosition()
  local tipDesc = CRichText.new({
    width = descSize.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 22,
    color = ccc3(255, 255, 255)
  })
  self:addChild(tipDesc)
  tipDesc:setPosition(ccp(x, y))
  tipDesc:addRichText(des)
end
function CFreePetConfirmView:getInputBoxTxt()
  local verifyNum = self.input_box:GetFieldText()
  if self.m_randNum == tonumber(verifyNum) then
    netsend.netbaseptc.resetFirePet(self.m_objId)
    ShowWarningInWar()
    self:CloseSelf()
  else
    ShowNotifyTips("请输入正确的数字后再按确定")
  end
end
function CFreePetConfirmView:Btn_Cancel(...)
  self:CloseSelf()
end
function CFreePetConfirmView:Btn_Confirm(...)
  self:getInputBoxTxt()
end
function CFreePetConfirmView:Clear()
  if self.input_box ~= nil then
    self.input_box:CloseTheKeyBoard()
    self.input_box:ClearTextFieldExtend()
  end
end
