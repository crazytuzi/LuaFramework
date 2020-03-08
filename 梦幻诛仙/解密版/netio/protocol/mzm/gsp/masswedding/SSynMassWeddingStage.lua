local SSynMassWeddingStage = class("SSynMassWeddingStage")
SSynMassWeddingStage.TYPEID = 12604935
SSynMassWeddingStage.BLESS_NO = 0
SSynMassWeddingStage.BLESS_YES = 1
SSynMassWeddingStage.MASSWEDDING_END_NO = 0
SSynMassWeddingStage.MASSWEDDING_END_YES = 1
function SSynMassWeddingStage:ctor(stage, blessed, supportSet, massweddingPlayEnd)
  self.id = 12604935
  self.stage = stage or nil
  self.blessed = blessed or nil
  self.supportSet = supportSet or {}
  self.massweddingPlayEnd = massweddingPlayEnd or nil
end
function SSynMassWeddingStage:marshal(os)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.blessed)
  do
    local _size_ = 0
    for _, _ in pairs(self.supportSet) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.supportSet) do
      os:marshalInt64(k)
    end
  end
  os:marshalInt32(self.massweddingPlayEnd)
end
function SSynMassWeddingStage:unmarshal(os)
  self.stage = os:unmarshalInt32()
  self.blessed = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.supportSet[v] = v
  end
  self.massweddingPlayEnd = os:unmarshalInt32()
end
function SSynMassWeddingStage:sizepolicy(size)
  return size <= 65535
end
return SSynMassWeddingStage
