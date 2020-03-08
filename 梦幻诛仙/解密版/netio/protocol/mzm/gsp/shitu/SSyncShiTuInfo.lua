local ShiTuRoleInfoAndModelInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfoAndModelInfo")
local SSyncShiTuInfo = class("SSyncShiTuInfo")
SSyncShiTuInfo.TYPEID = 12601610
function SSyncShiTuInfo:ctor(masterInfo, nowApprenticeList, totalApprenticeNum, aleardy_awarded_cfg_id_set, is_chu_shi_state, now_pay_respect_times)
  self.id = 12601610
  self.masterInfo = masterInfo or ShiTuRoleInfoAndModelInfo.new()
  self.nowApprenticeList = nowApprenticeList or {}
  self.totalApprenticeNum = totalApprenticeNum or nil
  self.aleardy_awarded_cfg_id_set = aleardy_awarded_cfg_id_set or {}
  self.is_chu_shi_state = is_chu_shi_state or nil
  self.now_pay_respect_times = now_pay_respect_times or nil
end
function SSyncShiTuInfo:marshal(os)
  self.masterInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.nowApprenticeList))
  for _, v in ipairs(self.nowApprenticeList) do
    v:marshal(os)
  end
  os:marshalInt32(self.totalApprenticeNum)
  do
    local _size_ = 0
    for _, _ in pairs(self.aleardy_awarded_cfg_id_set) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.aleardy_awarded_cfg_id_set) do
      os:marshalInt32(k)
    end
  end
  os:marshalInt32(self.is_chu_shi_state)
  os:marshalInt32(self.now_pay_respect_times)
end
function SSyncShiTuInfo:unmarshal(os)
  self.masterInfo = ShiTuRoleInfoAndModelInfo.new()
  self.masterInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfoAndModelInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.nowApprenticeList, v)
  end
  self.totalApprenticeNum = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.aleardy_awarded_cfg_id_set[v] = v
  end
  self.is_chu_shi_state = os:unmarshalInt32()
  self.now_pay_respect_times = os:unmarshalInt32()
end
function SSyncShiTuInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncShiTuInfo
