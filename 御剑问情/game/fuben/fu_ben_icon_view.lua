FbIconView = FbIconView or BaseClass(BaseView)
function FbIconView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "FBIconsView"}
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.fb_time = 0
	self.active_close = false
	self.fight_info_view = true
	self.monster_diff_time_list = {[1] = 0, [2] = 0}
	self.monster_variable_list = {}
	self.montser_count_down_list = {}
	self.click_call_back_list = {}
	self.monster_id = 0
	self.is_show_skymoney_text = false
	self.role_attr_change_event = BindTool.Bind1(self.OnRoleAttrValueChange, self)
	self.is_show_dec_btn = false
	self.is_show_btn_outfb = false
	self.is_show_rank_reward_btn = false
end

function FbIconView:LoadCallBack()
--	self.guild_boss_icon = self:FindObj("GuildBoss")
	self.exit_fb_btn = self:FindObj("ExitFbBtn")

	-- self.cur_min = self:FindVariable("CurMin")
	-- self.cur_sec = self:FindVariable("CurSec")
	-- self.cur_hour = self:FindVariable("CurHour")
	self.time_text = self:FindVariable("time_text")
	-- 钱多多文本描述
	self.show_text = self:FindVariable("show_text")
	--经验副本按钮
	self.show_btn_potion = self:FindVariable("ShowBtnPotion")
	self.show_btn_buff = self:FindVariable("ShowBtnBuff")

	--水晶副本按钮
	self.show_btn_shuijing_buff = self:FindVariable("ShowBtnShuijingBuff")

	-- 战场奖励列表按钮
	self.show_btn_reward = self:FindVariable("ShowRewardIcon")
	self.reward_time = self:FindVariable("reward_time")

	-- 公会争霸
	self.show_guildfight_rank_icon = self:FindVariable("ShowGuildFightRankIcon")
	self.guild_now_rank_des = self:FindVariable("GuildNowRankDes")
	self.show_zhaoji_btn = self:FindVariable("ShowZhaoJiBtn")
	self.zhaoji_times = self:FindVariable("zhaoji_times")
	self.zhaoji_times:SetValue(GuildFightData.Instance:GetRemindZhaojiTimes() or 0)

	self.buy_buff = self:FindObj("BuyBuff")
	self.buy_potion_anim = self:FindObj("BuyPotionAnim")
	self.buy_buff_anim = self:FindObj("BuyBuffAnim")
	self.buy_shuijing_buff = self:FindObj("BuyShuijingBuff")
	self.shuijing_buff = self:FindObj("ShuijingBuff")
	self.potion_flag = true
	self.buff_flag = true
	self.shuijing_buff_flag = true
	self.xiuluo_buff_flag = true
	self.mining_buff_flag = true
	self.tianshen_buff_flag = true


	self.is_on_potion = self:FindVariable("IsOnPotion")
	self.on_buff_des = self:FindVariable("BuffDes")
	self.is_on_buff = self:FindVariable("IsOnBuff")
	self.is_on_shuijing_buff = self:FindVariable("IsOnShuijingBuff")
	self.shui_jing_buff_text = self:FindVariable("shui_jing_buff_text")
	-- self.tx_color = self:FindVariable("Color")
	-- self.show_help_tip = self:FindVariable("ShowHelpTip")

	self.exit_btn_vis = self:FindVariable("ExitBtnVis")
	self.dec_btn_vis = self:FindVariable("DecBtnVis")
	-- self.help_dec = self:FindVariable("HelpDec")
	self.exit_time_act = self:FindVariable("ExitTimeAct")
	self.panel_act = self:FindVariable("Panel")
	self.show_guild_boss = self:FindVariable("ShowGuildBoss")
	self.show_guild_button = self:FindVariable("ShowGuildButton")

	self.show_btn_time = self:FindVariable("ShowBtnTime")		-- 离开按钮下面的倒计时

	self.show_auto_btn = self:FindVariable("ShowAutoBtn")		-- 自动挑战按钮

	self.show_exit_arrow = self:FindVariable("ShowExitArrow")		-- 离开场景提示箭头

	self.show_condition = self:FindVariable("ShowCondition")		-- 不显示时间，显示完成任务条件
	self.condition_txt = self:FindVariable("ConditionTxt")
	self.hot_spring_text = self:FindVariable("HotSpringText")
	self.show_question_text = self:FindVariable("ShowQuestionText")
	self.question_prepare_time = self:FindVariable("QuestionPrepareTime")
	self.show_guild_call = self:FindVariable("ShowGuildCall")
	self.guild_call_times = self:FindVariable("GuildCallTimes")
	self.show_rank_reward_icon = self:FindVariable("ShowRankRewardIcon")
	self.show_jinghua_icon = self:FindVariable("ShowJingHuaIcon")
	self.jingua_husong_num = self:FindVariable("JingHuaHuSongNum")

	self.show_question_text:SetValue(false)

	self.vip3_limit = self:FindVariable("Vip3Limit")
	self.auto_btn = self:FindObj("AutoBtn")
	-- 右侧图标，重要怪物刷新
	for i = 1, 2 do
		self.monster_variable_list[i] = {
				monster_min = self:FindVariable("MonsterTimeMin"..i),
				monster_sec = self:FindVariable("MonsterTimeSec"..i),
				monster_icon = self:FindVariable("MonsterIcon"..i),
				show_monster_icon = self:FindVariable("ShowMonsterIcon"..i),
				show_money_monster_icon = self:FindVariable("ShowMonsterIcon"..(i + 2)),
				show_monster_had_flush = self:FindVariable("ShowMonsterHadFlush"..i), -- 怪物已经刷新
				had_flush_text = self:FindVariable("HadFlushText"..i),	-- 刷新后显示的文字
				show_gray = self:FindVariable("ShowMonsterIconGray"..i),	-- 图标置灰

		}
	end

	self:ListenEvent("OpenJingHuaHuSong", BindTool.Bind(self.OpenJingHuaActView, self))
	self:ListenEvent("OnClickExit",
		BindTool.Bind(self.OnClickExit, self))
	self:ListenEvent("OnClicExplain",
		BindTool.Bind(self.OnClicExplain, self))
	-- self:ListenEvent("CloseHelpTip",
	-- 	BindTool.Bind(self.CloseHelpTip, self))
	self:ListenEvent("OnClickExpBuff",
		BindTool.Bind(self.OnClickExpBuff, self))
	self:ListenEvent("OnClickZhaoJi",
		BindTool.Bind(self.OnClickZhaoJi, self))
	self:ListenEvent("OnClickShuijingBuff",
		BindTool.Bind(self.OnClickShuijingBuff, self))
	self:ListenEvent("OnClickExpPotion",
		BindTool.Bind(self.OnClickExpPotion, self))
	self:ListenEvent("OnClickGuildBoss",
		BindTool.Bind(self.OnClickGuildBoss, self))
	self:ListenEvent("OnClickBossIcon1",
		BindTool.Bind(self.OnClickBossIcon, self, 1))
	self:ListenEvent("OnClickBossIcon2",
		BindTool.Bind(self.OnClickBossIcon, self, 2))
	self:ListenEvent("OnClickAutoBtn",
		BindTool.Bind(self.OnClickAutoBtn, self))
	self:ListenEvent("OnClickGuildFightRank",
		BindTool.Bind(self.OnClickGuildFightRank, self))

	self:ListenEvent("OnClickRewardIcon",
		BindTool.Bind(self.OnClickRewardIcon, self))
	self:ListenEvent("OnClickGuildCall",
		BindTool.Bind(self.OnClickGuildCall, self))
	self:ListenEvent("OpenMoneyTree",
		BindTool.Bind(self.OpenMoneyTree, self))
	self:ListenEvent("OnClickOpenRankReward",
		BindTool.Bind(self.OnClickOpenRankReward, self))


	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.MainOpenComlete, self))
	self:Flush()
	self.show_menu = false

	if self.monster_id > 0 then
		self:SetMonsterInfo(self.monster_id)
		self.monster_id = 0
	else
		self:SetMo_LongIcon()
	end
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FbIconView, BindTool.Bind(self.GetUiCallBack, self))
end

function FbIconView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FbIconView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
	self.click_call_back_list = {}

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.FbIconView)
	end

	if self.shuijing_count_down then
		CountDown.Instance:RemoveCountDown(self.shuijing_count_down)
		self.shuijing_count_down = nil
	end

	if self.tianshen_count_down then
		CountDown.Instance:RemoveCountDown(self.tianshen_count_down)
		self.tianshen_count_down = nil
	end

	if self.xiuluo_count_down then
		CountDown.Instance:RemoveCountDown(self.xiuluo_count_down)
		self.xiuluo_count_down = nil
	end

	if self.mining_count_down then
		CountDown.Instance:RemoveCountDown(self.mining_count_down)
		self.mining_count_down = nil
	end

	-- if GuaJiTaData.Instance then
		-- GuaJiTaData.Instance:SetAutoBtnState(false)
	-- end

	self:RemoveQuestionCountDown()

	-- 清理变量和对象
--	self.guild_boss_icon = nil
	self.show_zhaoji_btn = nil
	self.exit_fb_btn = nil
	self.time_text = nil
	self.show_text = nil
	self.show_btn_potion = nil
	self.show_btn_buff = nil
	self.buy_buff = nil
	self.buy_potion_anim = nil
	self.buy_buff_anim = nil
	self.is_on_potion = nil
	self.is_on_buff = nil
	self.exit_btn_vis = nil
	self.dec_btn_vis = nil
	self.exit_time_act = nil
	self.panel_act = nil
	self.show_guild_boss = nil
	self.show_btn_time = nil
	self.show_auto_btn = nil
	self.vip3_limit = nil
	self.auto_btn = nil
	self.show_btn_reward = nil
	self.reward_time = nil
	self.show_guildfight_rank_icon = nil
	self.guild_now_rank_des = nil
	self.monster_variable_list = {}
	self.show_exit_arrow = nil
	self.show_condition = nil
	self.condition_txt = nil
	self.show_question_text = nil
	self.hot_spring_text = nil
	self.question_prepare_time = nil
	self.buy_shuijing_buff = nil
	self.show_btn_shuijing_buff = nil
	self.is_on_shuijing_buff = nil
	self.shui_jing_buff_text = nil
	self.on_buff_des = nil
	self.shuijing_buff = nil
	self.show_guild_call = nil
	self.guild_call_times = nil
	self.zhaoji_times = nil
	self.show_rank_reward_icon = nil
	self.show_jinghua_icon = nil
	self.jingua_husong_num = nil
	self.show_guild_button = nil
end

function FbIconView:Open(...)
	self.is_show_dec_btn = false
	self.is_show_btn_outfb = false
	self.is_show_rank_reward_btn = false
	self.is_active_boss = false
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local name_list_t = Split(fb_scene_cfg.show_fbicon, "#")
	for k,v in pairs(name_list_t) do
		if v == "btn_outfb" then
			self.is_show_btn_outfb = true
		elseif v == "btn_fbdesc" then
			self.is_show_dec_btn = true
		end
	end

	--世界boss
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.IsWorldBossScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.is_show_rank_reward_btn = true
		self.tip_id = 140
	elseif BossData.IsDabaoBossScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 143
	elseif BossData.IsFamilyBossScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 141
	elseif	BossData.IsMikuBossScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 142
	elseif BossData.IsKfBossScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 144
	elseif BossData.IsActiveBossScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.is_show_rank_reward_btn = true
		self.is_active_boss = true
		self.tip_id = 160
	elseif AncientRelicsData.IsAncientRelics(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 165
	elseif BossData.IsSecretBossScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 214
	elseif BossData:IsXianJieBossScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 242
	elseif RelicData.Instance:IsRelicScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 174
	elseif GuildData.Instance:IsGuildBossScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 61
	elseif ActivityData.Instance:IsShuShanScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 248
	elseif JingHuaHuSongData.Instance:IsJingHuaScene(scene_id) then
		self.is_show_btn_outfb = true
		self.is_show_dec_btn = true
		self.tip_id = 269
	elseif BossData.IsBabyBossScene(scene_id) then
		self.tip_id = 263
	end

	-- if self.is_show_dec_btn <then></then>
	-- 	local scene_id = Scene.Instance:GetSceneId()
	-- 	local scene_type = Scene.Instance:GetSceneType()
	-- 	if not SettingData.Instance:HasEnterFb(scene_type, scene_id) then
	-- 		local scene_logic = Scene.Instance:GetSceneLogic()
	-- 		if scene_logic then
	-- 			scene_logic:SetAutoGuajiWhenEnterScene(false)
	-- 		end
	-- 	end
	-- end

	BaseView.Open(self, ...)
end

function FbIconView:ExitWithTips(str, scene_id)
	local yes_func = function ()
		FuBenCtrl.Instance:SendExitFBReq()
		if Scene.Instance:GetSceneType() == SceneType.TeamSpecialFb or Scene.Instance:GetSceneType() == SceneType.TeamTower then
			FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM)
		end
		if Scene.Instance:GetSceneType() == SceneType.CrossFB then
			CrossServerData.Instance:SetLeaveCrossFbState(true)
		end
	end
	-- TipsCtrl.Instance:ShowTwoOptionView(Language.Common.ExitCurrentScene, yes_func)
	TipsCtrl.Instance:ShowCommonAutoView("", str or Language.Common.ExitCurrentScene, yes_func)
end

function FbIconView:OnClickExit()
	local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if scene_cfg.fight_cant_exit and 1 == scene_cfg.fight_cant_exit then
		local main_role = Scene.Instance:GetMainRole()
		if main_role:IsFightStateByRole() or (main_role:IsFightState() and main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_PEACE) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.FightingCantExitFb)
			return
		end
	end

	local scene_id = Scene.Instance:GetSceneId()
	if BossData.IsWorldBossScene(scene_id)
	or AncientRelicsData.IsAncientRelics(scene_id)
	or RelicData.Instance:IsRelicScene(scene_id) then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		local scene_logic = Scene.Instance:GetSceneLogic()
		local x, y = scene_logic:GetTargetScenePos(scene_id)
		if x == nil or y == nil then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotToTarget)
			return
		end
		Scene.Instance:GetSceneLogic():StopAutoGather()
		GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0)
		return
	end
	if BossData.IsDabaoBossScene(scene_id)
	or BossData.IsFamilyBossScene(scene_id)
	or BossData.IsMikuBossScene(scene_id)
	or BossData.IsActiveBossScene(scene_id)
	or BossData.IsSecretBossScene(scene_id) then
		local func = function()
			if IS_ON_CROSSSERVER and BossData.Instance:IsBossFamilyKfScene() then
				BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE)
				CrossServerCtrl.Instance:GoBack()
			else
				BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE)
			end
		end
		-- TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.ExitCurrentScene, nil, nil, false)
		TipsCtrl.Instance:ShowCommonAutoView("", Language.Common.ExitCurrentScene, func)
		return
	end

	if BossData:IsBabyBossScene(scene_id)  then
		local func = function()
			BossCtrl.SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_LEAVE_REQ)
		end
		TipsCtrl.Instance:ShowCommonAutoView("", Language.Common.ExitCurrentScene, func)
		return
	end

	if BossData:IsXianJieBossScene(scene_id)  then
		local funclevel = function()
			ViewManager.Instance:Close(ViewName.BossXianJieView)
			FuBenCtrl.Instance:SendExitHchzReq()
		end
		TipsCtrl.Instance:ShowCommonAutoView("", Language.Common.ExitCurrentScene, funclevel)
	end

	if ActivityData.Instance:IsShuShanScene(scene_id) then
		local funclevel = function()
			FuBenCtrl.Instance:SendExitHchzReq()
		end
		-- TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.ExitCurrentScene, nil, nil, false)
		TipsCtrl.Instance:ShowCommonAutoView("", Language.Common.ExitCurrentScene, funclevel)
		return
	end
	if JingHuaHuSongData.Instance:IsJingHuaScene(scene_id) then
		local funclevel = function()
			if JingHuaHuSongData.Instance:GetMainRoleState() == JH_HUSONG_STATUS.NONE then
				FuBenCtrl.Instance:SendExitHchzReq()
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.JingHuaHuSong.LeaveTip)
			end
		end
		TipsCtrl.Instance:ShowCommonAutoView("", Language.Common.ExitCurrentScene, funclevel)
		return
	end
	if scene_cfg.out_ui == 1 then
		local scene_type = Scene.Instance:GetSceneType()
		--如果当前场景为跨服挖矿
		if scene_type == SceneType.KfMining and KuaFuMiningData.Instance:GetGiftPanelRedPoint() then
			local ok_fun = function()
				KuaFuMiningCtrl.Instance:ClickGiftViewVisable()
		 	end
		 	local cancel_fun = function()
		 		FuBenCtrl.Instance:SendExitFBReq()
		 	end
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, Language.KuaFuFMining.ExitTips, nil, cancel_fun, nil, nil, nil, nil, nil, nil, nil, nil, nil, Language.Common.ExitScene, nil, nil, nil, true)
			return
		end

		--如果当前场景为跨服钓鱼
		if scene_type == SceneType.Fishing and CrossFishingData.Instance:IsCanExchange() then
			local ok_fun = function()
				FishingCtrl.Instance:OpenCreel()
		 	end
		 	local cancel_fun = function()
		 		FuBenCtrl.Instance:SendExitFBReq()
		 	end
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, Language.Fishing.ExitTips, nil, cancel_fun, nil, nil, nil, nil, nil, nil, nil, nil, nil, Language.Common.ExitScene, nil, nil, nil, true)
			return
		end

		self:ExitWithTips(scene_cfg.ui_instructions, scene_id)
	 	return
	end

	FuBenCtrl.Instance:SendExitFBReq()

	-- GuaJiTaData.Instance:SetAutoBtnState(false)
end

-- 玩法说明
function FbIconView:OnClicExplain(stop_guaji)
	local close_callback = nil
	if stop_guaji then
		GuajiCtrl.Instance:StopGuaji()
		close_callback = function ()
			local scene_logic = Scene.Instance:GetSceneLogic()
			if scene_logic then
				scene_logic:SetAutoGuajiWhenEnterScene(true)
				if scene_logic:IsAutoGuajiWhenEnterScene() then
					GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
				end
			end
		end
	end
	-- self.show_help_tip:SetValue(true)
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.GUILD_BOSS)
	local scene_type = Scene.Instance:GetSceneType()
	if act_info and scene_type == SceneType.GuildStation then
		if act_info.status == ACTIVITY_STATUS.OPEN or act_info.status == ACTIVITY_STATUS.STANDY then
			TipsCtrl.Instance:ShowHelpTipView(272, close_callback)
			return
		end
	end

	if self.tip_id then
		TipsCtrl.Instance:ShowHelpTipView(self.tip_id, close_callback)
		return
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg then
		TipsCtrl.Instance:ShowHelpTipView(fb_scene_cfg.fb_desc, close_callback)
	end
end

function FbIconView:SetPotionIsClick()
	self.potion_is_click:SetValue(false)
end

function FbIconView:SetBuffIsClick()
	self.buff_is_click:SetValue(false)
end

function FbIconView:CloseHelpTip()
	-- self.show_help_tip:SetValue(false)
end

function FbIconView:SetBuffBubbles()
	self.is_on_buff:SetValue(false)
end

function FbIconView:SetShuijingBuffBubbles()
	self.is_on_shuijing_buff:SetValue(false)
end

function FbIconView:SetShuijingBuffBubblesText()
	local crystal_info =  CrossCrystalData.Instance:GetCrystalInfo()
	local seconds = math.floor(crystal_info.gather_buff_time - TimeCtrl.Instance:GetServerTime())

	if seconds < 0 and self.shuijing_buff_flag then					--这个写在这位置，不然会出BUG
		self.shuijing_buff.animator:SetBool("is_click", true)
	end

	if seconds > 0 then
		self.shui_jing_buff_text:SetValue(TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2))
		if self.shuijing_count_down then
			CountDown.Instance:RemoveCountDown(self.shuijing_count_down)
			self.shuijing_count_down = nil
			self.shuijing_buff_flag=false
		end
		self.shuijing_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.ShuijingBuffTimeCountDown, self))
	end
end

function FbIconView:SetTianshenBuffBubblesText()
	if not self:IsLoaded() then
		return
	end
	local gather_buff_time =  TianShenGraveData.Instance:GetGatherBuffEndTime()
	local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())

	if seconds < 0 and self.tianshen_buff_flag then					--这个写在这位置，不然会出BUG
		self.shuijing_buff.animator:SetBool("is_click", true)
	end

	if seconds > 0 then
		self.shui_jing_buff_text:SetValue(TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2))
		if self.tianshen_count_down then
			CountDown.Instance:RemoveCountDown(self.tianshen_count_down)
			self.tianshen_count_down = nil
			self.tianshen_buff_flag=false
		end
		self.tianshen_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.TianshenBuffTimeCountDown, self))
	end
end

function FbIconView:ShuijingBuffTimeCountDown(elapse_time, total_time)
	self.shuijing_buff.animator:SetBool("is_click", false)
	local diff_timer = total_time - elapse_time
	self.shui_jing_buff_text:SetValue(TimeUtil.FormatSecond(diff_timer, diff_timer > 3600 and 3 or 2))
	if diff_timer <= 0 then
		self.shui_jing_buff_text:SetValue("")
	end
	-- 无敌称号时间小于20秒开始闪烁
	if diff_timer <= 20 and self.shuijing_wudi_title then
		Scene.Instance:GetSceneLogic():ChangeTitle()
		self.shuijing_wudi_title = false
	end
end

function FbIconView:TianshenBuffTimeCountDown(elapse_time, total_time)
	self.shuijing_buff.animator:SetBool("is_click", false)
	local diff_timer = total_time - elapse_time
	self.shui_jing_buff_text:SetValue(TimeUtil.FormatSecond(diff_timer, diff_timer > 3600 and 3 or 2))
	if diff_timer <= 0 then
		self.shui_jing_buff_text:SetValue("")
	end
	-- 无敌称号时间小于20秒开始闪烁
	if diff_timer <= 20 and self.tianshen_wudi_title then
		Scene.Instance:GetSceneLogic():ChangeTitle()
		self.tianshen_wudi_title = false
	end
end


function FbIconView:SetXiuLuoBuffBubblesText()
	local gather_buff_time =  KuaFuXiuLuoTowerData.Instance:GetBossGatherEndTime() or 0
	local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())

	if seconds < 0 and self.xiuluo_buff_flag then					--这个写在这位置，不然会出BUG
		self.shuijing_buff.animator:SetBool("is_click", true)
	end

	if seconds > 0 and self.shui_jing_buff_text then
		self.shui_jing_buff_text:SetValue(TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2))
		if self.xiuluo_count_down then
			CountDown.Instance:RemoveCountDown(self.xiuluo_count_down)
			self.xiuluo_count_down = nil
			self.xiuluo_buff_flag = false
		end
		self.xiuluo_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.XiuLuoBuffTimeCountDown, self))
	end
end

function FbIconView:XiuLuoBuffTimeCountDown(elapse_time, total_time)
	self.shuijing_buff.animator:SetBool("is_click", false)
	local diff_timer = total_time - elapse_time
	self.shui_jing_buff_text:SetValue(TimeUtil.FormatSecond(diff_timer, diff_timer > 3600 and 3 or 2))
	if diff_timer <= 0 then
		self.shui_jing_buff_text:SetValue("")
	end
	-- 无敌称号时间小于20秒开始闪烁
	if diff_timer <= 20 and self.xiuluo_wudi_title then
		Scene.Instance:GetSceneLogic():ChangeTitle()
		self.xiuluo_wudi_title = false
	end
end

