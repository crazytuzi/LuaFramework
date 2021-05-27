CrossEatChickenProgress = CrossEatChickenProgress or BaseClass(XuiBaseView)

function CrossEatChickenProgress:__init()
	self.def_index = 1
	-- self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.config_tab = {
		{"cross_eat_chicken_progress_ui_cfg", 1, {0}},
	}
	self.boss_refresh_time = 0
	self.can_penetrate = true
end

function CrossEatChickenProgress:__delete()
	
end

function CrossEatChickenProgress:ReleaseCallBack()
	self.boss_refresh_time = 0
end

function CrossEatChickenProgress:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local screen_size = HandleRenderUnit:GetSize()
		local off_set = 160
		local size = self.node_t_list.layout_cross_eat_chicken_progress.node:getContentSize()
		self.root_node:setPosition(screen_size.width - off_set - size.width, -size.height/2 - 8)
		XUI.RichTextSetCenter(self.node_t_list.rich_poinson_area.node)
		XUI.RichTextSetCenter(self.node_t_list.rich_self_explode_boss.node)
		--print("位置：", self.root_node:getPositionX(), self.root_node:getPositionY())
	end
end

function CrossEatChickenProgress:OpenCallBack()
	self:CreateTimer1()
	self:CreateTimer2()
	if self.close_pannel == nil then
		self.close_pannel = GlobalEventSystem:Bind(CommonpanelOpenOrCloseEvent.CLOSE_PANEL, BindTool.Bind(self.Close, self))
	end
end

function CrossEatChickenProgress:CloseCallBack()
	self.poinson_range_id = nil
	self:DeleteTimer1()
	self:DeleteTimer2()
	if self.close_pannel then
		GlobalEventSystem:UnBind(self.close_pannel)
		self.close_pannel = nil
	end
end

function CrossEatChickenProgress:ShowIndexCallBack(index)
	self:Flush(index)
end

function CrossEatChickenProgress:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "progress" then
			self.node_t_list.txt_kill_cnt.node:setString(string.format(Language.CrossEatChicken.KillTxt, v[1]))
			self.node_t_list.txt_alive_cnt.node:setString(string.format(Language.CrossEatChicken.AliveTxt, v[2]))
			self.boss_refresh_time = v[5] + Status.NowTime
			self:FlushBossRefreshTime(1)
			self.poinson_range_id = v[3]
			self.drop_range_time = v[4] + Status.NowTime
			self:FlushPoinsonAreaTime(1)
		end
	end
end

function CrossEatChickenProgress:FlushPoinsonAreaTime(t)
	if self.poinson_range_id and self.poinson_range_id > 0 then
		local rest_time = self.drop_range_time - Status.NowTime
		rest_time = TimeUtil.FormatSecond(rest_time, 2)
		local name = CrossEatChickenData.Instance:GetDropRangeList(self.poinson_range_id) and CrossEatChickenData.Instance:GetDropRangeList(self.poinson_range_id).name or ""
		local content = string.format(Language.CrossEatChicken.PoinsonTxts[2], name, rest_time)
		RichTextUtil.ParseRichText(self.node_t_list.rich_poinson_area.node, content, 20)
	else
		RichTextUtil.ParseRichText(self.node_t_list.rich_poinson_area.node, Language.CrossEatChicken.PoinsonTxts[1], 20)
		self:DeleteTimer1()
	end
end

function CrossEatChickenProgress:CreateTimer1()
	if self.timer_1 == nil then
		self.timer_1 = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushPoinsonAreaTime, self), 1)
	end
end

function CrossEatChickenProgress:DeleteTimer1()
	if self.timer_1 then
		GlobalTimerQuest:CancelQuest(self.timer_1)
		self.timer_1 = nil
	end
end

function CrossEatChickenProgress:CreateTimer2()
	if self.timer_2 == nil then
		self.timer_2 = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushBossRefreshTime, self), 1)
	end
end

function CrossEatChickenProgress:DeleteTimer2()
	if self.timer_2 then
		GlobalTimerQuest:CancelQuest(self.timer_2)
		self.timer_2 = nil
	end
end

function CrossEatChickenProgress:FlushBossRefreshTime(t)
	local rest_time = self.boss_refresh_time - Status.NowTime
	if rest_time >= 0 then
		rest_time = TimeUtil.FormatSecond(rest_time, 2)
		local content = string.format(Language.CrossEatChicken.NextExplodeBoss[2], rest_time)
		RichTextUtil.ParseRichText(self.node_t_list.rich_self_explode_boss.node, content, 20)
	else
		RichTextUtil.ParseRichText(self.node_t_list.rich_self_explode_boss.node, Language.CrossEatChicken.NextExplodeBoss[1], 20)
	end
end