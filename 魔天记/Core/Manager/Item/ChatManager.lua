ChatManager = { }
-- 频道:世界,宗门,队伍,活动,私人
ChatChannel = { world = 1, school = 2, team = 3, active = 5, pirvate = 4, system = 6 }
-- 标签:系统,世界,宗门,队伍,招募,活动
ChatTag = { system = 1, world = 2, school = 3, team = 4, enlist = 5, active = 6 }
local ChatLevel = { 80, 0, 0, 80, 0 } --聊天等级限制
local _Insert = table.insert
local _Rmove = table.remove
ChatManager.UseVoice = GameConfig.UseVoice()
-- 标签对应的频道
function ChatManager.GetTagForChannel(c)
    local sn = ChatTag.world
    if c == ChatChannel.team then
        sn = ChatTag.team
    elseif c == ChatChannel.school then
        sn = ChatTag.school
    elseif c == ChatChannel.active then
        sn = ChatTag.active
    elseif c == ChatChannel.system then
        sn = ChatTag.system
    end
    return sn
end
-- 频道对应的标签
function ChatManager.GetChannelForTag(tag)

    local sn = ChatChannel.world
    if tag == ChatTag.team then
        sn = ChatChannel.team
    elseif tag == ChatTag.school then
        sn = ChatChannel.school
    elseif tag == ChatTag.system then
        sn = ChatChannel.system
    elseif tag == ChatTag.active then
        sn = ChatChannel.active
    elseif tag == ChatTag.enlist then
        sn = ChatChannel.team
    end

    return sn
end
-- 标签对应的sprite名字
function ChatManager.GetSpriteNameForTag(tag)
    local sn = "WorldFlg"
    if tag == ChatTag.team then
        sn = "teamFlg"
    elseif tag == ChatTag.school then
        sn = "zhongMenFlg"
    elseif tag == ChatTag.system then
        sn = "SystemFlg"
    elseif tag == ChatTag.active then
        sn = "huodongflg"
    elseif tag == ChatTag.enlist then
        sn = "zhangMuFlg"
    end
    return sn
end
ChatManager.CHAT_RECEIVE_DATA = "CHAT_RECEIVE_DATA"-- 接收消息

-- 聊天设置
ChatSettingData = {
    world = true,
    team = true,
    school = true,
    active = true,
    system = true
    ,
    worldSound = false,
    teamSound = true,
    schoolSound = true,
    activeSound = true,
    wifiSound = true
}
ChatManager.SettingDataKey = "mtj_Chat_SettingData"
ChatManager._SettingDataKeySplit = ","
function ChatManager._InitSettingData()
    -- Util.RemoveData(ChatManager.SettingDataKey)
    local settings = string.trim(Util.GetString(ChatManager.SettingDataKey))
    -- logTrace("settings=" .. tostring(settings) .. string.len(settings))
    if settings == nil or string.len(settings) < 1 then return end
    local arr = string.split(settings, ChatManager._SettingDataKeySplit)
    for k, v in pairs(ChatSettingData) do ChatSettingData[k] = false end
    for k, v in pairs(arr) do if ChatSettingData[v] ~= nil then ChatSettingData[v] = true end end
    -- for k,v in pairs(ChatSettingData) do logTrace(tostring(k) .. "____" .. tostring(v)) end
end
function ChatManager.SaveSettingData()
    local strs = { }
    for k, v in pairs(ChatSettingData) do if v then _Insert(strs, k) end end
    -- for k,v in pairs(ChatSettingData) do logTrace(tostring(k)  .. "_" ..  tostring(v)) end
    strs = table.concat(strs, ChatManager._SettingDataKeySplit)
    -- logTrace("strs=" .. tostring(strs))
    Util.SetString(ChatManager.SettingDataKey, strs)
end
ChatManager._InitSettingData()

