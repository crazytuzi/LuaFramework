local SCreateLifeSkillItemSuccess = class("SCreateLifeSkillItemSuccess")
SCreateLifeSkillItemSuccess.TYPEID = 12626690
function SCreateLifeSkillItemSuccess:ctor(activity_cfgid, item_id, item_num)
  self.id = 12626690
  self.activity_cfgid = activity_cfgid or nil
  self.item_id = item_id or nil
  self.item_num = item_num or nil
end
function SCreateLifeSkillItemSuccess:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.item_id)
  os:marshalInt32(self.item_num)
end
function SCreateLifeSkillItemSuccess:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.item_id = os:unmarshalInt32()
  self.item_num = os:unmarshalInt32()
end
function SCreateLifeSkillItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SCreateLifeSkillItemSuccess
