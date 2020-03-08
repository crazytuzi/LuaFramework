local STransforToRobLocationRes = class("STransforToRobLocationRes")
STransforToRobLocationRes.TYPEID = 12599854
STransforToRobLocationRes.ROB_MARRIAGE_END = 1
function STransforToRobLocationRes:ctor(result)
  self.id = 12599854
  self.result = result or nil
end
function STransforToRobLocationRes:marshal(os)
  os:marshalInt32(self.result)
end
function STransforToRobLocationRes:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function STransforToRobLocationRes:sizepolicy(size)
  return size <= 65535
end
return STransforToRobLocationRes
