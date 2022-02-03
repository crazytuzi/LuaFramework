--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 战令活动
-- @DateTime:    2019-04-19 10:03:38
-- *******************************
OrderActionMainWindow = OrderActionMainWindow or BaseClass(BaseView)

local controller = OrderActionController:getInstance()
local model = controller:getModel()
local controll_action = ActionController:getInstance()
local lev_reward_list = Config.HolidayWarOrderData.data_lev_reward_list
function OrderActionMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

    self.layout_name = "orderaction/orderaction_main_window1"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("orderaction", "orderaction"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("orderwar", "orderwar"), type = ResourcesType.plist},
    }
    self.tab_view = {}
    self.tab_panel_list = {} --视图
    self.cur_index = nil
    self.cur_box_status = nil
end

function OrderActionMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)

    self.btn_untie_reward = self.main_container:getChildByName("btn_untie_reward")
    --解锁奖励总览
    self.btn_open_lock = self.main_container:getChildByName("btn_open_lock")
    self.btn_open_lock_label = self.btn_open_lock:getChildByName("name")
    self.btn_open_lock_label:setString("")
    self.btn_open_lock_label:setTextColor(cc.c3b(0x71,0x28,0x04))
    self.btn_open_lock_label:disableEffect(cc.LabelEffect.OUTLINE)
    self.btn_open_lock_label:setFontSize(22)
    self.btn_open_lock:loadTexture(PathTool.getResFrame("common", "common_1027"), LOADTEXT_TYPE_PLIST)
    --购买等级
    self.btn_buy_lev = self.main_container:getChildByName("btn_buy_lev")
    local lev_label = self.btn_buy_lev:getChildByName("Text_2")
    lev_label:setString(TI18N("购买等级"))
    lev_label:setTextColor(cc.c3b(0x71,0x28,0x04))
    lev_label:disableEffect(cc.LabelEffect.OUTLINE)
    lev_label:setFontSize(22)

    local tab_view = self.main_container:getChildByName("tab_view")
    local title_name = {TI18N("奖励"),TI18N("任务")}
    for i=1,2 do
        local tab = {}
        tab.btn_tab_view = tab_view:getChildByName("tab_"..i)
        tab.normal = tab.btn_tab_view:getChildByName("normal")
        tab.select = tab.btn_tab_view:getChildByName("select")
        tab.select:setVisible(false)
        tab.name = tab.btn_tab_view:getChildByName("name")
        tab.name:setTextColor(cc.c4b(0xcf,0xb5,0x93,0xff))
        tab.name:setString(title_name[i])
        tab.icon = tab.btn_tab_view:getChildByName("icon")
        tab.icon:setOpacity(178)
        tab.index = i
        self.tab_view[i] = tab
    end
    --进度条
    self.bar_bg = self.main_container:getChildByName("bar_bg")
    self.bar = self.bar_bg:getChildByName("bar")
    self.bar:setPercent(0)
    self.bar:setScale9Enabled(true)
    self.bar_num = self.bar_bg:getChildByName("bar_num")
    self.bar_num:setString("")

    --底部图片
    self.banner_botton = self.main_container:getChildByName("banner_botton")
    --活动时间与领取
    self.time_text_bg = self.main_container:getChildByName("Text_4")
    self.time_text_bg:setString(TI18N("活动剩余时间:"))
    self.time_text = self.main_container:getChildByName("time_text")
    self.time_text:setString("")
    self.all_get = self.main_container:getChildByName("all_get")
    self.all_get:getChildByName("Text_6"):setString(TI18N("一键领取"))
    -- 进阶卡购买
    self.advance_card_buy = self.main_container:getChildByName("advance_card_buy")
    self.advance_card_buy_label = self.advance_card_buy:getChildByName("Text")
    self.advance_card_buy_label:setString("")
    self.advance_card_buy:setVisible(false)

    self:tabMainPeriodView()
    self.btn_rule = self.main_container:getChildByName("btn_rule")
    self.btn_close = self.main_container:getChildByName("btn_close")
