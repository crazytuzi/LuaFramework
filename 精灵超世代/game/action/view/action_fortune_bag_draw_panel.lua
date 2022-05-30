----------------------------
-- @Author: yuanqi@shiyue.com
-- @Date:   2020-1-4
-- @Description:   不放回抽奖
----------------------------
ActionFortuneBagDrawPanel =
    class(
    "ActionFortuneBagDrawPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = ActionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local flip_delay = 30
local flip_open_delay = 30
local item_count = 35

function ActionFortuneBagDrawPanel:ctor(bid)
    self.holiday_bid = bid
    self:loadResources()
    self.camp_id = model:getFortuneBagCampId()
    self.bag_item_list = {} --奖励
end

function ActionFortuneBagDrawPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("fortunebag", "fortunebag"), type = ResourcesType.plist}
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(
        self.res_list,
        function()
            self:configUI()
            self:register_event()
        end
    )
end

function ActionFortuneBagDrawPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_fortune_bag_draw_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setPosition(-40, -80)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.image_bg = self.main_container:getChildByName("image_bg")
    self.can_flip = false
    local str = "action_fortune_bag_draw"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str = tab_vo.reward_title
    end

    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/action", str)
    if not self.background_load then
        self.background_load = loadSpriteTextureFromCDN(self.image_bg, bg_res, ResourcesType.single, self.background_load)
    end
    self.txt_time_title = self.main_container:getChildByName("txt_time_title")
    self.txt_time_title:setString(TI18N("活动时间："))
    self.txt_time_value = self.main_container:getChildByName("txt_time_value")
    self.txt_time_value:setString("")
    self.btn_tips = self.main_container:getChildByName("btn_tips")
    self.btn_next = self.main_container:getChildByName("btn_next")
    self.btn_next:getChildByName("txt_next"):setString(TI18N("下一轮"))
    self.txt_click_tips = self.main_container:getChildByName("txt_click_tips")
    self.txt_click_tips:setString(TI18N("点击格子翻牌"))
    self.txt_wheels = self.main_container:getChildByName("txt_wheels")
    self.txt_wheels:setString(TI18N("第一轮"))
    self.icon_num = self.main_container:getChildByName("icon_num")
    self.icon_sprite = self.main_container:getChildByName("icon_sprite")
    self.addtimes_btn = self.main_container:getChildByName("addtimes_btn")

    -- 皮肤预览按钮
    self.battle_preview_btn = self.main_container:getChildByName("battle_preview_btn")
    self.preview_btn_label = self.battle_preview_btn:getChildByName("preview_btn_label")
    self.preview_btn_label:setString(TI18N("皮肤预览"))

    -- 终极大奖
    self.item_ultimate_reward = self.main_container:getChildByName("item_ultimate_reward")
    self.item_ultimate_reward.lock_icon = self.item_ultimate_reward:getChildByName("lock_icon")
    self.item_ultimate_reward.replace = self.item_ultimate_reward:getChildByName("replace")
    self.item_ultimate_reward.icon = BackPackItem.new(true, true)
    self.item_ultimate_reward.icon:setAnchorPoint(0.5, 0.5)
    self.item_ultimate_reward.icon:setPosition(self.item_ultimate_reward:getContentSize().width / 2, self.item_ultimate_reward:getContentSize().height / 2)
    self.item_ultimate_reward.icon:setTouchEnabled(false)
    self.item_ultimate_reward.icon:setSwallowTouches(false)
    self.item_ultimate_reward:addChild(self.item_ultimate_reward.icon)

    self.effect_mask = self.main_container:getChildByName("effect_mask")

    -- 福袋列表
    self.fortune_bag_list = self.main_container:getChildByName("fortune_bag_list")
    self.scroll_view_size = self.fortune_bag_list:getContentSize()
    local setting = {
        item_class = FortuneBagItem, -- 单元类
        start_x = 1, -- 第一个单元的X起点
        space_x = 12, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 12, -- y方向的间隔
        item_width = 85, -- 单元的尺寸width
        item_height = 85, -- 单元的尺寸height
        row = 5, -- 行数，作用于水平滚动类型
        col = 7 -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.fortune_bag_list, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, self.scroll_view_size, setting)
    self.item_scrollview:setClickEnabled(false)

    controller:sender28307()
    controller:sender28300()
end

function ActionFortuneBagDrawPanel:register_event()
    if not self.update_fortune_bag_draw_event then
        self.update_fortune_bag_draw_event =
            GlobalEvent:getInstance():Bind(
            ActionEvent.FORTUNE_BAG_DRAW_BASE_EVENT,
            function(data)
                if not data then
                    return
                end
                -- 自选奖励
                if self.can_flip then
                    self.data = data
                    self:setRewardData(data)
                    self:beginBagFlip()
                else
                    self:setPanelData(data)
                end
                self:setGuideEffect()
                self:setUltimateReward(data)
            end
        )
    end

    registerButtonEventListener(
        self.addtimes_btn,
        function()
            local controller = ActionController:getInstance()
            local tab_vo = controller:getActionSubTabVo(991048)
            if tab_vo then
                controller.action_operate:handleSelectedTab(controller.action_operate.tab_list[tab_vo.bid])
            else
                message(TI18N("该活动已结束"))
            end
        end,
        true,
        1,
        nil,
        0.8
    )

    registerButtonEventListener(
        self.btn_tips,
        function(param, sender, event_type)
            if self.data then
                local rule_data = {
                    start_time = self.data.start_time,
                    end_time = self.data.end_time,
                    round = self.data.round,
                    optional_id = self.data.optional_id or 0
                }
                controller:openFortuneBagRuleWindow(true, rule_data)
            end
        end,
        true,
        1
    )

    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event =
            GlobalEvent:getInstance():Bind(
            BackpackEvent.ADD_GOODS,
            function(bag_code, data_list)
                self:updataItem(bag_code, data_list)
            end
        )
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event =
            GlobalEvent:getInstance():Bind(
            BackpackEvent.MODIFY_GOODS_NUM,
            function(bag_code, data_list)
                self:updataItem(bag_code, data_list)
            end
        )
    end

    registerButtonEventListener(self.btn_next, function(param, sender, event_type) controller:sender28308() end, true, 1)
    registerButtonEventListener(self.item_ultimate_reward, function(param, sender, event_type) self:clickSelectUltimate() end, false, 1)
    registerButtonEventListener(self.item_ultimate_reward.replace, function(param, sender, event_type) self:clickSelectUltimate() end, false, 1)
    registerButtonEventListener(self.battle_preview_btn, function() TimesummonController:getInstance():send23219(self.holiday_bid) end, true, 1)
end

function ActionFortuneBagDrawPanel:updataItem(bag_code, data_list)
    if self.draw_consume then
        local is_update = false
        if data_list ~= nil then
            for i,v in pairs(data_list) do
                if v.base_id == self.draw_consume[1] then
                    is_update = true
                    break
                end
            end
        end
        if is_update then
            local item_config = Config.ItemData.data_get_data(self.draw_consume[1])
            local count = BackpackController:getInstance():getModel():getItemNumByBid(self.draw_consume[1])
            self.icon_num:setString(count or 0)
        end
    end
end

function ActionFortuneBagDrawPanel:clickSelectUltimate()
    if not self.data then
        return
    end
    local isWinUltimate = false
    for k, v in pairs(self.data.award_list) do
        if v.id >= 10000 then
            isWinUltimate = true
            break
        end
    end
    if isWinUltimate then
        local constant_cfg = Config.HolidayOptionalLotteryData.data_constant
        if constant_cfg and constant_cfg.max_round and constant_cfg.max_round.val == self.data.round then
            message(TI18N("已经达到最大轮次了"))
        else
            message(TI18N("您已获得本轮终极大奖"))
        end
    elseif not self.opening then
        local select_panel_data = {
            cur_round = self.data.round,
            select_type_id = self.data.optional_id
        }
        controller:openFortuneBagSelectWindow(true, select_panel_data)
    end
end

-- 开始打开福袋
function ActionFortuneBagDrawPanel:beginOpenBagFlip(cell)
    if self.opening ~= nil and self.opening then
        return
    end
    -- self:setBagOpening(true)
    self.flip_num = -flip_open_delay
    self.opening = true
    cell_data = cell:getData()
    self:clearTimeTicket()
    -- if cell.resetItemFlip then
    --     cell:resetItemFlip()
    -- end
    local function _callback()
        if cell then
            cell:setOpenItemFlip(self.flip_num)
            self.flip_num = self.flip_num + 3
        end
        if self.flip_num >= 0 and self.flip_num < 3 then
            controller:sender28302(cell_data.pos)
        end
        if self.flip_num >= flip_open_delay then
            self:clearTimeTicket()
            if cell.resetItemFlip then
                cell:resetItemFlip()
            end
            self:setRewardData()
        end
    end
    self.time_open_ticket = GlobalTimeTicket:getInstance():add(_callback, 1 / (flip_open_delay * 2))
    self.opening_ticket =
        GlobalTimeTicket:getInstance():add(
        function()
            self.opening = false
            if self.opening_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.opening_ticket)
                self.opening_ticket = nil
            end
        end,
        1.2,
        1
    )
end

-- 开始福袋翻转福袋
function ActionFortuneBagDrawPanel:beginBagFlip()
    self.bag_item_list = self.item_scrollview:getItemList()
    self.flip_num = -flip_delay
    self:clearTimeTicket()
    local function _callback()
        if self.bag_item_list then
            for k, v in pairs(self.bag_item_list) do
                if v.setItemFlip then
                    v:setItemFlip(self.flip_num)
                end
            end
            self.flip_num = self.flip_num + 1
        end
        if self.flip_num >= flip_delay then
            self.fortune_bag_list:setVisible(false)
            self:clearTimeTicket()

            if self.main_container and self.bag_effect == nil then
                self.bag_effect =
                    createEffectSpine(PathTool.getEffectRes(352), cc.p(self.scroll_view_size.width / 2, self.scroll_view_size.height - 29), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self.endBagFlip))
                self.effect_mask:addChild(self.bag_effect)
            elseif self.bag_effect then
                self.bag_effect:setVisible(true)
                self.bag_effect:setToSetupPose()
                self.bag_effect:setAnimation(0, PlayerAction.action, false)
            end
        end
    end
    self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 1 / (flip_delay * 2))
end

-- 结束翻转福袋
function ActionFortuneBagDrawPanel:endBagFlip()
    self.fortune_bag_list:setVisible(true)
    self.bag_effect:setVisible(false)
    self.can_flip = false
    self.bag_item_list = self.item_scrollview:getItemList()
    if self.bag_item_list then
        for k, v in pairs(self.bag_item_list) do
            if v.resetItemFlip then
                v:resetItemFlip()
            end
        end
        self.flip_num = self.flip_num + 1
    end
    if self.data then
        self:setPanelData(self.data)
    end
end

function ActionFortuneBagDrawPanel:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
    if self.time_open_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_open_ticket)
        self.time_open_ticket = nil
    end
end

function ActionFortuneBagDrawPanel:setRewardData(data)
    if not data then
        return
    end
    local data_list = {}
    local config = Config.HolidayOptionalLotteryData.data_normal_award[self.camp_id]
    local ultimate_config = Config.HolidayOptionalLotteryData.data_optional_award[self.camp_id]
    local normal_cfg_index = 1
    local round_config = {} --当前轮次普通奖励
    if config and config[data.round] then
        for k, v in pairs(config[data.round]) do
            table_insert(round_config, v)
        end
        table.sort(
            round_config,
            function(a, b)
                return a.id < b.id
            end
        )
    end
    for i = 1, item_count do --循环给每个item赋值
        local data_item = {
            pos = i,
            is_open = false,
            gold_time = data.gold_time,
            original_gold_time = data.original_gold_time,
            is_ultimate = false
        }
        if self.is_select_ultimate then --已经选择了自选奖励（处理下发的数据）
            for k, v in pairs(data.award_list) do
                if v.pos == i then
                    data_item.is_open = true
                    if v.id < 10000 and round_config then
                        for k1, v1 in pairs(round_config) do
                            if v1.id == v.id then
                                data_item.rewards = v1.rewards
                                break
                            end
                        end
                    else
                        if ultimate_config and ultimate_config[v.id] then
                            data_item.rewards = ultimate_config[v.id].rewards
                        end
                    end
                    break
                end
            end
        else --没有选择自选奖励（显示配置数据）
            data_item.is_open = true
            if i ~= (math.ceil(#round_config / 2) + 1) then
                if round_config and round_config[normal_cfg_index] then
                    data_item.rewards = round_config[normal_cfg_index].rewards
                end
                normal_cfg_index = normal_cfg_index + 1
            else
                data_item.is_ultimate = true
                data_item.round = data.round
                if ultimate_config and ultimate_config[data.optional_id] then
                    data_item.rewards = ultimate_config[data.optional_id].rewards
                end
            end
        end
        data_list[i] = deepCopy(data_item)
    end

    self.item_scrollview:setData(
        data_list,
        function(cell)
            local data = cell:getData()
            local constant_cfg = Config.HolidayOptionalLotteryData.data_constant
            local draw_consume
            local count = 0
            if constant_cfg and constant_cfg.draw_expend and constant_cfg.draw_expend.val then
                draw_consume = constant_cfg.draw_expend.val[1]
            end
            if draw_consume then
                count = BackpackController:getInstance():getModel():getItemNumByBid(draw_consume[1])
            end
            if not data.is_open then
                if count >= draw_consume[2] then --有足够消耗道具
                    -- controller:sender28302(data.pos)
                    self:beginOpenBagFlip(cell)
                else
                    if data.gold_time > 0 then --可以优惠价用钻石购买
                        local replace_consume = {}
                        if constant_cfg and constant_cfg.draw_expend_value and constant_cfg.draw_expend_value.val then
                            replace_consume = constant_cfg.draw_expend_value.val[1]
                        end
                        local original_consume = {}
                        if constant_cfg and constant_cfg.draw_original_price and constant_cfg.draw_original_price.val then
                            original_consume = constant_cfg.draw_original_price.val[1]
                        end
                        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(replace_consume[1] or 3).icon)
                        local iconsrc1 = PathTool.getItemRes(Config.ItemData.data_get_data(original_consume[1] or 3).icon)
                        local str =
                            string_format(
                            TI18N("是否消耗(原价<img src='%s' scale=0.3 />%s)<img src='%s' scale=0.3 />%s进行翻牌？\n今日剩余钻石折扣兑换次数<div fontcolor=#289b14>%s</div>次！"),
                            iconsrc1,
                            original_consume[2],
                            iconsrc,
                            replace_consume[2],
                            data.gold_time
                        )
                        local alert =
                            CommonAlert.show(
                            str,
                            TI18N("确定"),
                            function()
                                -- controller:sender28302(data.pos)
                                self:beginOpenBagFlip(cell)
                            end,
                            TI18N("取消"),
                            nil,
                            CommonAlert.type.rich
                        )
                        local line = createImage(title_bg, PathTool.getResFrame("welfare", "welfare_40"), 243, 103, cc.p(0.5, 0.5), true, 1, true)
                        line:setScaleX(0.9)
                        alert.alert_panel:addChild(line)
                    else
                        if data.original_gold_time > 0 then --可以原价用钻石购买
                            if constant_cfg and constant_cfg.draw_original_price and constant_cfg.draw_original_price.val then
                                original_consume = constant_cfg.draw_original_price.val[1]
                            end
                            local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(original_consume[1] or 3).icon)
                            local str =
                                string_format(TI18N("是否消耗<img src='%s' scale=0.3 />%s进行翻牌？\n今日剩余钻石兑换次数<div fontcolor=#289b14>%s</div>次！"), iconsrc, original_consume[2], data.original_gold_time)
                            local alert =
                                CommonAlert.show(
                                str,
                                TI18N("确定"),
                                function()
                                    -- controller:sender28302(data.pos)
                                    self:beginOpenBagFlip(cell)
                                end,
                                TI18N("取消"),
                                nil,
                                CommonAlert.type.rich
                            )
                        else
                            local str = TI18N("今日钻石兑换次数已达上限！")
                            CommonAlert.show(
                                str,
                                TI18N("获取更多"),
                                function()
                                    local controller = ActionController:getInstance()
                                    local tab_vo = controller:getActionSubTabVo(991048)
                                    if tab_vo then
                                        controller:openActionMainPanel(false)
                                        controller:openActionMainPanel(true, nil, tab_vo.bid)
                                    else
                                        message(TI18N("该活动已结束"))
                                    end
                                end,
                                TI18N("取消")
                            )
                        end
                    end
                end
            else
                if data.is_ultimate and data.round then
                    local select_panel_data = {
                        cur_round = data.round,
                        select_type_id = 0
                    }
                    controller:openFortuneBagSelectWindow(true, select_panel_data)
                end
            end
        end
    )
end

