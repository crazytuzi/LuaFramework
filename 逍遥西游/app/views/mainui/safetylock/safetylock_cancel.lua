SafetylockCancel = class("SafetylockCancel", CcsSubView)
function SafetylockCancel:ctor(cancelListener)
  SafetylockCancel.super.ctor(self, "views/lock_unlock_cancel.csb", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
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
  self:getNode("title"):setText("解锁密码")
  local pos_tips = self:getNode("pos_tips")
  local size = pos_tips:getSize()
  local tipsText = CRichText.new({
    width = size.width,
    fontSize = 19,
    color = ccc3(255, 196, 98),
    align = CRichText_AlignType_Left
  })
  self:addChild(tipsText)
  local text = string.format("#<IRP>##<r:94,g:211,b:207>请输入密码以解除安全锁，##<r:255,g:0,b:0>解除安全锁将使你的帐号处于风险较高的状态，请慎重操作。#")
  tipsText:addRichText(text)
  local h = tipsText:getContentSize().height
  local x, y = pos_tips:getPosition()
  tipsText:setPosition(ccp(x, y + size.height - h))
  self.m_InputPwd1 = self:getNode("input_pw1")
  local size = self.m_InputPwd1:getSize()
  TextFieldEmoteExtend.extend(self.m_InputPwd1, nil, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
end
function SafetylockCancel:Clear()
end
function SafetylockCancel:OnBtn_Confirm(obj, t)
  local pwdString1 = self.m_InputPwd1:GetFieldText()
  print("pwdString1:", pwdString1)
  if checkStringIsLegalForSafetylock(pwdString1) == false then
    AwardPrompt.addPrompt("需要输入6~8位的数字密码")
    return
  end
  netsend.netsafetylock.cancel(pwdString1)
  self:CloseSelf()
end
function SafetylockCancel:OnBtn_Cancel(obj, t)
  self:CloseSelf()
end
function ShowSafetylockCancelView()
  getCurSceneView():addSubView({
    subView = SafetylockCancel.new(),
    zOrder = MainUISceneZOrder.popSafetylock
  })
end
