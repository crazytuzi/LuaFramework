SkyMoneyRewardView = SkyMoneyRewardView or BaseClass(BaseView)

function SkyMoneyRewardView:__init()
	self.ui_config = {"uis/views/skymoney_prefab", "SkyMoneyRewardView"}
	self.item_cells = {}
end

function SkyMoneyRewardView:ReleaseCallBack()
	for k, v in pairs(self.item_cells) do
		v.item_cell:DeleteMe()
	end
	self.item_cells = {}
end

function SkyMoneyRewardView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	for i = 1, 6 do
		local item_obj = self:FindObj("Item"..i)
		local item_cell = ItemCell.New(item_obj)
		self.item_cells[i] = {item_obj = item_obj, item_cell = item_cell}
	end

	self:Flush()
end

function SkyMoneyRewardView:OnClickClose()
	self:Close()
	SkyMoneyData.Instance:CloseCallBack()
end

function SkyMoneyRewardView:OnFlush(param_t)
	local item_list = SkyMoneyData.Instance:GetSkyMoneyItemList()
	local bind_gold_num = SkyMoneyData.Instance:GetSkyMoneyGoldNum()
	local index = 0
	if item_list == nil then return end
	for k, v in pairs(self.item_cells) do
		v.item_obj:SetActive(item_list[k] ~= nil)
		if item_list[k] then
			index = k
			v.item_cell:SetData(item_list[k])
		end
	end
	if bind_gold_num > 0 then
		local data = {item_id = 65533, num = bind_gold_num}
		if self.item_cells[index + 1] then
			self.item_cells[index + 1].item_obj:SetActive(true)
			self.item_cells[index + 1].item_cell:SetData(data)
		else
			self.item_cells[index - 1].item_obj:SetActive(true)
			self.item_cells[index - 1].item_cell:SetData(data)
		end
	end
end
