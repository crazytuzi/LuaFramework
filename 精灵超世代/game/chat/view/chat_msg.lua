-- 单条聊天信息
-- author:cloud
-- date: 2016.12.27
--ChatMsg = ChatMsg or BaseClass()
ChatMsg = class("ChatMsg",function()
    return ccui.Widget:create()
end)

function ChatMsg:ctor(width, height)
    self:setCascadeOpacityEnabled(true)
    self.view_width = width or 410
    self.view_height = height or 130
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setCascadeOpacityEnabled(true)
    self.root_wnd:setContentSize(cc.size(self.view_width, self.view_height))
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self:addChild(self.root_wnd)

    self:initLayout()
    self.dataObj = nil  --聊天数据
    self.channel = nil  --设置当前的频道
    self.gap =30       --每条聊天信息间距
    self.is_myself = false
end


-- 初始化布局
function ChatMsg:initLayout()
    --聊天容器
    self.head_root = ccui.Widget:create()
    self.head_root:setCascadeOpacityEnabled(true)
    self.head_root:setAnchorPoint(cc.p(0, 0))
    self.head_root:setPosition(cc.p(-28,0))
    self.root_wnd:addChild(self.head_root)
    --频道背景
    self.channel_bg = ccui.ImageView:create()
    self.channel_bg:setCascadeOpacityEnabled(true)
    self.channel_bg:setAnchorPoint(cc.p(0,0))
    self.channel_label = createLabel(18, 1, nil, self.channel_bg:getContentSize().width / 2, self.channel_bg:getContentSize().height / 2, '', self.channel_bg, 1, cc.p(0.5, 0.5))
    self.root_wnd:addChild(self.channel_bg,1)
  
end

function ChatMsg:setTiemVisible(bool)
    if self.talk_time then
        self.talk_time:setVisible(bool)
    end
end

--显示普通聊天数据
function ChatMsg:showHead(data)
    if self.notice_content then
        self.notice_content:setVisible(false)
    end
    self.head_root:setVisible(true)
   local roleVo = RoleController:getInstance():getRoleVo()
    local bid = data.bubble_bid

    if self.notice_bg then 
        self.notice_bg:setVisible(false)
    end
    
    if tolua.isnull(self.head_icon)  then
        self.head_icon = PlayerHead.new(PlayerHead.type.circle)
        self.head_icon:setTouchEnabled(true)
        self.head_icon:setHeadLayerScale(0.8)
        self.head_icon:setAnchorPoint(cc.p(0.5,0.5))
        self.head_root:addChild(self.head_icon)
        

        -- self.head_icon:addTouchEventListener(function(sender, event)
        --     if ccui.TouchEventType.ended == event and self.dataObj then
        --         local roleVo = RoleController:getInstance():getRoleVo()
        --         local touchPos = cc.p(sender:getTouchEndPosition().x+320,sender:getTouchEndPosition().y)
        --         Debug.info(self.dataObj.flag)
        --         if self.dataObj.flag then
        --             -- --私聊
        --             -- ChatMgr:getInstance():onTouchHead(sender, self.dataObj.rid, self.dataObj.srv_id, self.dataObj.name or "")
        --         else
        --             if roleVo.rid==self.dataObj.rid and roleVo.srv_id==self.dataObj.srv_id then return end
        --             ChatController:getInstance():openFriendInfo(self.dataObj,touchPos)
        --         end
        --     end
        -- end)

        local roleVo = RoleController:getInstance():getRoleVo()

        --试试长按
        self.head_icon:addCallBack(function (  )
            if self.dataObj then
                -- 同省频道玩家不给查看
                if self.dataObj.channel == ChatConst.Channel.Province then
                    if self.is_myself then
                        message(TI18N("这是你自己哦"))
                    else
                        ChatController:getInstance():openChatReportWindow(true, self.dataObj)
                    end
                    return
                end
                
                --local touchPos = cc.p(sender:getTouchEndPosition().x+320,sender:getTouchEndPosition().y)
                if self.dataObj.flag then
                    -- --私聊
                    -- ChatMgr:getInstance():onTouchHead(sender, self.dataObj.rid, self.dataObj.srv_id, self.dataObj.name or "")
                else
                    if roleVo.rid==self.dataObj.rid and roleVo.srv_id==self.dataObj.srv_id then return end
                    ChatController:getInstance():openFriendInfo({srv_id = self.dataObj.srv_id, rid = self.dataObj.rid, flag="chat_msg", channel=self.dataObj.channel})--,touchPos)
                end
            end
        end,true)
        self.head_icon:setHeadData({srv_id=data.srv_id,rid=data.rid,name=data.name})
        --头像框
        local vo = Config.AvatarData.data_avatar[data.head_bid]
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.head_icon:showBg(res, nil, false, vo.offy)
        end

        self.head_icon:longCliCallback(function (data)
            --Debug.info(data)
            if data.rid == roleVo.rid and data.srv_id == roleVo.srv_id then 
                message(TI18N("这是你自己~"))
                return
            end
            --message(string.format("长按啦啦啦艾特%s",data.name))
            local input = ChatController:getInstance():getChatInput(  )
            if input then 
                local const_data = Config.SayData.data_const
                local lev = 30
                local text = ""
                if const_data and const_data["at_condition"] then
                    lev = const_data["at_condition"].val
                    text = const_data["at_condition"].desc
                end
                if roleVo.lev >= lev then
                    input:setInputText("@"..data.name.." ")
                else
                    message(text)
                end
            end
        end)

        --性别
        self.sex_icon = ccui.ImageView:create()
        self.sex_icon:setAnchorPoint(cc.p(0,0))
        self.sex_icon:setScale(0.6)
        self.sex_icon:setPosition(cc.p(65,10))
        self.head_icon:addChild(self.sex_icon,10)
        self.sex_icon:setVisible(false)
        
        self.capacity = createLabel(17,Config.ColorData.data_color4[1],nil,94,59,"",self.head_root)
        self.capacity:setAnchorPoint(cc.p(0, 0.5))

        self.talk_time = createLabel(22,Config.ColorData.data_color4[147],nil,262,110-7,"",self.head_root)
        self.talk_time:setVisible(false)
        self.talk_time:setAnchorPoint(cc.p(0.5, 1))
        self.talk_time:setPosition(365,90)
        if TimeTool.getDayDifference(data.talk_time) > 1 then--r如果已经超过一天显示日期
            self.talk_time:setString(TimeTool.getMDHMS(data.talk_time))
        else
            self.talk_time:setString(TimeTool.getHMS(data.talk_time))
        end

        --名字
        self.player_name = createLabel(20,Config.ColorData.data_new_color4[6],nil,109,94,"",self.head_root)
        self.player_name:setAnchorPoint(cc.p(0, 0.5))

        --聊天内容背景
        self.chat_pic = ccui.Widget:create()
        self.chat_pic:setPositionX(112)
        self.chat_pic:setAnchorPoint(cc.p(0, 1))
        self.chat_pic:setTouchEnabled(true)
        self.head_root:addChild(self.chat_pic)

        self.chat_bg = ccui.ImageView:create()
        self.chat_bg:setAnchorPoint(cc.p(0, 1))
        self.chat_bg:setPositionX(125)
        self.chat_bg:setTouchEnabled(true)
        self.chat_bg:setSwallowTouches(false)
        self.chat_bg:setPropagateTouchEvents(true)
        self.head_root:addChild(self.chat_bg,-1)

        --聊天内容 54f1ff
        self.content = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(20, 64), 5, -1, self.view_width)
        self.chat_pic:addChild(self.content)
        self.content:addTouchLinkListener(function(type, value, sender)
            ChatHelp.OnChatTouched(type, value, sender, self.dataObj )
        end, {"click","href"})
        self.content:setMaxWidth(420, false)
    end
    --哈哈哈哈啊哈哈哈哈哈哈哈啊哈哈啊哈哈啊哈哈哈哈啊哈哈哈哈哈哈哈哈哈
    if tolua.isnull(self.chat_pic) then return end
    local hero = RoleController:getInstance():getRoleVo()
    local is_self
    if (data.rid == hero.rid and data.srv_id == hero.srv_id) or (data.flag ==1 or data.flag ==11)then
        is_self = true
    end

    local chat_conf =  {
        bid = 1,
        ornament = 0,
        color = 25}   --Config.ChatBubble[bid]
        
    -- if not chat_conf then
    --     chat_conf = Config.ChatBubble[1]
    -- end
    local res = PathTool.getResFrame("mainui","mainui_chat_bg_0")
    local content_color = 175

    self.chat_bg:loadTexture(res,LOADTEXT_TYPE_PLIST)
    
    self.chat_bg:setScale9Enabled(true)
    self.chat_bg:setCapInsets(cc.rect(30,11,1,1))

    self:removeComps()
    self:showVoiceTishi(false)
    --聊天内容/语音区分
    local temp_str = ""
    local voice_url
    local voice_sec = 0
    if data.len == 1 then --有语音时显示
        voice_url, voice_sec = VoiceMgr:getInstance():splitVoice(data.msg)
        local is_translate, voice_msg = VoiceMgr:getInstance():getMsg(data.msg)
        if not is_translate then
            self:setVoiceListener(true)
        end
        self:setVoicePlayListener(true)
        if string.len(voice_msg) >= 45 then
            voice_msg = string.sub(voice_msg, 1, 39) .. "...."
        end
        temp_str = temp_str..string.format(" <img src='%s'/>", PathTool.getResFrame("mainui","mainui_record_3"))
        temp_str = temp_str..string.format("<div fontcolor=%s> %s%s  </div>",tranformC3bTostr(175), voice_sec, "\" "..voice_msg)
        self.content._clickNode:setTouchEnabled(false)
    --聊天展示
    elseif data.len == 2 then
        self.content._clickNode:setTouchEnabled(false)
        temp_str = data.msg
    else
        temp_str = data.msg
    end
    -- temp_str = string.format("<div fontsize=%s fontcolor=%s>%s</div>",17,tranformC3bTostr(chat_conf.color),temp_str)
    temp_str = string.format("<div fontsize=%s fontcolor=%s>%s</div>",22,tranformC3bTostr(content_color),temp_str)
    self.content:setString(temp_str)
    if data.len == 0 then
        self.content._clickNode:setTouchEnabled(true)
    end
    self.content._clickNode:setSwallowTouches(false)
    self.content._clickNode:setPropagateTouchEvents(true)
    self.chat_pic:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            --self.chat_pic:setOpacity(128)
            self:popUpBegin(data.msg)
        else
            --self.chat_pic:setOpacity(255)
            if eventType==ccui.TouchEventType.ended then
                if data.len==1 then --语音
                    self:playVoice()
                elseif data.len == 2 then --展示
                    local str = self.content:getDivArgs({"click"})
                    if str then
                        ChatHelp.OnChatTouched("click", str, sender,self.dataObj)
                    end
                elseif data.len == 3 then
                    local str = self.content:getDivArgs({"click"})
                    if str then
                        ChatHelp.OnChatTouched("click", str, sender,self.dataObj)
                    end
                else
                    self:popUpEnd()
                end
            end
        end
    end)

    local size = self.content:getSize()
    local _content_gap = 10
    local _height = size.height + _content_gap
    if _height < 64 then
        _height = 64
    end
    local v_width = math.max(33+self.content:getContentSize().width,64)
    
    -- --不同的气泡框对应的要相应加个宽高
    local offx = 0
    local offy = 0

    self.chat_pic:setContentSize(cc.size(v_width, _height))
    self.chat_bg:setContentSize(cc.size(v_width, _height))
    --头像
    local sex = 0
    if data.sex == 1 then sex = 1 end

    if data.face_id == 0 or data.face_id == 1 then
        local face_file = self.data.face_file or ""
        if face_file ~= "" then
            local face_update_time = self.data.face_update_time or 0
            self.head_icon:setHeadRes(face_id, false, LOADTEXT_TYPE, face_file, face_update_time)
        end
    else
        self.head_icon:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
    end

    if data.sex ~= 2 then 
        self.sex_icon:setVisible(true)
        self.sex_icon:loadTexture(PathTool.getResFrame("common","common_sex"..sex), LOADTEXT_TYPE_PLIST)
    else 
        self.sex_icon:setVisible(false)
    end
     --区分跨服名字
    if data.channel == ChatConst.Channel.Cross then
        local srv_name = getServerName(data.srv_id)
        local name_str = "【" .. srv_name .. "】" .. data.name
        self.player_name:setString(name_str)
    else
        self.player_name:setString(data.name)
    end
   
    --[[if is_self then
        self.head_icon:setLev(RoleController:getInstance():getRoleVo().lev)
    else
        self.head_icon:setLev(data.lev)
    end--]]

    --self.head_icon:setLevPositon(cc.p(5,58))
    --判断是否是vip玩家
    --Debug.info(data)
    --print("=========data.vip_lev=====",data.vip_lev)
    -- 同省频道不显示vip标识
    if data.channel ~= ChatConst.Channel.Province and not self.vip_image and data.is_show_vip and data.is_show_vip == 0 and data.vip_lev and data.vip_lev > 0 then
        self.vip_image = createSprite( PathTool.getResFrame("common","common_1038"), 66, 92)
        self.vip_image:setAnchorPoint(cc.p(0, 0.5))
        self.head_root:addChild(self.vip_image)
    end

    -- 同省频道显示地址、时间
    if data.channel == ChatConst.Channel.Province then
        -- 地址
        if not self.site_txt then
            self.site_txt = createLabel(20,Config.ColorData.data_color4[271],nil,109,94,"",self.head_root)
        end
        if data.city then
            self.site_txt:setString(data.city)
        end
        -- 时间
        --[[if not self.msg_time then
            self.msg_time = createLabel(20,Config.ColorData.data_color4[271],nil,109,94,"",self.head_root)
        end
        if data.tick then
            self.msg_time:setString("[ " .. TimeTool.getMDHM(data.tick) .. " ]")
        end--]]
    end

    --调整高度
    local pic_size = self.chat_pic:getContentSize()
    local img_size = self.head_icon:getContentSize()
    local total_height = pic_size.height+30
    total_height = total_height + self.gap + 2
    self.root_wnd:setContentSize(self.view_width, total_height)
    self:setContentSize(cc.size(self.view_width,total_height))
    self:setAnchorPoint(cc.p(0,1))
    self.head_icon:setPosition(80,total_height-50)
    if not self.is_whole then
        self.channel_bg:setVisible(false)
    else
        self.channel_bg:setVisible(true)
    end
    local offx = 125
    local world_x = 0
    local guild_x = 0
    local sex_x = 0

    self.player_name:setPosition(cc.p(offx+guild_x+3,self.head_icon:getPositionY()+20))
    local vip_x = 0
    if self.vip_image then 
        self.vip_image:setPosition(self.player_name:getPositionX()+self.player_name:getContentSize().width+4, self.player_name:getPositionY())
        vip_x = 15
    end
    if self.site_txt then
        self.site_txt:setAnchorPoint(cc.p(0, 0.5))
        self.site_txt:setPosition(cc.p(self.player_name:getPositionX()+self.player_name:getContentSize().width+4+40,self.head_icon:getPositionY()+20))
    end
    --[[if self.msg_time then
        self.msg_time:setAnchorPoint(cc.p(0, 0.5))
        self.msg_time:setPosition(cc.p(537, self.head_icon:getPositionY()+20))
    end--]]

    -- if self.title_icon then 
    --     self.title_icon:setPosition(self.arena_icon:getPositionX()+self.arena_icon:getContentSize().width,self.player_name:getPositionY()+4)
    -- end
    

    self.channel_bg:setPosition(97, total_height-self.channel_bg:getContentSize().height+4)
    self.chat_pic:setPositionY(self.head_icon:getPositionY()+offy-2)
    self.chat_bg:setPositionY(self.head_icon:getPositionY()+offy-2)
    self.talk_time:setPositionY(self.head_icon:getPositionY()+53)
    local offy = 0
    self.content:setAnchorPoint(cc.p(0,0.5))
    self.content:setPosition(35, self.chat_pic:getContentSize().height/2)

    if self.voice_red_icon then
        self.voice_red_icon:setPosition(59, self.chat_pic:getContentSize().height-9)
    end

    --队伍
    if data.len==3 and self.join_btn then
        self.join_btn:setPosition(self.chat_pic:getPositionX()+self.chat_pic:getContentSize().width-8, self.chat_pic:getPositionY()-self.chat_pic:getContentSize().height+7)
    end
    --语音播放
    if data.len==1 then
        self:onVoicePlay()
    end