end
--
function OrderActionMainWindow:tabMainPeriodView()
    self.level_num = self.main_container:getChildByName("level_num")
    self.level_num:setString("")
    local zhanling_lev_label = self.main_container:getChildByName("Text_21")
    zhanling_lev_label:setString(TI18N("战令等级"))
    local desc = createRichLabel(20, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0,0.5), cc.p(244,805), nil, nil, 400)
    self.main_container:addChild(desc)
    local title_barner = self.main_container:getChildByName("title_barner")
    
    local title_name = self.main_container:getChildByName("Image_1"):getChildByName("Text_1")
    local str, title_str = " ", TI18N("开学迎新")
    title_name:setString(title_str)
    title_barner:setPositionX(353)
    local cur_period = model:getCurPeriod()
    local res_str, botton_res_str= "orderaction_banner3_1", "orderaction_banner1_1"
    local bar_num_textColor, bar_num_outlineColor, level_num_outlineColor, lev_label_outlineColor = cc.c4b(0xff,0xff,0xff,0xff), cc.c4b(0x6b,0x2a,0x06,0xff), cc.c4b(0x0b,0x44,0x9a,0xff), cc.c4b(0x7f,0x3a,0x18,0xff)
    local num_x, lev_label_x = 95, 0
    local content_textColor = "34564a"
    if cur_period == 6 then --花火映秋
        title_str = TI18N("花火映秋")
        bar_num_textColor = cc.c4b(0xff,0xff,0xff,0xff)
        bar_num_outlineColor = cc.c4b(0x6b,0x2a,0x06,0xff)
        num_x, lev_label_x = 95, 95
        lev_label_outlineColor = cc.c4b(0x7f,0x3a,0x18,0xff)
        content_textColor = "7f3a18"
    elseif cur_period == 7 then --奇妙之夜
        title_str = TI18N("奇妙之夜")
        bar_num_textColor = cc.c4b(0xff,0xff,0xff,0xff)
        bar_num_outlineColor = cc.c4b(0x55,0x18,0x7f,0xff)
        num_x, lev_label_x = 103, 103
        lev_label_outlineColor = cc.c4b(0x55,0x18,0x7f,0xff)
        self.banner_botton:setPositionY(-30)
        content_textColor = "55187f"
    elseif cur_period == 8 then --雪舞冬季
        title_str = TI18N("雪舞冬季")
        bar_num_textColor = cc.c4b(0xff,0xff,0xff,0xff)
        bar_num_outlineColor = cc.c4b(0x0b,0x44,0x9a,0xff)
        num_x, lev_label_x = 103, 101
        level_num_outlineColor = cc.c4b(0x0b,0x44,0x9a,0xff)
        lev_label_outlineColor = cc.c4b(0x0b,0x44,0x9a,0xff)
        self.banner_botton:setPositionY(-57)
        title_barner:setPositionY(678)
        content_textColor = "0b449a"
    elseif cur_period == 9 then   --岁初礼赞
        title_str = TI18N("岁初礼赞")
        bar_num_textColor = cc.c4b(0xff,0xff,0xff,0xff)
        bar_num_outlineColor = cc.c4b(0x6b,0x14,0x2b,0xff)
        num_x, lev_label_x = 103, 101
        level_num_outlineColor = cc.c4b(0x6b,0x14,0x2b,0xff)
        lev_label_outlineColor = cc.c4b(0x6b,0x14,0x2b,0xff)
        self.banner_botton:setPositionY(-57)
        title_barner:setPositionY(678)
        content_textColor = "6b142b"
    elseif cur_period == 10 then   --踏雪拾春
        title_str = TI18N("踏雪拾春")
        bar_num_textColor = cc.c4b(0xff,0xff,0xff,0xff)
        bar_num_outlineColor = cc.c4b(0x67,0x15,0x15,0xff)
        num_x, lev_label_x = 103, 101
        level_num_outlineColor = cc.c4b(0x67,0x15,0x15,0xff)
        lev_label_outlineColor = cc.c4b(0x67,0x15,0x15,0xff)
        self.banner_botton:setPositionY(-13)
        title_barner:setPositionY(678)
        content_textColor = "671515"
    end

    str = string.format(TI18N("<div fontcolor=#ffffff outline=2,#%s >通过</div><div fontcolor=#ffd200 outline=2,#%s>完成任务</div><div fontcolor=#ffffff outline=2,#%s>提升等级，领取奖励</div>"), content_textColor, content_textColor, content_textColor)
    title_name:setString(title_str)
    self.bar_num:setTextColor(bar_num_textColor)
    self.bar_num:enableOutline(bar_num_outlineColor, 2)
    self.level_num:setPositionX(num_x)
    self.level_num:enableOutline(level_num_outlineColor, 2)
    zhanling_lev_label:setPositionX(lev_label_x)
    zhanling_lev_label:enableOutline(lev_label_outlineColor, 2)
    title_barner:setPositionY(678)
    desc:setString(str)
    
    local res = PathTool.getPlistImgForDownLoad("bigbg/orderaction", "orderaction_top" .. cur_period ) or nil
    local botton_res = PathTool.getPlistImgForDownLoad("bigbg/orderaction", "orderaction_buttom" .. cur_period ) or nil
 
    if not self.title_barner_load then
        self.title_barner_load = loadSpriteTextureFromCDN(title_barner, res, ResourcesType.single, self.title_barner_load)
    end

    if not self.barner_botton_load then
        self.barner_botton_load = loadSpriteTextureFromCDN(self.banner_botton, botton_res, ResourcesType.single, self.barner_botton_load)
    end

    self.activity_time = self.main_container:getChildByName("activity_time")
    self.activity_time:setString("")
    self.activity_time:disableEffect(cc.LabelEffect.OUTLINE)
    local text_exp = self.btn_untie_reward:getChildByName("Text_3")
    text_exp:setString(TI18N("额外经验包"))
    if cur_period == 10 then
        text_exp:setTextColor(cc.c4b(0xff,0xe7,0xbe,0xff))
        text_exp:enableOutline(cc.c4b(0x67,0x15,0x15,0xff),2)
    end

