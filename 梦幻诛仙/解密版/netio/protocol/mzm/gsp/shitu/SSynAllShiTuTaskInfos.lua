local SSynAllShiTuTaskInfos = class("SSynAllShiTuTaskInfos")
SSynAllShiTuTaskInfos.TYPEID = 12601634
function SSynAllShiTuTaskInfos:ctor(all_shitu_task_infos)
  self.id = 12601634
  self.all_shitu_task_infos = all_shitu_task_infos or {}
end
function SSynAllShiTuTaskInfos:marshal(os)
  os:marshalCompactUInt32(table.getn(self.all_shitu_task_infos))
  for _, v in ipairs(self.all_shitu_task_infos) do
    v:marshal(os)
  end
end
function SSynAllShiTuTaskInfos:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.shitu.ShiTuTaskInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.all_shitu_task_infos, v)
  end
end
function SSynAllShiTuTaskInfos:sizepolicy(size)
  return size <= 65535
end
return SSynAllShiTuTaskInfos
