local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local SnapshotModule = Lplus.Extend(ModuleBase, MODULE_NAME)
local def = SnapshotModule.define
local ECGUIMan = require("GUI.ECGUIMan")
def.const("number").SWITCH_ID = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_TAKE_PHOTO
def.const("number").SCREEN_SHOT_LIMIT = 2048
local instance
def.static("=>", SnapshotModule).Instance = function()
  if instance == nil then
    instance = SnapshotModule()
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, SnapshotModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SnapshotModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CAMERA_CLICK, SnapshotModule.OnClickCameraBtn)
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.FEATURE):IsFeatureListInited() then
    return false
  end
  local isOpen = _G.IsFeatureOpen(SnapshotModule.SWITCH_ID)
  return isOpen
end
def.method("table").EnterCaptureMode = function(self, panel)
  ECGUIMan.Instance():ShowAllUIExceptMe(false, panel)
end
def.method("table").LeaveCaptureMode = function(self, panel)
  ECGUIMan.Instance():ShowAllUIExceptMe(true, panel)
end
def.method("table", "function").CaptrueTheMomement = function(self, params, callback)
  params = params or {}
  ECGUIMan.Instance():EnterPanelTopmostMode()
  local clock = os.clock()
  local microClock = math.floor(os.clock() * 1000 % 1000)
  local dateStr = os.date("%Y%m%d%H%M%S") .. "." .. microClock
  local savePath
  if params.isRaw then
    savePath = string.format("%s/UserData/Snapshot/raw/mhzx_snap_raw_%s.png", GameUtil.GetAssetsPath(), dateStr)
  else
    savePath = string.format("%s/UserData/Snapshot/mhzx_snap_%s.png", GameUtil.GetAssetsPath(), dateStr)
  end
  GameUtil.CreateDirectoryForFile(savePath)
  local limit = SnapshotModule.SCREEN_SHOT_LIMIT
  GameUtil.ScreenShot(0, 0, Screen.width, Screen.height, limit, savePath, function(ret, filePath)
    warn("Captrue ScreenShot Status", ret, savePath)
    ECGUIMan.Instance():LeavePanelTopmostMode()
    _G.SafeCallback(callback, ret, filePath)
  end)
end
def.method("string", "=>", "boolean").ShareToSocialSpace = function(self, localPath)
  local SocialSpaceModule = require("Main.SocialSpace.SocialSpaceModule")
  return SocialSpaceModule.Instance():SendPhotoToSpace(localPath)
end
def.method("string").ShareToSocialNetwork = function(self, localPath)
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local CommonSharePanel = require("Main.Common.CommonSharePanel")
    CommonSharePanel.Instance():ShowPanelEx(0, localPath, {
      urlType = CommonSharePanel.UrlType.Local
    })
  elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
    local ECUniSDK = require("ProxySDK.ECUniSDK")
    if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
      ECUniSDK.Instance():Share({localPic = localPath})
    elseif ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
      ECUniSDK.Instance():Share({
        imgPath = localPath,
        title = textRes.RelationShipChain[101],
        desc = textRes.RelationShipChain[104]
      })
    end
  else
    Toast(textRes.Snapshot[2])
  end
end
def.static("table", "table").OnFeatureOpenInit = function(params, context)
  Event.DispatchEvent(ModuleId.SNAPSHOT, gmodule.notifyId.Snapshot.FEATURE_OPEN_CHANGE, nil)
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local switchId = params.feature
  if switchId ~= SnapshotModule.SWITCH_ID then
    return
  end
  Event.DispatchEvent(ModuleId.SNAPSHOT, gmodule.notifyId.Snapshot.FEATURE_OPEN_CHANGE, nil)
end
def.static("table", "table").OnClickCameraBtn = function(params, context)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.Snapshot[7], textRes.Snapshot[8], "", "", 0, 15, function(s)
    if s == 1 then
      local SnapshotPanel = require("Main.Snapshot.ui.SnapshotPanel")
      SnapshotPanel.Instance():ShowPanel()
    end
  end, nil)
end
return SnapshotModule.Commit()
