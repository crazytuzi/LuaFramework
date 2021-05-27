
FubenData = FubenData or BaseClass()

FubenType = {
	Main = 1,
	PersonalBoss = 2,
	Material = 3,
	Guild = 4,
	Strength = 5,
	Tafang = 6,
	CallBoss = 7,
	Hhjd = 100,			-- 行会禁地1层
	Hhjd2 = 101,		-- 行会禁地2层
	SixWorld = 102,		-- 六界战场
	JIYanFuben = 103, 	--
	Babel = 105, 		--通天塔
	LianYuFuben = 106,  --炼狱副本
}	

FubenData.FubenCfg = {
	[FubenType.PersonalBoss] = GameFubenCfg.fubenList,
	-- [FubenType.Material] = FubenAwardCfg,
	[FubenType.Strength] = {challenge_fuben_cfg},
	[FubenType.Tafang] = {TafangFubenCfg},
	[FubenType.CallBoss] = {{fubenId = 30}},
	[FubenType.Hhjd] = {ZuDuiFuBenCfg[FubenType.Guild]},
	[FubenType.Hhjd2] = {GuildForbiddenAreaNpcCfg},
	[FubenType.JIYanFuben] =  {expFubenConfig},
}

FubenData.FB_GUIDE_SHOW_TYPE = {
	-- [FubenType.PersonalBoss] = {enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [FubenType.Material] = {enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [FubenType.Strength] = {enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [FubenType.Tafang] = {enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [FubenType.CallBoss] = {enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [FubenType.Hhjd] = {enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [FubenType.Hhjd2] = {enter = MainuiTask.SHOW_TYPE.RIGHT, out = MainuiTask.SHOW_TYPE.LEFT},
	-- [FubenType.SixWorld] = {enter = MainuiTask.SHOW_TYPE.LEFT, out = MainuiTask.SHOW_TYPE.LEFT},
}

-- 闯关结果
STRENFTH_FB_STATE = {
	DEATH_FAIL = 0,				-- 闯关失败(玩家死亡)
	OVERTIME_FAIL = 1,			-- 闯关失败(超时)
	ONE_SUCCESS = 2,			-- 闯关成功
	ALL_SUCCESS = 3,			-- 闯关成功(完成了所以关)
}

-- 行会禁地一层区域状态
HHJD_AREA_STATE = {
	WAIT = 0,			-- 等待区
	MONSTER1 = 1,		-- 第1个怪物区
	MONSTER2 = 2,		-- 第2个怪物区
	MONSTER3 = 3,		-- 第3个怪物区
	NEXT_SCENE = 4,		-- 下一层区
}

FubenData.BOSS_ENTER_TIMES = "boss_enter_times"
FubenData.JY_FUBEN_DATA = "jy_fuben_data"

function FubenData:__init()
	if FubenData.Instance then
		ErrorLog("[FubenData]:Attempt to create singleton twice!")
		return
	end
	FubenData.Instance = self

	self:InitFubenInfo()
	self.fuben_enter_info = {}
	self.fuben_other_info = {}

	self.hhjd_left_times = 0
	self.hhjd_is_finished = false

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetHhjdRemindIndex), RemindName.Hhjd)

	self.is_had_max_Level = 0  --已经挑战过的最高难度等级
    self.is_had_max_bo_num  = 0 -- 已经挑战过的最高难度等级的最高波数
    self.last_level = 0          --上次挑战的难度等级
    self.last_bo_num = 0         --上次挑战通过波数
    self.had_figth_num  = 0      --挑战次数
    self.cur_had_bo_num = 1      --当前波数
    self.remain_moster_num = 0   --当前剩余怪物
    self.remain_time = 0         -- 副本剩余时间
    self.is_saodang = 0 		--是不是扫荡
    self.buy_time = 0 			--经验副本购买次数

    self.skill_boss_num = 0 	--击杀怪物数量


    --炼狱副本
    self.enter_times = 0
    self.had_buy_num = 0
    self.had_bo_num = 0
    self.max_bo_num = 0
    self.cur_bo_num = 0
    self.remain_boss_num = 0
    self.remain_time_lianyu = 0

    self.skill_monster_num_lianyu = 0  --在炼狱中击杀怪物的数量
end

function FubenData:__delete()
	FubenData.Instance = nil

	if self.fuben_alert then
		self.fuben_alert:DeleteMe()
		self.fuben_alert = nil
	end 
end

function FubenData:InitFubenInfo()
	self.fuben_type = -1			-- 副本类型
	self.cur_monster_num = 0		-- 当前副本怪物数量
	-- self.total_monster_num = 0		-- 当前副本怪物总数量
	self.fuben_left_time = -1		-- 副本剩余时间
	self.fuben_set_time = 0			-- 副本剩余时间对比时间
	self.is_finish = false			-- 副本是否完成
	
	self.fuben_id = 0				-- 副本Id
	self.fuben_name = ""			-- 副本名字
	self.fuben_cfg = nil			-- 副本配置

	self.fuben_other_info = {}		-- 副本其它信息
end

function FubenData:GetFubenType()
	return self.fuben_type
end

function FubenData:IsInFuben()
	return self.fuben_type > 0
end

function FubenData:ResetFubenType()
	self.fuben_type = -1
end

--副本左边任务面板数据
function FubenData:GetTaskData()
	local fb_task_data = {}
	if self.fuben_type == FubenType.PersonalBoss then
		fb_task_data = self:GetPersonalTaskData()
	elseif self.fuben_type == FubenType.Material then
		fb_task_data = self:GetFubenTaskData()
	elseif self.fuben_type == FubenType.Tafang then
		fb_task_data = self:GetTaFangTaskData()
	elseif self.fuben_type == FubenType.Hhjd or self.fuben_type == FubenType.Hhjd2 then
		fb_task_data = self:GetHhjdTaskData()
	-- elseif self.fuben_type == FubenType.Strength then
	-- 	fb_task_data = self:GetStrengthTaskData()
	end

	if self:IsInFuben() then
		if fb_task_data == nil or next(fb_task_data) == nil then
			return {
				[OTHER_TASK_GUIDE.RIGHT] = {
					guide_name = MainuiTask.GUIDE_NAME.NUll,
					btn_path = "task_btn_fuben",
				}
			}
		end
	end
	
	for k, v in pairs(OTHER_TASK_GUIDE) do
		if nil == fb_task_data[v] then
			fb_task_data[v] = {}
		end
	end

	return fb_task_data
end

function FubenData:SetCallBossData(protocol)
	self.is_death = protocol.is_death or 0
	self.boss_id = protocol.boss_id or 0
	self.boss_time = protocol.time or 0
	self.fuben_set_time = TimeCtrl.Instance:GetServerTime()
end

function FubenData:GetCallBossTaskData()
	local boss_name = BossData.Instance.GetMosterCfg(self.boss_id).name
	local reward_cfg = MainuiData.Instance:GetMonsterRewardCfg(self.boss_id)
	local award_list = BossData.Instance.GetMosterCfg(self.boss_id).drops
	local color = self.is_death == 1 and COLOR3B.GREEN or COLOR3B.WHITE
	local monster_num_str = string.format(Language.Fuben.LeftMonster, C3b2Str(color), self.is_death or 0, 1)
	local texts = {
		[1] = {line = 7, content = boss_name},
		[2] = {line = 6, content = monster_num_str},
		[3] = {line = 1, content = string.format(Language.Fuben.LeftTime, "ff2828"), timer = self.is_death == 0 and self:GetCallBossTime() or 30},
	}
	local items = {}
	for i = 1, #reward_cfg do
		items[i] = reward_cfg[i]
	end

	local btns = {
		["tips"] = {
			path = ResPath.GetCommon("part_100"),
			x = MainuiTask.Size.width - 30,
			y = (MainuiTask.Size.height - 60) - 30,
			event = function ()
				DescTip.Instance:SetContent(Language.Fuben.CallBossTips, Language.Fuben.CallBossTitle)
			end,
		},	
	}

	local opt_btns = {}
	opt_btns = {
		["out_fuben"] = {
			title = Language.Fuben.ExitFuben,
			event = function ()
				self.fuben_alert = self.fuben_alert or Alert.New()
				self.fuben_alert:SetLableString(self.is_death == 1 and Language.Fuben.ExitFubenBossAlert or Language.Fuben.ExitFubenAlert)
				self.fuben_alert:SetOkFunc(function()
					FubenCtrl.OutFubenReq(self:GetFubenId())
				end)
				self.fuben_alert:SetCancelString(Language.Common.Cancel)
				self.fuben_alert:SetOkString(self.is_death == 0 and Language.Common.Confirm or Language.Fuben.ButtonText)
				self.fuben_alert:SetShowCheckBox(false)
				self.fuben_alert:Open()
			end,
		},
	}
	return {
		[OTHER_TASK_GUIDE.RIGHT] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_PERSONAL_BOSS,
			btn_path = "task_btn_fuben",
			render = CallBossRender,
			render_data = {texts = texts, items = items, btns = btns},
		},
		[OTHER_TASK_GUIDE.BOTTOM] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_PERSONAL_BOSS,
			render_data = {btns = opt_btns, parent_panel = OTHER_TASK_GUIDE.RIGHT},
		},
	}
end

function FubenData:SetFubenMonsterNum(protocol)
	self.fuben_id = protocol.fuben_id
	self.cur_monster_num = protocol.cur_monster_num
	-- self.total_monster_num = protocol.total_monster_num
end

function FubenData:SetKillMonsterNum(num)
	self.fuben_other_info.kill_monster_num = num
end

function FubenData:SetFubenId(id)
	self.fuben_id = id
end

function FubenData:SetFubenInfo(protocol)
	-- self:InitFubenInfo()
	
	self.fuben_id = protocol.fuben_id
	self.fuben_name = protocol.fuben_name
	self.fuben_left_time = protocol.fuben_left_time
	self.fuben_set_time = TimeCtrl.Instance:GetServerTime()
	self.is_finish = false

	-- for k, v in pairs(protocol.fuben_info or {}) do
	-- 	self.fuben_other_info[k] = v 
	-- end
	self.fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	for k, v in pairs(FubenData.FubenCfg[self.fuben_type] or {}) do
		if v.fubenId == self.fuben_id then
			self.fuben_cfg = v
		end
	end

	if self.fuben_type == FubenType.Strength and (self:GetFubenLeftTime() > 0) then
		UiInstanceMgr.Instance:DelOneCountDownView("tafang_right_top")
		UiInstanceMgr.Instance:CreateOneCountdownView(
			"tafang_right_top",
			self:GetFubenLeftTime(),
			{x = HandleRenderUnit:GetWidth() - 100, y = HandleRenderUnit:GetHeight() - 130},
			{num_type = "fb_num_100_", folder_name = "scene"},
			nil,
			function (elapse_time, total_time)
				local num = total_time - math.floor(elapse_time)
				if num == 10 then
					UiInstanceMgr.Instance.coutdown_view_list["tafang_right_top"].num_t.num_type = "fb_num_101_"
				end
			end
		)
	end
end

function FubenData:GetFubenCfg()
	return self.fuben_cfg
end

function FubenData:GetFubenMonsterNum()
	return self.fuben_monster_num
end

-- 副本id
function FubenData:GetFubenId()
	return self.fuben_id
end

function FubenData:GetFubenLeftTime()
	return self.fuben_left_time - (TimeCtrl.Instance:GetServerTime() - self.fuben_set_time)
end

function FubenData:GetCallBossTime()
	return self.boss_time - (TimeCtrl.Instance:GetServerTime() - self.fuben_set_time)
end

function FubenData:SetFubenEnterInfo(list)
	self.fuben_enter_info = list
	self:DispatchEvent(FubenData.BOSS_ENTER_TIMES)
end

function FubenData:GetFubenEnterInfo()
	return self.fuben_enter_info
end

function FubenData:SetCumulativeExp(num, loss_exp)
	self.fuben_other_info.cumulative_exp = num
	self.fuben_other_info.loss_exp = loss_exp
end

-- 勇者闯关副本结果
function FubenData:SetStrengthFbResult(result, is_click_quit)
	self.fuben_other_info.add_level_num = self.fuben_other_info.add_level_num or 0
	self.fuben_other_info.result = result

	UiInstanceMgr.Instance:DelOneCountDownView("tafang_right_top")
	UiInstanceMgr.Instance:DelOneCountDownView("tafang_middle")
	if result == STRENFTH_FB_STATE.ONE_SUCCESS then
		self.fuben_other_info.add_level_num = self.fuben_other_info.add_level_num + 1
		FubenData.ShowStrengthFbCountdown("fb_success_word_5", 0, 0)
	elseif result == STRENFTH_FB_STATE.ALL_SUCCESS then
		self.fuben_other_info.add_level_num = self.fuben_other_info.add_level_num + 1
		FubenData.ShowStrengthFbCountdown("fb_success_word_4", 55, 0, true)
	else
		if not is_click_quit then
			FubenData.ShowStrengthFbCountdown("fb_fail_word_3", 55, 0, true)
		end
	end

	local view_data = {
		result = self.fuben_other_info.result, 				
		level_num = self.fuben_other_info.add_level_num, 		-- 累计关数
		award = self.fuben_other_info.total_award_data, 
		cur_level = self.fuben_other_info.Level 				-- 当前关卡	
	}
	FubenCtrl.Instance:SetStrengthViewData(view_data)
end

function FubenData.ShowStrengthFbCountdown(word_name, offset_x, offset_y, out_func)
	-- 背景
	local bg = XUI.CreateImageView(0, 0, ResPath.GetScene("fb_bg_101"), true)
	local bg_size = bg:getContentSize()
	bg:setPosition(bg_size.width * 0.5, bg_size.height * 0.5)

	-- 文字
	local word = XUI.CreateImageView(bg_size.width * 0.5, bg_size.height * 0.5, ResPath.GetScene(word_name), true)

	-- 图片数字节点
	local rich_num = CommonDataManager.CreateLabelAtlasImage(0)
	rich_num:setPosition(bg_size.width * 0.5 + offset_x, bg_size.height * 0.5 + offset_y)

	local layout_t = {x = HandleRenderUnit:GetWidth() * 0.5, y = HandleRenderUnit:GetHeight() * 0.5, anchor_point = cc.p(0.5, 0.5), content_size = bg_size}
	local num_t = {num_node = rich_num, num_type = "zdl_y_", folder_name = "scene"}
	local img_t = {bg, word}

	if out_func then
		local function out()
			StrenfthFbCtrl.SendBraveMakingBreakthroughReq(3)
		end
		GlobalTimerQuest:AddDelayTimer(out, 5)
		UiInstanceMgr.Instance:CreateOneCountdownView("tafang_middle", 5, layout_t, num_t, img_t)
		return
	end

	UiInstanceMgr.Instance:CreateOneCountdownView("tafang_middle", 5, layout_t, num_t, img_t)
end

-- 材料副本
function FubenData:GetFubenTaskData()
	local fuben_cfg = self:GetFubenCfg()
	if fuben_cfg == nil then
		return
	end

	local items = {}
	for i = 1, #fuben_cfg.award do
		items[i] = fuben_cfg.award[i]
	end

	local total_monster_num = fuben_cfg.Number
	local color = self.cur_monster_num >= total_monster_num and COLOR3B.GREEN or COLOR3B.WHITE
	local monster_num_str = string.format(Language.Fuben.LeftMonster, C3b2Str(color), self.cur_monster_num or 0, total_monster_num or 0)
	local texts = {
		[6] = {line = 6, content = monster_num_str},
	}

	local btns = {}

	local opt_btns = {}
	if self.is_finish == true then
		opt_btns = {
			["rec_normal"] = {
				title = Language.Fuben.RecNormal,
				event = function()
					if self.fuben_type == FubenType.PersonalBoss then
						FubenCtrl.RecFubenReward(1)
					elseif self.fuben_type == FubenType.Material then
						FubenCtrl.RecMaterialFubenReward(1)
					end
				end,
			},
			
		}

		-- 双倍或三倍领取
		if fuben_cfg.doubleConsume and fuben_cfg.doubleConsume.count then
			local str = ""
			local str_2 = ""
			if self.fuben_type == FubenType.PersonalBoss then
				str = Language.Fuben.RecDoubleAlert
				str_2 = Language.Fuben.RecDouble
			else
				str = Language.Fuben.RecTreblingAlert
				str_2 = Language.Fuben.RecTrebling
			end

			opt_btns["rec_normal"].x = 62
			opt_btns["rec_double"] = {
				x = MainuiTask.Size.width - 62,
				title = str_2,
				event = function ()
					self.fuben_alert = self.fuben_alert or Alert.New()
					self.fuben_alert:SetLableString(string.format(str, fuben_cfg.doubleConsume.count))
					self.fuben_alert:SetOkFunc(function()
						if self.fuben_type == FubenType.PersonalBoss then
							FubenCtrl.RecFubenReward(2)
						elseif self.fuben_type == FubenType.Material then
							FubenCtrl.RecMaterialFubenReward(2)
						end
					end)
					self.fuben_alert:SetCancelString(Language.Common.Cancel)
					self.fuben_alert:SetOkString(Language.Common.Confirm)
					self.fuben_alert:SetShowCheckBox(false)
					self.fuben_alert:Open()
				end,
				effect = {},
			}
		end
	else
		opt_btns = {
			["out_fuben"] = {
				title = Language.Fuben.ExitFuben,
				event = function ()
					self.fuben_alert = self.fuben_alert or Alert.New()
					self.fuben_alert:SetLableString(Language.Fuben.ExitFubenAlert)
					self.fuben_alert:SetOkFunc(function()
						FubenCtrl.OutFubenReq(self:GetFubenId())
					end)
					self.fuben_alert:SetCancelString(Language.Common.Cancel)
					self.fuben_alert:SetOkString(Language.Common.Confirm)
					self.fuben_alert:SetShowCheckBox(false)
					self.fuben_alert:Open()
				end,
			},
		}

		texts[1] = {line = 1, content = string.format(Language.Fuben.LeftTime, "ff2828"), timer = self:GetFubenLeftTime()}
	end

	return {
		[OTHER_TASK_GUIDE.RIGHT] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_PERSONAL_BOSS,
			btn_path = "task_btn_fuben",
			render_data = {texts = texts, btns = btns, items = items},
		},
		[OTHER_TASK_GUIDE.BOTTOM] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_PERSONAL_BOSS,
			render_data = {btns = opt_btns, parent_panel = OTHER_TASK_GUIDE.RIGHT},
		},
	}
end

function FubenData:GetPersonalTaskData()
	opt_btns = {
		["out_fuben"] = {
			title = Language.Fuben.ExitFuben,
			event = function ()
				self.fuben_alert = self.fuben_alert or Alert.New()
				self.fuben_alert:SetLableString(Language.Fuben.ExitPerFubenAlert)
				self.fuben_alert:SetOkFunc(function()
					FubenCtrl.OutFubenReq(self:GetFubenId())
				end)
				self.fuben_alert:SetCancelString(Language.Common.Cancel)
				self.fuben_alert:SetOkString(Language.Common.Confirm)
				self.fuben_alert:SetShowCheckBox(false)
				self.fuben_alert:Open()
			end,
		},
	}
	return {
		[OTHER_TASK_GUIDE.RIGHT] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_PERSONAL_BOSS,
			btn_path = "task_btn_fuben",
			render_data = {texts = texts, btns = btns, items = items},
		},
		[OTHER_TASK_GUIDE.BOTTOM] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_PERSONAL_BOSS,
			render_data = {btns = opt_btns, parent_panel = OTHER_TASK_GUIDE.RIGHT},
		},
	}
end

-- 魔界秘境
function FubenData:GetFamTaskData()
	local fuben_cfg = DevildomDrogsCfg
	if fuben_cfg == nil then
		return
	end
	local items = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local lh_grade = LunHuiData.Instance:GetLunGrade() + 1
	local index = 1
	for i = 1, #fuben_cfg[lh_grade] do
		if (fuben_cfg[lh_grade][i].job == 0 and fuben_cfg[lh_grade][i].sex == 0) or 
		fuben_cfg[lh_grade][i].job == prof then 
			items[index] = fuben_cfg[lh_grade][i]
			index = index + 1
		end
	end

	local texts = {
		[1] = {line = 7, content = Language.Boss.TabGrop[7]},
		[2] = {line = 6, content = Language.Boss.FamDropsDes},
		[3] = {line = 1, content = string.format(Language.Boss.SurplusFamIntegral, BossData.Instance:GetDevildomFamIntegral())},
	}

	local btns = {
		["tips"] = {
			path = ResPath.GetCommon("part_100"),
			x = MainuiTask.Size.width - 30,
			y = (MainuiTask.Size.height - 60) - 30,
			event = function ()
				DescTip.Instance:SetContent(Language.Fuben.DevildomFamTips, Language.Fuben.CallBossTitle)
			end,
		},	
	}

	local opt_btns = {}
	opt_btns = {
		["out_fuben"] = {
			title = Language.Fuben.ExitFuben,
			x = 62,
			event = function ()
				self.fuben_alert = self.fuben_alert or Alert.New()
				self.fuben_alert:SetLableString(Language.Boss.ExitDevildomFamAlert)
				self.fuben_alert:SetOkFunc(function()
					BossCtrl.GoBackTownReq()
				end)
				self.fuben_alert:SetCancelString(Language.Common.Cancel)
				self.fuben_alert:SetOkString(Language.Common.Confirm)
				self.fuben_alert:SetShowCheckBox(false)
				self.fuben_alert:Open()
			end,
		},
		["buy_integral"] = {
			title = Language.Boss.BuyFamIntegral,
			x = MainuiTask.Size.width - 62,
			event = function ()
				self.fuben_alert = self.fuben_alert or Alert.New()
				local des = string.format(Language.Boss.BuyFamIntegralAlert, BossData.Instance:GetBuyFamIntegralCost(), BossData.Instance:GetBuyFamIntegral())
				self.fuben_alert:SetLableString(des)
				self.fuben_alert:SetOkFunc(function ()
					BossCtrl.BuyDevildomFamIntegralReq()
			  	end)
			  	self.fuben_alert:SetCancelString(Language.Common.Cancel)
				self.fuben_alert:SetOkString(Language.Common.Confirm)
				self.fuben_alert:SetShowCheckBox(false)
				self.fuben_alert:Open()
			end,
		}
	}

	return {
		[OTHER_TASK_GUIDE.RIGHT] = {
			guide_name = MainuiTask.GUIDE_NAME.Fam,
			btn_path = "task_btn_fuben",
			render = FeixuBossRender,
			render_data = {texts = texts, btns = btns, items = items},
		},
		[OTHER_TASK_GUIDE.BOTTOM] = {
			guide_name = MainuiTask.GUIDE_NAME.Fam,
			render = MJMJGuideBottomRender,
			render_data = {btns = opt_btns, parent_panel = OTHER_TASK_GUIDE.RIGHT},
		},
	}
end

-- 封魔塔防已任务完成，所有怪物已刷完
function FubenData:TaFangTaskIsFinish()
	if Scene.Instance:GetSceneLogic():GetFubenType() == FubenType.Tafang then
		local fuben_cfg = FubenData.Instance:GetFubenCfg()
		if fuben_cfg.totalExp then
			-- 获得经验和损失经验和等于副本总经验时任务完成
			if fuben_cfg.totalExp <= ((self.fuben_other_info.cumulative_exp or 0) + (self.fuben_other_info.loss_exp or 0)) then
				return true
			end
		end
	end
	return false
end

-- 封魔塔防
function FubenData:GetTaFangTaskData()
	local fuben_cfg = self:GetFubenCfg()
	if fuben_cfg == nil then
		return 
	end

	self.fuben_other_info.cumulative_exp = self.fuben_other_info.cumulative_exp or 0
	self.fuben_other_info.loss_exp = self.fuben_other_info.loss_exp or 0
	local texts = {
		[3] = {line = 3, content = string.format(Language.Fuben.LostExp, self.fuben_other_info.loss_exp)},
		[4] = {line = 4, content = string.format(Language.Fuben.GetExp, self.fuben_other_info.cumulative_exp)},
		[5] = {line = 5, content = string.format(Language.Fuben.FinishExp, fuben_cfg.totalExp)},
		-- [5] = {line = 5, content = string.format(Language.Fuben.MonsterNum, "ffc800", self.total_monster_num or 0, fuben_cfg.totalMonsterNum)},
		-- [5] = {line = 5, content = string.format(Language.Fuben.MonsterNum, "ffc800", self.fuben_other_info.kill_monster_num or 0, fuben_cfg.totalMonsterNum)},
	}

	if self:GetFubenLeftTime() == 0 then
		-- 未开启
		texts[6] = {line = 6, content = string.format(Language.Fuben.FbStateStr, "1eff00", Language.Fuben.NotOpen)}
	else
		-- 已开启
		texts[2] = {line = 2, content = string.format(Language.Fuben.LeftTime, "ff2828"), timer = self:GetFubenLeftTime()}
		texts[6] = {line = 6, content = string.format(Language.Fuben.FbStateStr, "ff2828", Language.Fuben.IsOpen)}
	end

	local opt_btns = {
		["out_fuben"] = {
			title = Language.Fuben.ExitFuben,
			event = function ()
				if TafangFubenCfg.totalMonsterNum > self.cur_monster_num then
					self.fuben_alert = self.fuben_alert or Alert.New()
					self.fuben_alert:SetLableString(Language.Fuben.ExitFubenAlert)
					self.fuben_alert:SetOkFunc(function()
						FubenCtrl.OutFubenReq(self:GetFubenId())
					end)
					self.fuben_alert:SetCancelString(Language.Common.Cancel)
					self.fuben_alert:SetOkString(Language.Common.Confirm)
					self.fuben_alert:SetShowCheckBox(false)
					self.fuben_alert:Open()
				else
					FubenCtrl.OutFubenReq(self:GetFubenId())
				end
			end,
		},
	}

	return {
		[OTHER_TASK_GUIDE.RIGHT] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_TAFANG,
			btn_path = "task_btn_fuben",
			render_data = {texts = texts, btns = btns},
		},
		[OTHER_TASK_GUIDE.BOTTOM] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_TAFANG,
			render_data = {btns = opt_btns, parent_panel = OTHER_TASK_GUIDE.RIGHT},
		},
	}
end

-- 勇者闯关
-- function FubenData:GetStrengthTaskData()
-- 	local fuben_cfg = self:GetFubenCfg()
-- 	local fuben_level = self.fuben_other_info.Level or 1
-- 	local i1 = math.ceil(fuben_level / 10 )
-- 	local i2 = fuben_level - (i1 - 1) * 10
-- 	local cur_level_cfg = fuben_cfg.RoundList[i1] and fuben_cfg.RoundList[i1].gateList[i2]
-- 	local first_pass_award = nil
-- 	if fuben_level % 10 == 0 then
-- 		first_pass_award = fuben_cfg.RoundList[i1].firstPassAward
-- 	end
-- 	if fuben_cfg == nil or cur_level_cfg == nil then
-- 		return
-- 	end

-- 	local is_finish = self.cur_monster_num >= cur_level_cfg.monsterCount
-- 	local color = is_finish and COLOR3B.GREEN or COLOR3B.WHITE
-- 	local monster_num_str = string.format(Language.Fuben.KillBossNum, C3b2Str(color), self.cur_monster_num, cur_level_cfg.monsterCount)
	
-- 	local texts = {
-- 		[1] = {line = 1, content = string.format(Language.Fuben.LeftTime, "ff2828"), timer = self:GetFubenLeftTime()},
-- 		[6] = {line = 6, content = monster_num_str},
-- 		[7] = {line = 7, content = string.format(Language.Fuben.LevelNumber, fuben_level)},
-- 	}

