local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local ECMSDK = require("ProxySDK.ECMSDK")
local QQVIPWellFarePanel = Lplus.Extend(ECPanelBase, "QQVIPWellFarePanel")
local def = QQVIPWellFarePanel.define
def.field("number").m_SubPage = 1
def.field("table").m_UIGO = nil
local instance
def.static("=>", QQVIPWellFarePanel).Instance = function()
  if not instance then
    instance = QQVIPWellFarePanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, subPage)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_SubPage = subPage
  self:CreatePanel(RESPATH.PREFAB_QQVIP_WELLFARE_PANEL, GUILEVEL.NORMAL)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateSubPage()
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.QQVIPCharge, QQVIPWellFarePanel.OnQQVIPCharge)
  self.m_bCanMoveBackward = true
end
def.override().OnDestroy = function(self)
  self.m_SubPage = 1
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.QQVIPCharge, QQVIPWellFarePanel.OnQQVIPCharge)
end
def.static("table", "table").OnQQVIPCharge = function(p1, p2)
  warn("QQVIPWellFarePanel QQVIPCharge")
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateSubPage()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Tap_Svip" then
    self.m_SubPage = 2
    self:UpdateSubPage()
  elseif id == "Tap_Vip" then
    self.m_SubPage = 1
    self:UpdateSubPage()
  elseif id == "Btn_OpenSVip" then
    ECMSDK.PayQQRight(3)
  elseif id == "Btn_RenewSVip" then
    ECMSDK.PayQQRight(2)
  elseif id == "Btn_OpenVip" then
    ECMSDK.PayQQRight(1)
  elseif id == "Btn_RenewVip" then
    ECMSDK.PayQQRight(4)
  elseif id == "Img_Bag_1" then
    local key = "NORMAL_VIP_FRESHMAN_AWARD_TIPS_CFG_ID"
    if self.m_SubPage == 2 then
      key = "SUPER_VIP_FRESHMAN_AWARD_TIPS_CFG_ID"
    end
    local tipsID = RelationShipChainMgr.GetGrcConstant(key)
    GUIUtils.ShowHoverTip(tipsID)
  elseif id == "Img_Bag_2" then
    local key = "NORMAL_VIP_PAY_AWARD_TIPS_CFG_ID"
    if self.m_SubPage == 2 then
      key = "SUPER_VIP_PAY_AWARD_TIPS_CFG_ID"
    end
    local tipsID = RelationShipChainMgr.GetGrcConstant(key)
    GUIUtils.ShowHoverTip(tipsID)
  end
end
def.method().InitData = function(self)
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Group_SVip = self.m_panel:FindDirect("Img_Bg/Group_SVip")
  self.m_UIGO.Group_Vip = self.m_panel:FindDirect("Img_Bg/Group_Vip")
  self.m_UIGO.Tap_Svip = self.m_panel:FindDirect("Img_Bg/Tap_Svip")
  self.m_UIGO.Tap_Vip = self.m_panel:FindDirect("Img_Bg/Tap_Vip")
end
def.method().UpdateSubPage = function(self)
  local groupSVIPGO = self.m_UIGO.Group_SVip
  local groupVIPGO = self.m_UIGO.Group_Vip
  local vipLevel = RelationShipChainMgr.GetSepicalVIPLevel()
  GUIUtils.Toggle(self.m_UIGO.Tap_Vip, self.m_SubPage == 1)
  GUIUtils.Toggle(self.m_UIGO.Tap_Svip, self.m_SubPage == 2)
  if self.m_SubPage == 1 then
    GUIUtils.SetActive(self.m_UIGO.Group_Vip:FindDirect("Btn_OpenVip"), vipLevel == 0)
    GUIUtils.SetActive(self.m_UIGO.Group_Vip:FindDirect("Btn_RenewVip"), vipLevel == 2 or vipLevel == 1)
  elseif self.m_SubPage == 2 then
    GUIUtils.SetActive(self.m_UIGO.Group_SVip:FindDirect("Btn_OpenSVip"), vipLevel == 0 or vipLevel == 1)
    GUIUtils.SetActive(self.m_UIGO.Group_SVip:FindDirect("Btn_RenewSVip"), vipLevel == 2)
  end
end
return QQVIPWellFarePanel.Commit()
