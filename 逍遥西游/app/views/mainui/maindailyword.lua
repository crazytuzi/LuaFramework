g_MainDailyWord = nil
CMainDailyWord = class("CMainDailyWord", CcsSubView)
function CMainDailyWord:ctor()
  CMainDailyWord.super.ctor(self, "views/main_dailyword.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_DailyWordTable = DeepCopyTable(data_TeamDailyword)
  for index = 1, 8 do
    btn = self:addBtnListener(string.format("dailyword_%d", index), function()
      self:OnSelectDailyword(index)
    end)
    if btn then
      local desc = self.m_DailyWordTable[index]
      if desc ~= nil then
        btn:setTitleText(desc)
      else
        btn:setVisible(false)
        btn:setTouchEnabled(false)
      end
    end
  end
  self:SetCloseWhenTouchOutside()
  self:ListenMessage(MsgID_Team)
  if g_MainDailyWord ~= nil then
    g_MainDailyWord:CloseSelf()
    g_MainDailyWord = nil
  end
  g_MainDailyWord = self
end
function CMainDailyWord:SetCloseWhenTouchOutside()
  self:enableCloseWhenTouchOutside(self:getNode("boxbg"), true)
end
function CMainDailyWord:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Team_PlayerLeaveTeam then
    local pid = arg[1]
    if pid == g_LocalPlayer:getPlayerId() then
      self:CloseSelf()
    end
  end
end
function CMainDailyWord:OnSelectDailyword(index)
  local desc = self.m_DailyWordTable[index]
  if desc then
    if g_TeamMgr:getLocalPlayerTeamId() ~= 0 then
      g_MessageMgr:sendTeamMessage(desc)
    else
      ShowNotifyTips("组队后才可在队伍频道里聊天")
    end
  end
  self:CloseSelf()
end
function CMainDailyWord:Btn_Close(obj, t)
  self:CloseSelf()
end
function CMainDailyWord:Clear()
  if g_MainDailyWord == self then
    g_MainDailyWord = nil
  end
end