end
function ChatMsg:createNotice()
     --聊天内容
    --print("=======self.view_width==",self.view_width)
    self.notice_content = createRichLabel(22, 175, cc.p(0, 1), cc.p(70, 25), 5, 0, self.view_width)
    self.notice_content:setLocalZOrder(1)
    self.root_wnd:addChild(self.notice_content)
    self.notice_content:addTouchLinkListener(function(type, value, sender)
        ChatHelp.OnChatTouched(type, value, sender, self.dataObj )
    end, {"click","href"})
end
--如果是自己的话，聊天信息放右边
function ChatMsg:setMyNotice(data)
    if not data then return end
    local pos = self.view_width - 126
    self.head_root:setPosition(cc.p(pos,0))
    local is_other = false

    self.chat_bg:setFlippedX(true)
    self.chat_pic:setPositionY(self.head_icon:getPositionY()-2)
    self.chat_bg:setPosition(cc.p(35, self.head_icon:getPositionY()-2))
    self.content:setAnchorPoint(cc.p(1,0.5))
    self.content:setPosition(cc.p(512,self.chat_pic:getContentSize().height/2))
    
    self.chat_pic:setPosition(cc.p(-500,self.chat_bg:getPositionY()))

    local offx = -5
    local world_x = 0
    local guild_x = 0
    local sex_x = 0

    self.player_name:setAnchorPoint(1,0.5)
    self.player_name:setPosition(cc.p(20,self.head_icon:getPositionY()+20))

    local vip_x = 0
    if self.vip_image then 
        self.vip_image:setAnchorPoint(cc.p(1,0.5))
        vip_x = 15
        self.vip_image:setPosition(cc.p(self.player_name:getPositionX()-self.player_name:getContentSize().width+2,self.player_name:getPositionY()))
    end
    if self.site_txt then
        self.site_txt:setAnchorPoint(cc.p(1, 0.5))
        self.site_txt:setPosition(cc.p(self.player_name:getPositionX()-self.player_name:getContentSize().width+2-20,self.head_icon:getPositionY()+20))
    end
    --[[if self.msg_time then
        self.msg_time:setAnchorPoint(cc.p(1,0.5))
        self.msg_time:setPosition(cc.p(-387, self.head_icon:getPositionY()+20))
    end--]]

    -- if self.title_icon then 
    --     local width = self.title_icon:getContentSize().width*0.8
    --     if width == 0 then 
    --         width = 161*0.8
    --     end
    --     self.title_icon:setPosition(self.arena_icon:getPositionX()-width,self.player_name:getPositionY()+4)
    -- end
