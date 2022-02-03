--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-15 19:43:59
-- @description    : 
		-- 天界副本星级奖励
---------------------------------
local _controller = HeavenController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

HeavenStarAwardWindow = HeavenStarAwardWindow or BaseClass(BaseView)

function HeavenStarAwardWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "heaven/heaven_star_award_window"
end

function HeavenStarAwardWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)  

    local title_label = container:getChildByName("title_label")
    title_label:setString(TI18N("目标奖励"))
    
    self.close_btn = container:getChildByName("close_btn")

    local item_list = container:getChildByName("item_container")
	local scroll_view_size = item_list:getContentSize()
    local setting = {
        item_class = HeavenStarAwardItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 3,                   -- y方向的间隔
        item_width = 600,               -- 单元的尺寸width
        item_height = 156,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function HeavenStarAwardWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), nil, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), nil, 2)

	-- 领取奖励
	self:addGlobalEvent(HeavenEvent.Get_Chapter_Award_Event, function (  )
		self:setData()
	end)
end

function HeavenStarAwardWindow:_onClickCloseBtn(  )
	_controller:openHeavenStarAwardWindow(false)
end

function HeavenStarAwardWindow:setData(  )
	if self.chapter_id then
		local award_cfg = Config.DungeonHeavenData.data_star_award[self.chapter_id]
		if not award_cfg then return end

		local extend = {}
		extend.chapter_vo = _model:getChapterDataById(self.chapter_id)
		extend.chapter_id = self.chapter_id
		self.item_scrollview:setData(award_cfg, nil, nil, extend)
	end
end

function HeavenStarAwardWindow:openRootWnd( chapter_id )
	self.chapter_id = chapter_id

	self:setData()
end

function HeavenStarAwardWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openHeavenStarAwardWindow(false)
end

----------------------------@ item
HeavenStarAwardItem = class("HeavenStarAwardItem", function()
    return ccui.Widget:create()
end)

function HeavenStarAwardItem:ctor()
	self:configUI()
	self:register_event()
end

function HeavenStarAwardItem:configUI(  )
	self.size = cc.size(600, 156)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("heaven/heaven_star_award_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")

    self.go_btn = container:getChildByName("go_btn")
    self.go_btn:setTitleColor(Config.ColorData.data_color4[1])
    self.go_btn:setTitleText(TI18N("前往"))
    self.go_btn_label = self.go_btn:getTitleRenderer()
    if self.go_btn_label ~= nil then
        self.go_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
    self.get_btn = container:getChildByName("get_btn")
    self.get_btn:setTitleColor(Config.ColorData.data_color4[1])
    self.get_btn:setTitleText(TI18N("领取"))
    self.get_btn_label = self.get_btn:getTitleRenderer()
    if self.get_btn_label ~= nil then
        self.get_btn_label:enableOutline(Config.ColorData.data_color4[263], 2)
    end
    self.btn_has = container:getChildByName("btn_has")

    self.title_label = container:getChildByName("title_label")

    local award_list = container:getChildByName("award_list")
    local bgSize = award_list:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height)
	local scale = 0.8
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*scale,               -- 单元的尺寸width
        item_height = BackPackItem.Height*scale,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    	scale = scale
    }
    self.good_scrollview = CommonScrollViewLayout.new(award_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.good_scrollview:setSwallowTouches(false)
end

function HeavenStarAwardItem:register_event(  )
	registerButtonEventListener(self.go_btn, function (  )
		self:_onClickGoBtn()
	end, true)

	registerButtonEventListener(self.get_btn, function (  )
		self:_onClickGetBtn()
	end, true)
end

-- 前往
function HeavenStarAwardItem:_onClickGoBtn(  )
	if self.chapter_id then
		_controller:openHeavenChapterWindow(true, self.chapter_id)
		_controller:openHeavenStarAwardWindow(false)
	end
end

-- 领取
function HeavenStarAwardItem:_onClickGetBtn(  )
	if self.chapter_id and self.data then
		_controller:sender25215(self.chapter_id, self.data.award_id)
	end
end

function HeavenStarAwardItem:setExtendData( extend )
	self.chapter_id = extend.chapter_id
	self.chapter_vo = extend.chapter_vo or {}
end

function HeavenStarAwardItem:setData( data )
	if not data then return end

	self.data = data

	local cur_star_num = self.chapter_vo.all_star or 0
	local max_star_num = data.limit_star or 0

	-- 标题
	self.title_label:setString(_string_format(TI18N("本章达成%d个星级目标(%d/%d)"), data.limit_star, cur_star_num, max_star_num))

	-- 奖励
	local award_data = {}
	for i,v in ipairs(data.award) do
		local bid = v[1]
		local num = v[2]
		local vo = deepCopy(Config.ItemData.data_get_data(bid))
        vo.quantity = num
        _table_insert(award_data, vo)
	end
	self.good_scrollview:setData(award_data)
	self.good_scrollview:addEndCallBack(function ()
		local list = self.good_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
        end
	end)

	-- 按钮状态
	local award_status = self:getAwardStatus(data.award_id)
	if award_status == 0 then
		self.go_btn:setVisible(true)
		self.get_btn:setVisible(false)
		self.btn_has:setVisible(false)
	elseif award_status == 1 then
		self.go_btn:setVisible(false)
		self.get_btn:setVisible(true)
		self.btn_has:setVisible(false)
	else
		self.go_btn:setVisible(false)
		self.get_btn:setVisible(false)
		self.btn_has:setVisible(true)
	end
end

-- 0:未达成 1:可领取  2:已领取
function HeavenStarAwardItem:getAwardStatus( award_id )
	local status = 0
	if self.chapter_vo.award_info then
		for k,v in pairs(self.chapter_vo.award_info) do
			if v.id == award_id then
				status = v.flag
				break
			end
		end
	end
	return status
end

function HeavenStarAwardItem:DeleteMe(  )
	if self.good_scrollview then
		self.good_scrollview:DeleteMe()
		self.good_scrollview = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end
