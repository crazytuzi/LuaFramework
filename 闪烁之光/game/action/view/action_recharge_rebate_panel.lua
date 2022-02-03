----------------------------
-- @Author:         yuanqi@shiyue.com
-- @Date:           2019-12-24 9:56
-- @Description:    充值返利
----------------------------
ActionRechargeRebatePanel =
    class(
    "ActionRechargeRebatePanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = ActionController:getInstance()
local model = controller:getModel()
local table_remove = table.remove
local table_insert = table.insert
local string_format = string.format

function ActionRechargeRebatePanel:ctor(bid)
    self.holiday_bid = bid
    self:configUI()
    self:register_event()
end

function ActionRechargeRebatePanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_recharge_rebate_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setPosition(-40, -80)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.image_bg = self.main_container:getChildByName("image_bg")

    local str = "txt_cn_action_recharge_rebate"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str = tab_vo.reward_title
    end

    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str)
    if not self.item_load then
        self.item_load =
            createResourcesLoad(
            res,
            ResourcesType.single,
            function()
                if not tolua.isnull(self.image_bg) then
                    self.image_bg:loadTexture(res, LOADTEXT_TYPE)
                end
            end,
            self.item_load
        )
    end

    self.btn_tips = self.main_container:getChildByName("btn_tips")
    self.txt_time_title = self.main_container:getChildByName("txt_time_title")
    self.txt_time_title:setString(TI18N("活动时间："))
    self.txt_time_value = self.main_container:getChildByName("txt_time_value")
    self.txt_time_value:setString("")
    self.btn_charge = self.main_container:getChildByName("btn_charge")
    self.txt_charge = self.btn_charge:getChildByName("label")
    self.txt_charge:setString(TI18N("前往充值"))
    self.txt_charge_bg = self.main_container:getChildByName("txt_charge_bg")
    self.txt_charge_bg:setString(TI18N("剩余钻石："))
    self.image_perc = self.main_container:getChildByName("image_perc")
    self.image_txt_bg = self.main_container:getChildByName("image_txt_bg")
    self.image_txt_bg:loadTexture(PathTool.getResFrame("welfare", "txt_cn_welfare_8"), LOADTEXT_TYPE_PLIST)
    self.remaining = CommonNum.new(17, self.main_container, 1, -2, cc.p(0.5, 0.5))
    self.remaining:setPosition(355, 235)
    self:setStaticPanelData()
    controller:sender28100()
    controller:sender28103()
    controller:cs16603(self.holiday_bid)
end

function ActionRechargeRebatePanel:register_event()
    if not self.update_recharge_rebate_event then
        self.update_recharge_rebate_event =
            GlobalEvent:getInstance():Bind(
            ActionEvent.UPDATE_RECHARGE_REBATE_EVENT,
            function(data)
                if not data then
                    return
                end
                self:setPanelData(data)
            end
        )
    end

    registerButtonEventListener(
        self.btn_tips,
        function(param, sender, event_type)
            local config
            if self.holiday_bid == ActionRankCommonType.recharge_rebate then
                config = Config.HolidayClientData.data_constant.recharge_rebate_rules
            end
            if config and config.desc then
                TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(), nil, nil, 500)
            end
        end,
        true,
        1
    )

    registerButtonEventListener(
        self.btn_charge,
        function()
            controller:sender28101()
            --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
            VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
        end,
        true,
        1
    )
end

-- 设置百分比，招财猫特效不会刷新的面板内容
function ActionRechargeRebatePanel:setStaticPanelData()
    local config = Config.HolidayChargeRebateData.data_constant

    -- 设置百分比
    if self.image_perc and config and config["rebate_pro_res"] and config["rebate_pro_res"].val then
        self.image_perc:loadTexture(PathTool.getResFrame("welfare", config["rebate_pro_res"].val or "txt_cn_welfare_9"), LOADTEXT_TYPE_PLIST)
    end
    -- 创建招财猫特效
    if config and config["rebate_effect"] and config["rebate_effect"].val then
        local effect_id = config["rebate_effect"].val[1] or 0
        local effect_posx = config["rebate_effect"].val[2] or 360
        local effect_posy = config["rebate_effect"].val[3] or 350
        if not self.cat_effect then
            self.cat_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(effect_posx, effect_posy), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.cat_effect:setScale(0.85)
            self.main_container:addChild(self.cat_effect)
        end
    end
end

function ActionRechargeRebatePanel:setPanelData(data)
    if not data then
        return
    end

    if data.start_time and data.end_time then
        self.txt_time_value:setString(TimeTool.getMD2(data.start_time) .. "-" .. TimeTool.getMD2(data.end_time))
    end
    local pos_x = self.txt_time_value:getPositionX() - self.txt_time_value:getContentSize().width
    self.txt_time_title:setPositionX(pos_x + 5)

    if data.rsidue_gold and data.rsidue_gold > 0 then
        self.remaining:setNum(data.rsidue_gold)
        self:updateBtnStatus(false)
    else
        self.remaining:setNum(0)
        self:updateBtnStatus(true)
    end
end

-- 刷新领奖充值按钮状态
function ActionRechargeRebatePanel:updateBtnStatus(is_gray)
    if is_gray then
        self.btn_charge:setTouchEnabled(false)
        setChildUnEnabled(true, self.btn_charge)
        self.txt_charge:enableOutline(Config.ColorData.data_color4[84], 2)
    else
        self.btn_charge:setTouchEnabled(true)
        setChildUnEnabled(false, self.btn_charge)
        self.txt_charge:enableOutline(Config.ColorData.data_color4[264], 2)
    end
end

function ActionRechargeRebatePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function ActionRechargeRebatePanel:DeleteMe()
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.remaining then
        self.remaining:DeleteMe()
        self.remaining = nil
    end
    if self.cat_effect then
        self.cat_effect:clearTracks()
        self.cat_effect:removeFromParent()
        self.cat_effect = nil
    end
    doStopAllActions(self.txt_time_value)
    if self.update_recharge_rebate_event then
        GlobalEvent:getInstance():UnBind(self.update_recharge_rebate_event)
        self.update_recharge_rebate_event = nil
    end
end
