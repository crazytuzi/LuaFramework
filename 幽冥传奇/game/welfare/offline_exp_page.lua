-- 离线经验页面
OfflineRewardPage = OfflineRewardPage or BaseClass()

OfflineCheckType = {
	Normal = 1,			--单倍
	Double = 2,			--双倍
	Triple = 3,			--三倍
}

function OfflineRewardPage:__init()
	self.view = nil
	self.check_box_list = {}
	self.select_box_type = 1		-- 1单倍 2双倍 3三倍
	self.check_parent_list = {}
end

function OfflineRewardPage:__delete()
	self:RemoveEvent()
	if self.info_list then
		self.info_list:DeleteMe()
		self.info_list = nil
	end
	self.check_box_list = {}
	self.check_parent_list = {}
	self.select_box_type = 1
	self.view = nil
end

function OfflineRewardPage:InitPage(view)
	self.view = view
	self.check_parent_list = {
						self.view.node_t_list.layout_normal_fetch.node,
						self.view.node_t_list.layout_double_fetch.node,
						self.view.node_t_list.layout_triple_fetch.node
					}
	self:CreateAwarItemList()
	XUI.AddClickEventListener(self.view.node_t_list.btn_offline_fetch.node, BindTool.Bind(self.OnFetchClick, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_interp_offlin.node, BindTool.Bind(self.OnInterpClick), true)
	self:CreateMyCheckBoxs()
	self:SetDoubleTripleCondText()
	self:InitEvent()

	self:OnOfflineExpDataChange()
end

function OfflineRewardPage:InitEvent()
	self.offline_event = GlobalEventSystem:Bind(WelfareEventType.OFFLINE_EXP_DATA_CHANGE, BindTool.Bind(self.OnOfflineExpDataChange, self))
end

function OfflineRewardPage:RemoveEvent()
	if self.offline_event then
		GlobalEventSystem:UnBind(self.offline_event)
		self.offline_event = nil
	end
end

--更新视图界面
function OfflineRewardPage:UpdateData(data)
	-- WelfareCtrl.Instance:OfflineAwardInfoReq()
end	

function OfflineRewardPage:CreateMyCheckBoxs()
	for i = 1 , #self.check_parent_list do
		local node = XUI.CreateImageView(0, 0, ResPath.GetCommon("bg_checkbox_hook"), true)
		node:setVisible(false)
		node:setAnchorPoint(0, 0)
		self.check_parent_list[i]:addChild(node, 99)
		self.check_box_list[i] = node
		XUI.AddClickEventListener(self.check_parent_list[i], BindTool.Bind(self.OnCheckBoxClicked,self,node), true)
	end	
	self.check_box_list[1]:setVisible(true)
	self.select_box_type = 1
end	

function OfflineRewardPage:CreateAwarItemList()
	if not self.info_list then
		local ph = self.view.ph_list.ph_offline_list
		self.info_list = ListView.New()
		self.info_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OfflineExpInfodRender, nil, nil, self.view.ph_list.ph_offline_item)
		self.info_list:SetMargin(3)
		self.info_list:SetItemsInterval(6)
		self.view.node_t_list.page5.node:addChild(self.info_list:GetView(), 99)
	end
end

function OfflineRewardPage:OnCheckBoxClicked(node)
	local temp_type = 1
	local _, offline_total_h, total_awar_info, offline_fetch_state = WelfareData.Instance:GetOfflineExpAllInfo()
	if offline_fetch_state == 1 then
		for i = #self.check_box_list, 1 , -1 do
			if node == self.check_box_list[i] then
				self.check_box_list[i]:setVisible(true)
				temp_type = i
			else
				self.check_box_list[i]:setVisible(false)
			end	
		end
	end	
	self.select_box_type = temp_type

	self:SetTotalAwardInfo(total_awar_info, offline_fetch_state)
end

function OfflineRewardPage:SetDoubleTripleCondText()
	local fetch_cfg = WelfareData.Instance:GetOfflineFetchConf()
	local vipLv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	for k, v in pairs(fetch_cfg) do
		if self.view.node_t_list["txt_fet_cond_" .. k] then
			local color = vipLv >= v.needVipLevel and COLOR3B.BRIGHT_GREEN or COLOR3B.RED
			self.view.node_t_list["txt_fet_cond_" .. k].node:setColor(color)
			self.view.node_t_list["txt_fet_cond_" .. k].node:setString(string.format(Language.Welfare.OfflineFetchCondTex, v.needVipLevel))
		end
	end
end

-- 设置已获得奖励信息
function OfflineRewardPage:SetTotalAwardInfo(awar_info, offline_fetch_state)
	local is_can_fetch = next(awar_info) and true or false
	self.view.node_t_list.btn_offline_fetch.node:setEnabled(is_can_fetch)
	for i = 1, 2 do
		if awar_info[i] then
			self.view.node_t_list["txt_total_get_" .. i].node:setString(awar_info[i].count * self.select_box_type)
		else
			self.view.node_t_list["txt_total_get_" .. i].node:setString(0)
		end
	end

	self.view.node_t_list.txt_cost.node:setString("")
	local vipLv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	local fetch_cfg = WelfareData.Instance:GetOfflineFetchConf()
	if fetch_cfg[self.select_box_type] then
		local cfg = fetch_cfg[self.select_box_type]
		local money_name = ShopData.GetMoneyTypeName(cfg.costMoneyType)
		local num = 0
		if awar_info[1] then
			num = cfg.CostMoneyNum * math.floor(awar_info[1].count / cfg.preNum)
		end
		self.view.node_t_list.txt_cost.node:setString(string.format(Language.Welfare.OfflineFetchCostTex, num, money_name))
	end
