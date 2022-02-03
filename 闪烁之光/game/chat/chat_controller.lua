--[[
    * 类注释写在这里-----------------
    * @author {cloud}
    * <br/>Create: 2016-12-23
]]
ChatController = ChatController or BaseClass(BaseController)

function ChatController:config()
    self.pro_12766 = true --12766协议只处理一次
    self.voiceCache = {}  --语音消息缓存列表

    self.model = ChatModel.New(self)
    self.dispather = GlobalEvent:getInstance()

    if self.login_event_success == nil then
        self.login_event_success = self.dispather:Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.login_event_success)
            self.login_event_success = nil
            self:initData()
        end)
    end
    -- --发送语音信息
    -- self.send_voice_evt = self.dispather:Bind(EventId.CHAT_SEND_VOICE, function(name, time, channel, taken_obj)
    --     self:voiceTranslate(name, time, channel, taken_obj)
    -- end)
    -- --发送图文信息
    -- self.send_msges_evt = self.dispather:Bind(EventId.CHAT_SEND_MSGES, function(msg, channel, taken_obj)
    --     self:sendMessage(msg, channel, taken_obj)
    -- end)
    -- --自定义聊天数据
    -- self.custom_msg_evt = self.dispather:Bind(EventId.CHAT_CUSTOM_MSG, function(msg, channel)
    --     self:showMyMsg(msg, channel)
    -- end)
    -- --语音上传状态变化
    -- self.voice_upload_evt = self.dispather:Bind(EventId.ON_VOICE_UPLOAD_RESULT, function(data)
    --     isSuccess, filename = unpack(data)
    --     self:checkSendVoiceMsg(isSuccess, filename)
    -- end)

    -- if not self.close_other_event then
    --     self.recommend_event = self.dispather:Bind(FriendContants.CLOSE_OTHER,function()
    --         self:closePrivate()
    --     end)
    -- end
    self.tar_cur_open_type = nil
end

function ChatController:getModel()
    return self.model
end

function ChatController:registerEvents()
    --[[if not self.update_drama_data_event then
        self.update_drama_data_event = GlobalEvent:getInstance():Bind(SceneEvent.ENTER_FIGHT,function (combat_type)
            if combat_type == BattleConst.Fight_Type.Darma then -- 进入剧情副本战斗触发剧情频道显示
                self:checkShowDramaMsg()
            end
        end)
    end--]]
end

-- 聊天数据
function ChatController:initChatMsgData(  )
    --频道;1:世界;2:场景;4:帮派;8;队伍;16:传闻;32:顶部传闻;64:系统;128:顶部系统
    self.stack_list =
    {
        [ChatConst.Channel.Multi]  = Array.New(),
        [ChatConst.Channel.Whole]  = Array.New(),
        [ChatConst.Channel.World]  = Array.New(),
        [ChatConst.Channel.Gang]   = Array.New(),
        [ChatConst.Channel.Friend] = Array.New(),
        [ChatConst.Channel.Notice]  = Array.New(), --++
        [ChatConst.Channel.Cross]  = Array.New(),
        [ChatConst.Channel.Scene]  = Array.New(),
        [ChatConst.Channel.Team]  = Array.New(),
        [ChatConst.Channel.Drama]  = Array.New(),
        [ChatConst.Channel.Province]  = Array.New(),
    }
    -- 未读数量
    self.cache_msg_list = {}
end

--初始化数据
function ChatController:initData()
    --聊天数据
    self:initChatMsgData()
    self.stack_id = 0
    --频道显示条目限制
    self.stack_limit =
    {
        [ChatConst.Channel.Multi]  = 40,
        [ChatConst.Channel.Whole]  = 80,
        [ChatConst.Channel.World]  = 30,
        [ChatConst.Channel.Gang]   = 30,
        [ChatConst.Channel.Friend] = 30,
        [ChatConst.Channel.Cross]  = 40,
        [ChatConst.Channel.Notice] = 16, --++
        [ChatConst.Channel.Scene] = 30, --++
        [ChatConst.Channel.Team] = 30, --++
        [ChatConst.Channel.Drama]  = 30,
        [ChatConst.Channel.Province]  = 30,
    }

    --默认提示文字
    local sys_msg = {}
    sys_msg.len = 0
    sys_msg.channel = ChatConst.Channel.System
    sys_msg.role_list = {}
    sys_msg.msg = string.format("欢迎来到%s~", GAME_NAME)
    sys_msg.flag = 1
    self:handle12761(sys_msg)
    self.is_first = true

    --系统定时内容
    local time = 10*60 
    self.sys_index = 1
    self.sys_total = #Config.LoadingDescData.data_desc
    self.sys_ticket = GlobalTimeTicket:getInstance():add(function()
        local sys_msg = {}
        sys_msg.len = 0
        sys_msg.channel = ChatConst.Channel.System
        sys_msg.role_list = {}
        sys_msg.msg = Config.LoadingDescData.data_desc[self.sys_index]
        self:handle12761(sys_msg)
        self.sys_index = self.sys_index + 1
        if self.sys_index > self.sys_total then
            self.sys_index = 1
        end
    end,time)
end

