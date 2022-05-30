--******** 文件说明 ********
-- @Author:      yuanqi@shiyue.com
-- @description: 订阅/特权
-- @DateTime:    2020-02-26
-- *******************************
SubscriptionPrivilegePanel =
    class(
    "SubscriptionPrivilegePanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = WelfareController:getInstance()
local model = controller:getModel()
local string_format = string.format
local config = Config.SubscriberData
function SubscriptionPrivilegePanel:ctor()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("subscribe", "subscribe"), type = ResourcesType.plist}
    }
    self.is_ios_subscribe = IOS_SUBSCRIBE and IS_IOS_PLATFORM --是否是iOS平台并且能够订购
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(
        self.res_list,
        function()
            if self.loadResListCompleted then
                self:loadResListCompleted()
            end
        end
    )
end

function SubscriptionPrivilegePanel:loadResListCompleted()
    self:createRootWnd()
    self:register_event()
    controller:sender10989()
end

function SubscriptionPrivilegePanel:createRootWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/subscription_privilege_panel"))
    self:addChild(self.root_wnd)
    self:setPosition(-40, -88)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    local image_bg = self.main_container:getChildByName("image_bg")
    local bg_path = PathTool.getPlistImgForDownLoad("bigbg/welfare", "txt_cn_subscription_privilege")
    self.load_bg = loadSpriteTextureFromCDN(image_bg, bg_path, ResourcesType.single)

    local effect_node = self.main_container:getChildByName("effect_node")
    self.role_effect = createEffectSpine(PathTool.getEffectRes(160), cc.p(0, 0), cc.p(0, 0.5), true, "action")
    self.role_effect:setScale(1.5)
    effect_node:addChild(self.role_effect)
    self.subscribe_group = self.main_container:getChildByName("subscribe_group")
    self.subscribe_group:setVisible(false)
    self.btn_quarter = self.subscribe_group:getChildByName("btn_quarter")
    self.btn_month = self.subscribe_group:getChildByName("btn_month")
    self.privileged_info = self.main_container:getChildByName("privileged_info")
    self.privileged_info:setVisible(false)
    self.is_activated = self.privileged_info:getChildByName("is_activated")
    self.is_activated:setString(TI18N("特权已激活"))
    self.expires_time = self.privileged_info:getChildByName("expires_time")
    self.avatar_tips = self.main_container:getChildByName("avatar_tips")
    self.recuit_tips = self.main_container:getChildByName("recuit_tips")
    self.stone_tips = self.main_container:getChildByName("stone_tips")
    self.and_show_bg = self.main_container:getChildByName("and_show_bg")
    self.ios_show_bg = self.main_container:getChildByName("ios_show_bg")
    self.ios_rule_scroll = self.main_container:getChildByName("ios_rule_scroll")
    self.ios_rule_scroll_size = self.ios_rule_scroll:getContentSize()
    self.scroll_view = createScrollView(self.ios_rule_scroll_size.width, self.ios_rule_scroll_size.height, 0, 0, self.ios_rule_scroll, ScrollViewDir.vertical)
    self.scroll_container = self.scroll_view:getInnerContainer()

    -- 创建头像框
    local circle_base_id = config.data_constant.circle_id.val
    local circle_config
    if circle_base_id then
        circle_config = Config.AvatarData.data_avatar[circle_base_id]
    end
    local face_id = circle_config.res_id or 1
    local circle_scale = 95 / 117
    local effect_id = Config.AvatarData.data_avatar_effect[face_id]
    if effect_id ~= nil and effect_id.effect_id ~= "" then
        self:showCircleBgEffect(true, effect_id.effect_id, circle_scale)
    end
    self:setBtnInfo()
    self:differentiatedPlatform()
end

