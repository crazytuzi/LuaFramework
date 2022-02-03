--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-11 15:57:52
-- @description    : 
		-- 天界副本主界面
---------------------------------
local _controller = HeavenController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

HeavenDungeonPanel = class("HeavenDungeonPanel", function()
    return ccui.Widget:create()
end)

function HeavenDungeonPanel:ctor(  ) 
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("heaven","heaven"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_85", true), type = ResourcesType.single },
    }

    self.chapter_show_data = {}  -- 章节数据
    self.move_speed = 4  --背景相对章节移动的系数
	self.is_first_open = true  -- 首次打开界面标识

	self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
            self:loadResListCompleted()
        end
	end)
	self:configUI()
    self:register_event()
end

function HeavenDungeonPanel:loadResListCompleted()
    -- self:configUI()
    -- self:register_event()
end

function HeavenDungeonPanel:addToParent( status )
	status = status or false
	self:setVisible(status)
	if self.is_first_open then
		-- 没有缓存数据才请求
		if not _model:checkIsHaveChapterCache() then
			_controller:sender25200()
		else
			self:refreshLeftCount()
			self:updateLeftBuyCount()
		end
	  	self.is_first_open = false
  	end
end

function HeavenDungeonPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("heaven/heaven_dungeon_panel"))
	self.root_wnd:setPosition(0,0)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
	self:setAnchorPoint(0,0)
	
	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	local top_panel = main_container:getChildByName("top_panel")
	self.btn_rule = top_panel:getChildByName("btn_rule")

	self.map_layer = self.root_wnd:getChildByName("map_layer")
	self.chapter_list = self.main_container:getChildByName("chapter_list")
	local bottom_panel = main_container:getChildByName("bottom_panel")
	self.bottom_panel = bottom_panel
	bottom_panel:getChildByName("count_title"):setString(TI18N("挑战次数:"))
	self.count_label = bottom_panel:getChildByName("count_label")
	self.add_btn = bottom_panel:getChildByName("add_btn")
	self.btn_rank = bottom_panel:getChildByName("btn_rank")
	self.btn_rank:getChildByName("label"):setString(TI18N("排行榜"))
	self.btn_shop = bottom_panel:getChildByName("btn_shop")
	self.btn_shop:getChildByName("label"):setString(TI18N("神装商店"))
	self.btn_book = bottom_panel:getChildByName("btn_book")
	self.btn_book:getChildByName("label"):setString(TI18N("神装图鉴"))

	
	-- 适配
	local top_off = display.getTop(main_container)
	local bottom_off = display.getBottom(main_container)
	top_panel:setPositionY(top_off - 158)
	bottom_panel:setPositionY(bottom_off+110)
	self.map_layer:setPositionY(bottom_off)
	self.map_layer:setContentSize(cc.size(SCREEN_WIDTH, display.height))
	self.chapter_list:setPositionY(bottom_off)
	self.chapter_list:setContentSize(cc.size(SCREEN_WIDTH, display.height))

	-- 章节列表
	self:createCapterList()
	-- 章节数据
	self:updateChapterShowData(true)
	-- 地图资源
	self:createMapBgList()
end

-- 更新章节数据
function HeavenDungeonPanel:updateChapterShowData( force )
	self.chapter_show_data = {}

	local max_pass_chapter_id = _model:getMaxPassChapterId()
	self.last_chapter_id = 1
	local all_chapter_num = 0
	for i,v in ipairs(Config.DungeonHeavenData.data_chapter) do
		if v.limit_id <= max_pass_chapter_id then
			local num = #self.chapter_show_data
			if num == 0 then num = 1 end
			if not self.chapter_show_data[num] then
				self.chapter_show_data[num] = {}
				self.chapter_show_data[num].chapter_datas = {}
				self.chapter_show_data[num].index = num
				self.last_chapter_id = v.id
				all_chapter_num = all_chapter_num + 1
				_table_insert(self.chapter_show_data[num].chapter_datas, v)
			else
				if #(self.chapter_show_data[num].chapter_datas) >= 6 then
					self.chapter_show_data[num+1] = {}
					self.chapter_show_data[num+1].chapter_datas = {}
					self.chapter_show_data[num+1].index = num+1
					self.last_chapter_id = v.id
					all_chapter_num = all_chapter_num + 1
					_table_insert(self.chapter_show_data[num+1].chapter_datas, v)
				else
					self.last_chapter_id = v.id
					all_chapter_num = all_chapter_num + 1
					_table_insert(self.chapter_show_data[num].chapter_datas, v)
				end
			end
		end
	end

	if self.chapter_scrollview then
		local num = #self.chapter_show_data
		local inner_height = num * HeavenConst.Chapter_List_Height + HeavenConst.Chapter_List_Bottom + 20
		if self.chapter_show_data[num] and #(self.chapter_show_data[num].chapter_datas) < 5 then
			if #(self.chapter_show_data[num].chapter_datas) < 3 then
				inner_height = inner_height - HeavenConst.Chapter_List_Height*2/3
			else
				inner_height = inner_height - HeavenConst.Chapter_List_Height/3
			end
		end
		if force then
			-- 滑动到开启的章节
			self.chapter_scrollview:reloadData(nil, {container_height = inner_height}, false)
			local percent = 100
			if max_pass_chapter_id > 3 then
				percent = 100 - (math.ceil(max_pass_chapter_id/2)/(math.ceil(all_chapter_num/2))*100)
				if percent > 20 then
					percent = percent + (HeavenConst.Chapter_List_Bottom+150)/inner_height*100
				else
					percent = 0
				end
			end
			self.chapter_scrollview:scrollToPercentVertical(percent, 0.1)
		else
			-- 保持当前位置
			self.chapter_scrollview:reloadData(nil, {container_height = inner_height}, true)
		end
	end
