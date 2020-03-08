local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local PartnerTips = Lplus.Extend(ECPanelBase, "PartnerTips")
local def = PartnerTips.define
local inst
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
def.static("=>", PartnerTips).Instance = function()
  if inst == nil then
    inst = PartnerTips()
    inst:Init()
  end
  return inst
end
def.field("number")._partnerID = 0
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("number").ShowDlg = function(self, partnerID)
  self._partnerID = partnerID
  if self.m_panel == nil or self.m_panel.isnil then
    print("PartnerMain CreatePanel()")
    self:CreatePanel(RESPATH.PREFAB_UI_PARTNER_TIPS, 2)
    self:SetOutTouchDisappear()
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
  else
  end
end
def.method().Fill = function(self)
  local List = self.m_panel:FindDirect("Img_Bg/Scroll View/List")
  local list = List:GetComponent("UIList")
  local partnerCfg = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, self._partnerID)
  partnerCfg.name = record:GetStringValue("name")
  partnerCfg.LoveId = record:GetIntValue("LoveId")
  local loveCfg = PartnerInterface.GetPartnerLoveCfg(partnerCfg.LoveId)
  list.itemCount = #loveCfg.LoveId2Rate
  list:Resize()
  local Label_Title = self.m_panel:FindDirect("Img_Bg/Label_Title")
  Label_Title:GetComponent("UILabel"):set_text(string.format(textRes.Partner[30], partnerCfg.name))
  for k, v in pairs(loveCfg.LoveId2Rate) do
    local Group_Label = List:FindDirect(string.format("Group_Label_%d", k))
    local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_LOVE_DATA_CFG, v.loveId)
    local loveName = record:GetStringValue("loveName")
    local loveDes = record:GetStringValue("loveDes")
    local loveRank = record:GetIntValue("loveRank")
    local color = Color.Color(1, 1, 1, 1)
    if loveRank == 0 then
      color = Color.Color(constant.PartnerConstants.loveRankLowFontColorR / 255, constant.PartnerConstants.loveRankLowFontColorG / 255, constant.PartnerConstants.loveRankLowFontColorB / 255, 1)
    elseif loveRank == 1 then
      color = Color.Color(constant.PartnerConstants.loveRankNormalFontColorR / 255, constant.PartnerConstants.loveRankNormalFontColorG / 255, constant.PartnerConstants.loveRankNormalFontColorB / 255, 1)
    elseif loveRank == 2 then
      color = Color.Color(constant.PartnerConstants.loveRankHighFontColorR / 255, constant.PartnerConstants.loveRankHighFontColorG / 255, constant.PartnerConstants.loveRankHighFontColorB / 255, 1)
    end
    local Label_Name = Group_Label:FindDirect(string.format("Label_Name_%d", k))
    Label_Name:GetComponent("UILabel"):set_text(loveName)
    Label_Name:GetComponent("UILabel"):set_textColor(color)
    local Label_Content = Group_Label:FindDirect(string.format("Label_Content_%d", k))
    Label_Content:GetComponent("UILabel"):set_text(loveDes)
  end
end
PartnerTips.Commit()
return PartnerTips
