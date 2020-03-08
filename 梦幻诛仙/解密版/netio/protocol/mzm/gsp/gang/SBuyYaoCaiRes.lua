local SBuyYaoCaiRes = class("SBuyYaoCaiRes")
SBuyYaoCaiRes.TYPEID = 12589926
function SBuyYaoCaiRes:ctor(itemId)
  self.id = 12589926
  self.itemId = itemId or nil
end
function SBuyYaoCaiRes:marshal(os)
  os:marshalInt32(self.itemId)
end
function SBuyYaoCaiRes:unmarshal(os)
  self.itemId = os:unmarshalInt32()
end
function SBuyYaoCaiRes:sizepolicy(size)
  return size <= 65535
end
return SBuyYaoCaiRes