---------------------------------------------
--注册协议
function ChatController:registerProtocals()
    --聊天相关协议
    self:RegisterProtocal(12720, "handle12720")  --私聊
    self:RegisterProtocal(12721, "handle12721")  --推送私聊消息
    self:RegisterProtocal(12722, "handle12722")  --登录推送私聊数据
    self:RegisterProtocal(12725, "handle12725")  --发送语音信息
    self:RegisterProtocal(12726, "handle12726")  --下载语音信息
    self:RegisterProtocal(12741, "handle12741")  --提示
    self:RegisterProtocal(12743, "handle12743")  --系统提示&聊天提示
    self:RegisterProtocal(12799, "hander12799")  --消息发送

    --新聊天协议
    self:RegisterProtocal(12761, "handle12761")  --接收通用聊天
    self:RegisterProtocal(12762, "handle12762")  --发送通用聊天
    self:RegisterProtocal(12763, "handle12763")  --服务端分发翻译
    self:RegisterProtocal(12766, "handle12766")  --登录聊天记录

    --聊天艾特功能
    self:RegisterProtocal(12767, "handle12767")  --聊天艾特功能
    self:RegisterProtocal(12768, "handle12768")  --已查看艾特信息

    -- 清除某玩家聊天记录
    self:RegisterProtocal(12704, "handle12704")
end

-- 对对象发起私聊
function ChatController:sender12720(to_srv_id, to_rid, len, msg)
    local protocal = {}
    protocal.to_srv_id = to_srv_id
    protocal.to_rid = to_rid
    protocal.len = len
    protocal.msg = msg
    self:SendProtocal(12720,protocal)
end

-- 发起私聊失败提示
function ChatController:handle12720(data)
    if data.code == 0 then message2(data.msg) end
end

-- 保存私聊的信息
function ChatController:handle12721(data)
    data.msg = WordCensor:getInstance():relapceFaceIconTag(data.msg)[2]
    local srv_id_other = data.srv_id
    local rid_other = data.rid
    local roleVo = RoleController:getInstance():getRoleVo()
    if not roleVo then return end
    if FriendController:getInstance():getModel():isBlack(rid_other, srv_id_other) then return end
    data.talk_time = data.tick
    if data.flag == 11 or data.flag == 1 then --我对对方说
        data.other_rid = data.rid
        data.other_srv_id = data.srv_id
        data.other_name = data.name
        data.other_lev = data.lev
        data.other_face_id = data.face_id
        data.other_face_file = data.face_file
        data.other_face_update_time = data.face_update_time

        data.rid    = roleVo.rid
        data.srv_id = roleVo.srv_id
        data.name   = roleVo.name
        data.career = roleVo.career
        data.sex    = roleVo.sex
        data.face_id = roleVo.face_id
        data.face_file = roleVo.face_file
        data.face_update_time = roleVo.face_update_time
    elseif data.flag == 2 then --对方对我说
        data.rid    = data.rid
        data.srv_id = data.srv_id
        data.name   = data.name
        data.career = data.career
        data.sex    = data.sex
        data.face_id = data.face_id
        data.face_file = data.face_file
        data.face_update_time = data.face_update_time

        data.other_rid = roleVo.rid
        data.other_srv_id = roleVo.srv_id
        data.other_name = roleVo.name
        data.other_lev = roleVo.lev
        data.other_face_id = roleVo.face_id
        data.other_face_file = roleVo.face_file
        data.other_face_update_time = roleVo.face_update_time

        self.model:setRedList(data.srv_id,data.rid,1)
    end

    self.model:saveTalkTime(srv_id_other,rid_other)
    data.channel = ChatConst.Channel.Friend
    local chatVo = self.model:pushPrivateMsg(data, srv_id_other,rid_other, data.talk_time)
    self.model:writeFriendMsg(roleVo.srv_id, roleVo.rid, srv_id_other,rid_other,data.talk_time)

    self.model:addContactList(srv_id_other,rid_other)
    self.model:writeContactList()

    if data.flag == 2 then
        local vo = ChatVo.New()
        vo:setObjectAttr(data)
        vo:setMessageAttr(data)
        vo.id = self:getUniqueId()
        vo.channel  = ChatConst.Channel.Friend
        self:saveChatMsg(vo, ChatConst.Channel.Whole) --综合频道
    end

    GlobalEvent:getInstance():Fire(EventId.CHAT_UPDATE_SELF, chatVo)
    GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_GROUP_COUNT)

     -- 玩家世界聊天和公会聊天看看需要不需要缓存起来
    if self.cur_channel ~= ChatConst.Channel.Friend or self:isChatOpen() == false then
        self:accumulateChannelNum(ChatConst.Channel.Friend)
    end
end

