local SSynAddShengWangNum = class("SSynAddShengWangNum")
SSynAddShengWangNum.TYPEID = 12583438
function SSynAddShengWangNum:ctor(addNum)
  self.id = 12583438
  self.addNum = addNum or nil
end
function SSynAddShengWangNum:marshal(os)
  os:marshalInt32(self.addNum)
end
function SSynAddShengWangNum:unmarshal(os)
  self.addNum = os:unmarshalInt32()
end
function SSynAddShengWangNum:sizepolicy(size)
  return size <= 65535
end
return SSynAddShengWangNum
