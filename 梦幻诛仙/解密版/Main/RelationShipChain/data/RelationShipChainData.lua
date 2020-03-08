local Lplus = require("Lplus")
local Json = require("Utility.json")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ECMSDK = require("ProxySDK.ECMSDK")
local RelationShipChainData = Lplus.Class("RelationShipChainData")
local def = RelationShipChainData.define
def.field("boolean").m_Toggle = false
def.field("boolean").m_IsRecallPlayer = false
def.field("number").m_TotalFriendNum = 0
def.field("number").m_RecallFriendNum = 0
def.field("number").m_TodayRecallFriendNum = 0
def.field("number").m_BigGiftAwardState = -1
def.field("number").m_TotalGiftNum = 0
def.field("number").m_FriendNumAwardSerialID = 0
def.field("number").m_RecallFriendsAwardSerialID = 0
def.field("table").m_GiftSwith = function()
  return {}
end
def.field("table").m_FriendData = function()
  return {}
end
def.field("table").m_ReciveGiftData = function()
  return {}
end
def.field("table").m_SendGiftData = function()
  return {}
end
def.field("table").m_ReciveGiftTimesData = function()
  return {}
end
def.field("table").m_SubscribeData = function()
  return {}
end
def.field("table").m_InviteFriendData = function()
  return {}
end
def.field("table").m_RecallFriendSignAwardData = function()
  return {}
end
def.field("table").m_MyInfo = function()
  return {}
end
def.field("table").m_NoticeActivityData = function()
  return {}
end
def.field("table").m_OldMyInfo = function()
  return {}
end
def.field("table").m_OldFriendData = function()
  return {}
end
local instance
def.static("=>", RelationShipChainData).Instance = function()
  if not instance then
    instance = RelationShipChainData()
  end
  return instance
end
def.method().SetInitialFriendDate = function(self, friendData)
  self.m_OldFriendData = friendData
  for k, v in pairs(friendData) do
    if v.openid == myselfOpenId then
      self.m_OldMyInfo = v
      break
    end
  end
end
def.method("=>", "string").GetImgCacheFolder = function(self)
  local path = Application.persistentDataPath .. "/FriendImgCache"
  GameUtil.CreateDirectoryForFile(path)
  return path
end
def.method("number", "number", "table").SetFriendData = function(self, totalNum, pageIndex, friendData)
  self.m_TotalFriendNum = totalNum
  for _, v in pairs(friendData) do
    local openid = GetStringFromOcts(v.openid)
    if openid:len() ~= 0 then
      v.pageIndex = pageIndex
      self.m_FriendData[openid] = v
    end
  end
end
def.method("userdata", "=>", "table").SearchFriendData = function(self, roleId)
  if self.m_FriendData then
    for k, v in pairs(self.m_FriendData) do
      if v.roleid == roleId then
        return v
      end
    end
  end
  return nil
end
def.method("userdata").UpdateRecallFriendData = function(self, openid)
  local openid = GetStringFromOcts(openid)
  if self.m_FriendData[openid] then
    self.m_FriendData[openid].recall_state = 2
  end
end
def.method("number", "number", "table").SetReciveGiftData = function(self, totalNum, pageIndex, data)
  self.m_TotalGiftNum = totalNum
  for k, v in pairs(data) do
    v.pageIndex = pageIndex
    local serialid = v.serialid:ToNumber()
    self.m_ReciveGiftData[serialid] = v
  end
end
def.method("number", "number").UpdateReciveGiftData = function(self, type, serialid)
  for k, v in pairs(self.m_ReciveGiftData) do
    if v.gift_type == type and v.serialid:ToNumber() == serialid then
      self.m_ReciveGiftData[k] = nil
      self.m_TotalGiftNum = self.m_TotalGiftNum - 1
    end
  end
end
def.method("table").SetSendGiftData = function(self, data)
  for k, v in pairs(data) do
    self.m_SendGiftData[v.gift_type] = v.today_send_gift_infos
  end
end
def.method("number", "userdata").UpdateSendGiftData = function(self, type, openid)
  local sendData = self.m_SendGiftData[type]
  if not sendData then
    self.m_SendGiftData[type] = {}
  end
  table.insert(self.m_SendGiftData[type], {to = openid})
end
def.method("table").SetReciveGiftTimesData = function(self, reciveGiftTimesData)
  self.m_ReciveGiftTimesData = reciveGiftTimesData
end
def.method("number", "number").UpdateReciveGiftTimesData = function(self, type, serialid)
  for k, v in pairs(self.m_ReciveGiftTimesData) do
    if v.gift_type == type then
      v.today_receive_times = v.today_receive_times + 1
    end
  end
  self:UpdateReciveGiftData(type, serialid)
end
def.method("number", "number").SetFriendsCountAwardInfo = function(self, serialid, friendNum)
  self.m_FriendNumAwardSerialID = serialid
  self.m_TotalFriendNum = friendNum
end
def.method("number", "number", "number").SetRecallFriendsCountAwardInfo = function(self, serialid, friendNum, todayRecallFriends)
  self.m_RecallFriendsAwardSerialID = serialid
  self.m_RecallFriendNum = friendNum
  self.m_TodayRecallFriendNum = todayRecallFriends
end
def.method("number").UpdateFriendNumAwardSerialID = function(self, serialid)
  self.m_FriendNumAwardSerialID = serialid
end
def.method("number").UpdateRecallFriendNumSerialID = function(self, serialid)
  self.m_RecallFriendsAwardSerialID = serialid
end
def.method().IncCanRecallFriendNum = function(self)
  self.m_RecallFriendNum = self.m_RecallFriendNum + 1
end
def.method().ResetTodayRecallFriendNum = function(self)
  self.m_TodayRecallFriendNum = 0
end
def.method().IncTodayRecallFriendNum = function(self)
  self.m_TodayRecallFriendNum = self.m_TodayRecallFriendNum + 1
end
def.method().RefreshRankDate = function(self)
  self.m_OldMyInfo = self.m_MyInfo
  self.m_OldFriendData = self.m_FriendData
end
def.method("string").SetSubscribeData = function(self, data)
  local result = Json.decode(data)
  self.m_SubscribeData = {}
  if result.errcode == 0 then
    local list = result.subscribe_list
    for k, v in pairs(list) do
      local cfg = RelationShipChainData.GetSubscribeRemindCfgByIndex(v.id)
      if cfg then
        cfg.status = v.status
        cfg.title = v.title
        cfg.id = v.id
        table.insert(self.m_SubscribeData, cfg)
      end
    end
  elseif result.errcode == -10000 then
    Debug.LogWarning("\231\179\187\231\187\159\229\164\177\232\180\165")
  elseif result.errcode == -10002 then
    Debug.LogWarning("\229\143\130\230\149\176\233\148\153\232\175\175")
  end
end
def.method("string", "number").UpdateSubscribeData = function(self, data, id)
  local result = Json.decode(data)
  if result.errcode == 0 then
    for _, v in pairs(self.m_SubscribeData) do
      if v.id == id then
        v.status = not v.status
      end
    end
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.Subscribe, nil)
  elseif result.errcode == -10000 then
    Debug.LogWarning("\231\179\187\231\187\159\229\164\177\232\180\165")
  elseif result.errcode == -10002 then
    Debug.LogWarning("\229\143\130\230\149\176\233\148\153\232\175\175")
  elseif result.errcode == -20001 then
    Toast(textRes.RelationShipChain[22])
  end
end
def.method("=>", "table").GetSubscribeData = function(self)
  return self.m_SubscribeData
end
def.method("table").SetCareActivityData = function(self, data)
  self.m_NoticeActivityData = {}
  for k, v in pairs(data) do
    local activityCfg = ActivityInterface.GetActivityCfgById(k)
    if activityCfg and activityCfg.subscribeRemindid > 0 then
      local cfg = RelationShipChainData.GetSubscribeRemindCfg(activityCfg.subscribeRemindid)
      cfg.status = v == 1 and true or false
      cfg.activityID = k
      table.insert(self.m_NoticeActivityData, cfg)
    end
  end
