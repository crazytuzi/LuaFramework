local SSyncExpConvertXiuLian = class("SSyncExpConvertXiuLian")
SSyncExpConvertXiuLian.TYPEID = 12586018
function SSyncExpConvertXiuLian:ctor(roleExp, xiuLianExp)
  self.id = 12586018
  self.roleExp = roleExp or nil
  self.xiuLianExp = xiuLianExp or nil
end
function SSyncExpConvertXiuLian:marshal(os)
  os:marshalInt32(self.roleExp)
  os:marshalInt32(self.xiuLianExp)
end
function SSyncExpConvertXiuLian:unmarshal(os)
  self.roleExp = os:unmarshalInt32()
  self.xiuLianExp = os:unmarshalInt32()
end
function SSyncExpConvertXiuLian:sizepolicy(size)
  return size <= 65535
end
return SSyncExpConvertXiuLian
