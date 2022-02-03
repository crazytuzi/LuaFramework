-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会捐献面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildDonateWindow = GuildDonateWindow or BaseClass(BaseView)

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local string_format = string.format

function GuildDonateWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
	self.win_type = WinType.Big
	self.title_str = TI18N("捐献")
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guild", "guild"), type = ResourcesType.plist}
    } 
    self.awards_list = {}
end  

function GuildDonateWindow:open_callback()
    self.main_view = createCSBNote(PathTool.getTargetCSB("guild/guild_donate_window"))
    self.container:addChild(self.main_view) 
    local main_view = self.main_view

    main_view:getChildByName("day_exp"):setString(TI18N("今日统计：")) 
    main_view:getChildByName("next_lev_title"):setString(TI18N("下一等级：")) 
    main_view:getChildByName("notice"):setString(TI18N("每天只能捐献1次，每天0点重置")) 

    self.progress_bar = main_view:getChildByName("progress_bar")    -- 积分进度条
    self.progress_bar:setScale9Enabled(true) 
    self.lev_title = main_view:getChildByName("lev_title")          -- 公会等级
    self.exp_value = main_view:getChildByName("exp_value")          -- 今日捐献的值
    self.explain_btn = main_view:getChildByName("explain_btn")      -- 说明面板

    self.total_width = self.progress_bar:getContentSize().width
    self.start_x = self.progress_bar:getPositionX()

    self.awards = main_view:getChildByName("awards")
    self.awards:setVisible(false)

    local config = Config.GuildData.data_const.day_exp_max
    if config then
        for i,v in ipairs(Config.GuildData.data_donate_box) do
            local awards = self.awards:clone()
            awards:setVisible(true)
            local container = awards:getChildByName("container")
            local value = awards:getChildByName("value")
            value:setString(v.box_val)
            main_view:addChild(awards)
            local percent = v.box_val / config.val -- 设置位置
            awards:setPosition(self.start_x + self.total_width * percent, 56)

            local object = {}
            object.item = awards 
            object.container = container 
            object.status = GuildConst.status.normal
            object.id = i
            object.config = v  --{box_val = 1000, rewards = {{10, 250}, {2, 2500}}, effect_id = 109}, 
            object.is_show_tips = true
            self.awards_list[i] = object
        end
    end

    self.desc = createRichLabel(24, 175, cc.p(0, 0.5), cc.p(142, 732), nil, nil, 500) 
    main_view:addChild(self.desc)

    self.donate_container = main_view:getChildByName("donate_container")
    local size = self.donate_container:getContentSize()
    local setting = {
        item_class = GuildDonateItem,
        start_x = 4,
        space_x = 4,
        start_y = 4,
        space_y = 0,
        item_width = 614,
        item_height = 187,
        row = 0,
        col = 1
    }
    self.scroll_view = CommonScrollViewLayout.new(self.donate_container, nil, nil, nil, size, setting) 
end

function GuildDonateWindow:register_event()
    registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
        local config = Config.GuildData.data_const.game_rule1
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end,true, 1)

    for k,object in pairs(self.awards_list) do
        object.item:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                if object.config then
                    if object.is_show_tips == true then
                        CommonAlert.showItemApply(TI18N("当前捐献活跃度奖励"),object.config.rewards, nil, TI18N("确定"), nil, nil, TI18N("奖励"), nil, nil, true )
                    else
                        controller:requestDonateBoxRewards(object.id)
                    end
                end
            end
        end)
    end

    if self.my_guild_info == nil then
        self.my_guild_info = model:getMyGuildInfo()
        if self.my_guild_info ~= nil and self.update_guild_event == nil then
            self.update_guild_event = self.my_guild_info:Bind(GuildEvent.UpdateMyInfoEvent, function(key, value) 
                if key == "lev" then
                    self:updateMyGuildLev()
                end
            end)
        end
    end
    if self.update_donate_event == nil then
        self.update_donate_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateDonateInfo, function() 
            self:updateDonateListStatus()
        end)
    end

    if self.update_donate_box_status_event == nil then
        self.update_donate_box_status_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateDonateBoxStatus, function(id) 
            if id ~= nil then
                local object = self.awards_list[id]
                if object then
                    object.is_show_tips = true
                    object.status = GuildConst.status.finish
                    if not tolua.isnull(object.box_effect) then 
                        object.box_effect:clearTracks()
                        object.box_effect:setToSetupPose()
                        object.box_effect:setAnimation(0, PlayerAction.action_3, true)
                    end
                end
            else
                self:updateDonateBoxList()
            end
        end)
    end