-- 	local items = {}
-- 	local total_award_count = (self.fuben_other_info.left_award_num or 0) + (is_finish and cur_level_cfg.awardItemCount or 0)
-- 	local item_desc_format_1 = "{wordcolor;ffff00;" .. Language.Fuben.CurLevel .. "}{wordcolor;00ff00;x " .. cur_level_cfg.awardItemCount .. "}"
-- 	local item_desc_format_2 = "{wordcolor;ffff00;" .. Language.Fuben.Accumulative .. "}{wordcolor;00ff00;x " .. total_award_count .. "}"
-- 	items = {
-- 		[1] = {type = 0, id = fuben_cfg.awardItemId, count = cur_level_cfg.awardItemCount, bind = 1, item_desc_format = item_desc_format_1},
-- 		[2] = {type = 0, id = fuben_cfg.awardItemId, count = total_award_count, bind = 1, item_desc_format = item_desc_format_2},
-- 	}

-- 	self.fuben_other_info.total_award_data = {}
-- 	table.insert(self.fuben_other_info.total_award_data, {item_id = fuben_cfg.awardItemId, num = total_award_count, is_bind = 1})
-- 	if first_pass_award then
-- 		for k, v in pairs(first_pass_award) do
-- 			table.insert(self.fuben_other_info.total_award_data, {item_id = v.id, num = v.count, is_bind = v.bind})
-- 		end
-- 	end
-- 	-- self.fuben_other_info.total_award_data = {item_id = fuben_cfg.awardItemId, num = total_award_count, is_bind = 1}

