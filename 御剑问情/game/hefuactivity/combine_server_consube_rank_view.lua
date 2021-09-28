CombineServerConsubeRank =  CombineServerConsubeRank or BaseClass(BaseRender)

function CombineServerConsubeRank:__init()
	self.contain_cell_list = {}
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)
end

function CombineServerConsubeRank:__delete()
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
	self.xiaofei_count = nil
end

function CombineServerConsubeRank:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)

    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))

	self.xiaofei_count = self:FindVariable("xiaofei_count")
	self.xiaofei_count:SetValue(HefuActivityData.Instance:GetConsumeRankConsumeGold())
	self.reward_list = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK)
	self.consube_rank_info = HefuActivityData.Instance:GetConsubeRankInfo()
end

function CombineServerConsubeRank:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function CombineServerConsubeRank:ClickReChange()
	ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_youhui)
end

function CombineServerConsubeRank:OnFlush()
	self.reward_list = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK)
	self.consube_rank_info = HefuActivityData.Instance:GetConsubeRankInfo()
	if self.xiaofei_count then
		self.xiaofei_count:SetValue(HefuActivityData.Instance:GetConsumeRankConsumeGold())
	end
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
end

function CombineServerConsubeRank:SetTime(rest_time)
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

function CombineServerConsubeRank:GetNumberOfCells()
	return 3
end

function CombineServerConsubeRank:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell =CombineServerConsubeRankCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetItemData(self.reward_list)
	contain_cell:SetIndex(cell_index)
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
	-- contain_cell:SetCostData(self.coset_list[cell_index], rank, is_show)
	contain_cell:SetPlayerData(self.consube_rank_info.user_list[cell_index]  or {})
	contain_cell:Flush()
end

----------------------------CombineServerConsubeRankCell---------------------------------
CombineServerConsubeRankCell = CombineServerConsubeRankCell or BaseClass(BaseCell)

function CombineServerConsubeRankCell:__init()
	self.avatar_key = 0
	self.reward_data = {}
	self.player_name = self:FindVariable("player_name")
	self.player_image = self:FindVariable("player_img")
	self.is_show = self:FindVariable("IsShow")
	self.text = self:FindVariable("text")
	self.icon_image = self:FindObj("IconImage")
	self.raw_image =self:FindObj("RawImage")
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
end

function CombineServerConsubeRankCell:__delete()
	self.player_name = nil
	self.text = nil
	self.player_image = nil
	self.is_show = nil
	self.icon_image = nil
	self.raw_image = nil
	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function CombineServerConsubeRankCell:SetPlayerData(playerdata)
	self.player_data = playerdata
end

function CombineServerConsubeRankCell:SetItemData(data)
	self.reward_data = data
end

function CombineServerConsubeRankCell:SetIndex(index)
	self.index = index
end

-- function CombineServerConsubeRankCell:SetCostData(coset_text, rank, is_show)
-- 	local str = string.format(Language.Activity.ChongZhiRank, rank, coset_text)
-- 	self.text:SetValue(str)
-- 	self.is_show:SetValue(is_show)
-- end

function CombineServerConsubeRankCell:OnFlush()
	self.player_name:SetValue("")

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

	local str = string.format(Language.HefuActivity.ConsubeRank, self.index, self.reward_data.rank_limit)
	self.text:SetValue(str)

	--如果没有人上榜
	if self.player_data.role_id == 0 then
		self.player_name:SetValue("")
		self.is_show:SetValue(false)
	else
		self.player_name:SetValue(self.player_data.user_name)
		-- 协议返回的头像key
		CommonDataManager.SetAvatar(self.player_data.role_id, self.raw_image, self.icon_image, self.player_image, self.player_data.sex, self.player_data.prof, false)
	end
end