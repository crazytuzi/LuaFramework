KaifuActivityPanelTen = KaifuActivityPanelTen or BaseClass(BaseRender)

function KaifuActivityPanelTen:__init(instance)
	self.cell_list = {}
end

function KaifuActivityPanelTen:LoadCallBack()
	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function KaifuActivityPanelTen:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function KaifuActivityPanelTen:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
end

function KaifuActivityPanelTen:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelTenListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local cfg = KaifuActivityData.Instance:GetLeiJiChongZhiCfg()
	local flag_cfg = KaifuActivityData.Instance:GetLeijiChongZhiFlagCfg()[cfg[data_index + 1].seq]
	cell_item:SetData(cfg[data_index + 1])
	cell_item:ListenClick(BindTool.Bind(self.OnClickGet, self, cfg[data_index + 1].seq, flag_cfg.flag))
end

function KaifuActivityPanelTen:OnClickGet(index, flag)
	local flag = flag or 0
	if flag == 2 then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, index)
		return
	end
	if flag == 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
	end
end

function KaifuActivityPanelTen:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelTen:OnFlush()
	local activity_type = self.cur_type
	if KaifuActivityData.Instance:GetLeiJiChongZhiInfo() == nil then return end

	self.activity_type = activity_type or self.activity_type

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if activity_type == self.temp_activity_type then
		self.list.scroller:RefreshActiveCellViews()
	else
		if self.list.scroller.isActiveAndEnabled then
			self.list.scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = activity_type
end


PanelTenListCell = PanelTenListCell or BaseClass(BaseRender)

local ITEM_NUM = 3

function PanelTenListCell:__init(instance)
	self.title = self:FindVariable("Title")
	self.show_had_get = self:FindVariable("ShowHad")
	self.show_get_btn = self:FindVariable("ShowGetBtn")

	self.gray_get_button = self:FindObj("GetButton")

	self.item_list = {}
	for i = 1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
end

function PanelTenListCell:__delete()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function PanelTenListCell:SetData(data)
	if data == nil then return end
	local grade_index = 0
	local str = string.gsub(data.description, "%[.-%]", function (str)
		local change_str = data[string.sub(str, 2, -2)]
		local leiji_chongzhi_info = KaifuActivityData.Instance:GetLeiJiChongZhiInfo()
		local total_charge_value = leiji_chongzhi_info.total_charge_value or 0
		if total_charge_value < tonumber(change_str) then
			change_str = string.format(Language.Mount.ShowRedStr, change_str)
		end
		return change_str
	end)

	self.title:SetValue(str)
	self.show_had_get:SetValue(data.flag == 0)
	self.show_get_btn:SetValue(data.flag ~= 0)

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_list = {}

	local gift_id = 0
	for k, v in pairs(data.reward_item) do
		local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			gift_id = v.item_id
			local item_gift_list = ItemData.Instance:GetGiftItemList(v.item_id)
			if gift_cfg and gift_cfg.rand_num and gift_cfg.rand_num > 0 then
				item_gift_list = {v}
			end
			for _, v2 in pairs(item_gift_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.item_id)
				if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
					table.insert(item_list, v2)
				end
			end
		else
			table.insert(item_list, v)
		end
	end

	local is_destory_effect = true
	for k, v in pairs(self.item_list) do
		v:SetActive(nil ~= item_list[k])

		if item_list[k] then
			for _, v2 in pairs(data.item_special or {}) do
				if v2.item_id == item_list[k].item_id then
					v:IsDestoryActivityEffect(false)
					v:SetActivityEffect()
					is_destory_effect = false
					break
				end
			end
			if is_destory_effect then
				v:IsDestoryActivityEffect(is_destory_effect)
				v:SetActivityEffect()
			end
			v:SetGiftItemId(gift_id)
			v:SetData(item_list[k])
		end
	end
	self.gray_get_button.button.interactable = data.flag == 2
end

function PanelTenListCell:ListenClick(handler)
	self:ClearEvent("OnClickGet")
	self:ListenEvent("OnClickGet", handler)
end