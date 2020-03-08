local SSyncArtifactInformation = class("SSyncArtifactInformation")
SSyncArtifactInformation.TYPEID = 12618248
function SSyncArtifactInformation:ctor(artifact_map, equipped_artifact_class)
  self.id = 12618248
  self.artifact_map = artifact_map or {}
  self.equipped_artifact_class = equipped_artifact_class or nil
end
function SSyncArtifactInformation:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.artifact_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.artifact_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.equipped_artifact_class)
end
function SSyncArtifactInformation:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.fabaolingqi.FabaoArtifactInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.artifact_map[k] = v
  end
  self.equipped_artifact_class = os:unmarshalInt32()
end
function SSyncArtifactInformation:sizepolicy(size)
  return size <= 65535
end
return SSyncArtifactInformation
