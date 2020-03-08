local SSyncClearApplyList = class("SSyncClearApplyList")
SSyncClearApplyList.TYPEID = 12589829
function SSyncClearApplyList:ctor()
  self.id = 12589829
end
function SSyncClearApplyList:marshal(os)
end
function SSyncClearApplyList:unmarshal(os)
end
function SSyncClearApplyList:sizepolicy(size)
  return size <= 65535
end
return SSyncClearApplyList
