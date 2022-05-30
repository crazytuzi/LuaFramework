-- MainUI单条聊天视图
-- author:cloud
-- date:2016.12.27

MainChatUiMsg = class("MainChatUiMsg", function()
    return ccui.Layout:create()
end)

function MainChatUiMsg:ctor(width, height, max_width, channel)
    self.view_width = width or 421
    self.view_height = height or 36
    self.max_width = max_width
    self.channel = channel
    self._font_size = 22
    self:setAnchorPoint(cc.p(0,1))
    self:setContentSize(cc.size(self.view_width, self.view_height))
    self.content = createRichLabel(self._font_size, Config.ColorData.data_color4[1] , cc.p(0,1), cc.p(70,29), 10, -1, max_width-10)
    self:addChild(self.content)

    -- 点击
    local clickLinkCallBack = function ( type, value, sender, pos, is_click )
        if type == "href" then
            if value == "sound" then
                self:playVoice()
            else
                ChatHelp.OnChatTouched("href", value, sender,self.dataObj)
            end
            return
        end
        if type == "click" and value == "name" and self.dataObj then
            local roleVo = RoleController:getInstance():getRoleVo()
            if self.dataObj.rid == roleVo.rid and self.dataObj.srv_id == roleVo.srv_id then 
                message(TI18N("这是你自己~"))
                return
            end
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.dataObj.srv_id, rid = self.dataObj.rid, flag="mainchatmsg"})
            return
        end

        if value ~= "" and value ~= "name" and value ~= "sound" then
            ChatHelp.OnChatTouched("click", value, sender,self.dataObj)
            return
        end
        if is_click then
            local open_channel = self.dataObj.channel or self.channel
            if open_channel == ChatConst.Channel.Friend then
                if self.dataObj.flag == 2 then -- 别人发给我的
                    ChatController:getInstance():openChatPanel(open_channel, "friend", self.dataObj)
                else
                    local friend_data = {}
                    friend_data.rid = self.dataObj.other_rid
                    friend_data.srv_id = self.dataObj.other_srv_id
                    ChatController:getInstance():openChatPanel(open_channel, "friend", friend_data)
                end
            elseif open_channel ~= ChatConst.Channel.Drama then
                ChatController:getInstance():openChatPanel(open_channel)
            end
        end
    end
    self.content:addTouchLinkListener(clickLinkCallBack,{"click","sound","href"})

    local function onNodeEvent(event)
        if "exit" == event then
            self:setVoiceListener(false)
            self:setVoicePlayListener(false)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function MainChatUiMsg:setData(data)
    --Debug.info(data)
    local obj = ChatMgr:getInstance():analyseTeamHelp(data)
    self.dataObj = data
    if obj then
        self.dataObj = obj
        --self:showTeamUI(obj)
        return
    end

    self:setVoiceListener(false)
    self:setVoicePlayListener(false)
    local show_msg = ""
    local message, color, voice_sec, voice_url, color1

    if self.channel == ChatConst.Channel.Friend then
        if data.flag == 2 then
            color = ChatConst.MainFriendMsgColor[2]
        else
            color = ChatConst.MainFriendMsgColor[1]
        end
    elseif data.channel == ChatConst.Channel.Drama and (data.name == nil or data.name == "") then
        color = Config.ColorData.data_color4[241]
    else
        color = ChatConst.MainMsgColor[data.channel]
    end
    color = color or cc.c3b(255, 250, 118)

    if data.len == 1 then
        local voice_bg, is_self
        local hero = RoleController:getInstance():getRoleVo()
        voice_url, voice_sec = VoiceMgr:getInstance():splitVoice(data.msg)
        if data.rid == hero.rid and data.srv_id == hero.srv_id then
            is_self = true
        end
        voice_bg = PathTool.getResFrame("mainui","mainui_record_3")
        local is_translate, voice_msg = VoiceMgr:getInstance():getMsg(data.msg)
        --[[if not is_translate then
            self:setVoiceListener(true)
        end--]]
        self:setVoicePlayListener(true)
        --show_msg = string.format("<img src='%s' scale=1 />", voice_bg)..("<div click='sound'>"..voice_sec.."\" "..voice_msg.."</div>")
        show_msg = "<div fontColor="..c3bToStr(color)..">"..TI18N("发来一段语音").."</div>"
        show_msg = show_msg .. string.format("<div href=sound>%s</div>", TI18N("点击收听"))
        show_msg = show_msg .. string.format("<img src='%s' scale=1 />", voice_bg) .. ("<div click='sound'>"..voice_sec.."\" " .. "</div>")
        self.voiceUrl = data.msg --记录语音字符串
    else
        str = "<div fontColor="..c3bToStr(color)..">"..data.msg.."</div>"
        show_msg = str
        self.voiceUrl = nil
    end

    -- 频道标识
    local iconStr = ""
    if data.channel and self.channel ~= ChatConst.Channel.Friend then
        local channel_res = PathTool.getResFrame("mainui","txt_cn_chat_icon_"..ChatConst.ChannelRes[data.channel])
        iconStr = string.format("<img src='%s' scale=1 />", channel_res)
    end

    -- 称号
    local titleStr = ""
    if data.ext_list then
        for k,v in pairs(data.ext_list) do
            if v.type == 3 then
                local config = Config.HonorData.data_title[v.val]
                if config then
                    local title_res = PathTool.getTargetRes("honor","txt_cn_honor_"..config.res_id,false,false)
                    titleStr = string.format("<img src='%s' scale=1.0 />", title_res)
                end
                break
            end
        end
    end

    -- 性别标识
    local sexStr = ""
    if data.sex and data.sex < 2 and (data.channel ~= ChatConst.Channel.Notice and data.channel ~= ChatConst.Channel.NoticeTop and data.channel ~= ChatConst.Channel.System and data.channel ~= ChatConst.Channel.SystemTop and data.channel ~= ChatConst.Channel.Gang_Sys) then
        local sex_res = PathTool.getResFrame("common","common_sex"..data.sex)
        sexStr = string.format("<img src='%s' scale=0.7 />", sex_res)
    end

    -- 玩家名称
    local nameStr = ""
    if data.name ~= "" then
        local tempChannel = data.channel or self.channel
        local text_color = ChatConst.MainNameColor[tempChannel] or "#ffa76"
        if tempChannel == ChatConst.Channel.Drama then
            nameStr = string.format("<div fontcolor=%s >%s</div> ", text_color, "[" .. transformNameByServ(data.name, data.srv_id) .. "]")
        else
            -- vip标识
            if data.vip_lev and data.vip_lev > 0 then
                local vip_res = PathTool.getResFrame("mainui","mainui_vip")
                local vip_str = string.format("<img src='%s' scale=1 />", vip_res)
                nameStr = string.format("<div fontcolor=%s click='name'>%s</div> ", text_color, "[" .. vip_str .. transformNameByServ(data.name, data.srv_id) .. "]")
            else
                nameStr = string.format("<div fontcolor=%s click='name'>%s</div> ", text_color, "[" .. transformNameByServ(data.name, data.srv_id) .. "]")
            end      
        end
    end
    show_msg = iconStr .. titleStr .. sexStr .. nameStr .. show_msg
    self.content:setString(show_msg)
    self.msg = show_msg

    local size = self.content:getSize()
    local total_height = size.height
    self.content:setPosition(cc.p(5, 29))

    if data.channel and self.channel ~= ChatConst.Channel.Friend then
        self.channel_label = createLabel(18, 1, nil, self.content:getContentSize().width / 2, self.content:getContentSize().height / 2, '', self.channel_bg, 1, cc.p(0.5, 0.5))
        self.channel_label:setString(ChatConst.ChannelWord[channel])
        self.channel_label:setPosition(cc.p(38,14))
    end
    self:removePlayEffect()
