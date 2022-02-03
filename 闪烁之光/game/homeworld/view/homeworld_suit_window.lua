--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-01 17:38:42
-- @description    : 
		-- 套装一览
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

HomeworldSuitWindow = HomeworldSuitWindow or BaseClass(BaseView)

function HomeworldSuitWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "homeworld/homeworld_suit_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("homeworld", "homeworld"), type = ResourcesType.plist},
	}

	self.award_list = {}
end

function HomeworldSuitWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(main_container , 1) 

	main_container:getChildByName("win_title"):setString(TI18N("主题一览"))
	main_container:getChildByName("tips_label"):setString(TI18N("收集进度达到一定阶段时能获得奖励，努力收集家具吧！"))
	main_container:getChildByName("tips_label_2"):setString(TI18N("该主题包含以下装饰"))
	main_container:getChildByName("tips_label_3"):setString(TI18N("收集进度:"))

	self.close_btn = main_container:getChildByName("close_btn")
	self.preview_btn = main_container:getChildByName("preview_btn")

	local progress_bg = main_container:getChildByName("progress_bg")
	self.progress = progress_bg:getChildByName("progress")
	self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)
	self.progress_txt = progress_bg:getChildByName("progress_txt")

	self.name_label = main_container:getChildByName("name_label")
	self.num_label = main_container:getChildByName("num_label")

	local list_panel = main_container:getChildByName("list_panel")
	local scroll_view_size = list_panel:getContentSize()
    local setting = {
        start_x = 3,                  -- 第一个单元的X起点
        space_x = 7,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 7,                   -- y方向的间隔
        item_width = 194,               -- 单元的尺寸width
        item_height = 260,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 3,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self.image_bg = createSprite(PathTool.getResFrame("common", "common_1005"), 105, 778, self.main_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
end

function HomeworldSuitWindow:_createNewCell(  )
	local cell = HomeworldSuitItem.new()
    return cell
end

function HomeworldSuitWindow:_numberOfCells(  )
	if not self.suit_data then return 0 end
    return #self.suit_data
end

function HomeworldSuitWindow:_updateCellByIndex( cell, index )
	if not self.suit_data then return end
    cell.index = index
    local cell_data = self.suit_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function HomeworldSuitWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openHomeworldSuitWindow(false)
	end, false, 2)

	registerButtonEventListener(self.close_btn, function (  )
		_controller:openHomeworldSuitWindow(false)
	end, true, 2)

	registerButtonEventListener(self.preview_btn, function (  )
		self:onClickPreviewBtn()
	end, true)

	self:addGlobalEvent(HomeworldEvent.Get_Suit_Award_Data_Event, function (  )
    	self:updateSuitAwardInfo()
    end)
end

function HomeworldSuitWindow:onClickPreviewBtn(  )
	if not self.suit_cfg then return end

	local home_info = {}
	for k,v in pairs(self.suit_cfg.preview or {}) do
		local bid = v[1]
		local dir = v[2]
		local index = v[3]
		if bid and dir then
			if dir == 99 then
				home_info.wall_bid = bid
			elseif dir == 98 then
				home_info.land_bid = bid
			else
				home_info.unit_list = home_info.unit_list or {}
				local object = {}
				object.bid = bid
				object.dir = dir
				object.index = index or 0
				_table_insert(home_info.unit_list, object)					
			end
		end
	end
	if next(home_info) ~= nil then
		if self.suit_cfg then
			home_info.homename = self.suit_cfg.name .. TI18N("预览")
		end
		_controller:enterPreviewState(home_info)
		self:showSelfWindow(false)
	else
		message(TI18N("暂无预览"))
	end
end

function HomeworldSuitWindow:openRootWnd( suit_id )
	self.suit_cfg = Config.HomeData.data_suit[suit_id]
	if not self.suit_cfg  then return end

	_controller:sender26013() -- 请求套装数据

	self:updateSuitBaseInfo()

	self.suit_data = {}
	local suit_id_list = Config.HomeData.data_suit_unit[suit_id]
	if suit_id_list then
		for k,id in pairs(suit_id_list) do
			local unit_cfg = Config.HomeData.data_home_unit(id)
			_table_insert(self.suit_data, unit_cfg)
		end
	end
	table.sort(self.suit_data, SortTools.KeyLowerSorter("bid"))
	self.item_scrollview:reloadData()
end

function HomeworldSuitWindow:updateSuitBaseInfo(  )
	if not self.suit_cfg then return end

	self.name_label:setString(self.suit_cfg.name)
	self.num_label:setString(_string_format(TI18N("共:%d"), self.suit_cfg.comfort))

	-- 图标
	if not self.suit_icon then
		self.suit_icon = createSprite(nil, 105, 778, self.main_container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
	end
	if not self.cur_res_id or self.cur_res_id ~= self.suit_cfg.res_id then
		self.cur_res_id = self.suit_cfg.res_id
		local res_path = PathTool.getSuitIconRes( self.suit_cfg.res_id )
		self.icon_load = loadSpriteTextureFromCDN(self.suit_icon, res_path, ResourcesType.single, self.icon_load)
	end

	-- 描述
	if not self.desc_txt then
		self.desc_txt = createRichLabel(20, cc.c4b(120,80,70,255), cc.p(0, 0.5), cc.p(185, 785), 5, nil, 380)
		self.main_container:addChild(self.desc_txt)
	end
	self.desc_txt:setString(self.suit_cfg.desc)
end

function HomeworldSuitWindow:updateSuitAwardInfo(  )
	if not self.suit_cfg then return end
	-- 奖励进度
	local award_data = _model:getHomeSuitAwardDataById(self.suit_cfg.set_id)
	local max_val = self.suit_cfg.num
	local cur_val = 0
	if award_data and award_data.collect then
		cur_val = tableLen(award_data.collect)
	end
	self.progress_txt:setString(cur_val .. "/" .. max_val)
	self.progress:setPercent(cur_val/max_val*100)

	local function getAwardGetStatus( id )
		local is_get = false
		if award_data and award_data.reward then
			for k,v in pairs(award_data.reward) do
				if v.id == id then
					is_get = true
					break
				end
			end
		end
		return is_get
	end

	local award_cfg = Config.HomeData.data_suit_award[self.suit_cfg.set_id]
	if award_cfg then
		local show_data = {}
		local max_num = 0
		for k,cfg in pairs(award_cfg) do
			if cfg.num > max_num then
				max_num = cfg.num
			end
			_table_insert(show_data, cfg)
		end
		table.sort(show_data, SortTools.KeyLowerSorter("id"))

		for k,award_node in pairs(self.award_list) do
			award_node:setVisible(false)
		end
		local start_x = 148
		for i,v in ipairs(show_data) do
			local award_node = self.award_list[i]
			if not award_node then
				award_node = HomeworldSuitAward.new()
				self.main_container:addChild(award_node)
				self.award_list[i] = award_node
			end
			local status = getAwardGetStatus(v.id)
			award_node:setData(v, status, cur_val)
			local pos_x = start_x + (v.num/max_num)*485
			award_node:setPosition(cc.p(pos_x, 125))
			award_node:setVisible(true)
		end
	end
end

function HomeworldSuitWindow:showSelfWindow( status )
	self.root_wnd:setVisible(status)
end

function HomeworldSuitWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.icon_load then
		self.icon_load:DeleteMe()
		self.icon_load = nil
	end
	for k,v in pairs(self.award_list) do
		v:DeleteMe()
		v = nil
	end
	_controller:openHomeworldSuitWindow(false)
end

------------------------@ item
HomeworldSuitItem = class("HomeworldSuitItem", function()
    return ccui.Widget:create()
end)

function HomeworldSuitItem:ctor()
    self:configUI()
    self:register_event()
end

function HomeworldSuitItem:configUI(  )
	self.size = cc.size(194, 260)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("homeworld/homeworld_suit_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.container:setSwallowTouches(false)

    self.name_txt = self.container:getChildByName("name_txt")
    self.image_tips = self.container:getChildByName("image_tips")
    self.image_tips:getChildByName("label"):setString(TI18N("未收集"))
    self.num_txt = self.container:getChildByName("num_txt")
    self.container:getChildByName("detail_txt"):setString(TI18N("详情"))
    self.sp_icon = self.container:getChildByName("sp_icon")
    self.sp_icon:setScale(0.75)
end

function HomeworldSuitItem:register_event(  )
	registerButtonEventListener(self.container, function (  )
		if self.data then
			_controller:openFurnitureInfoWindow(true, self.data.bid)
		end
	end, true, 1, nil, nil, nil, true)
end

function HomeworldSuitItem:setData( data )
	if not data then return end

	self.data = data

	local item_config = Config.ItemData.data_get_data(data.bid)
	self.name_txt:setString(data.name)
	if item_config then
		self.name_txt:setTextColor(BackPackConst.getBlackQualityColorC4B(item_config.quality))
	end

	-- 舒适度
	if not self.confort_txt then
		self.confort_txt = createRichLabel(20, cc.c4b(134,79,53), cc.p(0.5, 0.5), cc.p(self.size.width*0.5, 205))
		self.container:addChild(self.confort_txt)
	end
	self.confort_txt:setString(_string_format(TI18N("舒适度<div fontcolor=157e22>+%d</div>"), data.soft))

	--  图标
	if self.data.icon and (not self.cur_res_icon or self.cur_res_icon ~= self.data.icon) then
        local res_path = PathTool.getFurnitureNormalRes(self.data.icon)
        self.cur_res_icon = self.data.icon
        loadSpriteTexture(self.sp_icon, res_path, LOADTEXT_TYPE)
    end

	local have_num = _model:getFurnitureAllNumByBid(data.bid)
	self.num_txt:setString(_string_format(TI18N("拥有:%d"), have_num))

	if have_num > 0 then
		self.image_tips:setVisible(false)
	else
		self.image_tips:setVisible(true)
	end
end

function HomeworldSuitItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end

---------------------@ 奖励item
HomeworldSuitAward = class("HomeworldSuitAward", function()
    return ccui.Widget:create()
end)

function HomeworldSuitAward:ctor()
    self:configUI()
    self:register_event()
end

function HomeworldSuitAward:configUI(  )
	self.size = cc.size(54, 64)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(cc.p(self.size.width*0.5, self.size.height*0.5))
	self.root_wnd:setTouchEnabled(true)
	self:addChild(self.root_wnd)

	self.image_bg = createImage(self.root_wnd, PathTool.getResFrame("homeworld", "homeworld_1053"), self.size.width*0.5, self.size.height*0.5, cc.p(0.5, 0.5), true, nil, true)
	self.image_bg:setCapInsets(cc.rect(20, 15, 1, 1))
	self.image_bg:setContentSize(self.size)

	-- 红点
    if not self.update_red_status_event then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(HomeworldEvent.Update_Red_Status_Data,function(bid, status)
            if bid == HomeworldConst.Red_Index.Suit then
                self:updateSuitAwardRedStatus()
            end
        end)
    end
end

function HomeworldSuitAward:register_event(  )
	registerButtonEventListener(self.root_wnd, function (  )
		if self.data and self.cur_num then
			if self.data.num <= self.cur_num then
				if self.is_get then
					message(TI18N("已经领取过奖励啦"))
				else
					_controller:sender26014(self.data.id)
				end
			else
				message(TI18N("未达到领取条件"))
			end
		end
	end, true)
end

function HomeworldSuitAward:setData( data, is_get, cur_num )
	if not data then return end

	self.data = data
	self.is_get = is_get or false
	self.cur_num = cur_num or 0

	if data.reward and data.reward[1] then
		local bid = data.reward[1][1]
		local num = data.reward[1][2]
		local item_config = Config.ItemData.data_get_data(bid)
		if item_config then
			if not self.award_icon then
				local res = PathTool.getItemRes(item_config.icon)
				self.award_icon = createSprite(res, self.size.width*0.5, self.size.height*0.5+7, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE)
				self.award_icon:setScale(0.4)
			end
			if not self.award_num then
				self.award_num = createLabel(16, 1, 2, self.size.width-6, 12, num, self.root_wnd, 2, cc.p(1, 0))
			end
		end
	end

	if is_get == true then
		if not self.get_icon then
			self.get_icon = createSprite(PathTool.getResFrame("homeworld", "txt_cn_homeworld_2"), 22, 55, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		end
		self.get_icon:setVisible(true)
	elseif self.get_icon then
		self.get_icon:setVisible(false)
	end

	self:updateSuitAwardRedStatus()
end

function HomeworldSuitAward:updateSuitAwardRedStatus(  )
	if self.data and self.data.set_id and self.data.id then
		local red_status = _model:checkSuitAwardRedStatus(self.data.set_id, self.data.id)
		addRedPointToNodeByStatus(self.root_wnd, red_status, 7, 7)
	end
end

function HomeworldSuitAward:DeleteMe(  )
	if self.update_red_status_event then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end