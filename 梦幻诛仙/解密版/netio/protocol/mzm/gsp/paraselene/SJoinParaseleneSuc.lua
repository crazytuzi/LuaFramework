local SJoinParaseleneSuc = class("SJoinParaseleneSuc")
SJoinParaseleneSuc.TYPEID = 12598278
function SJoinParaseleneSuc:ctor()
  self.id = 12598278
end
function SJoinParaseleneSuc:marshal(os)
end
function SJoinParaseleneSuc:unmarshal(os)
end
function SJoinParaseleneSuc:sizepolicy(size)
  return size <= 65535
end
return SJoinParaseleneSuc
