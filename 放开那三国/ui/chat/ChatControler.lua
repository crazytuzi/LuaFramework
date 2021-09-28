-- Filename: ChatControler.lua
-- Author: DJN
-- Date: 2015-04-21
-- Purpose: 聊天控制层

module("ChatControler", package.seeall)
require "script/ui/chat/ChatUtil"
require "script/ui/chat/ChatMainLayer"
local WORLD_TAG     = 1  
local PM_TAG        = 2
local GUILD_TAG     = 3
local GM_TAG        = 4

local _isRecording    --是否正在录音
local _timerSprite    --录音计时用
local _recordTipSprite--正在录音的提示
function init( ... )
    _isRecording = false
    _timerSprite = nil
    _recordTipSprite = nil
end
--[[
	@des 	:关闭按钮的回调
	@param 	:
	@return :
--]]
function closeClick()    
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    ChatMainLayer.closeLayer()
end
--[[
    @des    :发送按钮回调
    @param  :
    @return :
--]]
function sendClick()
    -- 音效
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local curIndex = ChatMainLayer.getCurIndex()
    print("curIndex",curIndex)
    if(curIndex == WORLD_TAG or curIndex== GUILD_TAG)then
        --世界或军团
        ChatUtil.sendChatinfo(ChatMainLayer.getTalkEditBox(), ChatCache.ChatInfoType.normal, ChatMainLayer.getCurChannel(), sendClickCallback)
         -- 发言需要的物品
        -- local hornDescLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3315"),g_sFontName,23)
        -- hornDescLabel:setAnchorPoint(ccp(0,0))
        -- hornDescLabel:setPosition(ccp(m_layerSize.width*0.05, m_layerSize.height*0.15))
        -- hornDescLabel:setColor(ccc3(0x00,0x6d,0x2f))
        -- m_chatWorldLayer:addChild(hornDescLabel)
        
        -- hornDescLabel:setVisible(false)
        
        -- require "db/DB_Chat_interface"
        -- chatInterface = DB_Chat_interface.getDataById(1)
        -- if(chatInterface ==nil or chatInterface.chat_cost_goods==nil)then
        --     chatItemId = 0
        -- else
        --     chatItemId = tonumber(lua_string_split(chatInterface.chat_cost_goods,"|")[1])
        -- end
        -- require "script/ui/item/ItemUtil"
        -- local itemInfo = ItemUtil.getCacheItemInfoBy(tonumber(chatItemId))
        -- local hornNumber = 0
        -- if(itemInfo ~= nil and itemInfo.item_num ~= nil and tonumber(itemInfo.item_num) ~= 0)then
        --     hornNumber = itemInfo.item_num
        -- end
    elseif(curIndex == PM_TAG)then
        --私聊
        sendPmChat()
    end
end
--[[
    @des    :发送完成后回调
    @param  :
    @return :
--]]
function sendClickCallback(cbFlag, dictData, bRet )
    if(dictData.err ~= "ok") then
        return
    end
    ChatMainLayer.setTalkEditBox("")
end
--[[
    @des    :私聊按钮回调
    @param  :
    @return :
--]]
function sendPmChat(audio_info)
    local receiver_name = ChatMainLayer.getNameEditBox()
    if(receiver_name ==UserModel.getUserName())then
        AlertTip.showAlert( GetLocalizeStringBy("key_1495"), nil, false, nil)
    elseif receiver_name == "" then
        AlertTip.showAlert( GetLocalizeStringBy("key_2050"), nil, false, nil)
    else
        RequestCenter.user_getUserInfoByUname(function( cbFlag, dictData, bRet )
                require "script/utils/LuaUtil"
                if(dictData.err == "ok") then
                    if(dictData.ret == nil or dictData.ret.err ~= "ok" ) then
                        require "script/ui/tip/AlertTip"
                        AlertTip.showAlert( GetLocalizeStringBy("key_2686"), nil, false, nil)
                    elseif ChatCache.isShieldedPlayer(dictData.ret.uid) then
                         AlertTip.showAlert(GetLocalizeStringBy("key_10010"), nil, false, nil)
                    else
                        ChatMainLayer.setTargetName(ChatMainLayer.getNameEditBox())
                        dopmSend(dictData.ret, audio_info)
                    end
                end
            end,
            Network.argsHandler(receiver_name)
        )
    end

end

