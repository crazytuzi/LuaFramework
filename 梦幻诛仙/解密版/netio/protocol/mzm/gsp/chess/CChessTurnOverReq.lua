local CChessTurnOverReq = class("CChessTurnOverReq")
CChessTurnOverReq.TYPEID = 12619022
function CChessTurnOverReq:ctor(cell_index)
  self.id = 12619022
  self.cell_index = cell_index or nil
end
function CChessTurnOverReq:marshal(os)
  os:marshalInt32(self.cell_index)
end
function CChessTurnOverReq:unmarshal(os)
  self.cell_index = os:unmarshalInt32()
end
function CChessTurnOverReq:sizepolicy(size)
  return size <= 65535
end
return CChessTurnOverReq
