-- --------------------------------------------------------------------
-- @author: lwc(必填, 创建模块的人员)
-- @editor: lwc(必填, 后续维护以及修改的人员)
-- @description:
--      系统设置
-- <br/>Create: 2019年5月25日
-- --------------------------------------------------------------------
RoleSystemSetPanel = RoleSystemSetPanel or BaseClass(BaseView)

local controller = RoleController:getInstance()
local model = controller:getModel()

function RoleSystemSetPanel:__init(ctrl)
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.role_vo = controller:getRoleVo()
    self.is_full_screen = true
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.win_type = WinType.Mini
    self.layout_name = "roleinfo/role_system_set_panel" 
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("rolepersonalspace","rolepersonalspace"), type = ResourcesType.plist },
    }          
end

function RoleSystemSetPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)
    self.win_title = self.main_container:getChildByName("win_title")
    self.win_title:setString(TI18N("系统设置"))

    self.page_name_1 = self.main_container:getChildByName("page_name_1")
    self.page_name_1:setString(TI18N("声音设置"))
    self.page_name_2 = self.main_container:getChildByName("page_name_2")
    self.page_name_2:setString(TI18N("其他设置"))

    self.close_btn = self.main_container:getChildByName("close_btn")

    self.music_con = self.main_container:getChildByName("music_con")
    self.music_btn = self.music_con:getChildByName("music_btn")
    local name = self.music_btn:getChildByName("name")
    name:setString(TI18N("音乐"))
    self.sound_btn = self.music_con:getChildByName("sound_btn")
    name = self.sound_btn:getChildByName("name")
    name:setString(TI18N("音效"))
    self.voice_btn = self.music_con:getChildByName("voice_btn")
    name = self.voice_btn:getChildByName("name")
    name:setString(TI18N("语音"))
    self.auto_pk_btn = self.music_con:getChildByName("auto_pk_btn")
    name = self.auto_pk_btn:getChildByName("name")
    name:setString(TI18N("切磋无需验证"))
    self.property_btn = self.music_con:getChildByName("property_btn")
    self.property_btn:getChildByName("name"):setString(TI18N("高品质"))
    self.chat_red_btn = self.music_con:getChildByName("chat_red_btn")
    self.chat_red_btn:getChildByName("name"):setString(TI18N("公频聊天红点"))
    -- self.hide_vip_btn = self.music_con:getChildByName("hide_vip_btn")
    -- self.hide_vip_btn:getChildByName("name"):setString(TI18N("隐藏VIP标识"))
    -- self.hide_vip_btn:setVisible(false)

    self.quit_btn = self.main_container:getChildByName("quit_btn")
    self.quit_btn:getChildByName("label"):setString(TI18N("退出游戏"))

    self.switch_btn = self.main_container:getChildByName("switch_btn")
    self.switch_btn:getChildByName("label"):setString(TI18N("切换账号"))
    
    self.contact_btn = self.main_container:getChildByName("contact_btn")
    self.contact_btn:getChildByName("label"):setString(TI18N("Bug反馈"))
   
    self.exchange_btn = self.main_container:getChildByName("exchange_btn")
    self.exchange_btn:getChildByName("label"):setString(TI18N("礼包兑换"))
    
    self.share_btn = self.main_container:getChildByName("share_btn")
    self.share_btn:getChildByName("label"):setString(TI18N("游戏分享"))
    
    self.invitecode_btn = self.main_container:getChildByName("invitecode_btn")
    self.invitecode_btn:getChildByName("label"):setString(TI18N("推荐码"))
    
    self.main_container:getChildByName("sever_key"):setString(TI18N("当前区服："))
    
    self.sever_name = self.main_container:getChildByName("sever_name")
    if MAKELIFEBETTER then
        self.contact_btn:setVisible(false)
        self.exchange_btn:setVisible(false)
    end
    if not SHOW_GAME_SHARE then
        self.share_btn:setVisible(false)
    end
    if not SHOW_SINGLE_INVICODE then
        self.invitecode_btn:setVisible(false)
    end
    if IS_WIN_PLATFORM then
        self.switch_btn:setVisible(false)
    end
end

