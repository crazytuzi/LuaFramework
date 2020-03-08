local SJiuXiaoPreciousItemBrd = class("SJiuXiaoPreciousItemBrd")
SJiuXiaoPreciousItemBrd.TYPEID = 12595476
function SJiuXiaoPreciousItemBrd:ctor(roleName, npcid, activityid, item2Num)
  self.id = 12595476
  self.roleName = roleName or nil
  self.npcid = npcid or nil
  self.activityid = activityid or nil
  self.item2Num = item2Num or {}
end
function SJiuXiaoPreciousItemBrd:marshal(os)
  os:marshalString(self.roleName)
  os:marshalInt32(self.npcid)
  os:marshalInt32(self.activityid)
  local _size_ = 0
  for _, _ in pairs(self.item2Num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.item2Num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SJiuXiaoPreciousItemBrd:unmarshal(os)
  self.roleName = os:unmarshalString()
  self.npcid = os:unmarshalInt32()
  self.activityid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item2Num[k] = v
  end
end
function SJiuXiaoPreciousItemBrd:sizepolicy(size)
  return size <= 65535
end
return SJiuXiaoPreciousItemBrd