function FbIconView:SetMiningBuffBubblesText()
	local gather_buff_time =  KuaFuMiningData.Instance:GetGatherBuffEndTime() or 0
	local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
	if seconds < 0 and self.mining_buff_flag and self.shuijing_buff then					--这个写在这位置，不然会出BUG
		self.shuijing_buff.animator:SetBool("is_click", true)
	end

	if seconds > 0 and self.shui_jing_buff_text then
		self.shui_jing_buff_text:SetValue(TimeUtil.FormatSecond(seconds, seconds > 3600 and 3 or 2))
		if self.mining_count_down then
			CountDown.Instance:RemoveCountDown(self.mining_count_down)
			self.mining_count_down = nil
			self.mining_buff_flag = false
		end
		self.mining_count_down = CountDown.Instance:AddCountDown(seconds, 1, BindTool.Bind(self.MiningBuffTimeCountDown, self))
	end
end

--跨服挖矿
function FbIconView:MiningBuffTimeCountDown(elapse_time, total_time)
	if not self.shuijing_buff then
		return
	end
	self.shuijing_buff.animator:SetBool("is_click", false)
	local diff_timer = total_time - elapse_time
	self.shui_jing_buff_text:SetValue(TimeUtil.FormatSecond(diff_timer, diff_timer > 3600 and 3 or 2))
	if diff_timer <= 0 then
		self.shui_jing_buff_text:SetValue("")
	end
	--无敌称号时间小于20秒开始闪烁
	if diff_timer <= 10 and self.mining_wudi_title then
		Scene.Instance:GetSceneLogic():ChangeTitle()
		self.mining_wudi_title = false
	end
end

function FbIconView:SetPotionBubbles()
	self.is_on_potion:SetValue(false)
end

function FbIconView:OnClickExpBuff()
	self:SetBuffBubbles()
	if self.buff_flag then
		self.buy_buff_anim.animator:SetBool("is_click", false)
		self.buff_flag = false
	end
	self:SetGuWuBuff()
	TipsCtrl.Instance:TipsExpInSprieFuBenView()
end

function FbIconView:OnClickZhaoJi()
	GuildFightCtrl.Instance:QiuJiuHandler()
end

-- 设置一战到底鼓舞动画
function FbIconView:SetGuWuBuff()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg() or {}
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ChaosWar then		-- 一战到底
		if user_info and user_info.gongji_guwu_per >= other_cfg.gongji_guwu_max_per then
			if self.buy_buff_anim.animator.isActiveAndEnabled then
				self.buy_buff_anim.animator:SetBool("is_click",false)
			end
		end
	end
end

function FbIconView:OnClickShuijingBuff()
	local scene_type = Scene.Instance:GetSceneType()
	self:SetShuijingBuffBubbles()
	if scene_type == SceneType.ShuiJing then
		if self.shuijing_buff_flag then
			self.shuijing_buff.animator:SetBool("is_click", false)
			self.shuijing_buff_flag = false
		end
	elseif scene_type == SceneType.Kf_XiuLuoTower then
		if self.xiuluo_buff_flag then
			self.shuijing_buff.animator:SetBool("is_click", false)
			self.xiuluo_buff_flag = false
		end
	elseif scene_type == SceneType.KfMining then
		if self.mining_buff_flag then
			self.shuijing_buff.animator:SetBool("is_click", false)
			self.mining_buff_flag = false
		end
	elseif scene_type == SceneType.CrossShuijing then
		if self.tianshen_buff_flag then
			self.shuijing_buff.animator:SetBool("is_click", false)
			self.tianshen_buff_flag = false
		end
	end

	local func1 = function()
		self.shuijing_wudi_title = true
		CrossCrystalCtrl.OnShuijingBuyBuff()
	end
	local func2 = function()
		self.xiuluo_wudi_title = true
		ActivityCtrl.Instance:OnKFtowerBuff()
	end
	local func3 = function()
		self.mining_wudi_title = true
		KuaFuMiningCtrl.Instance:BuyMiningBuff()
	end
	local func4 = function ()
		self.tianshen_wudi_title = true
		TianShenGraveCtrl.OnShuijingBuyBuff()
	end

	local other_cfg = ConfigManager.Instance:GetAutoConfig("activityshuijing_auto").other[1]
	local xiuluo_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	if scene_type == SceneType.ShuiJing and other_cfg then
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.CrossCrystal.BuyBuffTips, other_cfg.gather_buff_gold, other_cfg.gather_max_times), func1)
	elseif scene_type == SceneType.Kf_XiuLuoTower and xiuluo_cfg then
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.CrossCrystal.BuyBuffTips, xiuluo_cfg.buff_gold, xiuluo_cfg.buff_time / 60), func2)
	elseif scene_type == SceneType.KfMining then
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.CrossCrystal.BuyBuffTips, KuaFuMiningData.Instance:GetBuffBuyGold(), KuaFuMiningData.Instance:GetBuffDurationTime() / 60), func3)
	elseif scene_type == SceneType.CrossShuijing then
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.CrossCrystal.BuyBuffTips, TianShenGraveData.Instance:GetBuffBuyGold(), TianShenGraveData.Instance:GetBuffDurationTime() / 60), func4)
	end
end

function FbIconView:OnClickRewardIcon()
	CityCombatCtrl.Instance:OpenRewardView()
end

function FbIconView:OnClickExpPotion()
	self:SetPotionBubbles()
	if self.potion_flag then
		self.buy_potion_anim.animator:SetBool("is_click", false)
		self.potion_flag = false
	end
	TipsCtrl.Instance:ShowTipExpFubenView()
end

function FbIconView:OnClickOpenRankReward()
	local open_type = self.is_active_boss and BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE
	BossCtrl.Instance:OpenWorldBossRankRewardView(open_type)
end

function FbIconView:OnClickGuildCall()
	local times, cost = CityCombatData.Instance:GetGuildCallCost()
	if times < 0 or cost < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.CityCombat.TimesLack)
		return
	end

	local func = function ()
		GuildCtrl.Instance:SendSendGuildSosReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_GONGCHENGZHAN)
	end
	local describe = times > 0 and string.format(Language.CityCombat.GuildCall_1, cost) or Language.CityCombat.GuildCall_2
	TipsCtrl.Instance:ShowCommonAutoView("", describe, func)
end

function FbIconView:OpenCallBack()
	--先把按钮都隐藏掉
	self.show_guildfight_rank_icon:SetValue(false)
	self.show_btn_potion:SetValue(false)
	self.show_btn_buff:SetValue(false)
	self.show_btn_shuijing_buff:SetValue(false)
	self.show_question_text:SetValue(false)
	self.show_zhaoji_btn:SetValue(false)
	self.show_jinghua_icon:SetValue(false)

	for k, v in pairs(self.monster_variable_list) do
		v.show_gray:SetValue(false)
	end

	self.show_condition:SetValue(false)

	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		end, 0.1)
	self:Flush()
	local scene_id = Scene.Instance:GetSceneId()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_id == 4501 then
		self.show_btn_potion:SetValue(true)
		self.show_btn_buff:SetValue(true)
		local role_level = PlayerData.Instance.role_vo.level
		if not SettingData.Instance:HasEnterFb(scene_type, scene_id) then
			self.is_on_potion:SetValue(true)
			self.is_on_buff:SetValue(true)
			self.on_buff_des:SetValue(Language.FuBen.IconViewBuffDefaultDes)
		else
			self.is_on_potion:SetValue(false)
			self.is_on_buff:SetValue(false)
		end
	elseif scene_type == SceneType.ShuiJing then -- 水晶
		self.show_btn_shuijing_buff:SetValue(true)
		local crystal_info =  CrossCrystalData.Instance:GetCrystalInfo()
		local seconds = math.floor(crystal_info.gather_buff_time - TimeCtrl.Instance:GetServerTime())
		if seconds <= 0 then
			self.is_on_shuijing_buff:SetValue(true)
		end
		self:SetShuijingBuffBubblesText()
	elseif scene_type == SceneType.CrossShuijing then -- 水晶
		self.show_btn_shuijing_buff:SetValue(true)
		local gather_buff_time =  TianShenGraveData.Instance:GetGatherBuffEndTime()
		local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
		if seconds <= 0 then
			self.is_on_shuijing_buff:SetValue(true)
		end
		self:SetTianshenBuffBubblesText()
	elseif scene_type == SceneType.Kf_XiuLuoTower then -- 跨服修罗塔
		self.show_btn_shuijing_buff:SetValue(true)
		local gather_buff_time =  KuaFuXiuLuoTowerData.Instance:GetBossGatherEndTime() or 0
		local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
		if seconds <= 0 then
			self.is_on_shuijing_buff:SetValue(true)
		end
		self:SetXiuLuoBuffBubblesText()

	elseif scene_type == SceneType.GuildStation then -- 军团驻地
		self:FlushMoneyTree()
		self:ShowGuildBossButton()

	elseif scene_type == SceneType.KfMining then -- 跨服挖矿
		--self.show_btn_shuijing_buff:SetValue(true)  --屏蔽掉跨服挖矿的无敌采集
		local gather_buff_time =  KuaFuMiningData.Instance:GetGatherBuffEndTime() or 0
		local seconds = math.floor(gather_buff_time - TimeCtrl.Instance:GetServerTime())
		if seconds <= 0 then
			self.is_on_shuijing_buff:SetValue(true)
		end
		self:SetMiningBuffBubblesText()

	elseif scene_type == SceneType.ChaosWar then	-- 一战到底
		self:SetBuffBtnInYiZhanDaoDiScene()
		self.is_on_buff:SetValue(not FuBenCtrl.Instance:ReturnIsGuWuFull())
		self.buy_buff.animator:SetBool("shake", not FuBenCtrl.Instance:ReturnIsGuWuFull())
	elseif scene_type == SceneType.LingyuFb then

		self.show_guildfight_rank_icon:SetValue(true)

		local role = GameVoManager.Instance:GetMainRoleVo()
		local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid or 0

		if role and role.role_id then
			self.show_zhaoji_btn:SetValue(tuanzhang_uid == role.role_id)
		else
			self.show_zhaoji_btn:SetValue(false)
		end
	elseif scene_type == SceneType.HotSpring then
		self.show_question_text:SetValue(true)
	elseif scene_type == SceneType.GongChengZhan then
		local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
		local vis = mainrole_vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG
		self.show_guild_call:SetValue(vis)
	elseif JingHuaHuSongData.Instance:IsJingHuaScene(scene_id) then
		self.show_jinghua_icon:SetValue(true)
		self:SetJingHuaHuSongNum()
	end
	self.vip3_limit:SetValue(PlayerData.Instance.role_vo.vip_level < 3)

	PlayerData.Instance:ListenerAttrChange(self.role_attr_change_event)
end

function FbIconView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:SetGuWuBuff()
	end
	self:SetBtnAnim()
end

-- 设置按钮的跳动动画
function FbIconView:SetBtnAnim()
	local scene_type = Scene.Instance:GetSceneType()

	if not self.buff_flag then
		if self.buy_buff_anim.animator.isActiveAndEnabled then
			self.buy_buff_anim.animator:SetBool("is_click",false)
		end
	end

	if not self.potion_flag then
		if self.buy_potion_anim.animator.isActiveAndEnabled then
			self.buy_potion_anim.animator:SetBool("is_click", false)
		end
	end

	if scene_type == SceneType.ShuiJing then
		if not self.shuijing_buff_flag then
			if self.shuijing_buff.animator.isActiveAndEnabled then
				self.shuijing_buff.animator:SetBool("is_click", false)
			end
		end
	elseif scene_type == SceneType.Kf_XiuLuoTower then
		if not self.xiuluo_buff_flag then
			if self.shuijing_buff.animator.isActiveAndEnabled then
				self.shuijing_buff.animator:SetBool("is_click", false)
			end
		end
	elseif scene_type == SceneType.KfMining then
		if not self.mining_buff_flag then
			if self.shuijing_buff.animator.isActiveAndEnabled then
				self.shuijing_buff.animator:SetBool("is_click", false)
			end
		end
	elseif scene_type == SceneType.CrossShuijing then
		if not self.tianshen_buff_flag then
			if self.shuijing_buff.animator.isActiveAndEnabled then
				self.shuijing_buff.animator:SetBool("is_click", false)
			end
		end
	end
end

function FbIconView:SetBuffBtnInYiZhanDaoDiScene()
	self.show_btn_buff:SetValue(true)
	self.is_on_buff:SetValue(true)
	self.on_buff_des:SetValue(Language.FuBen.IconViewBuffYiZhanDaoDiDes)
end

function FbIconView:OnRoleAttrValueChange(key, new_value, old_value)
	if key == "vip_level" then
		self.vip3_limit:SetValue(new_value < 3)
	end
end

function FbIconView:CloseCallBack()
	self.monster_diff_time_list = {}
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.reward_count_down then
		CountDown.Instance:RemoveCountDown(self.reward_count_down)
		self.reward_count_down = nil
	end
	for k, v in pairs(self.montser_count_down_list) do
		CountDown.Instance:RemoveCountDown(v)
	end
	self.montser_count_down_list = {}

	self.tip_id = nil
	if self.monster_variable_list[1] then
		self.monster_variable_list[1].show_monster_icon:SetValue(false)
		self.monster_variable_list[1].show_money_monster_icon:SetValue(false)
	end
	if self.monster_variable_list[2] then
		self.monster_variable_list[2].show_monster_icon:SetValue(false)
		self.monster_variable_list[1].show_money_monster_icon:SetValue(false)
	end

	self.is_show_skymoney_text = false
	self.is_complete = false

	self.auto_click_callback = nil
	-- self.click_call_back_list = {}
	PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change_event)
	self.is_countdown_leave = false
	if self.exit_time_act ~= nil then
		self.exit_time_act:SetValue(false)
	end

end

function FbIconView:SetCountDown()
	local scene_type = Scene.Instance:GetSceneType()
	-- self.show_auto_btn:SetValue(scene_type == SceneType.RuneTower)

	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo() or {}
	local quality_fb_info = {}
	if scene_type == SceneType.ChallengeFB then
		quality_fb_info = FuBenData.Instance:GetPassLayerInfo()
	end
	if not next(fb_scene_info) and not next(quality_fb_info) then return end

	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp
	-- self.fb_time = 0
	self.exit_time_act:SetValue((next(fb_scene_info) ~= nil
								and scene_type ~= SceneType.ExpFb
								and scene_type ~= SceneType.HunYanFb)
								or scene_type == SceneType.ChallengeFB)
	self.show_btn_time:SetValue((next(fb_scene_info) ~= nil and scene_type == SceneType.ExpFb) or scene_type == SceneType.ChallengeFB)

	if nil ~= self.temp_wave and nil ~= fb_scene_info.param1 then
		if next(fb_scene_info) and self.temp_wave < fb_scene_info.param1 then
			Scene.SendGetAllObjMoveInfoReq()
			if self.count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
		end
	end

	if next(fb_scene_info) and role_hp <= 0 and fb_scene_info.is_finish == 1 then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		return
	end
	if next(fb_scene_info) and fb_scene_info.is_pass == 1 and fb_scene_info.is_finish == 1 then
		if not self.is_countdown_leave then
			if not self.is_complete or scene_type ~= SceneType.CrossFB then
				if scene_type == SceneType.PataFB or scene_type == SceneType.RuneTower then
					-- 去掉爬塔副本打完一关后的倒计时
					self.fb_time = 0
				else
					self.fb_time = TimeCtrl.Instance:GetServerTime() + 15
				end
			end
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
			self.is_complete = true
			self.is_countdown_leave = true
		end
	else
		self.is_countdown_leave = false
		if next(quality_fb_info) then
			self.fb_time = quality_fb_info.time_out_stamp or 0
		else
			self.fb_time = fb_scene_info.time_out_stamp or 0
		end
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
	end

	if scene_type == SceneType.ExpFb then
		self.temp_wave = fb_scene_info.param1
	end

	if self.count_down == nil then
		local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(self.fb_time - TimeCtrl.Instance:GetServerTime() + 0.5)
			-- if left_time <= 30 then
			-- 	-- self.tx_color:SetValue(Language.FB.WarmColor)
			-- else
			-- 	-- self.tx_color:SetValue(Language.FB.NormalColor)
			-- end
			if left_time <= 0 then
				self.time_text:SetValue("00:00")
				--FuBenData.Instance:MaxExpFB() <= fb_scene_info.param1
				if next(fb_scene_info) and scene_type ~= SceneType.CrossFB
					and scene_type ~= SceneType.Kf_XiuLuoTower and scene_type ~= SceneType.SuoYaoTowerFB
					and scene_type ~= SceneType.TeamSpecialFb and scene_type ~= SceneType.TeamFB
					and scene_type ~= SceneType.SCENE_TYPE_TUITU_FB then
						FuBenCtrl.Instance:SendExitFBReq()
				elseif self.is_complete and scene_type ~= SceneType.SuoYaoTowerFB
					and scene_type ~= SceneType.TeamSpecialFb and scene_type ~= SceneType.TeamFB
					and scene_type ~= SceneType.SCENE_TYPE_TUITU_FB then
						FuBenCtrl.Instance:SendExitFBReq()
					-- if scene_type == SceneType.CrossFB then
					-- 	UserVo.Instance.plat_server_id = UserVo.Instance.old_plat_id
					-- 	UserVo.Instance.plat_name = UserVo.Instance.old_plat_name
					-- 	LoginCtrl.SendUserLogout()
					-- 	CrossServerData.Instance:SetDisconnectGameServer()
					-- 	GameNet.Instance:DisconnectGameServer()
					-- 	GameNet.Instance:AsyncConnectLoginServer(5)
					-- end
				elseif next(fb_scene_info) and fb_scene_info.is_pass == 0 and fb_scene_info.is_finish == 0 and scene_type ~= SceneType.TeamFB then
					GlobalTimerQuest:AddDelayTimer(function()
						ViewManager.Instance:Open(ViewName.FBFailFinishView)
					end, 2)
				elseif scene_type == SceneType.ChallengeFB then
					if next(quality_fb_info) and quality_fb_info.is_pass == 0 then
						GlobalTimerQuest:AddDelayTimer(function()
							ViewManager.Instance:Open(ViewName.FBFailFinishView)
						end, 2)
					end
				end
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			local h_text = ""
			local m_text = ""
			local s_text = ""
			local the_time_text = ""
			if left_hour > 0 then
				if left_hour> 9 then
					h_text = left_hour..":"
				else
					h_text = "0".. left_hour .. ":"
				end
				the_time_text = the_time_text .. h_text
			end
			if left_min > 9 then
				m_text = left_min .. "" .. ":"
			else
				m_text = "0".. left_min .. ":"
			end
			if left_sec > 9 then
				s_text = left_sec .. ""
			else
				s_text = "0"..left_sec
			end
			the_time_text = the_time_text .. m_text .. s_text
			self.time_text:SetValue(the_time_text)
		end

		local diff_time = self.fb_time - TimeCtrl.Instance:GetServerTime()
		if diff_time > 0 then
			diff_time_func(0, diff_time)
			self.count_down = CountDown.Instance:AddCountDown(
				diff_time, 0.5, diff_time_func)
		else
			self.exit_time_act:SetValue(false)
			self.time_text:SetValue("00:00")
		end
	end
end

function FbIconView:SwitchButtonState(enable)
	self.show_menu = not enable
	self:Flush()
end

function FbIconView:MainOpenComlete()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	self:Flush()
end

function FbIconView:FlushTWInfo()
	local next_reward_time = CityCombatData.Instance:GetTWRewardTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushGBInfo()
	local next_reward_time = CityCombatData.Instance:GetGBRewardTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushYiZhanDaoDiInfo()
	local next_reward_time = YiZhanDaoDiData.Instance:GetLuckyRewardNextFlushTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushQXLDInfo()
	local next_reward_time = CityCombatData.Instance:GetQXLDRewardTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushGongChenInfo()
	local next_reward_time = CityCombatData.Instance:GetZhanChangRewardTime()
	self:FlushRewardTime(next_reward_time)
end

function FbIconView:FlushRewardTime(next_reward_time)
	if self.reward_count_down then
		CountDown.Instance:RemoveCountDown(self.reward_count_down)
		self.reward_time:SetValue("")
		self.reward_count_down = nil
	end
	if 0 == next_reward_time then return end
	local servre_time = TimeCtrl.Instance:GetServerTime()
	self.reward_count_down = CountDown.Instance:AddCountDown(next_reward_time - servre_time, 1, BindTool.Bind(self.RewardCountDown, self))
end

function FbIconView:RewardCountDown(elapse_time, total_time)
	if total_time - elapse_time <= 0 then
		self.reward_time:SetValue("")
		return
	end
	local time_str = TimeUtil.FormatSecond(total_time - elapse_time, 2)
	self.reward_time:SetValue(time_str)
end

function FbIconView:FlushGuildRank()
	local global_info = GuildFightData.Instance:GetGlobalInfo()
	local des = ""
	if global_info.guild_rank <= 0 then
		des = Language.Guild.NotGuildFightRank
	else
		des = string.format(Language.Guild.GuildFightRank, global_info.guild_rank)
	end
	self.guild_now_rank_des:SetValue(des)
end

function FbIconView:FlushGuildCallTimes()
	left_times = CityCombatData.Instance:GetGuildCallLeftTimes()
	self.guild_call_times:SetValue(string.format(Language.CityCombat.LeftTimes, left_times))
end

function FbIconView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "zhanchan_info" then
			self:FlushGongChenInfo()
		elseif k == "tw_info" then
			self:FlushTWInfo()
		elseif k == "gb_info" then
			self:FlushGBInfo()
		elseif k == "qxld_info" then
			self:FlushQXLDInfo()
		elseif k == "xzyj_info" then
			self:SetConditionData()
		elseif k == "question" then
			self:CheckQuestionPrepare()
		elseif k == "guild_boss" then
			self:FlushGuildBossIcon()
		elseif k == "yizhandaodi_info" then
			self:FlushYiZhanDaoDiInfo()
		elseif k == "guild_rank" then
			self:FlushGuildRank()
			--不return掉的话界面会一直刷很奇怪
			return
		elseif k == "guild_call" then
			self:FlushGuildCallTimes()
			return
		end
	end
	self.panel_act:SetValue(not self.show_menu)
	self:SetBtnAnim()
	self.exit_btn_vis:SetValue(self.is_show_btn_outfb)
	self.dec_btn_vis:SetValue(self.is_show_dec_btn)
	self.show_rank_reward_icon:SetValue(self.is_show_rank_reward_btn)
	local scene_type = Scene.Instance:GetSceneType()
	local scene_id = Scene.Instance:GetSceneId()
	self.show_btn_reward:SetValue(scene_type == SceneType.GongChengZhan or
		scene_type == SceneType.ClashTerritory or
		scene_type == SceneType.LingyuFb or
		scene_type == SceneType.QunXianLuanDou
		or scene_type == SceneType.ChaosWar)
	if self.is_show_btn_outfb then
		if scene_type == SceneType.GongChengZhan then
			self:DoActivityCountDown(ACTIVITY_TYPE.GONGCHENGZHAN)
			self:FlushGongChenInfo()
		elseif scene_type == SceneType.TombExplore then
			self:DoActivityCountDown(ACTIVITY_TYPE.TOMB_EXPLORE)
		elseif scene_type == SceneType.Kf_XiuLuoTower then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_XIULUO_TOWER)
		elseif scene_type == SceneType.ClashTerritory then
			self:DoActivityCountDown(ACTIVITY_TYPE.CLASH_TERRITORY)
			self:FlushTWInfo()
		elseif scene_type == SceneType.QunXianLuanDou then
			self:DoActivityCountDown(ACTIVITY_TYPE.QUNXIANLUANDOU)
			self:FlushQXLDInfo()
		elseif scene_type == SceneType.TianJiangCaiBao then
			self:DoActivityCountDown(ACTIVITY_TYPE.TIANJIANGCAIBAO)
		elseif scene_type == SceneType.GuildMiJingFB then
			self:DoActivityCountDown(ACTIVITY_TYPE.GUILD_SHILIAN)
		elseif scene_type == SceneType.HotSpring then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_HOT_SPRING)
			self:CheckQuestionPrepare()
		elseif scene_type == SceneType.LingyuFb then
			self:DoActivityCountDown(ACTIVITY_TYPE.GUILDBATTLE)
			self:FlushGBInfo()
		elseif scene_type == SceneType.ChaosWar then		-- 一战到底
			self:DoActivityCountDown(ACTIVITY_TYPE.CHAOSWAR)
			self:FlushYiZhanDaoDiInfo()
		elseif scene_type == SceneType.KfMining then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_MINING)
		elseif scene_type == SceneType.Fishing then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_FISHING)
		elseif scene_type == SceneType.CrossShuijing then
			self:DoActivityCountDown(ACTIVITY_TYPE.CROSS_SHUIJING)
		else
			self:SetCountDown()
		end
	end

	--三倍挂机因为是普通场景，额外单独处理时间

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI) and YewaiGuajiData.Instance:IsGuaJiScene(scene_id) then
		self:DoActivityCountDown(ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI)
	end

	-- if self.is_show_dec_btn then
	-- 	if not SettingData.Instance:HasEnterFb(scene_type, scene_id) then
	-- 		SettingData.Instance:SetFbEnterFlag(scene_type, true, scene_id)
	-- 		self:OnClicExplain(true)
	-- 	end
	-- end

	self:FlushGuildBossIcon()

	for k, v in pairs(self.monster_diff_time_list) do
		if v > 0 then
			self:SetMonsterCountDown(k)
		end
	end

	self.show_text:SetValue(self.is_show_skymoney_text)

	self:SetMonsterCacheInfo()
end

function FbIconView:ActivityCallBack()
	self:FlushGuildBossIcon()
end

function FbIconView:FlushGuildBossIcon()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.GuildStation then
		self.show_guild_button:SetValue(true)
		local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BOSS)
		local boss_info = GuildData.Instance:GetBossInfo() or {}
		local boss_normal_call_count = boss_info.boss_normal_call_count or 0
		-- 如果今天还没有召唤过boss
		if is_open and boss_normal_call_count <= 0 then
--			self.guild_boss_icon.animator:SetBool("Flash", true)
		else
--			self.guild_boss_icon.animator:SetBool("Flash", false)
		end
	else
		self.show_guild_button:SetValue(false)
	end
end

function FbIconView:DoActivityCountDown(activity_type)
	local info = ActivityData.Instance:GetActivityStatuByType(activity_type)
	if info then
		local end_time = info.next_time or 0
		local total_time = end_time - TimeCtrl.Instance:GetServerTime()
		self:SetCountDownByTotalTime(total_time)
	end
end

function FbIconView:SetCountDownByTotalTime(total_time)
	if self:IsLoaded() then
		if total_time <= 0 then
			self.exit_time_act:SetValue(false)
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
			return
		end

		local scene_type = Scene.Instance:GetSceneType()

		if scene_type == SceneType.GuildStation then
			self.exit_time_act:SetValue(false)
		else
			self.exit_time_act:SetValue(true)
		end

		if self.count_down == nil then
			local function diff_time_func(elapse_time, total_time2)
				if elapse_time >= total_time2 then
					local time = "00:00"
					self.time_text:SetValue(time)
					self.show_btn_time:SetValue(false)
					if self.count_down then
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
					return
				end
				local left_time = math.floor(total_time2 - elapse_time + 0.5)
				local h, m, s = WelfareData.Instance:TimeFormat(left_time)
				local h_text = ""
				local m_text = ""
				local s_text = ""
				local the_time_text = ""
				if h > 0 then
					if h>9 then
						h_text = h..":"
					else
						h_text = "0".. h .. ":"
					end
					the_time_text = the_time_text .. h_text
				end
				if m > 9 then
					m_text = m .. "" .. ":"
				else
					m_text = "0".. m .. ":"
				end
				if s > 9 then
					s_text = s .. ""
				else
					s_text = "0"..s
				end
				the_time_text = the_time_text .. m_text .. s_text
				self.time_text:SetValue(the_time_text)
			end
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
			diff_time_func(0, total_time)
			self.count_down = CountDown.Instance:AddCountDown(
				total_time, 0.5, diff_time_func)
		end
	end
end

function FbIconView:OnClickGuildBoss()
	ViewManager.Instance:Open(ViewName.GuildBoss)
end

function FbIconView:OpenMoneyTree()
	local info = PlayerData.Instance:GetRoleVo()
	local guild_id = GuildData.Instance.guild_id

	local yes_func = function()
		GuildCtrl.Instance:OpenGuildMoneyTree(guild_id, info.role_id)
	end

	TipsCtrl.Instance:ShowCommonAutoView("", Language.Guild.OpenMoneyTree, yes_func)
end

function FbIconView:ShowGuildBossButton()
	if nil == self.show_guild_boss then
		return
	end

	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.GUILD_BOSS)
	local scene_type = Scene.Instance:GetSceneType()

	self.show_guild_boss:SetValue(false)
	if act_info and scene_type == SceneType.GuildStation then
		if act_info.status == ACTIVITY_STATUS.OPEN or act_info.status == ACTIVITY_STATUS.STANDY then
			self.show_guild_boss:SetValue(true)
		end
	end
end

function FbIconView:SetMonsterInfo(monster_id, index)
	local index = index or 1
	if self:IsLoaded() then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[monster_id]
		if not monster_cfg then return end
			if monster_cfg.headid > 0 then
				local bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
				if Scene.Instance:GetSceneType() == SceneType.TianJiangCaiBao then
					bundle, asset = ResPath.GetlingxingBossIcon(monster_cfg.headid)
				end
				self.monster_variable_list[index].monster_icon:SetAsset(bundle, asset)
			end
		else
		self.monster_id = monster_id
	end
end

function FbIconView:SetMo_LongIcon()
	local index = 1
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[8402]
	local bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
	self.monster_variable_list[index].monster_icon:SetAsset(bundle, asset)
end

-- 设置 已刷新 文本 Active
function FbIconView:ShowMonsterHadFlush(enable, flush_text, index)
	local index = index or 1

	if self:IsLoaded() then
		-- 怪物刷新后文本的显示，默认显示“已刷新”
		local flush_text = flush_text or Language.Boss.HadFlush
		self.monster_variable_list[index].show_monster_had_flush:SetValue(enable)
		if enable then
			self:SetMonsterIcon(index, true)
			self.monster_variable_list[index].had_flush_text:SetValue(flush_text)

			if self.montser_count_down_list[index] ~= nil then
				CountDown.Instance:RemoveCountDown(self.montser_count_down_list[index])
				self.montser_count_down_list[index] = nil
			end
		end
	else
		FuBenData.Instance:SaveShowMonsterHadFlush(enable, flush_text, index)
	end
end

-- 设置右侧怪物倒计时
function FbIconView:SetMonsterDiffTime(diff_time, index)
	local index = index or 1
	self.monster_diff_time_list[index] = diff_time
	if self:IsLoaded() then
		self:SetMonsterCountDown(index)
	end
end

function FbIconView:SetMonsterIconState(enable, index)
	local index = index or 1
	if self:IsLoaded() then
		self:SetMonsterIcon(index, enable)
	else
		FuBenData.Instance:SaveMonsterIconState(enable, index)
	end
end

function FbIconView:SetMonsterIconGray(enable, index)
	local index = index or 1
	if self:IsLoaded() then
		self.monster_variable_list[index].show_gray:SetValue(enable)
	else
		FuBenData.Instance:SaveMonsterIconGray(enable, index)
	end
end

function FbIconView:SetMonsterCountDown(index)
	local index = index or 1
	if not self.montser_count_down_list[index] and self.monster_diff_time_list[index] and tonumber(self.monster_diff_time_list[index]) > 0 then
		local diff_time = self.monster_diff_time_list[index]

		self:SetMonsterIcon(index, true)
		local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0.5 then
				if self.montser_count_down_list[index] ~= nil then
					CountDown.Instance:RemoveCountDown(self.montser_count_down_list[index])
					self.montser_count_down_list[index] = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.monster_variable_list[index].monster_min:SetValue(left_min)
			self.monster_variable_list[index].monster_sec:SetValue(left_sec)
		end
		if self.montser_count_down_list[index] ~= nil then
			CountDown.Instance:RemoveCountDown(self.montser_count_down_list[index])
			self.montser_count_down_list[index] = nil
		end
		diff_time_func(0, diff_time)
		self.montser_count_down_list[index] = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function FbIconView:SetClickCallBack(call_back, index)
	local index = index or 1
	self.click_call_back_list[index] = call_back
