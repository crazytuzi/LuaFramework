local SSynBountyInfo = class("SSynBountyInfo")
SSynBountyInfo.TYPEID = 12584193
function SSynBountyInfo:ctor(bountyCount, taskInfos)
  self.id = 12584193
  self.bountyCount = bountyCount or nil
  self.taskInfos = taskInfos or {}
end
function SSynBountyInfo:marshal(os)
  os:marshalInt32(self.bountyCount)
  local _size_ = 0
  for _, _ in pairs(self.taskInfos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.taskInfos) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynBountyInfo:unmarshal(os)
  self.bountyCount = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.bounty.BTaskInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.taskInfos[k] = v
  end
end
function SSynBountyInfo:sizepolicy(size)
  return size <= 65535
end
return SSynBountyInfo
