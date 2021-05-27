CombinedServerActView = CombinedServerActView or BaseClass(BaseView)

function CombinedServerActView:LoadGongchengView()
	self.node_t_list.btn_gc_reward.node:addClickEventListener(BindTool.Bind(self.OnClickGcRewardHandler, self))
	self:CreateGongchengRewards()
end

function CombinedServerActView:DeleteGongchengView()
	for k,v in pairs(self.gongcheng_reward_t) do
		v:DeleteMe()
	end
	self.gongcheng_reward_t = {}
end

function CombinedServerActView:CreateGongchengRewards()
	self.gongcheng_reward_t = {}
	for i = 1, 4 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_awrad_gongcheng_"..i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_award_gongchneg.node:addChild(cell:GetView(), 300)
		table.insert(self.gongcheng_reward_t, cell)
	end
	local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_gongcheng)
	local act_cfg = CombinedServerActData.GetCombinedServActCfg(act_id)
	if act_cfg then
		for i,v in ipairs(self.gongcheng_reward_t) do
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

function CombinedServerActView:FlushGongchengView(param_t)
	local act_id = CombinedServerActData.GetActIdByIndex(TabIndex.combinedserv_gongcheng)
	local act_info = CombinedServerActData.Instance:GetActInfo(act_id)
	if nil == act_info then return end
	self.node_t_list.btn_gc_reward.node:setEnabled(act_info.act_state == 1)
end

function CombinedServerActView:OnClickGcRewardHandler()
	local act_id = CombinedServerActData.GetActIdByIndex(self:GetShowIndex())
	CombinedServerActCtrl.SendSendCombinedReq(act_id)
end