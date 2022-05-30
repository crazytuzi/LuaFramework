-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      创建公会标签面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildCreatePanel = class("GuildCreatePanel", function()
    return ccui.Layout:create()
end)

local controller = GuildController:getInstance()

function GuildCreatePanel:ctor(ctrl)
    self:initConditionList()
    self.set_index = 0 -- 默认不验证
    self.condition_index = 1
    self.condition_index_2 = 1
    self.had_fill = false

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("guild/guild_create_panel"))
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")

    local name_title = container:getChildByName("name_title")
    name_title:setString(TI18N("公会大名："))
    local name_desc = container:getChildByName("name_desc")
    name_desc:setString(TI18N("长度限制2-6个汉字"))
    local declaration_title = container:getChildByName("declaration_title")
    declaration_title:setString(TI18N("公会宣言："))
    local set_title = container:getChildByName("set_title")
    set_title:setString(TI18N("验证设置："))
    local condition_title = container:getChildByName("condition_title")
    condition_title:setString(TI18N("入会要求："))
    local condition_title_2 = container:getChildByName("condition_title_2")
    condition_title_2:setString(TI18N("战力要求："))
    local desc = container:getChildByName("desc")
    desc:setString(TI18N("以上信息在创建后仍可修改"))

    local desc_vip = container:getChildByName("desc_vip")

    self.set_value = container:getChildByName("set_value")

    self.condition_value = container:getChildByName("condition_value")
    self.condition_value_2 = container:getChildByName("condition_value_2")

    self.condition_left = container:getChildByName("condition_left")
    self.condition_right = container:getChildByName("condition_right")
    self.condition_left_2 = container:getChildByName("condition_left_2")
    self.condition_right_2 = container:getChildByName("condition_right_2")
    self.set_left = container:getChildByName("set_left")
    self.set_right = container:getChildByName("set_right")

    local res = PathTool.getResFrame("common", "common_99998")
    self.edit_title = createEditBox(container, res, cc.size(365, 46), nil, 18, Config.ColorData.data_new_color4[6], 22,
        TI18N("请输入公会名字"), nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_title:setAnchorPoint(cc.p(0, 0.5))
    self.edit_title:setPlaceholderFontColor(Config.ColorData.data_new_color4[6])
    self.edit_title:setFontColor(Config.ColorData.data_new_color4[6])
    self.edit_title:setPosition(cc.p(197, 532))
    self.edit_title:setMaxLength(12)

    local res = PathTool.getResFrame("common", "common_99998")
    self.declaration_value = createEditBox(container, res, cc.size(365, 146), nil, 18,
        Config.ColorData.data_new_color4[6], 22, TI18N("请输入公会宣言内容"), nil, nil, LOADTEXT_TYPE_PLIST,
        cc.EDITBOX_INPUT_MODE_ANY)
    self.declaration_value:setAnchorPoint(cc.p(0, 1))
    self.declaration_value:setPlaceholderFontColor(Config.ColorData.data_new_color4[6])
    self.declaration_value:setFontColor(Config.ColorData.data_new_color4[6])
    self.declaration_value:setPosition(cc.p(200, 470))
    self.declaration_value:setMaxLength(100)

    self.create_btn = container:getChildByName("create_btn")
    local size = self.create_btn:getContentSize()

    -- local desc_vip = container:getChildByName("desc_vip")
    -- desc_vip:setVisible(false)

    local config = Config.GuildData.data_const.create_gold
    local gold_num = 100
    if config ~= nil then
        gold_num = config.val
    end
    local item_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id.gold)
    local item_icon = 2
    if item_config ~= nil then
        item_icon = item_config.icon
    end
    self.create_btn_label = createRichLabel(26, 1, cc.p(0.5, 0.5), cc.p(size.width * 0.5, size.height * 0.5), nil, nil,
        size.width)
    self.create_btn:addChild(self.create_btn_label)

    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = Config.GuildData.data_const.maintain_vip_condition

    local str = string.format(TI18N("需达VIP%d才可创建公会"), lev.val)
    desc_vip:setString(str)
    if role_vo.vip_lev < lev.val then
        self.create_btn:setTouchEnabled(false)
        self.create_btn_label:setString(string.format("<img src=%s visible=true scale=0.3 />%s %s",
            PathTool.getItemRes(item_icon), gold_num, TI18N("创建公会")))
        setChildUnEnabled(true, self.create_btn)
    else
        self.create_btn_label:setString(string.format(
            "<img src=%s visible=true scale=0.3 /><div outline=2,#764519>%s %s</div>", PathTool.getItemRes(item_icon),
            gold_num, TI18N("创建公会")))
    end

    self:setGuildSetInfo(self.set_index)
    self:setGuildConditionInfo(self.condition_index)
    self:setGuildConditionInfo2(self.condition_index_2)

    self:registerEvent()
