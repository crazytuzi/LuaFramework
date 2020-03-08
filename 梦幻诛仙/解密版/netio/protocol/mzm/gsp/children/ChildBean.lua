local OctetsStream = require("netio.OctetsStream")
local ChildBean = class("ChildBean")
ChildBean.BABY_PERIOD = 0
ChildBean.CHILDHOOD_PERIOD = 1
ChildBean.ADULT_PERIOD = 2
function ChildBean:ctor(child_id, child_name, child_gender, child_model_cfg_id_map, child_period, child_belong_role_id, child_another_parent_role_id, child_period_info, fashions)
  self.child_id = child_id or nil
  self.child_name = child_name or nil
  self.child_gender = child_gender or nil
  self.child_model_cfg_id_map = child_model_cfg_id_map or {}
  self.child_period = child_period or nil
  self.child_belong_role_id = child_belong_role_id or nil
  self.child_another_parent_role_id = child_another_parent_role_id or nil
  self.child_period_info = child_period_info or nil
  self.fashions = fashions or {}
end
function ChildBean:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalOctets(self.child_name)
  os:marshalInt32(self.child_gender)
  do
    local _size_ = 0
    for _, _ in pairs(self.child_model_cfg_id_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.child_model_cfg_id_map) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.child_period)
  os:marshalInt64(self.child_belong_role_id)
  os:marshalInt64(self.child_another_parent_role_id)
  os:marshalOctets(self.child_period_info)
  local _size_ = 0
  for _, _ in pairs(self.fashions) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.fashions) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function ChildBean:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.child_name = os:unmarshalOctets()
  self.child_gender = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.child_model_cfg_id_map[k] = v
  end
  self.child_period = os:unmarshalInt32()
  self.child_belong_role_id = os:unmarshalInt64()
  self.child_another_parent_role_id = os:unmarshalInt64()
  self.child_period_info = os:unmarshalOctets()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.children.DressedInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.fashions[k] = v
  end
end
return ChildBean
