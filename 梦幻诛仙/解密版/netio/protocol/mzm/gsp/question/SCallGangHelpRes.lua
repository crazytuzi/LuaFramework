local SCallGangHelpRes = class("SCallGangHelpRes")
SCallGangHelpRes.TYPEID = 12594695
function SCallGangHelpRes:ctor(useCount)
  self.id = 12594695
  self.useCount = useCount or nil
end
function SCallGangHelpRes:marshal(os)
  os:marshalInt32(self.useCount)
end
function SCallGangHelpRes:unmarshal(os)
  self.useCount = os:unmarshalInt32()
end
function SCallGangHelpRes:sizepolicy(size)
  return size <= 65535
end
return SCallGangHelpRes
