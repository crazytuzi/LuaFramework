--**************
--元宵厨房
--**************
AnimateYuanzhenGotoKitchenWindow = AnimateYuanzhenGotoKitchenWindow or BaseClass(BaseView)

local controller = AnimateActionController:getInstance()
local make_list = Config.HolidayMakeData.data_make_list
local make_lev_list = Config.HolidayMakeData.data_make_lev_list
local rewart_list = Config.HolidayMakeData.data_make_lev_list
local table_insert = table.insert
local table_sort = table.sort
--活动id，制作等级，奖励id，当前经验
function AnimateYuanzhenGotoKitchenWindow:__init(holiday_id,make_lev,holiday_reward_bid,cur_exp)
	self.holiday_id = holiday_id
	self.holiday_reward_bid = holiday_reward_bid
	self.make_lev = make_lev
	self.cur_exp = cur_exp
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "animateaction/animate_yuanzhen_goto_kitchen"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("animateaction","animateaction_yaunzhen"), type = ResourcesType.plist},
        { path = PathTool.getPlistImgForDownLoad("bigbg/animateaction/barner","animateaction_barner_1"), type = ResourcesType.single},
    }
end

function AnimateYuanzhenGotoKitchenWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
    main_container:getChildByName("title_name"):setString(TI18N("元宵厨房"))
    main_container:getChildByName("make_lev_text"):setString(TI18N("制作等级"))
    main_container:getChildByName("title_image"):getChildByName("title_image_text_1"):setString(TI18N("需要材料"))
    main_container:getChildByName("title_image"):getChildByName("title_image_text_2"):setString(TI18N("奖励"))
    	
    self.title_banner = main_container:getChildByName("title_banner")
    local res = PathTool.getTargetRes("bigbg/animateaction/barner","animateaction_barner_1",false,false)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.title_banner) then
                loadSpriteTexture(self.title_banner, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
    
    self.charge_num = CommonNum.new(26, main_container, 1, 1, cc.p(0, 0.5))
    self.charge_num:setPosition(105, 785)

    self.btn_more_lev = main_container:getChildByName("btn_more_lev")
    self.bar = main_container:getChildByName("bar")
    self.bar:setScale9Enabled(true)
    self.bar_num = main_container:getChildByName("bar_num")
    self.more_good_cons = main_container:getChildByName("more_good_cons")
    local scroll_more_size = self.more_good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 15,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.70,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.70,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.70                     -- 缩放
    }
    self.more_scrollview = CommonScrollViewLayout.new(self.more_good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_more_size, setting)
    self.more_scrollview:setSwallowTouches(false)
    
    self.good_cons = main_container:getChildByName("good_cons")
	local scroll_view_size = self.good_cons:getContentSize()
    local setting = {
        item_class = AnimateYuanzhenGotoKitchenItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 608,               -- 单元的尺寸width
        item_height = 167,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.btn_close = main_container:getChildByName("btn_close")
end
function AnimateYuanzhenGotoKitchenWindow:sortItemList(list)
    local tempsort = {
        [0] = 0,
        [1] = 1,
        [2] = 2,
    }
    local function sortFunc(objA,objB)
        if objA.status ~= objB.status then
            if tempsort[objA.status] and tempsort[objB.status] then
                return tempsort[objA.status] < tempsort[objB.status]
            else
                return false
            end
        else
            return objA.id < objB.id
        end
    end
    table_sort(list, sortFunc)
end
function AnimateYuanzhenGotoKitchenWindow:setTaskData(make_lev)
	if self.item_scrollview then	
		--0:可以制作 1:不可制作 2:全部完成
		local tab_list = {}
		for i,v in pairs(make_list[self.holiday_id]) do
			local is_task = false
	        for k,val in pairs(v.loss) do
		    	local num = 0
                local config = Config.ItemData.data_get_data(val[1])
                if config and config.type == BackPackConst.item_type.ASSET then
                    local role_vo = RoleController:getInstance():getRoleVo()
                    num = role_vo.coin
                else
                    num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(val[1])
                end

		    	if num < val[2] then
		    		is_task = true
		    		break
		    	end
		    end
		    if is_task == true then
		    	v.status = 1
		    else
		    	v.status = 0
                if make_lev < v.lev then
                    v.status = 1
                end
		    end
		    v.remain_num = v.limit - controller:getModel():getKitchenRemainData(v.id)
			if v.remain_num == 0 then
				v.status = 2
			end
			table_insert(tab_list,v)
		end
		table_sort(tab_list,function(a,b) return a.id < b.id end)
		self:sortItemList(tab_list)
		local tab = {}
		tab.holiday_reward_bid = self.holiday_reward_bid
		tab.make_lev = make_lev
		self.item_scrollview:setData(tab_list,nil,nil,tab)
	end
end
function AnimateYuanzhenGotoKitchenWindow:openRootWnd()
	self.charge_num:setNum(self.make_lev)
	self:setTaskData(self.make_lev)
	self:setLevRedStatus()
	local lev = self.make_lev + 1
	if lev >= #make_lev_list[self.holiday_id] then
		lev = #make_lev_list[self.holiday_id]
	end

	local str = string.format("%d/%d",self.cur_exp,make_lev_list[self.holiday_id][lev].exp)
	self.bar_num:setString(str)
	self.bar:setPercent(self.cur_exp/make_lev_list[self.holiday_id][lev].exp*100)

	local list = {}
    for k, v in pairs(make_lev_list[self.holiday_id][lev].reward) do
        local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
        if vo then
            vo.quantity = v[2]
            table.insert(list, vo)
        end
    end
	self.more_scrollview:setData(list)
	self.more_scrollview:addEndCallBack(function()
        local list = self.more_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
        end
    end)
end
--查看更多红点
function AnimateYuanzhenGotoKitchenWindow:setLevRedStatus()
	if self.holiday_id then
		local red_status = false
		for i,v in pairs(rewart_list[self.holiday_id]) do
			if controller:getModel():getKitchenLevData(v.lev) == false and v.lev <= self.make_lev then
				red_status = true
				break
			end
		end
		addRedPointToNodeByStatus(self.btn_more_lev, red_status)
	end
end
function AnimateYuanzhenGotoKitchenWindow:register_event()
	self:addGlobalEvent(AnimateActionEvent.YuanZhenFestval_Kitchen,function(data)
		if not data or next(data) == nil then return end
		self.charge_num:setNum(data.lev)
		local lev = data.lev + 1
		if lev >= #make_lev_list[self.holiday_id] then
			lev = #make_lev_list[self.holiday_id]
		end
		local str = string.format("%d/%d",data.exp,make_lev_list[self.holiday_id][lev].exp)
		self.bar_num:setString(str)
		self.bar:setPercent(data.exp/make_lev_list[self.holiday_id][lev].exp*100)
		self:setTaskData(data.lev)
	end)

	self:addGlobalEvent(AnimateActionEvent.YuanZhenFestval_Kitchen_Lev,function(data)
		self:setLevRedStatus()
	end)

	registerButtonEventListener(self.btn_more_lev, function()
    	controller:openAnimateYuanzhenKitchenLevWindow(true,self.holiday_id)
    end ,true, 1)
	registerButtonEventListener(self.btn_close, function()
    	controller:openAnimateYuanzhenGotoKitchenWindow(false)
    end ,true, 1)
end
function AnimateYuanzhenGotoKitchenWindow:close_callback()
	if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	if self.more_scrollview then
		self.more_scrollview:DeleteMe()
	end
	self.more_scrollview = nil
	if self.charge_num then
        self.charge_num:DeleteMe()
        self.charge_num = nil
    end
	controller:openAnimateYuanzhenGotoKitchenWindow(false)
end

------------------------------------------
-- 子项
AnimateYuanzhenGotoKitchenItem = class("AnimateYuanzhenGotoKitchenItem", function()
    return ccui.Widget:create()
end)
local reward_list = Config.HolidayMakeData.data_make_reward_list
function AnimateYuanzhenGotoKitchenItem:ctor()
	self:configUI()
	self:register_event()
end

function AnimateYuanzhenGotoKitchenItem:configUI()
	self.size = cc.size(608,167)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("animateaction/animate_yuanzhen_goto_kitchen_item"))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")

    self.name_text = main_container:getChildByName("name_text")
    self.tesk_text = main_container:getChildByName("tesk_text")
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto_label = self.btn_goto:getChildByName("Text_3")

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 3,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 4,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.80,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.70                     -- 缩放
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.tesk_item = BackPackItem.new(nil,true,nil,0.7)
    main_container:addChild(self.tesk_item)
    self.tesk_item:setPosition(cc.p(405, 62))
    self.tesk_item:setDefaultTip()
    self.tesk_item:setSwallowTouches(false)
