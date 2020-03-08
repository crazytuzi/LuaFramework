local SGetSingleGroupInfoFail = class("SGetSingleGroupInfoFail")
SGetSingleGroupInfoFail.TYPEID = 12605193
SGetSingleGroupInfoFail.GROUP_NOT_EXIST = 1
SGetSingleGroupInfoFail.NOT_IN_GROUP = 2
function SGetSingleGroupInfoFail:ctor(res)
  self.id = 12605193
  self.res = res or nil
end
function SGetSingleGroupInfoFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetSingleGroupInfoFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetSingleGroupInfoFail:sizepolicy(size)
  return size <= 65535
end
return SGetSingleGroupInfoFail