end
def.method("number").UpdateNoticeActivityData = function(self, id)
  for k, v in pairs(self.m_NoticeActivityData) do
    if v.activityID == id then
      v.status = not v.status
    end
  end
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NoticeActivity, nil)
end
def.method("=>", "table").GetNoticeActivityData = function(self)
  return self.m_NoticeActivityData
end
def.method("table").SetInviteFriendInfo = function(self, data)
  self.m_InviteFriendData = data
end
def.method("number").UpdateAwardGiftTiems = function(self, award_gift_times)
  if self.m_InviteFriendData then
    self.m_InviteFriendData.award_gift_times = award_gift_times
  end
end
def.method("userdata").UpdateRebateBindYuanbao = function(self, rebate_bind_yuanbao)
  if self.m_InviteFriendData then
    self.m_InviteFriendData.rebate_bind_yuanbao = rebate_bind_yuanbao
  end
end
def.method("=>", "table").GetInviteFriendData = function(self)
  return self.m_InviteFriendData
end
def.method("=>", "number").GetFriendNum = function(self)
  return self.m_TotalFriendNum
end
def.method("=>", "number").GetRecallFriendNum = function(self)
  return self.m_RecallFriendNum
end
def.method("=>", "number").GetGiftNum = function(self)
  return self.m_TotalGiftNum
end
def.method("=>", "table").GetMyInfo = function(self)
  return self.m_MyInfo
end
def.method("=>", "table").GetFriendData = function(self)
  return self.m_FriendData
end
def.method("=>", "table").GetReciveGiftData = function(self)
  return self.m_ReciveGiftData
end
def.method("number", "=>", "table").GetSendGiftData = function(self, type)
  return self.m_SendGiftData[type]
end
def.method("=>", "number").GetFriendNumAwardSerialID = function(self)
  return self.m_FriendNumAwardSerialID
end
def.method("=>", "number").GetRecallFriendsAwardSerialID = function(self)
  return self.m_RecallFriendsAwardSerialID
end
def.method("boolean").SetRecallFriendFlag = function(self, flag)
  self.m_IsRecallPlayer = flag
end
def.method("=>", "boolean").IsRecallPlayer = function(self)
  return self.m_IsRecallPlayer
end
def.method("number").SetBigGiftAwardState = function(self, flag)
  self.m_BigGiftAwardState = flag
end
def.method("number").UpdateRecallFriendSignAwardData = function(self, day)
  self.m_RecallFriendSignAwardData[day] = 3
end
def.method("=>", "table").GetRecallFriendSignAwardData = function(self)
  return self.m_RecallFriendSignAwardData
end
def.method("table").SetRecallFriendSignAwardData = function(self, data)
  self.m_RecallFriendSignAwardData = data
end
def.method("=>", "number").GetBigGiftAwardState = function(self)
  return self.m_BigGiftAwardState
end
def.method("=>", "number").GetTodayRecallFriendNum = function(self)
  return self.m_TodayRecallFriendNum
end
def.method("number", "=>", "number").GetReciveGiftTimesData = function(self, type)
  for _, v in pairs(self.m_ReciveGiftTimesData) do
    if v.gift_type == type then
      return v.today_receive_times
    end
  end
  return 0
end
def.method("=>", "number").GetCanRecallFriendNum = function(self)
  local count = 0
  for _, v in pairs(self.m_FriendData) do
    if v.recall_state == 1 then
      count = count + 1
    end
  end
  return count
end
def.method("number", "number").TurnOnOff = function(self, type, onoff)
  self.m_GiftSwith[type] = onoff == 1 and true or false
end
def.method("number", "=>", "boolean").GetGiftSwith = function(self, type)
  if self.m_GiftSwith[type] == nil then
    return true
  else
    return self.m_GiftSwith[type]
  end
