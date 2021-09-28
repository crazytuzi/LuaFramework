channel = {
  no = 0,
  needUpdate = true,
  updateUrl = Update_Version_Url,
  gameParam = {},
  interClassName = nil,
  showLaunchLogo = false,
  showGM = true,
  showServerAccount = true,
  showSettingFAQ = true,
  showUserCenterOnly = false,
  showGiftInputCode = false,
  useNomogeAccount = false,
  needPayOrderidFromServer = false,
  showMoMoFriendList = false,
  useTalkingData = false,
  channelIdForTalkingData = nil,
  payGroupId = 2,
  devicePlatformType = nil,
  svrlog = false,
  errorWarning = false,
  needRename = nil
}
function channel.init()
  if device.platform == "ios" then
    channel.no = 10002
  else
    channel.no = 10001
  end
  channel.no = tostring(channel.no)
  print("channel no =", channel.no)
  local data = ChannelData[channel.no]
  dump(data)
  if data then
    for k, v in pairs(data) do
      channel[k] = v
    end
  end
  ResetChannelRenameParam()
  print("----------------------------------------------------")
  print("#channel.no \t\t\t\t\t=", channel.no)
  print("#channel.needUpdate \t\t\t=", channel.needUpdate)
  print("#channel.updateUrl \t\t\t=", channel.updateUrl)
  print("#channel.payGroupId \t\t\t=", channel.payGroupId)
  print("----------------------------------------------------")
end
function channel.getChannelIdForTalkingData()
  if channel.channelIdForTalkingData ~= nil then
    return tostring(channel.channelIdForTalkingData)
  end
  return tostring(channel.no)
end
channel.init()
