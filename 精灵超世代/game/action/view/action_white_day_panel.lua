----------------------------
-- @Author: yuanqi@shiyue.com
-- @Date:   2019-03-06
-- @Description:   白色情人节
----------------------------
ActionWhiteDayPanel =
    class(
    "ActionWhiteDayPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = ActionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
function ActionWhiteDayPanel:ctor(bid)
    self.config = Config.HolidayValentineBossData
    self.holiday_bid = bid
    self.camp_id = 50050
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.camp_id then
        self.camp_id = tab_vo.camp_id
    end
    self:loadResources()
    self.skill_item_list = {}
    self.reward_item_list = {}
end

function ActionWhiteDayPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildsecretarea", "guildsecretarea"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("actionwhitedaymonster", "actionwhitedaymonster"), type = ResourcesType.plist}
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(
        self.res_list,
        function()
            if self.configUI then
                self:configUI()
            end
            if self.register_event then
                self:register_event()
            end
        end
    )
end

function ActionWhiteDayPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_white_day_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    -- self:setPosition(-40, -80)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.image_bg = self.main_container:getChildByName("image_bg")

    self.hero_icon = self.main_container:getChildByName("hero_icon")
    self.hero_icon:setAnchorPoint(cc.p(0.5, 0.5))
    self.txt_time_title = self.main_container:getChildByName("txt_time_title")
    self.txt_time_title:setString(TI18N("活动时间："))
    self.txt_time_value = self.main_container:getChildByName("txt_time_value")
    self.txt_time_value:setString("")
    self.btn_tips = self.main_container:getChildByName("btn_tips")
    self.fight_btn = self.main_container:getChildByName("fight_btn")
    self.btn_label = self.fight_btn:getChildByName("label")
    self.btn_label:setString(TI18N("前往挑战"))
    self.left_btn = self.main_container:getChildByName("left_btn")
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.title = self.main_container:getChildByName("title")
    self.title:setString(TI18N("女神试炼"))
    self.buy_panel = self.main_container:getChildByName("buy_panel")
    self.buy_panel:getChildByName("key"):setString(TI18N("剩余次数:"))
    self.buy_count = self.buy_panel:getChildByName("label")
    self.buy_btn = self.buy_panel:getChildByName("add_btn")
    self.buy_btn:setVisible(false)
    self.buy_tips = createRichLabel(20, cc.c4b(0xff, 0xf8, 0xbf, 0xff), cc.p(0.5, 0.5), cc.p(0, -20), nil, nil, 600)
    self.buy_panel:addChild(self.buy_tips)

    self.skill_container = self.main_container:getChildByName("skill_container")
    self.skill_container_size = self.skill_container:getContentSize()
    self.skill_container:setScrollBarEnabled(false)

    self.item_container = self.main_container:getChildByName("item_container")
    self.item_container:setScrollBarEnabled(false)

    controller:cs16603(self.holiday_bid)
    controller:sender28800()
end

function ActionWhiteDayPanel:register_event()
    if not self.Init_White_Day_Event then
        self.Init_White_Day_Event =
            GlobalEvent:getInstance():Bind(
            ActionEvent.White_Day_Init_Event,
            function(data)
                self:setInitData(data)
            end
        )
    end

    registerButtonEventListener(
        self.btn_tips,
        function(param, sender, event_type)
            local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
            if tab_vo and tab_vo.camp_id then
                self.camp_id = tab_vo.camp_id
            end
            local rule_cfg
            if self.config and self.config.data_boss_list and self.config.data_boss_list[self.camp_id] then
                rule_cfg = self.config.data_boss_list[self.camp_id][self.select_base_id]
            end
            if rule_cfg and rule_cfg.rules then
                TipsManager:getInstance():showCommonTips(rule_cfg.rules, sender:getTouchBeganPosition(), nil, nil, 500)
            end
        end,
        true,
        1,
        nil,
        0.8
    )

    registerButtonEventListener(
        self.fight_btn,
        function()
            self:clickFight()
        end,
        true,
        1
    )

    registerButtonEventListener(
        self.buy_btn,
        function()
            self:clickAdd()
        end,
        true,
        1
    )

    registerButtonEventListener(self.left_btn, handler(self, self.onClickLeftBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickRightBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
end

function ActionWhiteDayPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool then
        BattleConst.Fight_Type.WhiteDayWar = 41
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.WhiteDayWar)
    else
        BattleController:getInstance():openBattleView(false)
        -- 还原ui战斗类型
        MainuiController:getInstance():resetUIFightType()
    end
end

function ActionWhiteDayPanel:setInitData(data)
    print("ActionWhiteDayPanel:setInitData", data)
    if not data then
        return
    end
    self.data = data
    self:setBossList()
    if next(self.boss_list) == nil then
        return
    end
    if #self.boss_list == 1 then
        self.left_btn:setVisible(false)
        self.right_btn:setVisible(false)
    end
    table_sort(self.boss_list, SortTools.KeyLowerSorter("id"))
    self.can_challenge_times = data.time
    self.can_buy_time = data.buy_time
    if self.can_challenge_times then
    end
    self.buy_count:setString(tostring(self.can_challenge_times))
    if self.select_base_index == nil then
        if self.data.id == 0 then
            self.select_base_index = 1
        else
            for i, v in ipairs(self.boss_list) do
                if self.data.id == v.id then
                    self.select_base_index = i
                    break
                end
            end
        end
        --容错用的
        if self.select_base_index == nil then
            self.select_base_index = 1
        end
    end
    self:updateBossInfoByBossID(self.select_base_index)
end

function ActionWhiteDayPanel:setBossList()
    self.boss_list = {}
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.camp_id then
        self.camp_id = tab_vo.camp_id
    end
    if self.config and self.config.data_boss_list and self.config.data_boss_list[self.camp_id] then
        for k, v in pairs(self.config.data_boss_list[self.camp_id]) do
            if v.id >= self.data.id then
                table_insert(self.boss_list, v)
            end
        end
    end
end

function ActionWhiteDayPanel:clickFight()
    print("ActionWhiteDayPanel:clickFight", self.data)
    if self.data and self.data.time <= 0 then
        message(TI18N("挑战次数不足"))
        return
    end
    if not self.select_base_id then
        return
    end
    local setting = {
        select_base_id = self.select_base_id
    }
    HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.WhiteDay, setting)
end

function ActionWhiteDayPanel:clickAdd()
    if not self.select_base_id then
        return
    end
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.camp_id then
        self.camp_id = tab_vo.camp_id
    end
    if self.config and self.config.data_boss_list and self.config.data_boss_list[self.camp_id] then
        if self.can_buy_time > 0 then
            local max_buy_time = self.config.data_boss_list[self.camp_id][self.select_base_id].buy_time
            local cur_buy_time = max_buy_time - self.can_buy_time -- 现在是第几次购买
            local comsume = {}
            if cur_buy_time == 0 then
                comsume = self.config.data_constant.holiday_valentine_boss_buy_loss1.val
            elseif cur_buy_time < max_buy_time then
                comsume = self.config.data_constant.holiday_valentine_boss_buy_loss2.val
            end
            if comsume and comsume[1] then
                local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(comsume[1][1] or 3).icon)
                local str = string_format(TI18N("是否消耗<img src='%s' scale=0.3 />%s购买次数？"), iconsrc, comsume[1][2])
                local alert =
                    CommonAlert.show(
                    str,
                    TI18N("确定"),
                    function()
                        controller:sender28803()
                    end,
                    TI18N("取消"),
                    nil,
                    CommonAlert.type.rich
                )
            end
        else
            controller:sender28803()
        end
    end
