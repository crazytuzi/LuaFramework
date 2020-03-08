local SNewMemberConfirmSwornRes = class("SNewMemberConfirmSwornRes")
SNewMemberConfirmSwornRes.TYPEID = 12597806
SNewMemberConfirmSwornRes.SUCCESS = 0
SNewMemberConfirmSwornRes.ERROR_UNKNOWN = 1
SNewMemberConfirmSwornRes.ERROR_NOTAGREE = 2
SNewMemberConfirmSwornRes.ERROR_TITLENAME = 3
SNewMemberConfirmSwornRes.ERROR_TEAM_STATUT = 4
function SNewMemberConfirmSwornRes:ctor(resultcode)
  self.id = 12597806
  self.resultcode = resultcode or nil
end
function SNewMemberConfirmSwornRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SNewMemberConfirmSwornRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SNewMemberConfirmSwornRes:sizepolicy(size)
  return size <= 65535
end
return SNewMemberConfirmSwornRes
