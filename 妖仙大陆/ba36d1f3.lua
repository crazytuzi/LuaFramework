
local _M = {}
_M.__index = _M
local cjson 	= require "cjson"  
local Util      = require "Zeus.Logic.Util"


_M.ChannelState = {   
  Channel_world = 1, 
  Channel_union = 2,
  Channel_group = 3,
  Channel_private = 4,
  Channel_crossServer = 5,
  Channel_ally = 6,
  Channel_system = 7,
  
  Channel_horm = 8, 
  Channel_teamInvited = 9,
}


_M.ChatData = {
	{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
}


_M.ChatPushCallback = {
  chatPushCb = {},
}


local isBlackLisInit = false
_M.BlackList = {}


_M.RecordCount = 100


_M.mSettingItems = {}


_M.mCommonItems = {}


_M.RedPoint = {
  {showPoint = false},
  {showPoint = false},
  {showPoint = false},
  {showPoint = false},
  {showPoint = false},
  {showPoint = false},
  {showPoint = false},
}


_M.sendTime = {}

local lastChatItemIndex = 0 
local ChatItemGetTime = {}

function _M.NeedShowTime(data) 
  local datalist = _M.ChatData[data.s2c_scope]
  if #datalist < 2 then
    return true
  end
  local index = 0
  for i=1,#datalist do
    if datalist[1].s2c_index == data.s2c_index then 
      return true
    end

    if datalist[i].s2c_index > index and datalist[i].s2c_index < data.s2c_index then 
      index = datalist[i].s2c_index
    end
  end

  if ChatItemGetTime[data.s2c_index] - ChatItemGetTime[index] > 5*60 then
    return true
  end

  return false
end


function _M.InitBaseSetData()
    
    _M.mSettingItems = GlobalHooks.DB.Find('ChatSetting', {})
    for i = 1, #_M.mSettingItems do
        _M.mSettingItems[i].IsHide = UnityEngine.PlayerPrefs.GetInt(_M.mSettingItems[i].ChannelID .. "chatchannel", 0)
        _M.mSettingItems[i].curColor =  tonumber(UnityEngine.PlayerPrefs.GetString(i .. "channelcolor", "0"))
        _M.mSettingItems[i].AnonymousState = 0
        _M.mSettingItems[i].Lefttimes = UnityEngine.PlayerPrefs.GetInt(DataMgr.Instance.UserData.RoleID .. i .. System.DateTime.Today:ToShortDateString() .. "Lefttimes", -1)
        if _M.mSettingItems[i].Lefttimes == -1 then   
          _M.mSettingItems[i].Lefttimes = _M.mSettingItems[i].CallTimes
        end
    end

    for j = _M.ChannelState.Channel_world, _M.ChannelState.Channel_ally do
      _M.mCommonItems[j] = GlobalHooks.DB.Find('DefMsg', {channelId = j})
      for i = 1, #_M.mCommonItems[j] do
        _M.mCommonItems[j][i].common = UnityEngine.PlayerPrefs.GetString(DataMgr.Instance.UserData.RoleID .. i .. "chatCommon" .. j, "")
        _M.mCommonItems[j][i].commontimes = UnityEngine.PlayerPrefs.GetInt(DataMgr.Instance.UserData.RoleID .. i .. "chatCommontimes" .. j, 0)
      end
    end
end


function _M.SaveBaseSetData()
    
    for i = 1, #_M.mSettingItems do
        UnityEngine.PlayerPrefs.SetInt(_M.mSettingItems[i].ChannelID .. "chatchannel", _M.mSettingItems[i].IsHide)
        UnityEngine.PlayerPrefs.SetString(i .. "channelcolor", tostring(_M.mSettingItems[i].curColor))
        UnityEngine.PlayerPrefs.SetInt(DataMgr.Instance.UserData.RoleID .. i .. System.DateTime.Today:ToShortDateString() .. "Lefttimes", _M.mSettingItems[i].Lefttimes)
        
    end

    for j = _M.ChannelState.Channel_world, _M.ChannelState.Channel_ally do
      for i = 1, #_M.mCommonItems[j] do
        UnityEngine.PlayerPrefs.SetString(DataMgr.Instance.UserData.RoleID .. i .. "chatCommon" .. j, _M.mCommonItems[j][i].common)
        UnityEngine.PlayerPrefs.SetInt(DataMgr.Instance.UserData.RoleID .. i .. "chatCommontimes" .. j, _M.mCommonItems[j][i].commontimes)
      end
    end
end

local function CheckIsSameStr(str, channel)
  	
  	for i = 1, #_M.mCommonItems[channel] do
    	if string.gsub(str, "|", "") == string.gsub(_M.mCommonItems[channel][i].common, "|", "") then
      		return true
    	end
  	end
  	return false
end

local function GetLastCommon(channel)
  	
  	local index = 1
  	local lastcount = 1000000
  	for i = 1, #_M.mCommonItems[channel] do
    	if lastcount > _M.mCommonItems[channel][i].commontimes then
      		lastcount = _M.mCommonItems[channel][i].commontimes
      		index = i
    	end
  	end
  	return index
end

local function ResetLastCommon(channel)
  	
  	for i = 1, #_M.mCommonItems[channel] do
    	_M.mCommonItems[channel][i].commontimes = _M.mCommonItems[channel][i].commontimes - 1000
  	end
end

function _M.InitBlackList()
  Pomelo.FriendHandler.friendGetAllFriendsRequest(function (ex,sjson)
    	if not ex then
      	local param = sjson:ToData()
      	if param.blackList ~= nil and #param.blackList > 0 then
        		for i = 1, #param.blackList do
          		_M.AddNewBlackRole(param.blackList[i].id)
        		end
      	end
    	end
  end)
end

function _M.AddNewBlackRole(roleid)
  if _M.BlackList[roleid] == nil then
      _M.BlackList[roleid] = 1
  end
end

function _M.RemoveBlackRole(roleid)
  if _M.BlackList[roleid] ~= nil then
      _M.BlackList[roleid] = nil
  end  
end


function _M.GetCharacterList(channel)
  	
  	local datalist = _M.ChatData[channel]
  	local chatacterlist = {}
  	for i = 1, #datalist do 
      	local finduser = false
        local data = datalist[#datalist + 1 - i]
      	if data.s2c_sys == 1 then
          	finduser = true
      	else
          	for j = 1, #chatacterlist do
              	if chatacterlist[j].s2c_playerId == data.s2c_playerId then
                  	finduser = true
                  	break
              	end
          	end
      	end
      	
      	
      	if finduser == false and data.s2c_playerId ~= DataMgr.Instance.UserData.RoleID then
        	chatacterlist[#chatacterlist + 1] = data
      	end
  	end
  	return chatacterlist
end

function _M.GetLastSpeakPerson(channel)
    
    local datalist = _M.ChatData[channel]
    local chatacterlist = {}
    for i = 1, #datalist do 
        local data = datalist[#datalist + 1 - i]
        if data.s2c_playerId ~= DataMgr.Instance.UserData.RoleID then
          return data
        end
    end
end

function _M.RemoveChatPushListener(key)
  	_M.ChatPushCallback.chatPushCb[key] = nil
end

function _M.AddChatPushListener(key, cb)
  	_M.ChatPushCallback.chatPushCb[key] = cb
end

function _M.deleteOneDataByIndex(index)
	for i = 1, #_M.ChatData[index] - 1 do
		_M.ChatData[index][i] = _M.ChatData[index][i + 1]
	end
	_M.ChatData[index][#_M.ChatData[index]] = nil
end

local function insertData(scr, data, length)
    
    if data.s2c_serverData ~= nil then
      data.serverData = cjson.decode(data.s2c_serverData)
      if data.serverData == nil then
        data.serverData = {}
      end
      if data.serverData.s2c_titleMsg == nil then
        data.serverData.s2c_titleMsg = ""
      end
    end

    
    if data.serverData.s2c_vip == nil and data.s2c_sys ~= 1 then
      GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'error')  .. data.s2c_content)
      return false
    end

    if scr == nil then
        scr = {}
        scr[1] = data
    else
        if #scr > length then
            for i = 1, length do
                scr[i] = scr[i + 1]
            end
            scr[length + 1] = data
        else
            scr[#scr + 1] = data
        end
    end
    return true
end

function _M.initChatData(lenght)
	
	for i = 1, lenght do
		local item = {}
		table.insert(ChatData, item)
	end
end

function _M.GetContentColor(scope)
	
	
  	if _M.mSettingItems[scope] ~= nil then
    	if _M.mSettingItems[scope].curColor ~= 0 and _M.mSettingItems[scope].curColor ~= 255 then
      		return _M.mSettingItems[scope].curColor
    	else
      		return GameUtil.CovertHexStringToRGBA(_M.mSettingItems[scope].FontColor)
    	end
  	else
    	if _M.mSettingItems[1].curColor ~= 0 and _M.mSettingItems[1].curColor ~= 255 then
      		return _M.mSettingItems[1].curColor
    	else
      		return GameUtil.CovertHexStringToRGBA(_M.mSettingItems[1].FontColor)
    	end
  	end
end

local function IsVoiceMsg(msg)
    
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

local lastSendContent = nil
local sameContentTimes = 0 
function _M.chatMessageRequest(scope, content, acceptRoleId, cb, isAtAll, titleMsg, funtype)
  	
    
    local isVoice = IsVoiceMsg(content)
    if _M.mCommonItems[scope] ~= nil 
      and isVoice == nil 
      and (funtype == nil or funtype == 0) then

      if CheckIsSameStr(content, scope) == false then
        local mCurcommonItems = _M.mCommonItems[scope][GetLastCommon(scope)]
        if mCurcommonItems ~= nil then
          mCurcommonItems.common = content
          mCurcommonItems.commontimes = mCurcommonItems.commontimes + 1
          if mCurcommonItems.commontimes > 1500 then
              ResetLastCommon(scope)
          end
        end
      end
    end

    if _M.sendTime[scope] ~= nil then
      local time = math.floor((System.DateTime.Now - _M.sendTime[scope]).TotalSeconds)
      local coolDown = 0
      local delayCoolDownTime = 0
      if _M.mSettingItems[scope] ~= nil then
        coolDown = _M.mSettingItems[scope].CoolDown
        delayCoolDownTime = _M.mSettingItems[scope].CoolDownExtra
      end

      if lastSendContent == content then
          coolDown = coolDown + sameContentTimes * delayCoolDownTime
      else
          sameContentTimes = 0
      end

      if _M.mSettingItems[scope] ~= nil and time < coolDown then 
          local str = Util.GetText(TextConfig.Type.CHAT, 'sendmessage')
          GameAlertManager.Instance:ShowNotify("<f>" .. string.gsub(str, "|1|", coolDown - time) .. "</f>")
          return
      end
    end
    _M.sendTime[scope] = System.DateTime.Now
  	if scope == _M.ChannelState.Channel_group and DataMgr.Instance.TeamData.HasTeam == false then
  		GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'message2'))
  		return
  	elseif scope == _M.ChannelState.Channel_union and DataMgr.Instance.UserData.Guild == false then
  		GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'message3'))
  		return
    elseif scope == _M.ChannelState.Channel_crossServer then
        local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
        if sceneType ~= PublicConst.SceneType.CrossServer then
          GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'only_connect'))
          return
        end
  	end

  	local input = {}
  	input.s2c_name = DataMgr.Instance.UserData.Name
  	input.s2c_level = DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0)
  	input.s2c_pro = DataMgr.Instance.UserData.Pro
  	input.s2c_zoneId = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.ZONEID)
  	input.s2c_vip = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.VIP)
  	if isAtAll ~= nil then
    	input.s2c_isAtAll = isAtAll
    	if isAtAll == 1 then
      		if _M.mSettingItems[scope].Lefttimes > 0 then
        		_M.mSettingItems[scope].Lefttimes = _M.mSettingItems[scope].Lefttimes - 1
      		else
        		return 
      		end
    	end
  	else
    	input.s2c_isAtAll = 0 
  	end

  	if titleMsg ~= nil then
    	input.s2c_titleMsg = titleMsg 
  	end

  	if funtype ~= nil then
    	input.s2c_funtype = funtype 
  	end

  	
  	input.s2c_color = _M.GetContentColor(scope)
	if _M.mSettingItems[scope] ~= nil and _M.mSettingItems[scope].AnonymousState ~= 0 then
  		input.s2c_AnonymousState = _M.mSettingItems[scope].AnonymousState
  		_M.mSettingItems[scope].AnonymousState = 0
	end

  	if acceptRoleId == nil or string.gsub(acceptRoleId, " ", "") == "" then
    	input.acceptRoleId = ""
    	
     
     
    	
  	else
    	input.acceptRoleId = acceptRoleId
  	end
  	local msg = cjson.encode(input)
	
	
	FileSave.channel = scope
  	FileSave.chatContent = content
  	FileSave.acceptRoleId = input.acceptRoleId 
  	FileSave.serverData = msg
  	FileSave.CallBack = LuaUIBinding.UploadDoneCallBack(function(isSend)
      if isSend then
    		if cb ~= nil then
  	       cb(isSend)
  	    end
      else
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "chatservererror"))
      end
  	end)
  	

	
	Pomelo.ChatHandler.sendChatRequest(scope,content,msg,acceptRoleId,function (ex,json)
        if json then
          local param = json:ToData()
          cb(param)
        end
      	if not ex then
          if lastSendContent == content then
            sameContentTimes = sameContentTimes +1
          end
          lastSendContent = content
      	end
    end)
	
end

function _M.getChatServerIdRequest(cb)
  	





end

function _M.getSaveChatMsgRequest(c2s_scope,c2s_index,c2s_uid,cb)
  	
    
    cb({})


  	
   
	  
	  
   
   
   
   
   
   
   
   
   
   
   
   
   
end

function _M.interactRequest(type, c2s_playerId,c2s_playerName, cb)
  	Pomelo.InteractHandler.interactRequest(type, c2s_playerId,c2s_playerName, function (ex,json)
    	if not ex then
      		local param = json:ToData()
      		cb(param)
    	end
  	end)
end

function _M.interactConfigRequest(cb)
  	Pomelo.InteractHandler.interactConfigRequest(function (ex,json)
    	if not ex then
      		local param = json:ToData()
      		cb(param)
    	end
  	end)
end

function _M.interactTimesRequest(cb)
  	Pomelo.InteractHandler.interactTimesRequest(function (ex,json)
    	if not ex then
      		local param = json:ToData()
      		cb(param)
    	end
  	end)
end

function _M.ShowNotifyLabel(s2c_msg)
	
    local s = ""
    if string.find(s2c_msg,"g") then
        
        local index = string.find(s2c_msg,"g")
        local value = string.sub(s2c_msg,2,index-1)
        local format_gold = Util.GetText(TextConfig.Type.SHOP, "format_gold",value)
        s = string.format("%s",format_gold)
    elseif string.find(s2c_msg,"e") then
        
        local index = string.find(s2c_msg,"e")
        local value = string.sub(s2c_msg,2,index-1)
        local format_exp = Util.GetText(TextConfig.Type.SHOP, "format_exp",value)
        s = string.format("%s",format_exp)
    end
    local node = XmdsUISystem.CreateFromFile("xmds_ui/common/tip_jump.gui.xml");
    local cvs = node:FindChildByEditName("cvs_tips",true):Clone()
    local text = cvs:FindChildByEditName("lb_get",true)
    text.Text = s

    node:Dispose();


















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

