FubenMutilView = FubenMutilView or BaseClass(BaseView)

function FubenMutilView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("word_fuben_multi")

	self.texture_path_list[1] = "res/xui/fuben.png"
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"fuben_mutil_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	
	self.team_list_view = nil
	
end

function FubenMutilView:ReleaseCallBack()
	if self.team_list_view then
		self.team_list_view:DeleteMe()
		self.team_list_view = nil
	end
	
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.award_cell_list then
		for _, v in ipairs(self.award_cell_list) do
			v:DeleteMe()
		end
		self.award_cell_list = nil
	end

	if self.scene_change then
		GlobalEventSystem:UnBind(self.scene_change)
		self.scene_change = nil
	end
end

function FubenMutilView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateTeamList()
		self:CreateLinkTexts()
		-- self:CreateRoleDisplayModel()
		self:CreateAwardCells()
		XUI.AddClickEventListener(self.node_t_list.btn_create_team.node, BindTool.Bind(self.OnClickCreateTeam, self))
		-- XUI.AddClickEventListener(self.node_t_list.btn_tips.node, BindTool.Bind(self.OnClickTips, self))
	end

	EventProxy.New(FubenMutilData.Instance, self):AddEventListener(FubenMutilData.LEFT_ENTER_TIMES, BindTool.Bind(self.OnFlushLeftTimes, self))
	EventProxy.New(FubenTeamData.Instance, self):AddEventListener(FubenTeamData.FLUSH_MUTIL_DATA, BindTool.Bind(self.OnFlushMutilData, self))
	EventProxy.New(FubenTeamData.Instance, self):AddEventListener(FubenTeamData.FLUSH_TEAM_DATA, BindTool.Bind(self.OnFlushTeamData, self))
	-- EventProxy.New(FubenTeamData.Instance, self):AddEventListener(FubenTeamData.FLUSH_ROLE_MODEL, BindTool.Bind(self.OnFlushRoleModel, self))
	EventProxy.New(FubenTeamData.Instance, self):AddEventListener(FubenTeamData.REMOVE_TEAM_DATA, BindTool.Bind(self.OnRemoveTeamData, self))
	EventProxy.New(FubenTeamData.Instance, self):AddEventListener(FubenTeamData.CREATE_TEAM_DATA, BindTool.Bind(self.OnCreateTeamData, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneChange, self))
end

function FubenMutilView:CreateTeamList()
	local ph = self.ph_list.ph_team_list
	self.team_list_view = ListView.New()
	self.team_list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, FubenMutilTeamItem, ListViewGravity.CenterHorizontal, false, self.ph_list.ph_team_item)
	self.team_list_view:SetMargin(2)
	self.team_list_view:SetItemsInterval(2)
	self.team_list_view:SetJumpDirection(ListView.Top)
	self.team_list_view:SetAutoSupply(true)
	self.team_list_view:SetSelectCallBack(BindTool.Bind(self.OnSelectTeamItem, self))
	self.node_t_list.layout_fuben_mutil.node:addChild(self.team_list_view:GetView(), 10)
	self.cur_select_index = 1
end

function FubenMutilView:CreateLinkTexts()
	local text = RichTextUtil.CreateLinkText(Language.FubenMutil.LinkTexts[1], 20, COLOR3B.GREEN)
	text:setPosition(660, 25)
	self.node_t_list.layout_fuben_mutil.node:addChild(text, 100)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnClickInvateGuild, self), true)
	
	text = RichTextUtil.CreateLinkText(Language.FubenMutil.LinkTexts[2], 20, COLOR3B.GREEN)
	text:setPosition(850, 25)
	self.node_t_list.layout_fuben_mutil.node:addChild(text, 100)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnClickInvateServer, self), true)
end

function FubenMutilView:CreateRoleDisplayModel()
	-- self.role_model = RoleDisplay.New(self.node_t_list.layout_fuben_mutil.node, 99)
	-- self.role_model:SetPosition(295, 410)
	-- self.role_model:SetScale(1)
end

function FubenMutilView:CreateAwardCells()
	local award_list = FubenMutilData.GetFubenPannelAwardList(FubenMutilType.Team)
	local count = #award_list
	local ph = self.ph_list.ph_award_cell
	self.award_cell_list = {}
	for i = 1, count do
		local cell = BaseCell.New()
		-- cell:SetScale(0.8)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x + (i - 1) * (BaseCell.SIZE + 10), ph.y-13)
		cell:SetData({item_id = award_list[i].id, num = award_list[i].count, is_bind = award_list[i].bind})
		self.node_t_list.layout_award.node:addChild(cell:GetView(), 10)
		self.award_cell_list[i] = cell
	end
	local width = BaseCell.SIZE * count + 10 * (count - 1)
	self.node_t_list.layout_award.node:setContentWH(width, BaseCell.SIZE)
	self.node_t_list.layout_award.node:setPosition(587 / 2, 60)
end

function FubenMutilView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()

	FubenMutilCtrl.SendGetFubenTeamInfo(FubenMutilType.Team, FubenMutilId.Team)
	FubenMutilCtrl.SendGetFubenEnterTimes(FubenMutilType.Team)
	FubenMutilCtrl.SendOpenFubenMutilView(1)
