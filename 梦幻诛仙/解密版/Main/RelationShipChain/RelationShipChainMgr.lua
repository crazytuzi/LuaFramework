local Lplus = require("Lplus")
local ECMSDK = require("ProxySDK.ECMSDK")
local RelationShipChainData = require("Main.RelationShipChain.data.RelationShipChainData")
local Json = require("Utility.json")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local ErrorCodes = require("netio.protocol.mzm.gsp.grc.ErrorCodes")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local EnterWorldAlertMgr = require("Main.Common.EnterWorldAlertMgr")
local RelationShipChainMgr = Lplus.Class("RelationShipChainMgr")
local def = RelationShipChainMgr.define
def.const("string").GETSUBSCRIBEURL = "https://game.weixin.qq.com/cgi-bin/subscribe/getlistsubscribe"
def.const("string").SETSUBSCRIBEURL = "https://game.weixin.qq.com/cgi-bin/subscribe/setsubscribe"
local instance
def.const("number").SHAREACTIVIEID = 350000309
def.const("number").PAGESIZE = 8
def.field("number").m_RedGiftCountDownTimer = 0
def.field("number").m_RedGiftCountDownTimer2 = 0
def.static("=>", RelationShipChainMgr).Instance = function()
  if not instance then
    instance = RelationShipChainMgr()
  end
  return instance
end
def.static("table").GetFriendListFromServer = function(params)
  warn("RelationShipChainMgr GetFriendListFromServer ........", params.page_index)
  local p = require("netio.protocol.mzm.gsp.grc.CGetGrcFriendList").new(params.page_index)
  gmodule.network.sendProtocol(p)
end
def.static("table").SendUpDateMsgToSever = function(params)
  local p = require("netio.protocol.mzm.gsp.grc.CGrcUpdateRoleInfo").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").SendGift = function(params)
  local p = require("netio.protocol.mzm.gsp.grc.CGrcSendGift").new(params.gift_type, params.to)
  gmodule.network.sendProtocol(p)
end
def.static("table").ReceiveGift = function(params)
  local p = require("netio.protocol.mzm.gsp.grc.CGrcReceiveGift").new(params.gift_type, Int64.new(params.serialid))
  gmodule.network.sendProtocol(p)
end
def.static("table").TurnOnoff = function(params)
  warn("TurnOnoff........", params.gift_type, params.onoff)
  local p = require("netio.protocol.mzm.gsp.grc.CGrcTurnOnOff").new(params.gift_type, params.onoff)
  gmodule.network.sendProtocol(p)
end
def.static("table").GetReceiveGiftList = function(params)
  warn("GetReceiveGiftList........", params.page_index)
  local p = require("netio.protocol.mzm.gsp.grc.CGetGrcReceiveGiftList").new(params.page_index)
  gmodule.network.sendProtocol(p)
end
def.static("table").GetSelfPlatVipInfo = function(params)
  local p = require("netio.protocol.mzm.gsp.grc.CGrcGetSelfPlatVipInfo").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").ReportQQVipPayInfo = function(params)
  warn("CReportQQVipPayInfo........", params.vip_flag, params.is_new)
  local p = require("netio.protocol.mzm.gsp.grc.CReportQQVipPayInfo").new(params.vip_flag, params.is_new)
  gmodule.network.sendProtocol(p)
end
def.static("table").GetCareActivityList = function(params)
  local p = require("netio.protocol.mzm.gsp.activity.CGetCareActivityReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").TurnOnCareActivity = function(params)
  local p = require("netio.protocol.mzm.gsp.activity.CTakeCareActivityReq").new(params.activityCfgId, params.careFlag)
  gmodule.network.sendProtocol(p)
  if params.careFlag == 1 then
    ECMSDK.SetTag(tostring(params.activityCfgId))
  else
    ECMSDK.DelTag(tostring(params.activityCfgId))
  end
end
def.static("table").GetRedgiftActivityReward = function(params)
  warn("GetRedgiftActivityReward........")
  local p = require("netio.protocol.mzm.gsp.activity.CGetRedgiftActivityRewardReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").GetReward = function(params)
  warn("GetReward........", params.award_serial_no)
  local p = require("netio.protocol.mzm.gsp.grc.CGetGrcFriendsCountAward").new(params.award_serial_no)
  gmodule.network.sendProtocol(p)
end
def.static("table").GetAllGift = function(params)
  warn("GetAllGift........")
  local giftType = RelationShipChainMgr.GetGrcGiftCfg().gift_type
  local todayReciveTimes = RelationShipChainMgr.GetReciveGiftTimesData(giftType)
  local maxReciveTimes = RelationShipChainMgr.GetGrcGiftCfg().receive_max_times_everyday
  if todayReciveTimes >= maxReciveTimes then
    Toast(textRes.RelationShipChain[9])
    return
  end
  local p = require("netio.protocol.mzm.gsp.grc.CGrcReceiveAllGift").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").GetInviteFriendsInfo = function(params)
  warn("GetInviteFriendsInfo.................")
  local p = require("netio.protocol.mzm.gsp.grc.CGetInviteFriendsInfo").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").GetInviteFriendsGift = function(params)
  warn("GetInviteFriendsGift.................")
  local p = require("netio.protocol.mzm.gsp.grc.CGetInviteFriendsGift").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").GetInviteFriendsRebateBindYuanbao = function(params)
  warn("GetInviteFriendsRebateBindYuanbao.................")
  local p = require("netio.protocol.mzm.gsp.grc.CGetInviteFriendsRebateBindYuanbao").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").SendRecallFriendReq = function(params)
  warn("CSendRecallFriendReq.................", params.zone_id, params.role_id, params.open_id)
  local p = require("netio.protocol.mzm.gsp.grc.CSendRecallFriendReq").new(params.zone_id, params.role_id, params.open_id)
  gmodule.network.sendProtocol(p)
end
def.static("table").GetRecallFriendSignAwardInfo = function(params)
  warn("GetRecallFriendSignAwardInfo.................")
  local p = require("netio.protocol.mzm.gsp.grc.CGetRecallFriendSignAwardInfo").new()
  gmodule.network.sendProtocol(p)
end
def.static("table").GetRecallFriendSignAward = function(params)
  warn("GetRecallFriendSignAward.................", params.sign_day)
  local p = require("netio.protocol.mzm.gsp.grc.CGetRecallFriendSignAward").new(params.sign_day)
  gmodule.network.sendProtocol(p)
end
def.static("table").GetRecallFriendsCountAward = function(params)
  warn("CGetRecallFriendsCountAward.................")
  local p = require("netio.protocol.mzm.gsp.grc.CGetRecallFriendsCountAward").new(params.award_serial_no)
  gmodule.network.sendProtocol(p)
end
def.static("table").GetRecallFriendsBigGiftAward = function(params)
  warn("CGetRecallFriendsBigGiftAward.................")
  local p = require("netio.protocol.mzm.gsp.grc.CGetRecallFriendsBigGiftAward").new()
  gmodule.network.sendProtocol(p)
end
def.static().GetBoxInfo = function()
  local act_cfgid = 132
  if LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    act_cfgid = 132
  end
  warn("GetBoxInfo.................", actid)
  local p = require("netio.protocol.mzm.gsp.grc.GetBoxInfo").new(act_cfgid)
  gmodule.network.sendProtocol(p)
end
def.static("string", "string", "number", "function").HttpPostBody = function(url, body, postID, cb)
  url = _G.NormalizeHttpURL(url)
  GameUtil.httpPost(url, postID, body, function(success, url, postId, data)
    if success and cb then
      cb(data:get_string())
    else
    end
  end, {})
end
def.static("number", "number").SetDataToURL = function(id, opType)
  local sdkInfo = ECMSDK.GetMSDKInfo()
  if not sdkInfo then
    return
  end
  local url = RelationShipChainMgr.SETSUBSCRIBEURL .. ("?access_token=%s"):format(sdkInfo.accessToken)
  local body = {}
  body.msg_id = id
  body.op_type = opType
  RelationShipChainMgr.HttpPostBody(url, Json.encode(body), id, function(data)
    RelationShipChainData.Instance():UpdateSubscribeData(data, id)
  end)
end
def.static().GetDataFromURL = function()
  local sdkInfo = ECMSDK.GetMSDKInfo()
  if not sdkInfo or not sdkInfo.accessToken then
    return
  end
  local url = RelationShipChainMgr.GETSUBSCRIBEURL .. ("?access_token=%s"):format(sdkInfo.accessToken)
  local body = {}
  body.page = 0
  body.page_size = 10
  RelationShipChainMgr.HttpPostBody(url, Json.encode(body), 1, function(data)
    RelationShipChainData.Instance():SetSubscribeData(data)
  end)
end
def.static("table", "table").OnLoginAccountSuccess = function(p1, p2)
  RelationShipChainMgr.GetDataFromURL()
end
def.static("table", "table").OnRankFriendPanelClick = function(p1, p2)
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local friendNum = RelationShipChainMgr.GetFriendNum()
    local giftNum = RelationShipChainMgr.GetGiftNum()
    warn("OnRankFriendPanelClick :", friendNum, " ", giftNum)
    if friendNum == 0 then
      RelationShipChainMgr.GetFriendListFromServer({page_index = 1})
    else
      local frinedPageNum = math.ceil(friendNum / RelationShipChainMgr.PAGESIZE)
      for i = 1, frinedPageNum do
        RelationShipChainMgr.GetFriendListFromServer({page_index = i})
      end
    end
    if giftNum == 0 then
      RelationShipChainMgr.GetReceiveGiftList({page_index = 1})
    else
      local giftPageNum = math.ceil(giftNum / RelationShipChainMgr.PAGESIZE)
      for i = 1, giftPageNum do
        RelationShipChainMgr.GetReceiveGiftList({page_index = i})
      end
    end
    local relationShipChainPanel = require("Main.RelationShipChain.ui.RelationShipChainPanel")
    relationShipChainPanel.Instance():ShowPanel()
  elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
    local efunRelationShipChainPanel = require("Main.RelationShipChain.ui.EfunRelationShipChainPanel")
    efunRelationShipChainPanel.Instance():ShowPanel()
  end
end
def.static("table", "table").OnShareActivie = function(p1, p2)
  warn("RelationShipChainMgr OnShareActivie", p1[1])
  if p1[1] == RelationShipChainMgr.SHAREACTIVIEID then
    local sdktype = ClientCfg.GetSDKType()
    if sdktype == ClientCfg.SDKTYPE.MSDK then
      if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX and not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.WX) then
        Toast(textRes.Common[311])
        return
      elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.QQ) then
        Toast(textRes.Common[310])
        return
      elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
        Toast(textRes.Common[313])
        return
      end
      local ShareTipsPanel = require("Main.RelationShipChain.ui.ShareTipsPanel")
      ShareTipsPanel.Instance():ShowPanel(true)
    elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
      local ECUniSDK = require("ProxySDK.ECUniSDK")
      if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
        local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
        ECUniSDK.Instance():SetShareType(UseType.SHARE_AWARD)
        ECUniSDK.Instance():Share({
          name = textRes.RelationShipChain[64],
          caption = textRes.RelationShipChain[65],
          shareDesc = textRes.RelationShipChain[66],
          type = ECUniSDK.SHARETYPE.FB
        })
      elseif ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
        ECUniSDK.Instance():Share({
          title = textRes.RelationShipChain[101],
          desc = textRes.RelationShipChain[104],
          callback = function(success)
            if success then
              local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
              local GiftAwardMgr = require("Main.Award.mgr.GiftAwardMgr")
              GiftAwardMgr.Instance():DrawAward(UseType.SHARE_AWARD)
              GameUtil.AddGlobalTimer(1, true, function()
                Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, {
                  RelationShipChainMgr.SHAREACTIVIEID
                })
              end)
            end
          end
        })
      end
    end
  end
