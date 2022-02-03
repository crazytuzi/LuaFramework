--***************
--元宵厨房等级
--***************
AnimateYuanzhenKitchenLevWindow = AnimateYuanzhenKitchenLevWindow or BaseClass(BaseView)

local controller = AnimateActionController:getInstance()
local rewart_list = Config.HolidayMakeData.data_make_lev_list
local make_name = Config.HolidayMakeData.data_make_list
local table_insert = table.insert
local table_sort = table.sort
function AnimateYuanzhenKitchenLevWindow:__init(holiday_id)
	self.holiday_id = holiday_id
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "animateaction/animate_yuanzhen_kitchen_lev"
end

function AnimateYuanzhenKitchenLevWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = AnimateYuanzhenKitchenLevItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 608,               -- 单元的尺寸width
        item_height = 167,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.btn_close = main_container:getChildByName("btn_close")
end
function AnimateYuanzhenKitchenLevWindow:openRootWnd()
	controller:sender24805()
end

function AnimateYuanzhenKitchenLevWindow:sortItemList(list)
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
function AnimateYuanzhenKitchenLevWindow:register_event()
	self:addGlobalEvent(AnimateActionEvent.YuanZhenFestval_Kitchen_Lev, function(data)
		if not data or next(data) == nil then return end
		if self.item_scrollview then
			local tab_list = {}
			for i,v in pairs(rewart_list[self.holiday_id]) do
				if controller:getModel():getKitchenLevData(v.lev) == true then
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
			tab.holiday_id = self.holiday_id
			self.item_scrollview:setData(tab_list,nil,nil,tab)
		end
	end)
	registerButtonEventListener(self.btn_close, function()
    	controller:openAnimateYuanzhenKitchenLevWindow(false)
    end ,true, 1)
end
function AnimateYuanzhenKitchenLevWindow:close_callback()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	controller:openAnimateYuanzhenKitchenLevWindow(false)
end

------------------------------------------
-- 子项
AnimateYuanzhenKitchenLevItem = class("AnimateYuanzhenKitchenLevItem", function()
    return ccui.Widget:create()
end)

function AnimateYuanzhenKitchenLevItem:ctor()
	self:configUI()
	self:register_event()
end

function AnimateYuanzhenKitchenLevItem:configUI()
	self.size = cc.size(608,167)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("animateaction/animate_yuanzhen_kitchen_lev_item"))
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

    self.title_text = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(1,0.5), cc.p(583,143), nil, nil, 500)
	main_container:addChild(self.title_text)
end

function AnimateYuanzhenKitchenLevItem:register_event()
	registerButtonEventListener(self.btn_get, function()
		if self.data then
	    	controller:sender24807(self.data.lev)
	    end
    end ,true, 1)
end
function AnimateYuanzhenKitchenLevItem:setExtendData(tab)
	self.make_lev = tab.make_lev
	self.reward_id = tab.holiday_id
end
function AnimateYuanzhenKitchenLevItem:setData(data)
	if not data or next(data) == nil then return end
	self.data = data

	local str = string.format(TI18N("制作等级: %d级"),data.lev)
	self.title_name:setString(str)
	str = string.format(TI18N("解锁制作: <div fontcolor=#c85a00 >%s</div>"),data.unlock_name)
	self.title_text:setString(str)

	self.btn_get:setVisible(data.status == 0)
	self.has_spr:setVisible(data.status == 1)
	if data.lev <= self.make_lev then
		setChildUnEnabled(false, self.btn_get)
		self.btn_get_label:setColor(cc.c4b(0x71,0x28,0x04,0xff))
	else
		setChildUnEnabled(true, self.btn_get)
		self.btn_get_label:setColor(cc.c4b(0xff,0xff,0xff,0xff))
	end

	local list = {}
    for k, v in pairs(rewart_list[self.reward_id][data.lev].reward) do
        local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
        if vo then
            vo.quantity = v[2]
            table.insert(list, vo)
        end
    end
	self.item_scrollview:setData(list)
	self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
        end
    end)
end
function AnimateYuanzhenKitchenLevItem:DeleteMe()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	self:removeAllChildren()
	self:removeFromParent()
end
