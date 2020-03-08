local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local DeviceUtility = Lplus.Class(CUR_CLASS_NAME)
local def = DeviceUtility.define
DeviceUtility.Constants = {
  CHARGING = 2,
  DISCHARGING = 3,
  FULL_CHARGE = 5,
  NETWORK_PROVIDER_CMCC = "CMCC",
  NETWORK_PROVIDER_CUCC = "CUCC",
  NETWORK_PROVIDER_CTC = "CTC",
  NETWORK_PROVIDER_CTTC = "CTTC",
  NETWORK_PROVIDER_UNKNOWN = "UNKNOWN",
  CROP_FAILED = -1,
  CROP_DONE = 0,
  CROP_CANCELED = 1,
  CROP_IGNORED = 2
}
DeviceUtility.NetworkState = {
  UNAVAILABLE = -1,
  UNKNOWN = 0,
  WIFI = 1,
  MOBILE = 2
}
local funcs = {}
local batteryInfos = {
  -1,
  -1,
  -1
}
function DeviceUtility.onBattery(level, temperature, status)
  batteryInfos = {
    level,
    temperature,
    status
  }
  for k, func in pairs(funcs) do
    func(level, temperature, status)
  end
end
def.static("function").GetBattery = function(onBattery)
  funcs[onBattery] = onBattery
  if ZLUtil then
    ZLUtil.getBattery()
  end
  onBattery(unpack(batteryInfos))
end
local function getDefaultNetworkState()
  local state = DeviceUtility.NetworkState.WIFI
  if GameUtil.IsWirelessNetwork() then
    state = DeviceUtility.NetworkState.MOBILE
  end
  return state
end
def.static("=>", "number").GetNetWorkState = function()
  local state
  if ZLUtil and ZLUtil.getNetworkState then
    state = ZLUtil.getNetworkState()
  end
  if state and state ~= 0 then
    if state > 0 then
      state = math.floor(state / 100)
    end
    return state
  else
    return getDefaultNetworkState()
  end
end
def.static("=>", "number").GetNetWorkDetailState = function()
  local state
  if ZLUtil and ZLUtil.getNetworkState then
    state = ZLUtil.getNetworkState()
  end
  if state and state ~= 0 then
    return state
  else
    return getDefaultNetworkState()
  end
end
def.static("=>", "boolean").IsWIFIConnected = function()
  return DeviceUtility.GetNetWorkState() == DeviceUtility.NetworkState.WIFI
end
def.static("=>", "string").GetNetworkProviderID = function()
  if ZLUtil and ZLUtil.getNetworkProviderID then
    return ZLUtil.getNetworkProviderID()
  end
  return ""
end
def.static("=>", "string").GetNetworkProviderName = function()
  local providerID = DeviceUtility.GetNetworkProviderID()
  if providerID == "46000" or providerID == "46002" or providerID == "46004" or providerID == "46007" then
    return DeviceUtility.Constants.NETWORK_PROVIDER_CMCC
  elseif providerID == "46001" or providerID == "46006" or providerID == "46009" then
    return DeviceUtility.Constants.NETWORK_PROVIDER_CUCC
  elseif providerID == "46003" or providerID == "46005" or providerID == "46011" then
    return DeviceUtility.Constants.NETWORK_PROVIDER_CTC
  elseif providerID == "46020" then
    return DeviceUtility.Constants.NETWORK_PROVIDER_CTTC
  else
    return DeviceUtility.Constants.NETWORK_PROVIDER_UNKNOWN
  end
end
local _version
def.static("=>", "number").GetProgramCurrentVersion = function()
  if _version == nil then
    _version = GameUtil.GetProgramCurrentVersionInfo()
    _version = tonumber(_version) or 0
  end
  return _version
end
def.static("=>", "boolean").IsNetworkStateFixedVersion = function()
  local NETWORK_STATE_FIX_VERSION = 110
  if _G.platform ~= _G.Platform.ios then
    return true
  end
  local version = DeviceUtility.GetProgramCurrentVersion()
  return NETWORK_STATE_FIX_VERSION <= version
