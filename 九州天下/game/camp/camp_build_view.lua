CampBuildView = CampBuildView or BaseClass(BaseRender)

function CampBuildView:__init()
	self.open_view = 0
	self.tower_res_list = {}
end

function CampBuildView:__delete()
	if self.act_timer ~= nil then
		CountDown.Instance:RemoveCountDown(self.act_timer)
	end
	self.act_timer = nil

	for i = 1, 4 do
		if self["tower_model_" .. i] ~= nil then
			self["tower_model_" .. i]:DeleteMe()
			self["tower_model_" .. i] = nil
		end
	end

	self.exp_value = nil
	self.exp_max = nil
	self.country_rank = nil
	self.label_notice = nil
	self.label_activity = nil
	self.label_timer = nil
	self.is_build_country = nil
	self.is_show_build_btn = nil
	self.list_view = nil
	self.is_show_timer = nil

	if self.log_build_cell_list then
		for k,v in pairs(self.log_build_cell_list) do
			v:DeleteMe()
		end
	end
	self.log_build_cell_list = {}

	self.open_view = 0
end

function CampBuildView:LoadCallBack(instance)
	self.exp_value = self:FindVariable("ExpValue")
	self.exp_max = self:FindVariable("ExpMax")
	self.country_rank = self:FindVariable("CountryRank")
	self.label_notice = self:FindVariable("LabelNotice")
	self.label_activity = self:FindVariable("LabelActivity")
	self.label_timer = self:FindVariable("LabelTimer")
	self.is_build_country = self:FindVariable("IsBuildCountry")
	self.is_show_build_btn = self:FindVariable("IsShowBuildBtn")
	self.is_show_timer = self:FindVariable("IsShowTimer")

	--列表滚动条
	self.log_build_cell_list = {}
	self.log_list_view = self:FindObj("ListView")

	local log_build_list_delegate = self.log_list_view.list_simple_delegate
	--生成数量
	log_build_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	--刷新
	log_build_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBulidLogListView, self)

	self:ListenEvent("OnClickBuildCountry", BindTool.Bind(self.OnClickBuildCountry, self))
	self:ListenEvent("OnClickCheckRule", BindTool.Bind(self.OnClickCheckRule, self))
	self:ListenEvent("OnClickMonsterAttack", BindTool.Bind(self.OnClickMonsterAttack, self))
	self:ListenEvent("OnMonsterSiegeTip", BindTool.Bind(self.OnClickMonsterSiegeTip, self))

	for i = 1, 4 do
		self:ListenEvent("OnClickBuildTower" .. i, BindTool.Bind(self.OnClickBuildTower, self, i))
		self["tower_obj_" .. i] = self:FindObj("Display" .. i)
		self["show_tower_" .. i] = self:FindVariable("ShowTower" .. i)
	end

	self.label_notice:SetValue(Language.Camp.BuildNotice)
end

function CampBuildView:GetNumberOfCells()
	local report_data = CampData.Instance:GetQueryCampBuildReport()
	return #report_data or 0
end

function CampBuildView:ChangTowerState(seq, is_show)
	if seq == nil then
		return
	end

	if self["show_tower_" .. seq] ~= nil then
		self["show_tower_" .. seq]:SetValue(is_show)
	end

	if not is_show then
		return
	end

	if self["tower_model_" .. seq] == nil then
		if self["tower_obj_" .. seq] ~= nil then
			self["tower_model_" .. seq] = RoleModel.New("camp_build_view")
			self["tower_model_" .. seq]:SetDisplay(self["tower_obj_" .. seq].ui3d_display)
		end
	end

	local data = CampData.Instance:GetMonsterSiegeInfo()
	--local res_id = CampQiYunView.QiYunTaModelRes[data.monster_siege_camp]
	local ta_data = CampData.Instance:GetTowerCfgBySeq(seq - 1)
	if ta_data ~= nil and data ~= nil and data.monster_siege_camp ~= nil then
		local res_id = ta_data["camp_" .. data.monster_siege_camp]
		if res_id ~= nil and self["tower_model_" .. seq] ~= nil and (self.tower_res_list[seq] == nil or self.tower_res_list[seq] ~= res_id) then
			local bundle, asset = ResPath.GetMonsterModel(res_id)
			self["tower_model_" .. seq]:SetMainAsset(bundle, asset)
			self.tower_res_list[seq] = res_id
		end
	end
end

function CampBuildView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "all" then
			-- local data = CampData.Instance:GetMonsterSiegeInfo()
			-- if data ~= nil then
			-- 	local camp = PlayerData.Instance.role_vo.camp
			-- 	if data.monster_siege_camp > 0 and data.monster_siege_camp == camp then
			-- 		self:SetOpenView(1)
			-- 	else
			-- 		self:SetOpenView(0)
			-- 	end
			-- end
			self:CheckIsShowMonsterSiege()

			if self.is_build_country ~= nil then
				self.is_build_country:SetValue(self.open_view == 1)
			end

			if self.open_view == 1 then
				self:FlushMonsterSiege()
			else
				self:FlushBuildView()
			end
		-- elseif k == "flush_monster_siege" then
		-- 	-- local camp = PlayerData.Instance.role_vo.camp
		-- 	-- if v.monster_siege_camp ~= nil and v.monster_siege_camp > 0 and v.monster_siege_camp == camp then
		-- 	-- 	self.open_view = 1
		-- 	-- 	if self.is_build_country ~= nil then
		-- 	-- 		self.is_build_country:SetValue(self.open_view == 1)
		-- 	-- 	end
		-- 	-- end
		-- 	self:CheckIsShowMonsterSiege()
		-- 	if self.is_build_country ~= nil then
		-- 		self.is_build_country:SetValue(self.open_view == 1)
		-- 	end

		-- 	if self.open_view == 1 then
		-- 		self:FlushMonsterSiege()
		-- 	end
		-- elseif k == "flush_camp_build_view" then
		-- 	if self.is_build_country ~= nil then
		-- 		self.is_build_country:SetValue(self.open_view == 1)
		-- 	end
		-- 	if self.open_view == 0 then
		-- 		self:FlushBuildView()
		-- 	end
		MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.Camp), MainUIViewChat.IconList.IS_CAMP_BUILDING, false)
		end
	end
end

--刷新ListView
function CampBuildView:RefreshBulidLogListView(cell, data_index, cell_index)
	data_index = data_index + 1
	local log_build_cell = self.log_build_cell_list[cell]
	if log_build_cell == nil then
		log_build_cell = CampBuildItem.New(cell.gameObject)
		self.log_build_cell_list[cell] = log_build_cell
	end

	log_build_cell:SetIndex(data_index)
	local report_data = CampData.Instance:GetQueryCampBuildReport()
	log_build_cell:SetData(report_data[data_index])
end

function CampBuildView:FlushBuildView()
	local camp_info = CampData.Instance:GetCampItemList()
	local camp_item_list = CampData.Instance:GetCampLevelCfgByCampLevel(camp_info.camp_level)

	self.country_rank:SetValue(camp_item_list.name)
	self.exp_max:SetValue(camp_item_list.level_up_need_exp)
	if camp_info.camp_exp >= camp_item_list.level_up_need_exp then
		self.exp_value:SetValue(ToColorStr(camp_info.camp_exp, TEXT_COLOR.GREEN_5))
	else
		self.exp_value:SetValue(ToColorStr(camp_info.camp_exp, TEXT_COLOR.RED))
	end

	-- 设置建设国家按钮的显示状况
	--local vo = GameVoManager.Instance:GetMainRoleVo()
	--local is_show = vo.camp_post == 1 and camp_info.camp_level % 3 == 0 and camp_info.camp_level ~= 0 and camp_info.camp_exp == camp_item_list.level_up_need_exp

	-- 设置List数据
	if self.log_list_view.scroller.isActiveAndEnabled then
		self.log_list_view.scroller:ReloadData(0)
	end

	local camp_data = CampData.Instance:GetCampInfo()
	local my_role_id = PlayerData.Instance.role_vo.role_id
	if camp_data == nil or next(camp_data) == nil then
		self.is_show_build_btn:SetValue(false)
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local is_show = vo.camp_post == 1 and camp_info.camp_level % 3 == 0 and camp_info.camp_level ~= 0 and camp_info.camp_exp == camp_item_list.level_up_need_exp
	-- if camp_data.officer_list ~= nil and camp_data.officer_list[1] ~= nil then
	-- 	if camp_data.officer_list[1].role_id == my_role_id then
	-- 		self.is_show_build_btn:SetValue(is_show)
	-- 	end
	-- else
	-- 	self.is_show_build_btn:SetValue(false)
	-- end
	self.is_show_build_btn:SetValue(is_show)