function SubscriptionPrivilegePanel:differentiatedPlatform()
    if self.is_ios_subscribe then
        self.and_show_bg:setVisible(false)
        self.ios_show_bg:setVisible(true)
        self.ios_show_bg:setVisible(true)
        self.ios_rule_label = createRichLabel(16, cc.c3b(64, 32, 23), cc.p(0, 1), cc.p(0, 0), 10)
        self.ios_rule_label:setMaxWidth(380)
        self.scroll_container:addChild(self.ios_rule_label)
        local label_desc = config.data_constant.agreement_ios
        if label_desc and label_desc.desc then
            self.ios_rule_label:setString(label_desc.desc)
        end
        self.rule_label_size = self.ios_rule_label:getSize()
        self.ios_rule_label:setPosition(cc.p(0, self.rule_label_size.height))
        self.scroll_container:setContentSize(cc.size(self.ios_rule_scroll_size.width, self.rule_label_size.height))
        self.scroll_container:setPosition(cc.p(0, self.ios_rule_scroll_size.height - self.rule_label_size.height))
        self.avatar_tips:setPosition(cc.p(239, 508))
        self.recuit_tips:setPosition(cc.p(393, 440))
        self.stone_tips:setPosition(cc.p(451, 375))
    else
        self.and_show_bg:setVisible(true)
        self.ios_show_bg:setVisible(false)
        self.ios_show_bg:setVisible(false)
        self.avatar_tips:setPosition(cc.p(230, 464))
        self.recuit_tips:setPosition(cc.p(406, 385))
        self.stone_tips:setPosition(cc.p(480, 302))
        self:addRichLabel()
    end
end

function SubscriptionPrivilegePanel:addRichLabel()
    self.agreement_label = createRichLabel(24, cc.c3b(95, 55, 32), cc.p(0.5, 0.5), cc.p(0, 0))
    self.agreement_label:setString(string_format("<div href=xxx>%s</div>", TI18N("查看特权规则")))
    self.agreement_label:addTouchLinkListener(
        function(type, value, sender, pos)
            local label_desc = config.data_constant.agreement2_and
            if label_desc and label_desc.desc then
                TipsManager:getInstance():showCommonTips(label_desc.desc, pos, nil, nil, 500)
            end
        end,
        {"click", "href"}
    )
    self.main_container:addChild(self.agreement_label)
    local container_size = self.main_container:getContentSize()
    self.agreement_label:setPosition(container_size.width / 2, 240)
end

function SubscriptionPrivilegePanel:setBtnInfo()
    local charge_id = config.data_id_info[SubscribeId.quarter].charge_id
    local charge_list = Config.ChargeData.data_charge_data
    local quarter_money = self.btn_quarter:getChildByName("quarter_money")
    if charge_list and charge_list[charge_id] then
        quarter_money:setString("￥" .. charge_list[charge_id].val)
    end
    self.btn_quarter:getChildByName("Text_8"):setString(TI18N("季度订阅"))

    charge_id = config.data_id_info[SubscribeId.month].charge_id
    charge_list = Config.ChargeData.data_charge_data
    local month_money = self.btn_month:getChildByName("month_money")
    if charge_list and charge_list[charge_id] then
        month_money:setString("￥" .. charge_list[charge_id].val)
    end
    self.btn_month:getChildByName("Text_9"):setString(TI18N("月订阅"))
end

