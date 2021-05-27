ActivityOpenCommonView = ActivityOpenCommonView or BaseClass(XuiBaseView)

function ActivityOpenCommonView:__init()
	self.texture_path_list[1] = "res/xui/activity.png"
	self.config_tab = {
						{"activity_ui_cfg", 3, {0}}
					}
	self.desc_data = nil 
	self.is_any_click_close = true
	
end

function ActivityOpenCommonView:__delete()
	
end

function ActivityOpenCommonView:ReleaseCallBack()
	if nil ~= self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
end

function ActivityOpenCommonView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActivityOpenCommonView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActivityOpenCommonView:SetDescData(data)
	self.desc_data = data
	self:Flush()
end

function ActivityOpenCommonView:OnFlush(paramt,index)
	-- local color = COLOR3B.BRIGHT_GREEN
	-- local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
	-- local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)		-- 人物转生等级

 --    RichTextUtil.ParseRichText(self.node_t_list.rich_act_name.node, self.desc_data.cfg.act_name, 20, COLOR3B.G_Y)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_acti_lev.node, self.desc_data.cfg.act_condDesc, 20, color)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_acti_time.node, self.desc_data.cfg.act_timeDesc, 20, color)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_acti_descrip.node, self.desc_data.cfg.act_ruleDesc, 20, COLOR3B.G_W2)
	-- self.node_t_list.btn_actjoin.node:addClickEventListener(BindTool.Bind(self.OnAcitiviJoinBtn, self))

	-- if circle_level >= self.desc_data.cfg.act_levelLimit[1] and role_level >= self.desc_data.cfg.act_levelLimit[2] then
	-- 	if self.desc_data.cfg.act_max_num ~= 0 then
	-- 		if self.desc_data.cfg.act_remain_num == self.desc_data.cfg.act_max_num then
	-- 			self.node_t_list.btn_actjoin.node:setEnabled(false)
	-- 		else
	-- 			self.node_t_list.btn_actjoin.node:setEnabled(true)
	-- 		end
	-- 	else
	-- 		if self.desc_data.is_open == 0 or self.desc_data.is_over == 1 or self.desc_data.is_open_today == 0 then
	-- 			self.node_t_list.btn_actjoin.node:setEnabled(false)	
	-- 		elseif self.desc_data.is_open ==1 or self.desc_data.is_over == 0 or self.desc_data.is_open_today == 1 then
	-- 			self.node_t_list.btn_actjoin.node:setEnabled(true)
	-- 		end
	-- 	end
	-- else
	-- 	self.node_t_list.btn_actjoin.node:setEnabled(false)
	-- end

	local color = COLOR3B.BRIGHT_GREEN
    RichTextUtil.ParseRichText(self.node_t_list.rich_act_name.node, self.desc_data.act_name, 20, COLOR3B.G_Y)
	RichTextUtil.ParseRichText(self.node_t_list.rich_acti_lev.node, Language.Activity.CommonViewLevel..self.desc_data.act_condDesc, 20, COLOR3B.YELLOW)
	RichTextUtil.ParseRichText(self.node_t_list.rich_acti_time.node, Language.Activity.CommonViewTime..self.desc_data.act_timeDesc, 20, COLOR3B.YELLOW)
	RichTextUtil.ParseRichText(self.node_t_list.rich_acti_descrip.node, self.desc_data.act_ruleDesc, 20, COLOR3B.GREEN)
	local achieve_cfg = ActivityData.Instance:GetOneAchieveCfgByAchiID(self.desc_data.act_acheveid)
	self.node_tree.layout_activity_common_bg.txt_active_degree.node:setString(achieve_cfg.awards[1].count)

	self:ActivityShowReward()
	-- local achieve_cfg = ActivityData.Instance:GetOneAchieveCfgByAchiID(self.desc_data.act_acheveid)
	local finish_cond = achieve_cfg.conds[1].count
	local is_finish = AchieveData.Instance:GetAwardState(self.desc_data.act_acheveid) and AchieveData.Instance:GetAwardState(self.desc_data.act_acheveid).finish == 1 and true or false
	local prog = nil 
	if is_finish then 
		prog = Language.Activity.Descfinish
	else
		prog = AchieveData.Instance:GetAchieveFinishCount(achieve_cfg.conds[1].eventId).count .. "/" .. finish_cond
	end
	RichTextUtil.ParseRichText(self.node_tree.layout_activity_common_bg.txt_rest_time.node, prog, nil, COLOR3B.YELLOW)
	--self.node_tree.layout_activity_common_bg.txt_rest_time.node:setString(prog)
	self.node_tree.layout_activity_common_bg.img_icon.node:loadTexture(ResPath.GetMainui("act_icon_" .. self.desc_data.icon))

	if self.desc_data.act_rank == 1 or self.desc_data.act_rank == 2 then
		self.node_tree.layout_activity_common_bg.rank_img.node:loadTexture(ResPath.GetActivityPic("rank_12"))
	elseif self.desc_data.act_rank == 3 or self.desc_data.act_rank == 4 then
		self.node_tree.layout_activity_common_bg.rank_img.node:loadTexture(ResPath.GetActivityPic("rank_34"))
	else
		self.node_tree.layout_activity_common_bg.rank_img.node:loadTexture(ResPath.GetActivityPic("rank_5"))
	end

end

function ActivityOpenCommonView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self:CreateRewardCell()
		XUI.AddClickEventListener(self.node_t_list.btn_join.node, BindTool.Bind2(self.OnAcitiviJoinBtn, self))
	end
end

function ActivityOpenCommonView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ActivityOpenCommonView:OnAcitiviJoinBtn()
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

function ActivityOpenCommonView:ActivityShowReward()
	if nil == self.cell_gift_list then return end
	local cur_data = ItemData.AwardsToItems(self.desc_data.act_showAwards)
	local vis = false
	for i1 = 1, 6 do
		vis = cur_data[i1] and true or false
		self.cell_gift_list[i1]:GetView():setVisible(vis)
		self.cell_gift_list[i1]:SetData(cur_data[i1])
	end
end

function ActivityOpenCommonView:CreateRewardCell()
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