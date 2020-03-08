local CPopup = class("CPopup")
CPopup.TYPEID = 12608002
function CPopup:ctor(popup_type)
  self.id = 12608002
  self.popup_type = popup_type or nil
end
function CPopup:marshal(os)
  os:marshalInt32(self.popup_type)
end
function CPopup:unmarshal(os)
  self.popup_type = os:unmarshalInt32()
end
function CPopup:sizepolicy(size)
  return size <= 65535
end
return CPopup
