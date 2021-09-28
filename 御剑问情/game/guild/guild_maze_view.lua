GuildMazeView = GuildMazeView or BaseClass(BaseRender)

function GuildMazeView:__init(instance)
	if instance == nil then
		return
	end
	self.ui_layer = GameObject.Find("GameRoot/UILayer")
	self:InitChatScroller()
	self:InitRankScroller()
	self:InitDoorPanel()
	self:ListenEvent("OnClickGuildHelp",
		BindTool.Bind(self.OnClickGuildHelp, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickRankReward",
		BindTool.Bind(self.OnClickRankReward, self))
	self.layer = self:FindVariable("Layer")
	self.my_name = self:FindVariable("MyName")
	self.my_rank = self:FindVariable("MyRank")
	self.my_finish_time = self:FindVariable("MyFinishTime")
	self.cd = self:FindVariable("CD")
	self.is_finish = self:FindVariable("IsFinish")
	self.animator_cd = self:FindObj("AnimatorCD"):GetComponent(typeof(UnityEngine.Animator))
	self.is_help_cd = self:FindVariable("IsHelpCD")
	self.help_cd = self:FindVariable("HelpCD")
	self.max_layer = self:FindVariable("MaxLayer")
	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell" .. i))
	end
	local maze_info = GuildData.Instance:GetMazeInfo()
	self.old_layer = maze_info.layer + 1
	self.last_help_time = 0
	self.maze_help_cd = GuildData.Instance:GetMazeHelpCD()
	self.finish = false
	self.complete_count = 5
	self:FlushReward()
end

function GuildMazeView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	for k, v in pairs(self.rank_cell_list) do
		v:DeleteMe()
	end
	self.rank_cell_list = {}
	if self.chat_measuring then
		GameObject.Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self:RemoveCountDown()
	self:RemoveCountDown2()
	for k,v in pairs(self.door_list) do
		v:DeleteMe()
	end
	self.door_list = {}
end

function GuildMazeView:Flush()
	local maze_info = GuildData.Instance:GetMazeInfo()
	self.max_layer:SetValue(maze_info.max_layer)
	local layer = maze_info.layer + 1
	local chat_compre_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.GUILD) or {}
	self.compre_list = {}
	local msg_list = chat_compre_list.msg_list or {}
	local main_role_vo = Scene.Instance:GetMainRole().vo
	for k,v in ipairs(msg_list) do
		if string.find(v.content, "{guild_maze_chose;" .. layer) or (string.find(v.content, "{guild_maze_chose;") and v.from_uid == main_role_vo.role_id) or
		string.find(v.content, "{guild_maze_help;") then
			table.insert(self.compre_list, v)
		end
	end
	local is_lock = ChatData.Instance:GetIsLockState()
	if is_lock then
		self.chat_list.scroller:RefreshAndReloadActiveCellViews(true)
	else
		self.chat_list.scroller:ReloadData(1)
	end

	self.rank_info = GuildData.Instance:GetMazeRankInfo()
	self.my_name:SetValue(main_role_vo.name)
	local rank = 0
	for k,v in ipairs(self.rank_info.rank_list) do
		if v.uid == main_role_vo.role_id then
			rank = k
			break
		end
	end
	if rank > 0 then
		self.my_rank:SetValue(rank)
	else
		self.my_rank:SetValue(Language.Common.ZanWu)
	end

	self:FlushCurLayer()

	if self.rank_list.scroller.isActiveAndEnabled then
		self.rank_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildMazeView:FlushReward()
	-- 这里改为一直显示第五层奖励
	local cfg = GuildData.Instance:GetMazeCfgByLayer(5)
	local num = 1
	if cfg then
		local reward_item = cfg.reward_item
		for k,v in pairs(reward_item) do
			if self.item_cell_list[num] then
				self.item_cell_list[num]:SetParentActive(true)
				self.item_cell_list[num]:SetData(v)
			end
			num = num + 1
		end
	end
	for i = num, 3 do
		self.item_cell_list[i]:SetParentActive(false)
	end
end

