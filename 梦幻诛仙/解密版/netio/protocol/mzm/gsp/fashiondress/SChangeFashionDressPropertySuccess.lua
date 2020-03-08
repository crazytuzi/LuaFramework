local SChangeFashionDressPropertySuccess = class("SChangeFashionDressPropertySuccess")
SChangeFashionDressPropertySuccess.TYPEID = 12603151
function SChangeFashionDressPropertySuccess:ctor(old_fashion_dress_cfg_id, new_fashion_dress_cfg_id)
  self.id = 12603151
  self.old_fashion_dress_cfg_id = old_fashion_dress_cfg_id or nil
  self.new_fashion_dress_cfg_id = new_fashion_dress_cfg_id or nil
end
function SChangeFashionDressPropertySuccess:marshal(os)
  os:marshalInt32(self.old_fashion_dress_cfg_id)
  os:marshalInt32(self.new_fashion_dress_cfg_id)
end
function SChangeFashionDressPropertySuccess:unmarshal(os)
  self.old_fashion_dress_cfg_id = os:unmarshalInt32()
  self.new_fashion_dress_cfg_id = os:unmarshalInt32()
end
function SChangeFashionDressPropertySuccess:sizepolicy(size)
  return size <= 65535
end
return SChangeFashionDressPropertySuccess
