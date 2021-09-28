LevelRewardView = LevelRewardView or BaseClass(BaseRender)

function LevelRewardView:__init()
	self.cell_list = {}
	self.scroller_data = WelfareData.Instance:GetLevelRewardList()
	self:InitSroller()
end

function LevelRewardView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function LevelRewardView:InitSroller()
	self.scroller = self:FindObj("Scroller")
	local scroller_delegate = self.scroller.page_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)
end

function LevelRewardView:NumberOfCellsDel()
	return #self.scroller_data
end

function LevelRewardView:CellRefreshDel(index, cellObj)
	index = index + 1
	local reward_cell = self.cell_list[cellObj]
	if not reward_cell then
		reward_cell = LevelRewardItemCell.New(cellObj)
		self.cell_list[cellObj] = reward_cell
	end
	reward_cell:SetData(self.scroller_data[index])
end

function LevelRewardView:Flush()
	GlobalTimerQuest:AddDelayTimer(function()
		self.scroller_data = WelfareData.Instance:GetLevelRewardList()
		if self.scroller.list_view.isActiveAndEnabled then
			local function loadcomplete()
				self.scroller.list_view:JumpToIndex(0)
			end
			self.scroller.list_view:Reload(loadcomplete)
		end
	end, 0)
end

-----------------------LevelRewardItemCell---------------------------------
LevelRewardItemCell = LevelRewardItemCell or BaseClass(BaseCell)

function LevelRewardItemCell:__init()

	self.item_cell_list = {}
	self.item_list = self:FindObj("ItemList")

	local child_count = self.item_list.transform.childCount
	for i = 0, child_count - 1 do
		local child_item_obj = self.item_list.transform:GetChild(i).gameObject
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(child_item_obj)
		item_cell:SetData()
		table.insert(self.item_cell_list, item_cell)
	end

	self.level = self:FindVariable("Level")						--等级
	self.left_count = self:FindVariable("LeftCount")			--剩余个数
	self.have_left_count = self:FindVariable("HaveLeftCount")	--是否显示剩余个数
	self.is_get = self:FindVariable("IsGet")					--是否已领取
	self.is_reach = self:FindVariable("IsReach")				--是否达成
	self.is_all_get = self:FindVariable("IsAllGet")				--是否已领完

	self:ListenEvent("ClickGet", BindTool.Bind(self.ClickGet, self))
end

function LevelRewardItemCell:__delete()
	for k, v in ipairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function LevelRewardItemCell:ClickGet()
	WelfareCtrl.Instance:SendGetLevelReward(self.data.level)
end

function LevelRewardItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	local level = self.data.level
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.level < level then
		self.is_reach:SetValue(false)
	else
		self.is_reach:SetValue(true)
	end
	self.level:SetValue(level)

	local index = self.data.index
	local get_flag = WelfareData.Instance:GetLevelRewardFlag(index)
	if get_flag == 1 then
		self.is_get:SetValue(true)
	else
		self.is_get:SetValue(false)
	end

	local has_get_count = WelfareData.Instance:GetHasGetCountByIndex(index)
	if self.data.is_limit_num == 1 then
		self.have_left_count:SetValue(true)
		local left_count = self.data.limit_num - has_get_count
		left_count = left_count < 0 and 0 or left_count
		self.left_count:SetValue(left_count)
		if left_count == 0 then
			self.is_all_get:SetValue(true)
		else
			self.is_all_get:SetValue(false)
		end
	else
		self.is_all_get:SetValue(false)
		self.have_left_count:SetValue(false)
	end

	local reward_item_list = self.data.reward_item[0]

	local gift_reward_list = ItemData.Instance:GetGiftItemListByProf(reward_item_list.item_id)
	for k, v in ipairs(self.item_cell_list) do
		local reward_item_data = gift_reward_list[k]
		if reward_item_data then
			v:SetGiftItemId(reward_item_list.item_id)
			v:SetActive(true)
			v:SetData(reward_item_data)

			--第一个物品特殊展示(250级开始显示)
			if k == 1 then
				if self.data.level >= 200 then
					-- local itme_cfg = ItemData.Instance:GetItemConfig(reward_item_data.item_id)
					v:ShowSpecialEffect(true)
					local bunble, asset = ResPath.GetItemActivityEffect()
					v:SetSpecialEffect(bunble, asset)
				else
					v:ShowSpecialEffect(false)
				end
			end
		else
			v:SetActive(false)
		end
	end
end