local SMenpaiPVPNormalResult = class("SMenpaiPVPNormalResult")
SMenpaiPVPNormalResult.TYPEID = 12596226
SMenpaiPVPNormalResult.ENTER_MENPAI_MAP__MAX_LOSE_TIMES = 1
SMenpaiPVPNormalResult.ENTER_MENPAI_MAP__PARTICPATED = 2
function SMenpaiPVPNormalResult:ctor(result)
  self.id = 12596226
  self.result = result or nil
end
function SMenpaiPVPNormalResult:marshal(os)
  os:marshalInt32(self.result)
end
function SMenpaiPVPNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SMenpaiPVPNormalResult:sizepolicy(size)
  return size <= 65535
end
return SMenpaiPVPNormalResult