-- 登录推送私聊离线消息
function ChatController:handle12722(data_list)
    --Debug.info(data_list)
    if not self.read_list then self.read_list = {} end --标记未读信息
    local roleVo = RoleController:getInstance():getRoleVo()
    if not roleVo then return end
    local time = GameNet:getInstance():getTime()
    GlobalTimeTicket:getInstance():add(function()
        local group_id
        local temp = {}
        for k, v in pairs(data_list.offline_list) do
            if not FriendController:getInstance():getModel():isBlack(v.rid, v.srv_id) then
                group_id = v.rid.."_"..v.srv_id
                if not self.read_list[group_id] then
                    self.read_list[group_id] = {v.rid, v.srv_id}
                end
                for i=1, #(v.msg_list) do
                    local vo = {}
                    vo.rid = v.rid
                    vo.srv_id = v.srv_id
                    vo.name = v.name
                    vo.lev = v.lev
                    vo.career = v.career
                    vo.face_id = v.face_id
                    vo.face_file = v.face_file
                    vo.face_update_time = v.face_update_time

                    vo.sex = v.sex
                    vo.vip_lev = v.vip_lev
                    vo.len = v.msg_list[i].len
                    vo.msg = WordCensor:getInstance():relapceFaceIconTag(v.msg_list[i].msg)[2]
                    vo.flag = 2 --标记是别人的信息
                    vo.talk_time = v.msg_list[i].tick
                    vo.other_rid = roleVo.rid
                    vo.other_srv_id = roleVo.srv_id
                    vo.other_name = roleVo.name
                    vo.other_lev = roleVo.lev
                    vo.other_face_id = roleVo.face_id
                    vo.other_face_file = roleVo.face_file
                    vo.other_face_update_time = roleVo.face_update_time

                    table.insert(temp, vo)
                end
            end
        end

        for k,v in pairs(temp) do
            -- 缓存到本地数据
            self.model:saveTalkTime(v.srv_id,v.rid,v.talk_time)
            local chatVo = self.model:pushPrivateMsg(v,v.srv_id,v.rid, v.talk_time)
            --保存最近联系人
            self.model:addContactList(v.srv_id,v.rid)
            self.model:writeContactList()

            self.model:writeFriendMsg(roleVo.srv_id, roleVo.rid, v.srv_id,v.rid,v.talk_time)
            self.model:setRedList(v.srv_id,v.rid,1)
            GlobalEvent:getInstance():Fire(EventId.CHAT_UPDATE_SELF, chatVo)
        end
        temp = nil
    end,2,1)
end

--提示信息
function ChatController:handle12741(data)
    showAssetsMsg(data.msg)
end

--提示信息(并且在聊天框显示)
function ChatController:handle12743(data)
    message(data.msg)
    local sys_msg = {}
    sys_msg.len = 0
    sys_msg.channel = ChatConst.Channel.System
    sys_msg.role_list = {}
    sys_msg.msg = data.msg
    self:handle12761(sys_msg, true)
end

--消息发送
function ChatController:hander12799(data_list)
    if not self.alert_msg then
        self.alert_msg = ""
        GlobalTimeTicket:getInstance():add(function()
             ErrorMessage.show(self.alert_msg)
             self.alert_msg = nil
        end, 1, 1)
    end
    self.alert_msg = string.format("%s%s\n", self.alert_msg, data_list.msg)
end

--通知服务端已阅读私聊离线数据
function ChatController:noticeReader(srv_id,rid)

    if self.read_list==nil or srv_id==nil or rid==nil then
        return
    end
    local group_id = rid.."_"..srv_id
    if self.read_list[group_id] then
        self.read_list[group_id] = nil
        local protocal = {}--ProtocalRulesMgr:getInstance():GetPrototype(12723)
        protocal.rid = rid
        protocal.srv_id = srv_id
        self:SendProtocal(12723,protocal)
    end
end

--语音翻译文字
function ChatController:voiceTranslate(name, time, channel, taken_obj)
    local msg = name.."@"..time
    self:sendVoiceMsg(msg, channel, taken_obj)
    callSpeechRecognizeDo(name, function(str)
        VoiceMgr:getInstance():setMsg(msg, str)
        local protocal ={}-- ProtocalRulesMgr:getInstance():GetPrototype(12764)
        protocal.channel = channel
        protocal.id = msg
        protocal.msg = str
        self:SendProtocal(12764,protocal)
    end)
end

--发送语音消息， channel见ChatConst.Channel
function ChatController:sendVoiceMsg(msg, channel, taken_obj)
    if ChatConst.Channel.Friend == channel then
        if taken_obj then
            self:sender12720(taken_obj.srv_id, taken_obj.rid, 1, msg)
        end
    else
        self:sendChatMsg(channel, 1, msg)
    end
end
--发送文字信息，channel见ChatConst.Channel
function ChatController:sendMessage(msg, channel, taken_obj, len)
    len = len or 0
    if channel == 0 then channel = 1 end
    if ChatConst.Channel.Friend == channel then   --if channel == 1 then
        --好友频道
        if self.tar_chat_data then
            self:sender12720(self.tar_chat_data.srv_id, self.tar_chat_data.rid, len, msg)
        end
    else
        self:sendChatMsg(channel, len, msg)
    end
end

--显示自定义聊天信息
function ChatController:showMyMsg(msg, channel)

end

--发送聊天数据
function ChatController:sendChatMsg(channel, len, msg)
    if len > 0 or ChatMgr:getInstance():canSpeak(channel) then
        self:sendMsgToServer(channel, len, msg)
        return true
    end
    return false
end

--向服务器发送聊天数据
function ChatController:sendMsgToServer(channel, len, msg)
    local protocal = {}
    protocal.channel = channel
    protocal.len = len 
    protocal.msg = msg
    local roleVo = RoleController:getInstance():getRoleVo()
    protocal.sign = cc.CCGameLib:getInstance():md5str(table.concat({roleVo.rid, roleVo.srv_id, channel, len, msg, '____'}, ''))
    self:SendProtocal(12762, protocal)
    ChatMgr:getInstance():setSpeakTime(channel)
