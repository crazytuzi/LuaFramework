local ChessPieceInfo = require("netio.protocol.mzm.gsp.chess.ChessPieceInfo")
local SChessMoveSuccessRep = class("SChessMoveSuccessRep")
SChessMoveSuccessRep.TYPEID = 12619036
function SChessMoveSuccessRep:ctor(to_cell_piece_info)
  self.id = 12619036
  self.to_cell_piece_info = to_cell_piece_info or ChessPieceInfo.new()
end
function SChessMoveSuccessRep:marshal(os)
  self.to_cell_piece_info:marshal(os)
end
function SChessMoveSuccessRep:unmarshal(os)
  self.to_cell_piece_info = ChessPieceInfo.new()
  self.to_cell_piece_info:unmarshal(os)
end
function SChessMoveSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SChessMoveSuccessRep
