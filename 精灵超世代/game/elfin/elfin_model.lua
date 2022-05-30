-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-08-13
-- --------------------------------------------------------------------
ElfinModel = ElfinModel or BaseClass()

function ElfinModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ElfinModel:config()
	self.elfin_hatch_list = {}  -- 孵化器数据
	self.elfin_buy_info = {} 	-- 今日购买精灵蛋和砸蛋道具的物品数量
	self.activated_elfin_list = {} -- 已激活的精灵id（用于图鉴）

	self.elfin_tree_data = {} 	-- 精灵古树数据
	self.tree_attr_change_data = {} -- 精灵古树四个属性值的变化缓存
	self.hatch_cfg = Config.SpriteData.data_hatch_data
	self.elfin_red_list = {} -- 红点数据
end

-- 设置今日购买数量信息
function ElfinModel:setElfinBuyInfo( data )
	self.elfin_buy_info = data or {}
end

-- 更新某一个物品今日购买信息
function ElfinModel:updateElfinBuyInfoByBid( bid, count )
	local is_have = false
	for k,v in pairs(self.elfin_buy_info) do
		if v.item_bid == bid then
			is_have = true
			v.buy_num = count
			break
		end
	end
	if not is_have then
		local info = {}
		info.item_bid = bid
		info.buy_num = count
		table.insert(self.elfin_buy_info, info)
	end
end

-- 根据bid获取该物品今日购买数量
function ElfinModel:getElfinBuyCountByBid( bid )
	local buy_num = 0
	for k,v in pairs(self.elfin_buy_info) do
		if v.item_bid == bid then
			buy_num = v.buy_num
			break
		end
	end
	return buy_num
end

-- 设置已经激活的精灵图鉴
function ElfinModel:setActivatedElfinList( data )
	self.activated_elfin_list = data or {}
end

-- 根据精灵id判断是否已经激活
function ElfinModel:checkElfinIsActivatedByBid( bid )
	local is_activated = false
	for k,v in pairs(self.activated_elfin_list) do
		if v.item_bid == bid then
			is_activated = true
			break
		end
	end
	return is_activated
end

-- 设置灵窝数据
function ElfinModel:setElfinHatchList( data_list )
	self.elfin_hatch_list = {}

	for k,data in pairs(data_list) do
		local elfin_hatch_vo = ElfinHatchVo.New()
		elfin_hatch_vo:updateData(data)
		if self.hatch_cfg and self.hatch_cfg[data.id] then
			elfin_hatch_vo.sort = self.hatch_cfg[data.id].sort
		end
		table.insert(self.elfin_hatch_list, elfin_hatch_vo)
	end

	-- 检测是否有孵化完成的灵窝
	self:calculateElfinHatchDoneRedStatus()
	self:calculateElfinHatchLvupRedStatus()
	self:calculateElfinHatchEggRedStatus()
end

-- 更新灵窝数据
function ElfinModel:updateElfinHatchData( data_list )
	for _,data in pairs(data_list) do
		local is_have = false
		for k,elfin_hatch_vo in pairs(self.elfin_hatch_list) do
			if elfin_hatch_vo.id == data.id then
				elfin_hatch_vo:updateData(data)
				is_have = true
				break
			end
		end
		if not is_have then
			local elfin_hatch_vo = ElfinHatchVo.New()
			elfin_hatch_vo:updateData(data)
			if self.hatch_cfg and self.hatch_cfg[data.id] then
				elfin_hatch_vo.sort = self.hatch_cfg[data.id].sort
			end
			table.insert(self.elfin_hatch_list, elfin_hatch_vo)
		end
	end

	-- 检测是否有孵化完成的灵窝
	self:calculateElfinHatchDoneRedStatus()
	self:calculateElfinHatchLvupRedStatus()
	self:calculateElfinHatchEggRedStatus()
end

-- 更新某一个灵窝的数据
function ElfinModel:updateOneElfinHatchData( data )
	for _,elfin_hatch_vo in pairs(self.elfin_hatch_list) do
		if elfin_hatch_vo.id == data.id then
			elfin_hatch_vo:updateData(data)
			break
		end
	end
	self:calculateElfinHatchDoneRedStatus()
	self:calculateElfinHatchLvupRedStatus()
	self:calculateElfinHatchEggRedStatus()
