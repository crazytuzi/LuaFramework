--********************
--冒险宝箱奖励
--********************
AdventureBoxRewardWindow = AdventureBoxRewardWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
function AdventureBoxRewardWindow:__init(kill_master)
	self.kill_master = kill_master or 0
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "adventure/adventure_box_reward_window"
end

function AdventureBoxRewardWindow:open_callback()
	self.background = self.root_wnd:getChildByName("bg")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    main_container:getChildByName("title"):setString(TI18N("目标奖励"))
    self:playEnterAnimatianByObj(main_container, 2)
    self.btn_close = main_container:getChildByName("btn_close")

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = AdventureBoxRewardItem,      -- 单元类
        start_x = 10,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 600,               -- 单元的尺寸width
        item_height = 168,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end
function AdventureBoxRewardWindow:openRootWnd()
	self:updataTeskRewardList()
end
function AdventureBoxRewardWindow:sortItemList(list)
    local tempsort = {
        [0] = 2,  -- 0 未领取放中间
        [1] = 1,  -- 1 可领取放前面
        [2] = 3,  -- 2 已领取放最后
    }
    local function sortFunc(obj_a,obj_b)
        if obj_a.status ~= obj_b.status then
            if tempsort[obj_a.status] and tempsort[obj_b.status] then
                return tempsort[obj_a.status] < tempsort[obj_b.status]
            else
                return false
            end
        else
            return obj_a.id < obj_b.id
        end
    end
    table_sort(list, sortFunc)
end
function AdventureBoxRewardWindow:updataTeskRewardList()
    local reward_list = Config.AdventureData.data_round_reward_list
    if self.item_scrollview then
        local list = {}
        for i,v in pairs(reward_list) do
            v.status = 0
            if self.kill_master >= v.count then
                v.status = 1
            end
            if controller:getUiModel():getAdventureBoxStatus(v.id) == 2 then
                v.status = 2
            end
            table_insert(list,v)
        end
        self:sortItemList(list)
        self.item_scrollview:setData(list,nil,nil,self.kill_master)
    end
end
function AdventureBoxRewardWindow:register_event()
	registerButtonEventListener(self.btn_close, function()
        controller:openAdventureBoxRewardView(false)
    end,true,2)
    registerButtonEventListener(self.background, function()
        controller:openAdventureBoxRewardView(false)
    end,false,2)
    self:addGlobalEvent(AdventureEvent.UpdateBoxTeskEvent,function(data)
        self:updataTeskRewardList()
    end)
end
function AdventureBoxRewardWindow:close_callback()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	controller:openAdventureBoxRewardView(false)
end
------------------------------------------
-- 子项
AdventureBoxRewardItem = class("AdventureBoxRewardItem", function()
    return ccui.Widget:create()
end)

function AdventureBoxRewardItem:ctor()
	self:configUI()
	self:register_event()
end

function AdventureBoxRewardItem:configUI()
	self.size = cc.size(600,168)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("adventure/adventure_box_reward_item"))
    self:addChild(self.root_wnd)
    local main_container = self.root_wnd:getChildByName("main_container")
    self.name_text = main_container:getChildByName("name_text")

    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:setVisible(false)
    self.btn_goto:getChildByName("Text_2"):setString(TI18N("前往"))
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get:setVisible(false)
    self.btn_get:getChildByName("Text_2"):setString(TI18N("领取"))
    self.spr_has = main_container:getChildByName("spr_has")
    self.spr_has:setVisible(false)

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
function AdventureBoxRewardItem:register_event()
	registerButtonEventListener(self.btn_goto, function()
        controller:openAdventureBoxRewardView(false)
    end,true,1)
    registerButtonEventListener(self.btn_get, function()
        if self.data and self.data.id then
	        controller:send20635(self.data.id)
	    end
    end,true,1)
end
function AdventureBoxRewardItem:setExtendData(index)
	self.kill_index = index
end
function AdventureBoxRewardItem:setData(data)
    if not data then return end
    self.data = data
	self.btn_goto:setVisible(data.status == 0)
	self.btn_get:setVisible(data.status == 1)
	self.spr_has:setVisible(data.status == 2)
	local str = string_format(TI18N("击杀%d个守卫  (%d/%d)"),data.count,self.kill_index,data.count)
	self.name_text:setString(str)
	local list = {}
    for k, v in pairs(data.items) do
        local vo = {}
    	vo.bid = v[1]
        vo.quantity = v[2]
        table.insert(list, vo)
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
function AdventureBoxRewardItem:DeleteMe()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	self:removeAllChildren()
	self:removeFromParent()
end