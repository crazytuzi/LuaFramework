local SFindFireworkSuc = class("SFindFireworkSuc")
SFindFireworkSuc.TYPEID = 12625154
function SFindFireworkSuc:ctor(activityId, name, num)
  self.id = 12625154
  self.activityId = activityId or nil
  self.name = name or nil
  self.num = num or nil
end
function SFindFireworkSuc:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalOctets(self.name)
  os:marshalInt32(self.num)
end
function SFindFireworkSuc:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.name = os:unmarshalOctets()
  self.num = os:unmarshalInt32()
end
function SFindFireworkSuc:sizepolicy(size)
  return size <= 65535
end
return SFindFireworkSuc