end
def.static("table", "table").OnNewDay = function(p1, p2)
  local giftNum = RelationShipChainMgr.GetGiftNum()
  warn("RelationShipChainMgr OnNewDay!!!!!!!!!!!!!!", giftNum)
  if giftNum == 0 then
    RelationShipChainMgr.GetReceiveGiftList({page_index = 1})
  else
    local giftPageNum = math.ceil(giftNum / RelationShipChainMgr.PAGESIZE)
    for i = 1, giftPageNum do
      RelationShipChainMgr.GetReceiveGiftList({page_index = i})
    end
  end
  GameUtil.AddGlobalTimer(3, true, function()
    require("Main.MainUI.ui.MainUITopButtonGroup").Instance():InitUI()
  end)
  RelationShipChainData.Instance():ResetTodayRecallFriendNum()
  RelationShipChainData.Instance():ClearSendGiftData()
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, nil)
end
local flag = false
def.static("table").OnSyncGrcGetFriendList = function(p)
  warn("OnSyncGrcGetFriendList...", p.total_friend_count, p.page_index)
  RelationShipChainData.Instance():SetFriendData(p.total_friend_count, p.page_index, p.friends)
  if not flag then
    local frinedPageNum = math.ceil(p.total_friend_count / RelationShipChainMgr.PAGESIZE)
    for i = 1, frinedPageNum do
      RelationShipChainMgr.GetFriendListFromServer({page_index = i})
    end
    flag = true
  end
end
def.static("table").OnGrcSendGiftResp = function(p)
  warn("OnGrcSendGiftResp...", p.retcode, p.gift_type, p.to, ErrorCodes.ERROR_MAX_SEND_TIMES_EVERYDAY)
  if p.retcode == 0 then
    RelationShipChainData.Instance():UpdateSendGiftData(p.gift_type, p.to)
    local ShareComfirmPanel = require("Main.RelationShipChain.ui.ShareComfirmPanel")
    ShareComfirmPanel.Instance():ShowPanel({
      type = 1,
      id = p.to
    })
  elseif p.retcode == ErrorCodes.ERROR_RECEIVER_TURN_OFF_RECEIVE then
    Toast(textRes.RelationShipChain[7])
  elseif p.retcode == ErrorCodes.ERROR_MAX_SEND_TIMES_EVERYDAY then
    Toast(textRes.RelationShipChain[6])
  elseif p.retcode == ErrorCodes.ERROR_ALREADY_SENDED_TO_RECEIVER then
    Toast(textRes.RelationShipChain[25])
  else
    warn("Fail to send gift: ", p.retcode)
  end
end
def.static("table").OnGrcReceiveGiftResp = function(p)
  if p.retcode == 0 then
    local name = textRes.RelationShipChain[28 + p.gift_type] or textRes.RelationShipChain[29]
    local num = RelationShipChainMgr.GetGrcGiftCfg().gift_count
    Toast(textRes.RelationShipChain[36]:format(num, name))
    RelationShipChainData.Instance():UpdateReciveGiftTimesData(p.gift_type, p.serialid:ToNumber())
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ReciveGift, nil)
  elseif p.retcode == ErrorCodes.ERROR_MAX_RECEIVE_TIMES_EVERYDAY then
    Toast(textRes.RelationShipChain[9])
  else
    warn("Fail to recive gift: ", p.retcode)
  end
end
def.static("table").OnGrcReceiveAllGiftResp = function(p)
  warn("OnGrcReceiveAllGiftResp", p.retcode, p.receive_gifts)
  if p.retcode == 0 then
    for k, v in pairs(p.receive_gifts) do
      for _, serialid in pairs(v.serialids) do
        RelationShipChainData.Instance():UpdateReciveGiftTimesData(v.gift_type, serialid:ToNumber())
      end
    end
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ReciveGift, nil)
  elseif p.retcode == 102 then
    Toast(textRes.RelationShipChain[39])
  end
end
def.static("table").OnSyncGrcGiftTypeOnOff = function(p)
  warn("OnSyncGrcGiftTypeOnOff...", #p.gift_type_onoff_map)
  for k, v in pairs(p.gift_type_onoff_map) do
    RelationShipChainData.Instance():TurnOnOff(k, v)
  end
end
def.static("table").OnGrcTurnOnOffResp = function(p)
  warn("OnGrcTurnOnOffResp...", p.retcode, p.gift_type, p.onoff)
  if p.retcode == 0 then
    RelationShipChainData.Instance():TurnOnOff(p.gift_type, p.onoff)
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.TurnOnOff, nil)
  else
    warn("Fail to TurnOn: ", p.retcode)
  end
end
def.static("table").OnGrcGetSelfPlatVipInfoResp = function(p)
end
def.static("table").OnSyncGrcExceedFriendList = function(p)
end
def.static("table").OnSyncCareActivity = function(p)
  RelationShipChainData.Instance():SetCareActivityData(p.careMap)
  local temp = RelationShipChainMgr.GetNoticeActivityData()
  if #temp ~= 0 then
    local pushNoticePanel = require("Main.RelationShipChain.ui.PushNoticePanel")
    pushNoticePanel.Instance():ShowPanel(1)
  else
    Toast(textRes.RelationShipChain[23])
  end
end
def.static("table").OnTakeCareActivityRes = function(p)
  warn("OnTakeCareActivityRes...", p.result, p.activityCfgId)
  if p.result == 0 then
    RelationShipChainData.Instance():UpdateNoticeActivityData(p.activityCfgId)
  end
