--******** 文件说明 ********
-- @Author:      yuanqi@shiyue.com
-- @description: RFM个人推送礼包
-- @DateTime:    2020-03-18
-- *******************************
RfmPersonnalGiftWindow = RfmPersonnalGiftWindow or BaseClass(BaseView)

local controller = RfmPersonnalGiftController:getInstance()
local table_insert = table.insert
local table_sort = table.sort
local num_pos_x = 325 --数字的位置
function RfmPersonnalGiftWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.TOP_TAG
    if BaseView and BaseView.winMap then
        local is_mini = false
        for k, v in pairs(BaseView.winMap) do
            if v.layout_name and (v.layout_name == "mainui/item_exhibition_view" or  v.layout_name == "heaven/heaven_main_window") then
                self.win_type = WinType.Mini
                self.view_tag = ViewMgrTag.TOP_TAG
                is_mini = true
                break
            end
        end
        if not is_mini then
            for k, v in pairs(BaseView.winMap) do
                if v.win_type == WinType.Mini then
                    self.win_type = WinType.Mini
                    self.view_tag = ViewMgrTag.DIALOGUE_TAG
                    break
                end
            end
        end
    end
    self.layout_name = "rfmpersonalgift/rfm_personal_gift_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("personalgift", "rfmpersonalgift_bg"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("personalgift", "personalgift"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("num", "type30"), type = ResourcesType.plist}
    }
    self.item_list = {}
    self.max_index = 1 --最大个数
    self.touch_buy_btn = true
    self.charge_config = nil
end

function RfmPersonnalGiftWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)
    local image_bg = self.main_container:getChildByName("image_bg")
    local res = PathTool.getPlistImgForDownLoad("personalgift", "rfmpersonalgift_bg")
    image_bg:setPositionY(180)
    self.image_bg_load = loadSpriteTextureFromCDN(image_bg, res, ResourcesType.single, self.image_bg_load)
    self.item_scroll = self.main_container:getChildByName("item_scroll")
    self.item_scroll_size = self.item_scroll:getContentSize()
    self.item_scroll:setScrollBarEnabled(false)

    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.btn_buy_label = self.btn_buy:getChildByName("Text_1")
    self.btn_buy_label:setString("")
    self.time = self.main_container:getChildByName("time")
    self.time:setString("")
    self.limit_buy_text = self.main_container:getChildByName("limit_buy_text")
    self.limit_buy_text:setString("")
    self.gift_percent_num = CommonNum.new(30, self.main_container, nil, -5, cc.p(0.5, 0.5))
    self.gift_percent_num:setPosition(num_pos_x, 217)
    self.btn_close = self.main_container:getChildByName("btn_close")
    self.bubble_img = self.main_container:getChildByName("bubble_img")
    self.bubble_label = createRichLabel(22, cc.c4b(0xff, 0xf2, 0xa8, 0xff), cc.p(0, 0.5), cc.p(8, self.bubble_img:getContentSize().height / 2 + 5), 5, nil, 410)
    self.bubble_img:addChild(self.bubble_label)

    self.tab_page = self.main_container:getChildByName("tab_page")
    self.tab_page:setVisible(false)
    self.btn_left = self.tab_page:getChildByName("btn_left")
    self.btn_right = self.tab_page:getChildByName("btn_right")
    self.page_icon_group = self.tab_page:getChildByName("page_icon_group")
    self.page_icon_list = {}
    self:createEffect()
end

function RfmPersonnalGiftWindow:openRootWnd()
    controller:sender28900()
end

function RfmPersonnalGiftWindow:register_event()
    self:addGlobalEvent(
        ActionEvent.Is_Charge_Event,
        function(data)
            if self.charge_config and data and self.charge_config.id == data.charge_id and data.status == 1 then
                sdkOnPay(self.charge_config.val, 1, self.charge_config.id, self.charge_config.name)
            end
        end
    )
    self:addGlobalEvent(RfmPersonnalGiftEvent.Rfm_Personal_Gift_Event, function(data) self:selectData(data) end)
    registerButtonEventListener(self.btn_close, function() controller:openRfmPersonalGiftView(false) end, false, 2)
    -- registerButtonEventListener(self.background, function() controller:openRfmPersonalGiftView(false) end, false, 2)
    registerButtonEventListener(self.btn_buy, function() self:touchBtnCharge() end, true, 1)
    registerButtonEventListener(self.btn_left, function() self:onTouchLeft() end, false)
    registerButtonEventListener(self.btn_right, function() self:onTouchRight() end, false)
