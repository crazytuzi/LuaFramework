local Lplus = require("Lplus")
local LoginPreloadMgr = Lplus.Class("LoginPreloadMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local LoginUtility = require("Main.Login.LoginUtility")
local LoadingMgr = require("Main.Common.LoadingMgr")
local def = LoginPreloadMgr.define
def.const("table").PreloadResType = {
  UI = 1,
  NPC = 2,
  MONSTER = 3,
  EFFECT = 4,
  PROTOCOL = 5,
  DATA = 6,
  MAP = 7,
  PROTOCOL_FAKE = 8
}
def.field("table").protocolState = nil
def.field("number").protTimerId = 0
local instance
def.static("=>", LoginPreloadMgr).Instance = function()
  if instance == nil then
    instance = LoginPreloadMgr()
  end
  return instance
end
def.method().PreloadRes = function(self)
  if gmodule.moduleMgr:GetModule(ModuleId.LOGIN):IsInWorld() then
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isLoginLoading = true
  local PreloadResType = LoginPreloadMgr.PreloadResType
  local taskList = {
    [PreloadResType.UI] = 20,
    [PreloadResType.NPC] = 0,
    [PreloadResType.MONSTER] = 0,
    [PreloadResType.EFFECT] = 60,
    [PreloadResType.PROTOCOL_FAKE] = 80,
    [PreloadResType.PROTOCOL] = 1,
    [PreloadResType.DATA] = 20,
    [PreloadResType.MAP] = 5
  }
  if _G.cur_quality_level == 1 then
    taskList[PreloadResType.EFFECT] = 0
  end
  LoadingMgr.Instance():SetLoadingUIReadyCallback(function()
    LoginUtility.DestroyLoginBackground()
    warn("DestroyAllLoginUI~~~~~~~~")
    LoginUtility.DestroyAllLoginUI()
  end)
  LoadingMgr.Instance():StartLoading(LoadingMgr.LoadingType.EnterWorld, taskList, LoginPreloadMgr.OnLoadingFinished, nil)
  self:IncProtocolCount(1)
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_LOADING_START, nil)
  self:Load()
end
def.method().Load = function(self)
  local ECPate = Lplus.ForwardDeclare("ECPate")
  ECPate.LoadPatePrefab(nil)
  local PreloadResType = LoginPreloadMgr.PreloadResType
  LoadingMgr.Instance():ExecuteAsyncLoadTask(PreloadResType.UI, {
    RESPATH.ITEMTIPS,
    RESPATH.PREFAB_AWARD_PANEL,
    RESPATH.DLG_FIGHT_MAIN,
    RESPATH.MAINUI_PANEL_RES,
    RESPATH.PREFAB_GAME_NOTICE_PANEL_RES,
    RESPATH.PREFAB_GAME_BANNER_NOTICE_PANEL_RES,
    RESPATH.PREFAB_FM_PANEL,
    RESPATH.MAINUI_SECOND_TOP_PANEL_RES
  })
  self:LoadAllDatas()
  require("Main.Map.MapUtility").WatchMapLoading(function(val)
    if val == 0 then
      GameUtil.AddGlobalLateTimer(0, true, function()
        GameUtil.AddGlobalTimer(0.5, true, function()
          if _G.IsLoadMap == true and _G.MapNodeCount == 0 and _G.MapNodeMax == 0 then
            LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.MAP, 1)
          end
        end)
      end)
    end
    LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.MAP, val)
  end, true)
  local progress = 0
  local count = 0
  local function fakeProtoclUpdate(...)
    self.protTimerId = GameUtil.AddGlobalTimer(1, true, function()
      if self.protTimerId == 0 then
        return
      end
      if not gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isLoginLoading then
        self.protTimerId = 0
        return
      end
      progress = progress + 0.15
      count = count + 1
      local val = math.log10(1 + progress)
      if val >= 1 then
        val = 1
      end
      LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.PROTOCOL_FAKE, val)
      if val < 1 then
        fakeProtoclUpdate()
      else
        self.protTimerId = 0
      end
    end)
  end
  fakeProtoclUpdate()