end

function CampBuildView:CheckIsShowMonsterSiege()
	local camp_info = CampData.Instance:GetCampItemList()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local is_max = false
	local is_my_camp = false

	if camp_info ~= nil then
		local camp_item_list = CampData.Instance:GetCampLevelCfgByCampLevel(camp_info.camp_level)
		if camp_item_list ~= nil then
			local vo = GameVoManager.Instance:GetMainRoleVo()
			is_max = camp_info.camp_level % 3 == 0 and camp_info.camp_level ~= 0 and camp_info.camp_exp == camp_item_list.level_up_need_exp
		end
	end	

	local data = CampData.Instance:GetMonsterSiegeInfo()
	if data ~= nil then
		if data.act_status == ACTIVITY_STATUS.CLOSE and data.monster_siege_camp == 0 then
			self:SetOpenView(0)
			return 
		end

		local camp = PlayerData.Instance.role_vo.camp
		if data.monster_siege_camp > 0 and data.monster_siege_camp == camp then
			is_my_camp = true
		end
	end

	local view_value = (is_max and is_my_camp) and 1 or 0
	self:SetOpenView(view_value)
end

function CampBuildView:FlushMonsterSiege()
	local data = CampData.Instance:GetMonsterSiegeInfo()
	if data == nil or next(data) == nil then
		return
	end

	local show_timer = false
	if data.act_status ~= ACTIVITY_STATUS.CLOSE then
		if data.is_pass ~= nil then
			local str = Language.Camp.MonsterSiegeTimerLab
			if data.is_pass == 0 then
				show_timer = true
				if data.act_status == ACTIVITY_STATUS.STANDY then
					str = Language.Camp.MonsterSiegeReadly
				end

				if self.label_activity ~= nil then
					self.label_activity:SetValue(str)
				end
			end
		end	
	end

	if data.is_pass == 1 and data.camp_level_up_last_time > 0 then
		show_timer = true
		if self.label_activity ~= nil then
			self.label_activity:SetValue(Language.Camp.CampBuildTimerLab)
		end			
	end

	if self.is_show_timer ~= nil then
		self.is_show_timer:SetValue(show_timer)
		if show_timer then
			if self.act_timer ~= nil then
				CountDown.Instance:RemoveCountDown(self.act_timer)
				self.act_timer = nil
			end

			local time = 0
			if data.is_pass == 1 then
				time = math.floor(data.camp_level_up_last_time)
			else
				time = math.floor(data.act_next_status_change_time - TimeCtrl.Instance:GetServerTime())
			end

			if time > 0 then
				self.act_timer = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.UpdateActTimer, self))
			end
		else
			if self.act_timer ~= nil then
				CountDown.Instance:RemoveCountDown(self.act_timer)
				self.act_timer = nil
			end
		end
	end

	if data.monster_siege_tower_build_flag ~= nil then
		local tower_tab = bit:d2b(data.monster_siege_tower_build_flag)
		if tower_tab ~= nil then
			for i = 1, 4 do
				self:ChangTowerState(i, tower_tab[33 - i] == 1)
			end
		end
	end
end

function CampBuildView:UpdateActTimer(elapse_time, total_time)
	local time = math.floor(total_time - elapse_time)
	local timer_str = TimeUtil.FormatSecond2HMS(time)
	if self.label_timer ~= nil then
		self.label_timer:SetValue(timer_str)
	end

	if not CountDown.Instance:HasCountDown(self.act_timer) then
		self.act_timer = nil
		if self.is_show_timer ~= nil then
			self.is_show_timer:SetValue(false)		
		end
	end
end

