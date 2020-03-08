local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local EC = require("Types.Vector3")
local RECT = require("Types.Rect")
local AnonymousEventManager = require("Utility.AnonymousEvent").AnonymousEventManager
local ECModel = require("Model.ECModel")
local ECFxMan = require("Fx.ECFxMan")
local ECSoundMan = require("Sound.ECSoundMan")
local ECMSDK = require("ProxySDK.ECMSDK")
local ECUniSDK = require("ProxySDK.ECUniSDK")
require("Main.ECConfigs")
require("Common.ECClientDef")
require("Common.CfgPath")
require("Event.Event").Instance()
require("Main.Common.Utils")
local ECGame = Lplus.Class("ECGame")
local def = ECGame.define
def.const(AnonymousEventManager).EventManager = AnonymousEventManager()
def.field("string").m_UserName = ""
def.field("string").m_Password = ""
def.field("string").m_ServerIP = ""
def.field("userdata").m_roleid = nil
def.field("string").m_roleName = ""
def.field("number").m_roleLevel = 0
def.field("number").m_mapid = 0
def.field("number").m_mapx = 0
def.field("number").m_mapy = 0
def.field("number").m_ServerPort = 0
def.field("table").m_MainHostPlayer = nil
def.field("userdata").m_2DWorldCamObj = nil
def.field("userdata").m_2DWorldCam = nil
def.field("userdata").m_Main3DCam = nil
def.field("userdata").m_Main3DCamComponent = nil
def.field("userdata").m_Fly3DCam = nil
def.field("userdata").m_Fly3DCamComponent = nil
def.field("userdata").m_cloudCam = nil
def.field("userdata").m_fightCam = nil
def.field(ECGUIMan).m_GUIMan = nil
def.field("number").m_GCTimer = 0
def.field("number").m_Game1sTimer = 0
def.field("userdata").m_postCam = nil
def.field("number").m_IsLogin = 0
def.field("boolean").m_bCreateConsole = false
def.field("boolean").m_isInFight = false
def.field("table").m_cameraTaken = nil
def.field("number").m_scale2d = 1
def.field("number").m_scale3d = 1
def.field("boolean").mGCFlag = false
def.field("table").m_AllGuiResList = nil
def.field("boolean").m_ScreenDark = false
def.field("number").m_DarkScreenTimer = 0
def.field("number").m_AutoTimer = 0
def.field("boolean").m_inGameLogic = false
def.field("number").m_GameState = 0
def.field("table").m_HistoryGameState = nil
def.field("number").m_refreshDirTimer = 0
def.field("boolean").m_skipClickGroundOnce = false
local _max_destroy_count = 10
def.static("=>", ECGame).new = function()
  local obj = ECGame()
  obj.m_AllGuiResList = {}
  return obj
end
local theGame
def.static("=>", ECGame).Instance = function()
  return theGame
end
def.method("string", "string", "string", "number").SetUserName = function(self, name, pwd, server, port)
  self.m_UserName = name
  self.m_Password = pwd
  self.m_ServerIP = server
  self.m_ServerPort = port
end
def.method("=>", "string").GetUserNameWithZoneId = function(self)
  local _, _, capture = self.m_UserName:find(".+@(%d+)$")
  if not capture then
    local zoneIdStr = tostring(require("netio.Network").m_zoneid)
    return self.m_UserName .. "@" .. zoneIdStr
  else
    return self.m_UserName
  end
end
def.method("string", "number").SetServerInfo = function(self, server, port)
  self.m_ServerIP = server
  self.m_ServerPort = port
end
def.method("userdata", "string", "number").setRoleInfo = function(self, roleid, roleName, roleLevel)
  self.m_roleid = roleid
  self.m_roleName = roleName
  self.m_roleLevel = roleLevel
end
def.method("number", "number", "number").setMapInfo = function(self, mapid, mapx, mapy)
  self.m_mapid = mapid
  self.m_mapx = mapx
  self.m_mapy = mapy
end
def.method("number", "number").setMapPosInfo = function(self, mapx, mapy)
  self.m_mapx = mapx
  self.m_mapy = mapy
end
local _3d_cam_dir = EC.Vector3.new(0, -math.sin(cam_3d_rad), 1)
_3d_cam_dir:Normalize()
def.method("number", "number", "=>", "userdata").Create3DCamera = function(self, iWindowWidth, iWindowHeight)
  local cam3dObj = GameObject.GameObject("Main3DCamera")
  local cam = cam3dObj:AddComponent("Camera")
  cam.clearFlags = CameraClearFlags.Nothing
  cam:set_cullingMask(get_cull_mask(ClientDef_Layer.Player) + get_cull_mask(ClientDef_Layer.NPC))
  cam:set_orthographic(true)
  cam.orthographicSize = iWindowHeight / 2 * cam_2d_to_3d_scale
  self.m_scale3d = cam.orthographicSize
  cam.depth = CameraDepth.Main3D
  cam.nearClipPlane = -200
  cam.farClipPlane = 200
  cam3dObj.position = EC.Vector3.new(0, 0, 0)
  cam3dObj.rotation = Quaternion.Euler(EC.Vector3.new(cam_3d_degree, 0, 0))
  self.m_Main3DCam = cam3dObj
  self.m_Main3DCamComponent = cam
  CommonCamera.game3DCamera = cam
  return cam3dObj
end
def.method("number", "number", "=>", "userdata").Create3DFlyCamera = function(self, iWindowWidth, iWindowHeight)
  local cam3dObj = GameObject.GameObject("Fly3DCamera")
  local cam = cam3dObj:AddComponent("Camera")
  cam.clearFlags = CameraClearFlags.Nothing
  cam:set_cullingMask(get_cull_mask(ClientDef_Layer.FlyPlayer) + get_cull_mask(ClientDef_Layer.FlyNpc))
  cam:set_orthographic(true)
  cam.orthographicSize = iWindowHeight / 2 * cam_2d_to_3d_scale
  cam.depth = CameraDepth.FLY
  cam.nearClipPlane = -500
  cam.farClipPlane = 500
  cam3dObj.position = EC.Vector3.new(0, 0, 0)
  cam3dObj.rotation = Quaternion.Euler(EC.Vector3.new(cam_3d_degree, 0, 0))
  self.m_Fly3DCam = cam3dObj
  self.m_Fly3DCamComponent = cam
  CommonCamera.gameFlyCamera = cam
  return cam3dObj
