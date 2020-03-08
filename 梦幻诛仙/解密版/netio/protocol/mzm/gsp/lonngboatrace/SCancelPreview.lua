local SCancelPreview = class("SCancelPreview")
SCancelPreview.TYPEID = 12619268
function SCancelPreview:ctor()
  self.id = 12619268
end
function SCancelPreview:marshal(os)
end
function SCancelPreview:unmarshal(os)
end
function SCancelPreview:sizepolicy(size)
  return size <= 65535
end
return SCancelPreview
