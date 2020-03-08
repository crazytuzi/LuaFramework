local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PostInviteInfoPanel = Lplus.Extend(ECPanelBase, "PostInviteInfoPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local def = PostInviteInfoPanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
def.field("table").m_UIGO = nil
local instance
def.static("=>", PostInviteInfoPanel).Instance = function()
  if not instance then
    instance = PostInviteInfoPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_AWARD_POST_INVITE_INFO_PANEL, 0)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Label_Code = self.m_panel:FindDirect("Img_Bg/Label_Code")
  self.m_UIGO.Label_Content = self.m_panel:FindDirect("Img_Bg/Label_Content")
  self.m_UIGO.Label2 = self.m_panel:FindDirect("Img_Bg/Label2")
  self.m_UIGO.Label = self.m_panel:FindDirect("Img_Bg/Label")
  local inviteFriendData = RelationShipChainMgr.GetInviteFriendData()
  GUIUtils.SetText(self.m_UIGO.Label_Code, GetStringFromOcts(inviteFriendData.invite_code))
end
def.method("number").Copy = function(self, type)
  local copyString = ""
  if type == 1 then
    copyString = self.m_UIGO.Label_Code:GetComponent("UILabel").text
  elseif type == 2 then
    local title = self.m_UIGO.Label:GetComponent("UILabel").text .. self.m_UIGO.Label_Code:GetComponent("UILabel").text .. "\n"
    copyString = self.m_UIGO.Label_Content:GetComponent("UILabel").text .. "\n"
    copyString = copyString .. self.m_UIGO.Label2:GetComponent("UILabel").text
    copyString = title .. copyString:gsub("[%[01A-F%-%]]", "")
  end
  warn("Copy String ~~~~~~~", copyString)
  Toast(textRes.Common[410])
  require("ProxySDK.ECMSDK").SetClipBoard(copyString)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Copy" then
    self:Copy(1)
  elseif id == "Btn_CopyAll" then
    self:Copy(2)
  end
end
return PostInviteInfoPanel.Commit()