end

--发送信息返回
function ChatController:handle12762(data)
    if data.code == 0 then
        message(data.msg)
    end
end

--保存下要艾特的人
function ChatController:saveAtData( data )
    self.at_data = data
end

function ChatController:getAtData(  )
    return self.at_data
end

-- 服务端分发翻译
function ChatController:handle12763(data)
    VoiceMgr:getInstance():setMsg(data.id, data.msg)
end

-- 保存聊天数据
function ChatController:saveChatMsg(data, channel)
    if self.stack_list==nil or self.stack_list[channel]==nil then
        -- print("频道不存在..."..channel)
        return
    end
    if self.stack_list[channel]:GetSize() >= self.stack_limit[channel] then
        self.stack_list[channel]:PopFront()
    end
    self.stack_list[channel]:PushBack(data)
end

-- 清空聊天记录
function ChatController:clearChatLog(channel)
    if self.stack_list and self.stack_list[channel] then
       self.stack_list[channel] = nil
       self.stack_list[channel] = Array.New()
    end
end

-- 获取聊天数据
function ChatController:getChannelData(channel)
    return self.stack_list[channel] or Array.New()
end

function ChatController:handle12704( data )
    self:deleteChatDataByRidAndSrvid(data.rid, data.srv_id)
end

-- 根据角色id、服务器id删除该角色聊天数据
function ChatController:deleteChatDataByRidAndSrvid( rid, srv_id )
    if not rid or not srv_id or self.stack_list == nil then return end
    for channel,list in pairs(self.stack_list) do
        for i=list:GetSize()-1,0,-1 do
            local v = list:Get(i)
            if srv_id == v.srv_id and rid == v.rid then
                list:Erase(i)
            end
        end
    end
end

-- 聊天记录唯一ID
function ChatController:getUniqueId()
    -- return GameNet:getInstance():getTime()
    if not self.stack_id then self.stack_id = 0 end
    self.stack_id = self.stack_id + 1
    return self.stack_id
end

--接收聊天数据
--@is_login_content 登陆 是登陆的的聊天内容
function ChatController:handle12761(data, bool, is_login_content)
    local channel = data.channel
    local channel_tmp = 1
    -- 解析表情标记

    if self.pro_12766 and self.is_first==false then
        self.pro_12766 = nil
    end

    self.is_first = false

    data.msg = WordCensor:getInstance():relapceFaceIconTag(data.msg)[2]
    data.msg = WordCensor:getInstance():relapceAssetsTag(data.msg)
    for i = 1, 16 do
        if math.floor(channel / 2) * 2 ~= channel then
            data.channel = channel_tmp
            self:handle12761__(data, bool, is_login_content)
        end
        channel_tmp = channel_tmp * 2
        channel = math.floor(channel / 2)
        if channel < 1 then return end
    end
end

function ChatController:handle12761__(data, bool, is_login_content)
    local channel = data.channel
    --滚动传闻
    if channel == ChatConst.Channel.NoticeTop then
        local message = WordCensor:getInstance():relapceAssetsTag(string.format("<div fontsize=17>%s</div>", data.msg))
        GlobalMessageMgr:getInstance():showMoveHorizontal(message, Config.ColorData.data_color3[1])
        return
    end
    --滚动系统
    if channel == ChatConst.Channel.SystemTop then
        local message = string.format("<div fontsize=17>%s</div>", data.msg)
        GlobalMessageMgr:getInstance():showMoveHorizontal(message, Config.ColorData.data_color3[1]) 
        return
    end
    -- 跨服、同省消息（未达到开启等级时也会收到）
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    if channel == ChatConst.Channel.Cross then
        local cross_config = Config.MiscData.data_const["cross_level"]
        if role_vo.lev < cross_config.val then
            return
        end
    elseif channel == ChatConst.Channel.Province then
        local province_config = Config.MiscData.data_const["province_level"]
        if role_vo.lev < province_config.val then
            return
        end
    end

    -- 系统频道消息（资产消耗）
    if channel == ChatConst.Channel.System then
        self:pushAssetsMsg(data.msg)
        return
    end

    local vo = ChatModel.clone(data, channel)
    vo.id = self:getUniqueId()
    if not FriendController:getInstance():getModel():isBlack(vo.rid, vo.srv_id) then
        if vo.flag~="openGang" and vo.flag~="openTeam" then
            if channel~=ChatConst.Channel.Gang and channel~=ChatConst.Channel.Team and channel~=ChatConst.Channel.Cross and channel~=ChatConst.Channel.Gang_Sys and channel~=ChatConst.Channel.Team_Sys and channel~=ChatConst.Channel.Scene and channel~=ChatConst.Channel.Notice and channel~=ChatConst.Channel.System and channel~=ChatConst.Channel.Province then
                self:saveChatMsg(vo, ChatConst.Channel.Multi)
            end
            self:saveChatMsg(vo, ChatConst.Channel.Whole) --综合频道
        end
        if bool == nil then
            if channel == ChatConst.Channel.Gang_Sys then
                self:saveChatMsg(vo, ChatConst.Channel.Gang)
            elseif channel == ChatConst.Channel.Team_Sys then
                vo.rid = 0
                self:saveChatMsg(vo, ChatConst.Channel.Team)
            else
                self:saveChatMsg(vo, channel)
            end
            
            local is_myself = false
            if vo.rid and vo.rid ~=0 and vo.srv_id then 
                if role_vo.rid == vo.rid and role_vo.srv_id == vo.srv_id then 
                    is_myself = true
                end
            end

            -- 玩家世界聊天和公会聊天看看需要不需要缓存起来
            if is_myself == false then
                if channel == ChatConst.Channel.World and (self.cur_channel ~= ChatConst.Channel.World or self:isChatOpen() == false) then
                    self:accumulateChannelNum(ChatConst.Channel.World)
                elseif channel == ChatConst.Channel.Gang and (self.cur_channel ~= ChatConst.Channel.Gang or self:isChatOpen() == false) then
                    self:accumulateChannelNum(ChatConst.Channel.Gang)
                elseif channel == ChatConst.Channel.Cross and (self.cur_channel ~= ChatConst.Channel.Cross or self:isChatOpen() == false) then
                    self:accumulateChannelNum(ChatConst.Channel.Cross)
                elseif channel == ChatConst.Channel.Province and (self.cur_channel ~= ChatConst.Channel.Province or self:isChatOpen() == false) then
                    self:accumulateChannelNum(ChatConst.Channel.Province)
                end
            end
        end
    end

    -- 判读是否为自己发的
    local is_self = false
    if role_vo and role_vo.rid == vo.rid and role_vo.srv_id == vo.srv_id then
        is_self = true
    end
    if not FriendController:getInstance():getModel():isBlack(vo.rid, vo.srv_id) or
       channel == ChatConst.Channel.Team_Sys then --组队聊天也要此事件
        GlobalEvent:getInstance():Fire(EventId.CHAT_UDMSG_WORLD, channel, is_self, is_login_content)
    end
    --记录自动播放的语音
    if data.len==1 and data.role_list and #data.role_list>0 then
        local roleObj = data.role_list[1]
        local keyStr = roleObj.srv_id .. "_" .. roleObj.rid
        if role_vo and keyStr ~= role_vo:getRoleSrid() then
            VoiceMgr:getInstance():insertVoice(data.msg, channel)
        end
    end