end
def.method().LoadAllDatas = function(self)
  local CommonCacheCfgPath = require("Common.CacheCfgPath")
  package.loaded["Common.CacheCfgPath"] = nil
  local CacheCfgPath = {}
  for k, v in pairs(CommonCacheCfgPath) do
    table.insert(CacheCfgPath, v)
  end
  local total = #CacheCfgPath
  print("LoadAllDatas #total = " .. total)
  local co = coroutine.create(function(maxLoadDataTime)
    local PreloadResType = LoginPreloadMgr.PreloadResType
    local bCache = true
    local READ_NUM_PER_FRAME = 20
    local count = 1
    for i, path in ipairs(CacheCfgPath) do
      local t = DynamicData.GetTable(path, bCache)
      if t then
        DynamicDataTable.SetCache(path, bCache)
      end
      LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.DATA, count / total)
      count = count + 1
      if maxLoadDataTime < Time.realtimeSinceStartup then
        coroutine.yield()
      end
    end
  end)
  local MAX_LOAD_DATA_TIME_PER_FRAME = 0.4
  local function run()
    GameUtil.AddGlobalLateTimer(0, true, function()
      if coroutine.status(co) ~= "dead" then
        local maxLoadDataTime = Time.realtimeSinceStartup + MAX_LOAD_DATA_TIME_PER_FRAME
        coroutine.resume(co, maxLoadDataTime)
        return run()
      end
    end)
  end
  GameUtil.AddGlobalLateTimer(0, true, function()
    run()
    require("Main.Item.ItemUtils").CacheItemBaseData()
  end)
end
def.static("boolean", "table").OnLoadingFinished = function(isSuccess, tag)
  instance.protocolState = nil
  GameUtil.AddGlobalLateTimer(2, true, function()
    if not _G.CGPlay then
      Application.set_targetFrameRate(_G.max_frame_rate)
      GameUtil.SetLoadTimeLimit(0.015)
    end
  end)
  gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isLoginLoading = false
  if _G.log_file_flag then
    utility.AFileSetLogOutput(true)
  end
  if isSuccess then
    LoginUtility.DestroyLoginBackground()
    LoginUtility.DestroyAllLoginUI()
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_LOADING_FINISHED, nil)
  else
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_LOADING_ABORT, nil)
  end
end
def.method("function").PreloadCreateRoleModels = function(self, callback)
  local roleList = LoginUtility.Instance():GetUnlockedRoleList()
  local resPathList = {}
  for i, role in ipairs(roleList) do
    local path = LoginUtility.GetCreateRole2DModelPath(role.occupation, role.gender)
    table.insert(resPathList, path)
    local path = LoginUtility.GetCreateRoleOccupationBGPath(role.occupation)
    table.insert(resPathList, path)
  end
  local taskList = {
    [1] = 100
  }
  LoadingMgr.Instance():StartLoading(LoadingMgr.LoadingType.Other, taskList, function()
    for i, resPath in ipairs(resPathList) do
      LoadingMgr.Instance():ReleaseCache(resPath)
    end
    if callback then
      callback()
    end
  end, nil)
  LoadingMgr.Instance():ExecuteAsyncLoadTask(1, resPathList)
end
def.method("=>", "number").GetProtocolProgress = function(self)
  local state = self.protocolState
  if state == nil then
    return 1
  end
  if state.count == 0 then
    return 1
  end
  return state.finish / state.count
end
def.method("number").IncProtocolCount = function(self, num)
  self.protocolState = self.protocolState or {finish = 0, count = 0}
  local state = self.protocolState
  state.count = state.count + num
  local progress = self:GetProtocolProgress()
  LoadingMgr.Instance():UpdateTaskProgress(LoginPreloadMgr.PreloadResType.PROTOCOL, progress)
end
def.method("number").IncProtocolFinishCount = function(self, num)
  local state = self.protocolState
  if state == nil then
    return
  end
  state.finish = state.finish + num
  local progress = self:GetProtocolProgress()
  if progress >= 1 then
    if self.protTimerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.protTimerId)
      self.protTimerId = 0
    end
    LoadingMgr.Instance():UpdateTaskProgress(LoginPreloadMgr.PreloadResType.PROTOCOL_FAKE, 1)
  end
  LoadingMgr.Instance():UpdateTaskProgress(LoginPreloadMgr.PreloadResType.PROTOCOL, progress)
end
LoginPreloadMgr.Commit()
return LoginPreloadMgr