end

function OrderActionMainWindow:tabChargeView(index,period)
    index = index or 1
    if self.cur_index == index then return end
    self.cur_index = index

    self:setButtonShowORHide(index)
    if index ~= 3 then
        self:tabHeadTitle(index)
    end
    if self.cur_panel ~= nil then
        if self.cur_panel.setVisibleStatus then
            self.cur_panel:setVisibleStatus(false)
        end
    end
    self.cur_panel = self:createTabViewPanel(self.cur_index,period)
    if self.cur_panel ~= nil then
        if self.cur_panel.setVisibleStatus then
            self.cur_panel:setVisibleStatus(true)
        end
    end
end

function OrderActionMainWindow:tabHeadTitle(index)
    if self.cur_herd_title ~= nil then
        self.cur_herd_title.select:setVisible(false)
        self.cur_herd_title.icon:setOpacity(178)
        self.cur_herd_title.name:setTextColor(cc.c4b(0xcf,0xb5,0x93,0xff))
    end
    self.cur_herd_title = self.tab_view[index]
    if self.cur_herd_title ~= nil then
        self.cur_herd_title.select:setVisible(true)
        self.cur_herd_title.icon:setOpacity(255)
        self.cur_herd_title.name:setTextColor(cc.c4b(0xff,0xed,0xd6,0xff))
    end
end

function OrderActionMainWindow:createTabViewPanel(index,period)
    local panel = self.tab_panel_list[index]
    if panel == nil then
        if index == OrderActionView.reward_panel then
            panel = OrderActionRewardPanel1.new(period)
        elseif index == OrderActionView.tesk_panel then
            panel = OrderActionTeskPanel1.new(period)
        end
        local size = self.main_container:getContentSize()
        if panel then
            panel:setPosition(cc.p(size.width/2,394))
            self.main_container:addChild(panel)
        end
        self.tab_panel_list[index] = panel
    end
    return panel
