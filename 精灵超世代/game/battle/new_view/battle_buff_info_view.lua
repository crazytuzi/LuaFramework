--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-02-14 15:43:08
-- @description    : 
		-- buff总览
---------------------------------
BattleBuffInfoView = BattleBuffInfoView or BaseClass(BaseView)

local _controller = BattleController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

local Dir_Type = {
	Left = 1,  -- 左边宝可梦
	Right = 2  -- 右边宝可梦
}

function BattleBuffInfoView:__init( )
	self.win_type = WinType.Mini
	self.layout_name = "battle/battle_buff_info_view"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false

	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("battleharm", "battleharm"), type = ResourcesType.plist },
		{ path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
	}

	self.left_item_list = {}
	self.right_item_list = {}
end

function BattleBuffInfoView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

    self.left_name_label = container:getChildByName("left_name_label")
    self.right_name_label = container:getChildByName("right_name_label")
    self.left_role_panel = container:getChildByName("left_role_panel")
    self.right_role_panel = container:getChildByName("right_role_panel")

    self.close_btn = container:getChildByName("close_btn")
    local close_btn_label = self.close_btn:getChildByName("label")
    close_btn_label:setString(TI18N("确  定"))
    
    local title_label = container:getChildByName("title_label")
    title_label:setString(TI18N("BUFF总览"))
end

function BattleBuffInfoView:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)

	-- 每回合更新一次
	self:addGlobalEvent(BattleEvent.UPDATE_ROUND_NUM, function (  )
		self:setData()
	end)
end

function BattleBuffInfoView:_onClickCloseBtn(  )
	_controller:openBattleBuffInfoView(false)
end

function BattleBuffInfoView:openRootWnd( left_name, right_name )
	self.left_name = left_name or ""
	self.right_name = right_name or ""
	self:setData(true)
end

function BattleBuffInfoView:setData( is_init )
	local all_object = _controller:getModel():getAllObject()
	if not all_object or next(all_object) == nil then return end

	-- 取出左右两侧数据
	local left_data = {}
	local right_data = {}

	for k,bRole in pairs(all_object) do
		-- 筛选掉神器
		if bRole.object_type == BattleObjectType.Pet or bRole.object_type == BattleObjectType.Unit then
			if bRole.group == 1 then
				_table_insert(left_data, bRole)
			elseif bRole.group == 2 then
				_table_insert(right_data, bRole)
			end
		end
	end

	local start_y = self.left_role_panel:getContentSize().height

	-- 左侧
	self.left_name_label:setString(self.left_name)
	for k,item in pairs(self.left_item_list) do
		item:setVisible(false)
	end
	for i,l_data in ipairs(left_data) do
		if is_init then
			delayRun(
	            self.left_role_panel, i*4 / display.DEFAULT_FPS, function()
	                local role_item = self.left_item_list[i]
					if role_item == nil then
						role_item = BattleBuffInfoItem.new(Dir_Type.Left)
						self.left_item_list[i] = role_item
						self.left_role_panel:addChild(role_item)
					end
					role_item:setVisible(true)
					local item_size = role_item:getContentSize()
					role_item:setPosition(cc.p(0, start_y-(i-1)*(item_size.height)))
					role_item:setData(l_data)
	            end
	        )
		else
			local role_item = self.left_item_list[i]
			if role_item == nil then
				role_item = BattleBuffInfoItem.new(Dir_Type.Left)
				self.left_item_list[i] = role_item
				self.left_role_panel:addChild(role_item)
			end
			role_item:setVisible(true)
			local item_size = role_item:getContentSize()
			role_item:setPosition(cc.p(0, start_y-(i-1)*(item_size.height)))
			role_item:setData(l_data)
		end
	end

	-- 右侧
	self.right_name_label:setString(self.right_name)
	for k,item in pairs(self.right_item_list) do
		item:setVisible(false)
	end
	for i,r_data in ipairs(right_data) do
		if is_init then
			delayRun(
	            self.right_role_panel, i*4 / display.DEFAULT_FPS, function()
	                local role_item = self.right_item_list[i]
					if role_item == nil then
						role_item = BattleBuffInfoItem.new(Dir_Type.Right)
						self.right_item_list[i] = role_item
						self.right_role_panel:addChild(role_item)
					end
					role_item:setVisible(true)
					local item_size = role_item:getContentSize()
					role_item:setPosition(cc.p(0, start_y-(i-1)*(item_size.height)))
					role_item:setData(r_data)
	            end
	        )
		else
			local role_item = self.right_item_list[i]
			if role_item == nil then
				role_item = BattleBuffInfoItem.new(Dir_Type.Right)
				self.right_item_list[i] = role_item
				self.right_role_panel:addChild(role_item)
			end
			role_item:setVisible(true)
			local item_size = role_item:getContentSize()
			role_item:setPosition(cc.p(0, start_y-(i-1)*(item_size.height)))
			role_item:setData(r_data)
		end
	end