end

function MainChatUiMsg:getItemRealSize(  )
    local msgSize = self.content:getContentSize()
    return cc.size(msgSize.width, msgSize.height+5)
end

-- 翻译语音事件
function MainChatUiMsg:setVoiceListener(bool)
    if bool then
        if not self.voice_evt then
            self.voice_evt = GlobalEvent:getInstance():Bind(VoiceMgr.NewMsg, function(name, msg)
                if self["onTranslateEnd"] then
                    self:onTranslateEnd(name, msg)
                end
            end)
        end
    else
        if self.voice_evt then
            GlobalEvent:getInstance():UnBind(self.voice_evt)
            self.voice_evt = nil
        end
    end
end

-- 语音播放事件
function MainChatUiMsg:setVoicePlayListener(bool)
    if bool then
        if not self.play_evt then
            self.play_evt = GlobalEvent:getInstance():Bind(VoiceMgr.Played, function(bool)
                if self["onVoicePlay"] then
                    self:onVoicePlay()
                end
            end)
        end
    else
        if self.play_evt then
            GlobalEvent:getInstance():UnBind(self.play_evt)
            self.play_evt = nil
        end
    end
end

-- 翻译结束,重新排版布局
function MainChatUiMsg:onTranslateEnd(voice_name, voice_msg)
    if self.dataObj and self.dataObj.len==1 and self.dataObj.msg==voice_name then
        self:setData(self.dataObj)
        GlobalEvent:getInstance():Fire(ChatConst.Voice_Translate_Main)
    end
