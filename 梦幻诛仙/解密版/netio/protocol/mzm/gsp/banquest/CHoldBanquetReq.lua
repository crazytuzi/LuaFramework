local CHoldBanquetReq = class("CHoldBanquetReq")
CHoldBanquetReq.TYPEID = 12605954
function CHoldBanquetReq:ctor()
  self.id = 12605954
end
function CHoldBanquetReq:marshal(os)
end
function CHoldBanquetReq:unmarshal(os)
end
function CHoldBanquetReq:sizepolicy(size)
  return size <= 65535
end
return CHoldBanquetReq
