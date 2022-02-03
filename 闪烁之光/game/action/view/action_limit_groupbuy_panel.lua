-- --------------------------------------------------------------------
--- 限时团购
-- --------------------------------------------------------------------
local color_data = {
    [1] = cc.c4b(0xfb,0xef,0xb9,0xff)
}
local table_insert = table.insert
local holiday_data = Config.HolidayGrouponData.data_holiday_reward

ActionLimitGroupbuyPanel = class("ActionLimitGroupbuyPanel", function()
	return ccui.Widget:create()
end)

local controll = ActionController:getInstance()
function ActionLimitGroupbuyPanel:ctor(bid)
    self.holiday_bid = bid
    self.old_price = {} --原价
    self.new_price = {} --折扣价
    self.diamond_back = 0 --钻石返利
    self.remain_buy_num = {} --今日可购买数量
    self.discount_bar = {} --折扣进度条
    self.get_status = 1 -- 领取状态（1不可领）
    self.holiday_item_bid = 0

    self.cur_index = 1
    self:loadResources()
	
end
function ActionLimitGroupbuyPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("actionlimitgroup","actionlimitgroup"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_acc_limit"), type = ResourcesType.single },
    } 
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
            self:loadResListCompleted()
        end
    end)
end
function ActionLimitGroupbuyPanel:loadResListCompleted()
    self:configUI()
    self:register_event()
