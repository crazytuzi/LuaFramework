local SWinLoseBrd = class("SWinLoseBrd")
SWinLoseBrd.TYPEID = 12598549
SWinLoseBrd.RESULT__GIVE_UP = 1
SWinLoseBrd.RESULT__EARLY = 2
SWinLoseBrd.RESULT__TIMEOUT = 3
function SWinLoseBrd:ctor(winner_id, winner_name, loser_id, loser_name, result)
  self.id = 12598549
  self.winner_id = winner_id or nil
  self.winner_name = winner_name or nil
  self.loser_id = loser_id or nil
  self.loser_name = loser_name or nil
  self.result = result or nil
end
function SWinLoseBrd:marshal(os)
  os:marshalInt64(self.winner_id)
  os:marshalString(self.winner_name)
  os:marshalInt64(self.loser_id)
  os:marshalString(self.loser_name)
  os:marshalInt32(self.result)
end
function SWinLoseBrd:unmarshal(os)
  self.winner_id = os:unmarshalInt64()
  self.winner_name = os:unmarshalString()
  self.loser_id = os:unmarshalInt64()
  self.loser_name = os:unmarshalString()
  self.result = os:unmarshalInt32()
end
function SWinLoseBrd:sizepolicy(size)
  return size <= 65535
end
return SWinLoseBrd
