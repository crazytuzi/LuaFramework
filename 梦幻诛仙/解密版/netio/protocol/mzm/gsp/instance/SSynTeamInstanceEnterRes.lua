local SSynTeamInstanceEnterRes = class("SSynTeamInstanceEnterRes")
SSynTeamInstanceEnterRes.TYPEID = 12591369
SSynTeamInstanceEnterRes.SUC = 1
SSynTeamInstanceEnterRes.FAIL = 2
function SSynTeamInstanceEnterRes:ctor(ret)
  self.id = 12591369
  self.ret = ret or nil
end
function SSynTeamInstanceEnterRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SSynTeamInstanceEnterRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SSynTeamInstanceEnterRes:sizepolicy(size)
  return size <= 65535
end
return SSynTeamInstanceEnterRes
