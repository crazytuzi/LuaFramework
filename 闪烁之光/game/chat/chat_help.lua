-- 聊天公具类
-- author:cloud
--date:2016.12.26

ChatHelp = ChatHelp or {}
ChatHelp.UpLoadUrl   = string.format("%s/receive_file.php?", URL_PATH.voice)
ChatHelp.DownLoadUrl = string.format("%s/upload/", URL_PATH.voice)

function ChatHelp.getDownloadAddress2(content)
    local srv_id, rid, time_stamp = unpack(Split(content, "-"))
    return ChatHelp.DownLoadUrl..math.floor(time_stamp/600).."/"..srv_id.."/"
end

function ChatHelp.formatFileName(name)
    if AUDIO_RECORD_TYPE == 10 then
        return string.format("%s%s", string.gsub(name, "-", "_"), ".wav")
    else
        return string.format("%s%s", string.gsub(name, "-", "_"), ".mp3")
    end
end

--点击录音
--channel:频道 taken_obj携带数据, channel 详见ChatConst.Channel
function ChatHelp.RecordTouched(sender, eventType, channel, taken_obj)
    if not _callAudioInit then
        local voice_status = callFunc("checkVoice")
        if voice_status == "" or voice_status == "true" then
            callAudioInit()
        end
    else
    -- if not _callAudioInit then -- 第一次录音的时候初始化
    --     callAudioInit()
    -- else
        ChatHelp.channel   = channel
        ChatHelp.taken_obj = taken_obj
        if eventType == ccui.TouchEventType.began then
            if ChatMgr:getInstance():canSpeak(channel) then
                if ChatHelp.rec_sec==nil or math.ceil(GameNet:getInstance():getTime()-ChatHelp.rec_sec) > 2 then
                    ChatHelp.OpenTipsPanel()
                    ChatHelp.is_pressed = true
                    ChatHelp.StarRecord()
                    ChatHelp.UpdatePressStatus(true)
                    sender:stopAllActions()
                    delayRun(sender, 15, function()
                        ChatHelp.StopRecord()
                        --callAudioStop()
                    end)
                else
                    message(TI18N("录音过于频繁，请两秒后再尝试"))
                end
            end
        elseif eventType == ccui.TouchEventType.moved then
            if ChatHelp.is_pressed then
                local touch_pos = sender:convertToNodeSpace(sender:getTouchMovePosition())
                local touch_size = sender:getContentSize()
                if touch_pos.x<-35 or touch_pos.y<-35 or touch_pos.x>touch_size.width+35 or touch_pos.y>touch_size.height+35 then
                    ChatHelp.UpdatePressStatus(nil) --触摸点移除到图片外
                else
                    ChatHelp.UpdatePressStatus(true)
                end
            end
        elseif eventType==ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.ended then
            ChatHelp.CloseTipsPanel()
            if ChatHelp.is_pressed then
                ChatHelp.StopRecord()
            end
            GlobalTimeTicket:remove("record_start_delay")
            callAudioStop()
            AudioManager:getInstance():resumeMusic()
            ChatHelp.is_pressed = nil
        end
    end
end

--开始录音
function ChatHelp.StarRecord()
	if ChatHelp.is_pressed then
		local hero = RoleController:getInstance():getRoleVo()
        ChatHelp.rec_sec = GameNet:getInstance():getTime()
        ChatHelp.voice_name = string.format("%s-%s-%s", hero.srv_id, hero.rid, ChatHelp.rec_sec)
        GlobalTimeTicket:remove("record_start_delay")
        GlobalTimeTicket:getInstance():add(function()
            callAudioStart()
        end, 30/display.DEFAULT_FPS, 1, "record_start_delay")
        AudioManager:getInstance():pauseMusic()
	end
end