end

function GuildCreatePanel:registerEvent()
    self.condition_left:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.condition_index == 1 then
                return
            end
            self.condition_index = self.condition_index - 1
            self:setGuildConditionInfo(self.condition_index)
        end
    end)
    self.condition_right:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.condition_index >= #self.condition_list then
                return
            end
            self.condition_index = self.condition_index + 1
            self:setGuildConditionInfo(self.condition_index)
        end
    end)
    self.condition_left_2:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.condition_index_2 == 1 then
                return
            end
            self.condition_index_2 = self.condition_index_2 - 1
            self:setGuildConditionInfo2(self.condition_index_2)
        end
    end)
    self.condition_right_2:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.condition_index_2 >= #self.condition_list_2 then
                return
            end
            self.condition_index_2 = self.condition_index_2 + 1
            self:setGuildConditionInfo2(self.condition_index_2)
        end
    end)

    self.set_left:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.set_index == 0 then
                return
            end
            self.set_index = self.set_index - 1
            self:setGuildSetInfo(self.set_index)
        end
    end)
    self.set_right:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.set_index == 1 then
                return
            end
            self.set_index = self.set_index + 1
            self:setGuildSetInfo(self.set_index)
        end
    end)

    self.create_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local config = self.condition_list[self.condition_index]
            local config_2 = self.condition_list_2[self.condition_index_2]
            local guild_name = self.edit_title:getText()
            if guild_name == "" then
                message(TI18N("公会名称不能为空"))
            elseif StringUtil.getStrLen(guild_name) > 12 then
                message(TI18N("公会名字不得超过6个文字"))
            else
                local sign = self.declaration_value:getText()
                if config and config_2 then
                    controller:requestCreateGuild(guild_name, sign, self.set_index, config.lev, config_2)
                end
            end
        end
    end)
end

function GuildCreatePanel:addToParent(status)
    self:setVisible(status)

    if status == true and not self.had_fill then
        self.had_fill = true
        if Config.GuildData.data_sign_length > 0 then
            local index = math.random(1, Config.GuildData.data_sign_length)
            local config = Config.GuildData.data_sign[index]
            if config ~= nil then
                self.declaration_value:setText(config.sign)
            end
        end
    end
end

function GuildCreatePanel:setGuildConditionInfo(index)
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

function GuildCreatePanel:setGuildConditionInfo2(index)
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

function GuildCreatePanel:initConditionList()
    self.condition_list = {{
        index = 1,
        lev = 1,
        desc = TI18N("1级")
    }, {
        index = 2,
        lev = 10,
        desc = TI18N("10级")
    }, {
        index = 3,
        lev = 20,
        desc = TI18N("20级")
    }, {
        index = 4,
        lev = 30,
        desc = TI18N("30级")
    }, {
        index = 5,
        lev = 40,
        desc = TI18N("40级")
    }, {
        index = 6,
        lev = 50,
        desc = TI18N("50级")
    }, {
        index = 7,
        lev = 60,
        desc = TI18N("60级")
    }}

    local guild_limit_power_choice = Config.GuildData.data_const.guild_limit_power_choice
    if guild_limit_power_choice then
        self.condition_list_2 = guild_limit_power_choice.val
    else
        self.condition_list_2 = {0, 50000, 100000, 200000, 400000, 800000, 1500000, 3000000}
    end

    -- self.condition_list_2 = {
    --     {index = 1, lev = 1,  desc = TI18N("0")},
    --     {index = 2, lev = 10, desc = TI18N("10w")}, 
    --     {index = 3, lev = 20, desc = TI18N("20级")}, 
    --     {index = 4, lev = 30, desc = TI18N("30级")}, 
    --     {index = 5, lev = 40, desc = TI18N("40级")}, 
    --     {index = 6, lev = 50, desc = TI18N("50级")}, 
    --     {index = 7, lev = 60, desc = TI18N("60级")},    
    -- }
end

function GuildCreatePanel:setGuildSetInfo(index)
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

function GuildCreatePanel:DeleteMe()
end