function ActionFortuneBagDrawPanel:setGuideEffect()
    -- 引导手指
    if not self.data then
        return
    end
    self.is_select_ultimate = self.data.optional_id ~= nil and self.data.optional_id ~= 0
    if self.data.round == 1 and not self.is_select_ultimate then
        if self.guide_effect == nil then
            local _x, _y = self.item_ultimate_reward:getPosition()
            self.guide_effect = createEffectSpine(PathTool.getEffectRes(240), cc.p(_x, _y), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            self:addChild(self.guide_effect)
        else
            self.guide_effect:setVisible(true)
        end
    elseif self.guide_effect then
        self.guide_effect:setVisible(false)
    end
end

function ActionFortuneBagDrawPanel:setPanelData(data)
    if not data then
        return
    end
    self.data = data
    local constant_cfg = Config.HolidayOptionalLotteryData.data_constant
    self.is_select_ultimate = data.optional_id ~= nil and data.optional_id ~= 0
    -- 已经选择了自选奖励的话不用翻转效果和洗牌特效
    self.can_flip = not self.is_select_ultimate
    --活动时间
    if data.start_time and data.end_time then
        self.txt_time_value:setString(TimeTool.getMD2(data.start_time) .. "-" .. TimeTool.getMD2(data.end_time))
    end

    -- 下一轮按钮显示
    if data.next_round then
        self.btn_next:setVisible(data.next_round == 1)
    end

    -- 抽完最后一张提示
    if data.award_list and #data.award_list >= item_count then
        message(TI18N("你已获得全部奖励"))
    end

    -- 抽奖消耗
    if constant_cfg and constant_cfg.draw_expend and constant_cfg.draw_expend.val then
        self.draw_consume = constant_cfg.draw_expend.val[1]
    end
    if self.draw_consume then
        local item_config = Config.ItemData.data_get_data(self.draw_consume[1])
        if item_config then
            local res = PathTool.getItemRes(item_config.icon)
            loadSpriteTexture(self.icon_sprite, res, LOADTEXT_TYPE)
        end
        count = BackpackController:getInstance():getModel():getItemNumByBid(self.draw_consume[1])
        self.icon_num:setString(count or 0)
    end

    -- 设置期数
    if data.round ~= nil then
        local str = string_format(TI18N("第%s轮"), StringUtil.numToChinese(data.round))
        self.txt_wheels:setString(str)
    end

    -- 福袋奖励
    self:setRewardData(data)
    -- self:setBagOpening(false)
end

-- 设置自选奖励
function ActionFortuneBagDrawPanel:setUltimateReward(data)
    if not data then
        return
    end
    self.is_select_ultimate = data.optional_id ~= nil and data.optional_id ~= 0
    local ultimate_config = Config.HolidayOptionalLotteryData.data_optional_award[self.camp_id]
    self.item_ultimate_reward.lock_icon:setVisible(not self.is_select_ultimate)
    self.item_ultimate_reward.replace:setVisible(self.is_select_ultimate)
    self.item_ultimate_reward.icon:setVisible(self.is_select_ultimate)
    if self.is_select_ultimate and ultimate_config[data.optional_id] then
        self.item_ultimate_reward.icon:setData()
        local vo = {}
        vo = deepCopy(Config.ItemData.data_get_data(ultimate_config[data.optional_id].rewards[1][1]))
        vo.quantity = ultimate_config[data.optional_id].rewards[1][2]
        self.item_ultimate_reward.icon:setData(vo)
    end
    if not self.ultimaet_add_effect then
        local size = self.item_ultimate_reward.lock_icon:getContentSize()
        self.ultimaet_add_effect = createEffectSpine(PathTool.getEffectRes(353), cc.p(size.width / 2, size.height / 2), cc.p(0.5, 0.5), true, PlayerAction.action)
        self.item_ultimate_reward.lock_icon:addChild(self.ultimaet_add_effect)
    end
end

function ActionFortuneBagDrawPanel:DeleteMe()
    if self.background_load then
        self.background_load:DeleteMe()
        self.background_load = nil
    end
    doStopAllActions(self.txt_time_value)
    if self.update_fortune_bag_draw_event then
        GlobalEvent:getInstance():UnBind(self.update_fortune_bag_draw_event)
        self.update_fortune_bag_draw_event = nil
    end
    if self.reward_item_list then
        for i, v in pairs(self.reward_item_list) do
            v:DeleteMe()
        end
        self.reward_item_list = nil
    end
    doStopAllActions(self.cur_reward_scrollview)
    if self.opening_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.opening_ticket)
        self.opening_ticket = nil
    end
    if self.bag_effect then
        self.bag_effect:clearTracks()
        self.bag_effect:removeFromParent()
        self.bag_effect = nil
    end
    if self.ultimaet_add_effect then
        self.ultimaet_add_effect:clearTracks()
        self.ultimaet_add_effect:removeFromParent()
        self.ultimaet_add_effect = nil
    end
    if self.guide_effect then
        self.guide_effect:clearTracks()
        self.guide_effect:removeFromParent()
        self.guide_effect = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end
    self:clearTimeTicket()
end