end

-- 左
function ActionWhiteDayPanel:onClickLeftBtn()
    if not self.boss_list then
        return
    end
    if not self.select_base_index then
        return
    end
    if #self.boss_list == 0 then
        return
    end
    self.select_base_index = self.select_base_index - 1
    if self.select_base_index <= 0 then
        self.select_base_index = #self.boss_list
    end
    self:updateBossInfoByBossID(self.select_base_index)
end

-- 右
function ActionWhiteDayPanel:onClickRightBtn()
    if not self.boss_list then
        return
    end
    if not self.select_base_index then
        return
    end
    if #self.boss_list == 0 then
        return
    end
    self.select_base_index = self.select_base_index + 1
    if self.select_base_index > #self.boss_list then
        self.select_base_index = 1
    end
    self:updateBossInfoByBossID(self.select_base_index)
end

function ActionWhiteDayPanel:updateBossInfoByBossID(index)
    if not self.data then
        return
    end
    if not index then
        return
    end
    if not self.boss_list[index] then
        return
    end
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.camp_id then
        self.camp_id = tab_vo.camp_id
    end
    self.select_base_id = self.boss_list[index].id
    if self.select_base_id == self.data.id then
        setChildUnEnabled(false, self.fight_btn, Config.ColorData.data_color4[1])
        self.btn_label:enableOutline(cc.c4b(0x65, 0x1d, 0x00, 0xff), 2)
        self.fight_btn:setTouchEnabled(true)
    else
        setChildUnEnabled(true, self.fight_btn, Config.ColorData.data_color4[1])
        self.fight_btn:setTouchEnabled(false)
        self.btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    end
    local time_cfg = self.config.data_boss_list[self.camp_id][self.select_base_id]
    if time_cfg and time_cfg.act_time then
        self.txt_time_value:setString(time_cfg.act_time)
    end
    self.boss_config = self.config.data_boss_list[self.camp_id][self.select_base_id]
    if not self.boss_config then
        return
    end
    if self.boss_config.buy_time > 0 then
        self.buy_btn:setVisible(true)
        -- self.buy_panel:setContentSize(cc.size(90, 34))
        self.buy_count:setPosition(45, 17)
    else
        self.buy_btn:setVisible(false)
        -- self.buy_panel:setContentSize(cc.size(120, 34))
        self.buy_count:setPosition(60, 17)
    end
    self:updateSkillInfo()
    if self.boss_config.title_name and self.boss_config.title_name ~= "" then
        self.title:setString(self.boss_config.title_name)
    end
    --奖励
    local data_list = self.boss_config.reward or {}
    local setting = {}
    setting.scale = 0.9
    setting.max_count = 4
    setting.is_center = true
    self.item_list = commonShowSingleRowItemList(self.item_container, self.item_list, data_list, setting)

    --立绘
    self:setBackgroundImg(self.boss_config.draw_id or 1)
