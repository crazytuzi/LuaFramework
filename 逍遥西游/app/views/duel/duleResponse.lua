g_DuelResponseDlg = nil
CDuelResponse = class("CDuelResponse", CPopWarning)
function CDuelResponse:ctor(pid, name, tp, rt)
  local duleTypeTxt = "单人决斗"
  if tp ~= 0 then
    duleTypeTxt = "多人决斗"
  end
  local tip = string.format("玩家#<Y>%s#向你发起了生死决斗，决斗方式为#<R>%s#，请确定是否接受挑战？", name, duleTypeTxt)
  local param = {
    title = "提示",
    text = tip,
    confirmText = "确定",
    cancelText = "取消",
    autoCancelTime = rt or 0,
    hideInWar = true,
    align = CRichText_AlignType_Left
  }
  CDuelResponse.super.ctor(self, param)
  self:ListenMessage(MsgID_Activity)
  self:ShowCloseBtn(false)
  if g_DuelResponseDlg ~= nil then
    g_DuelResponseDlg:CloseSelf()
    g_DuelResponseDlg = nil
  end
  g_DuelResponseDlg = self
end
function CDuelResponse:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_DuelStatus then
    local arg = {
      ...
    }
    local status = arg[1]
    if status == 2 then
      self:CloseSelf()
    end
  else
    CDuelResponse.super.OnMessage(self, msgSID, ...)
  end
end
function CDuelResponse:OnBtn_Confirm(obj, t)
  self:CloseSelf()
  netsend.netactivity.responseDuel(1)
end
function CDuelResponse:OnBtn_Cancel(obj, t)
  self:CloseSelf()
  netsend.netactivity.responseDuel(0)
end
function CDuelResponse:OnBtn_Close(obj, t)
end
function CDuelResponse:ShowWarning(iShow)
  self:setEnabled(iShow)
  self._auto_create_opacity_bg_ins:setEnabled(iShow)
  self:SwallowTouchEvent(iShow)
end
function CDuelResponse:Clear()
  CDuelResponse.super.Clear(self)
  if g_DuelResponseDlg == self then
    g_DuelResponseDlg = nil
  end
end