end

function FubenMutilView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()

	FubenMutilCtrl.SendOpenFubenMutilView(2)
	self.cur_select_index = nil
end

function FubenMutilView:ShowIndexCallBack(index)
	self:OnFlushMutilData()
end

function FubenMutilView:OnFlush(param_t, index)
end

function FubenMutilView:OnFlushMutilData()
	self:FlushLeftEnterTimes()
	self:FlushLimitText()
	self:FlushTeamListView()
end
function FubenMutilView:OnFlushLeftTimes()
	self:FlushLeftEnterTimes()
end
function FubenMutilView:OnFlushRoleModel()
	local data_list = self.team_list_view:GetDataList()
	if type(data_list) == "table" then
		local data = data_list[self.cur_select_index or 1]
		if data ~= nil then
			local info = FubenMutilData.Instance:GetTeamDetailInfo(FubenMutilType.Team, FubenMutilLayer[133], data.team_id)
			self:ChangeRoleModel(info)
		end
	end
	self:FlushTeamListView()
end
function FubenMutilView:OnFlushTeamData()
	self:FlushTeamListView()
end
function FubenMutilView:OnRemoveTeamData()
	self:FlushTeamListView()
	if not FubenMutilData.Instance:IsMyCreatedTeam(FubenMutilType.Team, FubenMutilLayer[133]) then
		self.node_t_list.btn_create_team.node:setTitleText(Language.FubenMutil.CreateTeamBtnText[1])
	end
end
function FubenMutilView:OnCreateTeamData()
	if FubenMutilData.Instance:IsMyCreatedTeam(FubenMutilType.Team, FubenMutilLayer[133]) then
		self.node_t_list.btn_create_team.node:setTitleText(Language.FubenMutil.CreateTeamBtnText[2])
	end
end

function FubenMutilView:OnSceneChange(scene_id, scene_type, fuben_id)
	if FubenMutilId.Team == fuben_id and FubenMutilSceneId.Team == scene_id then 
		self:Close()
	end
end


function FubenMutilView:FlushLeftEnterTimes()
	local max_times = FubenMutilData.GetFubenMaxEnterTimes(FubenMutilType.Team)
	local used_times = FubenMutilData.Instance:GetFubenUsedTimes(FubenMutilType.Team)
	local left_times = max_times - used_times
	if left_times < 0 then left_times = 0 end
	local rich_desc = RichTextUtil.ParseRichText(self.node_t_list.rich_desc.node, string.format(Language.FubenMutil.PannelDesc, left_times <= 0 and "ff0000" or "00ff00", left_times, max_times), 18)
	rich_desc:setVerticalSpace(5)
end

function FubenMutilView:FlushTeamListView()
	self.team_list_view:CancelSelect()
	local team_data_list = FubenMutilData.Instance:GetTeamInfoList(FubenMutilType.Team, FubenMutilLayer[133])
	if type(team_data_list) == "table" then
		self.team_list_view:SetDataList(team_data_list)
		self.team_list_view:SelectIndex(self.cur_select_index or 1)
		if FubenMutilData.Instance:GetTeamCount(FubenMutilType.Team, FubenMutilLayer[133]) <= 0 then
			-- self.role_model:Reset(Scene.Instance:GetMainRole())
		end
	end
end

function FubenMutilView:FlushLimitText()
	local created = FubenMutilData.Instance:IsMyCreatedTeam(FubenMutilType.Team, FubenMutilLayer[133])
	self.node_t_list.btn_create_team.node:setTitleText(created and Language.FubenMutil.CreateTeamBtnText[2] or Language.FubenMutil.CreateTeamBtnText[1])

	local limit_level = FubenMutilData.GetFubenLimitLevel(FubenMutilType.Team, FubenMutilLayer[133])
	local my_level = RoleData.Instance:GetAttr(OBJ_ATTR.PROP_ACTOR_ONCE_MAX_LEVEL)
	self.node_t_list.lbl_cond.node:setString(string.format(Language.FubenMutil.LimitConds[1], limit_level))
	self.node_t_list.lbl_cond.node:setColor(my_level >= limit_level and COLOR3B.GREEN or COLOR3B.RED)
end

function FubenMutilView:ChangeRoleModel(info)
	for k, v in pairs(info or {}) do
		if v.is_leader == 1 then
			-- self.role_model:SetRoleResId(v.model_id)
			-- self.role_model:SetWuQiResId(v.weapon_id)
			-- self.role_model:SetChiBangResId(v.wing_id)
			break
		end
	end
end

