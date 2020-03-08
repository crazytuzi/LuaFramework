local SGetAnimalMatesSuccess = class("SGetAnimalMatesSuccess")
SGetAnimalMatesSuccess.TYPEID = 12615446
function SGetAnimalMatesSuccess:ctor(animalid, mate_times, birth_time, mate_infos)
  self.id = 12615446
  self.animalid = animalid or nil
  self.mate_times = mate_times or nil
  self.birth_time = birth_time or nil
  self.mate_infos = mate_infos or {}
end
function SGetAnimalMatesSuccess:marshal(os)
  os:marshalInt64(self.animalid)
  os:marshalInt32(self.mate_times)
  os:marshalInt32(self.birth_time)
  os:marshalCompactUInt32(table.getn(self.mate_infos))
  for _, v in ipairs(self.mate_infos) do
    v:marshal(os)
  end
end
function SGetAnimalMatesSuccess:unmarshal(os)
  self.animalid = os:unmarshalInt64()
  self.mate_times = os:unmarshalInt32()
  self.birth_time = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.zoo.MateInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.mate_infos, v)
  end
end
function SGetAnimalMatesSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetAnimalMatesSuccess
