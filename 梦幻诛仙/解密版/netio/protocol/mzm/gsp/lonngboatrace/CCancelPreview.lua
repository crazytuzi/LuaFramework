local CCancelPreview = class("CCancelPreview")
CCancelPreview.TYPEID = 12619275
function CCancelPreview:ctor()
  self.id = 12619275
end
function CCancelPreview:marshal(os)
end
function CCancelPreview:unmarshal(os)
end
function CCancelPreview:sizepolicy(size)
  return size <= 65535
end
return CCancelPreview