local function AddMessageData(param)
  if param.s2c_scope == _M.ChannelState.Channel_union then
    DataMgr.Instance.MessageData:AddSimulationMessage(MessageData.MsgType.LegionChatMsg)
  elseif param.s2c_scope == _M.ChannelState.Channel_group and param.s2c_sys ~= 9 then 
    DataMgr.Instance.MessageData:AddSimulationMessage(MessageData.MsgType.TeamChatMsg)
  elseif param.s2c_scope == _M.ChannelState.Channel_ally then
    DataMgr.Instance.MessageData:AddSimulationMessage(MessageData.MsgType.AllyChatMsg)
  end
end

function _M.RemoveMessageData(channel)
  
  if channel == _M.ChannelState.Channel_union then
    DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.LegionChatMsg)
  elseif channel == _M.ChannelState.Channel_group then
    DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.TeamChatMsg)
  elseif channel == _M.ChannelState.Channel_ally then
    DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.AllyChatMsg)
  end
end

local function dealChatMsg(param)
  	if isBlackLisInit == false then
      _M.InitBlackList()
      isBlackLisInit = true
    end

    if _M.BlackList[param.s2c_playerId] ~= nil then
    		return
  	end

  	
    if insertData(_M.ChatData[param.s2c_scope], param, _M.RecordCount - 1) == false then
      return
    end

    
  	
   
  	
    	if param.s2c_scope == _M.ChannelState.Channel_ally or 
        (param.serverData ~= nil and (param.serverData.s2c_isAtAll == 1 or param.serverData.s2c_isAtAll == 2)) then
      		_M.RedPoint[param.s2c_scope].showPoint = true
    	end
  	

    
    
    param.isVoice = IsVoiceMsg(param.s2c_content)
    



















    param.s2c_index = lastChatItemIndex 
    lastChatItemIndex = lastChatItemIndex+1
    ChatItemGetTime[param.s2c_index] = os.time()

    AddMessageData(param)
  	
  	
  	for key,val in pairs(_M.ChatPushCallback.chatPushCb) do
    	
      
    	val(param)

  	end