end

function OfflineRewardPage:OnOfflineExpDataChange()
	local offline_all_map_info, offline_total_h, total_awar_info, offline_fetch_state = WelfareData.Instance:GetOfflineExpAllInfo()
	self.info_list:SetDataList(offline_all_map_info)
	if offline_fetch_state == OFFLINE_EXP_AWARD_FETCH_STATE.CANNOT then
		for i = 1, 3 do
			self.check_box_list[i]:setVisible(i == 1)
			self.check_parent_list[i]:setTouchEnabled(i == 1)
			self.select_box_type = 1
		end
	end
	local content = string.format(Language.Welfare.OfflineHourContent, offline_total_h)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_total_get.node, content)
	self:SetTotalAwardInfo(total_awar_info)
end

--领取离线奖励
function OfflineRewardPage:OnFetchClick()
	-- print("领取类型：", self.select_box_type)
	WelfareCtrl.Instance:FetchOfflineAwardReq(self.select_box_type)
end

function OfflineRewardPage:OnInterpClick()
	DescTip.Instance:SetContent(Language.Welfare.InterpContents[2], Language.Welfare.InterpTitles[2])
end

--OfflineExpInfodRender
OfflineExpInfodRender = OfflineExpInfodRender or BaseClass(BaseRender)
function OfflineExpInfodRender:__init()

end

function OfflineExpInfodRender:__delete()

end

function OfflineExpInfodRender:CreateChild()
	BaseRender.CreateChild(self)
end

function OfflineExpInfodRender:OnFlush()
	if not self.data then return end
	local path = self.data.open_state == OFFLINE_EXP_OPEN_STATE.NO and ResPath.GetCommon("btn_106_normal") or ResPath.GetCommon("btn_106_select")
	self.node_tree.map_title_bg.node:loadTexture(path)
	path = ResPath.GetBigPainting("offline_exp_" .. self.index, true)
	self.node_tree.img_offline_bg.node:loadTexture(path)
	self.node_tree.img_offline_bg.node:setGrey(self.data.open_state == OFFLINE_EXP_OPEN_STATE.NO)
	
	self.node_tree.txt_map_name.node:setString(self.data.map_name)
	self.node_tree.txt_info_title.node:setString(Language.Welfare.OfflineInfoTitles[self.data.open_state])
	
	self.node_tree.layout_award_info.node:setVisible(self.data.open_state == OFFLINE_EXP_OPEN_STATE.YES)
	self.node_tree.layout_get_cond.node:setVisible(self.data.open_state == OFFLINE_EXP_OPEN_STATE.NO)	

	if self.data.open_state == OFFLINE_EXP_OPEN_STATE.NO then
		for i, v in ipairs(self.data.conds_info) do
			if self.node_tree["layout_get_cond"]["txt_cond_" .. i] then
				self.node_tree["layout_get_cond"]["txt_cond_" .. i].node:setColor(v.achieve_state == 0 and COLOR3B.RED or COLOR3B.BRIGHT_GREEN)
				local str = ""
				if v.event == OFFLINE_OPEN_COND_EVE_TYPE.ActorLevel then
					str = string.format(Language.Welfare.OfflineExpConds[1], v.param or 0, v.param2 or 0)
				elseif v.event == OFFLINE_OPEN_COND_EVE_TYPE.KillMonster then
					local monster_cfg = BossData.GetMosterCfg(v.param)
					str = string.format(Language.Welfare.OfflineExpConds[2], v.param2 or 1, monster_cfg and DelNumByString(monster_cfg.name or ""))
				elseif v.event == OFFLINE_OPEN_COND_EVE_TYPE.VipLevel then
					str = string.format(Language.Welfare.OfflineExpConds[3], v.param)
				end
				self.node_tree["layout_get_cond"]["txt_cond_" .. i].node:setString(str)
			end
		end
	else
		for i = 1, 3 do
			if self.data.per_h_awards[i] then
				local one_award_info = self.data.per_h_awards[i]
				local icon_path = ItemData.GetAwardTypeIcon(one_award_info.type)
				self.node_tree["layout_award_info"]["img_awar_" .. i].node:setVisible(true)
				self.node_tree["layout_award_info"]["img_awar_" .. i].node:loadTexture(icon_path)
				self.node_tree["layout_award_info"]["txt_award_" .. i].node:setString(one_award_info.count)
			else
				self.node_tree["layout_award_info"]["img_awar_" .. i].node:setVisible(false)
				self.node_tree["layout_award_info"]["txt_award_" .. i].node:setString("")
			end
		end
	end

end

function OfflineExpInfodRender:CreateSelectEffect()

end