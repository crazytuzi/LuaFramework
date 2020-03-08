local CRecoveryCatToItem = class("CRecoveryCatToItem")
CRecoveryCatToItem.TYPEID = 12605704
function CRecoveryCatToItem:ctor()
  self.id = 12605704
end
function CRecoveryCatToItem:marshal(os)
end
function CRecoveryCatToItem:unmarshal(os)
end
function CRecoveryCatToItem:sizepolicy(size)
  return size <= 65535
end
return CRecoveryCatToItem
