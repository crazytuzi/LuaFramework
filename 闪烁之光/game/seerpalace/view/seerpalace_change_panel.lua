--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-20 22:00:51
-- @description    : 
		-- 先知殿（英雄转换）
---------------------------------
local controller = SeerpalaceController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
local table_sort = table.sort

SeerpalaceChangePanel = class("SeerpalaceChangePanel", function()
    return ccui.Widget:create()
end)

function SeerpalaceChangePanel:ctor(  )
	self.camp_list = {}
	self.cur_role_vo = {}
	self.cur_role_item = nil
	self.cur_camp_type = HeroConst.CampType.eNone
	self.left_stars_1 = {}
	self.left_stars_2 = {}
	self.right_stars_1 = {}
	self.right_stars_2 = {}
	self.is_first_open = true  -- 首次打开界面标识
	self.change_partner_id = 0 -- 有置换结果但未保存的英雄，0为没有
	self.change_new_partner_bid = 0 -- 有置换结果但未保存的新英雄，0为没有
	self.lock_partner_ids = {} -- 锁住不能置换的英雄
	self.cancel_partner_id = 0 -- 缓存取消保存的英雄id，取消之后要依然选中它

	self:configUI()
	self:register_event()
end

function SeerpalaceChangePanel:addToParent( status )
	status = status or false
    self:setVisible(status)
    if self.is_first_open then
  		-- 初次打开界面时请求置换相关数据
    	controller:requestSeerpalaceChangeInfo()
    	self.is_first_open = false
    end
end

function SeerpalaceChangePanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("seerpalace/seerpalace_change_panel"))
	self.root_wnd:setPosition(0,0)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    local main_container = self.root_wnd:getChildByName("main_container")

    self.change_btn = main_container:getChildByName("change_btn")
    self.change_btn:setVisible(false)
    local btn_size = self.change_btn:getContentSize()
    self.change_btn_label = createRichLabel(24, cc.c4b(255,255,255,255), cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.change_btn:addChild(self.change_btn_label)
    self.change_btn_label:setString(TI18N("转换"))

    self.cancel_btn = main_container:getChildByName("cancel_btn")
    local cancel_btn_label = self.cancel_btn:getChildByName("label")
    cancel_btn_label:setString(TI18N("取消"))
    self.cancel_btn:setVisible(false)

    self.save_btn = main_container:getChildByName("save_btn")
    local save_btn_label = self.save_btn:getChildByName("label")
    save_btn_label:setString(TI18N("保存"))
    self.save_btn:setVisible(false)

    self.left_panel = main_container:getChildByName("left_panel")
    self.left_panel:setVisible(false)
    self.left_lv_label = self.left_panel:getChildByName("left_lv_label")

    self.right_panel = main_container:getChildByName("right_panel")
    self.right_panel:setVisible(false)
    self.right_lv_label = self.right_panel:getChildByName("right_lv_label")

    self.left_effect_node = main_container:getChildByName("left_effect_node")
    self.right_effect_node = main_container:getChildByName("right_effect_node")

    self.role_layout = main_container:getChildByName("role_layout")
    for i=1,4 do
    	local camp_btn = self.role_layout:getChildByName("camp_btn_" .. i)
    	if camp_btn then
    		local camp_data = {}
    		camp_data.camp_btn = camp_btn
    		camp_data.select_image = camp_btn:getChildByName("select_image")
    		camp_data.select_image:setVisible(false)
    		self.camp_list[i] = camp_data
    	end
    end

    local bgSize = self.role_layout:getContentSize()
    local scale = 0.9
	local scroll_view_size = cc.size(bgSize.width - 80, 108)
    local setting = {
        item_class = HeroExhibitionItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 119*scale,               -- 单元的尺寸width
        item_height = 119*scale,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    	scale = scale,
    }

    self.role_scrollview = CommonScrollViewLayout.new(self.role_layout, cc.p(40,128) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.role_scrollview:setSwallowTouches(false)
end

function SeerpalaceChangePanel:register_event(  )
	registerButtonEventListener(self.change_btn, handler(self, self._onClickChangeBtn), true)
	registerButtonEventListener(self.cancel_btn, handler(self, self._onClickCancelBtn), true)
	registerButtonEventListener(self.save_btn, handler(self, self._onClickSaveBtn), true)
	registerButtonEventListener(self.left_panel, handler(self, self._onClickLeftHero))
	registerButtonEventListener(self.right_panel, handler(self, self._onClickRightHero))

	for index,object in ipairs(self.camp_list) do
		if object.camp_btn then
			registerButtonEventListener(object.camp_btn, handler(self, self._onClickCampBtn), nil, nil, index)
		end
	end

	if not self.role_change_info_event  then
		self.role_change_info_event = GlobalEvent:getInstance():Bind(SeerpalaceEvent.Change_Role_Info_Event,function (data)
			self:setData(data)
		end)
	end

	if not self.change_success_event then
		self.change_success_event = GlobalEvent:getInstance():Bind(SeerpalaceEvent.Change_Role_Success,function ()
			self:handleRightChangeEffect(true)
		end)
	end
end

-- 置换
function SeerpalaceChangePanel:_onClickChangeBtn(  )
	if self.cur_role_vo and self.cur_role_vo.id then
		controller:requestSeerpalaceChangeRole(self.cur_role_vo.id, 1)
	else
		message(TI18N("请先选择一位英雄"))
	end
end

-- 取消
function SeerpalaceChangePanel:_onClickCancelBtn(  )
	if self.change_partner_id and self.change_partner_id ~= 0 then
		self.cancel_partner_id = self.change_partner_id
		controller:requestSeerpalaceChangeRole(self.change_partner_id, 0)
	end
end

-- 保存
function SeerpalaceChangePanel:_onClickSaveBtn()
	if self.change_partner_id and self.change_partner_id ~= 0 then
		controller:requestSeerpalaceChangeRole(self.change_partner_id, 2)
	end
end

function SeerpalaceChangePanel:_onClickLeftHero(  )
	if self.cur_role_vo and next(self.cur_role_vo) ~= nil then
		HeroController:getInstance():openHeroTipsPanel(true, self.cur_role_vo)
	end
end

function SeerpalaceChangePanel:_onClickRightHero(  )
	if self.change_new_partner_bid then
		--HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
	end
end

function SeerpalaceChangePanel:setData( data )
	self.data = data or {}
	self.change_partner_id = data.partner_id or 0
	self.change_new_partner_bid = data.new_partner_bid or 0
	self.lock_partner_ids = data.partner_ids or {}

	self.role_layout:setVisible(self.change_partner_id == 0)
	self.cancel_btn:setVisible(self.change_partner_id ~= 0)
	self.save_btn:setVisible(self.change_partner_id ~= 0)

	for k,cur_camp_data in pairs(self.camp_list) do
		if cur_camp_data and cur_camp_data.select_image then
			cur_camp_data.select_image:setVisible(false)
		end
	end

	self.cur_role_vo = {}
	if self.change_partner_id == 0 then
		self.cur_index = self.cur_index or 1
		self:_onClickCampBtn(self.cur_index, true)
	else
		self.cur_camp_type = HeroConst.CampType.eNone
		if self.cur_role_item then
			self.cur_role_item:setSelected(false)
			self.cur_role_item = nil
		end
	end

	self:refreshRoleSpine()
end

-- 刷新英雄头像列表
function SeerpalaceChangePanel:refreshRoleList(  )
	self.cur_role_data = {}
	local all_role_list = HeroController:getInstance():getModel():getAllHeroArray()
	local camp_type = HeroConst.CampType.eNone
	if self.cur_index == SeerpalaceConst.Change_Index_Camp.All then
		camp_type = HeroConst.CampType.eNone
	elseif self.cur_index == SeerpalaceConst.Change_Index_Camp.Water then
		camp_type = HeroConst.CampType.eWater
	elseif self.cur_index == SeerpalaceConst.Change_Index_Camp.Fire then
		camp_type = HeroConst.CampType.eFire
	elseif self.cur_index == SeerpalaceConst.Change_Index_Camp.Wind then
		camp_type = HeroConst.CampType.eWind
	end
	self.cur_camp_type = camp_type

	for k,role_vo in pairs(all_role_list.items or {}) do
		if role_vo.star == 4 or role_vo.star == 5 then
			local is_lock = self:checkIsLockedRole(role_vo.id)
			if camp_type == HeroConst.CampType.eNone then
				if role_vo.camp_type == HeroConst.CampType.eWater or 
				   role_vo.camp_type == HeroConst.CampType.eFire or
				   role_vo.camp_type == HeroConst.CampType.eWind then
				   	local role_data = deepCopy(role_vo)
				   	role_data.is_locked = is_lock
				   	table_insert(self.cur_role_data, role_data)
				end
			elseif role_vo.camp_type == camp_type then
				local role_data = deepCopy(role_vo)
				role_data.is_locked = is_lock
				table_insert(self.cur_role_data, role_data)
			end
		end
	end

	local function SortFunc( objA, objB )
		local is_lock_a = self:checkIsLockedRole(objA.id)
		local is_lock_b = self:checkIsLockedRole(objB.id)
		if is_lock_a and not is_lock_b then
			return false
		elseif not is_lock_a and is_lock_b then
			return true
		elseif objA.star == objB.star then
			if objA.camp_type == objB.camp_type then
				return objA.lev > objB.lev
			else
				return objA.camp_type < objB.camp_type
			end
		else
			return objA.star > objB.star
		end
	end
	table_sort(self.cur_role_data, SortFunc)

	if self.cur_role_item then
		self.cur_role_item:setSelected(false)
	end

	local extendData = {scale = 0.85, can_click = true, from_type = HeroConst.ExhibitionItemType.eHeroChange}
	self.role_scrollview:setData(self.cur_role_data, handler(self, self._onClickPartner), nil, extendData)
	self.role_scrollview:addEndCallBack(function (  )
		if self.cur_role_vo and next(self.cur_role_vo) ~= nil and self.cur_camp_type then
			-- 记录了上一次选中英雄的数据，切换到全部或该英雄阵营时，该英雄继续为选中状态
			if self.cur_role_vo.camp_type == self.cur_camp_type or self.cur_camp_type == HeroConst.CampType.eNone then
				local list = self.role_scrollview:getItemList()
				for k,v in pairs(list) do
					local data = v:getData()
					if data.id == self.cur_role_vo.id then
						self:_onClickPartner(v, data)
						break
					end
				end
			end
		elseif self.cancel_partner_id and self.cancel_partner_id ~= 0 then --选中取消置换的英雄
			local list = self.role_scrollview:getItemList()
			for k,v in pairs(list) do
				local data = v:getData()
				if data.id == self.cancel_partner_id then
					self:_onClickPartner(v, data)
					self.role_scrollview:jumpToMove(cc.p(-(k-3)*(0.85*119+15), 0), 0.01)
					break
				end
			end
			self.cancel_partner_id = 0
		end
    end)
end

-- 判断是否为锁住的英雄
function SeerpalaceChangePanel:checkIsLockedRole( id )
	local is_locked = false
	for k,v in pairs(self.lock_partner_ids) do
		if v.id and v.id == id then
			is_locked = true
			break
		end
	end
	return is_locked
end

function SeerpalaceChangePanel:_onClickPartner( item, vo )
	if vo:checkHeroLockTips(true) then
		return
	end
	if self.cur_role_item then
		self.cur_role_item:setSelected(false)
	end
	item:setSelected(true)
	self.cur_role_item = item
	self.cur_role_vo = vo

	local role_star = vo.star
	local label_str = ""
	local cost_config = Config.RecruitHighData.data_seerpalace_const["hero_change" .. role_star]
	if cost_config and cost_config.val then
		local bid = cost_config.val[1][1]
		local num = cost_config.val[1][2]
		local item_config = Config.ItemData.data_get_data(bid)
		if item_config then
			label_str = string.format("<img src=%s visible=true scale=0.3 /><div fontColor=#ffffff fontsize=26 outline=2,#6c2b00>%d 转换</div>", PathTool.getItemRes(item_config.icon), num)
		end
	end
	self.change_btn_label:setString(TI18N(label_str))

	self:refreshRoleSpine()
end

-- 刷新英雄模型显示
function SeerpalaceChangePanel:refreshRoleSpine(  )
	if self.right_role then
		self.right_role:DeleteMe()
		self.right_role = nil
	end

	-- 选中了某一个英雄或者有未保存的重置英雄
	if (self.cur_role_vo and next(self.cur_role_vo) ~= nil) or self.change_partner_id ~= 0 then
		local left_role_vo = {} -- 左侧英雄的数据
		if self.change_partner_id == 0 then
			left_role_vo = self.cur_role_vo
			self.change_btn:setVisible(true)
			self:handleRightRandomEffect(true)
		else
			left_role_vo = HeroController:getInstance():getModel():getHeroById(self.change_partner_id)
			self.change_btn:setVisible(false)
			self:handleRightRandomEffect(false)
		end
		if left_role_vo and next(left_role_vo) ~= nil then
			self.cur_role_vo = left_role_vo
			local type_res = PathTool.getHeroCampTypeIcon(left_role_vo.camp_type)
			if not self.left_role_bid or not self.left_role_star or self.left_role_bid ~= left_role_vo.bid or self.left_role_star ~= left_role_vo.star then
				self.left_role_bid = left_role_vo.bid
				self.left_role_star = left_role_vo.star

				if self.left_role then
					self.left_role:DeleteMe()
					self.left_role = nil
				end
				self.left_role = BaseRole.new(BaseRole.type.partner, left_role_vo, nil, {skin_id = left_role_vo.use_skin}) 
			    self.left_role:setCascade(true)
			    self.left_role:setAnchorPoint(cc.p(0.5, 0))
			    self.left_role:setPosition(cc.p(100, 180))
			    self.left_role:setAnimation(0,PlayerAction.show,true)
			    self.left_panel:addChild(self.left_role)

			    if not self.left_name_label then
			    	self.left_name_label = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(100, 372))
			    	self.left_panel:addChild(self.left_name_label)
			    end
			    local left_name = string.format("<img src='%s' scale=0.5 />    <div fontcolor=#ffffff outline=2,#000000>    %s</div>", type_res, left_role_vo.name)
				self.left_name_label:setString(left_name)
				self.left_lv_label:setString(left_role_vo.lev)
			end

			self.right_lv_label:setString(left_role_vo.lev)
			local right_name = ""
		    if self.change_new_partner_bid ~= 0 then
		    	local base_config = Config.PartnerData.data_partner_base[self.change_new_partner_bid]

		    	local right_role_data = {bid = self.change_new_partner_bid, star = left_role_vo.star}
		    	self.right_role = BaseRole.new(BaseRole.type.partner, right_role_data) 
		    	self.right_role:setCascade(true)
			    self.right_role:setAnchorPoint(cc.p(0.5, 0))
			    self.right_role:setPosition(cc.p(100, 180))
			    self.right_role:setAnimation(0,PlayerAction.show,true)
			    self.right_panel:addChild(self.right_role)

			    if base_config and base_config.name then
			    	right_name = string.format("<img src='%s' scale=0.5 /><div fontcolor=#ffffff outline=2,#000000>    %s</div>", type_res, base_config.name)
			    end
			else
				right_name = string.format("<img src='%s' scale=0.5 /><div fontcolor=#ffffff outline=2,#000000>    ????</div>", type_res)
			end
			
		    if not self.right_name_label then
		    	self.right_name_label = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(100, 372))
		    	self.right_panel:addChild(self.right_name_label)
		    end
		    self.right_name_label:setString(right_name)

			for k,star in pairs(self.left_stars_1) do
				star:setVisible(false)		
			end
			for k,star in pairs(self.left_stars_2) do
				star:setVisible(false)		
			end
			for k,star in pairs(self.right_stars_1) do
				star:setVisible(false)	
			end
			for k,star in pairs(self.right_stars_2) do
				star:setVisible(false)	
			end
			if self.left_star10 then
				self.left_star10:setVisible(false)
			end
			if self.right_star10 then
				self.right_star10:setVisible(false)
			end

			local role_star = left_role_vo.star
			local _cStar = function(star_count, res, star_list, parent_node)
				local star_pos = SeerpalaceConst.Change_Pos_X[star_count] or {}
		        for i=1,star_count do
		            if not star_list[i] then 
		                local star = createImage(parent_node, res, 0, 338, cc.p(0.5, 0.5), true)
		                star_list[i] = star
		            end
		            star_list[i]:setVisible(true)
		            local pos_x = star_pos[i]
		            if pos_x then
		            	star_list[i]:setPositionX(pos_x)
		            end
		        end
		    end

		    if role_star > 0 and role_star <= 5 then
		        local res = PathTool.getResFrame("common","common_90074")
		        _cStar(role_star, res, self.left_stars_1, self.left_panel)
		        _cStar(role_star, res, self.right_stars_1, self.right_panel)
		    elseif role_star >= 6 and role_star <= 9 then
		        local res = PathTool.getResFrame("common","common_90075")
		        local count = role_star - 5
		        _cStar(count, res, self.left_stars_2, self.left_panel)
		        _cStar(count, res, self.right_stars_2, self.right_panel)
		    elseif role_star >= 10 then
		    	local res = PathTool.getResFrame("common","common_90073")
		        if self.left_star10 == nil then
		            self.left_star10 = createImage(self.left_panel, res, 100, 338,cc.p(0.5,0.5),true,0,false)
		            self.left_star10:setScale(1.2)
		        else
		            self.left_star10:setVisible(true)
		        end
		        if self.right_star10 == nil then
		            self.right_star10 = createImage(self.right_panel, res, 100, 338,cc.p(0.5,0.5),true,0,false)
		            self.right_star10:setScale(1.2)
		        else
		            self.right_star10:setVisible(true)
		        end
		    end
		end

		self.left_panel:setVisible(true)
		self.right_panel:setVisible(true)
		self:handleLeftEmptyEffect(false)
	else
		self.left_panel:setVisible(false)
		self.right_panel:setVisible(false)
		self.change_btn:setVisible(false)
		self:handleLeftEmptyEffect(true)
		self:handleRightRandomEffect(false)
		self.left_role_bid = nil
		self.left_role_star = nil
		if self.left_role then
			self.left_role:DeleteMe()
			self.left_role = nil
		end
	end