end

-- 资产提示信息
function ChatController:pushAssetsMsg(text)
    if text == "" then return end
    local chat_vo = ChatVo.New()
    chat_vo.channel = ChatConst.Channel.System
    chat_vo.msg = text
    chat_vo.id = self:getUniqueId()
    chat_vo.msg = WordCensor:getInstance():relapceAssetsTag(chat_vo.msg)
    self:saveChatMsg(chat_vo, ChatConst.Channel.Notice)
    GlobalEvent:getInstance():Fire(EventId.CHAT_UDMSG_ASSETS)
end

--登录上线最近的几条聊天消息
function ChatController:handle12766(data)
    if self.pro_12766 then
        self.pro_12766 = nil
        for i=1, #data.msg_list do
            self:handle12761(data.msg_list[i], nil, true)
        end
        self.pro_12766 = true
    end
end

-- 获取聊天引用频道
function ChatController:getRefChannel(from)
    if self.chat_ui and self.chat_ui:isOpen() then
        channel =  self.chat_ui.channel
    end
    if channel == nil or channel == -1 then
        channel = 1
    end
    return channel
end

-- 获取聊天输入框文本内容
function ChatController:getTextInputFace()
    local text
    if self.chat_ui and self.chat_ui:isOpen() then
        text = self.chat_ui:getEditText()
    end
    if text then
        return WordCensor:getInstance():relapceFaceIconTag(text)[1]
    end
    return 0
end

-- 表情宽高读
function ChatController:getFaceSpineSize(face_id)
    if not self.face_info then self.face_info = {} end
    if self.face_info[face_id] then
        return self.face_info[face_id]
    else
        for k, v in pairs(Config.FaceData.data_biaoqing) do
            if v.file == face_id then
                self.face_info[face_id] = {v.width, v.heigh}
                return self.face_info[face_id]
            end
        end
    end
    return {42, 30}
end

-- 发送语音信息
function ChatController:sender12725(name, voice, time)
    local protocal ={} --ProtocalRulesMgr:getInstance():GetPrototype(12725)
    protocal.voice = voice
    protocal.voice_len = string.len(voice)
    protocal.time = time
    protocal.type = AUDIO_RECORD_TYPE
    self:SendProtocal(12725,protocal)
    self.uploading = name
    GlobalTimeTicket:getInstance():add(function()
        self:uploadVoiceFail(1)
    end, 5, 1, "chat_voice_upload_fail")
end

-- 语音上传结果
function ChatController:handle12725(data)
    if not self.uploading then return end
    if data.flag == 1 then
        GlobalTimeTicket:getInstance():remove("chat_voice_upload_fail")
        local cache = self.voiceCache[self.uploading]
        if cache then
            local key = data.srv_id.."-"..data.voice_id
            local file = ChatHelp.formatFileName(key)
            self:voiceTranslate(key, cache.time, cache.channel, cache.take)
            cc.FileUtils:getInstance():renameFile(PathTool.getVoicePath(""), ChatHelp.formatFileName(AUDIO_RECORD_FILE), file)
            VoiceMgr:getInstance():addCacheVoiceFile(key, file, cache.time)
        else
            message(TI18N("录音失败"))
        end
        self.voiceCache[self.uploading] = nil
        self.uploading = nil
    else
        self:uploadVoiceFail(2)
    end
