-- --------------------------------------------------------------------
-- 活动首冲+累充
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
ActionAccChargePanel = class("ActionAccChargePanel", function()
    return ccui.Widget:create()
end)

function ActionAccChargePanel:ctor(bid,type)
    self.holiday_bid = bid
	self.type = type
	self.ctrl = ActionController:getInstance()
	self.role_vo = RoleController:getInstance():getRoleVo()
    self.cur_select = nil
    self.cur_index = nil
	self:configUI()
	self:register_event()
end

function ActionAccChargePanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_acc_charge_panel"))
	self.root_wnd:setPosition(-40,-118)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.bg = self.main_container:getChildByName("background")
    local res = PathTool.getTargetRes("bigbg/action","action_acc_bg",false,false)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.bg) then
                self.bg:loadTexture(res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end


    self.title_con = self.main_container:getChildByName("title_con")
    self.title_img = self.title_con:getChildByName("title_img")
    local tab_vo = self.ctrl:getActionSubTabVo(self.holiday_bid)
    if tab_vo then
        if tab_vo.aim_title == nil or tab_vo.aim_title == "" then
            tab_vo.aim_title = "txt_cn_action_acc_title"
        end
        local res = PathTool.getTargetRes("bigbg/action",tab_vo.aim_title,false,false)
        if not self.item_load1 then
            self.item_load1 = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load1)
        end
    end

    self.tab_con = self.main_container:getChildByName("tab_con")
    self.btn_list = {}
    local btn_label_list = {TI18N("每日充值"),TI18N("连续充值")}
    for i=1,2 do 
    	local btn = self.tab_con:getChildByName("btn"..i)
        local arrow = btn:getChildByName("arrow") 
        local red_point = btn:getChildByName("red_point")

    	self.btn_list[i] = btn
        self.btn_list[i].arrow = arrow
        self.btn_list[i].arrow:setVisible(false)
        self.btn_list[i].red_point = red_point
        self.btn_list[i].red_point:setVisible(false)
        self.btn_list[i]:setBright(false)
        self.btn_list[i].label = self.btn_list[i]:getTitleRenderer()
        self.btn_list[i].label:setTextColor(Config.ColorData.data_color4[141])
    	btn:setTitleText(btn_label_list[i])
    end

    self.charge_con = self.main_container:getChildByName("charge_con")
    local time_title = self.title_con:getChildByName("time_title")
    time_title:setString(TI18N("剩余时间："))
    self.time_val = self.title_con:getChildByName("time_val")
    -- self.bar_val = self.charge_con:getChildByName("bar_val")

    --self.goods_con = self.charge_con:getChildByName("goods_con")
    local scroll_view_size = self.charge_con:getContentSize()
    local setting = {
        item_class = ActionAccDayItem,      -- 单元类
        start_x = 13,                  -- 第一个单元的X起点
        space_x = 2,                    -- x方向的间隔
        start_y = 12,                    -- 第一个单元的Y起点
        space_y = 12,                   -- y方向的间隔
        item_width = ActionAccDayItem.Width,               -- 单元的尺寸width
        item_height = ActionAccDayItem.Height,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.charge_con, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.charge_btn = self.main_container:getChildByName("charge_btn")
    self.charge_btn:setTitleText(TI18N("立即充值"))
    self.charge_btn.label = self.charge_btn:getTitleRenderer()
    if self.charge_btn.label ~= nil then
        self.charge_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end

    self.acc_charge_con = self.main_container:getChildByName("acc_charge_con")
    local scroll_view_size2 = self.acc_charge_con:getContentSize()
    local setting = {
        item_class = ActionAccChargeItem,      -- 单元类
        start_x = 3,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 4,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = ActionAccChargeItem.Width,               -- 单元的尺寸width
        item_height = ActionAccChargeItem.Height,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }

    self.item_scrollview1 = CommonScrollViewLayout.new(self.acc_charge_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size2, setting)
    self.item_scrollview1:setSwallowTouches(false)
end

function ActionAccChargePanel:register_event(  )
    if not self.update_action_even_event  then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if data.bid == self.holiday_bid then
                self.item_effect_list = data.item_effect_list
                self:setLessTime(data.remain_sec)
                if data.args and next(data.args)~=nil then 
                    for k,v in pairs(data.args) do
                        if v.args_key == 1 then --进度
                            self.has_num = v.args_val
                        end
                    end
                end
                --整理下数据
                self.today_list = {}
                self.acc_list = {}
                local temp = {}
                if data.aim_list and next(data.aim_list)~=nil then 
                    --找出今日累充和累充天数的数据
                    for k,v in pairs(data.aim_list) do
                        for a,j in pairs(v.aim_args) do
                            if j.aim_args_key == 3 then 
                                if j.aim_args_val == 1 then  --今日累充
                                    self.today_list[k] = v
                                    self.today_list[k].has_num = self.has_num
                                    self.today_list[k].item_effect_list = self.item_effect_list
                                elseif j.aim_args_val == 2 then
                                    self.acc_list[k] = v
                                    self.acc_list[k].item_effect_list = self.item_effect_list
                                end
                            elseif j.aim_args_key == 4 then --需要充值多少钱
                                if self.today_list[k] then 
                                    self.today_list[k].need_charge = j.aim_args_val
                                end
                                if self.acc_list[k] then 
                                    self.acc_list[k].need_charge = j.aim_args_val
                                end
                            elseif j.aim_args_key == 5 then --目标值 需要冲多少天
                                if self.today_list[k] then 
                                    self.today_list[k].charge_day = j.aim_args_val
                                end
                                if self.acc_list[k] then 
                                    self.acc_list[k].charge_day = j.aim_args_val
                                end
                            elseif j.aim_args_key == 6 then --计数
                                if self.today_list[k] then 
                                    self.today_list[k].has_charge = j.aim_args_val
                                end
                                if self.acc_list[k] then 
                                    self.acc_list[k].has_charge = j.aim_args_val
                                end
                            end
                        end
                    end
                end

                if self.cur_index then 
                    self:updateByIndex(self.cur_index)
                end
            end
        end)
    end

    for k,v in pairs(self.btn_list) do
        v:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:selectByBtn(k)
            end
        end)
    end

    self.charge_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            VipController:getInstance():openVipMainWindow(true)
            --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
        end
    end)
