-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会成员窗体
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildMemberWindow = GuildMemberWindow or BaseClass(BaseView)

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local string_format = string.format

function GuildMemberWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.is_full_screen = false 
	self.win_type = WinType.Big
	self.title_str = TI18N("成员列表")
    self.my_guild_info = model:getMyGuildInfo()
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guild", "guild"), type = ResourcesType.plist}
	}

    self.touch_btn = true
    self.show_menber_list = {} --当前展示的成员列表
end 

function GuildMemberWindow:open_callback()
	self.main_view = createCSBNote(PathTool.getTargetCSB("guild/guild_member_window"))
	self.container:addChild(self.main_view) 

    self.scroll_container = self.main_view:getChildByName("background")
    self.desc = self.main_view:getChildByName("desc")

    self.explain_btn = self.main_view:getChildByName("explain_btn")

    self.exit_btn = self.main_view:getChildByName("exit_btn")
    self.exit_btn_label = self.exit_btn:getChildByName("label")

    self.recruit_btn = self.main_view:getChildByName("recruit_btn")
    self.recruit_btn:getChildByName("label"):setString(TI18N("公会招募"))

    self.checkapply_btn = self.main_view:getChildByName("checkapply_btn")
    self.checkapply_btn:getChildByName("label"):setString(TI18N("查看申请"))

    self.extend_container = self.main_view:getChildByName("extend_container")

    local desc = createRichLabel(18,Config.ColorData.data_color4[175],cc.p(0.5,0.5),cc.p(300,0),nil,nil,450)
    self.extend_container:addChild(desc)
    desc:setString(TI18N("按钮中可执行任命、转让、移除等权限操作"))
    -- self.extend_container:getChildByName("desc"):setString(TI18N("按钮中可执行任命、转让、移除等权限操作"))
end

function GuildMemberWindow:register_event()
    self.recruit_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openGuildApplySetWindow(true)
        end
    end) 
    self.checkapply_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openGuildApplyWindow(true)
        end
    end) 
    self.exit_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.show_type == GuildConst.show_type.all then
                controller:requestExitGuild() --退出公会
            else 
                if not self.touch_btn then return end
                if self.time_ticket == nil then
                    self.time_ticket = GlobalTimeTicket:getInstance():add(function()
                        self.touch_btn = true
                        if self.time_ticket ~= nil then
                            GlobalTimeTicket:getInstance():remove(self.time_ticket)
                            self.time_ticket = nil
                        end
                    end, 2)
                end
                self.touch_btn = nil
                local list = {}
                for k,v in pairs(self.show_menber_list) do
                    table.insert(list, {rid = v.rid, srv_id = v.srv_id})
                end
                controller:send13579(self.show_type, list) --一键提醒
            end
        end
    end) 

    registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
        local config = Config.GuildData.data_const.game_rule
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end,true, 1)


    if self.update_member_list_event == nil then
        self.update_member_list_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateMyMemberListEvent, function(type)
            if type == 0 then return end 
            self:updateMemberList(type)
        end)
    end

    if self.my_guild_info ~= nil then
        if self.update_myguild_event == nil then
            self.update_myguild_event = self.my_guild_info:Bind(GuildEvent.UpdateMyInfoEvent, function(key, value)
                if key == "members_num" or key == "members_max" then
                    self:updateMemberNum()
                end
            end)
        end
    end

    if self.update_assistant_event == nil then
        self.update_assistant_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateAssistantNumEvent, function() 
            if self.role_vo ~= nil and self.role_vo.position ~= GuildConst.post_type.member then
                self:updateMemberNum()
            end
        end)
    end

    self.role_vo = RoleController:getInstance():getRoleVo()
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "gid" then
                    if value == 0 then
                        controller:openGuildMemberWindow(false) 
                    end
                elseif key == "position" then
                    self:updateExitStatus()
                end
            end)
        end 
    end

    if self.update_red_status_event == nil then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateGuildRedStatus, function(red_type, status)
            self:updateApplyRedStatus(red_type, status)
        end)
    end
