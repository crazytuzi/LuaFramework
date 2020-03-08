local SSynChessInfo = class("SSynChessInfo")
SSynChessInfo.TYPEID = 12619032
SSynChessInfo.SIDE_RED = 1
SSynChessInfo.SIDE_BLUE = 2
function SSynChessInfo:ctor(cfg_id, enemy_id, enemy_name, enemy_occupation, enemy_gender, enemy_level, enemy_avatar, current_player, self_side, round, round_start_time, chess_piece_infos)
  self.id = 12619032
  self.cfg_id = cfg_id or nil
  self.enemy_id = enemy_id or nil
  self.enemy_name = enemy_name or nil
  self.enemy_occupation = enemy_occupation or nil
  self.enemy_gender = enemy_gender or nil
  self.enemy_level = enemy_level or nil
  self.enemy_avatar = enemy_avatar or nil
  self.current_player = current_player or nil
  self.self_side = self_side or nil
  self.round = round or nil
  self.round_start_time = round_start_time or nil
  self.chess_piece_infos = chess_piece_infos or {}
end
function SSynChessInfo:marshal(os)
  os:marshalInt32(self.cfg_id)
  os:marshalInt64(self.enemy_id)
  os:marshalString(self.enemy_name)
  os:marshalInt32(self.enemy_occupation)
  os:marshalInt32(self.enemy_gender)
  os:marshalInt32(self.enemy_level)
  os:marshalInt32(self.enemy_avatar)
  os:marshalInt32(self.current_player)
  os:marshalInt32(self.self_side)
  os:marshalInt32(self.round)
  os:marshalInt64(self.round_start_time)
  os:marshalCompactUInt32(table.getn(self.chess_piece_infos))
  for _, v in ipairs(self.chess_piece_infos) do
    v:marshal(os)
  end
end
function SSynChessInfo:unmarshal(os)
  self.cfg_id = os:unmarshalInt32()
  self.enemy_id = os:unmarshalInt64()
  self.enemy_name = os:unmarshalString()
  self.enemy_occupation = os:unmarshalInt32()
  self.enemy_gender = os:unmarshalInt32()
  self.enemy_level = os:unmarshalInt32()
  self.enemy_avatar = os:unmarshalInt32()
  self.current_player = os:unmarshalInt32()
  self.self_side = os:unmarshalInt32()
  self.round = os:unmarshalInt32()
  self.round_start_time = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.chess.ChessPieceInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.chess_piece_infos, v)
  end
end
function SSynChessInfo:sizepolicy(size)
  return size <= 65535
end
return SSynChessInfo
