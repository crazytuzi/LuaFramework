local CAddNewMemberReq = class("CAddNewMemberReq")
CAddNewMemberReq.TYPEID = 12597790
function CAddNewMemberReq:ctor()
  self.id = 12597790
end
function CAddNewMemberReq:marshal(os)
end
function CAddNewMemberReq:unmarshal(os)
end
function CAddNewMemberReq:sizepolicy(size)
  return size <= 65535
end
return CAddNewMemberReq
