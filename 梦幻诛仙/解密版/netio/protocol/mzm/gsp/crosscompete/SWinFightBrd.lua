local SWinFightBrd = class("SWinFightBrd")
SWinFightBrd.TYPEID = 12616727
function SWinFightBrd:ctor(winner_leader, winner_number, loser_leader, loser_number, score)
  self.id = 12616727
  self.winner_leader = winner_leader or nil
  self.winner_number = winner_number or nil
  self.loser_leader = loser_leader or nil
  self.loser_number = loser_number or nil
  self.score = score or nil
end
function SWinFightBrd:marshal(os)
  os:marshalString(self.winner_leader)
  os:marshalInt32(self.winner_number)
  os:marshalString(self.loser_leader)
  os:marshalInt32(self.loser_number)
  os:marshalInt32(self.score)
end
function SWinFightBrd:unmarshal(os)
  self.winner_leader = os:unmarshalString()
  self.winner_number = os:unmarshalInt32()
  self.loser_leader = os:unmarshalString()
  self.loser_number = os:unmarshalInt32()
  self.score = os:unmarshalInt32()
end
function SWinFightBrd:sizepolicy(size)
  return size <= 65535
end
return SWinFightBrd