end
def.method("number", "number", "=>", "userdata").CreateCloudCamera = function(self, iWindowWidth, iWindowHeight)
  local cam3dObj = GameObject.GameObject("CloudCam")
  local cam = cam3dObj:AddComponent("Camera")
  cam.clearFlags = CameraClearFlags.Nothing
  cam:set_cullingMask(get_cull_mask(ClientDef_Layer.Cloud))
  cam:set_orthographic(true)
  cam.orthographicSize = 3
  cam.depth = CameraDepth.CLOUD_UP
  cam.nearClipPlane = -500
  cam.farClipPlane = 500
  cam3dObj.position = EC.Vector3.new(0, 0, 0)
  cam3dObj.rotation = Quaternion.Euler(EC.Vector3.new(0, 0, 0))
  self.m_cloudCam = cam3dObj
  local function OnCloudLoad(obj)
    local cloud1 = Object.Instantiate(obj, "GameObject")
    cloud1.name = require("Main.Fly.FlyModule").YunCai .. "1"
    cloud1.transform.parent = self.m_cloudCam.transform
    cloud1.transform.localScale = EC.Vector3.new(2, 1, 1)
    cloud1.transform.localRotation = Quaternion.Euler(EC.Vector3.new(90, 0, 0))
    cloud1.transform.localPosition = EC.Vector3.new(0, 0, 0)
    cloud1:SetLayer(ClientDef_Layer.Cloud)
    cloud1:SetActive(false)
    local cloudCtrl1 = cloud1:AddComponent("CloudController")
    cloudCtrl1.k = 0
    cloudCtrl1.defaultX = 0
    cloudCtrl1.defaultY = 0
    cloudCtrl1.refobj = self.m_2DWorldCamObj
    self.m_cloudCam:SetActive(false)
  end
  GameUtil.AsyncLoad(RESPATH.Cloud, OnCloudLoad)
  return cam3dObj
end
def.method().CreateModelOulineCamera = function(self)
  GameUtil.AsyncLoad(RESPATH.ModelOutlineShader, function(sh)
    local postCam = self.m_MainCam:AddComponent("MainPostCamera")
    local camobj = GameObject.GameObject("Model Outline Camera")
    local cam = camobj:AddComponent("Camera")
    postCam.postCam = cam
    postCam.postShader = sh
    postCam.CullMask = get_cull_mask(ClientDef_Layer.HostPlayer)
    postCam.PostCullMask = default_cull_mask_post
    self.m_postCam = postCam
    cam.enabled = false
    self.m_ModelOutlineCam = camobj
  end)
end
def.method("=>", "number").DecideQualityLevel = function(self)
  print(SystemInfo.graphicsDeviceVersion)
  if platform == 1 then
    local gen = iPhone.generation
    if gen == 0 then
      return 3
    elseif gen < iPhoneGeneration.iPad4Gen or gen == iPhoneGeneration.iPhone5C then
      return 1
    elseif gen < iPhoneGeneration.iPhone5S then
      return 2
    else
      return 3
    end
  elseif platform == 2 then
    local xiaomi = 0
    if SystemInfo.deviceModel ~= nil and SystemInfo.deviceModel:lower():find("xiaomi") then
      xiaomi = 1
    end
    if SystemInfo.processorCount >= 4 and SystemInfo.systemMemorySize > 1600 then
      if SystemInfo.graphicsDeviceVersion:find("^OpenGL ES 2") then
        return 2 - xiaomi
      end
      if Screen.height > 1000 then
        return 3 - xiaomi
      else
        return 2 - xiaomi
      end
    else
      return 1
    end
  end
  return 3
end
def.method("number", "boolean").SetQualityLevel = function(self, lev, init)
  if lev == 1 then
    if init then
      QualitySettings.blendWeights = 2
      if platform == 1 then
        QualitySettings.masterTextureLimit = 1
      else
        QualitySettings.masterTextureLimit = 1
      end
    end
    max_frame_rate = 30
    max_show_players = GetSysConstCfg("screenLv1")
  elseif lev == 2 then
    if init then
      QualitySettings.blendWeights = 2
      if platform == 1 then
        QualitySettings.masterTextureLimit = 1
      else
        QualitySettings.masterTextureLimit = 0
      end
    end
    if platform == 2 then
      max_frame_rate = 30
    end
    _G.max_fx_count = 128
    max_show_players = GetSysConstCfg("screenLv2")
  else
    if init then
      QualitySettings.blendWeights = 2
      QualitySettings.masterTextureLimit = 0
    end
    if platform == 1 then
      _G.max_frame_rate = 30
    end
    _G.max_fx_count = 128
    max_show_players = GetSysConstCfg("screenLv3")
  end
end
def.method().Init2DWorld = function(self)
  local screenwidth = Screen.width
  local screenheight = Screen.height
  local fRate = screenwidth / screenheight
  local iWindowWidth, iWindowHeight
  if fRate < 1.49 then
    iWindowWidth = 960
    iWindowHeight = math.floor(iWindowWidth / fRate)
  else
    iWindowHeight = 640
    iWindowWidth = math.floor(iWindowHeight * fRate)
  end
  local camobj = GameObject.GameObject("2DWorldCamera")
  camobj.localPosition = EC.Vector3.new(0, 0, -100)
  camobj.tag = "MainCamera"
  local cam = camobj:AddComponent("Camera")
  cam.clearFlags = CameraClearFlags.SolidColor
  cam.backgroundColor = Color.black
  cam.orthographic = true
  cam.orthographicSize = iWindowHeight / 2
  self.m_scale2d = cam.orthographicSize
  cam.nearClipPlane = -500
  cam.farClipPlane = 500
  cam.depth = CameraDepth.MAP
  self.m_2DWorldCamObj = camobj
  self.m_2DWorldCam = cam
  cam:set_cullingMask(get_cull_mask(ClientDef_Layer.Default))
  MainLogic.Init(screenwidth, screenheight, iWindowWidth, iWindowHeight)
  CommonCamera.game2DCamera = cam
  self:Create3DCamera(iWindowWidth, iWindowHeight)
  self:Create3DFlyCamera(iWindowWidth, iWindowHeight)
  self:CreateCloudCamera(iWindowWidth, iWindowHeight)
end
local defshaderlist = {}
local l_print = print
function _G.EnablePrint(enable)
  if enable then
    _G.print = l_print
  else
    function _G.print()
    end
  end
end
local luagctimer = 0
local slow_gc = false
local function real_gc(isunloadassets)
  if isunloadassets and not _G.unload_unused_func_call then
    _G.unload_unused_func_call = true
    GameUtil.UnloadUnusedAssets(function()
      _G.unload_unused_func_call = false
    end)
  end
  if luagctimer == 0 then
    luagctimer = GameUtil.AddGlobalTimer(0, false, function()
      local step
      if slow_gc then
        step = 25
      else
        step = 50
      end
      local starttm = Time.realtimeSinceStartup
      if _G.isDebugBuild then
        GameUtil.BeginSamp("collectgarbage step")
      end
      local bFinish = collectgarbage("step", step)
      if _G.isDebugBuild then
        GameUtil.EndSamp()
      end
      if Time.realtimeSinceStartup - starttm > 0.002 then
        slow_gc = true
      end
      if bFinish then
        GameUtil.RemoveGlobalTimer(luagctimer)
        luagctimer = 0
        slow_gc = false
      end
    end)
  end
end
local fullgccount = 0
local function total_gc()
  local function cache_gc(full)
    local cur_count = GameUtil.UpdateResCache(_max_destroy_count)
    if cur_count < _max_destroy_count then
      real_gc(full)
      return
    end
    GameUtil.AddGlobalTimer(0.3, true, function()
      cache_gc(full)
      ECGame.Instance():GCTLog("freq")
    end)
  end
  _G.LastGCTime = Time.time
  if fullgccount < 5 then
    cache_gc(false)
    fullgccount = fullgccount + 1
  elseif ECGame.Instance().m_isInFight then
    cache_gc(false)
  else
    cache_gc(true)
    fullgccount = 0
  end
end
def.method("boolean").DelayGC = function(self, isunloadassets)
  if _G.isDebugBuild then
    GameUtil.AddGlobalTimer(0, true, function()
      GameUtil.BeginSamp("DelayGC")
      GameUtil.EndSamp()
    end)
  end
  if self.mGCFlag then
    return
  end
  self.mGCFlag = true
  GameUtil.ResetGlobalTimer(self.m_GCTimer)
  GameUtil.RemoveAllResCache()
  GameUtil.UIReleaseInactive(32)
  real_gc(isunloadassets)
end
def.method().SyncGC = function(self)
  GameUtil.RemoveAllResCache()
  GameUtil.UIReleaseInactive(32)
  if _G.isDebugBuild then
    GameUtil.BeginSamp("collectgarbage")
    collectgarbage("collect")
    GameUtil.EndSamp()
  else
    collectgarbage("collect")
  end
  GameUtil.GC()
  if not _G.unload_unused_func_call then
    _G.unload_unused_func_call = true
    GameUtil.UnloadUnusedAssets(function()
      _G.unload_unused_func_call = false
    end)
  end
  GameUtil.ResetGlobalTimer(self.m_GCTimer)
  _G.LastGCTime = Time.time
end
local _font_asset
def.method().Init = function(self)
  local camera = GUIRoot.GetCamera()
  camera.depth = CameraDepth.GUI
  if _G.ui_use_global_notify then
    if GameUtil.SetUseNGUIGlobalNotify then
      GameUtil.SetUseNGUIGlobalNotify(true)
    else
      _G.ui_use_global_notify = false
    end
  end
  MainLogic.LuaCreate()
  warn("Game Init: " .. Time.realtimeSinceStartup)
  RenderSettings.fog = 0
  RenderSettings.fogMode = 1
  collectgarbage("setpause", 150)
  GameUtil.SetMaxResCacheCount(16)
  GameUtil.SetFileLoaderPriorityForMap(3)
  Screen.sleepTimeout = -1
  if Application.platform == RuntimePlatform.IPhonePlayer then
    platform = 1
  elseif Application.platform == RuntimePlatform.Android then
    platform = 2
  end
  if _G.log_file_flag then
    utility.AFileSetMainThreadId()
    utility.AFileSetLogOutput(false)
  end
  print(("platform: %s, AssetPath: %s"):format(tostring(platform), GameUtil.GetAssetsPath()))
  require("Main.Common.Timer").Instance()
  require("Main.module.Module")
  _G.cur_quality_level = self:DecideQualityLevel()
  self:SetQualityLevel(_G.cur_quality_level, true)
  do
    local seed = GameUtil.GenRandomSeed()
    math.randomseed(seed)
    print(("randomseed: 0x%08x"):format(seed))
    function math.randomseed()
      error("should not call randomseed when game running")
    end
  end
  local pre_sh = {
    "Shaders/Fx/Particle/Clip/ParticleAdd_Clip.shader.u3dext",
    "Shaders/Fx/Particle/Clip/ParticleAlphaBlend_Clip.shader.u3dext"
  }
  for i = 1, #pre_sh do
    local sh = GameUtil.SyncLoad(pre_sh[i])
    if sh then
      GameUtil.AddPreloadShader(sh)
    end
  end
  GameUtil.AsyncLoad("Arts/Fonts/Fangzheng.TTF.u3dext", function(obj)
    if _G.platform == 2 then
      NGUIText.finalSize = 200
      NGUIText.fontStyle = 0
      NGUIText.dynamicFont = obj
      local txt = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-*&()#@~!{}"
      NGUIText.Prepare(txt)
      NGUIText.finalSize = 0
      NGUIText.fontStyle = 0
      NGUIText.dynamicFont = nil
    end
    _font_asset = obj
  end)
  self:Init2DWorld()
  ECSoundMan.Instance():Init()
  if not ClientCfg.IsSurportApollo() then
    local ECSpeechUtil = require("Chat.ECSpeechUtil")
    local ECTalkRay = require("Chat.ECTalkRay")
    ECSpeechUtil.Instance():speech_init()
    ECTalkRay.Instance():InitTalkRay()
  end
  ECFxMan.Instance():Init()
  Application.set_targetFrameRate(60)
  GameUtil.SetCreateImmidiateThreshold(102400)
  self.m_GCTimer = GameUtil.AddGlobalTimer(60, false, total_gc)
  self.m_Game1sTimer = GameUtil.AddGlobalTimer(1, false, function()
    self:Game1sTimerCallback()
  end)
  require("Main.Common.SensitiveWordsFilterMgr").Init()
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    if not MSDK_ENABLED then
      error("Lack MSDK_ENABLED Macro")
    end
    ECMSDK.Instance():InitMSDK()
  elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
    ECUniSDK.Instance():Init()
  end
  require("Utility.ECUtility")
  if ClientCfg.IsSurportApollo() then
    local ECApollo = require("ProxySDK.ECApollo")
    ECApollo.Instance():Init()
  end
  if platform == 1 and sdktype == ClientCfg.SDKTYPE.MSDK then
    local ECReplayKit = require("ProxySDK.ECReplayKit")
    ECReplayKit.Instance():Init()
  elseif platform == 2 then
    local ECQQEC = require("ProxySDK.ECQQEC")
    ECQQEC.Instance():Init()
  end
  Application.set_runInBackground(true)
  local function on_cg_event(start, identity, dramaTable)
    if start == false then
      GameUtil.AddGlobalTimer(0.2, true, function()
        self:SyncGC()
      end)
    end
  end
  local CG = require("CG.CG")
  CG.Instance():SetNotify(on_cg_event)
  self.m_HistoryGameState = {capacity = 5}
end
def.method().InitSystemSetting = function(self)
  local UserDataTable = UserData.Instance()
  local musicValue = 1
  if UserDataTable:GetSystemCfg("MusicToggle") ~= nil then
    local musicToggle = UserDataTable:GetSystemCfg("MusicToggle")
    if not musicToggle then
      musicValue = 0
    end
  end
  ECSoundMan.SetVolume(SOUND_TYPES.BACKGROUND, musicValue)
  local soundValueEnvironment = 1
  local soundValueGUI = 1
  if UserDataTable:GetSystemCfg("SoundToggle") ~= nil then
    local soundToggle = UserDataTable:GetSystemCfg("SoundToggle")
    if not soundToggle then
      soundValueEnvironment = 0
      soundValueGUI = 0
      NGUITools.mGlobalSoundToggle = false
    end
  end
  ECSoundMan.SetVolume(SOUND_TYPES.ENVIRONMENT, soundValueEnvironment)
  ECSoundMan.SetVolume(SOUND_TYPES.GUI, soundValueGUI)
end
local get_render_info = function(m)
  local result = {}
  result.model = m
  local skinrender = m:GetComponentInChildren("SkinnedMeshRenderer")
  result.mesh = skinrender.sharedMesh
  result.mat = skinrender.sharedMaterials
  local bonenames = {}
  local bones = skinrender.bones
  for i = 1, #bones do
    bonenames[i] = bones[i].gameObject.name
  end
  result.bonenames = bonenames
  return result
end
def.method().Start = function(self)
  if not self.m_GUIMan then
    self.m_GUIMan = ECGUIMan.Instance()
    self.m_GUIMan:Init()
    if _G.isDebugBuild then
      Debug.LogWarning("m_GUIMan:Init")
    end
  end
  if _G.isDebugBuild then
    Debug.LogWarning("require")
  end
  require("Main.Common.AbsoluteTimer").Init()
  gmodule.gameStart()
  if _G.isDebugBuild then
    Debug.LogWarning("gameStart")
  end
