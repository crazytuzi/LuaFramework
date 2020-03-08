local SGetIndianaLogsSuccess = class("SGetIndianaLogsSuccess")
SGetIndianaLogsSuccess.TYPEID = 12629005
function SGetIndianaLogsSuccess:ctor(activity_cfg_id, logs)
  self.id = 12629005
  self.activity_cfg_id = activity_cfg_id or nil
  self.logs = logs or {}
end
function SGetIndianaLogsSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalCompactUInt32(table.getn(self.logs))
  for _, v in ipairs(self.logs) do
    v:marshal(os)
  end
end
function SGetIndianaLogsSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.indiana.IndianaLog")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.logs, v)
  end
end
function SGetIndianaLogsSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetIndianaLogsSuccess
