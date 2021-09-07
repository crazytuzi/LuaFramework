TipsChouRewardView = TipsChouRewardView or BaseClass(BaseView)
local COL_NUM = 5

function TipsChouRewardView:__init(instance)
	self.ui_config = {"uis/views/tips/rewardtips", "ChouRewardTips"}
	self.item_num = 0
	self.data_list = {}
end

function TipsChouRewardView:ReleaseCallBack()
	for k, v in pairs(self.reward_contain_list) do
		v:DeleteMe()
	end
	self.reward_contain_list = {}
	self.list_view = nil
	self.show_func = nil
	self.func_btn_text = nil
	self.title_text = nil
end

function TipsChouRewardView:CloseCallBack()	
	self.item_num = 0
	self.title_content = ""
	self.func_btn_content = ""
	self.click_func = nil
	self.data_list = {}
end

function TipsChouRewardView:LoadCallBack()
	self.reward_contain_list = {}
	self.list_view = self:FindObj("ListView")
	self:ListenEvent("CloseView", BindTool.Bind(self.Close, self))
	self.show_func = self:FindVariable("ShowFunc")
	self.func_btn_text = self:FindVariable("BtnText")
	self.title_text = self:FindVariable("Title")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsChouRewardView:SetOpenParam(item_list, title_content, func_btn_content, click_func)
	self.item_num = #item_list
	self.title_content = title_content or ""
	self.func_btn_content = func_btn_content or ""
	self.click_func = click_func
	self.data_list = self:ChnageItemList(item_list)
end

function TipsChouRewardView:ChnageItemList(item_list)
	local data_list = {}
	local index = 1
	for i = 1, self.item_num, COL_NUM do
		data_list[index] = {item_list[i], item_list[i+1], item_list[i+2], item_list[i+3], item_list[i+4]}
		index = index +1
	end
	return data_list
end

function TipsChouRewardView:OpenCallBack()
	self:ListenClick()
	self.func_btn_text:SetValue(self.func_btn_content)
	self.title_text:SetValue(self.title_content)
	self.list_view.scroller:ReloadData(0)
end

function TipsChouRewardView:ListenClick()
	self:ClearEvent("ClickFunc")
	self.show_func:SetValue(false)
	if self.click_func then
		self:ListenEvent("ClickFunc", self.click_func)
		self.show_func:SetValue(true)
	end
end

function TipsChouRewardView:GetNumberOfCells()
	if self.item_num % COL_NUM ~= 0 then
		return math.floor(self.item_num / COL_NUM) + 1
	else
		return self.item_num / COL_NUM
	end
end

function TipsChouRewardView:RefreshCell(cell, cell_index)
	local reward_contain = self.reward_contain_list[cell]
	if reward_contain == nil then
		reward_contain = RewardContain.New(cell.gameObject, self)
		self.reward_contain_list[cell] = reward_contain
	end
	cell_index = cell_index + 1
	reward_contain:SetAllItemId(self.data_list[cell_index])
	-- reward_contain:OnFlushAllItem()
end

function TipsChouRewardView:FlushAllCell()
	for k,v in pairs(self.reward_contain_list) do
		v:OnFlushAllItem()
	end
end

----------------------------------------------------------------------------
RewardContain = RewardContain or BaseClass(BaseCell)
function RewardContain:__init()
	self.item_list = {}
	for i = 1, COL_NUM do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("ItemCell_"..i))
	end
end

function RewardContain:SetAllItemId(item_id_list)
	for i = 1, COL_NUM do
		self.item_list[i]:SetData(item_id_list[i])
		self.item_list[i]:SetActive(not (item_id_list[i] == nil))
	end
end

function RewardContain:OnFlushAllItem()
	for i = 1, COL_NUM do
		self.item_list[i]:Flush()
	end
end

function RewardContain:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end