end
--显示公告，传闻数据
function ChatMsg:showNotice(data)
    if not self.notice_bg then 
        self.notice_bg = ccui.ImageView:create()
        self.notice_bg:setAnchorPoint(cc.p(0, 1))
        self.root_wnd:addChild(self.notice_bg,0)
         self.notice_bg:setScale9Enabled(true)
         self.notice_bg:loadTexture(PathTool.getResFrame("mainui","mainui_chat_notice_bg"),LOADTEXT_TYPE_PLIST)
         self.notice_bg:setCapInsets(cc.rect(40,30,1,1))
    end
    self.notice_bg:setVisible(true)
    if not self.notice_content then
        self:createNotice()
    end
    self.head_root:removeAllChildren()
    self.head_bg = nil
    self.notice_content:setMaxWidth(self.view_width - 145, false)
    local str = ""
    local color
    --系统频道
    if data.channel == ChatConst.Channel.System then
        color = c3bToStr(Config.ColorData.data_color3[175])
        str = "<div fontColor="..color..">"..data.msg.."</div>"
    --传闻频道
    elseif data.channel == ChatConst.Channel.Notice then
        color = c3bToStr(Config.ColorData.data_color3[175])
        str = "<div fontColor="..color..">"..data.msg.."</div>"
    --帮派系统
    elseif data.channel == ChatConst.Channel.Gang_Sys then
        str = "<div>".. data.msg .. "</div>"
    elseif data.channel == ChatConst.Channel.Team or ChatConst.Channel.Team_Sys then
        str = "<div>".. data.msg .. "</div>"
    end
    self.notice_content:setString(str)
    self.notice_content._clickNode:setTouchEnabled(true)
    self.notice_content._clickNode:setSwallowTouches(false)
    local total_height = self.notice_content:getSize().height
    total_height = total_height + self.gap
    self.root_wnd:setContentSize(self.view_width - 90, total_height+7)
    self:setContentSize(cc.size(self.view_width - 90,total_height))
    self.notice_bg:setContentSize(cc.size(self.view_width - 10,total_height-4))
    self:setAnchorPoint(cc.p(0,1))
    self.channel_bg:setPosition(30, total_height-self.channel_bg:getContentSize().height-10)
    self.notice_content:setPosition(110, total_height-12)
    self.notice_bg:setPosition(3, total_height+3)
    self.notice_content:setVisible(true)
