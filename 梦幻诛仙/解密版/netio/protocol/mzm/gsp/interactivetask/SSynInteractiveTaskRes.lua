local SSynInteractiveTaskRes = class("SSynInteractiveTaskRes")
SSynInteractiveTaskRes.TYPEID = 12610314
function SSynInteractiveTaskRes:ctor(typeid2graphs)
  self.id = 12610314
  self.typeid2graphs = typeid2graphs or {}
end
function SSynInteractiveTaskRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.typeid2graphs) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.typeid2graphs) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function SSynInteractiveTaskRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.interactivetask.TaskInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.typeid2graphs[k] = v
  end
end
function SSynInteractiveTaskRes:sizepolicy(size)
  return size <= 65535
end
return SSynInteractiveTaskRes
