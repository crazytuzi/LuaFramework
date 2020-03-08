local SDissolveGroupFail = class("SDissolveGroupFail")
SDissolveGroupFail.TYPEID = 12605208
SDissolveGroupFail.GROUP_NOT_EXIST = 1
SDissolveGroupFail.ONLY_MASTER_CAN_DISSOLVE = 2
function SDissolveGroupFail:ctor(res)
  self.id = 12605208
  self.res = res or nil
end
function SDissolveGroupFail:marshal(os)
  os:marshalInt32(self.res)
end
function SDissolveGroupFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SDissolveGroupFail:sizepolicy(size)
  return size <= 65535
end
return SDissolveGroupFail
