local CReportMusicGameResult = class("CReportMusicGameResult")
CReportMusicGameResult.TYPEID = 12609793
CReportMusicGameResult.RIGHT = 0
CReportMusicGameResult.WRONG = 1
function CReportMusicGameResult:ctor(game_id, turn_index, result)
  self.id = 12609793
  self.game_id = game_id or nil
  self.turn_index = turn_index or nil
  self.result = result or nil
end
function CReportMusicGameResult:marshal(os)
  os:marshalInt32(self.game_id)
  os:marshalInt32(self.turn_index)
  os:marshalInt32(self.result)
end
function CReportMusicGameResult:unmarshal(os)
  self.game_id = os:unmarshalInt32()
  self.turn_index = os:unmarshalInt32()
  self.result = os:unmarshalInt32()
end
function CReportMusicGameResult:sizepolicy(size)
  return size <= 65535
end
return CReportMusicGameResult