--开启建设国家
function CampBuildView:OnClickBuildCountry()
	-- self.is_build_country:SetValue(true)
	-- self.open_view = 1
	-- self:Flush()
	local camp_info = CampData.Instance:GetCampInfo()
	local my_role_id = PlayerData.Instance.role_vo.role_id
	if camp_info == nil or next(camp_info) == nil then
		return
	end

	if camp_info.officer_list ~= nil and camp_info.officer_list[1] ~= nil then
		if camp_info.officer_list[1].role_id == my_role_id then
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_ACT_MONSTER_SIEGE)
		end
	end
end

--查看规则
function CampBuildView:OnClickCheckRule()
	TipsCtrl.Instance:ShowHelpTipView(212)
end

--怪物攻城开启
function CampBuildView:OnClickMonsterAttack()
	--ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.ACTIVITY_TYPE_MONSTER_SIEGE)
	local data = CampData.Instance:GetMonsterSiegeInfo()
	if data == nil or next(data) == nil then
		return
	end

	if data.is_pass == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.IsPassTip)
		return
	end
	
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_MONSTER_SIEGE)
end

function CampBuildView:OnClickMonsterSiegeTip()
	TipsCtrl.Instance:ShowHelpTipView(213)
end

--建塔
function CampBuildView:OnClickBuildTower(tower_index)
	local data = CampData.Instance:GetMonsterSiegeInfo()
	if data == nil or next(data) == nil then
		return
	end

	if data.act_status == ACTIVITY_STATUS.OPEN then
		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.NoCanBuildTa)
		return 
	end

	if data.is_pass == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.NoCanBuildTaPass)
		return 		
	end

	if tower_index ~= nil then
		TipsCtrl.Instance:OpenCampTowerBuildView(tower_index - 1)
	end
end

function CampBuildView:SetOpenView(open_view)
	if open_view ~= nil then
		self.open_view = open_view
	end
end

----------------------------------------------------------------------------
--CampBuildItem	建造日志成员列表
----------------------------------------------------------------------------
CampBuildItem = CampBuildItem or BaseClass(BaseCell)

function CampBuildItem:__init()
	self.log_content = self:FindVariable("LogContent")
	self.is_singular = self:FindVariable("IsSingular")
end

function CampBuildItem:__delete()
	self.log_content = nil
	self.is_singular = nil
end

function CampBuildItem:OnFlush()
	if not self.data or not next(self.data) then return end

	local time = TimeCtrl.Instance:GetServerTime() - self.data.report_time
	local log_time = TimeUtil.LastDonateTime(time)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	--local my_camp_name = CampData.Instance:GetCampNameByCampType(vo.name)
	-- local role_info = ToColorStr(my_camp_name .. self.data.my_name, TEXT_COLOR.BLUE_4)

	local exp_cfg = CampData.Instance:GetCampLevelExpAdd(self.data.type)
	if exp_cfg == nil or next(exp_cfg) == nil then
		return
	end

	local content = ""
	local build_log = Language.Camp.BuildLog[exp_cfg.reason]
	-- 判断日志是否是抢皇帝
	-- if exp_cfg.reason == 0 then
	-- 	my_camp = Language.Common.ScnenCampNameAbbr[vo.camp]
	-- 	content = log_time .. string.format(build_log, my_camp, ToColorStr(exp_cfg.add_exp, COLOR.ORANGE))
	-- else
	-- 	local enemy_camp_name = CampData.Instance:GetCampNameByCampType(self.data.param)
	-- 	local log_info = string.format(build_log, enemy_camp_name, ToColorStr(exp_cfg.add_exp, COLOR.ORANGE))
	-- 	content = log_time .. role_info ..  log_info
	-- end

	local camp_name = Language.Common.CampName[self.data.param]
	local my_camp_name = Language.Common.CampName[vo.camp]
	if exp_cfg.reason < 3 then
		content = log_time .. string.format(build_log, camp_name, exp_cfg.add_exp)
	else
		content = log_time .. string.format(build_log, my_camp_name, self.data.my_name, camp_name, exp_cfg.add_exp)
	end

	self.log_content:SetValue(content)
	self:SetBgStatus(self.index % 2 == 1)
end

function CampBuildItem:SetBgStatus(is_show)
	self.is_singular:SetValue(is_show)
end