function FubenMutilView:OnClickCreateTeam()
    local text = self.node_t_list.btn_create_team.node:getTitleText()
	if text == Language.FubenMutil.CreateTeamBtnText[1] then
	    FubenMutilCtrl.SendCreateTeam(FubenMutilType.Team, FubenMutilId.Team)
    elseif text == Language.FubenMutil.CreateTeamBtnText[2] then
		local team_list = FubenMutilData.Instance:GetTeamInfoList(FubenMutilType.Team, FubenMutilLayer[133])
		local team = team_list[1]
		local my_name = RoleData.Instance:GetRoleName()
		if team and team.leader_name == my_name then
			if team.menber_count < 2 then
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.FubenMutil.EnterFubenCond[1], 2))
			else
				FubenMutilCtrl.SendPreEnterFuben(FubenMutilType.Team, FubenMutilId.Team, team.team_id, team.fuben_layer)
			end
		end
    end
end

function FubenMutilView:OnClickTips()
	local max_times = FubenMutilData.GetFubenMaxEnterTimes(FubenMutilType.Team)
	local used_times = FubenMutilData.Instance:GetFubenUsedTimes(FubenMutilType.Team)
	local left_times = max_times - used_times
	if left_times < 0 then left_times = 0 end
	DescTip.Instance:SetContent(string.format(Language.FubenMutil.Desc,  left_times <= 0 and "ff0000" or "00ff00", left_times, max_times), Language.FubenMutil.TipTitle)
end

function FubenMutilView:OnSelectTeamItem(item, index)
	self.cur_select_index = index
	local data = item and item:GetData() or nil
	if data == nil then
		return
	end

	item:SetSelect(item:CanSelect())

	if data.menber_infos and next(data.menber_infos) ~= nil then
		self:ChangeRoleModel(data.menber_infos)
	else
		FubenMutilCtrl.SendGetTeamDetailInfo(FubenMutilType.Team, FubenMutilId.Team, data.team_id)
	end
end

function FubenMutilView:OnClickInvateGuild()
	FubenMutilCtrl.SendInvateFuben(FubenMutilType.Team, 2)
end

function FubenMutilView:OnClickInvateServer()
	FubenMutilCtrl.SendInvateFuben(FubenMutilType.Team, 1)
end


FubenMutilTeamItem = FubenMutilTeamItem or BaseClass(BaseRender)
function FubenMutilTeamItem:__init()
	
end

function FubenMutilTeamItem:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.btn_join.node:setTitleText("")
	XUI.AddClickEventListener(self.node_tree.btn_join.node, BindTool.Bind(self.OnClickJoin, self))
	XUI.AddClickEventListener(self.node_tree.lbl_team_count.node, BindTool.Bind(self.OnClickTeamCount, self))
end

function FubenMutilTeamItem:OnFlush()
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	self.node_tree.btn_join.node:setVisible(self.data ~= nil)
	self.node_tree.lbl_leader_name.node:setVisible(self.data ~= nil)
	self.node_tree.lbl_team_count.node:setVisible(self.data ~= nil)

	if self.data == nil then
        return 
	end

	local max_men_count = 5
	self.node_tree.lbl_leader_name.node:setString(self.data.leader_name)
	self.node_tree.lbl_team_count.node:setString(string.format("%d/%d", self.data.menber_count, max_men_count))
    local myname = RoleData.Instance:GetRoleName()
    if myname == self.data.leader_name then
        self.node_tree.btn_join.node:setTitleText(Language.FubenMutil.JoinBtnText[3])
		self.node_tree.lbl_leader_name.node:setColor(COLOR3B.GRAY)
		self.node_tree.lbl_team_count.node:setColor(COLOR3B.GRAY)
	elseif FubenMutilData.Instance:IsContainByName(myname, FubenMutilType.Team, FubenMutilId.Team, self.data.fuben_layer, self.data.team_id) then
		self.node_tree.btn_join.node:setTitleText(Language.FubenMutil.JoinBtnText[2])
		self.node_tree.lbl_leader_name.node:setColor(COLOR3B.GRAY)
		self.node_tree.lbl_team_count.node:setColor(COLOR3B.GRAY)
    else
        self.node_tree.btn_join.node:setTitleText(Language.FubenMutil.JoinBtnText[1])
		self.node_tree.lbl_leader_name.node:setColor(COLOR3B.OLIVE)
		self.node_tree.lbl_team_count.node:setColor(COLOR3B.OLIVE)
	end
end

function FubenMutilTeamItem:OnClickJoin()
	local text = self.node_tree.btn_join.node:getTitleText()
    if text == Language.FubenMutil.JoinBtnText[3] then
		FubenMutilCtrl.SendDissolveTeam(FubenMutilType.Team, FubenMutilId.Team, self.data.team_id)
    elseif text == Language.FubenMutil.JoinBtnText[2] then
		FubenMutilCtrl.SendExitTeamRequest(FubenMutilType.Team, FubenMutilId.Team, self.data.team_id)
    elseif text == Language.FubenMutil.JoinBtnText[1] then
		FubenMutilCtrl.SendJoinTeamRequest(FubenMutilType.Team, FubenMutilId.Team, self.data.team_id, self.data.fuben_layer)
    end
end

function FubenMutilTeamItem:OnClickTeamCount()
	FubenMutilCtrl.Instance:OpenMenListAlert(FubenMutilType.Team, FubenMutilId.Team, self.data.fuben_layer, self.data.team_id, MenberListAlert.OpenType.LOOK_MENBER)
end