local CGiveUpBreed = class("CGiveUpBreed")
CGiveUpBreed.TYPEID = 12609317
function CGiveUpBreed:ctor()
  self.id = 12609317
end
function CGiveUpBreed:marshal(os)
end
function CGiveUpBreed:unmarshal(os)
end
function CGiveUpBreed:sizepolicy(size)
  return size <= 65535
end
return CGiveUpBreed
