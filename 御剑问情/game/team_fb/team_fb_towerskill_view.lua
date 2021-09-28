TowerSkillView = TowerSkillView or BaseClass(BaseView)

function TowerSkillView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "TowerSkill"}
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.skill_time1 = 0
	self.skill_time2 = 0
	self.skill_time3 = 0
	self.skill_time4 = 0
end

function TowerSkillView:__delete()

end

function TowerSkillView:LoadCallBack()
	self.skill_type = self:FindVariable("skill_type")
	for i = 1, 4 do
		self:ListenEvent("GongJi" .. i,BindTool.Bind(self.SendSkill, self, i))
		self:ListenEvent("FangYu" .. i,BindTool.Bind(self.SendSkill, self, i))
		self:ListenEvent("FuZhu" .. i,BindTool.Bind(self.SendSkill, self, i))
		self["skill_time_pro" .. i] = self:FindVariable("skill_time_" .. i)
		self["skill_time_text" .. i] = self:FindVariable("skill_time_text" .. i)
		self["hide_text" .. i] = self:FindVariable("hide_text" .. i)
	end
end

function TowerSkillView:ReleaseCallBack()
	for i = 1,4 do
		self:RemoveCountDown(i)
		self["skill_time_pro" .. i] = nil
		self["skill_time_text" .. i] = nil
		self["hide_text" .. i] = nil
	end
	self.skill_type = nil
end

function TowerSkillView:OpenCallBack()
	self:Flush("CD")
end

function TowerSkillView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "CD" then
			self:UpdateSkillTime()
		end
	end
	local team_info = TeamFbData.Instance:GetTeamTowerInfo()
	if nil ~= team_info then
		if team_info.skill_list[1].skill_id <= 7 and team_info.skill_list[1].skill_id > 3 then
			self.skill_type:SetValue(1)
		elseif team_info.skill_list[1].skill_id <= 3 then
			self.skill_type:SetValue(2)
		elseif team_info.skill_list[1].skill_id <= 13 and team_info.skill_list[1].skill_id > 7 then
			self.skill_type:SetValue(3)
		end
	end
end

function TowerSkillView:SendSkill(index)
	local team_skill_list = TeamFbData.Instance:GetSkillCfg()
	local team_info = TeamFbData.Instance:GetTeamTowerInfo()
	local time = 0
	if nil ~= team_info then
		local target_obj = GuajiCtrl.Instance:SelectAtkTarget(false)
		local id = team_info.skill_list[index].skill_id
		if VIRTUAL_SKILL[id] then
			if VIRTUAL_SKILL[id].pos == VIRTUAL_SKILL_EFFECT_POS.MainRole then
				target_obj = Scene.Instance:GetMainRole()
			end
		end

		if nil ~= target_obj then
			local main_role = Scene.Instance:GetMainRole()
			local main_role_x, main_role_y = main_role:GetLogicPos()
			local target_x, target_y = target_obj:GetLogicPos()
			FightCtrl.SendPerformSkillReq(
				index - 1,
				0,
				target_x,
				target_y,
				target_obj:GetObjId(),
				true,
				main_role_x,
				main_role_y)
		end
		self:PlaySkillAnim(id, target_obj)
	end
end

function TowerSkillView:PlaySkillAnim(skill_id, target_obj)
	local skill_cfg = VIRTUAL_SKILL[skill_id]
	if skill_cfg then
		local main_role = Scene.Instance:GetMainRole()
		local target = target_obj
		if skill_cfg.pos == VIRTUAL_SKILL_EFFECT_POS.MainRole then
			target = main_role
		end

		if target then
			local part = main_role:GetDrawObj():GetPart(SceneObjPart.Main)
			local part_obj = part:GetObj()
			if part_obj ~= nil and not IsNil(part_obj.gameObject) then
				local animator = part_obj.animator
				animator:SetTrigger("attack5")
			end

			local attach_obj = target:GetRoot()
			if attach_obj then
				local effect = AsyncLoader.New(attach_obj.transform)
				local call_back = function(effect_obj)
					if effect_obj then
						effect_obj.transform.localScale = Vector3(skill_cfg.scale, skill_cfg.scale, skill_cfg.scale)
					end
				end
				effect:Load(skill_cfg.bundle, skill_cfg.asset, call_back)
				GlobalTimerQuest:AddDelayTimer(function() effect:Destroy() effect:DeleteMe() end, 5)
			end
		end
	end
