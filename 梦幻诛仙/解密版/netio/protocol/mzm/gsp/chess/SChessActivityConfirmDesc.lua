local SChessActivityConfirmDesc = class("SChessActivityConfirmDesc")
SChessActivityConfirmDesc.TYPEID = 12619038
function SChessActivityConfirmDesc:ctor(activity_id, chess_game_cfg_id)
  self.id = 12619038
  self.activity_id = activity_id or nil
  self.chess_game_cfg_id = chess_game_cfg_id or nil
end
function SChessActivityConfirmDesc:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.chess_game_cfg_id)
end
function SChessActivityConfirmDesc:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.chess_game_cfg_id = os:unmarshalInt32()
end
function SChessActivityConfirmDesc:sizepolicy(size)
  return size <= 65535
end
return SChessActivityConfirmDesc
