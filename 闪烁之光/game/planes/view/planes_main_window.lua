-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      位面冒险
-- <br/>Create: 2019-11-26
-- --------------------------------------------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

PlanesMainWindow = PlanesMainWindow or BaseClass(BaseView)

function PlanesMainWindow:__init()
	self.win_type = WinType.Full
    self.is_full_screen = true
	self.layout_name = "planes/planes_main_window"

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("planes", "planes_main"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("planes","big_bg_1", true), type = ResourcesType.single},
	}

	self.planes_item_list = {}
end

function PlanesMainWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("planes","big_bg_1",true), LOADTEXT_TYPE)
	self.background:setScale(display.getMaxScale())
	
	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	self.win_title = main_container:getChildByName("win_title")
	self.win_title:setString(TI18N("位面征战"))
	self.btn_rule = main_container:getChildByName("btn_rule")
	self.btn_shop = main_container:getChildByName("btn_shop")
	self.btn_shop:getChildByName("label"):setString(TI18N("商店"))
	self.btn_award = main_container:getChildByName("btn_award")
	self.btn_award:getChildByName("label"):setString(TI18N("奖励加成"))
	self.btn_first_award = main_container:getChildByName("btn_first_award")
	self.btn_first_award:getChildByName("label"):setString(TI18N("首通奖励"))
	self.bottom_panel = main_container:getChildByName("bottom_panel")
	self.close_btn = self.bottom_panel:getChildByName("close_btn")
	self.cur_dun_txt = self.bottom_panel:getChildByName("cur_dun_txt")
	self.cur_dun_txt:setString("")
	self.time_txt = self.bottom_panel:getChildByName("time_txt")
	self.bottom_panel:getChildByName("tips_txt"):setString(TI18N("选择副本后本轮征战不可更换其他副本"))
	self.bottom_panel:getChildByName("tips_txt_1"):setString(TI18N("每个副本可获不同阵营的英雄碎片，其余奖励相同"))

	self.lock_tips_bg = main_container:getChildByName("lock_tips_bg")
	self.lock_tips_bg:getChildByName("tips_txt"):setString(TI18N("开启条件:"))
	self.lock_tips_bg:setVisible(false)
	self.lock_tips_txt_1 = self.lock_tips_bg:getChildByName("tips_txt_1")
	self.lock_tips_txt_2 = self.lock_tips_bg:getChildByName("tips_txt_2")
	self.lock_tips_txt_3 = self.lock_tips_bg:getChildByName("tips_txt_3")

	self.pos_node_list = {}
	for i = 1, 5 do
		local pos_node = main_container:getChildByName("pos_node_" .. i)
		if pos_node then
			_table_insert(self.pos_node_list, pos_node)
		end
	end

	-- 适配
	local top_off = display.getTop(main_container)
	local bottom_off = display.getBottom(main_container)
	local offset_y = top_off - bottom_off - SCREEN_HEIGHT -- 屏幕高度差
	local image_title = main_container:getChildByName("image_title")
	image_title:setPositionY(top_off - 55)
	self.win_title:setPositionY(top_off - 119)
	self.btn_rule:setPositionY(top_off - 160)
	self.btn_shop:setPositionY(top_off - 160)
	self.btn_award:setPositionY(top_off - 255)
	self.btn_first_award:setPositionY(top_off - 350)
	self.bottom_panel:setPositionY(bottom_off)
end

-- 锁屏
function PlanesMainWindow:onLockScreenCallBack( flag )
	if flag == true then
		if not self.lock_mask then
			local con_size = self.main_container:getContentSize()
			self.lock_mask = ccui.Layout:create()
			self.lock_mask:setContentSize(SCREEN_WIDTH, SCREEN_HEIGHT)
			self.lock_mask:setAnchorPoint(cc.p(0.5, 0.5))
			self.lock_mask:setScale(display.getMaxScale())
			self.lock_mask:setPosition(con_size.width*0.5, con_size.height*0.5)
			self.lock_mask:setTouchEnabled(true)
			self.lock_mask:setSwallowTouches(true)
			self.main_container:addChild(self.lock_mask, 10)
		end
		self.lock_mask:setVisible(true)
	elseif self.lock_mask then
		self.lock_mask:setVisible(false)
	end