end

-- 获取所有灵窝数据
function ElfinModel:getElfinHatchList(  )
	return self.elfin_hatch_list
end

-- 根据灵窝id获取数据
function ElfinModel:getElfinHatchVoById( id )
	for k,elfin_hatch_vo in pairs(self.elfin_hatch_list) do
		if elfin_hatch_vo.id == id then
			return elfin_hatch_vo
		end
	end
end

-- 精灵系统是否开启
function ElfinModel:checkElfinIsOpen( not_tips )
	--屏蔽精灵系统
	if IS_HIDE_ELFIN then
		return false
	end

	local is_open = false
	local role_vo = RoleController:getInstance():getRoleVo()
	local open_cfg = Config.SpriteData.data_const["sprite_unlocked_lv"]
	if open_cfg and role_vo and open_cfg.val <= role_vo.lev then
		is_open = true
	end

	if not is_open and open_cfg and not not_tips then
		message(open_cfg.desc)
	end

	return is_open
end

-- 设置精灵古树数据
function ElfinModel:setElfinTreeData( data )
	-- 记录一下{"atk", "hp_max", "def", "speed"}四个属性值的变化
	self.tree_attr_change_data = {}

	if self.elfin_tree_data and next(self.elfin_tree_data) ~= nil then
		local key_list = {"atk", "hp_max", "def", "speed"}
		for i,attr_key in ipairs(key_list) do
			local old_val = self.elfin_tree_data[attr_key]
			local new_val = data[attr_key]
			if new_val > old_val then
				self.tree_attr_change_data[attr_key] = new_val - old_val
			end
		end

		-- 阶级变化，弹出唤醒成功界面
		if self.elfin_tree_data.break_lev < data.break_lev then
			ElfinController:getInstance():openElfinTreeRouseWindow(true, self.elfin_tree_data, data)
		end

		-- 战力变化飘字
		if self.elfin_tree_data.power and self.elfin_tree_data.power < data.power then
			GlobalMessageMgr:getInstance():showPowerMove( data.power-self.elfin_tree_data.power,PathTool.getResFrame("common", "txt_cn_common_90025"),self.elfin_tree_data.power )
		end
	end

	self.elfin_tree_data = data or {}
	--记录一下4咯位置对应
	self.dic_elfin_item_pos = {}
	local sprites = data.sprites or {}
	for i,v in ipairs(data.sprites) do
		self.dic_elfin_item_pos[v.pos] = v.item_bid
	end

	-- 记录一下当前古树升级、进阶消耗的材料，用于监听材料数量变化显示红点
	self.tree_cost_list = {}
	self.tree_step_lev = 0
	local level_cfg = Config.SpriteData.data_tree_up_lv(data.lev)
    local step_cfg = Config.SpriteData.data_tree_step[data.break_lev]
    if level_cfg and step_cfg then
    	if data.lev >= step_cfg.lev_max then -- 进阶
			self.tree_cost_list = step_cfg.expend
			local temp_list =  step_cfg.step_cond
			for k,v in pairs(temp_list) do
				if v[1] == "role_lev" then
					self.tree_step_lev = v[2]
				end
			end
	    else -- 升级
	    	self.tree_cost_list = level_cfg.expend
	    end
    end
    self:calculateTreeUplvRedStatus()

    -- 是否有可放置的精灵
    self:calculateTreePutElfinRedStatus()

    -- 上阵的精灵是否可以合成
    self:calculateElfinCompoundRedStatus()

    -- 上阵精灵中是否有同类型更高级的精灵
    self:calculateElfinHigherRedStatus()
end

function ElfinModel:getElfinTreeData(  )
	if IS_HIDE_ELFIN then
		return nil
	end
	return self.elfin_tree_data
end

