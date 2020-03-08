local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgGangCrossBattleCmd = Lplus.Extend(ECPanelBase, "DlgGangCrossBattleCmd")
local GUIUtils = require("GUI.GUIUtils")
local GangCrossData = require("Main.GangCross.data.GangCrossData")
local def = DlgGangCrossBattleCmd.define
local dlg
def.field("table").roleInfo = nil
def.static("=>", DlgGangCrossBattleCmd).Instance = function()
  if dlg == nil then
    dlg = DlgGangCrossBattleCmd()
  end
  return dlg
end
def.method("table").ShowDlg = function(self, roleInfo)
  self.roleInfo = roleInfo
  if self:IsShow() then
    self:ShowInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_GANG_BATTLE_HEADMENU, 2)
    self:SetOutTouchDisappear()
  end
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
  if self.roleInfo == nil then
    return
  end
  if id == "Btn_PK" then
    local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(self.roleInfo.roleId)
    local myrole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
    if role and role:IsInState(RoleState.BATTLE) then
      Toast(textRes.Gang[217])
      return
    elseif role and role:IsInState(RoleState.PROTECTED) then
      Toast(textRes.Gang[218])
      return
    elseif myrole:IsInState(RoleState.PROTECTED) then
      Toast(textRes.Gang[220])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crosscompete.CAttackReq").new(self.roleInfo.roleId))
  elseif id == "Btn_Watch" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CObserveFightReq").new(self.roleInfo.roleId))
  end
  self:Hide()
end
def.method().ShowInfo = function(self)
  if self.m_panel == nil or self.roleInfo == nil then
    return
  end
  self.m_panel:FindDirect("Label_Name"):GetComponent("UILabel").text = self.roleInfo.name
  self.m_panel:FindDirect("Img_Frame/Label_Lv"):GetComponent("UILabel").text = self.roleInfo.level
  local myGangId = GangCrossData.Instance().gangId
  if myGangId == nil then
    warn("[DlgGangCrossBattleCmd]MyGangId is nil when show target info")
  end
  if myGangId and self.roleInfo.gangId:eq(myGangId) then
    local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(self.roleInfo.roleId)
    if role:IsInState(RoleState.BATTLE) then
      self.m_panel:FindDirect("Btn_PK"):SetActive(false)
      self.m_panel:FindDirect("Btn_Watch"):SetActive(true)
    else
      self.m_panel:FindDirect("Btn_PK"):SetActive(false)
      self.m_panel:FindDirect("Btn_Watch"):SetActive(false)
    end
  else
    self.m_panel:FindDirect("Btn_PK"):SetActive(true)
    self.m_panel:FindDirect("Btn_Watch"):SetActive(false)
  end
  local uiSprite = self.m_panel:FindDirect("Img_Frame/Img_Icon"):GetComponent("UISprite")
  uiSprite.spriteName = GUIUtils.GetHeadSpriteName(self.roleInfo.occupationId, self.roleInfo.gender)
end
DlgGangCrossBattleCmd.Commit()
return DlgGangCrossBattleCmd
