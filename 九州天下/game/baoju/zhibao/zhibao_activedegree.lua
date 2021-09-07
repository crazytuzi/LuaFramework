ZhiBaoActiveDegreeView = ZhiBaoActiveDegreeView or BaseClass(BaseRender)

local ListViewDelegate = ListViewDelegate
local CENTER_POINT_OFFSET = 60
function ZhiBaoActiveDegreeView:__init()
	self.active_degree_value = self:FindVariable("ActiveDegreeValue")
	self.slider_value = self:FindVariable("SliderValue")
	self.cell_position_list = {}
	self:InitScroller()

	self.complete_call_back = BindTool.Bind(self.CompleteCallBack, self)

	self.handle_slide_obj = self:FindObj("HandleSlideObj")

	local obj_group = self:FindObj("ObjGroup")
	local reward_group_long = obj_group.rect.rect.width

	self.rewards = {}
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "RewardsGroup") ~= nil then
			self.rewards[count] = ActiveDegreeRewardCell.New(obj)
			self.rewards[count].index = count - 1
			count = count + 1
		end
	end

	local max_value = ZhiBaoData.Instance:GetActiveDegreeLimit()
	local all_rewards = ZhiBaoData.Instance:GetActiveRewardInfo()

	for i=1,#all_rewards do
		if self.rewards[i] ~= nil then
			local pos_x = (all_rewards[i].cfg.degree_limit / max_value) * reward_group_long
			local pos = self.rewards[i].root_node.rect.anchoredPosition3D
			pos.x = pos_x
			self.rewards[i].root_node.rect.anchoredPosition3D = pos
		end
	end

	self.active_degree_limit = ZhiBaoData.Instance:GetActiveDegreeLimit()
	self:Flush()
end

function ZhiBaoActiveDegreeView:__delete()
	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = nil
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ZhiBaoActiveDegreeView:OpenCallBack()
	GlobalTimerQuest:AddDelayTimer(function()
		self.arrow_index = 1
		self.scroller.scroller:ReloadData(0)
	end, 0)
end

function ZhiBaoActiveDegreeView:OnProtocolChange()
	self.scroller_data = ZhiBaoData.Instance:GetActiveDegreeScrollerData()
	self:Flush()
end

function ZhiBaoActiveDegreeView:CompleteCallBack()
	local active_degree_data = ZhiBaoData.Instance:GetActiveDegreeInfo()
	local now_value = self.slider_value:GetFloat()
	local next_value = now_value + self.interval_value
	self.slider_value:SetValue(next_value)

	local next_total_degree = self.active_degree_limit * next_value
	next_total_degree = string.format("%.2f", next_total_degree)
	next_total_degree = math.ceil(next_total_degree)

	self.active_degree_value:SetValue(next_total_degree..' / '..self.active_degree_limit)
	if next_total_degree >= active_degree_data.total_degree then
		self.reward_data = ZhiBaoData.Instance:GetActiveRewardInfo()
		for i=1,#self.rewards do
			self.rewards[i]:SetData(self.reward_data[i])
		end
	end
end

function ZhiBaoActiveDegreeView:Flush()
	local is_change = ZhiBaoData.Instance:GetIsChange()
	local start_fly_obj = ZhiBaoData.Instance:GetStartFlyObj()
	local active_degree_data = ZhiBaoData.Instance:GetActiveDegreeInfo()
	self.reward_data = ZhiBaoData.Instance:GetActiveRewardInfo()
	for i=1,#self.rewards do
		self.rewards[i]:SetData(self.reward_data[i])
	end
	--进度条
	self.active_degree_value:SetValue(active_degree_data.total_degree..' / '..self.active_degree_limit)
	local value = active_degree_data.total_degree / self.active_degree_limit
	self.slider_value:SetValue(value)

	if self.scroller and self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshActiveCellViews()

		if is_change and start_fly_obj then
			-- local now_value = self.slider_value:GetFloat()
			-- local max_value = active_degree_data.total_degree / self.active_degree_limit
			-- self.interval_value = (max_value - now_value)/5
			TipsCtrl.Instance:ShowFlyEffectManager(ViewName.BaoJu, "effects2/prefab/ui/ui_guangdian1_prefab", "UI_guangdian1", start_fly_obj, self.handle_slide_obj, nil, 1)
		end
	end
end