end

--要滚动聊天信息
function MainChatUiMsg:runMoveAction(width)
    self.content:stopAllActions()
    self.content:setPosition(cc.p(3,28))
    if width > self.content:getContentSize().width then return end
	local posX = self.content:getPositionX()
	local posY = self.content:getPositionY()
    local gap = self.content:getContentSize().width-width
    local delay = cc.DelayTime:create(3)
    local run_time = 0.3--+0.01*(gap+self.chat_icon:getContentSize().width+10-posX)
    local action = cc.MoveTo:create(run_time,cc.p(2, posY))
    local delay2 = cc.DelayTime:create(3)
    self.content:runAction(cc.Sequence:create(delay,action,delay2,cc.CallFunc:create(function()
        --  self.content:setPosition(cc.p(0,self.scroll:getContentSize().height/2))
    end)))
end

function MainChatUiMsg:showPureMsg(data)
    self:setVoiceListener(false)
    self:setVoicePlayListener(false)
    self.dataObj = data

    local color
    if self.channel == ChatConst.Channel.Friend then
        if data.flag == 2 then
            color = ChatConst.MainFriendMsgColor[2]
        else
            color = ChatConst.MainFriendMsgColor[1]
        end
    elseif data.channel == ChatConst.Channel.Drama and (data.name == nil or data.name == "") then
        color = Config.ColorData.data_color4[241]
    else
        color = ChatConst.MainMsgColor[data.channel]
    end
    color = color or cc.c3b(255, 250, 118)

    local show_msg = self:formatMsg(self._font_size, c3bToStr(color), data.msg)

    local size = self.content:getSize()

    -- 频道标识
    local iconStr = ""
    if data.channel and self.channel ~= ChatConst.Channel.Friend then
        local channel_res = PathTool.getResFrame("mainui","txt_cn_chat_icon_"..ChatConst.ChannelRes[data.channel])
        iconStr = string.format("<img src='%s' scale=1 />", channel_res)
    end

    -- 称号
    local titleStr = ""
    if data.ext_list then
        for k,v in pairs(data.ext_list) do
            if v.type == 3 then
                local config = Config.HonorData.data_title[v.val]
                if config then
                    local title_res = PathTool.getTargetRes("title","txt_cn_title_"..config.res_id,false,false)
                    titleStr = string.format("<img src='%s' scale=1.0 />", title_res)
                end
                break
            end
        end
    end

    -- 性别标识
    local sexStr = ""
    if data.sex and data.sex < 2 and (data.channel ~= ChatConst.Channel.Notice and data.channel ~= ChatConst.Channel.NoticeTop and data.channel ~= ChatConst.Channel.System and data.channel ~= ChatConst.Channel.SystemTop and data.channel ~= ChatConst.Channel.Gang_Sys) then
        local sex_res = PathTool.getResFrame("common","common_sex"..data.sex)
        sexStr = string.format("<img src='%s' scale=0.7 />", sex_res)
    end

    -- 玩家名称
    local nameStr = ""
    if data.name ~= ""  then
        local tempChannel = data.channel or self.channel
        local text_color = ChatConst.MainNameColor[tempChannel] or "#ffa76"
        if tempChannel == ChatConst.Channel.Drama then
            nameStr = string.format("<div fontcolor=%s >%s</div> ", text_color, "[" .. transformNameByServ(data.name, data.srv_id) .. "]")
        else
            -- vip标识
            if data.vip_lev and data.vip_lev > 0 then
                local vip_res = PathTool.getResFrame("mainui","mainui_vip")
                local vip_str = string.format("<img src='%s' scale=1 />", vip_res)
                nameStr = string.format("<div fontcolor=%s click='name'>%s</div> ", text_color, "[" .. vip_str .. transformNameByServ(data.name, data.srv_id) .. "]")
            else
                nameStr = string.format("<div fontcolor=%s click='name'>%s</div> ", text_color, "[" .. transformNameByServ(data.name, data.srv_id) .. "]")
            end 
        end
    end

    show_msg = iconStr .. titleStr .. sexStr .. nameStr .. show_msg
    self.content:setString(show_msg)
    self.msg = data.msg

    local total_height = size.height
    self.content:setPosition(cc.p(5, 29))

    if data.channel and self.channel ~= ChatConst.Channel.Friend then
        self.channel_label = createLabel(18, 1, nil, self.content:getContentSize().width / 2, self.content:getContentSize().height / 2, '', self.channel_bg, 1, cc.p(0.5, 0.5))
        self.channel_label:setString(ChatConst.ChannelWord[channel])
        self.channel_label:setPosition(cc.p(38,14))
    end

    local msgSize = self.content:getContentSize()
    --self:setContentSize(cc.size(self.view_width, msgSize.height+6))

    self.voiceUrl = nil
    self.tar_channel = nil
