--------------------------------------------------------
-- 日常活动视图  配置 StdActivityCfg
--------------------------------------------------------

local ActivityChildView = ActivityChildView or BaseClass(SubView)

function ActivityChildView:__init()
	self.texture_path_list[1] = "res/xui/activity.png"
	self:SetModal(true)
	self.config_tab = {
		{"activity_ui_cfg", 1, {0}},
		{"activity_ui_cfg", 2, {0}},
	}

	self.select_index = 1
	self.is_first_open = true
	self.cur_act_data = nil
	self.last_act_data = nil
end

function ActivityChildView:__delete()
end

function ActivityChildView:ReleaseCallBack()
	self.cur_act_data = nil
	self.last_act_data = nil
	self.is_first_open = true
	if self.act_type_list then
		self.act_type_list:DeleteMe()
		self.act_type_list = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.flush_list_timer then
		GlobalTimerQuest:CancelQuest(self.flush_list_timer)
		self.flush_list_timer = nil
	end
end

function ActivityChildView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self:CreateActivityTypeList()
		self:CreateRewardCells()
		self.node_t_list.btn_join.node:addClickEventListener(BindTool.Bind(self.OnClickJoinBtn, self))
		self.node_t_list.rich_acti_entry.node:setVerticalSpace(3)
		self.node_t_list.rich_acti_descrip.node:setVerticalSpace(3)
	end
end

function ActivityChildView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.is_first_open = true
	if nil == self.flush_list_timer then
		self.flush_list_timer = GlobalTimerQuest:AddDelayTimer(function()
				self:Flush(0, "flush_act_list") end, 300)
	end
end

function ActivityChildView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ActivityChildView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.select_index = 1
	self.act_type = nil
	if self.flush_list_timer then
		GlobalTimerQuest:CancelQuest(self.flush_list_timer)
		self.flush_list_timer = nil
	end	
end

--刷新界面
function ActivityChildView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then
			self.select_index = 1
			self:SetActTypeListData(v.select_type)
			self.act_type_list:SelectIndex(self.select_index)
			self.act_type_list:SetSelectItemToTop(self.select_index)
		elseif k == "content" then
			self:FlushContentView()
		elseif k == "flush_act_list" then
			self:SetActTypeListData()
			self.act_type_list:SelectIndex(self.select_index)
			if self.flush_list_timer then
				GlobalTimerQuest:CancelQuest(self.flush_list_timer)
				self.flush_list_timer = nil
			end
			self.flush_list_timer = GlobalTimerQuest:AddDelayTimer(function()
				self:Flush(0, "flush_act_list") end, 300)
		end
	end
end

function ActivityChildView:CreateActivityTypeList()
	local ph = self.ph_list.ph_activity_type_list
	self.act_type_list = ListView.New()
	self.act_type_list:Create(ph.x, ph.y, ph.w, ph.h, direction, ActTypeRender, nil, false, self.ph_list.ph_activity_item)
	self.act_type_list:SetItemsInterval(3)
	self.act_type_list:SetJumpDirection(ListView.Top)
	self.act_type_list:SetSelectCallBack(BindTool.Bind(self.SelectActivityTypeCallback, self))
	self.node_t_list.layout_main_panel.node:addChild(self.act_type_list:GetView(), 100)

end

function ActivityChildView:CreateRewardCells()
	self.cell_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_item_cell" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_main_panel.node:addChild(cell:GetView(), 103)
		table.insert(self.cell_list, cell)
	end

end