end
--额外经验包宝箱
function OrderActionMainWindow:updateBoxStatus()
    local status = 0
    local rmb_status = model:getRMBStatus()
    local extra_status = model:getExtraStatus()
    if rmb_status == 0 then
        status = 0
    elseif rmb_status == 1 then
        if extra_status == 0 then
            status = 1
        elseif extra_status == 1 then
            status = 2
        end
    end
    if self.cur_box_status == status then return end
    self.cur_box_status = status

    local action = PlayerAction.action_1
    if status == 0 then
        action = PlayerAction.action_1
    elseif status == 1 then
        action = PlayerAction.action_2
    elseif status == 2 then
        action = PlayerAction.action_3
    end

    if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end
    local cur_period = model:getCurPeriod()
    if cur_period == 1 or cur_period == 2 then
        if not tolua.isnull(self.extra_exp) and self.box_effect == nil then
            self.box_effect = createEffectSpine(PathTool.getEffectRes(110), cc.p(40, 15), cc.p(0, 0), true, action)
            self.extra_exp:addChild(self.box_effect)
        end
    else
        if not tolua.isnull(self.btn_untie_reward) and self.box_effect == nil then
            self.box_effect = createEffectSpine(PathTool.getEffectRes(110), cc.p(40, 22), cc.p(0, 0), true, action)
            self.btn_untie_reward:addChild(self.box_effect)
        end
    end
end

--任务红点
function OrderActionMainWindow:getTaskRedPoint()
    local status = model:getTaskRedPoint()
    addRedPointToNodeByStatus(self.tab_view[2].btn_tab_view, status)
