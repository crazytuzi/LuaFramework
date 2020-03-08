local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QixiInstruction = Lplus.Extend(ECPanelBase, "QixiInstruction")
local def = QixiInstruction.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
def.static("=>", QixiInstruction).Instance = function()
  if dlg == nil then
    dlg = QixiInstruction()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_QIXI_INSTRUCTION, 1)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local cfg = gmodule.moduleMgr:GetModule(ModuleId.QIXI):GetActivityCfg(constant.QixiConsts.activityId)
  if cfg == nil then
    return
  end
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(cfg.ruleId)
  self.m_panel:FindDirect("Img_Bg0/Group_Right/Img_Bg_R/Scroll View/Label"):GetComponent("UILabel").text = tipContent
  local isCaptain = require("Main.Team.TeamData").Instance():MeIsCaptain()
  self.m_panel:FindDirect("Img_Bg0/Btn_Start"):SetActive(isCaptain)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, QixiInstruction.OnEnterFight)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, QixiInstruction.OnEnterFight)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if dlg.m_panel then
    dlg:Hide()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Start" then
    if not require("Main.Team.TeamData").Instance():MeIsCaptain() then
      Toast(textRes.Team[61])
      return
    end
    self:Hide()
    local pro = require("netio.protocol.mzm.gsp.chinesevalentine.CChineseValentineJoinReq").new(constant.QixiConsts.activityId)
    gmodule.network.sendProtocol(pro)
  elseif id == "Bth_Close" then
    self:Hide()
  end
end
QixiInstruction.Commit()
return QixiInstruction
