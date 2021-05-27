ChargeThreeView = ChargeThreeView or BaseClass(ActBaseView)

function ChargeThreeView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ChargeThreeView:__delete()
	if nil~=self.charge_grade_grid then
		self.charge_grade_grid:DeleteMe()
	end
	self.charge_grade_grid = nil

	if nil~=self.day_charge_num then
		self.day_charge_num:DeleteMe()
	end
	self.day_charge_num = nil
end

function ChargeThreeView:InitView()
	self:CreateChargeNumber()
	self:CreateChargeGrid()
	self.node_t_list.btn_go_charge.node:addClickEventListener(BindTool.Bind(self.OnClickGoChargeHandler, self))
	self.node_t_list.btn_left.node:addClickEventListener(BindTool.Bind(self.OnClickLeftBackHandler, self))
	self.node_t_list.btn_right.node:addClickEventListener(BindTool.Bind(self.OnClickRightBackHandler, self))
end

function ChargeThreeView:CreateChargeGrid()
	local ph_shouhun = self.ph_list.ph_act_grid_item
	local cell_num = table.getn(ActivityBrilliantData.Instance:GetChargeThreeList()) + 1
	if nil == self.charge_grade_grid  then
		self.charge_grade_grid = BaseGrid.New() 
		self.charge_grade_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
		local grid_node = self.charge_grade_grid:CreateCells({w = ph_shouhun.w, h = ph_shouhun.h, itemRender = ChargeThreeRender, ui_config = self.ph_list.ph_act_grid_item, cell_count = cell_num, col = 1, row = 1})
		self.node_t_list.layout_charge_three.node:addChild(grid_node, 10)
		self.charge_grade_grid:GetView():setPosition(ph_shouhun.x, ph_shouhun.y)
	end
end

function ChargeThreeView:CreateChargeNumber()
	local ph = self.ph_list.ph_num
	self.day_charge_num = NumberBar.New()
	self.day_charge_num:SetRootPath(ResPath.GetAct_73_83("num_act_73_"))
	self.day_charge_num:SetPosition(385, 376)
	self.day_charge_num:SetGravity(NumberBarGravity.Center)
	self.day_charge_num:SetSpace(0)
	self.node_t_list.layout_charge_three.node:addChild(self.day_charge_num:GetView(), 300, 300)
end

function ChargeThreeView:RefreshView(param_list)
	-- PrintTable(ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CSFS))
	local charge_list = ActivityBrilliantData.Instance:GetChargeThreeList()
	self.charge_grade_grid:SetDataList(charge_list)
	local index = self.charge_grade_grid:GetCurPageIndex() or 1
	self.day_charge_num:SetNumber(charge_list[index - 1].pay_money)
	self:UpdateBtnState()
end

function ChargeThreeView:OnPageChangeCallBack()
	local index = self.charge_grade_grid:GetCurPageIndex() or 0
	local charge_list = ActivityBrilliantData.Instance:GetChargeThreeList()
	self.day_charge_num:SetNumber(charge_list[index - 1].pay_money)
end

function ChargeThreeView:OnClickGoChargeHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end

function ChargeThreeView:OnClickRightBackHandler()
	local index = self.charge_grade_grid:GetCurPageIndex() or 0
	if index < self.charge_grade_grid:GetPageCount() then
		self.charge_grade_grid:ChangeToPage(index + 1)
	end
	self:UpdateBtnState()
end

function ChargeThreeView:OnClickLeftBackHandler()
	local index = self.charge_grade_grid:GetCurPageIndex() or 0
	if index > 1 then
		self.charge_grade_grid:ChangeToPage(index - 1)
	end
	self:UpdateBtnState()
end

function ChargeThreeView:UpdateBtnState()
	self.node_t_list.btn_left.node:setVisible(not (self.charge_grade_grid:GetCurPageIndex() == 1))
	self.node_t_list.btn_right.node:setVisible(not (self.charge_grade_grid:GetCurPageIndex() == self.charge_grade_grid:GetPageCount()))
end

ChargeThreeRender = ChargeThreeRender or BaseClass(BaseRender)
function ChargeThreeRender:__init()
end

function ChargeThreeRender:__delete()
	if nil~=self.charge_grade_list then
		self.charge_grade_list:DeleteMe()
	end
	self.charge_grade_list = nil
end

function ChargeThreeRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateChargeGradeList()
end

function ChargeThreeRender:CreateChargeGradeList()
	if nil == self.charge_grade_list then
		local ph = self.ph_list.ph_charge_list
		self.charge_grade_list = GridScroll.New()
		self.charge_grade_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 90, ChargeThreeListItemRender, ScrollDir.Vertical, false, self.ph_list.ph_act_73_item)
		self.view:addChild(self.charge_grade_list:GetView(), 100)
	end	
end

function ChargeThreeRender:OnFlush()
	if nil == self.data then
		return 
	end
	self.charge_grade_list:SetDataList(self.data.grade_list)
	self.charge_grade_list:JumpToTop()
end

function ChargeThreeRender:CreateSelectEffect()
end



ChargeThreeListItemRender = ChargeThreeListItemRender or BaseClass(BaseRender)
function ChargeThreeListItemRender:__init()
end

function ChargeThreeListItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function ChargeThreeListItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_awards_cell
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
	XUI.AddClickEventListener(self.node_tree.btn_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end

function ChargeThreeListItemRender:OnClickGetRewardBtn()
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.CSFS, self.data.grade, self.data.item_index == 4 and 0 or self.data.item_index)
end

function ChargeThreeListItemRender:OnFlush()
	if nil == self.data then 
		return
	end
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.btn_lingqu.node:setVisible(false)
	local is_cur_day = false
	if self.data.cur_day == 0 then 
		is_cur_day = self.data.item_index == self.data.charge_day + 1
	else
		is_cur_day = self.data.item_index == self.data.charge_day
	end
	self.node_tree.img_cur_icon.node:setVisible(is_cur_day and self.data.item_index ~= 4)
	self.node_tree.img_day.node:loadTexture(ResPath.GetAct_73_83("act_day_" .. self.data.item_index))
	local data_list = {}
	for k, v in pairs(self.data.awards) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)
	
	if self.data.item_index <= self.data.charge_day or (self.data.item_index == 4 and self.data.charge_day == 3) then 
		if self.data.sign == 0 then 
			self.node_tree.img_stamp.node:setVisible(false)
			self.node_tree.btn_lingqu.node:setVisible(true)
		else 
			self.node_tree.img_stamp.node:loadTexture(ResPath.GetCommon("stamp_1"))
			self.node_tree.img_stamp.node:setVisible(true)
			self.node_tree.btn_lingqu.node:setVisible(false)
		end
	else
		self.node_tree.img_stamp.node:loadTexture(ResPath.GetCommon("stamp_3"))
		self.node_tree.img_stamp.node:setVisible(true)
		self.node_tree.btn_lingqu.node:setVisible(false)
	end
end

function ChargeThreeListItemRender:CreateSelectEffect()
end