-- 	-- local result = STRENFTH_FB_STATE.OVERTIME_FAIL
-- 	-- if fuben_level >= #fuben_cfg.RoundList and is_finish then
-- 	-- 	result = STRENFTH_FB_STATE.ALL_SUCCESS
-- 	-- end
-- 	-- local view_data = {result = result, level_num = is_finish and fuben_level or (fuben_level - 1), award = self.fuben_other_info.total_award_data}
-- 	-- FubenCtrl.Instance:SetStrengthViewData(view_data)

-- 	local btns = {
-- 		["tips"] = {
-- 			path = ResPath.GetCommon("part_100"),
-- 			x = MainuiTask.Size.width - 30,
-- 			y = (MainuiTask.Size.height - 60) - 30,
-- 			event = function ()
-- 				DescTip.Instance:SetContent(Language.Fuben.StrengthTipsContent, Language.Fuben.StrengthTipsTitle)
-- 			end,
-- 		},	
-- 	}

-- 	local opt_btns = {
-- 		["out_fuben"] = {
-- 			title = Language.Fuben.ExitFuben,
-- 			event = function ()
-- 				self.fuben_alert = self.fuben_alert or Alert.New()
-- 				local zorder = self.fuben_alert.zorder
-- 				self.fuben_alert.zorder = COMMON_CONSTS.ZORDER_FB_PANEL + 1
-- 				self.fuben_alert:SetLableString(Language.Fuben.ExitFubenAlert)
-- 				self.fuben_alert:SetOkFunc(function()
-- 					self:SetStrengthFbResult(STRENFTH_FB_STATE.OVERTIME_FAIL, true)
-- 					StrenfthFbCtrl.SendBraveMakingBreakthroughReq(3)
-- 				end)
-- 				self.fuben_alert:SetCancelString(Language.Common.Cancel)
-- 				self.fuben_alert:SetOkString(Language.Common.Confirm)
-- 				self.fuben_alert:SetShowCheckBox(false)
-- 				self.fuben_alert:Open()
-- 				self.fuben_alert.zorder = zorder
-- 			end,
-- 		},
-- 	}

-- 	return {
-- 		[OTHER_TASK_GUIDE.RIGHT] = {
-- 			guide_name = MainuiTask.GUIDE_NAME.FB_STRENGTH,
-- 			btn_path = "task_btn_fuben",
-- 			render_data = {texts = texts, btns = btns, items = items},
-- 		},
-- 		[OTHER_TASK_GUIDE.BOTTOM] = {
-- 			guide_name = MainuiTask.GUIDE_NAME.FB_STRENGTH,
-- 			render_data = {btns = opt_btns, parent_panel = OTHER_TASK_GUIDE.RIGHT},
-- 		},
-- 	}
-- end

------------------------------------------------------
-- 行会禁地 begin
------------------------------------------------------
FubenData.HhjdFinishedEvent = "hhjd_finished_event"
function FubenData:GetHhjdFbTeamListData()
	return FubenTeamData.Instance:GetTeamInfoList(FubenMutilType.Hhjd, FubenMutilLayer.Hhjd1)
end

function FubenData:SetHhjd2FbInfo()
	self.fuben_type = FubenType.Hhjd2
	self.fuben_left_time = FubenData.FubenCfg[FubenType.Hhjd2][1].fuben_time
	self.fuben_set_time = TimeCtrl.Instance:GetServerTime()
end

function FubenData:SetHhjdFbInfo(area_state)
	self.fuben_other_info.area_state = area_state
	self.fuben_type = FubenType.Hhjd
	if self.fuben_other_info.area_state == HHJD_AREA_STATE.WAIT then
		self.hhjd_is_finished = false
	elseif self.fuben_other_info.area_state == HHJD_AREA_STATE.MONSTER1 then
		FubenMutilCtrl.SendGetFubenEnterTimes(FubenMutilType.Hhjd)
		self.fuben_left_time = FubenData.FubenCfg[FubenType.Hhjd][1].fuben_time
		self.fuben_set_time = TimeCtrl.Instance:GetServerTime()
	end
end

function FubenData:GetHhjdFbAreaState()
	return self.fuben_other_info.area_state or HHJD_AREA_STATE.WAIT
end

-- 获取行会禁地当前要击杀的怪物信息
function FubenData:GetHhjdCurMonsterInfo()
	if self:HhjdIsSecond() then
		return FubenData.FubenCfg[FubenType.Hhjd2][1].BossInfo
	else
		local area_state = self:GetHhjdFbAreaState()
		for k, v in pairs(FubenData.FubenCfg[FubenType.Hhjd][1].MonsterId) do
			if k == area_state then
				return v
			end
		end
	end
end

-- 行会禁地每天最大进入次数
function FubenData:GetEnterHhjdMaxTimes()
	return FubenData.FubenCfg[FubenType.Hhjd][1].EveryDayJoin
end

function FubenData:GetLeftHhjdTimes()
	-- return self:GetEnterHhjdMaxTimes() - FubenMutilData.Instance:GetFubenUsedTimes(FubenMutilType.Hhjd)
	return self:GetEnterHhjdMaxTimes() - self.hhjd_left_times
end

function FubenData:SetLeftHhjdTimes(times)
	self.hhjd_left_times = times
	RemindManager.Instance:DoRemindDelayTime(RemindName.Hhjd)
end

function FubenData:FinishHhjd()
	self.hhjd_is_finished = true
	self:DispatchEvent(FubenData.HhjdFinishedEvent)
end

-- 行会禁地是否完成
function FubenData:HhjdIsFinished()
	return self.hhjd_is_finished
end

-- 行会禁地组队最大成员数量
function FubenData:GetHhjdFbMaxNumber()
	return FubenData.FubenCfg[FubenType.Hhjd][1].MaxPlayer
