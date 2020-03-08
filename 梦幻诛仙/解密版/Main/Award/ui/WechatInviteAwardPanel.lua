local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WechatInviteAwardPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local def = WechatInviteAwardPanel.define
local Vector = require("Types.Vector")
local WechatInviteAwardMgr = require("Main.Award.mgr.WechatInviteAwardMgr")
def.field("table").m_UIGO = nil
local instance
def.static("=>", WechatInviteAwardPanel).Instance = function()
  if not instance then
    instance = WechatInviteAwardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_PRIZE_WECHAT_INVITE, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.WECHAT_INVITE_AWARD_CLOSE, WechatInviteAwardPanel.OnWechatInviteAwardClose)
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.WECHAT_INVITE_AWARD_CLOSE, WechatInviteAwardPanel.OnWechatInviteAwardClose)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Join" or id == "Texture_Bg" then
    self:OnClickConfirmBtn()
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  local Texture_Bg = self.m_panel:FindDirect("Group_WeChatInvite/Texture_Bg")
  GUIUtils.AddBoxCollider(Texture_Bg)
end
def.method().UpdateUI = function(self)
end
def.method().OnClickConfirmBtn = function(self)
  local ECMSDK = require("ProxySDK.ECMSDK")
  local url = textRes.Common.wechat_direction_invite
  url = _G.AttachGameData2URL(url)
  ECMSDK.OpenURL(url, ECMSDK.SCREENDIR.PORTRAIT)
  WechatInviteAwardMgr.Instance():SetKnow(true)
end
def.static("table", "table").OnWechatInviteAwardClose = function()
  require("Main.Award.ui.AwardPanel").Instance():DestroyPanel()
end
return WechatInviteAwardPanel.Commit()
