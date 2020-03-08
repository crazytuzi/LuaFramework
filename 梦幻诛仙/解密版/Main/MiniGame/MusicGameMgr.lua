local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local MusicGameMgr = Lplus.Class(CUR_CLASS_NAME)
local def = MusicGameMgr.define
local instance
def.field("number").curGameId = 0
def.field("number").curTurn = 0
def.field("number").curScore = 0
def.static("=>", MusicGameMgr).Instance = function()
  if instance == nil then
    instance = MusicGameMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.musicgame.SStartMusicGame", MusicGameMgr.OnSStartMusicGame)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.musicgame.SStopMusicGame", MusicGameMgr.OnSStopMusicGame)
end
def.method().OnReset = function(self)
  self.curGameId = 0
  self.curTurn = 0
  self.curScore = 0
end
def.static("number", "=>", "table").GetMusicGameCfg = function(gameId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MUSIC_GAME_CFG, gameId)
  if record == nil then
    warn("GetMusicGameCfg(" .. gameId .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.game_id = record:GetIntValue("game_id")
  cfg.game_type = record:GetIntValue("game_type")
  cfg.turn_sum = record:GetIntValue("turn_sum")
  cfg.lighting_duration_ms = record:GetIntValue("lighting_duration_ms")
  cfg.wrong_effect_id = record:GetIntValue("wrong_effect_id")
  cfg.wrong_music_id = record:GetIntValue("wrong_music_id")
  cfg.desc = record:GetStringValue("desc")
  cfg.point_upper_limit = record:GetIntValue("point_upper_limit")
  cfg.right_point = record:GetIntValue("right_point")
  cfg.wrong_point = record:GetIntValue("wrong_point")
  cfg.ui_id = record:GetStringValue("ui_id")
  cfg.tips_content_id = record:GetIntValue("tips_content_id")
  cfg.countdown_length = record:GetIntValue("countdown_length")
  cfg.musicInfoList = {}
  local rec2 = record:GetStructValue("musicalScaleInfosStruct")
  local count = rec2:GetVectorSize("musicalScaleInfosList")
  for i = 1, count do
    local rec3 = rec2:GetVectorValueByIdx("musicalScaleInfosList", i - 1)
    local info = {}
    info.sort_id = rec3:GetIntValue("sort_id")
    info.musical_scale = rec3:GetIntValue("musical_scale")
    info.interval_ms = rec3:GetIntValue("interval_ms")
    info.effect_id = rec3:GetIntValue("effect_id")
    info.music_id = rec3:GetIntValue("music_id")
    table.insert(cfg.musicInfoList, info)
  end
  return cfg
end
def.static("table").OnSStartMusicGame = function(p)
  warn("-------OnSStartMusicGame-----:", p.game_id)
  instance.curGameId = p.game_id
  instance.curTurn = p.complete_turn_index
  instance.curScore = p.current_point
  local MusicGamePanel = require("Main.MiniGame.ui.MusicGamePanel")
  MusicGamePanel.Instance():ShowPanel(p.game_id)
end
def.static("table").OnSStopMusicGame = function(p)
  warn("------OnSStopMusicGame----:", p.res, p.game_id)
  if p.res == p.GAME_OVER then
    Event.DispatchEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MUSIC_GAME_END, {
      p.game_id,
      p.res
    })
  end
end
def.method("number", "=>", "number").addTurnNum = function(self, num)
  self.curTurn = self.curTurn + 1
  return self.curTurn
end
def.method("number").addScore = function(self, num)
  self.curScore = self.curScore + num
end
return MusicGameMgr.Commit()
