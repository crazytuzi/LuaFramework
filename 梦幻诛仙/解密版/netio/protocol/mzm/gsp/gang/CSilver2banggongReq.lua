local CSilver2banggongReq = class("CSilver2banggongReq")
CSilver2banggongReq.TYPEID = 12589912
function CSilver2banggongReq:ctor(level)
  self.id = 12589912
  self.level = level or nil
end
function CSilver2banggongReq:marshal(os)
  os:marshalInt32(self.level)
end
function CSilver2banggongReq:unmarshal(os)
  self.level = os:unmarshalInt32()
end
function CSilver2banggongReq:sizepolicy(size)
  return size <= 65535
end
return CSilver2banggongReq
