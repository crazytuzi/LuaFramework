CrossBattleFbLogic = CrossBattleFbLogic or BaseClass(BaseFbLogic)

function CrossBattleFbLogic:__init()
	self.sec_60_left_time_timer = nil
end

function CrossBattleFbLogic:__delete()
	if self.exit_alert then
		self.exit_alert:DeleteMe()
		self.exit_alert = nil
	end

	GlobalTimerQuest:CancelQuest(self.sec_60_left_time_timer)
end

function CrossBattleFbLogic:Enter(old_scene_type, new_scene_type)	
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.LEFT)
	self:UpdateTaskGuideData()

	-- GlobalTimerQuest:AddDelayTimer(function()
	-- 	self:AddLeftTimeTimer()
	-- end, 2)
end

function CrossBattleFbLogic:Out()
	BaseFbLogic.Out(self)

	GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE)
	GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.LEFT)
end

function CrossBattleFbLogic:ShowTimeOutText()
	UiInstanceMgr.Instance:DelOneCountDownView("cross_battle_60_sec_left_time")
	local left_time = self:GetLeftTime()
	if left_time <= 0 then
		return
	end

	-- 背景
	local bg = XUI.CreateImageView(0, 0, ResPath.GetScene("fb_bg_101"), true)
	local bg_size = bg:getContentSize()
	bg:setPosition(bg_size.width * 0.5, bg_size.height * 0.5)

	-- 文字
	local word = XUI.CreateImageView(bg_size.width * 0.5 + 50, bg_size.height * 0.5, ResPath.GetScene("word_cross_battle_time_out"), true)

	-- 图片数字节点
	local offset_x, offset_y = 100, 0
	local rich_num = CommonDataManager.CreateLabelAtlasImage(0)
	rich_num:setPosition(offset_x, bg_size.height * 0.5 + offset_y)

	local layout_t = {x = HandleRenderUnit:GetWidth() * 0.5, y = HandleRenderUnit:GetHeight() - 200, anchor_point = cc.p(0.5, 0.5), content_size = bg_size}
	local num_t = {num_node = rich_num, num_type = "zdl_y_", folder_name = "scene"}
	local img_t = {bg, word}

	UiInstanceMgr.Instance:CreateOneCountdownView("cross_battle_60_sec_left_time", left_time, layout_t, num_t, img_t)
end

function CrossBattleFbLogic:GetLeftTime()
	local time_info = CrossServerData.Instance:BattleEntranceOpenInfo()
	local left_time = 0
	for k, v in pairs(time_info.times) do
		if v.left_time > 0 then
			left_time = v.left_time
			break
		end
	end
	return left_time
end

function CrossBattleFbLogic:AddLeftTimeTimer()
	local left_time = self:GetLeftTime()
	local timer_left_time = left_time - 60 > 0 and left_time - 60 or 0
	GlobalTimerQuest:CancelQuest(self.sec_60_left_time_timer)
	self.sec_60_left_time_timer = GlobalTimerQuest:AddDelayTimer(function()
		self.sec_60_left_time_timer = nil
		self:ShowTimeOutText()
		self:UpdateTaskGuideData()
	end, timer_left_time)

	self:UpdateTaskGuideData()
end

function CrossBattleFbLogic:UpdateTaskGuideData()
	self.entrance_index = 1
	for k, v in pairs(FubenData.FubenCfg[FubenType.SixWorld]) do
		if v.fubenId == self.fuben_id then
			self.entrance_index = k
			break
		end
	end

	local fuben_cfg = CrossServerData.Instance:GetEntrancesCfg(self.entrance_index)
	if fuben_cfg == nil then
		return 
	end

	-- local left_time = self:GetLeftTime()

	local texts = {
		{line = 7, content = fuben_cfg.fubenName},
		{line = 6, content = Language.Activity.MonsterDrops},
		-- {line = 6, content = string.format(Language.Fuben.LeftTime, "ff2828"), timer = left_time}, -- 倒计时
		{line = 1, content = string.format(Language.CrossServer.LeftFubenValue, CrossServerData.Instance:TumoVal())},
	}

	local drops = CrossServerData.Instance:GetEntrancesDrops(self.entrance_index)
	local items = {}
	for k, v in pairs(drops) do
		table.insert(items, {type = 0, id = v.item_id, count = v.num, is_bind = v.bind})
	end

	local btns = {
		["tips"] = {
			path = ResPath.GetCommon("part_100"),
			x = MainuiTask.Size.width - 30,
			y = (MainuiTask.Size.height - 60) - 30,
			event = function ()
				DescTip.Instance:SetContent(CrossServerData.Instance:CrossBattleRule(), Language.CrossServer.FubenTipTitle)
			end,
		},	
	}

	local opt_btns = {
		["out_fuben"] = {
			title = Language.Fuben.ExitFuben,
			x = 62,
			event = function ()
				self.fuben_alert = self.fuben_alert or Alert.New()
				self.fuben_alert:SetLableString(Language.Fuben.QuitSixWorld)
				self.fuben_alert:SetOkFunc(function()
					CrossServerCtrl.SentQuitCrossServerReq(CROSS_SERVER_TYPE.FUBEN, self.entrance_index)
				end)
				self.fuben_alert:SetCancelString(Language.Common.Cancel)
				self.fuben_alert:SetOkString(Language.Common.Confirm)
				self.fuben_alert:SetShowCheckBox(false)
				self.fuben_alert:Open()
			end,
		},
		["cross_battle_value"] = {
			title = Language.CrossServer.BuyTulong,
			x = MainuiTask.Size.width - 62,
			event = function ()
				CrossServerCtrl.Instance:BuyTumo()
			end,
		}
	}

	local task_data = {
		[OTHER_TASK_GUIDE.LEFT] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_CROSS_BATTLE,
			btn_path = "task_btn_cross_battle",
			-- btn_x = 101,
			render = CallBossRender,
			render_data = {texts = texts, btns = btns, items = items},
		},
		[OTHER_TASK_GUIDE.BOTTOM] = {
			guide_name = MainuiTask.GUIDE_NAME.FB_CROSS_BATTLE,
			render_data = {btns = opt_btns, parent_panel = OTHER_TASK_GUIDE.LEFT},
		},
	}
	
	GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE, task_data)
end