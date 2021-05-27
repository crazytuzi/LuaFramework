-- 开服达标比拼
OpenSerRaceStandardView = OpenSerRaceStandardView or BaseClass(XuiBaseView)

function OpenSerRaceStandardView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	-- self.texture_path_list[2] = 'res/xui/activity.png'
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"openserver_race_standard_ui_cfg", 1, {0}},
		-- {"common_ui_cfg", 2, {0}},
	}
	self.grid_list = nil
	self.need_req = true
end

function OpenSerRaceStandardView:__delete()
end

function OpenSerRaceStandardView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.act_open_update_evt == nil then
		self.act_open_update_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_RACE_STAND_ACT_OPEN_UPDATE, BindTool.Bind(self.SetGridData, self))
	end
	-- RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
end

function OpenSerRaceStandardView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.need_req = true
	if self.act_open_update_evt then
		GlobalEventSystem:UnBind(self.act_open_update_evt)
		self.act_open_update_evt = nil
	end
end

function OpenSerRaceStandardView:ReleaseCallBack()
	if self.grid_list then
		self.grid_list:DeleteMe()
		self.grid_list = nil 
	end

	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)	
	end
	if self.open_ser_race_evt then
		GlobalEventSystem:UnBind(self.open_ser_race_evt)
		self.open_ser_race_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function OpenSerRaceStandardView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateGridList()
		self:InitEvent()
		self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
		RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
		XUI.RichTextSetCenter(self.node_t_list.rich_act_des.node)
		XUI.RichTextSetCenter(self.node_t_list.rich_des_tip_1.node)
		XUI.RichTextSetCenter(self.node_t_list.rich_des_tip_2.node)
		self.node_t_list.rich_act_des.node:setVerticalAlignment(RichVAlignment.VA_CENTER)
		RichTextUtil.ParseRichText(self.node_t_list.rich_act_des.node, Language.OpenServiceAcitivity.RaceTitle, 22)
	end
end

function OpenSerRaceStandardView:RoleDataChangeCallback(key, value)
	-- if key == OBJ_ATTR.CREATURE_LEVEL then
	-- 	self:FlushActiveTypeList()
	-- end
end

function OpenSerRaceStandardView:ShowIndexCallBack(index)
	self:Flush(index)
end

function OpenSerRaceStandardView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then
			self:SetGridData()
		end
	end
end

function OpenSerRaceStandardView:ReqCurPageInfo()
	if self.need_req then
		self.need_req = false
		if self.cur_cell and self.cur_cell:GetData() then
			local cur_data = self.cur_cell:GetData()
			if cur_data.is_over == false then
				OpenSerRaceStandardCtrl.OpenSerRaceStandardInfoReq(cur_data.act_id)
			end
		end
	end
end