end
def.static("table").OnSyncGrcSendGiftList = function(p)
  warn("OnSyncGrcSendGiftList...", p.user_send_gift_infos)
  RelationShipChainData.Instance():SetSendGiftData(p.user_send_gift_infos)
end
def.static("table").OnSyncGrcReceiveGiftList = function(p)
  warn("OnSyncGrcReceiveGiftList", p.total_count, p.page_index, p.user_receive_gift_times_infos, p.receive_gift_infos)
  RelationShipChainData.Instance():SetReciveGiftTimesData(p.user_receive_gift_times_infos)
  RelationShipChainData.Instance():SetReciveGiftData(p.total_count, p.page_index, p.receive_gift_infos)
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ReciveGift, {
    p.page_index
  })
end
local reciveRedGIft = false
def.static("table").OnSyncRedgiftActivityStartRes = function(p)
  warn("OnSyncRedgiftActivityStartRes", reciveRedGIft)
  if not reciveRedGIft then
    reciveRedGIft = true
  end
end
def.static("table").OnGetRedgiftActivityRewardRes = function(p)
  warn("OnGetRedgiftActivityRewardRes", p.result, p.cfgId, p.rewardInfo.awardMoney)
  local moneyInfo = p.rewardInfo.awardMoney
  local money = 0
  for k, v in pairs(moneyInfo) do
    if v ~= 0 then
      money = v
    end
  end
  if p.result == 0 then
    local ShareComfirmPanel = require("Main.RelationShipChain.ui.ShareComfirmPanel")
    if p.cfgId == RelationShipChainMgr.GetRedGiftActivityConstant("commonRewardId") then
      Toast(textRes.activity[354]:format(money))
      PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.RelationShipChain[37], PersonalHelper.Type.Gold, money, PersonalHelper.Type.Text, textRes.RelationShipChain[31])
    elseif p.cfgId == RelationShipChainMgr.GetRedGiftActivityConstant("topRewardId") then
      ShareComfirmPanel.Instance():ShowPanel({type = 2, param = money})
      Toast(textRes.activity[355]:format(money))
      PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.RelationShipChain[38], PersonalHelper.Type.Gold, money, PersonalHelper.Type.Text, textRes.RelationShipChain[31])
    else
      ShareComfirmPanel.Instance():ShowPanel({type = 3})
      Toast(textRes.activity[356])
    end
  end
end
def.static("table").OnSyncGrcFriendsCountAwardInfo = function(p)
  warn("OnSyncGrcFriendsCountAwardInfo", p.award_serial_no, p.friends_count)
  RelationShipChainData.Instance():SetFriendsCountAwardInfo(p.award_serial_no, p.friends_count)
end
def.static("table").OnGetGrcFriendsCountAwardFailed = function(p)
  warn("OnGetGrcFriendsCountAwardFailed", p.retcode, p.award_serial_no)
  local SGetGrcFriendsCountAwardFailed = require("netio.protocol.mzm.gsp.grc.SGetGrcFriendsCountAwardFailed")
  if p.retcode == SGetGrcFriendsCountAwardFailed.ERR_SERIAL_NO_INVALID then
    Toast(textRes.RelationShipChain[26])
  elseif p.retcode == SGetGrcFriendsCountAwardFailed.ERR_FRIENDS_COUNT_NOT_MEET then
    Toast(textRes.RelationShipChain[27])
  end
end
def.static("table").OnGetGrcFriendsCountAwardSuccess = function(p)
  warn("OnGetGrcFriendsCountAwardSuccess", p.award_serial_no)
  RelationShipChainData.Instance():UpdateFriendNumAwardSerialID(p.award_serial_no)
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyAutoReward, nil)
end
def.static("table").OnNotifyPrivilegeAwardTip = function(p)
  warn("OnNotifyPrivilegeAwardTip           ", p.award_type, p.privilege_type)
  local cfg = RelationShipChainData.GetPrivilegeAwardCfg(p.privilege_type)
  local moneyType = PersonalHelper.Type.Gold
  if cfg.sign_extra_award_type == 4 then
    moneyType = PersonalHelper.Type.Silver
  end
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Common[150], moneyType, cfg.sign_extra_award_num)
end
def.static("table").OnGetInviteFriendsInfoResp = function(p)
  warn("OnGetInviteFriendsInfoResp", p.invite_code, p.invitee_num, p.award_gift_times, p.rebate_bind_yuanbao)
  RelationShipChainData.Instance():SetInviteFriendInfo(p)
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyInviteFriendsGift, nil)
end
def.static("table").OnGetInviteFriendsGiftResp = function(p)
  warn("OnGetInviteFriendsGiftResp", p.retcode, p.award_gift_times)
  if p.retcode == 0 then
    RelationShipChainData.Instance():UpdateAwardGiftTiems(p.award_gift_times)
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyInviteFriendsGift, nil)
  elseif p.retcode == 440 then
    Toast(textRes.Common[407])
  elseif p.retcode == 441 then
    Toast(textRes.Common[412])
  end
end
def.static("table").OnGetInviteFriendsRebateBindYuanbaoResp = function(p)
  warn("OnGetInviteFriendsRebateBindYuanbaoResp", p.retcode, p.rebate_bind_yuanbao)
  if p.retcode == 0 then
    RelationShipChainData.Instance():UpdateRebateBindYuanbao(p.rebate_bind_yuanbao)
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyInviteFriendsGift, nil)
  elseif p.retcode == 432 then
    Toast(textRes.Common[405])
  elseif p.retcode == 433 then
    Toast(textRes.Common[406])
  else
    warn("OnGetInviteFriendsRebateBindYuanbaoResp" .. p.retcode)
  end
end
def.static("table").OnReportQQVipPayInfo = function(p)
  warn("OnReportQQVipPayInfo", p.retcode, p.vip_flag, p.is_new)
  if p.retcode == 0 then
    RelationShipChainMgr.SetSpeicalVIPLevel(p.vip_flag)
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.QQVIPCharge, nil)
  end
