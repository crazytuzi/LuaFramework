WantEquipView = WantEquipView or BaseClass(BaseView)

function WantEquipView:__init()
	self.ui_config = {"uis/views/chatview_prefab", "WantEquipView"}
	self.play_audio = true

	self.equip_cell = {}
	self.select_data = nil
end

function WantEquipView:__delete()

end

function WantEquipView:ReleaseCallBack()
	for k,v in pairs(self.equip_cell) do
		v:DeleteMe()
	end
	self.equip_cell = {}
	self.equip_list = nil
end

-------------------回调---------------------
function WantEquipView:LoadCallBack()
	-- 创建抽奖网格
	do
		self.equip_list = self:FindObj("ListView")
		local list_delegate = self.equip_list.page_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
		self.equip_list.list_view:JumpToIndex(0)
		self.equip_list.list_view:Reload()
	end

	-- 注册事件
	self:RegisterAllEvents()
end

-- 注册所有所需事件
function WantEquipView:RegisterAllEvents()
	self:ListenEvent("OnClickCloseButton",BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickWantEquip",BindTool.Bind(self.OnClickWantEquip, self))
end

function WantEquipView:OpenCallBack()
	self:Flush()
end

function WantEquipView:CloseCallBack()
	self.select_data = nil
end

function WantEquipView:OnClickWantEquip()
	if nil == self.select_data then
		TipsCtrl.Instance:ShowSystemMsg(Language.Equip.XuanzeZhuangBei)
		return
	end
	local dec = Language.Chat.WantEquipDec[math.random(1, #Language.Chat.WantEquipDec)] or ""
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv)
	dec = string.format(dec, self.select_data.item_id, max_order, "{face;" .. string.format("%03d", math.random(1, 40)) .. "}")
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, dec, CHAT_CONTENT_TYPE.TEXT)
	self:Close()
end

function WantEquipView:GetNumberOfCells()
	return 10
end

function WantEquipView:RefreshCell(index, cellObj)
	-- 构造Cell对象.

	local grid_index = math.floor(index / 5) * 5 + (5 - index % 5)
	local cell = self.equip_cell[grid_index]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		self.equip_cell[grid_index] = cell
		cell:SetToggleGroup(self.equip_list.toggle_group)
	end
	self:SetData(cell, grid_index)
	cell:SetHighLight(true)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell))
end

function WantEquipView:HandleBagOnClick(cell)
	if cell and cell:GetData() then
		self.select_data = cell:GetData()
	end
end

function WantEquipView:SetData(cell, index)
	local sub_type = EquipData.GetEquipSubtype(index - 1) or 0
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv)
	local cfg = EquipData.Instance:GetOrderEquip(prof, max_order, sub_type, 5)
	if cfg then
		local data = {item_id = cfg.id, num = 1}
		cell:SetData(data)
		if self.select_data == nil then
			local equip = EquipData.Instance:GetGridData(index - 1) or {}
			local item_id = equip.item_id or 0
			local equip_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")[item_id]
			if equip_cfg == nil or equip_cfg.order < max_order or equip_cfg.color < 5 then
				self.select_data = data
				cell:SetToggle(true)
			end
		end
	else
		cell:SetData({})
	end
end
-- 刷新
function WantEquipView:OnFlush()
	for k,v in pairs(self.equip_cell) do
		self:SetData(v, k)
	end
end