-- 获取古树的四个精灵bid(只有已经解锁的精灵，解锁未放置时bid为0)
function ElfinModel:getElfinTreeElfinList(  )
	if IS_HIDE_ELFIN then
		return {}
	end
	if not self.elfin_tree_data then return {} end
	return self.elfin_tree_data.sprites or {}
end

--根据位置获取精灵bid 如果 bid ==nil 说明未解锁
function ElfinModel:getElfinItemByPos(pos)	
	if self.dic_elfin_item_pos then
		return self.dic_elfin_item_pos[pos]
	end
	return nil
end

--获取一个缺省空的精灵数据
function ElfinModel:getDedefaultElfinInfo()
	if self.elfin_tree_data then
		local sprites = {}
		local eflin_data = self.elfin_tree_data.sprites or {}
		for i,v in ipairs(eflin_data) do
			local data = {}
			data.pos = v.pos
			data.item_bid = 0
			table.insert(sprites, data)
		end
		return sprites
	end
	return {}
end

function ElfinModel:getElfinTreeByBid(bid)
	if self.dic_elfin_item_pos and bid and bid ~= 0 then
		for pos,_bid in pairs(self.dic_elfin_item_pos) do
			if _bid == bid then
				return pos
			end
		end
	end
	return nil
end

function ElfinModel:getElfinTreeAttrChangeData(  )
	return self.tree_attr_change_data
end

-- 根据属性名称、突破等级计算出下一级的属性值
function ElfinModel:getElfinTreeNextAttrVal( attr_key, lev, break_lev )
	local attr_val = 0
	local attr_base_cfg = Config.SpriteData.data_tree_attr[1]
	local step_cfg = Config.SpriteData.data_tree_step[break_lev]
	if not attr_base_cfg or not step_cfg then return attr_val end

	local add_attr_key = "add_" .. attr_key -- 成长属性值
	if attr_key == "hp_max" then
		add_attr_key = "add_hp"
	end

	local function getStepAttrVal( key )
		local val = 0
		for k,v in pairs(step_cfg.all_attr or {}) do
			if v[1] == key then
				val = v[2] or 0
			end
		end
		return val
	end

	local base_val = attr_base_cfg[attr_key] or 0
	local step_val = getStepAttrVal(attr_key)
	local base_groud_val = attr_base_cfg[add_attr_key] or 0
	local step_groud_val = step_cfg[add_attr_key] or 0
	attr_val = base_val + step_val + (lev * base_groud_val * step_groud_val / 1000000)
	return GameMath.round(attr_val)
end

-------------------------------------@ 红点相关
function ElfinModel:updateElfinRedStatus( bid, status )
	if not self:checkElfinIsOpen(true) then return end
    self.elfin_red_list[bid] = status

    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.partner, {bid = bid, status = status})
    GlobalEvent:getInstance():Fire(ElfinEvent.Update_Elfin_Red_Event, bid, status)
end

-- 计算灵窝孵化完成的红点
function ElfinModel:calculateElfinHatchDoneRedStatus(  )
	if not self:checkElfinIsOpen(true) then return end
	local hatch_done_red = false
	for k,hatch_vo in pairs(self.elfin_hatch_list) do
		if hatch_vo.state == ElfinConst.Hatch_Status.Over then
			hatch_done_red = true
			break
		end
	end
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_hatch_done, hatch_done_red)
end

-- 计算灵窝升级的红点
function ElfinModel:calculateElfinHatchLvupRedStatus(  )
	if not self:checkElfinIsOpen(true) then return end
	local red_status = false
	-- local hatch_vo = self.elfin_hatch_list[1]
	-- if not self.not_calculate_hatch_flag and hatch_vo and Config.SpriteData.data_hatch_lev[hatch_vo.lev+1] then
	-- 	local next_hatch_lev_cfg = Config.SpriteData.data_hatch_lev[hatch_vo.lev+1]
	-- 	local role_vo = RoleController:getInstance():getRoleVo()
	-- 	if role_vo.vip_lev >= next_hatch_lev_cfg.limit_vip then
	-- 		red_status = true
	-- 		for i,v in ipairs(next_hatch_lev_cfg.expend) do
	-- 	        local bid = v[1]
	-- 	        local need_num = v[2]
	-- 	        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
	-- 	        if have_num < need_num then
	-- 	        	red_status = false
	-- 	        	break
	-- 	        end
	-- 	    end
	-- 	end
	-- end
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_hatch_lvup, red_status)
end

