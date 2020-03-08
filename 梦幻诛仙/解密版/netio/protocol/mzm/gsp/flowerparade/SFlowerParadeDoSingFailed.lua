local SFlowerParadeDoSingFailed = class("SFlowerParadeDoSingFailed")
SFlowerParadeDoSingFailed.TYPEID = 12625678
SFlowerParadeDoSingFailed.MAX_COUNT = 1
function SFlowerParadeDoSingFailed:ctor(code)
  self.id = 12625678
  self.code = code or nil
end
function SFlowerParadeDoSingFailed:marshal(os)
  os:marshalInt32(self.code)
end
function SFlowerParadeDoSingFailed:unmarshal(os)
  self.code = os:unmarshalInt32()
end
function SFlowerParadeDoSingFailed:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeDoSingFailed
