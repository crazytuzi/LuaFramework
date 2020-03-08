local SFinishBaotuRes = class("SFinishBaotuRes")
SFinishBaotuRes.TYPEID = 12626181
function SFinishBaotuRes:ctor()
  self.id = 12626181
end
function SFinishBaotuRes:marshal(os)
end
function SFinishBaotuRes:unmarshal(os)
end
function SFinishBaotuRes:sizepolicy(size)
  return size <= 65535
end
return SFinishBaotuRes