--结束录音
function ChatHelp.StopRecord()
    -- print("==============stopRecord")
    GlobalTimeTicket:remove("record_start_delay")
    callAudioStop()
    GlobalTimeTicket:remove("record_stop_delay")
    GlobalTimeTicket:getInstance():add(function()
        AudioManager:getInstance():resumeMusic()
    end, 30/display.DEFAULT_FPS, 1, "record_stop_delay")
	if ChatHelp.voice_name and ChatHelp.is_pressed then
		local seconds = math.ceil(GameNet:getInstance():getTime()-ChatHelp.rec_sec)
		if seconds > 1 then
            uploadFile(ChatHelp.formatFileName(AUDIO_RECORD_FILE), ChatHelp.voice_name, seconds)
            --发送聊天数据
			--GlobalEvent:getInstance():Fire(EventId.CHAT_SEND_VOICE, ChatHelp.voice_name.."@"..seconds, ChatHelp.channel, ChatHelp.taken_obj)
            ChatController:getInstance():insertVoiceMsg(ChatHelp.voice_name, ChatHelp.voice_name.."@"..seconds, seconds, ChatHelp.channel, ChatHelp.taken_obj)
            ChatHelp.voice_name = nil
			-- message(string.format("录音%d秒", seconds))
			ChatHelp.rec_sec = nil
		else
			message(TI18N("录音时间小于1秒，录音失败"))
		end
	end
end

