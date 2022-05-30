---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/09 21:10:02
-- @description: 位面冒险 对方阵容
---------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

PlanesMasterWindow = PlanesMasterWindow or BaseClass(BaseView)

function PlanesMasterWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "planes/planes_master_info"

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("planes", "planes_map"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("planes", "planes_info"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("planes","big_bg_2"), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("planes","big_bg_3"), type = ResourcesType.single},
	}

	self.award_item_list = {}
	self.left_item_list = {}
	self.right_item_list = {}
end

function PlanesMasterWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	self.win_title = main_container:getChildByName("win_title")
	self.win_title:setString(TI18N("守卫"))
	main_container:getChildByName("tips_txt"):setString(TI18N("挑战怪物或精英怪胜利后可掉落增强实力的遗物"))
	main_container:getChildByName("award_txt"):setString(TI18N("奖励"))
	--
	--local left_bg_1 = main_container:getChildByName("left_bg_1")
	--loadSpriteTexture(left_bg_1, PathTool.getPlistImgForDownLoad("planes","big_bg_3"), LOADTEXT_TYPE)
	--local right_bg_1 = main_container:getChildByName("right_bg_1")
	--loadSpriteTexture(right_bg_1, PathTool.getPlistImgForDownLoad("planes","big_bg_2"), LOADTEXT_TYPE)

	self.btn_fight = main_container:getChildByName("btn_fight")
	self.btn_fight:getChildByName("label"):setString(TI18N("开战"))
	self.btn_embattle = main_container:getChildByName("btn_embattle")
	self.btn_embattle:getChildByName("label"):setString(TI18N("布阵"))
	self.close_btn = main_container:getChildByName("close_btn")

	self.left_name_txt = main_container:getChildByName("name_txt_1")
	self.left_atk_txt = main_container:getChildByName("atk_txt_1")
	self.left_atk_txt:setString(0)
	self.left_role_panel = main_container:getChildByName("panel_role_left")
	self.right_name_txt = main_container:getChildByName("name_txt_2")
	self.right_atk_txt = main_container:getChildByName("atk_txt_2")
	self.right_role_panel = main_container:getChildByName("panel_role_right")

	self.left_buff_txt_1 = main_container:getChildByName("left_buff_txt_1")
	self.left_buff_txt_2 = main_container:getChildByName("left_buff_txt_2")
	self.left_buff_txt_3 = main_container:getChildByName("left_buff_txt_3")
	self.add_atk_txt_1 = main_container:getChildByName("add_atk_txt_1")
	self.add_atk_txt_1:setString(TI18N("战力值+0%"))
	self.add_atk_txt_2 = main_container:getChildByName("add_atk_txt_2")
	self.award_tips_txt = main_container:getChildByName("award_tips_txt")

	-- 精灵
	self.left_elfin_item_list = {}
	self.right_elfin_item_list = {}
	self.tree_lv_left = main_container:getChildByName("tree_lv_left")
	self.tree_lv_right = main_container:getChildByName("tree_lv_right")
	self.left_elfin_panel = main_container:getChildByName("left_elfin_panel")
	self.right_elfin_panel = main_container:getChildByName("right_elfin_panel")

	local panel_size = self.left_role_panel:getContentSize()
    --9位置
    self.left_position_list = {}
    for i=1,9 do
		local item_bg = self.left_role_panel:getChildByName("pos_bg_" .. i)
		local pos_x, pos_y = item_bg:getPosition()
		_table_insert(self.left_position_list, cc.p(pos_x, pos_y))
	end
	self.right_position_list = {}
	for i=1,9 do
		local item_bg = self.right_role_panel:getChildByName("pos_bg_" .. i)
		local pos_x, pos_y = item_bg:getPosition()
		_table_insert(self.right_position_list, cc.p(pos_x, pos_y))
	end

	self.left_role_head = PlayerHead.new(PlayerHead.type.circle)
	self.left_role_head:setPosition(92, 857)
	self.left_role_head:setScale(0.9)
	self.main_container:addChild(self.left_role_head)
	
	self.right_role_head = PlayerHead.new(PlayerHead.type.circle)
	self.right_role_head:setPosition(402, 857)
	self.right_role_head:setScale(0.9)
    self.main_container:addChild(self.right_role_head)

	self.reward_panel = main_container:getChildByName("reward_panel")
	local panel_size = self.reward_panel:getContentSize()
	local scroll_view_size = cc.size(panel_size.width, panel_size.height+10)
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.8,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.8,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.8
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.reward_panel, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
	self.item_scrollview:setClickEnabled(false)
