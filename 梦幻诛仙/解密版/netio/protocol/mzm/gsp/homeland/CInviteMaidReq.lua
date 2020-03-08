local CInviteMaidReq = class("CInviteMaidReq")
CInviteMaidReq.TYPEID = 12605459
function CInviteMaidReq:ctor(maidCfgId)
  self.id = 12605459
  self.maidCfgId = maidCfgId or nil
end
function CInviteMaidReq:marshal(os)
  os:marshalInt32(self.maidCfgId)
end
function CInviteMaidReq:unmarshal(os)
  self.maidCfgId = os:unmarshalInt32()
end
function CInviteMaidReq:sizepolicy(size)
  return size <= 65535
end
return CInviteMaidReq
