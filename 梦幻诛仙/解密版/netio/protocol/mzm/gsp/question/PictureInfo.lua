local OctetsStream = require("netio.OctetsStream")
local PictureInfo = class("PictureInfo")
function PictureInfo:ctor(resourceList, movePath, difficultyLevelId)
  self.resourceList = resourceList or {}
  self.movePath = movePath or {}
  self.difficultyLevelId = difficultyLevelId or nil
end
function PictureInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.resourceList))
  for _, v in ipairs(self.resourceList) do
    os:marshalInt32(v)
  end
  os:marshalCompactUInt32(table.getn(self.movePath))
  for _, v in ipairs(self.movePath) do
    v:marshal(os)
  end
  os:marshalInt32(self.difficultyLevelId)
end
function PictureInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.resourceList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.question.AllMoveSteps")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.movePath, v)
  end
  self.difficultyLevelId = os:unmarshalInt32()
end
return PictureInfo
