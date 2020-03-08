local OctetsStream = require("netio.OctetsStream")
local MiFangInfo = class("MiFangInfo")
function MiFangInfo:ctor(itemList, cfgId, endTime, useCount, totalCount)
  self.itemList = itemList or {}
  self.cfgId = cfgId or nil
  self.endTime = endTime or nil
  self.useCount = useCount or nil
  self.totalCount = totalCount or nil
end
function MiFangInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.itemList))
  for _, v in ipairs(self.itemList) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.cfgId)
  os:marshalInt64(self.endTime)
  os:marshalInt32(self.useCount)
  os:marshalInt32(self.totalCount)
end
function MiFangInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemList, v)
  end
  self.cfgId = os:unmarshalInt32()
  self.endTime = os:unmarshalInt64()
  self.useCount = os:unmarshalInt32()
  self.totalCount = os:unmarshalInt32()
end
return MiFangInfo
