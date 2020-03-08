local SBandstandAnswerFail = class("SBandstandAnswerFail")
SBandstandAnswerFail.TYPEID = 12627976
SBandstandAnswerFail.NOT_STARTED = 1
SBandstandAnswerFail.MUSIC_FRAGMENT_NOT_MATCH = 2
SBandstandAnswerFail.ALREADY_ANSWERED = 3
SBandstandAnswerFail.FRAGMENT_WITHOUT_LYRIC = 4
function SBandstandAnswerFail:ctor(error_code)
  self.id = 12627976
  self.error_code = error_code or nil
end
function SBandstandAnswerFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SBandstandAnswerFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SBandstandAnswerFail:sizepolicy(size)
  return size <= 65535
end
return SBandstandAnswerFail