end
def.method("string", "=>", "string").GetNickName = function(self, openid)
  if not self.m_FriendData[openid] then
    warn("GetNickName is nil")
    return ""
  end
  return self.m_FriendData[openid].nickname or ""
end
def.method("string", "=>", "string").GetImgURL = function(self, openid)
  if not self.m_FriendData[openid] then
    warn("GetImgURL is nil")
    return ""
  end
  return self.m_FriendData[openid].figure_url or ""
end
def.method("number", "string", "=>", "boolean").IsSend = function(self, type, openid)
  local sendData = self.m_SendGiftData[type]
  if not sendData then
    return false
  else
    for k, v in pairs(sendData) do
      local to = GetStringFromOcts(v.to)
      if to == openid then
        return true
      end
    end
    return false
  end
end
def.method().ClearSendGiftData = function(self)
  self.m_SendGiftData = {}
  for k, v in pairs(self.m_ReciveGiftTimesData) do
    v.today_receive_times = 0
  end
end
def.method("=>", "table").GetAllCanRecallFriends = function(self)
  local friendData = self:GetFriendData()
  local recallFriends = {}
  for _, v in pairs(friendData) do
    if v.recall_state == 1 and ECMSDK.GetMSDKInfo().openId ~= GetStringFromOcts(friendData.openid) then
      table.insert(recallFriends, v)
    end
  end
  table.sort(recallFriends, function(l, r)
    if not l.fighting_capacity or not r.fighting_capacity then
      return false
    end
    if l.recall_state ~= r.recall_state then
      return l.recall_state < r.recall_state
    elseif l.fighting_capacity ~= r.fighting_capacity then
      return l.fighting_capacity > r.fighting_capacity
    else
      return GetStringFromOcts(l.openid) > GetStringFromOcts(r.openid)
    end
  end)
  return recallFriends
end
def.static("number", "=>", "table").GetShareTitleAndContent = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SHARE_TITLE_CONTENT, id)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.title = record:GetStringValue("title")
  cfg.content = record:GetStringValue("content")
  return cfg
end
def.static("number", "=>", "table").GetSubscribeRemindCfgByIndex = function(id)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SUBSCRIBE_REMIND_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local indexId = record:GetIntValue("indexId")
    if id == indexId then
      cfg = {}
      cfg.id = record:GetIntValue("id")
      cfg.activityName = record:GetStringValue("activityName")
      cfg.cycle = record:GetStringValue("cycle")
      cfg.time = record:GetStringValue("time")
      cfg.type = record:GetStringValue("type")
      cfg.content = record:GetIntValue("content")
      cfg.indexId = record:GetIntValue("indexId")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("string", "=>", "number").GetGrcConstant = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GRC_CONSTS, key)
  if not record then
    warn("GetGrcConstant(" .. key .. ") return nil")
    return 0
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  return value
end
def.static("number", "=>", "table").GetGrcGiftCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GRC_GIFT_CFG, id)
  if not record then
    warn("GetGrcGiftCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.name = record:GetStringValue("name")
  cfg.gift_type = record:GetIntValue("gift_type")
  cfg.gift_count = record:GetIntValue("gift_count")
  cfg.send_max_times_everyday = record:GetIntValue("send_max_times_everyday")
  cfg.receive_max_times_everyday = record:GetIntValue("receive_max_times_everyday")
  return cfg
end
def.static("number", "=>", "table").GetPrivilegeAwardCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PRIVILEGE_AWARD_CFG, id)
  if not record then
    warn("GetPrivilegeAwardCfg(" .. id .. ") return nil")
    return nil
  end
  local cfg = {}
  cfg.privilege_type = record:GetIntValue("privilege_type")
  cfg.sign_extra_award_type = record:GetIntValue("sign_extra_award_type")
  cfg.sign_extra_award_num = record:GetIntValue("sign_extra_award_num")
  cfg.daily_award_mail_cfg_id = record:GetIntValue("daily_award_mail_cfg_id")
  cfg.daily_team_instance_award_buff_cfg_id = record:GetIntValue("daily_team_instance_award_buff_cfg_id")
  return cfg
