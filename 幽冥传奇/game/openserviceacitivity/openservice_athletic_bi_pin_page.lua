-- 开服每日主题比拼
OpenServiceAthleticBiPinPage = OpenServiceAthleticBiPinPage or BaseClass()

function OpenServiceAthleticBiPinPage:__init()
	self.view = nil
	self.cur_index = nil
end	

function OpenServiceAthleticBiPinPage:__delete()
	self:RemoveEvent()
	if self.cells_t then
		for k, v in pairs(self.cells_t) do
			v:DeleteMe()
		end
		self.cells_t = nil
	end
	if self.fp_numbar then
		self.fp_numbar:DeleteMe()
		self.fp_numbar = nil
	end
	self.view = nil
	self.cur_index = nil
end	

--初始化页面接口
function OpenServiceAthleticBiPinPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateAwardCells()
	self:InitEvent()
	CommonAction.ShowJumpAction(self.view.node_t_list.img_gift_bg_b.node, 18)
end	

--初始化事件
function OpenServiceAthleticBiPinPage:InitEvent()
	if self.timer == nil then
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTime, self),  1)
	end

	if self.bi_pin_evt == nil then
		self.bi_pin_evt = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_BI_PIN, BindTool.Bind(self.OnBiPinEvtData, self))
	end
end

--移除事件
function OpenServiceAthleticBiPinPage:RemoveEvent()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.bi_pin_evt then
		GlobalEventSystem:UnBind(self.bi_pin_evt)
		self.bi_pin_evt = nil
	end

end

--更新视图界面
function OpenServiceAthleticBiPinPage:UpdateData(data, index)
	if self.cur_index == nil or self.cur_index ~= index then
		self.cur_index = index
		-- self:FlushTime()
		self.cur_act_type = OpenServiceAcitivityData.Instance:GetAthleticTypeByIndex(index)
		-- print("cur_act_type", self.cur_act_type, self.cur_index)
		OpenServiceAcitivityCtrl.Instance:GetOpenSerAthleticAwardInfoReq(self.cur_act_type)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_activity_b.node, OPEN_SERVER_ACTS_INTERPS[index] or "", 22, COLOR3B.GREEN)
	end
end

function OpenServiceAthleticBiPinPage:OnBiPinEvtData(act_type)
	if self.cur_act_type and self.cur_act_type == act_type then
		local my_info_data = OpenServiceAcitivityData.Instance:GetOpenSerMyStageLvInfo(self.cur_act_type)
		self.act_data = OpenServiceAcitivityData.Instance:GetOpenSerOneAthleticData(self.cur_act_type)
		if not self.act_data then return end
		self:FlushTime()
		local path = ResPath.GetOpenServerActivities("txt_top1_des_1")
		local path_2 = ResPath.GetOpenServerActivities("big_show_1")
		if self.cur_act_type > 0 and self.cur_act_type <= OPEN_ATHLETICS_TYPE.BossScore then
			path = ResPath.GetOpenServerActivities("txt_top1_des_" .. self.cur_act_type)
			local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
			local big_show = OpenServiceAcitivityData.Instance:GetOpenSerBigShowIcons(self.cur_act_type)
			if big_show and big_show[sex + 1] then
				path_2 = ResPath.GetOpenServerActivities("big_show_" .. big_show[sex + 1])
			end
		end
		self.view.node_t_list.img_athb_top1_des.node:loadTexture(path)
		self.view.node_t_list.img_gift_bg_b.node:loadTexture(path_2)

		for k, v in ipairs(self.cells_t) do
			v:SetVisible(false)
		end
		local fight_power = 0
		for i, v in ipairs(self.act_data[1].awards) do
			self.cells_t[i]:SetVisible(true)
			self.cells_t[i]:SetData(v)
			if v.is_equip then
				fight_power = fight_power + ItemData.Instance:GetItemScore(v)
			end
		end
		self.fp_numbar:SetNumber(fight_power)
		local top_1_str = ""
		local my_info = ""
		local my_stage, my_lev = my_info_data.my_stage, my_info_data.my_lev
		local stage = self.act_data[1].stage
		local lev = self.act_data[1].lev
		if self.cur_act_type ~= OPEN_ATHLETICS_TYPE.Wing and self.cur_act_type ~= OPEN_ATHLETICS_TYPE.Hero and
		 self.cur_act_type ~= OPEN_ATHLETICS_TYPE.Ride and self.cur_act_type ~= OPEN_ATHLETICS_TYPE.BossScore and
		 self.cur_act_type ~= OPEN_ATHLETICS_TYPE.Stone then
			if self.cur_act_type == OPEN_ATHLETICS_TYPE.Leveling then
				local step, star = ZhuanshengData.Instance:GetStepStar(stage)
				if self.act_data[1].top1_name and self.act_data[1].top1_name ~= "" then
					top_1_str = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.cur_act_type), step, star, lev)
				end
				local step_2, star_2 = ZhuanshengData.Instance:GetStepStar(my_stage)
				my_info = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.cur_act_type), step_2, star_2, my_lev)
			else
				if self.act_data[1].top1_name and self.act_data[1].top1_name ~= "" then
					top_1_str = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.cur_act_type), stage, lev)
				end
				my_info = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.cur_act_type), my_stage, my_lev)
			end
		else
			if self.act_data[1].top1_name and self.act_data[1].top1_name ~= "" then
				top_1_str = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.cur_act_type), stage)
			end
			my_info = string.format(OpenServiceAcitivityData.GetAthleticTopOneLvStrByID(self.cur_act_type), my_stage)
		end
		if self.act_data[1].top1_name and self.act_data[1].top1_name ~= "" then
			top_1_str = string.format(Language.OpenServiceAcitivity.BiPinTop1Tex, self.act_data[1].top1_name, top_1_str)
		else
			top_1_str = string.format(Language.OpenServiceAcitivity.BiPinTop1Tex, Language.Common.ZanWu, top_1_str)
		end
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_athb_top_1.node, top_1_str)

		-- local award_des_title = string.format(Language.OpenServiceAcitivity.BiPinTop1AwardDes, Language.OpenServiceAcitivity.BiPinTypeName[act_type] or "")
		-- self.view.node_t_list.txt_athb_top_1_awar_des.node:setString(award_des_title)

		my_info = string.format(Language.OpenServiceAcitivity.BinPinMyInfo, my_info)
		self.view.node_t_list.txt_athb_my_cnt.node:setString(my_info)
	end