end
def.static("table").OnSyncRedgiftActivityLeftTime = function(p)
  warn("OnSyncRedgiftActivityLeftTime-------------------------------------------", p.leftTime)
  local AnnouncementTip = require("GUI.AnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local function SendMsg(time)
    local content = string.format(textRes.AnnounceMent[67], time)
    AnnouncementTip.Announce(content)
    ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
  end
  local min = math.floor(p.leftTime / 60)
  local sec = p.leftTime - min * 60
  instance:ClearRedGiftCountDownTimer()
  if min < 0 or min > 5 then
    return
  end
  instance.m_RedGiftCountDownTimer2 = GameUtil.AddGlobalTimer(sec, true, function()
    if min == 5 or min == 1 then
      SendMsg(min)
    end
    if min > 0 then
      instance.m_RedGiftCountDownTimer = GameUtil.AddGlobalTimer(60, false, function()
        min = min - 1
        if min == 1 then
          SendMsg(min)
        end
        if min <= 0 then
          local RedGiftPanel = require("Main.activity.ui.RedGiftPanel")
          RedGiftPanel.Instance():ShowDlg()
          instance:ClearRedGiftCountDownTimer()
        end
      end)
    else
      local RedGiftPanel = require("Main.activity.ui.RedGiftPanel")
      RedGiftPanel.Instance():ShowDlg()
      instance:ClearRedGiftCountDownTimer()
    end
  end)
end
def.static("table").OnPassAllLayerRes = function(p)
  warn("RelationShipChainMgr OnPassAllLayerRes", p.isFanPai, p.seconds)
  if GameUtil.IsEvaluation() then
    return
  end
  local function FinishActivity()
    local SharePhotoPanel = require("Main.RelationShipChain.ui.SharePhotoPanel")
    local srcPanel = SharePhotoPanel.Instance()
    srcPanel:ShowPanel({
      id = 350000016,
      params = {
        seconds = p.seconds
      }
    })
    return srcPanel
  end
  if p.isFanPai == 0 then
    RelationShipChainMgr.PrepareShare(true, FinishActivity, nil)
  else
    do
      local preparing = true
      Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.MULTI_ROLE_FLIP_CARD_END, function()
        if preparing then
          RelationShipChainMgr.PrepareShare(true, FinishActivity, nil)
          preparing = false
        end
      end)
    end
  end
end
def.static("table").OnSendRecallFriendSuccess = function(p)
  warn("RelationShipChainMgr OnSendRecallFriendSuccess", p.zone_id, p.role_id, p.open_id)
  Toast(textRes.RelationShipChain[61])
  local index = math.random(3) + 56
  ECMSDK.SendToGameFriend(0, _G.GetStringFromOcts(p.open_id), textRes.RelationShipChain[56], textRes.RelationShipChain[index], textRes.RelationShipChain[60], 5, ECMSDK.ShareURL[5])
  RelationShipChainData.Instance():IncCanRecallFriendNum()
  RelationShipChainData.Instance():IncTodayRecallFriendNum()
  RelationShipChainData.Instance():UpdateRecallFriendData(p.open_id)
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendAward, nil)
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriend, nil)
end
def.static("table").OnGetRecallFriendSignAwardInfoSuccess = function(p)
  warn("RelationShipChainMgr OnGetRecallFriendSignAwardInfoSuccess", p.sign_award_state_map)
  RelationShipChainData.Instance():SetRecallFriendSignAwardData(p.sign_award_state_map)
end
def.static("table").OnGetRecallFriendSignAwardSuccess = function(p)
  warn("RelationShipChainMgr OnGetRecallFriendSignAwardSuccess", p.sign_day)
  RelationShipChainData.Instance():UpdateRecallFriendSignAwardData(p.sign_day)
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendSignAward, nil)
end
def.static("table").OnSyncRecallFriendsCountAwardInfo = function(p)
  warn("RelationShipChainMgr OnSyncRecallFriendsCountAwardInfo", p.award_serial_no, p.recall_friends_count, p.today_recall_friends_count)
  RelationShipChainData.Instance():SetRecallFriendsCountAwardInfo(p.award_serial_no, p.recall_friends_count, p.today_recall_friends_count)
end
def.static("table").OnGetRecallFriendsCountAwardSuccess = function(p)
  warn("RelationShipChainMgr OnGetRecallFriendsCountAwardSuccess", p.award_serial_no)
  RelationShipChainData.Instance():UpdateRecallFriendNumSerialID(p.award_serial_no)
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendAward, nil)
end
def.static("table").OnRecallFriendNormalFail = function(p)
  warn("RelationShipChainMgr OnRecallFriendNormalFail", p.result)
  Toast(textRes.RelationShipChain.Error[p.result])
end
def.static("table").OnGetRecallFriendsBigGiftAwardSuccess = function(p)
  warn("RelationShipChainMgr OnGetRecallFriendsBigGiftAwardSuccess")
  RelationShipChainData.Instance():SetBigGiftAwardState(1)
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendBigGiftAward, nil)
end
def.static("table").OnSyncRecallFriendsBigGiftAwardInfo = function(p)
  warn("RelationShipChainMgr OnSyncRecallFriendsBigGiftAwardInfo", p.big_gift_awarded_state)
  RelationShipChainData.Instance():SetBigGiftAwardState(p.big_gift_awarded_state)
  RelationShipChainData.Instance():SetRecallFriendFlag(true)
  if p.big_gift_awarded_state == 0 and FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_RECALL_FRIEND) then
    local recallFriendsPanel = require("Main.RelationShipChain.ui.RecallFriendsPanel")
    recallFriendsPanel.Instance():ShowPanel(2)
  end
