local SyncRecallLossInfo = class("SyncRecallLossInfo")
SyncRecallLossInfo.TYPEID = 12600367
function SyncRecallLossInfo:ctor(loss_infos, update_time, today_num)
  self.id = 12600367
  self.loss_infos = loss_infos or {}
  self.update_time = update_time or nil
  self.today_num = today_num or nil
end
function SyncRecallLossInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.loss_infos))
  for _, v in ipairs(self.loss_infos) do
    v:marshal(os)
  end
  os:marshalInt32(self.update_time)
  os:marshalInt32(self.today_num)
end
function SyncRecallLossInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.grc.RecallLossInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.loss_infos, v)
  end
  self.update_time = os:unmarshalInt32()
  self.today_num = os:unmarshalInt32()
end
function SyncRecallLossInfo:sizepolicy(size)
  return size <= 65535
end
return SyncRecallLossInfo
