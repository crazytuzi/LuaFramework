local SLoginWaitForOthers = class("SLoginWaitForOthers")
SLoginWaitForOthers.TYPEID = 12607260
function SLoginWaitForOthers:ctor(waitRoleInfos, ret)
  self.id = 12607260
  self.waitRoleInfos = waitRoleInfos or {}
  self.ret = ret or nil
end
function SLoginWaitForOthers:marshal(os)
  os:marshalCompactUInt32(table.getn(self.waitRoleInfos))
  for _, v in ipairs(self.waitRoleInfos) do
    v:marshal(os)
  end
  os:marshalInt32(self.ret)
end
function SLoginWaitForOthers:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.ladder.WaitRoleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.waitRoleInfos, v)
  end
  self.ret = os:unmarshalInt32()
end
function SLoginWaitForOthers:sizepolicy(size)
  return size <= 65535
end
return SLoginWaitForOthers
