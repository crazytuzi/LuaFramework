------------------------------------------------------------
-- 回收
------------------------------------------------------------
RecycleView = RecycleView or BaseClass(BaseView)

function RecycleView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetBag("titile_melting")
	self.texture_path_list[1] = 'res/xui/bag.png'
	self.texture_path_list[2] = 'res/xui/vip.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"bag_ui_cfg", 4, {0}},
		-- {"bag_ui_cfg", 5, {0}, false},
		{"common_ui_cfg", 2, {0}},
	}

	self.recycle_item = {}

	self.tab_index = 1
	self.need_jump = true -- 需要至顶部
end

function RecycleView:__delete()
end

function RecycleView:ReleaseCallBack()
	self.recycle_eff = nil
	self.jifen_eff = nil
	self.eff_list = nil

	if nil ~= self.recycle_grid then
		self.recycle_grid:DeleteMe()
		self.recycle_grid = nil
	end

	if nil ~= self.spe_grid then
		self.spe_grid:DeleteMe()
		self.spe_grid = nil
	end

	if nil ~= self.spe_item_grid then
		self.spe_item_grid:DeleteMe()
		self.spe_item_grid = nil
	end

	if self.re_tabbar then
		self.re_tabbar:DeleteMe()
		self.re_tabbar = nil
	end

	if self.top_rey_num then
		self.top_rey_num:DeleteMe()
		self.top_rey_num = nil
	end

	if self.top_jf_num then
		self.top_jf_num:DeleteMe()
		self.top_jf_num = nil
	end

	if self.melting_view then
		self.melting_view:DeleteMe()
		self.melting_view = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if nil ~= self.timer then
		GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
		self.timer = nil
	end
	
	self.tab_index = 1
end

function RecycleView:LoadCallBack(index, loaded_times)
	self:CreateRecycleGrid()
	self:CreateSpecialGrid()
	self:StorageTabbar()
	self:CreateMeltingList()
	self:CreateRewardCells()
	XUI.AddClickEventListener(self.node_t_list.btn_melting.node, BindTool.Bind(self.OnClickRecycleAssureHandler, self))
	XUI.AddClickEventListener(self.node_t_list.btn_special.node, BindTool.Bind(self.OnClickSpericalRecycle, self))

	EventProxy.New(BlessingData.Instance, self):AddEventListener(BlessingData.FORTUNE_DATA, BindTool.Bind(self.OnBagFortuneData, self))
	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.WEAR_HOUSE_DATA_CHANGE, BindTool.Bind(self.RecycleChange, self))

	local bag_data_proxy = EventProxy.New(BagData.Instance, self)
	bag_data_proxy:AddEventListener(BagData.RECYCLE_LIST_CHANGE, BindTool.Bind(self.OnRecycleListChange, self))
	bag_data_proxy:AddEventListener(BagData.RECYCLE_SUCCESS, BindTool.Bind(self.OnRecycleSuccess, self))
	bag_data_proxy:AddEventListener(BagData.BAG_MELTING_CHESS_CHANGE, BindTool.Bind(self.RecycleChange, self))
	bag_data_proxy:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.RecycleChange, self))--监听背包变化

	--更新回收数据
	bag_data_proxy:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.Flush, self))

	-- 重启运势
	local ph_txt = self.ph_list.ph_bless_txt
	self.txt_share_pre = RichTextUtil.CreateLinkText("重启运势", 18, COLOR3B.GREEN)
	self.txt_share_pre:setPosition(ph_txt.x, ph_txt.y)
	XUI.AddClickEventListener(self.txt_share_pre, BindTool.Bind(self.OnOpenBless, self, 1), true)
	self.node_t_list.layout_melting.node:addChild(self.txt_share_pre, 100)
end

function RecycleView:StorageTabbar()
	if nil == self.re_tabbar then
		self.re_tabbar = Tabbar.New()
		self.re_tabbar:SetTabbtnTxtOffset(2, 12)

		self.re_tabbar:CreateWithNameList(self.node_t_list.layout_melting.node, -80, 570, BindTool.Bind(self.TabSelectCellBack, self),
			Language.Bag.TabGroup2, true, ResPath.GetCommon("toggle_110"), 25, true)
	end
end

function RecycleView:CreateMeltingList()
	local ph = self.ph_list.ph_recycle_list
	self.melting_view = ListView.New()
	self.melting_view:Create(ph.x, ph.y, ph.w, ph.h, nil, MeltingListRender, nil, nil, self.ph_list.ph_recycle_item)
	self.node_t_list.layout_melting.layout_add_melting.node:addChild(self.melting_view:GetView(), 10)
	self.melting_view:SetItemsInterval(1)
	self.melting_view:SetMargin(1)

	self.melting_view:JumpToTop(true)
end

function RecycleView:TabSelectCellBack(index)
	self.tab_index = index
	BagData.Instance:RecycleStorageChree(index)
	BagData.Instance:InitRecycleList()
	if self.tab_index == 3 then
		self:FlushSpeGrid()
	end
	
	self.need_jump = true

	self:Flush()
end

function RecycleView:FlushSpeGrid()
	BagData.Instance:GetDecomeData(BagData.Instance:GetSpecialEqip())
	local choice_data = BagData.Instance:GetSpeData()

	self.spe_grid:SetDataList(choice_data)
	local page_count = math.floor((#choice_data + 1) / 25) + 1
	local max_count = page_count* 25
	self.spe_grid:ExtendGrid(max_count)
end

function RecycleView:OnOpenBless()
	ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView.Drop.FortureBoss)
end

function RecycleView:RecycleChange()
	BagData.Instance:InitRecycleList()
	if self.tab_index == 3 then
		self:FlushSpeGrid()
	end
	self:FlushData()
end

function RecycleView:CreateRewardCells()
	self.cell_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_item_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_melting.layout_add_melting.node:addChild(cell:GetView(), 10)
		table.insert(self.cell_list, cell)
	end
end

function RecycleView:OnBagFortuneData()
	local type = BlessingData.Instance:GetFortuneType()
	type = type == 0 and 1 or type

	local txt = Language.Blessing.RecycleAdd[1] .. Language.Blessing.FortuneType[type] .. "  " .. Language.Blessing.RecycleAdd[2] .. Fortunecfg.lucks[type].RecoveryAdditions/10000*100 .. "%"
	self.node_t_list.txt_vip_add.node:setString(txt)
end

function RecycleView:OnFlush(param_t, index)
	self.node_t_list.layout_special_equ.node:setVisible(self.tab_index == 3)
	self.node_t_list.layout_add_melting.node:setVisible(self.tab_index ~= 3)
	self.txt_share_pre:setVisible(self.tab_index ~= 3)

	self:FlushData()
end

function RecycleView:FlushData()
	if self.tab_index ~= 3 then
		local data = BagData.Instance:RevertTypeEquip(BagData.Instance:GetRecycleChess())
		self.recycle_grid:SetDataList(data)
		self.recycle_item = data

		local list = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.recycle_lev_limit or {}
		self.melting_view:SetDataList(list)
		if self.need_jump then
			self.melting_view:JumpToTop(true)
			self.need_jump = false
		end

		local reward_list = BagData.Instance:GetRecycle(data)
		local rew_list = {}
		for k, v in pairs(reward_list) do
			local vo = {
				item_id = k, 
				num = v,
			}
			table.insert(rew_list, vo)
		end

		for k1, v1 in pairs(self.cell_list) do
			if nil ~= rew_list[k1] then
				v1:SetData(rew_list[k1])
			else
				v1:SetData(nil)
			end
		end
		self:OnBagFortuneData()
	else
		local choice_data, item_list = BagData.Instance:GetSpeData()
		local list = {}
		for k1, v1 in pairs(item_list) do
			local vo = {
				item_id = k1, 
				num = v1,
			}
			table.insert(list, vo)
		end
		if not list[0] and list[1] then
			list[0] = table.remove(list, 1)
		end
		self.spe_item_grid:SetDataList(list)
	end
end

function RecycleView:PlaySuccesAct()
	local list = self.recycle_grid:GetDataList()
	local item_len = #self.recycle_item > BaseEquipMeltingConfig.limitCount and BaseEquipMeltingConfig.limitCount or #self.recycle_item+1
	if item_len-1 == 0 and next(self.recycle_item) ~= nil then 
		item_len = 1
	elseif next(self.recycle_item) == nil then
		return
	end

	self.eff_list = self.eff_list or {}
	for i = 0, item_len-1 do
		if self.eff_list[i] then
			local path, name = ResPath.GetEffectUiAnimPath(1140)
			self.eff_list[i]:setAnimate(path, name, 1, FrameTime.Effect, false)
		else
			
			if self.recycle_grid
			and self.recycle_grid.GetAllCell
			and self.recycle_grid:GetAllCell()
			and self.recycle_grid:GetAllCell()[i]
			and self.recycle_grid:GetAllCell()[i].GetView
			and self.recycle_grid:GetAllCell()[i]:GetView()
			then
				local parent = self.recycle_grid:GetAllCell()[i]:GetView()
				self.eff_list[i] = RenderUnit.CreateEffect(1140, parent, 100, nil, 1, 40, 40)
			end
		end
	end

	if self.recycle_eff then
		self.recycle_eff:setVisible(true)
		local path, name = ResPath.GetEffectUiAnimPath(1141)
		self.recycle_eff:setAnimate(path, name, 1, FrameTime.Effect, false)
	else
		self.recycle_eff = RenderUnit.CreateEffect(1141, self.node_t_list.layout_melting.node, 100, nil, 1, 500, 400)
	end

	if self.jifen_eff then
		self.jifen_eff:setVisible(true)
		local path, name = ResPath.GetEffectUiAnimPath(621)
		self.jifen_eff:setAnimate(path, name, 1, FrameTime.Effect, false)
	else
		self.jifen_eff = RenderUnit.CreateEffect(621, self.node_t_list.layout_melting.node, 100, nil, 1, 500, 300)
	end

	if self.top_rey_num == nil then
		local rey_num = NumberBar.New()
		rey_num:SetGravity(NumberBarGravity.Center)
		rey_num:SetRootPath(ResPath.GetVipResPath("vip_level_num_"))
		rey_num:SetPosition(310, 95)
		rey_num:SetSpace(-1)
		rey_num:SetNumber(0)
		self.recycle_eff:addChild(rey_num:GetView(), 101, 101)
		rey_num:GetView():setVisible(true)
		self.top_rey_num = rey_num
	end
	self.top_rey_num:SetNumber(BagData.Instance:GetRecycle(self.recycle_item)[493])

	if self.top_jf_num == nil then
		local jf_num = NumberBar.New()
		jf_num:SetGravity(NumberBarGravity.Center)
		jf_num:SetRootPath(ResPath.GetVipResPath("vip_level_num_"))
		jf_num:SetPosition(310, 95)
		jf_num:SetSpace(-1)
		jf_num:SetNumber(0)
		self.jifen_eff:addChild(jf_num:GetView(), 101, 101)
		self.top_jf_num = jf_num
	end
	self.top_jf_num:SetNumber(BagData.Instance:GetRecycle(self.recycle_item)[2096])

	if nil == self.timer then
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SecTime, self), 1)
	end