end

function SeerpalaceChangePanel:_onClickCampBtn( index, force )
	if self.cur_index == index and not force then return end

	if self.cur_index then
		local old_camp_data = self.camp_list[self.cur_index]
		if old_camp_data and old_camp_data.select_image then
			old_camp_data.select_image:setVisible(false)
		end
	end

	local cur_camp_data = self.camp_list[index]
	if cur_camp_data and cur_camp_data.select_image then
		cur_camp_data.select_image:setVisible(true)
	end

	self.cur_index = index
	self:refreshRoleList()
end

-- 左边为空时播放的特效
function SeerpalaceChangePanel:handleLeftEmptyEffect( status )
	if status == false then
        if self.left_empty_effect then
            self.left_empty_effect:clearTracks()
            self.left_empty_effect:removeFromParent()
            self.left_empty_effect = nil
        end
    else
        if not tolua.isnull(self.left_effect_node) and self.left_empty_effect == nil then
            self.left_empty_effect = createEffectSpine(Config.EffectData.data_effect_info[620], cc.p(0, 0), cc.p(0.5, 0), true, PlayerAction.action)
            self.left_effect_node:addChild(self.left_empty_effect)
        end
    end
end

-- 右边为随机时的特效
function SeerpalaceChangePanel:handleRightRandomEffect( status )
	if status == false then
        if self.right_random_effect then
            self.right_random_effect:clearTracks()
            self.right_random_effect:removeFromParent()
            self.right_random_effect = nil
        end
    else
        if not tolua.isnull(self.right_effect_node) and self.right_random_effect == nil then
            self.right_random_effect = createEffectSpine(Config.EffectData.data_effect_info[621], cc.p(0, 0), cc.p(0.5, 0), true, PlayerAction.action)
            self.right_effect_node:addChild(self.right_random_effect)
        end
    end
