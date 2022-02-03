--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2019-12-5 11:31:52
-- @description    : 
		-- 回归红包界面
---------------------------------
local _controller = ReturnActionController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_sort = table.sort

ReturnActionRedbagWindow = ReturnActionRedbagWindow or BaseClass(BaseView)

function ReturnActionRedbagWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "returnaction/returnaction_redbag_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("actionpetard", "actionpetard"), type = ResourcesType.plist},
	}
end

function ReturnActionRedbagWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(main_container , 1)

	main_container:getChildByName("win_title"):setString(TI18N("回归红包"))

	self.close_btn = main_container:getChildByName("close_btn")

	self.my_redbag_panel = main_container:getChildByName("my_redbag_panel")
	self.num_txt = self.my_redbag_panel:getChildByName("num_txt")

	self.redbag_msg_panel = main_container:getChildByName("redbag_msg_panel")

	local btn_panel = main_container:getChildByName("btn_panel")
	local panel_size = btn_panel:getContentSize()
	self.sub_tab_array = {
        {title = TI18N("抢红包"), index = 1},
        {title = TI18N("红包传闻"), index = 2},
	}
	if not self.sub_tab_scrollview then
		local panel_size = btn_panel:getContentSize()
		self.sub_tab_scrollview = CommonSubBtnList.new(btn_panel, cc.p(0.5, 0.5), cc.p(panel_size.width*0.5, panel_size.height*0.5), cc.size(142, 50), handler(self, self._onClickSubTabBtn))
	end
	self.sub_tab_scrollview:setData(self.sub_tab_array, 1)
end

function ReturnActionRedbagWindow:_onClickSubTabBtn( index )
	if self.cur_tab_index and self.cur_tab_index == index then return end
	self.cur_tab_index = index

	if index == ReturnActionConstants.Redbag_Tab.Redbag then
		if not self.my_redbag_scrollview then
			self:createMyRedbagScrollview()
			_controller:sender27910() -- 请求红包数据
		end
	elseif index == ReturnActionConstants.Redbag_Tab.Redmsg then
		if not self.redbag_msg_scrollview then
			self:createRedbagMsgScrollview()
			_controller:sender27913() -- 请求红包传闻数据
		end
	end

	if self.my_redbag_panel then
		self.my_redbag_panel:setVisible(index == ReturnActionConstants.Redbag_Tab.Redbag)
	end
	if self.redbag_msg_panel then
		self.redbag_msg_panel:setVisible(index == ReturnActionConstants.Redbag_Tab.Redmsg)
	end
end

