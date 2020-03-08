local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SelectCoupleDlg = Lplus.Extend(ECPanelBase, "SelectCoupleDlg")
local GUIUtils = require("GUI.GUIUtils")
local def = SelectCoupleDlg.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = SelectCoupleDlg()
  end
  return _instance
end
def.field("table").couples = nil
def.field("function").callback = nil
def.static("table", "function").ShowSelectCoupleDlg = function(cps, callback)
  if cps == nil then
    return
  end
  local dlg = SelectCoupleDlg.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.couples = cps
  dlg.callback = callback
  dlg:CreatePanel(RESPATH.PREFAB_CHOOSECOUPLE, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self:FillCouples()
end
def.method().FillCouples = function(self)
  local grid = self.m_panel:FindDirect("Img_Bg0/Grid")
  local count = grid:get_childCount()
  for i = 1, count do
    local go = grid:GetChild(i - 1)
    local info = self.couples[i]
    if info then
      go:SetActive(true)
      local name1 = go:FindDirect("Label_Name1")
      local name2 = go:FindDirect("Label_Name2")
      name1:GetComponent("UILabel"):set_text(info.man)
      name2:GetComponent("UILabel"):set_text(info.women)
    else
      go:SetActive(false)
    end
  end
end
def.method("number").DoCallback = function(self, param)
  if self.callback then
    self.callback(param)
  end
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  warn("onClick", id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 7) == "Couple_" then
    local index = tonumber(string.sub(id, 8))
    if index then
      local info = self.couples[index]
      if info then
        self:DoCallback(info.id)
      end
    end
  end
end
SelectCoupleDlg.Commit()
return SelectCoupleDlg
