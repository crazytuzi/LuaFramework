local CLeaveTreasureHunt = class("CLeaveTreasureHunt")
CLeaveTreasureHunt.TYPEID = 12633097
function CLeaveTreasureHunt:ctor(activity_cfg_id)
  self.id = 12633097
  self.activity_cfg_id = activity_cfg_id or nil
end
function CLeaveTreasureHunt:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CLeaveTreasureHunt:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CLeaveTreasureHunt:sizepolicy(size)
  return size <= 65535
end
return CLeaveTreasureHunt