end

function TowerSkillView:UpdateSkillTime()
	local team_info = TeamFbData.Instance:GetTeamTowerInfo()
	if team_info then
		for k,v in pairs(team_info.skill_list) do
			local cd = math.max(0, v.last_perform_time - TimeCtrl.Instance:GetServerTime())
			self:FlushSkillTime(k, cd, v.skill_id)
		end
	end
end

function TowerSkillView:FlushSkillTime(index,time,id)
	self:RemoveCountDown(index)
	if index == 1 then
		self["hide_text" .. index]:SetValue(true)
		local function diff_time_func1 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				self["skill_time" .. index] = 0
				self["skill_time_text" .. index]:SetValue(0)
				self["skill_time_pro" .. index]:SetValue(0)
				self["hide_text" .. index]:SetValue(false)
				self:RemoveCountDown(index)
				return
			end
			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end
			self["skill_time" .. index] = left_time
			self["skill_time_text" .. index]:SetValue(left_sec)
			self["skill_time_pro" .. index]:SetValue(left_time / TeamFbData.Instance:SetTeamTowerDefendSkillCD(id))
		end
		diff_time_func1(0, time)
		self.montser_count_down_list1 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func1)
	end

	if index == 2 then
		self["hide_text" .. index]:SetValue(true)
		local function diff_time_func2 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				self["skill_time" .. index] = 0
				self["skill_time_text" .. index]:SetValue(0)
				self["skill_time_pro" .. index]:SetValue(0)
				self["hide_text" .. index]:SetValue(false)
				self:RemoveCountDown(index)
				return
			end
			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end
			self["skill_time" .. index] = left_time
			self["skill_time_text" .. index]:SetValue(left_sec)
			self["skill_time_pro" .. index]:SetValue(left_time / TeamFbData.Instance:SetTeamTowerDefendSkillCD(id))
		end
		diff_time_func2(0, time)
		self.montser_count_down_list2 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func2)
	end

	if index == 3 then
		self["hide_text" .. index]:SetValue(true)
		local function diff_time_func3 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				self["skill_time" .. index] = 0
				self["skill_time_text" .. index]:SetValue(0)
				self["skill_time_pro" .. index]:SetValue(0)
				self["hide_text" .. index]:SetValue(false)
				self:RemoveCountDown(index)
				return
			end
			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end
			self["skill_time" .. index] = left_time
			self["skill_time_text" .. index]:SetValue(left_sec)
			self["skill_time_pro" .. index]:SetValue(left_time / TeamFbData.Instance:SetTeamTowerDefendSkillCD(id))
		end
		diff_time_func3(0, time)
		self.montser_count_down_list3 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func3)
	end

	if index == 4 then
		self["hide_text" .. index]:SetValue(true)
		local function diff_time_func4 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				self["skill_time" .. index] = 0
				self["skill_time_text" .. index]:SetValue(0)
				self["skill_time_pro" .. index]:SetValue(0)
				self["hide_text" .. index]:SetValue(false)
				self:RemoveCountDown(index)
				return
			end
			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end
			self["skill_time" .. index] = left_time
			self["skill_time_text" .. index]:SetValue(left_sec)
			self["skill_time_pro" .. index]:SetValue(left_time / TeamFbData.Instance:SetTeamTowerDefendSkillCD(id))
		end
		diff_time_func4(0, time)
		self.montser_count_down_list4 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func4)
	end

end

function TowerSkillView:RemoveCountDown(index)
	if self.montser_count_down_list1 ~= nil and index == 1 then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list1)
	 	self.montser_count_down_list1 = nil
	end

	if self.montser_count_down_list2 ~= nil and index == 2 then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list2)
	 	self.montser_count_down_list2 = nil
	end

	if self.montser_count_down_list3 ~= nil and index == 3 then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list3)
	 	self.montser_count_down_list3 = nil
	end

	if self.montser_count_down_list4 ~= nil and index == 4 then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list4)
	 	self.montser_count_down_list4 = nil
	end

end