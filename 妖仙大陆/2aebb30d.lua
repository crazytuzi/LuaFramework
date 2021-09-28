
local _M = {}
_M.__index = _M
local cjson = require "cjson" 
local ChatModel   = require "Zeus.Model.Chat" 
local DaoyouModel   = require "Zeus.Model.Daoyou"
local SocialUtil  = require "Zeus.UI.XmasterSocial.SocialUtil"


local _M = {}

_M.__index = _M
_M.PushData = {}
_M.EventPushCallback = {
  PushCb = {}
}
_M.MessagePushCallback = {
  PushCb = {}
}

_M.PrivateChannel = 4

local RecentlyList = {}
local FriendList = {}

local AllRecordCash = {}

local function SortDataList(data)
    
    if data == nil then
        return
    end
    table.sort(data, function (aa,bb) 
        if  aa.isOnline > bb.isOnline then
            return true
        end
        return false
    end)
end

function _M.StartsWith(item, res)
    local pos = string.find(item, res)
    
    if(pos and pos == 1)then
        return true
    else
        return false
    end
end

function _M.EndsWith(item, res)
    local tempitem = item
    local pos = string.find(tempitem, res)
    local length = string.len(tempitem) - string.len(res) + 1
    
    while (pos and pos <= length)do
        if(pos == length)then
            return true
        end
        tempitem = string.sub(tempitem, pos - 1, length)
        pos = string.find(tempitem, res)
        length = string.len(tempitem) - string.len(res) + 1
    end
    return false
end

function _M.GetContent(item,type)
  local subLen = 4
  if type ~= nil then
    subLen  = string.len(type) + 3
  end
    local length = string.len(item)
    
    local content = string.sub(item, subLen, length - (subLen+1))
    
    return content
end

function _M.IsVoiceMsg(msg)
    
    local retArray = split(msg, "|")
    for i, ement in ipairs(retArray) do
        local item = ement
        if _M.StartsWith(item, "<v ") and _M.EndsWith(item, "></v>") then
            local curcontent = _M.GetContent(item)
            local msg = cjson.decode(curcontent)
            return msg
        end
    end
    return nil
end

function _M.GetAllRecentlyList(cb)
  Pomelo.FriendHandler.getRecentChatListRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      RecentlyList = param.s2c_ls or {}
      SortDataList(RecentlyList)
      
      
      cb()
    end
  end)
end

function _M.GetAllSocialList(cb)
  Pomelo.FriendHandler.friendGetAllFriendsRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      FriendList = param
      
      
      SortDataList(FriendList.friends)
      SortDataList(FriendList.chouRens)
      SortDataList(FriendList.blackList)
      cb()
    end
  end)
end

function _M.GetRecentlyList()
  return RecentlyList
end

function _M.GetFriendList()
  return FriendList
end

function _M.GetDaoyouInviteList()
  local list = {}
  local daoyouList = DaoyouModel.GetDaoqunInfo().dyInfo or {}
  if FriendList.friends then
    for i,v in ipairs(FriendList.friends) do
      if v.isOnline > 0 then
        local isDaoyou = false
        for j,k in ipairs(daoyouList) do
          if v.id == k.playerId then
            isDaoyou = true
          end
        end
        if isDaoyou == false then
          table.insert(list, v)
        end
      end
    end
  end
  return list
end

function _M.sendMessageRequest(content, acceptRoleId, cb)
    

    local input = {}
    input.s2c_name = DataMgr.Instance.UserData.Name
    input.s2c_level = DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0)
    input.s2c_pro = DataMgr.Instance.UserData.Pro
    input.s2c_zoneId = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.ZONEID)
    input.s2c_vip = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.VIP)
    input.s2c_titleMsg = "" 
    input.acceptRoleId = acceptRoleId
    input.s2c_color = ChatModel.GetContentColor(_M.PrivateChannel)
    
    
    
    local msg = cjson.encode(input)
    
    Pomelo.ChatHandler.sendChatRequest(_M.PrivateChannel,content,msg,acceptRoleId,function (ex,json)
        if not ex then
          local param = json:ToData()
          cb(param)
        end
    end)
end