end

-- 右边置换成功的特效
function SeerpalaceChangePanel:handleRightChangeEffect( status )
	if status == false then
        if self.right_change_effect then
            self.right_change_effect:clearTracks()
            self.right_change_effect:removeFromParent()
            self.right_change_effect = nil
        end
    else
        if not tolua.isnull(self.right_effect_node) and self.right_change_effect == nil then
            self.right_change_effect = createEffectSpine(Config.EffectData.data_effect_info[622], cc.p(0, 0), cc.p(0.5, 0), false, PlayerAction.action)
            self.right_effect_node:addChild(self.right_change_effect)
        elseif self.right_change_effect then
        	self.right_change_effect:setAnimation(0, PlayerAction.action, false)
        end
    end
end

function SeerpalaceChangePanel:DeleteMe(  )
	self:handleLeftEmptyEffect(false)
	self:handleRightRandomEffect(false)
	self:handleRightChangeEffect(true)
	if self.role_scrollview then
		self.role_scrollview:DeleteMe()
		self.role_scrollview = nil
	end

	if self.left_role then
		self.left_role:DeleteMe()
		self.left_role = nil
	end

	if self.right_role then
		self.right_role:DeleteMe()
		self.right_role = nil
	end

	if self.left_name_label then
		self.left_name_label:DeleteMe()
		self.left_name_label = nil
	end

	if self.right_name_label then
		self.right_name_label:DeleteMe()
		self.right_name_label = nil
	end

	if self.change_btn_label then
		self.change_btn_label:DeleteMe()
		self.change_btn_label = nil
	end

	if self.role_change_info_event then
        GlobalEvent:getInstance():UnBind(self.role_change_info_event)
        self.role_change_info_event = nil
    end
    if self.change_success_event then
    	GlobalEvent:getInstance():UnBind(self.change_success_event)
    	self.change_success_event = nil
    end
end