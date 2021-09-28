local VoiceInter = {}
VoiceInter.cls_ios = "BdVoiceInter"
VoiceInter.cls_and = "com/hk/core/voice/NmgAudioRecorder"
function VoiceInter.setMessageListener(listener)
end
function VoiceInter.InitSDK(appKey, appSecret)
end
function VoiceInter.startRecognize(sampleRateInHz)
end
function VoiceInter.stopRecord()
end
function VoiceInter.cancelRecord()
end
function VoiceInter.enableGetVoiceVolumn(isEnable)
end
function VoiceInter.getCurrentDBLevelMeter()
end
function VoiceInter.playPCMString(pcmString, sampleRateInHz)
end
return VoiceInter
