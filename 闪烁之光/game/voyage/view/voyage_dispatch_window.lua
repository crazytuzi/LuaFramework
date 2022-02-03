--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-12-06 19:57:29
-- @description    : 
		-- 远航派遣界面
---------------------------------
VoyageDispatchWindow = VoyageDispatchWindow or BaseClass(BaseView)

local controller = VoyageController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local table_remove = table.remove

function VoyageDispatchWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "voyage/voyage_order_info"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("voyage", "voyage"), type = ResourcesType.plist},
	}

	self.role_vo = RoleController:getInstance():getRoleVo()
	self.camp_btns = {}
	self.cur_camp = HeroConst.CampType.eNone
	self.need_hero_num = 0  -- 可选英雄最大数
	self.chose_heros = {}   -- 选中的英雄列表
	self.hero_boxs = {} 	-- 英雄头像框(最大英雄数量)
	self.hero_icons = {} 	-- 选中的英雄头像
	self.camp_icons = {} 	-- 阵营条件图标
	self.conditions = {} 	-- 条件
	self.con_status = false -- 条件满足状态
	self.con_tips = TI18N("不满足派遣条件") -- 派遣提示
end

function VoyageDispatchWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
	self:playEnterAnimatianByObj(main_container, 1)
	local win_title = main_container:getChildByName("win_title")
	win_title:setString(TI18N("任务详情"))

	local camp_node = main_container:getChildByName("camp_node")
	self.img_select = camp_node:getChildByName("img_select")
	for i=0,5 do
		local camp_btn = camp_node:getChildByName("camp_btn" .. i)
		self.camp_btns[i] = camp_btn
		if i == 0 then -- 默认选中全部阵营
			local pos_x, pos_y = camp_btn:getPosition()
			self.img_select:setPosition(cc.p(pos_x, pos_y))
		end
	end

	self.no_hero_image = main_container:getChildByName("no_hero_image")
	self.no_hero_image:getChildByName("label"):setString(TI18N("暂无该阵营英雄"))
	-- local exit_tips_label = main_container:getChildByName("exit_tips_label")
	-- exit_tips_label:setString(TI18N("点击空白区域关闭窗口"))

	self.quick_btn = main_container:getChildByName("quick_btn")
	self.quick_btn:getChildByName("label"):setString(TI18N("一键调遣"))
	self.dispatch_btn = main_container:getChildByName("dispatch_btn")
	self.dispatch_btn:getChildByName("label"):setString(TI18N("派出"))

	local num_bg_1 = main_container:getChildByName("num_bg_1")
	self.item_num_label = num_bg_1:getChildByName("item_num_label")
	local num_bg_2 = main_container:getChildByName("num_bg_2")
	self.time_label = num_bg_2:getChildByName("time_label")

	self.status_label = main_container:getChildByName("status_label")
	self.status_label:setString(TI18N("达成条件"))

	-- 条件满足图标
	self.condition_layout = main_container:getChildByName("condition_layout")
	-- 选择的英雄
	self.hero_layout = main_container:getChildByName("hero_layout")

	local lay_scrollview = main_container:getChildByName("lay_scrollview")
	local bg_size = lay_scrollview:getContentSize()
	local scroll_view_size = cc.size(bg_size.width-20, bg_size.height-20)
    local setting = {
        item_class = HeroExhibitionItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 22,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 17,                   -- y方向的间隔
        item_width = HeroExhibitionItem.Width*0.9,               -- 单元的尺寸width
        item_height = HeroExhibitionItem.Height*0.9,              -- 单元的尺寸height
        scale = 0.9,
        col = 5,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.hero_scrollview = CommonScrollViewLayout.new(lay_scrollview, cc.p(10, 10) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function VoyageDispatchWindow:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.quick_btn, handler(self, self._onClickQuickChoseBtn), true)
	registerButtonEventListener(self.dispatch_btn, handler(self, self._onClickDispatchBtn), true)
	for index=0,5 do
		local btn = self.camp_btns[index]
		registerButtonEventListener(btn, handler(self, self._onClickCampBtn), true, nil, index)
	end

	-- 情报值更新
	if self.role_assets_event == nil then
        if self.role_vo == nil then self.role_vo = RoleController:getInstance():getRoleVo() end
        self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key == "energy" then
                self:refreshItemNum()
            end
        end)
    end

    -- 消耗情报值变化（活动期间）
    self:addGlobalEvent(VoyageEvent.UpdateActivityStatusEvent, function (  )
    	self:refreshItemNum()
    end)
