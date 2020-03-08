local CChooseCardReq = class("CChooseCardReq")
CChooseCardReq.TYPEID = 12612100
function CChooseCardReq:ctor(constellation, index)
  self.id = 12612100
  self.constellation = constellation or nil
  self.index = index or nil
end
function CChooseCardReq:marshal(os)
  os:marshalInt32(self.constellation)
  os:marshalInt32(self.index)
end
function CChooseCardReq:unmarshal(os)
  self.constellation = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function CChooseCardReq:sizepolicy(size)
  return size <= 65535
end
return CChooseCardReq
