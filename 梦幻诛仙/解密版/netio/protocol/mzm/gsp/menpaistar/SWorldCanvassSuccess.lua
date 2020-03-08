local SWorldCanvassSuccess = class("SWorldCanvassSuccess")
SWorldCanvassSuccess.TYPEID = 12612360
function SWorldCanvassSuccess:ctor(target_roleid)
  self.id = 12612360
  self.target_roleid = target_roleid or nil
end
function SWorldCanvassSuccess:marshal(os)
  os:marshalInt64(self.target_roleid)
end
function SWorldCanvassSuccess:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
end
function SWorldCanvassSuccess:sizepolicy(size)
  return size <= 65535
end
return SWorldCanvassSuccess