end
function ActionLimitGroupbuyPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_limit_groupbuy_panel"))
	self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setPosition(-40, -87)
	self:setAnchorPoint(0, 0)
	
	local main_container = self.root_wnd:getChildByName("main_container")
	local bg = main_container:getChildByName("bg")
    local res = PathTool.getPlistImgForDownLoad("bigbg/action", "action_acc_limit")
	if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(bg) then
    			loadSpriteTexture(bg, res, LOADTEXT_TYPE)
    		end
    	end,self.item_load)
    end

    main_container:getChildByName("Text_1"):setString(TI18N("团购人数越多，打折的力度越大，\n差价均返还，快来抢购吧！"))
    local back_bg = main_container:getChildByName("back_bg")
    back_bg:getChildByName("Text_2"):setString(TI18N("当前可返现："))
    self.back_sprite = back_bg:getChildByName("back_sprite")
    self.back_num = back_bg:getChildByName("back_num")
    self:setPrice(3,self.back_sprite,self.back_num,"")

    self.bar = main_container:getChildByName("bar")
    self.bar:setScale9Enabled(true)
    self.bar:setPercent(0)
    --是否营业
    self.start_layer = main_container:getChildByName("start_layer")
    self.start_layer:getChildByName("Text_3"):setString(TI18N("营业中"))
    self.start_layer:setVisible(true)
    self.time_text = self.start_layer:getChildByName("time_text")
    self.time_text:setString("00:00:00")
    self.pause_layer = main_container:getChildByName("pause_layer")
    self.pause_layer:getChildByName("Text_5"):setString(TI18N("暂停营业"))
    self.pause_layer:setVisible(false)

    --领取和购买
    self.get_layer = main_container:getChildByName("get_layer")
    self.get_layer:setVisible(false)
    self.btn_get = self.get_layer:getChildByName("btn_get")
    self.btn_get_label = self.btn_get:getChildByName("Text_20")
    self.btn_get_label:setString(TI18N("领取"))
    self.get_layer:getChildByName("Text_21"):setString(TI18N("当前可返现："))
    self.back_get_sprite = self.get_layer:getChildByName("back_get_sprite")
    self.back_get_text = self.get_layer:getChildByName("back_get_text")
    self:setPrice(3,self.back_get_sprite,self.back_get_text,"")

    self.buy_layer = main_container:getChildByName("buy_layer")
    self.buy_layer:setVisible(true)
    self.btn_buy = self.buy_layer:getChildByName("btn_buy")
    self.btn_buy:getChildByName("Text_14")
    self.btn_buy_label = self.btn_buy:getChildByName("Text_14")
    self.btn_buy_label:setString(TI18N("购买"))

    self.buy_layer:getChildByName("Text_15"):setString(TI18N("原价："))
    self.old_sprite = self.buy_layer:getChildByName("old_sprite")
    self.old_text = self.buy_layer:getChildByName("old_text")
    self:setPrice(3,self.old_sprite,self.old_text,"")

    self.buy_layer:getChildByName("Text_15_0"):setString(TI18N("现价："))
    self.new_sprite = self.buy_layer:getChildByName("new_sprite")
    self.new_text = self.buy_layer:getChildByName("new_text")
    self:setPrice(3,self.new_sprite,self.new_text,"")
    self.discount_line = self.buy_layer:getChildByName("discount_line")
    self.discount_line_size = self.discount_line:getContentSize()

    self.get_item = BackPackItem.new(nil,true)
    self.buy_layer:addChild(self.get_item)
    self.get_item:setPosition(cc.p(129, 144))
    self.get_item:setDefaultTip()
    
    local totle_lenght = main_container:getChildByName("Image_4")
    local break_lenght = totle_lenght:getContentSize().width / 4
    self.discount_list = {}
    for i=1,5 do
        local tab = {}
        local discount = main_container:getChildByName("discount_"..i)
        discount:setPositionX(totle_lenght:getPositionX()+break_lenght*(i-1))
        tab.num = discount:getChildByName("num")
        tab.num:setString("")
        tab.discount = discount:getChildByName("discount")
        tab.discount:setString("")
        self.discount_list[i] = tab
    end    

    self.limit_group_buy = createRichLabel(20, Config.ColorData.data_color4[1], cc.p(0.5,0.5), cc.p(360,290), nil, nil, nil)
    main_container:addChild(self.limit_group_buy)
    
    self.day_buy_totle = createRichLabel(24, color_data[1], cc.p(0,0.5), cc.p(210,101), nil, nil, nil)
    self.buy_layer:addChild(self.day_buy_totle)
    
    local good_con = main_container:getChildByName("good_con")
    local scroll_view_size = good_con:getContentSize()
    local setting = {
        item_class = BackPackItem,
        start_x = 0,
        space_x = 26,
        start_y = 19,
        space_y = 0,
        item_width = BackPackItem.Width * 0.8,
        item_height = BackPackItem.Height * 0.8,
        row = 1,
        col = 0,
        scale = 0.8
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_con,cc.p(0, 0),ScrollViewDir.horizontal,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview:setBounceEnabled(false)

    controll:cs16603(self.holiday_bid)
end

--显示的东西
function ActionLimitGroupbuyPanel:showDiscountReward(bid)
    local tab_list = {}
    if holiday_data[bid] then
        for i,v in ipairs(holiday_data[bid]) do
            local tab = {}
            tab.id = v.reward[1][1]
            tab.quantity = v.reward[1][2]
            table_insert(tab_list,tab)
        end
    end
    if next(tab_list) == nil then return end
    self.cur_index = self.cur_index or 1
    if tab_list[self.cur_index] then
        self.get_item:setBaseData(tab_list[self.cur_index].id, tab_list[self.cur_index].quantity)
    end
    self:tableView(self.cur_index)

    local function func(cell)
        local index = cell:getData()._index
        if self.cur_index == index then return end
        self.cur_index = index
        self.get_item:setBaseData(cell:getData().id, cell:getData().quantity)
        self:tableView(self.cur_index)
    end
    self.item_scrollview:setData(tab_list,func)
end
function ActionLimitGroupbuyPanel:tableView(index)
    index = index or 1
    self.old_text:setString(self.old_price[index] or 0)
    local text_width = self.old_text:getContentSize().width
    self.discount_line:setContentSize(cc.size(self.discount_line_size.width+text_width, self.discount_line_size.height))
    
    self.new_text:setString(self.new_price[index] or 0)

    self.back_get_text:setString(self.diamond_back or 0)
    self.back_num:setString(self.diamond_back or 0)

    self:setBuyLimitCount(index)

    local str = string.format(TI18N("已团购<div fontColor=#66ff00> %d </div>次"),self.discount_bar[index])
    self.limit_group_buy:setString(str)
    local bar_num = self:sectionCalculation(self.discount_bar[index], index)
    self.bar:setPercent(bar_num)
    for i=1,5 do
        if holiday_data[self.holiday_item_bid] then
            local num = holiday_data[self.holiday_item_bid][index].discount[i][2]*0.001 * 10
            self.discount_list[i].discount:setString(num..TI18N("折"))
            local totle = holiday_data[self.holiday_item_bid][index].discount[i][1]
            self.discount_list[i].num:setString(totle)
        end
    end
end

function ActionLimitGroupbuyPanel:setBuyLimitCount(index)
    if holiday_data[self.holiday_item_bid] and holiday_data[self.holiday_item_bid][index] then
        self.remain_buy_num[index] = self.remain_buy_num[index] or 0
        if self.remain_buy_num[index] <= 0 then
            self.remain_buy_num[index] = 0
        end

        local limit = holiday_data[self.holiday_item_bid][index].limit or 0
        local all_limit = holiday_data[self.holiday_item_bid][index].all_limit or 0
            
        local str = ""
        --活动期间可购买
        if limit == 0 then
            str = string.format(TI18N("活动期间可购买<div fontColor=#66ff00> %d </div>件"),self.remain_buy_num[index])
        else--每日购买
            str = string.format(TI18N("今日可购买<div fontColor=#66ff00> %d </div>件"),self.remain_buy_num[index])
        end
        self.day_buy_totle:setString(str)
        if self.remain_buy_num[index] == 0 then
            setChildUnEnabled(true, self.btn_buy)
            self.btn_buy_label:disableEffect(cc.LabelEffect.OUTLINE)
            self.btn_buy_label:setString(TI18N("已购买"))
            self.btn_buy:setTouchEnabled(false)
        else
            setChildUnEnabled(false, self.btn_buy)
            self.btn_buy_label:enableOutline(Config.ColorData.data_color4[264], 2)
            self.btn_buy_label:setString(TI18N("购买"))
            self.btn_buy:setTouchEnabled(true)
        end
    end
end

function ActionLimitGroupbuyPanel:setPrice(item,node_spr,node,node_text)
    local item_config = Config.ItemData.data_get_data(item)
    if not item_config then return end
    local res = PathTool.getItemRes(item_config.icon)
    loadSpriteTexture(node_spr, res, LOADTEXT_TYPE)
    if node then
        node:setString(node_text)
    end
end

--分段计算进度条
function ActionLimitGroupbuyPanel:sectionCalculation(num, index)
    if not holiday_data[self.holiday_item_bid] then return 0 end

    local segmeent = 25
    local percent = 1
    if holiday_data[self.holiday_item_bid][index] and holiday_data[self.holiday_item_bid][index].discount then
        local bar_list = holiday_data[self.holiday_item_bid][index].discount
        if num <= bar_list[2][1] then
            local per = num / bar_list[2][1] * segmeent
            return per
        elseif num > bar_list[2][1] and num <= bar_list[3][1] then
            percent = 3
        elseif num > bar_list[3][1] and num <= bar_list[4][1] then
            percent = 4
        elseif num > bar_list[4][1] and num <= bar_list[5][1] then
            percent = 5
        else
            return 100
        end
        local adv = bar_list[percent][1] - bar_list[percent-1][1]
        local count = num - bar_list[percent-1][1]
        local per = math.floor(segmeent*(percent-2) + ( count / adv ) * segmeent)
        return per
    else
        return 0
    end
end

--设置倒计时
function ActionLimitGroupbuyPanel:setLessTime(less_time)
    if tolua.isnull(self.time_text) then
        return
    end
    doStopAllActions(self.time_text)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_text:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    doStopAllActions(self.time_text)
                    self.start_layer:setVisible(false)
                    self.pause_layer:setVisible(true)

                    self.buy_layer:setVisible(false)
                    self.get_layer:setVisible(true)
                    self:refreshGetButStatus()
                else
                    self:setTimeFormatString(less_time)
                end
            end))))
    else
        self:setTimeFormatString(less_time)
        self.start_layer:setVisible(false)
        self.pause_layer:setVisible(true)

        self.buy_layer:setVisible(false)
        self.get_layer:setVisible(true)
        
        self:refreshGetButStatus()
    end
