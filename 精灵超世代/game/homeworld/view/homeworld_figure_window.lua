--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-02 14:23:38
-- @description    : 
		-- 家园形象设置
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

HomeworldFigureWindow = HomeworldFigureWindow or BaseClass(BaseView)

function HomeworldFigureWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "homeworld/homeworld_figure_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("homeworld", "homeworld"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("homeworld","homeworld_big_bg_3"), type = ResourcesType.single },
	}
end

function HomeworldFigureWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

	self.main_container:getChildByName("win_title"):setString(TI18N("更换家园形象"))

	self.name_txt = self.main_container:getChildByName("name_txt")
	self.lock_con_txt = self.main_container:getChildByName("lock_con_txt")
	self.soft_val_txt = self.main_container:getChildByName("soft_val_txt")

	self.close_btn = self.main_container:getChildByName("close_btn")
	self.btn_unlock = self.main_container:getChildByName("btn_unlock")
	local btn_size = self.btn_unlock:getContentSize()
	self.btn_unlock_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(btn_size.width*0.5, btn_size.height*0.5))
	self.btn_unlock:addChild(self.btn_unlock_label)
	self.btn_chose = self.main_container:getChildByName("btn_chose")
	self.btn_chose_lab = self.btn_chose:getChildByName("label")
	self.btn_chose_lab:setString(TI18N("确认更换"))
	
	local list_panel = self.main_container:getChildByName("list_panel")
	local scroll_view_size = list_panel:getContentSize()
    local setting = {
        start_x = 26,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 119,               -- 单元的尺寸width
        item_height = 119,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 2,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
end

function HomeworldFigureWindow:_createNewCell(  )
	local cell = HomeworldFigureItem.new()
	cell:addCallBack(handler(self, self._onClickItemCallBack))
    return cell
end

function HomeworldFigureWindow:_numberOfCells(  )
	if not self.figure_data then return 0 end
    return #self.figure_data
end

function HomeworldFigureWindow:_updateCellByIndex( cell, index )
	if not self.figure_data then return end
    cell.index = index
    local cell_data = self.figure_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function HomeworldFigureWindow:_onCellTouched( cell )
	local cell_data = self.figure_data[cell.index]
	if cell_data then
		self:_onClickItemCallBack(cell, cell_data)
	end
end

function HomeworldFigureWindow:_onClickItemCallBack( item_node, cell_data )
	if self.cur_item then
		self.cur_item:setIsSelect(false)
	end
	item_node:setIsSelect(true)
	self.cur_item = item_node

	self:updateFigureInfo(cell_data)
end

function HomeworldFigureWindow:updateFigureInfo( item_data )
	if not item_data then return end

	if item_data.status == HomeworldConst.Figure_State.Unlock then
		self:showCucoloris(false)
		self:showFigureModel(true, item_data.look_id, item_data.look_standby)
		self.name_txt:setString(item_data.name)
		self.name_txt:setVisible(true)
		self.lock_con_txt:setVisible(false)
		self.soft_val_txt:setVisible(false)
		self.btn_unlock:setVisible(false)

		if item_data.id == _model:getMyCurHomeFigureId() then
			setChildUnEnabled(true, self.btn_chose)
			self.btn_chose:setTouchEnabled(false)
			self.btn_chose_lab:disableEffect(cc.LabelEffect.OUTLINE)
		else
			setChildUnEnabled(false, self.btn_chose)
			self.btn_chose:setTouchEnabled(true)
			self.btn_chose_lab:enableOutline(Config.ColorData.data_color4[264], 2)
		end
	elseif item_data.status == HomeworldConst.Figure_State.CanUnlock then
		self:showCucoloris(true)
		self:showFigureModel(false)
		setChildUnEnabled(true, self.btn_chose)
		self.btn_chose:setTouchEnabled(false)
		self.btn_chose_lab:disableEffect(cc.LabelEffect.OUTLINE)
		self.btn_unlock:setVisible(true)
		addRedPointToNodeByStatus(self.btn_unlock, true, 7, 7)
		if item_data.loss[1] then
			local bid = item_data.loss[1][1]
			local num = item_data.loss[1][2]
			local item_config = Config.ItemData.data_get_data(bid)
			if item_config then
				self.btn_unlock_label:setString(_string_format(TI18N("<img src='%s' scale=0.35 /><div shadow=0,-2,2,#854000>%d解锁</div>"), PathTool.getItemRes(item_config.icon), num))
			end
		end
		self.name_txt:setVisible(false)
		self.lock_con_txt:setVisible(false)
		self.soft_val_txt:setVisible(false)
	elseif item_data.status == HomeworldConst.Figure_State.Lock then
		self:showCucoloris(true)
		self:showFigureModel(false)
		setChildUnEnabled(true, self.btn_chose)
		self.btn_chose:setTouchEnabled(false)
		self.btn_chose_lab:disableEffect(cc.LabelEffect.OUTLINE)
		if item_data.tips ~=nil and item_data.tips ~= "" then
			self.name_txt:setString(item_data.tips)
			self.lock_con_txt:setVisible(false)
			self.soft_val_txt:setVisible(false)
			self.name_txt:setVisible(true)
		else
			self.lock_con_txt:setString(_string_format(TI18N("家园舒适度达到%d"), item_data.open_soft))
			local max_soft_val = _model:getMaxComfortValue()
			self.soft_val_txt:setString(_string_format("%d/%d", max_soft_val, item_data.open_soft))
			self.lock_con_txt:setVisible(true)
			self.soft_val_txt:setVisible(true)
			self.name_txt:setVisible(false)
		end
		self.btn_unlock:setVisible(false)
	end
end

function HomeworldFigureWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
    	_controller:openHomeworldFigureWindow(false)
    end, false, 2)

	registerButtonEventListener(self.close_btn, function (  )
    	_controller:openHomeworldFigureWindow(false)
    end, true, 2)

    registerButtonEventListener(self.btn_unlock, handler(self, self._onClickUnlockBtn), true)

    registerButtonEventListener(self.btn_chose, handler(self, self._onClickChoseBtn), true)

    -- 更新形象列表
    self:addGlobalEvent(HomeworldEvent.Update_My_Figure_Data_Event, function ( id )
    	self:updateFigureList(id)
    end)