end

function PlanesMainWindow:onShowLockContent( world_pos, index, dun_id )
	if not self.touch_mask then
		local con_size = self.main_container:getContentSize()
		self.touch_mask = ccui.Layout:create()
		self.touch_mask:setContentSize(SCREEN_WIDTH, SCREEN_HEIGHT)
		self.touch_mask:setAnchorPoint(cc.p(0.5, 0.5))
		self.touch_mask:setScale(display.getMaxScale())
		self.touch_mask:setPosition(con_size.width*0.5, con_size.height*0.5)
		self.touch_mask:setTouchEnabled(true)
		self.main_container:addChild(self.touch_mask, 10)
		self.touch_mask:setSwallowTouches(false)
		self.touch_mask:addTouchEventListener(function ( sender, event_type )
			if event_type == ccui.TouchEventType.ended then
				self.touch_mask:setVisible(false)
				self.lock_tips_bg:setVisible(false)
			end
		end)
	end
	self.touch_mask:setVisible(true)
	self.lock_tips_bg:setVisible(true)
	local local_pos = self.main_container:convertToNodeSpace(world_pos)
	if index%2 == 0 then
		self.lock_tips_bg:setPosition(local_pos.x + 260, local_pos.y-70)
	else
		self.lock_tips_bg:setPosition(local_pos.x - 260, local_pos.y-70)
	end
	local dun_cfg = Config.SecretDunData.data_customs[dun_id]
	if dun_cfg then
		local tips_str_list = {}
        local is_pass = false
        -- 通关位面副本
		if dun_cfg.id_limit and dun_cfg.id_limit[1] then
			if _model:checkDunIsPassByDunId(dun_cfg.id_limit[1]) then
				is_pass = true
			end
			local dun_info = Config.SecretDunData.data_dun_info[dun_cfg.id_limit[1]]
			if is_pass then
				self.lock_tips_txt_1:setTextColor(cc.c4b(87, 202, 69, 255))
				self.lock_tips_txt_1:setString(TI18N(_string_format("[%s]进度达100%%[已达成]", dun_info.name or "")))
			else
				self.lock_tips_txt_1:setTextColor(cc.c4b(224, 191, 152, 255))
				self.lock_tips_txt_1:setString(TI18N(_string_format("[%s]进度达100%%", dun_info.name or "")))
			end
		end
		
        -- 等级
        local role_vo = RoleController:getInstance():getRoleVo()
		if role_vo.lev < dun_cfg.lev_limit then
			self.lock_tips_txt_2:setTextColor(cc.c4b(224, 191, 152, 255))
			self.lock_tips_txt_2:setString(TI18N(_string_format("角色等级达%d级", dun_cfg.lev_limit)))
		else
			self.lock_tips_txt_2:setTextColor(cc.c4b(87, 202, 69, 255))
			self.lock_tips_txt_2:setString(TI18N(_string_format("角色等级达%d级[已达成]", dun_cfg.lev_limit)))
        end
        -- 战力
        if role_vo.power < dun_cfg.power_limit then
            self.lock_tips_txt_3:setTextColor(cc.c4b(224, 191, 152, 255))
			self.lock_tips_txt_3:setString(TI18N(_string_format("角色战力达到%d", dun_cfg.power_limit)))
		else
			self.lock_tips_txt_3:setTextColor(cc.c4b(87, 202, 69, 255))
			self.lock_tips_txt_3:setString(TI18N(_string_format("角色战力达到%d[已达成]", dun_cfg.power_limit)))
        end
    end
end

