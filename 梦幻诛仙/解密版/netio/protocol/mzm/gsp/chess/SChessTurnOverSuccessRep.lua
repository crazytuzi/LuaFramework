local ChessPieceInfo = require("netio.protocol.mzm.gsp.chess.ChessPieceInfo")
local SChessTurnOverSuccessRep = class("SChessTurnOverSuccessRep")
SChessTurnOverSuccessRep.TYPEID = 12619026
function SChessTurnOverSuccessRep:ctor(cell_piece_info)
  self.id = 12619026
  self.cell_piece_info = cell_piece_info or ChessPieceInfo.new()
end
function SChessTurnOverSuccessRep:marshal(os)
  self.cell_piece_info:marshal(os)
end
function SChessTurnOverSuccessRep:unmarshal(os)
  self.cell_piece_info = ChessPieceInfo.new()
  self.cell_piece_info:unmarshal(os)
end
function SChessTurnOverSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SChessTurnOverSuccessRep