end

--显示资产提示信息
function ChatMsg:showCustomTips(data)
    if not self.notice_content then
        self:createNotice()
    end
    self.head_root:removeAllChildren()
    self.head_bg = nil
    self.notice_content:setMaxWidth(self.view_width,false)
    self.notice_content:setString("<div>"..data.msg.."</div>")
    self.notice_content._clickNode:setTouchEnabled(true)
    self.notice_content._clickNode:setSwallowTouches(false)
    local total_height = self.notice_content:getSize().height
    total_height = total_height + 8
    self.root_wnd:setContentSize(self.view_width, total_height)
    self:setContentSize(cc.size(self.view_width,total_height))
    self:setAnchorPoint(cc.p(0,1))
    self.notice_content:setPosition(0, total_height-1)
    self.channel_bg:setVisible(false)
end

-- 宗门、组队提示
function ChatMsg:showTipsMsg(data)
    if not self.notice_content then
        self:createNotice()
    end
    self.head_root:removeAllChildren()
    self.head_bg = nil
    self.notice_content:setMaxWidth(self.view_width - 65, false)
    local str = ""
    local color
    --帮派频道
    if data.channel == ChatConst.Channel.Gang then
        str = data.msg
    --队伍系统
    elseif data.channel == ChatConst.Channel.Team then
        str = data.msg
    end
    self.notice_content:setString(str)
    self.notice_content._clickNode:setTouchEnabled(true)
    self.notice_content._clickNode:setSwallowTouches(false)
    local total_height = self.notice_content:getSize().height
    total_height = total_height + self.gap
    self.root_wnd:setContentSize(self.view_width, total_height)
    self.channel_bg:setPosition(0, total_height-self.channel_bg:getContentSize().height-3)
    self.notice_content:setPosition(62, total_height-1)
    self.channel_bg:setVisible(true)
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setSwallowTouches(false)
    self.root_wnd:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if data.flag == "openTeam" then
                -- TeamController:getInstance():openMainView()
            elseif data.flag == "openGang" then
                local roleVo = RoleController:getInstance():getRoleVo()
                if roleVo.lev<17 and not roleVo:isHasGuild() then
                    message(TI18N("公会17级开启"))
                -- else
                --     GuildCtrl:getInstance():openPanelByStatus()
                end
            end
        end
    end)