end

function PlanesMasterWindow:register_event( )
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
	registerButtonEventListener(self.btn_fight, handler(self, self.onClickFightBtn), true)
	registerButtonEventListener(self.btn_embattle, handler(self, self.onClickEmbattleBtn), true)

	-- 可出战宝可梦数据
	self:addGlobalEvent(PlanesEvent.Get_All_Hero_Event, function (  )
		self.get_all_hero_flag = true
		if self.form_data then
			self:setMyFormData()
		end
	end)

	-- 我方阵容数据
	self:addGlobalEvent(PlanesEvent.Get_Form_Data_Event, function ( data )
		self.form_data = data
		if self.get_all_hero_flag then
			self:setMyFormData()
		end
	end)

	-- 通过布阵更新了我方阵容数据
	self:addGlobalEvent(PlanesEvent.Update_Form_Data_Event, function ( form_type, pos_data )
		self:updateMyFormData(form_type, pos_data)
	end)

	-- 我方精灵数据更新
	self:addGlobalEvent(ElfinEvent.Get_Elfin_Tree_Data_Event, function (  )
		self:updateMyElfinInfo()
	end)

	-- 通过布阵后战力值更新
	self:addGlobalEvent(PlanesEvent.Update_Form_Atk_Event, function ( atk_val )
		self:updateMyHeroAtkVal(atk_val)
	end)

	-- 敌方阵容数据
	self:addGlobalEvent(PlanesEvent.Get_Master_Data_Event, function ( data )
		self:setMasterData(data)
	end)
end

function PlanesMasterWindow:onClickCloseBtn(  )
	_controller:openPlanesMasterWindow(false)
end

-- 出战
function PlanesMasterWindow:onClickFightBtn(  )
	if not self.form_data or not self.grid_index then return end

	local ext_list = {}
	-- 阵法
	_table_insert(ext_list, {type = PlanesConst.Proto_23104._6, val1 = self.form_data.formation_type, val2 = 0})
	-- 神器
	_table_insert(ext_list, {type = PlanesConst.Proto_23104._7, val1 = self.form_data.hallows_id, val2 = 0})
	-- 宝可梦
	for k,v in pairs(self.form_data.pos_info) do
		if (v.flag and v.flag == 1) or (v.data and v.data.flag == 1) then -- 雇佣宝可梦
			_table_insert(ext_list, {type = PlanesConst.Proto_23104._11, val1 = v.pos, val2 = v.id})
		else
			_table_insert(ext_list, {type = PlanesConst.Proto_23104._8, val1 = v.pos, val2 = v.id})
		end
	end
	_controller:sender23104( self.grid_index, 1, ext_list )
	_controller:openPlanesMasterWindow(false)
end

-- 布阵
function PlanesMasterWindow:onClickEmbattleBtn(  )
	HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Planes, {}, HeroConst.FormShowType.eFormSave)
end

function PlanesMasterWindow:openRootWnd( grid_index )
	self.grid_index = grid_index
	self:updateAwardList()
	_controller:sender23122() -- 请求我方阵容数据
	_controller:sender23104( grid_index, 0, {} ) -- 请求敌方阵容数据
	_controller:sender23115()
end

-- 奖励数据
function PlanesMasterWindow:updateAwardList(  )
	if not self.grid_index then return end
	local evt_vo = _model:getPlanesEvtVoByGridIndex(self.grid_index)
	if not evt_vo or not evt_vo.config then return end

	-- 标题
	self.win_title:setString(evt_vo.config.name)
	-- 怪物显示事件名称
	if evt_vo.config.type == PlanesConst.Evt_Type.Monster then
		self.right_name_txt:setString(evt_vo.config.name)
	end

	local cur_dun_id = _model:getCurDunId()
	local add_per = 0
	local show_data_list = {}
	for id,cfg in pairs(Config.SecretDunData.data_customs) do
		if _model:checkDunIsPassByDunId(id) then
			add_per = add_per + (cfg.add_radio or 0)
		end
	end
	self.award_tips_txt:setString(TI18N(_string_format("当前奖励加成值:%d%%", add_per/10)))

	local data_list = evt_vo.config.reward or {}
	local item_list = {}
	for k,v in pairs(data_list) do
		local vo = {}
        vo.bid = v[1]
        vo.quantity = math.floor((1+add_per/1000)*v[2])
        _table_insert(item_list, vo)
    end
    self.item_scrollview:setData(item_list)
	self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
		for k,v in pairs(list) do
			local item_vo = v:getData()
			if item_vo.bid == 25 and _model:isHolidayOpen() then
				v:holidHeroExpeditTag(true, TI18N("限时提升"))
			end
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end

