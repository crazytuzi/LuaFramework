HappyBargainChongZhiRankView =  HappyBargainChongZhiRankView or BaseClass(BaseRender)

function HappyBargainChongZhiRankView:__init()
	self.contain_cell_list = {}
	self.player_data_list = {}
end

function HappyBargainChongZhiRankView:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function HappyBargainChongZhiRankView:LoadCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_DAILY_CHONGZHI_RANK)

	self.rest_time = self:FindVariable("rest_time")
	self.rest_hour = self:FindVariable("RestHour")
	self.rest_min = self:FindVariable("RestMin")
	self.rest_sec = self:FindVariable("RestSecond")
	self.rank_levle = self:FindVariable("rank_levle")
	self.chongzhi_count = self:FindVariable("chongzhi_count")

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	
	self.chongzhi_count:SetValue(HappyBargainData.Instance:GetCrossRAChongzhiRankChongzhiInfo())
	local open_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.CROSS_RAND_ACTIVITY_TYPE_CHONGZHI_RANK)
	self.reward_list, self.coset_list, self.rank_list = HappyBargainData.Instance:GetChongZhiRankInfo(open_day)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local rest_time = HappyBargainData.Instance:GetActEndTime(ACTIVITY_TYPE.CROSS_RAND_ACTIVITY_TYPE_CHONGZHI_RANK)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
		self:SetRestTime(rest_time)
		end)
	HappyBargainCtrl.Instance:SendCrossRandActivityRequest(ACTIVITY_TYPE.CROSS_RAND_ACTIVITY_TYPE_CHONGZHI_RANK)
	HappyBargainCtrl.Instance:SendGetPersonRankListReq(ACTIVITY_TYPE.CROSS_RAND_ACTIVITY_TYPE_CHONGZHI_RANK)
	
end

function HappyBargainChongZhiRankView:SetRestTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(str)
end

function HappyBargainChongZhiRankView:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function HappyBargainChongZhiRankView:FlushChongZhi()
	local player_data_list = HappyBargainData.Instance:GetPersonRankListProtocols().rank_list
	table.sort(player_data_list, SortTools.KeyUpperSorter("total_chongzhi"))
	self.player_data_list = player_data_list

	local role_info = GameVoManager.Instance:GetMainRoleVo()
	if self.rank_levle then
		self.rank_levle:SetValue(Language.Rank.NoInRank)
		for i, v in ipairs(self.player_data_list) do
			if role_info.role_id == v.role_id then
				self.rank_levle:SetValue(i)
				break
			end
		end
	end
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(HappyBargainData.Instance:GetCrossRAChongzhiRankChongzhiInfo())
	end
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
end

function HappyBargainChongZhiRankView:GetNumberOfCells()
	return #self.reward_list
end

function HappyBargainChongZhiRankView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = HappyBargainChongZhiRankViewCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell:SetCostData(self.coset_list[cell_index], self.rank_list[cell_index])
	contain_cell:SetPlayerData(self.player_data_list[cell_index]  or {})
	contain_cell:Flush()
end

----------------------------HappyBargainChongZhiRankViewCell---------------------------------
HappyBargainChongZhiRankViewCell = HappyBargainChongZhiRankViewCell or BaseClass(BaseCell)

function HappyBargainChongZhiRankViewCell:__init()
	self.avatar_key = 0
	self.reward_data = {}
	self.player_name = self:FindVariable("player_name")
	self.player_image = self:FindVariable("player_img")
	self.show_image = self:FindVariable("showimage")
	self.is_show = self:FindVariable("IsShow")
	self.text = self:FindVariable("text")
	self.rawimage_path = self:FindVariable("rawimagePath")
	self.server_id = self:FindVariable("ServerId")
	self.chongzhi_count = self:FindVariable("ChongZhiCount")
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
end

function HappyBargainChongZhiRankViewCell:__delete()
	self.player_name = nil
	self.text = nil
	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function HappyBargainChongZhiRankViewCell:SetRewardItem()
	local item_gift_list = ItemData.Instance:GetGiftItemList(self.reward_data.item_id)
	if not item_gift_list then return end
	local item_num = #item_gift_list < 6 and #item_gift_list or 5
	for i = 1, item_num do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
	
	for k,v in pairs(item_gift_list) do
		if v then
			self.item_cell_list[k]:SetData(v)
		end
	end
end

function HappyBargainChongZhiRankViewCell:SetPlayerData(playerdata)
	self.player_data = playerdata
end

function HappyBargainChongZhiRankViewCell:SetItemData(data)
	self.reward_data = data
	self:SetRewardItem()
end

function HappyBargainChongZhiRankViewCell:SetCostData(coset_text, rank)
	local str = ""
	if rank == 1 then
		str = string.format(Language.Activity.ChongZhiRank1, rank, coset_text)
	else
		str = string.format(Language.Activity.ChongZhiRank, rank, coset_text)
	end
	self.text:SetValue(str)
end

function HappyBargainChongZhiRankViewCell:LoadCallBack(user_id, path)
	if self:IsNil() or self.player_data == nil then
		return
	end

	if user_id ~= self.player_data.role_id then
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

function HappyBargainChongZhiRankViewCell:OnFlush()
	self.rawimage_path:SetValue("")
	--如果没有人上榜
	if not next(self.player_data) then
		self.player_name:SetValue("")
		self.is_show:SetValue(false)
		self.show_image:SetValue(true)
		self.server_id:SetValue("")
		self.chongzhi_count:SetValue("")
	else
		self.is_show:SetValue(true)
		self.player_name:SetValue(self.player_data.role_name)
		self.server_id:SetValue(self.player_data.server_id)
		self.chongzhi_count:SetValue(self.player_data.total_chongzhi)

		-- 协议返回的头像key
		local avatar_key = AvatarManager.Instance:GetAvatarKey(self.player_data.role_id)
		-- 如果没有
		if avatar_key == 0 then
			self.avatar_key = 0
			local bundle, asset = AvatarManager.GetDefAvatar(self.player_data.prof, false, self.player_data.sex)
			self.show_image:SetValue(true)
			self.player_image:SetAsset(bundle, asset)
		else
			self.avatar_key = avatar_key
			AvatarManager.Instance:GetAvatar(self.player_data.role_id, false, BindTool.Bind(self.LoadCallBack, self, self.player_data.role_id))
		end
	end
end