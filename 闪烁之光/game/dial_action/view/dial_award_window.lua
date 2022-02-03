--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-26 15:04:37
-- @description    : 
		-- 转盘积分奖励
---------------------------------
local _controller = DialActionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

DialAwardWindow = DialAwardWindow or BaseClass(BaseView)

function DialAwardWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "seven_goal/seven_goal_adventure_lev_reward"
end

function DialAwardWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
	main_container:getChildByName("Text_1"):setString(TI18N("积分奖励"))

	self.btn_close = main_container:getChildByName("btn_close")

	local good_cons = main_container:getChildByName("good_cons")
	local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = DialAwardItem,      -- 单元类
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
end

function DialAwardWindow:register_event(  )
	registerButtonEventListener(self.btn_close, function (  )
		_controller:openDialAwardWindow(false)
	end, false, 2)

	self:addGlobalEvent(DialActionEvent.Update_Dial_Data_Event, function (  )
    	self:setData()
    end)
end

function DialAwardWindow:openRootWnd(  )
	self:setData()
end

function DialAwardWindow:setData(  )
	local award_data = _model:getDialAwardData()
	if not award_data or next(award_data) == nil then return end

	local show_data = {}
	local holiday_lv = _model:getDialHolidayLv()
	for k,aData in pairs(award_data) do
		local score_cfg = Config.HolidayDialData.data_score_award[aData.id]
		if score_cfg then
			for _,v in pairs(score_cfg) do
				if v.limit_lev_min <= holiday_lv and v.limit_lev_max >= holiday_lv then
					local s_data = {}
					s_data.id = aData.id
					s_data.status = aData.status
					s_data.config = v
					_table_insert(show_data, s_data)
					break
				end
			end
		end
	end

	local sort_index = {
		[0] = 2, -- 不能领取
		[1] = 1, -- 可领取
		[2] = 3, -- 已领取
	}
	local function sortFunc( objA, objB )
		if objA.status ~= objB.status then
			local status_index_a = sort_index[objA.status]
			local status_index_b = sort_index[objB.status]
			return status_index_a < status_index_b
		else
			return objA.id < objB.id
		end
	end
	table.sort(show_data, sortFunc)
	self.item_scrollview:setData(show_data)
end

function DialAwardWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openDialAwardWindow(false)
end

-----------------------------@ item
DialAwardItem = class("DialAwardItem", function()
    return ccui.Widget:create()
end)

function DialAwardItem:ctor()
	self:configUI()
	self:register_event()
end

function DialAwardItem:configUI()
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
    self.num_txt = main_container:getChildByName("num_txt")

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
    self.goods_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.goods_scrollview:setSwallowTouches(false)
end

function DialAwardItem:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.data then
            _controller:sender16673(self.data.id)
        end
    end,true, 1)
end

function DialAwardItem:setData(data)
	if not data or next(data) == nil then return end
    self.data = data

    self.has_spr:setVisible(data.status == 2)
    if data.status == 0 then  -- 不能领取
    	self.btn_get:setVisible(true)
    	setChildUnEnabled(true, self.btn_get)
    elseif data.status == 1 then -- 可领取
    	self.btn_get:setVisible(true)
    	setChildUnEnabled(false, self.btn_get)
    else
    	self.btn_get:setVisible(false)
    end

    -- 物品列表
    local item_list = {}
    if data.config then
    	for k, v in pairs(data.config.award_list or {}) do
	        local bid = v[1]
			local num = v[2]
			local vo = deepCopy(Config.ItemData.data_get_data(bid))
	        vo.quantity = num
	        _table_insert(item_list, vo)
	    end
        self.title_name:setString(string.format(TI18N("累积抽取%d次"), data.config.num or 0))

        -- 积分
        local have_score = _model:getDialScore()
        self.num_txt:setString(string.format("(%d/%d)", have_score, data.config.num))
        self.num_txt:setVisible(true)
    end
    self.goods_scrollview:setData(item_list)
    self.goods_scrollview:addEndCallBack(function()
        local list = self.goods_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end
function DialAwardItem:DeleteMe()
	if self.goods_scrollview then
		self.goods_scrollview:DeleteMe()
	end
	self.goods_scrollview = nil
	self:removeAllChildren()
	self:removeFromParent()
end