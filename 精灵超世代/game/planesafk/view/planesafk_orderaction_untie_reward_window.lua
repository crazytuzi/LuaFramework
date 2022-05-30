--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 购买进阶卡
-- @DateTime:    2020-02-14 20:08:18
-- *******************************
PlanesafkOrderactionUntieRewardWindow = PlanesafkOrderactionUntieRewardWindow or BaseClass(BaseView)

local controller = PlanesafkController:getInstance()
local model = controller:getModel()
function PlanesafkOrderactionUntieRewardWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "planesafk/planesafk_orderaction_untie_reward_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("planes","orderaction_bg"), type = ResourcesType.single},
    }
end

function PlanesafkOrderactionUntieRewardWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2)
    
    main_container:getChildByName("Text_3"):setString(TI18N("征战之证"))
    main_container:getChildByName("Text_3_0"):setString(TI18N("现在购买可立即解锁"))
    main_container:getChildByName("Text_3_1"):setString(TI18N("累计通关积分总计可获得"))

    local label_lock = createRichLabel(22, cc.c4b(0x2b, 0x19, 0x5e, 0xff), cc.p(0.5, 0.5), cc.p(305, 365), nil, nil, 400)
    local str = string.format(TI18N("<div fontcolor=#ffecac >激活征战之证，立即解锁</div><div fontcolor=#0DFD00 >5阶</div><div fontcolor=#ffecac >奖励！</div>"))
    label_lock:setString(str)
    main_container:addChild(label_lock)
    
    self.btn_change = main_container:getChildByName("btn_change")
    self.btn_change_label = self.btn_change:getChildByName("Text_6")
    local image_bg = main_container:getChildByName("Sprite_1")
    local res = PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_orderaction_bg")
    if not self.image_bg_load then
        self.image_bg_load = loadSpriteTextureFromCDN(image_bg, res, ResourcesType.single, self.image_bg_load)
    end

    if model:getGiftStatus() == 1 then
        self.btn_change:setTouchEnabled(false)
        setChildUnEnabled(true, self.btn_change)
        self.btn_change_label:disableEffect(cc.LabelEffect.OUTLINE)
    end
    self.goods_1 = main_container:getChildByName("goods_1")
    self.goods_1:setScrollBarEnabled(false)
    self.goods_2 = main_container:getChildByName("goods_2")
    self.goods_2:setScrollBarEnabled(false)
    self:setData()
end
function PlanesafkOrderactionUntieRewardWindow:setData()
	local card_list = Config.PlanesWarOrderData.data_advance_card_list
	local period = model:getCurPeriod()
	if card_list and card_list[period] then
		local data_list = card_list[period].client_reward_1 or {}
		local setting = {}
		setting.scale = 0.7
        setting.space_x = 3
		setting.max_count = 4
		setting.is_center = true
		self.item_list1 = commonShowSingleRowItemList(self.goods_1, self.item_list1, data_list, setting)

		local data_list = card_list[period].client_reward_2 or {}
		local setting = {}
		setting.scale = 0.7
		setting.max_count = 4
		setting.is_center = true
        self.item_list2 = commonShowSingleRowItemList(self.goods_2, self.item_list2, data_list, setting)
        
        local charge_list = Config.ChargeData.data_charge_data
        local charge_id = card_list[period].charge_id or nil
        if charge_id and charge_list[charge_id] then
            self.btn_change_label:setString(string.format(TI18N("￥%d购买"),charge_list[charge_id].val))
        end
	end
end

function PlanesafkOrderactionUntieRewardWindow:register_event()
    self:addGlobalEvent(PlanesafkEvent.Planesafk_OrderAction_Init_Event, function()
        if model:getGiftStatus() == 1 then
            self.btn_change:setTouchEnabled(false)
            setChildUnEnabled(true, self.btn_change)
            self.btn_change_label:disableEffect(cc.LabelEffect.OUTLINE)
        end
    end)

    registerButtonEventListener(self.background, function()
        controller:openBuyCardView(false)
    end,false, 2)
    registerButtonEventListener(self.btn_change, function()
        self:changeWarn()
    end,true, 1)

    self:addGlobalEvent(ActionEvent.Is_Charge_Event, function(data)
        if self.cur_charge_id and data and self.cur_charge_id == data.charge_id and data.status == 1 then
            local charge_list = Config.ChargeData.data_charge_data
            local card_list = Config.PlanesWarOrderData.data_advance_card_list
            local period = model:getCurPeriod()
            if card_list and card_list[period] then
                local charge_id = card_list[period].charge_id or nil
                if charge_id and charge_list[charge_id] then
                    sdkOnPay(charge_list[charge_id].val, 1, charge_list[charge_id].id, charge_list[charge_id].name)
                end
            end
        end
    end)
end

function PlanesafkOrderactionUntieRewardWindow:changeWarn()
    local day = model:getCurDay()
    local charge_list = Config.ChargeData.data_charge_data
    local card_list = Config.PlanesWarOrderData.data_advance_card_list
    local period = model:getCurPeriod()
    
    if card_list and card_list[period] then
        local str = nil
        if day >= 39 then
            if day == 44 then
                str =  TI18N("活动将在今天结束，是否确认充值")
            else
                str = string.format(TI18N("活动将在 %d 天后结束，是否确认充值"),44-day)
            end            
        end

        if str then
            CommonAlert.show(str,TI18N("确定"),function()
                local charge_id = card_list[period].charge_id or nil
                if charge_id and charge_list[charge_id] then
                    self.cur_charge_id = charge_list[charge_id].id
                    ActionController:getInstance():sender21016(self.cur_charge_id)
                end
            end,TI18N("取消"),nil,CommonAlert.type.common,nil,{timer=5, timer_for=true},26)
        else
            local charge_id = card_list[period].charge_id or nil
            if charge_id and charge_list[charge_id] then
                self.cur_charge_id = charge_list[charge_id].id
                ActionController:getInstance():sender21016(self.cur_charge_id)
            end
        end
    end        
end
function PlanesafkOrderactionUntieRewardWindow:openRootWnd()
    
end
function PlanesafkOrderactionUntieRewardWindow:close_callback()
    if self.image_bg_load then
        self.image_bg_load:DeleteMe()
    end
    self.image_bg_load = nil
	if self.item_list1 then
        for i,v in pairs(self.item_list1) do
            v:DeleteMe()
        end
        self.item_list1 = nil
    end
    if self.item_list2 then
        for i,v in pairs(self.item_list2) do
            v:DeleteMe()
        end
        self.item_list2 = nil
    end
	controller:openBuyCardView(false)
end
