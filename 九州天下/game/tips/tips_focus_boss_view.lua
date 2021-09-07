TipsFocusBossView = TipsFocusBossView or BaseClass(BaseView)

function TipsFocusBossView:__init()
	self.ui_config = {"uis/views/tips/focustips", "FocusTips"}

	self.is_rune = false
	self.view_layer = UiLayer.Pop
	self.is_yi_ji = false
	self.timer_cal = 15
end

function TipsFocusBossView:LoadCallBack()
	self:ListenEvent("close_click",
		BindTool.Bind(self.CloseClick, self))
	self:ListenEvent("go_click",
		BindTool.Bind(self.GoClick, self))
	self.time = self:FindVariable("time")
	self.boss_icon = self:FindVariable("boss_icon")
	self.show_frame = self:FindVariable("show_frame")
	self.boss_desc = self:FindVariable("boss_desc")
	self.no_mask_icon = self:FindVariable("no_mask_icon")
	self.show_no_mask_icon = self:FindVariable("show_no_mask_icon")

	self.btn_text = self:FindVariable("btn_text")
	self.show_time = self:FindVariable("show_time")
end

function TipsFocusBossView:ReleaseCallBack()
	self.time = nil
	self.boss_icon = nil
	self.show_frame = nil
	self.boss_desc = nil
	self.no_mask_icon = nil
	self.show_no_mask_icon = nil

	self.btn_text = nil
	self.show_time = nil
end

function TipsFocusBossView:OpenCallBack()
	self:Flush()
	-- self:CalTime()
end

function TipsFocusBossView:CloseClick()
	self:Close()
end

function TipsFocusBossView:GoClick()
	if self.ok_call_back then
		self.ok_call_back()
	end
	self:Close()
end

function TipsFocusBossView:CloseCallBack()
	self.is_rune = false
	self.boss_id = nil
	self.ok_call_back = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function TipsFocusBossView:SetData(boss_id, ok_call_back)
	self.boss_id = boss_id
	self.ok_call_back = ok_call_back
	self:Flush()
end

function TipsFocusBossView:SetRuneInfo(is_rune)
	self.is_rune = is_rune or false
end

function TipsFocusBossView:SetXingZuoYiJiInfo(is_yi_ji)
	self.is_yi_ji = is_yi_ji or false
end

function TipsFocusBossView:OnFlush()
	self.show_time:SetValue(not self.is_rune)
	self.show_no_mask_icon:SetValue(self.is_rune or self.is_yi_ji)

	if self.boss_id then
		local monster_cfg = BossData.Instance:GetMonsterInfo(self.boss_id)
		if monster_cfg then
			local bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
			self.boss_icon:SetAsset(bundle, asset)
		
			self.show_frame:SetValue(true)
			if self.boss_id == BossData.Instance:GetWorldBossList()[1].bossID then
				self.boss_desc:SetValue(Language.Boss.BossFlushDesc)
			else
				self.boss_desc:SetValue(string.format("%s(%s%s)", monster_cfg.name, monster_cfg.level, Language.Common.Ji))
			end
		end
	elseif self.is_rune then
		local bundle, asset = ResPath.GetGuajiTaIcon()
		self.no_mask_icon:SetAsset(bundle, asset)
		self.boss_desc:SetValue(Language.Rune.OfflineTimeNoEnough)
		self.btn_text:SetValue(Language.OpenServer.GoBuy)
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	elseif self.is_yi_ji then
		local bundle, asset = ResPath.GetXingZuoYiJiIcon()
		self.no_mask_icon:SetAsset(bundle, asset)
		self.boss_desc:SetValue(Language.ShengXiao.OpenXingZuoYiJi)
		self.btn_text:SetValue(Language.Common.GoImmediately)
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	else
		self.show_frame:SetValue(false)
		local bundle, asset = ResPath.GetMainUIButton("Icon_System_Boss")
		self.boss_icon:SetAsset(bundle, asset)
		self.boss_desc:SetValue(Language.Boss.BossFlushDesc)
	end

	self:CalTime()
end

function TipsFocusBossView:CalTime()
	if self.is_rune then
		return
	end

	if self.time_quest then
		return
	end

	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer_cal = self.timer_cal - UnityEngine.Time.deltaTime
		if self.timer_cal >= 0 then
			local str = Language.Common.AutoExit
			if nil ~= self.boss_id then
				str = Language.Boss.AutoRefresh
			end
			self.time:SetValue(math.floor(self.timer_cal) .. str)
		end
		if self.timer_cal < 0 then
			self:CloseClick()
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end, 0)
end

function TipsFocusBossView:SetCountdown(time)
	self.timer_cal = time or 15
end