end

-- 上传语音失败
function ChatController:uploadVoiceFail(code)
    GlobalTimeTicket:getInstance():remove("chat_voice_upload_fail")
    cc.FileUtils:getInstance():removeFile(PathTool.getVoicePath(self.uploading))
    self.voiceCache[self.uploading] = nil
    self.uploading = nil
end

-- 请求下载语音文件
function ChatController:sender12726(srv_id, id)
    local protocal = {}--ProtocalRulesMgr:getInstance():GetPrototype(12726)
    protocal.srv_id = srv_id
    protocal.voice_id = id
    self:SendProtocal(12726,protocal)
end

-- 下载语音文件完成
function ChatController:handle12726(data)
    if data.time > 0 then
        local key = data.srv_id.."-"..data.voice_id
        local name = ChatHelp.formatFileName(key)
        local voice = VoiceMgr:getInstance():addCacheVoiceFile(key, name, data.time)
        local path = PathTool.getVoicePath(name)
        if data.type == 10 then
            writeBinaryFile(PathTool.getVoicePath(AUDIO_WAV_FILE_DECODE_IN), data.voice)
            callSpeexDecode(PathTool.getVoicePath(AUDIO_WAV_FILE_DECODE_IN), path) -- 解压
        else
            writeBinaryFile(path, data.voice)
        end
        VoiceMgr:getInstance():startPlay(voice)
    else
        message(data.voice)
    end
end


--聊天艾特功能
function ChatController:handle12767( data )
    self.model:setAtData(data)
    if self.chat_ui then 
        self.chat_ui:showAtNotice(true,data)
    end
end

--已查看艾特信息
function ChatController:sender12768( rid,srv_id,channel,msg )
    local protocal ={}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.channel = channel
    protocal.msg = msg
    self:SendProtocal(12768,protocal)
end

function ChatController:handle12768(  )
    
end

--返回信息的id
function ChatController:getId( channel,srv_id,rid,name,msg )
    local list = self.stack_list[channel]
    local id = 1 
    --Debug.info(list)
    for i=0,list:GetSize()-1 do
        local v = list:Get(i)
        --Debug.info(v)
        if srv_id == v.srv_id and rid == v.rid and name == v.name and msg == v.msg then 
            --return v.id
            id = v.id
        end
    end
    return id 
end

--返回该id信息是否是缓存里 判断是否显示@
function ChatController:getIsShowAt( channel,srv_id,rid,name,msg )
    local id = self:getId(channel,srv_id,rid,name,msg)
    local channelList = self.chat_ui.channelList
    if channelList[ChatConst.Channel.Friend] then
        if channelList[ChatConst.Channel.Friend].stack_item[id] then
            return true
        else
            return false
        end
    end
    return false
end

-- 私聊界面位置
function ChatController:getPrivateChatPosX()
    return SCREEN_X+450*SCALE_RATE-2
end

function ChatController:getChatRootWnd()
    if self.chat_ui and self.chat_ui:isOpen() then
        return self.chat_ui.root_wnd
    end
end

-- 通過世界頻道 打开好友信息界面
function ChatController:openFriendInfo(data,touchPos)
    FriendController:getInstance():openFriendCheckPanel(true,data)
end

------------------------------------------------------------
--打开聊天界面
function ChatController:openChatPanel(channel,form,data)
    local story_model = StoryController:getInstance():getModel()
    if story_model:isStoryState() == true then return end
    if GuideController:getInstance():isInGuide() then return end
    channel = channel or ChatConst.Channel.World
    if channel == ChatConst.Channel.Whole then
        channel = ChatConst.Channel.World
    elseif channel == ChatConst.Channel.Gang_Sys then
        channel = ChatConst.Channel.Gang
    end
    if channel ~= ChatConst.Channel.World and channel ~= ChatConst.Channel.Gang and channel ~= ChatConst.Channel.Friend and channel ~= ChatConst.Channel.Notice then
        channel = ChatConst.Channel.World
    end
    if not self.chat_ui then
        self.chat_ui = ChatWindow.New(self)
    end
    if form == "friend" then
        local roleVo = RoleController:getInstance():getRoleVo()
        if data then
            self.model:addContactList(data.srv_id,data.rid)
            self.model:writeContactList()
        else
            local vo = FriendController:getInstance():getModel():getArray():Get(0)
            if vo then
                self.model:addContactList(vo.srv_id,vo.rid)
                self.model:writeContactList()
            end
        end
    end     
    if not self.chat_ui:isOpen() then
        self.chat_ui:open()
    end
    if form == "friend" then
        self.chat_ui:openChannel(channel,data.srv_id,data.rid) 
    else
        self.chat_ui:openChannel(channel)  
    end
    -- 打开面板的时候关闭聊天气泡
    MainuiController:getInstance():setMainUIChatBubbleStatus(false) 
end

function ChatController:moveView(bool)
    if self.chat_ui then
        self.chat_ui:moveUI(bool)
    end
end

-- 关闭聊天界面
function ChatController:closeChatUseAction()
    if self.chat_ui and self.chat_ui:isOpen() then
        self.chat_ui:playMoveAct()
    end
