CombinedServerActView = CombinedServerActView or BaseClass(BaseView)

function CombinedServerActView:LoadFashionView()
	self.node_t_list.btn_xb_toxunbao.node:addClickEventListener(BindTool.Bind(self.OnClickFashionXunbaoHandler, self))
	self.node_t_list.btn_xb_reward.node:addClickEventListener(BindTool.Bind(self.OnClickFashionRewardHandler, self))
	self:CreateFashionRewards()
end

function CombinedServerActView:DeleteFashionView()
	for k,v in pairs(self.fashion_reward_t) do
		v:DeleteMe()
	end
	self.fashion_reward_t = {}
end

function CombinedServerActView:CreateFashionRewards()
	self.fashion_reward_t = {}
	for i = 1,1 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_xunbao_cell"..i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		local size = cell:GetView():getContentSize()
		local cell_effct = RenderUnit.CreateEffect(929, cell:GetView(), 200, 0.23, nil, size.width / 2, size.height / 2)
		self.node_t_list.layout_fashion.node:addChild(cell:GetView(), 300)
		table.insert(self.fashion_reward_t, cell)
	end
	local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_fashion)
	local act_cfg = CombinedServerActData.GetCombinedServActCfg(act_id)
	if act_cfg then
		for i,v in ipairs(self.fashion_reward_t) do
			if act_cfg.awards[i] then
				local data =  act_cfg.awards[i]
				if data.type == tagAwardType.qatEquipment then
					v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = data.bind})
				else
					local virtual_item_id = ItemData.GetVirtualItemId(data.type)
					if virtual_item_id then
						v:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind = 0})
					end
				end
			end
			v:SetVisible(act_cfg.awards[i] ~= nil)
		end
	end
end

function CombinedServerActView:FlushFashionView(param_t)
	local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_fashion)
	local act_info = CombinedServerActData.Instance:GetActInfo(act_id)
	if nil == act_info then return end

	if nil ~= param_t and nil ~= param_t.result and nil ~= param_t.result.result then
		act_info.reward_count = param_t.result.result
	end

	local content = string.format(Language.CombinedServerAct.FashionDec, act_info.xb_count)
	RichTextUtil.ParseRichText(self.node_t_list.rich_xb_reward.node, content, 20)
	local curRewardContent = string.format(Language.CombinedServerAct.CurrentRewardDec, act_info.reward_count)
	RichTextUtil.ParseRichText(self.node_t_list.rich_reward_count.node, curRewardContent, 20);

	self.node_t_list.btn_xb_reward.node:setEnabled(act_info.reward_count > 0)
end

function CombinedServerActView:OnClickFashionXunbaoHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
end

function CombinedServerActView:OnClickFashionRewardHandler()
	local act_id = CombinedServerActData.GetActIdByIndex(self:GetShowIndex())
	CombinedServerActCtrl.SendSendCombinedReq(act_id)
end