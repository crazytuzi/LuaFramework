local OctetsStream = require("netio.OctetsStream")
local GetCorpsZoneReq = class("GetCorpsZoneReq")
function GetCorpsZoneReq:ctor(activity_cfgid, corpsids, context)
  self.activity_cfgid = activity_cfgid or nil
  self.corpsids = corpsids or {}
  self.context = context or nil
end
function GetCorpsZoneReq:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalCompactUInt32(table.getn(self.corpsids))
  for _, v in ipairs(self.corpsids) do
    os:marshalInt64(v)
  end
  os:marshalOctets(self.context)
end
function GetCorpsZoneReq:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.corpsids, v)
  end
  self.context = os:unmarshalOctets()
end
return GetCorpsZoneReq
