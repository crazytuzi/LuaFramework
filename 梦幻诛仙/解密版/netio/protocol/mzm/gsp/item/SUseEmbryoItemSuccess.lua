local AnimalInfo = require("netio.protocol.mzm.gsp.zoo.AnimalInfo")
local SUseEmbryoItemSuccess = class("SUseEmbryoItemSuccess")
SUseEmbryoItemSuccess.TYPEID = 12584871
function SUseEmbryoItemSuccess:ctor(item_cfgid, used_num, animal_info)
  self.id = 12584871
  self.item_cfgid = item_cfgid or nil
  self.used_num = used_num or nil
  self.animal_info = animal_info or AnimalInfo.new()
end
function SUseEmbryoItemSuccess:marshal(os)
  os:marshalInt32(self.item_cfgid)
  os:marshalInt32(self.used_num)
  self.animal_info:marshal(os)
end
function SUseEmbryoItemSuccess:unmarshal(os)
  self.item_cfgid = os:unmarshalInt32()
  self.used_num = os:unmarshalInt32()
  self.animal_info = AnimalInfo.new()
  self.animal_info:unmarshal(os)
end
function SUseEmbryoItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseEmbryoItemSuccess
