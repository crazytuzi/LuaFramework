local netsafetylock = {}
function netsafetylock.safetylockInfoUpdate(param, ptc_main, ptc_sub)
  print("netsafetylock.safetylockInfoUpdate:")
  if g_LocalPlayer then
    g_LocalPlayer:safetylockDataUpdate(param)
  end
end
function netsafetylock.safetylockHadUnlocked(param, ptc_main, ptc_sub)
  print("netsafetylock.safetylockHadUnlocked:")
  if g_LocalPlayer then
    g_LocalPlayer:needUnlockPwd()
  end
  PutItemToUpgradePackageZhuangbei()
  PutItemToUpgradeZhuangbei()
  ResetCreateZhuangbei()
  SendMessage(MsgID_ItemInfo_ShowSafeLock)
end
return netsafetylock
