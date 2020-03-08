local SUseWuShiItemResponse = class("SUseWuShiItemResponse")
SUseWuShiItemResponse.TYPEID = 12618771
SUseWuShiItemResponse.GET_WU_SHI = 1
SUseWuShiItemResponse.SHOW_WU_SHI = 2
function SUseWuShiItemResponse:ctor(opt, wuShiCfgId)
  self.id = 12618771
  self.opt = opt or nil
  self.wuShiCfgId = wuShiCfgId or nil
end
function SUseWuShiItemResponse:marshal(os)
  os:marshalInt32(self.opt)
  os:marshalInt32(self.wuShiCfgId)
end
function SUseWuShiItemResponse:unmarshal(os)
  self.opt = os:unmarshalInt32()
  self.wuShiCfgId = os:unmarshalInt32()
end
function SUseWuShiItemResponse:sizepolicy(size)
  return size <= 65535
end
return SUseWuShiItemResponse
