-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      入帮申请设置面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildApplySetWindow = GuildApplySetWindow or BaseClass(BaseView)

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local string_format = string.format

function GuildApplySetWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Mini
    self.set_index = 1
    self.condition_index = 1 
    self.condition_index_2 = 1 
    self.layout_name = "guild/guild_apply_set_window"
    self:initConditionList()
end 

function GuildApplySetWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 1)

    self.close_btn = container:getChildByName("close_btn")
    self.confirm_btn = container:getChildByName("confirm_btn")
    self.recruit_btn = container:getChildByName("recruit_btn")
    self.set_value = container:getChildByName("set_value")
    self.condition_value = container:getChildByName("condition_value")
    self.condition_left = container:getChildByName("condition_left")
    self.condition_right = container:getChildByName("condition_right")
    self.condition_value_2 = container:getChildByName("condition_value_2")
    self.condition_left_2 = container:getChildByName("condition_left_2")
    self.condition_right_2 = container:getChildByName("condition_right_2")
    self.set_left = container:getChildByName("set_left")
    self.set_right = container:getChildByName("set_right")  

    container:getChildByName("win_title"):setString(TI18N("入会设置")) 
    container:getChildByName("set_title"):setString(TI18N("验证设置："))
    container:getChildByName("condition_title"):setString(TI18N("入会要求："))
    container:getChildByName("condition_title_2"):setString(TI18N("战力要求："))
    self.recruit_btn:getChildByName("label"):setString(TI18N("发布招募"))
    self.confirm_btn:getChildByName("label"):setString(TI18N("确定"))
end

function GuildApplySetWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openGuildApplySetWindow(false) 
        end
    end) 
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openGuildApplySetWindow(false) 
        end
    end) 
    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local config = self.condition_list[self.condition_index]
            local config_2 = self.condition_list_2[self.condition_index_2]
            if config and config_2 then
                controller:requestChangeApplySet(self.set_index, config.lev, config_2)
            end
        end
    end)
    self.recruit_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openGuildApplySetWindow(false) 
            controller:requestGuildRecruit()
        end
    end) 
    self.condition_left:addTouchEventListener(
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.condition_index == 1 then return end
                self.condition_index = self.condition_index - 1
                self:setGuildConditionInfo(self.condition_index)
            end
        end
    )
    self.condition_right:addTouchEventListener(
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.condition_index >= #self.condition_list then return end
                self.condition_index = self.condition_index + 1
                self:setGuildConditionInfo(self.condition_index)
            end
        end
    )

    self.condition_left_2:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.condition_index_2 == 1 then return end
            self.condition_index_2 = self.condition_index_2 - 1
            self:setGuildConditionInfo2(self.condition_index_2) 
        end
    end) 
    self.condition_right_2:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.condition_index_2 >= #self.condition_list_2 then return end
            self.condition_index_2 = self.condition_index_2 + 1
            self:setGuildConditionInfo2(self.condition_index_2) 
        end
    end) 
    self.set_left:addTouchEventListener(
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.set_index == 0 then return end
                self.set_index = self.set_index - 1
                self:setGuildSetInfo(self.set_index)
            end
        end
    )
    self.set_right:addTouchEventListener(
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.set_index == 1 then return end
                self.set_index = self.set_index + 1
                self:setGuildSetInfo(self.set_index)
            end
        end
    ) 
end

function GuildApplySetWindow:openRootWnd()
    local my_info = model:getMyGuildInfo()
    if my_info ~= nil then 
        self.set_index = my_info.apply_type
        self:setGuildSetInfo(self.set_index)

        local condition_lev = my_info.apply_lev
        for i,v in ipairs(self.condition_list) do
            if v.lev == condition_lev then
                self.condition_index = i
                break
            end
        end
        self:setGuildConditionInfo(self.condition_index) 

        local power = my_info.apply_power
        for i,value in ipairs(self.condition_list_2) do
            if value == power then
                self.condition_index_2 = i
                break
            end
        end
        self:setGuildConditionInfo2(self.condition_index_2) 
    end