end

-- 创建背景特效
function RfmPersonnalGiftWindow:createEffect()
    self.bg_effect = createEffectSpine(PathTool.getEffectRes(519), cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.action_1)
    self.bg_effect:setPosition(self.main_container:getContentSize().width / 2, 280)
    self.main_container:addChild(self.bg_effect, -1)
    self.fg_effect = createEffectSpine(PathTool.getEffectRes(519), cc.p(40, 22), cc.p(0, 0), true, PlayerAction.action_2)
    self.main_container:addChild(self.fg_effect)
    self.fg_effect:setPosition(300, 180)
end

-- 创建或删除下方选择区域
function RfmPersonnalGiftWindow:createTab(status)
    if not status then
        self.tab_page:setVisible(false)
    else
        self.tab_page:setVisible(true)
        local tab_count = #self.data
        self.max_index = tab_count
        local distants = self.page_icon_group:getContentSize().width / tab_count
        self.max_index = tab_count
        for i = 1, tab_count do
            local integer, decimal = math.modf(tab_count / 2) --返回整数和小数部分
            local size = self.page_icon_group:getContentSize()
            local pos_x = 0
            if decimal == 0 then
                pos_x = (i - integer - 0.5) * distants + size.width / 2
            else
                pos_x = (i - integer - 1) * distants + size.width / 2
            end
            local tab_img
            if self.tab_list == nil then
                self.tab_list = {}
            end
            for k, v in pairs(self.tab_list) do -- 设置所有的都隐藏
                v:setVisible(true)
            end
            if self.tab_list ~= nil and self.tab_list[i] ~= nil then -- 已经创建过了的直接取
                tab_img = self.tab_list[i]
                tab_img:setPosition(cc.p(pos_x, size.height / 2))
            else
                tab_img = createSprite(PathTool.getResFrame("personalgift", "personalgift_2"), pos_x, size.height / 2, self.page_icon_group, cc.p(0.5, 0.5))
            end
            self.tab_list[i] = tab_img
        end
        for i = 1, #self.tab_list do -- 设置用到的显示，没用到的不显示
            if i <= tab_count then
                self.tab_list[i]:setVisible(true)
            else
                self.tab_list[i]:setVisible(false)
            end
        end
    end
end

-- 选择出未超时的礼包
function RfmPersonnalGiftWindow:selectData(data)
    local temp_data
    if data ~= nil and data.gift_list ~= nil then
        temp_data = data.gift_list
    else
        temp_data = self.data
    end
    if temp_data ~= nil then
        self.data = {}
        for k, v in pairs(temp_data) do
            local less_time = v.over_time - GameNet:getInstance():getTime()
            if less_time > 0 and v.buy_count < v.limit_count then
                table_insert(self.data, v)
            end
        end
        if #self.data <= 0 then
            controller:openRfmPersonalGiftView(false)
        else
            table_sort(self.data, function(a, b) return b.over_time < a.over_time end)
            self:setData()
        end
    end
end

function RfmPersonnalGiftWindow:setData()
    self.select_index = 0
    if #self.data > 1 then
        self:createTab(true)
    else
        self:createTab(false)
    end
    self:tabPageIconChange(1)
end

--点击充值按钮
function RfmPersonnalGiftWindow:touchBtnCharge()
    if not self.charge_config then
        return
    end
    if not self.touch_buy_btn then
        return
    end

    if self.buy_btn_ticket == nil then
        self.buy_btn_ticket =
            GlobalTimeTicket:getInstance():add(
            function()
                self.touch_buy_btn = true
                if self.buy_btn_ticket ~= nil then
                    GlobalTimeTicket:getInstance():remove(self.buy_btn_ticket)
                    self.buy_btn_ticket = nil
                end
            end,
            2
        )
    end
    self.touch_buy_btn = nil

    if self.charge_config.id then
        ActionController:getInstance():sender21016(self.charge_config.id)
    end
end

function RfmPersonnalGiftWindow:setRewardSetting(data)
    local setting = {}
    setting.scale = 0.7
    setting.space_x = 10
    setting.start_x = 0
    setting.is_center = true
    setting.max_count = 5
    local data_list1 = {}
    if data then
        for k, v in pairs(data) do
            table_insert(data_list1, {v.id, v.num})
        end
    end
    return setting, data_list1
