FbIconView = FbIconView or BaseClass(BaseView)
function FbIconView:__init()
	self.ui_config = {"uis/views/fubenview", "FBIconsView"}
	self.view_layer = UiLayer.MainUILow
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
end

function FbIconView:LoadCallBack()
	self.guild_boss_icon = self:FindObj("GuildBoss")
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

	-- 战场奖励列表按钮
	self.show_btn_reward = self:FindVariable("ShowRewardIcon")
	self.reward_time = self:FindVariable("reward_time")

	self.buy_buff = self:FindObj("BuyBuff")
	self.buy_potion = self:FindObj("BuyPotion")
	self.potion_flag = true
	self.buff_flag = true

	self.is_on_potion = self:FindVariable("IsOnPotion")
	self.is_on_buff = self:FindVariable("IsOnBuff")

	-- self.tx_color = self:FindVariable("Color")
	-- self.show_help_tip = self:FindVariable("ShowHelpTip")

	self.exit_btn_vis = self:FindVariable("ExitBtnVis")
	self.dec_btn_vis = self:FindVariable("DecBtnVis")
	-- self.help_dec = self:FindVariable("HelpDec")
	self.exit_time_act = self:FindVariable("ExitTimeAct")
	self.panel_act = self:FindVariable("Panel")
	self.show_guild_boss = self:FindVariable("ShowGuildBoss")
	self.show_btn_time = self:FindVariable("ShowBtnTime")		-- 离开按钮下面的倒计时
	self.show_auto_btn = self:FindVariable("ShowAutoBtn")		-- 自动挑战按钮
	self.show_exit_arrow = self:FindVariable("ShowExitArrow")		-- 离开场景提示箭头
	self.show_condition = self:FindVariable("ShowCondition")		-- 不显示时间，显示完成任务条件
	self.condition_txt = self:FindVariable("ConditionTxt")
	self.show_question_text = self:FindVariable("ShowQuestionText")
	self.question_prepare_time = self:FindVariable("QuestionPrepareTime")
	self.show_question_text:SetValue(false)
	self.show_guwu = self:FindVariable("Show_GuWu")
	self.vip3_limit = self:FindVariable("Vip3Limit")
	self.auto_btn = self:FindObj("AutoBtn")
	self.left_time_obj = self:FindObj("LeftTimeObj")
	self.is_hunyan = self:FindVariable("IsHunYan")
	self.leave_text = self:FindVariable("LeaveText")
	self.btn_guwu = self:FindObj("GuWuBtn")
	self.btn_explain = self:FindObj("ExplainBtn")
	self.show_gongxian = self:FindVariable("ShowGongXian")
	self.is_click = true
	
	-- 右侧图标，重要怪物刷新
	for i = 1, 2 do
		self.monster_variable_list[i] = {
			monster_min = self:FindVariable("MonsterTimeMin"..i),
			monster_sec = self:FindVariable("MonsterTimeSec"..i),
			monster_icon = self:FindVariable("MonsterIcon"..i),
			show_monster_icon = self:FindVariable("ShowMonsterIcon"..i),
			show_monster_had_flush = self:FindVariable("ShowMonsterHadFlush"..i), -- 怪物已经刷新
			had_flush_text = self:FindVariable("HadFlushText"..i),	-- 刷新后显示的文字
			show_gray = self:FindVariable("ShowMonsterIconGray"..i),	-- 图标置灰
		}
	end

	self:ListenEvent("OnClickExit", BindTool.Bind(self.OnClickExit, self))
	self:ListenEvent("OnClicExplain", BindTool.Bind(self.OnClicExplain, self))
	self:ListenEvent("OnClickExpBuff", BindTool.Bind(self.OnClickExpBuff, self))
	self:ListenEvent("OnClickExpPotion", BindTool.Bind(self.OnClickExpPotion, self))
	self:ListenEvent("OnClickGuildBoss", BindTool.Bind(self.OnClickGuildBoss, self))
	self:ListenEvent("OnClickBossIcon1", BindTool.Bind(self.OnClickBossIcon, self, 1))
	self:ListenEvent("OnClickBossIcon2", BindTool.Bind(self.OnClickBossIcon, self, 2))
	self:ListenEvent("OnClickAutoBtn", BindTool.Bind(self.OnClickAutoBtn, self))
	self:ListenEvent("OnClickGuWu", BindTool.Bind(self.OnClickGuWu, self))
	self:ListenEvent("OnClickRewardIcon", BindTool.Bind(self.OnClickRewardIcon, self))
	self:ListenEvent("OnClickGongXian", BindTool.Bind(self.OnClickGongXian, self))

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
	end
	self:ShowGuWuBtn()
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

	if GuaJiTaData.Instance then
		GuaJiTaData.Instance:SetAutoBtnState(false)
	end

	self:RemoveQuestionCountDown()

	-- 清理变量和对象
	self.guild_boss_icon = nil
	self.exit_fb_btn = nil
	self.time_text = nil
	self.show_text = nil
	self.show_btn_potion = nil
	self.show_btn_buff = nil
	self.buy_buff = nil
	self.buy_potion = nil
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
	self.monster_variable_list = {}
	self.show_exit_arrow = nil
	self.show_condition = nil
	self.condition_txt = nil
	self.show_question_text = nil
	self.question_prepare_time = nil
	self.show_guwu = nil
	self.left_time_obj = nil
	self.is_show_guest_manage = nil
	self.is_hunyan = nil
	self.leave_text = nil
	self.btn_guwu = nil
	self.btn_explain = nil
	self.is_click = nil
	self.show_gongxian = nil
end

function FbIconView:ExitWithTips(str)
	local yes_func = function ()
		FuBenCtrl.Instance:SendExitFBReq()

		if Scene.Instance:GetSceneType() == SceneType.CrossFB then
			CrossServerData.Instance:SetLeaveCrossFbState(true)
		end
	end
	-- TipsCtrl.Instance:ShowTwoOptionView(Language.Common.ExitCurrentScene, yes_func)
	TipsCtrl.Instance:ShowCommonTip(yes_func, nil, str or Language.Common.ExitCurrentScene)
end

function FbIconView:OnClickExit()
	local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if scene_cfg.fight_cant_exit and 1 == scene_cfg.fight_cant_exit then
		local main_role = Scene.Instance:GetMainRole()
		if main_role:IsFightState() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.FightingCantExitFb)
			return
		end
	end
	-- local scene_type = Scene.Instance:GetSceneType()
	-- if scene_type == SceneType.GongChengZhan or
	-- 	scene_type == SceneType.HunYanFb or
	-- 	scene_type == SceneType.TombExplore or
	-- 	scene_type == SceneType.ClashTerritory or
	-- 	scene_type == SceneType.QunXianLuanDou or
	-- 	scene_type == SceneType.Kf_XiuLuoTower or
	-- 	scene_type == SceneType.ShuiJing or
	-- 	scene_type == SceneType.ZhongKui or
	-- 	scene_type == SceneType.TianJiangCaiBao or
	-- 	scene_type == SceneType.Question or
	-- 	scene_type == SceneType.QingYuanFB or
	-- 	scene_type == SceneType.LingyuFb or
	-- 	scene_type == SceneType.HotSpring or
	-- 	scene_type == SceneType.CrossBoss then
	-- 		self:ExitWithTips()
	-- 	return
	-- end
	-- if scene_type == SceneType.CrossFB then
	-- 	local str =	Language.KuaFuFuBen.Exit
	-- 	self:ExitWithTips(str)
	-- 	return
	-- end

	local scene_id = Scene.Instance:GetSceneId()
	if AncientRelicsData.IsAncientRelics(scene_id)
	or RelicData.Instance:IsRelicScene(scene_id) then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		local scene_logic = Scene.Instance:GetSceneLogic()
		local x, y = scene_logic:GetTargetScenePos(scene_id)
		if x == nil or y == nil then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotToTarget)
			return
		end
		GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0)
		return
	end
	if BossData.IsWorldBossScene(scene_id)
	or BossData.IsDabaoBossScene(scene_id)
	or BossData.IsFamilyBossScene(scene_id)
	or BossData.IsMikuBossScene(scene_id)
	or BossData.IsActiveBossScene(scene_id)
	or BossData.IsBabyBossScene(scene_id) then
		local func = function()
			if BossData.IsWorldBossScene(scene_id) then
				BossCtrl.Instance:SendEnterBossWorld(BossData.WORLD_BOSS_ENTER_TYPE.WORLD_BOSS_LEAVE)
			elseif BossData.IsBabyBossScene(scene_id) then
				BossCtrl.SendBabyBossOpera(BABY_BOSS_OPERATE_TYPE.TYPE_LEAVE_REQ)
			else
				BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE)
			end
		end
		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Boss.ExitCurrentScene)
		return
	end

	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ExpFb then
		self:ExitWithTips(Language.Common.ExitCurrentScene)
		return
	elseif scene_type == SceneType.DiMaiFb then
		self:ExitWithTips(Language.QiangDiMai.ExitDiMaiRemind)
		return
	else
		if scene_cfg.out_ui == 1 then
			self:ExitWithTips(scene_cfg.ui_instructions)
		 	return
		end
	end

	FuBenCtrl.Instance:SendExitFBReq()

	GuaJiTaData.Instance:SetAutoBtnState(false)
end

-- 玩法说明
function FbIconView:OnClicExplain()
	-- self.show_help_tip:SetValue(true)
	if self.tip_id then
		TipsCtrl.Instance:ShowHelpTipView(self.tip_id)
		return
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg then
		TipsCtrl.Instance:ShowHelpTipView(fb_scene_cfg.fb_desc)
	end
end

function FbIconView:CloseHelpTip()
	-- self.show_help_tip:SetValue(false)
end

function FbIconView:SetBuffBubbles()
	self.is_on_buff:SetValue(false)
end

function FbIconView:SetPotionBubbles()
	self.is_on_potion:SetValue(false)
end

function FbIconView:OnClickExpBuff()
	self:SetBuffBubbles()
	if self.buff_flag == true then
		self.buy_buff.animator:SetBool("shake", false)
		self.buff_flag = false
	end
	TipsCtrl.Instance:TipsExpInSprieFuBenView()
end

function FbIconView:OnClickRewardIcon()
	CityCombatCtrl.Instance:OpenRewardView()
end

function FbIconView:OnClickExpPotion()
	self:SetPotionBubbles()
	if self.potion_flag == true then
		self.buy_potion.animator:SetBool("shake", false)
		self.potion_flag = false
	end
	TipsCtrl.Instance:ShowTipExpFubenView()
end

function FbIconView:OnClickGongXian()
	ViewManager.Instance:Open(ViewName.LianFuRankView)
end

function FbIconView:PotionEffectState()
	if FightData.Instance:GetMainRoleDrugAddExp() ~= 0 then
		self.buy_potion.animator:SetBool("shake", false)
	end
end