-- 我方阵容数据
function PlanesMasterWindow:setMyFormData( )
	local role_vo = RoleController:getInstance():getRoleVo()
	if not self.form_data or not role_vo then return end
	-- 名称
	self.left_name_txt:setString(role_vo.name)
	-- 头像
	self.left_role_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)

	-- 宝可梦头像
	self.hero_base_atk_val = 0
	local formation_config = Config.FormationData.data_form_data[self.form_data.formation_type]
	local partner_ids = {}
	for i=1,5 do
		local role_info = self:getRoleDataByIndex(i, self.form_data.pos_info)
		local role_data
		if role_info then
			if role_info.flag and role_info.flag == 1 then
				role_data = _model:getPlanesHireHeroData(role_info.id)
				_table_insert(partner_ids, {flag = 1, id = role_data.partner_id})
			else
				role_data = HeroController:getInstance():getModel():getHeroById(role_info.id)
				_table_insert(partner_ids, {flag = 0, id = role_data.partner_id})
			end
		end
        local hero_item = self.left_item_list[i]
		if role_data then
            if hero_item == nil then
                hero_item = self:createHeroItemByIndex(i, self.left_role_panel)
                self.left_item_list[i] = hero_item
            else
                hero_item:setVisible(true)
			end
			hero_item:setData(role_data)
			if role_data.flag == 1 then
	            hero_item:showHelpImg(true)
	        else
	            hero_item:showHelpImg(false)
	        end
	        -- 剩余血量
	        local hp_per = role_data.hp_per or PlanesController:getInstance():getModel():getMyPlanesHeroHpPer(role_data.partner_id, role_data.flag)
	        if hp_per then
	            hero_item:showProgressbar(hp_per)
	        end

			-- 位置
			local pos_cfg = formation_config.pos[i]
			if pos_cfg then
				local pos = self.left_position_list[pos_cfg[2]]
				if pos then
					hero_item:setPosition(pos)
				end
			end

			-- 总战力
			self.hero_base_atk_val = self.hero_base_atk_val + (role_data.power or 0)
        else
            if hero_item then
                hero_item:setVisible(false)
            end
        end
	end

	-- 请求战力加成
	if next(partner_ids) ~= nil then
		-- 请求新上阵宝可梦的战力值
		_controller:sender23120(partner_ids)
	end

	-- 精灵
	self:updateMyElfinInfo()
end

-- 更新我方精灵显示
function PlanesMasterWindow:updateMyElfinInfo(  )
	local elfin_data = ElfinController:getInstance():getModel():getElfinTreeData()
	--有报错 所以改了
	if not elfin_data then self.tree_lv_left:setString("") return end

	self.tree_lv_left:setString(_string_format(TI18N("古树：%d级"), elfin_data.lev or 0))
	-- 精灵
    for i=1,4 do
        local left_elfin_item = self.left_elfin_item_list[i]
        if not left_elfin_item then
            left_elfin_item = SkillItem.new(true, true, true, 0.5, true)
            local pos_x = 28 + (i-1)*68
            left_elfin_item:setPosition(cc.p(pos_x, 24))
            self.left_elfin_panel:addChild(left_elfin_item)
            self.left_elfin_item_list[i] = left_elfin_item
        end
        self:setElfinSkillItemData(left_elfin_item, elfin_data.sprites or {}, i)
    end
end

