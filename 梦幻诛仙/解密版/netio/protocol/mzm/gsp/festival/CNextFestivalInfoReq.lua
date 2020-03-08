local CNextFestivalInfoReq = class("CNextFestivalInfoReq")
CNextFestivalInfoReq.TYPEID = 12600070
function CNextFestivalInfoReq:ctor()
  self.id = 12600070
end
function CNextFestivalInfoReq:marshal(os)
end
function CNextFestivalInfoReq:unmarshal(os)
end
function CNextFestivalInfoReq:sizepolicy(size)
  return size <= 65535
end
return CNextFestivalInfoReq
