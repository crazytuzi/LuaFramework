--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-09-21 14:23:41
-- @description    : 
		-- 花火大会热度奖励界面
---------------------------------
local _controller = PetardActionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

PetardAwardWindow = PetardAwardWindow or BaseClass(BaseView)

function PetardAwardWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "seven_goal/seven_goal_adventure_lev_reward"
end

function PetardAwardWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2)
    main_container:getChildByName("Text_1"):setString(TI18N("活动奖励"))
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = PetardAwardItem,      -- 单元类
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
    self.award_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.award_scrollview:setSwallowTouches(false)

    self.btn_close = main_container:getChildByName("btn_close")
end

function PetardAwardWindow:register_event(  )
	registerButtonEventListener(self.btn_close, function ( )
		_controller:openPetardAwardWindow(false)
	end, true, 2)

    -- 刷新奖励
    self:addGlobalEvent(PetardActionEvent.Get_Base_Info_Event, function (  )
        self:setData()
    end)
end

function PetardAwardWindow:openRootWnd(  )
	self:setData()
end

function PetardAwardWindow:setData(  )
	local petard_data = _model:getPetardBaseInfo()
	if not petard_data then return end

	local function getLanternStateById( id )
        local state = PetardActionConst.Lantern_State.Lock
        for k,v in pairs(petard_data.score_award or {}) do
            if v.id == id then
                if v.status == 1 then -- 可领取
                    state = PetardActionConst.Lantern_State.CanGet
                elseif v.status == 2 then -- 已领取
                    state = PetardActionConst.Lantern_State.Got
                end
                break
            end
        end
        return state
    end

	local award_data = {}
	for i,cfg in ipairs(Config.HolidayPetardData.data_award) do
		local data = {}
		data.cfg = cfg
		data.cur_hot = petard_data.score
		data.state = getLanternStateById(cfg.id)
		_table_insert(award_data, data)
	end
	self.award_scrollview:setData(award_data)
end

function PetardAwardWindow:close_callback(  )
	if self.award_scrollview then
		self.award_scrollview:DeleteMe()
		self.award_scrollview = nil
	end
	_controller:openPetardAwardWindow(false)
end


---------------------------@ item
PetardAwardItem = class("PetardAwardItem", function()
    return ccui.Widget:create()
end)

function PetardAwardItem:ctor()
	self:configUI()
	self:register_event()
end

function PetardAwardItem:configUI(  )
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
        scale = 0.80                     -- 缩放
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function PetardAwardItem:setData( data )
	if not data then return end

	local config = data.cfg
	local state = data.state
	local cur_hot = data.cur_hot or 0

	if not config or not state then return end

	self.award_id = config.id

    local max_hot_val = _model:getMaxPetardHotVal()
	self.title_name:setString(_string_format(TI18N("全服烟花热度达到%d"), config.count/1000*max_hot_val))
	self.num_txt:setString(_string_format("(%d/%d)", cur_hot, config.count/1000*max_hot_val))
	self.num_txt:setVisible(true)

	local award_list = {}
	for i,v in ipairs(config.award) do
		local item_data = deepCopy(Config.ItemData.data_get_data(v[1]))
        if item_data then
            item_data.quantity = v[2]
            _table_insert(award_list, item_data)
        end
	end

	if #award_list > 4 then
        self.item_scrollview:setClickEnabled(true)
    else
        self.item_scrollview:setClickEnabled(false)
    end
	self.item_scrollview:setData(award_list)
	self.item_scrollview:addEndCallBack(function()
        local item_list = self.item_scrollview:getItemList()
        for k,v in pairs(item_list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)

	self.btn_get:setVisible(state ~= PetardActionConst.Lantern_State.Got)
	self.has_spr:setVisible(state == PetardActionConst.Lantern_State.Got)

    if state == PetardActionConst.Lantern_State.Lock then
    	setChildUnEnabled(true, self.btn_get)
    	self.btn_get:setTouchEnabled(false)
    else
    	setChildUnEnabled(false, self.btn_get)
    	self.btn_get:setTouchEnabled(true)
    end
end

function PetardAwardItem:register_event( )
	registerButtonEventListener(self.btn_get, handler(self, self.onClickGetBtn), true)
end

function PetardAwardItem:onClickGetBtn(  )
	if self.award_id then
		_controller:sender27007(self.award_id)
	end
end

function PetardAwardItem:DeleteMe(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	self:removeAllChildren()
	self:removeFromParent()
end