local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local BubbleGameMgr = Lplus.Class(CUR_CLASS_NAME)
local def = BubbleGameMgr.define
local instance
def.field("number").curGameId = 0
def.field("number").curTurn = 0
def.field("number").curScore = 0
def.field("number").startTime = 0
def.field("number").totalScore = 0
def.field("boolean").isResumeGame = false
def.static("=>", BubbleGameMgr).Instance = function()
  if instance == nil then
    instance = BubbleGameMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bubblegame.SStartBubbleGame", BubbleGameMgr.OnSStartBubbleGame)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bubblegame.SStopBubbleGame", BubbleGameMgr.OnSStopBubbleGame)
end
def.method().OnReset = function(self)
  self.curGameId = 0
  self.curTurn = 0
  self.curScore = 0
  self.isResumeGame = false
end
def.static("number", "=>", "table").GetBubbleGameCfg = function(gameId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BUBBLE_GAME_CFG, gameId)
  if record == nil then
    warn("!!!!!GetBubbleGameCfg(" .. gameId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.game_id = record:GetIntValue("game_id")
  cfg.desc = record:GetStringValue("desc")
  cfg.turn_sum = record:GetIntValue("turn_sum")
  cfg.game_time = record:GetIntValue("game_time")
  cfg.game_over_effect_id = record:GetIntValue("game_over_effect_id")
  cfg.point_upper_limit = record:GetIntValue("point_upper_limit")
  cfg.right_point = record:GetIntValue("right_point")
  cfg.wrong_point = record:GetIntValue("wrong_point")
  cfg.tips_content_id = record:GetIntValue("tips_content_id")
  cfg.ui_id = record:GetStringValue("ui_id")
  cfg.model_id = record:GetIntValue("model_id")
  cfg.countdown_time = record:GetIntValue("countdown_time")
  cfg.tips_time = record:GetIntValue("tips_time")
  cfg.game_stage_infos = {}
  local rec2 = record:GetStructValue("gameStageInfosStruct")
  local count = rec2:GetVectorSize("gameStageInfosList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("gameStageInfosList", i - 1)
    local info = {}
    info.sort_id = rec3:GetIntValue("sort_id")
    info.duration = rec3:GetIntValue("duration")
    info.drop_duration_ms = rec3:GetIntValue("drop_duration_ms")
    info.drop_interval_ms = rec3:GetIntValue("drop_interval_ms")
    table.insert(cfg.game_stage_infos, info)
  end
  return cfg
end
def.static("table").OnSStartBubbleGame = function(p)
  warn("-----OnSStartBubbleGame:", p.game_id, p.start_timestamp, p.is_resume_game)
  local self = instance
  self.curGameId = p.game_id
  self.curTurn = p.complete_turn_index
  self.totalScore = p.current_point
  self.startTime = p.start_timestamp
  self.curScore = 0
  self.isResumeGame = p.is_resume_game == p.RESUME_GAME
  local BubbleGamePanel = require("Main.MiniGame.ui.BubbleGamePanel")
  BubbleGamePanel.Instance():ShowPanel(p.game_id)
end
def.static("table").OnSStopBubbleGame = function(p)
  warn("------OnSStopBubbleGame:", p.game_id, p.res == p.GAME_OVER)
  if p.res == p.GAME_OVER then
    Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.BUBBLE_GAME_END, {
      p.game_id,
      p.res
    })
  end
end
def.method("number").addScore = function(self, num)
  self.curScore = self.curScore + num
  self.totalScore = self.totalScore + num
end
def.method("number", "=>", "number").addTurn = function(self, num)
  self.curTurn = self.curTurn + num
  return self.curTurn
end
return BubbleGameMgr.Commit()
