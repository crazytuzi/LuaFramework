local Lplus = require("Lplus")
local ChessUtils = Lplus.Class("ChessUtils")
local def = ChessUtils.define
def.static("number", "=>", "table").GetChessGameCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHESS_GAME_CFG, id)
  if record == nil then
    warn("[GetChessGameCfg] get nil record for id: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.chessBoardCfgId = record:GetIntValue("chessBoardCfgId")
  cfg.chessPieceCfgId = record:GetIntValue("chessPieceCfgId")
  cfg.chessBoardMaxColumn = record:GetIntValue("chessBoardMaxColumn")
  cfg.chessBoardMaxRow = record:GetIntValue("chessBoardMaxRow")
  cfg.roundTimeLimit = record:GetIntValue("roundTimeLimit")
  cfg.surrenderRoundCount = record:GetIntValue("surrenderRoundCount")
  cfg.drawRoundCount = record:GetIntValue("drawRoundCount")
  cfg.maxRoundCount = record:GetIntValue("maxRoundCount")
  cfg.turnOverEffect = record:GetIntValue("turnOverEffect")
  cfg.chessBoardBg = record:GetIntValue("chessBoardBg")
  cfg.blueModelColorId = record:GetIntValue("blueModelColorId")
  cfg.redModelColorId = record:GetIntValue("redModelColorId")
  cfg.moveActionName = record:GetStringValue("moveActionName")
  cfg.attackActionName = record:GetStringValue("attackActionName")
  cfg.deathActionName = record:GetStringValue("deathActionName")
  cfg.modelIdBeforeTurnOver = record:GetIntValue("modelIdBeforeTurnOver")
  cfg.nameBeforeTurnOver = record:GetStringValue("nameBeforeTurnOver")
  cfg.blueNameColorId = record:GetIntValue("blueNameColorId")
  cfg.redNameColorId = record:GetIntValue("redNameColorId")
  cfg.winEffect = record:GetIntValue("winEffect")
  cfg.loseEffect = record:GetIntValue("loseEffect")
  cfg.drawEffect = record:GetIntValue("drawEffect")
  return cfg
end
def.static("number", "=>", "table").GetChessBoardCfg = function(typeid)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHESS_BOARD_CFG)
  DynamicDataTable.SetCache(entries, true)
  local size = DynamicDataTable.GetRecordsCount(entries)
  local grids = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local _type_id = record:GetIntValue("typeId")
    if _type_id == typeid then
      local cfg = {}
      cfg.x = record:GetIntValue("x")
      cfg.y = record:GetIntValue("y")
      cfg.row = record:GetIntValue("row")
      cfg.col = record:GetIntValue("col")
      local idx = bit.lshift(cfg.row, 16) + cfg.col
      grids[idx] = cfg
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return grids
end
def.static("number", "=>", "table").GetChessPieceCfg = function(index)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_CHESS_PIECE_CFG, index)
  if record == nil then
    warn("[GetChessPieceCfg] get nil record for id: ", index)
    return nil
  end
  local cfg = {}
  cfg.index = record:GetIntValue("index")
  cfg.typeId = record:GetIntValue("typeId")
  cfg.name = record:GetStringValue("name")
  cfg.count = record:GetIntValue("count")
  cfg.modelId = record:GetIntValue("modelId")
  cfg.modelScale = record:GetIntValue("modelScale") / 10000
  return cfg
end
def.static("=>", "number", "number").GetMaxMinChessPieceIndex = function()
  local max_index, min_index = 0, -1
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CHESS_PIECE_CFG)
  DynamicDataTable.SetCache(entries, true)
  local size = DynamicDataTable.GetRecordsCount(entries)
  local grids = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, size - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local _index = record:GetIntValue("index")
    if max_index < _index then
      max_index = _index
    end
    if min_index == -1 or min_index > _index then
      min_index = _index
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return max_index, min_index
end
ChessUtils.Commit()
return ChessUtils