--打开录音提示界面
function ChatHelp.OpenTipsPanel()
    if not ChatHelp.tips then
        local tips = VoiceRecordUI.new()
        tips:setAnchorPoint(0.5,0.5)
        tips:setPosition(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
        ChatHelp.tips = tips
        local zorder = ChatController:getInstance():getChatWindowZorder()
        ViewManager:getInstance():addToLayerByTag(ChatHelp.tips,ViewMgrTag.TOP_TAG, zorder+1)
    end
end

--记录状态
function ChatHelp.UpdatePressStatus(val)
    ChatHelp.is_pressed = val
    if ChatHelp.tips then
        ChatHelp.tips:setIsRecord(val)
    end
end

--关闭录音提示界面
function ChatHelp.CloseTipsPanel()
    doRemoveFromParent(ChatHelp.tips)
    ChatHelp.tips=nil
end

--触摸聊天内容，分类处理标签
function ChatHelp.OnChatTouched(type, content, sender,self_data)
    if not content then return end
    local role_data = self_data or {}
    local vo = RoleController:getInstance():getRoleVo()
    if vo == nil then return end
    local list = Split(content, "|")
    if not list[1] then return end
    local click_type = tonumber(list[1])

    if type == "href" or type == "click" then
        if click_type == 4 then  --伙伴展示
    		if list[2] and list[3] and list[4] and list[5] and list[6] then
                local vo ={bid =tonumber(list[2]),role_id=tonumber(list[3]),role_srv_id=list[4],star=tonumber(list[5]),is_awake=tonumber(list[6]),partner_id=tonumber(list[7])}
                local look_type = 3
                if vo and vo.partner_id ==0 then 
                    look_type = 2
                end
    		end
        elseif click_type == 5 or click_type == ChatConst.Link.Watch_Ladder then  --战斗录像查看
            local is_in_fight = BattleController:getInstance():getModel():isInFight() -- 战斗中不给弹出二级提示,因为可能新手阶段点开挡住引导了
            if is_in_fight == true then
                message(TI18N("正在战斗中或者观看录像中，无法观看录像"))
                return
            end
            local function fun()
                if list[2]  then
                    if not BattleController:getInstance():getModel():isInFight() and not BattleController:getInstance():getWatchReplayStatus() then
                        if click_type == ChatConst.Link.Watch_Ladder then
                            if list[3] then
                                BattleController:getInstance():csRecordBattle(tonumber(list[3]), list[2])
                            end
                        else
                            BattleController:getInstance():csRecordBattle(tonumber(list[2]))
                        end
                    else
                        message(TI18N("正在战斗中或者观看录像中，无法观看录像"))
                    end
                end
            end
            local str = TI18N("是否前往查看该录像")
            local ok_btn= TI18N("确定")
            local cancel_btn= TI18N("取消")
            CommonAlert.show(str,ok_btn,fun,cancel_btn,nil,CommonAlert.type.rich,nil,nil,22,nil)
        elseif click_type == 6 then --申请入帮
            if list[2] and list[3] then
                GuildController:getInstance():requestJoinGuild(tonumber(list[2]), list[3], 1)
            end
        elseif click_type == 7 then --抢成员红包
            RedbagController:getInstance():openMainView(true)            
        elseif click_type == ChatConst.Link.OtherRole then
            local rid = tonumber(list[2]) or 0
            local s_rid = list[3] or ""
            local vo = {rid = rid, srv_id =s_rid }
            ChatController:getInstance():openFriendInfo(vo)
        elseif click_type == 29 then 
            local hero_id = tonumber(list[3]) or 0
            LookController:getInstance():sender11062(hero_id, role_data.srv_id)
        elseif click_type == 30 then  --冠军赛传闻
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.champion_call)
        elseif click_type == 31 then  --活动BOSS传闻
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.wonderful, 93001)
        elseif click_type == 32 then -- 欢迎入帮的需求
            local rid = tonumber(list[2]) or 0
            local srv_id = list[3] or ""
            GuildController:getInstance():welcomeNewMember(rid, srv_id)
        elseif click_type == 35 then
            local id = tonumber(list[2]) or 0 
            ActionController:getInstance():openActionMainPanel(true, nil, id) 
        elseif click_type == 36 then    --月卡购买
            ChatController:getInstance():closeChatUseAction()
            local yueka_status = WelfareController:getInstance():getModel():getYuekaStatus() 
            if yueka_status == true then
                -- WelfareController:getInstance():openMainWindow(true, WelfareIcon.yueka)
            else
                VipController:getInstance():openVipMainWindow(true)
                --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
            end
        elseif click_type == 37 then    -- 首充跳转
            ChatController:getInstance():closeChatUseAction()
            local is_open = MainuiController:getInstance():checkMainFunctionOpenStatus(MainuiConst.icon.first_charge, MainuiConst.function_type.other, false) 
            if is_open == true then
                local first_icon = MainuiController:getInstance():getFunctionIconById(MainuiConst.icon.first_charge)
                if first_icon then
                    ActionController:getInstance():openFirstChargeView(true) 
                else
                    VipController:getInstance():openVipMainWindow(true)
                    --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
                end
            end
        elseif click_type == 38 then    -- 召唤跳转
            PartnersummonController:getInstance():openPartnerSummonWindow(true)
        elseif click_type == 42 then    -- 竞技场跳转
            ChatController:getInstance():closeChatUseAction()
            local build_vo = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.arena)
            if build_vo and build_vo.is_lock then
                message(build_vo.desc)
                return
            end
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.arena_call)
        elseif click_type == 44 then --公会副本
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildDun)
        elseif click_type == 45 then --充值返利
            local is_open = MainuiController:getInstance():checkMainFunctionOpenStatus(MainuiConst.icon.first_charge, MainuiConst.function_type.other, false) 

            if is_open == true then
                local _type = tonumber(list[2]) or 0
                local action_id = tonumber(list[3]) or 0
                if _type ~= 0 and action_id ~= 0 then
                    ActionController:getInstance():openActionMainPanel(true, nil, action_id) 
                end
            end
        elseif click_type == 46 then
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.hallows)
        elseif click_type == 47 then --神将活动
            local is_open = MainuiController:getInstance():checkMainFunctionOpenStatus(MainuiConst.icon.first_charge, MainuiConst.function_type.other, false) 
            if is_open == true then
                ActionController:getInstance():openActionMainPanel(true, nil, 93006)
            end
        elseif click_type == 50 then --星河神殿
            local is_open = PrimusController:getInstance():checkIsCanOpenPrimusWindow() 
            if is_open == true then
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.primuswar)
            end
        elseif click_type == 48 then -- 联盟战
            local is_open = GuildwarController:getInstance():checkIsCanOpenGuildWarWindow()
            if is_open == true then
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.guildwar)
            end
        elseif click_type == ChatConst.Link.Item_Show then
            local srv_id = list[2] or ""
            local share_id = tonumber(list[3]) or 0
            RefController:getInstance():getGoodsTips(share_id, srv_id)
        elseif click_type == ChatConst.Link.Open_Ladder then
            local is_open = LadderController:getInstance():getModel():getLadderOpenStatus()
            if is_open then
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.ladderwar)
                ChatController:getInstance():closeChatUseAction()
            end
        elseif click_type == 53 then --英雄殿
            if LadderController:getInstance():getModel():getLadderOpenStatus() then
                LadderController:getInstance():openLadderTopThreeWindow(true)
                ChatController:getInstance():closeChatUseAction()
            end
        elseif click_type == 54 then -- 限时召唤
            ActionController:getInstance():openActionMainPanel(true, nil, ActionRankCommonType.time_summon)
            ChatController:getInstance():closeChatUseAction()
        elseif click_type == 55 then -- 精英赛
            if ElitematchController:getInstance():getModel():checkElitematchIsOpen() then
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.eliteMatchWar)
                ChatController:getInstance():closeChatUseAction()
            end
        elseif click_type == 56 then -- 精英赛个人分享
            local period = tonumber(list[2]) or 0
            local id = tonumber(list[3]) or 0
            local share_srv_id = list[4] or ""
            local elite_data = {}
            elite_data.id = id 
            elite_data.share_srv_id = share_srv_id
            ElitematchController:getInstance():openElitematchPersonalInfoPanel(true, period, elite_data)
        elseif click_type == ChatConst.Link.Open_Vedio_info then --录像馆分享的
            local vedio_id = tonumber(list[2]) or 0
            local svr_id = list[3] or ""
            local _type = tonumber(list[4]) or 0
            local hall_svr_id = list[5] or ""
            local channel = role_data.channel or ChatConst.Channel.World
            VedioController:getInstance():send19908( vedio_id, svr_id, _type, channel ,hall_svr_id)
            -- VedioController:getInstance():openVedioLookPanel(true, vedio_id, svr_id, _type)
        elseif click_type == ChatConst.Link.Crossarena then -- 跨服竞技场
            if CrossarenaController:getInstance():getModel():getCrossarenaIsOpen() then
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossArenaWar)
                ChatController:getInstance():closeChatUseAction()
            end
        elseif click_type == ChatConst.Link.Crossarena_honour then -- 跨服竞技场（赛季荣耀）
            if CrossarenaController:getInstance():getModel():getCrossarenaIsOpen() then
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossArenaWar, CrossarenaConst.Sub_Type.Honour)
                ChatController:getInstance():closeChatUseAction()
            end
        elseif click_type == ChatConst.Link.Action_Treasure then
            ActionController:getInstance():openActionMainPanel(true, MainuiConst.icon.festival, ActionRankCommonType.action_treasure)
            ChatController:getInstance():closeChatUseAction()
        elseif click_type == ChatConst.Link.Honor_Icon then -- 荣誉icon分享
            local share_id = tonumber(list[3])
            if share_id then
                RoleController:getInstance():send25816(share_id, role_data.srv_id, role_data)
            end
        elseif click_type == ChatConst.Link.Task_Exp then -- 历练任务分享
            local share_id = tonumber(list[3])
            if share_id then
                RoleController:getInstance():send25818(share_id, role_data.srv_id, role_data)
            end
        elseif click_type == ChatConst.Link.Honor_Level then -- 荣誉等级分享
            local share_id = tonumber(list[2])
            if share_id then
                RoleController:getInstance():send25820(share_id, role_data.srv_id, role_data)
            end
        elseif click_type == ChatConst.Link.Growth_Way then --成长之路
            local share_id = tonumber(list[2])
            if share_id then
                local role_vo = vo
                if role_data.rid == role_vo.rid and role_data.srv_id == role_vo.srv_id then
                    --是自己: 直接打开
                    RoleController:getInstance():openRolePersonalSpacePanel(true, {index = RoleConst.Tab_type.eGrowthWay})
                else
                    local setting = {}
                    setting.form_type = RoleConst.Other_Form_Type.eGrowthWayShare
                    setting.share_id = share_id
                    RoleController:getInstance():requestRoleInfo(role_data.rid, role_data.srv_id, setting)
                end
            end
        elseif click_type == ChatConst.Link.Crosschampion then --周冠军赛
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossChampion)
            ChatController:getInstance():closeChatUseAction()
        elseif click_type == 66 then --精英召唤
            ActionController:getInstance():openActionMainPanel(true, nil, ActionRankCommonType.elite_summon)
            ChatController:getInstance():closeChatUseAction()
        elseif click_type == ChatConst.Link.Elfin_Summon then -- 精灵召唤
            ActionController:getInstance():openActionMainPanel(true, nil, ActionRankCommonType.time_elfin_summon)
            ChatController:getInstance():closeChatUseAction()
        elseif click_type == ChatConst.Link.voyage_senior_privilege then -- 远航高级特权跳转
            VipController:getInstance():openVipMainWindow(true, VIPTABCONST.PRIVILEGE)
            ChatController:getInstance():closeChatUseAction()
        elseif click_type == ChatConst.Link.voyage_Luxury_privilege then -- 远航豪华特权跳转
            VipController:getInstance():openVipMainWindow(true, VIPTABCONST.PRIVILEGE)
            ChatController:getInstance():closeChatUseAction()
        elseif click_type == ChatConst.Link.select_elite_summon then -- 自选精英召唤
            ActionController:getInstance():openActionMainPanel(true, nil, ActionRankCommonType.select_elite_summon)
            ChatController:getInstance():closeChatUseAction()
        end
    end
end

