-- --------------------------------------------------------------------
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: shuwen(必填, 后续维护以及修改的人员)
-- @description:
--      角色设置面板
-- <br/>Create: 2018-05-15
-- --------------------------------------------------------------------
RoleSetWindow = RoleSetWindow or BaseClass(BaseView)

function RoleSetWindow:__init(ctrl)
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.ctrl = ctrl
	self.role_vo = self.ctrl:getRoleVo()
    self.is_full_screen = true
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.win_type = WinType.Mini
    self.layout_name = "roleinfo/role_set_window" 
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("face","face"), type = ResourcesType.plist },
    }      	   
end

function RoleSetWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)

	self.title_container = self.main_container:getChildByName("title_container")
	self.title_label = self.title_container:getChildByName("title_label")
	self.title_label:setString(TI18N("设置"))

	self.close_btn = self.main_container:getChildByName("close_btn")

	self.info_con = self.main_container:getChildByName("info_con")
	self.name = self.info_con:getChildByName("name")
	self.pen = self.info_con:getChildByName("pen")
	self.country = self.info_con:getChildByName("country")
	local title = self.info_con:getChildByName("title")
	title:setString(TI18N("称号："))
	self.title_val = self.info_con:getChildByName("title_val")
	self.title_val:setString(TI18N("暂无"))
	-- self.change_btn = self.info_con:getChildByName("change_btn")
	-- self.change_btn:setTitleText(TI18N("更改"))
 --    self.change_btn.label = self.change_btn:getTitleRenderer()
 --    if self.change_btn.label ~= nil then
 --        self.change_btn.label:enableOutline(Config.ColorData.data_color4[175], 2)
 --    end
	self.head = PlayerHead.new(PlayerHead.type.circle)
    self.head:setAnchorPoint(cc.p(0, 0))
    self.head:setPosition(cc.p(20, 40))
    self.info_con:addChild(self.head,-1)

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
    self.hide_vip_btn = self.music_con:getChildByName("hide_vip_btn")
    self.hide_vip_btn:getChildByName("name"):setString(TI18N("隐藏VIP标识"))
    self.hide_vip_btn:setVisible(false)

    self.btn_con = self.main_container:getChildByName("btn_con")
    self.quit_btn = self.btn_con:getChildByName("quit_btn")
    self.quit_btn:setTitleText(TI18N("退出游戏"))
    self.quit_btn.label = self.quit_btn:getTitleRenderer()
    if self.quit_btn.label ~= nil then
        self.quit_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
    self.switch_btn = self.btn_con:getChildByName("switch_btn")
    self.switch_btn:setTitleText(TI18N("切换账号"))
    self.switch_btn.label = self.switch_btn:getTitleRenderer()
    if self.switch_btn.label ~= nil then
        self.switch_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
    self.contact_btn = self.btn_con:getChildByName("contact_btn")
    self.contact_btn:setTitleText(TI18N("Bug反馈"))
    self.contact_btn.label = self.contact_btn:getTitleRenderer()
    if self.contact_btn.label ~= nil then
        self.contact_btn.label:enableOutline(Config.ColorData.data_color4[263], 2)
    end
    self.exchange_btn = self.btn_con:getChildByName("exchange_btn")
    self.exchange_btn:setTitleText(TI18N("礼包兑换"))
    self.exchange_btn.label = self.exchange_btn:getTitleRenderer()
    if self.exchange_btn.label ~= nil then
        self.exchange_btn.label:enableOutline(Config.ColorData.data_color4[263], 2)
    end
    self.share_btn = self.btn_con:getChildByName("share_btn")
    self.share_btn:setTitleText(TI18N("游戏分享"))
    self.share_btn.label = self.share_btn:getTitleRenderer()
    if self.share_btn.label ~= nil then
        self.share_btn.label:enableOutline(Config.ColorData.data_color4[263], 2)
    end
    self.invitecode_btn = self.btn_con:getChildByName("invitecode_btn")
    self.invitecode_btn:setTitleText(TI18N("推荐码"))
    self.invitecode_btn.label = self.invitecode_btn:getTitleRenderer()
    if self.invitecode_btn.label ~= nil then
        self.invitecode_btn.label:enableOutline(Config.ColorData.data_color4[263], 2)
    end

    self.model_con = self.main_container:getChildByName("model_con")
    self.change_btn = self.model_con:getChildByName("change_btn")
    self.change_btn:setTitleText(TI18N("个性设置"))
    self.title_img = self.model_con:getChildByName("title_img")
    if MAKELIFEBETTER then
        self.contact_btn:setVisible(false)
        self.exchange_btn:setVisible(false)
        self.change_btn:setVisible(false)
    end
    if not SHOW_GAME_SHARE then
        self.share_btn:setVisible(false)
    end
    if not SHOW_SINGLE_INVICODE then
        self.invitecode_btn:setVisible(false)
    end

    --称号信息
    self.ctrl:sender23300()
    --形象信息
    self.ctrl:requestRoleModelInfo()

    --self:setData()
