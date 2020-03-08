local CAttendMysteryVisitorReq = class("CAttendMysteryVisitorReq")
CAttendMysteryVisitorReq.TYPEID = 12605508
function CAttendMysteryVisitorReq:ctor(mystery_visitor_cfg_id)
  self.id = 12605508
  self.mystery_visitor_cfg_id = mystery_visitor_cfg_id or nil
end
function CAttendMysteryVisitorReq:marshal(os)
  os:marshalInt32(self.mystery_visitor_cfg_id)
end
function CAttendMysteryVisitorReq:unmarshal(os)
  self.mystery_visitor_cfg_id = os:unmarshalInt32()
end
function CAttendMysteryVisitorReq:sizepolicy(size)
  return size <= 65535
end
return CAttendMysteryVisitorReq