end

function BattleBuffInfoView:close_callback(  )
	self.left_role_panel:stopAllActions()
	for k,v in pairs(self.left_item_list) do
		v:DeleteMe()
		v = nil
	end
	self.right_role_panel:stopAllActions()
	for k,v in pairs(self.right_item_list) do
		v:DeleteMe()
		v = nil
	end
	_controller:openBattleBuffInfoView(false)
end

-------------------------@ item
BattleBuffInfoItem = class("BattleBuffInfoItem", function()
    return ccui.Widget:create()
end)

function BattleBuffInfoItem:ctor(dir)
	self.role_dir = dir or Dir_Type.Left

	self.buff_list_item = {}

	self:configUI()
	self:register_event()
end

function BattleBuffInfoItem:configUI(  )
	self.size = cc.size(300,99)
	self:setTouchEnabled(false)
	self:setAnchorPoint(cc.p(0, 1))
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("battle/battle_buff_info_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.touch_layout = container:getChildByName("touch_layout")
    self.arrow_sp = container:getChildByName("Sprite_1")

    self.hero_head = HeroExhibitionItem.new(0.7, true)
    self.hero_head:addCallBack(handler(self, self._onClickHeroCallBack))
    container:addChild(self.hero_head)

    if self.role_dir == Dir_Type.Left then
    	self.hero_head:setPosition(cc.p(50, self.size.height/2))
    	self.touch_layout:setPosition(cc.p(self.size.width, 0))
    	self.arrow_sp:setPosition(cc.p(282, 15))
    	self.arrow_sp:setScaleX(1)
    else
    	self.hero_head:setPosition(cc.p(self.size.width - 50, self.size.height/2))
    	self.touch_layout:setPosition(cc.p(self.size.width - self.hero_head:getContentSize().width*0.7 - 18, 0))
    	self.arrow_sp:setPosition(cc.p(18, 15))
    	self.arrow_sp:setScaleX(-1)
    end
end

function BattleBuffInfoItem:_onClickHeroCallBack(  )
	if self.data and self.data.owner_id ~= 0 and self.data.owner_srv_id ~= "" and self.data.object_id then
		local role_vo = RoleController:getInstance():getRoleVo()
		if role_vo.rid == self.data.owner_id and role_vo.srv_id == self.data.owner_srv_id then
			local hero_vo = HeroController:getInstance():getModel():getHeroById(self.data.object_id)
			if hero_vo and next(hero_vo) ~= nil then
				HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
			else
				message(TI18N("该宝可梦来自异域，无法查看"))
			end
		else
			if self.data.owner_srv_id == "robot" then
				message(TI18N("该宝可梦来自异域，无法查看"))
			else
				LookController:getInstance():sender11061(self.data.owner_id, self.data.owner_srv_id, self.data.object_id)
			end
		end
	else
		message(TI18N("该宝可梦来自异域，无法查看"))
	end
end

function BattleBuffInfoItem:register_event(  )
	registerButtonEventListener(self.touch_layout, function (  )
		if self.buff_list_data and next(self.buff_list_data) ~= nil then
			_controller:openBattleBuffListView(true, self.buff_list_data, self.data.group, self.data.object_bid)
		end
	end)
end

function BattleBuffInfoItem:setData( data )
	self.data = data or {}
	-- 头像
	local hero_vo = HeroVo.New()
	if Config.PartnerData.data_partner_base[data.object_bid] then
		hero_vo.bid = data.object_bid
		hero_vo.star = data.star
	else
		local unit_config = Config.UnitData.data_unit(data.object_bid)
		if unit_config then
			hero_vo.bid = tonumber(unit_config.head_icon)
			if unit_config.star and unit_config.star > 0 then
				hero_vo.star = unit_config.star
			else
				local base_config = Config.PartnerData.data_partner_base[hero_vo.bid]
				if base_config then
					hero_vo.star = base_config.init_star
				end
			end
			hero_vo.master_head_id = hero_vo.bid
		end
	end
	hero_vo.camp_type = data.camp_type
	hero_vo.lev = data.lev
	hero_vo.use_skin = data.fashion
	hero_vo.resonate_lev = data.crystal
	
	self.hero_head:setData(hero_vo)
	if data.hp > 0 then
		self.hero_head:showStrTips(false)
    else
        self.hero_head:showStrTips(true,TI18N("已阵亡"),{c3b = cc.c3b(255,255,255)})
    end

    -- buff 图标
    local temp_list = {}
    local temp_group_list = {}
    for i,v in pairs(data.buff_list) do
    	local buff_config = Config.SkillData.data_get_buff[v.bid]
		local res_id = buff_config.icon
		-- 根据配置表判断一下，如果角色死亡，buff是否为需要清除的
		if res_id ~= nil and res_id ~= 0 and (self.data.hp > 0 or (buff_config.clean_when_dead and buff_config.clean_when_dead == "false")) then
			if temp_list[res_id] == nil then
				temp_list[res_id] = {res_id=res_id, num=0, name=buff_config.name, remain_round=v.remain_round, desc=buff_config.desc, buff_infos = {}}
			end
			if temp_list[res_id].num == 0 or (buff_config.join_type and buff_config.join_type ~= 3) then
				temp_list[res_id].num = temp_list[res_id].num + 1
				_table_insert(temp_list[res_id].buff_infos, {buff_id=v.bid, remain_round=v.remain_round, group = buff_config.group, group_pro=buff_config.group_pro})
				if buff_config.group then
					temp_group_list[buff_config.group] = true
				end
			elseif buff_config.join_type and buff_config.join_type == 3 and buff_config.group then -- 类型为覆盖共存
				if temp_group_list[buff_config.group] then
					-- 该组已有buff，则取该组中权重最高的显示，权重一样，则取id小的显示
					for _,b_info in pairs(temp_list[res_id].buff_infos or {}) do
						if b_info.group == buff_config.group then
							if b_info.group_pro < buff_config.group_pro or (b_info.group_pro == buff_config.group_pro and b_info.buff_id > v.bid) then
								b_info.buff_id = v.bid
								b_info.remain_round = v.remain_round
								b_info.group_pro = buff_config.group_pro
							end
							break
						end
					end
				else
					-- 该组还没有buff，直接添加
					temp_group_list[buff_config.group] = true
					temp_list[res_id].num = temp_list[res_id].num + 1
					_table_insert(temp_list[res_id].buff_infos, {buff_id=v.bid, remain_round=v.remain_round, group = buff_config.group, group_pro=buff_config.group_pro})
				end
			end
		end
	end
	self.buff_list_data = {}
	for k,v in pairs(temp_list) do
		_table_insert(self.buff_list_data, v)
	end
	table.sort(self.buff_list_data,function(a,b)
		return  a.res_id < b.res_id
	end)
	-- 更新一次buff列表界面的数据
	_controller:updateBattleBuffListView(self.buff_list_data, self.data.group, self.data.object_bid)

	for k,buff_object in pairs(self.buff_list_item) do
		if buff_object.icon then
			buff_object.icon:setVisible(false)
		end
	end

	local start_x = 110
	local start_y = 85
	if self.role_dir == Dir_Type.Right then
		start_x = self.size.width - start_x
	end
	local space_x = 5
	local space_y = 5
	local buff_icon_size = cc.size(33, 32)
	for i,bData in ipairs(self.buff_list_data) do
		if i <= 8 then -- 最多显示8个
			local buff_object = self.buff_list_item[i]
			if buff_object == nil then
				buff_object = self:createBuffItem()
				self.buff_list_item[i] = buff_object
			end
			buff_object.icon:setVisible(true)
			buff_object.label:setString(bData.num)

			-- 位置
			local row = math.ceil(i/4)
			local index = i%4
			if index == 0 then index = 4 end

			local pos_x = start_x + (index-1)*(buff_icon_size.width+space_x) + buff_icon_size.width/2
			if self.role_dir == Dir_Type.Right then
				pos_x = start_x - (index-1)*(buff_icon_size.width+space_x) - buff_icon_size.width/2
			end
			local pos_y = start_y - (row -1)*(buff_icon_size.height+space_x) - buff_icon_size.height/2
			buff_object.icon:setPosition(cc.p(pos_x, pos_y))

			local buff_icon_id = bData.res_id
			local buff_path = PathTool.getBigBuffRes(buff_icon_id)
			if buff_object.path ~= buff_path then
				buff_object.path = buff_path 
				loadSpriteTexture(buff_object.icon, buff_path, LOADTEXT_TYPE)
			end
		end
	end
end

function BattleBuffInfoItem:createBuffItem(  )
	local object = {}
	local icon = createSprite(nil, 0, 0, self.container, cc.p(0.5,0.5), nil, 5) 
	icon:setCascadeOpacityEnabled(true)

	local label = createLabel(14, Config.ColorData.data_color4[1], nil, 30, 0, 0, icon)
	label:setAnchorPoint(1, 0)
	label:enableOutline(Config.ColorData.data_color4[2], 1)
	object.icon = icon
	object.label = label
	object.path = ""
	return object
end

function BattleBuffInfoItem:DeleteMe(  )
	if self.hero_head then
		self.hero_head:DeleteMe()
		self.hero_head = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end