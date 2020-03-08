local SAccountNumLimit = class("SAccountNumLimit")
SAccountNumLimit.TYPEID = 12590098
function SAccountNumLimit:ctor()
  self.id = 12590098
end
function SAccountNumLimit:marshal(os)
end
function SAccountNumLimit:unmarshal(os)
end
function SAccountNumLimit:sizepolicy(size)
  return size <= 10240
end
return SAccountNumLimit
