local OctetsStream = require("netio.OctetsStream")
local ChessPieceInfo = class("ChessPieceInfo")
function ChessPieceInfo:ctor(chess_piece_index, chess_cell_index, owner)
  self.chess_piece_index = chess_piece_index or nil
  self.chess_cell_index = chess_cell_index or nil
  self.owner = owner or nil
end
function ChessPieceInfo:marshal(os)
  os:marshalInt32(self.chess_piece_index)
  os:marshalInt32(self.chess_cell_index)
  os:marshalInt32(self.owner)
end
function ChessPieceInfo:unmarshal(os)
  self.chess_piece_index = os:unmarshalInt32()
  self.chess_cell_index = os:unmarshalInt32()
  self.owner = os:unmarshalInt32()
end
return ChessPieceInfo
