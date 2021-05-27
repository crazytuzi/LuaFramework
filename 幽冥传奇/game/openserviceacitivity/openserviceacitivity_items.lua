-- OpenSevrAthleticAwardItem 开服竞技奖励item
OpenSevrAthleticAwardItem = OpenSevrAthleticAwardItem or BaseClass(BaseRender)
function OpenSevrAthleticAwardItem:__init()
	self.is_first_created = true
end

function OpenSevrAthleticAwardItem:__delete()
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
	self.awar_icon = nil
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.is_first_created = true
end

function OpenSevrAthleticAwardItem:CreateChild()
	BaseRender.CreateChild(self)
	self.interval = 2
	local ph = self.ph_list.ph_cells_list
	self.cell_item_ui_cfg = self.ph_list.ph_cell_1
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, GridCell, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list:SetItemsInterval(self.interval)
	self.view:addChild(self.cells_list:GetView(), 90)
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnFetchClicked, self), true)
	self.node_tree.btn_fetch.node:setLocalZOrder(100)
	self.node_tree.txt_fetch_awar_time.node:setLocalZOrder(100)
	self.node_tree.txt_fetch_awar.node:setLocalZOrder(100)
end

function OpenSevrAthleticAwardItem:OnFlush()
	if not self.data then return end
	-- if self.index == 1 then
	-- 	print("第一名信息：", self.data.top1_name, self.data.top1_role_id)
	-- end
	if not self.awar_icon then
		local img_ph = self.ph_list.ph_open_cell
		local path = ResPath.GetOpenServerActivities("athletic_1")
		self.awar_icon = XUI.CreateImageView(img_ph.x, img_ph.y, path, true)
		self.view:addChild(self.awar_icon, 100)
	end
	if self.data.act_type == OPEN_ATHLETICS_TYPE.Leveling then
		path = ResPath.GetOpenServerActivities("athletic_1")
	else
		path = ResPath.GetOpenServerActivities("athletic_" .. self.data.icon)
	end
	self.awar_icon:loadTexture(path)
	self:SetCellsListData(self.data.awards)
	self.node_tree.txt_item_name.node:setString(self.data.desc)
	if self.data.top1_name and self.data.top1_role_id then
		local main_role_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)
		self.node_tree.img_state.node:setVisible(self.data.top1_name == "")
		self.node_tree.btn_fetch.node:setVisible(false)
		self.node_tree.txt_rest_title.node:setString(Language.OpenServiceAcitivity.TopOne)
		self.node_tree.txt_rest_cnt.node:setString(self.data.top1_name ~= "" and self.data.top1_name or Language.Common.ZanWu)
		self.node_tree.txt_top1_lv.node:setString("")
		self.node_tree.txt_fetch_awar_time.node:setString("")
		self.node_tree.txt_fetch_awar.node:setString("")
		if self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		end
		if self.data.top1_name ~= "" then
			local top1_lv_str = ""
			if self.data.act_type ~= OPEN_ATHLETICS_TYPE.Wing and self.data.act_type ~= OPEN_ATHLETICS_TYPE.Hero and
			 self.data.act_type ~= OPEN_ATHLETICS_TYPE.Ride and self.data.act_type ~= OPEN_ATHLETICS_TYPE.BossScore and
			 self.data.act_type ~= OPEN_ATHLETICS_TYPE.Stone then
				if self.data.act_type == OPEN_ATHLETICS_TYPE.Leveling then
					local step, star = ZhuanshengData.Instance:GetStepStar(self.data.stage)
					top1_lv_str = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.data.act_type), step, star, self.data.lev)
				else
					top1_lv_str = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.data.act_type), self.data.stage, self.data.lev)
				end
			else
				top1_lv_str = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.data.act_type), self.data.stage)
			end
			self.node_tree.txt_top1_lv.node:setString(top1_lv_str)
			self:SetTimerCountDown()
		end
		-- else
			-- self.node_tree.img_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
		-- end
	else
		-- if self.is_first_created then
		-- 	self.is_first_created = false
		-- 	self.node_tree.txt_rest_title.node:setPositionY(self.node_tree.txt_rest_title.node:getPositionY() - 15)
		-- 	self.node_tree.txt_rest_cnt.node:setPositionY(self.node_tree.txt_rest_cnt.node:getPositionY() - 15)
		-- end
		local rest_cnt = self.data.rest_cnt >= 0 and self.data.rest_cnt or 0  
		self.node_tree.txt_rest_cnt.node:setString(self.data.max_cnt == -1 and Language.OpenServiceAcitivity.NoLimit or rest_cnt)
		self.node_tree.btn_fetch.node:setVisible(self.data.state == OPEN_ATHLETICS_FETCH_STATE.CAN_FETCH)
		self.node_tree.img_state.node:setVisible(self.data.state ~= OPEN_ATHLETICS_FETCH_STATE.CAN_FETCH)
		if self.node_tree.img_state.node:isVisible() then
			local path = ""
			if self.data.state == OPEN_ATHLETICS_FETCH_STATE.NOT_COMPLETE then
				path = ResPath.GetCommon("stamp_3")
			elseif self.data.state == OPEN_ATHLETICS_FETCH_STATE.HAVE_FETCHED then
				path = ResPath.GetCommon("stamp_10")
			elseif self.data.state == OPEN_ATHLETICS_FETCH_STATE.NO_CNT then
				path = ResPath.GetCommon("stamp_11")
			end
			self.node_tree.img_state.node:loadTexture(path)
		end
	end