end

function RecycleView:SecTime()
	self.recycle_eff:setVisible(false)
	self.jifen_eff:setVisible(false)

	GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
	self.timer = nil
end

function RecycleView:ShowIndexCallBack(index)
	self.need_jump = true
	self.re_tabbar:SelectIndex(BagData.Instance:GetRecycleType())
	self:Flush()
end

function RecycleView:OnRecycleSuccess()
	self:PlaySuccesAct()
	BagData.Instance:InitRecycleList()
	if self.tab_index == 3 then
		self:FlushSpeGrid()
	end
	self:FlushData()
end

function RecycleView:OnRecycleListChange()
	self:Flush()
end

function RecycleView:OnClickRecycleAssureHandler()
	local list = {}
	local list_index = 1
	local limit_count = BaseEquipMeltingConfig and BaseEquipMeltingConfig.limitCount or 50
	for k, v in pairs(self.recycle_item) do
		if list_index <= limit_count then
			if v.series then
				list[list_index] = v.series
				list_index = list_index + 1
			end
		else
			break
		end
	end

	local index = BagData.Instance:GetRecycleType()
	BagCtrl.SendBagRecycleReq(index, list)
end

function RecycleView:OnClickSpericalRecycle()
	local list = {}
	local list2 = {}
	local list_index = 1
	local limit_count = 25
	local cell_list = self.spe_grid:GetAllCell()
	local basis_resolve_cfg = BagData.Instance:GetBasisResolveCfg()
	for index = 0, #cell_list do
		if list_index <= limit_count then
			local data = cell_list[index] and cell_list[index]:GetData() or {}
			if next(data) then
				if data.choice == 1 then
					if basis_resolve_cfg[data.item_id or 0] then
						local cur_cfg = basis_resolve_cfg[data.item_id or 0]
						local compose_index = cur_cfg.index or 0
						list2[compose_index] = (list2[compose_index] or 0) + 1
					elseif data.series then
						list[list_index] = data.series
						list_index = list_index + 1
					end
				end
			else
				-- 数据为空时停止循环
				break
			end
		else
			-- 超出上限时,停止循环
			break
		end
	end

	if next(list) then
		BagCtrl.SendBagRecycleReq(1, list)
	end

	if next(list2) then
		for compose_index, compose_num in pairs(list2) do
			local is_onekey_compose = compose_num > 1 and 1 or 0
			BagCtrl.SendComposeItem(3, 1, compose_index, is_onekey_compose, compose_num)
		end
	end