end
function OrderActionMainWindow:register_event()
    self:addGlobalEvent(OrderActionEvent.OrderAction_Init_Event, function(data)
        self:tabChargeView(1,data.period)
        self:setBasicInitData(data)
        self:updateBoxStatus()
        self:getTaskRedPoint()
        local time = data.end_time - GameNet:getInstance():getTime()
        controll_action:getModel():setCountDownTime(self.time_text,time)
        if self.activity_time then
            local config = Config.HolidayWarOrderData.data_constant
            local textcolor = Config.ColorData.data_color4[1]
            if config and config.action_time then
                local action_time = config.action_time.desc  --期数
                local color  = cc.c4b(0x34,0x56,0x4a,0xff)
                if data.period == 5 and config.action_time4 then
                    action_time = config.action_time4.desc or ""
                    color = cc.c4b(0x34,0x56,0x4a,0xff)
                elseif data.period == 6 and config.action_time5 then
                    action_time = config.action_time5.desc or ""
                    color = cc.c4b(0x7f,0x3a,0x18,0xff)
                elseif data.period == 7 and config.action_time6 then
                    action_time = config.action_time6.desc or ""
                    color = cc.c4b(0x55,0x18,0x7f,0xff)
                elseif data.period == 8 and config.action_time7 then
                    action_time = config.action_time7.desc or ""
                    color = cc.c4b(0x0b,0x44,0x9a,0xff)
                elseif data.period == 9 and config.action_time8 then
                    action_time = config.action_time8.desc or ""
                    color = cc.c4b(0x6b,0x14,0x2b,0xff)
                 elseif data.period == 10 and config.action_time9 then
                    action_time = config.action_time9.desc or ""
                    color = cc.c4b(0x67,0x15,0x15,0xff)
                    textcolor = cc.c4b(0xfa,0xd2,0x89,0xff)
                end
                self.activity_time:setString(TI18N("活动时间：")..action_time)
                self.activity_time:setTextColor(textcolor)
                self.activity_time:enableOutline(color, 2)
            end
        end
    end)
    --任务更新
    self:addGlobalEvent(OrderActionEvent.OrderAction_TaskGet_Event,function()
        self:getTaskRedPoint()
    end)
    self:addGlobalEvent(OrderActionEvent.OrderAction_LevReward_Event,function()
        self:statusTabRewardRedPoint()
    end)

    self:addGlobalEvent(OrderActionEvent.OrderAction_Updata_LevExp_Event, function(data)
        self:setBasicInitData(data)
        model:setRewardLevRedPoint()
        self:statusTabRewardRedPoint()
    end)

    self:addGlobalEvent(OrderActionEvent.OrderAction_IsPopWarn_Event, function(data)
        if data then
            local totle_day = 30
            local cur_period = model:getCurPeriod()
            if cur_period == 10 then
                totle_day = 29
            end
            if (totle_day - data.cur_day) == 7 or (totle_day - data.cur_day) == 3 or (totle_day - data.cur_day) == 0 then
                if data.is_pop == 1 then
                    controller:openEndWarnView(true,data.cur_day)
                end
            end
        end
    end)
    --***
    self:addGlobalEvent(OrderActionEvent.OrderAction_BuyGiftCard_Event, function()
        self:updateBoxStatus()
        if model:getGiftStatus() == 1 then
            self.advance_card_buy:setEnabled(false)
            setChildUnEnabled(true, self.advance_card_buy)
            self.btn_open_lock_label:setString(TI18N("奖励总览"))
            self.btn_open_lock:loadTexture(PathTool.getResFrame("common", "common_1027"), LOADTEXT_TYPE_PLIST)
        else
            self.advance_card_buy:setEnabled(true)
            setChildUnEnabled(false, self.advance_card_buy)
            self.btn_open_lock_label:setString(TI18N("解锁领取"))
        end
    end)

    registerButtonEventListener(self.btn_buy_lev, function()
        local cur_period = model:getCurPeriod()
        if lev_reward_list[cur_period] then
            local cur_lev = model:getCurLev()
            if cur_lev >= 40 then
                message(TI18N("您已满级，无法购买~~~"))
            else
                controller:openBuyLevView(true)
            end
        end
    end,true, 1)
    registerButtonEventListener(self.btn_untie_reward, function()
        local period = model:getCurPeriod()
        if model:getGiftStatus() == 1 then
            controller:send25308()
        else
            controller:openBuyCardView(true)
        end
    end,false, 1)
    for i,v in pairs(self.tab_view) do
        registerButtonEventListener(v.btn_tab_view, function()
            local day = model:getCurDay()
            local period = model:getCurPeriod()
            self:tabChargeView(v.index,period)
        end,false, 3)
    end
    
    registerButtonEventListener(self.btn_open_lock, function()
        local day = model:getCurDay()
        local period = model:getCurPeriod()
        if model:getGiftStatus() == 1 then
            controller:openUntieRewardView(true)
        else
            controller:openBuyCardView(true)
        end
    end,true, 1)

    registerButtonEventListener(self.btn_close, function()
        controller:openOrderActionMainView(false)
    end,true, 2)
    registerButtonEventListener(self.background, function()
        controller:openOrderActionMainView(false)
    end,false, 2)

    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        local config = Config.HolidayWarOrderData.data_constant
        local period = model:getCurPeriod()
        if config then
            local config_desc = config.action_rule4
            if period == 6 then
                config_desc = config.action_rule5
            elseif period == 7 then
                config_desc = config.action_rule6
            elseif period == 8 then
                config_desc = config.action_rule7
            elseif period == 9 then
                config_desc = config.action_rule8
            elseif period == 10 then
                config_desc = config.action_rule9
            end
            TipsManager:getInstance():showCommonTips(config_desc.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,false, 1)

    registerButtonEventListener(self.all_get, function()
        controller:send25304(0)
    end,true, 1)
    
    registerButtonEventListener(self.advance_card_buy, function()
        self:changeWarn()
    end,true, 1)

    registerButtonEventListener(self.extra_exp, function()
        if model:getGiftStatus() == 1 then
            controller:send25308()
        else
            message(TI18N("请激活进阶卡解锁经验包"))
            local day = model:getCurDay()
            local period = model:getCurPeriod()
            self:tabChargeView(3,period)
        end
    end,false, 1)