end

-- 行会禁地当前组队成员数量
function FubenData:GetHhjdTeamMemberCount()
	-- local self_team_info = FubenTeamData.Instance:GetMyTeamInfo(FubenMutilType.Hhjd, FubenMutilLayer.Hhjd1)
	-- return self_team_info and self_team_info.menber_count or 0
	local team_info = TeamData.Instance:GetTeamInfo()
	return team_info and team_info.member_list and #team_info.member_list or 0
end

-- 行会禁地是否是第二层
function FubenData:HhjdIsSecond()
	return Scene.Instance:GetSceneLogic():GetFubenType() == FubenType.Hhjd2
end

function FubenData:GetHhjdShowAwards()
	local items = {}
	local order = 1
	local is_open = is_second_scene and true or (self:GetHhjdFbAreaState() ~= HHJD_AREA_STATE.WAIT)
	local fuben_cfg = is_second_scene and FubenData.FubenCfg[FubenType.Hhjd2][1] or FubenData.FubenCfg[FubenType.Hhjd][1]
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local member_count = self:GetHhjdTeamMemberCount()
	for k, v in pairs(fuben_cfg.preview_rewards or {}) do
		if v.sex == sex and v.prof == prof and v.member_count == member_count then
			local item = DeepCopy(v)
			item.no_text = true
			items[order] = item
			order = order + 1
		end
	end
	return items
end

function FubenData:GetHhjdTaskData()
	-- 是否是第二层
	local is_second_scene = self:HhjdIsSecond()
	-- 是否是已开启（二层一定是开启）
	local is_open = is_second_scene and true or (self:GetHhjdFbAreaState() ~= HHJD_AREA_STATE.WAIT)
	local fuben_cfg = is_second_scene and FubenData.FubenCfg[FubenType.Hhjd2][1] or FubenData.FubenCfg[FubenType.Hhjd][1]

	local items = {}
	local order = 1
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local member_count = self:GetHhjdTeamMemberCount()
	for k, v in pairs(fuben_cfg.preview_rewards or {}) do
		if v.sex == sex and v.prof == prof and v.member_count == member_count then
			local item = DeepCopy(v)
			item.x = 31 + (62) * (order - 1)
			item.y = 74
			item.no_text = true
			items["hhjd_item_" .. order] = item
			order = order + 1
		end
	end

	local texts = {
		{line = 4, content = is_second_scene and Language.Activity.MonsterDrops or Language.Fuben.RewadDisplay},
		{line = 6, content = string.format(Language.Fuben.OnlineTeam, self:GetHhjdTeamMemberCount(), self:GetHhjdFbMaxNumber())},
		{line = 7, content = Scene.Instance:GetSceneName()},
	}

	if is_open then
		local monster_info = self:GetHhjdCurMonsterInfo()
		local monster_cfg = BossData.GetMosterCfg(monster_info and monster_info[1] or 0)
		local name = monster_cfg and monster_cfg.name
		if name and not is_second_scene then
			table.insert(texts, {line = 5, content = string.format(Language.Fuben.KillGuard, "ff2828", name, 0, 1)})
		end
		table.insert(texts, {line = 1, content = string.format(Language.Fuben.LeftTime, "ff2828"), timer = self:GetFubenLeftTime(),
			complete_func = function() FubenCtrl.OutFubenReq(self:GetFubenId()) end})
	end

	local btns = {
		["tips"] = {
			path = ResPath.GetCommon("part_100"),
			x = MainuiTask.Size.width - 30,
			y = (MainuiTask.Size.height - 60) - 30,
			event = function ()
				DescTip.Instance:SetContent(fuben_cfg.TipContent or "", Language.Fuben.CallBossTitle)
			end,
		},	
	}

	local opt_btns = {
		["out_fuben"] = {
			x = 62,
			title = Language.Fuben.ExitFuben,
			event = function ()
				self.fuben_alert = self.fuben_alert or Alert.New()
				self.fuben_alert:SetLableString(Language.Fuben.ExitFubenAlert)
				self.fuben_alert:SetOkFunc(function()
					FubenCtrl.OutFubenReq(self:GetFubenId())
				end)
				self.fuben_alert:SetCancelString(Language.Common.Cancel)
				self.fuben_alert:SetOkString(Language.Common.Confirm)
				self.fuben_alert:SetShowCheckBox(false)
				self.fuben_alert:Open()
			end,
		},
	}

	if not is_open then
		opt_btns["open"] = {
			x = MainuiTask.Size.width - 62,
			title = Language.Fuben.Open,
			event = function (btn)
				UiInstanceMgr.DelRectEffect(btn)
				if self:GetHhjdTeamMemberCount() <= 1 then
					self.fuben_alert = self.fuben_alert or Alert.New()
					self.fuben_alert:SetLableString(Language.Fuben.HhjdMemberTip)
					self.fuben_alert:SetOkFunc(function()
						FubenCtrl.StartHhjdReq()
					end)
					self.fuben_alert:SetShowCheckBox(false)
					self.fuben_alert:SetOkString(Language.Fuben.OnePeopleChallenge)
					self.fuben_alert:SetCancelString(Language.Fuben.ContinueWait)
					self.fuben_alert:Open()
				else
					FubenCtrl.StartHhjdReq()
				end
			end,
			effect = {},
		}
	else
		opt_btns["goto"] = {
			x = MainuiTask.Size.width - 62,
			title = Language.Fuben.GoTo,
			event = function (btn)
				local scene_logic = Scene.Instance:GetSceneLogic()
				if scene_logic.AutoMoveFight then scene_logic:AutoMoveFight() end
			end,
		}
		-- 自动寻路打怪
		GlobalTimerQuest:AddDelayTimer(function()
			if Scene.Instance:GetMainRole():IsMove() then
				return
			end
			local scene_logic = Scene.Instance:GetSceneLogic()
			if scene_logic.AutoMoveFight then scene_logic:AutoMoveFight() end
		end, 1)
	end

	if self.hhjd_is_finished then
		opt_btns = {
			["finish_hhjd"] = {
				title = Language.Fuben.FinishFuben,
				event = function ()
					FubenCtrl.OutFubenReq(self:GetFubenId())
				end,
			},
		}
	end

	return {
		[OTHER_TASK_GUIDE.RIGHT] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_HHJD,
			btn_path = "task_btn_fuben",
			render_data = {texts = texts, btns = btns, items = items},
		},
		[OTHER_TASK_GUIDE.BOTTOM] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_HHJD,
			render_data = {btns = opt_btns, parent_panel = OTHER_TASK_GUIDE.RIGHT},
		},
	}