end

function RecycleView:CreateRecycleGrid()
	self.recycle_grid = BaseGrid.New()
	self.recycle_grid:SetGridName(GRID_TYPE_BAG)
	
	local ph_baggrid = self.ph_list.ph_melting_list
	local grid_node = self.recycle_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count = 50, col=5, row=5, direction = ScrollDir.Vertical})
	grid_node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_add_melting.node:addChild(grid_node, 100)
	grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
	self.recycle_grid:SetSelectCallBack(BindTool.Bind1(self.SelectRecycleCellCallBack, self))
end

function RecycleView:CreateSpecialGrid()
	if self.spe_grid == nil then
		self.spe_grid = BaseGrid.New()
		self.spe_grid:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
		self.spe_grid:SetIsMultiSelect(true)
		-- self.spe_grid:SetCreateCallback(BindTool.Bind(self.SpeGridCreateCallback, self))

		local ph_baggrid = self.ph_list.ph_special_list
		local grid_node = self.spe_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, itemRender = RecycleRender, direction = ScrollDir.Vertical, cell_count= 25, col = 5, row = 5,ui_config = self.ph_list.ph_spe_item})
		grid_node:setAnchorPoint(0.5, 0.5)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.node_t_list.layout_special_equ.node:addChild(grid_node, 100)
		self.spe_grid:SetSelectCallBack(BindTool.Bind1(self.SelectSpegridCallBack, self))
		BagData.Instance:GetDecomeData(BagData.Instance:GetSpecialEqip())
	end

	self.spe_item_grid = BaseGrid.New()
	self.spe_item_grid:SetGridName(GRID_TYPE_RECYCLE_BAG)
	local ph_baggrid = self.ph_list.ph_spe_item_list
	local grid_node = self.spe_item_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count=16, col=4, row=4, itemRender = BagCell, direction = ScrollDir.Vertical})
	grid_node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_special_equ.node:addChild(grid_node, 100)
	grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
	self.spe_item_grid:SetIsMultiSelect(true)
	self.spe_item_grid:SetSelectCallBack(BindTool.Bind1(self.SelectItemCellCallBack, self))
end

function RecycleView:SelectSpegridCallBack(cell)
	local data = cell:GetData()
	local index = cell:GetIndex()
	if BagData.Instance:GetBasisSelectCount() > 25 then
	else
		if type(data) == "table" then
			BagData.Instance:SetIsChoiceData(data.choice, index)
			self:Flush()
		end
	end
