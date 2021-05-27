-- 每日签到
DailySignInPage = DailySignInPage or BaseClass()

function DailySignInPage:__init()
	self.view = nil
end

function DailySignInPage:__delete()
	self:RemoveEvent()
	if self.num_bar then
		self.num_bar:DeleteMe()
		self.num_bar = nil
	end
	if self.grid_scroll then
		self.grid_scroll:DeleteMe()
		self.grid_scroll = nil
	end
	self.view = nil
end

function DailySignInPage:InitPage(view)
	self.view = view
	XUI.AddClickEventListener(self.view.node_t_list.btn_signin.node, BindTool.Bind(self.OnSigninClicked, self), true)
	self:CreateGrid()
	self:CreateNumBar()
	self:InitEvent()
	self:OnSignInDataChange()
end

function DailySignInPage:InitEvent()
	self.sign_in_data_event = GlobalEventSystem:Bind(WelfareEventType.SIGN_IN_DATA_CHANGE, BindTool.Bind(self.OnSignInDataChange, self))
end

function DailySignInPage:RemoveEvent()
	if self.sign_in_data_event then
		GlobalEventSystem:UnBind(self.sign_in_data_event)
		self.sign_in_data_event = nil
	end
end

function DailySignInPage:CreateNumBar()
	if not self.num_bar then
		local ph = self.view.ph_list.ph_num_bar
		self.num_bar = NumberBar.New()
		self.num_bar:SetRootPath(ResPath.GetCommon("num_100_"))
		self.num_bar:SetPosition(ph.x, ph.y)
		self.num_bar:SetSpace(-5)
		self.num_bar:SetGravity(NumberBarGravity.Left)
		self.view.node_t_list.page1.node:addChild(self.num_bar:GetView(), 9)

	end
end

function DailySignInPage:CreateGrid()
	if not self.grid_scroll then
		local ph = self.view.ph_list.ph_sign_grid
		self.grid_scroll = GridScroll.New()
		self.grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 7, 98, SignInRender, ScrollDir.Vertical, false, self.view.ph_list.ph_sign_item)
		self.view.node_t_list.page1.node:addChild(self.grid_scroll:GetView(), 90)
		-- self.grid_scroll:SetSelectCallBack(BindTool.Bind(self.SelectItemCallBack, self))
		-- self.grid_scroll:SetDataList(WelfareData.Instance:GetSignInData())
		-- self.grid_scroll:SelectItemByIndex(1)
	end
end

--更新视图界面
function DailySignInPage:UpdateData(data)
	local vipLv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	self.num_bar:SetNumber(vipLv)
end	

function DailySignInPage:SelectItemCallBack(item)
	-- if item == nil or item:GetData() == nil then return end
	-- local data = item:GetData()
	-- local today_sign_state = WelfareData.Instance:GetTodaySignState()
	-- for k, v in pairs(self.grid_scroll:GetItems()) do
	-- end
end

function DailySignInPage:OnSigninClicked()
	local today_sign_state, cur_sign_day, some_day, repair_times = WelfareData.Instance:GetTodaySignState()
	if today_sign_state == 0 then
		self.view.node_t_list.btn_signin.node:setTitleText(Language.Welfare.Repaire[1])
		WelfareCtrl.Instance:SignInGetAwardReq(1)
	elseif today_sign_state == 1 then
		self.view.node_t_list.btn_signin.node:setTitleText(Language.Welfare.Repaire[2])
		WelfareCtrl.Instance:SignInGetAwardReq(2)
	else
		self.view.node_t_list.btn_signin.node:setTitleText(Language.Welfare.Repaire[1])
	end
end

function DailySignInPage:OnSignInDataChange()
	local today_sign_state, cur_sign_day, some_day, repair_times = WelfareData.Instance:GetTodaySignState()
	self.view.node_t_list.lbl_sign_in_num.node:setString(cur_sign_day)
	if self.grid_scroll then
		self.grid_scroll:SetDataList(WelfareData.Instance:GetSignInData())
		if cur_sign_day == some_day then
			self.view.node_t_list.btn_signin.node:setTitleText(Language.Welfare.Repaire[1])
			self.view.node_t_list.btn_signin.node:setEnabled(false)
			self.view.node_t_list.txt_use_yb.node:setVisible(false)
			self.view.node_t_list.img_gold.node:setVisible(false)
		else
			self.view.node_t_list.txt_use_yb.node:setVisible(true)
			self.view.node_t_list.img_gold.node:setVisible(true)
			self.view.node_t_list.btn_signin.node:setEnabled(true)
			if today_sign_state == 1 then
				self.view.node_t_list.txt_use_yb.node:setVisible(true)
				self.view.node_t_list.img_gold.node:setVisible(true)
				self.view.node_t_list.btn_signin.node:setTitleText(Language.Welfare.Repaire[2])
			else
				self.view.node_t_list.txt_use_yb.node:setVisible(false)
				self.view.node_t_list.img_gold.node:setVisible(false)
				self.view.node_t_list.btn_signin.node:setTitleText(Language.Welfare.Repaire[1])
			end
		end
	end
	local comsume_money = WelfareData.Instance:GetRepairMoney(repair_times)
	local month = WelfareData.Instance:GetCurMonth()
	self.view.node_t_list.img_signin_month.node:loadTexture(ResPath.GetWelfare("month_" .. month))
	self.view.node_t_list.txt_use_yb.node:setString(comsume_money)
end

----------------------------------------------------
-- SignInRender
----------------------------------------------------
SignInRender = SignInRender or BaseClass(BaseRender)
SignInRender.SelectItem = nil
function SignInRender:__init()
	self.click_callback = nil
	SignInRender.SelectItem = nil
	self.is_select = false
end

function SignInRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function SignInRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img9_selec.node:setVisible(false)
	local ph_cell = self.ph_list.ph_cell
	self.cell = BaseCell.New()
	self.cell:GetCell():setAnchorPoint(cc.p(0.5, 0.5))
	self.cell:GetCell():setPosition(ph_cell.x, ph_cell.y)
	self.view:addChild(self.cell:GetCell(), 1, 1)
	-- self.node_tree.img_have_signed.node:setGrey(true)
end

function SignInRender:OnFlush()
	if not self.data then return end

	self.node_tree.img_have_signed.node:setVisible(self.data.state == SIGN_IN_STATUS.ALREADYGET)
	local rewarData = self.data.reward
	self.cell:SetData({item_id = rewarData.id, num = rewarData.count, is_bind = rewarData.bind})
	self:IsHaveVipDoubleFlag(self.data.vip)
	self:SetGrey()
	local today_sign_state, cur_sign_day, some_day, repair_times = WelfareData.Instance:GetTodaySignState()
	local days = cur_sign_day + 1
	self:SetSelecEffVisible(today_sign_state == SIGN_IN_STATUS.NOT_GET and self.index == days)
	if self.data.state ~= 0 then
		if self.data.state == SIGN_IN_STATUS.NOT_REPAIR then
			self.node_tree.img_have_signed.node:setVisible(false)
			self.node_tree.img_buqian.node:setVisible(true)
			if today_sign_state == SIGN_IN_STATUS.NOT_GET and self.index == days then
				self.node_tree.img_buqian.node:setVisible(false)
			end
		else
			self.node_tree.img_have_signed.node:setVisible(true)
			self.node_tree.img_buqian.node:setVisible(false)
		end
	else
		self.node_tree.img_have_signed.node:setVisible(false)
		self.node_tree.img_buqian.node:setVisible(false)
	end
end

function SignInRender:IsHaveVipDoubleFlag(bool)
	if not bool then return end
	local ph = self.ph_list.ph_double_flag
	local size = self.view:getContentSize()
	local doubImg = XUI.CreateImageView(ph.x, ph.y, ResPath.GetWelfare("desc_1"))
	self.view:addChild(doubImg, 99)
	self.view.doubImg = doubImg
	local vipImg = XUI.CreateImageView(22, 62, ResPath.GetCommon("v_" .. self.data.vip))
	self.view.vipImg = vipImg
	self.view:addChild(vipImg, 99)
end

function SignInRender:SetSelecEffVisible(vis)
	if self.node_tree.img9_selec then
		self.node_tree.img9_selec.node:setVisible(vis)
	end
end

function SignInRender:SetGrey()
	self.cell:MakeGray(self.data.state == SIGN_IN_STATUS.ALREADYGET)
	if self.view.doubImg and self.view.vipImg then
		self.view.doubImg:setGrey(self.data.state == SIGN_IN_STATUS.ALREADYGET)
		self.view.vipImg:setGrey(self.data.state == SIGN_IN_STATUS.ALREADYGET)
	end
end

function SignInRender:CreateSelectEffect()
	
end