--------------------------------------------------------------------------
--PlayerTitleView 	称号面板视图
--------------------------------------------------------------------------
PlayerTitleView = PlayerTitleView or BaseClass(BaseRender)

function PlayerTitleView:__init(instance)
	if instance == nil then
		return
	end
	--self:FlushModel()
end

function PlayerTitleView:LoadCallBack()
	self:ListenEvent("close_attr_tips",BindTool.Bind(self.OnCloseTipsClick, self))
	self:ListenEvent("OnClickJinjie", BindTool.Bind(self.OnClickJinjie, self))
	self:ListenEvent("attr_btn",BindTool.Bind(self.AllAttriBtnOnClick, self))
	self:ListenEvent("unwield_btn", BindTool.Bind(self.OnUnwieldClick, self))
	self:ListenEvent("adron_btn",BindTool.Bind(self.OnAdronClick, self))

	--Attribute面板
	self.attck_value = self:FindVariable("attack_value")
	self.defense_value = self:FindVariable("defense_value")
	self.hp_value = self:FindVariable("hp_value")
	self.power_value = self:FindVariable("power_value")
	self.describe_value = self:FindVariable("describe_value")
	self.show_adron_interactable = self:FindVariable("show_adron_interactable")
	self.show_adron_btn = self:FindVariable("show_adron_btn")
	self.show_unwield_btn = self:FindVariable("show_unwield_btn")
	self.title_icon = self:FindVariable("title_icon")
	--获取称号总属性面板信息
	self.all_attack_value = self:FindVariable("all_attack_value")
	self.all_defense_value = self:FindVariable("all_defense_value")
	self.all_hp_value = self:FindVariable("all_hp_value")
	self.all_power_value = self:FindVariable("all_power_value")
	self.all_attribute_contain = self:FindObj("all_attribute_contain")
	self.display = self:FindObj("Display")

	local title_data = TitleData.Instance
	self.current_title_id = title_data:GetUsedTitle() or title_data:GetTitleInfo().title_id_list[1] or title_data:GetFirstTitleId()
	self.title_contain_list = {}
	self.adron_title_frame = self:FindObj("adron_title_frame")
	--self:FlushTitle()
	self:UpdateAttribute()
	self.show_jinjie_red_point = self:FindVariable("ShowJinjieRedPoint")
	self.title_id_list = TitleData.Instance:ResortTitleIdList()
	self.all_title_id_cfg = TitleData.Instance:GetAllTitle()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.TitleGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.TitleRefreshCell, self)
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.PlayerTitle)
end

function PlayerTitleView:__delete()
	RemindManager.Instance:UnBind(self.remind_change)
	for k, v in pairs(self.title_contain_list) do
		v:DeleteMe()
	end
	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	self.title_contain_list = {}
	self.current_title_id = 0
end

function PlayerTitleView:SetCurrentId(title_id)
	self.current_title_id = title_id
	self:Flush()
end

function PlayerTitleView:GetCurrentId()
	return self.current_title_id
end

function PlayerTitleView:FlushModel()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.display.ui3d_display)
	end
	if self.role_model then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.role_model:SetModelResInfo(role_vo, nil, nil, nil, nil, true)
	end
end

----------点击事件------------
function PlayerTitleView:OnClickJinjie()
	ViewManager.Instance:Open(ViewName.PlayerTitleHuanhua)
end

function PlayerTitleView:OnCloseTipsClick()
	self.all_attribute_contain:SetActive(false)
end

function PlayerTitleView:AllAttriBtnOnClick()
	--self.all_attribute_contain:SetActive(true)
	local attr = TitleData.Instance:GetShowAttrList()
	-- self.all_attack_value:SetValue(attr.attack)
	-- self.all_defense_value:SetValue(attr.defense)
	-- self.all_hp_value:SetValue(attr.hp)
	--self.all_power_value:SetValue(attr.power)
	local attribute = CommonStruct.Attribute()
	attribute.gong_ji = attr.attack
	attribute.fang_yu = attr.defense
	attribute.max_hp = attr.hp

	TipsCtrl.Instance:OpenGeneralView(attribute)
end

function PlayerTitleView:OnUnwieldClick()
	TitleCtrl.Instance:SendCSUseTitle({0,0,0})
end

function PlayerTitleView:OnAdronClick()
	if not TitleData.Instance:GetIsUsed(self.current_title_id) then
		local used_title_list = {self.current_title_id, 0, 0}
		TitleCtrl.Instance:SendCSUseTitle(used_title_list)
	end
end
----------点击事件------------

