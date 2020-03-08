local CChangeWingView = class("CChangeWingView")
CChangeWingView.TYPEID = 12596494
function CChangeWingView:ctor(index, modelId, isshowwing)
  self.id = 12596494
  self.index = index or nil
  self.modelId = modelId or nil
  self.isshowwing = isshowwing or nil
end
function CChangeWingView:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.modelId)
  os:marshalInt32(self.isshowwing)
end
function CChangeWingView:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.modelId = os:unmarshalInt32()
  self.isshowwing = os:unmarshalInt32()
end
function CChangeWingView:sizepolicy(size)
  return size <= 65535
end
return CChangeWingView