end

function MainChatUiMsg:getIconPositionY()
    -- return self.chat_icon:getPositionY()
    return self.content:getPositionY()
end

function MainChatUiMsg:getMsgContentSize(  )
    return self.content:getContentSize()
end

-- 显示聊天时间
function MainChatUiMsg:setTiemVisible( state )
    
end

-- 调整聊天内容宽度
function MainChatUiMsg:adjustClickNodeWidth()
    local width = self.content._clickNode:getContentSize().width
    if width > self.max_width then
        width = self.max_width
    end
    self.content._clickNode:setContentSize(cc.size(width, self.content._clickNode:getContentSize().height))
end

-- 语音播放效果更新
function MainChatUiMsg:onVoicePlay()
    if self.voiceUrl and self.soundIcon then
        VoiceMgr:getInstance():showVoiceEffect(self.soundIcon, VoiceMgr:getInstance():isPlaying(self.voiceUrl))
    end
end
function MainChatUiMsg:setContentTouch(bool)
    if self.content and self.content._clickNode then
        self.content._clickNode:setTouchEnabled(bool)
    end
end
-- 播放语音
function MainChatUiMsg:playVoice()
    if self.voiceUrl then
        VoiceMgr:getInstance():playVoice(self.voiceUrl)
    end
end

-- 移除播放效果
function MainChatUiMsg:removePlayEffect()
    if not tolua.isnull(self.soundIcon) then
        self.soundIcon:removeFromParent()
    end
    self.soundIcon = nil
end

-- 是否能@人
function MainChatUiMsg:checkIsCanAtPeople(  )
    if self.channel == ChatConst.Channel.Whole or self.channel == ChatConst.Channel.World or self.channel == ChatConst.Channel.Gang or self.channel == ChatConst.Channel.Friend then
        return true
    end
    return false
end

function MainChatUiMsg:formatName(size, color, capacity, text)
    if capacity and capacity ~= 0 then
        return string.format("<div fontsize=%s fontColor=%s>%s</div><div fontsize=%s fontColor=%s click='name' >%s</div>", size, tranformC3bTostr(11), ChatConst.capacity[capacity], size, color,  text)
    else
        return string.format("<div fontsize=%s fontColor=%s click='name' >%s</div>", size, color, text)
    end
end

function MainChatUiMsg:formatMsg(size, color, text)
    return string.format("<div fontsize=%s fontColor=%s>%s</div>", size, color, text)
end

function MainChatUiMsg:setId(id)
    self.id = id
end

function MainChatUiMsg:getId()
    return self.id
end