end

--刷新技能
function ActionWhiteDayPanel:updateSkillInfo()
    if not self.boss_config then
        return
    end
    local skill_list = self.boss_config.boss_skill_id or {}
    -- skill_list = {203102,203102,203102,203102}
    --技能item的宽度
    self.skill_width = 100
    local item_width = self.skill_width + 10
    local total_width = item_width * #skill_list
    local max_width = math.max(self.skill_container_size.width, total_width)
    self.skill_container:setInnerContainerSize(cc.size(max_width, self.skill_container_size.height))

    for i, v in ipairs(self.skill_item_list) do
        v:setVisible(false)
    end

    local x = 0
    if total_width > self.skill_container_size.width then
        --技能的总宽度大于 显示的宽度 就从左往右显示
        x = 0
    else
        --否则从中从中间显示
        x = (self.skill_container_size.width - total_width) * 0.5
    end

    for i, skill_id in ipairs(skill_list) do
        local config = Config.SkillData.data_get_skill(skill_id)
        if config then
            --是否锁住
            if self.skill_item_list[i] == nil then
                self.skill_item_list[i] = {}
                self.skill_item_list[i] = SkillItem.new(true, true, true, 0.8, false)
                self.skill_container:addChild(self.skill_item_list[i])
            end
            self.skill_item_list[i]:setData(config)
            self.skill_item_list[i]:setVisible(true)
            self.skill_item_list[i]:setPosition(x + item_width * (i - 1) + item_width * 0.5, self.skill_width / 2 + 6)
        else
            print(string_format("技能表id: %s 没发现", tostring(skill_id)))
        end
    end
end

function ActionWhiteDayPanel:setBackgroundImg(index)
    if not index then
        return
    end
    -- local bg_name = "white_day_boss_" .. index
    -- local bg_res = PathTool.getPlistImgForDownLoad("bigbg/whiteday", bg_name, true)
    -- if self.record_hero_res == nil or self.record_hero_res ~= bg_res then
    --     self.record_hero_res = bg_res
    --     self.item_load_icon = loadSpriteTextureFromCDN(self.hero_icon, bg_res, ResourcesType.single, self.item_load_icon)
    -- end
    local str = "txt_cn_white_day_monster" .. index
    local bg_res = PathTool.getPlistImgForDownLoad("actionwhitedaymonster", str)
    if not self.background_load then
        self.background_load = loadSpriteTextureFromCDN(self.image_bg, bg_res, ResourcesType.single, self.background_load)
    end
end

function ActionWhiteDayPanel:DeleteMe()
    if self.background_load then
        self.background_load:DeleteMe()
        self.background_load = nil
    end
    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    -- if self.item_load_icon then
    --     self.item_load_icon:DeleteMe()
    -- end
    -- self.item_load_icon = nil
    if self.skill_item_list then
        for k, v in pairs(self.skill_item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    if self.Init_White_Day_Event then
        GlobalEvent:getInstance():UnBind(self.Init_White_Day_Event)
        self.Init_White_Day_Event = nil
    end
    if self.item_list then
        for i, v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
end
