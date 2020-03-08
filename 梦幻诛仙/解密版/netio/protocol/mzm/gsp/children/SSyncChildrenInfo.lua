local SSyncChildrenInfo = class("SSyncChildrenInfo")
SSyncChildrenInfo.TYPEID = 12609285
SSyncChildrenInfo.NO_CHILD_SHOW = -1
SSyncChildrenInfo.LOGIN = 0
SSyncChildrenInfo.DIVORCE = 1
SSyncChildrenInfo.MARRIAGE = 2
function SSyncChildrenInfo:ctor(child_info_map, show_child_id, show_child_period, bag_child_id_list, sync_type, discard_child_map)
  self.id = 12609285
  self.child_info_map = child_info_map or {}
  self.show_child_id = show_child_id or nil
  self.show_child_period = show_child_period or nil
  self.bag_child_id_list = bag_child_id_list or {}
  self.sync_type = sync_type or nil
  self.discard_child_map = discard_child_map or {}
end
function SSyncChildrenInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.child_info_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.child_info_map) do
      os:marshalInt64(k)
      v:marshal(os)
    end
  end
  os:marshalInt64(self.show_child_id)
  os:marshalInt32(self.show_child_period)
  os:marshalCompactUInt32(table.getn(self.bag_child_id_list))
  for _, v in ipairs(self.bag_child_id_list) do
    os:marshalInt64(v)
  end
  os:marshalInt32(self.sync_type)
  local _size_ = 0
  for _, _ in pairs(self.discard_child_map) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.discard_child_map) do
    os:marshalInt64(k)
    os:marshalInt64(v)
  end
end
function SSyncChildrenInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.children.ChildBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.child_info_map[k] = v
  end
  self.show_child_id = os:unmarshalInt64()
  self.show_child_period = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.bag_child_id_list, v)
  end
  self.sync_type = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt64()
    self.discard_child_map[k] = v
  end
end
function SSyncChildrenInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncChildrenInfo
