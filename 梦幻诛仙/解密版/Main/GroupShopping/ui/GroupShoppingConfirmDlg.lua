local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GroupShoppingConfirmDlg = Lplus.Extend(ECPanelBase, "GroupShoppingConfirmDlg")
local def = GroupShoppingConfirmDlg.define
def.field("string").m_title = ""
def.field("string").m_content = ""
def.field("function").m_callback = nil
local instance
def.static("=>", GroupShoppingConfirmDlg).Instance = function()
  if instance == nil then
    instance = GroupShoppingConfirmDlg()
  end
  return instance
end
def.static("string", "string", "function").ShowConfirm = function(title, content, callback)
  local dlg = GroupShoppingConfirmDlg.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.m_title = title
  dlg.m_content = content
  dlg.m_callback = callback
  dlg:CreatePanel(RESPATH.PREFAB_GROUP_SHOPPING_CONFIRM, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GroupShoppingConfirmDlg.OnFeatureChange, self)
  local titleLbl = self.m_panel:FindDirect("Img_0/Label_Title")
  titleLbl:GetComponent("UILabel"):set_text(self.m_title)
  local cntLbl = self.m_panel:FindDirect("Img_0/Group_Content/Label_Info")
  cntLbl:GetComponent("UILabel"):set_text(self.m_content)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GroupShoppingConfirmDlg.OnFeatureChange)
  self.m_title = ""
  self.m_content = ""
  self.m_callback = nil
end
def.method("table").OnFeatureChange = function(self, params)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING and params.open == false then
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    local callback = self.m_callback
    self:DestroyPanel()
    if callback then
      callback(false)
    end
  elseif id == "Label_Rule" then
    require("GUI.GUIUtils").ShowHoverTip(constant.CGroupShoppingConsts.DESCRIPTION_TIP_ID, 0, 0)
  elseif id == "Btn_Confirm" then
    local callback = self.m_callback
    self:DestroyPanel()
    if callback then
      callback(true)
    end
  end
end
GroupShoppingConfirmDlg.Commit()
return GroupShoppingConfirmDlg
