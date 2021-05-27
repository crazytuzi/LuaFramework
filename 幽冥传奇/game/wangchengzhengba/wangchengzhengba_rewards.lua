local WangChengZhengBaRewardsView = WangChengZhengBaRewardsView or BaseClass(SubView)

function WangChengZhengBaRewardsView:__init()
	self.texture_path_list[1] = 'res/xui/wangchengzhengba.png'
	self.config_tab = {
		{"wangchengzhengba_ui_cfg", 5, {0}},
	}
end

function WangChengZhengBaRewardsView:LoadCallBack(index, loaded_times)
	self.node_t_list.btn_receive_award.node:addClickEventListener(BindTool.Bind1(self.OnClickAutoReceiveRewardHandler, self))
	-- self.node_t_list.btn_receive_award.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_receive_award.node, 1)
	-- self.node_t_list.btn_receive_award.remind_eff:setVisible(false)
	self:CreateTitle()
	self:CreateRoleDisplay()
	self:CreateRewardItem()
	self:CreateRightShow()
	EventProxy.New(WangChengZhengBaData.Instance, self):AddEventListener(WangChengZhengBaData.RewardDataChangeEvent, BindTool.Bind(self.OnFlushRewardView, self))
end

function WangChengZhengBaRewardsView:ReleaseCallBack()
	if self.role_title then
		self.role_title:DeleteMe()
		self.role_title = nil
	end

	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end

	if self.reward_item_list then
		for i, v in pairs(self.reward_item_list) do
			v:DeleteMe()
			v = nil
		end
		self.reward_item_list = nil
	end
end

function WangChengZhengBaRewardsView:ShowIndexCallBack(index)
	self:OnFlushRewardView()
	self:OnFlushRemind(WangChengZhengBaData.Instance.sbk_can_get_reward_mark > 0)
end

function WangChengZhengBaRewardsView:CreateTitle()
	local ph = self.ph_list.ph_role_title
	self.role_title = Title.New()
	self.role_title:GetView():setPosition(ph.x, ph.y)
	self.node_t_list.layout_siege_rewards.node:addChild(self.role_title:GetView(), 20)
	self.role_title:SetTitleId(1)
end

function WangChengZhengBaRewardsView:CreateRoleDisplay()
	local ph = self.ph_list.ph_role_display
	if self.role_display then return end
	self.role_display = RoleDisplay.New(self.node_t_list.layout_siege_rewards.node, nil, false, true, true, false, false, false)
	self.role_display:SetPosition(ph.x, ph.y+20)
	self.role_display:SetScale(0.8)

	local mainrole = Scene.Instance:GetMainRole()
	if nil ~= mainrole then
		self.role_display:Reset(mainrole)
		-- self.role_display:SetRoleResId(30000+RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX))
		-- self.role_display:SetWuQiResId(30000)
	end
end

function WangChengZhengBaRewardsView:CreateRewardItem()
	self.reward_item_list = {}
	for i = 1, 3 do
		local cell = BaseCell.New()
		cell:SetAnchorPoint(0, 0)
		cell:SetCellBg(nil)
		cell:GetView():setPosition(20, 20)
		self.node_t_list["layout_reward_item" .. i].node:addChild(cell:GetView(), 1)
		table.insert(self.reward_item_list, cell)
		self.node_t_list["layout_reward_item" .. i].node:setVisible(false)
	end
end

function WangChengZhengBaRewardsView:CreateRightShow()
	-- local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	-- local cfg = WangChengZhengBaData.Instance:GetShowConfig()
	-- local LeaderClothesId
	-- for k, v in pairs(cfg.LeaderPrivilege.sbkClothes.Clothes) do
	-- 	if v.sex == sex then
	-- 		LeaderClothesId = v.ClothesId
	-- 	end
	-- end
	-- local LeaderAwardFull = {}
	-- LeaderAwardFull[1] = ItemData.Instance:GetItemName(cfg.LeaderPrivilege.sbkTitle.Title.item_id)
	-- LeaderAwardFull[2] = ItemData.Instance:GetItemName(cfg.LeaderPrivilege.sbkWeapon.WeaponId)
	-- LeaderAwardFull[3] = ItemData.Instance:GetItemName(LeaderClothesId)

	local reward_content = WangChengZhengBaData.Instance:GetRewardContent()
	local scroll_node = self.node_t_list.scroll_text_content.node

	local rich_reward = XUI.CreateRichText(100, 10, 500, 0, false)
	rich_reward:setVerticalSpace(14)
	scroll_node:addChild(rich_reward, 100, 100)
	-- HtmlTextUtil.SetString(rich_reward, txt or "")
	RichTextUtil.ParseRichText(rich_reward, reward_content or "", 17, cc.c3b(0xA6, 0xA6, 0xA6))
	rich_reward:refreshView()

	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(rich_reward:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	rich_reward:setAnchorPoint(0, 0.5)
	rich_reward:setPosition(5, inner_h - 5)

	-- 默认跳到顶端
	scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
end

function WangChengZhengBaRewardsView:OnFlushLeftData()
	local data_instance = WangChengZhengBaData.Instance
	local reward_list = data_instance:GetRewardShowItemList()
	self.role_title:SetTitleId(data_instance:GetRewardShowTitle().TitleId)
	self.role_display:SetRoleResId(data_instance:GetRewardShowRoleData().role_res_id)
	self.role_display:SetWuQiResId(data_instance:GetRewardShowRoleData().wuqi_res_id)
	if reward_list then
		for i = 1, 3 do
			self.reward_item_list[i]:SetData(reward_list[i])
		end
	end
end

function WangChengZhengBaRewardsView:OnClickAutoReceiveRewardHandler()
	WangChengZhengBaCtrl.SendGetGongChengGuildReward(WangChengZhengBaData.Instance:GetRewardIndex())
	self.node_t_list.btn_receive_award.remind_eff:setVisible(false)
end

function WangChengZhengBaRewardsView:OnFlushRewardView()
	-- self:OnFlushSocietyRoleName()
	self:OnFlushGetRewardBtn()
	self:OnFlushLeftData()
	-- self:OnFlushJumpToReward()
end

function WangChengZhengBaRewardsView:OnFlushSocietyRoleName()
	local data = WangChengZhengBaData.Instance:GetSbkBaseMsg()
	-- 初始化为空
	self:SetRewardPostName()
	for i = SOCIAL_MASK_DEF.GUILD_TANGZHU_FIR, SOCIAL_MASK_DEF.GUILD_LEADER do
		self:SetRewardPostName(i)
	end

	if data and data.guild_name ~= "" then
		self:SetRewardPostName(nil, data.guild_name)
	end

	if data and data.guild_main_mb_list then
		for k,v in pairs(data.guild_main_mb_list) do
			-- if v.mb_state ~= 0 then
			-- 	if v.guild_position and v.vo and v.vo.name then self:SetRewardPostName(v.guild_position, v.vo.name) end
			-- end
			if v.role_name and v.role_name ~= "" then self:SetRewardPostName(k, v.role_name) end
		end
	end
end

function WangChengZhengBaRewardsView:OnFlushGetRewardBtn()
	if nil == self.node_t_list.btn_receive_award then return end
	self.node_t_list.btn_receive_award.node:setEnabled(WangChengZhengBaData.Instance.sbk_can_get_reward_mark == 1)
end

function WangChengZhengBaRewardsView:OnFlushRemind(is_show_remind)
	-- if self.node_t_list and self.node_t_list.btn_receive_award then
	-- 	self.node_t_list.btn_receive_award.remind_eff:setVisible(is_show_remind)
	-- end
end

return WangChengZhengBaRewardsView