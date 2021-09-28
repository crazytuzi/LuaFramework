CongZhiRank =  CongZhiRank or BaseClass(BaseRender)

function CongZhiRank:__init()
	self.contain_cell_list = {}
	self.player_data_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.rest_time = self:FindVariable("rest_time")
	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self.rank_levle = self:FindVariable("rank_levle")
	self.chongzhi_count = self:FindVariable("chongzhi_count")
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)
end

function CongZhiRank:__delete()
	if self.contain_cell_list then
		for k,v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end
	self.player_data_list = {}
	self.list_view = nil
	self.rest_time = nil
	self.rank_levle = nil
	self.chongzhi_count = nil
end

function CongZhiRank:OpenCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

	self.chongzhi_count:SetValue(KaifuActivityData.Instance:GetDayChongZhiCount())
	--RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)

	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
--	self.reward_list, self.coset_list, self.rank_list = KaifuActivityData.Instance:GetDayChongZhiRankInfoListByDay(7 - time_tab.day, opengameday)
	local pass_day = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK)
	self.reward_list, self.coset_list, self.rank_list = KaifuActivityData.Instance:GetDayChongZhiRankInfoListByDay(pass_day + 1, opengameday)
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
	self.player_data_list = KaifuActivityData.Instance:GetDailyChongZhiRank()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	if self.rank_levle then
		self.rank_levle:SetValue(KaifuActivityData.Instance:GetRank())
	end
end

function CongZhiRank:FlushChongZhi()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(KaifuActivityData.Instance:GetDayChongZhiCount())
	end
end

function CongZhiRank:SetTime(rest_time)
	-- local left_day = math.floor(rest_time / 86400)
	-- if left_day > 0 then
	-- 	time_str = TimeUtil.FormatSecond(rest_time, 8)
	-- else
	-- 	time_str = TimeUtil.FormatSecond(rest_time)
	-- end
	local time_str = ""
	local day_second = 24 * 60 * 60         -- 一天有多少秒
	local left_day = math.floor(rest_time / day_second)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 7)
	elseif rest_time < day_second then
		if math.floor(rest_time / 3600) > 0 then
			time_str = TimeUtil.FormatSecond(rest_time, 1)
		else
			time_str = TimeUtil.FormatSecond(rest_time, 2)
		end
	end
	
	if self.rest_time then
		self.rest_time:SetValue(time_str)
	end
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
	contain_cell:SetIndex(cell_index)
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
	local chongzhi_count = KaifuActivityData.Instance:GetDayChongZhiCount()
	contain_cell:SetCostData(self.coset_list[cell_index], rank, is_show, chongzhi_count)
	contain_cell:SetPlayerData(self.player_data_list[cell_index]  or {})
	contain_cell:Flush()
end

----------------------------CongZhiRankCell---------------------------------
CongZhiRankCell = CongZhiRankCell or BaseClass(BaseCell)

function CongZhiRankCell:__init()
	self.avatar_key = 0
	self.reward_data = {}
	self.player_name = self:FindVariable("player_name")
	self.show_image = self:FindVariable("player_img")
	self.is_show = self:FindVariable("IsShow")
	self.text = self:FindVariable("text")
	self.iconimg = self:FindVariable("iconimg")
	self.rawimg = self:FindObj("rawimg")
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
	self.show_image = nil
	self.is_show = nil
	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self.iconimg = nil
	self.rawimg = nil

end

function CongZhiRankCell:SetPlayerData(playerdata)
	self.player_data = playerdata

end

function CongZhiRankCell:SetItemData(data)
	self.reward_data = data
end

function CongZhiRankCell:SetCostData(coset_text, rank, is_show, chongzhi_count)
	local color = chongzhi_count >= tonumber(coset_text) and "#0000f1" or "#e40000"
	local str = string.format(Language.Activity.ChongZhiRank, rank, color, chongzhi_count, coset_text)
	self.text:SetValue(str)
	self.is_show:SetValue(is_show)
end

function CongZhiRankCell:OnFlush()
	for k,v in pairs(self.reward_data) do
		if v then
			self.item_cell_list[k + 1]:SetData(v)
		end
	end
	--如果没有人上榜
	if not next(self.player_data) then
		self.player_name:SetValue("")
		self.is_show:SetValue(false)
	else
		local role_id = self.player_data.user_id
		local function download_callback(path)
			if nil == self.rawimg or IsNil(self.rawimg.gameObject) then
				return
			end
			if self.player_data.user_id ~= role_id then
				return
			end
			local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
			self.rawimg.raw_image:LoadSprite(avatar_path,
			function()
				if self.player_data.user_id ~= role_id then
					return
				end
				self.show_image:SetValue(false)
			end)
		end
		self.player_name:SetValue(self.player_data.user_name)
		CommonDataManager.NewSetAvatar(self.player_data.user_id, self.show_image, self.iconimg, self.rawimg, self.player_data.sex, self.player_data.prof, false,download_callback)
	end
end