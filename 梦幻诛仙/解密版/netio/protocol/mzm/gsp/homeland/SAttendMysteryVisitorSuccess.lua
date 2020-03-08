local SAttendMysteryVisitorSuccess = class("SAttendMysteryVisitorSuccess")
SAttendMysteryVisitorSuccess.TYPEID = 12605507
function SAttendMysteryVisitorSuccess:ctor(mystery_visitor_cfg_id)
  self.id = 12605507
  self.mystery_visitor_cfg_id = mystery_visitor_cfg_id or nil
end
function SAttendMysteryVisitorSuccess:marshal(os)
  os:marshalInt32(self.mystery_visitor_cfg_id)
end
function SAttendMysteryVisitorSuccess:unmarshal(os)
  self.mystery_visitor_cfg_id = os:unmarshalInt32()
end
function SAttendMysteryVisitorSuccess:sizepolicy(size)
  return size <= 65535
end
return SAttendMysteryVisitorSuccess