end
def.method().LoginServer = function(self)
  local userid = "tj2012"
  local pwd = 123456
  local loginType = 0
  local network = require("netio.Network")
  local ip = "10.68.32.20"
  local port = "18700"
  network.setAccountInfo(userid, pwd, loginType)
  network.setServerInfo(ip, port)
  network.login()
end
def.method("number").Tick = function(self, dt)
  ECModel.UpdateLoadedResult(false)
  ZLUtil.tick()
  _G.Timer:Update(dt)
end
def.method("number").UpdateMutilFrameLoadMap = function(self, dt)
  for i, v in pairs(_G.terraintile_muitlLoadmap) do
    local sp = _G.terraintile_map[v[1]]
    if sp ~= nil then
      sp:Load(v[2])
      _G.terraintile_muitlLoadmap[v[1]] = nil
      return
    end
  end
end
def.method("number").LateTick = function(self, dt)
  if gmodule == nil then
    return
  end
  local scene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
  if scene ~= nil then
    if self.m_MainHostPlayer ~= nil and self.m_MainHostPlayer.m_node2d ~= nil and not self.m_MainHostPlayer.m_node2d.isnil and _G.CGPlay == false then
      local x, y, z = self.m_MainHostPlayer.m_node2d:GetPosXYZ()
      MapScene.Update(scene, dt, x, y, _G.IsCamMoveMode)
    end
    if _G.CGPlay then
      local pos = self.m_2DWorldCamObj.localPosition
      MapScene.Update(scene, dt, pos.x, world_height - pos.y, true)
    end
    if not _G.IsMutilFrameLoadMap then
      _G.IsMutilFrameLoadMap = true
      if _G.IsLoadMap then
        _G.MapNodeCount = 0
        local MapUtility = require("Main.Map.MapUtility")
        MapUtility.EndLoading()
      end
    end
  end
  _G.max_player_loaded_per_frame = 0
  _G.terrain_tile_loaded_per_frame = 0
  _G.terrain_tile_to_load_per_frame = 0
  self.mGCFlag = false
end
def.method("number").OnKeyboard = function(self, k)
  if k == KeyCode.Space then
  elseif k == KeyCode.Escape then
    local lockUI = require("GUI.LockScreenUIPanel")
    if lockUI.Instance().m_panel ~= nil and not lockUI.Instance().m_panel.isnil then
      Toast(textRes.MainUI[4])
      return
    end
    self:OnClickScreen(0, 0)
    if _G.IsOverseasVersion() and ECGUIMan.Instance():MoveBackward() then
      return
    end
    gmodule.moduleMgr:GetModule(ModuleId.SYSTEM_SETTING):Quit()
    self:saveLogoutInfo()
  elseif k == KeyCode.F9 then
    gmodule.moduleMgr:GetModule(ModuleId.MAINUI):ToggleMainUI()
  end
end
def.method("boolean").Pause = function(self, pauseStatus)
  local ECApollo = require("ProxySDK.ECApollo")
  local ECQQEC = require("ProxySDK.ECQQEC")
  local ECReplayKit = require("ProxySDK.ECReplayKit")
  if pauseStatus then
    if _G.platform == 1 and not GameUtil.IsEvaluation() then
      self:ResumeScreenBright()
    end
    local sdktype = ClientCfg.GetSDKType()
    if sdktype == ClientCfg.SDKTYPE.MSDK then
      ECApollo.Pause()
      ECQQEC.OnPause()
    end
    ECReplayKit.PauseBroadcast()
    require("Main.Chat.ChatModule").Instance():SaveChat(true)
    require("Main.Chat.SpeechMgr").Instance():CancelSpeech()
    self:saveLogoutInfo()
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_PAUSE, nil)
  else
    self:OnBrightResumed()
    local sdktype = ClientCfg.GetSDKType()
    if sdktype == ClientCfg.SDKTYPE.MSDK then
      ECApollo.Resume()
      ECQQEC.OnResume()
    end
    ECReplayKit.ResumeBroadcast()
    Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_RESUME, nil)
  end
end
def.method().saveLogoutInfo = function(self)
  local network = require("netio.Network")
  local info = "|205"
  info = info .. "|113"
  info = info .. "|logInterface"
  info = info .. "|?"
  info = info .. "|"
  info = info .. network.m_zoneid
  info = info .. "|"
  info = info .. network.m_aid
  info = info .. "|id|"
  info = info .. self.m_UserName
  info = info .. "|"
  if self.m_roleid ~= nil then
    info = info .. self.m_roleid:tostring()
  end
  info = info .. "|"
  info = info .. self.m_roleName
  info = info .. "|"
  info = info .. self.m_roleLevel
  info = info .. "|"
  info = info .. GameUtil.GetMacAddress()
  info = info .. "|"
  local lastFrames = ECGUIMan.Instance():getLastShowFrames()
  if lastFrames ~= nil then
    local count = #lastFrames
    for i = 1, count do
      if lastFrames[i] ~= nil then
        info = info .. lastFrames[i]
        info = info .. ":"
      end
    end
  end
  info = info .. "|"
  local lastProtocols = network.m_lastSendProtocols
  if lastProtocols ~= nil then
    local count = #lastProtocols
    for i = 1, count do
      if lastProtocols[i] ~= nil then
        info = info .. lastProtocols[i]
        info = info .. ":"
      end
    end
  end
  info = info .. "|"
  lastProtocols = network.m_lastRecvProtocols
  if lastProtocols ~= nil then
    local count = #lastProtocols
    for i = 1, count do
      if lastProtocols[i] ~= nil then
        info = info .. lastProtocols[i]
        info = info .. ":"
      end
    end
  end
  info = info .. "|1"
  info = info .. "|"
  info = info .. self.m_mapid
  info = info .. ":"
  info = info .. self.m_mapx
  info = info .. ":"
  info = info .. self.m_mapy
  info = info .. "|"
  warn(info)
end
def.method("number").SetHighQualityFrame = function(self, level)
  if 3 == level then
    _G.max_frame_rate = 45
  elseif 2 == level then
    _G.max_frame_rate = 30
  else
    _G.max_frame_rate = 20
  end
  Application.set_targetFrameRate(_G.max_frame_rate)
end
def.method().Release = function(self)
  require("Main.Chat.ChatModule").Instance():SaveChat(true)
  if self.m_GUIMan then
    self.m_GUIMan:Release()
  end
  ECFxMan.Instance():Release()
  if not ClientCfg.IsSurportApollo() then
    ECSpeechUtil.Instance():speech_fini()
    ECTalkRay.Instance():RemoveTalkRay()
  end
  GameUtil.RemoveGlobalTimer(self.m_GCTimer)
  self.m_GCTimer = 0
  GameUtil.RemoveGlobalTimer(self.m_Game1sTimer)
  self.m_Game1sTimer = 0
  Application.set_targetFrameRate(60)
  gmodule.network.disConnect()
  if platform == 2 then
    local ECProxySDK = require("ProxySDK.ECProxySDK")
    ECProxySDK.Instance():CleanProxySDK()
  end
  DynamicData.Release()
  self:SetGameState(_G.GameState.None)
  local ECQQEC = require("ProxySDK.ECQQEC")
  ECQQEC.OnDestroy()
  print("ECGame released")
