DiMaiFbInfoView = DiMaiFbInfoView or BaseClass(BaseView)

function DiMaiFbInfoView:__init()
	self.ui_config = {"uis/views/dimaiview", "DiMaiFbInfoView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function DiMaiFbInfoView:LoadCallBack()
	self.title_name = self:FindVariable("TitleName")
	self.target_str = self:FindVariable("TargetStr")
	self.show_panel = self:FindVariable("ShowPanel")
	self.fight_power = self:FindVariable("FightPower")

	self.item_list = {}
	for i = 0, 2 do
		self.item_list[i] = {}
		self.item_list[i].obj = self:FindObj("Item" .. i)
		self.item_list[i].cell = ItemCell.New()
		self.item_list[i].cell:SetInstanceParent(self.item_list[i].obj)
		self.item_list[i].obj:SetActive(false)
	end

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self:Flush()
end

function DiMaiFbInfoView:__delete()
end

function DiMaiFbInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k,v in pairs(self.item_list) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_list = {}

	self.title_name = nil
	self.target_str = nil
	self.show_panel = nil
	self.fight_power = nil
end

function DiMaiFbInfoView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function DiMaiFbInfoView:OnFlush()
	local map_name = Scene.Instance:GetSceneName()
	self.title_name:SetValue(map_name or "")

	local dimai_fb_info = DiMaiData.Instance:GetFBDimaiInfo()
	if dimai_fb_info then
		local dimai_info_cfg = DiMaiData.Instance:GetDiMaiInfoCfg(dimai_fb_info.layer, dimai_fb_info.point)
		if dimai_info_cfg then
			for k, v in pairs(dimai_info_cfg.challenge_rewards) do
				self.item_list[k].obj:SetActive(true)
				self.item_list[k].cell:SetData(v)
			end
			local monster_cfg = BossData.Instance:GetMonsterInfo(dimai_info_cfg.monster_id)
			if monster_cfg then
				self.target_str:SetValue(string.format(Language.QiangDiMai.TargetBossRemind, monster_cfg.name))
			end

			local dimai_single_info = DiMaiData.Instance:GetSingleDimaiInfo()
			if dimai_single_info then
				local zhanli = dimai_single_info.dimai_info.challenge_succ_times * dimai_info_cfg.increasing_force + dimai_info_cfg.initial_force
				if zhanli then
					self.fight_power:SetValue(string.format(Language.QiangDiMai.RecommendedFightPower, ToColorStr(zhanli, COLOR.GREEN)))
				end
			end
		end
	end
end