end

function OpenServiceAthleticBiPinPage:CreateAwardCells()
	if self.cells_t == nil then
		self.cells_t = {}
		for i = 1, 4 do
			local ph = self.view.ph_list["ph_athb_gift_cell_" .. i]
			local cell = BaseCell.New()
			cell:SetPosition(ph.x, ph.y)
			cell.cell_effect = RenderUnit.CreateEffect(920, cell:GetView(), 99, frame_interval, loops, x, y, callback_func)
			self.view.node_t_list.layout_athletic_b_1.node:addChild(cell:GetView(), 90)
			cell:SetVisible(false)
			self.cells_t[i] = cell
		end
	end

	if self.fp_numbar == nil then
		local ph = self.view.ph_list.ph_athb_fight_power
		self.fp_numbar = NumberBar.New()
		self.fp_numbar:SetRootPath(ResPath.GetFightResPath("cy_"))
		self.fp_numbar:SetPosition(ph.x, ph.y)
		self.fp_numbar:SetSpace(-6)
		self.view.node_t_list.layout_athletic_b_1.node:addChild(self.fp_numbar:GetView(), 90)
		-- self.fp_numbar:SetNumber(0)
		-- self.fp_numbar:SetGravity(NumberBarGravity.Center)
	end
end

function OpenServiceAthleticBiPinPage:FlushTime()
	-- self.view.node_t_list.txt_time_athb.node:setString("")
	if not self.cur_index then
		return
	end
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_athb_get_awar_tip.node, "")
	local top1_name = self.act_data and self.act_data[1].top1_name
	local now_server_time = TimeCtrl.Instance:GetServerTime()
	local day_t = OpenServiceAcitivityData.Instance:GetTabbarOpenTime(self.cur_index)
	local open_server_time = OpenServiceAcitivityData.Instance:GetOpenServerTime(true)

	local shift_day = (day_t and day_t[2] and day_t[2] >= 1) and day_t[2] or 0
	local end_time = open_server_time + shift_day * 24 * 60 * 60
	local rest_time_str = ""
	local rest_time_str_2 = ""
	if end_time > now_server_time then
		rest_time_str = TimeUtil.FormatSecond2Str(end_time - now_server_time, state, is_noday)
		rest_time_str_2 = TimeUtil.FormatSecond2Str(end_time - now_server_time, 2, is_noday)
	end

	self.view.node_t_list.txt_time_athb.node:setString(rest_time_str)
	if top1_name and top1_name ~= "" then
		local content = string.format(Language.OpenServiceAcitivity.BiPinTop1GetAwarTip, rest_time_str_2) .. Language.OpenServiceAcitivity.Fetch
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_athb_get_awar_tip.node, content)
	end

end