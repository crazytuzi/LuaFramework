local SChineseValentineClickErrorRep = class("SChineseValentineClickErrorRep")
SChineseValentineClickErrorRep.TYPEID = 12622083
SChineseValentineClickErrorRep.NOT_START = 1
function SChineseValentineClickErrorRep:ctor(code)
  self.id = 12622083
  self.code = code or nil
end
function SChineseValentineClickErrorRep:marshal(os)
  os:marshalInt32(self.code)
end
function SChineseValentineClickErrorRep:unmarshal(os)
  self.code = os:unmarshalInt32()
end
function SChineseValentineClickErrorRep:sizepolicy(size)
  return size <= 65535
end
return SChineseValentineClickErrorRep
