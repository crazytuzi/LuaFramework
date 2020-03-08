local Lplus = require("Lplus")
local ECMSDK = require("ProxySDK.ECMSDK")
local Octets = require("netio.Octets")
local LoginUtility = Lplus.Class("LoginUtility")
local def = LoginUtility.define
local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
def.const("number").LOGIN_HISTORY_VERSION = 2.1
def.field("table").occupationList = nil
def.field("table")._catchedHistoryMap = nil
def.field("table")._catchedUserHistory = nil
def.field("string")._lastUserName = ""
def.const("number").RECENT_SERVER_RECORD_MAX = 12
def.const("string").LOGIN_HISTORY_CONFIG_NAME = "config/login_history.lua"
local isAuroraStarted = false
local instance
def.static("=>", LoginUtility).Instance = function()
  if instance == nil then
    instance = LoginUtility()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  local configPath = string.format("%s/%s", Application.persistentDataPath, LoginUtility.LOGIN_HISTORY_CONFIG_NAME)
  GameUtil.CreateDirectoryForFile(configPath)
end
def.method("=>", "table").GetOccupationList = function(self)
  if self.occupationList == nil then
    self.occupationList = {}
    local allCreateRoleCfgs = LoginUtility.GetAllCreateRoleCfgs()
    for k, v in pairs(allCreateRoleCfgs) do
      local occupationInfo = self.occupationList[v.occupationId] or {}
      occupationInfo[v.gender] = v.isOpen
      self.occupationList[v.occupationId] = occupationInfo
    end
  end
  return self.occupationList
end
def.method("=>", "table").GetUnlockedRoleList = function(self)
  local unlockedRoleList = {}
  local occupationList = self:GetOccupationList()
  for occupation, occupationInfo in pairs(occupationList) do
    for gender, isUnlock in pairs(occupationInfo) do
      if isUnlock and _G.IsOccupationOpen(occupation, gender) then
        table.insert(unlockedRoleList, {occupation = occupation, gender = gender})
      end
    end
  end
  return unlockedRoleList
end
def.method("number", "=>", "boolean").IsOccupationUnlocked = function(self, occupation)
  local occupationList = self:GetOccupationList()
  if occupationList[occupation] == nil then
    return false
  end
  if occupationList[occupation][GenderEnum.MALE] == false and occupationList[occupation][GenderEnum.FEMALE] == false then
    return false
  end
  return true
end
def.method("number", "number", "=>", "boolean").IsOccupationGenderUnlocked = function(self, occupation, gender)
  local occupationList = self:GetOccupationList()
  if occupationList[occupation] == nil then
    return false
  end
  if occupationList[occupation][gender] == false then
    return false
  end
  return true
end
def.method("number", "=>", "boolean").IsOccupationHided = function(self, occupation)
  return not _G.IsOccupationOpen(occupation)
end
def.static("number", "number", "=>", "string", "number").GetCreateRoleModelPath = function(occupation, gender)
  local modelId = _G.GetOccupationCfg(occupation, gender).modelId
  local path = _G.GetModelPath(modelId)
  return path, modelId
end
def.static("number", "number", "=>", "string", "number").GetCreateRole2DModelPath = function(occupation, gender)
  local createRoleCfg = LoginUtility.GetCreateRoleCfg(occupation, gender)
  local iconId = createRoleCfg.model2dId
  local path = _G.GetIconPath(iconId)
  return path, iconId
end
def.static("number", "=>", "string").GetCreateRoleOccupationBGPath = function(occupation)
  local createRoleCfg = LoginUtility.GetCreateRoleCfg(occupation, 1)
  local iconId = createRoleCfg.bgImageId
  local path = _G.GetIconPath(iconId)
  return path
end
def.static("number", "=>", "string").GetOccupationImageSpriteName = function(occupation)
  local name = string.format("%d-5", occupation)
  return name
end
def.static("number", "=>", "string").GetOccupationImage2SpriteName = function(occupation)
  local name = string.format("Img_MenPai_%d", occupation)
  return name
end
def.static("number", "number", "=>", "string").GetOccupationPoemSpriteName = function(occupation, gender)
  local name = string.format("Img_Word%d_%d", occupation, gender)
  return name
end
def.static("number", "=>", "string").GetOccupationDescSpriteName = function(occupation)
  local name = string.format("Img_Skill_%d", occupation)
  return name
