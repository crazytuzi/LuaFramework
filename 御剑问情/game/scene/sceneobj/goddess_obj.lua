Goddess = Goddess or BaseClass(FollowObj)

function Goddess:__init(vo)
	self.obj_type = SceneObjType.Goddess
	self.draw_obj:SetObjType(self.obj_type)
	self.goddess_res_id = 0
	self.goddess_wing_res_id = 0
	self.goddess_shen_gong_res_id = 0
	self.is_goddess = true
	self:SetObjId(vo.obj_id)
	self.is_visible = true

	self.follow_offset = 2
	self.is_wander = true
	self.mass = 0.5
	self.wander_cd = 7
	self.anim_name = SceneObjAnimator.Atk1

	self.regain_wander_time = 20			--玩家攻击状态停止之后，随机漫步恢复时间
	self.wander_quest_delay_time = 0.2		--随机漫步控制计时器调用间隔时间
	self.cur_regain_wander_time = 0

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

	if self.is_wander_ctrl_timer_quest then
		GlobalTimerQuest:CancelQuest(self.is_wander_ctrl_timer_quest)
		self.is_wander_ctrl_timer_quest = nil
	end

end

function Goddess:InitShow()
	FollowObj.InitShow(self)
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
		self:ChangeModel(SceneObjPart.FaZhen, ResPath.GetGoddessWingModel(self.goddess_wing_res_id))
	end

	if self.goddess_shen_gong_res_id ~= nil and self.goddess_shen_gong_res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Halo, ResPath.GetGoddessWeaponModel(self.goddess_shen_gong_res_id))
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
		self:ChangeModel(SceneObjPart.FaZhen, ResPath.GetGoddessWingModel(self.goddess_wing_res_id))
	elseif key == "goddess_shen_gong_id" then
		self:UpdateShenGongResId()
		self:ChangeModel(SceneObjPart.Halo, ResPath.GetGoddessWeaponModel(self.goddess_shen_gong_res_id))
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
			res_id = ShenyiData.Instance:GetShenyiImageCfg()[self.vo.goddess_wing_id].res_id
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
			res_id = ShengongData.Instance:GetShengongImageCfg()[self.vo.goddess_shen_gong_id].res_id
		end
		self.goddess_shen_gong_res_id = res_id
		-- self.goddess_shen_gong_res_id = 12000 + self.vo.goddess_shen_gong_id
	end
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

function Goddess:DoAttack(skill_id, target_x, target_y, target_obj_id, target_type)
	self.anim_name = GoddessData.Instance:IsGoddessSkill(skill_id) and SceneObjAnimator.Atk2 or SceneObjAnimator.Atk1
	Character.DoAttack(self, skill_id, target_x, target_y, target_obj_id, target_type)
	--随机漫步控制
	if self.is_wander_ctrl_timer_quest == nil then
		self.is_wander_ctrl_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.IsWanderUpdate, self), self.wander_quest_delay_time)
	end
end

function Goddess:EnterStateAttack()
	Character.EnterStateAttack(self, self.anim_name)
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

function Goddess:IsWanderUpdate()
	local target = Scene.Instance:GetObjectByObjId(self.owner_obj_id)  --获取主人obj
	if target == nil or not target.IsAtkPlaying then 
		self:CancelIsWanderTimer()
		return
	end
	if target:IsAtkPlaying() then
		self.is_wander = false									--取消随机漫步
		self.cur_regain_wander_time = self.regain_wander_time 	--重置随机漫步恢复时间
	else
		self.cur_regain_wander_time = self.cur_regain_wander_time - self.wander_quest_delay_time  --随机漫步恢复时间倒数
		if self.cur_regain_wander_time <= 0 then
			self.cur_regain_wander_time = 0
			self.is_wander = true 								--恢复随机漫步
			--取消随机漫步计时器
			self:CancelIsWanderTimer()
		end
	end
end

--取消随机漫步计时器
function Goddess:CancelIsWanderTimer()
	if self.is_wander_ctrl_timer_quest then
		GlobalTimerQuest:CancelQuest(self.is_wander_ctrl_timer_quest)
		self.is_wander_ctrl_timer_quest = nil
	end
end