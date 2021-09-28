TiantingExit1 = class("TiantingExit1", CcsSubView)
function TiantingExit1:ctor(exitType)
  TiantingExit1.super.ctor(self, "views/tianting1.csb", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_level = {
      listener = handler(self, self.OnBtn_LeveWithAward),
      variName = "btn_level"
    },
    btn_level_direct = {
      listener = handler(self, self.OnBtn_LeveDirect),
      variName = "btn_level_direct"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.txt_times = self:getNode("txt_times")
  self.txt_exp = self:getNode("txt_exp")
  self.m_ExitType = exitType
  local cur, sum = activity.tianting:getTimes()
  self.txt_times:setText(string.format("%d/%d", cur, sum))
  local exp = activity.tianting:getTotalExp()
  self.txt_exp:setText(string.format("%d", exp))
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_MapScene)
end
function TiantingExit1:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_ExitTianting then
    self:CloseSelf()
  elseif msgSID == MsgID_MapScene_ChangedMap then
    self:CloseSelf()
  end
end
function TiantingExit1:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function TiantingExit1:OnBtn_LeveWithAward(btnObj, touchType)
  print("OnBtn_LeveWithAward---->>")
  self:CloseSelf()
  if self.m_ExitType == 2 then
    activity.tianting:reqLeave(2, 1)
    netsend.netteam.tempLeaveTeam()
  else
    activity.tianting:reqLeave(2)
  end
end
function TiantingExit1:OnBtn_LeveDirect(btnObj, touchType)
  print("OnBtn_LeveDirect---->>")
  self:CloseSelf()
  if self.m_ExitType == 2 then
    activity.tianting:reqLeave(1, 1)
    netsend.netteam.tempLeaveTeam()
  else
    activity.tianting:reqLeave(1)
  end
end
