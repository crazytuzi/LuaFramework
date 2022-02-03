-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-03-04
-- --------------------------------------------------------------------
ElementModel = ElementModel or BaseClass()

function ElementModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ElementModel:config()
	self.element_data = {}
	self.red_status = false


	--记录当前打开的神殿类型
	self.record_open_type = nil
end

function ElementModel:getRecordOpenType()
	return self.record_open_type
end
function ElementModel:setRecordOpenType(open_type)
	self.record_open_type = open_type
end

-- 设置元素神殿基础数据
function ElementModel:setElementData( data )
	self.element_data = data or {}
	self:updateLadderRedStatus()
end

-- 获取元素神殿数据
function ElementModel:getElementData(  )
	return self.element_data or {}
end

-- 判断是否有元素神殿的数据
function ElementModel:checkIsHaveElementData(  )
	if not self.element_data or next(self.element_data) == nil then
		return false
	end
	return true
end

-- 刷新购买次数相关数据
function ElementModel:updateElementCountData( data )
	if self.element_data then
		for key,val in pairs(data) do
			self.element_data[key] = val
		end
		self:updateLadderRedStatus()
	end
end

-- 刷新最大通关数
function ElementModel:updateElementCustomsData( data )
	if self.element_data and self.element_data.list then
		for k,v in pairs(self.element_data.list) do
			if v.type == data.type then
				v.group = data.group
				v.boss_id = data.boss_id
				break
			end
		end
	end
end

-- 获取剩余挑战次数
function ElementModel:getLeftChallengeCount(  )
	if self.element_data then
		return self.element_data.num or 0
	end
	return 0
end

-- 今日普通购买次数
function ElementModel:getNormalBuyCount(  )
	if self.element_data then
		return self.element_data.buy_num or 0
	end
	return 0
end

-- 获取今日特权购买次数
function ElementModel:getPrivilegeBuyCount(  )
	if self.element_data then
		return self.element_data.pr_buy_num or 0
	end
	return 0
end

-- 获取剩余购买次数（包括普通次数和特权次数）
function ElementModel:getTodayLeftBuyCount(  )
	local left_count = 0
	local normal_count = self.element_data.buy_num or 0
	local normal_max_count = 0
	local role_vo = RoleController:getInstance():getRoleVo()
	for k,v in pairs(Config.ElementTempleData.data_buy_count) do
		if v.vip <= role_vo.vip_lev then
			normal_max_count = normal_max_count + 1
		end
	end
	left_count = normal_max_count - normal_count
	local privilege_status = RoleController:getInstance():getModel():checkPrivilegeStatus(4) -- 特权激活状态
	if privilege_status then
		local pri_count = self.element_data.pr_buy_num or 0
		left_count = left_count + Config.ElementTempleData.data_privilege_length - pri_count
	end
	if left_count < 0 then left_count = 0 end
	return left_count
end

-- 根据副本类型获取最大通关数
function ElementModel:getElementCustomsIdByType( ele_type )
	local customs_id = 0
	if self.element_data and self.element_data.list then
		for k,v in pairs(self.element_data.list) do
			if v.type == ele_type then
				customs_id = v.boss_id
				break
			end
		end
	end
	return customs_id
end

-- 更新元素圣殿红点
function ElementModel:updateLadderRedStatus( )
	self.red_status = false
	if self.element_data and self.element_data.num > 0 then
		self.red_status = true
	end
	-- 更新主界面图标红点

	local status = AdventureActivityController:getInstance():isOpenActivity(AdventureActivityConst.Ground_Type.element)
    if status == false then
        self.red_status = false
    end
	MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.adventure, {bid = AdventureActivityConst.Red_Type.element, status = self.red_status})
	-- 更新天梯界面红点
	GlobalEvent:getInstance():Fire(ElementEvent.Update_Element_Red_Status, self.red_status)
end

-- 判断元素圣殿红点状态
function ElementModel:checkElementRedStatus(  )
	return self.red_status
end

-- 元素圣殿是否开启
function ElementModel:checkElementIsOpen( not_tips )
	local role_vo = RoleController:getInstance():getRoleVo()
	local open_cfg = Config.ElementTempleData.data_const["join_lev"]
	local is_open = true
	if open_cfg and open_cfg.val > role_vo.lev then
		is_open = false
		if not not_tips then
			message(open_cfg.desc)
		end
	end
	return is_open
end

function ElementModel:__delete()
end