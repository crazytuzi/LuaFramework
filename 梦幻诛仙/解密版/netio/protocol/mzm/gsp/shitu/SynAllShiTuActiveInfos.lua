local SynAllShiTuActiveInfos = class("SynAllShiTuActiveInfos")
SynAllShiTuActiveInfos.TYPEID = 12601654
function SynAllShiTuActiveInfos:ctor(all_shitu_active_infos)
  self.id = 12601654
  self.all_shitu_active_infos = all_shitu_active_infos or {}
end
function SynAllShiTuActiveInfos:marshal(os)
  os:marshalCompactUInt32(table.getn(self.all_shitu_active_infos))
  for _, v in ipairs(self.all_shitu_active_infos) do
    v:marshal(os)
  end
end
function SynAllShiTuActiveInfos:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.shitu.ShiTuActiveInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.all_shitu_active_infos, v)
  end
end
function SynAllShiTuActiveInfos:sizepolicy(size)
  return size <= 65535
end
return SynAllShiTuActiveInfos
