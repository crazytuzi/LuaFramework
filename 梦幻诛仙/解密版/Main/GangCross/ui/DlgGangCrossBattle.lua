local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangCrossBattleMgr = require("Main.GangCross.GangCrossBattleMgr")
local GangCrossData = require("Main.GangCross.data.GangCrossData")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local DlgGangCrossBattle = Lplus.Extend(ECPanelBase, "DlgGangCrossBattle")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GUIUtils = require("GUI.GUIUtils")
local def = DlgGangCrossBattle.define
local dlg
def.field("number").safeTime = 0
def.static("=>", DlgGangCrossBattle).Instance = function()
  if dlg == nil then
    dlg = DlgGangCrossBattle()
  end
  return dlg
end
def.override().OnCreate = function(self)
  self.m_panel:FindDirect("Img_Bg/Btn_Quit"):SetActive(true)
  Timer:RegisterListener(self.UpdateCountDown, self)
  Event.RegisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Info_Changed, DlgGangCrossBattle.OnBattleInfoChanged)
  Event.RegisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.LEAVE_GANG_BATTLE_MAP, DlgGangCrossBattle.OnStatusChanged)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgGangCrossBattle.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgGangCrossBattle.OnLeaveFight)
end
def.method().ShowDlg = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_GANGCROSS_BATTLE, 0)
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(self.UpdateCountDown)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgGangCrossBattle.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgGangCrossBattle.OnLeaveFight)
  Event.UnregisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.Gang_Battle_Info_Changed, DlgGangCrossBattle.OnBattleInfoChanged)
  Event.UnregisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.LEAVE_GANG_BATTLE_MAP, DlgGangCrossBattle.OnStatusChanged)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:SetActionPoint()
  self:SetBattleInfo()
  self:SetProtectTime(0)
  if require("Main.Fight.FightMgr").Instance().isInFight and self.m_panel then
    self.m_panel:SetActive(false)
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if dlg.m_panel then
    dlg.m_panel:SetActive(false)
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if dlg.m_panel then
    dlg.m_panel:SetActive(true)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Quit" then
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
  CommonConfirmDlg.ShowConfirm("", textRes.GangCross[21], DlgGangCrossBattle.SendExitReq, {})
end
def.method().SetActionPoint = function(self)
  if self.m_panel then
    self.m_panel:FindDirect("Img_Bg/Img_MovePower/Label_Num"):GetComponent("UILabel").text = tostring(GangCrossBattleMgr.Instance().actionPoint)
  end
end
def.method().SetBattleInfo = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local infoPanel = self.m_panel:FindDirect("Img_Bg/Img_FightMember")
  local infos = GangCrossBattleMgr.Instance().gangBattleInfo
  if infos == nil then
    infoPanel:SetActive(false)
    return
  end
  infoPanel:SetActive(true)
  local panel = infoPanel:FindDirect("Group_Label")
  for _, v in pairs(infos) do
    if v.data.factionid:eq(GangCrossData.Instance().gangId) then
      local svrName = GangCrossUtility.Instance():GetSvrNameForGangId(v.data.factionid)
      local name = v.name .. "-" .. svrName
      panel:FindDirect("Label_Code"):GetComponent("UILabel").text = tostring(v.data.pk_score + v.data.player_score + v.data.mercenary_score)
      panel:FindDirect("Label_Num"):GetComponent("UILabel").text = tostring(v.data.player_number)
      panel:FindDirect("Label_Name"):GetComponent("UILabel").text = name or ""
    else
      local svrName = GangCrossUtility.Instance():GetSvrNameForGangId(v.data.factionid)
      local name = v.name .. "-" .. svrName
      panel:FindDirect("Label_TargetCode"):GetComponent("UILabel").text = tostring(v.data.pk_score + v.data.player_score + v.data.mercenary_score)
      panel:FindDirect("Label_TargetNum"):GetComponent("UILabel").text = tostring(v.data.player_number)
      panel:FindDirect("Label_TargetName"):GetComponent("UILabel").text = name or ""
    end
  end
end
def.method("number").SetProtectTime = function(self, t)
  self.safeTime = t
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if t > 0 then
    self.m_panel:FindDirect("Img_Bg/Group_ProtectTime/Label_LeftTime"):GetComponent("UILabel").text = tostring(self.safeTime) .. "S"
  end
  self.m_panel:FindDirect("Img_Bg/Group_ProtectTime"):SetActive(t > 0)
end
def.method("number").UpdateCountDown = function(self, tk)
  if self.safeTime <= 0 or self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self.safeTime = self.safeTime - tk
  self.m_panel:FindDirect("Img_Bg/Group_ProtectTime/Label_LeftTime"):GetComponent("UILabel").text = tostring(self.safeTime) .. "S"
  if self.safeTime == 0 then
    self.m_panel:FindDirect("Img_Bg/Group_ProtectTime"):SetActive(false)
  end
end
def.static("table", "table").OnBattleInfoChanged = function(p1, p2)
  dlg:SetBattleInfo()
end
def.static("table", "table").OnStatusChanged = function(p1, p2)
  dlg:Hide()
end
DlgGangCrossBattle.Commit()
return DlgGangCrossBattle