end

function GuildApplySetWindow:setGuildConditionInfo(index)
	local config = self.condition_list[index]
	if config ~= nil then
		self.condition_value:setString(config.desc)
	end

    local status = 1
    if index == 1 then
        status = 1
    elseif index == #self.condition_list then
        status = 2
    else
        status = 3
    end
    if self.condition_status ~= status then
        self.condition_status = status
        if status == 1 then
            self.condition_left:setTouchEnabled(false)
            self.condition_right:setTouchEnabled(true)
            setChildUnEnabled(true, self.condition_left)
            setChildUnEnabled(false, self.condition_right)
        elseif status == 2 then
            self.condition_left:setTouchEnabled(true)
            self.condition_right:setTouchEnabled(false)
            setChildUnEnabled(false, self.condition_left)
            setChildUnEnabled(true, self.condition_right)
        else
            self.condition_left:setTouchEnabled(true)
            self.condition_right:setTouchEnabled(true)
            setChildUnEnabled(false, self.condition_left)
            setChildUnEnabled(false, self.condition_right)
        end
    end
end

function GuildApplySetWindow:setGuildConditionInfo2(index)
    local value = self.condition_list_2[index]
    if value ~= nil then
        local value_str = MoneyTool.GetMoneyString(value)
        self.condition_value_2:setString(value_str) 
    end

    local status = 1
    if index == 1 then
        status = 1
    elseif index == #self.condition_list_2 then
        status = 2
    else
        status = 3
    end
    if self.condition_status_2 ~= status then
        self.condition_status_2 = status
        if status == 1 then
            self.condition_left_2:setTouchEnabled(false)
            self.condition_right_2:setTouchEnabled(true)
            setChildUnEnabled(true, self.condition_left_2)
            setChildUnEnabled(false, self.condition_right_2)
        elseif status == 2 then
            self.condition_left_2:setTouchEnabled(true)
            self.condition_right_2:setTouchEnabled(false)
            setChildUnEnabled(false, self.condition_left_2)
            setChildUnEnabled(true, self.condition_right_2)
        else
            self.condition_left_2:setTouchEnabled(true)
            self.condition_right_2:setTouchEnabled(true)
            setChildUnEnabled(false, self.condition_left_2)
            setChildUnEnabled(false, self.condition_right_2)
        end
    end
end

function GuildApplySetWindow:initConditionList()
	self.condition_list = {
		{index = 1, lev = 1, desc = TI18N("1级")},
		{index = 2, lev = 10, desc = TI18N("10级")},
		{index = 3, lev = 20, desc = TI18N("20级")},
		{index = 4, lev = 30, desc = TI18N("30级")},
		{index = 5, lev = 40, desc = TI18N("40级")},
		{index = 6, lev = 50, desc = TI18N("50级")},
		{index = 7, lev = 60, desc = TI18N("60级")},
	}


    local guild_limit_power_choice =  Config.GuildData.data_const.guild_limit_power_choice
    if guild_limit_power_choice then
        self.condition_list_2 = guild_limit_power_choice.val
    else
        self.condition_list_2 = {0,50000,100000,200000,400000,800000,1500000,3000000}    
    end
end

function GuildApplySetWindow:setGuildSetInfo(index)
	if index == 0 then
		self.set_value:setString(TI18N("不需要验证"))
        self.set_left:setTouchEnabled(false)
        self.set_right:setTouchEnabled(true)
        setChildUnEnabled(true, self.set_left)
        setChildUnEnabled(false, self.set_right)
	elseif index == 1 then
		self.set_value:setString(TI18N("需要验证"))
        self.set_left:setTouchEnabled(true)
        self.set_right:setTouchEnabled(false)
        setChildUnEnabled(false, self.set_left)
        setChildUnEnabled(true, self.set_right)
	end
end 

function GuildApplySetWindow:close_callback()
    controller:openGuildApplySetWindow(false)
end