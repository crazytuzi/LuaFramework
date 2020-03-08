local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local GUIUtils = require("GUI.GUIUtils")
local LoginTipsPanel = Lplus.Extend(ECPanelBase, "LoginTipsPanel")
local def = LoginTipsPanel.define
local instance
def.static("=>", LoginTipsPanel).Instance = function()
  if not instance then
    instance = LoginTipsPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_LOGIN_TIPS, GUILEVEL.MUTEX)
end
def.override().OnCreate = function(self)
  local btnWXGO = self.m_panel:FindDirect("Img_Bg0/Btn_Wechat")
  GUIUtils.SetActive(btnWXGO, ECMSDK.IsPlatformInstalled(MSDK_LOGIN_PLATFORM.WX))
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  local DlgLogin = require("Main.Login.ui.DlgLogin")
  if id == "Btn_QQ" then
    DlgLogin.Instance():EnableLoginBtns(false)
    ECMSDK.Login(MSDK_LOGIN_PLATFORM.QQ)
    ECMSDK.ReportEvent("login", "11", true)
    ECMSDK.SetGSDKEvent(3, true, "WX")
  elseif id == "Btn_Wechat" then
    DlgLogin.Instance():EnableLoginBtns(false)
    ECMSDK.Login(MSDK_LOGIN_PLATFORM.WX)
    ECMSDK.ReportEvent("login", "10", true)
    ECMSDK.SetGSDKEvent(3, true, "WX")
  elseif id == "Btn_Continue" then
    DlgLogin.Instance():EnableLoginBtns(false)
    ECMSDK.Login(MSDK_LOGIN_PLATFORM.GUEST)
    ECMSDK.ReportEvent("login", "9", true)
    ECMSDK.SetGSDKEvent(3, true, "GUEST")
  end
  self:DestroyPanel()
end
return LoginTipsPanel.Commit()