end
def.static().BackgroundPreloadHeroModels = function()
  local PreRandom = require("Main.Common.PreRandom")
  local roleList = LoginUtility.Instance():GetUnlockedRoleList()
  local roleCount = #roleList
  local selectedIndex = PreRandom.PreRandom(1, roleCount)
  local role = roleList[selectedIndex]
  local occupationCfg = _G.GetOccupationCfg(role.occupation, role.gender)
  local modelId = occupationCfg.modelId
  local modelPath = LoginUtility.GetCreateRoleModelPath(role.occupation, role.gender)
  local bgPath = LoginUtility.Instance():GetCreateRoleOccupationBGPath(role.occupation)
  local resPathList = {
    modelPath,
    bgPath,
    RESPATH.PREFAB_LODING_PANEL_RES
  }
  AsyncLoadArray(resPathList, function(resList)
    for i, res in ipairs(resList) do
      if res then
      end
    end
  end)
end
def.method("string", "=>", "table").GetUserLoginHistory = function(self, username)
  if self._catchedHistoryMap and self._catchedHistoryMap[username] then
    return self._catchedHistoryMap[username]
  end
  local history = self:LoadLoginHistory()
  if history == nil or history.history_map == nil then
    return nil
  end
  local userHistory = history.history_map[username]
  self._catchedHistoryMap = self._catchedHistoryMap or {}
  self._catchedHistoryMap[username] = userHistory
  return userHistory
end
def.method("=>", "string").GetLastUserName = function(self)
  if self._lastUserName ~= "" then
    return self._lastUserName
  end
  local history = self:LoadLoginHistory()
  if history == nil then
    return ""
  end
  self._lastUserName = history.last_user_name
  return self._lastUserName
end
def.method("=>", "table").LoadLoginHistory = function(self)
  local configPath = string.format("%s/%s", Application.persistentDataPath, LoginUtility.LOGIN_HISTORY_CONFIG_NAME)
  local chunk = loadfile(configPath)
  local history
  if chunk then
    history = chunk()
  end
  if history == nil then
    return nil
  end
  if history.version ~= LoginUtility.LOGIN_HISTORY_VERSION then
    return nil
  end
  return history
end
def.static("string", "number", "=>", "table").GetServerLastLoginRoleCfg = function(username, serverId)
  local loginHistory = LoginUtility.Instance():GetUserLoginHistory(username)
  local lastLoginRole
  if loginHistory then
    for i, record in ipairs(loginHistory) do
      if record.serverId == serverId then
        lastLoginRole = record.roleList[1]
        if lastLoginRole and lastLoginRole.roleid and type(lastLoginRole.roleid) == "string" then
          lastLoginRole.roleid = Int64.ParseString(lastLoginRole.roleid)
        end
      end
    end
  end
  return lastLoginRole
end
def.static("string", "number", "=>", "userdata").GetServerLastLoginRoleId = function(username, serverId)
  local lastLoginRole = LoginUtility.GetServerLastLoginRoleCfg(username, serverId)
  local roleId
  if lastLoginRole then
    roleId = lastLoginRole.roleid
  end
  return roleId
end
def.static("string", "number", "=>", "table").GetRoleListCfg = function(username, serverId)
  local loginHistory = LoginUtility.Instance():GetUserLoginHistory(username)
  local roleList
  if loginHistory then
    for i, record in ipairs(loginHistory) do
      if record.serverId == serverId then
        roleList = record.roleList
        break
      end
    end
  end
  return roleList
end
def.method("string", "number", "table").AddLoginHistory = function(self, username, serverId, roleList)
  self:AddLoginHistoryEx(username, serverId, roleList, {updateOrder = true})
end
def.method("string", "number", "table", "table").AddLoginHistoryEx = function(self, username, serverId, roleList, params)
  self._lastUserName = username
  self._catchedHistoryMap = self._catchedHistoryMap or {}
  self._catchedHistoryMap[username] = self._catchedHistoryMap[username] or {}
  local newRecord = {serverId = serverId, roleList = roleList}
  local serverList = self._catchedHistoryMap[username]
  local serverCount = #serverList
  local pos = math.min(serverCount + 1, LoginUtility.RECENT_SERVER_RECORD_MAX)
  for i, server in ipairs(serverList) do
    if server.serverId == serverId then
      pos = i
      break
    end
  end
  if serverCount >= pos then
    table.remove(serverList, pos)
  elseif serverCount >= LoginUtility.RECENT_SERVER_RECORD_MAX then
    table.remove(serverList, serverCount)
  end
  if params.updateOrder then
    table.insert(serverList, 1, newRecord)
  else
    table.insert(serverList, pos, newRecord)
  end
