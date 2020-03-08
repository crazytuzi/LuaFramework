local OctetsStream = require("netio.OctetsStream")
local JiuXiaoMapDataBean = class("JiuXiaoMapDataBean")
JiuXiaoMapDataBean.NOT_AWARD = 0
JiuXiaoMapDataBean.AWARDED = 1
function JiuXiaoMapDataBean:ctor(awarded, cfgid, processes)
  self.awarded = awarded or nil
  self.cfgid = cfgid or nil
  self.processes = processes or {}
end
function JiuXiaoMapDataBean:marshal(os)
  os:marshalInt32(self.awarded)
  os:marshalInt32(self.cfgid)
  os:marshalCompactUInt32(table.getn(self.processes))
  for _, v in ipairs(self.processes) do
    os:marshalInt32(v)
  end
end
function JiuXiaoMapDataBean:unmarshal(os)
  self.awarded = os:unmarshalInt32()
  self.cfgid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.processes, v)
  end
end
return JiuXiaoMapDataBean