--[[
    @des    :更换头像按钮切换回调
    @param  :
    @return :
--]]
function callbackChangeHead( ... )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    require "db/DB_Normal_config"
    require "script/model/user/UserModel"
    require "script/ui/tip/SingleTip"
    local vip_level_need = DB_Normal_config. getDataById(1).chatChangeHead
    if vip_level_need > UserModel.getVipLevel() then
        SingleTip.showTip("VIP" .. tostring(vip_level_need) .. GetLocalizeStringBy("key_8030"))
        return
    end
    require "script/ui/chat/ChangeHeadLayer"
    ChangeHeadLayer.show(ChatMainLayer.getTouchPriority()-60)
end
--[[
    @des    :发送私聊成功后回调
    @param  :
    @return :
--]]
function sendPmClickCallback(cbFlag, dictData, bRet, p_text )
    if(dictData.err == "ok") then
        if(dictData.ret == "userOffline")then
            
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert(GetLocalizeStringBy("key_2664"), nil, false, nil)
            return
        elseif dictData.ret == "beBlack" then
            AlertTip.showAlert(GetLocalizeStringBy("key_8428"), nil, false, nil)
            return
        end
        if(dictData.ret ~=nil and dictData.ret.message ~=nil)then
            local chatInfo = {}
            chatInfo.message_text = p_text
            chatInfo.sender_uid = tostring(UserModel.getUserUid())
            chatInfo.sender_uname = UserModel.getUserName()
            chatInfo.sender_vip = tostring(UserModel.getVipLevel())
            chatInfo.sender_level = tostring(UserModel.getHeroLevel())
            chatInfo.sender_tmpl = tostring(UserModel.getAvatarHtid())
            chatInfo.channel = tostring(4)
            chatInfo.sender_gender = tostring(UserModel.getUserSex() == 1 and 1 or 0)
            chatInfo.figure = {}
            chatInfo.figure["1"] = UserModel.getDressIdByPos(1)
            chatInfo.headpic = tostring(UserModel.getFigureId())
            chatInfo.isSelfSend = true

            addChat(chatInfo)     
            ChatMainLayer.setTalkEditBox("")
        end
    end
end
--[[
    @des    :私聊的消息框点击回调
    @param  :
    @return :
--]]
function chatPMCellClickCallback(p_chatInfo)
    -- local index = tag
    -- local PmChatInfo = ChatMainLayer.getTalkInfoByTag(PM_TAG)
    -- local chatInfo = PmChatInfo[index]
    local chatInfo = p_chatInfo
    if chatInfo.sender_uname ~= UserModel.getUserName() then
       ChatMainLayer.setNameEditBox(chatInfo.sender_uname)
    end
end
--[[
    @des    :发送私聊
    @param  :
    @return :
--]]
function dopmSend(userInfo, audio_info)
    print("audio_info=", audio_info)
    ChatUtil.sendChatinfo( (audio_info or ChatMainLayer.getTalkEditBox()), ChatCache.ChatInfoType.normal,  ChatCache.ChannelType.pm, sendPmClickCallback, tonumber(userInfo.uid))
end
--[[
    @des    :点击玩家头像的回调
    @param  :
    @return :
--]]
function headCb(p_chatInfo)
    -- local index = node:getTag()
    -- local chatInfo = ChatMainLayer.getCurChatInfo()
    -- chatInfo = chatInfo[index]
    local chatInfo = p_chatInfo
    local htid = tonumber(chatInfo.sender_tmpl)
    showFriendView(chatInfo.sender_uname,chatInfo.sender_level,chatInfo.sender_fight,htid,chatInfo.sender_uid,chatInfo.sender_gender,chatInfo.figure)
end
--[[
    @des    :点击玩家头像的回调后的弹板
    @param  :
    @return :
--]]
function showFriendView(uname,ulevel,power,htid,uid,uGender,dressInfo)
    require "script/model/user/UserModel"
    if(tonumber(uid)==tonumber(UserModel.getUserInfo().uid))then
        require "script/ui/main/AvatarInfoLayer"
        if AvatarInfoLayer.getObject() == nil then
            local scene = CCDirector:sharedDirector():getRunningScene()
            local ccLayerAvatarInfo = AvatarInfoLayer.createLayer(ChatMainLayer.getTouchPriority()-60)
            scene:addChild(ccLayerAvatarInfo,1999,3122)
        end
        return
    end
    
    require "script/ui/chat/ChatUserInfoLayer"
    require "db/DB_Heroes"
    local hero = DB_Heroes.getDataById(htid)
    
    local imageFile = hero.head_icon_id
    ChatUserInfoLayer.showChatUserInfoLayer(uname,ulevel,power,"images/base/hero/head_icon/" .. imageFile,uid,uGender,htid,dressInfo, ChatMainLayer.getTouchPriority()-70)

    -- body
