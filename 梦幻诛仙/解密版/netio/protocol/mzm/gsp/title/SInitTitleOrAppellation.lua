local SInitTitleOrAppellation = class("SInitTitleOrAppellation")
SInitTitleOrAppellation.TYPEID = 12593922
function SInitTitleOrAppellation:ctor(ownTitle, ownAppellation, activeTitle, activeAppellation, pro2appellationId)
  self.id = 12593922
  self.ownTitle = ownTitle or {}
  self.ownAppellation = ownAppellation or {}
  self.activeTitle = activeTitle or nil
  self.activeAppellation = activeAppellation or nil
  self.pro2appellationId = pro2appellationId or nil
end
function SInitTitleOrAppellation:marshal(os)
  os:marshalCompactUInt32(table.getn(self.ownTitle))
  for _, v in ipairs(self.ownTitle) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.ownAppellation))
  for _, v in ipairs(self.ownAppellation) do
    v:marshal(os)
  end
  os:marshalInt32(self.activeTitle)
  os:marshalInt32(self.activeAppellation)
  os:marshalInt32(self.pro2appellationId)
end
function SInitTitleOrAppellation:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.title.TitleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.ownTitle, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.title.AppellationInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.ownAppellation, v)
  end
  self.activeTitle = os:unmarshalInt32()
  self.activeAppellation = os:unmarshalInt32()
  self.pro2appellationId = os:unmarshalInt32()
end
function SInitTitleOrAppellation:sizepolicy(size)
  return size <= 65535
end
return SInitTitleOrAppellation
