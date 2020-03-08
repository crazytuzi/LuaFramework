local OctetsStream = require("netio.OctetsStream")
local GameStatus = class("GameStatus")
function GameStatus:ctor(start_time, stop_time, circle_reduce_count, next_circle_reduce_time, player_names, player_score_infos)
  self.start_time = start_time or nil
  self.stop_time = stop_time or nil
  self.circle_reduce_count = circle_reduce_count or nil
  self.next_circle_reduce_time = next_circle_reduce_time or nil
  self.player_names = player_names or {}
  self.player_score_infos = player_score_infos or {}
end
function GameStatus:marshal(os)
  os:marshalInt32(self.start_time)
  os:marshalInt32(self.stop_time)
  os:marshalInt32(self.circle_reduce_count)
  os:marshalInt32(self.next_circle_reduce_time)
  do
    local _size_ = 0
    for _, _ in pairs(self.player_names) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.player_names) do
      os:marshalInt64(k)
      os:marshalOctets(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.player_score_infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.player_score_infos) do
    os:marshalInt64(k)
    v:marshal(os)
  end
end
function GameStatus:unmarshal(os)
  self.start_time = os:unmarshalInt32()
  self.stop_time = os:unmarshalInt32()
  self.circle_reduce_count = os:unmarshalInt32()
  self.next_circle_reduce_time = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalOctets()
    self.player_names[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local BeanClazz = require("netio.protocol.mzm.gsp.ballbattle.PlayerScoreInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.player_score_infos[k] = v
  end
end
return GameStatus
