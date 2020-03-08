local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgGangCrossBattlePrepare = Lplus.Extend(ECPanelBase, "DlgGangCrossBattlePrepare")
local GangCrossBattleMgr = require("Main.GangCross.GangCrossBattleMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GangCrossData = require("Main.GangCross.data.GangCrossData")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local def = DlgGangCrossBattlePrepare.define
local dlg
def.field("number").leftTime = 0
def.static("=>", DlgGangCrossBattlePrepare).Instance = function()
  if dlg == nil then
    dlg = DlgGangCrossBattlePrepare()
  end
  return dlg
end
def.override().OnCreate = function(self)
  self.m_panel:FindDirect("Img_Bg/Btn_Watch"):SetActive(true)
  Timer:RegisterListener(self.UpdateCountDown, self)
  Event.RegisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.LEAVE_GANG_BATTLE_MAP, DlgGangCrossBattlePrepare.OnStatusChanged)
  Event.RegisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Prepare_Player_Changed, DlgGangCrossBattlePrepare.OnPlayerNumChanged)
end
def.method().ShowDlg = function(self)
  self.leftTime = self:GetTime()
  if not self:IsShow() then
    self:CreatePanel(RESPATH.PREFAB_GANG_BATTLE_PREPARE, 0)
  end
end
def.method("=>", "number").GetTime = function(self)
  local left = 900
  local nowTime = GetServerTime()
  local actTime = GangCrossUtility.Instance():getActivityWeekBeginTime()
  if actTime > 0 and nowTime > actTime then
    local actIndex = GangCrossData.Instance():GetCompeteIndex()
    if actIndex >= constant.GangCrossConsts.MaxCompeteCountOfOneTime then
      actIndex = 1
    else
      actIndex = 0
    end
    local minutes = constant.GangCrossConsts.PrepareMinutes + constant.GangCrossConsts.FightMinutes + constant.GangCrossConsts.WaitForceEndMinutes + constant.GangCrossConsts.RestMinutes
    left = actTime + constant.GangCrossConsts.SignUpDays * 86400 + (constant.GangCrossConsts.MatchHours + constant.GangCrossConsts.MailRemindHours) * 3600 + (actIndex * minutes + constant.GangCrossConsts.WaitMinutes + constant.GangCrossConsts.PrepareMinutes) * 60 - nowTime
    left = left + constant.GangCrossConsts.ProtectedMinutes * 60
    if left < 0 then
      left = 0
    end
  end
  return left
end
def.method().ResetTime = function(self)
  self.leftTime = self:GetTime()
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(self.UpdateCountDown)
  Event.UnregisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.LEAVE_GANG_BATTLE_MAP, DlgGangCrossBattlePrepare.OnStatusChanged)
  Event.UnregisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Prepare_Player_Changed, DlgGangCrossBattlePrepare.OnPlayerNumChanged)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowInfo()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Watch" then
    self:onBtnExitClick()
  elseif id == "Btn_Cancel" then
    self:Hide()
  end
end
def.static("number", "table").SendExitReq = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crosscompete.CLeaveCrossCompeteMapReq").new())
  end
end
def.method().onBtnExitClick = function(self)
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.GangCross[36], constant.GangCrossConsts.ProtectedMinutes), DlgGangCrossBattlePrepare.SendExitReq, {})
end
def.method().ShowInfo = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self.m_panel:FindDirect("Img_Bg/Img_MovePower/Label_Num"):GetComponent("UILabel").text = tostring(GangCrossBattleMgr.Instance().actionPoint)
  self.m_panel:FindDirect("Img_Bg/Img_PersonNum/Label_Num"):GetComponent("UILabel").text = tostring(GangCrossBattleMgr.Instance().preparePlayerNum)
  local left = Seconds2HMSTime(self.leftTime)
  self.m_panel:FindDirect("Img_Bg/Img_LeftTime/Label_Num"):GetComponent("UILabel").text = string.format(textRes.Gang[214], left.m, left.s)
end
def.static("table", "table").OnPlayerNumChanged = function(p1, p2)
  if dlg.m_panel == nil or dlg.m_panel.isnil then
    return
  end
  dlg.m_panel:FindDirect("Img_Bg/Img_PersonNum/Label_Num"):GetComponent("UILabel").text = tostring(GangCrossBattleMgr.Instance().preparePlayerNum)
end
def.method("number").UpdateCountDown = function(self, tk)
  if self.leftTime <= 0 then
    return
  end
  self.leftTime = self.leftTime - tk
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local left = Seconds2HMSTime(self.leftTime)
  self.m_panel:FindDirect("Img_Bg/Img_LeftTime/Label_Num"):GetComponent("UILabel").text = string.format(textRes.Gang[214], left.m, left.s)
end
def.static("table", "table").OnStatusChanged = function(p1, p2)
  dlg:Hide()
end
DlgGangCrossBattlePrepare.Commit()
return DlgGangCrossBattlePrepare
