local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DrawLucky = Lplus.Extend(ECPanelBase, "DrawLucky")
local GUIUtils = require("GUI.GUIUtils")
local def = DrawLucky.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = DrawLucky()
  end
  return _instance
end
def.field("string").name = ""
def.field("boolean").result = false
def.field("boolean").drawed = false
def.static("boolean", "string").ShowDrawLucky = function(result, name)
  local dlg = DrawLucky.Instance()
  dlg.result = result
  dlg.name = name
  dlg.drawed = false
  if dlg:IsShow() then
    dlg:Update()
  else
    dlg:CreatePanel(RESPATH.PREFAB_DRAWLUCKY, 1)
  end
end
def.override().OnCreate = function(self)
  self:Update()
end
def.override().OnDestroy = function(self)
end
def.method().Update = function(self)
  local lbl1 = self.m_panel:FindDirect("Img_Bg/Label_1")
  local lbl2 = self.m_panel:FindDirect("Img_Bg/Label_2")
  local name = self.m_panel:FindDirect("Img_Bg/Label_Name")
  if self.result then
    lbl1:SetActive(false)
    lbl2:SetActive(true)
    name:SetActive(true)
    name:GetComponent("UILabel"):set_text(self.name)
  else
    lbl1:SetActive(true)
    lbl2:SetActive(false)
    name:SetActive(false)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_Tree" then
    if not self.result and not self.drawed then
      require("Main.Marriage.MultiWeddingMgr").Instance():DrawLuckyGuy()
      self.drawed = true
    else
      Toast(textRes.Marriage[121])
    end
  end
end
DrawLucky.Commit()
return DrawLucky