end
def.static("=>", "table").GetAllGrcFriendsCountAwardCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GRC_FRIENDS_COUNT_AWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    cfgs[i + 1] = {}
    cfgs[i + 1].id = record:GetIntValue("id")
    cfgs[i + 1].name = record:GetStringValue("name")
    cfgs[i + 1].serial_no = record:GetIntValue("serial_no")
    cfgs[i + 1].need_count = record:GetIntValue("need_count")
    cfgs[i + 1].award_cfg_id = record:GetIntValue("award_cfg_id")
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("number", "=>", "table").GetSubscribeRemindCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SUBSCRIBE_REMIND_CFG, id)
  if not record then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.activityName = record:GetStringValue("activityName")
  cfg.cycle = record:GetStringValue("cycle")
  cfg.time = record:GetStringValue("time")
  cfg.type = record:GetStringValue("type")
  cfg.content = record:GetIntValue("content")
  cfg.indexId = record:GetIntValue("indexId")
  return cfg
end
def.static("=>", "table").GetAllSubscribeRemind = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SUBSCRIBE_REMIND_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    cfgs[i + 1] = {}
    cfgs[i + 1].id = record:GetIntValue("id")
    cfgs[i + 1].activityName = record:GetStringValue("activityName")
    cfgs[i + 1].cycle = record:GetStringValue("cycle")
    cfgs[i + 1].time = record:GetStringValue("time")
    cfgs[i + 1].type = record:GetStringValue("type")
    cfgs[i + 1].content = record:GetIntValue("content")
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("string", "=>", "number").GetRedGiftActivityConstant = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_RED_GIFT_ACTIVITY_CONSTS, key)
  if not record then
    warn("GetRedGiftActivityConstant(" .. key .. ") return nil")
    return 0
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  return value
end
def.static("string", "=>", "number").GetInviteFriendConstant = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_INVITE_FRIEND_CONSTS, key)
  if not record then
    warn("GetInviteFriendConstant(" .. key .. ") return nil")
    return 0
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  return value
end
def.static("=>", "table").GetRecallFriendNumAwardCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_RECALL_FRIEND_NUM_AWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    cfgs[i + 1] = {}
    cfgs[i + 1].serial_no = record:GetIntValue("serialNo")
    cfgs[i + 1].need_count = record:GetIntValue("recallFriendNum")
    cfgs[i + 1].award_cfg_id = record:GetIntValue("awardId")
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("=>", "table").GetRecallFriendSignAwardCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_RECALL_FRIEND_SIGN_AWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    cfgs[i + 1] = {}
    cfgs[i + 1].signDay = record:GetIntValue("signDay")
    cfgs[i + 1].desc = record:GetStringValue("awardDescribe") or ""
    cfgs[i + 1].awardId = record:GetIntValue("awardId")
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("string", "=>", "number").GetRecallFriendConstant = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_RECALL_FRIENDS_CONSTS, key)
  if not record then
    warn("GetRecallFriendConstant(" .. key .. ") return nil")
    return 0
  end
  local value = DynamicRecord.GetIntValue(record, "value")
  return value
end
def.method().ClearAll = function(self)
  self.m_IsRecallPlayer = false
  self.m_GiftSwith = {}
  self.m_FriendData = {}
  self.m_ReciveGiftData = {}
  self.m_SendGiftData = {}
  self.m_ReciveGiftTimesData = {}
  self.m_SubscribeData = {}
  self.m_MyInfo = {}
  self.m_NoticeActivityData = {}
  self.m_OldMyInfo = {}
  self.m_OldFriendData = {}
  self.m_InviteFriendData = {}
  self.m_RecallFriendSignAwardData = {}
end
return RelationShipChainData.Commit()
