local CComposeJewelAuto = class("CComposeJewelAuto")
CComposeJewelAuto.TYPEID = 12618764
function CComposeJewelAuto:ctor(jewelCfgId, isUseYuanBaoMakeup)
  self.id = 12618764
  self.jewelCfgId = jewelCfgId or nil
  self.isUseYuanBaoMakeup = isUseYuanBaoMakeup or nil
end
function CComposeJewelAuto:marshal(os)
  os:marshalInt32(self.jewelCfgId)
  os:marshalUInt8(self.isUseYuanBaoMakeup)
end
function CComposeJewelAuto:unmarshal(os)
  self.jewelCfgId = os:unmarshalInt32()
  self.isUseYuanBaoMakeup = os:unmarshalUInt8()
end
function CComposeJewelAuto:sizepolicy(size)
  return size <= 65535
end
return CComposeJewelAuto
