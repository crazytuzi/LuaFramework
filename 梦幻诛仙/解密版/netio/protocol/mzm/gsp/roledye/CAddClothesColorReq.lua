local CAddClothesColorReq = class("CAddClothesColorReq")
CAddClothesColorReq.TYPEID = 12597251
function CAddClothesColorReq:ctor(hairid, clothid, fashionDressCfgId, hairItemCfgId2useyuanbao, clothItemCfgId2useyuanbao)
  self.id = 12597251
  self.hairid = hairid or nil
  self.clothid = clothid or nil
  self.fashionDressCfgId = fashionDressCfgId or nil
  self.hairItemCfgId2useyuanbao = hairItemCfgId2useyuanbao or {}
  self.clothItemCfgId2useyuanbao = clothItemCfgId2useyuanbao or {}
end
function CAddClothesColorReq:marshal(os)
  os:marshalInt32(self.hairid)
  os:marshalInt32(self.clothid)
  os:marshalInt32(self.fashionDressCfgId)
  do
    local _size_ = 0
    for _, _ in pairs(self.hairItemCfgId2useyuanbao) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.hairItemCfgId2useyuanbao) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.clothItemCfgId2useyuanbao) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.clothItemCfgId2useyuanbao) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function CAddClothesColorReq:unmarshal(os)
  self.hairid = os:unmarshalInt32()
  self.clothid = os:unmarshalInt32()
  self.fashionDressCfgId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.hairItemCfgId2useyuanbao[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.clothItemCfgId2useyuanbao[k] = v
  end
end
function CAddClothesColorReq:sizepolicy(size)
  return size <= 65535
end
return CAddClothesColorReq