function SubscriptionPrivilegePanel:register_event()
    registerButtonEventListener(
        self.btn_quarter,
        function()
            local charge_id = config.data_id_info[SubscribeId.quarter].charge_id
            local charge_list = Config.ChargeData.data_charge_data
            if charge_id and charge_list[charge_id] then
                self.cur_charge_id = charge_list[charge_id].id
                ActionController:getInstance():sender21016(self.cur_charge_id)
            end
        end,
        false
    )

    registerButtonEventListener(
        self.btn_month,
        function()
            local charge_id = config.data_id_info[SubscribeId.month].charge_id
            local charge_list = Config.ChargeData.data_charge_data
            if charge_id and charge_list[charge_id] then
                self.cur_charge_id = charge_list[charge_id].id
                ActionController:getInstance():sender21016(self.cur_charge_id)
            end
        end,
        false
    )

    registerButtonEventListener(
        self.btn_tips,
        function(param, sender, event_type)
            local android_desc = config.data_constant.agreement2_and
            if android_desc and android_desc.desc then
                TipsManager:getInstance():showCommonTips(android_desc.desc, sender:getTouchBeganPosition(), nil, nil, 500)
            end
        end,
        false
    )

    registerButtonEventListener(
        self.avatar_tips,
        function(param, sender, event_type)
            self:clickItemTips(1)
        end,
        false
    )
    registerButtonEventListener(
        self.recuit_tips,
        function(param, sender, event_type)
            self:clickItemTips(2)
        end,
        false
    )
    registerButtonEventListener(
        self.stone_tips,
        function(param, sender, event_type)
            self:clickItemTips(3)
        end,
        false
    )

    if not self.update_info_event then
        self.update_info_event =
            GlobalEvent:getInstance():Bind(
            WelfareEvent.Update_Subscribe_data,
            function(data)
                self:updateInfo(data)
            end
        )
    end

    if not self.subscribe_charge_data then
        self.subscribe_charge_data =
            GlobalEvent:getInstance():Bind(
            ActionEvent.Is_Charge_Event,
            function(data)
                if self.cur_charge_id and data and self.cur_charge_id == data.charge_id and data.status == 1 then
                    local charge_list = Config.ChargeData.data_charge_data
                    if self.cur_charge_id and charge_list[self.cur_charge_id] then
                        sdkOnPay(charge_list[self.cur_charge_id].val, 1, charge_list[self.cur_charge_id].id, charge_list[self.cur_charge_id].name)
                    end
                end
            end
        )
    end
end

function SubscriptionPrivilegePanel:clickItemTips(index)
    local const_config = config.data_constant
    local item_config
    if const_config then
        if index == 1 then
            item_config = Config.ItemData.data_get_data(const_config.item_avatar.val)
        elseif index == 2 then
            item_config = Config.ItemData.data_get_data(const_config.item_recuit.val)
        elseif index == 3 then
            item_config = Config.ItemData.data_get_data(const_config.item_stone.val)
        end
        if item_config then
            TipsManager:getInstance():showGoodsTips(item_config)
        end
    end
end

function SubscriptionPrivilegePanel:updateInfo(data)
    if data == nil or data.id == nil or data.start_unixtime == nil then
        return
    end
    self.privileged_info:setVisible(data.id ~= 0)
    self.subscribe_group:setVisible(data.id == 0)
    local end_time = data.start_unixtime + (((SubscribeAddDay[data.id] or 1) - 1) * 24 * 60 * 60)
    local str = string_format(TI18N("%s-%s"), TimeTool.getMD2(data.start_unixtime), TimeTool.getMD2(end_time))
    self.expires_time:setString(str)
end

function SubscriptionPrivilegePanel:showCircleBgEffect(bool, effect_id, scale)
    if bool == false then
        if self.bg_effect then
            self.bg_effect:clearTracks()
            self.bg_effect:removeFromParent()
            self.bg_effect = nil
        end
    else
        if self.bg_effect == nil then
            scale = scale or 1
            self.bg_effect = createEffectSpine(effect_id, cc.p(105, 270), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.bg_effect:setScale(scale)
            self.main_container:addChild(self.bg_effect, 1)
        else
            self.bg_effect:setVisible(true)
        end
    end
end

function SubscriptionPrivilegePanel:setVisibleStatus(status)
    bool = bool or false
    self:setVisible(status)
end

function SubscriptionPrivilegePanel:DeleteMe()
    if self.role_effect then
        self.role_effect:clearTracks()
        self.role_effect:removeFromParent()
        self.role_effect = nil
    end
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.load_bg then
        self.load_bg:DeleteMe()
        self.load_bg = nil
    end
    if self.update_info_event then
        self.update_info_event = GlobalEvent:getInstance():UnBind(self.update_info_event)
        self.update_info_event = nil
    end
    if self.subscribe_charge_data then
        self.subscribe_charge_data = GlobalEvent:getInstance():UnBind(self.subscribe_charge_data)
        self.subscribe_charge_data = nil
    end
    if self.circle_load then
        self.circle_load:DeleteMe()
        self.circle_load = nil
    end
    self:showCircleBgEffect(false)
end