function ActivityChildView:SetRewardCellsData(type_id)
	local cur_award_t = ActivityData.GetOneTypeActivityAwardCfg(type_id)
	if nil == next(cur_award_t) then return end
	for i = 1, 4 do
		if self.cell_list[i]:GetData() then
			self.cell_list[i]:SetData(nil)
			if self.cell_list[i].cell_effc then
				self.cell_list[i].cell_effc:setVisible(false)
			end
		end
		-- self.cell_list[i]:SetVisible(i <= #cur_award_t)
	end
	for i,v in ipairs(cur_award_t) do
		if not self.cell_list[i] then break end
		self.cell_list[i]:SetData(v)
		if v.is_spec_effc then
			local cell_effc = AnimateSprite:create()
			cell_effc:setPosition(ph.w / 2, ph.h / 2)
			local path, name = ResPath.GetEffectUiAnimPath(920)
			if path and name then
				cell_effc:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			end
			cell_effc:setVisible(false)
			self.cell_list[i].cell_effc = cell_effc
			self.cell_list[i]:GetView():addChild(cell_effc, 100)
		end
		if self.cell_list[i].cell_effc then	
			self.cell_list[i].cell_effc:setVisible(true)
		end
	end
end

function ActivityChildView:SelectActivityTypeCallback(item)
	if self.cur_act_data then
		self.last_act_data = self.cur_act_data
	end
	if nil == item or nil == item:GetData() then return end
	if not self.last_act_data then
		self.last_act_data = item:GetData()
	end
	self.cur_act_data = item:GetData()
	self.select_index = item:GetIndex() or 1
	self:Flush(0, "content")
end

function ActivityChildView:OnClickJoinBtn()
	local cfg = ActivityData.GetOneTypeActivityCfg(self.cur_act_data.type)
	if not cfg or not next(cfg) then return end 
	local opt_str = cfg.Delivery

	if string.sub(opt_str, 1, 7) == "moveto," then
		local param = Split(string.sub(opt_str, 8, -1), ",")
		if param[1] then
			MoveCache.end_type = MoveEndType.Normal
			GuajiCtrl.Instance:FlyByIndex(param[1])
		end
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.Activity)
end

function ActivityChildView:SetActTypeListData(select_type)
	local data_t = ActivityData.AllActivitiesOpenTimeCfg()
	for k, v in ipairs(data_t) do
		if v.type == select_type then
			self.select_index = k
			break
		end
	end
	self.act_type_list:SetDataList(data_t)
end

function ActivityChildView:FlushContentView()
	if not self.cur_act_data then return end

	local data_t = ActivityData.GetOneTypeActivityCfg(self.cur_act_data.type)
	RichTextUtil.ParseRichText(self.node_t_list.rich_activity_time.node, self.cur_act_data.time_str, 20, COLOR3B.BRIGHT_GREEN)
	if self.cur_act_data.type ~= self.last_act_data.type or self.is_first_open then
		self.is_first_open = false
		self:SetRewardCellsData(self.cur_act_data.type)
		RichTextUtil.ParseRichText(self.node_t_list.rich_acti_name.node, data_t.name, 20)
		RichTextUtil.ParseRichText(self.node_t_list.rich_time_title.node, data_t.timeDesc)
		RichTextUtil.ParseRichText(self.node_t_list.rich_join_condition.node, data_t.ruleDesc, 20)
		RichTextUtil.ParseRichText(self.node_t_list.rich_acti_entry.node, data_t.entrance, 20)
		RichTextUtil.ParseRichText(self.node_t_list.rich_acti_descrip.node, data_t.desc, 20)
	end
end 

--活动类型itemrender
ActTypeRender = ActTypeRender or BaseClass(BaseRender)
function ActTypeRender:__init()
	
end

function ActTypeRender:__delete()
	self.img_act_bg = nil
	self.img_act_name = nil
	-- self.img9_text_bg = nil
	self.rch_opn_tm = nil
end

function ActTypeRender:CreateChild()
	BaseRender.CreateChild(self)
	self.img_act_bg = self.node_tree.img_cur_bg.node
	self.img_act_name = self.node_tree.img_act_name.node
	self.rch_opn_tm = self.node_tree.rich_open_time.node 
end

function ActTypeRender:OnFlush()
	if self.data == nil then return end
	self.img_act_bg:loadTexture(ResPath.GetBigPainting("daily_activity_" .. self.data.type))
	self.img_act_name:loadTexture(ResPath.GetActivityPic("activity_" .. self.data.type))
	if self.data.is_open_today <= 0 then
		self.node_tree.img_cur_bg.node:setGrey(true)
		self.img_act_name:setGrey(true)
	else
		self.node_tree.img_cur_bg.node:setGrey(self.data.is_over > 0 and true or false)
		self.img_act_name:setGrey(self.data.is_over > 0 and true or false)
	end
	local color = COLOR3B.BRIGHT_GREEN
	if self.img_act_bg:isGrey() then
		color = COLOR3B.OLIVE
	end
	local content = "(" .. self.data.time_str .. ")" .. self.data.open_day_str
	RichTextUtil.ParseRichText(self.rch_opn_tm, content, 24, color)
	self.rch_opn_tm:refreshView()	--获取富文本内容大小之前要刷新一下
	local size = self.rch_opn_tm:getInnerContainerSize()
	-- self.img9_text_bg:setContentWH(size.width + 10, size.height)
end

return ActivityChildView