end
local preload = false
def.method().PreLoadRes = function(self)
  if preload then
    return
  end
  local list = self.m_AllGuiResList
  GameUtil.AsyncLoad(RESPATH.EMOJIATLAS, function(obj)
    list[#list + 1] = obj
  end)
end
local _mbsize = 1048576
def.method().ShowStat = function(self)
  GameUtil.RemoveAllStatInfo()
  GameUtil.AddStatInfo(200, 110, 100, 100, string.format("objmap: %d, ecm: %d", GameUtil.GetObjMapCount(), _G.ecmodel_loaded_count))
  GameUtil.AddStatInfo(200, 160, 100, 100, string.format("mono: %.2f, cache: %d", GameUtil.GetMonoTotalMemory() / _mbsize, GameUtil.GetResCacheCount()))
  local lua_mem = collectgarbage("count") / 1024
  local cpp_mem = utility.GetCppMem() / _mbsize
  GameUtil.AddStatInfo(200, 210, 100, 100, string.format("qality: %d, lua_mem: %.2f, cpp_mem: %.2f", _G.cur_quality_level, lua_mem, cpp_mem))
  GameUtil.AddStatInfo(200, 260, 100, 100, "timercount: " .. tostring(GameUtil.GetTotalTimerCount()))
  GameUtil.AddStatInfo(200, 310, 100, 100, string.format("topcostlevel fx: %d, %d %d %d,  %d, %d, %d", FxCacheMan.Instance:get_currentFxCount(), FxCacheMan.GetCurLodCostLevelCount(1, 0), FxCacheMan.GetCurLodCostLevelCount(1, 1), FxCacheMan.GetCurLodCostLevelCount(1, 2), FxCacheMan.GetCurLodCostLevelCount(0, 0), FxCacheMan.GetCurLodCostLevelCount(0, 1), FxCacheMan.GetCurLodCostLevelCount(0, 2)))
end
def.method().SaveStat = function(self)
  local nowSec = GetServerTime()
  local nYear = tonumber(os.date("%Y", endTime))
  local nMonth = tonumber(os.date("%m", endTime))
  local nDay = tonumber(os.date("%d", endTime))
  local nHour = tonumber(os.date("%H", endTime))
  local nMin = tonumber(os.date("%M", endTime))
  local nSec = tonumber(os.date("%S", endTime))
  local lua_mem = collectgarbage("count") / 1024
  local path = string.format("%s/luamem.txt", Application.persistentDataPath)
  local fileHandle, errorMessage = io.open(path, "a")
  if fileHandle == nil then
    error(errorMessage)
    return
  end
  fileHandle:write(string.format("%d-%d-%d  %d:%d:%d  lua_mem = %.2f M\n", nYear, nMonth, nDay, nHour, nMin, nSec, lua_mem))
  fileHandle:close()
end
def.method().Game1sTimerCallback = function(self)
end
local GM_KEY = "dmmhzxnb"
def.method("string", "=>", "boolean").OpenGM = function(self, str)
  str = string.trim(str)
  if str == GM_KEY then
    _G.ToggleDebugConsole()
    return true
  else
    return false
  end
end
def.method("string", "=>", "boolean").DebugString = function(self, str)
  str = string.trim(str)
  if str == GM_KEY then
    _G.ToggleDebugConsole()
    warn(">>> " .. str)
    return true
  end
  if require("Main.ClientCmd").DoClientCmd(str) then
    warn(">>> " .. str)
    return true
  end
  if string.byte(str) == string.byte(".") then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gm.CGMCommand").new(string.sub(str, 2)))
    require("Main.ClientCmd").DoServerCmd(str)
    warn(">>> " .. str)
    return true
  end
  warn(string.format("You input '%s', but nothing happened.(*-_-)", str))
  Toast(string.format("You input '%s', but nothing happened.(*-_-)", str))
  return false
end
local l_allUnityLogs = {}
local l_unityLogErrorCount = 0
local UnityLogEvent = require("Event.SystemEvents").UnityLogEvent
local LogType = UnityLogEvent.LogType
def.method("number", "string").OnUnityLog = function(self, logType, str)
  local maxHalfLen = 300
  if #l_allUnityLogs > maxHalfLen * 2 then
    for i = 1, maxHalfLen do
      l_allUnityLogs[i] = l_allUnityLogs[#l_allUnityLogs - maxHalfLen + i]
    end
    for i = #l_allUnityLogs, maxHalfLen + 1, -1 do
      l_allUnityLogs[i] = nil
    end
  end
  local strEx
  if logType ~= LogType.Warning and logType ~= LogType.Log then
    l_unityLogErrorCount = l_unityLogErrorCount + 1
    strEx = ("ERR#%d %s"):format(l_unityLogErrorCount, str)
    require("GUI.ECPanelDebugInput").Instance():Popup(l_unityLogErrorCount)
  else
    strEx = str
  end
  l_allUnityLogs[#l_allUnityLogs + 1] = logType
  l_allUnityLogs[#l_allUnityLogs + 1] = strEx
  local event = UnityLogEvent()
  event.logType = logType
  event.str = strEx
  ECGame.EventManager:raiseEvent(self, event)
end
def.method("=>", "table").GetUnityLogs = function()
  return l_allUnityLogs
end
def.method().ClearUnityLogs = function(self)
  while #l_allUnityLogs > 0 do
    table.remove(l_allUnityLogs)
  end
  l_unityLogErrorCount = 0
end
def.method("number", "number").OnMoveGround = function(self, x, y)
  if not IsEnteredWorld() or self.m_isInFight or gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsInWedding() or IsWatchingMoon() then
    return
  end
  local map2dPos = ScreenToMap2DPos(x, y)
  if gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInEditMode() then
    return
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  heroModule.needShowAutoEffect = false
  if heroModule:IsPatroling() then
    heroModule:StopPatroling()
  end
  local clickX = map2dPos.x < 0 and 0 or map2dPos.x > world_width and world_width or map2dPos.x
  local clickY = 0 > map2dPos.y and world_height or map2dPos.y > world_height and 0 or world_height - map2dPos.y
  heroModule:MoveTo(gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId, clickX, clickY, -1, 0, MoveType.AUTO, nil)
  local pos = Map2DPosTo3D(clickX, world_height - clickY)
  ECFxMan.Instance():Play(RESPATH.EFFECT_CLICK_GROUND, pos, Quaternion.identity, -1, false, -1)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, {x = clickX, y = clickY})
end
def.method("number", "number").OnClickGround = function(self, x, y)
  if self.m_skipClickGroundOnce then
    self.m_skipClickGroundOnce = false
    return
  end
  if not IsEnteredWorld() or self.m_isInFight or gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):IsInWedding() or IsWatchingMoon() or self.m_cameraTaken and #self.m_cameraTaken > 0 then
    return
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule.myRole == nil then
    return
  end
  if heroModule.myRole:IsInState(RoleState.ROOTS) then
    Toast(textRes.Hero[65])
    return
  end
  heroModule.needShowAutoEffect = false
  if heroModule:IsPatroling() then
    heroModule:StopPatroling()
  end
  local map2dPos = ScreenToMap2DPos(x, y)
  local clickX = 0 > map2dPos.x and 0 or map2dPos.x > world_width and world_width or map2dPos.x
  local clickY = 0 > map2dPos.y and world_height or map2dPos.y > world_height and 0 or world_height - map2dPos.y
  heroModule:MoveTo(gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId, clickX, clickY, -1, 0, MoveType.AUTO, nil)
  ECFxMan.Instance():PlayEffectAt2DPos(RESPATH.EFFECT_CLICK_GROUND, clickX, world_height - clickY)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, {x = clickX, y = clickY})
end
def.method().ResumeScreenBright = function(self)
  if self.m_ScreenDark then
    self.m_ScreenDark = false
    ZLUtil.screenBright(ZLUtil.oldScreenBright())
    Application.set_targetFrameRate(_G.max_frame_rate)
    local SoundModule = require("Main.Sound.SoundModule")
    SoundModule.Instance():UpdateBGMusicSetting()
    SoundModule.Instance():UpdateEffectSoundSetting()
  end
end
def.method().OnBrightResumed = function(self)
  local settingModule = require("Main.SystemSetting.SystemSettingModule")
  local Setting_Module = gmodule.moduleMgr:GetModule(ModuleId.SYSTEM_SETTING)
  local SETTING_ID = settingModule.SystemSetting
  local setting = Setting_Module:GetSetting(SETTING_ID.DrakScreen)
  if setting.isEnabled then
    self:ResetDarkScreenTimer()
  elseif self.m_DarkScreenTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_DarkScreenTimer)
    self.m_DarkScreenTimer = 0
  end