end

local function SystmChat(eventname, params)
  	
  	
  	local param = {
    	s2c_code = 1,
    	s2c_playerId = "",
	    s2c_uid = "",
	    s2c_content = "" .. params.s2c_content,
	    s2c_scope = _M.ChannelState.Channel_system,
	    s2c_name = "",
	    s2c_pro = 1,
	    s2c_level = 1,
	    s2c_acceptRoleId = "",
	    s2c_time = "",
	    s2c_sys = 1,
  	}
  	dealChatMsg(param)
end

function GlobalHooks.DynamicPushs.onChatPush(ex, json)
    
    
    if ex == nil then
        local param = json:ToData()
        if param ~= nil then
          if param.s2c_scope == _M.ChannelState.Channel_private then
              EventManager.Fire("Event.Social.newChatMsgPush", {data = param})
          else
        	    dealChatMsg(param)
          end
        end
    end
end

function GlobalHooks.DynamicPushs.onChatErrorPush(ex, json)
  
  
  	if ex == nil then
      	local param = json:ToData()
      	if(param ~= nil)then
        	GameAlertManager.Instance:ShowFloatingTips(param.s2c_msg)
      	end
  	end
end

function GlobalHooks.DynamicPushs.tipPush(ex, json)
  	
  	
  	if ex == nil then
      	local param = json:ToData()
      		if(param ~= nil)then
        	
	        if param.s2c_type == 0 then
	          	GameAlertManager.Instance:ShowFloatingTips(param.s2c_msg)
          elseif param.s2c_type == 1 then  
              GameAlertManager.Instance:ShowNotify(param.s2c_msg)
	        elseif param.s2c_type == 2 then
              
	          	GameAlertManager.Instance:ShowFloatingTipsMinor(param.s2c_msg)
	        elseif param.s2c_type == 3 then
	          	GameAlertManager.Instance:ShowNotify2nd(param.s2c_msg)
	        elseif param.s2c_type == 4 then
	          	GameAlertManager.Instance:ShowGoRoundTipsXml(param.s2c_msg, nil)
	        elseif param.s2c_type == 5 then  
	        	  _M.ShowNotifyLabel(param.s2c_msg)
           elseif param.s2c_type == 6 then  
              GameAlertManager.Instance:ShowGoRoundBottomTipsXml(param.s2c_msg, nil)
	        else
	          	GameAlertManager.Instance:ShowNotify(param.s2c_msg)
	        end
      	end
  	end
end

function GlobalHooks.DynamicPushs.receiveInteractPush(ex, json)
  	
  	
  	if ex == nil then
      	local param = json:ToData()
      	if(param ~= nil and param.show ~= nil )then
        	
        	GameUtil.ShowAssertBulider(param.show)
      	end
  	end
end

function _M.InitNetWork()
    Pomelo.GameSocket.onChatPush(GlobalHooks.DynamicPushs.onChatPush)
    Pomelo.GameSocket.onChatErrorPush(GlobalHooks.DynamicPushs.onChatErrorPush)
    Pomelo.GameSocket.tipPush(GlobalHooks.DynamicPushs.tipPush)
    Pomelo.GameSocket.receiveInteractPush(GlobalHooks.DynamicPushs.receiveInteractPush)
    
end

function _M.dealSysChatMsg(param)
    dealChatMsg(param)
end

return _M
