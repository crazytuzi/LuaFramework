-- VIP-福利
VipView = VipView or BaseClass(XuiBaseView)

function VipView:InitWelfareView()
	self.cell_effect_list = {}

	self:UpdateWelfareView()
	self:CreateWelfareNumberBar()
	self:CreateWelfareRewardItems()
	self:CreateWelfarePageScroll()

	self.exp_buff_text = RichTextUtil.CreateLinkText("", 21, COLOR3B.GREEN, nil, true)
	self.exp_buff_text:setPosition(800, 225)
	self.exp_buff_text:setColor(VipData.Instance:IsExpBuffReceive() and COLOR3B.G_W or COLOR3B.GREEN)
	self.node_t_list.layout_vip_welfare.node:addChild(self.exp_buff_text, 30)
	XUI.AddClickEventListener(self.exp_buff_text, BindTool.Bind1(self.OnClickExpBuffReceive, self), true)

	XUI.AddClickEventListener(self.node_t_list["layout_btn_welfare_receive"].node, BindTool.Bind1(self.OnClickWelfareReceive, self), true)
	if not self.node_t_list["layout_btn_welfare_receive"].stamp_node then
		local x, y = self.node_t_list["layout_btn_welfare_receive"].node:getPosition()
		local stamp = XUI.CreateImageView(x, y, ResPath.GetCommon("stamp_1"), true)
		stamp:setVisible(false)
		self.node_t_list.layout_vip_welfare.node:addChild(stamp, 100)
		self.node_t_list["layout_btn_welfare_receive"].stamp_node = stamp
	end
	XUI.AddClickEventListener(self.node_t_list["btn_page_down"].node, BindTool.Bind2(self.ChangeWeflareLevel, self, -1), true)
	XUI.AddClickEventListener(self.node_t_list["btn_page_up"].node, BindTool.Bind2(self.ChangeWeflareLevel, self, 1), true)
end

function VipView:DeleteWelfareView()
	self.cell_effect_list = {}

	if self.welfare_vip_num then
		self.welfare_vip_num:DeleteMe()
		self.welfare_vip_num = nil
	end

	if self.welfare_reward_vip_num then
		self.welfare_reward_vip_num:DeleteMe()
		self.welfare_reward_vip_num = nil
	end

	if self.welfare_page_scorll then
		self.welfare_page_scorll:DeleteMe()
		self.welfare_page_scorll = nil
	end

	if self.welfare_reward_items ~= nil then
		for i,v in ipairs(self.welfare_reward_items) do
			v:DeleteMe()
		end
		self.welfare_reward_items = nil
	end
end

function VipView:UpdateWelfareView()
	local level = VipData.Instance.vip_level
	for i=1, level do
		if VipData.Instance:IsVIPLevRewardReceive(i) == false then
			self.cur_welfare_level = i
			return
		end
	end
	self.cur_welfare_level = level
	if self.cur_welfare_level == 0 then
		self.cur_welfare_level = 1
	elseif self.cur_welfare_level >= #VipConfig.VipGrade then
		self.cur_welfare_level = #VipConfig.VipGrade
	else
		self.cur_welfare_level = self.cur_welfare_level + 1
	end

end

function VipView:OnFlushWelfareView(auto_turn)
	if auto_turn then
		self:UpdateWelfareView()
		self.need_turn = false
	end

	self.welfare_vip_num:SetNumber(self.cur_welfare_level)
	self.welfare_reward_vip_num:SetNumber(self.cur_welfare_level)

	local vip_welfare_data = VipData.GetVipWelfareList(self.cur_welfare_level)
	self.welfare_page_scorll:SetDataList(vip_welfare_data)

	if auto_turn then
		self.welfare_page_scorll:JumpToPage(2)
	end

	self:SetRewardList()

	local is_receive = VipData.Instance:IsVIPLevRewardReceive(self.cur_welfare_level)
	self.node_t_list["layout_btn_welfare_receive"].stamp_node:setVisible(is_receive)
	self.node_t_list["layout_btn_welfare_receive"].node:setVisible(not is_receive)
	self.node_t_list["layout_btn_welfare_receive"].node:setColor(is_receive and COLOR3B.GRAY or COLOR3B.WHITE)

	self:OnFlushVipExpRec()
	self:UpdateBtnState()
end

