local CGetShangHuiItemCalParams = class("CGetShangHuiItemCalParams")
CGetShangHuiItemCalParams.TYPEID = 12592656
function CGetShangHuiItemCalParams:ctor(itemId)
  self.id = 12592656
  self.itemId = itemId or nil
end
function CGetShangHuiItemCalParams:marshal(os)
  os:marshalInt32(self.itemId)
end
function CGetShangHuiItemCalParams:unmarshal(os)
  self.itemId = os:unmarshalInt32()
end
function CGetShangHuiItemCalParams:sizepolicy(size)
  return size <= 65535
end
return CGetShangHuiItemCalParams
