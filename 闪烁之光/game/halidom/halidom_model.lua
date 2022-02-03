-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-03-07
-- --------------------------------------------------------------------
HalidomModel = HalidomModel or BaseClass()

function HalidomModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function HalidomModel:config()
	self.all_halidom_data = {}
	self.halidom_red_list = {}
end

-- 设置圣物数据
function HalidomModel:setAllHalidomData( data_list )
	self.all_halidom_data = {}
	for k,hData in pairs(data_list) do
		local halidom_vo = HalidomVo.New()
		halidom_vo:updateData(hData)
		table.insert(self.all_halidom_data, halidom_vo)
	end
	self:checkHalidomRedStatus()
end

-- 更新某一圣物数据(也可能是新增)
function HalidomModel:updateHalidomData( data )
	local is_have = false
	for k,halidom_vo in pairs(self.all_halidom_data) do
		if halidom_vo.id == data.id then
			is_have = true
			halidom_vo:updateData(data)
			break
		end
	end
	if not is_have then
		local halidom_vo = HalidomVo.New()
		halidom_vo:updateData(data)
		table.insert(self.all_halidom_data, halidom_vo)
	end
	self:checkHalidomRedStatus()
	return is_have
end

-- 根据id获取圣物数据
function HalidomModel:getHalidomDataById( id )
	for k,halidom_vo in pairs(self.all_halidom_data) do
		if halidom_vo.id == id then
			return halidom_vo
		end
	end
	return {}
end

-- 根据阵营id获取圣物数据
function HalidomModel:getHalidomDataByCampType( camp_type )
	for k,halidom_vo in pairs(self.all_halidom_data) do
		local halidom_cfg = Config.HalidomData.data_base[halidom_vo.id]
		if halidom_cfg and halidom_cfg.camp == camp_type then
			return halidom_vo
		end
	end
end

-- 根据id判断圣物是否解锁
function HalidomModel:checkHalidomIsUnlock( id )
	local is_unlock = false
	for k,halidom_vo in pairs(self.all_halidom_data) do
		if halidom_vo.id == id then
			is_unlock = true
			break
		end
	end
	return is_unlock
end

-- 获取圣物是否开启
function HalidomModel:checkHalidomIsOpen( not_tips )
	local role_vo = RoleController:getInstance():getRoleVo()
	local limit_lv_cfg = Config.HalidomData.data_const["halidom_open_lev"]
	if limit_lv_cfg and role_vo and limit_lv_cfg.val <= role_vo.lev then
		return true
	end
	if not not_tips and limit_lv_cfg then
		message(limit_lv_cfg.desc)
	end
	return false
end

---------@ 红点相关
function HalidomModel:updateHalidomRedStatus( bid, status )
    self.halidom_red_list[bid] = status

    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.partner, {bid = bid, status = status})
    GlobalEvent:getInstance():Fire(HalidomEvent.Update_Halidom_Red_Event, bid, status)
end

function HalidomModel:getHalidomRedStatus(  )
	local red_status = false
	for bid,status in pairs(self.halidom_red_list) do
		if status == true then
			red_status = true
			break
		end
	end
	return red_status
end

-- 获取圣物红点状态
function HalidomModel:getHalidomRedStatusByRedBid( bid )
	return self.halidom_red_list[bid] or false
end

-- 计算一下红点数据
function HalidomModel:calculateHalidomRedStatus(  )
	if not self:checkHalidomIsOpen(true) then return end
	for k,halidom_vo in pairs(self.all_halidom_data) do
		halidom_vo:checkHalidomRedStatus()
	end
	self:checkHalidomRedStatus()
end

function HalidomModel:checkHalidomRedStatus(  )
	if not self:checkHalidomIsOpen(true) then
		return
	end
	-- 是否有可以解锁的圣物
	local unlock_red_status = false
	for k,v in pairs(Config.HalidomData.data_base) do
		if self:checkHalidomIsCanUnlock(v.id) then
			unlock_red_status = true
			break
		end
	end
	self:updateHalidomRedStatus(HeroConst.RedPointType.eRPHalidom_Unlock, unlock_red_status)

	-- 是否有可以升级的圣物
	local lvup_red_status = false
	for k,halidom_vo in pairs(self.all_halidom_data) do
		if halidom_vo:getRedStatusByType(HalidomConst.Red_Type.Lvup) then
			lvup_red_status = true
			break
		end
	end
	self:updateHalidomRedStatus(HeroConst.RedPointType.eRPHalidom_Lvup, lvup_red_status)

	-- 是否有可以进阶的圣物
	local step_red_status = false
	for k,halidom_vo in pairs(self.all_halidom_data) do
		if halidom_vo:getRedStatusByType(HalidomConst.Red_Type.Step) then
			step_red_status = true
			break
		end
	end
	self:updateHalidomRedStatus(HeroConst.RedPointType.eRPHalidom_Step, step_red_status)
end

-- 根据圣物id判断是否满足解锁条件
function HalidomModel:checkHalidomIsCanUnlock( id )
	local is_can_unlock = false
	if self:checkHalidomIsOpen(true) and not self:checkHalidomIsUnlock(id) then
		local base_cfg = Config.HalidomData.data_base[id]
		if base_cfg then
			is_can_unlock = true
			local hero_array = HeroController:getInstance():getModel():getAllHeroArray()
			local hero_size = hero_array:GetSize()
			for k,v in pairs(base_cfg.loss) do
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
					is_can_unlock = false
					break
				end
			end
		end
	end
	return is_can_unlock
end

function HalidomModel:__delete()
end