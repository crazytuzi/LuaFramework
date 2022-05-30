-- --------------------------------------------------------------------
-- 0.1元礼包
-- --------------------------------------------------------------------
OneCentGiftWindow = OneCentGiftWindow or BaseClass(BaseView)

local controller = OnecentgiftController:getInstance()
local controll_action = ActionController:getInstance()
local model = controller:getModel()
local config = Config.HolidayDimeData
local string_format = string.format
function OneCentGiftWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "action/action_one_cent_gift_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("onecent", "onecent"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("onecent", "onecent_bg"), type = ResourcesType.single}
    }
end

function OneCentGiftWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setAnchorPoint(cc.p(0.5, 0.5))
    self.background:setPosition(360, 640)
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)
    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.btn_label = self.btn_buy:getChildByName("label")
    self.btn_close = self.main_container:getChildByName("btn_close")
    self.price_img = self.main_container:getChildByName("price_img")

    self.original_price = self.main_container:getChildByName("original_price")
    self.original_price:setString(TI18N("原价："))
    self.original_price_val = self.main_container:getChildByName("original_price_val")

    self.time_text = self.main_container:getChildByName("time_text")
    self.time_text:setString(TI18N("剩余可购买时间："))
    self.time_text_val = self.main_container:getChildByName("time_text_val")

    self.image_bg = self.main_container:getChildByName("image_bg")
    local str = "onecent_bg"
    local bg_res = PathTool.getPlistImgForDownLoad("onecent", str)
    if not self.background_load then
        self.background_load = loadSpriteTextureFromCDN(self.image_bg, bg_res, ResourcesType.single, self.background_load)
    end

    self.goods_item = self.main_container:getChildByName("goods_item")
    local scroll_view_size = self.goods_item:getContentSize()
    local setting = {
        start_x = 0, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = 720, -- 单元的尺寸width
        item_height = 115, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 1, -- 列数，作用于垂直滚动类型
        need_dynamic = true
        -- checkovercallback = handler(self, self.updateSlideShowByVertical)
    }
    self.reward_goods_item = CommonScrollViewSingleLayout.new(self.goods_item, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.reward_goods_item:setSwallowTouches(true)

    self.reward_goods_item:registerScriptHandlerSingle(handler(self, self.CreateNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.reward_goods_item:registerScriptHandlerSingle(handler(self, self.NumberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.reward_goods_item:registerScriptHandlerSingle(handler(self, self.UpdateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function OneCentGiftWindow:openRootWnd()
    model:setFirstRed(false)
    controller:send16651()
    local const_config = config.data_constant
    if const_config and const_config.original_price then
        self.original_price_val:setString(const_config.original_price.val .. TI18N("元"))
    end
    self.text_effect = createEffectSpine(PathTool.getEffectRes(355), cc.p(358, 639), cc.p(0.5, 0.5), true, PlayerAction.action_1)
    self.main_container:addChild(self.text_effect)
end

function OneCentGiftWindow:register_event()
    self:addGlobalEvent(
        OnecentgiftEvent.Onecentgift_Init_Event,
        function()
            self:setPanelData()
        end
    )

    self:addGlobalEvent(
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

    registerButtonEventListener(
        self.background,
        function()
            controller:openOnecentiftView(false)
        end,
        false,
        2
    )

    registerButtonEventListener(
        self.btn_buy,
        function()
            local period = model:getCurPeriod()
            local period_config = config.data_period_list
            local charge_id
            if period_config and period_config[period] then
                charge_id = period_config[period].change_id
            end
            local charge_list = Config.ChargeData.data_charge_data
            if charge_id and charge_list[charge_id] then
                self.cur_charge_id = charge_list[charge_id].id
                ActionController:getInstance():sender21016(self.cur_charge_id)
            end
        end,
        true,
        1
    )

    registerButtonEventListener(
        self.btn_close,
        function()
            controller:openOnecentiftView(false)
        end,
        true,
        1
    )
end

--奖励列表
function OneCentGiftWindow:CreateNewCell()
    local cell = OneCentGiftItem.new()
    return cell
end

function OneCentGiftWindow:NumberOfCells()
    if not self.reward_list then
        return 0
    end
    return #self.reward_list
end

function OneCentGiftWindow:UpdateCellByIndex(cell, index)
    if not self.reward_list then
        return
    end
    local cell_data = self.reward_list[index]
    if not cell_data then
        return
    end

    cell:setData(cell_data)
end

function OneCentGiftWindow:setPanelData()
    local period = model:getCurPeriod()
    local period_config = config.data_period_list
    local charge_list = Config.ChargeData.data_charge_data
    if period_config and period_config[period] then
        local charge_id = period_config[period].change_id
        if charge_id and charge_list[charge_id] then
            self.btn_label:setString(charge_list[charge_id].val .. TI18N("元购买"))
        end
    end
    if model:getIsBuy() then
        setChildUnEnabled(true, self.btn_buy, Config.ColorData.data_color4[1])
        self.btn_buy:setTouchEnabled(false)
        self.btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    else
        setChildUnEnabled(false, self.btn_buy, Config.ColorData.data_color4[1])
        self.btn_label:enableOutline(Config.ColorData.data_color4[277], 2)
        self.btn_buy:setTouchEnabled(true)
    end
    self.reward_list = model:getAwardData()
    self.reward_goods_item:reloadData()
    local img_res = ""
    if self.text_effect then
        if model:getIsCheap() then
            self.text_effect:setAnimation(0, PlayerAction.action_1, true)
            img_res = PathTool.getResFrame("onecent", "onecent_3")
        else
            self.text_effect:setAnimation(0, PlayerAction.action_2, true)
            img_res = PathTool.getResFrame("onecent", "onecent_4")
        end
    end
    self.price_img:loadTexture(img_res, LOADTEXT_TYPE_PLIST)
    if model:getEndTime() == 0 then
        self.time_text:setVisible(false)
        self.time_text_val:setVisible(false)
    else
        local time = model:getEndTime() - GameNet:getInstance():getTime()
        commonCountDownTime(
            self.time_text_val,
            time,
            {
                callback = function(time)
                    self:countDownTimeCallBack(time)
                end
            }
        )
    end
end

function OneCentGiftWindow:countDownTimeCallBack(time)
    if time <= 0 then
        controller:openOnecentiftView(false)
    else
        self.time_text_val:setString(TimeTool.GetTimeForFunction(time))
    end
end

function OneCentGiftWindow:close_callback()
    doStopAllActions(self.main_container)
    doStopAllActions(self.time_text_val)
    if self.background_load then
        self.background_load:DeleteMe()
        self.background_load = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.text_effect then
        self.text_effect:clearTracks()
        self.text_effect:removeFromParent()
    end
    self.text_effect = nil
    controller:openOnecentiftView(false)
end

---------------------------@ 子项
OneCentGiftItem =
    class(
    "OneCentGiftItem",
    function()
        return ccui.Widget:create()
    end
)

function OneCentGiftItem:ctor()
    self:configUI()
    self:register_event()
end

function OneCentGiftItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_one_cent_gift_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(720, 115))
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.pic_has = self.main_container:getChildByName("pic_has")
    self.btn_get = self.main_container:getChildByName("btn_get")
    self.btn_txt = self.btn_get:getChildByName("label")
    self.text_remian = self.main_container:getChildByName("Text_4")
    self.condition_txt = self.main_container:getChildByName("condition_txt")
    self.select_group = self.main_container:getChildByName("select_group")
    self.select_group:setTouchEnabled(false)
    self.goods_item = BackPackItem.new(true, true, nil, 1, false)
    self.goods_item:setPosition(cc.p(170, self.main_container:getContentSize().height / 2))
    self.goods_item:setAnchorPoint(cc.p(0.5, 0.5))
    self.goods_item:setScale(0.8)
    self.goods_item:setDefaultTip()
    self.goods_item:setSwallowTouches(false)
    self.main_container:addChild(self.goods_item)
end

function OneCentGiftItem:register_event()
    registerButtonEventListener(
        self.btn_get,
        function()
            if self.data and self.data.id then
                controller:send16652(self.data.id)
            end
        end,
        true
    )
end

function OneCentGiftItem:setData(data)
    if not data then
        return
    end

    self.data = data
    local vo = {}
    vo.bid = data.award[1][1]
    vo.quantity = data.award[1][2]
    self.goods_item:setData(vo)

    -- 奖励状态(0:不可领取 1:可领取 2:已领取)
    if data.rev_state == 0 then
        self.btn_get:setVisible(true)
        self.btn_txt:setString(TI18N("未达成"))
        self.pic_has:setVisible(false)
        setChildUnEnabled(true, self.btn_get, Config.ColorData.data_color4[1])
        self.btn_txt:disableEffect(cc.LabelEffect.OUTLINE)
        self.btn_get:setTouchEnabled(false)
    elseif data.rev_state == 1 then
        self.btn_get:setVisible(true)
        self.pic_has:setVisible(false)
        self.btn_txt:setString(TI18N("领取"))
        setChildUnEnabled(false, self.btn_get, Config.ColorData.data_color4[1])
        self.btn_txt:enableOutline(Config.ColorData.data_color4[277], 2)
        self.btn_get:setTouchEnabled(true)
    elseif data.rev_state == 2 then
        self.btn_get:setVisible(false)
        self.pic_has:setVisible(true)
    end
    if data.power_limit <= 0 then
        self.condition_txt:setString(string_format(TI18N("购买后立即领取")))
    else
        self.condition_txt:setString(string_format(TI18N("战力达到%d"), data.power_limit))
    end
    self.select_group:setVisible(data.is_select)
    self:setLightEffect()
end

function OneCentGiftItem:setLightEffect()
    if self.data and self.data.is_show_effect and self.data.is_show_effect == 1 then
        if self.lightEffect == nil then
            self.lightEffect = createEffectSpine(PathTool.getEffectRes(356), cc.p(360, 57), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.main_container:addChild(self.lightEffect)
        else
            self.lightEffect:setVisible(true)
        end
    elseif self.lightEffect ~= nil then
        self.lightEffect:setVisible(false)
    end
end

function OneCentGiftItem:DeleteMe()
    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
    if self.lightEffect then
        self.lightEffect:clearTracks()
        self.lightEffect:removeFromParent()
    end
    self.lightEffect = nil
    self:removeAllChildren()
    self:removeFromParent()
end
