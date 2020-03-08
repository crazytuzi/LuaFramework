local SFlowerParadeCounddown = class("SFlowerParadeCounddown")
SFlowerParadeCounddown.TYPEID = 12625667
function SFlowerParadeCounddown:ctor(activityId, roleList, ocp, map, startTime)
  self.id = 12625667
  self.activityId = activityId or nil
  self.roleList = roleList or {}
  self.ocp = ocp or nil
  self.map = map or nil
  self.startTime = startTime or nil
end
function SFlowerParadeCounddown:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalCompactUInt32(table.getn(self.roleList))
  for _, v in ipairs(self.roleList) do
    v:marshal(os)
  end
  os:marshalInt32(self.ocp)
  os:marshalInt32(self.map)
  os:marshalInt64(self.startTime)
end
function SFlowerParadeCounddown:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.flowerparade.ParadeRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.roleList, v)
  end
  self.ocp = os:unmarshalInt32()
  self.map = os:unmarshalInt32()
  self.startTime = os:unmarshalInt64()
end
function SFlowerParadeCounddown:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeCounddown
