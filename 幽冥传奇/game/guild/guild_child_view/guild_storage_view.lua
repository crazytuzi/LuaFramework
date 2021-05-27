-- 行会仓库
local GuildStorageView = GuildStorageView or BaseClass(SubView)

function GuildStorageView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"guild_ui_cfg", 13, {0}},
	}
end

function GuildStorageView:LoadCallBack()
	self:CreateStorageGrid()
	self:CreateCheckBox("show_exchange", self.node_t_list.layout_box_show_exchange.node)
	self:CreateCheckBox("show_self_prof", self.node_t_list.layout_box_show_self_prof.node)
	self.event_proxy = EventProxy.New(GuildData.Instance, self)
	self.event_proxy:AddEventListener(GuildData.GuildInfoChange, BindTool.Bind(self.OnFlushStorageView, self))
	self.event_proxy:AddEventListener(GuildData.StorageListChange, BindTool.Bind(self.OnFlushStorageView, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function GuildStorageView:ReleaseCallBack()
	self.storage_ex_parts = nil

	if self.bag_grid ~= nil then
		self.bag_grid:DeleteMe()
		self.bag_grid = nil
	end

	if self.bag_radio ~= nil then
		self.bag_radio:DeleteMe()
		self.bag_radio = nil
	end

	if self.guild_storage_grid ~= nil then
		self.guild_storage_grid:DeleteMe()
		self.guild_storage_grid = nil
	end

	if self.guild_storage_radio ~= nil then
		self.guild_storage_radio:DeleteMe()
		self.guild_storage_radio = nil
	end

	if self.destroy_storage_alert ~= nil then
		self.destroy_storage_alert:DeleteMe()
		self.destroy_storage_alert = nil
	end

	if self.select_list_layout_model ~= nil then
		self.select_list_layout_model:removeFromParent()
		self.select_list_layout_model = nil
	end
end

function GuildStorageView:ShowIndexCallBack()
	self:OnFlushStorageView()
end

function GuildStorageView:OnFlushStorageView()
	self:UpdataGuildStorageGrid()
	-- self:FlushStorageExParts()

	local guild_info = GuildData.Instance:GetGuildInfo()
	local contribution = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_CON)
	local storage_list = GuildData.Instance:GetStorageList()
	local list = {}
	local order = 0

	for k, v in pairs(storage_list) do
		local judge_1 = true
		local judge_2 = true
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			if self.check_box_list["show_exchange"].status == true then
				judge_1 = contribution >= item_cfg.contri
			end
			if self.check_box_list["show_self_prof"].status == true then
				for k_2,v_2 in pairs(item_cfg.conds) do
					if v_2.cond == ItemData.UseCondition.ucJob then
						judge_2 = v_2.value == RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
					end
				end
			end
		end
		if judge_1 and judge_2 then
			list[order] = v
			order = order + 1
		end
	end
	self.guild_storage_grid:SetDataList(list)
	self.node_t_list.lbl_guild_stoare_contribution.node:setString(contribution)
	self:SetGuildStorageData()
end

function GuildStorageView:ItemDataListChangeCallback(vo)
	self:SetGuildStorageData()
end

function GuildStorageView:CreateCheckBox(key, parent)
	self.check_box_list = self.check_box_list or {}

	self.check_box_list[key] = {}
	self.check_box_list[key].status = false
	self.check_box_list[key].node = XUI.CreateImageView(20, 20, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	parent:addChild(self.check_box_list[key].node, 10)
	XUI.AddClickEventListener(parent, BindTool.Bind2(self.OnClickSelectBoxHandler, self, key), true)
end

function GuildStorageView:OnClickSelectBoxHandler(key)
	if self.check_box_list == nil or self.check_box_list[key] == nil then return end

	self.check_box_list[key].status = not self.check_box_list[key].status
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)

	self:OnFlushStorageView()
	-- if key == "show_exchange" then
	-- 	self:Flush(TabIndex.guild_storage)
	-- elseif key == "show_self_prof" then
	-- 	self:Flush(TabIndex.guild_storage)
	-- end
end

function GuildStorageView:CreateStorageGrid()
	if self.bag_grid == nil then
		self.bag_grid = BaseGrid.New()
		self.bag_grid:SetGridName(GRID_TYPE_BAG)
		self.bag_grid:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
		local ph_baggrid = self.ph_list.ph_bag_grid
		local grid_node = self.bag_grid:CreateCells({w = ph_baggrid.w, h = ph_baggrid.h, cell_count = 80, col = 4, row = 5})
		grid_node:setAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_guild_storage.node:addChild(grid_node, 100)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		-- self.bag_grid:SetDataList(BagData.Instance:GetItemDataList())
		self.bag_grid:SetSelectCallBack(BindTool.Bind2(self.SelectCellCallBack, self, EquipTip.FROM_BAG_ON_GUILD_STORAGE))
		self:SetGuildStorageData()

		-- self.bag_radio = RadioButton.New()
		-- self.bag_radio:SetRadioButton(self.node_t_list.layout_bag_grid_page)
		-- self.bag_radio:SetSelectCallback(BindTool.Bind1(self.BagRadioHandler, self))
		-- self.bag_grid:SetRadioBtn(self.bag_radio)
	end
	self.node_t_list.layout_bag_grid_page.node:setVisible(false)

	if self.guild_storage_grid == nil then
		self.guild_storage_grid = BaseGrid.New()
		self.guild_storage_grid:SetGridName("GuildStorage")
		self.guild_storage_grid:SetPageChangeCallBack(BindTool.Bind1(self.OnStoragePageChange, self))
		local ph_baggrid = self.ph_list.ph_guild_grid
		local level = GuildData.Instance:GetGuildInfo().cur_guild_level
		local max_count = GuildData.GetGuildMaxDepotBagCount(level)
		max_count = max_count >= 20 and max_count or 20
		local page = math.ceil(max_count / 20)
		local grid_node = self.guild_storage_grid:CreateCells({w = ph_baggrid.w, h = ph_baggrid.h, cell_count = max_count, col = 4, row = 5})
		grid_node:setAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_guild_storage.node:addChild(grid_node, 100)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.guild_storage_grid:SetSelectCallBack(BindTool.Bind2(self.SelectCellCallBack, self, EquipTip.FROM_STORAGE_ON_GUILD_STORAGE))

		-- local radio_btn_t = {}
		-- for i = 1, page do
		-- 	table.insert(radio_btn_t, "")
		-- end
		-- local space_interval = math.min((344 - page * 33) / (page + 2), 33)
		-- local off_x = 351 + (344 - (page - 1) * space_interval - 33 * page) / 2
		-- self.guild_storage_radio = Tabbar.New()
		-- self.guild_storage_radio:CreateWithNameList(self.node_t_list.layout_guild_storage.node, off_x, 80,
		-- 	BindTool.Bind1(self.StorageRadioHandler, self), 
		-- 	radio_btn_t, false, ResPath.GetGuild("toggle_storage"))
		-- self.guild_storage_radio:SetSpaceInterval(space_interval)
		-- self.guild_storage_grid:SetRadioBtn(self.guild_storage_radio)
	end
end

function GuildStorageView:SetGuildStorageData()
	if self.bag_grid then
		local bag_list = GuildData.Instance:GetDonateEquipList()
		self.bag_grid:SetDataList(bag_list)
	end
end

function GuildStorageView:UpdataGuildStorageGrid()
	local level = GuildData.Instance:GetGuildInfo().cur_guild_level
	local max_count = GuildData.GetGuildMaxDepotBagCount(level)
	local page = math.ceil(max_count / 20)
	local page_count = self.guild_storage_grid:GetPageCount()
	if page_count ~= page then
		if page_count < page then
			self.guild_storage_grid:ExtendGrid(max_count)
		else
			for i = page + 1, page_count do
				self.guild_storage_grid:RemoveLastPage()
			end		
		end
		self.guild_storage_grid:ChangeToPage(1)
		local radio_btn_t = {}
		for i = 1, page do
			table.insert(radio_btn_t, "")
		end
		local space_interval = math.min((344 - page * 26) / (page + 2), 26)
		-- local space_interval = 0
		local off_x = 355 + (344 - (page - 1) * space_interval - 26 * page) / 2
		-- self.guild_storage_radio:SetNameList(radio_btn_t, false, ResPath.GetGuild("toggle_storage"))
		-- self.guild_storage_radio:SetPosition(off_x, 80)
		-- self.guild_storage_radio:SetSpaceInterval(space_interval)
	end
end

function GuildStorageView:SelectCellCallBack(form_view, cell)
	if cell == nil then
		return
	end

	local cell_data = cell:GetData()
	if cell_data and next(cell_data) then
		TipCtrl.Instance:OpenItem(cell_data, form_view)				--打开tip,提示使用
	end
end

function GuildStorageView:OnBagPageChange(grid_view, cur_page_index, prve_page_index)
end

function GuildStorageView:BagRadioHandler(index)
	if nil ~= self.bag_grid then
		self.bag_grid:ChangeToPage(index)
	end
end

function GuildStorageView:OnStoragePageChange(grid_view, cur_page_index, prve_page_index)
end

function GuildStorageView:StorageRadioHandler(index)
	if nil ~= self.guild_storage_grid then
		self.guild_storage_grid:ChangeToPage(index)
	end
end

return GuildStorageView