-- 聊天管理
-- author:cloud
--date:2016.12.26

ChatMgr = ChatMgr or BaseClass()

function ChatMgr:__init()
	if ChatMgr.Instance ~= nil then
		error("[ChatMgr] cann't be created twice!")
		return
	end
	ChatMgr.Instance = self
    self.vip_lev = -1

    -- 聊天CD时间
    self.speak_times = {}
    if Config.SayData.data_const then
        if Config.SayData.data_const["cooldown_same_province"] then
            self.speak_times[ChatConst.Channel.Province] = Config.SayData.data_const["cooldown_same_province"].val
        end
        if Config.SayData.data_const["cooldown_cross_service"] then
            self.speak_times[ChatConst.Channel.Cross] = Config.SayData.data_const["cooldown_cross_service"].val
        end
        if Config.SayData.data_const["cooldown_world"] then
            self.speak_times[ChatConst.Channel.World] = Config.SayData.data_const["cooldown_world"].val
        end
        if Config.SayData.data_const["cooldown_guild"] then
            self.speak_times[ChatConst.Channel.Gang] = Config.SayData.data_const["cooldown_guild"].val
        end
        if Config.SayData.data_const["cooldown_team"] then
            self.speak_times[ChatConst.Channel.Team] = Config.SayData.data_const["cooldown_team"].val
        end
    end
end

function ChatMgr:getInstance()
	if ChatMgr.Instance == nil then
		ChatMgr.New()
	end
	return ChatMgr.Instance
end


function ChatMgr:__delete()
	ChatMgr.Instance = nil
end

-- 添加播放效果
function ChatMgr:playVoice(voice_icon, sec, finish_func, adjust_x, adjust_y)
    if voice_icon.__is_playing__ then return end
    if self.__playing then return end
    if tolua.isnull(voice_icon) then return end
    self.__playing = true
    adjust_x = adjust_x or 0
    adjust_y = adjust_y or 0
    -- self:stopVoice()
	self.finish_func = finish_func
    self.voice_icon = voice_icon
    self.voice_icon.__is_playing__ = true
    local effect = SoundEffect.new()
    effect:setPosition(cc.p(voice_icon:getPositionX()+adjust_x, voice_icon:getPositionY()+adjust_y))
    effect:play()
    voice_icon:setVisible(false)
    voice_icon:getParent():addChild(effect)
    self.sound_effect = effect
	local function onNodeEvent(event)
    	if "exit" == event then
    		self.sound_effect = nil
            self.voice_icon = nil
            self.__playing = nil
    		AudioManager:getInstance():resumeMusic()
    	end
	end
	voice_icon:registerScriptHandler(onNodeEvent)
	voice_icon:stopAllActions()
	voice_icon:runAction(cc.Sequence:create(cc.DelayTime:create(sec), cc.CallFunc:create(function()
		self:stopVoice()
	end)))
	AudioManager:getInstance():pauseMusic()
end

-- 停止播放效果
function ChatMgr:stopVoice()
	if not tolua.isnull(self.sound_effect) then
       self.sound_effect:stop()
	   doRemoveFromParent(self.sound_effect)
	   self.sound_effect = nil
	end
    if self.finish_func then
       self.finish_func()
    end
    if not tolua.isnull(self.voice_icon) then
       self.voice_icon:stopAllActions()
       self.voice_icon:setVisible(true)
       self.voice_icon.__is_playing__ = nil
    end
	AudioManager:getInstance():resumeMusic()
    self.__playing = nil
end

function ChatMgr:isPlaying()
    return self.__playing
end

-- 点击播放语音
function ChatMgr:touchVoice(voice_url, root)
    -- print("voice_url, self.__playing", voice_url, self.__playing)
    if not voice_url or self.__playing then return 0 end
    local delay_time = 0
    local file_name = ChatHelp.formatFileName(voice_url)
    if not PathTool.checkSound(file_name) then
        ChatHelp.setDownloadAddress2(voice_url)
        cc.FmodexManager:downloadFile(file_name)
        delay_time = 1
        setWillPlaySound(file_name)
    else
        AudioManager:getInstance():playSound(file_name) 
    end
    -- if not tolua.isnull(root) then
    --     delayRun(root, delay_time, function()
    --         AudioManager:getInstance():playSound(file_name) 
    --     end)
    -- end
    return delay_time
end

