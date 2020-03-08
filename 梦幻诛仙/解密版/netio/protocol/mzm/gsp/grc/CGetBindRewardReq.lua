local CGetBindRewardReq = class("CGetBindRewardReq")
CGetBindRewardReq.TYPEID = 12600377
function CGetBindRewardReq:ctor(open_id, bind_type)
  self.id = 12600377
  self.open_id = open_id or nil
  self.bind_type = bind_type or nil
end
function CGetBindRewardReq:marshal(os)
  os:marshalOctets(self.open_id)
  os:marshalInt32(self.bind_type)
end
function CGetBindRewardReq:unmarshal(os)
  self.open_id = os:unmarshalOctets()
  self.bind_type = os:unmarshalInt32()
end
function CGetBindRewardReq:sizepolicy(size)
  return size <= 65535
end
return CGetBindRewardReq