end

--世界的聊天的设置数据
function ChatMsg:setData(data, is_whole)
    self.is_whole = is_whole
    self.dataObj = data
    self:setVoicePlayListener(false)
    self:setVoiceListener(false)
    --队伍招募UI
    local obj = ChatMgr:getInstance():analyseTeamHelp(data)
    if obj then
        self.dataObj = obj
        self:showHead(obj)
        return
    end
    if data.flag == "openTeam" then
        self:setChannel(data.channel)
        self:showTipsMsg(data)
    elseif data.channel == ChatConst.Channel.System or 
        data.channel == ChatConst.Channel.Notice or  
        data.channel == ChatConst.Channel.Gang_Sys  then
        self:setChannel(data.channel)
        self:showNotice(data)
    elseif data.channel == -1 then
        self:showCustomTips(data)
    elseif (data.channel == ChatConst.Channel.Team or data.channel == ChatConst.Channel.Team_Sys) and data.rid ==0 then
        self:setChannel(data.channel)
        self:showNotice(data)
    else
        self:showHead(data)
    end
    if data.rid and data.rid ~=0 and data.srv_id then 
        local role = RoleController:getInstance():getRoleVo()
        if role.rid == data.rid and role.srv_id == data.srv_id then 
            self:setMyNotice(data)
            self.is_myself = true
        end
    end
end

