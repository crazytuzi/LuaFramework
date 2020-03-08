local CReportBubbleGameResult = class("CReportBubbleGameResult")
CReportBubbleGameResult.TYPEID = 12610052
CReportBubbleGameResult.RIGHT = 0
CReportBubbleGameResult.WRONG = 1
function CReportBubbleGameResult:ctor(game_id, turn_index, result)
  self.id = 12610052
  self.game_id = game_id or nil
  self.turn_index = turn_index or nil
  self.result = result or nil
end
function CReportBubbleGameResult:marshal(os)
  os:marshalInt32(self.game_id)
  os:marshalInt32(self.turn_index)
  os:marshalInt32(self.result)
end
function CReportBubbleGameResult:unmarshal(os)
  self.game_id = os:unmarshalInt32()
  self.turn_index = os:unmarshalInt32()
  self.result = os:unmarshalInt32()
end
function CReportBubbleGameResult:sizepolicy(size)
  return size <= 65535
end
return CReportBubbleGameResult