function PlayerTitleView:TitleGetNumberOfCells()
	return math.ceil(#self.title_id_list/2)
end

function PlayerTitleView:TitleRefreshCell(contain,cell_index)
	local title_contain = self.title_contain_list[contain]
	if title_contain == nil then
		title_contain = TitleContain.New(contain.gameObject, self)
		self.title_contain_list[contain] = title_contain
		title_contain:SetToggleGroup(self.list_view.toggle_group)
	end
	local data = {self.title_id_list[2 * cell_index + 1] , self.title_id_list[2 * cell_index + 2]}
	title_contain:SetData(data)
end

--更新属性面板
function PlayerTitleView:UpdateAttribute()
	local title_cfg = TitleData.Instance:GetUpgradeCfg(self.current_title_id)
	if not title_cfg then
		title_cfg = TitleData.Instance:GetTitleCfg(self.current_title_id)
	end
	if title_cfg == nil then return end
	self.attck_value:SetValue(title_cfg.gongji)
	self.defense_value:SetValue(title_cfg.fangyu)
	self.hp_value:SetValue(title_cfg.maxhp)
	local desc = ""
	if not title_cfg.desc then
		desc = TitleData.Instance:GetTitleCfg(self.current_title_id).desc
	end
	self.describe_value:SetValue(title_cfg.desc or desc)
	self.power_value:SetValue(CommonDataManager.GetCapabilityCalculation(title_cfg))
end

function PlayerTitleView:SetUiTitle(ui_title_res)
	self.ui_title_res = ui_title_res
	self:FlushTitle()
end

function PlayerTitleView:FlushTitle()
	local bundle, asset = ResPath.GetTitleIcon(self.current_title_id)
	self.title_icon:SetAsset(bundle, asset)
	if self.ui_title_res then
		self.ui_title_res:SetAsset(bundle, asset)
	end
end

function PlayerTitleView:SetAllAttributeFalse()
	self.all_attribute_contain:SetActive(false)
end

function PlayerTitleView:ChangeBtnState()
	local title_data = TitleData.Instance
	local cur_adron_id = title_data:GetUsedTitle()
	self.show_adron_btn:SetValue(self.current_title_id ~= cur_adron_id)
	self.show_unwield_btn:SetValue(self.current_title_id == cur_adron_id)
	self.show_adron_interactable:SetValue(title_data:GetTitleActiveState(self.current_title_id))
end

function PlayerTitleView:OnFlush()
	self.title_id_list = TitleData.Instance:ResortTitleIdList()
	self:ChangeBtnState()
	self:FlushTitle()
	self:FlushAllHL()
	self:FlushModel()
	self:UpdateAttribute()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function PlayerTitleView:FlushAllHL()
	for k,v in pairs(self.title_contain_list) do
		v:FlushHL()
	end
end

function PlayerTitleView:RemindChangeCallBack(remind_name, num)
	self.show_jinjie_red_point:SetValue(num > 0)
end

--------------------------------------------------------------------------
--TitleContain 		称号容器
--------------------------------------------------------------------------

TitleContain = TitleContain  or BaseClass(BaseCell)

function TitleContain:__init()
	self.title_cell_list = {}
	for i = 1, 2 do
		self.title_cell_list[i] = TitleCell.New(self:FindObj("TitleContent"..i))
	end
end

function TitleContain:__delete()
	for i=1,2 do
		self.title_cell_list[i] = nil
	end
	self.title_cell_list = {}
end

function TitleContain:OnFlush()
	for i=1,2 do
		self.title_cell_list[i]:SetData(self.data[i])
	end
end

function TitleContain:SetToggleGroup(toggle_group)
	for i=1,2 do
		self.title_cell_list[i]:SetToggleGroup(toggle_group)
	end
end

function TitleContain:FlushHL()
	for i=1,2 do
		self.title_cell_list[i]:FlushHL()
	end
end
----------------------------------------------------------------------------
--TitleCell 		称号滚动条格子
----------------------------------------------------------------------------

TitleCell = TitleCell or BaseClass(BaseCell)

function TitleCell:__init()
	self.show_hight_light = self:FindVariable("show_hight_light")
	self.title_icon = self:FindVariable("title_icon")
	self.show_gray = self:FindVariable("show_gray")
	self.cell_toggle = self.root_node.toggle
	self.cell_toggle:AddValueChangedListener(BindTool.Bind(self.TitleOnClick, self))
	self.adorn_go = self:FindObj("adorn_go")
end

function TitleCell:__delete()
end

function TitleCell:OnFlush()
	self.root_node:SetActive(true)
	if self.data == nil then
		self.root_node:SetActive(false)
		return
	end
	self.adorn_go:SetActive(TitleData.Instance:GetIsUsed(self.data))
	self:FlushHL()
	local bundle, asset = ResPath.GetTitleIcon(self.data)
	self.title_icon:SetAsset(bundle, asset)
	local is_active = false
	local title_cfg = TitleData.Instance:GetTitleInfo()
	for k,v in pairs(title_cfg.title_id_list) do
		if self.data == v then
			is_active = true
		end
	end
	self.show_gray:SetValue(is_active)
end

function TitleCell:TitleOnClick(is_click)
	if is_click then
		local title_view = PlayerCtrl.Instance:GetTitleView()
		if title_view and title_view:GetCurrentId() ~= self.data then
			title_view:SetCurrentId(self.data)
		end
	end
end

function TitleCell:FlushHL()
	local title_view = PlayerCtrl.Instance:GetTitleView()
	if title_view then
		self.show_hight_light:SetValue(self.data == title_view:GetCurrentId())
	end
end

function TitleCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

