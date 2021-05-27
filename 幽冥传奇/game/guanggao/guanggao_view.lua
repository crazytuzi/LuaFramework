GuanggaoView = GuanggaoView or BaseClass(XuiBaseView)
function GuanggaoView:__init()
	self.zorder = -1
	self.texture_path_list[1] = 'res/xui/login.png'
	self.config_tab = {
		{"guanggao_ui_cfg", 1, {0}},
	}
end	

function GuanggaoView:__delete()
end	

function GuanggaoView:ReleaseCallBack()
	if self.page_grid then
		self.page_grid:DeleteMe()
		self.page_grid = nil
	end	
end

function GuanggaoView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.left_btn.node,BindTool.Bind(self.OnLeft,self))
		XUI.AddClickEventListener(self.node_t_list.right_btn.node,BindTool.Bind(self.OnRight,self))
	end
end

function GuanggaoView:CreatePageView(cell_count)
	if not self.page_grid then
		self.page_grid = BaseGrid.New()

		local layout_content = self.node_t_list.layout_content.node
		local size = layout_content:getContentSize()
		local grid_node = self.page_grid:CreateCells({w = size.width, h = size.height, cell_count = cell_count, col=1, row=1, 
													itemRender = GuanggaoPageCell, ui_config = self.ph_list.ph_item_page,
													direction = ScrollDir.Horizontal})
		self.page_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChange, self))
		self.node_t_list.layout_content.node:addChild(grid_node, 100)
	end
end	

function GuanggaoView:OnLeft()
	self.page_grid:ChangeToPage(self.page_grid:GetCurPageIndex() - 1)
	self:CheckDirVisible()
end	

function GuanggaoView:OnRight()
	self.page_grid:ChangeToPage(self.page_grid:GetCurPageIndex() + 1)
	self:CheckDirVisible()
end	

function GuanggaoView:OpenCallBack()
	GuanggaoCtrl.Instance:SendServerStateReq()
end

function GuanggaoView:CheckDirVisible()
	if self.page_grid:GetCurPageIndex() <= 1 then
		self.node_t_list.left_btn.node:setVisible(false)
	else	
		self.node_t_list.left_btn.node:setVisible(true)	
	end

	if self.page_grid:GetCurPageIndex() >= self.page_grid:GetPageCount() then
		self.node_t_list.right_btn.node:setVisible(false)
	else	
		self.node_t_list.right_btn.node:setVisible(true)
	end
end	

function GuanggaoView:OnPageChange()
	self:CheckDirVisible()
end	

function GuanggaoView:PageRadioHandler(index)
	if nil ~= self.page_grid then
		self.page_grid:ChangeToPage(index)
		self:CheckDirVisible()
	end
end

function GuanggaoView:OnFlush(param_t, index)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local data = ClientGuanggaoDayCfg[open_day]
	local list = {}
	for i,v in ipairs(data) do
		list[i] = OpenServerAdvertisementPageCfg[v]
	end	

	local item = table.remove(list,1)
	list[0] = item

	self:CreatePageView(#data)
	self.page_grid:SetDataList(list)
	self:CheckDirVisible()
end	


GuanggaoPageCell = GuanggaoPageCell or BaseClass(BaseRender)
function GuanggaoPageCell:__init()
end

function GuanggaoPageCell:__delete()
	if nil ~= self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
	self.effec = nil
end	

function GuanggaoPageCell:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_gift_list = {}
	for i = 1, 2 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		self.view:addChild(cell:GetView(), 300)
		table.insert(self.cell_gift_list, cell)
	end

	XUI.AddClickEventListener(self.node_tree.btn_reward.node,BindTool.Bind(self.OnReward,self))
	XUI.AddClickEventListener(self.node_tree.btn_join.node,BindTool.Bind(self.OnClick,self))

	if not self.effec then
		self.effec = RenderUnit.CreateEffect(10, self.node_tree.btn_reward.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		self.effec:setScaleX(0.6)
	end
end

function GuanggaoPageCell:OnFlush()
	if not self.data then return end

	self.node_tree.img_bg.node:loadTexture(ResPath.GetBigPainting("guanggao_" .. self.data.dayIndex,true))	

	local cur_data = {}
	local index = 1
	for i, v in ipairs(self.data.Awards) do
		if v.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if virtual_item_id then
				cur_data[index] = {["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0}
			end
		else
			cur_data[index] = {item_id = v.id, num = v.count, is_bind = 1}
		end
		index = index + 1
	end

	local vis = false
	for i1, v1 in ipairs(cur_data) do
		for i1 = 1, 2 do
			vis = cur_data[i1] and true or false
			self.cell_gift_list[i1]:GetView():setVisible(vis)
		end
		self.cell_gift_list[i1]:SetData(v1)
	end

	local state = GuanggaoData.Instance:GetBtnShowState(self.data.dayIndex)
	local open_day = OtherData.Instance:GetOpenServerDays()
	if open_day == self.data.dayIndex then
		self.node_tree.btn_reward.node:setEnabled(state == 0)
		self.effec:setVisible(state == 0)
		self.node_tree.btn_join.node:setEnabled(true)
	else
		self.node_tree.btn_reward.node:setEnabled(false)
		self.effec:setVisible(false)
		self.node_tree.btn_join.node:setEnabled(false)
	end
end	

function GuanggaoPageCell:OnClick()
	ActivityCtrl.Instance:OpenOneActView(self.data)	
end	

function GuanggaoPageCell:OnReward()
	GuanggaoCtrl.Instance:SendRewardResult()
end