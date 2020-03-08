local CGetSignState = class("CGetSignState")
CGetSignState.TYPEID = 12589945
function CGetSignState:ctor()
  self.id = 12589945
end
function CGetSignState:marshal(os)
end
function CGetSignState:unmarshal(os)
end
function CGetSignState:sizepolicy(size)
  return size <= 65535
end
return CGetSignState
