local CGetOnlineExpRewardReq = class("CGetOnlineExpRewardReq")
CGetOnlineExpRewardReq.TYPEID = 12587598
function CGetOnlineExpRewardReq:ctor()
  self.id = 12587598
end
function CGetOnlineExpRewardReq:marshal(os)
end
function CGetOnlineExpRewardReq:unmarshal(os)
end
function CGetOnlineExpRewardReq:sizepolicy(size)
  return size <= 65535
end
return CGetOnlineExpRewardReq
