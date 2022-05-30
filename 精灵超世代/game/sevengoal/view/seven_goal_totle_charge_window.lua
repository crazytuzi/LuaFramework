--***************
--任务中累充奖励
--***************
SevenGoalTotleChargeWindow = SevenGoalTotleChargeWindow or BaseClass(BaseView)

local controller = SevenGoalController:getInstance()
local charge_list = Config.DayGoalsNewData.data_charge_list
local table_sort = table.sort
local table_insert = table.insert
function SevenGoalTotleChargeWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "seven_goal/seven_goal_adventure_lev_reward"
end

function SevenGoalTotleChargeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2)
    main_container:getChildByName("Text_1"):setString(TI18N("累充奖励"))
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = SevenGoalTotleChargeItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 608,               -- 单元的尺寸width
        item_height = 167,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.btn_close = main_container:getChildByName("btn_close")
end
function SevenGoalTotleChargeWindow:openRootWnd()
    if self.item_scrollview then
        local peroid = controller:getModel():getSevenGoalPeriod()
        local totle_charge_data = controller:getModel():getPeriodChargeTotalData()
        self.item_scrollview:setData(totle_charge_data,nil,nil,peroid)
    end
end
function SevenGoalTotleChargeWindow:register_event()
    self:addGlobalEvent(SevenGoalEvent.Tesk_Updata, function(data)
        if self.item_scrollview then
            local totle_charge_data = controller:getModel():getPeriodChargeTotalData()
            local peroid = controller:getModel():getSevenGoalPeriod()
            self.item_scrollview:setData(totle_charge_data,nil,nil,peroid)
        end
    end)

	registerButtonEventListener(self.btn_close, function()
    	controller:openSevenGoalTotleChargeView(false)
    end ,true, 1)
end
function SevenGoalTotleChargeWindow:close_callback()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	controller:openSevenGoalTotleChargeView(false)
end

------------------------------------------
-- 子项
SevenGoalTotleChargeItem = class("SevenGoalTotleChargeItem", function()
    return ccui.Widget:create()
end)

function SevenGoalTotleChargeItem:ctor()
	self:configUI()
	self:register_event()
end

function SevenGoalTotleChargeItem:configUI()
	self.size = cc.size(608,167)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("seven_goal/seven_goal_adventure_lev_reward_item"))
    self:addChild(self.root_wnd)
    local main_container = self.root_wnd:getChildByName("main_container")
    self.title_name = main_container:getChildByName("title_name")
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get_label = self.btn_get:getChildByName("Text_1")
    self.btn_get_label:setString(TI18N("领取"))
    self.btn_get:setVisible(false)
    self.has_spr = main_container:getChildByName("has_spr")
    self.has_spr:setVisible(false)

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.80,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.80,                     -- 缩放
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function SevenGoalTotleChargeItem:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.data then
            controller:sender13606(self.data.id)
        end
    end,true, 1)
end
function SevenGoalTotleChargeItem:setExtendData(period)
    self.cur_item_period = period
end
function SevenGoalTotleChargeItem:setData(data)
	if not data or next(data) == nil then return end
    self.data = data

    if charge_list[self.cur_item_period] and charge_list[self.cur_item_period][data.id] then
        if data.finish == 0 then
            setChildUnEnabled(true, self.btn_get)
            --self.btn_get_label:disableEffect(cc.LabelEffect.OUTLINE)
        else
            setChildUnEnabled(false, self.btn_get)
            --self.btn_get_label:enableOutline(Config.ColorData.data_color4[264], 2)
        end
        self.btn_get:setVisible(data.finish == 0 or data.finish == 1)
        self.has_spr:setVisible(data.finish == 2)
        
        self.title_name:setString(charge_list[self.cur_item_period][data.id].desc)
        local list = {}
        for k, v in pairs(charge_list[self.cur_item_period][data.id].award) do
            local vo = {}
            vo.bid = v[1]
            vo.quantity = v[2]
            table.insert(list, vo)
        end
        if #list > 4 then
            self.item_scrollview:setClickEnabled(true)
        else
            self.item_scrollview:setClickEnabled(false)
        end
        self.item_scrollview:setData(list)
        self.item_scrollview:addEndCallBack(function()
            local list = self.item_scrollview:getItemList()
            for k,v in pairs(list) do
                v:setDefaultTip()
                v:setSwallowTouches(false)
            end
        end)
    end
end
function SevenGoalTotleChargeItem:DeleteMe()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	self:removeAllChildren()
	self:removeFromParent()
end
