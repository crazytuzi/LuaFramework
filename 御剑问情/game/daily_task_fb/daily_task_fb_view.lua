DailyTaskFbView = DailyTaskFbView or BaseClass(BaseView)

function DailyTaskFbView:__init()
	self.ui_config = {"uis/views/dailytaskfb_prefab", "DailyTaskFbInfoView"}
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.active_close = false
	self.fight_info_view = true
end

function DailyTaskFbView:LoadCallBack()
	self.show_panel = self:FindVariable("ShowPanel")
	self.monster_name1 = self:FindVariable("MonsterName1")
	self.monster_name2 = self:FindVariable("MonsterName2")
	self.monster_name3 = self:FindVariable("MonsterName3")
	self.monster_score1 = self:FindVariable("MonsterScore1")
	self.monster_score2 = self:FindVariable("MonsterScore2")
	self.monster_score3 = self:FindVariable("MonsterScore3")
	self.max_score = self:FindVariable("MaxScore")
	self.cur_color = self:FindVariable("CurColor")
	self.cur_score = self:FindVariable("CurScore")
	self.kill_monster1 = self:FindVariable("KillMonster1")
	self.kill_monster2 = self:FindVariable("KillMonster2")
	self.fb_detial = self:FindVariable("FbDetial")
	self.show_score_panel = self:FindVariable("ShowScorePanel")
	self.fb_name = self:FindVariable("FbName")
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function DailyTaskFbView:__delete()

end

function DailyTaskFbView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self.show_panel = nil
	self.monster_name1 = nil
	self.monster_name2 = nil
	self.monster_name3 = nil
	self.monster_score1 = nil
	self.monster_score2 = nil
	self.monster_score3 = nil
	self.cur_color = nil
	self.cur_score = nil
	self.kill_monster1 = nil
	self.kill_monster2 = nil
	self.fb_detial = nil
	self.show_score_panel = nil
	self.max_score = nil
	self.fb_name = nil
end

function DailyTaskFbView:OpenCallBack()
	self:Flush()
end

function DailyTaskFbView:CloseCallBack()

end

function DailyTaskFbView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function DailyTaskFbView:OnFlush(param_t)
	local fb_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_info then return end
	if fb_info.is_pass == 1 then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	end
	local show_score_view = fb_info.param1 == 1
	self.show_score_panel:SetValue(show_score_view)
	local cfg = DailyTaskFbData.Instance:GetFbCfg(fb_info.param1)
	if nil == cfg then return end
	self.fb_name:SetValue(cfg.fb_name)
	if show_score_view then
		self:FlushScoreView(fb_info, cfg)
	else
		self:FlushBossView(fb_info, cfg)
	end
end

function DailyTaskFbView:FlushScoreView(fb_info, cfg)
	for i = 1, 3 do
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[cfg["monster_" .. i]]
		if monster_cfg then
			self["monster_name" .. i]:SetValue(monster_cfg.name)
			self["monster_score" .. i]:SetValue(cfg["param_" .. i])
		end
	end
	self.cur_color:SetValue(fb_info.param2 < cfg.finish_param and "#ff0000" or "#32d45e")
	self.cur_score:SetValue(fb_info.param2)
	self.max_score:SetValue(cfg.finish_param)
end

function DailyTaskFbView:FlushBossView(fb_info, cfg)
	for i = 1, 2 do
		if i == 1 then
			local monster_id = cfg.boss_monster > 0 and cfg.boss_monster or cfg.monster_1
			local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[monster_id]
			local name = monster_cfg and monster_cfg.name or ""
			local cur_count = fb_info["param" .. (i + 1)] or 0
			local color = cur_count < cfg.finish_param and "#00ff90" or "#00ff90"
			local str = string.format(Language.DailyTaskFb.KillMonsterText, name, color, cur_count, cfg.finish_param)
			self["kill_monster" .. i]:SetValue(str)
		else
			self["kill_monster" .. i]:SetValue("")
		end
	end
	self.fb_detial:SetValue(cfg.fb_desc)
end