end

function GuildMemberWindow:openRootWnd(show_type)
    self.show_type = show_type or GuildConst.show_type.all --成员列表打开索引
    
    controller:requestGuildMemberList()     -- 请求公会成员信息
    self:updateApplyRedStatus() --刷新公会申请红点
end

function GuildMemberWindow:updateExitStatus()
    if self.role_vo == nil then return end
    if self.show_type ~= GuildConst.show_type.all then
        self.exit_btn_label:setString(TI18N("一键提醒"))
        self.recruit_btn:setVisible(false)
        self.checkapply_btn:setVisible(false)
        self.exit_btn:setVisible(self.role_vo.position ~= GuildConst.post_type.member)
        if next(self.show_menber_list) == nil then
            self.exit_btn:setVisible(false)
        end
    else
        if self.role_vo.position == GuildConst.post_type.leader then
            self.exit_btn_label:setString(TI18N("解散公会"))
        else
            self.exit_btn_label:setString(TI18N("退出公会")) 
        end
        self.extend_container:setVisible(self.role_vo.position ~= GuildConst.post_type.member)
        self.recruit_btn:setVisible(self.role_vo.position ~= GuildConst.post_type.member)
        self.checkapply_btn:setVisible(self.role_vo.position ~= GuildConst.post_type.member)
    end
end

--申请按钮红点状态
function GuildMemberWindow:updateApplyRedStatus(red_type, status)
    if red_type == GuildConst.red_index.apply then
        addRedPointToNodeByStatus(self.checkapply_btn, status)
    else
        local red_status = model:getRedStatus(GuildConst.red_index.apply)
        addRedPointToNodeByStatus(self.checkapply_btn, red_status)
    end
end

--==============================--
--desc:只有会长或者副会长才做这个处理
--time:2018-06-01 10:52:25
--@return 
--==============================--
function GuildMemberWindow:updateMemberNum()
    if self.show_type ~= GuildConst.show_type.all then
        local tips_str = ""
        if self.show_type == GuildConst.show_type.guild_war then
            tips_str = TI18N("公会战有剩余挑战次数的玩家：%s/%s")
        elseif self.show_type == GuildConst.show_type.guild_donate then
            tips_str = TI18N("公会捐献今日还未捐献的玩家：%s/%s")
        elseif self.show_type == GuildConst.show_type.guild_voyage then
            tips_str = TI18N("公会副本有剩余购买挑战次数的玩家：%s/%s")
        end
        if self.my_guild_info then
            self.desc:setString(string.format(tips_str, #self.show_menber_list, self.my_guild_info.members_max))
        end
    else
        if self.my_guild_info ~= nil and self.role_vo ~= nil then
            if self.role_vo.position == GuildConst.post_type.member then
                self.desc:setString(string.format(TI18N("人数：%s/%s"), self.my_guild_info.members_num, self.my_guild_info.members_max))
            else
                local config = Config.GuildData.data_post[getNorKey(GuildConst.post_type.assistant, self.my_guild_info.lev)]
                if config ~= nil then
                    local num = model:getAssistantSum()
                    self.desc:setString(string.format("%s%s/%s   %s%s/%s", TI18N("人数："), self.my_guild_info.members_num, self.my_guild_info.members_max, TI18N("副会长："), num, config ))
                end 
            end
        end
    end
end

--==============================--
--desc:打开窗体或者收到增删成员的时候才会更新
--time:2018-06-01 10:38:13
--@return 
--==============================--
function GuildMemberWindow:updateMemberList(type)
    self.show_menber_list = model:getGuildMemberList(self.show_type)
    if self.show_menber_list ~= nil and next(self.show_menber_list) ~= nil then
        if self.scroll_view == nil then
            local list_size = cc.size(self.scroll_container:getContentSize().width-10,self.scroll_container:getContentSize().height-20)
            local list_setting = {
                item_class = GuildMemberItem,
                start_x = 4,
                space_x = 4,
                start_y = 0,
                space_y = - 3,
                item_width = 600,
                item_height = 135,
                row = 0,
                col = 1,
                need_dynamic = true
            }
            self.scroll_view = CommonScrollViewLayout.new(self.scroll_container, cc.p(5,7), nil, nil, list_size, list_setting)
        end
        if type == 1 then
            if self.scroll_view then
                self.scroll_view:setData(self.show_menber_list)
            end
        else
            self.scroll_view:resetAddPosition(self.show_menber_list)
        end
    end
    self:updateMemberNum()
    self:updateExitStatus()
end

function GuildMemberWindow:close_callback()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    controller:openGuildMemberWindow(false)
    if self.update_member_list_event  ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_member_list_event)
        self.update_member_list_event = nil
    end
    if self.my_guild_info ~= nil then
        if self.update_myguild_event ~= nil then
            self.my_guild_info:UnBind(self.update_myguild_event)
            self.update_myguild_event = nil
        end
        self.my_guild_info = nil
    end
    if self.update_assistant_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_assistant_event)
        self.update_assistant_event = nil
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
        self.role_vo = nil
    end
    if self.update_red_status_event then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end
    for k,v in pairs(self.show_menber_list) do
        v:DeleteMe()
        v = nil
    end
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      成员列表单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildMemberItem = class("GuildMemberItem", function()
	return ccui.Layout:create()
end)

