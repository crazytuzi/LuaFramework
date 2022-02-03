--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-02 16:11:48
-- @description    : 
		-- 跨服战场主界面
---------------------------------
CrossgroundMainWindow = CrossgroundMainWindow or BaseClass(BaseView)

local _controller = CrossgroundController:getInstance()
local _model = CrossgroundController:getInstance():getModel()
local _table_sort = table.sort

function CrossgroundMainWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Full
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("crossground", "crossground"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_82", true), type = ResourcesType.single}
	}
	self.layout_name = "crossground/crossground_main"
end

function CrossgroundMainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_82",true), LOADTEXT_TYPE)
		self.background:setScale(display.getMaxScale())
	end

	local main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(main_panel, 1)

    self.close_btn = main_panel:getChildByName("close_btn")
	self.cross_btn = main_panel:getChildByName("cross_btn")

	local scroll_list = main_panel:getChildByName("scroll_list")
	local scroll_view_size = scroll_list:getContentSize()
    local setting = {
        item_class = CrossgroundItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 687,               -- 单元的尺寸width
        item_height = 214,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(scroll_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function CrossgroundMainWindow:openRootWnd(  )
	self:setData()
end

function CrossgroundMainWindow:setData(  )
	local ground_cfg = Config.CrossGroundData.data_base
	if ground_cfg then
        local list = {}
        local  table_insert = table.insert

        for k,v in pairs(ground_cfg) do
            table_insert(list, {data = v, index = k})
        end
        _table_sort(list, function(a,b) return a.index < b.index end)
		self.item_scrollview:setData(list)
	end
end

function CrossgroundMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, function (  )
        _controller:openCrossGroundMainWindow(false)
    end, false, 2)
	registerButtonEventListener(self.cross_btn, function (  )
		CrossshowController:getInstance():openCrossshowMainWindow(true)
	end, false, 1)

	-- 天梯红点
	self:addGlobalEvent(LadderEvent.UpdateLadderRedStatus, function (  )
		self:updateItemListRedStatus()
	end)

	-- 跨服竞技场红点
	self:addGlobalEvent(CrossarenaEvent.Update_Red_Status_Event, function (  )
		self:updateItemListRedStatus()
	end)

    -- 周冠军赛红点
    self:addGlobalEvent(CrosschampionEvent.Update_Red_Status_Event, function (  )
        self:updateItemListRedStatus()
    end)
    -- 组队竞技场
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_ALL_RED_POINT_EVENT, function (  )
        self:updateItemListRedStatus()
    end)

	-- 巅峰冠军赛
	self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MAIN_EVENT, function (  )
        if not self.item_scrollview then return end
        local item_list = self.item_scrollview:getItemList()
        if item_list then
            for k,item in pairs(item_list) do
                if item.item_obj_list and item.item_obj_list[2] and item.item_obj_list[2].data then
                    --巅峰冠军赛的id
                    if item.item_obj_list[2].data.id == 1006 then
                        item:updateArenaPeakInfo(item.item_obj_list[2], item.item_obj_list[2].data)
                    end
                end
            end
        end
	end)

    -- 巅峰冠军赛红点
    self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_ALL_RED_POINT_EVENT, function (  )
        self:updateItemListRedStatus()
    end)



end

function CrossgroundMainWindow:updateItemListRedStatus(  )
	if not self.item_scrollview then return end
	local item_list = self.item_scrollview:getItemList()
    if item_list then
        for k,item in pairs(item_list) do
            item:updateRedStatus()
        end
    end
end

function CrossgroundMainWindow:close_callback(  )
    --关闭的时候消除一下巅峰冠军赛的申请状态
    ArenapeakchampionController:getInstance().is_send_27700 = nil

	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openCrossGroundMainWindow(false)
end
