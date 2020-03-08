local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgRobWedding = Lplus.Extend(ECPanelBase, "DlgRobWedding")
local MarriageConsts = require("netio.protocol.mzm.gsp.marriage.MarriageConsts")
local def = DlgRobWedding.define
local dlg
def.static("=>", DlgRobWedding).Instance = function()
  if dlg == nil then
    dlg = DlgRobWedding()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_ROB_WEDDING, 0)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  if _G.PlayerIsInFight() then
    self:Hide()
    return
  end
  local attackInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetParadeAttackInfo()
  if attackInfo == nil then
    self.m_panel:FindDirect("Img_0/Group_Couple/Item_Husband/Img_Done"):SetActive(false)
    self.m_panel:FindDirect("Img_0/Group_Couple/Item_Wife/Img_Done"):SetActive(false)
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.marriage.CMarrageParadeAttackReq").new(MarriageConsts.GROOM))
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.marriage.CMarrageParadeAttackReq").new(MarriageConsts.BRIDE))
  else
    self.m_panel:FindDirect("Img_0/Group_Couple/Item_Husband/Img_Done"):SetActive(attackInfo[MarriageConsts.GROOM] == MarriageConsts.ATTACKED)
    self.m_panel:FindDirect("Img_0/Group_Couple/Item_Wife/Img_Done"):SetActive(attackInfo[MarriageConsts.BRIDE] == MarriageConsts.ATTACKED)
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgRobWedding.OnEnterFight)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.PARADE_ATTACK_STATE_CHANGED, DlgRobWedding.UpdateAttackState)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgRobWedding.OnEnterFight)
  Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.PARADE_ATTACK_STATE_CHANGED, DlgRobWedding.UpdateAttackState)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  dlg:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Wife" then
    local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    if pubMgr:IsInFollowState(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) == true then
      Toast(textRes.Hero[46])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.marriage.CParadeAttackBrideReq").new())
  elseif id == "Btn_Husband" then
    local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    if pubMgr:IsInFollowState(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) == true then
      Toast(textRes.Hero[46])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.marriage.CParadeAttackGroomReq").new())
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.static("table", "table").UpdateAttackState = function(p1, p2)
  local attackInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetParadeAttackInfo()
  if attackInfo then
    dlg.m_panel:FindDirect("Img_0/Group_Couple/Item_Husband/Img_Done"):SetActive(attackInfo[MarriageConsts.GROOM] == MarriageConsts.ATTACKED)
    dlg.m_panel:FindDirect("Img_0/Group_Couple/Item_Wife/Img_Done"):SetActive(attackInfo[MarriageConsts.BRIDE] == MarriageConsts.ATTACKED)
  end
end
DlgRobWedding.Commit()
return DlgRobWedding
