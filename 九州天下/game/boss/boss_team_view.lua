BossFamilyTeamInfo = BossFamilyTeamInfo or BaseClass(BaseRender)

function BossFamilyTeamInfo:__init()
	self.star_gray_list = {}
	self.team_cells = {}
	for i=1,3 do
		self.star_gray_list[i] = self:FindVariable("star_gray_" .. i)
	end

	self.add_exp_text = self:FindVariable("add_exp_text")
	self.show_add_exp = self:FindVariable("show_add_exp")
	self.show_exit_btn = self:FindVariable("show_exit_btn")
	self.show_create_team = self:FindVariable("show_create_team")
	self:ListenEvent("Exit_Click", BindTool.Bind(self.ExitClick, self))
	self:ListenEvent("OpenTeam", BindTool.Bind(self.OpenTeam, self))
	self:ListenEvent("CreateTeam", BindTool.Bind(self.CreateTeam, self))
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))

	self.contain_cell_list = {}
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function BossFamilyTeamInfo:__delete()
	self.add_exp_text = nil
	self.show_add_exp = nil
	self.show_exit_btn = nil
	self.show_create_team = nil
	for i=1,3 do
		self.star_gray_list[i] = nil
	end
	self.team_cells = {}
	self.star_gray_list = {}

	if self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function BossFamilyTeamInfo:GetNumberOfCells()
	return #self.team_list
end

function BossFamilyTeamInfo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = BossFamilyTeamCell.New(cell.gameObject, self)
		contain_cell.parent = self
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.team_list[cell_index])
end

function BossFamilyTeamInfo:OnChangeScene()
	self:Flush()
end

function BossFamilyTeamInfo:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function BossFamilyTeamInfo:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function BossFamilyTeamInfo:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 2
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function BossFamilyTeamInfo:OnFlush()
	self.team_list = ScoietyData.Instance:GetMemberList()
	self.show_create_team:SetValue(not next(self.team_list))
	for i=1,3 do
		self.star_gray_list[i]:SetValue(i <= #self.team_list and self.team_list[i].is_online == 1)
	end
	self.show_add_exp:SetValue(#self.team_list > 0)
	self.add_exp_text:SetValue(ScoietyData.Instance:GetTeamExp(self.team_list))
	self.show_exit_btn:SetValue(#self.team_list > 0)
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end

function BossFamilyTeamInfo:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossFamilyTeamInfo:GetSelectIndex()
	return self.select_index or 0
end

function BossFamilyTeamInfo:FlushAllHl()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHl(self.select_index)
	end
end
---------------------------------------------------------------
BossFamilyTeamCell = BossFamilyTeamCell or BaseClass(BaseCell)
function BossFamilyTeamCell:__init()
	self.role_name = self:FindVariable("Name")
	self.level_text = self:FindVariable("LevelText")
	self.menber_state = self:FindVariable("MenberState")
	self.show_hl = self:FindVariable("show_hl")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function BossFamilyTeamCell:__delete()
	self.role_name = nil
	self.level_text = nil
	self.menber_state = nil
	self.parent = nil
end

function BossFamilyTeamCell:OnFlush()
	self.root_node.gameObject:SetActive(self.data ~= nil and next(self.data) ~= nil)
	if not self.data or not next(self.data) then return end

	local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
	local member_state = ScoietyData.Instance:GetMemberPosState(self.data.role_id, self.data.scene_id, self.data.is_online)
	self.role_name:SetValue(self.data.name)
	self.level_text:SetValue(Language.Mainui.Level3 .. self.data.level)
	self.menber_state:SetValue(member_state)

end

function BossFamilyTeamCell:ClickItem()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if main_role_id == self.data.role_id then
		self.show_hl:SetValue(false)
		return
	end

	self.parent:SetSelectIndex(self.index)
	self.parent:FlushAllHl()

	local function canel_callback()
		if self.root_node then
			self.show_hl:SetValue(false)
		end
	end

	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.name, nil, canel_callback)
end

function BossFamilyTeamCell:FlushHl(cur_index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.show_hl:SetValue(self.data and cur_index == self.index and main_role_id ~= self.data.role_id)
end