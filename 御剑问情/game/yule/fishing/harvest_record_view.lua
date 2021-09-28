HarvestRecordView = HarvestRecordView or BaseClass(BaseView)

local MAX_ITEM_NUM = 3
function HarvestRecordView:__init()
    self.ui_config = {"uis/views/yuleview_prefab", "HarvestRecordView"}
end

function HarvestRecordView:__delete()

end

function HarvestRecordView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	self.have_besteal_record = nil
	self.show_third_item = nil
	self.list_view = nil
end

function HarvestRecordView:LoadCallBack()
	self.have_besteal_record = self:FindVariable("HaveBeStealRecord")
	self.show_third_item = self:FindVariable("ShowThirdItem")

	self.item_list = {}
	for i = 1, MAX_ITEM_NUM do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item" .. i))
		item_cell:SetData(nil)
		table.insert(self.item_list, item_cell)
	end

	self.list_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickButton", BindTool.Bind(self.ClickButton, self))
end

function HarvestRecordView:GetMaxCellNum()
	return #self.list_data
end

function HarvestRecordView:RefreshCellList(cell, data_index)
	data_index = data_index + 1
	local record_cell = self.cell_list[cell]
	if nil == record_cell then
		record_cell = NewBeStealRecordCell.New(cell.gameObject)
		self.cell_list[cell] = record_cell
	end
	record_cell:SetData(self.list_data[data_index])
end


function HarvestRecordView:CloseWindow()
	self:Close()
end

function HarvestRecordView:ClickButton()
	self:Close()
	if #self.list_data > 0 then
		ViewManager.Instance:Open(ViewName.BeStealRecordView)
	end
end

function HarvestRecordView:OpenCallBack()
	self:Flush()
end

function HarvestRecordView:CloseCallBack()
	
end

function HarvestRecordView:OnFlush()
	local reward_info = FishingData.Instance:GetShouFishRewardInfo()
	if nil ~= reward_info then
		--设置第一个格子
		local exp = reward_info.exp
		local item = self.item_list[1]
		item:SetData({item_id = ResPath.CurrencyToIconId.exp, num = exp, is_bind = 0})

		--设置第二个格子
		local rune_score = reward_info.rune_score
		item = self.item_list[2]
		item:SetData({item_id = ResPath.CurrencyToIconId.rune_jinghua, num = rune_score, is_bind = 0})

		local item_id = reward_info.item_id
		if item_id > 0 then
			--设置第三个格子
			self.show_third_item:SetValue(true)
			item = self.item_list[MAX_ITEM_NUM]
			item:SetData({item_id = item_id, num = reward_info.item_num})
		else
			self.show_third_item:SetValue(false)
		end
	end

	local steal_general_info = FishingData.Instance:GetStealGeneralInfoByQuailty(reward_info.fish_quality)
	if #steal_general_info <= 0 then
		self.have_besteal_record:SetValue(false)
	else
		self.have_besteal_record:SetValue(true)
		self.list_data = steal_general_info
		self.list_view.scroller:ReloadData(0)
	end
end


---------------NewBeStealRecordCell----------------------------
NewBeStealRecordCell = NewBeStealRecordCell or BaseClass(BaseRender)

function NewBeStealRecordCell:__init()
	self.name = self:FindVariable("Name")
	self.fish_name = self:FindVariable("FishName")
	-- self.count = self:FindVariable("Count")
end

function NewBeStealRecordCell:__delete()

end

function NewBeStealRecordCell:SetData(data)
	if nil == data then
		return
	end

	-- self.count:SetValue(1)
	self.name:SetValue(data.owner_name)
	local fish_info = FishingData.Instance:GetFishInfoByQuality(data.be_steal_quality)
	if nil ~= fish_info then
		local name = ToColorStr(fish_info.fish_name, FISH_NAME_COLOR[data.be_steal_quality])
		self.fish_name:SetValue(name)
	end
end