--初始化事件
function OpenSerRaceStandardView:InitEvent()
	XUI.AddClickEventListener(self.node_t_list.btn_left.node, BindTool.Bind(self.OnClickMoveLeftHandler, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_right.node, BindTool.Bind(self.OnClickMoveRightHandler, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_tip.node, BindTool.Bind(self.OnTip, self))
	self.open_ser_race_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_RACE_STAND, BindTool.Bind(self.UpdateOneGrid, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

function OpenSerRaceStandardView:CreateGridList()
	if self.grid_list == nil then
		self.grid_list = BaseGrid.New() 
		local ph_grid = self.ph_list.ph_grid_list
		local grid_node = self.grid_list:CreateCells({w = ph_grid.w + 20, h = ph_grid.h, itemRender = OpenSerRaceStandardRender, direction = ScrollDir.Horizontal, cell_count = 1, col = 1, row = 1, ui_config = self.ph_list.ph_grid_item})
		grid_node:setPosition(ph_grid.x, ph_grid.y)
		grid_node:setAnchorPoint(0.5, 0.5)
		self.node_t_list["layout_race_main_panel"].node:addChild(grid_node, 999)
		self.cur_index = self.grid_list:GetCurPageIndex()
		self.grid_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
		self.max_page = self.grid_list:GetPageCount()
		grid_node:setTouchEnabled(false)
	end
	local ph = self.ph_list.ph_rich_link_1
	self.text_node = RichTextUtil.CreateLinkText("", 20, COLOR3B.YELLOW, nil, true)
	self.text_node:setPosition(ph.x, ph.y)
	-- self.text_node:setPropagateTouchEvent(false)
	-- self.text_node:setString(Language.ActiveDegree.ActivityQuickLinks)
	-- self.text_node:setColor(COLOR3B.GREEN)
	self.node_t_list.layout_race_main_panel.node:addChild(self.text_node, 999)
	XUI.AddClickEventListener(self.text_node, BindTool.Bind(self.QuickLinks, self), true)
end

function OpenSerRaceStandardView:UpdateOneGrid(index, data)
	self.grid_list:UpdateOneCell(index, data)
	self:FlushShowInfo()
end

function OpenSerRaceStandardView:SetGridData()
	local data, max_count = OpenSerRaceStandardData.Instance:GetOpenSerRaceStandardData()
	self.grid_list:ExtendGrid(max_count)
	self.grid_list:SetDataList(data)
	self.max_page = self.grid_list:GetPageCount()
	self.cur_index = self.max_page
	self.grid_list:JumpToPage(self.max_page)
	self:FlushShowInfo()
end

function OpenSerRaceStandardView:OnPageChangeCallBack(grid, page_index, prve_page_index)
	self.cur_index = page_index
	self.need_req = true
	self:FlushShowInfo()
end

function OpenSerRaceStandardView:FlushShowInfo()
	self.node_t_list.btn_left.node:setVisible(self.cur_index ~= 1)
	self.node_t_list.btn_right.node:setVisible(self.cur_index ~= self.max_page)
	self.cur_cell = self.grid_list:GetCell(self.cur_index - 1)
	if self.cur_index ~= self.max_page then
		local nxt_cell = self.grid_list:GetCell(self.cur_index)
		if nxt_cell and nxt_cell:GetData() then
			local data = nxt_cell:GetData()
			self.node_t_list.btn_right.node:setVisible(data.is_open == true)
		end
	end
	self:FlushTxtInfo()
	self:ReqCurPageInfo()
	self:FlushTime()
end

function OpenSerRaceStandardView:FlushTxtInfo()
	if self.cur_cell and self.cur_cell:GetData() then
		local cur_data = self.cur_cell:GetData()
		local content = string.format(Language.OpenServiceAcitivity.RaceEndTip[1], cur_data.endDay)
		if cur_data.is_over then
			content = Language.OpenServiceAcitivity.RaceEndTip[2]
		end
		RichTextUtil.ParseRichText(self.node_t_list.rich_des_tip_1.node, content, 22, COLOR3B.GREEN)
		content = cur_data.is_over and content or (content .. Language.OpenServiceAcitivity.RaceEndTip2)
		-- RichTextUtil.ParseRichText(self.node_t_list.rich_des_tip_2.node, content, 20, COLOR3B.GREEN)
		content = ""
		if cur_data.is_stage_star then
			if cur_data.act_id == OPEN_SER_RACE_STANDARD_TYPE.Level then
				content = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, string.format(Language.OpenServiceAcitivity.RaceStandardTxts[cur_data.act_id], cur_data.my_star or 0, cur_data.my_stage or 0))
			else
				content = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, string.format(Language.OpenServiceAcitivity.RaceStandardTxts[cur_data.act_id], cur_data.my_stage or 0, cur_data.my_star or 0))
			end
		else
			if cur_data.act_id ~= OPEN_SER_RACE_STANDARD_TYPE.FuWen then
				content = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, string.format(Language.OpenServiceAcitivity.RaceStandardTxts[cur_data.act_id], cur_data.my_stage or 0))
			else
				-- local face_lv,_,name = FashionData.Instance:GetFaceLevel(cur_data.my_stage or 0)
				-- content = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, string.format(Language.OpenServiceAcitivity.RaceStandardTxts[cur_data.act_id], face_lv))
				-- content = content .. "(" .. name .. ")"
			end
		end
		self.text_node:setString(content)
	end
end

-- 倒计时
local act_end_time = 24 * 3600
function OpenSerRaceStandardView:FlushTime()
	local time_str = ""
	if self.cur_cell and self.cur_cell:GetData() and not self.cur_cell:GetData().is_over then
		local now_time = ActivityData.GetNowShortTime()
		local rest_time = act_end_time - now_time
		time_str = TimeUtil.FormatSecond2Str(rest_time, 1, true)
		time_str = string.format(Language.Common.EndCountDownTime, time_str)
	end
	self.node_t_list.txt_countdown_time.node:setString(time_str)
end

function OpenSerRaceStandardView:SelectCallback(item, index)
	
end

function OpenSerRaceStandardView:OnClickMoveLeftHandler()
	if self.cur_index > 1 then
		self.cur_index = self.cur_index - 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
end

function OpenSerRaceStandardView:OnClickMoveRightHandler()
	if self.cur_index < self.max_page then
		self.cur_index = self.cur_index + 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
end

function OpenSerRaceStandardView:OnTip()
	if self.cur_cell and self.cur_cell:GetData() then
		local cur_data = self.cur_cell:GetData()
		DescTip.Instance:SetContent(cur_data.tip or "", Language.OpenServiceAcitivity.RaceTipTitle)
	end
end

function OpenSerRaceStandardView:QuickLinks()
	if self.cur_cell and self.cur_cell:GetData() then
		local cur_data = self.cur_cell:GetData()
		OpenSerRaceStandardCtrl.OpenLinkWnd(cur_data.wndId)
	end
end