end


function RecycleView:SelectItemCellCallBack(cell)
	if cell == nil then
		return
	end
end

function RecycleView:OnBagPageChange(grid_view, cur_page_index, prve_page_index)
	-- self.bag_index = cur_page_index
end

function RecycleView:SelectRecycleCellCallBack(cell)

end

function RecycleView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	BagData.Instance:InitRecycleList()
	self:Flush()
end

function RecycleView:CloseCallBack(is_all)
	self.tab_index = 1
	AudioManager.Instance:PlayOpenCloseUiEffect()
	BagData.Instance:RecycleStorageChree(1)
end

----------------------------------------------------
-- 回收列表itemRender
----------------------------------------------------
MeltingListRender = MeltingListRender or BaseClass(BaseRender)

function MeltingListRender:__init()
end

function MeltingListRender:__delete()
	
end

function MeltingListRender:CreateChild()
	BaseRender.CreateChild(self)
	
	XUI.AddClickEventListener(self.node_tree.img_check.node, BindTool.Bind(self.OnClickRegis, self), false)
	self.node_tree.img_set_equ.node:setVisible(BagData.Instance:GetRecycleChess()[self.index] == 1)
end

function MeltingListRender:OnFlush()
	if nil == self.data then return end
	local text = self.data.desc or "{wordcolor;%s;%s}"
	local _, num = BagData.Instance:RquipTypeShow(self.index)
	local color_1 = (num == 0) and "a6a6a6" or "1eff00"
	local color_2 = (num == 0) and COLOR3B.GRAY or COLOR3B.G_W2
	RichTextUtil.ParseRichText(self.node_tree.txt_equ_num.node, string.format(text, color_1, num), nil, color_2)
end

function MeltingListRender:OnClickRegis()
	self.node_tree.img_set_equ.node:setVisible(not self.node_tree.img_set_equ.node:isVisible())
	
	BagData.Instance:SetMeltingChessData(self.index, self.node_tree.img_set_equ.node:isVisible())
end

function MeltingListRender:CreateSelectEffect()
end


RecycleRender = RecycleRender or BaseClass(BaseRender)
function RecycleRender:__init()
	-- self.is_select = true
end

function RecycleRender:DeleteMe()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function RecycleRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list.ph_cell
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(ph.x, ph.y)
	self.view:addChild(self.item_cell:GetView(), 100)
	self.item_cell:SetIsShowTips(false)
	self.item_cell:SetName(GRID_TYPE_BAG)
	self.item_cell:SetIsChoiceVisible(false)
	self.item_cell:GetView():setTouchEnabled(false)

	self:AddClickEventListener(self.click_callback)
end

function RecycleRender:OnFlush()
	if nil == self.data then
		self.item_cell:SetData(nil)
		self.item_cell:SetIsChoiceVisible(false)
		self.item_cell:MakeGray(false)
		return
	end

	-- 效准默认选择状态
	if self.data.choice == 0 and self.is_select then
		self.is_select = self.data.choice == 1
	end

	self.item_cell:SetData(self.data)
	self.item_cell:SetIsChoiceVisible(self.data.choice == 1)
	self.item_cell:MakeGray(self.data.choice == 1)
end

function RecycleRender:OnSelectChange(is_select)
	local basis_select_count = BagData.Instance:GetBasisSelectCount()
	if self.data.choice  ~= 1 and is_select and basis_select_count >= 25 or not self.item_cell:GetData() then
		self.is_select = false
		if basis_select_count >= 25 then
			local str = Language.Bag.TipShow10
			SystemHint:FloatingTopRightText(str)
		end

		return
	elseif self.data.choice  == 1 and not is_select and basis_select_count >= 25 then
		-- 取消选中
		BagData.Instance:ResetBasisSelectCount() -- 重置选中次数
	end

	self.data.choice = is_select and 1 or 0
	self:OnFlush()
end

function RecycleRender:CreateSelectEffect()
	
end