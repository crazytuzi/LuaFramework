LianxuFanliView = LianxuFanliView or BaseClass(ActBaseView)

function LianxuFanliView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function LianxuFanliView:__delete()
	if nil~=self.charge_grade_grid then
		self.charge_grade_grid:DeleteMe()
	end
	self.charge_grade_grid = nil

	if nil~=self.day_charge_num then
		self.day_charge_num:DeleteMe()
	end
	self.day_charge_num = nil
end

function LianxuFanliView:InitView()
	self:CreateChargeNumber()
	self:CreateChargeGrid()
	self.node_t_list.btn_go_charge.node:addClickEventListener(BindTool.Bind(self.OnClickGoChargeHandler, self))
	self.node_t_list.btn_left.node:addClickEventListener(BindTool.Bind(self.OnClickLeftBackHandler, self))
	self.node_t_list.btn_right.node:addClickEventListener(BindTool.Bind(self.OnClickRightBackHandler, self))
end

function LianxuFanliView:CreateChargeGrid()
	local ph_shouhun = self.ph_list.ph_charge_list
	local cell_num = table.getn(ActivityBrilliantData.Instance:GetLianxuFanliList()) + 1
	if nil == self.charge_grade_grid  then
		self.charge_grade_grid = BaseGrid.New() 
		self.charge_grade_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
		local grid_node = self.charge_grade_grid:CreateCells({w = ph_shouhun.w, h = ph_shouhun.h, itemRender = LianxuFanliRender, ui_config = self.ph_list.ph_act_grid_item, cell_count = cell_num, col = 1, row = 1})
		self.node_t_list.layout_lianxu_fanli.node:addChild(grid_node, 10)
		self.charge_grade_grid:GetView():setPosition(ph_shouhun.x, ph_shouhun.y)
	end
end

function LianxuFanliView:CreateChargeNumber()
	local ph = self.ph_list.ph_num
	self.day_charge_num = NumberBar.New()
	self.day_charge_num:SetRootPath(ResPath.GetCommon("num_155_"))
	self.day_charge_num:SetPosition(365, 448)
	self.day_charge_num:SetGravity(NumberBarGravity.Center)
	self.day_charge_num:SetSpace(0)
	self.node_t_list.layout_lianxu_fanli.node:addChild(self.day_charge_num:GetView(), 300, 300)
end

function LianxuFanliView:RefreshView(param_list)
	local charge_list = ActivityBrilliantData.Instance:GetLianxuFanliList()
	self.charge_grade_grid:SetDataList(charge_list)
	local index = self.charge_grade_grid:GetCurPageIndex() or 1
	self.day_charge_num:SetNumber(charge_list[index - 1].pay_money)
	self:UpdateBtnState()
end

function LianxuFanliView:OnPageChangeCallBack()
	local index = self.charge_grade_grid:GetCurPageIndex() or 0
	local charge_list = ActivityBrilliantData.Instance:GetLianxuFanliList()
	self.day_charge_num:SetNumber(charge_list[index - 1].pay_money)
end

function LianxuFanliView:OnClickGoChargeHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end

function LianxuFanliView:OnClickRightBackHandler()
	local index = self.charge_grade_grid:GetCurPageIndex() or 0
	if index < self.charge_grade_grid:GetPageCount() then
		self.charge_grade_grid:ChangeToPage(index + 1)
	end
	self:UpdateBtnState()
end

function LianxuFanliView:OnClickLeftBackHandler()
	local index = self.charge_grade_grid:GetCurPageIndex() or 0
	if index > 1 then
		self.charge_grade_grid:ChangeToPage(index - 1)
	end
	self:UpdateBtnState()
end

function LianxuFanliView:UpdateBtnState()
	self.node_t_list.btn_left.node:setVisible(not (self.charge_grade_grid:GetCurPageIndex() == 1))
	self.node_t_list.btn_right.node:setVisible(not (self.charge_grade_grid:GetCurPageIndex() == self.charge_grade_grid:GetPageCount()))
end

LianxuFanliRender = LianxuFanliRender or BaseClass(BaseRender)
function LianxuFanliRender:__init()
end

function LianxuFanliRender:__delete()
	if nil~=self.charge_grade_list then
		self.charge_grade_list:DeleteMe()
	end
	self.charge_grade_list = nil
end

function LianxuFanliRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateChargeGradeList()
end

function LianxuFanliRender:CreateChargeGradeList()
	if nil == self.charge_grade_list then
		local ph = self.ph_list.ph_charge_list
		self.charge_grade_list = GridScroll.New()
		self.charge_grade_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 100, LianxuFanliItemRender, ScrollDir.Vertical, false, self.ph_list.ph_act_80_item)
		self.view:addChild(self.charge_grade_list:GetView(), 100)
	end	
end

function LianxuFanliRender:OnFlush()
	if nil == self.data then
		return 
	end
	self.charge_grade_list:SetDataList(self.data.grade_list)
	self.charge_grade_list:JumpToTop()
end

function LianxuFanliRender:CreateSelectEffect()
end



LianxuFanliItemRender = LianxuFanliItemRender or BaseClass(BaseRender)
function LianxuFanliItemRender:__init()
end

function LianxuFanliItemRender:__delete()
	if nil ~= self.day_count then
		self.day_count:DeleteMe()
		self.day_count = nil
	end
end

function LianxuFanliItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.day_count = NumberBar.New()
	self.day_count:SetRootPath(ResPath.GetCommon("num_118_"))
	self.day_count:SetPosition(65, 32)
	self.day_count:SetGravity(NumberBarGravity.Center)
	self.day_count:SetSpace(-10)
	self.day_count:SetScale(0.7)
	self.view:addChild(self.day_count:GetView(), 300, 300)
	XUI.AddClickEventListener(self.node_tree.btn_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end

function LianxuFanliItemRender:OnClickGetRewardBtn()
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.LXFL, self.data.grade, self.data.item_index == self.data.freeAwardDay + 1 and 0 or self.data.item_index)
end

function LianxuFanliItemRender:OnFlush()
	if nil == self.data then 
		return
	end
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.btn_lingqu.node:setVisible(false)
	local is_last = self.data.item_index == self.data.freeAwardDay + 1
	self.node_tree.img_day.node:loadTexture(ResPath.GetAct_73_83("act_80_text_" .. (is_last and 2 or 1)))
	self.day_count:SetNumber(is_last and self.data.freeAwardDay or self.data.item_index)
	self.day_count:SetPosition(is_last and 78 or 65, 32)
	local str = string.format(Language.ActivityBrilliant.LianxuFanliFormat, (self.data.awards / self.data.pay_money * 100) .. "%", self.data.awards)
	RichTextUtil.ParseRichText(self.node_tree.rich_fanli_rate.node, str, 25, COLOR3B.YELLOW)
	
	if self.data.item_index <= self.data.charge_day or (self.data.item_index == self.data.freeAwardDay + 1 and self.data.charge_day == self.data.freeAwardDay) then 
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

function LianxuFanliItemRender:CreateSelectEffect()
end