local CBuyGoldSilver = class("CBuyGoldSilver")
CBuyGoldSilver.TYPEID = 12584790
function CBuyGoldSilver:ctor(yuanbaonum, moneytype, clientyuanbao)
  self.id = 12584790
  self.yuanbaonum = yuanbaonum or nil
  self.moneytype = moneytype or nil
  self.clientyuanbao = clientyuanbao or nil
end
function CBuyGoldSilver:marshal(os)
  os:marshalInt32(self.yuanbaonum)
  os:marshalInt32(self.moneytype)
  os:marshalInt64(self.clientyuanbao)
end
function CBuyGoldSilver:unmarshal(os)
  self.yuanbaonum = os:unmarshalInt32()
  self.moneytype = os:unmarshalInt32()
  self.clientyuanbao = os:unmarshalInt64()
end
function CBuyGoldSilver:sizepolicy(size)
  return size <= 65535
end
return CBuyGoldSilver
