local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonCountDown = Lplus.Extend(ECPanelBase, "CommonCountDown")
local def = CommonCountDown.define
local instance
def.field("number").time = -1
def.field("boolean").simple = false
def.static("number").Start = function(t)
  CommonCountDown.Instance().simple = false
  CommonCountDown.Instance():ShowDlg(t)
end
def.static("number").StartSimple = function(t)
  CommonCountDown.Instance().simple = true
  CommonCountDown.Instance():ShowDlg(t)
end
def.static().End = function()
  CommonCountDown.Instance():HideDlg()
end
def.static("=>", CommonCountDown).Instance = function()
  if instance == nil then
    instance = CommonCountDown()
  end
  return instance
end
def.method("number").ShowDlg = function(self, time)
  self.time = time
  if self:IsShow() then
    return
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_COUNTDOWN, 0)
  end
  Timer:RegisterListener(self.Update, self)
end
def.method().HideDlg = function(self)
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.m_panel:FindDirect("Label"):GetComponent("UILabel").text = tostring(self.time)
  self.m_panel:SetActive(true)
  if self.simple then
    self.m_panel:FindDirect("Group_Slider"):SetActive(false)
  end
end
def.method("number").Update = function(self, tick)
  self.time = self.time - 1
  if self.m_panel == nil then
    return
  end
  if self.time < 0 then
    self:HideDlg()
  else
    self.m_panel:FindDirect("Label"):GetComponent("UILabel").text = tostring(self.time)
  end
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(self.Update)
end
CommonCountDown.Commit()
return CommonCountDown
