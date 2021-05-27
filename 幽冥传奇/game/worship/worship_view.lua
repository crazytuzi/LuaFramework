
WorshipView = WorshipView or BaseClass(BaseView)
WorshipView.ENUM = {
	COUNT = 10,
	MULT = {1, 3, 6, 10},
-- PER = {[1] = 1, [3] = 3, [6] = 6, [10] = 10},
}
local TotalCnt = 10
local StartIndex = {1, 2}
function WorshipView:__init()
	--self.view_name = GuideModuleName.Activity
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("word_worship")
	self.texture_path_list[1] = "res/xui/worship.png"
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"worship_ui_cfg", 1, {0}},
		-- {"worship_ui_cfg", 2, {0}, false},
		{"common_ui_cfg", 2, {0}},
	}
	self.is_in_open = false
end

function WorshipView:__delete()
end

function WorshipView:ReleaseCallBack()
	-- if self.OneKeyUpConfirDlg then
	-- 	self.OneKeyUpConfirDlg:DeleteMe()
	-- 	self.OneKeyUpConfirDlg = nil
	-- end
	if self.chengzhu_display then
		self.chengzhu_display:DeleteMe()
		self.chengzhu_display = nil
	end
	if self.title then
		self.title:DeleteMe()
		self.title = nil
	end
	-- if self.btn_receive_reward then
	-- 	self.btn_receive_reward:DeleteMe()
	-- 	self.btn_receive_reward = nil
	-- end
	self.is_in_open = false
end

function WorshipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_flush_star.node:addClickEventListener(BindTool.Bind(self.OnFlushStarBtn, self))
		self.node_t_list.btn_despise.node:addClickEventListener(BindTool.Bind(self.OnDespiseBtn, self))
		self.node_t_list.btn_worship.node:addClickEventListener(BindTool.Bind(self.OnWorshipBtn, self))
		self.node_t_list.btn_worship_tips.node:addClickEventListener(BindTool.Bind(self.OnWorshipTipsBtn, self))
		
		self.node_t_list.lbl_act_time.node:setIgnoreSize(true)
		self.node_t_list.lbl_act_time.node:setDimensions(cc.size(0, 0))
		
		self:CreateWorshipStar()
		self:CreateDisplayRoles()
		self:CreateChengzhuTitle()
		self:CreateCellList()
		
		local ph = self.ph_list.ph_display_role
		self.btn_receive_reward = XUI.CreateButton(ph.x, ph.y - 295, 0, 0, false, ResPath.GetCommon("btn_103"), "", "", true)
		self.btn_receive_reward:setTitleFontSize(26)
		self.btn_receive_reward:setTitleFontName(COMMON_CONSTS.FONT)
		self.btn_receive_reward:setTitleText(Language.Common.LingQuJiangLi)
		self.btn_receive_reward:setTitleColor(cc.c3b(250, 230, 191))
		self.node_t_list.layout_worship.node:addChild(self.btn_receive_reward, 2)
		self.btn_receive_reward:addClickEventListener(BindTool.Bind1(self.OnReceiveRewardBtn, self))
		
		local despise_prog = XUI.CreateLoadingBar(667, 388, ResPath.GetWorship("prog_despise_progress"), XUI.IS_PLIST, nil, true, 105, 9, cc.rect(3, 3, 5, 5))
		despise_prog:setRotation(- 90)
		self.node_t_list.layout_worship.node:addChild(despise_prog, 99)
		self.despise_progressbar = ProgressBar.New()
		self.despise_progressbar:SetView(despise_prog)
		self.despise_progressbar:SetPercent(0)
		
		local worship_prog = XUI.CreateLoadingBar(802, 388, ResPath.GetWorship("prog_worship_progress"), XUI.IS_PLIST, nil, true, 105, 9, cc.rect(3, 3, 5, 5))
		worship_prog:setRotation(- 90)
		self.node_t_list.layout_worship.node:addChild(worship_prog, 99)
		self.worship_progressbar = ProgressBar.New()
		self.worship_progressbar:SetView(worship_prog)
		self.worship_progressbar:SetPercent(0)
	end
end


function WorshipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function WorshipView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	WangChengZhengBaCtrl.Instance:SendGetSbkRoleVoMsg()
end

