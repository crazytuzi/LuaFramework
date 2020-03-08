local CChineseValentineClickReq = class("CChineseValentineClickReq")
CChineseValentineClickReq.TYPEID = 12622088
function CChineseValentineClickReq:ctor(index)
  self.id = 12622088
  self.index = index or nil
end
function CChineseValentineClickReq:marshal(os)
  os:marshalInt32(self.index)
end
function CChineseValentineClickReq:unmarshal(os)
  self.index = os:unmarshalInt32()
end
function CChineseValentineClickReq:sizepolicy(size)
  return size <= 65535
end
return CChineseValentineClickReq
