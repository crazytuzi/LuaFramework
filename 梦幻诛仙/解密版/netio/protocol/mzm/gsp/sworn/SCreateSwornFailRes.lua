local SCreateSwornFailRes = class("SCreateSwornFailRes")
SCreateSwornFailRes.TYPEID = 12597769
SCreateSwornFailRes.ERROR_UNKNOWN = 0
SCreateSwornFailRes.ERROR_CREATE_TEAM = 1
SCreateSwornFailRes.ERROR_PLAYERSWORN = 2
SCreateSwornFailRes.ERROR_CREATE_PLAYERCOUNT = 3
SCreateSwornFailRes.ERROR_CREATE_NOTFRIEND = 4
SCreateSwornFailRes.ERROR_CREATE_FRIENDVALUE = 5
SCreateSwornFailRes.ERROR_CREATE_NOTAGREE = 6
SCreateSwornFailRes.ERROR_CREATE_NOTAGREENAME = 7
SCreateSwornFailRes.ERROR_CREATE_SILVER = 8
SCreateSwornFailRes.ERROR_CREATE_OVERTIME = 9
SCreateSwornFailRes.ERROR_CREATE_TEAMCHANGE = 10
SCreateSwornFailRes.ERROR_CREATE_TEAMLEADER = 11
SCreateSwornFailRes.ERROR_CREATE_OVERLAP = 12
SCreateSwornFailRes.ERROR_CREATE_PLAYERLEVEL = 13
SCreateSwornFailRes.ERROR_NAME_OVERLAP = 14
SCreateSwornFailRes.ERROR_TEAM_MEMBER_STATUS = 15
function SCreateSwornFailRes:ctor(resultcode, name1, name2)
  self.id = 12597769
  self.resultcode = resultcode or nil
  self.name1 = name1 or nil
  self.name2 = name2 or nil
end
function SCreateSwornFailRes:marshal(os)
  os:marshalInt32(self.resultcode)
  os:marshalString(self.name1)
  os:marshalString(self.name2)
end
function SCreateSwornFailRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
  self.name1 = os:unmarshalString()
  self.name2 = os:unmarshalString()
end
function SCreateSwornFailRes:sizepolicy(size)
  return size <= 65535
end
return SCreateSwornFailRes