end
def.method().ResetDarkScreenTimer = function(self)
  if self.m_DarkScreenTimer ~= 0 then
    GameUtil.ResetGlobalTimer(self.m_DarkScreenTimer)
  else
    self.m_DarkScreenTimer = GameUtil.AddGlobalTimer(600, true, function()
      self.m_DarkScreenTimer = 0
      local CG = require("CG.CG")
      if _G.CGPlay then
        self:ResetDarkScreenTimer()
        return
      end
      local remain_time = 10
      local msg = string.format(textRes.DarkScreen[1])
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local uiCommon = CommonConfirmDlg.ShowConfirmCoundDown(textRes.DarkScreen[2], msg, "", "", 1, remain_time, ECGame.OnClickDarkScreen, {})
    end)
  end
end
def.static().darkscreen = function()
  if not ECGame.Instance().m_ScreenDark then
    warn("darkscreen !")
    ECGame.Instance().m_ScreenDark = true
    if _G.platform == 2 then
      ZLUtil.screenBright()
      ZLUtil.screenBright(0.02)
    elseif _G.platform == 1 then
      ZLUtil.screenBright()
      ZLUtil.screenBright(0.02)
    end
    if ECGame.Instance().m_inGameLogic then
    end
    local ECSoundMan = require("Sound.ECSoundMan")
    ECSoundMan.SetVolume(SOUND_TYPES.BACKGROUND, 0)
    ECSoundMan.SetVolume(SOUND_TYPES.ENVIRONMENT, 0)
    local ECSoundModule = require("Main.Sound.SoundModule")
    ECSoundModule.Instance():SetFightEffectSoundVolume(0)
  end
end
def.static("number", "table").OnClickDarkScreen = function(clickType, data)
  warn("OnClickDarkScreen", clickType)
  if clickType == 1 then
    ECGame.darkscreen()
  elseif clickType == 0 then
    ECGame.Instance():ResetDarkScreenTimer()
  end
  if ECGame.Instance().m_AutoTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(ECGame.Instance().m_AutoTimer)
    ECGame.Instance().m_AutoTimer = 0
  end
end
def.method("number", "number").OnClickScreen = function(self, x, y)
  if _G.platform == 2 or _G.platform == 1 and not GameUtil.IsEvaluation() then
    local settingModule = require("Main.SystemSetting.SystemSettingModule")
    local Setting_Module = gmodule.moduleMgr:GetModule(ModuleId.SYSTEM_SETTING)
    local SETTING_ID = settingModule.SystemSetting
    local setting = Setting_Module:GetSetting(SETTING_ID.DrakScreen)
    self:ResumeScreenBright()
    if setting.isEnabled then
      self:ResetDarkScreenTimer()
    elseif self.m_DarkScreenTimer ~= 0 then
      GameUtil.RemoveGlobalTimer(self.m_DarkScreenTimer)
      self.m_DarkScreenTimer = 0
    end
  end
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_LEADER_CLICK_SCREEN, nil)
end
def.method("number", "number").OnPostClickScreen = function(self, x, y)
  if not self.m_GUIMan then
    return
  end
  self.m_GUIMan:NotifyDisappear("")
  local uiroot = self.m_GUIMan.m_UIRoot
  if not uiroot then
    return
  end
  local cam = self.m_GUIMan.m_camera
  if not cam then
    return
  end
end
local pos_2dcam = EC.Vector3.new(0, 0, -100)
local pos_3dcam = EC.Vector3.new(0, 0, 0)
local dir_3dcam = EC.Vector3.new(0, 0, 0)
local temp_3dcam = EC.Vector3.new(0, 0, 0)
def.method("number", "number").SetCameraFocus = function(self, x, y)
  if self.m_isInFight or self.m_cameraTaken and #self.m_cameraTaken > 0 then
    return
  end
  local roleHeight = not _G.CGPlay and GetRoleHeight() or 0
  if roleHeight > 0 then
    y = world_height - y + roleHeight
    if y > world_height - self.m_2DWorldCam.orthographicSize then
      y = world_height - self.m_2DWorldCam.orthographicSize
    end
  else
    y = world_height - y
  end
  pos_2dcam.x = x
  pos_2dcam.y = y
  if not _G.CGPlay then
    self.m_2DWorldCamObj.localPosition = pos_2dcam
  end
  Set2DPosTo3D(x, y, pos_3dcam)
  dir_3dcam:Set(self.m_Main3DCam:GetForwardXYZ())
  self.m_Main3DCam.localPosition = temp_3dcam:Assign(pos_3dcam:SubUnpack(dir_3dcam:MulUnpack(15)))
  dir_3dcam:Set(self.m_Fly3DCam:GetForwardXYZ())
  self.m_Fly3DCam.localPosition = temp_3dcam:Assign(pos_3dcam:SubUnpack(dir_3dcam:MulUnpack(15)))
  self.m_GUIMan.m_hudCameraGo.localPosition = pos_2dcam
  self.m_GUIMan.m_hudCameraGo2.localPosition = pos_2dcam
end
def.method("=>", "table").Get2dCameraPos = function(self)
  return pos_2dcam
end
def.method().SetFightCamera = function(self)
  if self.m_fightCam then
    self.m_fightCam:SetActive(true)
    return
  end
  local camobj = GameObject.GameObject("FightSceneCamera")
  local cam = camobj:AddComponent("Camera")
  cam.clearFlags = CameraClearFlags.Depth
  cam.orthographic = true
  cam.orthographicSize = self.m_2DWorldCam.orthographicSize
  cam.nearClipPlane = -500
  cam.farClipPlane = 500
  cam.depth = CameraDepth.BATTLEMAP
  cam:set_cullingMask(get_cull_mask(ClientDef_Layer.Fight))
  self.m_fightCam = camobj