function ZhiBaoActiveDegreeView:InitScroller()
	self.cell_list = {}
	self.scroller_data = ZhiBaoData.Instance:GetActiveDegreeScrollerData()
	self.scroller = self:FindObj("Scroller")

	self.scroller.scroller.scrollerScrolled = function ()
		local enum = self.scroller.scroller:GetPositionBeforeEnum()
		local half_rect_size = self.scroller.scroller.ScrollRectSize / 2

		for _, v in pairs(self.cell_list) do
			local index = v:GetIndex()
			local cell_position = self.scroller.scroller:GetScrollPositionForDataIndex(index, enum)
			local cell_height = v:GetHeight()
			local center_point = self.scroller.scroller.ScrollPosition + half_rect_size + 24
			center_point = math.ceil(center_point)
			cell_position = cell_position + cell_height/2
			self.cell_position_list[v] = cell_position
			local distance = cell_position - center_point
			if distance < 0 and distance > -75 then
				self.arrow_index = index
				self:FlushArrow()
			end
		end
	end

	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		if nil == self.cell_list[cell] then
			self.cell_list[cell] = ActiveDegreeScrollCell.New(cell.gameObject)
			self.cell_list[cell].parent_view = self
		end
		self.cell_list[cell]:SetIndex(data_index)
		self.cell_list[cell]:SetData(self.scroller_data[data_index])
		self:FlushArrow()
	end
end

function ZhiBaoActiveDegreeView:FlushArrow()
	for k,v in pairs(self.cell_list) do
		v:ShowArrow(v.index == self.arrow_index)
	end
end

----------------------------------------------------------------------------
--ActiveDegreeScrollCell 		活跃滚动条格子
----------------------------------------------------------------------------

ActiveDegreeScrollCell = ActiveDegreeScrollCell or BaseClass(BaseCell)
function ActiveDegreeScrollCell:__init(instance)
	self:ListenEvent("GetReward", BindTool.Bind(self.OnGetReward, self))

	self.exp = self:FindVariable("Exp")
	self.item_name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.times = self:FindVariable("Times")
	self.huo_yue = self:FindVariable("HuoYue")

	self.have_go_to = self:FindVariable("HaveGoTo")
	self.is_grey = self:FindVariable("is_grey")
	self.is_show_time = self:FindVariable("is_show_time")
	self.time = self:FindVariable("time")
	self.show_arrow = self:FindVariable("show_arrow")
	self.can_get = self:FindVariable("CanGet")

	--引导用按钮
	self.btn_go = self:FindObj("BtnGo")
	self.target_obj = self:FindObj("TargetObj")
	self.items={}
	for i=1,2 do
		local item_obj = self:FindObj("Item_"..i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.items[i] = {item_obj = item_obj, item_cell = item_cell}
	end
	self.activity_time_change_callback = BindTool.Bind(self.HandleTime, self)
	WelfareData.Instance:NotifyWhenTimeChange(self.activity_time_change_callback)
end

function ActiveDegreeScrollCell:__delete()
	if WelfareData.Instance ~= nil then
		WelfareData.Instance:UnNotifyWhenTimeChange(self.activity_time_change_callback)
	end

	self.parent_view = nil

	for k, v in ipairs(self.items) do
		v.item_cell:DeleteMe()
	end
	self.items = {}
end

function ActiveDegreeScrollCell:OnFlush()
	local degree = ZhiBaoData.Instance:GetActiveDegreeListBySeq(self.data.show_seq) or 0
	-- self.exp:SetValue(self.data.add_exp)
	-- self.huo_yue:SetValue(self.data.add_degree)
	-- local item_data= {{item_id = 90014,num=self.data.add_degree,is_bind = 0},{item_id = ResPath.CurrencyToIconId.exp or 0,num=self.data.add_exp,is_bind = 0}}
	local  item_data = {}
	table.insert(item_data, {item_id = ResPath.CurrencyToIconId.huoyue or 0,num=self.data.add_degree,is_bind = 0})
	table.insert(item_data, {item_id = ResPath.CurrencyToIconId.exp or 0,num=self.data.add_exp,is_bind = 0})
	for k,v in pairs(item_data) do
		if v then
			self.items[k].item_cell:SetData(v)
			self.items[k].item_obj:SetActive(true)
		end
	end
	self.item_name:SetValue(self.data.act_name)
	self.icon:SetAsset(ResPath.GetActiveDegreeIcon(self.data.pic_id))
	self.times:SetValue(degree..' / '..self.data.max_times)

	if degree >= self.data.max_times then
		self.is_grey:SetValue(1 == ZhiBaoData.Instance:GetRewardFetchFlag(self.data.type))
	else
		self.is_grey:SetValue(false)
	end

	if self.data.type == 0 then
		if degree >= self.data.max_times then
			self.is_show_time:SetValue(false)
			self.have_go_to:SetValue(true)
		else
			self.is_show_time:SetValue(true)
			self.have_go_to:SetValue(false)
		end
	else
		self.is_show_time:SetValue(false)
		self.have_go_to:SetValue(true)
	end

	if ZhiBaoData.Instance:GetActiveDegreeListByIndex(self.data.type) >= self.data.max_times then
		self.can_get:SetValue(true)
	else
		self.can_get:SetValue(false)
	end
end

function ActiveDegreeScrollCell:HandleTime()
	local hour, min, sec = WelfareData.Instance:GetOnlineTime()
	self.time:SetValue(string.format("%s:%s:%s",hour,min,sec))
end

function ActiveDegreeScrollCell:OnGetReward()
	if ZhiBaoData.Instance:GetActiveDegreeListByIndex(self.data.type) >= self.data.max_times then
		ZhiBaoData.Instance:SetStartFlyObj(self.target_obj)
		ZhiBaoCtrl.Instance:SendGetActiveReward(FETCH_ACTIVE_REWARD_OPERATE_TYEP.FETCH_ACTIVE_DEGREE_REWARD, self.data.type)
	else
		self.OnGoClick(self.data)
	end
end

function ActiveDegreeScrollCell.OnGoClick(data)
	if nil == data then return end
	if data.goto_panel ~= "" then
		if data.goto_panel == "GuildTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.GUILD)
			if task_id == nil or task_id == 0 then
				-- TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotGuildTask)
				ViewManager.Instance:Open(ViewName.Guild)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.BaoJu)
			return
		elseif data.goto_panel == "DailyTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
			print("task_id:  "..task_id)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotDailyTask)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.BaoJu)
			return
		elseif data.goto_panel == "HuSong" then
			ViewManager.Instance:Close(ViewName.BaoJu)
			YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
			return
		end
		ViewManager.Instance:Close(ViewName.BaoJu)
		local t = Split(data.goto_panel, "#")
		local view_name = t[1]
		local tab_index = t[2]
		if view_name == "FuBen" then
			FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
			FuBenCtrl.Instance:SendGetExpFBInfoReq()
			FuBenCtrl.Instance:SendGetStoryFBGetInfo()
			FuBenCtrl.Instance:SendGetVipFBGetInfo()
			FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		elseif view_name == "Activity" then
			ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE[tab_index])
			return
		end
		ViewManager.Instance:Open(view_name, TabIndex[tab_index])
	end
