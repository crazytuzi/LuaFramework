local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local ChessModule = Lplus.Extend(ModuleBase, "ChessModule")
require("Main.module.ModuleId")
local def = ChessModule.define
local instance
def.field("table").owned = nil
def.static("=>", ChessModule).Instance = function()
  if instance == nil then
    instance = ChessModule()
    instance.m_moduleId = ModuleId.CHESS
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chess.SNotifyPreviewChess", ChessModule.OnSNotifyPreviewChess)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ChessModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, ChessModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, ChessModule.OnNpcService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, ChessModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ChessModule.OnLeaveWorld)
end
def.override().LateInit = function(self)
  require("Main.Chess.ChessMgr").Instance()
end
def.static("table").OnSNotifyPreviewChess = function(p)
  require("Main.Chess.ui.DlgChessActivity").Instance():ShowDlg()
end
def.static("table", "table").OnLeaveWorld = function()
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1 and p1.feature == Feature.TYPE_CHESS_ACTIVITY then
    local isOpen = _G.IsFeatureOpen(Feature.TYPE_CHESS_ACTIVITY)
    local activityInterface = require("Main.activity.ActivityInterface").Instance()
    if isOpen then
      activityInterface:removeCustomCloseActivity(constant.ChessActivityConsts.ACTIVITY_ID)
    else
      require("Main.Chess.ChessMgr").Instance():EndGame()
      activityInterface:addCustomCloseActivity(constant.ChessActivityConsts.ACTIVITY_ID)
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_CHESS_ACTIVITY)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if isOpen then
    require("Main.Chess.ChessMgr").Instance()
    activityInterface:removeCustomCloseActivity(constant.ChessActivityConsts.ACTIVITY_ID)
  else
    require("Main.Chess.ChessMgr").Instance():EndGame()
    activityInterface:addCustomCloseActivity(constant.ChessActivityConsts.ACTIVITY_ID)
  end
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1[1]
  if activityId and activityId == constant.ChessActivityConsts.ACTIVITY_ID then
    local NPCInterface = require("Main.npc.NPCInterface")
    local npcCfg = NPCInterface.GetNPCCfg(constant.ChessActivityConsts.NPC_ID)
    if npcCfg == nil then
      return
    end
    NPCInterface.Instance():SetTargetNPCID(constant.ChessActivityConsts.NPC_ID)
    local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    heroMgr.needShowAutoEffect = true
    heroMgr:MoveTo(npcCfg.mapId, npcCfg.x, npcCfg.y, 0, 5, MoveType.AUTO, nil)
  end
end
def.static("table", "table").OnNpcService = function(p1, p2)
  local serviceID = p1[1]
  if serviceID == nil then
    return
  end
  local npcId = p1[2]
  if npcId == constant.ChessActivityConsts.NPC_ID and serviceID == constant.ChessActivityConsts.SERVICE_ID then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local state = ActivityInterface.GetActivityState(constant.ChessActivityConsts.ACTIVITY_ID)
    if state < 0 then
      Toast(textRes.activity[270])
      return
    end
    if state > 0 then
      Toast(textRes.activity[271])
      return
    end
    local pro = require("netio.protocol.mzm.gsp.chess.CPreviewChessReq").new()
    gmodule.network.sendProtocol(pro)
    require("Main.Chess.ui.DlgChessActivity").Instance():ShowDlg()
  end
end
ChessModule.Commit()
return ChessModule