end
def.method().SaveLoginHistory = function(self)
  if self._catchedHistoryMap then
    local newHistory = {
      version = LoginUtility.LOGIN_HISTORY_VERSION,
      last_user_name = self._lastUserName,
      history_map = nil
    }
    local oldHistory = self:LoadLoginHistory()
    if oldHistory then
      newHistory.history_map = oldHistory.history_map
    end
    newHistory.history_map = newHistory.history_map or {}
    for userName, history in pairs(self._catchedHistoryMap) do
      newHistory.history_map[userName] = history
    end
    local configPath = string.format("%s/%s", Application.persistentDataPath, LoginUtility.LOGIN_HISTORY_CONFIG_NAME)
    require("Main.Common.LuaTableWriter").SaveTable("LoginHistory", configPath, newHistory)
  end
end
def.static("=>", "table").GetServerConfigList = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SERVER_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgList = {}
  for i = 0, count - 1 do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i)
    local cfg = LoginUtility._GetServerCfg(entry)
    cfgList[cfg.serverNo] = cfg
  end
  return cfgList
end
def.static("number", "=>", "table").GetServerCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SERVER_CFG, id)
  if record == nil then
    warn("GetServerCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = LoginUtility._GetServerCfg(record)
  return cfg
end
def.static("userdata", "=>", "table")._GetServerCfg = function(record)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.serverAddr = record:GetStringValue("serverAddr")
  cfg.serverBeginPort = record:GetIntValue("serverBeginPort")
  cfg.serverEndPort = record:GetIntValue("serverEndPort")
  cfg.type = record:GetIntValue("type")
  cfg.serverNo = record:GetIntValue("serverNo") + 1
  cfg.serverName = record:GetStringValue("serverName")
  return cfg
end
def.static("string", "=>", "number").GetServerCfgConsts = function(key)
  local value = _G.constant.ServerConfigConsts[key]
  if value == nil then
    warn("GetServerCfgConsts(" .. key .. ") return nil")
    return 0
  end
  return value
end
def.static("=>", "string").GetRandomLoginBGResPath = function()
  local loginCfg = require("Main.Login.data.loginCfg")
  local bgMusicIdList = loginCfg.bgMusicIdList
  local resCount = #bgMusicIdList
  local selectedIndex = math.random(1, resCount)
  local audioId = bgMusicIdList[selectedIndex]
  local resPath = require("Sound.SoundData").Instance():GetSoundPath(audioId)
  return resPath
end
local createRoleCfgs
local genKeyFromOG = function(occupationId, gender)
  return bit.lshift(occupationId, 2) + gender
end
def.static("=>", "table").GetAllCreateRoleCfgs = function()
  if createRoleCfgs == nil then
    createRoleCfgs = {}
    local entries = DynamicData.GetTable(CFG_PATH.DATA_CREATE_ROLE_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local cfg = {}
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
      cfg.occupationId = record:GetIntValue("occupationId")
      cfg.gender = record:GetIntValue("gender")
      cfg.bgImageId = record:GetIntValue("occupationBg")
      cfg.poemImageId = record:GetIntValue("occupationIconId")
      cfg.artisticFontId = record:GetIntValue("occupationFontId")
      cfg.mainFXId = record:GetIntValue("occupationJieMianEffectId")
      cfg.modelId = record:GetIntValue("modelId")
      cfg.model2dId = record:GetIntValue("ROLE_PIC_ID") or 0
      cfg.defaultClothDryId = record:GetIntValue("DEFAULT_CLOTH_DRY_ID") or 0
      cfg.defaultHairDryId = record:GetIntValue("DEFAULT_HAIR_DRY_ID") or 0
      cfg.weaponFXId = record:GetIntValue("WEAPON_EFFECT_ID") or 0
      cfg.desc = record:GetStringValue("desc")
      cfg.aniName = record:GetStringValue("action")
      cfg.isOpen = record:GetCharValue("isOpen") == 1 and true or false
      cfg.skillIdList = {}
      local itemsStruct = record:GetStructValue("skillIdStruct")
      local size = itemsStruct:GetVectorSize("skillIdVector")
      for i = 0, size - 1 do
        local vectorRow = itemsStruct:GetVectorValueByIdx("skillIdVector", i)
        local skillId = vectorRow:GetIntValue("skillId")
        table.insert(cfg.skillIdList, skillId)
      end
      cfg.audioIdList = {}
      local itemsStruct = record:GetStructValue("audioIdStruct")
      local size = itemsStruct:GetVectorSize("audioIdVector")
      for i = 0, size - 1 do
        local vectorRow = itemsStruct:GetVectorValueByIdx("audioIdVector", i)
        local audioId = vectorRow:GetIntValue("audioId")
        table.insert(cfg.audioIdList, audioId)
      end
      createRoleCfgs[genKeyFromOG(cfg.occupationId, cfg.gender)] = cfg
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  return createRoleCfgs
end
def.static("number", "number", "=>", "table").GetCreateRoleCfg = function(occupationId, gender)
  local createRoleCfgs = LoginUtility.GetAllCreateRoleCfgs()
  return createRoleCfgs[genKeyFromOG(occupationId, gender)]
end
local loginBG
def.static().CreateLoginBackground = function()
  LoginUtility.HideWorldRelated()
  if loginBG then
    loginBG:SetActive(true)
    return
  end
  local Vector3 = require("Types.Vector").Vector3
  local loginBGPrefab = GameUtil.SyncLoad(RESPATH.PREFAB_LOGIN_DYNAMIC_BG_RES)
  if loginBGPrefab then
    local GUIUtils = require("GUI.GUIUtils")
    loginBG = GameObject.Instantiate(loginBGPrefab)
    loginBG.localPosition = Vector3.zero
    GUIUtils.ScaleToNoBorder(loginBG, 2)
  else
    loginBG = GameObject.GameObject("LoginBG_None")
    loginBG.localPosition = Vector3.zero
  end
  local camera = loginBG:GetComponentInChildren("Camera")
  if camera == nil then
    camera = loginBG:AddComponent("Camera")
  end
  camera.depth = 1
  camera.orthographic = true
  camera.orthographicSize = 1
  camera.nearClipPlane = -10
  camera.farClipPlane = 10
  camera.cullingMask = get_cull_mask(ClientDef_Layer.Default)
  camera.backgroundColor = Color.black
  camera.clearFlags = CameraClearFlags.SolidColor
  GameUtil.AddGlobalTimer(0, true, function()
    LoginUtility.PlayLoginBGM()
  end)
  GameUtil.DestroyGameUpdateBackgroundDialog()
end
def.static().DestroyLoginBackground = function()
  if loginBG then
    GameObject.Destroy(loginBG)
    loginBG = nil
  end
end
def.static().HideLoginBackground = function()
  if loginBG then
    loginBG:SetActive(false)
  end
end
def.static().HideWorldRelated = function()
  local ECGame = require("Main.ECGame")
  gmodule.moduleMgr:GetModule(ModuleId.MAP):HideMap()
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):DestroyTerrain()
  ECGame.Instance().m_2DWorldCamObj:SetActive(false)
  ECGame.Instance().m_Main3DCam:SetActive(false)
end
def.static("=>", "userdata").GetStaticLoginBackgroundObj = function()
  local uiRoot = GUIRoot.GetUIRootObj()
  return uiRoot:FindDirect("panel_loginbackground(Clone)")
end
def.static().PlayLoginBGM = function()
  local resPath = LoginUtility.GetRandomLoginBGResPath()
  require("Sound.ECSoundMan").Instance():PlayBackgroundMusic(resPath, true)
end
def.static("=>", "table").GetPhoneArg = function()
  local PhoneArg = require("netio.protocol.mzm.gsp.PhoneArg")
  local os = PhoneArg.OS_UNKNOWN
  if Application.platform == RuntimePlatform.IPhonePlayer then
    os = PhoneArg.OS_IOS
  elseif Application.platform == RuntimePlatform.Android then
    os = PhoneArg.OS_ANDROID
  end
  local macAddress = ""
  if GameUtil.GetMacAddress then
    macAddress = GameUtil.GetMacAddress()
  end
  local deviceInfo = LoginUtility.GetDeviceInfo()
  return PhoneArg.new(macAddress, os, unpack(deviceInfo))
end
def.static("=>", "table").GetDeviceInfo = function()
  local PhoneArg = require("netio.protocol.mzm.gsp.PhoneArg")
  local devicesystem = SystemInfo.operatingSystem
  local devicemodel = SystemInfo.deviceModel
  local networktype
  if GameUtil.IsWirelessNetwork() then
    networktype = PhoneArg.NET_SHUJUWANGLUO
  else
    networktype = PhoneArg.NET_WIFI
  end
  local width = Screen.width
  local height = Screen.height
  local deviceId = ""
  local deviceInfo = {
    devicesystem,
    devicemodel,
    networktype,
    width,
    height,
    deviceId
  }
  LoginUtility.GetLoginArg()
  return deviceInfo
end
def.static("number", "number", "table", "number", "userdata").DataToAuany = function(dir, reqtype, reqdata, reserved1, reserved2)
  local sdkInfo = ECMSDK.GetMSDKInfo()
  local Json = require("Utility.json")
  local DataBetweenAuanyAndOthersReq = require("netio.protocol.openau.DataBetweenAuanyAndOthersReq")
  local account = require("Main.ECGame").Instance():GetUserNameWithZoneId()
  local accountOctets = Octets.rawFromString(account)
  local zoneId = require("netio.Network").m_zoneid
  local roleId = _G.GetMyRoleID()
  if roleId then
    local reqData = Octets.rawFromString(Json.encode(reqdata))
    local p = DataBetweenAuanyAndOthersReq.new(dir, accountOctets, zoneId, roleId, reqtype, reqData, reserved1, reserved2)
    gmodule.network.sendProtocol(p)
    warn("Send DataBetweenAuanyAndOthersReq Success")
  else
    warn("Try to Send DataBetweenAuanyAndOthersReq, but roleID == nil, means client is not login!")
  end
end
def.static("=>", "table").GetLoginArg = function(self)
  local ECGame = require("Main.ECGame")
  local DeviceUtility = require("Utility.DeviceUtility")
  local loginArg = {}
  local appId = "1"
  local channelId = "1"
  local registerChannelid = "1"
  local platid = LoginArg.PLAT_PC
  local loginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
  local isFakePlatform = loginModule:IsFakeLoginPlatform()
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    local sdkInfo = ECMSDK.GetMSDKInfo()
    appId = sdkInfo and sdkInfo.appId or ""
    channelId = ECMSDK.GetChannelID()
    registerChannelid = ECMSDK.GetRegisterChannelID()
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
      appId = "G_" .. appId
    end
    if platform == Platform.ios then
      platid = LoginArg.PLAT_IOS
    elseif platform == Platform.android then
      if isFakePlatform then
        local loginPlatform = loginModule:GetLoginPlatform()
        if loginPlatform == Platform.ios then
          platid = LoginArg.PLAT_IOS
        end
      else
        platid = LoginArg.PLAT_ANDROID
      end
    else
      platid = LoginArg.PLAT_PC
    end
  elseif ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
    local ECUniSDK = require("ProxySDK.ECUniSDK")
    appId = ECUniSDK.Instance():GetUniAppId()
    channelId = ECUniSDK.Instance():GetChannelType()
    if platform == Platform.ios then
      platid = EFunLoginPlat.EFUN_PLAT_IOS
    elseif platform == Platform.android then
      platid = EFunLoginPlat.EFUN_PLAT_ANDROID
    else
      platid = EFunLoginPlat.EFUN_PLAT_PC
    end
  end
  loginArg.gameAppid = appId
  loginArg.channelid = channelId
  loginArg.registerChannelid = registerChannelid
  loginArg.platid = platid
  loginArg.fakePlatform = isFakePlatform and 1 or 0
  local providerName = DeviceUtility.GetNetworkProviderName()
  local provider
  if providerName == DeviceUtility.Constants.NETWORK_PROVIDER_CMCC then
    provider = LoginArg.CMCC
  elseif providerName == DeviceUtility.Constants.NETWORK_PROVIDER_CUCC then
    provider = LoginArg.CUCC
  elseif providerName == DeviceUtility.Constants.NETWORK_PROVIDER_CTC then
    provider = LoginArg.CTC
  else
    provider = LoginArg.UNKNOW
  end
  loginArg.telecomOper = provider
  loginArg.paramMap = {}
  loginArg.paramMap[LoginArg.KEY_CLIENT_VERSION] = ECGame.Instance():getClientVersion()
  loginArg.paramMap[LoginArg.KEY_SYSTEM_SOFTWARD] = SystemInfo.operatingSystem
  loginArg.paramMap[LoginArg.KEY_SYSTEM_HARDWARD] = SystemInfo.deviceModel
  local networktype = ""
  if GameUtil.IsWirelessNetwork() then
    networktype = "WIFI"
  else
    networktype = "MOBILE"
  end
  loginArg.paramMap[LoginArg.KEY_NETWORK] = networktype
  loginArg.paramMap[LoginArg.KEY_SCREEN_WIDTH] = Screen.width
  loginArg.paramMap[LoginArg.KEY_SCREEN_HIGHT] = Screen.height
  loginArg.paramMap[LoginArg.KEY_DENSITY] = Screen.dpi
  local cpuInfo = string.format("processorCount=%d,processorType=%s", SystemInfo.processorCount, SystemInfo.processorType)
  loginArg.paramMap[LoginArg.KEY_CPU_HARDWARD] = cpuInfo
  loginArg.paramMap[LoginArg.KEY_MEMORY] = SystemInfo.systemMemorySize
  loginArg.paramMap[LoginArg.KEY_GLRENDER] = SystemInfo.graphicsDeviceName
  loginArg.paramMap[LoginArg.KEY_GL_VERSION] = SystemInfo.graphicsDeviceVersion
  loginArg.paramMap[LoginArg.KEY_DEVICEID] = SystemInfo.deviceUniqueIdentifier
  loginArg.paramMap[LoginArg.KEY_LOGIN_PRIVILEGE_TYPE] = ECMSDK.GetLoginPrivilegeType()
  return loginArg
end
def.static("string", "=>", "string").ConvertBanLoginErrorInfo = function(errorInfo)
  if errorInfo == nil then
    warn("ConvertBanLoginErrorInfo: errorInfo is nil!")
    return ""
  end
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local Json = require("Utility.json")
  local forbidInfo = Json.decode(errorInfo)
  if forbidInfo == nil then
    return "json decode error"
  end
  local ret
  local endtime = tonumber(forbidInfo.endtime)
  local msg = forbidInfo.msg
  if msg == nil or msg == "" then
    msg = textRes.Login[65]
  end
  local timeStr
  if endtime and endtime > 0 then
    timeStr = os.date("%Y-%m-%d %H:%M", endtime)
  end
  if timeStr then
    ret = textRes.IDIP[9]:format(msg, timeStr)
  else
    ret = textRes.IDIP[14]:format(msg)
  end
  ret = HtmlHelper.ConvertHtmlColorToBBCode(ret)
  return ret
end
def.static("=>").DestroyAllLoginUI = function()
  require("Main.Login.ui.LoginMainPanel").Instance():DestroyPanel()
  require("Main.Login.ui.CreateRolePanel").Instance():DestroyPanel()
  require("Main.Login.ui.ChooseServerPanel").Instance():DestroyPanel()
  require("Main.Login.ui.SelectRolePanel").Instance():DestroyPanel()
  createRoleCfgs = nil
end
def.static("=>").Preload = function()
  require("Main.Item.ItemUtils").CacheItemBaseData()
  require("Main.Equip.EquipUtils").CacheAllWeaponColor()
end
def.static("=>", "number").GetForbidDeleteRoleMinLevel = function()
  local HeroUtility = require("Main.Hero.HeroUtility")
  return HeroUtility.Instance():GetRoleCommonConsts("CAN_NOT_DELETE_ROLE_MORE_THAN_LEVEL") or 0
end
def.static().StartAuroraSdk = function()
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.AuroraSdkStart(16, 16, 0)
    isAuroraStarted = true
  end
end
def.static().StopAuroraSdk = function()
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK and isAuroraStarted then
    isAuroraStarted = false
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.AuroraSdkStop()
  end
end
return LoginUtility.Commit()