-- 更新我方阵容
function PlanesMasterWindow:updateMyFormData( form_type, pos_data )
	if not self.form_data then return end
	self.form_data.formation_type = form_type
	self.form_data.pos_info = pos_data
	self.hero_base_atk_val = 0 -- 宝可梦基础战力值
	local partner_ids = {}
	local formation_config = Config.FormationData.data_form_data[self.form_data.formation_type]
	for i=1,5 do
		local role_info = self:getRoleDataByIndex(i, pos_data)
		local role_data
		if role_info then
			if role_info.data and role_info.data.flag == 1 then
				role_data = role_info.data
				_table_insert(partner_ids, {flag = 1, id = role_info.data.partner_id})
			else
				role_data = HeroController:getInstance():getModel():getHeroById(role_info.id)
				_table_insert(partner_ids, {flag = 0, id = role_data.partner_id})
			end
		end
        local hero_item = self.left_item_list[i]
        if role_data then
            if hero_item == nil then
                hero_item = self:createHeroItemByIndex(i, self.left_role_panel)
                self.left_item_list[i] = hero_item
            else
                hero_item:setVisible(true)
			end
			hero_item:setData(role_data)

			if role_data.flag == 1 then
	            hero_item:showHelpImg(true)
	        else
	            hero_item:showHelpImg(false)
	        end
	        -- 剩余血量
	        local hp_per = role_data.hp_per or PlanesController:getInstance():getModel():getMyPlanesHeroHpPer(role_data.partner_id, role_data.flag)
	        if hp_per then
	            hero_item:showProgressbar(hp_per)
	        end

			-- 位置
			local pos_cfg = formation_config.pos[i]
			if pos_cfg then
				local pos = self.left_position_list[pos_cfg[2]]
				if pos then
					hero_item:setPosition(pos)
				end
			end
			-- 总战力
			self.hero_base_atk_val = self.hero_base_atk_val + (role_data.power or 0)
        else
            if hero_item then
                hero_item:setVisible(false)
            end
        end
	end
	if next(partner_ids) ~= nil then
		-- 请求新上阵宝可梦的战力值
		_controller:sender23120(partner_ids)
	end
end

-- 敌方阵容数据
function PlanesMasterWindow:setMasterData( data )
	if not data then return end

	-- 名称
	if self.grid_index then
		local evt_vo = _model:getPlanesEvtVoByGridIndex(self.grid_index)
		if evt_vo and evt_vo.config and evt_vo.config.type == PlanesConst.Evt_Type.Guard then
			self.right_name_txt:setString(data.name)
		end
	end
	-- 战力
	self.right_atk_txt:setString(data.guards_power)
	-- 头像
	self.right_role_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)

	-- 宝可梦头像
	local formation_config = Config.FormationData.data_form_data[data.formation_type]
	for i=1,5 do
		local role_data = self:getRoleDataByIndex(i, data.guards)
        local hero_item = self.right_item_list[i]
        if role_data then
            if hero_item == nil then
                hero_item = self:createHeroItemByIndex(i, self.right_role_panel)
                self.right_item_list[i] = hero_item
            else
                hero_item:setVisible(true)
			end
			role_data.is_master = true
			role_data.rid = data.rid or 0
			role_data.srv_id = data.srv_id or ""
			hero_item:setData(role_data)
			-- 剩余血量
			if role_data.hp_per then
				hero_item:showProgressbar(role_data.hp_per)
				if role_data.hp_per <= 0 then
					hero_item:showStrTips(true,TI18N("已阵亡"),{c3b = cc.c3b(255,255,255)})
				end
	        end
			
			-- 位置
			local pos_cfg = formation_config.pos[i]
			if pos_cfg then
				local pos = self.right_position_list[pos_cfg[2]]
				if pos then
					hero_item:setPosition(pos)
				end
			end
        else
            if hero_item then
                hero_item:setVisible(false)
            end
        end
	end

	if IS_HIDE_ELFIN then
		self.tree_lv_right:setString("")
	else
		-- 精灵
		self.tree_lv_right:setString(_string_format(TI18N("古树：%d级"), data.sprite_lev or 0))
		for i=1,4 do
			local right_elfin_item = self.right_elfin_item_list[i]
			if not right_elfin_item then
				right_elfin_item = SkillItem.new(true, true, true, 0.5, true)
				local pos_x = -11 + (i-1)*64
				right_elfin_item:setPosition(cc.p(pos_x, 24))
				self.right_elfin_panel:addChild(right_elfin_item)
				self.right_elfin_item_list[i] = right_elfin_item
			end
			self:setElfinSkillItemData(right_elfin_item, data.sprites or {}, i)
		end
	end

	
	-- 加成
	local dif_val = data.strength or 1000
	if dif_val >= 1000 then
		self.add_atk_txt_2:setString(_string_format(TI18N("难度加成:+%s%%"), (dif_val-1000)/10))
	else
		self.add_atk_txt_2:setString(_string_format(TI18N("难度加成:-%s%%"), (1000-dif_val)/10))
	end
	
	-- 我方buff数据
	for k,v in pairs(data.buffs or {}) do
		if v.quality == 1 then -- 蓝
			self.left_buff_txt_1:setString(v.num)
		elseif v.quality == 2 then --紫
			self.left_buff_txt_2:setString(v.num)
		elseif v.quality == 3 then -- 橙
			self.left_buff_txt_3:setString(v.num)
		end
	end