function VipView:OnFlushVipExpRec()
	if self.exp_buff_text == nil then
		return
	end

	local vip_level = VipData.Instance.vip_level
	if vip_level > 0 then
		self.exp_buff_text:setVisible(true)
		self.exp_buff_text:setString(string.format(Language.Vip.ExpBuffReceive, vip_level))
		self.exp_buff_text:setColor(VipData.Instance:IsExpBuffReceive() and COLOR3B.G_W or COLOR3B.GREEN)
		XUI.SetButtonEnabled(self.exp_buff_text, not VipData.Instance:IsExpBuffReceive())
		if VipData.Instance:IsExpBuffReceive() == false then
			UiInstanceMgr.AddRectEffect({node = self.exp_buff_text, init_size_scale = 1.3, act_size_scale = 1.6, offset_w = - 15, offset_h = 8, color = COLOR3B.GREEN})
		else
			UiInstanceMgr.DelRectEffect(self.exp_buff_text)
		end
	else
		self.exp_buff_text:setVisible(false)
	end
end

function VipView:SetRewardList()
	local items = VipData.GetVipGradeItems(self.cur_welfare_level)	
	for k,v in pairs(self.welfare_reward_items) do
		v:SetVisible(false)
		self:SetCellEffect(k, 0)
	end

	local len = #items
	for i,v in ipairs(items) do
		local cell_k = i + #self.welfare_reward_items - len
		local cell = self.welfare_reward_items[cell_k]
		if cell then
			cell:SetVisible(true)
			cell:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
			self:SetCellEffect(cell_k, v.effectId and v.effectId or 0)
		end
	end
end

function VipView:SetCellEffect(cell_k, effect_id)
	effect_id = effect_id or 0
	local cell = self.welfare_reward_items[cell_k]
	if cell ~= nil then
		local x, y = cell:GetCell():getPosition()

		if effect_id > 0 and nil == self.cell_effect_list[cell_k] then
			self.cell_effect_list[cell_k] = AnimateSprite:create()
			self.cell_effect_list[cell_k]:setPosition(x, y)
			self.node_t_list.layout_vip_welfare.node:addChild(self.cell_effect_list[cell_k], 99, 99)
		end

		if nil ~= self.cell_effect_list[cell_k] then
			if effect_id > 0 then
				local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
				self.cell_effect_list[cell_k]:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
			else
				self.cell_effect_list[cell_k]:setStop()
			end
			self.cell_effect_list[cell_k]:setVisible(effect_id > 0)
		end
	end
end

function VipView:OnClickWelfareReceive()
	VipCtrl.Instance:SentVipRewardsReq(self.cur_welfare_level)
end

function VipView:OnClickExpBuffReceive()
	VipCtrl.Instance:SentVIPBuffReq()
end

function VipView:ChangeWeflareLevel(val)
	local change_level = self.cur_welfare_level + val
	if change_level <= #VipConfig.VipGrade and change_level >= 1 then
		if change_level > (VipData.Instance.vip_level + 1) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Vip.NextWefareError)
		else
			self.cur_welfare_level = change_level
			self:OnFlushWelfareView(false)
		end
	end
	self:UpdateBtnState()
end

