XiaoFeiRank =  XiaoFeiRank or BaseClass(BaseRender)

function XiaoFeiRank:__init()
	self.contain_cell_list = {}
end

function XiaoFeiRank:__delete()
	self.list_view = nil
	self.rank_levle = nil
	self.xiaofei_count = nil
	self.rest_time = nil

	if self.contain_cell_list then
		for k, v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function XiaoFeiRank:LoadCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_XIAOFEI_NUM)
 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_DAILY_CONSUME_RANK)
	self.list_view = self:FindObj("ListView")
	self.rest_hour = self:FindVariable("RestHour")
	self.rest_min = self:FindVariable("RestMin")
	self.rest_sec = self:FindVariable("RestSecond")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK)

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self.rank_levle = self:FindVariable("rank_levle")

	self.xiaofei_count = self:FindVariable("xiaofei_count")
	self.xiaofei_count:SetValue(KaiFuChargeData.Instance:GetDayConsumeRankInfo())
	
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	self.reward_list, self.coset_list, self.rank_list, self.fanli_rate = KaifuActivityData.Instance:GetDayConsumeRankRewardInfoListByDay(7 - time_tab.day)

	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time
	self:SetRestTime(reset_time_s)
end

function XiaoFeiRank:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.rest_hour:SetValue(left_hour)
			self.rest_min:SetValue(left_min)
			self.rest_sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function XiaoFeiRank:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function XiaoFeiRank:ClickReChange()
	-- 固定跳转到商城元宝界面
	ViewManager.Instance:Open(ViewName.Shop, 2)
end

function XiaoFeiRank:OnFlush()
	self.player_data_list = KaiFuChargeData.Instance:GetDailyXiaoFeiRank()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	if self.rank_levle then
		self.rank_levle:SetValue(KaiFuChargeData.Instance:GetRankLevel())
	end
	if self.xiaofei_count then
		self.xiaofei_count:SetValue(KaiFuChargeData.Instance:GetDayConsumeRankInfo())
	end
end

function XiaoFeiRank:FlushXiaoFei()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	if self.xiaofei_count then
		self.xiaofei_count:SetValue(KaiFuChargeData.Instance:GetDayConsumeRankInfo())
	end
end

function XiaoFeiRank:GetNumberOfCells()
	return #self.reward_list
end

function XiaoFeiRank:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = XiaoFeiRankCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	local rank = ""
	local last_rank = self.rank_list[cell_index - 1]
	local current_rank = self.rank_list[cell_index]
	local is_show = false
	if last_rank then
		if  current_rank - last_rank == 1 then
			rank = tostring(current_rank)
			is_show = true
		else
			rank = tostring((last_rank + 1).."-"..current_rank)
		end
	else
		if current_rank == 1 then
			rank = 1
			is_show = true
		else
			rank = tostring("0-"..current_rank)
		end
	end
	contain_cell:SetCostData(self.coset_list[cell_index], rank, self.fanli_rate[cell_index],is_show)
	contain_cell:SetPlayerData(self.player_data_list[cell_index]  or {})
	contain_cell:Flush()
end

----------------------------XiaoFeiRankCell---------------------------------
XiaoFeiRankCell = XiaoFeiRankCell or BaseClass(BaseCell)

function XiaoFeiRankCell:__init()
	self.avatar_key = 0
	self.reward_data = {}
	self.player_name = self:FindVariable("player_name")
	self.player_image = self:FindVariable("player_img")
	self.show_image = self:FindVariable("showimage")
	self.is_show = self:FindVariable("IsShow")
	self.text = self:FindVariable("text")
	self.text2 = self:FindVariable("text2")
	self.text3 = self:FindVariable("text3")
	self.rawimage_path = self:FindVariable("rawimagePath")
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
end

function XiaoFeiRankCell:__delete()
	self.player_name = nil
	self.text = nil
	self.text2 = nil
	self.text3 = nil
	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function XiaoFeiRankCell:SetPlayerData(playerdata)
	self.player_data = playerdata
end

function XiaoFeiRankCell:SetItemData(data)
	self.reward_data = data
end

function XiaoFeiRankCell:SetCostData(coset_text, rank, fanli_rate, is_show)
	local str = string.format(Language.Activity.XiaoFeiRank, rank, coset_text)
	self.text:SetValue(rank)
	self.text2:SetValue(coset_text)
	self.text3:SetValue(fanli_rate)
	self.is_show:SetValue(is_show)
end

function XiaoFeiRankCell:LoadTextureCallBack(user_id, path)
	if self:IsNil() then
		return
	end

	if user_id ~= self.player_data.user_id then
		self.show_image:SetValue(true)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(user_id, false)
	end
	self.show_image:SetValue(false)

	GlobalTimerQuest:AddDelayTimer(function()
		self.rawimage_path:SetValue(path)
	end, 0)
end

function XiaoFeiRankCell:OnFlush()
	self.rawimage_path:SetValue("")
	for k,v in pairs(self.reward_data) do
		if v then
			self.item_cell_list[k + 1]:SetData(v)
		end
	end
	--如果没有人上榜
	if not next(self.player_data) then
		self.player_name:SetValue("")
		self.is_show:SetValue(false)
		self.show_image:SetValue(true)
	else
		self.player_name:SetValue(self.player_data.user_name)
		-- 协议返回的头像key
		local avatar_key = AvatarManager.Instance:GetAvatarKey(self.player_data.user_id)
		-- 如果没有
		if avatar_key == 0 then
			self.avatar_key = 0
			local bundle, asset = AvatarManager.GetDefAvatar(self.player_data.prof, false, self.player_data.sex)
			self.show_image:SetValue(true)
			self.player_image:SetAsset(bundle, asset)
		else
			self.avatar_key = avatar_key
			if not self.is_show:GetBoolean() then
				return
			end
			AvatarManager.Instance:GetAvatar(self.player_data.user_id, false, BindTool.Bind(self.LoadTextureCallBack, self, self.player_data.user_id))
		end
	end
end