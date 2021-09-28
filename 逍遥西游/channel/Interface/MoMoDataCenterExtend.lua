MoMoDataCenterExtend = {}
MoMoDataCenterExtend.m_OpenSign = false
MoMoDataCenterExtend.cls_and = "com/hk/core/MoMoDateCenter"
And_MoMoData_appid = "ex_xycq_bXwEMhv"
And_ChannelDir = {
  ["nomoga"] = "nomoga",
  ["lj_test"] = "lj_test",
  ["baidumobilegame"] = "Y1",
  ["uc"] = "Y2",
  ["xiaomi"] = "Y3",
  ["wandoujia"] = "Y4",
  ["360"] = "Y5",
  ["lj"] = "Y6",
  ["anzhi"] = "Y7",
  ["oppo"] = "Y8",
  ["meizu"] = "Y9",
  ["yiwan"] = "Y10",
  ["lenovoopenid"] = "Y11",
  ["huawei"] = "Y12",
  ["muzhiwan"] = "Y13",
  ["jinli"] = "Y14",
  ["youku"] = "Y15",
  ["coolpad"] = "Y16",
  ["sogou"] = "Y17",
  ["pptv"] = "Y18",
  ["4399"] = "Y19",
  ["37"] = "Y20",
  ["dangle"] = "Y21",
  ["178"] = "Y22",
  ["pps"] = "Y23",
  ["37wan"] = "Y24",
  ["17173"] = "Y24",
  ["htc"] = "Y25",
  ["yyb"] = "Y26",
  ["boyakenuo"] = "Y27",
  ["appchina"] = "Y28",
  ["woyouwan"] = "Y29",
  ["woyouwan_bad"] = "Y30",
  ["guopan"] = "Y31",
  ["kugou"] = "Y32",
  ["kaopu"] = "Y33",
  ["vivo"] = "Y34",
  ["unicom_"] = "Y35",
  ["baofeng2"] = "Y36",
  ["and_momo"] = "Y37",
  ["pipawang"] = "Y38",
  ["yumi"] = "Y39",
  ["kuwo"] = "Y40"
}
function MoMoDataCenterExtend.extended(object)
  local dataShutDownChannel = {
    ["200020"] = 1,
    ["2000201"] = 1
  }
  if device.platform == "android" then
    local versionCode = SyNative.getAppChannelInfo("versionCode", "0")
    if tonumber(versionCode) >= 23 then
      MoMoDataCenterExtend.m_OpenSign = false
    else
      MoMoDataCenterExtend.m_OpenSign = false
    end
    print("=======>>>>> MoMoDataCenterExtend.extended   channel.no ", tonumber(versionCode), channel.no, dataShutDownChannel[tostring(channel.no)])
    if channel and dataShutDownChannel[tostring(channel.no)] == 1 then
      MoMoDataCenterExtend.m_OpenSign = false
    end
  end
  function object:momoDCLogin(param)
    print(" =======>>>>>>  momoDCLogin  ")
    dump(param, "  param  ")
    if MoMoDataCenterExtend.m_OpenSign == false then
      print(" 陌陌数据统计被关闭 ")
      return
    end
    local userId = param.userId
    local channelLabel = param.channelLabel
    if not And_ChannelDir[channelLabel] then
      local channelId = "未知"
    end
  end
  function object:momoDCLoginByPro(counterMsg)
    print("   counterMsg  =====>>>>", counterMsg)
    if counterMsg == nil or counterMsg == "" then
      return
    end
    local strlen = string.len(counterMsg)
    local strRe = string.reverse(counterMsg)
    local index = string.find(strRe, "@") or 0
    local counter = string.sub(counterMsg, 1, strlen - index)
    local sdkType = string.sub(counterMsg, strlen - index + 2)
    print("==================>>>>>>>>　counter＝", counter, "    sdkType =", sdkType)
    local channel = "nomoga"
    if sdkType == "momo" then
      channel = "and_momo"
    elseif sdkType == "uc" then
      channel = "uc"
    elseif sdkType == "lj" then
      if object.m_channelInter and object.m_channelInter.getChannelLabel then
        channel = object.m_channelInter:getChannelLabel()
      else
        channel = "lj"
      end
    elseif sdkType == "sdk37" then
      channel = "37"
    end
    object:momoDCLogin({channelLabel = channel, userId = counter})
  end
  function object:momoDCPay(param)
    print(" =======>>>>>>  MoMoDataCenterExtend  ")
    dump(param, "  param  ")
    if MoMoDataCenterExtend.m_OpenSign == false then
      print(" 陌陌数据统计被关闭 ")
      return
    end
    local channelLabel = param.channelLabel
    local tradeNo = param.tradeNo
    local tradeFee = param.tradeFee
    local propId = param.propId
    local sdkType = param.sdkType
    if sdkType == "uc" then
      channelLabel = "uc"
    elseif sdkType == "momo" then
      channelLabel = "and_momo"
    elseif sdkType == "sdk37" then
      channelLabel = "37"
    end
    local channelId = And_ChannelDir[channelLabel] or "未知"
    if device.platform == "android" then
      local ok = callStaticMethodJava(MoMoDataCenterExtend.cls_and, "DataPaySuccess", {
        And_MoMoData_appid,
        channelId,
        tradeNo,
        tonumber(tradeFee),
        propId
      }, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;FLjava/lang/String;)V")
    elseif device.platform == "ios" then
      print("IOS 还没配置陌陌数据统计")
    end
  end
  function object:momoDCExit()
    print(" =======>>>>>>  momoDCExit  ")
    if MoMoDataCenterExtend.m_OpenSign == false then
      print(" 陌陌数据统计被关闭 ")
      return
    end
    if device.platform == "android" then
      local ok = callStaticMethodJava(MoMoDataCenterExtend.cls_and, "DataExit", {}, "()V")
    elseif device.platform == "ios" then
      print("IOS 还没配置陌陌数据统计")
    end
  end
end
