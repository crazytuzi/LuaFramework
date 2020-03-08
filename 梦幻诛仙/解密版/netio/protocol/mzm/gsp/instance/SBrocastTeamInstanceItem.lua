local SBrocastTeamInstanceItem = class("SBrocastTeamInstanceItem")
SBrocastTeamInstanceItem.TYPEID = 12591388
function SBrocastTeamInstanceItem:ctor(role_name, instance_cfg_id, item_cfg_id)
  self.id = 12591388
  self.role_name = role_name or nil
  self.instance_cfg_id = instance_cfg_id or nil
  self.item_cfg_id = item_cfg_id or nil
end
function SBrocastTeamInstanceItem:marshal(os)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.instance_cfg_id)
  os:marshalInt32(self.item_cfg_id)
end
function SBrocastTeamInstanceItem:unmarshal(os)
  self.role_name = os:unmarshalOctets()
  self.instance_cfg_id = os:unmarshalInt32()
  self.item_cfg_id = os:unmarshalInt32()
end
function SBrocastTeamInstanceItem:sizepolicy(size)
  return size <= 65535
end
return SBrocastTeamInstanceItem