function FbIconView:OpenCallBack()
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
		else
			self.is_on_potion:SetValue(false)
			self.is_on_buff:SetValue(false)
		end
	else
		self.show_btn_potion:SetValue(false)
		self.show_btn_buff:SetValue(false)
	end
	self.vip3_limit:SetValue(PlayerData.Instance.role_vo.vip_level < 3)

	PlayerData.Instance:ListenerAttrChange(self.role_attr_change_event)
	-- self.buy_potion.animator:SetBool("shake", true)
	-- self.buy_buff.animator:SetBool("shake", true)
	
	if self.auto_btn then
		self.auto_btn.toggle.isOn = GuaJiTaData.Instance:GetAutoBtnState()
	end
	self.show_exit_arrow:SetValue(DaFuHaoData.Instance:IsDaFuHaoScene() and DaFuHaoData.Instance:IsGatherTimesLimit())
	self.show_question_text:SetValue(false)

	local leave_str = Language.Common.ExitScene
	if scene_type == SceneType.ShuiJing 
		or scene_type == SceneType.GongChengZhan
		or scene_type == SceneType.LingyuFb then		
		leave_str = Language.Common.ExitActivityScene
	end
	self.leave_text:SetValue(leave_str)
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
	end
	if self.monster_variable_list[2] then
		self.monster_variable_list[2].show_monster_icon:SetValue(false)
	end

	self.is_show_skymoney_text = false
	self.is_complete = false

	self.auto_click_callback = nil
	self.click_call_back_list = {}
	PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change_event)
	self.is_countdown_leave = false
	if self.exit_time_act then
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

	self.exit_time_act:SetValue((next(fb_scene_info) ~= nil and scene_type ~= SceneType.ExpFb) or scene_type == SceneType.ChallengeFB or scene_type == SceneType.HunYanFb)
	self.show_btn_time:SetValue((next(fb_scene_info) ~= nil and scene_type == SceneType.ExpFb) or scene_type == SceneType.ChallengeFB or scene_type == SceneType.HunYanFb)

	if nil ~= self.temp_wave then
		if next(fb_scene_info) and self.temp_wave  < fb_scene_info.param1 then
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
				elseif scene_type == SceneType.JunXian or scene_type == SceneType.DailyTaskFb then
					self.fb_time = TimeCtrl.Instance:GetServerTime() + 5
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
			if elapse_time >= total_time then
				self.time_text:SetValue("00:00")
				--FuBenData.Instance:MaxExpFB() <= fb_scene_info.param1
				if next(fb_scene_info) and scene_type ~= SceneType.CrossFB and scene_type ~= SceneType.Kf_XiuLuoTower then
					FuBenCtrl.Instance:SendExitFBReq()
				elseif self.is_complete then
					FuBenCtrl.Instance:SendExitFBReq()
					-- if scene_type == SceneType.CrossFB then
					-- 	UserVo.Instance.plat_server_id = UserVo.Instance.old_plat_id
					-- 	UserVo.Instance.plat_name = UserVo.Instance.old_plat_name
					-- 	LoginCtrl.SendUserLogout()
					-- 	CrossServerData.Instance:SetDisconnectGameServer()
					-- 	GameNet.Instance:DisconnectGameServer()
					-- 	GameNet.Instance:AsyncConnectLoginServer(5)
					-- end
				elseif next(fb_scene_info) and fb_scene_info.is_pass == 0 and fb_scene_info.is_finish == 0 then
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
		end
	end
	self.panel_act:SetValue(not self.show_menu)
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local name_list_t = Split(fb_scene_cfg.show_fbicon, "#")
	local btn_outfb_vis = false
	local dec_btn_vis = false
	for k,v in pairs(name_list_t) do
		if v == "btn_outfb" then
			btn_outfb_vis = true
		elseif v == "btn_fbdesc" then
			dec_btn_vis = true
		end
	end

	--世界boss
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.IsWorldBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 140
	elseif BossData.IsDabaoBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 143
	elseif BossData.IsFamilyBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 141
	elseif	BossData.IsMikuBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 142
	elseif BossData.IsKfBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 144
	elseif BossData.IsActiveBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 160
	elseif AncientRelicsData.IsAncientRelics(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 165
	elseif RelicData.Instance:IsRelicScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 174
	elseif BossData.IsBabyBossScene(scene_id) then
		btn_outfb_vis = true
		dec_btn_vis = true
		self.tip_id = 258
	end
	self.exit_btn_vis:SetValue(btn_outfb_vis)
	self.dec_btn_vis:SetValue(dec_btn_vis)
	local scene_type = Scene.Instance:GetSceneType()
	local scene_id = Scene.Instance:GetSceneId()
	self.show_btn_reward:SetValue(scene_type == SceneType.GongChengZhan or
		scene_type == SceneType.ClashTerritory or
		scene_type == SceneType.LingyuFb or
		scene_type == SceneType.QunXianLuanDou)
	self.is_hunyan:SetValue(scene_type == SceneType.HunYanFb)

	if btn_outfb_vis then
		if scene_type == SceneType.GongChengZhan then
			self:DoActivityCountDown(ACTIVITY_TYPE.GONGCHENGZHAN)
			self:FlushGongChenInfo()
		elseif scene_type == SceneType.HunYanFb then
			GlobalTimerQuest:AddDelayTimer(function()
				local total_time = MarriageData.Instance:GetWeedingTime()
				self:SetCountDownByTotalTime(total_time)
			end, 1)
		elseif scene_type == SceneType.TombExplore then
			self:DoActivityCountDown(ACTIVITY_TYPE.TOMB_EXPLORE)
		elseif scene_type == SceneType.Kf_XiuLuoTower then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_XIULUO_TOWER)
		elseif scene_type == SceneType.ClashTerritory then
			self:DoActivityCountDown(ACTIVITY_TYPE.CLASH_TERRITORY)
			self:FlushTWInfo()
		elseif scene_type == SceneType.QunXianLuanDou then
			self:DoActivityCountDown(ACTIVITY_TYPE.QUNXIANLUANDOU, true, 60)
			self:FlushQXLDInfo()
		elseif scene_type == SceneType.TianJiangCaiBao then
			self:DoActivityCountDown(ACTIVITY_TYPE.TIANJIANGCAIBAO)
		elseif scene_type == SceneType.GuildMiJingFB then
			self:DoActivityCountDown(ACTIVITY_TYPE.GUILD_SHILIAN)
		elseif scene_type == SceneType.HotSpring then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_HOT_SPRING)
			self:CheckQuestionPrepare()
		elseif scene_type == SceneType.LingyuFb then
			self:DoActivityCountDown(ACTIVITY_TYPE.GUILDBATTLE, true, 30)
			self:FlushGBInfo()
		elseif scene_type == SceneType.KfMining then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_MINING, false, 60)
		elseif scene_type == SceneType.Fishing then
			self:DoActivityCountDown(ACTIVITY_TYPE.KF_FISHING, false, 60)
		else
			self:SetCountDown()
		end
	end
	if dec_btn_vis then
		-- self.help_dec:SetValue(fb_scene_cfg.fb_desc)
		if not SettingData.Instance:HasEnterFb(scene_type, scene_id) then
			SettingData.Instance:SetFbEnterFlag(scene_type, true, scene_id)
			-- self:OnClicExplain()
		end
	end

	self:FlushGuildBossIcon()

	for k, v in pairs(self.monster_diff_time_list) do
		if v > 0 then
			self:SetMonsterCountDown(k)
		end
	end
	-- if Scene.Instance:GetSceneId() == 1120 then
	self.show_text:SetValue(self.is_show_skymoney_text)

	-- else
		-- self.show_text:SetValue(false)
	-- end
	self:PotionEffectState()
	if scene_type == SceneType.ExpFb and FuBenData.Instance:GetIsGetGuWu() and self.is_click then
		self.btn_guwu.animator:SetBool("IsShow", true)
	else
		self.btn_guwu.animator:SetBool("IsShow", false)
	end

	if scene_type == SceneType.CrossGuildBattle or scene_type == SceneType.XianYangCheng then
		self.btn_explain.transform.anchorMax = Vector2(1, 1)
		self.btn_explain.transform.anchorMin = Vector2(1, 1)
		self.btn_explain.transform.anchoredPosition3D = Vector3(-187, -74, 0)
		self.exit_fb_btn.transform.anchoredPosition3D = Vector3(-17, -74, 0)
		self.show_gongxian:SetValue(true)
	else
		self.btn_explain.transform.anchorMax = Vector2(1, 1)
		self.btn_explain.transform.anchorMin = Vector2(1, 1)
		self.btn_explain.transform.anchoredPosition3D = Vector3(-380, -7, 0)
		self.exit_fb_btn.transform.anchoredPosition3D = Vector3(-218, -7, 0)
		self.show_gongxian:SetValue(false)
	end
end

function FbIconView:ActivityCallBack()
	self:FlushGuildBossIcon()
end

function FbIconView:FlushGuildBossIcon()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.GuildStation then
		self.show_guild_boss:SetValue(true)
		local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BOSS)
		local boss_info = GuildData.Instance:GetBossInfo() or {}
		local boss_normal_call_count = boss_info.boss_normal_call_count or 0
		-- 如果今天还没有召唤过boss
		if is_open and boss_normal_call_count <= 0 then
			self.guild_boss_icon.animator:SetBool("Flash", true)
		else
			self.guild_boss_icon.animator:SetBool("Flash", false)
		end
	else
		self.show_guild_boss:SetValue(false)
	end
end

function FbIconView:DoActivityCountDown(activity_type, is_show_btn_time, leave_time)
	local info = ActivityData.Instance:GetActivityStatuByType(activity_type)
	if info then
		local end_time = info.next_time or 0
		local total_time = end_time - TimeCtrl.Instance:GetServerTime()
		self:SetCountDownByTotalTime(total_time, is_show_btn_time, leave_time)
	end
end

function FbIconView:SetCountDownByTotalTime(total_time, is_show_btn_time, leave_time)
	if self:IsLoaded() then
		if total_time <= 0 then
			self.exit_time_act:SetValue(false)
			self.show_btn_time:SetValue(false)
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
			return
		end
		self.exit_time_act:SetValue(leave_time == nil)

		if self.count_down == nil then
			local function diff_time_func(elapse_time, total_time2)
				if leave_time ~= nil then
					self.exit_time_act:SetValue(elapse_time >= total_time2 - leave_time)
					if is_show_btn_time then
						self.show_btn_time:SetValue(elapse_time < total_time2 - leave_time)
					end
				end

				if elapse_time >= total_time2 then
					local time = "00:00"
					if self.time_text ~= nil then
						self.time_text:SetValue(time)
					end
					
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
				if self.time_text ~= nil then
					self.time_text:SetValue(the_time_text)
				end
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