function WorshipView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function WorshipView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "OnOpenView" then
			self:SetLabsString(v)
			local multi_rate = tonumber(v[WORSHIP_ENUM.MULTI_RATE])
			self:SetMultiRateAndBtnsState(StartIndex[1], multi_rate, tonumber(v[WORSHIP_ENUM.LEFT_TIMES]) < TotalCnt
			and multi_rate < WorshipView.ENUM.COUNT or false)
			local vo = WangChengZhengBaData.Instance:GetSbkRoleVo(SOCIAL_MASK_DEF.GUILD_LEADER)
			self:SetCZRoleDisplay(vo, v)
		elseif k == "worship_despise" then
			self:SetLabsString(v)
			self:SetMultiRateAndBtnsState(StartIndex[2], WorshipView.ENUM.MULT[1], v[WORSHIP_ENUM.LEFT_TIMES] < TotalCnt
			and true or false)
			if ActivityData.Instance and ActivityData.Instance.act_mobai_data then
				local act_mobai_data = ActivityData.Instance.act_mobai_data
				if act_mobai_data.worship_exp and v[WORSHIP_ENUM.TOTAL_EXP] then
					act_mobai_data.worship_exp = v[WORSHIP_ENUM.TOTAL_EXP]
				end
				if act_mobai_data.total_exp and act_mobai_data.paodian_exp and v[WORSHIP_ENUM.TOTAL_EXP] then
					act_mobai_data.total_exp = act_mobai_data.paodian_exp + v[WORSHIP_ENUM.TOTAL_EXP]
				end
				ActivityData.Instance:OnMoBai(act_mobai_data)
			end
			
		elseif k == "refre_award" then
			local awradCfg = WorshipData.GetWorshipDespiseAwardCfg()
			local multi_rate = awradCfg[v[WORSHIP_ENUM.MULTI_RATE]].multiple
			self:SetMultiRateAndBtnsState(StartIndex[1], multi_rate, multi_rate < WorshipView.ENUM.COUNT)
		end
	end
end

function WorshipView:SetLabsString(param_t)
	if not param_t or not next(param_t) then return end
	if nil ~= param_t[WORSHIP_ENUM.CHENGZHU_NAME] and nil ~= param_t[WORSHIP_ENUM.ACT_TIME] and nil ~= param_t[WORSHIP_ENUM.CHENGZHU_GUILD] then
		self.node_t_list.lbl_chengzhu.node:setString(param_t[WORSHIP_ENUM.CHENGZHU_NAME])
		local act_time_str = ""
		if param_t[WORSHIP_ENUM.ACT_TIME] then
			local t = Split(param_t[WORSHIP_ENUM.ACT_TIME], " ")
			for k, v in pairs(t) do
				act_time_str = act_time_str .. v
				if k ~= #t then
					act_time_str = act_time_str .. "\n"
				end
			end
		end
		self.node_t_list.lbl_act_time.node:setString(act_time_str)
		self.node_t_list.lbl_cz_guild.node:setString(param_t[WORSHIP_ENUM.CHENGZHU_GUILD])
	end
	self.despise_progressbar:SetPercent(tonumber(param_t[WORSHIP_ENUM.DESPISE_PROGRESS]), false)
	self.node_t_list.lbl_despise_per.node:setString(param_t[WORSHIP_ENUM.DESPISE_PROGRESS] .. "%")
	self.worship_progressbar:SetPercent(tonumber(param_t[WORSHIP_ENUM.WORSHIP_PROGRESS]), false)
	self.node_t_list.lbl_worship_per.node:setString(param_t[WORSHIP_ENUM.WORSHIP_PROGRESS] .. "%")
	self.node_t_list.lbl_residue.node:setString(TotalCnt - param_t[WORSHIP_ENUM.LEFT_TIMES])
	-- self.node_t_list.lbl_award_count.node:setString(param_t[WORSHIP_ENUM.DAY_GLOD_BENEFIT])
end

--设置奖励倍率进度、按钮显示状态
function WorshipView:SetMultiRateAndBtnsState(start_n, multi_rate, is_enabled)
	local awradCfg = WorshipData.GetWorshipDespiseAwardCfg()
	local index = 1
	for i = start_n, #awradCfg do
		if awradCfg[i].multiple == multi_rate then
			index = i
			break
		end
	end
	for k, v in pairs(self.worship_stars_effs) do
		local star = self.worship_stars[k]
		local new_vis =(multi_rate >= k and star:isVisible())
		v:setVisible(new_vis)
	end
	local cfg = awradCfg[index] or {}
	-- local item_config = ItemData.Instance:GetItemConfig(cfg.awards[1].id)
	-- local color = string.format("%06x", item_config.color)
	self:FlushCellList(cfg.awards)

	self.node_t_list.btn_flush_star.node:setEnabled(is_enabled)
	self.node_t_list.btn_flush_star.node:setTitleColor(is_enabled and COLOR3B.WHITE or COLOR3B.GRAY)

	local consume_num = WorshipData.Instance:GetConsumeCfg()
	self.node_t_list.text_consume.node:setString(tostring(consume_num))
end