function VipView:UpdateBtnState()
	self.node_t_list.btn_page_down.node:setVisible(not (self.cur_welfare_level == 1))
	self.node_t_list.btn_page_up.node:setVisible(not (self.cur_welfare_level == #VipConfig.VipGrade))
	XUI.SetButtonEnabled(self.node_t_list.btn_page_up.node, not (self.cur_welfare_level > VipData.Instance.vip_level))
end

function VipView:CreateWelfareNumberBar()
	if self.welfare_vip_num == nil then 
		local x, y = self.node_t_list.img_word_welfare_vip.node:getPosition()
		local vip_level_num = NumberBar.New()
		vip_level_num:SetGravity(NumberBarGravity.Left)
		vip_level_num:SetRootPath(ResPath.GetVipResPath("vip_level_num_"))
		vip_level_num:SetPosition(x + 40, y - 15.5)
		vip_level_num:SetSpace(-1)
		vip_level_num:GetView():setScale(0.8)
		self.welfare_vip_num = vip_level_num
		self.node_t_list["layout_vip_welfare"].node:addChild(vip_level_num:GetView(), 100, 100)
	end

	if self.welfare_reward_vip_num == nil then 
		local x, y = self.node_t_list.img_word_reward.node:getPosition()
		local vip_level_num_2 = NumberBar.New()
		vip_level_num_2:SetGravity(NumberBarGravity.Center)
		vip_level_num_2:SetRootPath(ResPath.GetVipResPath("vip_num_2_"))
		vip_level_num_2:SetPosition(x - 8, y - 13)
		vip_level_num_2:SetSpace(-1)
		self.welfare_reward_vip_num = vip_level_num_2
		self.node_t_list["layout_vip_welfare"].node:addChild(vip_level_num_2:GetView(), 100, 100)
	end
end

function VipView:CreateWelfareRewardItems()
	if self.welfare_reward_items ~= nil then return end

	self.welfare_reward_items = {}
	for i = 1, 8 do
		local ph = self.ph_list["ph_cell_" .. i]
		if ph ~= nil then
			local reward_cell = BaseCell.New()
			reward_cell:GetView():setAnchorPoint(0.5, 0.5)
			reward_cell:GetView():setPosition(ph.x, ph.y)
			reward_cell:SetCellBg(ResPath.GetCommon("cell_102"))
			reward_cell:SetVisible(false)

			self.node_t_list["layout_vip_welfare"].node:addChild(reward_cell:GetView(), 99)
			self.welfare_reward_items[i] = reward_cell
		end
	end
	self:SetRewardList()
end

function VipView:CreateWelfarePageScroll()
	if self.welfare_page_scorll ~= nil then return end

	local ph = self.ph_list.ph_welfare_list
	local page_scorll = PageScrollView.New()
	page_scorll:CreateView({x = ph.x, y = ph.y, w = ph.w, h = ph.h, cell_count = 3, item_scale = 0.74, 
		itemRender = VipWelfareRender, direction = ScrollDir.Horizontal, ui_config = self.ph_list.ph_welfare_item})
	self.node_t_list["layout_vip_welfare"].node:addChild(page_scorll:GetView(), 99)
	
	self.welfare_page_scorll = page_scorll
end


----------------------------------------------------
-- VipWelfareRender
----------------------------------------------------
VipWelfareRender = VipWelfareRender or BaseClass(BaseRender)
VipWelfareRender.SHOW_CFG = {
	[1] = {
		bg_index = 1, attr_word_1_path = "word_vip_4", attr_word_2_path = "vip_welfare_word_1", 
		x_1 = 223, y_1 = 63.5, x_2 = 212, y_2 = 50.5, number_gravity = NumberBarGravity.Right,
	},
	[2] = {
		bg_index = 3, attr_word_1_path = "word_vip_6", attr_word_2_path = "vip_welfare_word_2",
		x_1 = 175, y_1 = 63.5, x_2 = 212, y_2 = 50.5, number_gravity = NumberBarGravity.Left,
	},
	[3] = {bg_index = 2, attr_word_1_path = "word_vip_5", attr_word_2_path = "vip_welfare_word_3", x_1 = 192, y_1 = 63.5,},
}

function VipWelfareRender:__init(w, h)
	self.param_num = nil
end

function VipWelfareRender:__delete()
	if self.param_num then
		self.param_num:DeleteMe()
		self.param_num = nil
	end
end

function VipWelfareRender:CreateChild()
	BaseRender.CreateChild(self)

	self.img_bg = self.node_tree.img_bg.node
	self.img_attr_bg_1 = self.node_tree.img_attr_bg_1.node
	self.img_attr_bg_2 = self.node_tree.img_attr_bg_2.node
	self.img_attr_word_1 = self.node_tree.img_attr_word_1.node
	self.img_attr_word_2 = self.node_tree.img_attr_word_2.node

	self:CreateNumber()
end

function VipWelfareRender:OnFlush()
	if self.data == nil then return end

	local show_config = VipWelfareRender.SHOW_CFG[self.data.type]
	if show_config == nil then return end

	self.img_bg:loadTexture(ResPath.GetBigPainting("vip_welfare_img_" .. show_config.bg_index, true))

	self.img_attr_word_1:loadTexture(ResPath.GetVipResPath(show_config.attr_word_1_path))
	self.img_attr_word_1:setPosition(show_config.x_1, show_config.y_1)

	if self.data.param and self.data.param > 0 then
		self.param_num:SetVisible(true)
		self.param_num:SetGravity(show_config.number_gravity)
		self.param_num:SetNumber(self.data.param)
		self.param_num:SetPosition(show_config.x_2, show_config.y_2)
	else
		self.param_num:SetVisible(false)
	end

	self.img_attr_word_2:loadTexture(ResPath.GetVipResPath(show_config.attr_word_2_path))
end

function VipWelfareRender:CreateSelectEffect()
end

function VipWelfareRender:CreateNumber()
	if self.param_num ~= nil then return end

	local param_num = NumberBar.New()
	param_num:SetGravity(NumberBarGravity.Left)
	param_num:SetRootPath(ResPath.GetVipResPath("vip_num_"))
	param_num:SetPosition(0, 0)
	param_num:SetSpace(-1)
	param_num:SetVisible(false)
	self.view:addChild(param_num:GetView(), 100, 100)
	self.param_num = param_num
end