end

-- 设置倒计时
function OpenSevrAthleticAwardItem:SetTimerCountDown()
	if nil == self.data then return end
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if not self.timer_quest then
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SetTimerCountDown, self), 60)
	end
	local server_time = TimeCtrl.Instance:GetServerTime() or 0
	local format_time = os.date("*t", server_time)		--获取年月日时分秒的表
	local now_time = (format_time.hour * 60 + format_time.min) * 60 + format_time.sec
	local remain_time = (OpenServerCfg.OpenServerDay - OtherData.Instance:GetOpenServerDays() + 1) * 24 * 3600 - now_time

	if remain_time <= 0 then
		self.node_tree.txt_fetch_awar_time.node:setString("")
		self.node_tree.txt_fetch_awar.node:setString("")
		if self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		end
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(remain_time)
	self.node_tree.txt_fetch_awar_time.node:setString(string.format(Language.OpenServiceAcitivity.CountDownTime, time_tab.day, time_tab.hour, time_tab.min))
	self.node_tree.txt_fetch_awar.node:setString(Language.OpenServiceAcitivity.Fetch)
end

function OpenSevrAthleticAwardItem:SetCellsListData(data)
	if data == nil then return end
	self.cells_list:SetData(data)
	local ph = self.ph_list.ph_cells_list
	local len = #data
	if len < 3 then
		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
		self.cells_list:GetView():setPosition(ph.x - 15 + (ph.w - w) * 0.5, ph.y)
	else
		self.cells_list:GetView():setPosition(ph.x, ph.y)
	end	
end

function OpenSevrAthleticAwardItem:OnFetchClicked()
	if not self.data then return end
	if self.data.act_type then
		OpenServiceAcitivityCtrl.Instance:SendGetOpenServerAcitivityRewardReq(self.data.act_type, self.data.idx)
	else
		OpenServiceAcitivityCtrl.Instance:GetOpenSerGuildReward(self.data.idx)
	end
end

-- 创建选中特效
function OpenSevrAthleticAwardItem:CreateSelectEffect()
	
end


------------------------------------------
-- OpenSerRaceStandardRender 达标比拼
------------------------------------------
OpenSerRaceStandardRender = OpenSerRaceStandardRender or BaseClass(BaseRender)
function OpenSerRaceStandardRender:__init()
	
end

function OpenSerRaceStandardRender:__delete()
	-- if self.cells_list_1 then
	-- 	self.cells_list_1:DeleteMe()
	-- 	self.cells_list_1 = nil
	-- end

	if self.exaward_cell then
		self.exaward_cell:DeleteMe()
		self.exaward_cell = nil
	end

	if self.standard_info_list then
		self.standard_info_list:DeleteMe()
		self.standard_info_list = nil
	end
end

function OpenSerRaceStandardRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_title_1.node)
	self.node_tree.rich_title_1.node:setVerticalAlignment(RichVAlignment.VA_CENTER)
	-- XUI.RichTextSetCenter(self.node_tree.rich_title_2.node)
	self.interval = 6
	self.cell_item_ui_cfg = self.ph_list.ph_cell_1_1
	self.exaward_cell = OpenRaceCell.New()
	self.exaward_cell:SetPosition(self.cell_item_ui_cfg.x, self.cell_item_ui_cfg.y)
	self.exaward_cell:GetView():setPropagateTouchEvent(false)
	self.view:addChild(self.exaward_cell:GetView(), 99)
	-- self.cells_list_1 = ListView.New()
	-- self.cells_list_1:Create(self.ph_list.ph_cell_list_1.x, self.ph_list.ph_cell_list_1.y,self.ph_list.ph_cell_list_1.w, self.ph_list.ph_cell_list_1.h, ScrollDir.Horizontal, OpenRaceCell, gravity, is_bounce, self.cell_item_ui_cfg)
	-- self.cells_list_1:SetItemsInterval(self.interval)
	-- self.view:addChild(self.cells_list_1:GetView(), 99)
	-- self.cells_list_1:GetView():setPropagateTouchEvent(false)

	local ph = self.ph_list.ph_standard_info_list
	self.standard_info_list = ListView.New()
	self.standard_info_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Vertical, OpenRaceStandardInfoItem, ListViewGravity.Bottom, is_bounce, self.ph_list.ph_standard_info_item)
	self.standard_info_list:SetItemsInterval(3)
	self.standard_info_list:SetJumpDirection(ListView.Top)
	self.standard_info_list:GetView():setPropagateTouchEvent(false)
	self.view:addChild(self.standard_info_list:GetView(), 99)
	-- ph = self.ph_list.ph_rich_link_2
	-- self.text_node_2 = RichTextUtil.CreateLinkText("", 18, COLOR3B.YELLOW, nil, true)
	-- self.text_node_2:setPosition(ph.x, ph.y)
	-- self.text_node_2:setString(Language.OpenServiceAcitivity.RaceTipLink)
	-- -- self.text_node_2:setColor(COLOR3B.GREEN)
	-- self.view:addChild(self.text_node_2, 999)
	-- XUI.AddClickEventListener(self.text_node_2, BindTool.Bind(self.QuickLinksTwo, self), true)
end

function OpenSerRaceStandardRender:OnFlush()
	if not self.data then return end
	RichTextUtil.ParseRichText(self.node_tree.rich_title_1.node, self.data.activityRankName or "", 22)
	-- RichTextUtil.ParseRichText(self.node_tree.rich_title_2.node, self.data.activityName or "", 20)
	RichTextUtil.ParseRichText(self.node_tree.rich_des_1.node, self.data.activityRank or "", 18)
	-- RichTextUtil.ParseRichText(self.node_tree.rich_des_2.node, self.data.activityDesc or "", 18)
	local content = Language.OpenServiceAcitivity.RaceMyRank[1]
	if self.data.my_rank > 0 then
		content = string.format(Language.OpenServiceAcitivity.RaceMyRank[2], self.data.my_rank)
	end
	self.node_tree.txt_my_rank.node:setString(content)
	content = Language.Common.ZanWu
	if self.data.top1_name and self.data.top1_name ~= "" then
		content = self.data.top1_name
	end
	content = Language.Common.Top1Name .. content
	self.node_tree.txt_top_1_name.node:setString(content)
	if nil == self.exaward_cell:GetData() then
		local show_data = self:GetShowAwardsData(self.data.exAwards)
		-- self:SetCellsData(show_data)
		self.exaward_cell:SetData(show_data[1])
	end
	self.standard_info_list:SetDataList(self.data.Rewards)
end

function OpenSerRaceStandardRender:GetShowAwardsData(data)
	local exAwards = {}
	if data then
		local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		for _, v in ipairs(data) do
			if (nil == v.job and nil == v.sex) or (v.job and v.sex and v.job == job and v.sex == sex) or
						(v.job and v.sex == nil and v.job == job) or (v.job == nil and v.sex and v.sex == sex) then
				table.insert(exAwards, {item_id = v.id, num = v.count, is_bind = v.bind, 
					strengthen_level = v.strong or 0, infuse_level = 0, is_equip = ItemData.GetIsEquip(v.id)})
			end
		end
	end
	return exAwards
