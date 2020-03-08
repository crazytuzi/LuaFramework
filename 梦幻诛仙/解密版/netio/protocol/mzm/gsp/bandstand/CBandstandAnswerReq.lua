local CBandstandAnswerReq = class("CBandstandAnswerReq")
CBandstandAnswerReq.TYPEID = 12627977
function CBandstandAnswerReq:ctor(music_id, fragment_index, answer_index)
  self.id = 12627977
  self.music_id = music_id or nil
  self.fragment_index = fragment_index or nil
  self.answer_index = answer_index or nil
end
function CBandstandAnswerReq:marshal(os)
  os:marshalInt32(self.music_id)
  os:marshalInt32(self.fragment_index)
  os:marshalInt32(self.answer_index)
end
function CBandstandAnswerReq:unmarshal(os)
  self.music_id = os:unmarshalInt32()
  self.fragment_index = os:unmarshalInt32()
  self.answer_index = os:unmarshalInt32()
end
function CBandstandAnswerReq:sizepolicy(size)
  return size <= 65535
end
return CBandstandAnswerReq