function FbIconView:SetMonsterInfo(monster_id, index)
	local index = index or 1
	if self:IsLoaded() then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[monster_id]
		if not monster_cfg then return end
		local bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
		self.monster_variable_list[index].monster_icon:SetAsset(bundle, asset)
	else
		self.monster_id = monster_id
	end
end

-- 设置 已刷新 文本 Active
function FbIconView:ShowMonsterHadFlush(enable, flush_text, index)
	local index = index or 1

	if self:IsLoaded() then
		-- 怪物刷新后文本的显示，默认显示“已刷新”
		local flush_text = flush_text or Language.Boss.HadFlush
		self.monster_variable_list[index].show_monster_had_flush:SetValue(enable)
		if enable then
			self.monster_variable_list[index].show_monster_icon:SetValue(true)
			self.monster_variable_list[index].had_flush_text:SetValue(flush_text)

			if self.montser_count_down_list[index] ~= nil then
				CountDown.Instance:RemoveCountDown(self.montser_count_down_list[index])
				self.montser_count_down_list[index] = nil
			end
		end
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
		self.monster_variable_list[index].show_monster_icon:SetValue(enable)
	end
end

function FbIconView:SetMonsterIconGray(enable, index)
	local index = index or 1
	if self:IsLoaded() then
		self.monster_variable_list[index].show_gray:SetValue(enable)
	end
end

function FbIconView:SetMonsterCountDown(index)
	local index = index or 1
	if not self.montser_count_down_list[index] and self.monster_diff_time_list[index] and tonumber(self.monster_diff_time_list[index]) > 0 then
		local diff_time = self.monster_diff_time_list[index]

		self.monster_variable_list[index].show_monster_icon:SetValue(true)

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
		temp_str = string.format(Language.ShengXiao.CurBossNum, info.now_boss_num)
	else
		temp_str = string.format(Language.ShengXiao.CurBoxNum, info.now_box_num)
	end
	self.condition_txt:SetValue(temp_str)
end

function FbIconView:CheckQuestionPrepare()
	local activity_prepare_time = HotStringChatData.Instance:GetActivityPrepareTime()
	if activity_prepare_time > 0 then
		self.show_question_text:SetValue(true)
		self:SetQuestionPrepareTime(activity_prepare_time)
	else
		self.show_question_text:SetValue(false)
	end
end

function FbIconView:RemoveQuestionCountDown()
	if self.question_count_down then
		CountDown.Instance:RemoveCountDown(self.question_count_down)
		self.question_count_down = nil
	end
end

function FbIconView:SetQuestionPrepareTime(total_time)
	if self.question_count_down == nil then
		local function diff_time_func(elapse_time, total_time2)
			if elapse_time >= total_time2 then
				local time = "00:00"
				self.question_prepare_time:SetValue(time)
				self:RemoveQuestionCountDown()
				self.show_question_text:SetValue(false)
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
			self.question_prepare_time:SetValue(the_time_text)
		end
		diff_time_func(0, total_time)
		self.question_count_down = CountDown.Instance:AddCountDown(
			total_time, 1, diff_time_func)
	end
end


function FbIconView:OnClickGuWu()
	self.is_click = false
	FuBenCtrl.Instance:OpenFbGuWu()
	self.btn_guwu.animator:SetBool("IsShow", false)	
end

-- 显示鼓舞按钮
function FbIconView:ShowGuWuBtn()
	local scene_type = Scene.Instance:GetSceneType()
	self.show_guwu:SetValue(scene_type == SceneType.ExpFb)
	if scene_type == SceneType.ExpFb and FuBenData.Instance:GetIsGetGuWu() and self.is_click then
		FuBenCtrl.Instance:OpenFbGuWu()
	end
end