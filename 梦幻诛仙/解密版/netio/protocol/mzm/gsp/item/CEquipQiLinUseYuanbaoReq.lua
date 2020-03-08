local CEquipQiLinUseYuanbaoReq = class("CEquipQiLinUseYuanbaoReq")
CEquipQiLinUseYuanbaoReq.TYPEID = 12584853
function CEquipQiLinUseYuanbaoReq:ctor(bagid, key, itemid, itemNum, clientNeedYuanbao, clientYuanbao)
  self.id = 12584853
  self.bagid = bagid or nil
  self.key = key or nil
  self.itemid = itemid or nil
  self.itemNum = itemNum or nil
  self.clientNeedYuanbao = clientNeedYuanbao or nil
  self.clientYuanbao = clientYuanbao or nil
end
function CEquipQiLinUseYuanbaoReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.key)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemNum)
  os:marshalInt32(self.clientNeedYuanbao)
  os:marshalInt64(self.clientYuanbao)
end
function CEquipQiLinUseYuanbaoReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.key = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
  self.clientNeedYuanbao = os:unmarshalInt32()
  self.clientYuanbao = os:unmarshalInt64()
end
function CEquipQiLinUseYuanbaoReq:sizepolicy(size)
  return size <= 65535
end
return CEquipQiLinUseYuanbaoReq
