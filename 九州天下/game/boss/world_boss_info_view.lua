WorldBossInfoView = WorldBossInfoView or BaseClass(BaseRender)

function WorldBossInfoView:__init(instance)
	if instance == nil then
		return
	end
end

function WorldBossInfoView:__delete()
	if self.scene_loaded then
		GlobalEventSystem:UnBind(self.scene_loaded)
		self.scene_loaded = nil
	end

	if self.team_panel then
		self.team_panel:DeleteMe()
		self.team_panel = nil
	end

	self:RemoveCountDown()
	self:PauseTweener()

	self.click_flag = nil
end

function WorldBossInfoView:LoadCallBack()
	self.click_flag = false
	self.team_panel = BossFamilyTeamInfo.New(self:FindObj("TeamPanel"))

	self:ListenEvent("OnClickPerson", BindTool.Bind(self.OnClickPerson, self))
	self:ListenEvent("OnClickTeam", BindTool.Bind(self.OnClickTeam, self))
	self:ListenEvent("OnClickRoll", function() self:OnClickRoll(1) end)
	self:ListenEvent("OnClickRoll1", function() self:OnClickRoll(2) end)
	self:ListenEvent("OnClickAbandon", function() self:OnClickAbandon(1) end)
	self:ListenEvent("OnClickAbandon1", function() self:OnClickAbandon(2) end)
	self.scene_loaded = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT,BindTool.Bind(self.OnSceneLoaded, self))

	self.rank = self:FindVariable("Rank")
	self.name = self:FindVariable("Name")
	self.damage = self:FindVariable("Damage")
	self.show_btn = self:FindVariable("ShowBtn")
	self.show_btn1 = self:FindVariable("ShowBtn1")
	self.xu_qiu = self:FindVariable("XuQiu")
	self.fang_qi = self:FindVariable("FangQi")
	self.sheng_yu_shi_jian = self:FindVariable("ShengYuShiJian")
	self.rest_time1 = self:FindVariable("RestTime1")
	self.rest_time2 = self:FindVariable("RestTime2")
	self.show_point1 = self:FindVariable("ShowPoint1")
	self.show_point2 = self:FindVariable("ShowPoint2")
	self.point1 = self:FindVariable("Point1")
	self.point2 = self:FindVariable("Point2")
	self.top_name1 = self:FindVariable("TopName1")
	self.top_name2 = self:FindVariable("TopName2")
	self.top_point1 = self:FindVariable("TopPoint1")
	self.top_point2 = self:FindVariable("TopPoint2")
	self.progress_value_1 = self:FindVariable("progress_value_1")
	self.progress_value_2 = self:FindVariable("progress_value_2")

	self.xu_qiu:SetValue(Language.Common.XuQiu)
	self.fang_qi:SetValue(Language.Common.FangQi)
	self.sheng_yu_shi_jian:SetValue(Language.Common.ShengYuShiJian)
	self.show_point1:SetValue(false)
	self.show_point2:SetValue(false)

	self.info_list = {}
	for i = 1, 5 do
		self.info_list[i] = {}
		self.info_list[i].obj = self:FindObj("DamageInfo" .. i)
		local variable_table = self.info_list[i].obj:GetComponent("UIVariableTable")
		self.info_list[i].rank = variable_table:FindVariable("Rank")
		self.info_list[i].name = variable_table:FindVariable("Name")
		self.info_list[i].damage = variable_table:FindVariable("Damage")
	end

	self.roll_effective_time = 10
	local world_boss_other_config = BossData.Instance:GetBossOtherConfig()
	if world_boss_other_config then
		self.roll_effective_time = world_boss_other_config.roll_effective_time or 10
	end
	self:OnSceneLoaded()
end

function WorldBossInfoView:OnSceneLoaded()
	self:RemoveCountDown()
	self.show_btn:SetValue(false)
	self.show_btn1:SetValue(false)
	local boss_id = BossData.Instance:GetCurBossID()
	if boss_id then
		BossCtrl.Instance:SendWorldBossPersonalHurtInfoReq(boss_id)
		BossCtrl.Instance:SendWorldBossGuildHurtInfoReq(boss_id)
	end
end

function WorldBossInfoView:OnFlush()
	if self.click_flag == false then
		self:FlushPersonScore()
	else 
		self.team_panel:Flush()
	end
end

function WorldBossInfoView:OnClickPerson()
	self.click_flag = false
	self:Flush()
end

function WorldBossInfoView:FlushPersonScore()
	local info = nil
	info = BossData.Instance:GetBossPersonalHurtInfo()
	if info then
		if info.self_rank > 0 then
			self.rank:SetValue(info.self_rank)
		else
			self.rank:SetValue(Language.Boss.NotOnTheList)
		end
		self.name:SetValue(GameVoManager.Instance:GetMainRoleVo().name)
		local damage = self:CountToString(info.my_hurt)
		if damage then
			self.damage:SetValue(damage)
		end
	end
	if info then
		for i = 1, 5 do
			self.info_list[i].rank:SetValue(i)
			local rank_info = info.rank_list[i]
			if rank_info then
				self.info_list[i].name:SetValue(rank_info.name)
				local damage = self:CountToString(rank_info.hurt)
				if damage then
					self.info_list[i].damage:SetValue(damage)
				end
			else
				self.info_list[i].name:SetValue(Language.Common.ZanWu)
				self.info_list[i].damage:SetValue(0)
			end
		end
	end
