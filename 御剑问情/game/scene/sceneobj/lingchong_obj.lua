LingChongObj = LingChongObj or BaseClass(FollowObj)

function LingChongObj:__init(vo)
	self.obj_type = SceneObjType.LingChongObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(vo.obj_id)
	self.is_visible = true

	self.lingchong_res_id = 0
	self.linggong_res_id = 0
	self.lingqi_res_id = 0

	self.follow_offset = 0
	self.is_wander = true
	self.mass = 0.5
	self.wander_cd = 7
end

function LingChongObj:__delete()
	self:CanelRecovWanderTimeQuest()
end

function LingChongObj:ChangeVisible(is_visible)
	self.is_visible = is_visible

	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)

		if is_visible then
			self:UpdateResId()
			self:ChangeLingChongModel()
			self:ChangeLingGongModel()
			self:ChangeLingQiModel()
		end
	end

	self:UpdateFollowUi()
end

function LingChongObj:InitShow()
	FollowObj.InitShow(self)

	self:UpdateFollowUi()

	self:UpdateResId()

	self:ChangeLingChongModel()
	self:ChangeLingGongModel()
	self:ChangeLingQiModel()
end

function LingChongObj:UpdateResId()
	self.lingchong_res_id = LingChongData.Instance:GetResIdByImageId(self.vo.lingchong_used_imageid)
	self.linggong_res_id = LingGongData.Instance:GetResIdByImageId(self.vo.linggong_used_imageid)
	self.lingqi_res_id = LingQiData.Instance:GetResIdByImageId(self.vo.lingqi_used_imageid)
end

function LingChongObj:SetAttr(key, value)
	Character.SetAttr(self, key, value)

	if key == "lingchong_used_imageid" then
		self.lingchong_res_id = LingChongData.Instance:GetResIdByImageId(value)
		self:ChangeLingChongModel()

		local name = ""
		local image_cfg_info = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(value)
		if image_cfg_info then
			name = image_cfg_info.image_name
		end
		self.vo.name = name

		self:ReloadUIName()

	elseif key == "linggong_used_imageid" then
		self.linggong_res_id = LingGongData.Instance:GetResIdByImageId(value)
		self:ChangeLingGongModel()

	elseif key == "lingqi_used_imageid" then
		self.lingqi_res_id = LingQiData.Instance:GetResIdByImageId(value)
		self:ChangeLingQiModel()
	end
end

function LingChongObj:UpdateFollowUi()
	local follow_ui = self:GetFollowUi()
	if follow_ui then
		follow_ui:SetHpVisiable(false)
		if self.is_visible then
			follow_ui:Show()
		else
			follow_ui:Hide()
		end
	end
end

function LingChongObj:ChangeLingChongModel()
	if self.lingchong_res_id <= 0 or not self.is_visible then
		self:RemoveModel(SceneObjPart.Main)
		return
	end

	local bundle, asset = ResPath.GetLingChongModel(self.lingchong_res_id)
	self:ChangeModel(SceneObjPart.Main, bundle, asset)
end

function LingChongObj:ChangeLingGongModel()
	if self.linggong_res_id <= 0 or not self.is_visible then
		self:RemoveModel(SceneObjPart.Weapon)
		return
	end

	local bundle, asset = ResPath.GetLingGongModel(self.linggong_res_id)
	self:ChangeModel(SceneObjPart.Weapon, bundle, asset)
end

function LingChongObj:ChangeLingQiModel()
	if self.lingqi_res_id <= 0 or not self.is_visible then
		self:RemoveModel(SceneObjPart.Mount)
		return
	end

	local bundle, asset = ResPath.GetLingQiModel(self.lingqi_res_id)
	self:ChangeModel(SceneObjPart.Mount, bundle, asset)
end

function LingChongObj:GetOwerRoleId()
	return self.vo.owner_role_id
end

--是否自己的灵宠
function LingChongObj:IsMainRoleLingChong()
	return self.vo.owner_is_mainrole
end

--是否灵宠
function LingChongObj:IsLingChong()
	return true
end

function LingChongObj:DoAttack(target_x, target_y, target_obj_id)
	if not self.is_visible then
		return
	end

	local target_obj = Scene.Instance:GetObj(target_obj_id)
	if target_obj ~= nil and nil ~= self.draw_obj then
		self.is_wander = false
		self:StopMove()

		local target = target_obj:GetRoot().transform
		local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
		main_part:SetAttackTarget(target)

		local target_x, target_y = target_obj:GetLogicPos()
		self:SetDirectionByXY(target_x, target_y)

		main_part:SetTrigger(LINGCHONG_ANIMATOR_PARAM.FIGHT)

		self:CanelRecovWanderTimeQuest()
		self.recov_wander_time_quest = GlobalTimerQuest:AddDelayTimer(function()
			self:RecovWander()
		end, 2)
	end
end

function LingChongObj:CanelRecovWanderTimeQuest()
	if self.recov_wander_time_quest then
		GlobalTimerQuest:CancelQuest(self.recov_wander_time_quest)
		self.recov_wander_time_quest = nil
	end
end

--恢复随机漫步
function LingChongObj:RecovWander()
	self.is_wander = true
end

function LingChongObj:EnterStateAttack()
end

function LingChongObj:UpdateStateAttack()
end

function LingChongObj:QuitStateAttack()
end

function LingChongObj:EnterStateStand()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger(LINGCHONG_ANIMATOR_PARAM.STATUS, 0)
	end
end

function LingChongObj:EnterStateMove()
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger(LINGCHONG_ANIMATOR_PARAM.STATUS, 1)
	end
end

function LingChongObj:UpdateStateMove(elapse_time)
	if self.delay_end_move_time > 0 then
		if Status.NowTime >= self.delay_end_move_time then
			self.delay_end_move_time = 0
			self:ChangeToCommonState()
		end
		return
	end

	if self.draw_obj then
		--移动状态更新
		local distance = elapse_time * self:GetMoveSpeed()
		self.move_pass_distance = self.move_pass_distance + distance

		if self.move_pass_distance >= self.move_total_distance then
			self.is_special_move = false
			self:SetRealPos(self.move_end_pos.x, self.move_end_pos.y)

			if self:MoveEnd() then
				self.move_pass_distance = 0
				self.move_total_distance = 0
				self.delay_end_move_time = Status.NowTime + 0.2
			end
		else
			local mov_dir = u3d.v2Mul(self.move_dir, distance)
			self:SetRealPos(self.real_pos.x + mov_dir.x, self.real_pos.y + mov_dir.y)
		end
	end
end

function LingChongObj:QuitStateMove()
	self.draw_obj:StopMove()
end