end
def.static("=>", "boolean").IsNetStreamBufferBugFixed = function()
  local fixedVersion = 113
  local version = DeviceUtility.GetProgramCurrentVersion()
  return fixedVersion <= version
end
def.static("=>", "boolean").IsSupportMidasJSAPI = function()
  local MIDAS_JS_API_VERSION = 117
  local version = DeviceUtility.GetProgramCurrentVersion()
  return MIDAS_JS_API_VERSION <= version
end
local _onTakePhotoCallback
def.static("function", "table").TakePhoto = function(onTakePhoto, extras)
  if ZLUtil and ZLUtil.takePhoto then
    _onTakePhotoCallback = onTakePhoto
    extras = extras or {}
    local maxWidth = extras.maxWidth or 1920
    local maxHeight = extras.maxHeight or 1080
    local quality = extras.quality or 75
    local isCrop = extras.isCrop or false
    local cropWidth = extras.cropWidth or 256
    local cropHeight = extras.cropHeight or 256
    ZLUtil.takePhoto(maxWidth, maxHeight, quality, isCrop, cropWidth, cropHeight)
  else
    warn("No take photo API.")
  end
end
def.static("string", "varlist").onTakePhoto = function(photoPath, cropResult)
  print(string.format("DeviceUtility.onTakePhoto %s, %s", photoPath, tostring(cropResult)))
  if _onTakePhotoCallback then
    _onTakePhotoCallback(photoPath, cropResult)
    _onTakePhotoCallback = nil
  end
end
local _onPickPhotoCallback
def.static("function", "table").PickPhoto = function(onPickPhoto, extras)
  if ZLUtil and ZLUtil.pickPhoto then
    _onPickPhotoCallback = onPickPhoto
    extras = extras or {}
    local maxWidth = extras.maxWidth or 1920
    local maxHeight = extras.maxHeight or 1080
    local quality = extras.quality or 75
    local isCrop = extras.isCrop or false
    local cropWidth = extras.cropWidth or 256
    local cropHeight = extras.cropHeight or 256
    ZLUtil.pickPhoto(maxWidth, maxHeight, quality, isCrop, cropWidth, cropHeight)
  else
    warn("No pick photo API.")
  end
end
def.static("string", "varlist").onPickPhoto = function(photoPath, cropResult)
  print(string.format("DeviceUtility.onPickPhoto %s, %s", photoPath, tostring(cropResult)))
  if _onPickPhotoCallback then
    _onPickPhotoCallback(photoPath, cropResult)
    _onPickPhotoCallback = nil
  end
end
def.static().InstallUncaughtExceptionHandler = function()
  local version = GameUtil.GetProgramCurrentVersionInfo()
  version = tonumber(version) or 0
  if _G.platform == Platform.android and version < 116 then
    return
  end
  if ZLUtil and ZLUtil.installUncaughtExceptionHandler then
    ZLUtil.installUncaughtExceptionHandler()
  end
end
def.static("=>", "string").GetIMEI = function()
  if ZLUtil and ZLUtil.getIMEI then
    return ZLUtil.getIMEI()
  end
  return ""
end
local _debugTGP
def.static("=>", "boolean").IsTGP = function()
  if _debugTGP ~= nil then
    return _debugTGP == true
  end
  if _G.platform ~= Platform.android then
    return false
  end
  local TGP_IMEI_PREFIX = "66666"
  local imei = DeviceUtility.GetIMEI()
  if imei:find("^" .. TGP_IMEI_PREFIX) then
    return true
  else
    return false
  end
end
def.static("dynamic").DebugSetAsTGP = function(isTGP)
  _debugTGP = isTGP
end
def.static("=>", "boolean").IsIPad = function()
  if _G.platform ~= _G.Platform.ios then
    return false
  end
  return SystemInfo.deviceModel:find("^iPad") ~= nil
end
return DeviceUtility.Commit()