end

-- 点击解锁
function HomeworldFigureWindow:_onClickUnlockBtn(  )
	if not self.cur_item then return end

	local item_data = self.cur_item:getData()
	if not item_data then return end

	_controller:sender26006(item_data.id)
end

-- 点击选择
function HomeworldFigureWindow:_onClickChoseBtn(  )
	if not self.cur_item then return end

	local item_data = self.cur_item:getData()
	if not item_data then return end

	if item_data.status == HomeworldConst.Figure_State.Unlock then
		if item_data.id == _model:getMyCurHomeFigureId() then
			message(TI18N("与当前形象相同"))
		else
			_controller:sender26005(item_data.id)
			_controller:openHomeworldFigureWindow(false)
		end
	elseif item_data.status == HomeworldConst.Figure_State.CanUnlock then
		message(TI18N("请先激活该形象"))
	elseif item_data.status == HomeworldConst.Figure_State.Unlock then
		message(TI18N("该形象尚未解锁"))
	end
end

function HomeworldFigureWindow:openRootWnd(  )
	self:updateFigureList()
end

function HomeworldFigureWindow:updateFigureList( id )
	self.figure_data = {}
	for k,cfg in pairs(Config.HomeData.data_figure) do
		local f_data = deepCopy(cfg)
		f_data.status = _model:getFigureActiveStatus(f_data.id)
		_table_insert(self.figure_data, f_data)
	end

	table.sort(self.figure_data, SortTools.KeyUpperSorter("status"))

	local default_index = 1
	if id then
		for i,v in ipairs(self.figure_data) do
			if id == v.id then
				default_index = i
				break
			end
		end
	end
	self.item_scrollview:reloadData(default_index)
end

-- 显示剪影
function HomeworldFigureWindow:showCucoloris( status )
	if status == true then
		if not self.image_cucoloris then
			self.image_cucoloris = createImage(self.main_container, nil, 180, 322, cc.p(0.5, 0.5), false)
			local res = PathTool.getPlistImgForDownLoad("homeworld","homeworld_big_bg_3")
			self.image_cucoloris:setScale(0.6)
			self.image_load = loadImageTextureFromCDN(self.image_cucoloris, res, ResourcesType.single, self.image_load)
		end
		self.image_cucoloris:setVisible(true)
	elseif self.image_cucoloris then
		self.image_cucoloris:setVisible(false)
	end
end

-- 显示模型
function HomeworldFigureWindow:showFigureModel( status, effect_id, anim_name )
	if status and effect_id then
		if not self.cur_effect_id or self.cur_effect_id ~= effect_id then
			self.cur_effect_id = effect_id
			self:removeRoleSpine()
			self.role_spine = createEffectSpine( effect_id, cc.p(195, 238), cc.p(0.5, 0), true, anim_name )
			self.role_spine:setScale(1.36)
			self.main_container:addChild(self.role_spine)
		elseif self.role_spine then
			self.role_spine:setVisible(true)
		end
	elseif self.role_spine then
		self.role_spine:setVisible(false)
	end