end

function WorldBossInfoView:OnClickTeam()
	if self.click_flag == false then
		self.click_flag = true
		self:Flush()
	else
		ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	end
end

function WorldBossInfoView:CountToString(count)
	if not count then return end
	if count > 9999 and count < 100000000 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count >= 100000000 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	return count
end

function WorldBossInfoView:OnClickRoll(index)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsWorldBossScene(scene_id) then
			local boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
			BossCtrl.Instance:SendWorldBossRollReq(boss_id, index)
		end
	end
end

function WorldBossInfoView:OnClickAbandon(index)
	if index == 1 then
		self.show_btn:SetValue(false)
	else
		self.show_btn1:SetValue(false)
	end
end

function WorldBossInfoView:SetCanRoll(index)
	local tweener = nil
	if index == 1 then
		self.show_btn:SetValue(true)
		self.show_point1:SetValue(false)
		self.slider1.value = 0
		tweener = self.slider1:DOValue(1, self.roll_effective_time, false)
		self.tweener1 = tweener
		if self.count_down1 then
			CountDown.Instance:RemoveCountDown(self.count_down1)
		end
		self.count_down1 = CountDown.Instance:AddCountDown(self.roll_effective_time, 0.1,
		 function(elapse_time, total_time) self.rest_time1:SetValue(string.format("%.1f", total_time - elapse_time))
		 self.progress_value_1:SetValue((total_time - elapse_time)/total_time)
		 if total_time - elapse_time <= 0 then
		 	self.show_btn:SetValue(false)
		 end end)
	else
		self.show_btn1:SetValue(true)
		self.show_point2:SetValue(false)
		self.slider2.value = 0
		tweener = self.slider2:DOValue(1, self.roll_effective_time, false)
		self.tweener2 = tweener
		if self.count_down2 then
			CountDown.Instance:RemoveCountDown(self.count_down2)
		end
		self.count_down2 = CountDown.Instance:AddCountDown(self.roll_effective_time, 0.1,
		 function(elapse_time, total_time) self.rest_time2:SetValue(string.format("%.1f", total_time - elapse_time))
		 self.progress_value_2:SetValue((total_time - elapse_time)/total_time)
		 if total_time - elapse_time <= 0 then
		 	self.show_btn1:SetValue(false)
		 end end)
	end
	if tweener then
		tweener:SetEase(DG.Tweening.Ease.Linear)
		tweener:OnComplete(function() self:OnClickAbandon(index) end)
	end
end

function WorldBossInfoView:SetRollResult(point, index)
	if index == 1 then
		self.show_point1:SetValue(true)
		self.point1:SetValue(point)
		if self.tweener1 then
			self.tweener1:Pause()
			self.tweener1 = nil
		end
		-- self.time_quest1 = GlobalTimerQuest:AddDelayTimer(function() self.show_btn:SetValue(false) end, 3)
	elseif index == 2 then
		self.show_point2:SetValue(true)
		self.point2:SetValue(point)
		if self.tweener2 then
			self.tweener2:Pause()
			self.tweener2 = nil
		end
		-- self.time_quest2 = GlobalTimerQuest:AddDelayTimer(function() self.show_btn1:SetValue(false) end, 3)
	end
end

function WorldBossInfoView:SetRollTopPointInfo(boss_id, hudun_index, top_roll_point, top_roll_name)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsWorldBossScene(scene_id) then
			local this_boss_id = BossData.Instance:GetWorldBossIdBySceneId(scene_id)
			if this_boss_id == boss_id then
				if hudun_index == 1 then
					self.top_point1:SetValue(top_roll_point)
					self.top_name1:SetValue(top_roll_name)
				elseif hudun_index == 2 then
					self.top_point2:SetValue(top_roll_point)
					self.top_name2:SetValue(top_roll_name)
				end
			end
		end
	end
end

function WorldBossInfoView:RemoveCountDown()
	if self.time_quest1 then
		GlobalTimerQuest:CancelQuest(self.time_quest1)
		self.time_quest1 = nil
	end
	if self.time_quest2 then
		GlobalTimerQuest:CancelQuest(self.time_quest2)
		self.time_quest2 = nil
	end
	if self.count_down1 then
		CountDown.Instance:RemoveCountDown(self.count_down1)
		self.count_down1 = nil
	end
	if self.count_down2 then
		CountDown.Instance:RemoveCountDown(self.count_down2)
		self.count_down2 = nil
	end
end

function WorldBossInfoView:PauseTweener()
	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end
	if self.tweener1 then
		self.tweener2:Pause()
		self.tweener2 = nil
	end
end

function WorldBossInfoView:MyLinearEase(time, duration, overshootOrAmplitude, period)
	return time / duration
end