local SPopup = class("SPopup")
SPopup.TYPEID = 12608001
function SPopup:ctor(popup_type)
  self.id = 12608001
  self.popup_type = popup_type or nil
end
function SPopup:marshal(os)
  os:marshalInt32(self.popup_type)
end
function SPopup:unmarshal(os)
  self.popup_type = os:unmarshalInt32()
end
function SPopup:sizepolicy(size)
  return size <= 65535
end
return SPopup
