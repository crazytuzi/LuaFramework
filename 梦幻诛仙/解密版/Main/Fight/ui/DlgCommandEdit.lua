local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgCommandEdit = Lplus.Extend(ECPanelBase, "DlgCommandEdit")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local GUIUtils = require("GUI.GUIUtils")
local def = DlgCommandEdit.define
local dlg
def.field("number").cmdType = 0
def.field("number").editIdx = 0
def.static("=>", DlgCommandEdit).Instance = function()
  if dlg == nil then
    dlg = DlgCommandEdit()
  end
  return dlg
end
def.override().OnCreate = function(self)
end
def.method("number", "number").ShowDlg = function(self, cmdType, idx)
  self.cmdType = cmdType
  self.editIdx = idx
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.COMMON_RENAME_PANEL_RES, 2)
end
def.override().OnDestroy = function(self)
end
def.static("table", "table").OnCloseSecondLevelUI = function()
  dlg:Hide()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.m_panel:FindDirect("Img_Bg0/Img_Correct"):SetActive(false)
  self.m_panel:FindDirect("Img_Bg0/Img_Wrong"):SetActive(false)
  self.m_panel:FindDirect("Img_Bg0/Label_NameCount"):SetActive(false)
  local input = self.m_panel:FindDirect("Img_Bg0/Img_BgInput"):GetComponent("UIInput")
  self.m_panel:FindDirect("Img_Bg0/Label_Tips"):GetComponent("UILabel").text = textRes.PVP[2]
  self.m_panel:FindDirect("Img_Bg0/Img_BgInput/Label_Input"):GetComponent("UILabel").text = textRes.PVP[3]
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    local v = self.m_panel:FindDirect("Img_Bg0/Img_BgInput"):GetComponent("UIInput").value
    v = string.trim(v)
    local _, count = string.gsub(v, "[^\128-\193]", "")
    if count > 4 then
      Toast(textRes.Fight[53])
      return
    end
    if v == "" then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CDelCommandReq").new(self.cmdType, self.editIdx))
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CChangeCommandReq").new(self.cmdType, self.editIdx, v))
    end
    self:Hide()
  elseif id == "Btn_Cancel" then
    self:Hide()
  end
end
DlgCommandEdit.Commit()
return DlgCommandEdit
