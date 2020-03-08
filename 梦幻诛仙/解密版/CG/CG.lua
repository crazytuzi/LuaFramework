local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local CG = Lplus.Class("CG")
local def = CG.define
def.field("userdata").m_rootObj = nil
def.field("boolean").isInArtEditor = false
def.field("boolean").m_isHideScene = false
def.field("boolean").m_waitloading = false
def.field("table").m_cgtext = nil
def.field("table").m_bitindex2mapid = nil
def.field("table").m_mapid2bitindex = nil
def.field("function").m_notify = nil
def.field("number").hostPlayerCount = 0
def.field("number").srcFlyOrthographicSize = 0
def.field("number").src2dOrthSize = 0
def.field("number").src3dOrthSize = 0
local s_regEventTable = {}
local s_dramaTable = {}
local s_inst
def.static("=>", CG).Instance = function()
  if not s_inst then
    s_inst = CG()
    s_inst.m_rootObj = GameObject.GameObject("dramaRootObj")
  end
  return s_inst
end
def.method("function", "=>", "function").SetNotify = function(self, notify)
  local old = self.m_notify
  self.m_notify = notify
  return old
end
def.method("table", "number", "boolean", "=>", "number", "boolean").GetSceneCGID = function(self, hp, sceneId, set)
  local cmd_discovermap_data = require("S2C.discovermap_data")
  local ECTaskInterface = require("Task.ECTaskInterface")
  local bitindex = self.m_mapid2bitindex[sceneId]
  print("GetSceneCGID:", sceneId, bitindex)
  if not bitindex then
    return 0, false
  end
  local firstCgInfo = self.m_bitindex2mapid[bitindex][2]
  local taskCgInfo = self.m_bitindex2mapid[bitindex][3]
  local beenHere = cmd_discovermap_data.IsBeenHere(hp.discovermap_data, bitindex, set)
  print("beenHere:", beenHere, " ", sceneId)
  if not beenHere and firstCgInfo then
    return firstCgInfo[1], firstCgInfo[2]
  end
  if not taskCgInfo then
    return 0, false
  end
  for _, taskData in ipairs(taskCgInfo) do
    local taskId = taskData[1]
    local cgid = taskData[2]
    local waitingLoading = not not taskData[3]
    print("task:", taskId, " ", waitingLoading)
    if ECTaskInterface.IsTaskExist(taskId) then
      return cgid, waitingLoading
    end
  end
  return 0, false
end
def.method("=>", "boolean").HostPlayerControlByCG = function(self)
  return self.hostPlayerCount > 0
end
def.method().StopAll = function(self)
  local ids = {}
  for k, _ in pairs(s_dramaTable) do
    table.insert(ids, k)
  end
  for k, id in pairs(ids) do
    self:Stop(id)
  end
end
def.method("number", "=>", "string").GetText = function(self, stringid)
  if not self.m_cgtext then
    return "no string table"
  end
  local text = self.m_cgtext[stringid]
  if not text then
    return "null"
  end
  return text
end
def.method().ChangeCamera = function()
  print(" change Camera ")
  local game = ECGame.Instance()
  local cgcameraGo = game.m_2DWorldCamObj
  local maincameraGo = game.m_2DWorldCamObj
  local cgcamera = cgcameraGo:GetComponent("Camera")
  local maincamera = game.m_2DWorldCamObj:GetComponent("Camera")
  warn("ChangeCamera")
  cgcameraGo.position = maincameraGo.position
  cgcameraGo.rotation = maincameraGo.rotation
  cgcamera.clearFlags = maincamera.clearFlags
  cgcamera.depth = maincamera.depth
  cgcamera.farClipPlane = maincamera.farClipPlane
  cgcamera.nearClipPlane = maincamera.nearClipPlane
  cgcamera.fieldOfView = maincamera.fieldOfView
  cgcamera.orthographic = maincamera.orthographic
  maincamera.enabled = false
  cgcamera.enabled = true
  HUDFollowTarget.gameCamera = cgcamera
  ECPateTextComponent.gameCamera = cgcamera
  HUDFollowTarget.gameCamera.clearFlags = CameraClearFlags.Nothing
  ECPateTextComponent.gameCamera.clearFlags = CameraClearFlags.Nothing
  maincamera.clearFlags = CameraClearFlags.SolidColor
end
def.method().RestoreCamera = function()
  print("restoreCamera!")
  local game = ECGame.Instance()
  local cgcameraGo = game.m_2DWorldCamObj
  local maincameraGo = game.m_2DWorldCamObj.parent
  local cgcamera = cgcameraGo:GetComponent("Camera")
  local maincamera = game.m_2DWorldCamObj:GetComponent("Camera")
  cgcamera.enabled = false
  maincamera.enabled = true
  HUDFollowTarget.gameCamera = game.m_Main3DCamComponent
  ECPateTextComponent.gameCamera = maincamera
  HUDFollowTarget.gameCamera.clearFlags = CameraClearFlags.Nothing
  ECPateTextComponent.gameCamera.clearFlags = CameraClearFlags.Nothing
  maincamera.clearFlags = CameraClearFlags.SolidColor
end
def.static("string", "=>", "boolean").IsServerCG = function(identity)
  if #identity > 6 and string.sub(identity, 1, 6) == "server" then
    return true
  end
  return false
end
def.static("string", "table").RegEvent = function(eventName, handlerObj)
  s_regEventTable[eventName] = handlerObj
end
def.method("userdata", "string").Drama_Init = function(self, dramaObj, identity)
  print("Drama_Init:", identity)
  _G.terrain_tile_max_per_frame = 500
  if s_dramaTable[identity] then
    error("not release darama:" .. identity)
  end
  local dramaTable = s_dramaTable[identity]
  dramaTable = dramaTable or {}
  dramaTable.drama = dramaObj
  dramaTable.depth = 61000
  s_dramaTable[identity] = dramaTable
  if self.m_notify then
    self.m_notify(true, identity, dramaTable)
  end
end
def.method("table", "string", "string", "userdata").DramaEvent_Start = function(self, dataTable, eventType, dramaName, eventObj)
  local handler = s_regEventTable[eventType]
  if not handler then
    return
  end
  local dramaTable = s_dramaTable[dramaName]
  if not dramaTable then
    return
  end
  handler:DramaEvent_Start(dataTable, dramaTable, eventObj)
end
def.method("table", "string", "string", "userdata").DramaEvent_Update = function(self, dataTable, eventType, dramaName, eventObj)
  local handler = s_regEventTable[eventType]
  if not handler then
    return
  end
  local dramaTable = s_dramaTable[dramaName]
  if not dramaTable then
    return
  end
  handler:DramaEvent_Update(dataTable, dramaTable, eventObj)
end
def.method("table", "string", "string", "userdata").DramaEvent_Release = function(self, dataTable, eventType, dramaName, eventObj)
  local handler = s_regEventTable[eventType]
  if not handler then
    return
  end
  local dramaTable = s_dramaTable[dramaName]
  handler:DramaEvent_Release(dataTable, dramaTable, eventObj)
end
def.method("string", "userdata").Drama_Finish = function(self, dramaName, dramaObj)
  local dramaTable = s_dramaTable[dramaName]
  if not self.isInArtEditor then
    local callStop = dramaTable.callStop
    dramaObj:ReleaseResource()
    if dramaTable.changeCameraAttach then
      MainCamera.host = nil
      MainCamera.automovemode = dramaTable.automovemode
      MainCamera.cgfollowmode = false
    end
    s_dramaTable[dramaName] = nil
    Object.Destroy(dramaObj.gameObject)
    if callStop or CG.IsServerCG(dramaName) then
    end
  end
  if dramaTable.changeCamera then
    self:RestoreCamera()
  end
  _G.CGPlay = false
  _G.IsMutilFrameLoadMap = false
  Application.set_targetFrameRate(_G.max_frame_rate)
  GameUtil.SetLoadTimeLimit(0.015)
  GameUtil.AddGlobalTimer(1, true, function()
    _G.IsCamMoveMode = true
  end)
  local ECGame = require("Main.ECGame")
  local game = ECGame.Instance()
  print(" ********************  drama:", dramaName, " is over")
  require("GUI.ToastTip").Block(false)
  require("Main.Item.ItemModule").Instance()._getNewItem:Block(false)
  require("Main.Item.ItemModule").Instance()._getNewItem:SetVisible(true)
  require("Main.Item.ui.EasyUseDlg").Block(false)
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, {dramaName})
  GameUtil.AddGlobalTimer(5, true, function()
    _G.terrain_tile_max_per_frame = 1
  end)
  local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.BGMusic)
  local volume
  if setting.mute then
    volume = 0
  else
    volume = setting.volume
  end
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.SetVolume(SOUND_TYPES.BACKGROUND, volume)
  if self.m_notify then
    self.m_notify(false, dramaName, dramaTable)
  end
end
def.method("number", "string", "function").PlayById = function(self, id, identity, cb)
  local filename = datapath.GetPathByID(id)
  print("playcg byid filename:", filename, " id:", id)
  if filename == "" then
    error("nocgname in datapath:", id)
  end
  local dramaTable = self:Play(filename, identity, cb)
  dramaTable.id = id
end
def.method("string", "string", "function", "=>", "table").Play = function(self, filename, identity, cb)
  if s_dramaTable[identity] then
    print("play cg error:" .. identity .. " is playing now")
    return {}
  end
  local function loaded(obj)
    local dramaGo = Object.Instantiate(obj, "GameObject")
    local drama = dramaGo:GetComponentInChildren("CGLuaDrama")
    if identity == "" then
      error("cg identity can't be null:" .. filename)
    elseif identity == drama.gameObject.name then
      error("cg identity can't same as CGLuaDrama's name:" .. identity .. ":" .. filename)
    end
    print("cg identity:", filename, "  ", identity)
    dramaGo.parent = self.m_rootObj
    dramaGo:SetActive(true)
    drama.identity = identity
    local dramaTable = s_dramaTable[identity]
    local tempdramaTable = s_dramaTable[drama.gameObject.name]
    dramaTable.drama = tempdramaTable.drama
    dramaTable.depth = tempdramaTable.depth
    if drama.gameObject.name ~= identity then
      s_dramaTable[drama.gameObject.name] = nil
    end
    _G.IsCamMoveMode = false
    _G.IsMutilFrameLoadMap = false
    if cb then
      cb(identity)
    end
  end
  _G.CGPlay = true
  Application.set_targetFrameRate(60)
  GameUtil.SetLoadTimeLimit(0)
  local dramaTable = {identity = identity}
  s_dramaTable[identity] = dramaTable
  GameUtil.AsyncLoad(filename, loaded)
  warn("LoadCgName =", filename)
  require("GUI.ToastTip").Block(true)
  require("Main.Item.ItemModule").Instance()._getNewItem:Block(true)
  require("Main.Item.ItemModule").Instance()._getNewItem:SetVisible(false)
  require("Main.Item.ui.EasyUseDlg").Block(true)
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.SetVolume(SOUND_TYPES.BACKGROUND, 0)
  return dramaTable
end
def.method("string").Stop = function(self, identity)
  local dramaTable = s_dramaTable[identity]
  if not dramaTable then
    print("not found drama:", identity)
    return
  end
  dramaTable.callStop = true
  dramaTable.drama:Stop()
  local ECGame = require("Main.ECGame")
  ECGame.Instance().m_Fly3DCamComponent.orthographicSize = CG.Instance().srcFlyOrthographicSize
  ECGame.Instance().m_2DWorldCam.orthographicSize = CG.Instance().src2dOrthSize
  ECGame.Instance().m_2DWorldCam.orthographicSize = CG.Instance().src3dOrthSize
end
return CG.Commit()