function GuildMazeView:FlushCurLayer()
	local maze_info = GuildData.Instance:GetMazeInfo()
	local layer = maze_info.layer + 1
	self.layer:SetValue(CommonDataManager.GetDaXie(layer))
	local reward_list = {}
	local cfg = GuildData.Instance:GetMazeCfgByLayer(maze_info.layer)
	local num = 1
	if cfg then
		local reward_item = cfg.reward_item
		for k,v in pairs(reward_item) do
			if v.item_id > 0 then
				table.insert(reward_list, v)
			end
		end
	end

	local reason = maze_info.reason
	maze_info.reason = GUILD_MAZE_INFO_REASON.GUILD_MAZE_INFO_REASON_DEF

	if layer > 5 and reason == GUILD_MAZE_INFO_REASON.GUILD_MAZE_INFO_REASON_FIRST_SUCC then
		ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "reward", {data = reward_list})
	end

	-- 掉层
	if layer < self.old_layer and reason == GUILD_MAZE_INFO_REASON.GUILD_MAZE_INFO_REASON_FAIL then
		TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui/ui_chuangguanshibai_prefab", "UI_ChuangGuanShiBai", 1.5)
		self:StartDownAnimation()
	-- 升层
	elseif layer > self.old_layer and layer <= 5 then
		TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui/ui_chuangguanchenggong_prefab", "UI_ChuangGuanChengGong", 1.5)
		self:StartUpAnimation()
	end

	local cd = GuildData.Instance:GetMazeAnswerCD()
	if cd > 0 then
		self.cd:SetValue(string.format(Language.Guild.MazeCD2, TimeUtil.FormatSecond(cd, 2)))
		self:RemoveCountDown()
		self.count_down = CountDown.Instance:AddCountDown(cd + 1, 0.5, BindTool.Bind(self.CountDown, self))
		-- 在第一层选错
		if self.old_layer == layer and reason == GUILD_MAZE_INFO_REASON.GUILD_MAZE_INFO_REASON_FAIL then
			TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui/ui_chuangguanshibai_prefab", "UI_ChuangGuanShiBai", 1.5)
			for k,v in pairs(self.door_list) do
				v:PlayShiBaiEffect(0.2 * k)
			end
		end
	else
		self.cd:SetValue("")
		for k,v in pairs(self.door_list) do
			v:SetNormal()
		end
	end
	if maze_info.complete_time > 0 then
		self.is_finish:SetValue(true)
		self.finish = true
		self.layer:SetValue(CommonDataManager.GetDaXie(layer - 1))
		local time_zone = TimeUtil.GetTimeZone()
		local complete_time = maze_info.complete_time + time_zone
		complete_time = complete_time % 86400
		self.my_finish_time:SetValue(TimeUtil.FormatSecond(complete_time, 5))
	else
		self.is_finish:SetValue(false)
		self.finish = false
		self.my_finish_time:SetValue("")
	end
	self.old_layer = layer
end

function GuildMazeView:ResetAnimatorState()
	self.complete_count = 5
	for k,v in pairs(self.door_list) do
		v:ResetState()
	end
end

function GuildMazeView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function GuildMazeView:CountDown(elapse_time, total_time)
	local cd = GuildData.Instance:GetMazeAnswerCD()
	if cd > 0 then
		self.cd:SetValue(string.format(Language.Guild.MazeCD2, TimeUtil.FormatSecond(cd, 2)))
	else
		self.cd:SetValue("")
		self:RemoveCountDown()
	end
end

function GuildMazeView:StartDownAnimation()
	self.complete_count = 0
	local call_back = function()
		self.complete_count = self.complete_count + 1
	end
	if next(self.door_list) then
		self.door_list[3]:ShowDownAnimation(0.2, call_back)
		self.door_list[4]:ShowDownAnimation(0.2 * 2, call_back)
		self.door_list[5]:ShowDownAnimation(0.2 * 3, call_back)
		self.door_list[1]:ShowDownAnimation(0.2 * 4, call_back)
		self.door_list[2]:ShowDownAnimation(0.2 * 5, call_back)
	end
end

function GuildMazeView:StartUpAnimation()
	self.complete_count = 0
	for k,v in ipairs(self.door_list) do
		v:ShowUpAnimation(0.2 * k, function()
			self.complete_count = self.complete_count + 1
		end)
	end
end
-----------------------------------ChatScroller--------------------------------------

function GuildMazeView:InitChatScroller()
	self.cell_list = {}
	self.compre_list = {}
	self.chat_list = self:FindObj("ChatList")

	local scroller_delegate = self.chat_list.list_simple_delegate
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.chat_list.scroller.scrollerScrolled = function()
		local position = self.chat_list.scroller.ScrollPosition
		position = position < 0 and 0 or position
		position = math.floor(position)
		local scroll_size = self.chat_list.scroller.ScrollSize
		if scroll_size < 10 then
			return
		end
	end
end

function GuildMazeView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local compre_data = self.compre_list[data_index]
	local scroller_delegate = self.chat_list.list_simple_delegate
	local chat_measuring = self:GetChatMeasuring(scroller_delegate)
	chat_measuring:SetEasy(true)
	chat_measuring:SetData(compre_data)
	height = chat_measuring:GetContentHeight()
	return height
end

function GuildMazeView:GetNumberOfCells()
	return #self.compre_list or 0
end

