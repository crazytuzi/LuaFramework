local OctetsStream = require("netio.OctetsStream")
local AccessWayInfo = class("AccessWayInfo")
function AccessWayInfo:ctor(accessWayType, idList)
  self.accessWayType = accessWayType or nil
  self.idList = idList or {}
end
function AccessWayInfo:marshal(os)
  os:marshalInt32(self.accessWayType)
  os:marshalCompactUInt32(table.getn(self.idList))
  for _, v in ipairs(self.idList) do
    os:marshalInt32(v)
  end
end
function AccessWayInfo:unmarshal(os)
  self.accessWayType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.idList, v)
  end
end
return AccessWayInfo