-- --------------------------------------------------------------------
-- 不放回抽奖福袋
--
-- @author: yuanqi(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-01-4
-- --------------------------------------------------------------------
FortuneBagItem =
    class(
    "FortuneBagItem",
    function()
        return ccui.Widget:create()
    end
)

function FortuneBagItem:ctor()
    self:configUI()
    self:register_event()
end

function FortuneBagItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_fortune_bag_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(60, 60))
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)

    self.bag_bg = self.main_container:getChildByName("bag_bg")
    self.bag_fg = self.main_container:getChildByName("bag_fg")
    self.bag_fg:setLocalZOrder(20)
    self.bag_fg:setVisible(false)

    self.goods_item = BackPackItem.new(true, true)
    self.goods_item:setScale(0.7)
    self.goods_item:setAnchorPoint(0.5, 0.5)
    self.goods_item:setPosition(self.bag_bg:getContentSize().width / 2, self.bag_bg:getContentSize().height / 2)
    self.goods_item:setTouchEnabled(false)
    self.goods_item:setSwallowTouches(false)
    self.bag_bg:addChild(self.goods_item)
    self.goods_item:setVisible(false)
end

function FortuneBagItem:register_event()
    self.main_container:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                self.touch_end = sender:getTouchEndPosition()
                local is_click = true
                if self.touch_began ~= nil then
                    is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
                end
                if is_click == true then
                    playButtonSound2()
                    if self.callback then
                        self:callback()
                    end
                end
            elseif event_type == ccui.TouchEventType.moved then
            elseif event_type == ccui.TouchEventType.began then
                self.touch_began = sender:getTouchBeganPosition()
            elseif event_type == ccui.TouchEventType.canceled then
            end
        end
    )
end

function FortuneBagItem:setData(data)
    if data == nil then
        return
    end
    self.data = data
    self:resetItemFlip()
    if data.rewards and next(data.rewards) ~= nil then
        local vo = {}
        vo = deepCopy(Config.ItemData.data_get_data(data.rewards[1][1]))
        vo.quantity = data.rewards[1][2]
        self.goods_item:setData(vo)
    elseif data.is_open then
        self.goods_item:setData({})
    end
    if data.is_open then
        self.bag_bg:setVisible(true)
        self.goods_item:setVisible(true)
        self.bag_fg:setVisible(false)
    else
        self.bag_bg:setVisible(false)
        self.goods_item:setVisible(false)
        self.bag_fg:setVisible(true)
    end
end

function FortuneBagItem:addCallBack(value)
    self.callback = value
end

function FortuneBagItem:getData()
    return self.data
end

function FortuneBagItem:getItemPosition()
    if self then
        return cc.p(self:getPosition())
    end
end

function FortuneBagItem:setItemFlip(flip_num)
    if flip_num <= 0 then
        self.bag_bg:setVisible(true)
        self.bag_fg:setVisible(false)
        self.bag_bg:setScaleX(math.abs(flip_num) / flip_delay)
    else
        self.bag_fg:setVisible(true)
        self.bag_bg:setVisible(false)
        self.bag_fg:setScaleX(flip_num / flip_delay)
    end
end

function FortuneBagItem:resetItemFlip()
    self.bag_bg:setScaleX(1)
    self.bag_fg:setScaleX(1)
    if self.data.is_open then
        self.bag_bg:setVisible(true)
        self.goods_item:setVisible(true)
        self.bag_fg:setVisible(false)
    else
        self.bag_bg:setVisible(false)
        self.goods_item:setVisible(false)
        self.bag_fg:setVisible(true)
    end
end

function FortuneBagItem:setOpenItemFlip(flip_num)
    if flip_num <= 0 then
        self.bag_fg:setVisible(true)
        self.bag_bg:setVisible(false)
        self.bag_fg:setScaleX(math.abs(flip_num) / flip_open_delay)
    else
        self.bag_bg:setVisible(true)
        self.bag_fg:setVisible(false)
        self.bag_bg:setScaleX(flip_num / flip_open_delay)
    end
end

-- function FortuneBagItem:resetOpenItemFlip()
--     self.bag_bg:setScaleX(1)
--     self.bag_fg:setScaleX(1)
--     if self.data.is_open then
--         self.bag_bg:setVisible(true)
--         self.goods_item:setVisible(true)
--         self.bag_fg:setVisible(false)
--     else
--         self.bag_bg:setVisible(false)
--         self.goods_item:setVisible(false)
--         self.bag_fg:setVisible(true)
--     end
-- end

function FortuneBagItem:DeleteMe()
    if self.goods_item then
        self.goods_item:DeleteMe()
    end
    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