function WorshipView:CreateCellList()
	local ph = self.ph_list["ph_cell_list"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_worship"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
	self:AddObj("cell_list")
end

function WorshipView:FlushCellList(show_list)
	local data_list = {}
	for i,v in ipairs(show_list) do
		local item_data = ItemData.InitItemDataByCfg(v)
		table.insert(data_list, item_data)
	end
	self.cell_list:SetDataList(data_list)

	-- 居中处理
	local view = self.cell_list:GetView()
	local inner = view:getInnerContainer()
	local size = view:getContentSize()
	local inner_width = BaseCell.SIZE * (#show_list)
	local view_width = math.min(self.ph_list["ph_cell_list"].w, inner_width + 20)
	view:setContentSize(cc.size(view_width, size.height))
	view:setInnerContainerSize(cc.size(inner_width, size.height))
	view:jumpToTop()
end

function WorshipView:CreateDisplayRoles()
	if nil ~= self.chengzhu_display then return end
	local ph = self.ph_list.ph_display_role
	self.chengzhu_display = RoleDisplay.New(self.node_t_list.layout_worship.node, 1, false, true, true, true, false, false)
	self.chengzhu_display:SetPosition(ph.x, ph.y)
end

function WorshipView:SetCZRoleDisplay(role_vo, param_t)
	if nil ~= self.chengzhu_display and nil ~= self.title then
		if role_vo then
			-- self.node_t_list.layout_display_role.node:setVisible(false)
			self.node_t_list["img_chengzhu"].node:setVisible(false)
			self.chengzhu_display:SetRoleVo(role_vo)
			self.title:SetTitleId(42)
		else
			-- self.node_t_list.layout_display_role.node:setVisible(true)
			self.node_t_list["img_chengzhu"].node:setVisible(true)
			self.chengzhu_display:SetVisible(false)
			self.title:SetVisible(false)
		end
	end
	local receive_time = WorshipData.GetWorshipMasterYbTimesCfg()
	local now_time = os.date("*t", TimeCtrl.Instance:GetServerTime())
	if not param_t or not next(param_t) then return end
	local is_receive_time = false
	local chengzhu_or_assist = false
	if now_time.hour < receive_time.beginTimes[1] or now_time.hour > receive_time.endTimes[1]
	or(now_time.hour == receive_time.beginTimes[1] and now_time.min < receive_time.beginTimes[2])
	or(now_time.hour == receive_time.endTimes[1] and now_time.min > receive_time.endTimes[2]) then
		is_receive_time = false
	else
		is_receive_time = true
	end
	if nil ~= param_t[WORSHIP_ENUM.CHENGZHU_ID] and nil ~= param_t[WORSHIP_ENUM.CHENGZHU_ASSIST_ID] then
		local role_id = tostring(GameVoManager.Instance:GetMainRoleVo().role_id)
		if role_id == param_t[WORSHIP_ENUM.CHENGZHU_ID] or role_id == param_t[WORSHIP_ENUM.CHENGZHU_ASSIST_ID] then
			chengzhu_or_assist = true
		end
	end
	local can_receive_reward = is_receive_time and chengzhu_or_assist
	self.btn_receive_reward:setVisible(can_receive_reward)
	if can_receive_reward and tonumber(param_t[WORSHIP_ENUM.IS_RECEIVE]) == 1 then
		self.btn_receive_reward:setEnabled(false)
	end
end

function WorshipView:CreateChengzhuTitle()
	if nil == self.title then
		self.title = Title.New()
		local ph = self.ph_list.ph_display_role
		self.title:GetView():setPosition(ph.x, ph.y + 200)
		self.node_t_list.layout_worship.node:addChild(self.title:GetView(), 1)
	end
end

function WorshipView:OnReceiveRewardBtn()
	WorshipCtrl.WorshipReceiveRewardsReq()
end

function WorshipView:CreateWorshipStar()
	self.worship_stars_effs = {}
	self.worship_stars = {}
	local ph = self.ph_list.ph_worship_star
	for i = 1, 10 do
		local file = ResPath.GetCommon("star_1_lock")	
		local start = XUI.CreateImageView(ph.x +(i - 1) * 30, ph.y, file)
		self.node_t_list.layout_worship.node:addChild(start, 99)
		local start_eff = RenderUnit.CreateEffect(911, self.node_t_list.layout_worship.node, nil, nil, nil, ph.x +(i - 1) * 30, ph.y)
		start_eff:setVisible(false)
		start:setVisible(true)
		self.worship_stars_effs[i] = start_eff
		self.worship_stars[i] = start
	end
end

function WorshipView:OnFlushStarBtn()
	WorshipCtrl.WorshipRefreRateReq(WORSHIP_MONEY_TYPE.BIND_GOLD)
end

function WorshipView:OnDespiseBtn()
	WorshipCtrl.WorshipOrDespiseReq(WORSHIP_SUPPORT_TYPE.DESPISE)
end

function WorshipView:OnWorshipBtn()
	WorshipCtrl.WorshipOrDespiseReq(WORSHIP_SUPPORT_TYPE.WORSHIP)
end

function WorshipView:OnWorshipTipsBtn()
	DescTip.Instance:SetContent(Language.Worship.WorshipDetail, Language.Worship.WorshipTitle)
end

