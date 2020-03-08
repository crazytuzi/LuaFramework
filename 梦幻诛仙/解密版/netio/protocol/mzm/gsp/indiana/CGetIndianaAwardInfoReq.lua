local CGetIndianaAwardInfoReq = class("CGetIndianaAwardInfoReq")
CGetIndianaAwardInfoReq.TYPEID = 12628993
function CGetIndianaAwardInfoReq:ctor(activity_cfg_id, turn, sortid)
  self.id = 12628993
  self.activity_cfg_id = activity_cfg_id or nil
  self.turn = turn or nil
  self.sortid = sortid or nil
end
function CGetIndianaAwardInfoReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.sortid)
end
function CGetIndianaAwardInfoReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function CGetIndianaAwardInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetIndianaAwardInfoReq
