--
-- @Author: LaoY
-- @Date:   2019-01-10 10:38:17
-- 附属对象基类
DependObjcet = DependObjcet or class("DependObjcet",SceneObject)
function DependObjcet:ctor(owner_id,actor_type,index,be_depend_object)
	self.owner_id = owner_id
	self.object_type = actor_type
	self.depend_index = index
	self.be_depend_object = be_depend_object

	if self.owner_info and self.owner_info.name then
		self.parent_node.name = self.owner_info.name .. "_" .. self.__cname .. "_" .. self.depend_index
	end
	
	self.check_owner_time = os.clock()
	self.last_check_pos = {x = 0,y = 0}
	self.stop_count_time = 0
	self.stop_check_offset_time = 3
	self.name_container:SetVisible(false)
	
	self.follow_speed = Vector2(0,0)
	self.follow_dir = Vector2(0,0)
	self.check_follow_range_square = 200 * 200
	self.smooth_time = 0.6
	
	self:InitMachine()
	-- self:SetPosition(self:GetRandomPosition())

	if self.is_main_role then
		local scene_obj_layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneObj)
	    if scene_obj_layer then
	        self.parent_transform:SetParent(scene_obj_layer)
	    else
	        logWarn("SceneObj is nil........................")
	    end
	end
end

function DependObjcet:InitData(owner_id,actor_type,index,be_depend_object)
	self.owner_id = owner_id
	self.owner_info = SceneManager:GetInstance():GetObjectInfo(owner_id)
	self.owner_object = SceneManager:GetInstance():GetObject(owner_id)
	self.is_main_role = self.owner_object == SceneManager:GetInstance():GetMainRole()

	self.owner_info_event_list = {}
	self.global_event_list = {}

	self.be_depend_object = be_depend_object
end

function DependObjcet:AddEvent()

end

function DependObjcet:InitMachine()
	self:RegisterMachineState(SceneConstant.ActionName.idle, true)
end

function DependObjcet:CreateBodyModel(abName,assetName,is_inore_animator)
	if self.depend_assetName == assetName then
		return
	end
	self.transform_layer_is_self = nil
	-- poolMgr:AddConfig(abName,assetName,Constant.CacheRoleObject,0,false)
	poolMgr:AddConfig(abName, assetName, 1, Constant.InPoolTime * 0.5, false)
	DependObjcet.super.CreateBodyModel(self,abName,assetName,is_inore_animator)
	self.depend_assetName = assetName

	local cf = Config.db_res_scale[self.depend_assetName]
	if cf then
		self:SetScale(cf.scale * 0.01)
	end
end

function DependObjcet:dctor()
	if self.owner_info_event_list then
		self.owner_info:RemoveTabListener(self.owner_info_event_list)
		self.owner_info_event_list = {}
	end
	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end
end

function DependObjcet:LoadBodyCallBack()
	-- self:SetPosition()
end

function DependObjcet:GetRandomPosition()
	local range = math.sqrt(self.check_follow_range_square)
	range = range - 1
	local angle = math.random(360)
	local vec = GetVectorByAngle(angle)
	vec = vec * range
	local x,y = self:GetCenterPosition()
	return x + vec.x,y+vec.y
end

function DependObjcet:SetFollowOffset(angle)
	local range = math.sqrt(self.check_follow_range_square)
	range = range - 1
	angle = angle + self.owner_object.direction_angle
	local vec = GetVectorByAngle(angle)
	self.follow_dir = vec * range
end

function DependObjcet:SetPosition(x,y)
	self.position.x = x
	self.position.y = y
	self.position.z = self:GetDepth(y)
	self:CheckNextBlock(x,y)
	if self.is_loaded then
		local world_pos = {x = self.position.x/SceneConstant.PixelsPerUnit,y = self.position.y/SceneConstant.PixelsPerUnit}
		SetGlobalPosition(self.parent_transform,world_pos.x,world_pos.y,self.position.z)
	end
	self:SetShadowImagePos()
end

function DependObjcet:GetPosition()
	return self.position
end

function DependObjcet:GetDepth(y)
	return DependObjcet.super.GetDepth(self,y)
	-- if self.body_pos then
	-- 	return DependObjcet.super.GetDepth(self,y+self.body_pos.y)
	-- else
	-- 	return DependObjcet.super.GetDepth(self,y)
	-- end
end

function DependObjcet:GetCenterPosition()
	local pos = self.owner_object.rush_pos or self.owner_object.position
	-- local pos = self.owner_object.position
	return pos.x,pos.y
end

function DependObjcet:GetFollowPosition()
	local pos = self.owner_object.position
	return pos.x + self.follow_dir.x,pos.y + self.follow_dir.y
end

function DependObjcet:AttackCallBack()
	self:ChangeToMachineDefalutState()
    return false
end

function DependObjcet:CheckWaitAttackCombo(skill_id)
    return false
end

function DependObjcet:FollowOwner(deltaTime)
	local from = self:GetPosition()
	from = Vector2(from.x,from.y)
	local to = Vector2(self:GetCenterPosition())
	if from.x == to.x and from.y == to.y then
		return
	end
	self:SetRotateY(GetAngleByPosition(self.position,self.owner_object.position))
	local dis = Vector2.DistanceNotSqrt(from,to)
	if dis <= 2*2 then
		self.is_update_offset = false
		self:SetPosition(to.x,to.y)
		return
	end
	
	local smoothTime = self.smooth_time
	if dis < 15*15 then
		smoothTime = self.smooth_time * 0.2
	end
	local pos,speed = Smooth(from, to, self.follow_speed, smoothTime, deltaTime)
	self.follow_speed = speed
	self:SetPosition(pos.x,pos.y)
end

function DependObjcet:FollowOwnerOffset(deltaTime)
	local from = self:GetPosition()
	from = Vector2(from.x,from.y)
	local to = Vector2(self:GetFollowPosition())
	if from.x == to.x and from.y == to.y then
		return
	end
	self:SetRotateY(GetAngleByPosition(self.position,self.owner_object.position))
	local dis = Vector2.DistanceNotSqrt(from,to)
	if dis <= 1*1 then
		self.is_update_offset = false
		self:SetPosition(to.x,to.y)
		return
	end
	local smoothTime = self.smooth_time
	smoothTime = smoothTime * 1.1
	if dis < 15*15 then
		smoothTime = self.smooth_time * 0.38
	end
	local pos,speed = Smooth(from, to, self.follow_speed, smoothTime, deltaTime)
	self.follow_speed = speed
	self:SetPosition(pos.x,pos.y)
end

function DependObjcet:CheckOwnerPosition()
	-- 0.1秒检测一次
	local cur_time_ms = os.clock()
	if cur_time_ms - self.check_owner_time < 100 then
		return
	end
	self.check_owner_time = cur_time_ms
	local range_square = self.check_follow_range_square
	local vec = Vector2(self:GetCenterPosition())
	local dis = Vector2.DistanceNotSqrt(self.position,vec)
	self.is_need_follow = dis > range_square
end

function DependObjcet:UpdatePosition(deltaTime)
	local x,y = self:GetCenterPosition()
	if self.last_check_pos.x == x and self.last_check_pos.y == y then
		self.stop_count_time = self.stop_count_time + deltaTime
		if (self.is_update_offset or self.stop_count_time > self.stop_check_offset_time)  then
			local to_x,to_y = self:GetFollowPosition()
			if Vector2.DistanceNotSqrt(self.position,{x = to_x,y = to_y}) < self.check_follow_range_square then
				self:FollowOwnerOffset(deltaTime)
			else
				self:FollowOwner(deltaTime)
			end
			-- if (not self.owner_object:IsRunning() and not self.owner_object:IsJumping()) then
			-- else
			-- 	self:FollowOwner(deltaTime)
			-- end
		end
	else
		-- self:SetRotateY(GetAngleByPosition(self.position,self.owner_object.position))
		self.last_check_pos.x = x
		self.last_check_pos.y = y
		self:CheckOwnerPosition()
		if self.is_need_follow  then
			self:FollowOwner(deltaTime)
			self.stop_count_time = 0
			self.is_update_offset = true
		else
			self.is_update_offset = false
			self.stop_count_time = self.stop_count_time + deltaTime
		end
	end

	-- if not self.is_update_offset then
	-- 	self:SetRotateY(GetAngleByPosition(self.position,self.owner_object.position))
	-- end
end

function DependObjcet:CheckAngle()
	if self.check_owner_angle ~= self.owner_object.direction_angle then
		self.check_owner_angle = self.owner_object.direction_angle
		if self.follow_angle then
			self:SetFollowOffset(self.follow_angle)
		end
	end
end

function DependObjcet:UpdateMachineState(state_name, delta_time)
	DependObjcet.super.UpdateMachineState(self,state_name, delta_time)
	self:UpdatePosition(delta_time)
	self:CheckAngle()
end

function DependObjcet:Update(delta_time)
	DependObjcet.super.Update(self,delta_time)
end

function DependObjcet:PlayAttack(skill_vo)
	if self.is_main_role then
		local release_control = false
		if skill_vo then
			release_control = SkillManager:GetInstance():IsReleaseDebuffSkill(skill_vo.skill_id)
		end
		local bo,buff_effect_type = self.owner_object.object_info:IsCanAttackByBuff()
		if not bo and not release_control then
			return
		end
	end
	local bo = DependObjcet.super.PlayAttack(self,skill_vo)
	return bo
end

-- over write
function DependObjcet:OwnerEnterState(state_name)
end

function DependObjcet:UpdateVisible()
	local is_show = true
	if self.visible_state then
		is_show = not self.visible_state:Contain()
	end
	local ower_is_show = true
	if self.owner_object.visible_state then
		ower_is_show = not self.owner_object.visible_state:Contain()
	end
	self:SetTransformLayer(is_show and ower_is_show)
end

function DependObjcet:Remove()
	self:destroy()
end

function DependObjcet:CreateDependObject(actor_type, index)
	if not self:GetDependObject(actor_type, index) then
		SceneManager:GetInstance():AddDependObjcet(self,self.owner_id, actor_type, index)
	end
end

-- function DependObjcet:GetDependObject(actor_type, index)
-- 	return SceneManager:GetInstance():GetDependObject(self, actor_type, index)
-- end

-- -- actor_type 可以不填
-- function DependObjcet:GetDependObjectList(actor_type)
-- 	return SceneManager:GetInstance():GetDependObjectList(self,actor_type)
-- end

-- function DependObjcet:RemoveDependObject(actor_type, index)
-- 	SceneManager:GetInstance():RemoveDependObject(self, actor_type, index)
-- end


 function DependObjcet:ClearFromScene()
	self:RemoveDependObject()
	EffectManager:GetInstance():RemoveAllSceneEffect(self)
end