ChatManager.MsgMaxNum =  50 --第个类型消息最多数量
ChatManager.MsgMaxUINum =  50 --消息显示最多数量
ChatManager.MsgMaxDataNum = 100 --时间内只处理有限的聊天数据,其他丢弃
ChatManager._Msgs = nil-- 聊天消息{world , team , school, active , system }
ChatManager._currentMyVoiceUrl = nil -- 当前我说的话远程路径
ChatManager._currentMyVoiceFilePath = nil -- 当前我说的话本地路径

function ChatManager.HandlerMsg()
    local len = #ChatManager.tempMsg
    if len < 1 then return end
    if len > ChatManager.MsgMaxDataNum then 
        local t = {}
        local ll = len - ChatManager.MsgMaxDataNum
        for i = 1, ChatManager.MsgMaxDataNum,1 do
            t[i] = ChatManager.tempMsg[ll + i]
        end
        ChatManager.tempMsg = t
    end
    --if len > 1 then len = 1 end
    --for i=1, len ,1 do
        local d = _Rmove(ChatManager.tempMsg, 1)
        MessageManager.Dispatch(ChatManager, ChatManager.CHAT_RECEIVE_DATA, d);
    --end
    --logTrace("HandlerMsg___" .. len .. "___" .. #ChatManager.tempMsg)
end
function ChatManager.Init()
    ChatManager._soundPlayTime = 0
    ChatManager._Msgs = { { }, { }, { }, { }, { }, { }, { } }
    ChatManager._msgTimer = Timer.New(ChatManager.HandlerMsg, 0.1, -1, true)
    ChatManager._msgTimer:Start()
    ChatManager.tempMsg = {}
    local socket = SocketClientLua.Get_ins()
    socket:RemoveDataPacketListener(CmdType.Chat_ReceiveMsg, ChatManager.ReceiveMsg);
    socket:AddDataPacketListener(CmdType.Chat_ReceiveMsg, ChatManager.ReceiveMsg);
end
function ChatManager.Clear()
    if ChatManager._msgTimer then
        ChatManager._msgTimer:Stop()
        ChatManager._msgTimer = nil
    end
    ChatManager.tempMsg = {}
    local socket = SocketClientLua.Get_ins()
    socket:RemoveDataPacketListener(CmdType.Chat_ReceiveMsg, ChatManager.ReceiveMsg);
end

-- 系统消息处理context内容tag标签前缀(ChatTag)
function ChatManager.SystemMsg(context, tag)
    if not channel then channel = ChatChannel.world end
    -- log("ChatManager.SystemMsg___" .. tostring( context) .. tostring( chanll).. tostring( chanll))
    local d = { }
    d.msg = context
    d.tag = tonumber(tag)
    d.date = GetTimeMillisecond()
    d.t = 1
    d.c = ChatManager.GetChannelForTag(d.tag)
    ChatManager._ReceiveMsg(d.c, d)
end

--[[s_id:发送者id
s_name:发送者name
k:职业
t:类型（1：文字2：语音）
c:channel渠道（1：世界2：门派3：队伍）
msg：（1：文字聊天信息 2： 语音翻译语音文字）
url：语音地址
time:语音消息时长（秒为单位）
date:发送时间（yyyy-MM-dd HH:mm:ss）--]]
function ChatManager.ReceiveMsg(cmd, data)
    --logTrace("ReceiveMsg___" .. data.s_id)
    if tonumber(data.s_id) < 0 then
        ChatManager.SystemMsg(data.msg,(- tonumber(data.s_id)))
        return
    end
    ChatManager._ReceiveMsg(data.c, data)
end
-- 查找消息是不是第二次转发
function ChatManager.VoiecHandler(msgs, data)
    if ChatManager.isFirstMsg(data) then return nil end
    for _, value in pairs(msgs) do
        if ChatManager.CheckSameMsg(value, data) then
            value.msg = data.msg
            return value
        end
    end
end
-- 是否同一个消息
function ChatManager.CheckSameMsg(data, data2)
    return data.url == data2.url
end
-- 第一次处理消息
function ChatManager.isFirstMsg(data)
    return data.t == 1 or string.len(data.msg) == 0
    -- 语音才分两次
end
function ChatManager._ReceiveMsg(channel, data)
    -- print("_ReceiveMsg start,t=" , Time.realtimeSinceStartup)
    if channel == ChatChannel.pirvate then return end
    -- 好友模块处理

    local msgs = ChatManager._Msgs[channel]
    local old = ChatManager.VoiecHandler(msgs, data)
    if old then
        _Insert(ChatManager.tempMsg, old)
        --MessageManager.Dispatch(ChatManager, ChatManager.CHAT_RECEIVE_DATA, old);
        return
    end
    _Insert(msgs, data)
    if #msgs >= ChatManager.MsgMaxNum then _Rmove(msgs, 1) end
    -- 最长消息限制
    -- 自动播放语音
    if data.t == 2 then
        -- print( data.url , ChatManager._currentMyVoiceUrl)
        if data.url == ChatManager._currentMyVoiceUrl then
            data.filePath = ChatManager._currentMyVoiceFilePath
            data.readed = true
        else
            -- 自己说的话不要播放
            local play = true
            if channel == ChatChannel.world and(not ChatSettingData.worldSound) then play = false end
            if play and channel == ChatChannel.team and(not ChatSettingData.teamSound) then play = false end
            if play and channel == ChatChannel.school and(not ChatSettingData.schoolSound) then play = false end
            if play and channel == ChatChannel.active and(not ChatSettingData.activeSound) then play = false end
            if play and channel == ChatChannel.pirvate then play = false end
            if play and ChatSettingData.wifiSound and(not Util.IsWifi) then play = false end
            if play then
                ChatManager.VoicePlay(data.filePath, data.url)
                data.readed = true
            end
        end
    end
    if not data.tag then data.tag = ChatManager.GetTagForChannel(data.c) end
   
    _Insert(ChatManager.tempMsg, data)
    --MessageManager.Dispatch(ChatManager, ChatManager.CHAT_RECEIVE_DATA, data);
end

function ChatManager.GetMsg(channel)
    return ChatManager._Msgs[channel]
end
function ChatManager.GetMsgsForSet()
    local cs = { }
    for k, v in pairs(ChatChannel) do
        if ChatSettingData[k] then _Insert(cs, v) end
    end
    return ChatManager.GetMsgs(cs)
end
function ChatManager.GetMsgsAll()
    local cs = { }
    for k, v in pairs(ChatChannel) do
        if v ~= ChatChannel.pirvate then _Insert(cs, v) end
    end
    return ChatManager.GetMsgs(cs)
end

local _sortfunc = table.sort

function ChatManager.GetMsgs(channels)
    local msgss = { }
    for k, v in pairs(channels) do
        -- logTrace("ChatManager.GetMsgs:c=" .. type(v) .. v)
        local msgs = ChatManager._Msgs[v]
        table.AddRange(msgss, msgs)
    end
    _sortfunc(msgss, function(a, b) return a.date < b.date end)
    return msgss
end

--[[
r_id:receive_id 接受者ID
t:类型（1：文字2：语音）
msg：（1：文字聊天信息 2： 语音翻译语音文字）
url：语音地址
time:语音消息时长（秒为单位）--]]
function ChatManager.SendMsg(channel, text, pid)
    if ChatLevel[channel] > PlayerManager.GetPlayerLevel() then
        MsgUtils.ShowTips(nil,nil,nil,ChatManager.GetNoLevelMsg(channel));
        return false
    end
    ChatManager._currentPid = pid
    ChatManager._SendMsg(1, channel, text)
    return true
end
function ChatManager.SendVoice(channel, text, filePath, url, time)
    -- print("SendVoice,t=" , channel, text, filePath, url, time)
    -- print("SendVoice start,t=" , Time.realtimeSinceStartup)
    ChatManager._currentMyVoiceUrl = url
    ChatManager._currentMyVoiceFilePath = filePath
    ChatManager._SendMsg(2, channel, text, url, time)
end
function ChatManager._SendMsg(t, channel, text, url, time)
    local data = { t = t, msg = text, url = url, time = time }
    local cmd = CmdType.Chat_SendWorld
    if channel == ChatChannel.school then
        cmd = CmdType.Chat_SendSchool
    elseif channel == ChatChannel.team then
        cmd = CmdType.Chat_SendTeam
    elseif channel == ChatChannel.pirvate then
        cmd = CmdType.Chat_SendPrivate
        data.r_id = ChatManager._currentPid
    elseif channel == ChatChannel.active then
        cmd = CmdType.Chat_SendActive
    end
    -- logTrace("SendMsg:t=".. t ..",chl=".. channel..",text=".. text..",url="..tostring(url)..",time=".. tostring(time))
    SocketClientLua.Get_ins():SendMessage(cmd, data)
end

ChatManager.VoiceAppId = 1000386-- 语音平台分配的appid
ChatManager.VoiceMaxLen = 30-- 录音最长时间(秒 不能过60秒(平台限定
ChatManager._currentChannel = nil
-- 初始化语音
function ChatManager.InitVoice()
    -- logTrace("RecordInit")
    if not ChatManager.UseVoice then return end
    VoiceInterface.Init(ChatManager.VoiceAppId, false, 0);
    -- 0/1/2/3
end
-- 登录语音
function ChatManager.VoiceLogin()
    if not ChatManager.UseVoice then return end
    local channels = { }
    for i, v in pairs(ChatChannel) do _Insert(channels, i) end
    local channels = table.concat(channels, ",");
    -- logTrace("RecordLogin:pid=" .. PlayerManager.playerId .. ",sid=" .. LoginProxy.currentServerIndex .. ",channels=" .. channels)
    VoiceInterface.Login(PlayerManager.playerId, PlayerManager.playerId
    , LoginProxy.currentServerIndex, channels, ChatManager.VoiceMaxLen + 10)
    VoiceInterface.OnRecordVolume = ChatManager._VoiceRecordVolume
end
-- 退出登录
function ChatManager.VoiceLogout()
    -- logTrace("RecordLogout")
    if not ChatManager.UseVoice then return end
    VoiceInterface.Logout()
end
function ChatManager.GetNoLevelMsg(channel)
    return ChatLevel[channel] .. LanguageMgr.Get("ChatManager/noLevel")
end
-- 开始录音,channel频道ChatChannel, pid 私聊玩家id
function ChatManager.VoiceRecordStart(channel, pid)
    -- logTrace("RecordStart:channel=" .. channel)
    if not ChatManager.UseVoice then return end
    if ChatLevel[channel] > PlayerManager.GetPlayerLevel() then
        MsgUtils.ShowTips(nil,nil,nil,ChatManager.GetNoLevelMsg(channel));
        return false
    end

    if channel == ChatChannel.team then
        if not ChatManager.CanSpeakTeam() then
            MsgUtils.ShowTips("ChatManager/noTeam");
            return false
        end
    end
    if channel == ChatChannel.school then
        if not ChatManager.CanSpeakSchool() then
            MsgUtils.ShowTips("ChatManager/noSchool");
            return false
        end
    end
    ChatManager._currentChannel = channel
    ChatManager._currentPid = pid
    VoiceInterface.RecordStart()
    ChatManager.PauseSound(true)
    return true
end
-- 结束录音,回调返回翻译文本text,本地filePath,远程url,time(秒
function ChatManager.VoiceRecordStop(cancel)
    -- print("VoiceRecordStop start,t=", Time.realtimeSinceStartup)
    -- logTrace("RecordStop,cancel=" .. tostring(cancel))
    -- VoiceInterface.RecordStop(cancel, function(text, filePath, url, time)
    -- logTrace("RecordStop:text=" .. text .. ",filePath=" .. filePath .. ",url=" .. url .. ",time=" .. time)
    -- print("VoiceRecordStop end,t=" , Time.realtimeSinceStartup)
    --    ChatManager.SendVoice(ChatManager._currentChannel, string.trim(text), filePath, url, time)
    -- end )
    if not ChatManager.UseVoice then return end
    -- 因为语音翻译慢,语音分两次转发,第一次是语音信息,第二次是翻译文本
    if not cancel then
        local cc = ChatManager._currentChannel
        VoiceInterface.OnStopRecord = function(filePath, time)
            if time < 1 then return end
            VoiceInterface.OnUploadRecord = function(url)
                -- print(filePath, time, url)
                if url == nil then return end
                ChatManager.SendVoice(cc, nil, filePath, url, time)
                VoiceInterface.OnTranslateRecord = function(text, url2)
                    -- print(text, url2)
                    if text == nil then return end
                    ChatManager.SendVoice(cc, text, nil, url, time)
                end
                -- url用于第二次转发后定位到第一次的消息体
                VoiceInterface.RecordTranslate("", url, 2)
            end
            VoiceInterface.RecordUpload(filePath)
        end
    end
    VoiceInterface.RecordStop()
    ChatManager.PauseSound(false)
end
-- 播放语音文件,本地filePath,远程url
function ChatManager.VoicePlay(filePath, url)
    -- logTrace("PlayRecord:filePath=" .. filePath .. ",url=" .. url)
    if not ChatManager.UseVoice then return end
    ChatManager._soundPlayTime = ChatManager._soundPlayTime + 1
    ChatManager.PauseSound(true)
    local _soundPlayTime = ChatManager._soundPlayTime
    VoiceInterface.PlayRecord(filePath and filePath or "", url, function()
        if _soundPlayTime == ChatManager._soundPlayTime then ChatManager.PauseSound(false) end
    end )
end
function ChatManager._EndVoicePlay(time)
    ChatManager.PauseSound(false)
end

-- 停止播放语音
function ChatManager.VoiceStop()
    -- logTrace("StopRecord")
    if not ChatManager.UseVoice then return end
    VoiceInterface.StopRecord()
    ChatManager.PauseSound(false)
end
-- 音量变化回调
function ChatManager._VoiceRecordVolume(val)
    -- logTrace("OnRecordVolume:val=" .. val)
    ModuleManager.SendNotification(ChatNotes.VOICE_CHANGE_VALUE, val / 26 + 1)
end
-- 打开关闭游戏声音
function ChatManager.PauseSound(val)
    SoundManager.instance:Puase(val)
end

function ChatManager.CanSpeak(channel)
    if channel == ChatChannel.world then return ChatManager.CanSpeakWorld() end
    if channel == ChatChannel.active then return ChatManager.CanSpeakActive() end
    if channel == ChatChannel.team then return ChatManager.CanSpeakTeam() end
    if channel == ChatChannel.school then return ChatManager.CanSpeakSchool() end
    if channel == ChatChannel.system then return false end
end
function ChatManager.CanSpeakSchool()
    return GuildDataManager.InGuild()
    -- return math.random(0, 1) == 0
end
function ChatManager.CanSpeakTeam()
    -- logTrace("CanSpeakTeam:" .. tostring(PartData.GetMyTeam() ~= nil))
    return PartData.GetMyTeam() ~= nil
end
function ChatManager.CanSpeakActive()
    if( GameSceneManager.map) then
       return GameSceneManager.map.info.is_talk
    end
    return false
end
function ChatManager.CanSpeakWorld()
    return PlayerManager.GetPlayerLevel() >= ChatLevel[ChatChannel.world]
end
function ChatManager.IsPlayerMsg(data)
    return data.s_id and tonumber(data.s_id) > 0
end
function ChatManager.GetPlayerInfo(id, cbFunc)
    ChatManager.cbFunc = cbFunc
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetSimplePlayerInfo, ChatManager._GetPlayerInfo);
    SocketClientLua.Get_ins():SendMessage(CmdType.GetSimplePlayerInfo, { id = id });
end
function ChatManager._GetPlayerInfo(cmd, data)
    if not ChatManager.cbFunc then return end
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetSimplePlayerInfo, ChatManager._GetPlayerInfo)
    ChatManager.cbFunc(data)
    ChatManager.cbFunc = nil
end