end

function ActionAccChargePanel:selectByBtn( index )
    if self.cur_index and self.cur_index==index then return end

    if self.cur_select then 
        self.cur_select:setBright(false)
        self.cur_select.arrow:setVisible(false)
        self.cur_select.label:setTextColor(Config.ColorData.data_color4[141])
    end

    self.cur_index = index
    self.cur_select = self.btn_list[index]
    self.cur_select:setBright(true)
    self.cur_select.arrow:setVisible(true)
    self.cur_select.label:setTextColor(Config.ColorData.data_color4[175])
    if index == 1 then --每日累充
        self.acc_charge_con:setVisible(false)
        self.charge_con:setVisible(true)
        if self.today_list and next(self.today_list)~=nil then
            self:createDaysList(self.today_list)
        end
    elseif index == 2 then --连续充值
        self.acc_charge_con:setVisible(true)
        self.charge_con:setVisible(false)
        if self.acc_list and next(self.acc_list)~=nil then
            self:createGoodsList(self.acc_list)
        end
    end
end

function ActionAccChargePanel:updateByIndex( index )
    if index == 1 then --每日累充
        self.acc_charge_con:setVisible(false)
        self.charge_con:setVisible(true)
        if self.today_list and next(self.today_list)~=nil then
            self:createDaysList(self.today_list)
        end
    elseif index == 2 then --连续充值
        self.acc_charge_con:setVisible(true)
        self.charge_con:setVisible(false)
        if self.acc_list and next(self.acc_list)~=nil then
            self:createGoodsList(self.acc_list)
        end
    end
    self:checkBtnRedList()
end

function ActionAccChargePanel:checkBtnRedList()
    local is_show_red = self:checkStatus(self.today_list)
    if self.btn_list[1] then
        self.btn_list[1].red_point:setVisible(is_show_red)
    end
    local show_list = {}
    for k, v in pairs(self.acc_list) do
        table.insert(show_list, v)
    end
    local is_show_red = self:checkGoodStatus(show_list)
    if self.btn_list[2] then
        self.btn_list[2].red_point:setVisible(is_show_red)
    end
end

function ActionAccChargePanel:createGoodsList( list )
    local show_list = {}
    for k,v in pairs(list) do
        table.insert(show_list,v)
    end
	self.item_scrollview1:setData(show_list)
    self.item_scrollview1:addEndCallBack(function (  )
        local list = self.item_scrollview1:getItemList()
        for k,v in pairs(list) do
            v:setHolidayBid(self.holiday_bid)
        end
    end)
    self:checkBtnRedList()
end

--判断是否还有没领的
function ActionAccChargePanel:checkGoodStatus(list)
    local is_not_get = false
    if list and next(list or {}) ~= 0 then
        for i, v in ipairs(list) do
            if v.status == 1 then
                is_not_get = true
            end
        end
    end
    return is_not_get
end