-- 设置不再显示灵窝升级的红点标识
function ElfinModel:setNotCalculateHatchLvupRedFlag(  )
	if self:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_hatch_lvup) then
		self.not_calculate_hatch_flag = true
	end
end

-- 设置打开过精灵孵化界面
function ElfinModel:setOpenElfinHatchFlag( flag )
	self.open_hatch_flag = flag
end

-- 计算是否有可孵化的灵窝和蛋
function ElfinModel:calculateElfinHatchEggRedStatus(  )
	if not self:checkElfinIsOpen(true) then return end
	local red_status = false
	local have_empty_hatch = false
	for k,hatch_vo in pairs(self.elfin_hatch_list) do
		if hatch_vo.is_open == 1 and hatch_vo.state == ElfinConst.Hatch_Status.Open then
			have_empty_hatch = true
			break
		end
	end
	if have_empty_hatch then
		local all_egg_list = BackpackController:getInstance():getModel():getBackPackItemListByType(BackPackConst.item_type.ELFIN_EGG)
		if #all_egg_list > 0 then
			red_status = true
		end
	end
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_hatch_egg, red_status)
end

-- 计算是否有可解锁的灵窝
function ElfinModel:calculateElfinHatchOpenRedStatus(  )
	if not self:checkElfinIsOpen(true) then return end
	local red_status = false
	for k,hatch_vo in pairs(self.elfin_hatch_list) do
		if hatch_vo.is_open == 2 and hatch_vo.state == ElfinConst.Hatch_Status.Open then
			red_status = true
			break
		end
	end
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_hatch_open, red_status)
end

-- 计算古树红点升级、进阶红点
function ElfinModel:calculateTreeUplvRedStatus(  )
	if not self:checkElfinIsOpen(true) then return end
	local red_status = false
	if self.tree_cost_list and next(self.tree_cost_list) ~= nil then
		red_status = true
		for k,v in pairs(self.tree_cost_list) do
			local bid = v[1]
			local need_num = v[2]
			local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
			if have_num < need_num then
				red_status = false
				break
			end
		end
		if red_status == true and self.tree_step_lev and self.tree_step_lev >0 then
			local role_vo = RoleController:getInstance():getRoleVo()
			if role_vo and self.tree_step_lev > role_vo.lev then
				red_status = false
			end
		end
		
	end
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_tree_lvup, red_status)
end

-- 获取古树当前升级或进阶消耗的物品bid
function ElfinModel:getElfinTreeCostBidList(  )
	local cost_bid_list = {}
	if self.tree_cost_list and next(self.tree_cost_list) ~= nil then
		for k,v in pairs(self.tree_cost_list) do
			table.insert(cost_bid_list, v[1])
		end
	end
	return cost_bid_list
end

-- 计算古树当前是否有可放置精灵的位置的红点
function ElfinModel:calculateTreePutElfinRedStatus(  )
	if not self:checkElfinIsOpen(true) then return end
	local red_status = false
	if self.elfin_tree_data.sprites and next(self.elfin_tree_data.sprites) ~= nil then
		local is_have_pos = false
		local have_type_list = {} -- 所有已经放置的精灵的类型
		for k,v in pairs(self.elfin_tree_data.sprites) do
			if v.item_bid == 0 then
				is_have_pos = true
			else
				local elfin_cfg = Config.SpriteData.data_elfin_data(v.item_bid)
				if elfin_cfg and elfin_cfg.sprite_type then
					table.insert(have_type_list, elfin_cfg.sprite_type)
				end
			end
		end
		
		if is_have_pos == true then
			-- 有位置未放置精灵，还要判断背包中是否有可放置的精灵
			local all_elfin_data = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.ELFIN) or {}
			for k,v in pairs(all_elfin_data) do
				local elfin_cfg = Config.SpriteData.data_elfin_data(v.base_id)
				if elfin_cfg then
					local is_same = false
					for _,e_type in pairs(have_type_list) do
						if elfin_cfg.sprite_type == e_type then
							is_same = true
							break
						end
					end
					-- 有非同类型可放置的精灵
					if not is_same then
						red_status = true
						break
					end
				end
			end
		end
	end
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_empty_pos, red_status)
end

