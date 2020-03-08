local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GUIUtils = require("GUI.GUIUtils")
local ShareTipsPanel = Lplus.Extend(ECPanelBase, "ShareTipsPanel")
local def = ShareTipsPanel.define
def.field("boolean").m_CanGetAward = false
def.field("table").m_UIGO = nil
local instance
def.static("=>", ShareTipsPanel).Instance = function()
  if not instance then
    instance = ShareTipsPanel()
  end
  return instance
end
def.method("boolean").ShowPanel = function(self, canGetAward)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_CanGetAward = canGetAward
  self:CreatePanel(RESPATH.PREFAB_SHARE_TIPS_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
end
def.method("number", "string").SendToFriendEx = function(self, scene, inviteCode)
  local content = textRes.Common[409]:format(inviteCode)
  local logoURL = ECMSDK.LogoURL
  if ECMSDK.IsHttpsSupported() and _G.platform == 1 then
    logoURL = ECMSDK.LogoURL2
  end
  if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    local url = textRes.Common.qq_invite_friend:format(inviteCode)
    MSDK.sendToQQ(scene, textRes.Common[408], content, url, logoURL)
  elseif LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    local url = textRes.Common.wechat_invite_friend:format(inviteCode)
    MSDK.sendToWXWithUrl(scene, textRes.Common[408], content, url, "MSG_SHARE_FRIEND_HIGH_SCORE", logoURL, "")
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_1" or id == "Btn_3" then
    if self.m_CanGetAward then
      ECMSDK.SetShareType(UseType.SHARE_AWARD)
      ECMSDK.SendToFriendWithPhoto(1, ECMSDK.ShareURL[4])
    else
      local inviteFriendData = require("Main.RelationShipChain.RelationShipChainMgr").GetInviteFriendData()
      local inviteCode = GetStringFromOcts(inviteFriendData.invite_code)
      if inviteCode then
        self:SendToFriendEx(1, inviteCode)
        ECMSDK.SendTLogToServer(_G.TLOGTYPE.SHAREINVITECODE, {
          inviteCode,
          id == "Btn_1" and 1 or 3
        })
      end
    end
  elseif id == "Btn_2" or id == "Btn_4" then
    if self.m_CanGetAward then
      ECMSDK.SetShareType(UseType.SHARE_AWARD)
      ECMSDK.SendToFriendWithPhoto(2, ECMSDK.ShareURL[4])
    else
      local inviteFriendData = require("Main.RelationShipChain.RelationShipChainMgr").GetInviteFriendData()
      local inviteCode = GetStringFromOcts(inviteFriendData.invite_code)
      if inviteCode then
        self:SendToFriendEx(2, inviteCode)
        ECMSDK.SendTLogToServer(_G.TLOGTYPE.SHAREINVITECODE, {
          inviteCode,
          id == "Btn_2" and 2 or 4
        })
      end
    end
  end
  self:DestroyPanel()
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Group_QQ = self.m_panel:FindDirect("Img_Bg/Group_QQ")
  self.m_UIGO.Group_WeiXin = self.m_panel:FindDirect("Img_Bg/Group_WeiXin")
  GUIUtils.SetActive(self.m_UIGO.Group_QQ, _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ)
  GUIUtils.SetActive(self.m_UIGO.Group_WeiXin, _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX)
end
return ShareTipsPanel.Commit()
