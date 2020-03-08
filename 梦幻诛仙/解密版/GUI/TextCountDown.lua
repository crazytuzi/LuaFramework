local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TextCountDown = Lplus.Extend(ECPanelBase, "TextCountDown")
local def = TextCountDown.define
local instance
def.static("number", "string", "=>", TextCountDown).Start = function(t, title)
  local dlg = TextCountDown()
  dlg:ShowDlg(t, title)
  return dlg
end
def.field("number").time = -1
def.field("string").title = ""
def.method("number", "string").ShowDlg = function(self, time, title)
  if self:IsShow() then
    return
  else
    self.time = time
    self.title = title
    self:CreatePanel(RESPATH.PREFAB_COMMON_TEXT_COUNTDOWN, 0)
    Timer:RegisterListener(self.Update, self)
  end
end
def.method().HideDlg = function(self)
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.m_panel:FindDirect("Img_Bg/Label_Title"):GetComponent("UILabel").text = self.title
  self.m_panel:FindDirect("Img_Bg/Group_Time/Label_Time"):GetComponent("UILabel").text = tostring(self.time) .. textRes.Common.Second
  self.m_panel:SetActive(true)
end
def.method("number").Update = function(self, tick)
  self.time = self.time - 1
  if self.m_panel == nil then
    return
  end
  if self.time < 0 then
    self:HideDlg()
  else
    self.m_panel:FindDirect("Img_Bg/Group_Time/Label_Time"):GetComponent("UILabel").text = tostring(self.time) .. textRes.Common.Second
  end
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(self.Update)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
TextCountDown.Commit()
return TextCountDown