-- 计算上阵的精灵是否可合成
function ElfinModel:calculateElfinCompoundRedStatus(  )
	if not self:checkElfinIsOpen(true) then return end
	local red_status = false
	self.elfin_com_cost_list = {} -- 记录一下上阵中的精灵合成所需材料
	if self.elfin_tree_data.sprites and next(self.elfin_tree_data.sprites) ~= nil then
		for k,v in pairs(self.elfin_tree_data.sprites) do
			local elfin_com_cfg = Config.SpriteData.data_elfin_com[v.item_bid]
			if v.item_bid ~= 0 and elfin_com_cfg and elfin_com_cfg.expend and next(elfin_com_cfg.expend) ~= nil then
				local temp_status = true
				for _,info in pairs(elfin_com_cfg.expend) do
					table.insert(self.elfin_com_cost_list, info)
					if red_status == false then
						local need_num = info[2]
						local have_num = BackpackController:getInstance():getModel():getItemNumByBid(info[1])
						if have_num < need_num then
							temp_status = false
						end
					end
				end
				if temp_status == true then
					red_status = true
				end
			end
		end
	end
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_compound, red_status)
end

-- 获取上阵的精灵合成消耗的物品bid
function ElfinModel:getElfinCompoundCostBidList(  )
	local cost_bid_list = {}
	if self.elfin_com_cost_list and next(self.elfin_com_cost_list) ~= nil then
		for k,v in pairs(self.elfin_com_cost_list) do
			table.insert(cost_bid_list, v[1])
		end
	end
	return cost_bid_list
end

-- 计算上阵精灵中是否有同类型更高级的精灵
function ElfinModel:calculateElfinHigherRedStatus(  )
	if not self:checkElfinIsOpen(true) then return end
	local red_status = false
	if self.elfin_tree_data.sprites and next(self.elfin_tree_data.sprites) ~= nil then
		local have_type_list = {} -- 所有已经放置的精灵的类型和阶数
		for k,v in pairs(self.elfin_tree_data.sprites) do
			local elfin_cfg = Config.SpriteData.data_elfin_data(v.item_bid)
			if v.item_bid ~= 0 and elfin_cfg then
				local object = {}
				object.step = elfin_cfg.step
				object.s_type = elfin_cfg.sprite_type
				table.insert(have_type_list, object)
			end
		end
		local all_elfin_data = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.ELFIN) or {}
		for k,v in pairs(all_elfin_data) do
			local elfin_cfg = Config.SpriteData.data_elfin_data(v.base_id)
			if elfin_cfg then
				for _,object in pairs(have_type_list) do
					if elfin_cfg.sprite_type == object.s_type and elfin_cfg.step > object.step then
						red_status = true
						break
					end
				end
			end
			if red_status == true then
				break
			end
		end
	end
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_higher_lv, red_status)
end

-- 计算图鉴红点
function ElfinModel:calculateElfinActivateRedStatus( activate_list )
	if not self:checkElfinIsOpen(true) then return end
	local red_status = false
	-- self.elfin_activate_red_data = self.elfin_activate_red_data or {}

	-- for _,v in pairs(activate_list or {}) do
	-- 	local elfin_cfg = Config.SpriteData.data_elfin_data(v.item_bid)
	-- 	if elfin_cfg then
	-- 		self.elfin_activate_red_data[elfin_cfg.step] = self.elfin_activate_red_data[elfin_cfg.step] or {}
	-- 		table.insert(self.elfin_activate_red_data[elfin_cfg.step], v.item_bid)
	-- 	end
	-- end
	-- for k,list in pairs(self.elfin_activate_red_data) do
	-- 	if #list > 0 then
	-- 		red_status = true
	-- 		break
	-- 	end
	-- end

	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_activate, red_status)
