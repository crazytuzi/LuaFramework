local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DouDouClearResultDlg = Lplus.Extend(ECPanelBase, "DouDouClearResultDlg")
local def = DouDouClearResultDlg.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = DouDouClearResultDlg()
  end
  return _instance
end
def.field("table").totalSocre = nil
def.field("table").otherSocres = nil
def.static("table", "table").ShowDouDouClearResultDlg = function(totalSocre, otherSocres)
  local dlg = DouDouClearResultDlg.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.totalSocre = totalSocre
  dlg.otherSocres = otherSocres
  dlg:CreatePanel(RESPATH.PREFAB_DOUDOU_CLEAR_RESUTL, 1)
end
def.static().Close = function()
  local dlg = DouDouClearResultDlg.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  self:FillTotoalScore()
  self:FillOtherScores()
end
def.override().OnDestroy = function(self)
end
def.method().FillTotoalScore = function(self)
  local totalGroup = self.m_panel:FindDirect("Label_Score")
  self:FillOneScore(totalGroup, self.totalSocre)
end
def.method().FillOtherScores = function(self)
  local list = self.m_panel:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  listCmp.itemCount = #self.otherSocres
  listCmp:Resize()
  local itemChildren = listCmp:get_children()
  for i = 1, #itemChildren do
    local item = itemChildren[i]
    local info = self.otherSocres[i]
    self:FillOneScore(item, info)
  end
end
def.method("userdata", "table").FillOneScore = function(self, go, info)
  if go then
    if info and info.name and info.score then
      local nameLbl = go:FindDirect("Label_Name")
      local scoreLbl = go:FindDirect("Label_Num")
      nameLbl:GetComponent("UILabel"):set_text(info.name)
      scoreLbl:GetComponent("UILabel"):set_text(tostring(info.score))
    else
      go:SetActive(false)
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
DouDouClearResultDlg.Commit()
return DouDouClearResultDlg
