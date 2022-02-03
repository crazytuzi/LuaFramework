--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-01 16:27:34
-- @description    : 
		-- 拜访界面
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

HomeworldVisitWindow = HomeworldVisitWindow or BaseClass(BaseView)

function HomeworldVisitWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "homeworld/homeworld_visit_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("homeworld", "homeworld"), type = ResourcesType.plist},
	}
end

function HomeworldVisitWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 1) 
	main_container:getChildByName("win_title"):setString(TI18N("拜访信息"))
	main_container:getChildByName("tips_label"):setString(TI18N("随机拜访可访问跨服的玩家，来看看跨服的玩家是如何装扮家园的吧！"))
	self.close_btn = main_container:getChildByName("close_btn")

	self.image_3 = main_container:getChildByName("image_3")

	self.list_panel = main_container:getChildByName("list_panel")
    local scroll_view_size = self.list_panel:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 3,                   -- y方向的间隔
        item_width = 602,               -- 单元的尺寸width
        item_height = 123,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self.rank_panel = main_container:getChildByName("rank_panel")
	self.rank_panel:getChildByName("rank_title"):setString(TI18N("我的排名"))
	self.rank_panel:getChildByName("rank_title_1"):setString(TI18N("排名"))
	self.rank_panel:getChildByName("rank_title_2"):setString(TI18N("玩家名称"))
	self.rank_panel:getChildByName("rank_title_3"):setString(TI18N("本周人气"))

	self.explain_btn = self.rank_panel:getChildByName("explain_btn")

	local rank_list = self.rank_panel:getChildByName("rank_list")
	local scroll_view_size = rank_list:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 3,                   -- y方向的间隔
        item_width = 602,               -- 单元的尺寸width
        item_height = 123,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.rank_scrollview = CommonScrollViewSingleLayout.new(rank_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.rank_scrollview:setSwallowTouches(false)

    self.rank_scrollview:registerScriptHandlerSingle(handler(self,self._createNewRankCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.rank_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfRankCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.rank_scrollview:registerScriptHandlerSingle(handler(self,self._updateRankCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    local btn_panel = main_container:getChildByName("btn_panel")
	local panel_size = btn_panel:getContentSize()
	self.sub_tab_array = {
        {title = TI18N("拜访好友"), index = 2},
        {title = TI18N("随机拜访"), index = 3},
        {title = TI18N("访客记录"), index = 1},
        {title = TI18N("本周排行"), index = 4},
	}
	if not self.sub_tab_scrollview then
		local panel_size = btn_panel:getContentSize()
		self.sub_tab_scrollview = CommonSubBtnList.new(btn_panel, cc.p(0.5, 0.5), cc.p(panel_size.width*0.5, panel_size.height*0.5), cc.size(142, 50), handler(self, self._onClickSubTabBtn))
	end
	self.sub_tab_scrollview:setData(self.sub_tab_array, 2)
end

function HomeworldVisitWindow:_createNewCell(  )
	local cell = HomeworldVisitItem.new()
    return cell
end

function HomeworldVisitWindow:_numberOfCells(  )
	if not self.show_data then return 0 end
    return #self.show_data
end

function HomeworldVisitWindow:_updateCellByIndex( cell, index )
	if not self.show_data then return end
    cell.index = index
    local cell_data = self.show_data[index]
    if not cell_data then return end
    cell:setData(cell_data, self.cur_tab_index)
end

function HomeworldVisitWindow:_createNewRankCell(  )
	local cell = HomeworldRankItem.new()
    return cell
end

function HomeworldVisitWindow:_numberOfRankCells(  )
	if not self.rank_data then return 0 end
    return #self.rank_data
end

function HomeworldVisitWindow:_updateRankCellByIndex( cell, index )
	if not self.rank_data then return end
    cell.index = index
    local cell_data = self.rank_data[index]
    if not cell_data then return end
    cell:setData(cell_data, self.cur_tab_index)
end

function HomeworldVisitWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openHomeworldVisitWindow(false)
	end, false, 2)

	registerButtonEventListener(self.close_btn, function (  )
		_controller:openHomeworldVisitWindow(false)
	end, true, 2)

	registerButtonEventListener(self.explain_btn, function ( param,sender, event_type )
		local rule_cfg = Config.HomeData.data_const["rank_tips"]
        if rule_cfg then
            TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
        end
	end, true, 1, nil, 0.8)

	-- 来访者数据
	self:addGlobalEvent(HomeworldEvent.Get_My_Home_Visiter_Event, function ( data )
		self.visit_data = data or {}
		self:updateList()
	end)

	-- 随机访问
	self:addGlobalEvent(HomeworldEvent.Get_Random_Visiter_Event, function ( data )
		self.random_data = data or {}
		self:updateList()
	end)

	-- 点赞次数
	self:addGlobalEvent(HomeworldEvent.Update_Left_Worship_Num, function (  )
		self:updateWorshipNum()
	end)

	-- 人气排行数据
	self:addGlobalEvent(HomeworldEvent.Get_Rank_Data_Event, function ( data )
		self:updateRankList(data)
	end)

	-- 红点
    self:addGlobalEvent(HomeworldEvent.Update_Red_Status_Data, function ( bid, status )
        if bid == HomeworldConst.Red_Index.Visit then
        	self:updateVisitRedStatus()
        end
    end)
end

function HomeworldVisitWindow:openRootWnd(  )
	self:updateVisitRedStatus()
	self:updateWorshipNum()
end

-- 剩余点赞次数更新
function HomeworldVisitWindow:updateWorshipNum(  )
	if not self.left_worship_num then
		self.left_worship_num = createRichLabel(22, 274, cc.p(0, 0.5), cc.p(35, 782))
		self.main_container:addChild(self.left_worship_num)
	end
	local max_num_cfg = Config.HomeData.data_const["day_praise_limit"]
	local left_num = _model:getLeftWorshipNum()
	if max_num_cfg then
		self.left_worship_num:setString(_string_format(TI18N("今日可点赞次数:<div fontcolor=#249003>%d</div>/%d"), left_num, max_num_cfg.val))
	end
end

function HomeworldVisitWindow:_onClickSubTabBtn( index )
	if self.cur_tab_index and self.cur_tab_index == index then return end
	self.cur_tab_index = index

	self.image_3:setVisible(index ~= 4)
	self.list_panel:setVisible(index ~= 4)
	self.rank_panel:setVisible(index == 4)
	commonShowEmptyIcon(self.main_container, false)

	if index == 1 then  -- 访客记录
		if not self.visit_flag then
			self.visit_flag = true
			_controller:sender26010()
		else
			self:updateList()
		end
		-- 清掉被拜访的红点
		_model:updateHomeworldRedStatus(HomeworldConst.Red_Index.Visit, false)
	elseif index == 2 then -- 好友家园
		if not self.friend_flag then
			self.friend_flag = true
			self.friend_data = FriendController:getInstance():getModel():getOpenHomeFriendList()
		end
		self:updateList()
	elseif index == 3 then -- 随机拜访
		if not self.random_flag then
			self.random_flag = true
			_controller:sender26009()
		else
			self:updateList()
		end
	elseif index == 4 then -- 人气排行
		if not self.rank_flag then
			self.rank_flag = true
			self:updateRankList()
			_controller:sender26020()
		end
	end
end

function HomeworldVisitWindow:updateList(  )
	commonShowEmptyIcon(self.rank_panel, false)
	self.show_data = {}
	local empty_str = ""
	if self.cur_tab_index == 1 then
		self.show_data = self.visit_data or {}
		empty_str = TI18N("家园近期暂无访客")
	elseif self.cur_tab_index == 2 then
		self.show_data = self.friend_data or {}
		empty_str = TI18N("暂无可拜访的好友，快去添加好友吧")
	elseif self.cur_tab_index == 3 then
		self.show_data = self.random_data or {}
		empty_str = TI18N("暂无可拜访的对象")
	end
	self.item_scrollview:reloadData()
	if next(self.show_data) == nil then
		commonShowEmptyIcon(self.main_container, true, {text=empty_str})
	else
		commonShowEmptyIcon(self.main_container, false)
	end
end

-- 排行榜数据
function HomeworldVisitWindow:updateRankList( data )
	data = data or {}

	-- 我的排行数据
	if not self.my_rank_txt then
		self.my_rank_txt = createLabel(26, 274, nil, 90, 136, nil, self.rank_panel, nil, cc.p(0.5, 0.5))
	end
	if not data.my_rank or data.my_rank == 0 then
		self.my_rank_txt:setString(TI18N("未上榜"))
	else
		self.my_rank_txt:setString(data.my_rank)
	end

	if not self.my_head_icon then
		self.my_head_icon = PlayerHead.new(PlayerHead.type.circle)
		self.my_head_icon:setScale(0.8)
	    self.my_head_icon:setPosition(194, 136)
	    self.rank_panel:addChild(self.my_head_icon)
	end

	local role_vo = RoleController:getInstance():getRoleVo()
	if role_vo.face_id then
		self.my_head_icon:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
	end
	if role_vo.lev then
		self.my_head_icon:setLev(role_vo.lev)
	end

	if not self.my_name_txt then
		self.my_name_txt = createLabel(22, 274, nil, 238, 136, nil, self.rank_panel, nil, cc.p(0, 0.5))
	end
	self.my_name_txt:setString(role_vo.name)

	if not self.my_soft_txt then
		self.my_soft_txt = createRichLabel(24, cc.c4b(149,83,34,255), cc.p(0.5, 0.5), cc.p(480, 136))
		self.rank_panel:addChild(self.my_soft_txt)
	end
	self.my_soft_txt:setString(_string_format("<img src='%s' scale=1.0 /> %d", PathTool.getResFrame("homeworld", "homeworld_1062"), data.my_score or 0))

	self.rank_data = data.rank_list or {}
	self.rank_scrollview:reloadData()
	if data.rank_list and next(data.rank_list) ~= nil then
		commonShowEmptyIcon(self.rank_panel, false)
	else
		commonShowEmptyIcon(self.rank_panel, true, {text=TI18N("暂无排行信息")})
	end
end

function HomeworldVisitWindow:updateVisitRedStatus(  )
	local red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Visit)
	self.sub_tab_scrollview:setBtnRedStatus(1, red_status)
end

function HomeworldVisitWindow:close_callback(  )
	if self.sub_tab_scrollview then
		self.sub_tab_scrollview:DeleteMe()
		self.sub_tab_scrollview = nil
	end
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.rank_scrollview then
		self.rank_scrollview:DeleteMe()
		self.rank_scrollview = nil
	end
	if self.my_head_icon then
		self.my_head_icon:DeleteMe()
		self.my_head_icon = nil
	end
	_controller:openHomeworldVisitWindow(false)
end

------------------------@ item
HomeworldVisitItem = class("HomeworldVisitItem", function()
    return ccui.Widget:create()
end)

function HomeworldVisitItem:ctor()
    self:configUI()
    self:register_event()
end

function HomeworldVisitItem:configUI(  )
	self.size = cc.size(602, 123)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("homeworld/homeworld_visit_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.visit_btn = self.container:getChildByName("visit_btn")
    self.visit_btn:getChildByName("label"):setString(TI18N("拜访Ta"))

    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
    self.head_icon:setPosition(64, self.size.height/2)
    self.container:addChild(self.head_icon)
    self.head_icon:addCallBack(function (  )
    	if self.data and self.data.srv_id and self.data.rid then
    		local role_vo = RoleController:getInstance():getRoleVo()
    		if self.data.srv_id == role_vo.srv_id and self.data.rid == role_vo.rid then
    			message(TI18N("你不认识你自己了么？"))
    		else
    			FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
    		end
    	end
    end)
end

function HomeworldVisitItem:register_event(  )
	registerButtonEventListener(self.visit_btn, function (  )
		if self.data and self.data.rid and self.data.srv_id then
			if _controller:checkHomeIsSameByRidAndSrvId(self.data.rid, self.data.srv_id) then
				message(TI18N("你已经在TA的家园啦"))
			else
				_controller:sender26003( self.data.rid, self.data.srv_id )
				_controller:openHomeworldVisitWindow(false)
			end
		end
	end, true)
end

function HomeworldVisitItem:setData( data, tab_type )
	if not data then return end

	self.data = data

	-- 头像
	local face_id = data.face_id or data.face
	if face_id then
		self.head_icon:setHeadRes(face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
	end
	-- 等级
	if data.lev then
		self.head_icon:setLev(data.lev)
	end

	-- 舒适度
	if not self.comfort_txt then
		self.comfort_txt = createRichLabel(24, 183, cc.p(0, 0.5))
		self.container:addChild(self.comfort_txt)
	end

	local role_name = transformNameByServ(data.name, data.srv_id) or ""

	if tab_type == 1 then -- 来访者
		if not self.visit_desc then
			self.visit_desc = createRichLabel(20, cc.c4b(21,126,34,255), cc.p(0, 1), cc.p(122, 100), 5, nil, 380)
			self.container:addChild(self.visit_desc)
		end
		local visit_str = _string_format(TI18N("<div fontcolor=643223>好友玩家</div><div fontcolor=157e22>%s</div><div fontcolor=643223>拜访了你的房间</div>"), role_name)
		if not FriendController:getInstance():isFriend(data.srv_id, data.rid) then
			visit_str = _string_format(TI18N("<div fontcolor=643223>非好友玩家</div><div fontcolor=157e22>%s</div><div fontcolor=643223>拜访了你的房间</div>"), role_name)
		end
		self.visit_desc:setString(visit_str)
		self.visit_desc:setVisible(true)

		if not self.visit_time then
			self.visit_time = createLabel(20, cc.c4b(120,80,70,255), nil, 122, 30, nil, self.container, nil, cc.p(0, 0.5))
		end
		self.visit_time:setString(TimeTool.getYMDHMS(data.time))
		self.visit_time:setVisible(true)

		local soft_val = 0
		if data.int_args and next(data.int_args) ~= nil then
			for k,v in pairs(data.int_args) do
				if v.key == 1 then
					soft_val = v.val
					break
				end
			end
		end
		if not soft_val or soft_val == 0 then
			self.comfort_txt:setVisible(false)
		else
			self.comfort_txt:setString(_string_format("<img src='%s' scale=0.8 /> <div fontsize=20> %d</div>", PathTool.getResFrame("homeworld", "homeworld_1021"), soft_val))
			self.comfort_txt:setPosition(cc.p(360, 30))
			self.comfort_txt:setVisible(true)
		end

		if self.name_txt then
			self.name_txt:setVisible(false)
		end
		if self.power_txt then
			self.power_txt:setVisible(false)
		end
		if self.onlinetime_txt then
			self.onlinetime_txt:setVisible(false)
		end
	else
		if not self.name_txt then
			self.name_txt = createLabel(24, 274, nil, 122, 85, nil, self.container, nil, cc.p(0, 0.5))
		end
		self.name_txt:setString(role_name)
		self.name_txt:setVisible(true)

		if not self.power_txt then
			self.power_txt = createLabel(22, cc.c4b(155,67,9,255), nil, 122, 48, nil, self.container, nil, cc.p(0, 0.5))
		end
		self.power_txt:setString(_string_format(TI18N("战力:%d"), data.power or 0))
		self.power_txt:setVisible(true)

		if not self.onlinetime_txt then
			self.onlinetime_txt = createLabel(22, cc.c4b(155,67,9,255), nil, 322, 48, nil, self.container, nil, cc.p(0, 0.5))
		end
		local last_time = data.last_login or data.login_time or 0
		local less_time = GameNet:getInstance():getTime() - last_time
		self.onlinetime_txt:setString(TimeTool.GetTimeFormatFriendShowTime(less_time))
		self.onlinetime_txt:setVisible(true)

		if not data.soft or data.soft == 0 then
			self.comfort_txt:setVisible(false)
		else
			self.comfort_txt:setString(_string_format("<img src='%s' scale=1.0 /> <div fontsize=24> %d</div>", PathTool.getResFrame("homeworld", "homeworld_1021"), data.soft))
			self.comfort_txt:setPosition(cc.p(322, 85))
			self.comfort_txt:setVisible(true)
		end

		if self.visit_desc then
			self.visit_desc:setVisible(false)
		end
		if self.visit_time then
			self.visit_time:setVisible(false)
		end
	end
end

function HomeworldVisitItem:DeleteMe(  )
	if self.head_icon then
		self.head_icon:DeleteMe()
		self.head_icon = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end

-------------------------- 人气排行 item
HomeworldRankItem = class("HomeworldRankItem", function()
    return ccui.Widget:create()
end)

function HomeworldRankItem:ctor()
    self:configUI()
    self:register_event()
end

function HomeworldRankItem:configUI(  )
	self.size = cc.size(602, 123)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("homeworld/homeworld_visit_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.visit_btn = self.container:getChildByName("visit_btn")
    self.visit_btn:getChildByName("label"):setString(TI18N("拜访Ta"))

    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
    self.head_icon:setScale(0.8)
    self.head_icon:setPosition(144, self.size.height/2)
    self.container:addChild(self.head_icon)
    self.head_icon:addCallBack(function (  )
    	if self.data and self.data.srv_id and self.data.rid then
    		local role_vo = RoleController:getInstance():getRoleVo()
    		if self.data.srv_id == role_vo.srv_id and self.data.rid == role_vo.rid then
    			message(TI18N("你不认识你自己了么？"))
    		else
    			FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
    		end
    	end
    end)
end

function HomeworldRankItem:register_event( )
	registerButtonEventListener(self.visit_btn, function (  )
		if self.data and self.data.rid and self.data.srv_id then
			if _controller:checkHomeIsSameByRidAndSrvId(self.data.rid, self.data.srv_id) then
				message(TI18N("你已经在TA的家园啦"))
			else
				_controller:sender26003( self.data.rid, self.data.srv_id )
				_controller:openHomeworldVisitWindow(false)
			end
		end
	end, true)
end

function HomeworldRankItem:setData( data )
	if not data then return end
	self.data = data

	if data.rank and data.rank >= 1 and data.rank <= 3 then
		if not self.rank_icon then
			self.rank_icon = createImage(self.container, nil, 50, self.size.height/2, cc.p(0.5,0.5), true, 1, false)
			self.rank_icon:setScale(0.7)
		end
		self.rank_icon:loadTexture(PathTool.getResFrame("common","common_200"..data.rank),LOADTEXT_TYPE_PLIST)
		self.rank_icon:setVisible(true)
		if self.rank_txt then
			self.rank_txt:setVisible(false)
		end
	elseif data.rank then
		if not self.rank_txt then
			self.rank_txt = createLabel(26, 274, nil, 50, self.size.height/2, nil, self.container, nil, cc.p(0.5, 0.5))
		end
		self.rank_txt:setString(data.rank or 0)
		self.rank_txt:setVisible(true)
		if self.rank_icon then
			self.rank_icon:setVisible(false)
		end
	end

	if data.face then
		self.head_icon:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
	end
	if data.lev then
		self.head_icon:setLev(data.lev)
	end

	if not self.name_txt then
		self.name_txt = createLabel(22, 274, nil, 192, self.size.height/2, nil, self.container, nil, cc.p(0, 0.5))
	end
	self.name_txt:setString(transformNameByServ(data.name, data.srv_id))

	if not self.soft_txt then
		self.soft_txt = createRichLabel(24, cc.c4b(149,83,34,255), cc.p(0.5, 0.5), cc.p(442, self.size.height/2))
		self.container:addChild(self.soft_txt)
	end
	self.soft_txt:setString(_string_format("<img src='%s' scale=1.0 /> %d", PathTool.getResFrame("homeworld", "homeworld_1062"), data.score or 0))
end

function HomeworldRankItem:DeleteMe(  )
	if self.head_icon then
		self.head_icon:DeleteMe()
		self.head_icon = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end