function GuildMemberItem:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guild/guild_member_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")

    --管理设置按钮
    self.set_post_btn = container:getChildByName("set_post_btn")

    self.role_online = container:getChildByName("role_online")
    self.role_name = container:getChildByName("role_name")
    self.role_position = container:getChildByName("role_position")
    self.role_donate = container:getChildByName("role_donate")
    self.role_day_donate = container:getChildByName("role_day_donate")
    self.role_action = container:getChildByName("role_action")

    container:getChildByName("position_title"):setString(TI18N("职位："))

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(73, 65)
    container:addChild(self.role_head)
    self.role_head:setLev(99) 

    self.container = container

	self:registerEvent()
end

function GuildMemberItem:registerEvent()
	self.role_head:addCallBack(function()
		if self.data ~= nil then
            if self.data.is_self == true then
                message(TI18N("怎么？自己都不认识了？"))
            else
			    FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
            end
		end
	end, false)
	
	self.set_post_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data ~= nil then    
                local role_vo = RoleController:getInstance():getRoleVo()

                if role_vo.position == 1 then
                    if self.data.post ~= GuildConst.post_type.leader then
                        controller:openGuildOperationPostWindow(true, self.data)
                    end
                elseif role_vo.position == 2 then
                    if self.data.post == GuildConst.post_type.member then
                        controller:openGuildOperationPostWindow(true, self.data)
                    elseif self.data.post == GuildConst.post_type.leader then
                        controller:openGuildImpeachPostWindow(true)
                    end
                elseif role_vo.position == 3 then
                    if self.data.post == GuildConst.post_type.leader then
                        controller:openGuildImpeachPostWindow(true)
                    end
                end
            end
		end
	end)
end

function GuildMemberItem:addCallBack(call_back)
	self.call_back = call_back
end

function GuildMemberItem:setData(data)
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end

	if data then
		self.data = data
        self.set_post_btn:setVisible(true)
        self:setBaseData()
        self:setOnLineStatus()
        self:updateBtnStatusByRolePost()
        if self.update_self_event == nil then
            self.update_self_event = self.data:Bind(GuildEvent.UpdateMyMemberItemEvent, function(key, value)
                if key == "post" or key == "role_post" then               -- 只更新职位
                    self:setPostInfo()
                    self:updateBtnStatusByRolePost()
                end
            end) 
        end

        --if data.is_self == true then
        --    self.container:loadTexture(PathTool.getResFrame("common","common_1020"), LOADTEXT_TYPE_PLIST)
        --else
        --    self.container:loadTexture(PathTool.getResFrame("common", "common_1029"), LOADTEXT_TYPE_PLIST)
        --end
	end
