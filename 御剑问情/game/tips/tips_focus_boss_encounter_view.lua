TipsFocusBossEncounterView = TipsFocusBossEncounterView or BaseClass(BaseView)

function TipsFocusBossEncounterView:__init()
	self.ui_config = {"uis/views/tips/focustips_prefab", "FocusEncounterBossTips"}
	self.view_layer = UiLayer.Pop
end

function TipsFocusBossEncounterView:LoadCallBack()
	self:ListenEvent("close_click",
		BindTool.Bind(self.CloseClick, self))
	self:ListenEvent("go_click",
		BindTool.Bind(self.GoClick, self))

	self.time = self:FindVariable("time")
	self.boss_icon = self:FindVariable("boss_icon")
	self.show_icon = self:FindVariable("show_icon")
	self.title_image = self:FindVariable("title_image")
	self.bg_image = self:FindVariable("bg_image")
	self.text_desc_1 = self:FindVariable("txt_des_1")
	self.text_desc_2 = self:FindVariable("txt_des_2")
end

function TipsFocusBossEncounterView:ReleaseCallBack()
	self.time = nil
	self.boss_icon = nil
	self.show_icon = nil
	self.title_image = nil
	self.bg_image = nil
	self.text_desc_1 = nil
	self.text_desc_2 = nil
end

function TipsFocusBossEncounterView:OpenCallBack()
	self:Flush()
end

function TipsFocusBossEncounterView:CloseClick()
	self:Close()
end

function TipsFocusBossEncounterView:SetCloseCallBack(close_callback)
	self.close_callback = close_callback
end

function TipsFocusBossEncounterView:GoClick()
	if self.ok_call_back then
		self.ok_call_back()
	end
	self:Close()
end

function TipsFocusBossEncounterView:CloseCallBack()
	self.ok_call_back = nil

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.close_callback then
		self.close_callback = nil
	end
end

function TipsFocusBossEncounterView:OnFlush()
	self:SetPanelValue()
end

function TipsFocusBossEncounterView:SetPanelValue()
	local encounter_boss_info = BossData.Instance:GetEncounterBossData()
	self.ok_call_back = encounter_boss_info.ok_callback

	if nil ~= encounter_boss_info.boss_id then
		local bundle_0, asset_0 = ResPath.GetFocusBossImage(0,TIP_COLOR_IMAGE[encounter_boss_info.boss_type])
		self.bg_image:SetAsset(bundle_0, asset_0)
		local bundle_1, asset_1 = ResPath.GetFocusBossImage(1,TIP_COLOR_TITLE[encounter_boss_info.boss_type])
		self.title_image:SetAsset(bundle_1, asset_1)
	end

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[encounter_boss_info.boss_id]
	if monster_cfg then
		local bundle, asset = nil, nil
		bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
		self.boss_icon:SetAsset(bundle, asset)
		self.show_icon:SetValue(true)
	else
		self.show_icon:SetValue(false)
	end

	local enter_times = BossData.Instance:GetEncounterBossEnterTimes()
	self.text_desc_1:SetValue(Language.Boss.EncounterBossTips1)
	self.text_desc_2:SetValue(string.format(Language.Boss.EncounterBossTips2, enter_times))

	self:SetCountDown(encounter_boss_info.close_count_down)
end

function  TipsFocusBossEncounterView:SetCountDown(count_down_time)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.time:SetValue(count_down_time)
	self.count_down = CountDown.Instance:AddCountDown(count_down_time, 1, BindTool.Bind(self.CountDown, self))
end

function TipsFocusBossEncounterView:CountDown(elapse_time, total_time)
	self.time:SetValue(total_time - elapse_time)
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end