-- 点击头像
function ChatMgr:onTouchHead(sender, rid, srv_id, name, call_func)
    if tolua.isnull(sender) then return end         -- 容错
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo.rid ~= rid or roleVo.srv_id ~= srv_id then
        if self.chat_teamid_call then
            GlobalEvent:getInstance():UnBind(self.chat_teamid_call)
            self.chat_teamid_call = nil
        end
        self.chat_teamid_call = GlobalEvent:getInstance():Bind(EventId.CHAT_TEAMID_CALL, function(data_list)
            GlobalEvent:getInstance():UnBind(self.chat_teamid_call)
            self.chat_teamid_call = nil
            if tolua.isnull(sender) then return end
            local pos = sender:getTouchEndPosition()
            local obj = {rid=data_list.rid, srv_id=data_list.srv_id, teamId=data_list.team_id, teamSrvId=data_list.team_srv_id, name=name}
        end)
    end
end

-- 聊天内容读取标记
function ChatMgr:isChatRead(id)
    if not self.stack_read then self.stack_read = {} end
    return self.stack_read[id] 
end

function ChatMgr:setChatRead(id)
    if not self.stack_read then self.stack_read = {} end
    self.stack_read[id] = 0
end

-- 解析队伍招募内容
-- 内容 角色id|服务器id|角色名|角色等级|角色职业|角色性别|目的地名称|最低等级|最高等级|当前人数|最大人数|目的地类型|目的地参数|队伍id
function ChatMgr:analyseTeamHelp(chat_vo)
    if chat_vo.len==3 then
        local list = Split(chat_vo.msg, "|")
        if #list >= 15 then
            local obj = {}
            obj.rid      = tonumber(list[1])
            obj.srv_id   = tostring(list[2])
            obj.name     = tostring(list[3])
            obj.lev      = tonumber(list[4])
            obj.career   = tonumber(list[5])
            obj.sex      = tonumber(list[6])
            obj.mis_name = tostring(list[7])
            obj.min_lev  = tonumber(list[8])
            obj.max_lev  = tonumber(list[9])
            obj.min_num  = tonumber(list[10])
            obj.max_num  = tonumber(list[11])
            obj.purpose  = tonumber(list[12])
            obj.tar_val  = tonumber(list[13])
            obj.teamId   = tonumber(list[14])
            obj.teamSrvId = tostring(list[15])
            obj.capacity = tonumber(list[16])
            obj.head_bid = tonumber(list[17])
            obj.len = 3
            -- obj.guild_lev = chat_vo
            return obj
        end
    end
end

-- 聊天说话检测
function ChatMgr:canSpeak(channel)
    if channel==ChatConst.Channel.World then
        -- if RoleController:getInstance():getRoleVo().lev < 10 then
        --     message("等级不足10级，不能在世界发言")
        --     return false
        -- end

    elseif channel==ChatConst.Channel.Team then
        -- if not TeamController:getInstance():isMyselfOnTeam() then
        --     message(ChatController:getInstance():getString("msg_noteam"))
        --     return false
        -- end
    elseif self.channel==ChatConst.Channel.Gang then
        if not RoleController:getInstance():getRoleVo():isHasGuild() then
            message(TI18N("您没有加入公会，不能在公会频道发言"))
            return false
        end
    end

    local times = self.speak_times[channel] or 0
    local now = GameNet:getInstance():getTime()
    if self["sec_"..channel] then
        if now - times < self["sec_"..channel] then
            message(string.format(TI18N("距离下次发言还剩下%s秒"), math.floor(self["sec_"..channel]+times-now)))
            return false
        end
    end
    return true
end

-- 记录聊天说话时间
function ChatMgr:setSpeakTime(channel, time)
    time = time or GameNet:getInstance():getTime()
    self["sec_"..channel] = time
end

----------------聊天复制/举报----------------------
--打开复制UI
function ChatMgr:showReportUI(bool, str, parent, x, y)
    if bool then
        if not self.maskUi then
            self.maskUi = ccui.Layout:create()
            self.maskUi:setTouchEnabled(true)
            self.maskUi:setSwallowTouches(false)
            self.maskUi:setContentSize(SCREEN_WIDTH,SCREEN_HEIGHT)
            ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG):addChild(self.maskUi)
            handleTouchEnded(self.maskUi, function(...)
                delayRun(self.maskUi,0.03, function()
                    self:showReportUI(false)
                end)
            end)
        end
    else
        if self.maskUi and not tolua.isnull(self.maskUi) then
            self.maskUi:removeFromParent()
        end
        self.maskUi = nil
        if self.copyUi and not tolua.isnull(self.copyUi) then
            self.copyUi:removeFromParent()
        end
        self.copyUi = nil
    end
end