end

function ActionLimitGroupbuyPanel:refreshGetButStatus()
    if self.get_status == 1 then
        setChildUnEnabled(true, self.btn_get)
        self.btn_get_label:disableEffect(cc.LabelEffect.OUTLINE)
        self.btn_get_label:setString(TI18N("已领取"))
        self.btn_get:setTouchEnabled(false)
    else
        setChildUnEnabled(false, self.btn_get)
        self.btn_get_label:enableOutline(Config.ColorData.data_color4[263], 2)
        self.btn_get_label:setString(TI18N("领取"))
        self.btn_get:setTouchEnabled(true)
    end
end

function ActionLimitGroupbuyPanel:setTimeFormatString(time)
    if time > 0 then
        self.time_text:setString(TimeTool.GetTimeFormatDayIIIIIIII(time))
    else
        self.time_text:setString("00:00:00")
    end
end
function ActionLimitGroupbuyPanel:register_event()
    if not self.update_group_event  then
        self.update_group_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
            if not data then return end
            if self.holiday_bid == data.bid then
                self:setLimitGroupbuyData(data)
            end
        end)
    end    

    registerButtonEventListener(self.btn_get, function()
        if self.holiday_bid then
            controll:cs16604(self.holiday_bid, 0, 0)
        end
    end,true, 1)
    registerButtonEventListener(self.btn_buy, function()
        local function func()
            if self.holiday_bid then
                controll:cs16604(self.holiday_bid, self.cur_index, 0)
            end
        end
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(3).icon)
        local str = string.format(TI18N("是否消耗 <img src='%s' scale=0.3 />%s 购买商品?"), iconsrc, self.new_price[self.cur_index])
        CommonAlert.show(str, TI18N("确定"), func, TI18N("取消"),nil, CommonAlert.type.rich)        
    end,true, 1)