end

function RoleSetWindow:openRootWnd()

end

function RoleSetWindow:setData()
	self.name:setString(self.role_vo.name)
    self.head:setHeadRes(self.role_vo.face_id, false, LOADTEXT_TYPE, self.role_vo.face_file, self.role_vo.face_update_time)
    self.head:setLev(self.role_vo.lev)
    self.head:setSex(self.role_vo.sex,cc.p(80,4))
    --头像框
    local vo = Config.AvatarData.data_avatar[self.role_vo.avatar_base_id]
    if vo then
        local res_id = vo.res_id or 1 
        local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id,false,false)
        self.head:showBg(res,nil,false,vo.offy)
    end
    --称号
    local vo = Config.HonorData.data_title[self.use_id]
    if vo then
        self.title_val:setString(vo.name)
    end

    if vo and vo.res_id then 
        local res = PathTool.getTargetRes("honor","txt_cn_honor_"..vo.res_id,false,false)
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
                if not tolua.isnull(self.title_img) then
                    loadSpriteTexture(self.title_img, res, LOADTEXT_TYPE)
                end
        end,self.item_load)
    end

    self:updateSpine(self.role_vo.look_id)

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

    self.auto_pk_btn:setPositionY(self.hide_vip_btn:getPositionY())
end

--改变模型
function RoleSetWindow:updateSpine( look_id )
    if not look_id then return end
    if self.record_look_id  and  self.record_look_id  == look_id then
        return 
    end
    self.record_look_id  = look_id
    local fun = function()
        if not self.spine then
            self.spine = BaseRole.new(BaseRole.type.role, look_id)
            self.spine:setAnimation(0,PlayerAction.show,true) 
            self.spine:setCascade(true)
            --self.spine:setPosition(cc.p(105,240))
            if partner_id == 21005 then 
                self.spine:setPosition(cc.p(110,295))
            else
                self.spine:setPosition(cc.p(110,250))
            end
            self.spine:setAnchorPoint(cc.p(0.5,0)) 
            self.spine:setScale(0.8)
            self.model_con:addChild(self.spine) 
            self.spine:setCascade(true)
            self.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(cc.Sequence:create(action))
        end
    end
    if self.spine then
        self.spine:setCascade(true)
        
        local action = cc.FadeOut:create(0.2)
        self.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                doStopAllActions(self.spine)
                self.spine:removeFromParent()
                self.spine = nil
                fun()
        end)))
    else
        fun()
    end

end