function ActionAccChargePanel:createDaysList( list )
    if list == nil or next(list) == nil then return end
    local action_list = {}
    for k,v in pairs(list) do
        table.insert( action_list, v )
    end

    self.charge_btn:setVisible(false)
    --[[local sum = self:checkGetStatus(action_list)
    if sum >= tableLen(action_list) then
        self.charge_btn:setVisible(false)
    else
        self.charge_btn:setVisible(true)
    end--]]

    self.item_scrollview:setData(action_list)
    self.item_scrollview:addEndCallBack(function (  )
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setHolidayBid(self.holiday_bid)
        end
    end)
    self:checkBtnRedList()

end
--检测按钮的状态
function ActionAccChargePanel:checkGetStatus(list)
    local sum = 0
    if list and next(list or {}) ~= 0 then
        for i,v in ipairs(list) do
            if v.status == 1 or v.status == 2 then
                sum = sum + 1
            end
        end
    end
    return sum
end

--判断是否还有没领的
function ActionAccChargePanel:checkStatus(list)
    local is_not_get = false
    if list and next(list or {}) ~= 0 then
        for i, v in ipairs(list) do
            if v.status == 1 then
                is_not_get = true
            end
        end
    end
    return is_not_get
end


--设置倒计时
function ActionAccChargePanel:setLessTime( less_time )
    if tolua.isnull(self.time_val) then return end
    self.time_val:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_val:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.time_val:stopAllActions()
            else
                self:setTimeFormatString(less_time)
            end
        end)
        )))
    else
        self:setTimeFormatString(less_time)
    end
end

function ActionAccChargePanel:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIII(time))
    else
        self.time_val:setString("")
    end
end

function ActionAccChargePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
    	ActionController:getInstance():cs16603(self.holiday_bid)
        self:selectByBtn(1)
    end
end

function ActionAccChargePanel:DeleteMe()
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.item_load1 then 
        self.item_load1:DeleteMe()
        self.item_load1 = nil
    end

	if self.item_scrollview then 
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end

    if self.item_scrollview1 then 
        self.item_scrollview1:DeleteMe()
        self.item_scrollview1 = nil
    end

    if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end

    doStopAllActions(self.time_val) 

end



-- --------------------------------------------------------------------
-- 累充 子项
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
ActionAccChargeItem = class("ActionAccChargeItem", function()
    return ccui.Widget:create()
end)

ActionAccChargeItem.Width = 219
ActionAccChargeItem.Height = 439

function ActionAccChargeItem:ctor()
	self.ctrl = ActionController:getInstance()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self:configUI()
	self:register_event()
end

function ActionAccChargeItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_acc_charge_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)
    self:setContentSize(cc.size(ActionAccChargeItem.Width,ActionAccChargeItem.Height))

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.desc = createRichLabel(26, 175, cc.p(0.5,1), cc.p(self.main_container:getContentSize().width/2,360))
    self.main_container:addChild(self.desc)

    self.scroll = self.main_container:getChildByName("scroll")
    self.btn = self.main_container:getChildByName("btn")
    self.btn:setTitleText(TI18N("领取"))
    self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(Config.ColorData.data_color4[277], 2)
    end

    local scroll_view_size = self.scroll:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 49,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 24,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.7
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.scroll, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function ActionAccChargeItem:setData( data )
    self.data = data
    local item_list = data.item_list
    local list = {}
    for k,v in pairs(item_list) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        vo.quantity = v.num
        table.insert(list,vo)
    end
    self.item_scrollview:setData(list)
    self.item_scrollview:addEndCallBack(function (  )
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            local data1 = v:getData()
            if data1 and data1.id then
                local bid = data1.id
                local quality = data1.quality
                for a,j in pairs(data.item_effect_list) do
                    if bid then
                        if bid == j.bid then
                            if quality >= 4 then
                                v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
                            else
                                v:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
                            end
                        end
                        -- if bid == j.bid then 
                        --     v:showItemEffect(true,165,"action",true,1.2)
                        -- end
                    end
                end
            end
        end
    end)
	--self.desc:setString(TI18N("累计充值")..data.charge_day..)
    self.desc:setString(string.format(TI18N("累计%s天 (%s/%s)\n  充值<div fontcolor=#249003>%s</div><img src=%s scale=0.25 visible=true />"),data.charge_day,data.has_charge,data.charge_day,data.need_charge,PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold)))

    self:changeChargeBtn(data.status)
end

function ActionAccChargeItem:register_event(  )
    self.btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()

                if self.data then
                    local status = self.data.status
                    if status == 1 then
                        self.ctrl:cs16604(self.holiday_bid,self.data.aim,0)
                    elseif status == 0 then 
                        VipController:getInstance():openVipMainWindow(true)
                        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
                    elseif status == 2 then 
                        message(TI18N("已经领取过了"))
                    end
                end

        end
    end)
end

function ActionAccChargeItem:setHolidayBid( bid )
    self.holiday_bid = bid
end