end

-- 点击下方选择条
function RfmPersonnalGiftWindow:tabPageIconChange(index)
    if self.select_index == index then
        return
    end
    local cur_tab_data = self.data[index]
    if cur_tab_data == nil then
        return
    end
    local time = cur_tab_data.over_time - GameNet:getInstance():getTime()
    doStopAllActions(self.time)
    commonCountDownTime(
        self.time,
        time,
        {
            callback = function(time)
                self:countDownTimeCallBack(time)
            end
        }
    )

    self.bubble_label:setString(cur_tab_data.desc)
    local setting, list = self:setRewardSetting(cur_tab_data.award)
    self.item_list = commonShowSingleRowItemList(self.item_scroll, self.item_list, list, setting)

    self.limit_buy_text:setString(string.format(TI18N("限购: %d/%d"), cur_tab_data.limit_count - cur_tab_data.buy_count, cur_tab_data.limit_count))
    self.charge_config = Config.ChargeData.data_charge_data[cur_tab_data.charge_id]
    if cur_tab_data.buy_count >= cur_tab_data.limit_count then
        self.btn_buy_label:setString(TI18N("已购买"))
        setChildUnEnabled(true, self.btn_buy)
        self.btn_buy:setTouchEnabled(false)
        self.btn_buy_label:disableEffect(cc.LabelEffect.OUTLINE)
    else
        setChildUnEnabled(false, self.btn_buy, Config.ColorData.data_color4[1])
        self.btn_buy_label:enableOutline(Config.ColorData.data_color4[277], 2)
        self.btn_buy:setTouchEnabled(true)
        if self.charge_config then
            self.btn_buy_label:setString(self.charge_config.val .. TI18N("元"))
        end
    end

    self.gift_percent_num:setNum(cur_tab_data.costly_num, true)
    if self.icon_per == nil then
        self.icon_per = createSprite(nil, num_pos_x + self.gift_percent_num:getContentSize().width * 0.5, 188, self.main_container, cc.p(0, 0.5))
        loadSpriteTexture(self.icon_per, PathTool.getResFrame("type30", "type30_per"), LOADTEXT_TYPE_PLIST)
    else
        self.icon_per:setPositionX(num_pos_x + self.gift_percent_num:getContentSize().width * 0.5)
    end
    if self.tab_list then
        for k, v in pairs(self.tab_list) do
            loadSpriteTexture(v, PathTool.getResFrame("personalgift", "personalgift_2"), LOADTEXT_TYPE_PLIST)
        end
        if self.tab_list[index] then
            loadSpriteTexture(self.tab_list[index], PathTool.getResFrame("personalgift", "personalgift_1"), LOADTEXT_TYPE_PLIST)
        end
    end
    self.select_index = index
end

--左边
function RfmPersonnalGiftWindow:onTouchLeft()
    local index = self.select_index - 1
    if index < 1 then
        index = self.max_index
    end
    self:tabPageIconChange(index)
end

--右边
function RfmPersonnalGiftWindow:onTouchRight()
    local index = self.select_index + 1
    if index > self.max_index then
        index = 1
    end
    self:tabPageIconChange(index)
end

--倒计时
function RfmPersonnalGiftWindow:countDownTimeCallBack(time)
    for k, v in pairs(self.data) do
        less_time = v.over_time - GameNet:getInstance():getTime()
        if less_time <= 0 then
            self:selectData()
        end
    end

    if time >= 0 then
        self.time:setString(TimeTool.GetTimeFormat(time) .. TI18N("后礼包消失"))
    end
end

function RfmPersonnalGiftWindow:close_callback()
    doStopAllActions(self.time)
    if self.image_bg_load then
        self.image_bg_load:DeleteMe()
        self.image_bg_load = nil
    end
    if self.item_list then
        for i, v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    if self.gift_percent_num then
        self.gift_percent_num:DeleteMe()
        self.gift_percent_num = nil
    end
    if self.buy_btn_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_btn_ticket)
        self.buy_btn_ticket = nil
    end
    if self.fg_effect then
        self.fg_effect:clearTracks()
        self.fg_effect:removeFromParent()
    end
    self.fg_effect = nil
    if self.bg_effect then
        self.bg_effect:clearTracks()
        self.bg_effect:removeFromParent()
    end
    self.bg_effect = nil
    controller:openRfmPersonalGiftView(false)
end
