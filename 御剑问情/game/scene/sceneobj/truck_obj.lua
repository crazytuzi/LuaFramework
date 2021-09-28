TruckObj = TruckObj or BaseClass(FollowObj)

-- 镖车
function TruckObj:__init(truck_vo)
	self.obj_type = SceneObjType.TruckObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(truck_vo.obj_id)
	self.vo = truck_vo

	self.peri_next_update_time = 0

	self.res_id = 2044001
	self.is_truck = true

	self.mass = 1
	self.sqrt_slow_down_distance = 8 * 8
	self.sqrt_stop_distance = 4 * 4
	self:SetMaxSpeed(10)
end

function TruckObj:__delete()
end

function TruckObj:InitShow()
	FollowObj.InitShow(self)


	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)
	self.res_id = 2044000 + self.vo.truck_color
	self.name = self.vo.name

	local task_reward_factor_list = ConfigManager.Instance:GetAutoConfig("husongcfg_auto").task_reward_factor_list
	
	if self.res_id ~= nil and self.res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetNpcModel(task_reward_factor_list[YunbiaoData.Instance:GetTaskColor()].show_model))
	end
end

-- 镖车不可战斗
function TruckObj:IsCharacter()
	return false
end

function TruckObj:GetOwerRoleId()
	return self.vo.owner_role_id
end

function TruckObj:IsTruck()
	return true
end