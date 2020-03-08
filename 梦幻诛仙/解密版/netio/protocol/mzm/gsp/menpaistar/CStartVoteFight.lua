local CStartVoteFight = class("CStartVoteFight")
CStartVoteFight.TYPEID = 12612376
function CStartVoteFight:ctor()
  self.id = 12612376
end
function CStartVoteFight:marshal(os)
end
function CStartVoteFight:unmarshal(os)
end
function CStartVoteFight:sizepolicy(size)
  return size <= 65535
end
return CStartVoteFight