end

function HomeworldFigureWindow:removeRoleSpine(  )
	if self.role_spine then
        self.role_spine:clearTracks()
        self.role_spine:removeFromParent()
        self.role_spine = nil
    end
end

function HomeworldFigureWindow:close_callback(  )
	self:removeRoleSpine()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.image_load then
		self.image_load:DeleteMe()
		self.image_load = nil
	end
	_controller:openHomeworldFigureWindow(false)
end

----------------------@ item
HomeworldFigureItem = class("HomeworldFigureItem", function()
    return ccui.Widget:create()
end)

function HomeworldFigureItem:ctor()
    self:configUI()
    self:register_event()
end

function HomeworldFigureItem:configUI(  )
	self.size = cc.size(119, 119)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setPosition(cc.p(self.size.width*0.5, self.size.height*0.5))
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setContentSize(self.size)
    self:addChild(self.root_wnd)

    self.image_bg = createImage(self.root_wnd, PathTool.getResFrame("common","common_1005"), self.size.width*0.5, self.size.height*0.5, cc.p(0.5, 0.5), true)
end

function HomeworldFigureItem:register_event(  )
	registerButtonEventListener(self.root_wnd, function (  )
		if self.callback then
			self.callback(self, self.data)
		end
	end, true, 1, nil, nil, nil, true)

	-- 红点
    if not self.update_red_status_event then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(HomeworldEvent.Update_Red_Status_Data,function(bid, status)
            if bid == HomeworldConst.Red_Index.Figure then
                self:updateFigureRedStatus()
            end
        end)
    end
end

function HomeworldFigureItem:updateFigureRedStatus(  )
	local red_staus = false
	if self.data and _model:getFigureActiveStatus(self.data.id) == HomeworldConst.Figure_State.CanUnlock then
		red_staus = true
	end
	addRedPointToNodeByStatus(self.root_wnd, red_staus, 7, 7, 99)
end

function HomeworldFigureItem:setData( data )
	if not data then return end

	self.data = data

	-- 图标
	if not self.figure_icon then
		self.figure_icon = createSprite(nil, self.size.width*0.5, self.size.height*0.5, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE)
	end
	if not self.cur_icon_id or self.cur_icon_id ~= data.ico_id then
		self.cur_icon_id = data.ico_id
		local res_path = PathTool.getFigureIconRes(data.ico_id)
		self.icon_load = loadSpriteTextureFromCDN(self.figure_icon, res_path, ResourcesType.single, self.icon_load, nil, handler(self, self._onLoadIconCallback))
	else
		self:_onLoadIconCallback()
	end

	-- 是否使用中
	local cur_figure_id = _model:getMyCurHomeFigureId()
	if data.id == cur_figure_id then
		if not self.use_icon then
			self.use_icon = createSprite(PathTool.getResFrame("common", "txt_cn_common_30015"), 33, 89, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 11)
			self.use_icon:setRotation(270)
		end
		self.use_icon:setVisible(true)
	elseif self.use_icon then
		self.use_icon:setVisible(false)
	end

	self:updateFigureRedStatus()
end

function HomeworldFigureItem:_onLoadIconCallback(  )
	-- 是否激活
	if self.data.status == HomeworldConst.Figure_State.Unlock then
		setChildUnEnabled(false, self.figure_icon)
	else
		setChildUnEnabled(true, self.figure_icon)
	end
end

function HomeworldFigureItem:addCallBack( callback )
	self.callback = callback
end

function HomeworldFigureItem:setIsSelect( status )
	if status == true then
		if not self.select_icon then
			self.select_icon = createImage(self.root_wnd, PathTool.getResFrame("common", "common_90019"), self.size.width*0.5, self.size.height*0.5, cc.p(0.5, 0.5), true, 10, true)
			self.select_icon:setContentSize(self.size)
		end
		self.select_icon:setVisible(true)
	elseif self.select_icon then
		self.select_icon:setVisible(false)
	end
end

function HomeworldFigureItem:getFigureId(  )
	if self.data then
		return self.data.id
	end
	return 0
end

function HomeworldFigureItem:getData(  )
	return self.data
end

function HomeworldFigureItem:DeleteMe(  )
	if self.icon_load then
		self.icon_load:DeleteMe()
		self.icon_load = nil
	end
	if self.update_red_status_event then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end