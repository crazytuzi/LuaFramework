local SStoryWallInfoRes = class("SStoryWallInfoRes")
SStoryWallInfoRes.TYPEID = 12606469
function SStoryWallInfoRes:ctor(storyids, readstoryids)
  self.id = 12606469
  self.storyids = storyids or {}
  self.readstoryids = readstoryids or {}
end
function SStoryWallInfoRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.storyids))
  for _, v in ipairs(self.storyids) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.readstoryids))
  for _, v in ipairs(self.readstoryids) do
    os:marshalInt32(v)
  end
end
function SStoryWallInfoRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.storyids, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.readstoryids, v)
  end
end
function SStoryWallInfoRes:sizepolicy(size)
  return size <= 65535
end
return SStoryWallInfoRes
