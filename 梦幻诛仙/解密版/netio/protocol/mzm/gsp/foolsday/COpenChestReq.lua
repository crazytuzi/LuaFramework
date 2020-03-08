local COpenChestReq = class("COpenChestReq")
COpenChestReq.TYPEID = 12612866
function COpenChestReq:ctor(grid, makerid)
  self.id = 12612866
  self.grid = grid or nil
  self.makerid = makerid or nil
end
function COpenChestReq:marshal(os)
  os:marshalInt32(self.grid)
  os:marshalInt64(self.makerid)
end
function COpenChestReq:unmarshal(os)
  self.grid = os:unmarshalInt32()
  self.makerid = os:unmarshalInt64()
end
function COpenChestReq:sizepolicy(size)
  return size <= 65535
end
return COpenChestReq
