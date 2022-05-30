--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-07.20:52:12
-- @description    : 
		-- 圣物数据
---------------------------------
HalidomVo = HalidomVo or BaseClass(EventDispatcher)

function HalidomVo:__init(  )
	self.id = 0  		-- 圣物id
	self.lev = 0 		-- 圣物等级
	self.exp = 0 		-- 圣物经验值
	self.step = 0 		-- 圣物阶数
	self.all_attr = {}  -- 圣物属性值

	self.red_status_list = {}  -- 圣物红点
end

function HalidomVo:updateData( data )
	for key, value in pairs(data) do
        self[key] = value
    end
    self:dispatchUpdateAttrByKey()
    self:checkHalidomRedStatus()
end

function HalidomVo:dispatchUpdateAttrByKey()
     
end

-- 检测红点数据
function HalidomVo:checkHalidomRedStatus(  )
	-- 升级
	local is_can_lvup = false
	local max_lv = Config.HalidomData.data_max_lev[self.id]
	local all_lv_cfg = Config.HalidomData.data_lvup[self.id]
	if self.lev < max_lv and all_lv_cfg then
		local lv_cfg = all_lv_cfg[self.lev]
		if lv_cfg then
			is_can_lvup = true
			for k,v in pairs(lv_cfg.loss or {}) do
				local bid = v[1]
				local num = v[2]
				local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
				if have_num < num then
					is_can_lvup = false
					break
				end
			end
		end
	end
	self.red_status_list[HalidomConst.Red_Type.Lvup] = is_can_lvup

	-- 进阶
	local is_can_step = false
	local max_step = Config.HalidomData.data_max_step[self.id]
	local all_step_cfg = Config.HalidomData.data_step[self.id]
	if self.step < max_step and all_step_cfg then
		local step_cfg = all_step_cfg[self.step + 1]
		if step_cfg then
			-- 是否满足进阶条件
			is_can_step = true
			for _,v in pairs(step_cfg.conds) do
				if v[1] == "lev" and v[2] and self.lev < v[2] then
					is_can_step = false
				end
			end
			-- 道具消耗是否满足
			if is_can_step then
				for _,v in pairs(step_cfg.loss_items) do
					local bid = v[1]
					local num = v[2]
					local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
					if have_num < num then
						is_can_step = false
						break
					end
				end
			end
			local hero_array = HeroController:getInstance():getModel():getAllHeroArray()
			local hero_size = hero_array:GetSize()
			-- 指定宝可梦消耗
			if is_can_step then
				for k,v in pairs(step_cfg.loss_fixed) do
					local bid = v[1]
					local star = v[2]
					local num = v[3]
					local have_num = 0
					for i=1, hero_size do
						local hero_vo = hero_array:Get(i-1)
						if hero_vo.is_lock == 0 and hero_vo.is_in_form == 0 and hero_vo.bid == bid and hero_vo.star == star then
							have_num = have_num + 1
						end
						if have_num >= num then
							break
						end
					end
					if have_num < num then
						is_can_step = false
						break
					end
				end
			end
			-- 随机宝可梦消耗
			if is_can_step then
				for k,v in pairs(step_cfg.loss_rand) do
					local camp = v[1]
					local star = v[2]
					local num = v[3]
					local have_num = 0
					for i=1, hero_size do
						local hero_vo = hero_array:Get(i-1)
						if hero_vo.is_lock == 0 and hero_vo.is_in_form == 0 and hero_vo.camp_type == camp and hero_vo.star == star then
							have_num = have_num + 1
						end
						if have_num >= num then
							break
						end
					end
					if have_num < num then
						is_can_step = false
						break
					end
				end
			end
		end
	end

	self.red_status_list[HalidomConst.Red_Type.Step] = is_can_step
end

-- 获取根据类型圣物红点状态
function HalidomVo:getRedStatusByType( red_type )
	return self.red_status_list[red_type] or false
end

function HalidomVo:__delete(  )
	
end