function RoleSetWindow:register_event()
    --获取称号
    if self.updateList == nil then
        self.updateList = GlobalEvent:getInstance():Bind(RoleEvent.GetTitleList,function ( data )
            self.use_id = data.base_id --正在使用的称号
            -- if data and data.honor then 
            --     for i,v in pairs(data.honor) do 
            --         if v and v.base_id then 
            --             self.use_id = v.base_id --正在使用的称号
            --         end
            --     end
            -- end
            self:setData()
        end)
    end

    if self.updateHaveList_event == nil then
        self.updateHaveList_event = GlobalEvent:getInstance():Bind(RoleEvent.UpdataTitleList,function ( data )
            -- if data and data.honor then 
            --     for i,v in pairs(data.honor) do 
            --         if v and v.base_id then 
            --             --self.use_id = v.base_id --正在使用的称号
            --         end
            --     end
            -- end
            -- self:setData()
        end)
    end
    --使用称号
    if self.use_event == nil then
        self.use_event = GlobalEvent:getInstance():Bind(RoleEvent.UseTitle,function ( id )
            if id then
                self.use_id = id
                self:setData()
            end
        end)
    end

    --形象信息
    if not self.updateModelList then
        self.updateModelList = GlobalEvent:getInstance():Bind(RoleEvent.GetModelList,function ( data )
            if data ~= nil then
                self:updateSpine(data.use_id)
            end

        end)
    end

	self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			self.ctrl:openNewRoleInfoView(false)
		end
	end)

	self.change_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			self.ctrl:openRoleDecorateView(true)
			self.ctrl:openNewRoleInfoView(false)
		end
    end)
    
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self.ctrl:openNewRoleInfoView(false)
            end
        end)
    end

	self.music_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.music_is_open, true, nil) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.music_is_open, false, nil) 
        end
    end)

    self.sound_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.audio_is_open, true, nil) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.audio_is_open, false, nil) 
        end
    end)

    self.voice_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.voice_is_open, true, nil) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.voice_is_open, false, nil) 
        end
    end)

    self.auto_pk_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            RoleController:getInstance():sender10318(1)
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            RoleController:getInstance():sender10318(0)
        end
    end)

    self.property_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.high_quality, true, nil) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.high_quality, false, nil) 
        end
    end)

    self.hide_vip_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            RoleController:getInstance():sender10348(1)
        elseif event_type == ccui.CheckBoxEventType.unselected then
            playButtonSound2()
            RoleController:getInstance():sender10348(0)
        end
    end)

     --改名
    if self.pen ~= nil then
        self.pen:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.role_vo.sex == 2 then
                    self.ctrl:openRoleChangeNameView(true)
                else
                    local function confirm_callback(str)
                        if str == nil or str == "" then
                            message(TI18N("名字不合法"))
                            return
                        end
                        if not self.role_vo then return end
                        local text = string.gsub(str, "\n", "")
                        RoleController:getInstance():changeRoleName(text,self.role_vo.sex)
                        --self.alert:close()
                        --self.alert = nil
                    end
                    local function cancel_callback()
                        --self.alert:close()
                        --self.alert = nil
                    end

                    --if self.alert == nil then
                        local msg = TI18N(string.format("<div fontcolor=#a95f0f>改名需消耗200 <img src=%s scale=0.3 visible=true /></div>",PathTool.getItemRes(Config.ItemData.data_get_data(3).icon)))
                        if self.role_vo ~= nil and self.role_vo.is_first_rename == TRUE then
                            msg = TI18N("首次更改免费哦~")
                        end
                        self.alert = CommonAlert.showInputApply(msg, TI18N("请输入名字(限制6字)"), TI18N("确 定"), 
                            confirm_callback, TI18N("取 消"), cancel_callback, true, cancel_callback, 20, CommonAlert.type.rich, FALSE,
                            cc.size(270,50),nil,{off_y=-15})
                        self.alert.alert_txt:setPositionY(20)
                        self.alert.line:setVisible(false)

                        local label = createLabel(26,Config.ColorData.data_color4[175],nil,75,75,TI18N("名字："),self.alert.alert_panel)
                    --end
                end
            end
        end)
    end

    if self.role_vo then
        if self.role_update_event == nil then
            self.role_update_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key,value)
                if key == "face_id" or key == "avatar_base_id" or key == "name" or key == "sex" or key == "look_id" then
                    self:setData()
                end
            end)
        end
    end

    --退出游戏
    if self.quit_btn ~= nil then
        self.quit_btn:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                sdkOnExit()
            end
        end)
    end

     -- 切换角色
    if self.switch_btn ~= nil then
        self.switch_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                AudioManager:getInstance():stopMusic()
                sdkOnSwitchAccount()
            end
        end)
    end

    --礼包兑换
    if self.exchange_btn ~= nil then
    	self.exchange_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
               	local function confirm_callback(str)
                	if str == nil or str == "" then
                    	message(TI18N("请输入正确的兑换码"))
                    	return
                    end
                    local text = string.gsub(str, "\n", "")
                    RoleController:getInstance():sender10945(text)
                end

                local function cancel_callback()

                end

                     CommonAlert.showInputApply(nil, TI18N("请输入正确的兑换码"), TI18N("兑换"), 
                           		confirm_callback, nil, nil, true, cancel_callback, 18, CommonAlert.type.rich, FALSE)
            end
        end)
    end

    -- bug按钮
    if self.contact_btn ~= nil then
        self.contact_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                NoticeController:getInstance():openServiceCenterWindow(true)
            end
        end)
    end

    -- 游戏分享按钮
    if self.share_btn ~= nil then
        self.share_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                WelfareController:getInstance():openMainWindow(true, WelfareIcon.share_game)
            end
        end)
    end

    -- 邀请码按钮
    if self.invitecode_btn ~= nil then
        self.invitecode_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                WelfareController:getInstance():openMainWindow(true, WelfareIcon.invicode)
            end
        end)
    end
end

function RoleSetWindow:closeSetNameAlert(  )
    if self.alert then
        self.alert:close()
        self.alert = nil
    end
end

function RoleSetWindow:close_callback()
    if self.updateList ~= nil then
        GlobalEvent:getInstance():UnBind(self.updateList)
        self.updateList = nil
    end

    if self.use_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.use_event)
        self.use_event = nil
    end
    if self.updateHaveList_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.updateHaveList_event)
        self.updateHaveList_event = nil
    end
    if self.role_vo then
        if self.role_update_event ~= nil then
            self.role_vo:UnBind(self.role_update_event)
            self.role_update_event = nil
        end
        self.role_vo = nil
    end

    if self.updateModelList then
        self.updateModelList = GlobalEvent:getInstance():UnBind(self.updateModelList)
        self.updateModelList = nil
    end

    if self.head then 
        self.head:DeleteMe()
        self.head = nil
    end

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

	SysEnv:getInstance():save()
	self.ctrl:openNewRoleInfoView(false)
end
