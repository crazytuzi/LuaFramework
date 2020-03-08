local CNewMemberConfirmSwornReq = class("CNewMemberConfirmSwornReq")
CNewMemberConfirmSwornReq.TYPEID = 12597807
CNewMemberConfirmSwornReq.CONFIRM_AGREE = 1
CNewMemberConfirmSwornReq.CONFIRM_NOTAGREE = 2
function CNewMemberConfirmSwornReq:ctor(confirm, title)
  self.id = 12597807
  self.confirm = confirm or nil
  self.title = title or nil
end
function CNewMemberConfirmSwornReq:marshal(os)
  os:marshalInt32(self.confirm)
  os:marshalString(self.title)
end
function CNewMemberConfirmSwornReq:unmarshal(os)
  self.confirm = os:unmarshalInt32()
  self.title = os:unmarshalString()
end
function CNewMemberConfirmSwornReq:sizepolicy(size)
  return size <= 65535
end
return CNewMemberConfirmSwornReq
