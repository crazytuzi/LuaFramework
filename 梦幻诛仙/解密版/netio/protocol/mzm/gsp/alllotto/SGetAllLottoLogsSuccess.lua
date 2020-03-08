local SGetAllLottoLogsSuccess = class("SGetAllLottoLogsSuccess")
SGetAllLottoLogsSuccess.TYPEID = 12626948
function SGetAllLottoLogsSuccess:ctor(activity_cfg_id, num, logs)
  self.id = 12626948
  self.activity_cfg_id = activity_cfg_id or nil
  self.num = num or nil
  self.logs = logs or {}
end
function SGetAllLottoLogsSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.num)
  os:marshalCompactUInt32(table.getn(self.logs))
  for _, v in ipairs(self.logs) do
    v:marshal(os)
  end
end
function SGetAllLottoLogsSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.alllotto.AllLottoLog")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.logs, v)
  end
end
function SGetAllLottoLogsSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAllLottoLogsSuccess
