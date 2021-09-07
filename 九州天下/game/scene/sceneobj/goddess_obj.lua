Goddess = Goddess or BaseClass(Character)

function Goddess:__init(vo)
	self.obj_type = SceneObjType.Goddess
	self.draw_obj:SetObjType(self.obj_type)
	self.goddess_res_id = 0
	self.goddess_wing_res_id = 0
	self.goddess_shen_gong_res_id = 0
	self.vo.move_speed = self.vo.move_speed - 300
	self.is_goddess = true
	self.do_move_time = 0
	self:SetObjId(vo.obj_id)
	self.is_visible = true
end

function Goddess:__delete()
	if self.bobble_timer_quest then
		GlobalTimerQuest:CancelQuest(self.bobble_timer_quest)
		self.bobble_timer_quest = nil
	end

	if self.release_timer then
		GlobalTimerQuest:CancelQuest(self.release_timer)
		self.release_timer = nil
	end
end

function Goddess:InitShow()
	Character.InitShow(self)
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)
	self:UpdateModelResId()
	self:UpdateWingResId()
	self:UpdateShenGongResId()
	self:ShowFollowUi()
	self:ShowFirstBubble()
	self.follow_ui:SetHpVisiable(false)
	if self.goddess_res_id ~= nil and self.goddess_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGoddessNotLModel(self.goddess_res_id))
	end

	if self.goddess_wing_res_id ~= nil and self.goddess_wing_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Wing, ResPath.GetGoddessWingModel(self.goddess_wing_res_id))
	end

	if self.goddess_shen_gong_res_id ~= nil and self.goddess_shen_gong_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Weapon, ResPath.GetGoddessWeaponModel(self.goddess_shen_gong_res_id))
	end

	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				local complete_func = function(part, obj)
					if part == SceneObjPart.Main then
						local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
						if main_part then
							main_part:SetTrigger("ShowSceneIdle")
						end
						local transform = self.draw_obj:GetRoot().transform
						transform.localScale = Vector3(0.9, 0.9, 0.9)
					end

					self:OnModelLoaded(part, obj)
				end
				self.draw_obj:SetLoadComplete(complete_func)
			end
		end
	end
end

function Goddess:SetAttr(key, value)
	Character.SetAttr(self, key, value)
	if key == "use_xiannv_id" then
		self:UpdateModelResId()
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGoddessNotLModel(self.goddess_res_id))
	elseif key == "goddess_wing_id" then
		self:UpdateWingResId()
		self:ChangeModel(SceneObjPart.Wing, ResPath.GetGoddessWingModel(self.goddess_wing_res_id))
	elseif key == "goddess_shen_gong_id" then
		self:UpdateShenGongResId()
		self:ChangeModel(SceneObjPart.Weapon, ResPath.GetGoddessWeaponModel(self.goddess_shen_gong_res_id))
	elseif key == "name" then
		self:ReloadUIName()
	elseif key == "xiannv_huanhua_id" then
		self:UpdateHuanhuaModelResId()
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGoddessNotLModel(self.goddess_res_id))
	end
end

function Goddess:UpdateModelResId()
	local goddess_data = GoddessData.Instance
	if self.vo.use_xiannv_id > -1 then
		local goddess_config = goddess_data:GetXianNvCfg(self.vo.use_xiannv_id)
		if goddess_config then
			local resid = goddess_config.resid
			if resid then
				self.goddess_res_id = resid
			end
		end
		local xiannv_huanhua_id = self.vo.xiannv_huanhua_id
		if xiannv_huanhua_id > -1 then
			local cfg = goddess_data:GetXianNvHuanHuaCfg(xiannv_huanhua_id)
			if cfg then
				self.goddess_res_id = goddess_data:GetXianNvHuanHuaCfg(xiannv_huanhua_id).resid
			end
		end
	end
end

function Goddess:UpdateHuanhuaModelResId()
	local xiannv_huanhua_id = self.vo.xiannv_huanhua_id
	if xiannv_huanhua_id > -1 then
		local goddess_config = GoddessData.Instance:GetXianNvHuanHuaCfg(xiannv_huanhua_id)
		if goddess_config then
			local resid = goddess_config.resid
			if resid then
				self.goddess_res_id = resid
			end
		end
	end
end

function Goddess:CanHideFollowUi()
	return false
end

function Goddess:UpdateWingResId()
	if self.vo.goddess_wing_id and self.vo.goddess_wing_id ~= 0 then
		local res_id = 0
		if self.vo.goddess_wing_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = ShenyiData.Instance:GetSpecialImagesCfg()[self.vo.goddess_wing_id - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			local shenyi_cfg = ShenyiData.Instance:GetShenyiImageCfg(self.vo.goddess_wing_id)
			res_id = shenyi_cfg ~= nil and shenyi_cfg.res_id or 0
			--res_id = ShenyiData.Instance:GetShenyiImageCfg()[self.vo.goddess_wing_id].res_id
		end
		self.goddess_wing_res_id = res_id
	end
end

function Goddess:UpdateShenGongResId()
	if self.vo.goddess_shen_gong_id and self.vo.goddess_shen_gong_id ~= 0 then
		local res_id = 0
		if self.vo.goddess_shen_gong_id >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = ShengongData.Instance:GetSpecialImagesCfg()[self.vo.goddess_shen_gong_id - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			local shengong_cfg = ShengongData.Instance:GetShengongImageCfg(self.vo.goddess_shen_gong_id)
			res_id = shengong_cfg ~= nil and shengong_cfg.res_id or 0
			--res_id = ShengongData.Instance:GetShengongImageCfg()[self.vo.goddess_shen_gong_id].res_id
		end
		self.goddess_shen_gong_res_id = res_id
		-- self.goddess_shen_gong_res_id = 12000 + self.vo.goddess_shen_gong_id
	end
end

function Goddess:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	if nil ~= obj and obj:IsRole() and obj:GetRoleId() == self.vo.owner_role_id then
		if obj:IsStand() and self:IsStand() then
			if self.do_move_time < now_time and (nil == self.follow_ui or not self.follow_ui.bubble_vis) then
				local target_x, target_y = math.random(-10,10), math.random(-10,10)
				local obj_x, obj_y = obj:GetLogicPos()
				target_x = obj_x + target_x
				target_y = obj_y + target_y
				if not AStarFindWay:IsBlock(target_x, target_y) then
					self:DoMove(target_x, target_y)
					self.do_move_time = now_time + 5
				end
			end
		end
	end
	self:CheckMove()
end


function Goddess:CheckMove()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	if nil == obj or not obj:IsRole() or obj:GetRoleId() ~= self.vo.owner_role_id then
		return false
	end

	self.vo.move_speed = obj:GetVo().move_speed

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
	local distance = math.floor(u3d.v2Length(delta_pos))

	target_x, target_y = AStarFindWay:GetTargetXY(self_x, self_y, target_x, target_y, 1)

	local base_speed = 100
	if obj:IsJump() then
		base_speed = 400
	end

	if distance <= 15 then
		if obj:IsMove() or obj:IsJump() then
			self.vo.move_speed = self.vo.move_speed + (distance - 8) * base_speed
			self:DoMove(target_x, target_y)
		end
	else
		self:SetLogicPos(target_x, target_y)
	end

	return true
end

function Goddess:IsCharacter()
	return false
end

function Goddess:GetOwerRoleId()
	return self.vo.owner_role_id
end

function Goddess:SetTrigger(key)
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local main_part = draw_obj:GetPart(SceneObjPart.Main)
		local weapon_part = draw_obj:GetPart(SceneObjPart.Weapon)
		if main_part then
			main_part:SetTrigger(key)
		end
		if weapon_part then
			weapon_part:SetTrigger(key)
		end
	end
end

function Goddess:SetBool(key, value)
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local main_part = draw_obj:GetPart(SceneObjPart.Main)
		local weapon_part = draw_obj:GetPart(SceneObjPart.Weapon)
		if main_part then
			main_part:SetBool(key, value)
		end
		if weapon_part then
			weapon_part:SetBool(key, value)
		end
	end
end

function Goddess:SetInteger(key, value)
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local main_part = draw_obj:GetPart(SceneObjPart.Main)
		local weapon_part = draw_obj:GetPart(SceneObjPart.Weapon)
		if main_part then
			main_part:SetInteger(key, value)
		end
		if weapon_part then
			weapon_part:SetInteger(key, value)
		end
	end
end

function Goddess:DoAttack(...)
	Character.DoAttack(self, ...)
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local weapon_part = draw_obj:GetPart(SceneObjPart.Weapon)
		if weapon_part then
			weapon_part:SetTrigger(SceneObjAnimator.Atk1)
		end
	end
end

function Goddess:EnterStateAttack()
	local anim_name = SceneObjAnimator.Atk1
	Character.EnterStateAttack(self, anim_name)
end

function Goddess:IsGoddess()
	return true
end

function Goddess:IsGoddessVisible()
	return self.is_visible
end

function Goddess:SetGoddessVisible(is_visible)
	self.is_visible = is_visible
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)
		if is_visible then
			self:GetFollowUi():Show()
		else
			self:GetFollowUi():Hide()
		end

	end
end

function Goddess:GetRandBubbletext()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_goddess_list

	local temp_list = {}
	for k,v in pairs(bubble_cfg) do
		if v.goddess_scene_id == 0 then
			table.insert(temp_list,v)
		end
	end

	if #temp_list > 0 then
		math.randomseed(os.time())
		local bubble_text_index = math.random(1, #temp_list)
		return temp_list[bubble_text_index].bubble_goddess_text
	else
		return ""
	end
end

function Goddess:GetFirstBubbleText()
	local bubble_cfg = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").bubble_goddess_list
	local scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(bubble_cfg) do
		if v.goddess_scene_id == scene_id then
			return v.bubble_goddess_text
		end
	end
end

function Goddess:ShowFirstBubble()
	if nil == self.release_timer then
		self.release_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.release_timer = nil
			if nil ~= self.follow_ui and self:IsMyGoddess() then
				local text = self:GetFirstBubbleText()
				if nil ~= text then
					self.follow_ui:ChangeBubble(text)
				end
			end
			self:UpdataTimer()
		end, 1)
	end
end

function Goddess:UpdataBubble()
	if nil ~= self.follow_ui then
		local text = self:GetRandBubbletext()
		self.follow_ui:ChangeBubble(text)
	end
end

function Goddess:UpdataTimer()
	local exist_time = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].exist_time
	local goddess_interval = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].goddess_interval
	self.bobble_timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:UpdataTimer() end, exist_time)
	if self.timer and nil ~= self.follow_ui and self:IsMyGoddess() then
		if self.timer >= goddess_interval then
			self.timer = self.timer - goddess_interval
			local rand_num = math.random(1, 10)
			local goddess_odds = ConfigManager.Instance:GetAutoConfig("bubble_list_auto").other[1].goddess_odds
			if rand_num * 0.1 <= goddess_odds then
				self:UpdataBubble()
				self.follow_ui:ShowBubble()
			end
		else
			self.follow_ui:HideBubble()
		end
	end
	self.timer = self.timer and self.timer + exist_time or exist_time
end

function Goddess:IsMyGoddess()
	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if nil ~= obj and obj:IsRole() and role_id == self.vo.owner_role_id then
		return true
	end
	return false
end