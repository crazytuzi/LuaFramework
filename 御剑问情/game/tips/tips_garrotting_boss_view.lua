TipGarrottingBossView = TipGarrottingBossView or BaseClass(BaseView)

function TipGarrottingBossView:__init()
	self.ui_config = {"uis/views/tips/garrottingbosstips_prefab", "GarrottingBossTips"}
	self.boss_id = 0
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].MonsterKill)
	end
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipGarrottingBossView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.time_quest = nil
	end
	self.boss_icon = nil
end

function TipGarrottingBossView:LoadCallBack()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.boss_icon = self:FindVariable("boss_icon")
end

function TipGarrottingBossView:SetData(boss_id)
	self.boss_id = boss_id
	self:Flush()
end

function TipGarrottingBossView:OpenCallBack()
	self:Flush()
	self:CalTime()
end

function TipGarrottingBossView:CloseCallBack()
	self.boss_id = 0
end

function TipGarrottingBossView:OnCloseClick()
	self:Close()
end

function TipGarrottingBossView:OnFlush()
	if self.boss_id ~= 0 then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.boss_id]
		local bundle, asset = nil, nil
		if monster_cfg then
			bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
			self.boss_icon:SetAsset(bundle, asset)
		end
	end
end

function TipGarrottingBossView:CalTime()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self:Close()
	end, 3)
end