end

function OpenSerRaceStandardRender:SetCellsData(data)
	if data == nil then return end
	self.cells_list_1:SetData(data)
	local ph = self.ph_list.ph_cell_list_1
	local len = #data
	if len < 3 then
		-- local interval = self.cells_list_1:GetView():getItemsInterval()
		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
		self.cells_list_1:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
	else
		self.cells_list_1:GetView():setPosition(ph.x, ph.y)
	end	
end

function OpenSerRaceStandardRender:QuickLinksTwo()
	if self.data == nil then return end
end

function OpenSerRaceStandardRender:FetchAward()
	-- if self.data == nil then return end
	-- OpenSerRaceStandardCtrl.OpenSerRaceStandardAwardReq(self.data.act_id)
end

OpenRaceCell = OpenRaceCell or BaseClass(BaseCell)
function OpenRaceCell:__init()
end

function OpenRaceCell:OnFlush()
	if nil == self.data then return end
	BaseCell.OnFlush(self)
	self:SetQualityEffect(7, 1)
end

function OpenRaceCell:CreateSelectEffect()

end

-- OpenRaceStandardInfoItem 开服达标奖励item
OpenRaceStandardInfoItem = OpenRaceStandardInfoItem or BaseClass(BaseRender)
function OpenRaceStandardInfoItem:__init()
	
end

function OpenRaceStandardInfoItem:__delete()
	if self.cells_list_2 then
		self.cells_list_2:DeleteMe()
		self.cells_list_2 = nil
	end
	self.awar_icon = nil
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function OpenRaceStandardInfoItem:CreateChild()
	BaseRender.CreateChild(self)
	self.interval = 4
	local ph = self.ph_list.ph_cell_list_2
	self.cell_item_ui_cfg = self.ph_list.ph_cell_1
	self.cells_list_2 = ListView.New()
	self.cells_list_2:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, GridCell, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list_2:SetItemsInterval(self.interval)
	self.view:addChild(self.cells_list_2:GetView(), 99)
	self.cells_list_2:GetView():setTouchEnabled(false)
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnFetchClicked, self), true)
	local bg_path = self.index % 2 ~= 0 and ResPath.GetCommon("img9_158") or ResPath.GetCommon("img9_206")
	self.node_tree.item_bg.node:loadTexture(bg_path)
	-- self.node_tree.txt_fetch_awar_time.node:setLocalZOrder(100)
	-- self.node_tree.txt_fetch_awar.node:setLocalZOrder(100)
end

