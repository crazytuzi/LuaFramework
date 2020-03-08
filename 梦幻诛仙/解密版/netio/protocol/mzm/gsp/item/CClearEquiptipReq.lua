local CClearEquiptipReq = class("CClearEquiptipReq")
CClearEquiptipReq.TYPEID = 12584837
function CClearEquiptipReq:ctor(statemask)
  self.id = 12584837
  self.statemask = statemask or nil
end
function CClearEquiptipReq:marshal(os)
  os:marshalInt32(self.statemask)
end
function CClearEquiptipReq:unmarshal(os)
  self.statemask = os:unmarshalInt32()
end
function CClearEquiptipReq:sizepolicy(size)
  return size <= 65535
end
return CClearEquiptipReq
