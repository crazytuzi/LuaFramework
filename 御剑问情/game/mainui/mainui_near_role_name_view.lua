MainUINearPeopleView = MainUINearPeopleView or BaseClass(BaseView)

function MainUINearPeopleView:__init()
	self.ui_config = {"uis/views/main_prefab", "NearPeopleView"}
	self.view_layer = UiLayer.Normal
end

function MainUINearPeopleView:LoadCallBack()
	self.name_cell_list = {}
	self.only_show_can_atk_toggle = self:FindObj("OnlyShowCanAtkToggle").toggle
	self.only_show_can_atk_toggle:AddValueChangedListener(BindTool.Bind(self.OnNearRoleToggleChange, self))
	self.near_role_list_view = self:FindObj("NearRoleListView")
	local near_role_list_delegate = self.near_role_list_view.list_simple_delegate
	near_role_list_delegate.NumberOfCellsDel = BindTool.Bind(self.NearRoleNum, self)
	near_role_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNearRoleView, self)
	self:ListenEvent("CloseNearRoleView",BindTool.Bind(self.CloseNearRoleView, self))
	self.obj_enter_level_role = GlobalEventSystem:Bind(SceneEventType.OBJ_ENTER_LEVEL_ROLE, BindTool.Bind(self.FlushNearRoleView, self))
	self.be_select = GlobalEventSystem:Bind(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObjHead, self))
	self.obj_delete = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDeleteHead, self))
	self.obj_dead = GlobalEventSystem:Bind(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDeleteHead, self))
end

function MainUINearPeopleView:ReleaseCallBack()
	for _, v in pairs(self.name_cell_list) do
		v:DeleteMe()
	end
	self.name_cell_list = {}
	self.only_show_can_atk_toggle = nil
	self.near_role_list_view = nil
	if self.obj_enter_level_role ~= nil then
		GlobalEventSystem:UnBind(self.obj_enter_level_role)
		self.obj_enter_level_role = nil
	end
	if self.be_select ~= nil then
		GlobalEventSystem:UnBind(self.be_select)
		self.be_select = nil
	end
	if self.obj_delete ~= nil then
		GlobalEventSystem:UnBind(self.obj_delete)
		self.obj_delete = nil
	end
	if self.obj_dead ~= nil then
		GlobalEventSystem:UnBind(self.obj_dead)
		self.obj_dead = nil
	end
end

function MainUINearPeopleView:OnNearRoleToggleChange(is_on)
	self.near_role_toggle_is_on = is_on
	if self.near_role_list_view and self.near_role_list_view.scroller.isActiveAndEnabled then
		self.near_role_list_view.scroller:ReloadData(0)
	end
end

function MainUINearPeopleView:NearRoleNum()
	return #self:GetCanAtkRole()
end

function MainUINearPeopleView:RefreshNearRoleView(cell, data_index)
	local name_cell = self.name_cell_list[cell]
	if not name_cell then
		name_cell = NearRoleNameCell.New(cell.gameObject)
		self.name_cell_list[cell] = name_cell
	end
	local list = self:GetCanAtkRole()
	name_cell:ListenClick(BindTool.Bind(self.OnClickRoleName, self, list[data_index + 1]))
	name_cell:SetIndex(data_index)
	name_cell:SetData(list[data_index + 1])
end

function MainUINearPeopleView:OnClickRoleName(obj)
	if not obj then return end
	obj:OnClicked()
end

function MainUINearPeopleView:GetCanAtkRole()
	local list = {}
	for k, v in pairs(Scene.Instance:GetRoleList()) do
		if not v:IsMainRole() and not v:IsModelTransparent() then
			if not self.near_role_toggle_is_on then
				table.insert(list, v)
			elseif self.near_role_toggle_is_on and Scene.Instance:IsEnemy(v) then
				table.insert(list, v)
			end
		end
	end
	return list
end

function MainUINearPeopleView:OpenNearRole()
	if self.near_role_list_view and self.near_role_list_view.scroller.isActiveAndEnabled then
		self.near_role_list_view.scroller:ReloadData(0)
	end
end

function MainUINearPeopleView:OnObjDeleteHead(obj)
	if SceneObj.select_obj == nil or SceneObj.select_obj == obj then
		self:FlushNearRoleView()
	end
end

function MainUINearPeopleView:OnSelectObjHead(target_obj, select_type)
	self:FlushNearRoleView()
end

function MainUINearPeopleView:FlushNearRoleView()
	if self.near_role_list_view and self.near_role_list_view.scroller.isActiveAndEnabled then
		self.near_role_list_view.scroller:ReloadData(0)
	end
end

function MainUINearPeopleView:CloseNearRoleView()
	self:Close()
end

--------------------------------------附近玩家Cell-----------------------------------------------

NearRoleNameCell = NearRoleNameCell or BaseClass(BaseRender)
function NearRoleNameCell:__init(instance)
	self.name = self:FindVariable("Name")
	self.zhanli = self:FindVariable("ZhanLi")
	self.show_select = self:FindVariable("ShowSelect")
	self.is_single = self:FindVariable("Is_Single")
	self.index = 0
end

function NearRoleNameCell:SetData(obj)
	local vo = obj and obj:GetVo() or {}
	local color = vo.name_color == EvilColorList.NAME_COLOR_WHITE and TEXT_COLOR.YELLOW or TEXT_COLOR.RED
	local name = vo.name or ""
	local cap = vo.total_capability or 0
	if cap > 0 then
		self.zhanli:SetValue(cap)
	end
	self.name:SetValue(name)
	self.show_select:SetValue(SceneObj.select_obj == obj)
	self.is_single:SetValue(1 == self.index % 2)
end

function NearRoleNameCell:ListenClick(handler)
	self:ClearEvent("OnClickName")
	self:ListenEvent("OnClickName", handler)
end

function NearRoleNameCell:SetIndex(index)
	self.index = index
end
