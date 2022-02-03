--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-24 20:42:34
-- @description    : 
		-- 录像收藏界面
---------------------------------
VedioCollectWindow = VedioCollectWindow or BaseClass(BaseView)

local _controller = VedioController:getInstance()
local _model = _controller:getModel()

function VedioCollectWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "vedio/vedio_collect_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("vedio", "vedio"), type = ResourcesType.plist},
	}

	self.vedio_cell_index = 1
end

function VedioCollectWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
	self:playEnterAnimatianByObj(main_container, 1)
	self.share_panel = self.root_wnd:getChildByName("share_panel")
	self.share_panel:setVisible(false)
    self.share_panel:setSwallowTouches(false)
    self.share_bg = self.share_panel:getChildByName("share_bg")
    self.btn_guild = self.share_bg:getChildByName("btn_guild")
    self.btn_world = self.share_bg:getChildByName("btn_world")
    self.btn_cross = self.share_bg:getChildByName("btn_cross")
    self.share_bg:getChildByName("guild_label"):setString(TI18N("分享到公会频道"))
    self.share_bg:getChildByName("world_label"):setString(TI18N("分享到世界频道"))
    self.share_bg:getChildByName("cross_label"):setString(TI18N("分享到跨服频道"))

	local win_title = main_container:getChildByName("win_title")
	win_title:setString(TI18N("个人收藏"))

	self.num_txt = main_container:getChildByName("num_txt")
	self.no_vedio_image = main_container:getChildByName("no_vedio_image")
	self.no_vedio_image:getChildByName("label"):setString(TI18N("暂无录像收藏"))

	local vedio_list = main_container:getChildByName("vedio_list")
	local scroll_view_size = vedio_list:getContentSize()
    local setting = {
        --item_class = VedioMainItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 620,               -- 单元的尺寸width
        item_height = 452,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.vedio_scrollview = CommonScrollViewSingleLayout.new(vedio_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.vedio_scrollview:setSwallowTouches(false)

    self.vedio_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.vedio_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.vedio_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function VedioCollectWindow:_createNewCell(  )
	local cell = VedioMainItem.new()
    cell:addCallBack(handler(self, self._onClickShareBtn))
    return cell
end

function VedioCollectWindow:_numberOfCells(  )
	if not self.data then return 0 end
    return #self.data
end

function VedioCollectWindow:_updateCellByIndex( cell, index )
	if not self.data then return end
    cell.index = index
    local cell_data = self.data[index]
    if not cell_data then return end
    cell:setExtendData({is_collect = true})
    cell:setData(cell_data, index)
    self.vedio_cell_index = index
end

function VedioCollectWindow:refreshCollectNum(  )
	local cur_num = 0
	if self.data then
		cur_num = #self.data
	end
	local max_num = 0
	local collect_cfg = Config.VideoData.data_const["self_collection_limit"]
	if collect_cfg then
		max_num = collect_cfg.val
	end
	self.num_txt:setString(string.format(TI18N("收藏数:%d/%d"), cur_num, max_num))
end

function VedioCollectWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openVedioCollectWindow(false)
	end)

	-- 分享到公会
    registerButtonEventListener(self.btn_guild, function (  )
    	if RoleController:getInstance():getRoleVo():isHasGuild() == false then
            message(TI18N("您暂未加入公会"))
            return
        end
        if self.replay_id then
            _controller:requestShareVedio(self.replay_id, ChatConst.Channel.Gang, self.srv_id, self.combat_type)
            _model:updateVedioData(nil, self.replay_id, "share", self.share_num)
            local new_data = self:updateVedioDataById(self.replay_id, "share", self.share_num)
            GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
        end
        self.replay_id = nil
        self.srv_id = nil
        self.combat_type = nil
        self.share_panel:setVisible(false)
    end, false, 1)
    -- 分享到世界
    registerButtonEventListener(self.btn_world, function (  )
        if self.replay_id then
            _controller:requestShareVedio(self.replay_id, ChatConst.Channel.World, self.srv_id, self.combat_type)
            _model:updateVedioData(nil, self.replay_id, "share", self.share_num)
            local new_data = self:updateVedioDataById(self.replay_id, "share", self.share_num)
            GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
        end
        self.replay_id = nil
        self.srv_id = nil
        self.combat_type = nil
        self.share_panel:setVisible(false)
    end, false, 1)
    -- 分享到跨服
    registerButtonEventListener(self.btn_cross, function (  )
    	local cross_config = Config.MiscData.data_const["cross_level"]
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo.lev < cross_config.val then
            message(string.format(TI18N("%d级开启跨服频道"), cross_config.val))
            return
        end
        if self.replay_id then
            _controller:requestShareVedio(self.replay_id, ChatConst.Channel.Cross, self.srv_id, self.combat_type)
            _model:updateVedioData(nil, self.replay_id, "share", self.share_num)
            local new_data = self:updateVedioDataById(self.replay_id, "share", self.share_num)
            GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
        end
        self.replay_id = nil
        self.srv_id = nil
        self.combat_type = nil
        self.share_panel:setVisible(false)
    end, false, 1)
    -- 点击关闭分享界面
    self.share_panel:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            self.share_panel:setVisible(false)
        end
    end)

	self:addGlobalEvent(VedioEvent.UpdateCollectVedioEvent, function ( data )
		self:setData(data)
	end)

	-- 取消收藏
	self:addGlobalEvent(VedioEvent.CancelCollectVedioEvent, function ( id )
		for k,v in pairs(self.data) do
			if v.id == id then
				table.remove(self.data, k)
				break
			end
		end
		if next(self.data) == nil then
			self.vedio_scrollview:reloadData()
			self.no_vedio_image:setVisible(true)
			--self.vedio_scrollview:setData(self.data)
		else
			--self.vedio_scrollview:resetAddPosition(self.data)
			self.vedio_scrollview:reloadData(self.vedio_cell_index-1)
			self.no_vedio_image:setVisible(false)
		end
		self:refreshCollectNum()
	end)