end
def.method("boolean").SetCreateConsole = function(self, bCreateConsole)
  self.m_bCreateConsole = bCreateConsole
  if self.m_bCreateConsole then
    _G.ToggleDebugConsole()
  end
end
local tweenerTimer = 0
local delayTimer = 0
def.method().ToGroundLayer = function(self)
  if PlayerIsInFight() then
    return
  end
  CameraOrthoTween.TweenCameraOrtheSize(self.m_2DWorldCam, self.m_2DWorldCam.orthographicSize, self.m_scale2d, fly_down_time)
  CameraOrthoTween.TweenCameraOrtheSize(self.m_Main3DCamComponent, self.m_Main3DCamComponent.orthographicSize, self.m_scale3d, fly_down_time)
  CameraOrthoTween.TweenCameraOrtheSize(self.m_Fly3DCamComponent, self.m_Fly3DCamComponent.orthographicSize, self.m_scale3d, fly_down_time)
  GameUtil.RemoveGlobalTimer(delayTimer)
  delayTimer = GameUtil.AddGlobalTimer(0.05, true, function()
    local realTime = Time.time
    local startValue = 0.6666666666666666
    local endValue = 1
    local diffValue = endValue - startValue
    GameUtil.RemoveGlobalTimer(tweenerTimer)
    tweenerTimer = GameUtil.AddGlobalTimer(0, false, function()
      local pastTime = Time.time - realTime
      if pastTime < fly_down_time then
        local curValue = pastTime / fly_down_time * diffValue + startValue
        Camera2D.SetWorldScale(curValue)
      else
        Camera2D.SetWorldScale(endValue)
        GameUtil.RemoveGlobalTimer(tweenerTimer)
        gmodule.moduleMgr:GetModule(ModuleId.MAP):SetMapExtend(256)
      end
    end)
  end)
  _G.terrain_tile_max_per_frame = 1
end
def.method().ResetGroundLayer = function(self)
  if PlayerIsInFight() then
    return
  end
  self:_ResetGroundLayer()
end
def.method()._ResetGroundLayer = function(self)
  GameUtil.RemoveGlobalTimer(delayTimer)
  GameUtil.RemoveGlobalTimer(tweenerTimer)
  CameraOrthoTween.TweenCameraStop(self.m_2DWorldCam)
  CameraOrthoTween.TweenCameraStop(self.m_Main3DCamComponent)
  CameraOrthoTween.TweenCameraStop(self.m_Fly3DCamComponent)
  self.m_2DWorldCam.orthographicSize = self.m_scale2d
  self.m_Main3DCamComponent.orthographicSize = self.m_scale3d
  self.m_Fly3DCamComponent.orthographicSize = self.m_scale3d
  Camera2D.SetWorldScale(1)
  gmodule.moduleMgr:GetModule(ModuleId.MAP):SetMapExtend(256)
  _G.terrain_tile_max_per_frame = 1
end
def.method().SetCameraToGround = function(self)
  Camera2D.SetWorldScale(1)
end
def.method().SetCameraToSky = function(self)
  Camera2D.SetWorldScale(0.6666666666666666)
end
def.method().ToSkyLayer = function(self)
  if self.m_isInFight then
    return
  end
  local skyScale = 1.5
  GameUtil.RemoveGlobalTimer(delayTimer)
  delayTimer = GameUtil.AddGlobalTimer(0.05, true, function()
    CameraOrthoTween.TweenCameraOrtheSize(self.m_2DWorldCam, self.m_scale2d, self.m_scale2d * skyScale, fly_up_time)
    CameraOrthoTween.TweenCameraOrtheSize(self.m_Main3DCamComponent, self.m_scale3d, self.m_scale3d * skyScale, fly_up_time)
    CameraOrthoTween.TweenCameraOrtheSize(self.m_Fly3DCamComponent, self.m_scale3d, self.m_scale3d * skyScale, fly_up_time)
  end)
  local realTime = Time.time
  local startValue = 1
  local endValue = 0.6666666666666666
  local diffValue = endValue - startValue
  GameUtil.RemoveGlobalTimer(tweenerTimer)
  tweenerTimer = GameUtil.AddGlobalTimer(0, false, function()
    local pastTime = Time.time - realTime
    if pastTime < fly_up_time then
      local curValue = pastTime / fly_up_time * diffValue + startValue
      Camera2D.SetWorldScale(curValue)
    else
      Camera2D.SetWorldScale(endValue)
      GameUtil.RemoveGlobalTimer(tweenerTimer)
    end
  end)
  gmodule.moduleMgr:GetModule(ModuleId.MAP):SetMapExtend(768)
  _G.terrain_tile_max_per_frame = 2
end
def.method().ResetSkyLayer = function(self)
  if PlayerIsInFight() then
    return
  end
  self:_ResetSkyLayer()
end
def.method()._ResetSkyLayer = function(self)
  GameUtil.RemoveGlobalTimer(delayTimer)
  GameUtil.RemoveGlobalTimer(tweenerTimer)
  CameraOrthoTween.TweenCameraStop(self.m_2DWorldCam)
  CameraOrthoTween.TweenCameraStop(self.m_Main3DCamComponent)
  CameraOrthoTween.TweenCameraStop(self.m_Fly3DCamComponent)
  local skyScale = 1.5
  self.m_2DWorldCam.orthographicSize = self.m_scale2d * skyScale
  self.m_Main3DCamComponent.orthographicSize = self.m_scale3d * skyScale
  self.m_Fly3DCamComponent.orthographicSize = self.m_scale3d * skyScale
  Camera2D.SetWorldScale(1 / skyScale)
  gmodule.moduleMgr:GetModule(ModuleId.MAP):SetMapExtend(768)
  _G.terrain_tile_max_per_frame = 1
end
def.method("=>", "number").GetGroundScale = function(self)
  return self.m_scale3d / self.m_Main3DCamComponent.orthographicSize
end
def.method().OnZoomStarted = function(self)
end
def.method("number").OnZoom = function(self, deltaDist)
end
def.method("number").OnZoomEnded = function(self, totalDist)
  local isExpand = true
  if totalDist > 0 then
    isExpand = false
  end
  require("Main.MainUI.ui.MainUIPanel").Instance():ExpandAll(isExpand)
end
def.method("=>", "number").getClientVersion = function(self)
  local VER_FILE_PATH = GameUtil.GetAssetsPath() .. "/patcher/config/game_ver.sw"
  local fin = io.open(VER_FILE_PATH, "r")
  if fin then
    local content = fin:read("*a")
    local ver = string.match(content, "current:(%d+)")
    fin:close()
    return tonumber(ver)
  else
    return -1
  end
end
def.method("string").OpenUrl = function(self, url)
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    ECMSDK.OpenURL(url)
  elseif Application.OpenURL then
    url = _G.NormalizeHttpURL(url)
    Application.OpenURL(url)
  else
    warn("[no implemention] openUrl(" .. url .. ") " .. "failed")
  end
end
def.method("string", "boolean").OpenUrlByZLBrowser = function(self, url, attachGameData)
  if ZLUtil == nil then
    warn("OpenUrlByZLBrowser: No ZLUtil")
    return
  end
  if ZLUtil.openUrl == nil then
    warn("OpenUrlByZLBrowser: No ZLUtil.openUrl")
    return
  end
  if attachGameData then
    url = _G.AttachGameData2URL(url)
  end
  print(string.format("ZLUtil.openUrl %s", url))
  ZLUtil.openUrl(url)
