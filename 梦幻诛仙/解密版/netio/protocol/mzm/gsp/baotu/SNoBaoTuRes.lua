local SNoBaoTuRes = class("SNoBaoTuRes")
SNoBaoTuRes.TYPEID = 12583681
function SNoBaoTuRes:ctor()
  self.id = 12583681
end
function SNoBaoTuRes:marshal(os)
end
function SNoBaoTuRes:unmarshal(os)
end
function SNoBaoTuRes:sizepolicy(size)
  return size <= 65535
end
return SNoBaoTuRes