end
--[[
    @des    :查看战报的回调
    @param  :
    @return :
--]]
function callbackLookReport(p_chatInfo)
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/guild/city/VisitorBattleLayer"
    
    -- local chat_info_index = tag
    -- require "script/ui/chat/ChatMainLayer"
    -- --local world_infoes = ChatWorldLayer.getChatInfoes()
    -- local world_infoes = ChatMainLayer.getTalkInfoByTag(1)
    -- print("chat_info_index",chat_info_index)                                               
    -- local chat_info = world_infoes[chat_info_index]
    local chat_info = p_chatInfo
    print("battle_report_info===", chat_info)
    print("chat_info.message_text",chat_info.message_text)
    local battle_report_info = ChatUtil.parseTabContent(chat_info.message_text, ChatUtil.BattleTabStr)
    local handleGetRecord = nil
    local battle_report_type = tonumber(battle_report_info[4])
    if battle_report_type == ChatCache.ChatInfoType.battle_report_player then
        handleGetRecord = function( fightRet )
            -- 调用战斗接口 参数:atk 
            require "script/battle/BattleLayer"
            -- 调用结算面板
            require "script/battle/ChatBattleReportLayer"
            -- require "script/model/user/UserModel"
            -- local uid = UserModel.getUserUid()
            -- 解析战斗串获得战斗评价
            local amf3_obj = Base64.decodeWithZip(fightRet)
            local lua_obj = amf3.decode(amf3_obj)
            print(GetLocalizeStringBy("key_1606"))
            print_t(lua_obj)
            local appraisal = lua_obj.appraisal
            -- 敌人uid
            local uid1 = lua_obj.team1.uid
            local uid2 = lua_obj.team2.uid
            local enemyUid = 0
            if(tonumber(uid1) ==  UserModel.getUserUid() )then
                enemyUid = tonumber(uid2)
            end
            if(tonumber(uid2) ==  UserModel.getUserUid() )then
                enemyUid = tonumber(uid1)
            end
            local reportData = {}
            reportData.server = lua_obj
            local closeCallback = function()
                require "script/battle/GuildBattle"
                BattleLayer.closeLayer()
            end
            local afterBattleLayer =  VisitorBattleLayer.createAfterBattleLayer(reportData, false, closeCallback)
            BattleLayer.showBattleWithString(fightRet, nextCallFun, afterBattleLayer,nil,nil,nil,nil,nil,true)
        end
    elseif battle_report_type == ChatCache.ChatInfoType.battle_report_union then
        handleGetRecord = function(fight_fet)
            local base64Data = Base64.decodeWithZip(fight_fet)
            local data = amf3.decode(base64Data)
            print_t(data)
            require "script/ui/guild/copy/GuildBattleReportLayer"
            require "script/battle/GuildBattle"
            local reportData = {}
            reportData.server = data
            local closeCallback = function()
                require "script/battle/GuildBattle"
                GuildBattle.closeLayer()
            end
            local visitor_battle_layer = VisitorBattleLayer.createAfterBattleLayer(reportData, false, closeCallback)
            GuildBattle.createLayer(reportData, GuildBattle.BattleForGuild, visitor_battle_layer, true)
        end
    elseif battle_report_type == ChatCache.ChatInfoType.battle_report_city then
        handleGetRecord = function(fight_ret)
            local base64Data = Base64.decodeWithZip(fight_ret)
            local data = amf3.decode(base64Data)
            print_t(data)
            require "script/ui/guild/copy/GuildBattleReportLayer"
            require "script/battle/GuildBattle"
            local reportData = {}
            reportData.server = data
            local closeCallback = function()
                require "script/battle/GuildBattle"
                GuildBattle.closeLayer()
            end
            local visitor_battle_layer = VisitorBattleLayer.createAfterBattleLayer(reportData, false, closeCallback)
            GuildBattle.createLayer(reportData, GuildBattle.BattleForCity, visitor_battle_layer, true)
        end
    else
        print("战报类型有误")
    end
    require "script/ui/mail/MailService"
    MailService.getRecord(tonumber(battle_report_info[3]), handleGetRecord)
