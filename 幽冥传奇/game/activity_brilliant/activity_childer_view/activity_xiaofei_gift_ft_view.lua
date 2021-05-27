XFGiftFTView = XFGiftFTView or BaseClass(ActBaseView)

function XFGiftFTView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function XFGiftFTView:__delete()
	if self.reward_cell_52 then
		self.reward_cell_52:DeleteMe()
		self.reward_cell_52 = nil
	end
end

function XFGiftFTView:InitView()
	self.node_t_list.btn_lingqu_52.node:addClickEventListener(BindTool.Bind(self.OnClickLingquFtHandler, self))
	self:CreateXFGiftFTRewards()
end

function XFGiftFTView:RefreshView(param_list)
	local num = ActivityBrilliantData.Instance.mine_num[ACT_ID.XFGIFTFT]
	local num_2 = ActivityBrilliantData.Instance:GetChongZhiLQNum()
	--self.node_t_list.layout_xfgift_52.lbl_activity_tip.node:setString(num)
	--self.node_t_list.layout_xfgift_52.lbl_lingqu_52_num.node:setString(num_2)
	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.act_id)
	local per_money = cfg.config.money
	if per_money then
		--local num_3 = math.modf(num / per_money) - num_2
		--self.node_t_list.layout_xfgift_52.lbl_remain_52_num.node:setString(num_3)

		local use_num = num_2 * per_money 

		local remain_num = num - use_num
		local text = "前往寻宝"
		if remain_num >= per_money then
			text = "领取奖励"
		end
		self.node_t_list.btn_lingqu_52.node:setTitleText(text)
		
		local text = string.format("当前累计消费：%d / %d 钻石", remain_num, per_money)
		RichTextUtil.ParseRichText(self.node_t_list.lbl_activity_tip.node, text, 20, COLOR3B.GREEN)
		XUI.RichTextSetCenter(self.node_t_list.lbl_activity_tip.node)
	end
end

function XFGiftFTView:CreateXFGiftFTRewards()
	self.cell_list = {}
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XFGIFTFT)
	if nil == cfg then return end
	for i=1, 3 do
		local ph = self.ph_list["ph_cell_52_" .. i]
		cell = ActBaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0, 0)
		self.node_t_list.layout_xfgift_52.node:addChild(cell:GetView(), 900)
		local item_data = {}
		local data = cfg.config.award[i]
		if nil ~= data then
			item_data.item_id = data.id
			item_data.num = data.count
			item_data.is_bind = data.bind
			item_data.effectId = data.effectId
			cell:SetData(item_data)
		else
			cell:SetData(nil)
		end
		cell:SetVisible(data ~= nil)
		table.insert(self.cell_list, cell)
	end
	
end

function XFGiftFTView:OnClickLingquFtHandler()

	local num = ActivityBrilliantData.Instance.mine_num[ACT_ID.XFGIFTFT]
	local num_2 = ActivityBrilliantData.Instance:GetChongZhiLQNum()
	--self.node_t_list.layout_xfgift_52.lbl_activity_tip.node:setString(num)
	--self.node_t_list.layout_xfgift_52.lbl_lingqu_52_num.node:setString(num_2)
	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.act_id)
	local per_money = cfg.config.money

	if per_money then
		--local num_3 = math.modf(num / per_money) - num_2
		--self.node_t_list.layout_xfgift_52.lbl_remain_52_num.node:setString(num_3)

		local use_num = num_2 * per_money 

		local remain_num = num - use_num
		if remain_num >= per_money then
			local act_id = ACT_ID.XFGIFTFT
   			ActivityBrilliantCtrl.Instance.ActivityReq(4,act_id,1)
   			return 
		end
		ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Xunbao)
	end

end
