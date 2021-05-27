-- 成长大礼界面
GrowupGiftPage = GrowupGiftPage or BaseClass()

function GrowupGiftPage:__init()
	self.view = nil
end

function GrowupGiftPage:__delete()
	self:RemoveEvent()
	if self.gift_info_list then
		self.gift_info_list:DeleteMe()
		self.gift_info_list = nil
	end

	if self.scale_numbar then
		self.scale_numbar:DeleteMe()
		self.scale_numbar = nil
	end

	if self.bug_yb_numbar then
		self.bug_yb_numbar:DeleteMe()
		self.bug_yb_numbar = nil
	end
	
	self.view = nil
end

function GrowupGiftPage:InitPage(view)
	self.view = view

	self:CreateGiftInfoList()
	self:CreateNumBar()
	self:CreateScaleNumBar()

	local data = WelfareData.Instance:GetGradeGiftCfg()

	
	
	self.view.node_t_list.txt_term.node:setString(string.format(Language.Welfare.NeedVipLevel, UpgradeGiftCfg.NeedVipLevel))
	self.view.node_t_list.txt_limit.node:setString(string.format(Language.Welfare.BuyGiftTimeLimit, UpgradeGiftCfg.DayLimit))
	self.bug_yb_numbar:SetNumber(UpgradeGiftCfg.GoldNum)
	self.scale_numbar:SetNumber(UpgradeGiftCfg.RewardFactor)
	self.gift_receive = GlobalEventSystem:Bind(WelfareEventType.GRADE_GIFT_RECEIVE_INFO, BindTool.Bind(self.OnGiftReceiveEvent, self))
	self.view.node_t_list.btn_bug_plan.node:addClickEventListener(BindTool.Bind(self.GetBuyPlan, self))
end

function GrowupGiftPage:RemoveEvent()
	if self.gift_receive then
		GlobalEventSystem:UnBind(self.gift_receive)
		self.gift_receive = nil
	end
end

function GrowupGiftPage:OnGiftReceiveEvent()
	local num = WelfareData.Instance:GetGiftRemainNum() or 9
	if num<=9 then
		self.view.node_t_list.txt_num.node:setString(9 or "")
	else
		self.view.node_t_list.txt_num.node:setString(num or "")
	end
	local data = WelfareData.Instance:GetGradeGiftCfg()
	self.gift_info_list:SetDataList(data.awards)
	local btn_buy = WelfareData.Instance:GetGiftBuyInfo()
	if btn_buy == 1 then
		self.view.node_t_list.btn_bug_plan.node:setEnabled(false)
		if num<=9 then
			self.view.node_t_list.txt_num.node:setString("8")
		else
			self.view.node_t_list.txt_num.node:setString(num)
		end 
		--self.view.node_t_list.img_buy.node:setGrey(true)
		self.view.node_t_list.txt_term.node:setString(Language.Welfare.BuyGift)
	end
end

function GrowupGiftPage:GetBuyPlan()
	WelfareCtrl.Instance:BugGrowupPlanReq()
end

function GrowupGiftPage:CreateGiftInfoList()
	if not self.gift_info_list then
		local ph = self.view.ph_list.ph_gift_list
		self.gift_info_list = ListView.New()
		self.gift_info_list:Create(ph.x, ph.y, ph.w, ph.h, direction, GradeGiftItem, nil, false, self.view.ph_list.ph_list_gift_info)
		self.gift_info_list:SetItemsInterval(3)
		self.gift_info_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.page7.node:addChild(self.gift_info_list:GetView(), 100)
	end
end

function GrowupGiftPage:CreateNumBar()
	local ph = self.view.ph_list.img_bug_yb
	self.bug_yb_numbar = NumberBar.New()
	self.bug_yb_numbar:SetRootPath(ResPath.GetFightResPath("g_"))
	self.bug_yb_numbar:SetPosition(ph.x, ph.y)
	self.bug_yb_numbar:SetSpace(-3)
	self.view.node_t_list.page7.node:addChild(self.bug_yb_numbar:GetView(), 90)
	self.bug_yb_numbar:SetNumber(0)
end

function GrowupGiftPage:CreateScaleNumBar()
	local ph = self.view.ph_list.img_scale
	self.scale_numbar = NumberBar.New()
	self.scale_numbar:SetRootPath(ResPath.GetFightResPath("g_"))
	self.scale_numbar:SetPosition(ph.x, ph.y)
	self.scale_numbar:SetSpace(-3)
	self.view.node_t_list.page7.node:addChild(self.scale_numbar:GetView(), 90)
	self.scale_numbar:SetNumber(0)
end


--更新视图界面
function GrowupGiftPage:UpdateData(data)
	local num = WelfareData.Instance:GetGiftRemainNum() or 9
	if num<=9 then
		self.view.node_t_list.txt_num.node:setString(9 or "")
	else
		self.view.node_t_list.txt_num.node:setString(num or "")
	end
	local data = WelfareData.Instance:GetGradeGiftCfg()
	self.gift_info_list:SetDataList(data.awards)
	local btn_buy = WelfareData.Instance:GetGiftBuyInfo()
	if btn_buy == 1 then
		self.view.node_t_list.btn_bug_plan.node:setEnabled(false)
		if num<=9 then
			self.view.node_t_list.txt_num.node:setString("8")
		else
			self.view.node_t_list.txt_num.node:setString(num)
		end 
		--self.view.node_t_list.img_buy.node:setGrey(true)
		self.view.node_t_list.txt_term.node:setString(Language.Welfare.BuyGift)
	end
end	


GradeGiftItem = GradeGiftItem or BaseClass(BaseRender)
function GradeGiftItem:__init()
	self.cells_list = {}
end

function GradeGiftItem:__delete()
	
end

function GradeGiftItem:CreateChild()
	BaseRender.CreateChild(self)
	
	self.node_tree.btn_can_receive.node:addClickEventListener(BindTool.Bind(self.GetConsume, self))
end

function GradeGiftItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_item_name.node:setString(self.data.item_desc)
	self.node_tree.txt_yuanbao_num.node:setString(self.data.item_awards[1].count)
	self.node_tree.btn_can_receive.node:setVisible(self.data.state == 1)
	self.node_tree.img_not.node:setVisible(self.data.state == 0)
	self.node_tree.img_receive.node:setVisible(self.data.state == 2)
end

-- 创建选中特效
function GradeGiftItem:CreateSelectEffect()
	
end

function GradeGiftItem:GetConsume()
	WelfareCtrl.Instance:ReceiveGrowupPlanReq(self.data.pos)
end