end

--引导用
function ActiveDegreeScrollCell:GetGoToPanel()
	local data = self.data or {}
	return data.goto_panel
end

function ActiveDegreeScrollCell:ShowArrow(is_show)
	local degree = ZhiBaoData.Instance:GetActiveDegreeListBySeq(self.data.show_seq) or 0
	local is_show = is_show and degree < self.data.max_times and self.data.act_name ~= "在线小时"
	self.show_arrow:SetValue(is_show)
end

function ActiveDegreeScrollCell:GetHeight()
	return self.root_node.rect.rect.height
end
----------------------------------------------------------------------------
--ActiveDegreeRewardCell		活跃奖励格子
----------------------------------------------------------------------------

ActiveDegreeRewardCell = ActiveDegreeRewardCell or BaseClass(BaseCell)
function ActiveDegreeRewardCell:__init()
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_number = self:FindVariable("Number")
	self.show_eff = self:FindVariable("ShowEff")
	self.have_got = self:FindVariable("Have_Got")
end

function ActiveDegreeRewardCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ActiveDegreeRewardCell:OnFlush()
	self.item_cell:SetData(self.data.cfg.item)
	--为什么要强制把物品数量设为-1呢？？
	-- self.item_cell:SetNum(-1)
	self.item_number:SetValue(self.data.cfg.degree_limit)
	self.have_got:SetValue(self.data.flag)
	if self.data.flag then
		--已领取
		self.show_eff:SetValue(false)
		self.item_cell:ClearItemEvent()
	else
		--未领取
		local degree_info =  ZhiBaoData.Instance:GetActiveDegreeInfo()
		local player_degree = degree_info.total_degree
		local click_func = nil
		if self.data.cfg.degree_limit <= player_degree then
			--可领取
			self.show_eff:SetValue(true)
			click_func = function()
			 	ZhiBaoCtrl.Instance:SendGetActiveReward(FETCH_ACTIVE_REWARD_OPERATE_TYEP.FETCHE_TOTAL_ACTIVE_DEGREE_REWARD, self.data.cfg.reward_index)
			 	AudioService.Instance:PlayRewardAudio()
			end
		else
			--不可领取
			self.show_eff:SetValue(false)
			click_func = function() TipsCtrl.Instance:OpenItem(self.data.cfg.item) end
		end
		self.item_cell:ListenClick(click_func)
	end
end
