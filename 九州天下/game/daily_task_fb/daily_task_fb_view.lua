DailyTaskFbView = DailyTaskFbView or BaseClass(BaseView)

function DailyTaskFbView:__init()
	self.ui_config = {"uis/views/dailytaskfb", "DailyTaskFbInfoView"}
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.fight_info_view = true
	self.show_timer_list = {}
	self.is_safe_area_adapter = true
end

function DailyTaskFbView:LoadCallBack()
	self.show_panel = self:FindVariable("ShowPanel")
	self.monster_name1 = self:FindVariable("MonsterName1")
	self.monster_name2 = self:FindVariable("MonsterName2")
	self.monster_name3 = self:FindVariable("MonsterName3")
	self.monster_score1 = self:FindVariable("MonsterScore1")
	self.monster_score2 = self:FindVariable("MonsterScore2")
	self.monster_score3 = self:FindVariable("MonsterScore3")

	self.show_monsrer_des = {}
	for i=1,3 do
		self.show_monsrer_des[i] = self:FindVariable("Show_Monsrer_Des"..i)
	end
	self.show_monsrer_des[1]:SetValue(true)
	self.monsrer_id = self:FindVariable("Monsrer_id")
	-- self.kill_monsrer = self:FindVariable("Kill_Monsrer")
	self.monsrer_num = self:FindVariable("Monsrer_Num")
	self.monsrer_id2 = self:FindVariable("Monsrer_id2")
	self.monsrer_id3 = self:FindVariable("Monsrer_id3")
	-- self.kill_monsrer2 = self:FindVariable("Kill_Monsrer2")
	self.monsrer_num2 = self:FindVariable("Monsrer_Num2")
	self.monsrer_num3 = self:FindVariable("Monsrer_Num3")
	self.exp = self:FindVariable("Exp")
	self.gongxian = self:FindVariable("GongXian")
	self.kill_list = {
		self:FindVariable("Kill_Monsrer"),
		self:FindVariable("Kill_Monsrer2"),
		self:FindVariable("Kill_Monsrer3"),
	}

	self.condition_color_list = {}
	for i = 1, 3 do
		self.condition_color_list[i] = self:FindVariable("ConditionColor" .. i)
	end

	self.boss_timer_str = self:FindVariable("BossTimerStr")
	self.show_boss_timer = self:FindVariable("ShowBossTimer")

	self.max_score = self:FindVariable("MaxScore")
	self.cur_color = self:FindVariable("CurColor")
	self.cur_score = self:FindVariable("CurScore")
	self.kill_monster1 = self:FindVariable("KillMonster1")
	self.kill_monster2 = self:FindVariable("KillMonster2")
	self.fb_detial = self:FindVariable("FbDetial")
	self.show_score_panel = self:FindVariable("ShowScorePanel")
	self.fb_name = self:FindVariable("FbName")

	self.item_cell_list = {}
	for i = 1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("ItemCell"..i))
		self.item_cell_list[i] = item
	end
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:PanleFlush()
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
	self.monsrer_id = nil
	self.monsrer_num = nil
	self.monsrer_id2 = nil
	self.monsrer_num2 = nil
	self.monsrer_num3 = nil
	self.exp = nil
	self.gongxian = nil
	self.kill_list = nil
	self.show_monsrer_des = nil
	self.monsrer_id3 = nil
	self.condition_color_list = nil

	self.boss_timer_str = nil
	self.show_boss_timer = nil

	self.show_timer_list = {}

	for k, v in pairs(self.item_cell_list) do
		v:DeleteMe()
		v = nil
	end

end

function DailyTaskFbView:OpenCallBack()
	self:Flush()
end

function DailyTaskFbView:CloseCallBack()

end

function DailyTaskFbView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function DailyTaskFbView:PanleFlush()
	local monster_id = DailyTaskFbData.Instance:DayRiChangFbCfg()
	local monster_num = DailyTaskFbData.Instance:DayRiChangFbMonsterNum()
	local tbl_id = Split(monster_id, "|")
	local tbl_num = Split(monster_num, "|")
	local exp,gongxian = DailyTaskFbData.Instance:DayRiChangFbReward()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	local fuben_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local kill_info_list = FuBenData.Instance:GetKillNumList()
	self.monsrer_id:SetValue(monster_cfg[tonumber(tbl_id[1])].name)
	self.monsrer_num:SetValue(tonumber(tbl_num[1]))
	self.monsrer_num2:SetValue(tonumber(tbl_num[2]))
	self.monsrer_num3:SetValue(tonumber(tbl_num[3]))
	for i = 1, #kill_info_list do
		local color = tonumber(tbl_num[i]) <= kill_info_list[i] and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
		if self.condition_color_list[i] then
			self.condition_color_list[i]:SetValue(color)
		end
		if self.kill_list[i] then
			if fuben_info.param1 == 0 then       -- 波数
				self.kill_list[i]:SetValue(0)
			else
				self.kill_list[i]:SetValue(kill_info_list[i])
			end
		end
	end

	self.item_cell_list[1]:SetData({item_id=COMMON_CONSTS.VIRTUAL_ITEM_EXP, num = exp, is_bind = 0})
	self.item_cell_list[2]:SetData({item_id=COMMON_CONSTS.VIRTUAL_ITEM_JIAZU, num = gongxian, is_bind = 0})
	-- self.exp:SetValue(tostring(exp))
	-- self.gongxian:SetValue(gongxian)

	if tbl_id[2] and tbl_num[2] then
		self.monsrer_id2:SetValue(monster_cfg[tonumber(tbl_id[2])].name)
	end
	if tbl_id[3] and tbl_num[3] then
		self.monsrer_id3:SetValue(monster_cfg[tonumber(tbl_id[3])].name)
	end
	self.show_monsrer_des[2]:SetValue(tbl_id[2] ~= nil and tbl_num[2] ~= nil)
	self.show_monsrer_des[3]:SetValue(tbl_id[3] ~= nil and tbl_num[3] ~= nil)

	local is_show_timer = false
	if self.boss_timer == nil and Scene.Instance:GetSceneId() == 2703 then
		if (fuben_info.param1 == 1 or fuben_info.param1 == 2) and self.show_timer_list[fuben_info.param1] == nil then
			is_show_timer = true
		end

		if self.show_boss_timer ~= nil and is_show_timer then
			self.show_timer_list[fuben_info.param1] = true
			self.show_boss_timer:SetValue(true)
		end

		if self.boss_timer_str ~= nil then
			self.boss_timer_str:SetValue(string.format(Language.DailyTaskFb.BossAppearTimer, 3))
		end
		self.boss_timer = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.ChangeTime, self))
	end
end

function DailyTaskFbView:ChangeTime(elapse_time, total_time)
	local timer = math.ceil(total_time - elapse_time)
	local str = string.format(Language.DailyTaskFb.BossAppearTimer, timer)
	if self.boss_timer_str ~= nil then
		self.boss_timer_str:SetValue(str)
	end

	if self.boss_timer ~= nil and not CountDown.Instance:HasCountDown(self.boss_timer) then
		if self.show_boss_timer ~= nil then
			self.show_boss_timer:SetValue(false)
		end		

		self.boss_timer = nil
	end
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
	local scene_id = Scene.Instance:GetSceneId()
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_cfg then return end
	self.fb_name:SetValue(scene_cfg.name)
	if nil == cfg then return end
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
			local color = cur_count < cfg.finish_param and "#ff0000" or "#32d45e"
			local str = string.format(Language.DailyTaskFb.KillMonsterText, name, color, cur_count, cfg.finish_param)
			self["kill_monster" .. i]:SetValue(str)
		else
			self["kill_monster" .. i]:SetValue("")
		end
	end
	self.fb_detial:SetValue(cfg.fb_desc)
end