function _M.getSocialInfoRequest(cb)
  Pomelo.FriendHandler.getSocialInfoRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.addFriendInfoRequest(cb)
  Pomelo.FriendHandler.addFriendInfoRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.queryPlayerNameRequest(c2s_strName, cb)
  Pomelo.FriendHandler.queryPlayerNameRequest(c2s_strName,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.concernFriendRequest(c2s_friendId, cb)
  Pomelo.FriendHandler.concernFriendRequest(c2s_friendId, function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.friendAllApplyRequest(c2s_toPlayerIds, cb)
  Pomelo.FriendHandler.friendAllApplyRequest(c2s_toPlayerIds, function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.concernAllFriendRequest(c2s_toPlayerIds, cb)
  Pomelo.FriendHandler.concernAllFriendRequest(c2s_toPlayerIds, function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.friendAllAgreeApplyRequest(c2s_toPlayerIds, cb)
  Pomelo.FriendHandler.friendAllAgreeApplyRequest(c2s_toPlayerIds, function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.friendAllRefuceApplyRequest(c2s_toPlayerIds, cb)
  Pomelo.FriendHandler.friendAllRefuceApplyRequest(c2s_toPlayerIds, function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.friendGetAllFriendsRequest(cb)
  Pomelo.FriendHandler.friendGetAllFriendsRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.friendMessageListRequest(cb)
  Pomelo.FriendHandler.friendMessageListRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      
      
      cb(param)
    end
  end)
end

function _M.deleteAllFriendMessageRequest(cb)
  Pomelo.FriendHandler.deleteAllFriendMessageRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.friendApplyRequest(c2s_toPlayerId, cb)
    Pomelo.FriendHandler.friendApplyRequest(c2s_toPlayerId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.friendAgreeApplyRequest(c2s_requestId, cb)
    Pomelo.FriendHandler.friendAgreeApplyRequest(c2s_requestId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.friendRefuceApplyRequest(c2s_requestId, cb)
    Pomelo.FriendHandler.friendRefuceApplyRequest(c2s_requestId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.friendGetFriendAwardRequest(c2s_friendId, c2s_awardId, cb)
    Pomelo.FriendHandler.friendGetFriendAwardRequest(c2s_friendId,c2s_awardId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.friendDeleteRequest(c2s_friendId, cb)
    Pomelo.FriendHandler.friendDeleteRequest(c2s_friendId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.friendAddFriendExpRequest(c2s_friendId, c2s_point, cb)
    Pomelo.FriendHandler.friendAddFriendExpRequest(c2s_friendId,c2s_point,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.getAllBlackListRequest(cb)
    Pomelo.FriendHandler.getAllBlackListRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        if param.blackList ~= nil and #param.blackList > 1 then
          for i = 1, #param.blackList do
            ChatModel.AddNewBlackRole(param.blackList[i].id)
          end
        end

        cb(param)
      end
    end)
end

function _M.deleteBlackListRequest(c2s_blackListId, cb)
    Pomelo.FriendHandler.deleteBlackListRequest(c2s_blackListId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
        ChatModel.RemoveBlackRole(c2s_blackListId)
      end
    end)
end

function _M.deleteAllBlackListRequest(cb)
    Pomelo.FriendHandler.deleteAllBlackListRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.addBlackListRequest(c2s_blackListId, cb)
    Pomelo.FriendHandler.addBlackListRequest(c2s_blackListId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
        ChatModel.AddNewBlackRole(c2s_blackListId)
      end
    end)
end

function _M.friendGetAwardsInfoRequest(c2s_friendId,cb)
  Pomelo.FriendHandler.friendGetAwardsInfoRequest(c2s_friendId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.recentContactsRequest(c2s_ids,cb)
  
  Pomelo.PlayerHandler.recentContactsRequest(c2s_ids,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.friendGetAllChouRenRequest(cb)
  Pomelo.FriendHandler.friendGetAllChouRenRequest(function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.friendAllDeleteChouRenRequest(c2s_chouRenIds, cb)
  Pomelo.FriendHandler.friendAllDeleteChouRenRequest(c2s_chouRenIds, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.friendAddChouRenRequest(c2s_chouRenId, cb)
  Pomelo.FriendHandler.friendAddChouRenRequest(c2s_chouRenId,function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.friendDeleteChouRenRequest(c2s_chouRenId, cb)
  Pomelo.FriendHandler.friendDeleteChouRenRequest(c2s_chouRenId,function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.friendSetXuanShangRequest(c2s_chouRenId, c2s_award, c2s_times, cb)
  Pomelo.FriendHandler.friendSetXuanShangRequest(c2s_chouRenId,c2s_award,c2s_times, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.friendGetWorldXuanShangListRequest(c2s_type,c2s_index, cb)
  Pomelo.FriendHandler.friendGetWorldXuanShangListRequest(c2s_type,c2s_index, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end


function _M.changeAreaByPlayerIdRequest(c2s_playerId,c2s_type, cb)
  Pomelo.ItemHandler.changeAreaByPlayerIdRequest(c2s_playerId,c2s_type, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.isItemNumEnoughRequest(c2s_templateId,c2s_num,cb)
  Pomelo.ItemHandler.isItemNumEnoughRequest(c2s_templateId,c2s_num, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.getShopItemListRequest(cb)
  Pomelo.FriendHandler.getShopItemListRequest(function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.exchangeFriendShopItemRequest(c2s_itemId,c2s_num,cb)
  
  Pomelo.FriendHandler.exchangeFriendShopItemRequest(c2s_itemId,c2s_num, function(ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

local function setReadFlag(playerId)
  for i,v in ipairs(AllRecordCash) do
    if v.id == playerId then
      v.read = true
    end
  end
end

local function getCashRecord(senderId, receiverId)
  for i,v in ipairs(AllRecordCash) do
    if v.id == senderId or v.id == receiverId then
      return v
    end
  end

  return nil
end

local function insertData(record, param)
  
  
  
  
  
  
  
  
  if #record.recordList == 0 then
    record.recordList[1] = param
  else
    if #record.recordList < ChatModel.RecordCount then
      record.recordList[#record.recordList+1] = param
    else
      for i=1,#record.recordList-1 do
        record.recordList[i] = record.recordList[i+1]
      end
      record.recordList[ChatModel.RecordCount] = param
    end
  end
end

local function dealChatMsg(param)
  if FriendList.blackList then
    for i,v in ipairs(FriendList.blackList) do
      if v.id == param.s2c_playerId or v.id == param.s2c_acceptRid then
          return
      end
    end
  end
  local eleId = param.s2c_playerId
  if eleId == DataMgr.Instance.UserData.RoleID then
    eleId = param.s2c_acceptRid
  end

  param.isVoice = _M.IsVoiceMsg(param.s2c_content)

  local record = getCashRecord(eleId, DataMgr.Instance.UserData.RoleID)
  if record == nil then
      _M.GetChatRecordList(eleId, function(recordList)
        record = recordList
      end)
  else
    insertData(record,param)
  end
  if record ~= nil then
    record.read = false
  end

  for key,val in pairs(_M.MessagePushCallback.PushCb) do
    val(param)
  end
end

local function clearChatRecordList(senderId)
  for i,v in ipairs(AllRecordCash) do
    if v.id == senderId then
      v.recordList = {}
    end
  end
end

function _M.clearChatRecordReqest(playerId, cb)
  Pomelo.FriendHandler.rmChatMsgRequest(playerId, function (ex,json)
    if not ex then
      clearChatRecordList(playerId)
      cb()
    end
  end)
end

function _M.GetChatRecordList(playerId, cb)
  local record = getCashRecord(playerId, DataMgr.Instance.UserData.RoleID)
  if record == nil then
    record = {id = playerId, recordList = {}, read = true}
    table.insert(AllRecordCash, record)
  else
    record.read = true
    cb(record)
    return
  end
  Pomelo.FriendHandler.getChatMsgRequest(playerId, function (ex,json)
    if not ex then
      local param = json:ToData()
      if param.s2c_msgLs and #param.s2c_msgLs>0 then
        for i = 1, #param.s2c_msgLs do
          insertData(record, param.s2c_msgLs[i])
        end
      end
      
      
      cb(record)
    end
  end, XmdsNetManage.PackExtData.New(false, true))

end

function _M.RemoveMessagePushListener(key)
  _M.MessagePushCallback.PushCb[key] = nil
end

function _M.AddMessagePushListener(key, cb)
  _M.MessagePushCallback.PushCb[key] = cb
end

local function playerNewMessagePush(eventname,param)
  if param ~= nil then
    
    
      
      
      dealChatMsg(param.data)
    
  end
end

function _M.SetPrivateChatId(eventname,param)
  
  
  
  
  
  
end

function _M.RemoveEventPushListener(key)
  _M.EventPushCallback.PushCb[key] = nil
end

function _M.AddEventPushListener(key, cb)
  _M.EventPushCallback.PushCb[key] = cb
end

function _M.RefreshMsg()
  for key,val in pairs(_M.EventPushCallback.PushCb) do
    val(nil)
  end
end

function GlobalHooks.DynamicPushs.playerNewRequestPush(ex, json)
  if ex == nil then
    local param = json:ToData()
    if(param ~= nil)then
      _M.PushData[#_M.PushData + 1] = param
      for key,val in pairs(_M.EventPushCallback.PushCb) do
        val(param)
      end
    end
  end
end

function _M.InitNetWork()
    EventManager.Subscribe("Event.Social.newChatMsgPush", playerNewMessagePush)
    EventManager.Subscribe("Event.SocialFriend.SetPrivateChatId", _M.SetPrivateChatId)
    
end

return _M