function OpenRaceStandardInfoItem:OnFlush()
	if not self.data then return end
	-- if self.index == 1 then
	-- 	print("第一名信息：", self.data.top1_name, self.data.top1_role_id)
	-- end
	if not self.awar_icon then
		local img_ph = self.ph_list.ph_open_cell
		local path = ""
		if self.data.act_id == OPEN_SER_RACE_STANDARD_TYPE.Level then
			path = ResPath.GetOpenServerActivities("athletic_1")
		else
			path = ResPath.GetOpenServerActivities("athletic_" .. self.data.icon)
		end
		self.awar_icon = XUI.CreateImageView(img_ph.x, img_ph.y, path, true)
		self.view:addChild(self.awar_icon, 100)
		self.node_tree.txt_item_name.node:setString(self.data.desc)
	end
	local show_data = self:GetShowAwardsData(self.data.awards)
	self:SetCellsListData(show_data)

	if self.data.top1_name and self.data.top1_role_id then
		local main_role_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)
		self.node_tree.img_state.node:setVisible(self.data.top1_name == "")
		self.node_tree.btn_fetch.node:setVisible(false)
		-- self.node_tree.txt_rest_title.node:setString(Language.OpenServiceAcitivity.TopOne)
		self.node_tree.txt_rest_cnt.node:setString(self.data.top1_name ~= "" and self.data.top1_name or Language.Common.ZanWu)
		self.node_tree.txt_top1_lv.node:setString("")
		self.node_tree.txt_fetch_awar_time.node:setString("")
		self.node_tree.txt_fetch_awar.node:setString("")
		if self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		end
		if self.data.top1_name ~= "" then
			local top1_lv_str = ""
			if self.data.act_type ~= OPEN_ATHLETICS_TYPE.Wing and self.data.act_type ~= OPEN_ATHLETICS_TYPE.Hero and
			 self.data.act_type ~= OPEN_ATHLETICS_TYPE.Ride and self.data.act_type ~= OPEN_ATHLETICS_TYPE.BossScore and
			 self.data.act_type ~= OPEN_ATHLETICS_TYPE.Stone then
				if self.data.act_type == OPEN_ATHLETICS_TYPE.Leveling then
					local step, star = ZhuanshengData.Instance:GetStepStar(self.data.stage)
					top1_lv_str = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.data.act_type), step, star, self.data.lev)
				else
					top1_lv_str = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.data.act_type), self.data.stage, self.data.lev)
				end
			else
				top1_lv_str = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.data.act_type), self.data.stage)
			end
			self.node_tree.txt_top1_lv.node:setString(top1_lv_str)
			self:SetTimerCountDown()
		else
			self.node_tree.img_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
		end
	else
		self.node_tree.txt_rest_cnt.node:setString(self.data.rest_cnt == -1 and Language.OpenServiceAcitivity.NoLimit or self.data.rest_cnt)
		self.node_tree.btn_fetch.node:setVisible(self.data.state == OPEN_ATHLETICS_FETCH_STATE.CAN_FETCH)
		self.node_tree.img_state.node:setVisible(self.data.state ~= OPEN_ATHLETICS_FETCH_STATE.CAN_FETCH)
		if self.node_tree.img_state.node:isVisible() then
			local path = ""
			if self.data.rest_cnt == -1 or self.data.rest_cnt > 0 then
				if self.data.state == OPEN_ATHLETICS_FETCH_STATE.NOT_COMPLETE then
					path = ResPath.GetCommon("stamp_3")
				elseif self.data.state == OPEN_ATHLETICS_FETCH_STATE.HAVE_FETCHED then
					path = ResPath.GetCommon("stamp_10")
				end
			elseif self.data.rest_cnt == 0 then
				path = ResPath.GetCommon("stamp_11")
			end
			self.node_tree.img_state.node:loadTexture(path)
		end
	end
end

function OpenRaceStandardInfoItem:GetShowAwardsData(data)
	local awards_data = {}
	if data then
		local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		for _, v in ipairs(data) do
			if (nil == v.job and nil == v.sex) or (v.job and v.sex and v.job == job and v.sex == sex) or
						(v.job and v.sex == nil and v.job == job) or (v.job == nil and v.sex and v.sex == sex) then
				table.insert(awards_data, {item_id = v.id, num = v.count, is_bind = v.bind, 
					strengthen_level = v.strong or 0, infuse_level = 0, is_equip = ItemData.GetIsEquip(v.id)})
			end
		end
	end
	return awards_data
end

function OpenRaceStandardInfoItem:SetCellsListData(data)
	if data == nil then return end
	self.cells_list_2:SetData(data)
	for _, v in pairs(self.cells_list_2:GetAllItems()) do
		v:GetView():setScale(0.8)
	end
	local ph = self.ph_list.ph_cell_list_2
	local len = #data
	if len < 3 then
		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
		self.cells_list_2:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
	else
		self.cells_list_2:GetView():setPosition(ph.x, ph.y)
	end	
end

-- 设置倒计时
function OpenRaceStandardInfoItem:SetTimerCountDown()
	if nil == self.data then return end
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if not self.timer_quest then
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SetTimerCountDown, self), 60)
	end
	local server_time = TimeCtrl.Instance:GetServerTime() or 0
	local format_time = os.date("*t", server_time)		--获取年月日时分秒的表
	local now_time = (format_time.hour * 60 + format_time.min) * 60 + format_time.sec
	local remain_time = (OpenServerCfg.OpenServerDay - OtherData.Instance:GetOpenServerDays() + 1) * 24 * 3600 - now_time

	if remain_time <= 0 then
		self.node_tree.txt_fetch_awar_time.node:setString("")
		self.node_tree.txt_fetch_awar.node:setString("")
		if self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		end
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(remain_time)
	self.node_tree.txt_fetch_awar_time.node:setString(string.format(Language.OpenServiceAcitivity.CountDownTime, time_tab.day, time_tab.hour, time_tab.min))
	self.node_tree.txt_fetch_awar.node:setString(Language.OpenServiceAcitivity.Fetch)
end

function OpenRaceStandardInfoItem:OnFetchClicked()
	if not self.data then return end
	OpenSerRaceStandardCtrl.OpenSerRaceStandardAwardReq(self.data.act_id, self.data.idx)
end

-- 创建选中特效
function OpenRaceStandardInfoItem:CreateSelectEffect()
	
end

OpenSerAddupChargeItem = OpenSerAddupChargeItem or BaseClass(BaseRender)
function OpenSerAddupChargeItem:__init()

end

function OpenRaceStandardInfoItem:__delete()
	if self.award_cell then
		self.award_cell:DeleteMe()
		self.award_cell = nil
	end

	if self.quality_effect then
		self.quality_effect:setStop()
		self.quality_effect = nil
	end
end

function OpenSerAddupChargeItem:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_day.node:loadTexture(ResPath.GetOpenServerActivities("charge_day" .. self.index))
	self.node_tree.img_stamp.node:setVisible(false)
end

function OpenSerAddupChargeItem:OnFlush()
	if not self.data then return end
	self:SetCellData(self.data.award)
	self.node_tree.img_stamp.node:setVisible(self.data.is_get)
	local effect_id = self.data.is_show_eff and 8 or 0
	self:SetQualityEffect(effect_id)
end

function OpenSerAddupChargeItem:CreateSelectEffect()

end

--设置品质特效
function OpenSerAddupChargeItem:SetQualityEffect(effect_id, scale)
	scale = scale or 1
	if effect_id > 0 and nil == self.quality_effect then
		local ph = self.ph_list.ph_cell
		self.quality_effect = AnimateSprite:create()
		self.quality_effect:setPosition(ph.x, ph.y)
		self.view:addChild(self.quality_effect, 99, 99)
	end

	if nil ~= self.quality_effect then
		if effect_id > 0 then
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
			self.quality_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
			self.quality_effect:setScale(scale)
		else
			self.quality_effect:setStop()
		end
		self.quality_effect:setVisible(effect_id > 0)
	end
end

function OpenSerAddupChargeItem:SetCellData(data)
	if not self.award_cell then
		local ph = self.ph_list.ph_cell
		self.award_cell = BaseCell.New()
		self.award_cell:SetPosition(ph.x, ph.y)
		self.award_cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.award_cell:GetView(), 2)
		self.award_cell:SetData(data)
		self.award_cell.bg_img:setVisible(false)
	end
	self.award_cell:SetQualityBgVis(false)
end


OpenSerWayItemRender = OpenSerWayItemRender or BaseClass(BaseRender)
function OpenSerWayItemRender:__init()

end

function OpenRaceStandardInfoItem:__delete()
	if self.award_cell then
		self.award_cell:DeleteMe()
		self.award_cell = nil
	end
end

function OpenSerWayItemRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.img_icon.node, BindTool.Bind(self.OpenView, self), true)
	self.node_tree.img_way_word.node:setVisible(false)
end

function OpenSerWayItemRender:OnFlush()
	if not self.data then return end
	self.node_tree.img_icon.node:loadTexture(ResPath.GetMainui("icon_"..self.data.icon.."_img"))
	self.node_tree.img_way_word.node:setVisible(self.data.text ~= nil)
	if self.data.text then
		self.node_tree.img_way_word.node:loadTexture(ResPath.GetMainui("icon_"..self.data.text.."_word"))
	end
end

function OpenSerWayItemRender:CreateSelectEffect()

end

function OpenSerWayItemRender:OpenView()
	if self.data == nil then return end 
	if self.data.activityId == nil then
		if self.data.fun and next(self.data.fun) then
			local index = self.data.fun[2]
			local name = self.data.fun[1]
			if name ~= "Shop" then
				if IS_ON_CROSSSERVER then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
					return 
				end
			end
			if index ~= nil then
				ViewManager.Instance:Open(name, index)
			else
				ViewManager.Instance:Open(name)
			end
			if  name == "Shop" then
				ViewManager.Instance:FlushView(name, index or 1, "all", {buy_id = self.data.fun[3]})
			end
		end
	else
		if IS_ON_CROSSSERVER then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
			return 
		end
		if self.data.activityId > 0 then
			ActivityCtrl.Instance:SendActiveGuidanceReq(self.data.activityId)
		end
	end
	if ViewManager.Instance:IsOpen(ViewName.OpenServiceAcitivity) then
		ViewManager.Instance:Close(ViewName.OpenServiceAcitivity)
	end
