TipsFocusBossView = TipsFocusBossView or BaseClass(BaseView)

function TipsFocusBossView:__init()
	self.ui_config = {"uis/views/tips/focustips_prefab", "FocusTips"}
	self.is_rune = false
	self.view_layer = UiLayer.Pop
	self.is_yi_ji = false
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
	-- self:Flush()
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

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
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
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.boss_id]
		local bundle, asset = nil, nil
		if monster_cfg then
			bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
			self.boss_icon:SetAsset(bundle, asset)
		end
		self.show_frame:SetValue(true)
		self.boss_desc:SetValue(Language.Boss.BossFocusDesc)
	elseif self.is_rune then
		local bundle, asset = ResPath.GetGuajiTaIcon()
		self.no_mask_icon:SetAsset(bundle, asset)
		self.boss_desc:SetValue(Language.Rune.OfflineTimeNoEnough)
		self.btn_text:SetValue(Language.OpenServer.GoBuy)
	elseif self.is_yi_ji then
		local bundle, asset = ResPath.GetXingZuoYiJiIcon()
		self.no_mask_icon:SetAsset(bundle, asset)
		self.boss_desc:SetValue(Language.ShengXiao.OpenXingZuoYiJi)
		self.btn_text:SetValue(Language.Common.GoImmediately)
	else
		self.show_frame:SetValue(false)
		local bundle, asset = ResPath.GetBossIcon(43)--ResPath.GetMainUI("Icon_System_Boss")
		self.boss_icon:SetAsset(bundle, asset)
		self.boss_desc:SetValue(Language.Boss.BossFlushDesc)
	end

	if self.is_rune then
		return
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.time:SetValue(15)
	self.count_down = CountDown.Instance:AddCountDown(15, 1, BindTool.Bind(self.CountDown, self))
end

function TipsFocusBossView:CountDown(elapse_time, total_time)
	self.time:SetValue(total_time - elapse_time)
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end