function RoleSystemSetPanel:register_event()
    registerButtonEventListener(self.background, function() controller:openRoleSystemSetPanel(false)  end, false, 2)
    registerButtonEventListener(self.close_btn, function() controller:openRoleSystemSetPanel(false)  end, true, 2)

    --退出游戏
    registerButtonEventListener(self.quit_btn, function() sdkOnExit() end, true, 1)
    -- 切换角色
    registerButtonEventListener(self.switch_btn, function() 
        AudioManager:getInstance():stopMusic()
        sdkOnSwitchAccount()
    end, true, 1)


    -- bug按钮
    registerButtonEventListener(self.contact_btn, function() NoticeController:getInstance():openServiceCenterWindow(true) end, true, 1)
    -- 游戏分享按钮
    registerButtonEventListener(self.share_btn, function() WelfareController:getInstance():openMainWindow(true, WelfareIcon.share_game) end, true, 1)
    -- 邀请码按钮
    registerButtonEventListener(self.invitecode_btn, function() WelfareController:getInstance():openMainWindow(true, WelfareIcon.invicode) end, true, 1)
    --礼包兑换
    registerButtonEventListener(self.exchange_btn, function() self:onExchangeBtn() end, true, 1)

    self.music_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.music_is_open, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.music_is_open, false, false) 
        end
    end)

    self.sound_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.audio_is_open, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.audio_is_open, false, false) 
        end
    end)

    self.voice_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.voice_is_open, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.voice_is_open, false, false) 
        end
    end)

    self.auto_pk_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            controller:sender10318(1)
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            controller:sender10318(0)
        end
    end)

    self.chat_red_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.chat_red_open, true, false)
            GlobalEvent:getInstance():Fire(EventId.CHAT_NEWMSG_FLAG)
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.chat_red_open, false, false)
            GlobalEvent:getInstance():Fire(EventId.CHAT_NEWMSG_FLAG)
        end
    end)

    self.property_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.high_quality, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.high_quality, false, false) 
        end
    end)

    self:addGlobalEvent(NoticeEvent.All_Feedback_Event_Data, function()  --
            local status = NoticeController:getInstance():getModel():getRedStatus() or false
            addRedPointToNodeByStatus( self.contact_btn, status, 6, 6, nil)
    end)

    -- self.hide_vip_btn:addEventListener(function ( sender,event_type )
    --     if event_type == ccui.CheckBoxEventType.selected then
    --         playButtonSound2()
    --         controller:sender10348(1)
    --     elseif event_type == ccui.CheckBoxEventType.unselected then
    --         playButtonSound2()
    --         controller:sender10348(0)
    --     end
    -- end)

end
function RoleSystemSetPanel:onExchangeBtn()
    local function confirm_callback(str)
        if str == nil or str == "" then
            message(TI18N("请输入正确的兑换码"))
            return
        end
        local text = string.gsub(str, "\n", "")
        controller:sender10945(text)
    end

    local function cancel_callback()

    end

    CommonAlert.showInputApply(nil, TI18N("请输入正确的兑换码"), TI18N("兑换"), confirm_callback, nil, nil, true, cancel_callback, 18, CommonAlert.type.rich, FALSE)
end

function RoleSystemSetPanel:openRootWnd()
    self:setData()
    NoticeController:getInstance():sender10813()   --客服中心红点
end

function RoleSystemSetPanel:setData()
    --音乐
    local music_open = SysEnv:getInstance():getBool(SysEnv.keys.music_is_open,true)
    self.music_btn:setSelected(music_open)
    --音效
    local audio_open = SysEnv:getInstance():getBool(SysEnv.keys.audio_is_open,true)
    self.sound_btn:setSelected(audio_open)
    --语音
    local voice_open = SysEnv:getInstance():getBool(SysEnv.keys.voice_is_open,true)
    self.voice_btn:setSelected(voice_open)
    -- pk验证
    self.auto_pk_btn:setSelected(self.role_vo.auto_pk == 1)
    -- 高品质
    local quality_open = SysEnv:getInstance():getBool(SysEnv.keys.high_quality,true)
    self.property_btn:setSelected(quality_open)
    -- 聊天红点显示
    local chat_red_open = SysEnv:getInstance():getBool(SysEnv.keys.chat_red_open,true)
    self.chat_red_btn:setSelected(chat_red_open)

    local name = getServerName(self.role_vo.srv_id) or ""
    self.sever_name:setString(name)
end



function RoleSystemSetPanel:close_callback()
    
    SysEnv:getInstance():save()
    controller:openRoleSystemSetPanel(false)
end
