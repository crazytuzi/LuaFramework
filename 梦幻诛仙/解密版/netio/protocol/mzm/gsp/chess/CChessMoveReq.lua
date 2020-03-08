local CChessMoveReq = class("CChessMoveReq")
CChessMoveReq.TYPEID = 12619023
function CChessMoveReq:ctor(from_cell_index, to_cell_index)
  self.id = 12619023
  self.from_cell_index = from_cell_index or nil
  self.to_cell_index = to_cell_index or nil
end
function CChessMoveReq:marshal(os)
  os:marshalInt32(self.from_cell_index)
  os:marshalInt32(self.to_cell_index)
end
function CChessMoveReq:unmarshal(os)
  self.from_cell_index = os:unmarshalInt32()
  self.to_cell_index = os:unmarshalInt32()
end
function CChessMoveReq:sizepolicy(size)
  return size <= 65535
end
return CChessMoveReq
