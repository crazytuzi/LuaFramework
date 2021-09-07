
Beauty = Beauty or BaseClass(Character)

-- 美人
function Beauty:__init(vo)
	self.obj_type = SceneObjType.BeautyObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(vo.beauty_used_seq)
	self.vo = vo
	self.beauty_res_id = 0
	self.beauty_halo_id = 0
	self.beauty_wing_res_id = 0
	self.beauty_shen_gong_res_id = 0
	self.is_active_shenwu = vo.beauty_is_active_shenwu
	self.vo.move_speed = self.vo.move_speed - 100
	self.origin_speed = self.vo.move_speed
	self.obj_speed = self.vo.move_speed
	self.peri_next_update_time = 0
	self.do_move_time = 0
	self.hit_num = 1
end

function Beauty:__delete()
	self.peri_next_update_time = nil
	self.do_move_time = nil
	self.obj_type = nil
	self.obj_speed = nil
	self.origin_speed = nil
	self.load_call_back = nil
end

function Beauty:InitShow()
	Character.InitShow(self)
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)
	self:UpdateModelResId()
	self:UpdateHaloResId()
	-- self.draw_obj:GetSceneObj():GetFollowUi():SetHpVisiable(false) -- 美人屏蔽followUI

	-- if self.draw_obj then
	-- 	if not self.draw_obj:IsDeleted() then
	-- 		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	-- 		if main_part then
	-- 			local complete_func = function(part, obj)
	-- 				if part == SceneObjPart.Main then
	-- 					local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	-- 					if main_part then
	-- 						main_part:SetTrigger("ShowSceneIdle")
	-- 					end
	-- 				end

	-- 				self:OnModelLoaded(part, obj)
	-- 			end
	-- 			self.draw_obj:SetLoadComplete(complete_func)
	-- 		end
	-- 	end
	-- end
end

function Beauty:UpdateModelResId()
	local beauty_data = BeautyData.Instance
	if self.vo.beauty_used_seq > -1 then
		if beauty_data then
			local beauty_config = beauty_data:GetBeautyActiveInfo(self.vo.beauty_used_seq)
			if beauty_config then
				self.beauty_res_id = beauty_config.model
			end
		end
		local beauty_used_huanhua = self.vo.beauty_used_huanhua_seq
		if beauty_used_huanhua > -1 then
			if beauty_data then
				local data = beauty_data:GetBeautyHuanhuaCfg(self.vo.beauty_used_huanhua_seq)
				if data ~= nil then
					self.beauty_res_id = data.model
				end
			end
			--self.beauty_res_id = 11001 + self.vo.beauty_used_huanhua_seq
		end
	end

	if self.beauty_res_id ~= nil and self.beauty_res_id ~= 0 then
		local asset, bundle = ResPath.GetGoddessNotLModel(self.beauty_res_id)
		self:ChangeModel(SceneObjPart.Main, asset, bundle, BindTool.Bind(self.SetShenwuShow, self))
	end
end

function Beauty:UpdateHaloResId(id)
	local check_id = id or self.vo.jingling_guanghuan_img_id
	if check_id > 0 then
		local cfg = nil
		if check_id > 1000 then
			cfg = BeautyHaloData.Instance:GetSpecialImageCfg(check_id - 1000)
		else
			cfg = BeautyHaloData.Instance:GetImageListInfo(check_id)
		end
		if cfg ~= nil then
			self.beauty_halo_id = cfg.res_id
		end
	end
	if self.beauty_halo_id ~= nil and self.beauty_halo_id ~= "" then
		self:ChangeModel(SceneObjPart.Halo, ResPath.GetNvShenHaloModel(self.beauty_halo_id))
	end
end

function Beauty:SetShenwuShow()
	self:UpShenwuShow(AttachPoint.Weapon, self.is_active_shenwu == 1)
	self:UpShenwuShow(AttachPoint.Weapon2, self.is_active_shenwu == 1)
end

function Beauty:UpShenwuShow(point, bool)
	if self.draw_obj == nil then
		return
	end
	
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local attach_point = part:GetAttachPoint(point)
	if nil ~= attach_point then
		attach_point.gameObject:SetActive(bool)
	end
end

function Beauty:SetAttr(key, value)
	Character.SetAttr(self, key, value)
	if key == "beauty_used_seq" then
		self:UpdateModelResId()
	elseif key == "beauty_is_active_shenwu" then
		self.is_active_shenwu = value
		self:SetShenwuShow()
	elseif key == "beauty_used_huanhua_seq" then
		self:UpdateModelResId()
	elseif key == "beauty_used_halo_seq" then
		self:UpdateHaloResId(value)
		if self.beauty_halo_id ~= nil and self.beauty_halo_id ~= "" then
			self:ChangeModel(SceneObjPart.Halo, ResPath.GetNvShenHaloModel(self.beauty_halo_id))
		end
	end
end

function Beauty:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)

	if self.peri_next_update_time and now_time >= self.peri_next_update_time then
		self.peri_next_update_time = now_time + 0.02
		local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
		if nil ~= obj and obj:IsRole() and obj:GetRoleId() == self.vo.owner_role_id then
			if obj:GetVo().move_speed ~= self.obj_speed then
				self.origin_speed = obj:GetVo().move_speed - 100
				self.obj_speed = obj:GetVo().move_speed
			end
			if obj:IsStand() and self:IsStand() then
				if self.do_move_time < now_time then
					local target_x, target_y = math.random(-8,8), math.random(-8,8)
					local obj_x, obj_y = obj:GetLogicPos()
					target_x = obj_x + target_x
					target_y = obj_y + target_y
					if not AStarFindWay:IsBlock(target_x, target_y) then
						self:DoMove(target_x, target_y)
						local part = self.draw_obj:GetPart(SceneObjPart.Main)
						self.do_move_time = now_time + 5
					end
				end
			end
		end
		self:CheckMove()
	end
end

-- 检查是否需要移动，返回是否移动
function Beauty:CheckMove()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	if nil == obj or not obj:IsRole() or obj:GetRoleId() ~= self.vo.owner_role_id then
		return false
	end
	local target_transfrom = obj:GetRoot().transform
	if nil == target_transfrom then
		return false
	end
	local target_x, target_y = target_transfrom.position.x, target_transfrom.position.z
	local self_transform = self:GetRoot().transform
	if nil == self_transform then
		return false
	end
	local self_x, self_y = self_transform.position.x, self_transform.position.z
	target_x, target_y = GameMapHelper.WorldToLogic(target_x, target_y)
	self_x, self_y = GameMapHelper.WorldToLogic(self_x, self_y)

	local delta_pos = u3d.vec2(target_x - self_x, target_y - self_y)
	self.distance = math.floor(u3d.v2Length(delta_pos))
	target_x, target_y = AStarFindWay:GetTargetXY(self_x, self_y, target_x, target_y, 1)
	if self.distance > 9 then
		local x, y = math.random(1,5), math.random(1,5)
		if self.distance < 20 and self.distance > 10 then
			self.vo.move_speed = self.vo.move_speed + 0.5 * self.distance
		elseif self.distance <= 10 then
			self.vo.move_speed = self.origin_speed
		end
		if self.distance > 20 then
			self:ChangeToCommonState()
			self:SetLogicPos(target_x + x, target_y + y)
			return
		end
		self:DoMove(target_x + x, target_y + y)
		return true
	end
	return false
end

function Beauty:GetOwerRoleId()
	return self.vo.owner_role_id
end

function Beauty:MoveEnd()
	if nil == self.distance then
		return false
	end
	return self.distance <= 9
end

function Beauty:IsBeautyVisible()
	return true
end

function Beauty:SetBeautyVisible(is_visible)
	self.is_visible = is_visible
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)
		-- if is_visible then
		-- 	self:GetFollowUi():Show()
		-- else
		-- 	self:GetFollowUi():Hide()
		-- end
	end
end

function Beauty:IsMyBeauty()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		return true
	end
	return false
end
function Beauty:SetIsSkill(position)
	if self.draw_obj == nil then
		return
	end
	local deliverer_position = self.draw_obj:GetRootPosition()
	if position then
		local direction = position - deliverer_position
		direction.y = 0
		if direction.x == 0 and direction.z == 0 then return end
		self.draw_obj:GetRoot().transform.localRotation = Quaternion.LookRotation(direction)
		-- local pos = Quaternion.LookRotation(direction)
		-- self.draw_obj:GetRoot().transform:DOLocalRotate(Vector3(pos.x, pos.y, pos.z), 0.2)
	end
end

function Beauty:EnterStateAttack()
	local anim_name = SceneObjAnimator.Atk1
	Character.EnterStateAttack(self, anim_name)
end

function Beauty:EnterStateMove()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:SetInteger("status", ActionStatus.Run)
end

function Beauty:EnterStateStand()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	math.randomseed(os.time())
	local value = math.random(1, 4)
	if value ~= 1 then
		part:SetInteger("status", 22)
	else
		part:SetInteger("status", ActionStatus.Idle)
	end
end