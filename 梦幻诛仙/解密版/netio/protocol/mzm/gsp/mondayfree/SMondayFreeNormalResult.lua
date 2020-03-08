local SMondayFreeNormalResult = class("SMondayFreeNormalResult")
SMondayFreeNormalResult.TYPEID = 12626183
SMondayFreeNormalResult.MondayFree__NOT_OPEN = 1
SMondayFreeNormalResult.GetSundayAward__TIME_INVALID = 11
SMondayFreeNormalResult.GetSundayAward__ALREADY = 12
SMondayFreeNormalResult.GetMondayAward__TIME_INVALID = 21
SMondayFreeNormalResult.GetMondayAward__ALREADY = 22
SMondayFreeNormalResult.FinishShimen__TIME_INVALID = 31
SMondayFreeNormalResult.FinishShimen__ALREADY = 32
SMondayFreeNormalResult.FinishShimen__FAIL = 33
SMondayFreeNormalResult.FinishBaotu__TIME_INVALID = 41
SMondayFreeNormalResult.FinishBaotu__ALREADY = 42
SMondayFreeNormalResult.FinishBaotu__FAIL = 43
function SMondayFreeNormalResult:ctor(result)
  self.id = 12626183
  self.result = result or nil
end
function SMondayFreeNormalResult:marshal(os)
  os:marshalInt32(self.result)
end
function SMondayFreeNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SMondayFreeNormalResult:sizepolicy(size)
  return size <= 65535
end
return SMondayFreeNormalResult
