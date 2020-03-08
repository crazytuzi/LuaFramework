local SSyncRename = class("SSyncRename")
SSyncRename.TYPEID = 12589836
function SSyncRename:ctor(newName)
  self.id = 12589836
  self.newName = newName or nil
end
function SSyncRename:marshal(os)
  os:marshalString(self.newName)
end
function SSyncRename:unmarshal(os)
  self.newName = os:unmarshalString()
end
function SSyncRename:sizepolicy(size)
  return size <= 65535
end
return SSyncRename
