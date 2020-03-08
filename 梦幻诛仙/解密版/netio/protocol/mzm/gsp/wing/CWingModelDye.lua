local CWingModelDye = class("CWingModelDye")
CWingModelDye.TYPEID = 12596510
function CWingModelDye:ctor(modelId, itemid, isUseYuanbao, clientYuanbaoNum, clientNeedYuanbaoNum)
  self.id = 12596510
  self.modelId = modelId or nil
  self.itemid = itemid or nil
  self.isUseYuanbao = isUseYuanbao or nil
  self.clientYuanbaoNum = clientYuanbaoNum or nil
  self.clientNeedYuanbaoNum = clientNeedYuanbaoNum or nil
end
function CWingModelDye:marshal(os)
  os:marshalInt32(self.modelId)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.isUseYuanbao)
  os:marshalInt64(self.clientYuanbaoNum)
  os:marshalInt32(self.clientNeedYuanbaoNum)
end
function CWingModelDye:unmarshal(os)
  self.modelId = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.isUseYuanbao = os:unmarshalInt32()
  self.clientYuanbaoNum = os:unmarshalInt64()
  self.clientNeedYuanbaoNum = os:unmarshalInt32()
end
function CWingModelDye:sizepolicy(size)
  return size <= 65535
end
return CWingModelDye
