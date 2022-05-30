--
-- @Author: yuanqi@shiyue.com
-- @Date:   2020-03-26
-- @description:	超值周卡
--
ActionSuperValueWeeklyCardPanel =
    class(
    "ActionSuperValueWeeklyCardPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = ActionController:getInstance()
local model = ActionController:getInstance():getModel()
local string_format = string.format

function ActionSuperValueWeeklyCardPanel:ctor(bid)
    self.holiday_bid = bid
    self:loadResources()
    self.good_list_data = {}
end

function ActionSuperValueWeeklyCardPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("superweekcard", "superweekcard_bg"), type = ResourcesType.single}
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

function ActionSuperValueWeeklyCardPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_super_value_weekly_card_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.txt_time_title = self.main_container:getChildByName("txt_time_title") --时间标题
    self.txt_time_title:setString(TI18N("终身限时购买："))
    self.txt_time_val = self.main_container:getChildByName("txt_time_val") --剩余时间
    self.btn_charge = self.main_container:getChildByName("btn_charge") -- 充值按钮
    self.txt_charge = self.btn_charge:getChildByName("txt_charge")
    self.award_group = self.main_container:getChildByName("award_group")
    self.img_bg = self.main_container:getChildByName("img_bg")
    local str = "superweekcard_bg"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str = tab_vo.reward_title
    end

    local bg_res = PathTool.getPlistImgForDownLoad("superweekcard", str)
    if not self.background_load then
        self.background_load = loadSpriteTextureFromCDN(self.img_bg, bg_res, ResourcesType.single, self.background_load)
    end
    self:createAwardItem()
    controller:sender16653()
end

function ActionSuperValueWeeklyCardPanel:register_event()
    registerButtonEventListener(self.btn_charge, function() self:onClickCharge() end, true, 1)
    if self.update_event == nil then
        self.update_event = GlobalEvent:getInstance():Bind(ActionEvent.SuperValueWeeklyCard_Init_Event, function(data) self:setData(data) end)
    end

    if self.charge_event == nil then
        self.charge_event = GlobalEvent:getInstance():Bind(ActionEvent.Is_Charge_Event,
        function(data)
            if self.cur_charge_id and data and self.cur_charge_id == data.charge_id and data.status == 1 then
                local charge_list = Config.ChargeData.data_charge_data
                if self.cur_charge_id and charge_list[self.cur_charge_id] then
                    sdkOnPay(charge_list[self.cur_charge_id].val, 1, charge_list[self.cur_charge_id].id, charge_list[self.cur_charge_id].name)
                end
            end
        end)
    end
end

function ActionSuperValueWeeklyCardPanel:setData(data)
    if not data then
        return
    end
    self.data = data
    --倒计时
    if self.data.is_buy and self.data.is_buy == 1 then
        self.txt_time_title:setVisible(false)
        self.txt_time_val:setVisible(false)
        self.btn_charge:setVisible(false)
    else
        self.txt_time_title:setVisible(true)
        self.txt_time_val:setVisible(true)
        self.btn_charge:setVisible(true)
        local time = self.data.end_time - GameNet:getInstance():getTime()
        model:setCountDownTime(self.txt_time_val, time)
        self.cur_charge_id = self.data.charge_id
        if self.cur_charge_id then
            local charge_list = Config.ChargeData.data_charge_data
            if self.cur_charge_id and charge_list and charge_list[self.cur_charge_id] then
                self.txt_charge:setString(charge_list[self.cur_charge_id].val .. TI18N("元"))
            end
        end
    end
    self:awardListData()
end

function ActionSuperValueWeeklyCardPanel:awardListData()
    local award_list_data = model:getSuperWeekAward()
    if award_list_data and next(award_list_data) then
        for i = 1, 7 do
            if self.award_item_list and self.award_item_list[i] and award_list_data[i] then
                self.award_item_list[i]:setData(award_list_data[i])
            end
        end
    end
end

function ActionSuperValueWeeklyCardPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function ActionSuperValueWeeklyCardPanel:onClickCharge()
    if self.cur_charge_id ~= nil then
        ActionController:getInstance():sender21016(self.cur_charge_id)
    end
end

function ActionSuperValueWeeklyCardPanel:createAwardItem()
    if self.award_item_list == nil then self.award_item_list = {} end
    for i = 1, 7 do
        local award_item = self.award_item_list[i] or ActionSuperValueWeeklyCardItem.new()
        local parent = self.award_group:getChildByName("award_item_" .. i)
        if parent then
            parent:addChild(award_item)
            self.award_item_list[i] = award_item
        end
    end