function PlanesMainWindow:register_event( )
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
	registerButtonEventListener(self.btn_rule, handler(self, self.onClickRuleBtn), true)
	registerButtonEventListener(self.btn_shop, handler(self, self.onClickShopBtn), true)
	registerButtonEventListener(self.btn_award, handler(self, self.onClickAwardBtn), true)
	registerButtonEventListener(self.btn_first_award, handler(self, self.onClickFirstAwardBtn), true)

	-- 副本数据
	self:addGlobalEvent(PlanesEvent.Update_Dun_Base_Event, function (  )
		self:setData()
	end)

	-- 红点数据
	self:addGlobalEvent(PlanesEvent.Update_Planes_Red_Event, function ( bid, red_status )
		self:updateRedStatus(bid)
	end)
end

function PlanesMainWindow:onClickCloseBtn(  )
	_controller:openPlanesMainWindow(false)
end

function PlanesMainWindow:onClickRuleBtn( param, sender, event_type )
	local rule_cfg = Config.SecretDunData.data_const["planes_rule"]
	if rule_cfg then
		TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
	end
end

function PlanesMainWindow:onClickShopBtn(  )
	MallController:getInstance():openMallPanel(true, MallConst.MallType.FriendShop)
end

function PlanesMainWindow:onClickAwardBtn(  )
	_controller:openPlanesAwardInfoWindow(true)
end

function PlanesMainWindow:onClickFirstAwardBtn(  )
	_controller:openPlanesFirstAwardWindow(true)
end

function PlanesMainWindow:openRootWnd( )
	_controller:sender23123(0)
	_controller:sender23100()
	_model:updatePlanesRedStatus(PlanesConst.Red_Index.Login, false)
	self:updateRedStatus()
end

function PlanesMainWindow:setData( )
	self.cur_dun_id = _model:getCurDunId() -- 当前选择的副本id

	local less_time = _model:getResetLessTime()
	if less_time > 0 then
		self.time_txt:setVisible(true)
		commonCountDownTime(self.time_txt, less_time, {label_type=CommonAlert.type.rich, end_title=TI18N("后重置")})
	else
		self.time_txt:setVisible(false)
	end

	local dun_cfg = Config.SecretDunData.data_dun_info[self.cur_dun_id]
	if dun_cfg then
		self.cur_dun_txt:setString(TI18N(_string_format("当前位于: %s", dun_cfg.name)))
	else
		self.cur_dun_txt:setString("")
	end

	local old_dun_num = 0
	if self.planes_data then
		old_dun_num = #self.planes_data
	end

	self.planes_data = {}
	for id,cfg in pairs(Config.SecretDunData.data_dun_info) do
		local dun_data = {}
		dun_data.id = id
		dun_data.name = cfg.name
		dun_data.dun_res_id = cfg.dun_res_id
		dun_data.dun_status = _model:getPlanesDunStatusById(id)
		_table_insert(self.planes_data, dun_data)
	end
	_table_sort(self.planes_data, SortTools.KeyLowerSorter("id"))

	for i,p_data in ipairs(self.planes_data) do
		local item = self.planes_item_list[i]
		local pos_node = self.pos_node_list[i]
		if not item and pos_node then
			item = PlanesMainItem.new()
			item:addCallBack(handler(self, self.onShowLockContent))
			item:addLockScreenCallBack(handler(self, self.onLockScreenCallBack))
			pos_node:addChild(item)
			self.planes_item_list[i] = item
		end
		if item then
			item:setData(p_data, i)
		end
	end
end

-- 更新红点相关数据
function PlanesMainWindow:updateRedStatus( bid )
	if bid == PlanesConst.Red_Index.Award then -- 首通奖励红点
		for k,item in pairs(self.planes_item_list or {}) do
			item:updateRedStatus()
		end
		
		local first_red_status = _model:getPlanesRedStatusByBid(PlanesConst.Red_Index.Award)
		addRedPointToNodeByStatus(self.btn_first_award, first_red_status)
	else
		local first_red_status = _model:getPlanesRedStatusByBid(PlanesConst.Red_Index.Award)
		addRedPointToNodeByStatus(self.btn_first_award, first_red_status)
	end
end

function PlanesMainWindow:close_callback( )
	if self.planes_item_list then
		for k,item in pairs(self.planes_item_list) do
			item:DeleteMe()
			item = nil
		end
	end
	_controller:openPlanesMainWindow(false)
end