local SCompetitionStartBrd = class("SCompetitionStartBrd")
SCompetitionStartBrd.TYPEID = 12598529
function SCompetitionStartBrd:ctor(opponent)
  self.id = 12598529
  self.opponent = opponent or nil
end
function SCompetitionStartBrd:marshal(os)
  os:marshalString(self.opponent)
end
function SCompetitionStartBrd:unmarshal(os)
  self.opponent = os:unmarshalString()
end
function SCompetitionStartBrd:sizepolicy(size)
  return size <= 65535
end
return SCompetitionStartBrd