end

function GuildDonateWindow:openRootWnd()
    local config_list = Config.GuildData.data_donate
    self.scroll_view:setData(config_list)
    self:updateDonateBoxList()
    self:updateMyGuildLev()
end

--==============================--
--desc:更新活跃度宝箱
--time:2018-07-11 03:50:52
--@return 
--==============================--
function GuildDonateWindow:updateDonateBoxList()
    local activity_value = model:getDonateActivityValue()
    self.exp_value:setString(activity_value)
    local config = Config.GuildData.data_const.day_exp_max
    if config == nil then return end
    self.progress_bar:setPercent(100 * activity_value / config.val) 

    for i, object in ipairs(self.awards_list) do
        local config = object.config
        local box_status = model:getDonateBoxStatus(object.id)
        local tmp_status = GuildConst.status.normal
        if box_status == true then                              -- 已经完成了
            tmp_status = GuildConst.status.finish
        else
            if activity_value >= object.config.box_val then     -- 可提交
                tmp_status = GuildConst.status.activity
            else
                tmp_status = GuildConst.status.un_activity
            end
        end
        local box_action = PlayerAction.action_1
        if tmp_status == GuildConst.status.finish then
            box_action = PlayerAction.action_3
        elseif tmp_status == GuildConst.status.activity then
            box_action = PlayerAction.action_2
        end
        if tmp_status == GuildConst.status.activity then
            object.is_show_tips = false
        else
            object.is_show_tips = true
        end

        if not tolua.isnull(object.box_effect) then
            if tmp_status ~= object.status then
                object.status = tmp_status
                object.box_effect:clearTracks()
                object.box_effect:setToSetupPose()
                object.box_effect:setAnimation(0, box_action, true)
            end
        else
            object.status = tmp_status
            delayRun(self.main_view, 2 * i / display.DEFAULT_FPS, function()
                local box = createEffectSpine(PathTool.getEffectRes(object.config.effect_id), cc.p(object.container:getContentSize().width * 0.5, 8), cc.p(0.5, 0), true, box_action)
                object.container:addChild(box)
                object.box_effect = box
            end)
        end
    end
end

--==============================--
--desc:设置等级相关
--time:2018-06-04 11:32:02
--@return 
--==============================--
function GuildDonateWindow:updateMyGuildLev()
    if self.my_guild_info == nil then return end
    self.lev_title:setString(string.format(TI18N("公会等级：%s级"),self.my_guild_info.lev))
    
    local next_lev = self.my_guild_info.lev + 1
    local config = Config.GuildData.data_guild_lev[next_lev]
    if config == nil then -- 达到最大值
        self.desc:setString(TI18N("当前已达最大值！"))
    else
        self.desc:setString(config.desc)
    end
end

function GuildDonateWindow:updateDonateListStatus()
    local item_list = self.scroll_view:getItemList()
    if item_list ~= nil then
        for k,v in pairs(item_list) do
            if v.updateDonateStatus then
                v:updateDonateStatus()
            end
        end
    end
end

function GuildDonateWindow:close_callback()
    self.main_view:stopAllActions()

    for i, object in ipairs(self.awards_list) do
        if object.box_effect then
            object.box_effect:setVisible(false)
            object.box_effect:removeFromParent()
        end
    end
    self.awards_list = nil

    controller:openGuildDonateWindow(false)
    if self.my_guild_info ~= nil then
        if self.update_guild_event ~= nil then
            self.my_guild_info:UnBind(self.update_guild_event)
            self.update_guild_event = nil
        end
        self.my_guild_info = nil
    end
    if self.update_donate_event then
        GlobalEvent:getInstance():UnBind(self.update_donate_event)
        self.update_donate_event = nil
    end
    if self.update_donate_box_status_event then
        GlobalEvent:getInstance():UnBind(self.update_donate_box_status_event)
        self.update_donate_box_status_event = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end


