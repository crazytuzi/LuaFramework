RoyalTombFbView = RoyalTombFbView or BaseClass(BaseView)

function RoyalTombFbView:__init()
	self.ui_config = {"uis/views/royaltomb", "RoyalTombInfoView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.show_tab = 0
end

function RoyalTombFbView:LoadCallBack()
	self.show_panel = self:FindObj("TaskParent")

	self.member_list_point = {}
	for i = 1, 3 do
		self.member_list_point[i] = self:FindVariable("MemberPoint" .. i)
	end
	self.monster_cur_point = self:FindVariable("MonsterCurPoint")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))


	self.button_open_team = self:FindObj("ButtonOpenTeam")
	self.button_content = self:FindObj("ButtonContent")
	self.button_create_team = self:FindObj("ButtonCreateTeam")

	self.star_gray_list = {}
	for i=1,3 do
		self.star_gray_list[i] = self:FindVariable("star_gray_" .. i)
	end

	self.add_exp_text = self:FindVariable("add_exp_text")
	self.show_add_exp = self:FindVariable("show_add_exp")
	self.show_exit_btn = self:FindVariable("show_exit_btn")
	self:ListenEvent("Exit_Click", BindTool.Bind(self.ExitClick, self))
	self:ListenEvent("ChooseTab1", BindTool.Bind(self.OnChooseTab, self, 0))
	self:ListenEvent("ChooseTab2", BindTool.Bind(self.OnChooseTab, self, 1))

	-- 生成滚动条
	self.cell_list = {}
	self.team_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.team_list or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local menber_cell = self.cell_list[cell]
		if menber_cell == nil then
			menber_cell = MainUiMenberCell.New(cell.gameObject)
			menber_cell.root_node.toggle.group = self.list_view.toggle_group
			menber_cell.team_view = self
			self.cell_list[cell] = menber_cell
		end

		menber_cell:SetIndex(data_index)
		menber_cell:SetData(self.team_list[data_index])
	end

	self.button_open_team.button:SetClickListener(BindTool.Bind(self.OpenTeam, self))
	self.button_create_team.button:SetClickListener(BindTool.Bind(self.CreateTeam, self))

	--self:OnChangeScene()
	self:Flush()
end

function RoyalTombFbView:ReleaseCallBack()
	self.show_tab = 0

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.cell_list ~= nil then
		for _,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.cell_list = {}
	end

	if self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	self.show_panel = nil
	self.member_list_point = {}
	self.monster_cur_point = nil

	self.button_open_team = nil
	self.button_content = nil
	self.button_create_team = nil
	self.add_exp_text = nil
	self.show_add_exp = nil
	self.show_exit_btn = nil
	self.list_view = nil
	self.star_gray_list = {}
end

function RoyalTombFbView:SwitchButtonState(enable)
	self.show_panel:SetActive(enable)
end

function RoyalTombFbView:OnChooseTab(tab_type)
	local team_list = ScoietyData.Instance:GetMemberList() or {}
	if self.show_tab == 1  and tab_type == 1 and #team_list > 0 then
		ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	end

	self.show_tab = tab_type
	self:Flush()
end

function RoyalTombFbView:OnFlush(param_t)
	if self.show_tab == 0 then
		local royaltomb_info = RoyTombData.Instance:GetHuanglingFBRoleInfo()
		local info_cfg = RoyTombData.Instance:GetRoyTombInfoCfg()
	 	if info_cfg and info_cfg.other and royaltomb_info then
			local other_cfg = info_cfg.other[1]
			local string = royaltomb_info.today_kill_role_score .. " / " .. other_cfg.kill_role_score_limit
			local str = string.format(Language.RoyalTomb.MonsterScore, string)
			self.monster_cur_point:SetValue(str)
			for i = 1, 3 do
			 	local team_info_list = royaltomb_info.team_info_list
			 	if team_info_list and team_info_list[i] then
			 		local name = team_info_list[i].name
			 		if name == "" then name = Language.RoyalTomb.NotIn end
					local str = string.format("<color=#ffffff>%s</color>", team_info_list[i].shared_score)
			 		self.member_list_point[i]:SetValue(name .. "：" .. str)
			 	end
			end
		end
	else
		self:ReloadData()
	end
end


function RoyalTombFbView:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

-- function RoyalTombFbView:OnChangeScene()
-- 	self:ReloadData()
-- end

function RoyalTombFbView:ReloadData()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.team_list = ScoietyData.Instance:GetMemberList()
		if not next(self.team_list) then
			self.button_content:SetActive(true)
		else
			self.button_content:SetActive(false)
		end
		self.list_view.scroller:ReloadData(0)
		for i=1,3 do
			self.star_gray_list[i]:SetValue(i <= #self.team_list and self.team_list[i].is_online == 1)
		end
	end
	self.show_add_exp:SetValue(self.list_view.scroller.isActiveAndEnabled and #self.team_list > 0)
	self.add_exp_text:SetValue(ScoietyData.Instance:GetTeamExp(self.team_list))
	self.show_exit_btn:SetValue(#self.team_list > 0)
end

function RoyalTombFbView:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	ScoietyCtrl.Instance:ShowNearTeamView()
end

function RoyalTombFbView:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 2
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function RoyalTombFbView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function RoyalTombFbView:GetSelectIndex()
	return self.select_index or 0
end