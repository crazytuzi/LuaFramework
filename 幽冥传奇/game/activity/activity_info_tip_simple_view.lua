ActivityCommonSimpleView = ActivityCommonSimpleView or BaseClass(XuiBaseView)

function ActivityCommonSimpleView:__init()
	self.texture_path_list[1] = "res/xui/activity.png"
	self.config_tab = {
						{"activity_ui_cfg", 8, {0}}
					}
	self.desc_data = nil 
	self.is_any_click_close = true
	
end

function ActivityCommonSimpleView:__delete()
	
end

function ActivityCommonSimpleView:ReleaseCallBack()
	if nil ~= self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
end

function ActivityCommonSimpleView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActivityCommonSimpleView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActivityCommonSimpleView:SetDescData(data)
	self.desc_data = data
	self:Flush()
end

function ActivityCommonSimpleView:OnFlush(paramt,index)
	-- self:ActivityShowReward()
	local color = COLOR3B.BRIGHT_GREEN
    RichTextUtil.ParseRichText(self.node_t_list.rich_act_name.node, self.desc_data.act_name, 20, COLOR3B.G_Y)
	RichTextUtil.ParseRichText(self.node_t_list.rich_acti_lev.node, Language.Activity.CommonViewLevel..self.desc_data.act_condDesc, 20, COLOR3B.YELLOW)
	RichTextUtil.ParseRichText(self.node_t_list.rich_acti_time.node, Language.Activity.CommonViewTime..self.desc_data.act_timeDesc, 20, COLOR3B.YELLOW)
	RichTextUtil.ParseRichText(self.node_t_list.rich_acti_descrip.node, self.desc_data.act_ruleDesc, 20, COLOR3B.GREEN)
	self.node_tree.layout_activity_simple_tip.img_icon.node:loadTexture(ResPath.GetMainui("act_icon_" .. self.desc_data.icon))
	if self.desc_data.act_rank == 1 or self.desc_data.act_rank == 2 then
		self.node_tree.layout_activity_simple_tip.rank_img.node:loadTexture(ResPath.GetActivityPic("rank_12"))
	elseif self.desc_data.act_rank == 3 or self.desc_data.act_rank == 4 then
		self.node_tree.layout_activity_simple_tip.rank_img.node:loadTexture(ResPath.GetActivityPic("rank_34"))
	else
		self.node_tree.layout_activity_simple_tip.rank_img.node:loadTexture(ResPath.GetActivityPic("rank_5"))
	end

end

function ActivityCommonSimpleView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		-- self:CreateRewardCell()
		XUI.AddClickEventListener(self.node_t_list.btn_join.node, BindTool.Bind2(self.OnAcitiviJoinBtn, self))
	end
end

function ActivityCommonSimpleView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ActivityCommonSimpleView:OnAcitiviJoinBtn()
	-- if self.desc_data == nil then return end
	-- ActivityCtrl.Instance:SendActiveGuidanceReq(self.desc_data.act_id)
	if self.desc_data == nil then return end
	if ActivityData.IsSwitchToOtherView(self.desc_data.act_teleId) then
		local tele_cfg = ActivityData.GetCommonTeleCfg(self.desc_data.act_teleId)
		ActivityCtrl.Instance:OpenOneActView(tele_cfg)
		ViewManager.Instance:Close(ViewName.Activity)
	else
		ActivityCtrl.Instance:SendActiveGuidanceReq(self.desc_data.act_id)
	end
	ViewManager.Instance:Close(ViewName.ActivityCalendar)
	self:Close()
end

function ActivityCommonSimpleView:ActivityShowReward()
	if nil == self.cell_gift_list then return end
	local cur_data = {}
	for i, v in ipairs(self.desc_data.act_showAwards) do
		if v.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if virtual_item_id then
				cur_data[i] = {["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0}
			end
		else
			cur_data[i] = {item_id = v.id, num = v.count, is_bind = 0}
		end
	end
	local vis = false
	for i1, v1 in ipairs(cur_data) do
		for i1 = 1, 6 do
			vis = cur_data[i1] and true or false
			self.cell_gift_list[i1]:GetView():setVisible(vis)
		end
		self.cell_gift_list[i1]:SetData(v1)
	end

end

function ActivityCommonSimpleView:CreateRewardCell()
	self.cell_gift_list = {}
	for i = 1, 6 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		self.node_t_list.layout_gift_cells.node:addChild(cell:GetView(), 300)

		-- local cell_effect = AnimateSprite:create()
		-- cell_effect:setPosition(ph.x, ph.y)
		-- self.node_t_list.layout_gift_cells.node:addChild(cell_effect, 300)
		-- cell_effect:setVisible(false)
		-- cell.cell_effect = cell_effect

		table.insert(self.cell_gift_list, cell)
	end
end