function ReturnActionRedbagWindow:createMyRedbagScrollview(  )
	if self.my_redbag_scrollview then return end

	local list_panel = self.my_redbag_panel:getChildByName("list_panel")
	local scroll_view_size = list_panel:getContentSize()
    local setting = {
        start_x = 15,                  -- 第一个单元的X起点
        space_x = 30,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 15,                   -- y方向的间隔
        item_width = 239,               -- 单元的尺寸width
        item_height = 328,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 2,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.my_redbag_scrollview = CommonScrollViewSingleLayout.new(list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.my_redbag_scrollview:setSwallowTouches(false)

    self.my_redbag_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.my_redbag_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.my_redbag_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function ReturnActionRedbagWindow:_createNewCell(  )
	local cell = ReturnActionRedbagItem.new()
	cell:addClickCallBack(handler(self, self.onClickItemCallBack))
    return cell
end

function ReturnActionRedbagWindow:_numberOfCells(  )
	if not self.my_redbag_data then return 0 end
    return #self.my_redbag_data
end

function ReturnActionRedbagWindow:_updateCellByIndex( cell, index )
	if not self.my_redbag_data then return end
    cell.index = index
    local cell_data = self.my_redbag_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ReturnActionRedbagWindow:onClickItemCallBack( red_packet_id, red_status )
	if not red_packet_id then return end
	if red_status == 1 then -- 红包可领取，则先播放特效
		self.cur_red_packet_id = red_packet_id
		self:handleRedEffect(true)
	else
		_controller:sender27911(red_packet_id)
	end
end

function ReturnActionRedbagWindow:handleRedEffect( status )
	if status == false then
        if self.red_effect then
            self.red_effect:clearTracks()
            self.red_effect:removeFromParent()
            self.red_effect = nil
        end
        if self.mask_layer then
        	self.mask_layer:removeFromParent()
        	self.mask_layer = nil
        end
    else
        if not tolua.isnull(self.main_container) and self.red_effect == nil then
        	local con_size = self.main_container:getContentSize()
            self.red_effect = createEffectSpine(Config.EffectData.data_effect_info[332], cc.p(con_size.width*0.5, con_size.height*0.5), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self._onRedAniCallBack))
            self.main_container:addChild(self.red_effect, 2)
        elseif self.red_effect then
            self.red_effect:setToSetupPose()
            self.red_effect:setAnimation(0, PlayerAction.action, false)
        end
        -- 创建一个全屏压黑背景
        if not self.mask_layer then
        	local con_size = self.main_container:getContentSize()
        	self.mask_layer = ccui.Layout:create()
	        self.mask_layer:setContentSize(SCREEN_WIDTH, SCREEN_HEIGHT)
	        self.mask_layer:setScale(display.getMaxScale())
	        self.mask_layer:setAnchorPoint(cc.p(0.5, 0.5))
	        self.mask_layer:setPosition(cc.p(con_size.width*0.5, con_size.height*0.5))
	        self.mask_layer:setTouchEnabled(true)
	        self.mask_layer:setSwallowTouches(true)
	        showLayoutRect(self.mask_layer, 200)
	        self.main_container:addChild(self.mask_layer, 1)
	    else
	    	showLayoutRect(self.mask_layer, 200)
	    	self.mask_layer:setVisible(true)
        end
    end
end

function ReturnActionRedbagWindow:_onRedAniCallBack(  )
	if self.cur_red_packet_id then
		_controller:sender27911(self.cur_red_packet_id)
		self.cur_red_packet_id = nil
	end
	if self.mask_layer then
		showLayoutRect(self.mask_layer, 0)
		-- 延迟1秒隐藏，防止快速点击
		delayRun(self.mask_layer, 1, function (  )
			self.mask_layer:setVisible(false)
		end)
	end
end

function ReturnActionRedbagWindow:createRedbagMsgScrollview(  )
	if self.redbag_msg_scrollview then return end

	local list_panel = self.redbag_msg_panel:getChildByName("list_panel")
	local scroll_size = list_panel:getContentSize()
	local setting = {
        item_class = ReturnActionRedbagMsgItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 596,               -- 单元的尺寸width
        item_height = 123,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.redbag_msg_scrollview = CommonScrollViewLayout.new(list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_size, setting)
end

function ReturnActionRedbagWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self.onClickChoseBtn), true, 2)

	registerButtonEventListener(self.background, handler(self, self.onClickChoseBtn), false, 2)

	-- 红包数据
	self:addGlobalEvent(ReturnActionEvent.Get_Redbag_Data_Event, function (  )
		self:updateMyRedbagList()
	end)

	-- 红包传闻
	self:addGlobalEvent(ReturnActionEvent.Get_Redbag_Msg_Data_Event, function ( data )--修改
		self:updateRedbagMsgList(data)
	end)
end

-- 更新我的红包列表
function ReturnActionRedbagWindow:updateMyRedbagList(  )
	local redbag_data = _model:getReturnRedbagData()
	if not redbag_data then return end
	self.my_redbag_data = redbag_data.red_packet_list or {}
	if next(self.my_redbag_data) == nil then
		commonShowEmptyIcon(self.my_redbag_scrollview, true, {text = TI18N("还没有人发放红包")})
	else
		commonShowEmptyIcon(self.my_redbag_scrollview, false)
		local function sortFunc( objA, objB )
			if objA.status == 1 and objB.status ~= 1 then
				return true
			elseif objA.status ~= 1 and objB.status == 1 then
				return false
			else
				return objA.red_packet_id > objB.red_packet_id
			end
		end
		_table_sort(self.my_redbag_data, sortFunc)
	end
	self.my_redbag_scrollview:reloadData(nil, nil, true)

	local get_num = redbag_data.get_num or 0
	local max_num = redbag_data.max_num or 0
	self.num_txt:setString(_string_format(TI18N("今日已领取红包:%d/%d"), get_num, max_num))
end

-- 更新红包传闻列表
function ReturnActionRedbagWindow:updateRedbagMsgList( data )
	data = data or {}
	if next(data) == nil then
		commonShowEmptyIcon(self.redbag_msg_scrollview, true, {text = TI18N("还没有人领取过红包")})
	else
		commonShowEmptyIcon(self.redbag_msg_scrollview, false)
	end
	if self.redbag_msg_scrollview then
		self.redbag_msg_scrollview:setData(data)	
	end
end

function ReturnActionRedbagWindow:onClickChoseBtn(  )
	_controller:openReturnRedbagWindow(false)
end

function ReturnActionRedbagWindow:openRootWnd(  )
	
end

function ReturnActionRedbagWindow:close_callback(  )
	self:handleRedEffect(false)
	if self.sub_tab_scrollview then
		self.sub_tab_scrollview:DeleteMe()
		self.sub_tab_scrollview = nil
	end
	if self.my_redbag_scrollview then
		self.my_redbag_scrollview:DeleteMe()
		self.my_redbag_scrollview = nil
	end
	if self.redbag_msg_scrollview then
		self.redbag_msg_scrollview:DeleteMe()
		self.redbag_msg_scrollview = nil
	end
	_controller:openReturnRedbagWindow(false)
end