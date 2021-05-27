XFZhuangPanView = XFZhuangPanView or BaseClass(ActTurnbleBaseView)

function XFZhuangPanView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function XFZhuangPanView:__delete()
	self:DeleteMoveTimer()

	if self.xf_zhuanpan_cell_list then 
		for k,v in pairs(self.xf_zhuanpan_cell_list) do
			v:DeleteMe()
		end
		self.xf_zhuanpan_cell_list = {}
	end

	self.cell_effect = nil
end

function XFZhuangPanView:InitView()
	self:CreateXfZpGridScroll()
	self.cell_effect = nil
	self.node_t_list.btn_go.node:addClickEventListener(BindTool.Bind(self.OnClickTurntableHandler, self))

	local eff_pos = self.ph_list["ph_zp_cell_1"]
	self.cell_effect = RenderUnit.CreateEffect(920, self.node_t_list.layout_xiaofei_zhuanpan.node, 999, nil, nil, eff_pos.x, eff_pos.y)
	self.cell_effect:setVisible(false)

	self.move_index = 1
	self.loop_num = 0
	self.turn_count = 0
	self.xf_zp_can_click = true
end

function XFZhuangPanView:RefreshView(param_t)
	local act_id = ACT_ID.XFZP
	local consum_gold = ActivityBrilliantData.Instance.consum_gold[act_id]
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XFZP)
	
	local num = ActivityBrilliantData.Instance:GetXFZPDrawNum() 
	local all_num = ActivityBrilliantData.Instance:GetXFZPAllDrawNum() 
	self.node_t_list.layout_xiaofei_zhuanpan.lbl_xf_zhuanpan.node:setString(consum_gold)
	self.node_t_list.layout_xiaofei_zhuanpan.lbl_zp_num.node:setString(string.format(Language.ActivityBrilliant.Text7, num))
	for k,v in pairs(param_t) do
		if k == "flush_view" and v.act_id == act_id and v.result and not self:GetIsIgnoreAction() then
			self.cell_effect:setVisible(true)
			self:CreateMoveTimer(v.result)
		else
			ItemData.Instance:SetDaley(not self.node_t_list.btn_go.node:isEnabled())
		end
	end
end

--登陆奖励
function XFZhuangPanView:CreateXfZpGridScroll()
	self.xf_zhuanpan_cell_list = {}
	for i=1,16 do 
		local cell = ActBaseCell.New()
		local ph = self.ph_list["ph_zp_cell_"..i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_xiaofei_zhuanpan.node:addChild(cell:GetView(), 300)
		table.insert(self.xf_zhuanpan_cell_list, cell)
	end
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XFZP)
	if act_cfg and act_cfg.config.award then	
		for i,v in ipairs(self.xf_zhuanpan_cell_list) do
			local data =  act_cfg.config.award[i].awards
			if data then
				if data.type == tagAwardType.qatEquipment then
					v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = data.bind, effectId = data.effectId})
				else
					local virtual_item_id = ItemData.GetVirtualItemId(data.type)
					if virtual_item_id then
						v:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind = data.bind or 0})
					end
				end
			else
				v:SetData()
			end
		end
	end
end

function XFZhuangPanView:UpdateXfZp(item_index)
	self.turn_count = self.turn_count  + 1
	if self.turn_count  < self.move_index * self.move_index / 24 then
		return
	end

	self.move_index = self.move_index + 1
	local index = self.move_index % 16
	if index == 0 then
		index = 16
	end

	if index == item_index and  self.move_index > 16 * 2 then
		self:DeleteMoveTimer()
		ItemData.Instance:SetDaley(false)
	end
		local ph = self.ph_list["ph_zp_cell_".. index]
	self.cell_effect:setPosition(ph.x,ph.y)
end

function XFZhuangPanView:OnClickTurntableHandler()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XFZP)
	local can_draw = ActivityBrilliantData.Instance:GetXFZPDrawNum() > 0 and ActivityBrilliantData.Instance:GetXFZPAllDrawNum() - ActivityBrilliantData.Instance:GetXFZPDrawNum() < act_cfg.config.params[2]
	self:UpdateAutoDrawTimer(4, can_draw) --每隔1秒抽一次

	if self:TryDrawIgnoreAction() then
		self.node_t_list.btn_go.node:setEnabled(true)
		ItemData.Instance:SetDaley(false)
		return
	end --成功则跳过动画

	self:OnClickDrawHandler()
end

function XFZhuangPanView:OnClickDrawHandler()
	ItemData.Instance:SetDaley(true)
	self.cell_effect:setVisible(false)
	if self.node_t_list.btn_go.node:isEnabled() then
		self:CreateMoveTimer(1)
	end

	local act_id = ACT_ID.XFZP
    if self.xf_zp_can_click then
   		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id)
   		self.xf_zp_can_click = false
   	end
end

function XFZhuangPanView:GetDrawNum()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XFZP)
	local consum_gold = ActivityBrilliantData.Instance.consum_gold[act_cfg.act_id]
	local num = 0
	local all_num =  math.floor(consum_gold / act_cfg.config.params[1])
	if all_num >= act_cfg.config.params[2] then
		all_num = act_cfg.config.params[2]
	end
	local yj_num = ActivityBrilliantData.Instance.xf_draw_num 
	local draw_num = all_num - yj_num
	local sy_num = all_num - yj_num
	return sy_num
end

function XFZhuangPanView:CreateMoveTimer(item_index)
	if self.move_timer then
		self:DeleteMoveTimer() 
	end
	local num = ActivityBrilliantData.Instance:GetXFZPDrawNum() 
	self.node_t_list.btn_go.node:setEnabled(num <= 0)
	self.move_index = 1
	self.loop_num = 0
	self.turn_count = 0
	self.move_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.UpdateXfZp, self, item_index), 0.05)
end

function XFZhuangPanView:DeleteMoveTimer()
	if self.move_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.move_timer)
		self.move_timer = nil
	end

	if self.node_t_list.btn_go then
		self.node_t_list.btn_go.node:setEnabled(true)
	end

	self.xf_zp_can_click = true
end