end

-- 每日主题充值
OpenDailyAddChargeAwardItem = OpenDailyAddChargeAwardItem or BaseClass(BaseRender)
function OpenDailyAddChargeAwardItem:__init()
	
end

function OpenDailyAddChargeAwardItem:__delete()
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function OpenDailyAddChargeAwardItem:CreateChild()
	BaseRender.CreateChild(self)
	self.interval = 2
	local ph = self.ph_list.ph_cells_list
	self.cell_item_ui_cfg = self.ph_list.ph_cell_1
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, GridCell, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list:SetItemsInterval(self.interval)
	self.view:addChild(self.cells_list:GetView(), 90)
	ph = self.ph_list.ph_open_cell
	self.img_bg = XUI.CreateImageView(ph.x, ph.y, ResPath.GetOpenServerActivities("gold_1"), true)
	self.view:addChild(self.img_bg, 99)
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnFetchGetReWard, self), true)
	self.node_tree.btn_fetch.node:setLocalZOrder(100)
end

function OpenDailyAddChargeAwardItem:OnFlush()
	if self.data == nil or self.data.reward == nil then return end
	self:SetCellsListData(self.data.reward)
	self.node_tree.txt_level_name.node:setString(OpenServiceAcitivityData.Instance:GetDailyMoney(self.data.pos)..Language.OpenServiceAcitivity.YuanBao or "")
	self.node_tree.btn_fetch.node:setVisible(self.data.state == OPEN_ATHLETICS_FETCH_STATE.CAN_FETCH)
	self.node_tree.img_state.node:setVisible(self.data.state == OPEN_ATHLETICS_FETCH_STATE.NOT_COMPLETE)
	self.node_tree.img_had_get.node:setVisible(self.data.state == OPEN_ATHLETICS_FETCH_STATE.HAVE_FETCHED)
	self.img_bg:loadTexture(ResPath.GetOpenServerActivities("gold_"..self.data.pos))
end

-- 创建选中特效
function OpenDailyAddChargeAwardItem:CreateSelectEffect()
	
end

function OpenDailyAddChargeAwardItem:SetCellsListData(data)
	if data == nil then return end
	self.cells_list:SetData(data)
	local ph = self.ph_list.ph_cells_list
	local len = #data
	if len < 4 then
		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
		self.cells_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
	else
		self.cells_list:GetView():setPosition(ph.x, ph.y)
	end	
end

function OpenDailyAddChargeAwardItem:OnFetchGetReWard()
	OpenServiceAcitivityCtrl.Instance:GetDailyThemeChargeReward(self.data.pos)
end

-- 开服累计充值
OpenChargeRewardAwardItem = OpenChargeRewardAwardItem or BaseClass(BaseRender)
function OpenChargeRewardAwardItem:__init()
	
end

function OpenChargeRewardAwardItem:__delete()
	if self.cells_list then
		self.cells_list:DeleteMe()
		self.cells_list = nil
	end
end

function OpenChargeRewardAwardItem:CreateChild()
	BaseRender.CreateChild(self)
	self.interval = 2
	local ph = self.ph_list.ph_cells_list
	self.cell_item_ui_cfg = self.ph_list.ph_cell_1
	self.cells_list = ListView.New()
	self.cells_list:Create(ph.x, ph.y,ph.w, ph.h, ScrollDir.Horizontal, GridCell, gravity, is_bounce, self.cell_item_ui_cfg)
	self.cells_list:SetItemsInterval(self.interval)
	self.view:addChild(self.cells_list:GetView(), 90)
	ph = self.ph_list.ph_open_cell
	self.img_bg = XUI.CreateImageView(ph.x, ph.y, ResPath.GetOpenServerActivities("gold_1"), true)
	self.view:addChild(self.img_bg, 99)
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnFetchGetReWard, self), true)
	self.node_tree.btn_fetch.node:setLocalZOrder(100)
