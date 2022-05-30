--***************
--七天目标等级奖励
--***************
SevenGoalAdventureLevRewardWindow = SevenGoalAdventureLevRewardWindow or BaseClass(BaseView)

local controller = SevenGoalController:getInstance()
local lev_list = Config.DayGoalsNewData.data_make_lev_list
local table_insert = table.insert
local table_sort = table.sort
function SevenGoalAdventureLevRewardWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "seven_goal/seven_goal_adventure_lev_reward"
end

function SevenGoalAdventureLevRewardWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2)
    main_container:getChildByName("Text_1"):setString(TI18N("等级奖励"))
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = SevenGoalAdventureLevRewardItem,      -- 单元类
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
function SevenGoalAdventureLevRewardWindow:openRootWnd()
	controller:sender13607()
end

function SevenGoalAdventureLevRewardWindow:sortItemList(list)
    local function sortFunc(objA,objB)
        if objA.status == 1 and objB.status == 0 then
        	return false
        elseif objA.status == 0 and objB.status == 1 then
        	return true
        else
            return objA.lev < objB.lev
        end
    end
    table_sort(list, sortFunc)
end
function SevenGoalAdventureLevRewardWindow:register_event()
	self:addGlobalEvent(SevenGoalEvent.Reward_Lev, function(data)
		if not data or next(data) == nil then return end
		if self.item_scrollview then
			local tab_list = {}
			local peroid = controller:getModel():getSevenGoalPeriod()
            if lev_list[peroid]  then
    			for i,v in pairs(lev_list[peroid]) do
    				if controller:getModel():getSevenGoalLevData(v.lev) == true then
    					v.status = 1
    				else
    					v.status = 0
    				end
    				table_insert(tab_list,v)
    			end
    			table_sort(tab_list,function(a,b) return a.lev < b.lev end)
    			self:sortItemList(tab_list)

    			local tab = {}
    			tab.make_lev = data.lev
    			self.item_scrollview:setData(tab_list,nil,nil,tab)
            end
		end 
	end)

	registerButtonEventListener(self.btn_close, function()
    	controller:openSevenGoalAdventureLevRewardView(false)
    end ,true, 1)
end
function SevenGoalAdventureLevRewardWindow:close_callback()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	controller:openSevenGoalAdventureLevRewardView(false)
end

------------------------------------------
-- 子项
SevenGoalAdventureLevRewardItem = class("SevenGoalAdventureLevRewardItem", function()
    return ccui.Widget:create()
end)

function SevenGoalAdventureLevRewardItem:ctor()
	self:configUI()
	self:register_event()
end

function SevenGoalAdventureLevRewardItem:configUI()
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
        scale = 0.80                     -- 缩放
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function SevenGoalAdventureLevRewardItem:register_event()
	registerButtonEventListener(self.btn_get, function()
		if self.data then
	    	controller:sender13608(self.data.lev)
	    end
    end ,true, 1)
end
function SevenGoalAdventureLevRewardItem:setExtendData(tab)
	self.make_lev = tab.make_lev or 0
end
function SevenGoalAdventureLevRewardItem:setData(data)
	if not data or next(data) == nil then return end
	self.data = data

	self.title_name:setString(data.title_name)
	self.btn_get:setVisible(data.status == 0)
	self.has_spr:setVisible(data.status == 1)
	if data.lev <= self.make_lev then
        setChildUnEnabled(false, self.btn_get)
        --self.btn_get_label:enableOutline(Config.ColorData.data_color4[264], 2)
	else
        setChildUnEnabled(true, self.btn_get)
        --self.btn_get_label:disableEffect(cc.LabelEffect.OUTLINE)
	end

	local list = {}
	local peroid = controller:getModel():getSevenGoalPeriod()
    if lev_list[peroid] then
        for k, v in pairs(lev_list[peroid][data.lev].reward) do
            local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
            if vo then
                vo.quantity = v[2]
                table.insert(list, vo)
            end
        end
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
function SevenGoalAdventureLevRewardItem:DeleteMe()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	self:removeAllChildren()
	self:removeFromParent()
end
