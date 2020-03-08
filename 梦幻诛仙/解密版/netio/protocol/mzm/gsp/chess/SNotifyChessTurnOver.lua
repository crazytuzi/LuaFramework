local ChessPieceInfo = require("netio.protocol.mzm.gsp.chess.ChessPieceInfo")
local SNotifyChessTurnOver = class("SNotifyChessTurnOver")
SNotifyChessTurnOver.TYPEID = 12619033
function SNotifyChessTurnOver:ctor(cell_piece_info)
  self.id = 12619033
  self.cell_piece_info = cell_piece_info or ChessPieceInfo.new()
end
function SNotifyChessTurnOver:marshal(os)
  self.cell_piece_info:marshal(os)
end
function SNotifyChessTurnOver:unmarshal(os)
  self.cell_piece_info = ChessPieceInfo.new()
  self.cell_piece_info:unmarshal(os)
end
function SNotifyChessTurnOver:sizepolicy(size)
  return size <= 65535
end
return SNotifyChessTurnOver