function GuildMazeView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = GuildMazeChatCell.New(cell.gameObject)
		self.cell_list[cell] = chat_cell
	end

	chat_cell:SetIndex(data_index)
	chat_cell:SetData(self.compre_list[data_index])
end

function GuildMazeView:GetChatMeasuring(delegate)
	if not delegate then
		return
	end
	if not self.chat_measuring then
		local cell = delegate:CreateCell()
		cell.transform:SetParent(self.ui_layer.transform, false)
		cell.transform.localPosition = Vector3(9999, 0, 0)			--直接放在界面外
		GameObject.DontDestroyOnLoad(cell.gameObject)
		self.chat_measuring = GuildMazeChatCell.New(cell.gameObject)
	end
	return self.chat_measuring
end

function GuildMazeView:OnClickGuildHelp()
	if self.finish then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MazeHasFinish)
		return
	end
	if self.last_help_time + self.maze_help_cd > Status.NowTime then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MazeHelpCD)
		return
	end
	self.is_help_cd:SetValue(true)
	self.last_help_time = Status.NowTime
	self.help_cd:SetValue(TimeUtil.FormatSecond(math.ceil(self.last_help_time + self.maze_help_cd - Status.NowTime), 2))
	self:RemoveCountDown2()
	self.count_down2 = CountDown.Instance:AddCountDown(self.maze_help_cd, 0.5, BindTool.Bind(self.CountDown2, self))

	local layer = GuildData.Instance:GetMazeInfo().layer + 1
	local text = string.format(Language.Guild.MazeHelp, layer)
	for i = 1, 5 do
		text = text .. string.format("{guild_maze;%d;%d;%d}", layer, i, TimeCtrl.Instance:GetServerTime())
	end
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, text, CHAT_CONTENT_TYPE.TEXT)
end

function GuildMazeView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(190)
end

function GuildMazeView:OnClickRankReward()
	GuildCtrl.Instance:OpenGuildMazeRankRewardView()
end

function GuildMazeView:OnClickDoor(index)
	if self.finish then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MazeHasFinish)
		return
	end
	-- 正在播放动画
	if self:CheckIsPlayAnimation() then
		return
	end
	local cd = GuildData.Instance:GetMazeAnswerCD()
	if cd > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MazeCD)
		self.animator_cd:SetTrigger("Flash")
		return
	end
	GuildCtrl.Instance:SendGuildMazeOperate(GUILD_MAZE_OPERATE_TYPE.GUILD_MAZE_OPERATE_TYPE_SELECT, index)
end

function GuildMazeView:RemoveCountDown2()
	if self.count_down2 then
		CountDown.Instance:RemoveCountDown(self.count_down2)
		self.count_down2 = nil
	end
end

function GuildMazeView:CountDown2(elapse_time, total_time)
	if self.last_help_time + self.maze_help_cd > Status.NowTime then
		self.help_cd:SetValue(TimeUtil.FormatSecond(math.ceil(self.last_help_time + self.maze_help_cd - Status.NowTime), 2))
		return
	end
	self.is_help_cd:SetValue(false)
	self.help_cd:SetValue("")
end

function GuildMazeView:CheckIsPlayAnimation()
	return self.complete_count < 5
end
-------------------------------------------RankScroller-----------------------------------------------

function GuildMazeView:InitRankScroller()
	self.rank_cell_list = {}
	self.rank_list = self:FindObj("RankList")

	local scroller_delegate = self.rank_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRankNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RankRefreshCell, self)
end

function GuildMazeView:GetRankNumberOfCells()
	local cell_number = 3
	if self.rank_info.rank_count > 0 then
		cell_number = self.rank_info.rank_count
	end
	return cell_number
end

function GuildMazeView:RankRefreshCell(cell, data_index)
	data_index = data_index + 1
	local rank_cell = self.rank_cell_list[cell]
	if rank_cell == nil then
		rank_cell = GuildMazeRankCell.New(cell.gameObject)
		self.rank_cell_list[cell] = rank_cell
	end

	rank_cell:SetIndex(data_index)
	rank_cell:SetData(self.rank_info.rank_list[data_index])
end

---------------------------------------------MazeDoorPanel-----------------------------------------------

