local SUseChildrenGrowthItemErrorRes = class("SUseChildrenGrowthItemErrorRes")
SUseChildrenGrowthItemErrorRes.TYPEID = 12609368
SUseChildrenGrowthItemErrorRes.ERROR_GROWTH_TO_MAX = 1
SUseChildrenGrowthItemErrorRes.ERROR_ITEM_USE_TO_MAX = 2
SUseChildrenGrowthItemErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 3
SUseChildrenGrowthItemErrorRes.ERROR_DO_NOT_HAS_ITEM = 4
function SUseChildrenGrowthItemErrorRes:ctor(ret)
  self.id = 12609368
  self.ret = ret or nil
end
function SUseChildrenGrowthItemErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SUseChildrenGrowthItemErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SUseChildrenGrowthItemErrorRes:sizepolicy(size)
  return size <= 65535
end
return SUseChildrenGrowthItemErrorRes
