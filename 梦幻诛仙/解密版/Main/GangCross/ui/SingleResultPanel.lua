local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local SingleResultPanel = Lplus.Extend(ECPanelBase, "SingleResultPanel")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local def = SingleResultPanel.define
local instance
def.field("table").uiTbl = nil
def.field("number").actTime = 0
def.field("number").actIndex = 0
def.field("table").showInfo = nil
def.static("=>", SingleResultPanel).Instance = function()
  if not instance then
    instance = SingleResultPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, info)
  self.showInfo = info
  if self:IsShow() then
    self:UpdateUI()
    return
  end
  local resPath = RESPATH.PREFAB_CROSS_RESULT2
  local prefab = GameUtil.SyncLoad(resPath)
  self.m_SyncLoad = true
  self:CreatePanel(resPath, -1)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local DescLabel = Img_Bg:FindDirect("Label")
  local WinLabel = Img_Bg:FindDirect("Group_Info/Group_Win/Label_Win")
  local LossLabel = Img_Bg:FindDirect("Group_Info/Group_Lose/Label_Lose")
  uiTbl.WinLabel = WinLabel
  uiTbl.LossLabel = LossLabel
  uiTbl.DescLabel = DescLabel
end
def.method().Reset = function(self)
end
def.method().UpdateUI = function(self)
  local uiTbl = self.uiTbl
  local showInfo = self.showInfo
  if showInfo then
    uiTbl.WinLabel:GetComponent("UILabel"):set_text(showInfo.win or "0")
    uiTbl.LossLabel:GetComponent("UILabel"):set_text(showInfo.loss or "0")
    uiTbl.DescLabel:GetComponent("UILabel"):set_text(showInfo.desc or "")
  end
end
def.method().HidePanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
end
return SingleResultPanel.Commit()