end

----------红点提示----------

-- 获取提醒显示索引 0不显示红点, 1显示红点
function FubenData.GetHhjdRemindIndex()
	local times = FubenData.Instance:GetLeftHhjdTimes()
	local index = times > 0 and 1 or 0
	return index
end

----------end----------

------------------------------------------------------
-- 行会禁地 end
------------------------------------------------------


--===--经验副本-========
function FubenData:SetJiYanFuBenInfo(protocol)
	self.is_had_max_Level = protocol.is_had_max_Level  --已经挑战过的最高难度等级
    self.is_had_max_bo_num  =  protocol.is_had_max_bo_num -- 已经挑战过的最高难度等级的最高波数
    self.last_level =  protocol.last_level          --上次挑战的难度等级
    self.last_bo_num =  protocol.last_bo_num         --上次挑战通过波数
    self.had_figth_num  =  protocol.had_figth_num      --挑战次数
  	self.is_saodang = protocol.is_saodang 			--是不是扫荡
  	self.buy_time = protocol.buy_time 				--购买次数
  	GlobalEventSystem:Fire(JI_YAN_FUBEN_EVENT.DATA_CHANGE)
  	self:DispatchEvent(FubenData.JY_FUBEN_DATA)
end

function FubenData:SendGetJinYanFubenONFuben(protocol)
	self.is_had_max_Level = protocol.is_had_max_Level  --已经挑战过的最高难度等级
    self.is_had_max_bo_num  =  protocol.is_had_max_bo_num -- 已经挑战过的最高难度等级的最高波数
    self.last_level =  protocol.last_level          --上次挑战的难度等级
    self.last_bo_num =  protocol.last_bo_num         --上次挑战通过波数
    self.had_figth_num  =  protocol.had_figth_num      --挑战次数
    self.cur_had_bo_num =  protocol.cur_had_bo_num      --当前波数
    self.remain_moster_num =  protocol.remain_moster_num   --当前剩余怪物
    self.remain_time =  protocol.remain_time  + TimeCtrl.Instance:GetServerTime()        -- 副本剩余时间
    GlobalEventSystem:Fire(JI_YAN_FUBEN_EVENT.SKILL_BO_CHANGE)
end

--得到已通关的最大等级
function FubenData:GetCurMaxLevel()
	return self.is_had_max_Level
end

-- 经验副本购买次数
function FubenData:JyFubenBuyTime()
	return self.buy_time
end

--得到已通关的最大波数
function FubenData:GetHadMaxBo()
	return self.is_had_max_bo_num
end

function FubenData:GetHadFightingNum()
	return self.had_figth_num
end

--当前波数
function FubenData:GetCurBoNum()
	return self.cur_had_bo_num
end

--当前挑战等级
function FubenData:GetCurFightLevel()
	return self.last_level
end

--当前剩余怪物数量
function FubenData:GetCurMonsterNum()
	return self.remain_moster_num
end

--挑战通关波数
function FubenData:GetHadTongGuangBo()
	return self.last_bo_num
end

--剩余时间
function FubenData:GetRemainTime()
	return self.remain_time
end

function FubenData:SetSkillNUM(skill_boss_num)
	self.skill_boss_num = skill_boss_num
	GlobalEventSystem:Fire(JI_YAN_FUBEN_EVENT.SKILL_NUM_CHANGE)
end

function FubenData:GetHadSkillNum( )
	return self.skill_boss_num
end



---====炼狱副本
function FubenData:SetOnLianyuFuBenData(protocol)
	self.enter_times = protocol.enter_times
    self.had_buy_num = protocol.had_buy_num
    self.had_bo_num = protocol.had_bo_num
    self.max_bo_num = protocol.max_bo_num
    GlobalEventSystem:Fire(LIAN_FUBEN_EVENT.DATA_CHANGE)

end

function FubenData:SetOnLianyuFuBenInFuBenData(protocol)
	self.enter_times = protocol.enter_times
    self.had_buy_num = protocol.had_buy_num
    self.had_bo_num = protocol.had_bo_num
    self.max_bo_num = protocol.max_bo_num
    self.cur_bo_num = protocol.cur_bo_num
    self.remain_boss_num = protocol.remain_boss_num
    self.remain_time_lianyu = protocol.remain_num  + TimeCtrl.Instance:GetServerTime()
    GlobalEventSystem:Fire(LIAN_FUBEN_EVENT.SKILL_BO_CHANGE)
end


function FubenData:SetSkillNumLianyu(num)
	self.skill_monster_num_lianyu = num
	GlobalEventSystem:Fire(LIAN_FUBEN_EVENT.SKILL_NUM_CHANGE)
end


function FubenData:GetEnterTimes()
	return self.enter_times
end

function FubenData:GetRemainTimeLianYu()
	return self.remain_time_lianyu
end

function FubenData:GetLianyuCurBoNum()
	return self.had_bo_num
end

function FubenData:GetHadBuyNum()
	return self.had_buy_num
end

function FubenData:GetHadBossNumLianyu()
	return self.remain_boss_num
end

function FubenData:GetLianYuNum()
	return self.skill_monster_num_lianyu
end

function FubenData:GetLiyuMaxBo()
	return self.max_bo_num
end

--得到奖励是否领取
function FubenData:GetRewardCanGet()
	return self.had_bo_num
end