end

-- 聊天界面一定时间没打开，则清掉聊天列表
function ChatController:openChatUITimer( status )
    if status == true and self.chat_ui then
        self.chat_begin_time = GameNet:getInstance():getTime()
        if self.chat_ui_timer == nil then
            self.chat_ui_timer = GlobalTimeTicket:getInstance():add(function()
                local cur_time = GameNet:getInstance():getTime()
                -- 聊天界面关闭5分钟后则清掉聊天列表
                if (cur_time - self.chat_begin_time) > ChatConst.Clear_Chat_Time then
                    GlobalTimeTicket:getInstance():remove(self.chat_ui_timer)
                    self.chat_ui_timer = nil
                    if self.chat_ui then
                        self.chat_ui:clearChatList()
                    end
                end
            end, 1)
        end
    else
        if self.chat_ui_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.chat_ui_timer)
            self.chat_ui_timer = nil
        end
    end
end

--返回聊天的输入组件
function ChatController:getChatInput()
    if self.chat_ui then 
        if self.chat_ui.chat_input then 
            return self.chat_ui.chat_input
        end
    end
end

-- @人
function ChatController:chatAtPeople( name, srv_id )
    local chatInput = self:getChatInput()
    if chatInput then
        chatInput:setInputText("@".. name .." ", srv_id)
    end
end

-- 同省频道打开举报界面
function ChatController:openChatReportWindow( status, data, view_type )
    if status == true then
        if not self.chat_report_wnd then
            self.chat_report_wnd = ChatRepoprtWindow.New()
        end
        if self.chat_report_wnd:isOpen() == false then
            self.chat_report_wnd:open(data, view_type)
        end
    else
        if self.chat_report_wnd then
            self.chat_report_wnd:close()
            self.chat_report_wnd = nil
        end
    end
end

--------------------------------------
function ChatController:isChatOpen()
    if self.chat_ui then
        return self.chat_ui:isOpen()
    end
    return false
end

-- 获取聊天窗口的层级
function ChatController:getChatWindowZorder(  )
    if self.chat_ui then
        return self.chat_ui:getCommonUIZOrder()
    end
    return 1
end

----主聊天的私聊panel
function ChatController:openPrivatePanel( bool,data,parent )
    if bool then
        if not self.chat_panel then
            self.chat_panel = PrivateChatPanel.new(self,parent)
        end
        self.chat_panel:setVisible(false)
    else
        if self.chat_panel and self.chat_panel:isVisible() then
            self.chat_panel:closeView()
            self.chat_panel:setVisible(false)
            self.chat_panel = nil
        end
    end
end

function ChatController:getChatPanel(  )
    return self.chat_panel
end

function ChatController:__delete(  )
    self:openChatUITimer(false)
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
    if self.send_voice_evt then
        GlobalEvent:getInstance():UnBind(self.send_voice_evt)
        self.send_voice_evt = nil
    end
    if self.send_msges_evt then
        GlobalEvent:getInstance():UnBind(self.send_msges_evt)
        self.send_msges_evt = nil
    end
    if self.custom_msg_evt then
        GlobalEvent:getInstance():UnBind(self.custom_msg_evt)
        self.custom_msg_evt = nil
    end
    if self.sys_ticket then
        GlobalTimeTicket:getInstance():remove(self.sys_ticket)
        self.sys_ticket = nil
    end
    if self.voice_upload_evt then
        GlobalTimeTicket:getInstance():remove(self.voice_upload_evt)
        self.voice_upload_evt = nil
    end
    if self.update_drama_data_event then
        GlobalEvent:getInstance():UnBind(self.update_drama_data_event)
        self.update_drama_data_event = nil
    end
    self:openShowDramaTimer(false)
end


-- 缓存语音消息数据
function ChatController:insertVoiceMsg(fileName, voiceStr, time, channel, takeData)
    if fileName then
        self.voiceCache[fileName] = {msg=voiceStr, time = time, channel=channel, take=takeData}
    end
end

-- 语音上传状态，检测是否发生语音
function ChatController:checkSendVoiceMsg(isSuccess, fileName)
    if not fileName then return end
    local data = self.voiceCache[fileName]
    if data then
        if isSuccess then
            self:voiceTranslate(data.msg, data.time, data.channel, data.take)
        else
            message(TI18N("录音失败"))
        end
        self.voiceCache[fileName] = nil
    end
end

-- 判断该频道是否被屏蔽
function ChatController:checkChannelStatus(channel)
    return true
    -- if SysEnv:getInstance() == nil then return end
    -- -- local guild_channel = SysEnv:getInstance():get(SysEnv.keys.auto_guild_voice, false)
    -- -- local world_channel = SysEnv:getInstance():get(SysEnv.keys.auto_world_voice, false)
    -- if ChatConst.Channel.World == channel then 
    --     return world_channel
    -- elseif ChatConst.Channel.Gang == channel then 
    --     return guild_channel
    -- else
    --     return true
    -- end
end

function ChatController:getTarCacheData()
    return self.tar_chat_data
end

-- 清空缓存数据
function ChatController:clearTarCacheData()
    self.tar_chat_data = nil
end

function ChatController:getTarCurOpenType()
    return self.tar_cur_open_type