end

function AnimateYuanzhenGotoKitchenItem:register_event()
    registerButtonEventListener(self.btn_goto, function()
    	controller:sender24806(self.data.id)
    end ,true, 1)
end
function AnimateYuanzhenGotoKitchenItem:setExtendData(tab)
	self.holiday_reward_bid = tab.holiday_reward_bid
	self.lev = tab.make_lev
end

function AnimateYuanzhenGotoKitchenItem:setData(data)
	if not data or next(data) == nil then return end
	self.data = data
	self.name_text:setString(data.name)
	local str = string.format(TI18N("剩余制作次数: %d次"),data.remain_num)
	self.tesk_text:setString(str)
	local comp_id = reward_list[self.holiday_reward_bid][data.id].reward[1][1]
	local comp_num = reward_list[self.holiday_reward_bid][data.id].reward[1][2]
	self.tesk_item:setBaseData(comp_id,comp_num)
	local list = {}
    for k, v in pairs(data.loss) do
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
        	local count = 0
        	if v:getData().type == BackPackConst.item_type.ASSET then
        		local role_vo = RoleController:getInstance():getRoleVo()
        		count = role_vo.coin
        	else
	        	count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(v:getData().id)
	        end
            v:setNeedNum(v:getData().quantity,count,0)
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
	if data.status == 0 then
		self.btn_goto_label:setString(TI18N("制作"))
        if data.lev <= self.lev then
            setChildUnEnabled(false, self.btn_goto)
            self.btn_goto_label:setColor(cc.c4b(0x25,0x55,0x05,0xff))
        else
            setChildUnEnabled(true, self.btn_goto)
            local str = string.format(TI18N("%d级开启"),data.lev)
            self.btn_goto_label:setString(str)
            self.btn_goto_label:setColor(cc.c4b(0xff,0xff,0xff,0xff))
        end
	else
		if data.status == 2 then
			self.btn_goto_label:setString(TI18N("大丰收"))
		else
            if data.lev <= self.lev then
                self.btn_goto_label:setString(TI18N("制作"))
            else
                local str = string.format(TI18N("%d级开启"),data.lev)
    	    	self.btn_goto_label:setString(str)
            end
	    end
    	setChildUnEnabled(true, self.btn_goto)
    	self.btn_goto_label:setColor(cc.c4b(0xff,0xff,0xff,0xff))
    end
end

function AnimateYuanzhenGotoKitchenItem:DeleteMe()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	if self.tesk_item then 
       self.tesk_item:DeleteMe()
       self.tesk_item = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end