end

function FbIconView:ClearClickCallBack()
	self.click_call_back_list = {}
end

function FbIconView:OnClickBossIcon(index)
	if Scene.Instance:GetSceneType() == SceneType.DaFuHao then
		if DaFuHaoAutoGatherEvent.func then
			DaFuHaoAutoGatherEvent.func()
		end
	end

	if self.click_call_back_list[index] then
		self.click_call_back_list[index]()
	end
end

function FbIconView:SetSkyMoneyTextState(value)
	self.is_show_skymoney_text = value

	if self.show_text then
		self.show_text:SetValue(self.is_show_skymoney_text)
	end
end

function FbIconView:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
	return nil
end

function FbIconView:SetAutoBtnClickCallBack(call_back)
	self.auto_click_callback = call_back
end

function FbIconView:OnClickAutoBtn()
	if self.auto_click_callback then
		self.auto_click_callback(self.auto_btn.toggle)
	end
end

function FbIconView:OnClickGuildFightRank()
	GuildFightCtrl.Instance:OpenRank()
end

function FbIconView:SetExitArrowState()
	if nil ~= self.show_exit_arrow then
		self.show_exit_arrow:SetValue(DaFuHaoData.Instance:IsDaFuHaoScene() and DaFuHaoData.Instance:IsGatherTimesLimit())
	end
end

function FbIconView:SetConditionData()
	if nil == self.show_condition then
		return
	end

	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.XingZuoYiJi then
		return
	end

	local info = RelicData.Instance:GetXingzuoYijiInfo()
	if nil == next(info) then return end

	self.show_condition:SetValue(true)
	local temp_str = ""
	if info.now_boss_num > 0 then
		temp_str = string.format(Language.ShengXiao.CurBossNum)
	else
		temp_str = string.format(Language.ShengXiao.CurBoxNum, info.now_box_num)
	end
	self.condition_txt:SetValue(temp_str)
end

function FbIconView:CheckQuestionPrepare()
	self.show_question_text:SetValue(true)
	self.exit_time_act:SetValue(false)

	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_HOT_SPRING) or {}
	local end_time = activity_info.next_time or 0

	local last_time = math.floor(end_time - TimeCtrl.Instance:GetServerTime())
	self:RemoveQuestionCountDown()
	self:SetQuestionPrepareTime(last_time)
end

function FbIconView:SetQuestionPrepareTime(total_time)
	if self.question_count_down == nil then
		self.question_count_down = CountDown.Instance:AddCountDown(total_time, 1, BindTool.Bind(self.HotSpringCountDown, self))
	end
end

function FbIconView:HotSpringCountDown(elapse_time, total_time)
	total_time = total_time - elapse_time
	local title_text = ""
	local the_time_text = ""
	local answer_last_time = HotStringChatData.Instance:GetActivityPrepareTime()			-- 温泉答题剩余准备时间
	local gather_flush_time = HotStringChatData.Instance:GetGatherFlushTime()				-- 采集物开始刷新时间
	local server_time = TimeCtrl.Instance:GetServerTime()

	if answer_last_time > 1 then
		title_text = Language.HotString.QuestionCountDown
		the_time_text = answer_last_time
		local _, mins, seconds = WelfareData.Instance:TimeFormat(math.floor(the_time_text))
		mins = WelfareData.Instance:TimeWithZero(mins)
		seconds = WelfareData.Instance:TimeWithZero(seconds)
		the_time_text = string.format(Language.HotString.AnswerTimeText, mins, seconds)
	else
		self.show_question_text:SetValue(false)
	end

	if gather_flush_time <= server_time then
		self.show_question_text:SetValue(true)
		title_text = Language.HotString.GatherCountDown
		local _, _, seconds = WelfareData.Instance:TimeFormat(math.floor(total_time))
		seconds = WelfareData.Instance:TimeWithZero(seconds)
		the_time_text = string.format(Language.HotString.GatherTimeText, seconds)
	end

	self.hot_spring_text:SetValue(title_text)
	self.question_prepare_time:SetValue(the_time_text)
end

function FbIconView:RemoveQuestionCountDown()
	if self.question_count_down then
		CountDown.Instance:RemoveCountDown(self.question_count_down)
		self.question_count_down = nil
	end
end

function FbIconView:SetMonsterCacheInfo()
	local icon_state_cache = FuBenData.Instance:GetMonsterIconStateCache()
	for k, v in pairs(icon_state_cache) do
		if self.monster_variable_list[k] then
			self:SetMonsterIcon(k, v)
		end
	end

	local icon_gray_cache = FuBenData.Instance:GetMonsterIconGrayCache()
	for k, v in pairs(icon_gray_cache) do
		if self.monster_variable_list[k] then
			self.monster_variable_list[k].show_gray:SetValue(v)
		end
	end

	local icon_flush_cache = FuBenData.Instance:GetShowMonsterHadFlushCache()
	local flush_text = Language.Boss.HadFlush
	for k, v in pairs(icon_flush_cache) do
		if self.monster_variable_list[k] then
			flush_text = v.flush_text or flush_text
			self.monster_variable_list[k].show_monster_had_flush:SetValue(v.enable)
			self.monster_variable_list[k].had_flush_text:SetValue(flush_text)
		end
	end

	FuBenData.Instance:ClearFBIconCache()
end

function FbIconView:SetMonsterIcon(i, v)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.TianJiangCaiBao then
		self.monster_variable_list[i].show_money_monster_icon:SetValue(v)
	else
		self.monster_variable_list[i].show_monster_icon:SetValue(v)
	end
end


function FbIconView:FlushZhaoJiRemindTimes()
	if self.zhaoji_times then
		self.zhaoji_times:SetValue(GuildFightData.Instance:GetRemindZhaojiTimes() or 0)
	end
end

function FbIconView:OpenJingHuaActView()
	ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.JINGHUA_HUSONG)
end

function FbIconView:SetJingHuaHuSongNum()
	local num = MainUIData.Instance:GetJingHuaHuSongNum()
	if nil == num then
		num = 0
	end

	if self.jingua_husong_num then
		self.jingua_husong_num:SetValue(num)
	end
end

function FbIconView:FlushMoneyTree()
	if nil == self.show_btn_time then
		return
	end

	local state = GuildData.Instance:GetMoneyTreeState()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local moneytree_info = GuildData.Instance:GetMoneyTreeTimeInfo()
	local next_time = moneytree_info.tianci_tongbi_close_time or 0
	local time = next_time - now_time
	local moneytree_pos = GuildData.Instance:GetMoneyTreePosInfo()
	local npc_id = GuildData.Instance:GetMoneyTreeID()
	local vo = {}

	if state then
		self.show_btn_time:SetValue(true)
		self:SetCountDownByTotalTime(time)
		if nil == moneytree_pos or nil == next(moneytree_pos) then
			return
		end

		vo.npc_id = npc_id or 0
		vo.pos_x = moneytree_pos.npc_x	or 0
		vo.pos_y = moneytree_pos.npc_y	or 0
		self:CreatMoneyTree(vo.npc_id, vo.pos_x, vo.pos_y, 0)
	end

end

function FbIconView:CreatMoneyTree(npc_id, x, y, rotation_y)
	local npc = Scene.Instance:GetNpcByNpcId(npc_id)
	if npc then
		return
	end

	local vo =	NpcVo.New()
	vo.npc_id = npc_id
	vo.pos_x = x
	vo.pos_y = y
	vo.rotation_y = rotation_y
	Scene.Instance:CreateNpc(vo)
	local npc_obj = Scene.Instance:GetNpcByNpcId(npc_id)
	npc_obj:GetFollowUi():SetName("")
	-- npc_obj:GetFollowUi():SetTextScale(3, 3)
	-- npc_obj:GetFollowUi():SetTextPosY(0)
end