local CComposeJewel = class("CComposeJewel")
CComposeJewel.TYPEID = 12618767
function CComposeJewel:ctor(jewelCfgId)
  self.id = 12618767
  self.jewelCfgId = jewelCfgId or nil
end
function CComposeJewel:marshal(os)
  os:marshalInt32(self.jewelCfgId)
end
function CComposeJewel:unmarshal(os)
  self.jewelCfgId = os:unmarshalInt32()
end
function CComposeJewel:sizepolicy(size)
  return size <= 65535
end
return CComposeJewel
