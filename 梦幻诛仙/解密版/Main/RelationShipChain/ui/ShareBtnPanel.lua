local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GUIUtils = require("GUI.GUIUtils")
local ShareBtnPanel = Lplus.Extend(ECPanelBase, "ShareBtnPanel")
local def = ShareBtnPanel.define
def.field(ECPanelBase).m_DepPanel = nil
def.field("boolean").m_IsDestroy = true
def.field("table").m_UIGO = nil
def.field("string").m_ImgPath = ""
def.field("function").m_ClickShareFunc = nil
local instance
def.static("=>", ShareBtnPanel).Instance = function()
  if not instance then
    instance = ShareBtnPanel()
    instance.m_depthLayer = GUIDEPTH.TOPMOST2 + 1
  end
  return instance
end
def.method("boolean").IsDestroy = function(self, isDestroy)
  self.m_IsDestroy = isDestroy
end
def.method("string").SetImgPath = function(self, imgPath)
  self.m_ImgPath = imgPath
end
def.method("function").SetClickShareFunc = function(self, ClickShareFunc)
  self.m_ClickShareFunc = ClickShareFunc
end
def.method(ECPanelBase).ShowPanel = function(self, depPanel)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_DepPanel = depPanel
  self:CreatePanel(RESPATH.PREFAB_SHARE_BIG_TU_BTN_PANEL, GUILEVEL.NORMAL)
end
def.override().OnCreate = function(self)
  require("GUI.ECPanelDebugInput").Instance():Show(false)
  self:InitUI()
  self.m_bCanMoveBackward = true
end
def.override().OnDestroy = function(self)
  self.m_ImgPath = ""
  self.m_UIGO = nil
  self.m_IsDestroy = true
end
def.method("boolean").ToggleBtn = function(self, show)
  local closeBtnGO = self.m_UIGO.Btn_Close
  local leftBtnGO = self.m_UIGO.Btn_Left
  local rightBtnGO = self.m_UIGO.Btn_Right
  GUIUtils.SetActive(closeBtnGO, show)
  GUIUtils.SetActive(leftBtnGO, show)
  GUIUtils.SetActive(rightBtnGO, show)
end
def.method("number").Share = function(self, scene)
  if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX and not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.WX) then
    Toast(textRes.Common[311])
    return
  elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.QQ) then
    Toast(textRes.Common[310])
    return
  elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
    Toast(textRes.Common[313])
    return
  end
  if self.m_ClickShareFunc then
    self.m_ClickShareFunc()
  end
  self:ToggleBtn(false)
  GameUtil.ScreenShot(0, 0, Screen.width, Screen.height, 800, self.m_ImgPath, function(ret, filePath)
    warn("Captrue ScreenShot Status", ret, self.m_ImgPath)
    if ret then
      self:ToggleBtn(true)
      local sdktype = ClientCfg.GetSDKType()
      if sdktype == ClientCfg.SDKTYPE.MSDK then
        ECMSDK.SendToFriendWithPhotoPath(scene, filePath)
      else
        local ECUniSDK = require("ProxySDK.ECUniSDK")
        if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
          ECUniSDK.Instance():Share({localPic = filePath})
        elseif ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
          ECUniSDK.Instance():Share({
            imgPath = filePath,
            title = textRes.RelationShipChain[101],
            desc = textRes.RelationShipChain[104]
          })
        end
      end
    end
  end)
end
def.method().EfunShare = function(self)
  if self.m_ClickShareFunc then
    self.m_ClickShareFunc()
  end
  GUIUtils.SetActive(self.m_UIGO.Btn_Center, false)
  GameUtil.ScreenShot(0, 0, Screen.width, Screen.height, 800, self.m_ImgPath, function(ret, filePath)
    warn("Captrue ScreenShot Status", ret, self.m_ImgPath)
    if ret then
      GUIUtils.SetActive(self.m_UIGO.Btn_Center, true)
      local ECUniSDK = require("ProxySDK.ECUniSDK")
      if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
        ECUniSDK.Instance():Share({localPic = filePath})
      elseif ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
        ECUniSDK.Instance():Share({
          imgPath = filePath,
          title = textRes.RelationShipChain[101],
          desc = textRes.RelationShipChain[104]
        })
      end
    end
  end)
end
def.method().Destroy = function(self)
  if not self.m_IsDestroy then
    return
  end
  if self.m_DepPanel then
    self.m_DepPanel:DestroyPanel()
  end
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self.m_IsDestroy = true
    self:Destroy()
  elseif id == "Btn_Left" then
    self:Share(1)
  elseif id == "Btn_Right" then
    self:Share(2)
  elseif id == "Btn_Center" then
    self:EfunShare()
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Btn_Close = self.m_panel:FindDirect("Btn_Close")
  self.m_UIGO.Btn_Left = self.m_panel:FindDirect("Btn_Left")
  self.m_UIGO.Btn_Right = self.m_panel:FindDirect("Btn_Right")
  self.m_UIGO.Btn_Center = self.m_panel:FindDirect("Btn_Center")
  local sdktype = ClientCfg.GetSDKType()
  GUIUtils.SetActive(self.m_UIGO.Btn_Left, sdktype == ClientCfg.SDKTYPE.MSDK)
  GUIUtils.SetActive(self.m_UIGO.Btn_Right, sdktype == ClientCfg.SDKTYPE.MSDK)
  GUIUtils.SetActive(self.m_UIGO.Btn_Center, sdktype == ClientCfg.SDKTYPE.UNISDK)
  local lDesc = _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and textRes.RelationShipChain[40] or textRes.RelationShipChain[42]
  GUIUtils.SetText(self.m_UIGO.Btn_Left:FindDirect("Label"), lDesc)
  local rDesc = _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and textRes.RelationShipChain[41] or textRes.RelationShipChain[43]
  GUIUtils.SetText(self.m_UIGO.Btn_Right:FindDirect("Label"), rDesc)
end
return ShareBtnPanel.Commit()
