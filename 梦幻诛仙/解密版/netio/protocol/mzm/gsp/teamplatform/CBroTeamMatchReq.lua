local CBroTeamMatchReq = class("CBroTeamMatchReq")
CBroTeamMatchReq.TYPEID = 12593685
function CBroTeamMatchReq:ctor()
  self.id = 12593685
end
function CBroTeamMatchReq:marshal(os)
end
function CBroTeamMatchReq:unmarshal(os)
end
function CBroTeamMatchReq:sizepolicy(size)
  return size <= 65535
end
return CBroTeamMatchReq
