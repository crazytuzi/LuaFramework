local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangBattleMgr = require("Main.Gang.GangBattleMgr")
local GangData = require("Main.Gang.data.GangData")
local DlgGangBattle = Lplus.Extend(ECPanelBase, "DlgGangBattle")
local GUIUtils = require("GUI.GUIUtils")
local def = DlgGangBattle.define
local dlg
def.field("number").safeTime = 0
def.static("=>", DlgGangBattle).Instance = function()
  if dlg == nil then
    dlg = DlgGangBattle()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Timer:RegisterListener(self.UpdateCountDown, self)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Battle_Info_Changed, DlgGangBattle.OnBattleInfoChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.LEAVE_GANG_BATTLE_MAP, DlgGangBattle.OnStatusChanged)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgGangBattle.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgGangBattle.OnLeaveFight)
end
def.method().ShowDlg = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_GANG_BATTLE, 0)
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(self.UpdateCountDown)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgGangBattle.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgGangBattle.OnLeaveFight)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Battle_Info_Changed, DlgGangBattle.OnBattleInfoChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.LEAVE_GANG_BATTLE_MAP, DlgGangBattle.OnStatusChanged)
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
  if id == "Btn_Confirm" then
    self:Hide()
  elseif id == "Btn_Cancel" then
    self:Hide()
  end
end
def.method().SetActionPoint = function(self)
  if self.m_panel then
    self.m_panel:FindDirect("Img_Bg/Img_MovePower/Label_Num"):GetComponent("UILabel").text = tostring(GangBattleMgr.Instance().actionPoint)
  end
end
def.method().SetBattleInfo = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local infoPanel = self.m_panel:FindDirect("Img_Bg/Img_FightMember")
  local infos = GangBattleMgr.Instance().gangBattleInfo
  if infos == nil then
    infoPanel:SetActive(false)
    return
  end
  infoPanel:SetActive(true)
  local panel = infoPanel:FindDirect("Group_Label")
  for _, v in pairs(infos) do
    if v.data.factionid:eq(GangData.Instance().gangId) then
      panel:FindDirect("Label_Code"):GetComponent("UILabel").text = tostring(v.data.pk_score + v.data.player_score + v.data.mercenary_score)
      panel:FindDirect("Label_Num"):GetComponent("UILabel").text = tostring(v.data.player_number)
      panel:FindDirect("Label_Name"):GetComponent("UILabel").text = v.name or ""
    else
      panel:FindDirect("Label_TargetCode"):GetComponent("UILabel").text = tostring(v.data.pk_score + v.data.player_score + v.data.mercenary_score)
      panel:FindDirect("Label_TargetNum"):GetComponent("UILabel").text = tostring(v.data.player_number)
      panel:FindDirect("Label_TargetName"):GetComponent("UILabel").text = v.name or ""
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
DlgGangBattle.Commit()
return DlgGangBattle