end

function ActionSuperValueWeeklyCardPanel:DeleteMe()
    doStopAllActions(self.txt_time_val)
    if self.background_load then
        self.background_load:DeleteMe()
        self.background_load = nil
    end
    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.charge_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.charge_event)
        self.charge_event = nil
    end
    if self.update_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_event)
        self.update_event = nil
    end
    for k, v in pairs(self.award_item_list) do
        if v.DeleteMe then
			v:DeleteMe()
			v = nil
		end
    end
    self.award_item_list = nil
end

----------------------@ 子项
ActionSuperValueWeeklyCardItem =
    class(
    "ActionSuperValueWeeklyCardItem",
    function()
        return ccui.Widget:create()
    end
)

function ActionSuperValueWeeklyCardItem:ctor()
    self:configUI()
    self:register_event()
end

function ActionSuperValueWeeklyCardItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_super_value_weekly_card_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(115, 150))
    self:setAnchorPoint(0, 0)

    self.container = self.root_wnd:getChildByName("container")
    self.name_txt = self.container:getChildByName("name_txt")
    self.time_txt = self.container:getChildByName("time_txt")
end

function ActionSuperValueWeeklyCardItem:register_event()
    self.container:addTouchEventListener(function(sender, event_type) 
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.data.id and self.data.finish == 1 then
                controller:sender16654(self.data.id)
            end
		end
	end)
end

function ActionSuperValueWeeklyCardItem:setData(data)
    if not data then
        return
    end
    self.data = data
    local less_time = self.data.award_time - GameNet:getInstance():getTime()
    if less_time <= (24 * 60 * 60) and less_time > 0 then
        commonCountDownTime(self.time_txt, less_time)
    else
        self.time_txt:setString(string_format(TI18N("第%s天"), self.data.id))
    end
    
    if self.data.award and self.data.award[1] then
        if not self.item_node then
            self.item_node = BackPackItem.new(false, true, false, 0.7, false, true)
            self.item_node:setDefaultTip(true, false)
            local container_size = self.container:getContentSize()
            self.item_node:setPosition(cc.p(container_size.width / 2, 80))
            self.container:addChild(self.item_node)
        end
        self.item_node:setBaseData(self.data.award[1].bid, self.data.award[1].num)
    end
     -- 设物品特效
     if self.item_effect == nil then
        if self.data.acv_id and self.data.acv_id ~= 0 and self.data.finish ~= 2 then
            local pos_x = self.item_node:getContentSize().width / 2
            local pos_y = self.item_node:getContentSize().height / 2
            local effect_action = "action"
            local scale = 1.0
            if self.data.acv_id == 263 then
                effect_action = "action1"
                scale = 1.1
            end
            self.item_effect = createEffectSpine(PathTool.getEffectRes(self.data.acv_id), cc.p(pos_x, pos_y), cc.p(0.5, 0.5), true, effect_action)
            self.item_effect:setScale(scale)
            self.item_node:addChild(self.item_effect)
        end
    elseif self.data and (self.data.acv_id == nil or self.data.acv_id == 0 or self.data.finish == 2) then
        self.item_effect:setVisible(false)
    else
        self.item_effect:setVisible(true)
    end

    self.item_node:setTouchEnabled(true)
    if self.data.finish == 0 then
        local item_name = self.item_node:getData().name
        if item_name then
            self.name_txt:setString(item_name)
        end
        self.item_node:setReceivedIcon(false)
    elseif self.data.finish == 1 then
        self.item_node:setTouchEnabled(false)
        self.name_txt:setString(TI18N("可领取"))
        self.item_node:setReceivedIcon(false)
    elseif self.data.finish == 2 then
        local item_name = self.item_node:getData().name
        if item_name then
            self.name_txt:setString(item_name)
        end
        self.item_node:setReceivedIcon(true)
    end
end

function ActionSuperValueWeeklyCardItem:DeleteMe()
    doStopAllActions(self.time_txt)
    if self.item_effect then
        self.item_effect:clearTracks()
        self.item_effect:removeFromParent()
        self.item_effect = nil
    end
    if self.item_node then
        self.item_node:DeleteMe()
        self.item_node = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
