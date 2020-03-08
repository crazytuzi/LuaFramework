local SGangCanvassSuccess = class("SGangCanvassSuccess")
SGangCanvassSuccess.TYPEID = 12612379
function SGangCanvassSuccess:ctor(target_roleid)
  self.id = 12612379
  self.target_roleid = target_roleid or nil
end
function SGangCanvassSuccess:marshal(os)
  os:marshalInt64(self.target_roleid)
end
function SGangCanvassSuccess:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
end
function SGangCanvassSuccess:sizepolicy(size)
  return size <= 65535
end
return SGangCanvassSuccess
