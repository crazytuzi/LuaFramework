local CCreateLifeSkillItem = class("CCreateLifeSkillItem")
CCreateLifeSkillItem.TYPEID = 12626689
function CCreateLifeSkillItem:ctor(activity_cfgid)
  self.id = 12626689
  self.activity_cfgid = activity_cfgid or nil
end
function CCreateLifeSkillItem:marshal(os)
  os:marshalInt32(self.activity_cfgid)
end
function CCreateLifeSkillItem:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
end
function CCreateLifeSkillItem:sizepolicy(size)
  return size <= 65535
end
return CCreateLifeSkillItem