end

function ElfinModel:checkActivateTabBtnRedStatus( index )
	if self.elfin_activate_red_data and self.elfin_activate_red_data[index] and next(self.elfin_activate_red_data[index]) ~= nil then
		return true
	end
	return false
end

function ElfinModel:clearActivateDataByIndex( index )
	if self.elfin_activate_red_data then
		self.elfin_activate_red_data[index] = {}
	end
	self:calculateElfinActivateRedStatus()
end

function ElfinModel:clearActivateRedData(  )
	self.elfin_activate_red_data = {}
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_activate, false)
end

function ElfinModel:clearActivateDataByBid( bid )
	if self.elfin_activate_red_data then
		for _,list in pairs(self.elfin_activate_red_data) do
			local is_have = false
			for k,v in pairs(list) do
				if v == bid then
					table.remove(list, k)
					is_have = true
					break
				end
			end
			if is_have then
				break
			end
		end
	end
end

-- 是否是新激活的精灵
function ElfinModel:checkIsNewActivateByBid( bid )
	local is_new = false
	for k,list in pairs(self.elfin_activate_red_data or {}) do
		for _,v in pairs(list) do
			if v == bid then
				is_new = true
				break
			end
		end
		if is_new then
			break
		end
	end
	return is_new
end

function ElfinModel:getElfinRedStatus(  )
	local red_status = false
	for bid,status in pairs(self.elfin_red_list) do
		if status == true then
			red_status = true
			break
		end
	end
	return red_status
end

-- 获取精灵红点状态
function ElfinModel:getElfinRedStatusByRedBid( bid )
	return self.elfin_red_list[bid] or false
end

-- 计算是否有免费召唤和未许愿
function ElfinModel:calculateElfinSummonRedStatus(  )
	if not self:checkElfinIsOpen(true) then return end
	local red_status = false
	local data = self:getElfinSummonData()
	if data then
		local cur_time = GameNet:getInstance():getTime()
		if data.free_time and data.free_time <= cur_time  then
			red_status = true
		end
		if red_status == false and data.lucky_ids and #data.lucky_ids<=0 then
			red_status = true
		end
		if red_status == false then
			local award_config = Config.HolidaySpriteLotteryData.data_award[data.camp_id]
			if award_config then
				for i,v in pairs(award_config) do
					local _un_enabled = false
					for k,m in pairs(data.do_awards) do
						if v.id == m.award_id then
							_un_enabled = true
							break
						end
					end
		
					if _un_enabled == false and v.times <= data.times then
						red_status = true
						break
					end		
				end
			end
		end
	end
	self:updateElfinRedStatus(HeroConst.RedPointType.eElfin_summon, red_status)
end

-- 设置精灵召唤数据
function ElfinModel:setElfinSummonData( data )
	self.elfin_summon_data = data
	self:calculateElfinSummonRedStatus()
end

-- 获取精灵召唤数据
function ElfinModel:getElfinSummonData( )
	return self.elfin_summon_data
end

--精灵方案数据
function ElfinModel:setPlanData(data)
	if not data then return end
	if self.elfin_plan_data == nil then
		self.elfin_plan_data = {}
	end

	for i,v in ipairs(data.plan_list) do
		if self.elfin_plan_data[v.id] == nil then
			self.elfin_plan_data[v.id] = v
		else
			for key,val in pairs(v) do
				self.elfin_plan_data[v.id][key] = val
			end
		end
	end
end

function ElfinModel:getPlanCount()
	if self.elfin_plan_data == nil then
		return 0
	end
	local count = 0
	for k,v in pairs(self.elfin_plan_data) do
		count = count + 1
	end
	return count
end

function ElfinModel:getPlanData()
	-- local data = {}
	-- for i=1,3 do
	-- 	local d = {}
	-- 	d.id = i
	-- 	d.name = "测试"..i
	-- 	d.plan_sprites = self.elfin_tree_data.sprites
	-- 	table.insert(data, d)
	-- end
	-- return data
	return self.elfin_plan_data 	
end

function ElfinModel:__delete()
end