function ActionAccChargeItem:changeChargeBtn( status )
    if status == 0 then
        self.btn:setTitleText(TI18N("去充值"))
        --setChildUnEnabled(true, self.btn)
        --self.btn.label:disableEffect(cc.LabelEffect.OUTLINE)
        self.btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
        self.btn:loadTextures(PathTool.getResFrame("common", "common_1018"), "", "", LOADTEXT_TYPE_PLIST)
    elseif status == 1 then --可领
        self.btn:setTitleText(TI18N("领取"))
        setChildUnEnabled(false, self.btn)
        self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
        self.btn:loadTextures(PathTool.getResFrame("common", "common_1017"), "", "", LOADTEXT_TYPE_PLIST)
    elseif status == 2 then 
        self.btn:setTitleText(TI18N("已领取"))
        setChildUnEnabled(true, self.btn)
        self.btn.label:disableEffect(cc.LabelEffect.OUTLINE)
    end
end

function ActionAccChargeItem:DeleteMe()
    if self.item_scrollview then 
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end




-- --------------------------------------------------------------------
-- 活动每日首冲 子项
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
ActionAccDayItem = class("ActionAccDayItem", function()
    return ccui.Widget:create()
end)

ActionAccDayItem.Width = 679
ActionAccDayItem.Height = 154

function ActionAccDayItem:ctor()
    self.ctrl = ActionController:getInstance()
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:configUI()
    self:register_event()
end

function ActionAccDayItem:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_acc_day_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)
    self:setContentSize(cc.size(ActionAccDayItem.Width,ActionAccDayItem.Height))

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_label = self.main_container:getChildByName("title_label")
    self.coin = self.main_container:getChildByName("coin")
    self.exp = self.main_container:getChildByName("exp")
    self.exp:setString("")
    self.get = self.main_container:getChildByName("get")
    self.get:setVisible(false)
    self.btn = self.main_container:getChildByName("btn")

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.btn = self.main_container:getChildByName("btn")
    self.btn:setTitleText(TI18N("领取"))
    self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(Config.ColorData.data_color4[277], 2)
    end

    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 3,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 11,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.7
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function ActionAccDayItem:register_event(  )
    self.btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            --if self.cur_index then
                if self.data then
                    local status = self.data.status
                    if status == 1 then
                        self.ctrl:cs16604(self.holiday_bid,self.data.aim,0)
                    elseif status == 0 then 
                        VipController:getInstance():openVipMainWindow(true)
                        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
                    end
                end
            --end
        end
    end)
end

function ActionAccDayItem:setData( data )
    self.data = data
    self.title_label:setString(TI18N("累充")..data.need_charge..TI18N("钻"))
    self.exp:setString(data.has_num.."/"..data.need_charge)
    self.coin:setPositionX(self.exp:getPositionX()-self.exp:getContentSize().width)

    self:changeBtn(data.status)

    local item_list = data.item_list
    local list = {}
    for k,v in pairs(item_list) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        vo.quantity = v.num
        table.insert(list,vo)
    end
    self.item_scrollview:setData(list)
    self.item_scrollview:addEndCallBack(function (  )
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            local data1 = v:getData()
            if data1 and data1.id then
                local bid = data1.id
                local quality = data1.quality
                for a,j in pairs(data.item_effect_list) do
                    if bid then
                        if bid == j.bid then 
                            if quality >= 4 then
                                v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
                            else
                                v:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
                            end
                            --v:showItemEffect(true,165,"action",true,1.2)
                        end
                    end
                end
            end
        end
    end)
end

function ActionAccDayItem:setHolidayBid( bid )
    self.holiday_bid = bid
end

function ActionAccDayItem:changeBtn( status )
    if status == 0 then
        self.btn:setVisible(true)
        self.get:setVisible(false)
        self.btn:setTitleText(TI18N("去充值"))
        self.btn:loadTextures(PathTool.getResFrame("common", "common_1018"), "", "", LOADTEXT_TYPE_PLIST)
        self.btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
        --self.btn.label:disableEffect(cc.LabelEffect.OUTLINE)
        --setChildUnEnabled(true, self.btn)
    elseif status == 1 then 
        self.btn:setVisible(true)
        self.get:setVisible(false)
        self.btn:setTitleText(TI18N("领取"))
        --setChildUnEnabled(false, self.btn)
        self.btn:loadTextures(PathTool.getResFrame("common", "common_1017"), "", "", LOADTEXT_TYPE_PLIST)
        self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    elseif status == 2 then 
        self.btn:setVisible(false)
        self.get:setVisible(true)
        -- self.btn:setTitleText(TI18N("已领取"))
        -- setChildUnEnabled(false, self.btn)
    end
end

function ActionAccDayItem:DeleteMe()
    if self.item_scrollview then 
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end