end
--奖励红点
function OrderActionMainWindow:statusTabRewardRedPoint()
    local status = model:getRewardLevRedPoint()
    addRedPointToNodeByStatus(self.tab_view[1].btn_tab_view, status)
    addRedPointToNodeByStatus(self.all_get, status,9,6)
end

--充值提醒
function OrderActionMainWindow:changeWarn()
    local day = model:getCurDay()
    local charge_list = Config.ChargeData.data_charge_data
    local card_list = Config.HolidayWarOrderData.data_advance_card_list
    local period = model:getCurPeriod()
    if card_list and card_list[period] and card_list[period][1] then
        local str = nil
        if day >= 24 then
            if period == 10 then
                if day == 29 then
                    str = TI18N("活动将在今天结束，是否确认充值")
                else
                    str = string.format(TI18N("活动将在 %d 天后结束，是否确认充值"),29-day)
                end
            else
                if day == 30 then
                    str = TI18N("活动将在今天结束，是否确认充值")
                else
                    str = string.format(TI18N("活动将在 %d 天后结束，是否确认充值"),30-day)
                end     
            end       
        end

        if str then
            CommonAlert.show(str,TI18N("确定"),function()
                local charge_id = card_list[period][1].charge_id or nil
                if charge_id and charge_list[charge_id] then
                    sdkOnPay(charge_list[charge_id].val, 1, charge_list[charge_id].id, charge_list[charge_id].name)
                end
            end,TI18N("取消"),nil,CommonAlert.type.common,nil,nil,26)
        else
            local charge_id = card_list[period][1].charge_id or nil
            if charge_id and charge_list[charge_id] then
                sdkOnPay(charge_list[charge_id].val, 1, charge_list[charge_id].id, charge_list[charge_id].name)
            end
        end
    end        
end

--设置数据
function OrderActionMainWindow:setBasicInitData(data)
    if not data then return end
    --当前等级
    local lev_num = data.lev or 0
    local cur_period = model:getCurPeriod()

    if self.level_num then
        self.level_num:setString(lev_num)
    end

    --等级经验
    if lev_reward_list and lev_reward_list[cur_period] then
        local cur_len = lev_num + 1
        if cur_len >= #lev_reward_list[cur_period] then
            cur_len = #lev_reward_list[cur_period]
        end

        if lev_reward_list[cur_period][cur_len] then
            --下一个等级的经验值
            local cur_exp = lev_reward_list[cur_period][cur_len].exp or 0
            --当前等级为0的时候
            if data.lev == 0 then
                self.bar:setPercent(data.exp / cur_exp * 100)
                self.bar_num:setString(data.exp.."/"..cur_exp)
            else
                --当前的
                local exp = lev_reward_list[cur_period][lev_num].exp or 0
                local diff_exp = cur_exp - exp
                local percent_num = (data.exp - exp) /  (cur_exp - exp) * 100
                self.bar:setPercent(percent_num)
                self.bar_num:setString(data.exp.."/"..cur_exp)
            end
        end
    end
end

--倒计时和购买
function OrderActionMainWindow:setButtonShowORHide(index)
    index = index or 1
    self.time_text_bg:setVisible(index == 1)
    self.time_text:setVisible(index == 1)
    self.all_get:setVisible(index == 1)
    self.advance_card_buy:setVisible(index == 3)
end

function OrderActionMainWindow:openRootWnd()
    controller:send25309()
    controller:send25300()
    controller:send25303()
    controller:send25306()
    controller:getModel():initTaskData()
end
function OrderActionMainWindow:close_callback()
    doStopAllActions(self.time_text)
    if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end
    if self.title_barner_load then
        self.title_barner_load:DeleteMe()
    end
    self.title_barner_load = nil

    if self.barner_botton_load then
        self.barner_botton_load:DeleteMe()
    end
    self.barner_botton_load = nil
    if self.tab_panel_list then
        for i,v in pairs(self.tab_panel_list) do 
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
        self.tab_panel_list = nil
    end
    if self.cur_lev_num then
        self.cur_lev_num:DeleteMe()
        self.cur_lev_num = nil
    end
    controller:openOrderActionMainView(false)
end