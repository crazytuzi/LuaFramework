CongZhiRank =  CongZhiRank or BaseClass(BaseRender)

function CongZhiRank:__init()
	self.contain_cell_list = {}
end

function CongZhiRank:__delete()
	-- if self.least_time_timer then
	-- 	CountDown.Instance:RemoveCountDown(self.least_time_timer)
	-- 	self.least_time_timer = nil
	-- end
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

function CongZhiRank:LoadCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_DAILY_CHONGZHI_RANK)
	self.list_view = self:FindObj("ListView")
	self.rest_hour = self:FindVariable("RestHour")
	self.rest_min = self:FindVariable("RestMin")
	self.rest_sec = self:FindVariable("RestSecond")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.rest_time = self:FindVariable("rest_time")
	-- if self.least_time_timer then
	-- 	CountDown.Instance:RemoveCountDown(self.least_time_timer)
	-- 	self.least_time_timer = nil
	-- end
	-- local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK)
	-- self:SetTime(rest_time)
	-- self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
	-- 		rest_time = rest_time - 1
	-- 		self:SetTime(rest_time)
	-- 	end)

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self.rank_levle = self:FindVariable("rank_levle")

	self.chongzhi_count = self:FindVariable("chongzhi_count")
	self.chongzhi_count:SetValue(KaiFuChargeData.Instance:GetDayChongZhiCount())
	--RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)

	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	-- local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local seq = ActivityData.GetActivityDays(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK)
	self.reward_list, self.coset_list, self.rank_list = KaifuActivityData.Instance:GetDayChongZhiRankInfoListByDay(seq, opengameday)

	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time
	self:SetRestTime(reset_time_s)

end

function CongZhiRank:SetRestTime(diff_time)
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


function CongZhiRank:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function CongZhiRank:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function CongZhiRank:OnFlush()
	self.player_data_list = KaiFuChargeData.Instance:GetDailyChongZhiRank()
	if self.rank_levle then
		self.rank_levle:SetValue(KaiFuChargeData.Instance:GetRank())
	end
end

function CongZhiRank:FlushChongZhi()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(KaiFuChargeData.Instance:GetDayChongZhiCount())
	end
end

function CongZhiRank:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min, temp.s)
	self.rest_time:SetValue(str)
end

function CongZhiRank:GetNumberOfCells()
	return #self.reward_list
end

function CongZhiRank:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = CongZhiRankCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	--local data = KaifuActivityData.Instance:GetDailyActiveRewardInfo()
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
	contain_cell:SetCostData(self.coset_list[cell_index], rank, is_show)
	contain_cell:SetPlayerData(self.player_data_list[cell_index]  or {})
	contain_cell:Flush()
end

----------------------------CongZhiRankCell---------------------------------
CongZhiRankCell = CongZhiRankCell or BaseClass(BaseCell)

function CongZhiRankCell:__init()
	self.avatar_key = 0
	self.reward_data = {}
	self.player_name = self:FindVariable("player_name")
	self.player_image = self:FindVariable("player_img")
	self.show_image = self:FindVariable("showimage")
	self.is_show = self:FindVariable("IsShow")
	self.text = self:FindVariable("text")
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

function CongZhiRankCell:__delete()
	self.player_name = nil
	self.text = nil
	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function CongZhiRankCell:SetPlayerData(playerdata)
	self.player_data = playerdata
end

function CongZhiRankCell:SetItemData(data)
	self.reward_data = data
end

function CongZhiRankCell:SetCostData(coset_text, rank, is_show)
	local str = string.format(Language.Activity.ChongZhiRank, rank, coset_text)
	self.text:SetValue(str)
	self.is_show:SetValue(is_show)
end

function CongZhiRankCell:LoadCallBack(user_id, path)
	if self:IsNil() or self.player_data == nil then
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

function CongZhiRankCell:OnFlush()
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
			AvatarManager.Instance:GetAvatar(self.player_data.user_id, false, BindTool.Bind(self.LoadCallBack, self, self.player_data.user_id))
			-- if avatar_key ~= self.avatar_key then
			-- 	self.avatar_key = avatar_key
			-- 	AvatarManager.Instance:GetAvatar(self.player_data.user_id, false, BindTool.Bind(self.LoadCallBack, self, self.player_data.user_id))
			-- end
		end
	end
end