end
def.static("table").OnGetBoxInfoRsp = function(p)
  warn("OnGetInnerBoxShareInfo", p.retcode, p.act_cfgid, p.box_info)
  if p.retcode == 0 then
    local boxInfo = GetStringFromOcts(p.box_info)
    if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      boxInfo = ShareURL[6]:format("132", boxInfo)
    end
    ECMSDK.SendToFriend(MSDK_SHARE_SCENE.SINGEL, boxInfo, textRes.RelationShipChain[62], textRes.RelationShipChain[63], ECMSDK.GAMETAG.WX[11])
  end
end
def.method().ClearRedGiftCountDownTimer = function(self)
  warn("ClearRedGiftCountDownTimer", self.m_RedGiftCountDownTimer, self.m_RedGiftCountDownTimer2)
  if self.m_RedGiftCountDownTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_RedGiftCountDownTimer)
    self.m_RedGiftCountDownTimer = 0
  end
  if self.m_RedGiftCountDownTimer2 ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_RedGiftCountDownTimer2)
    self.m_RedGiftCountDownTimer2 = 0
  end
end
def.static("=>", "table").GetFriendData = function()
  return RelationShipChainData.Instance():GetFriendData()
end
def.static("userdata", "=>", "table").SearchFriendData = function(roleId)
  return RelationShipChainData.Instance():SearchFriendData(roleId)
end
def.static("=>", "table").GetReciveGiftData = function()
  return RelationShipChainData.Instance():GetReciveGiftData()
end
def.static("number", "=>", "table").GetSendGiftData = function(type)
  return RelationShipChainData.Instance():GetSendGiftData(type)
end
def.static("number", "=>", "number").GetReciveGiftTimesData = function(type)
  return RelationShipChainData.Instance():GetReciveGiftTimesData(type)
end
def.static("number", "=>", "boolean").GetGiftSwith = function(type)
  return RelationShipChainData.Instance():GetGiftSwith(type)
end
def.static("=>", "number").GetFriendNum = function()
  return RelationShipChainData.Instance():GetFriendNum()
end
def.static("=>", "number").GetRecallFriendNum = function()
  return RelationShipChainData.Instance():GetRecallFriendNum()
end
def.static("=>", "number").GetGiftNum = function()
  return RelationShipChainData.Instance():GetGiftNum()
end
def.static("=>", "table").GetAllSubscribeRemind = function()
  return RelationShipChainData.GetAllSubscribeRemind()
end
def.static("=>", "table").GetSubscribeData = function()
  return RelationShipChainData.Instance():GetSubscribeData()
end
def.static("=>", "table").GetNoticeActivityData = function()
  return RelationShipChainData.Instance():GetNoticeActivityData()
end
def.static("=>", "number").GetFriendNumAwardSerialID = function()
  return RelationShipChainData.Instance():GetFriendNumAwardSerialID()
end
def.static("=>", "number").GetRecallFriendsAwardSerialID = function()
  return RelationShipChainData.Instance():GetRecallFriendsAwardSerialID()
end
def.static("=>", "number").GetBigGiftAwardState = function()
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_RECALL_FRIEND) then
    return -1
  end
  return RelationShipChainData.Instance():GetBigGiftAwardState()
end
def.static("=>", "boolean").IsRecallPlayer = function()
  return RelationShipChainData.Instance():IsRecallPlayer()
end
def.static("=>", "table").GetInviteFriendData = function()
  return RelationShipChainData.Instance():GetInviteFriendData()
end
def.static("number", "string", "=>", "boolean").IsSend = function(type, openid)
  return RelationShipChainData.Instance():IsSend(type, openid)
end
def.static("number", "number").SendToFriend = function(zone, cfgID)
  local cfg = RelationShipChainData.GetShareTitleAndContent(cfgID)
  if not cfg then
    return
  end
  ECMSDK.SendToFriend(zone, cfg.title, cfg.content)
end
def.static("string", "=>", "number").GetGrcConstant = function(key)
  return RelationShipChainData.GetGrcConstant(key)
end
def.static("string", "=>", "number").GetInviteFriendConstant = function(key)
  return RelationShipChainData.GetInviteFriendConstant(key)
end
def.static("string", "=>", "number").GetRecallFriendConstant = function(key)
  return RelationShipChainData.GetRecallFriendConstant(key)
end
def.static("=>", "table").GetGrcGiftCfg = function()
  local id = RelationShipChainData.GetGrcConstant("OPEN_GIFT_CFG_ID")
  return RelationShipChainData.GetGrcGiftCfg(id)
end
def.static("=>", "table").GetRecallFriendSignAwardCfg = function()
  return RelationShipChainData.GetRecallFriendSignAwardCfg()
end
def.static("=>", "table").GetRecallFriendSignAwardData = function()
  return RelationShipChainData.Instance():GetRecallFriendSignAwardData()
end
def.static("=>", "table", "table").GetPrivilegeAwardCfg = function()
  local loginType = RelationShipChainMgr.GetLoginType()
  local loginTypeInfo
  if loginType ~= 0 then
    loginTypeInfo = RelationShipChainData.GetPrivilegeAwardCfg(loginType)
  end
  local qqVipInfo
  local vipLevel = RelationShipChainMgr.GetSepicalVIPLevel()
  if vipLevel == 1 then
    qqVipInfo = RelationShipChainData.GetPrivilegeAwardCfg(4)
  elseif vipLevel == 2 then
    qqVipInfo = RelationShipChainData.GetPrivilegeAwardCfg(5)
  end
  return loginTypeInfo, qqVipInfo
end
def.static("=>", "table").GetAllGrcFriendsCountAwardCfg = function()
  return RelationShipChainData.GetAllGrcFriendsCountAwardCfg()
end
def.static("=>", "table").GetRecallFriendNumAwardCfg = function()
  return RelationShipChainData.GetRecallFriendNumAwardCfg()
