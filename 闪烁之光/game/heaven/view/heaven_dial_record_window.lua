--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-27 15:48:09
-- @description    : 
		-- 神装转盘抽奖记录
---------------------------------
local _controller = HeavenController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

HeavenDialRecordWindow = HeavenDialRecordWindow or BaseClass(BaseView)

function HeavenDialRecordWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "action/action_dial_record_window"
end

function HeavenDialRecordWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)  
	container:getChildByName("win_title"):setString(TI18N("祈祷记录"))
	container:getChildByName("myself_title"):setString(TI18N("个人记录"))
	container:getChildByName("all_title"):setString(TI18N("全服记录"))

	self.close_btn = container:getChildByName("close_btn")

	local my_record_list = container:getChildByName("my_record_list")
	local my_scroll_size = my_record_list:getContentSize()
    local setting = {
        item_class = HeavenDialRecordItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 542,               -- 单元的尺寸width
        item_height = 30,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.my_record_scrollview = CommonScrollViewLayout.new(my_record_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, my_scroll_size, setting)
    self.my_record_scrollview:setSwallowTouches(false)

	local all_record_list = container:getChildByName("all_record_list")
	local all_scroll_size = all_record_list:getContentSize()
    local setting = {
        item_class = HeavenDialRecordItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 542,               -- 单元的尺寸width
        item_height = 30,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.all_record_scrollview = CommonScrollViewLayout.new(all_record_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, all_scroll_size, setting)
    self.all_record_scrollview:setSwallowTouches(false)
end

function HeavenDialRecordWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openHeavenDialRecordWindow(false)
	end, false, 2)

	registerButtonEventListener(self.close_btn, function (  )
		_controller:openHeavenDialRecordWindow(false)
	end, true, 2)
	
	-- 数据返回
	self:addGlobalEvent(HeavenEvent.Update_Dial_Record_Data, function (  )
		self:setData()
	end)
end

function HeavenDialRecordWindow:setData(  )
	-- 个人记录
	local my_record_data = _model:getMyselfDialRecordData()
	self.my_record_scrollview:setData(my_record_data, nil, nil, 1)

	-- 全服记录
	local all_record_data = _model:getAllDialRecordData(self.group_id)
	self.all_record_scrollview:setData(all_record_data, nil, nil, 2)
end

function HeavenDialRecordWindow:openRootWnd( group_id )
	self.group_id = group_id
	_controller:sender25218(1, 0)
end

function HeavenDialRecordWindow:close_callback(  )
	if self.my_record_scrollview then
		self.my_record_scrollview:DeleteMe()
		self.my_record_scrollview = nil
	end
	if self.all_record_scrollview then
		self.all_record_scrollview:DeleteMe()
		self.all_record_scrollview = nil
	end
	_controller:openHeavenDialRecordWindow(false)
end

---------------------------@ item
HeavenDialRecordItem = class("HeavenDialRecordItem", function()
    return ccui.Widget:create()
end)

function HeavenDialRecordItem:ctor()
	self:configUI()
	self:register_event()

	self.r_type = 1 -- (1为自己，2为全服)
end

function HeavenDialRecordItem:configUI(  )
	self.size = cc.size(542, 30)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)
end

function HeavenDialRecordItem:register_event(  )
	
end

function HeavenDialRecordItem:setExtendData( r_type )
	self.r_type = r_type or 1
end

function HeavenDialRecordItem:setData( data )
	if not data then return end
	if not self.record_txt then
		self.record_txt = createRichLabel(24, cc.c3b(100,50,35), cc.p(0, 0.5), cc.p(0, self.size.height/2), nil, nil, 542)
		self:addChild(self.record_txt)
	end
    if data.bid then
        local item_cfg = Config.ItemData.data_get_data(data.bid)
        if item_cfg then
        	local txt_str = ""
        	local item_color = BackPackConst.getWhiteQualityColorStr(item_cfg.quality)
        	if self.r_type == 1 then
        		txt_str = _string_format(TI18N("获得  <div fontcolor=%s>  %s*%d</div>"), item_color, item_cfg.name, data.num)
        	elseif self.r_type == 2 then
        		txt_str = _string_format(TI18N("恭喜<div fontcolor=1c820a>  %s</div><div fontcolor=643223>  获得</div><div fontcolor=%s>  %s*%d</div>"), data.role_name, item_color, item_cfg.name, data.num)
        	end
            self.record_txt:setString(txt_str)
        end
    end
end

function HeavenDialRecordItem:DeleteMe(  )
	self:removeAllChildren()
    self:removeFromParent()
end