end

function ActionLimitGroupbuyPanel:setLimitGroupbuyData(data)
    local time = data.remain_sec or 0
    time = time - 24*60*60
    if time <= 0 then
        time = 0
    end
    self:setLessTime(time)
    self.diamond_back = data.finish or 0
    table.sort(data.aim_list, function(a,b) return a.aim < b.aim end)

    if data.aim_list then
        for i,v in ipairs(data.aim_list) do
            self:getBuyRealData(i,v.aim_args)
        end
    end
    local status_data = keyfind('args_key', 3, data.args) or nil
    if status_data then
        self.get_status = status_data.args_val or 0
    end
    local bid = keyfind('args_key', 4, data.args) or nil
    if bid then
        self.holiday_item_bid = bid.args_val or 0
    end

    self:showDiscountReward(self.holiday_item_bid)
    self:refreshGetButStatus()
end

function ActionLimitGroupbuyPanel:getBuyRealData(index,aim_args)
    self.old_price[index] = 0
    local price_list = keyfind('aim_args_key', 26, aim_args) or nil
    if price_list then
        self.old_price[index] = price_list.aim_args_val or 0
    end
    
    self.new_price[index] = 0
    local price_list = keyfind('aim_args_key', 27, aim_args) or nil
    if price_list then
        self.new_price[index] = price_list.aim_args_val or 0
    end
    
    self.remain_buy_num[index] = 0
    local totle_num,cur_num
    local totle_list = keyfind('aim_args_key', 2, aim_args) or nil
    if totle_list then
        totle_num = totle_list.aim_args_val or 0
    end
    local cur_list = keyfind('aim_args_key', 6, aim_args) or nil
    if cur_list then
        cur_num = cur_list.aim_args_val or 0
    end
    if totle_num and cur_num then
        self.remain_buy_num[index] = totle_num - cur_num
    end

    self.discount_bar[index] = 0
    local bar_list = keyfind('aim_args_key', 32, aim_args) or nil
    if bar_list then
        self.discount_bar[index] = bar_list.aim_args_val or 0
    end
end

function ActionLimitGroupbuyPanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
end

function ActionLimitGroupbuyPanel:DeleteMe()
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
	if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    doStopAllActions(self.time_text)

    if self.get_item then 
       self.get_item:DeleteMe()
       self.get_item = nil
    end
    if self.update_group_event then
        GlobalEvent:getInstance():UnBind(self.update_group_event)
        self.update_group_event = nil
    end
end