end
def.static("string", "=>", "number").GetRedGiftActivityConstant = function(key)
  return RelationShipChainData.GetRedGiftActivityConstant(key)
end
def.static("number").SetSpeicalVIPLevel = function(vipLevel)
  local friendData = RelationShipChainData.Instance():GetFriendData()
  local sdkInfo = ECMSDK.GetMSDKInfo()
  if not sdkInfo then
  end
  local openid = sdkInfo.openId
  local myInfo = friendData[openid]
  if myInfo then
  end
end
def.static("=>", "number").GetSepicalVIPLevel = function()
  local friendData = RelationShipChainData.Instance():GetFriendData()
  local sdkInfo = ECMSDK.GetMSDKInfo()
  if not sdkInfo then
    return 0
  end
  local openid = sdkInfo.openId
  local myInfo = friendData[openid]
  if myInfo then
    local QQVipFlag = require("netio.protocol.mzm.gsp.grc.QQVipFlag")
    local superVIP = myInfo.qq_vip_infos[QQVipFlag.VIP_SUPER]
    if superVIP and superVIP.is_vip == 1 then
      return 2
    end
    local normalVIP = myInfo.qq_vip_infos[QQVipFlag.VIP_NORMAL]
    if normalVIP and normalVIP.is_vip == 1 then
      return 1
    end
    return 0
  else
    return 0
  end
end
def.static("=>", "number").GetLoginType = function()
  if ECMSDK.IsQQGameCenter() then
    return 1
  elseif ECMSDK.IsWXGameCenter() then
    return 2
  elseif ECMSDK.IsFromYYB() then
    return 3
  else
    return 0
  end
end
def.static("=>", "boolean").CanReciveGift = function()
  local giftNum = RelationShipChainMgr.GetGiftNum()
  local giftType = RelationShipChainMgr.GetGrcGiftCfg().gift_type
  local todayReciveTimes = RelationShipChainMgr.GetReciveGiftTimesData(giftType)
  local maxReciveTimes = RelationShipChainMgr.GetGrcGiftCfg().receive_max_times_everyday
  return giftNum > 0 and todayReciveTimes < maxReciveTimes
end
def.static("=>", "boolean").CanReciveFriendNumGift = function()
  local friendNum = RelationShipChainMgr.GetFriendNum() - 1
  local rewardCfg = RelationShipChainMgr.GetAllGrcFriendsCountAwardCfg()
  local rewardID = RelationShipChainMgr.GetFriendNumAwardSerialID()
  local serialID = 0
  for k, v in pairs(rewardCfg) do
    if friendNum < v.need_count then
      serialID = v.serial_no - 1
      break
    else
      serialID = v.serial_no
    end
  end
  return rewardID < serialID
end
def.static("=>", "boolean").ToadyCanRecallFriend = function()
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_RECALL_FRIEND) then
    return false
  end
  local canRecallFriendPerDay = RelationShipChainMgr.GetRecallFriendConstant("MAX_RECALL_TIMES_EVERY_DAY")
  local todayRecallFriendNum = RelationShipChainData.Instance():GetTodayRecallFriendNum()
  local canRecallFriendNum = RelationShipChainData.Instance():GetCanRecallFriendNum()
  warn("RelationShipChainMgr ToadyCanRecallFriend ", todayRecallFriendNum, canRecallFriendPerDay, canRecallFriendNum)
  return todayRecallFriendNum < canRecallFriendNum and canRecallFriendPerDay > todayRecallFriendNum
end
def.static("=>", "boolean").CanReciveRecallFriendNumGift = function()
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_RECALL_FRIEND) then
    return false
  end
  local friendNum = RelationShipChainMgr.GetRecallFriendNum()
  local rewardCfg = RelationShipChainMgr.GetRecallFriendNumAwardCfg()
  local rewardID = RelationShipChainMgr.GetRecallFriendsAwardSerialID()
  local serialID = 0
  for k, v in pairs(rewardCfg) do
    if friendNum < v.need_count then
      serialID = v.serial_no - 1
      break
    else
      serialID = v.serial_no
    end
  end
  return rewardID < serialID
end
def.static("=>", "boolean").CanGetRecallFriendSignAward = function()
  if not FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_RECALL_FRIEND) then
    return false
  end
  local data = RelationShipChainData.Instance():GetRecallFriendSignAwardData()
  for k, v in pairs(data) do
    if v == 0 then
      return true
    end
  end
  return false
end
def.static("userdata", "=>", "string").ProcessHeadImgURL = function(url)
  local urlStr = GetStringFromOcts(url) or ""
  if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    urlStr = urlStr .. "/46"
  elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    urlStr = urlStr .. "40"
  end
  if ECMSDK.IsHttpsSupported() and platform == 1 then
    urlStr = string.gsub(urlStr, "^(http):", "%1s:")
  end
  return urlStr or ""
end
local randomNum = function(len)
  local ret = ""
  for i = 1, len do
    ret = ret .. math.random(0, 9)
  end
  return ret