end

function GuildMemberItem:setBaseData()
    if self.data == nil then return end
    local data = self.data
    self.role_name:setString(data.name)
    self.role_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
    self.role_head:setLev(data.lev)
    self.role_donate:setString(string.format(TI18N("%s"), data.donate))
    self.role_day_donate:setString(string.format(TI18N("%s"), data.day_donate))
    self.role_action:setString(string.format(TI18N("%s"), data.active_lev))
    self:setPostInfo() 
end

--==============================--
--desc:按钮的一些状态判断，比如说是否是自己需要怎么显示，以及自己是什么职位需要怎么显示
--time:2018-06-03 04:57:10
--@return 
--==============================--
--会长不上线X天可以弹劾
local imprachTime = 3--Config.GuildData.data_const.impeach_offline_day.val
local imprachTime_2 = 7 --成员
function GuildMemberItem:updateBtnStatusByRolePost()
    if self.data == nil then return end
    local role_vo = RoleController:getInstance():getRoleVo()

    if role_vo.position == 1 then
        if self.data.post == GuildConst.post_type.leader then
            self.set_post_btn:setVisible(false)
        else
            self.set_post_btn:setVisible(true)
        end
    elseif role_vo.position == 2 then
        if role_vo.position == self.data.post then --本人
            self.set_post_btn:setVisible(false)
        end
        if self.data.post == GuildConst.post_type.leader then
            local time = GameNet:getInstance():getTime() - self.data.login_time
            if time >= 86400*imprachTime then
                self.set_post_btn:setVisible(true)
            else
                self.set_post_btn:setVisible(false)
            end
        end
    elseif role_vo.position == 3 then
        if self.data.post == GuildConst.post_type.leader then
            local time = GameNet:getInstance():getTime() - self.data.login_time
            if time >= 86400*imprachTime_2 then
                self.set_post_btn:setVisible(true)
            else
                self.set_post_btn:setVisible(false)
            end
        else
            self.set_post_btn:setVisible(false)
        end
    end
end

function GuildMemberItem:setOnLineStatus()
    if self.data == nil then return end
    local data = self.data
    if data.online == FALSE then -- 不在线
        self.role_online:setTextColor(Config.ColorData.data_color4[183])
        local pass_time = GameNet:getInstance():getTime() - data.login_time
        if pass_time <= 60 then -- 小于1分钟
            self.role_online:setString(TI18N("刚刚")) 
        elseif 60 < pass_time and pass_time <= 3600 then -- 大于1分钟小于1小时
            self.role_online:setString(string.format(TI18N("%s分钟前"), math.floor( pass_time / 60 )))
        elseif 3600 < pass_time and pass_time <= 86400 then -- 大于1小时小于24小时
            self.role_online:setString(string.format(TI18N("%s小时前"), math.floor(pass_time / 3600))) 
        elseif 86400 < pass_time and pass_time <= 604800 then -- 大于24小时小于7天
            self.role_online:setString(string.format(TI18N("%s天前"), math.floor(pass_time / 86400)))
        else
            self.role_online:setString(TI18N("7天前")) 
        end
    else
        self.role_online:setTextColor(Config.ColorData.data_color4[178])
        self.role_online:setString(TI18N("在线"))
    end 
end

function GuildMemberItem:setPostInfo()
    if self.data == nil then return end
    local config = Config.GuildData.data_position[self.data.post]
    if config ~= nil then
        if self.data.post == GuildConst.post_type.member then
            self.role_position:setTextColor(Config.ColorData.data_color4[175]) 
        else
            self.role_position:setTextColor(Config.ColorData.data_color4[185]) 
        end
        self.role_position:setString(config.name)
    end
end

function GuildMemberItem:suspendAllActions()
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end 
end

function GuildMemberItem:DeleteMe()
    self:suspendAllActions()
	self:removeAllChildren()
	self:removeFromParent()
end