end

-------------------- 背景地图层
function HeavenDungeonPanel:createMapBgList(  )
	if self.map_bg_scrollview then return end

	-- 背景图
	local scroll_view_size = self.map_layer:getContentSize()
	local list_setting = {
        start_x = 0,
        space_x = 0,
        start_y = 0,
        space_y = 0,
        item_width = 720,
        item_height = 1280,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.map_bg_scrollview = CommonScrollViewSingleLayout.new(self.map_layer, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.bottom, scroll_view_size, list_setting, cc.p(0, 0)) 
    self.map_bg_scrollview:registerScriptHandlerSingle(handler(self, self.createCellMapBg), ScrollViewFuncType.CreateNewCell) --创建cell
    self.map_bg_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCellMapBg), ScrollViewFuncType.NumberOfCells) --获取数量
    self.map_bg_scrollview:setBounceEnabled(false)
    --self.map_bg_scrollview:setTouchEnabled(false)

    self.map_bg_scrollview:reloadData()
end

function HeavenDungeonPanel:createCellMapBg(  )
	local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_85", true)
    local cell =  createImage(nil, res, nil, nil, cc.p(0.5,0.5), false, 0, false)
    return cell
end

function HeavenDungeonPanel:numberOfCellMapBg(  )
	local cell_num = 0
	if self.chapter_innercontainer then
		local inner_size = self.chapter_innercontainer:getContentSize()
		cell_num = math.ceil(inner_size.height/self.move_speed/1280) + 1
	end
	return cell_num
end