-- 设置频道
function ChatMsg:setChannel(channel)
    channel = channel or ChatConst.Channel.World
    if self.channel ~= channel then
        self.channel_bg:loadTexture(PathTool.getResFrame("mainui","txt_cn_chat_icon_"..ChatConst.ChannelRes[channel]),LOADTEXT_TYPE_PLIST)
        self.channel_label:setString(TI18N(ChatConst.ChannelWord[channel]))
        self.channel_label:setPosition(cc.p(self.channel_bg:getContentSize().width/2,self.channel_bg:getContentSize().height/2))
    end
end

function ChatMsg:setId(id)
    self.id = id
end

function ChatMsg:getId()
    return self.id
end

-- 移除数据
function ChatMsg:removeComps()
    if self.join_btn then
       self.join_btn:DeleteMe()
       self.join_btn = nil
    end
end

-- 翻译语音事件
function ChatMsg:setVoiceListener(bool)
    if bool then
        if not self.voice_evt then
            self.voice_evt = GlobalEvent:getInstance():Bind(VoiceMgr.NewMsg, function(name, msg)
                if self.onTranslateEnd then
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
function ChatMsg:setVoicePlayListener(bool)
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
function ChatMsg:onTranslateEnd(voice_name, voice_msg)
    if self.dataObj and self.dataObj.len==1 and self.dataObj.msg==voice_name then
        self:setData(self.dataObj)
        GlobalEvent:getInstance():Fire(ChatConst.Voice_Translate_Panel)
    end
end

-- 语音播放效果更新
function ChatMsg:onVoicePlay()
    if self.dataObj and self.dataObj.len==1 and self.content["getElementWithIndex"] then
        local icon = self.content:getElementWithIndex(1)
        if icon then
            VoiceMgr:getInstance():showVoiceEffect(icon, VoiceMgr:getInstance():isPlaying(self.dataObj.msg), 13)
        end
        self:showVoiceTishi(not VoiceMgr:getInstance():isPlayed(self.dataObj.msg))
    end
end

-- 播放语音
function ChatMsg:playVoice()
    if self.dataObj and self.dataObj.len==1 then
        VoiceMgr:getInstance():playVoice(self.dataObj.msg)
    end
end

-- 语音红点
function ChatMsg:showVoiceTishi(bool)
    -- if bool and self.dataObj and self.dataObj.len~=1 then
    --     bool = false
    -- end
    -- if bool then
    --     if not self.voiceTishi then
    --         self.voiceTishi = cc.Sprite:create()
    
    --         self.voiceTishi:setScale(0.45)
    --         self.chat_pic:addChild(self.voiceTishi)
    --     end
    --     self.voiceTishi:setPosition(58, self.chat_pic:getContentSize().height-10)
    -- else
    --     if self.voiceTishi and not tolua.isnull(self.voiceTishi) then
    --         self.voiceTishi:removeFromParent()
    --     end
    --     self.voiceTishi = nil
    -- end
end

-- 弹出复制界面检测
function ChatMsg:popUpBegin(str)
    if str == nil then return end
    if string.find(str, "</div>") then
        local parsedtable = require("common.richlabel.labelparser").parse(str)
        if not parsedtable then return end
        str = ""
        for i=1, #parsedtable do
            str = str .. (parsedtable[i].content or "")
        end
    end
    self.copyStr = str
    self.touching = true
    delayRun(self.root_wnd, 2, function()
        if self.touching then
            local x = math.max(50,self.chat_pic:getContentSize().width-80)
            x = math.min(230, x)
            ChatMgr:getInstance():showReportUI(true, self.copyStr, self.root_wnd, self.chat_pic:getPositionX()+x, self.chat_pic:getPositionY()+8)
        end
    end)
end

function ChatMsg:popUpEnd()
    self.touching = nil
end

--重置数据
function ChatMsg:reset()
    -- if self.notice_content then
    --     self.notice_content:setVisible(false)
    -- end
    -- if self.head_root then
    --     self.head_root:setVisible(false)
    -- end
    self.root_wnd:setVisible(false)
end

function ChatMsg:getItemRealSize(  )
    return self.root_wnd:getContentSize()
end

-- 销毁数据
function ChatMsg:DeleteMe()

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    self:setVoiceListener(false)
    self:setVoicePlayListener(false)
    if self.head_icon then 
        self.head_icon:DeleteMe()
    end
    doRemoveFromParent(self.root_wnd)
    self.root_wnd = nil
    self.channel = nil
end
