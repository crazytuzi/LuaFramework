local CGetChildGrowthDiary = class("CGetChildGrowthDiary")
CGetChildGrowthDiary.TYPEID = 12609390
function CGetChildGrowthDiary:ctor(child_id)
  self.id = 12609390
  self.child_id = child_id or nil
end
function CGetChildGrowthDiary:marshal(os)
  os:marshalInt64(self.child_id)
end
function CGetChildGrowthDiary:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function CGetChildGrowthDiary:sizepolicy(size)
  return size <= 65535
end
return CGetChildGrowthDiary