end
def.static("boolean", "function", "function").PrepareShare = function(isDestroy, openPanelFunc, ClickShareFunc)
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
    local ECUniSDK = require("ProxySDK.ECUniSDK")
    if not ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
      return
    end
  end
  if not openPanelFunc then
    warn("There is no dependent panel in PrepareShare")
    return
  end
  local srcPanel = openPanelFunc()
  local shareName = srcPanel.m_panelName
  local filePath = GenShareImagePath(shareName .. randomNum(#shareName) .. ".png")
  if not srcPanel then
    warn("Fail to create  srcPanel")
    return
  end
  local ShareBtnPanel = require("Main.RelationShipChain.ui.ShareBtnPanel")
  ShareBtnPanel.Instance():IsDestroy(isDestroy)
  ShareBtnPanel.Instance():SetImgPath(filePath)
  ShareBtnPanel.Instance():SetClickShareFunc(ClickShareFunc)
  ShareBtnPanel.Instance():ShowPanel(srcPanel)
end
local recallKeyPrefix = "RecallTips_"
def.static("=>", "string").GetRecallFriendsStorageKey = function()
  local serverTime = _G.GetServerTime()
  local key = recallKeyPrefix .. tonumber(os.date("%Y%m%d", serverTime))
  return key
end
def.method("=>", "boolean").IsTodayShowRecallFriendsTips = function(self)
  local storageKey = RelationShipChainMgr.GetRecallFriendsStorageKey()
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  if LuaPlayerPrefs.HasRoleKey(storageKey) then
    return true
  end
  return false
end
def.method().MarkTodayShowRecallFriendsTips = function(self)
  local storageKey = RelationShipChainMgr.GetRecallFriendsStorageKey()
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  LuaPlayerPrefs.SetRoleString(storageKey, "1")
end
def.method().CheckToShowRecallFriendsTips = function(self)
  if not _G.IsFeatureOpen(Feature.TYPE_RECALL_FRIEND_OPTIMIZE) or require("Main.Recall.RecallModule").Instance():IsOpen(false) then
    EnterWorldAlertMgr.Instance():Next()
    return
  end
  if RelationShipChainMgr.ToadyCanRecallFriend() and not RelationShipChainMgr.Instance():IsTodayShowRecallFriendsTips() then
    require("Main.RelationShipChain.ui.RecallFriendsTipsPanel").Instance():ShowPanel()
    RelationShipChainMgr.Instance():MarkTodayShowRecallFriendsTips()
  else
    EnterWorldAlertMgr.Instance():Next()
  end
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SSyncGrcGetFriendList", RelationShipChainMgr.OnSyncGrcGetFriendList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGrcSendGiftResp", RelationShipChainMgr.OnGrcSendGiftResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGrcReceiveGiftResp", RelationShipChainMgr.OnGrcReceiveGiftResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SSyncGrcReceiveGiftList", RelationShipChainMgr.OnSyncGrcReceiveGiftList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SSyncGrcGiftTypeOnOff", RelationShipChainMgr.OnSyncGrcGiftTypeOnOff)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGrcTurnOnOffResp", RelationShipChainMgr.OnGrcTurnOnOffResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SSyncGrcSendGiftList", RelationShipChainMgr.OnSyncGrcSendGiftList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGrcGetSelfPlatVipInfoResp", RelationShipChainMgr.OnGrcGetSelfPlatVipInfoResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SSyncGrcExceedFriendList", RelationShipChainMgr.OnSyncGrcExceedFriendList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SSyncGrcFriendsCountAwardInfo", RelationShipChainMgr.OnSyncGrcFriendsCountAwardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetGrcFriendsCountAwardFailed", RelationShipChainMgr.OnGetGrcFriendsCountAwardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetGrcFriendsCountAwardSuccess", RelationShipChainMgr.OnGetGrcFriendsCountAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SReportQQVipPayInfoResp", RelationShipChainMgr.OnReportQQVipPayInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncCareActivity", RelationShipChainMgr.OnSyncCareActivity)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.STakeCareActivityRes", RelationShipChainMgr.OnTakeCareActivityRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncRedgiftActivityStartRes", RelationShipChainMgr.OnSyncRedgiftActivityStartRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SGetRedgiftActivityRewardRes", RelationShipChainMgr.OnGetRedgiftActivityRewardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGrcReceiveAllGiftResp", RelationShipChainMgr.OnGrcReceiveAllGiftResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncRedgiftActivityLeftTime", RelationShipChainMgr.OnSyncRedgiftActivityLeftTime)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SPassAllLayerRes", RelationShipChainMgr.OnPassAllLayerRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SNotifyPrivilegeAwardTip", RelationShipChainMgr.OnNotifyPrivilegeAwardTip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetInviteFriendsInfoResp", RelationShipChainMgr.OnGetInviteFriendsInfoResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetInviteFriendsGiftResp", RelationShipChainMgr.OnGetInviteFriendsGiftResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetInviteFriendsRebateBindYuanbaoResp", RelationShipChainMgr.OnGetInviteFriendsRebateBindYuanbaoResp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SSendRecallFriendSuccess", RelationShipChainMgr.OnSendRecallFriendSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetRecallFriendSignAwardInfoSuccess", RelationShipChainMgr.OnGetRecallFriendSignAwardInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetRecallFriendSignAwardSuccess", RelationShipChainMgr.OnGetRecallFriendSignAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SSyncRecallFriendsCountAwardInfo", RelationShipChainMgr.OnSyncRecallFriendsCountAwardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetRecallFriendsCountAwardSuccess", RelationShipChainMgr.OnGetRecallFriendsCountAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SRecallFriendNormalFail", RelationShipChainMgr.OnRecallFriendNormalFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SGetRecallFriendsBigGiftAwardSuccess", RelationShipChainMgr.OnGetRecallFriendsBigGiftAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grc.SSyncRecallFriendsBigGiftAwardInfo", RelationShipChainMgr.OnSyncRecallFriendsBigGiftAwardInfo)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RANK_FRIEND_CLICK, RelationShipChainMgr.OnRankFriendPanelClick)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, RelationShipChainMgr.OnLoginAccountSuccess)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, RelationShipChainMgr.OnShareActivie)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, RelationShipChainMgr.OnNewDay)
  EnterWorldAlertMgr.Instance():Register(EnterWorldAlertMgr.CustomOrder.ReCallFriend, RelationShipChainMgr.CheckToShowRecallFriendsTips, self)
end
def.method().Reset = function(self)
  flag = false
  RelationShipChainData.Instance():ClearAll()
  self:ClearRedGiftCountDownTimer()
end
return RelationShipChainMgr.Commit()