end

function VedioCollectWindow:_onClickShareBtn( world_pos, replay_id, share_num, srv_id, combat_type )
    self.replay_id = replay_id
    self.share_num = share_num
    self.srv_id = srv_id
    self.combat_type = combat_type
    local node_pos = self.share_panel:convertToNodeSpace(world_pos)
    if node_pos then
        self.share_bg:setPosition(cc.p(node_pos.x-38, node_pos.y+70))
        self.share_panel:setVisible(true)
    end
end

function VedioCollectWindow:updateVedioDataById( id, key, val )
	if not self.data then return end
	local vedio_data = {}
	for k,v in pairs(self.data) do
		if v.id == id then
			v[key] = val
			vedio_data = v
		end
	end
	return vedio_data
end

function VedioCollectWindow:openRootWnd(  )
	_controller:requestMyVedioByType(VedioConst.MyVedio_Type.Collect)
	self:refreshCollectNum()
	GlobalEvent:getInstance():Fire(VedioEvent.OpenCollectViewEvent, true)
end

function VedioCollectWindow:setData( data )
	if not data or next(data) == nil then
		self.no_vedio_image:setVisible(true)
	else
		self.no_vedio_image:setVisible(false)
		self.data = data
		self.vedio_scrollview:reloadData()
		--self.vedio_scrollview:setData(data, handler(self, self._onClickShareBtn), nil, {is_collect = true})
		self:refreshCollectNum()
	end
end

function VedioCollectWindow:close_callback(  )
	if self.vedio_scrollview then
		self.vedio_scrollview:DeleteMe()
		self.vedio_scrollview = nil
	end
	GlobalEvent:getInstance():Fire(VedioEvent.OpenCollectViewEvent, false)
	_controller:openVedioCollectWindow(false)
end