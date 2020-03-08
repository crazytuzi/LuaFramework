local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECMSDK = require("ProxySDK.ECMSDK")
local VIPRightPanel = Lplus.Extend(ECPanelBase, "VIPRightPanel")
local def = VIPRightPanel.define
def.field("number").m_SubPage = 1
local instance
def.static("=>", VIPRightPanel).Instance = function()
  if not instance then
    instance = VIPRightPanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, subPage)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_SubPage = subPage
  self:CreatePanel(RESPATH.PREFAB_VIP_RIGHT_PANEL, GUILEVEL.NORMAL)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.m_bCanMoveBackward = true
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method().InitData = function(self)
end
def.method().InitUI = function(self)
  GUIUtils.SetActive(self.m_panel:FindDirect("Group_QQ"), self.m_SubPage == 1)
  GUIUtils.SetActive(self.m_panel:FindDirect("Group_Wechat"), self.m_SubPage == 2)
  GUIUtils.SetActive(self.m_panel:FindDirect("Group_YingYongBao"), self.m_SubPage == 3)
end
return VIPRightPanel.Commit()