end

function VoyageDispatchWindow:openRootWnd( data )
	self:refreshCampHeroList()
	self:showBaseInfo(data)
end

-- 刷新英雄列表
function VoyageDispatchWindow:refreshCampHeroList(  )
	local hero_array = Array.New()
	local all_hero_array = HeroController:getInstance():getModel():getAllHeroArray()
	for i=1,all_hero_array:GetSize() do
        local hero_vo = all_hero_array:Get(i-1)
        if self.cur_camp == HeroConst.CampType.eNone or (self.cur_camp == hero_vo.camp_type) then
            -- 避免每次切换阵营都走这个循环判断是否在任务中
            if hero_vo.in_task == nil then
            	hero_vo.in_task = model:checkHeroIsInTaskById(hero_vo.partner_id)
            end
            hero_array:PushBack(hero_vo)
        end
    end

    local hero_num = hero_array:GetSize()
    if hero_num <= 0 then
    	self.no_hero_image:setVisible(true)
    	self.hero_scrollview:setData({})
    	return
    else
    	self.no_hero_image:setVisible(false)
    end
    local hero_list = hero_array.items
    local function sortFunc( objA, objB )
    	if objA.in_task and not objB.in_task then
    		return false
    	elseif not objA.in_task and objB.in_task then
    		return true
    	else
    		if objA.camp_type ~= objB.camp_type then
    			return objA.camp_type < objB.camp_type
    		else
    			if objA.star ~= objB.star then
    				return objA.star > objB.star
    			else
    				return objA.lev > objB.lev
    			end
    		end
    	end
    end
    table_sort(hero_list, sortFunc)
    local extendData = {scale = 0.9, can_click = true, click_delay = 0.5, from_type = HeroConst.ExhibitionItemType.eVoyage}
    self.hero_scrollview:setData(hero_list, function(item, hero_vo) self:_onClickHero(item ,hero_vo) end, nil, extendData)
end

-- 刷新情报值
function VoyageDispatchWindow:refreshItemNum(  )
	if self.role_vo and self.config then
		local cur_energy = self.role_vo.energy
		local need_energy = 0
		if self.config.expend[1] then
			need_energy = self.config.expend[1][2] or 0
			if model:getActivityStatus() == 1 then
				local discount_cfg = Config.ShippingData.data_const["discount"]
				if discount_cfg then
					need_energy = need_energy * discount_cfg.val/1000
				end
			end
		end
		self.item_num_label:setString(cur_energy.."/"..need_energy)
	end
end