end

-- 根据位置获取精灵的bid
function PlanesMasterWindow:getElfinBidByPos( sprite_data, pos )
    if not sprite_data or next(sprite_data) == nil then return end
    for k,v in pairs(sprite_data) do
        if v.pos == pos then
            return v.item_bid
        end
    end
end

function PlanesMasterWindow:setElfinSkillItemData( skill_item, sprite_data, pos )
    local elfin_bid = self:getElfinBidByPos(sprite_data, pos)
    if elfin_bid then
        skill_item:showLockIcon(false)
        local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
        if elfin_bid == 0 or not elfin_cfg then -- 已解锁，但未放置精灵
            skill_item:setData()
            skill_item:showLevel(false)
        else
            local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
            if skill_cfg then
                skill_item:showLevel(true)
                skill_item:setData(skill_cfg)
            end
        end
    else
        skill_item:setData()
        skill_item:showLevel(false)
        skill_item:showLockIcon(true)
    end
end

-- 更新我放战力值
function PlanesMasterWindow:updateMyHeroAtkVal( atk_val )
	self.left_atk_txt:setString(atk_val)
	self.hero_base_atk_val = self.hero_base_atk_val or 0
	local add_percent = (atk_val-self.hero_base_atk_val)/self.hero_base_atk_val*100
	self.add_atk_txt_1:setString(string.format(TI18N("战力值+%d%%"), add_percent))
end

-- 根据位置获取我方宝可梦id
function PlanesMasterWindow:getMyRoleIdByIndex( index, role_list )
	for k,v in pairs(role_list) do
		if v.pos == index then
            return v.id
        end
    end
end

-- 根据位置获取敌方宝可梦数据
function PlanesMasterWindow:getRoleDataByIndex( index, role_list )
	for k,v in pairs(role_list) do
        if v.pos == index then
            return v
        end
    end
end

--根据位置索引创建一个新的item
function PlanesMasterWindow:createHeroItemByIndex(index, parent)
	local hero_item = HeroExhibitionItem.new(0.65, true, nil, nil ,true)
	hero_item:addCallBack(handler(self, self.onClickHeroItem))
    parent:addChild(hero_item)
    hero_item:setVisible(true)
    return hero_item
end

function PlanesMasterWindow:onClickHeroItem( item, hero_data )
	if not hero_data then return end

	if hero_data.is_master then -- 怪物
		if hero_data.srv_id ~= "" and hero_data.rid and hero_data.partner_id then
			LookController:getInstance():sender11061(hero_data.rid, hero_data.srv_id, hero_data.partner_id)
		else
			message(TI18N("该宝可梦来自异域，无法查看"))
		end
	elseif hero_data.flag == 1 and hero_data.partner_id then -- 我方雇佣宝可梦
		PlanesController:getInstance():sender23116(hero_data.partner_id)
	else -- 我自己的宝可梦
		HeroController:getInstance():openHeroTipsPanel(true, hero_data)
	end
end

function PlanesMasterWindow:close_callback( )
	if self.left_role_head then
		self.left_role_head:DeleteMe()
		self.left_role_head = nil
	end
	if self.right_role_head then
		self.right_role_head:DeleteMe()
		self.right_role_head = nil
	end
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	for k,item in pairs(self.award_item_list) do
		item:DeleteMe()
		item = nil
	end
	for k,item in pairs(self.right_item_list) do
		item:DeleteMe()
		item = nil
	end
	for k,item in pairs(self.left_item_list) do
		item:DeleteMe()
		item = nil
	end
	for k,item in pairs(self.left_elfin_item_list) do
		item:DeleteMe()
		item = nil
	end
	for k,item in pairs(self.right_elfin_item_list) do
		item:DeleteMe()
		item = nil
	end
	_controller:openPlanesMasterWindow(false)
end