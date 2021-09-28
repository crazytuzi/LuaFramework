local BdVoiceInter = {}
BdVoiceInter.cls_ios = "BdVoiceInter"
BdVoiceInter.cls_and = "com/nomoga/core/BdVoiceInter"
function BdVoiceInter.InitSDK(appKey, appSecret)
  if device.platform == "ios" then
  elseif device.platform == "android" then
    callStaticMethodJava(BdVoiceInter.cls_and, "InitSDK", {appKey, appSecret})
  end
end
function BdVoiceInter.setMessageListener(listener)
  if device.platform == "ios" then
  elseif device.platform == "android" then
    callStaticMethodJava(BdVoiceInter.cls_and, "setMessageListener", {listener})
  end
end
function BdVoiceInter.startVoiceRecognition()
  if device.platform == "ios" then
  elseif device.platform == "android" then
    local ok, ret = callStaticMethodJava(BdVoiceInter.cls_and, "startVoiceRecognition", {})
    if ok then
      local r, t = string.match(ret, "(.*),(.*)")
      return r == 1, t
    end
    return false
  end
end
function BdVoiceInter.finishVoiceRecognition()
  if device.platform == "ios" then
  elseif device.platform == "android" then
    local ok, ret = callStaticMethodJava(BdVoiceInter.cls_and, "finishVoiceRecognition", {})
    return ok
  end
end
return BdVoiceInter
