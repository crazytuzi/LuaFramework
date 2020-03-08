local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SurveyDlg = Lplus.Extend(ECPanelBase, "SurveyDlg")
local Vector = require("Types.Vector")
local GuideModule = Lplus.ForwardDeclare("GuideModule")
local def = SurveyDlg.define
def.field("function").callback = nil
def.field("number").cfgId = 0
def.static("number", "function").ShowSurvey = function(cfgId, cb)
  local dlg = SurveyDlg()
  dlg.cfgId = cfgId
  dlg.callback = cb
  dlg:CreatePanel(RESPATH.PREFAB_SURVEY, 0)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  require("GUI.ECGUIMan").Instance():LockUI(false)
  gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_1" then
    self.callback(self.cfgId, 0)
    self:DestroyPanel()
  elseif id == "Btn_2" then
    self.callback(self.cfgId, 1)
    self:DestroyPanel()
  end
end
SurveyDlg.Commit()
return SurveyDlg