function GuildMazeView:InitDoorPanel()
	self.panel1 = self:FindObj("Panel1")
	self.panel2 = self:FindObj("Panel2")
	self.door_list = {}
	PrefabPool.Instance:Load(AssetID("uis/views/guildview_prefab", "MazeDoor"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, 5 do
            local obj = U3DObject(GameObject.Instantiate(prefab))
            if i <= 2 then
            	obj.transform:SetParent(self.panel1.transform, false)
            else
            	obj.transform:SetParent(self.panel2.transform, false)
            end
            local door = GuildMazeDoorCell.New(obj)
            door:SetIndex(i)
            door:SetClickCallBack(BindTool.Bind(self.OnClickDoor, self))
            self.door_list[i] = door
        end
        PrefabPool.Instance:Free(prefab)
    end)
end

-------------------------------------------GuildMazeDoorCell-----------------------------------------------

GuildMazeDoorCell = GuildMazeDoorCell or BaseClass(BaseRender)

function GuildMazeDoorCell:__init()
	self.index = 0
	self.number = self:FindVariable("Number")
	self:ListenEvent("OnClickNormal", BindTool.Bind(self.OnClickNormal, self))
	self:ListenEvent("OnClickGray", BindTool.Bind(self.OnClickGray, self))
	self.anim = self.root_node:GetComponent(typeof(UnityEngine.Animator))
	self.anim:ListenEvent("MazeUpPlayEnd", BindTool.Bind(self.MazeUpPlayEnd, self))
	self.anim:ListenEvent("MazeDownPlayEnd", BindTool.Bind(self.MazeDownPlayEnd, self))
	self:CheckCD()
end

function GuildMazeDoorCell:__delete()
	self:RemoveDelayTime()
end

function GuildMazeDoorCell:SetIndex(index)
	self.index = index
	self.number:SetValue(index)
end

function GuildMazeDoorCell:SetClickCallBack(call_back)
	self.call_back = call_back
end

function GuildMazeDoorCell:OnClickNormal()
	if self.call_back then
		self.call_back(self.index)
	end
end

function GuildMazeDoorCell:OnClickGray()
	if self.call_back then
		self.call_back(self.index)
	end
end

function GuildMazeDoorCell:SetTrigger(key)
	if self.anim.isActiveAndEnabled then
		self.anim:SetTrigger(key)
		return true
	else
		return false
	end
end

function GuildMazeDoorCell:SetNormal()
	self.anim:SetLayerWeight(1, 0)
end

function GuildMazeDoorCell:SetGray()
	self.anim:SetLayerWeight(1, 1)
end

function GuildMazeDoorCell:ShowUpAnimation(delay_time, call_back)
	self:RemoveDelayTime()
	delay_time = delay_time or 0
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
		if not self:SetTrigger("Up") then
			if call_back then
				call_back()
			end
		end
	end, delay_time)
	self.maze_up_play_end_call_back = call_back
end

function GuildMazeDoorCell:MazeUpPlayEnd()
	if self.maze_up_play_end_call_back then
		self.maze_up_play_end_call_back()
	end
end

function GuildMazeDoorCell:MazeDownPlayEnd()
	if self.maze_down_play_end_call_back then
		self.maze_down_play_end_call_back()
	end
end

function GuildMazeDoorCell:ShowDownAnimation(delay_time, call_back)
	self:RemoveDelayTime()
	delay_time = delay_time or 0
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
		if not self:SetTrigger("Down") then
			if call_back then
				call_back()
			end
		end
	 	self:CheckCD()
	end, delay_time)
	self.maze_down_play_end_call_back = call_back
end

function GuildMazeDoorCell:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function GuildMazeDoorCell:CheckCD()
	local cd = GuildData.Instance:GetMazeAnswerCD()
	if cd > 0 then
		self:SetGray()
	else
		self:SetNormal()
	end
end

function GuildMazeDoorCell:PlayShiBaiEffect(delay_time)
	self:RemoveDelayTime()
	delay_time = delay_time or 0
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:SetTrigger("ShiBai") self:SetGray() end, delay_time)
end

function GuildMazeDoorCell:OnFlush()
	self:CheckCD()
end

function GuildMazeDoorCell:ResetState()
	self:RemoveDelayTime()
	self:CheckCD()
end

-------------------------------------------GuildMazeRankCell-----------------------------------------------

GuildMazeRankCell = GuildMazeRankCell or BaseClass(BaseCell)

function GuildMazeRankCell:__init()
	self.name = self:FindVariable("Name")
	self.rank = self:FindVariable("Rank")
	self.finish_time = self:FindVariable("FinishTime")
end

function GuildMazeRankCell:__delete()

end

function GuildMazeRankCell:OnFlush()
	if self.data then
		self.name:SetValue(self.data.user_name)
		self.rank:SetValue(self.index)
		local time_zone = TimeUtil.GetTimeZone()
		local complete_time = self.data.complete_time + time_zone
		complete_time = complete_time % 86400
		self.finish_time:SetValue(TimeUtil.FormatSecond(complete_time, 5))
	else
		self.name:SetValue(Language.Guild.NonePerson)
		self.rank:SetValue(self.index)
		self.finish_time:SetValue("0:00")
	end
end