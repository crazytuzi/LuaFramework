CombineServerChongZhiRank =  CombineServerChongZhiRank or BaseClass(BaseRender)

function CombineServerChongZhiRank:__init()
	self.contain_cell_list = {}
	-- RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)
end

function CombineServerChongZhiRank:__delete()
	if self.contain_cell_list then
		for k,v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end

	self.list_view = nil
	self.rest_time = nil
	self.chongzhi_count = nil
end

function CombineServerChongZhiRank:SetCurTyoe(cur_type)
end

function CombineServerChongZhiRank:LoadCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	-- if self.least_time_timer then
	-- 	CountDown.Instance:RemoveCountDown(self.least_time_timer)
	-- 	self.least_time_timer = nil
	-- end
	-- local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK)
	-- self:SetTime(rest_time)
	-- self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
	-- 		rest_time = rest_time - 1
	-- 	self:SetTime(rest_time)
	-- 	end)

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))

	self.chongzhi_count = self:FindVariable("chongzhi_count")
	self.chongzhi_count:SetValue(HefuActivityData.Instance:GetChongZhiRankNum())

	self.reward_list = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK)
end

function CombineServerChongZhiRank:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function CombineServerChongZhiRank:OpenCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
		self:SetTime(rest_time)
		end)
end

function CombineServerChongZhiRank:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function CombineServerChongZhiRank:OnFlush()
	self.reward_list = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK)
	self.chong_zhi_rank_info = HefuActivityData.Instance:GetChongZhiRankInfo()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(HefuActivityData.Instance:GetChongZhiRankNum())
	end
end

function CombineServerChongZhiRank:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(str)
end

function CombineServerChongZhiRank:GetNumberOfCells()
	return  3
end

function CombineServerChongZhiRank:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell =CombineServerChongZhiRankCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetItemData(self.reward_list)
	-- local rank = ""
	-- local last_rank = self.rank_list[cell_index - 1]
	-- local current_rank = self.rank_list[cell_index]
	-- local is_show = false
	-- if last_rank then
	-- 	if  current_rank - last_rank == 1 then
	-- 		rank = tostring(current_rank)
	-- 		is_show = true
	-- 	else
	-- 		rank = tostring((last_rank + 1).."-"..current_rank)
	-- 	end
	-- else
	-- 	if current_rank == 1 then
	-- 		rank = 1
	-- 		is_show = true
	-- 	else
	-- 		rank = tostring("0-"..current_rank)
	-- 	end
	-- end
	-- contain_cell:SetCostData(self.coset_list[cell_index], rank, is_show)--
	if self.chong_zhi_rank_info and self.chong_zhi_rank_info.user_list then
		contain_cell:SetPlayerData(self.chong_zhi_rank_info.user_list[cell_index]  or {})
	end
	contain_cell:Flush()
end

----------------------------CombineServerChongZhiRankCell---------------------------------
CombineServerChongZhiRankCell = CombineServerChongZhiRankCell or BaseClass(BaseCell)

function CombineServerChongZhiRankCell:__init()
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
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
end

function CombineServerChongZhiRankCell:__delete()
	self.player_name = nil
	self.text = nil
	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function CombineServerChongZhiRankCell:SetPlayerData(playerdata)
	self.player_data = playerdata
end

function CombineServerChongZhiRankCell:SetItemData(data)
	self.reward_data = data
end

function CombineServerChongZhiRankCell:SetIndex(index)
	self.index = index
end

-- function CombineServerChongZhiRankCell:SetCostData(coset_text, rank, is_show)
-- 	local str = string.format(Language.Activity.ChongZhiRank, rank, coset_text)
-- 	self.text:SetValue(str)
-- 	self.is_show:SetValue(is_show)
-- end

function CombineServerChongZhiRankCell:LoadCallBack(user_id, path)
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

function CombineServerChongZhiRankCell:OnFlush()
	self.rawimage_path:SetValue("")
	self.player_name:SetValue("") 

	if self.reward_data == nil then
		return
	end
	
	local data = self.reward_data["reward_item_" .. self.index]
	local item_list = ItemData.Instance:GetGiftItemList(data.item_id)
	if #item_list == 0 then
		item_list[1] = data
	end

	for i = 1, 4 do
		if item_list[i] then
			self.item_cell_list[i]:SetData(item_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	local str = string.format(Language.Activity.ChongZhiRank, self.index, self.reward_data.rank_limit)
	self.text:SetValue(str)
	if self.player_data == nil then return  end
	--如果没有人上榜
	if self.player_data.role_id == 0 then
		self.player_name:SetValue("")
		self.is_show:SetValue(false)
		self.show_image:SetValue(true)
	else
		self.player_name:SetValue(self.player_data.user_name)
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
			if not self.is_show:GetBoolean() then
				return
			end
				AvatarManager.Instance:GetAvatar(self.player_data.role_id, false, BindTool.Bind(self.LoadCallBack, self, self.player_data.role_id))
			-- if avatar_key ~= self.avatar_key then
			-- 	self.avatar_key = avatar_key
			-- 	AvatarManager.Instance:GetAvatar(self.player_data.role_id, false, BindTool.Bind(self.LoadCallBack, self, self.player_data.role_id))
			-- end
		end
	end
end