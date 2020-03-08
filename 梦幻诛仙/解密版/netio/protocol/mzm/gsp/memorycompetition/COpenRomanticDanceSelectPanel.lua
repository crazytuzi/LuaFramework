local COpenRomanticDanceSelectPanel = class("COpenRomanticDanceSelectPanel")
COpenRomanticDanceSelectPanel.TYPEID = 12613140
function COpenRomanticDanceSelectPanel:ctor()
  self.id = 12613140
end
function COpenRomanticDanceSelectPanel:marshal(os)
end
function COpenRomanticDanceSelectPanel:unmarshal(os)
end
function COpenRomanticDanceSelectPanel:sizepolicy(size)
  return size <= 65535
end
return COpenRomanticDanceSelectPanel
