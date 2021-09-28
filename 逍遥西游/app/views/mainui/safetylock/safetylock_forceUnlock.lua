SafetylockForceUnlock = class("SafetylockForceUnlock", CcsSubView)
function SafetylockForceUnlock:ctor(cancelListener)
  SafetylockForceUnlock.super.ctor(self, "views/lock_unlock_force.csb", {
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
  self:getNode("title"):setText("强行解除")
  local pos_tips = self:getNode("pos_tips")
  local size = pos_tips:getSize()
  local tipsText = CRichText.new({
    width = size.width,
    fontSize = 19,
    color = ccc3(255, 196, 98),
    align = CRichText_AlignType_Left
  })
  self:addChild(tipsText)
  local unlockExceedTime = g_LocalPlayer:getSafetyLockForceUnlockTime()
  local serverTime = g_DataMgr:getServerTime()
  local delayTime = unlockExceedTime - serverTime
  local h, m, s = 0, 0, 0
  if delayTime > 0 then
    h, m, s = getHMSWithSeconds(delayTime)
  end
  local d = math.floor(h / 24)
  local leftH = h - d * 24
  local timeText = ""
  if d > 0 then
    timeText = string.format("%d天%02d小时", d, leftH)
  elseif h > 0 then
    timeText = string.format("%02d小时%02d分", leftH, m)
  else
    timeText = string.format("%02d分", m)
  end
  local text = string.format("  #<r:255,g:255,b:255>处于自动解除状态下，还需要##<r:255,g:0,b:0>%s##<r:255,g:255,b:255>后自动解除，若你已记起密码可输入密码进行解除#", timeText)
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
function SafetylockForceUnlock:Clear()
end
function SafetylockForceUnlock:OnBtn_Confirm(obj, t)
  local pwdString1 = self.m_InputPwd1:GetFieldText()
  print("pwdString1:", pwdString1)
  if checkStringIsLegalForSafetylock(pwdString1) == false then
    AwardPrompt.addPrompt("需要输入6~8位的数字密码")
    return
  end
  netsend.netsafetylock.forceUnlock(pwdString1)
  self:CloseSelf()
end
function SafetylockForceUnlock:OnBtn_Cancel(obj, t)
  self:CloseSelf()
end
function ShowSafetylockForceUnlockView()
  getCurSceneView():addSubView({
    subView = SafetylockForceUnlock.new(),
    zOrder = MainUISceneZOrder.popSafetylock
  })
end