end

function OpenChargeRewardAwardItem:OnFlush()
	if self.data == nil or self.data.reward == nil then return end
	self:SetCellsListData(self.data.reward)
	self.node_tree.txt_level_name.node:setString(OpenServiceAcitivityData.Instance:GetMoney(self.data.pos)..Language.OpenServiceAcitivity.YuanBao or "")
	self.node_tree.btn_fetch.node:setVisible(self.data.state == OPEN_ATHLETICS_FETCH_STATE.CAN_FETCH)
	self.node_tree.img_state.node:setVisible(self.data.state == OPEN_ATHLETICS_FETCH_STATE.NOT_COMPLETE)
	self.node_tree.img_had_get.node:setVisible(self.data.state == OPEN_ATHLETICS_FETCH_STATE.HAVE_FETCHED)
	self.img_bg:loadTexture(ResPath.GetOpenServerActivities("gold_"..self.data.pos))
end

-- 创建选中特效
function OpenChargeRewardAwardItem:CreateSelectEffect()
	
end

function OpenChargeRewardAwardItem:SetCellsListData(data)
	if data == nil then return end
	self.cells_list:SetData(data)
	local ph = self.ph_list.ph_cells_list
	local len = #data
	if len < 4 then
		local w = self.cell_item_ui_cfg.w * len + (len - 1) * self.interval
		self.cells_list:GetView():setPosition(ph.x + (ph.w - w) * 0.5, ph.y)
	else
		self.cells_list:GetView():setPosition(ph.x, ph.y)
	end	
end

function OpenChargeRewardAwardItem:OnFetchGetReWard()
	OpenServiceAcitivityCtrl.Instance:GetChargeReward(self.data.pos)
end

-- 时装折扣
OpenSerFashionDiscRender = OpenSerFashionDiscRender or BaseClass(BaseRender)
function OpenSerFashionDiscRender:__init()
	self.cell = nil
	self.alert_view = nil 
end

function OpenSerFashionDiscRender:__delete()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil 
	end
end

function OpenSerFashionDiscRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.cell:GetView(), 100)
	end
	XUI.AddClickEventListener(self.node_tree.buyBtn.node, BindTool.Bind1(self.BuyShopItem, self), true)
end

function OpenSerFashionDiscRender:OnFlush()
	if self.data == nil then return end
	local data = {item_id = self.data.id, num = self.data.count, is_bind = self.data.bind}
	self.cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.id)
	if item_cfg == nil then
		return 
	end
	self.node_tree.lbl_item_name.node:setString(item_cfg.name)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	self.node_tree.lbl_item_cost.node:setString(self.data.oldprice)
	self.node_tree.lbl_now_item_cost.node:setString(self.data.nowprice)
	self.node_tree.txt_rest_buy_time.node:setString(string.format(Language.Common.RestCount,self.data.rest_cnt))
	local path = ResPath.GetOpenServerActivities("discount_" .. self.data.icon) 
	self.node_tree.img_buy_bg.node:loadTexture(path)
	
end

-- 创建选中特效
function OpenSerFashionDiscRender:CreateSelectEffect()
	
end

function OpenSerFashionDiscRender:BuyShopItem()
	if not self.data then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.id)
	local money_name = ShopData.GetMoneyTypeName(MoneyType.Yuanbao)
	local txt = string.format(Language.CombineServerActivity.ShenMi_Shop, money_name, self.data.nowprice, string.format("%06x", item_cfg.color), item_cfg.name, self.data.count)
	local alert_view = Alert.New(txt)
	alert_view:SetIsAnyClickClose(false)
	alert_view:NoCloseButton()
	local ok_func = function()
			OpenServiceAcitivityCtrl.Instance:ReqOpenSerFashionDiscountBuy(self.data.idx, 1)
			alert_view:DeleteMe()
			alert_view = nil
	  	end
  	local cancel_func = function()
	  		alert_view:DeleteMe()
	  		alert_view = nil
	  end
	alert_view:SetOkFunc(ok_func)
	alert_view:SetCancelFunc(cancel_func)
  	alert_view:Open()
end