end

function ChatController:setTarCurOpenType(type)
    self.tar_cur_open_type = type
end


--==============================--
--desc:记录当前聊天面板所打来的聊天频道
--time:2018-07-27 02:57:47
--@channel:
--@return 
--==============================--
function ChatController:setLastChannel(channel)
    self.cur_channel = channel
    if self.cache_msg_list == nil then
        self.cache_msg_list = {}
    end
    self.cache_msg_list[channel] = 0
    -- 清除掉也要通知一下吧
    GlobalEvent:getInstance():Fire(EventId.CHAT_NEWMSG_FLAG, channel)
end

--==============================--
--desc:获取某一个聊天频道的新信息数量
--time:2018-07-27 03:46:48
--@channel:
--@return 
--==============================--
function ChatController:getChannelMsgSum(channel)
    if channel == nil then return 0 end
    if self.cache_msg_list  and self.cache_msg_list[channel] then
        return self.cache_msg_list[channel] or 0
    end
    return 0
end

--==============================--
--desc:获取
--time:2018-07-27 04:19:09
--@return 
--==============================--
function ChatController:getTotalMsgSum()
    if self.cache_msg_list == nil then 
        return 0
    else
        local total = 0
        for k,v in pairs(self.cache_msg_list) do
            total = total + v
        end
        return total
    end
end

--==============================--
--desc:设置某一个聊天界面的累积未读信息
--time:2018-07-27 03:30:59
--@channel:
--@return 
--==============================--
function ChatController:accumulateChannelNum(channel)
    if self.cache_msg_list == nil then
        self.cache_msg_list = {}
    end
    if self.cache_msg_list[channel] == nil then
        self.cache_msg_list[channel] = 0
    end
    self.cache_msg_list[channel] = self.cache_msg_list[channel] + 1
    -- 通知新的消息
    GlobalEvent:getInstance():Fire(EventId.CHAT_NEWMSG_FLAG, channel)
end

-- 显示剧情频道消息
function ChatController:checkShowDramaMsg(  )
    self.drama_dunid_cache = self.drama_dunid_cache or {}
    local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    if drama_data then
        local dun_id = drama_data.dun_id
        local is_first = drama_data.is_first
        if dun_id and is_first and is_first == 1 and not self:checkIsShowedDramaData(dun_id) then -- 首次挑战时才显示剧情频道消息
            -- 对应关卡的剧情消息
            local drama_data = Config.DramaChatData.data_info[dun_id]
            if drama_data then
                table.insert(self.drama_dunid_cache, dun_id)
                self.cur_play_dun_id = dun_id -- 当前正在播放的剧情章节
                self.drama_data_cache = self.drama_data_cache or {}
                for i,con in ipairs(drama_data.content) do
                    table.insert(self.drama_data_cache, con)
                end
                self:openShowDramaTimer(true)
            end
        end
    end
end

-- 检测是否已经显示过
function ChatController:checkIsShowedDramaData( dun_id )
    local isShowed = false
    for k,v in pairs( self.drama_dunid_cache ) do
        if v == dun_id then
            isShowed = true
        end
    end
    return isShowed
end

-- 剧情频道播放定时器
function ChatController:openShowDramaTimer( status )
    if status == true then
        GlobalEvent:getInstance():Fire(ChatEvent.AdjustMainChatBtnPos, true)
        if not self.showDramaTimer then
            self.drama_time = 0
            self.interval_time = -1
            self.showDramaTimer = GlobalTimeTicket:getInstance():add(function()
                self.drama_time = self.drama_time + 1
                local drama_content = self.drama_data_cache[1]
                if drama_content then
                    if self.drama_time >= self.interval_time then
                        self.interval_time = drama_content[1]  -- 播放间隔时间
                        local name = drama_content[2]      -- 名称
                        local msg = drama_content[3]       -- 剧情内容
                        local chat_vo = ChatVo.New()
                        chat_vo.channel = ChatConst.Channel.Drama
                        chat_vo.msg = WordCensor:getInstance():relapceFaceIconTag(msg)[2] or ""
                        chat_vo.id = self:getUniqueId()
                        chat_vo.name = name
                        chat_vo.sex = 3
                        self:saveChatMsg(chat_vo, ChatConst.Channel.Whole)
                        self:saveChatMsg(chat_vo, ChatConst.Channel.Drama)
                        table.remove(self.drama_data_cache, 1)
                        self.drama_time = 0
                        GlobalEvent:getInstance():Fire(EventId.CHAT_UDMSG_WORLD)
                    end
                else
                    GlobalEvent:getInstance():Fire(ChatEvent.AdjustMainChatBtnPos, false)
                    self.cur_play_dun_id = nil
                    GlobalTimeTicket:getInstance():remove(self.showDramaTimer)
                    self.showDramaTimer = nil
                end
            end, 1)
        end
    else
        GlobalEvent:getInstance():Fire(ChatEvent.AdjustMainChatBtnPos, false)
        self.cur_play_dun_id = nil
        if self.showDramaTimer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.showDramaTimer)
            self.showDramaTimer = nil
        end
    end
end

-- 当前是否正在播放剧情消息 如果正在播放则返回对应的关卡id，否则为nil
function ChatController:checkIsPlayingDramaMsg(  )
    return self.cur_play_dun_id
end