end
def.method("string").OpenUrlByZLBrowserWithPayInfo = function(self, url)
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local ECMSDK = require("ProxySDK.ECMSDK")
    local msdkInfo = ECMSDK.GetMSDKInfo()
    local params = {}
    params.access_token = msdkInfo and msdkInfo.accessToken or nil
    params.pay_token = ECMSDK.GetPayToken()
    params.pf = ECMSDK.GetPf()
    for k, v in pairs(params) do
      if type(v) == "string" then
        params[k] = v:urlencode()
      end
    end
    url = _G.AttachParams2URL(url, params)
    url = ECMSDK.GetEncodeUrl(url)
  else
    warn(string.format("[error] OpenUrlByZLBrowserWithPayInfo: Not supported sdktype(%d)", sdktype))
  end
  self:OpenUrlByZLBrowser(url, true)
end
_G._debug_shortcutMenuKey = nil
def.method("=>", "string").GetShortcutMenuKey = function(self)
  if _G._debug_shortcutMenuKey then
    return _G._debug_shortcutMenuKey
  end
  local key
  if ZLUtil and ZLUtil.shortcutMenuKey then
    key = ZLUtil.shortcutMenuKey()
  end
  key = key or ""
  return key
end
def.method().ClearShortcutMenuKey = function(self)
  if ZLUtil and ZLUtil.shortcutMenuKey then
    ZLUtil.shortcutMenuKey(true)
  end
  _G._debug_shortcutMenuKey = nil
end
def.method("string").SetShortcutMenuKey = function(self, key)
  _G._debug_shortcutMenuKey = key
end
def.method("=>", "boolean").IsQuickLaunch = function(self)
  if self:GetShortcutMenuKey() == "" then
    return false
  else
    return true
  end
end
def.method("number").SetGameState = function(self, state)
  if #self.m_HistoryGameState >= self.m_HistoryGameState.capacity then
    table.remove(self.m_HistoryGameState, 1)
  end
  table.insert(self.m_HistoryGameState, self.m_GameState)
  if self.m_GameState >= _G.GameState.LeavingGameWorld and state < _G.GameState.LeavingGameWorld then
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD_STAGE, nil)
  end
  self.m_GameState = state
end
def.method("=>", "number").GetGameState = function(self)
  return self.m_GameState
end
def.method("number", "=>", "number").GetHistoryGameState = function(self, idx)
  if idx == 0 then
    return self.m_GameState
  end
  local size = #self.m_HistoryGameState
  local gameState = self.m_HistoryGameState[size + idx + 1] or _G.GameState.None
  return gameState
end
def.method("=>", "string").GetGameInfo = function(self)
  local infoStr = {}
  local programVersion, versionName, version3 = GameUtil.GetProgramCurrentVersionInfo()
  local version = versionName
  version = version .. string.format(".%d", self:getClientVersion())
  infoStr.Version = version
  local sdktype = ClientCfg.GetSDKType()
  local platformStr = platform == 0 and "PC" or platform == 1 and "IOS" or platform == 2 and "Android" or "????"
  local myChannel = "Shadow"
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local logingPlatform = require("ProxySDK.ECMSDK").PayPlatform()
    if logingPlatform == MSDK_LOGIN_PLATFORM.WX then
      myChannel = "WeChat"
    elseif logingPlatform == MSDK_LOGIN_PLATFORM.QQ then
      myChannel = "QQ"
    end
  elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
    myChannel = "unisdk"
  end
  infoStr.Platform = string.format("%s@%s", myChannel, platformStr)
  infoStr.UserName = self.m_UserName or "????"
  local ServerListMgr = require("Main.Login.ServerListMgr")
  local cfg = gmodule.moduleMgr:GetModule(ModuleId.LOGIN):GetConnectedServerCfg()
  local serverName = cfg and cfg.name or "????"
  infoStr.ServerName = serverName or "????"
  local roleId = GetMyRoleID() or "????"
  infoStr.RoleId = tostring(roleId)
  local info = "[GameInfo] "
  for k, v in pairs(infoStr) do
    info = info .. k .. ":" .. v .. ", "
  end
  return info
end
local lastReqTime = os.time()
local DIR_INFO_EXPIRE_TIME = 300
def.method().RequestDirInfo = function(self)
  if not self:IsDirInfoExpired() then
    return
  end
  lastReqTime = os.time()
  GameUtil.RequestDirInfo(function()
    require("Main.Login.ServerListMgr").Instance():RefreshServerList()
  end)
end
def.method("=>", "boolean").IsDirInfoExpired = function(self)
  return math.abs(os.time() - lastReqTime) >= DIR_INFO_EXPIRE_TIME
end
def.method().StartRefreshDirTimer = function(self)
  self:RequestDirInfo()
  if self.m_refreshDirTimer ~= 0 then
    return
  end
  self.m_refreshDirTimer = GameUtil.AddGlobalTimer(DIR_INFO_EXPIRE_TIME + 1, false, function()
    local gameState = self:GetGameState()
    if gameState == _G.GameState.LoginAccount or gameState == _G.GameState.LoginMain or gameState == _G.GameState.ChooseServer then
      self:RequestDirInfo()
    end
  end)
end
def.method().StopRefreshDirTimer = function(self)
  if self.m_refreshDirTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_refreshDirTimer)
    self.m_refreshDirTimer = 0
  end
end
def.method().Restart = function(self)
  if platform == _G.Platform.android then
    if ZLUtil.restart then
      ZLUtil.restart()
    else
      warn("ZLUtil.restart is nil")
    end
  else
    self:Quit()
  end
end
def.method().Quit = function(self)
  if _G.platform == 0 then
    if Application.isEditor then
      Application.Quit()
    else
      os.exit(0)
    end
  else
    require("Utility.DeviceUtility").InstallUncaughtExceptionHandler()
    gmodule.moduleMgr:GetModule(ModuleId.LOGIN):Logout()
    Thread.Sleep(200)
    if _G.platform == 1 then
      os.exit()
    else
      GameUtil.Kill()
    end
  end
end
def.method().SkipClickGroundOnce = function(self)
  self.m_skipClickGroundOnce = true
end
def.method("string").GCTLog = function(self, reason)
  local ECMSDK = require("ProxySDK.ECMSDK")
  local content = {
    SystemInfo.get_deviceUniqueIdentifier(),
    SystemInfo.get_deviceName(),
    SystemInfo.get_systemMemorySize(),
    reason
  }
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.GC, content)
end
def.method("string").TakeCamera = function(self, takerName)
  if self.m_cameraTaken == nil then
    self.m_cameraTaken = {}
  end
  self.m_cameraTaken[#self.m_cameraTaken + 1] = takerName
end
def.method("string").ReleaseCamera = function(self, takerName)
  if self.m_cameraTaken == nil then
    return
  end
  local del_idx = 0
  for i = 1, #self.m_cameraTaken do
    if self.m_cameraTaken[i] == takerName then
      del_idx = i
      break
    end
  end
  table.remove(self.m_cameraTaken, del_idx)
end
ECGame.Commit()
theGame = ECGame.new()
return ECGame
