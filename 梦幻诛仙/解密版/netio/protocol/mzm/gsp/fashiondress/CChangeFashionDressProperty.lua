local CChangeFashionDressProperty = class("CChangeFashionDressProperty")
CChangeFashionDressProperty.TYPEID = 12603153
function CChangeFashionDressProperty:ctor(old_fashion_dress_cfg_id, new_fashion_dress_cfg_id)
  self.id = 12603153
  self.old_fashion_dress_cfg_id = old_fashion_dress_cfg_id or nil
  self.new_fashion_dress_cfg_id = new_fashion_dress_cfg_id or nil
end
function CChangeFashionDressProperty:marshal(os)
  os:marshalInt32(self.old_fashion_dress_cfg_id)
  os:marshalInt32(self.new_fashion_dress_cfg_id)
end
function CChangeFashionDressProperty:unmarshal(os)
  self.old_fashion_dress_cfg_id = os:unmarshalInt32()
  self.new_fashion_dress_cfg_id = os:unmarshalInt32()
end
function CChangeFashionDressProperty:sizepolicy(size)
  return size <= 65535
end
return CChangeFashionDressProperty
