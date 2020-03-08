local ChessPieceInfo = require("netio.protocol.mzm.gsp.chess.ChessPieceInfo")
local SNotifyChessMove = class("SNotifyChessMove")
SNotifyChessMove.TYPEID = 12619030
function SNotifyChessMove:ctor(from_cell_index, to_cell_piece_info)
  self.id = 12619030
  self.from_cell_index = from_cell_index or nil
  self.to_cell_piece_info = to_cell_piece_info or ChessPieceInfo.new()
end
function SNotifyChessMove:marshal(os)
  os:marshalInt32(self.from_cell_index)
  self.to_cell_piece_info:marshal(os)
end
function SNotifyChessMove:unmarshal(os)
  self.from_cell_index = os:unmarshalInt32()
  self.to_cell_piece_info = ChessPieceInfo.new()
  self.to_cell_piece_info:unmarshal(os)
end
function SNotifyChessMove:sizepolicy(size)
  return size <= 65535
end
return SNotifyChessMove
