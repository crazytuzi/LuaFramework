local CGetModuleFunSwitchesReq = class("CGetModuleFunSwitchesReq")
CGetModuleFunSwitchesReq.TYPEID = 12599041
function CGetModuleFunSwitchesReq:ctor()
  self.id = 12599041
end
function CGetModuleFunSwitchesReq:marshal(os)
end
function CGetModuleFunSwitchesReq:unmarshal(os)
end
function CGetModuleFunSwitchesReq:sizepolicy(size)
  return size <= 65535
end
return CGetModuleFunSwitchesReq
