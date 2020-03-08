local SUseChildrenCharaterItemErrorRes = class("SUseChildrenCharaterItemErrorRes")
SUseChildrenCharaterItemErrorRes.TYPEID = 12609407
SUseChildrenCharaterItemErrorRes.ERROR_CHARACTER_TO_MAX = 1
SUseChildrenCharaterItemErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 2
SUseChildrenCharaterItemErrorRes.ERROR_DO_NOT_HAS_ITEM = 3
function SUseChildrenCharaterItemErrorRes:ctor(ret)
  self.id = 12609407
  self.ret = ret or nil
end
function SUseChildrenCharaterItemErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SUseChildrenCharaterItemErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SUseChildrenCharaterItemErrorRes:sizepolicy(size)
  return size <= 65535
end
return SUseChildrenCharaterItemErrorRes
