local CEquipMake = class("CEquipMake")
CEquipMake.TYPEID = 12584759
function CEquipMake:ctor(eqpId, eqpMakeCfgId, isUseYuanbao, clientSilverNum, itemId2numMap, clientNeedYuanbao)
  self.id = 12584759
  self.eqpId = eqpId or nil
  self.eqpMakeCfgId = eqpMakeCfgId or nil
  self.isUseYuanbao = isUseYuanbao or nil
  self.clientSilverNum = clientSilverNum or nil
  self.itemId2numMap = itemId2numMap or {}
  self.clientNeedYuanbao = clientNeedYuanbao or nil
end
function CEquipMake:marshal(os)
  os:marshalInt32(self.eqpId)
  os:marshalInt32(self.eqpMakeCfgId)
  os:marshalInt32(self.isUseYuanbao)
  os:marshalInt64(self.clientSilverNum)
  do
    local _size_ = 0
    for _, _ in pairs(self.itemId2numMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.itemId2numMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.clientNeedYuanbao)
end
function CEquipMake:unmarshal(os)
  self.eqpId = os:unmarshalInt32()
  self.eqpMakeCfgId = os:unmarshalInt32()
  self.isUseYuanbao = os:unmarshalInt32()
  self.clientSilverNum = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemId2numMap[k] = v
  end
  self.clientNeedYuanbao = os:unmarshalInt32()
end
function CEquipMake:sizepolicy(size)
  return size <= 65535
end
return CEquipMake