-- -------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      捐献单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildDonateItem = class("GuildDonateItem", function()
	return ccui.Layout:create()
end)

function GuildDonateItem:ctor()
    self.awards_list = {}           -- 富文本奖励列表
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guild/guild_donate_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")

    self.donate_btn = container:getChildByName("donate_btn")
    self.donate_btn_label = self.donate_btn:getChildByName("label")
    self.donate_btn_label:setString(TI18N("捐献"))

    self.pass_donate = container:getChildByName("pass_donate")

    self.img = container:getChildByName("img")              -- 捐献类型的图片资源
    self.title_desc = container:getChildByName("title_desc")        -- 捐献的描述

    self.item_img = container:getChildByName("item_img")            -- 捐献的资产图片
    self.donate_value = container:getChildByName("donate_value")    -- 资产消耗

    self.container = container 
	
	self:registerEvent()
end

function GuildDonateItem:registerEvent()	
	self.donate_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            if self.data ~= nil then
                controller:requestGuildDonate(self.data.id)
            end
		end
	end)
end

function GuildDonateItem:addCallBack(call_back)
	self.call_back = call_back
end

function GuildDonateItem:setData(data)
    self.data = data
    self:updateDonateStatus()
    if data ~= nil then
        self.title_desc:setString(data.desc)

        if self.data.loss ~= nil then
            local loss_config = self.data.loss[1]
            if loss_config ~= nil then
                local item_config = Config.ItemData.data_get_data(loss_config[1]) 
                if item_config ~= nil then
                    loadSpriteTexture(self.item_img, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
                    self.donate_value:setString(loss_config[2])
                end
            end
        end

        if self.data.gain ~= nil then
            local _y = 0
            for i,v in ipairs(self.data.gain) do
                if self.awards_list[i] == nil then
                    local item_config = Config.ItemData.data_get_data(v[1]) 
                    if item_config ~= nil then
                        _y = 96 - (i-1)*50 
                        self.awards_list[i] = createRichLabel(26, 178, cc.p(0, 0.5), cc.p(266, _y), nil, nil, 250)
                        self.root_wnd:addChild(self.awards_list[i])
                        self.awards_list[i]:setString(string.format("<img src=%s visible=true scale=0.4 /> %s", PathTool.getItemRes(item_config.icon), v[2]))
                    end
                end
            end
        end
        local res_id = PathTool.getResFrame("guild",string.format("txt_cn_guild_100%s", self.data.id))
        if self.res_id ~= res_id then
            self.res_id = res_id
            loadSpriteTexture(self.img, res_id, LOADTEXT_TYPE_PLIST) 
        end
    end
end

--==============================--
--desc:捐献情况的更新
--time:2018-06-04 11:56:06
--@return 
--==============================--
function GuildDonateItem:updateDonateStatus()
    if self.data == nil then return end
    local status, self_status = model:checkDonateStatus(self.data.id)
    if status == true then                          -- 已经没有捐献次数的情况
        if self_status == true then                 -- 该类型已经捐献
            self.pass_donate:setVisible(true)
            self.donate_btn:setVisible(false) 
            self.donate_btn_label:setString(TI18N("已捐献")) 
        else
            setChildUnEnabled(true, self.donate_btn)
            self.donate_btn:setTouchEnabled(false)
            self.donate_btn_label:disableEffect() 
            self.donate_btn_label:setString(TI18N("不可捐献")) 
            self.donate_btn:setVisible(true)
            self.pass_donate:setVisible(false) 
        end
    else
        setChildUnEnabled(false, self.donate_btn)
        self.donate_btn:setTouchEnabled(true)
        self.donate_btn_label:enableOutline(Config.ColorData.data_color4[263], 2)
        self.donate_btn_label:setString(TI18N("捐献")) 
        self.donate_btn:setVisible(true)
        self.pass_donate:setVisible(false) 
    end
end

function GuildDonateItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 