end

--[[
    @des    :在聊天界面增加聊天内容
    @param  :
    @return :
--]]
function addChat(chatInfos)
    local chat_infos_temp = nil

    if(#chatInfos==0)then
        chat_infos_temp = {}
        table.insert(chat_infos_temp, chatInfos)
    else
        chat_infos_temp = chatInfos
    end
    print("chat_infos_temp")
    print_t(chat_infos_temp)
    for i=1,#chat_infos_temp do
        local chatInfo = chat_infos_temp[i]
        --如果没有被屏蔽的话
        if not ChatCache.isShieldedPlayer(chatInfo.sender_uid) then
             
            if( (ChatUtil.isChatCellTypeBy(chatInfo.message_text, ChatUtil.AudioTabStr)==true and RecordUtil.getSupportRecordStatus() == RecordUtil.kFlagRecordNo ))then
                -- 如果传过来的是语音，判断是否支持语音，如果不支持过滤掉，没有continue 的语言真蛋疼
                -- AnimationTip
            else
                -- chatInfo.channel  1<=>广播频道 2<=>世界频道（用户发的消息，出现在世界频道） 3<=>系统频道 (系统发的消息，出现在世界频道)
                -- 4<=>私人频道 5<=>私人广播频道(大喇叭) 100<=>副本频道 101<=>公会频道

                if tonumber(chatInfo.channel)==2 or tonumber(chatInfo.channel)==3 or tonumber(chatInfo.channel)==5 or tonumber(chatInfo.channel)==4 or tonumber(chatInfo.channel)==101 then
                    local ChatTag = nil --记录一下接收到的推送是什么消息 用于判断是否增加缓存队列和是否刷新
                    if ChatMainLayer.getIsOpen()==false then   -- 界面没有打开
                        --给首页的聊天按钮和军团按钮发推送 有未读消息
                        require "script/ui/main/MainBaseLayer"
                        MainBaseLayer.showChatAnimation(true)
                        if(tonumber(chatInfo.channel)==101)then
                            require "script/ui/guild/GuildBottomSprite"
                            GuildBottomSprite.setGuildChatItemAnimation(true)
                        end
                    end
                    if(tonumber(chatInfo.channel)==2 or tonumber(chatInfo.channel)==3 or tonumber(chatInfo.channel)==5)then
                        --要显示在世界聊天上的内容
                        ChatTag = WORLD_TAG
                    elseif(tonumber(chatInfo.channel)==4)then
                        --私聊内容                        
                        if(tonumber(chatInfo.sender_uid) ~= UserModel.getUserUid() )then
                        --因为私聊的消息发出后后端不会推送回来，要自己整理数据结构后调用addchat函数
                        --所以这里涉及一个问题 自己发出的私聊消息  不需要有红点提示                        
                            if ChatMainLayer.getIsOpen() == false then
                                ChatMainLayer.addNewPmCount(1)
                                print("ChatMainLayer.getNewPmCount()",ChatMainLayer.getNewPmCount())
                                MainBaseLayer.showChatTip(ChatMainLayer.getNewPmCount())                            
                            elseif(ChatMainLayer.getCurIndex() ~= PM_TAG) then 

                                ChatMainLayer.addNewPmCount(1)                         
                                ChatMainLayer.refreshPmTip()                                              
                            end
                        end
                        ChatTag = PM_TAG
                    elseif(tonumber(chatInfo.channel)==101)then
                        --军团聊天内容
                        ChatTag = GUILD_TAG
                    end
                    if(ChatTag == WORLD_TAG or ChatTag == PM_TAG or ChatTag == GUILD_TAG)then
                        local chat_cache = ChatMainLayer.getTalkInfoByTag(ChatTag)
                        table.insert(chat_cache,chatInfo)
                        ChatMainLayer.refreshChatView(ChatTag)
                    end
                end
            end
        end
    end
end

-----------------------------------------------------录音相关函数-----------------------
-- 开始录音
function beganRecorder( )
    print("start recorder!")

    if( Platform.getOS() == "android")then
        if(string.checkScriptVersion(g_publish_version, "4.3.4") < 0)then
            AnimationTip.showTip(GetLocalizeStringBy("key_10147"))
            RecordUtil.showDownloadTip()
            return
        end
    end

    if(RecordUtil.isSupportRecord() == false)then
        AnimationTip.showTip(GetLocalizeStringBy("key_10147"))
        RecordUtil.showDownloadTip()
        return
    end
    if(RecordUtil.isRecordPermisson() == false)then
        AnimationTip.showTip(GetLocalizeStringBy("key_10146"))
        return
    end

    
    showRecordTipSprite( true )
    
    RecordUtil.stopPlayRecord()
    AudioUtil.stopBgm()
    RecordUtil.startRecord()
    _isRecording = true
    startTimer()
end

-- 最多录音多长时间
function startTimer()
    endTimer()
    _timerSprite = CCNode:create()
    local BgLayer = ChatMainLayer.getChatLyerBg()
    if(BgLayer ~= nil)then
        print("bububububububub")
    end
    print("BgLayerBgLayerBgLayer",BgLayer)
    BgLayer:addChild(_timerSprite)
    schedule(_timerSprite, timeEndCallback, 30)
end
--停止录音计时的监听
function endTimer()
    if(_timerSprite)then
        _timerSprite:removeFromParentAndCleanup(true)
        _timerSprite = nil
    end
end
--录音完毕回调
function timeEndCallback()
    endTimer()
    
    -- 超时长 结束录音
    endRecorder()
end

-- 结束录音
function endRecorder( )
    print("end recorder!")
    endTimer()
    if(_isRecording == false)then
        return
    end
    local audio_data, a_sec_ms = RecordUtil.stopRecord()
    _isRecording = false

    AudioUtil.playBgm()
    deleteRecordTipSprite()
    if( math.floor(a_sec_ms/1000) < 1 )then
        AnimationTip.showTip(GetLocalizeStringBy("key_10008"))
        return
    end

    RecordUtil.sendRecorder(audio_data, a_sec_ms, function( status, a_data )
        if(status == 0)then
            -- 正常
            local cjson = require "cjson"
            local arrStr = cjson.decode(a_data)
            ChatCache.addAudioBy(arrStr.id, audio_data)
            sendAudioInfo(arrStr.id, a_sec_ms)
        else
            AnimationTip.showTip(GetLocalizeStringBy("key_10009"))
        end
    end)
end

-- 取消录音
function cancelRecorder()
    print("cancel recorder!")
    endTimer()
    if(_isRecording == true)then
        RecordUtil.stopRecord()
        AudioUtil.playBgm()
        deleteRecordTipSprite()
    end
end

-- 展示录音提示Sprite
function showRecordTipSprite( p_status )
    print("p_status=", p_status)
    if(_recordTipSprite == nil)then
        _recordTipSprite = RecordTipSprite:create()
        local chatLayer = ChatMainLayer.getChatLyerBg()
        _recordTipSprite:setPosition(ccp(chatLayer:getContentSize().width*0.5, chatLayer:getContentSize().height*0.5))
        _recordTipSprite:setAnchorPoint(ccp(0.5, 0.5))
        chatLayer:addChild(_recordTipSprite, 999, 999)
        showRecordVoice()
    end
    _recordTipSprite:showStaus(p_status)
end

-- 删除录音提示
function deleteRecordTipSprite()
    if(_recordTipSprite)then
        _recordTipSprite:removeFromParentAndCleanup(true)
        _recordTipSprite = nil
    end
end

-- 检查录音时的分贝
function showRecordVoice()
    if(_recordTipSprite)then
        schedule(_recordTipSprite, function ( ... )
            
            _recordTipSprite:setVoiceCol(RecordUtil.getCurVoiceLevel())
        end, 0.1)
    end
end

--录音时手指移动的回调
function movedCallback( isIn )
    print("movedCallback, isIn==", isIn)
    if(_isRecording == true)then
        showRecordTipSprite(isIn)
    end
end 

-- 发送录音
function sendAudioInfo( aid, aSec )
    local t_content = ChatUtil.unionAudioText(aid, aSec)
    if(ChatMainLayer.getCurChannel() == ChatCache.ChannelType.pm )then
        sendPmChat(t_content)
    else
        ChatUtil.sendChatinfo(t_content, ChatCache.ChatInfoType.normal, ChatMainLayer.getCurChannel(), audioSendClickCallback)
    end
end
-- 获取当前是否正在录音
function isRecording( ... )
    return _isRecording
end
-----------------------------------------------------录音相关函数结束-----------------------