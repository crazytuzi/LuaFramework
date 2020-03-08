local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GangCrossLoadingPanel = Lplus.Extend(ECPanelBase, "GangCrossLoadingPanel")
local GangCrossUtility = require("Main.GangCross.GangCrossUtility")
local def = GangCrossLoadingPanel.define
local instance
def.field("table").uiTbl = nil
def.field("table").gangInfo = nil
def.field("number").curProgress = 0
def.field("number").maxProgress = 1
def.static("=>", GangCrossLoadingPanel).Instance = function()
  if not instance then
    instance = GangCrossLoadingPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, gangInfo)
  self.gangInfo = gangInfo
  if self:IsShow() then
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CROSS_LOADING, -1)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
  else
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  do
    local Group_RedName = self.m_panel:FindDirect("Group_RedName")
    local Label_ServerName = Group_RedName:FindDirect("Label_ServerName")
    local Label_ServerLv = Group_RedName:FindDirect("Group_Server/Label_ServerLv")
    local Label_CampLv = Group_RedName:FindDirect("Group_CampLv/Label_CampLv")
    local Label_CampNum = Group_RedName:FindDirect("Group_CampNum/Label_CampNum")
    local Label_TitleName = Group_RedName:FindDirect("Label_TitleName")
    uiTbl.GroupRed = {
      Label_ServerName = Label_ServerName,
      Label_ServerLv = Label_ServerLv,
      Label_CampLv = Label_CampLv,
      Label_CampNum = Label_CampNum,
      Label_TitleName = Label_TitleName
    }
  end
  do
    local Group_BlueName = self.m_panel:FindDirect("Group_BlueName")
    local Label_ServerName = Group_BlueName:FindDirect("Label_ServerName")
    local Label_ServerLv = Group_BlueName:FindDirect("Group_Server/Label_ServerLv")
    local Label_CampLv = Group_BlueName:FindDirect("Group_CampLv/Label_CampLv")
    local Label_CampNum = Group_BlueName:FindDirect("Group_CampNum/Label_CampNum")
    local Label_TitleName = Group_BlueName:FindDirect("Label_TitleName")
    uiTbl.GroupBlue = {
      Label_ServerName = Label_ServerName,
      Label_ServerLv = Label_ServerLv,
      Label_CampLv = Label_CampLv,
      Label_CampNum = Label_CampNum,
      Label_TitleName = Label_TitleName
    }
  end
  local Group_Slider = self.m_panel:FindDirect("Group_Slider")
  local Img_BgSlider = Group_Slider:FindDirect("Img_BgSlider")
  uiTbl.Img_BgSlider = Img_BgSlider
  local uiProgress = Img_BgSlider:GetComponent("UIProgressBar")
  uiProgress.value = 0
  Img_BgSlider:SetActive(false)
end
def.method().Reset = function(self)
end
def.method("table", "table").ShowGangInfo = function(self, uiTbl, infoTbl)
  local Label_ServerName = uiTbl.Label_ServerName
  local Label_ServerLv = uiTbl.Label_ServerLv
  local Label_CampLv = uiTbl.Label_CampLv
  local Label_CampNum = uiTbl.Label_CampNum
  local Label_TitleName = uiTbl.Label_TitleName
  Label_ServerName:GetComponent("UILabel"):set_text(infoTbl.svrname)
  Label_ServerLv:GetComponent("UILabel"):set_text(infoTbl.svrlv)
  Label_CampLv:GetComponent("UILabel"):set_text(infoTbl.ganglv)
  Label_CampNum:GetComponent("UILabel"):set_text(infoTbl.gangnum)
  Label_TitleName:GetComponent("UILabel"):set_text(infoTbl.gangname)
end
def.method().UpdateUI = function(self)
  local uiTbl = self.uiTbl
  local gangInfo = self.gangInfo
  if gangInfo then
    self:ShowGangInfo(uiTbl.GroupRed, gangInfo.red)
    self:ShowGangInfo(uiTbl.GroupBlue, gangInfo.blue)
  end
end
def.method("number").UpdateTime = function(self, dt)
  if self.curProgress < self.maxProgress then
    self.curProgress = self.curProgress + 0.1
    if self.curProgress > self.maxProgress then
      self.curProgress = self.maxProgress
    end
    local Img_BgSlider = self.uiTbl.Img_BgSlider
    local uiProgress = Img_BgSlider:GetComponent("UIProgressBar")
    uiProgress.value = self.curProgress
  end
end
def.method().HidePanel = function(self)
  warn("=======================================GangCrossLoadingPanel.HidePanel 0")
  if self.m_panel then
    warn("=======================================GangCrossLoadingPanel.HidePanel 1")
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
end
return GangCrossLoadingPanel.Commit()