----------------- 章节列表
function HeavenDungeonPanel:createCapterList(  )
	if self.chapter_scrollview then return end
	local list_size = self.chapter_list:getContentSize()
    local scroll_view_size = cc.size(list_size.width, list_size.height-450)
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 20,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 720,               -- 单元的尺寸width
        item_height = HeavenConst.Chapter_List_Height,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
        checkovercallback = handler(self, self.checkOverShowByVertical)
    }
    self.chapter_scrollview = CommonScrollViewSingleLayout.new(self.chapter_list, cc.p(0, 280) , ScrollViewDir.vertical, ScrollViewStartPos.bottom, scroll_view_size, setting)
    self.chapter_scrollview:setSwallowTouches(true)
    self.chapter_scrollview:setBounceEnabled(false)

    self.chapter_innercontainer = self.chapter_scrollview:getContainer()

    self.chapter_scrollview:registerScriptHandlerSingle(handler(self,self.createChapterCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.chapter_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfChapterCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.chapter_scrollview:registerScriptHandlerSingle(handler(self,self.updateChapterCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function HeavenDungeonPanel:createChapterCell(  )
	local cell = HeavenMainChapter.new()
    return cell
end

function HeavenDungeonPanel:numberOfChapterCells(  )
	if not self.chapter_show_data then return 0 end
    return #self.chapter_show_data
end

function HeavenDungeonPanel:updateChapterCellByIndex( cell, index )
	if not self.chapter_show_data then return end
    local cell_data = self.chapter_show_data[index]
    if not cell_data then return end
    cell:setExtendData(self.last_chapter_id)
    cell:setData(cell_data)
end

function HeavenDungeonPanel:checkOverShowByVertical(  )
	local container_y = self.chapter_innercontainer:getPositionY()
    if self.map_bg_scrollview then
        local container = self.map_bg_scrollview:getContainer()
        if container then
            container:setPositionY(container_y/self.move_speed)
            self.map_bg_scrollview:checkOverShowByVerticalBottom()
        end
    end
end

-- 刷新挑战次数
function HeavenDungeonPanel:refreshLeftCount(  )
	local max_num_cfg = Config.DungeonHeavenData.data_const["refresh_number"]
	if max_num_cfg then
		local left_num = _model:getLeftChallengeCount()
		self.count_label:setString(left_num .. "/" .. max_num_cfg.val)
	end
end

function HeavenDungeonPanel:register_event(  )
	-- 规则说明
	registerButtonEventListener(self.btn_rule, function ( param, sender, event_type )
		local rule_cfg = Config.DungeonHeavenData.data_const["dunheaven_rule"]
		if rule_cfg then
			TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
		end
	end, true)

	-- 排行
	registerButtonEventListener(self.btn_rank, function (  )
		_controller:openHeavenRankWindow(true)
	end, true)

	-- 商店
	registerButtonEventListener(self.btn_shop, function (  )
		SuitShopController:getInstance():openSuitShopMainView(true)
	end, true)

	-- 神装图鉴
	registerButtonEventListener(self.btn_book, function (  )
		HeroController:getInstance():openHeroClothesLustratWindow(true)
	end, true)

	-- 增加购买次数
	registerButtonEventListener(self.add_btn, function (  )
		self:_onClickAddCountBtn()
	end, true)

	--章节数据返回
	if not self.get_chapter_data_event  then
		self.get_chapter_data_event = GlobalEvent:getInstance():Bind(HeavenEvent.Get_Chapter_Data_Event,function ()
			self:updateChapterShowData()
			self:refreshLeftCount()
			self:updateLeftBuyCount()
		end)
	end

	--挑战次数更新
	if not self.update_chapter_count_event  then
		self.update_chapter_count_event = GlobalEvent:getInstance():Bind(HeavenEvent.Update_Chapter_Count_Event,function ()
			self:refreshLeftCount()
		self:updateLeftBuyCount()
		end)
	end

	--章节数据增加
	if not self.add_chapter_data_event  then
		self.add_chapter_data_event = GlobalEvent:getInstance():Bind(HeavenEvent.Add_Chapter_Data_Event,function ()
			self:updateChapterShowData()
		end)
	end
end

-- 购买挑战次数
function HeavenDungeonPanel:_onClickAddCountBtn(  )
	local max_count_cfg = Config.DungeonHeavenData.data_const["refresh_number"]
	if not max_count_cfg then return end
	local left_challenge_num = _model:getLeftChallengeCount()
	if left_challenge_num >= max_count_cfg.val then
		message(TI18N("当前挑战次数已满"))
		return
	end

	local buy_num = _model:getTodayBuyCount()
	local buy_cfg = Config.DungeonHeavenData.data_count_buy[buy_num+1]
	if buy_cfg then
		local role_vo = RoleController:getInstance():getRoleVo()
		if buy_cfg.limit_vip <= role_vo.vip_lev then
			local str = string.format(TI18N("是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数？"), PathTool.getItemRes(3), buy_cfg.cost)					
			CommonAlert.show( str, TI18N("确定"), function()
				_controller:sender25207()
	    	end, TI18N("取消"), nil, CommonAlert.type.rich)
		else
			message(TI18N("提升VIP等级可增加购买次数"))
		end
	else
		message(TI18N("今日购买次数已用完"))
	end
end


-- 更新今日剩余购买次数
function HeavenDungeonPanel:updateLeftBuyCount(  )
	if not self.left_buy_count then
		self.left_buy_count = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(590, 6))
		self.bottom_panel:addChild(self.left_buy_count)
	end
	local left_count = _model:getTodayLeftBuyCount()
	self.left_buy_count:setString(string.format(TI18N("<div fontcolor=#fff8bf outline=2,#000000>(剩余购买次数:</div><div fontcolor=#39e522 outline=2,#000000>%d</div><div fontcolor=#fff8bf outline=2,#000000>)</div>"), left_count))
end

function HeavenDungeonPanel:DeleteMe(  )
	if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
	end

	if self.get_chapter_data_event then
        GlobalEvent:getInstance():UnBind(self.get_chapter_data_event)
        self.get_chapter_data_event = nil
	end
	
	if self.update_chapter_count_event then
        GlobalEvent:getInstance():UnBind(self.update_chapter_count_event)
        self.update_chapter_count_event = nil
	end

	if self.add_chapter_data_event then
        GlobalEvent:getInstance():UnBind(self.add_chapter_data_event)
        self.add_chapter_data_event = nil
	end

	if self.map_bg_scrollview then
		self.map_bg_scrollview:DeleteMe()
		self.map_bg_scrollview = nil
	end
	if self.chapter_scrollview then
		self.chapter_scrollview:DeleteMe()
		self.chapter_scrollview = nil
	end
end