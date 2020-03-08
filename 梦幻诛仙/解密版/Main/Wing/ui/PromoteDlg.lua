local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PromoteDlg = Lplus.Extend(ECPanelBase, "PromoteDlg")
local WingModule = require("Main.Wing.WingModule")
local WingUtils = require("Main.Wing.WingUtils")
local WingModel = require("Main.Wing.ui.WingModel")
local def = PromoteDlg.define
local instance
def.static("=>", PromoteDlg).Instance = function()
  if instance == nil then
    instance = PromoteDlg()
  end
  return instance
end
def.const("number").STAYTIME = 3
def.const("table").Type = {SHENGJIE = 1, WUPIN = 2}
def.field("number").wingId = 0
def.field("string").desc = ""
def.field("string").desc2 = ""
def.field("table").wingModel = nil
def.field("number").createTime = 0
def.field("number").type = 0
def.static("number", "string", "number").ShowWingPromote = function(wingId, desc, type)
  local self = PromoteDlg.Instance()
  if self:IsShow() then
    return
  end
  self.type = type
  self.wingId = wingId
  self.desc = desc
  self.desc2 = ""
  self:CreatePanel(RESPATH.PANEL_WINGUPGRADE, 1)
  self:SetModal(true)
end
def.static("number", "string", "string", "number").ShowWingPromote2 = function(wingId, desc, desc2, type)
  local self = PromoteDlg.Instance()
  if self:IsShow() then
    return
  end
  self.type = type
  self.wingId = wingId
  self.desc = desc
  self.desc2 = desc2
  self:CreatePanel(RESPATH.PANEL_WINGUPGRADE, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.createTime = GetServerTime()
  self:UpdateTitle()
  self:UpdateWingModel()
  self:UpdateDesc()
end
def.override("boolean").OnShow = function(self, isShow)
end
def.override().OnDestroy = function(self)
  if self.wingModel then
    self.wingModel:Destroy()
    self.wingModel = nil
  end
  SafeLuckDog(function()
    return true
  end)
end
def.method().UpdateTitle = function(self)
  local title1 = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Title_UpgradeSuccess")
  local title2 = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Title_GetWing")
  if self.type == PromoteDlg.Type.SHENGJIE then
    title1:SetActive(true)
    title2:SetActive(false)
  elseif self.type == PromoteDlg.Type.WUPIN then
    title1:SetActive(false)
    title2:SetActive(true)
  else
    title1:SetActive(false)
    title2:SetActive(false)
  end
end
def.method().UpdateWingModel = function(self)
  local uiModel = self.m_panel:FindDirect("Img_Bg0/WingModel")
  local uiModelCmp = uiModel:GetComponent("UIModel")
  local wingData = WingModule.Instance():GetWingData()
  local wingInfo = wingData:GetWingByWingId(self.wingId)
  local wingCfg = WingUtils.GetWingCfg(self.wingId)
  self.wingModel = WingModel()
  self.wingModel:Create(wingCfg.outlook, wingInfo and wingInfo.colorId or 0, function()
    if uiModelCmp.isnil then
      return
    end
    uiModelCmp.mCanOverflow = true
    local camera = uiModelCmp:get_modelCamera()
    camera:set_orthographic(true)
    uiModelCmp.modelGameObject = self.wingModel:GetModelGameObject()
  end)
end
def.method().UpdateDesc = function(self)
  local descLbl = self.m_panel:FindDirect("Img_Bg0/Label_Middle")
  local descLblLeft = self.m_panel:FindDirect("Img_Bg0/Label_Left")
  local descLblRight = self.m_panel:FindDirect("Img_Bg0/Label_Right")
  if self.desc2 == "" then
    descLbl:SetActive(true)
    descLbl:GetComponent("UILabel"):set_text(self.desc)
    descLblLeft:SetActive(false)
    descLblRight:SetActive(false)
  else
    descLbl:SetActive(false)
    descLblLeft:SetActive(true)
    descLblLeft:GetComponent("UILabel"):set_text(self.desc)
    descLblRight:SetActive(true)
    descLblRight:GetComponent("UILabel"):set_text(self.desc2)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Modal" then
    local curTime = GetServerTime()
    if curTime - self.createTime > PromoteDlg.STAYTIME then
      self:DestroyPanel()
    end
  end
end
return PromoteDlg.Commit()