-- 基础信息显示
function VoyageDispatchWindow:showBaseInfo( data )
	self.data = data or {}
	local config = self.data.config or {}
	self.config = config
	-- 情报值
	self:refreshItemNum()
	-- 时间
	self.time_label:setString(TimeTool.GetTimeFormat(config.need_time))
	-- 需要英雄数量的头像框
	for k,v in pairs(self.hero_boxs or {}) do
		v:setVisible(false)
	end
	local limit_num = config.limit_num
	self.need_hero_num = limit_num
	local box_pos = VoyageConst.Chose_Hero_PosX[limit_num]
	for i=1,limit_num do
		local hero_box = self.hero_boxs[i]
		if hero_box == nil then
			hero_box = createImage(self.hero_layout, PathTool.getResFrame("common", "common_1005"), 0, 0, cc.p(0.5, 0.5), true)
			hero_box:setScale(0.9)
			self.hero_boxs[i] = hero_box
		end
		hero_box:setVisible(true)
		local pos_x = box_pos[i]
		if pos_x then
			hero_box:setPosition(cc.p(pos_x, 54))
		end
	end
	-- 条件图标
	self:initConditionData()
	local temp_icons = {}
	local need_star = 0
	local star_num = 1
	local need_camps = {}
	for k,v in pairs(self.conditions or {}) do
		if v.star_num then
			need_star = v.need_num
			star_num = v.star_num
		elseif v.camp_type then
			table_insert(need_camps, v.camp_type)
		end
	end
	if need_star > 0 then
		self.star_icon = createImage(self.condition_layout, PathTool.getResFrame("voyage", "voyage_1009"), 0, 0, cc.p(0.5, 0.5), true)
		local star_text = createLabel(22,1,cc.c3b(132,65,0),22,23,star_num,self.star_icon,nil,cc.p(0.5, 0.5))
		self.star_icon:setTouchEnabled(true)
		registerButtonEventListener(self.star_icon, function (  )
			message(string.format(TI18N("需要一个%d星英雄"), star_num))
		end, false)
		setChildUnEnabled(true, self.star_icon)
		table_insert(temp_icons, self.star_icon)
	end
	for k,v in pairs(self.camp_icons or {}) do
		v:setVisible(false)
	end
	for i,camp_type in ipairs(need_camps) do
		local camp_icon = self.camp_icons[i]
		if camp_icon == nil then
			camp_icon = createImage(self.condition_layout, PathTool.getHeroCampTypeIcon(camp_type), 0, 0, cc.p(0.5, 0.5), true)
			camp_icon:setScale(0.8)
			camp_icon:setTouchEnabled(true)
			registerButtonEventListener(camp_icon, function (  )
				message(string.format(TI18N("需要一个%s英雄"), HeroConst.CampAttrName[camp_type]))
			end, false)
			setChildUnEnabled(true, camp_icon)
			self.camp_icons[i] = camp_icon
		end
		camp_icon.camp_type = camp_type
		camp_icon:setVisible(true)
		table_insert(temp_icons, camp_icon)
	end
	local icon_pos = VoyageConst.Condition_Icon_PosX[#temp_icons]
	for i,icon in ipairs(temp_icons) do
		local pos_x = icon_pos[i]
		if pos_x then
			icon:setPosition(cc.p(pos_x, 0))
		end
	end
end

-- 根据阵营类型获取阵营图标
function VoyageDispatchWindow:getCampIconByCampType( camp_type )
	for k,camp_icon in pairs(self.camp_icons or {}) do
		if camp_icon.camp_type == camp_type then
			return camp_icon
		end
	end
end

-- 初始化派遣条件
function VoyageDispatchWindow:initConditionData(  )
	self.conditions = {}
	if self.config then
		local conditions = self.config.condition or {}
		for k,con_id in pairs(conditions or {}) do
			local con_config = Config.ShippingData.data_condition[con_id] or {}
			local conition = con_config.conition or {}
			if conition[1] then
				local con_data = {}
				if conition[1][1] == "partner_star" then
					con_data.star_num = conition[1][2] -- 星数要求
					con_data.need_num = conition[1][3]
				elseif conition[1][1] == "partner_camp_type" then
					con_data.camp_type = conition[1][2] -- 阵营要求
					con_data.need_num = conition[1][3]
				end
				if next(con_data) ~= nil then
					table_insert(self.conditions, con_data)
				end
			end
		end
	end
end

-- 刷新条件满足状态
function VoyageDispatchWindow:refreshConditionStatus(  )
	self.con_status = true
	for k,v in pairs(self.conditions or {}) do
		local is_meet = false
		if v.star_num then
			is_meet = self:checkIsMeetCondition(1, v.star_num, v.need_num)
			setChildUnEnabled(not is_meet, self.star_icon)
		elseif v.camp_type then
			is_meet = self:checkIsMeetCondition(2, v.camp_type, v.need_num)
			local camp_icon = self:getCampIconByCampType(v.camp_type)
			setChildUnEnabled(not is_meet, camp_icon)
		end
		if is_meet == false and self.con_status then
			if v.star_num then
				self.con_tips = string.format(TI18N("需要一个%d星英雄"), v.star_num)
			elseif v.camp_type then
				self.con_tips = string.format(TI18N("需要一个%s系英雄"), HeroConst.CampName[v.camp_type])
			end
			self.con_status = false
		end
	end
	if self.con_status then
		self.status_label:setTextColor(cc.c3b(36,144,3))
	else
		self.status_label:setTextColor(cc.c3b(201,38,6))
	end
end

-- 判断所选英雄是否满足该条件 ttype:1星级 2阵营
function VoyageDispatchWindow:checkIsMeetCondition( ttype, value, num )
	local have_num = 0
	for k,hero_vo in pairs(self.chose_heros or {}) do
		if ttype == 1 and hero_vo.star >= value then
			have_num = have_num + 1
		elseif ttype == 2 and hero_vo.camp_type == value then
			have_num = have_num + 1
		end
	end
	return (have_num>=num)
end

-- 判断当前所选的英雄是否满足所有条件
function VoyageDispatchWindow:checkIsMeetAllCondition(  )
	local con_status = true
	for k,v in pairs(self.conditions or {}) do
		local is_meet = false
		if v.star_num then
			is_meet = self:checkIsMeetCondition(1, v.star_num, v.need_num)
		elseif v.camp_type then
			is_meet = self:checkIsMeetCondition(2, v.camp_type, v.need_num)
		end
		if is_meet == false then
			con_status = false
			break
		end
	end
	return con_status
end

function VoyageDispatchWindow:_onClickHero( item, hero_vo )
	if hero_vo.in_task then return end
	
	if hero_vo.is_ui_select then
		for k,hero_icon in pairs(self.hero_icons or {}) do
			local data = hero_icon:getData()
			if data.partner_id == hero_vo.partner_id then
				local hero_box = hero_icon:getParent()
				local world_pos = item:convertToWorldSpace(cc.p(0, 0))
				local node_pos = hero_box:convertToNodeSpace(world_pos)
				local move_act = cc.MoveTo:create(0.07, cc.p(node_pos.x+59.5, node_pos.y+59.5))
				local function callback(  )
					self:checkDeleteSameHeroIcon(hero_vo.partner_id)
				end
				hero_icon:runAction(cc.Sequence:create(move_act, cc.CallFunc:create(callback)))
				break
			end
		end
		hero_vo.is_ui_select = false
		item:setSelected(false)
		self:updateChoseHeroList(hero_vo, 2)
	else
		-- 判断当前是否还有空位
		if self.need_hero_num <= #self.chose_heros then
			message(TI18N("已达英雄数量上限"))
			return
		end
		self:createChoseHeroIcon(hero_vo, item)

		hero_vo.is_ui_select = true
		item:setSelected(true)
		self:updateChoseHeroList(hero_vo, 1)
	end
	self:refreshConditionStatus()
end

-- 创建一个选中的英雄图标
function VoyageDispatchWindow:createChoseHeroIcon( hero_vo, item )
	self:checkDeleteSameHeroIcon(hero_vo.partner_id)
	local hero_icon = HeroExhibitionItem.new(1, true, 0.5)
	hero_icon:setData(hero_vo)
	hero_icon:addCallBack(function (  )
		local vo = hero_icon:getData()
		local list = self.hero_scrollview:getItemList()
		local item_node
		-- 当英雄列表滑动了，对应的英雄item可能已经不存在
        for k,v in pairs(list or {}) do
            local h_vo = v:getData()
            if h_vo.partner_id == vo.partner_id then
            	item_node = v
            end
        end
        if item_node then
        	self:_onClickHero(item_node, item_node:getData())
        else
        	for k,icon in pairs(self.hero_icons or {}) do
				local data = icon:getData()
				if data.partner_id == vo.partner_id then
					local box = icon:getParent()
					icon:stopAllActions()
					icon:DeleteMe()
					table_remove(self.hero_icons, k)
					break
				end
			end
			vo.is_ui_select = false
			self:updateChoseHeroList(vo, 2)
			self:refreshConditionStatus()
        end
	end)
	local hero_box = self:getMastLeftEmptyBox()
	if hero_box then
		hero_icon:setName("hero_icon")
		hero_box:addChild(hero_icon)
		table_insert(self.hero_icons, hero_icon)
		if item then
			local world_pos = item:convertToWorldSpace(cc.p(0, 0))
			local node_pos = hero_box:convertToNodeSpace(world_pos)
			hero_icon:setPosition(cc.p(node_pos.x+59.5, node_pos.y+59.5))
			hero_icon:runAction(cc.MoveTo:create(0.07, cc.p(59.5, 59.5)))
		else
			hero_icon:setPosition(cc.p(59.5, 59.5))
		end
	end
end

-- 删除已经创建的一致的头像(点太快可能会出现)
function VoyageDispatchWindow:checkDeleteSameHeroIcon( id )
	for k,hero_icon in pairs(self.hero_icons or {}) do
		local data = hero_icon:getData()
		if data.partner_id == id then
			hero_icon:stopAllActions()
			hero_icon:DeleteMe()
			table_remove(self.hero_icons, k)
			break
		end
	end
end

-- 获取最靠前的一个空的头像box
function VoyageDispatchWindow:getMastLeftEmptyBox(  )
	local hero_box
	for i,box in ipairs(self.hero_boxs) do
		if not box:getChildByName("hero_icon") then
			hero_box = box
			break
		end
	end
	return hero_box
end

-- 更新选中的英雄列表 ttype:1为增 2为减
function VoyageDispatchWindow:updateChoseHeroList( hero_vo, ttype )
	if ttype == 1 then
		table_insert(self.chose_heros, hero_vo)
	elseif ttype == 2 then
		for k,v in pairs(self.chose_heros or {}) do
			if v.partner_id == hero_vo.partner_id then
				table_remove(self.chose_heros, k)
				break
			end
		end
	end
end

function VoyageDispatchWindow:_onClickCampBtn( index, sender )
	if self.cur_camp == index then return end

	self.cur_camp = index
	local pos_x, pos_y = sender:getPosition()
	self.img_select:setPosition(cc.p(pos_x, pos_y))

	self:refreshCampHeroList()
end

-- 一键出战
function VoyageDispatchWindow:_onClickQuickChoseBtn(  )
	-- 先清掉所有选择的数据
	for k,v in pairs(self.hero_icons or {}) do
    	v:stopAllActions()
    	v:DeleteMe()
    end
    self.hero_icons = {}
	for k,vo in pairs(self.chose_heros or {}) do
		vo.is_ui_select = false
	end
	self.chose_heros = {}
	local item_list = self.hero_scrollview:getItemList()
    for k,item in pairs(item_list or {}) do
        item:setSelected(false)
    end

	local all_hero = HeroController:getInstance():getModel():getHeroList()

	local star_num = 0
	local star_need = 0
	local need_camps = {}
	for k,con_data in pairs(self.conditions or {}) do
		if con_data.star_num then
			star_num = con_data.star_num
			star_need = con_data.need_num
		elseif con_data.camp_type then
			need_camps[con_data.camp_type] = con_data.need_num
		end
	end

	local star_hero = {} 		-- 满足星级条件的英雄
	local all_camp_hero = {} 	-- 满足阵营条件的英雄
	local both_hero = {} 		-- 同时满足星级和阵营的英雄
	for k,hero_vo in pairs(all_hero or {}) do
		local star_is_meet = false
		if hero_vo.star >= star_num and not model:checkHeroIsInTaskById(hero_vo.partner_id) then
			star_is_meet = true
			table_insert(star_hero, hero_vo)
		end
		for _,con_data in pairs(self.conditions or {}) do
			if con_data.camp_type and con_data.camp_type == hero_vo.camp_type and not model:checkHeroIsInTaskById(hero_vo.partner_id) then
				if not all_camp_hero[con_data.camp_type] then
					all_camp_hero[con_data.camp_type] = {}
				end
				table_insert(all_camp_hero[con_data.camp_type], hero_vo)
				if star_is_meet then
					table_insert(both_hero, hero_vo)
				end
			end
		end
	end
	local function sortFunc( objA, objB )
		if objA.star ~= objB.star then
			return objA.star < objB.star
		else
			if objA.lev ~= objB.lev then
				return objA.lev < objB.lev
			else
				return objA.camp_type < objB.camp_type
			end
		end
	end
	-- 按星级、等级、阵营从低到高排列
	table_sort(star_hero, sortFunc)
	table_sort(both_hero, sortFunc)
	for k,hero_list in pairs(all_camp_hero or {}) do
		table_sort(hero_list, sortFunc)
	end

	for i,hero_vo in ipairs(both_hero) do
		if #self.chose_heros < star_need then
			table_insert(self.chose_heros, hero_vo)
		elseif self:checkIsMeetAllCondition() then
			for camp,need_num in pairs(need_camps or {}) do
				if hero_vo.camp_type == camp and self:checkChoseHeroNumByCamp(camp) < need_num then
					table_insert(self.chose_heros, hero_vo)
				end
			end
		else
			break
		end
	end

	if self:checkIsMeetAllCondition() then
		self:afterQuickChoseHero()
		return
	end

	local star_dif_num = star_need - #self.chose_heros -- 满足星级条件的英雄，还差的个数
	if star_dif_num > 0 then
		local temp_num = 0
		for i,vo in ipairs(star_hero) do
			if not self:checkIsChoseHeroById(vo.partner_id) then
				table_insert(self.chose_heros, vo)
				temp_num = temp_num + 1
			end
			if temp_num >= star_dif_num then
				break
			end
		end
	end

	-- 满足条件或者星级条件都无法满足，则无需选择其他英雄
	if self:checkIsMeetAllCondition() then
		self:afterQuickChoseHero()
		return
	end

	for camp_type,hero_list in pairs(all_camp_hero or {}) do
		local need_num = need_camps[camp_type]
		local cur_num = self:checkChoseHeroNumByCamp(camp_type)
		local diff_num = need_num-cur_num
		if diff_num > 0 then
			local temp_num = 0
			for i,vo in ipairs(hero_list) do
				if not self:checkIsChoseHeroById(vo.partner_id) then
					table_insert(self.chose_heros, vo)
					temp_num = temp_num + 1
				end
				if temp_num >= diff_num then
					break
				end
			end
		end
	end
	self:afterQuickChoseHero()
end

function VoyageDispatchWindow:checkIsChoseHeroById( id )
	local is_have = false
	for k,v in pairs(self.chose_heros or {}) do
		if v.partner_id == id then
			is_have = true
			break
		end
	end
	return is_have
end

function VoyageDispatchWindow:checkChoseHeroNumByCamp( camp_type )
	local have_num = 0
	for k,v in pairs(self.chose_heros or {}) do
		if v.camp_type == camp_type then
			have_num = have_num + 1
		end
	end
	return have_num
end

-- 一键出战选择合适英雄之后界面刷新
function VoyageDispatchWindow:afterQuickChoseHero(  )
	for i,hero_vo in ipairs(self.chose_heros) do
		hero_vo.is_ui_select = true
		local item_list = self.hero_scrollview:getItemList()
	    for k,item in pairs(item_list or {}) do
	        local item_data = item:getData()
	        if item_data.partner_id == hero_vo.partner_id then
	        	item:setSelected(true)
	        end
	    end
		self:createChoseHeroIcon(hero_vo)
	end
	self:refreshConditionStatus()
end

-- 派遣
function VoyageDispatchWindow:_onClickDispatchBtn(  )
	if self.con_status == true then
		local assign_ids = {}
		for k,v in pairs(self.chose_heros or {}) do
			local assign = {}
			assign.partner_id = v.partner_id
			table_insert(assign_ids, assign)
		end
		if self.data then
			controller:requestReceiveOrder(self.data.order_id, assign_ids)
		end
	else
		self.con_tips = self.con_tips or TI18N("不满足派遣条件")
		message(self.con_tips)
	end
end

function VoyageDispatchWindow:_onClickCloseBtn(  )
	controller:openVoyageDispatchWindow(false)
end

function VoyageDispatchWindow:close_callback(  )
	if self.hero_scrollview then
		self.hero_scrollview:DeleteMe()
		self.hero_scrollview = nil
	end
	--清空选中状态
    local hero_list = HeroController:getInstance():getModel():getHeroList()
    for k, hero_vo in pairs(hero_list or {}) do
        hero_vo.is_ui_select = nil
        hero_vo.in_task = nil
    end
    if self.role_assets_event then
        if self.role_vo then
            self.role_vo:UnBind(self.role_assets_event)
        end
        self.role_assets_event = nil
        self.role_vo = nil
    end
    for k,v in pairs(self.hero_icons or {}) do
    	v:stopAllActions()
    	v:DeleteMe()
    end
	controller:openVoyageDispatchWindow(false)
end