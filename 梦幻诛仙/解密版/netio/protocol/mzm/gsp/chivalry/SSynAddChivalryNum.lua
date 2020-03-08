local SSynAddChivalryNum = class("SSynAddChivalryNum")
SSynAddChivalryNum.TYPEID = 12598785
function SSynAddChivalryNum:ctor(addNum)
  self.id = 12598785
  self.addNum = addNum or nil
end
function SSynAddChivalryNum:marshal(os)
  os:marshalInt32(self.addNum)
end
function SSynAddChivalryNum:unmarshal(os)
  self.addNum = os:unmarshalInt32()
end
function SSynAddChivalryNum:sizepolicy(size)
  return size <= 65535
end
return SSynAddChivalryNum
