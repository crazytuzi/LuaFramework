local SGiveItemSuccess = class("SGiveItemSuccess")
SGiveItemSuccess.TYPEID = 12584756
function SGiveItemSuccess:ctor(roleid)
  self.id = 12584756
  self.roleid = roleid or nil
end
function SGiveItemSuccess:marshal(os)
  os:marshalInt64(self.roleid)
end
function SGiveItemSuccess:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SGiveItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SGiveItemSuccess
