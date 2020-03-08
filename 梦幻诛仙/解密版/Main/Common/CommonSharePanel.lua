local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local GUIUtils = require("GUI.GUIUtils")
local CommonSharePanel = Lplus.Extend(ECPanelBase, "CommonSharePanel")
local def = CommonSharePanel.define
local UrlType = {
  Local = 1,
  Web = 2,
  Auto = 3
}
def.const("table").UrlType = UrlType
def.field("string").shareUrl = ""
def.field("table").m_UIGO = nil
def.field("number").shareType = 0
def.field("number").urlType = 0
local instance
def.static("=>", CommonSharePanel).Instance = function()
  if not instance then
    instance = CommonSharePanel()
  end
  return instance
end
def.method("number", "string").ShowPanel = function(self, shareType, url)
  self:ShowPanelEx(shareType, url, {
    urlType = UrlType.Web
  })
end
def.method("number", "string", "table").ShowPanelEx = function(self, shareType, url, exParams)
  if self:IsShow() then
    self:DestroyPanel()
  end
  if not ECMSDK.IsPlatformInstalled(_G.LoginPlatform) then
    local msg = textRes.Common[1000 + _G.LoginPlatform] or textRes.Common[1000]
    if msg then
      Toast(msg)
    end
    return
  end
  local exParams = exParams or {}
  self.shareType = shareType
  self.shareUrl = url
  self.urlType = exParams.urlType or UrlType.Auto
  self:CreatePanel(RESPATH.PREFAB_SHARE_TIPS_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
  self.shareUrl = ""
end
def.method("string").onClick = function(self, id)
  if id == "Btn_1" or id == "Btn_3" then
    ECMSDK.SetShareType(self.shareType)
    self:ShareToScene(_G.MSDK_SHARE_SCENE.SINGEL)
  elseif id == "Btn_2" or id == "Btn_4" then
    ECMSDK.SetShareType(self.shareType)
    self:ShareToScene(_G.MSDK_SHARE_SCENE.SPACE)
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
def.method("number").ShareToScene = function(self, shareScene)
  if self:IsUseLocalPath() then
    ECMSDK.SendToFriendWithPhotoPath(shareScene, self.shareUrl)
  else
    ECMSDK.SendToFriendWithPhoto(shareScene, self.shareUrl)
  end
end
def.method("=>", "boolean").IsUseLocalPath = function(self)
  if self.urlType == UrlType.Local then
    return true
  elseif self.urlType == UrlType.Web then
    return false
  else
    return self:IsLocalUrl(self.shareUrl)
  end
end
def.method("string", "=>", "boolean").IsLocalUrl = function(self, url)
  if url:find("^https?://") then
    return false
  else
    return true
  end
end
return CommonSharePanel.Commit()
