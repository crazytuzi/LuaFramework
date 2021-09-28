--------------------------------------------------------------------------
--PlayerTitleView 	称号面板视图
--------------------------------------------------------------------------
PlayerTitleView = PlayerTitleView or BaseClass(BaseRender)

function PlayerTitleView:__init(instance)
	if instance == nil then
		return
	end
	self:ListenEvent("OnClickJinjie", BindTool.Bind(self.OnClickJinjie, self))
	self:ListenEvent("attr_btn",BindTool.Bind(self.AllAttriBtnOnClick, self))
	self:ListenEvent("unwield_btn", BindTool.Bind(self.OnUnwieldClick, self))
	self:ListenEvent("adron_btn",BindTool.Bind(self.OnAdronClick, self))
	self:ListenEvent("OnClickActive", BindTool.Bind(self.SelectTitleCfg, self, ACTIVE_TITLE))
	self:ListenEvent("OnClickSpecial", BindTool.Bind(self.SelectTitleCfg, self, SPECIAL_TITLE))

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
	self.remian_time_text = self:FindVariable("remian_time_text")
	self.show_remind_time = self:FindVariable("show_remind_time")

	self.add_buff_list = {}
	for i=1,3 do
		self.add_buff_list[i] = {}
		self.add_buff_list[i].add_buff = self:FindVariable("add_buff_"..i)
		self.add_buff_list[i].show_buff = self:FindVariable("show_add_buff_"..i)
	end

	local title_data = TitleData.Instance
	self.current_title_id = title_data:GetCurTitleId()
	self.title_contain_list = {}
	self.adron_title_frame = self:FindObj("adron_title_frame")
	self:FlushTitle()
	self:UpdateAttribute()
	self.title_type = TitleData.Instance:GetDefTitleType()
	self.show_jinjie_red_point = self:FindVariable("ShowJinjieRedPoint")
	self.title_id_list = TitleData.Instance:ResortTitleIdList(self.title_type)
	self.all_title_id_cfg = TitleData.Instance:GetAllTitle(self.title_type)
	self.special_button = self:FindObj("SpecialButton")
	self.active_button = self:FindObj("ActiveButton")
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.TitleGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.TitleRefreshCell, self)
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.PlayerTitle)
	self.special_button.toggle.isOn = (self.title_type == SPECIAL_TITLE)
	self.active_button.toggle.isOn = (self.title_type == ACTIVE_TITLE)
end

function PlayerTitleView:__delete()
	RemindManager.Instance:UnBind(self.remind_change)
	for k, v in pairs(self.title_contain_list) do
		v:DeleteMe()
	end
	self.title_contain_list = {}
	self.current_title_id = 0
end

function  PlayerTitleView:SelectTitleCfg(title_type)
	if self.title_type == title_type then return end

	self.title_type = title_type
	self.all_title_id_cfg = TitleData.Instance:GetAllTitle(title_type)
	local title_id = TitleData.Instance:ResortTitleIdList(title_type)[1]
	self.list_view.scroller:ReloadData(0)
	self:SetCurrentId(title_id)
end

function PlayerTitleView:SetCurrentId(title_id)
	self.current_title_id = title_id
	self:Flush()
end

function PlayerTitleView:GetCurrentId()
	return self.current_title_id
end

----------点击事件------------
function PlayerTitleView:OnClickJinjie()
	ViewManager.Instance:Open(ViewName.PlayerTitleHuanhua)
end

function PlayerTitleView:AllAttriBtnOnClick()
	local attr = TitleData.Instance:GetShowAttrList()
	TipsCtrl.Instance:ShowFashionAttrView(attr.attack, attr.defense, attr.hp, attr.power, Language.Player.TitleAttrName);

end

function PlayerTitleView:OnUnwieldClick()
	TitleCtrl.Instance:SendCSUseTitle({0,0,0})
end

function PlayerTitleView:OnAdronClick()
	if not TitleData.Instance:GetTitleActiveState(self.current_title_id) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Role.TitleNotActivate)
		return
	end
	if not TitleData.Instance:GetIsUsed(self.current_title_id) then
		local used_title_list = {self.current_title_id, 0, 0}
		TitleCtrl.Instance:SendCSUseTitle(used_title_list)
	end
end
----------点击事件------------

function PlayerTitleView:TitleGetNumberOfCells()
	return math.ceil(#self.all_title_id_cfg/2)
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

function PlayerTitleView:ChangeBtnState()
	local title_data = TitleData.Instance
	local cur_adron_id = title_data:GetUsedTitle()
	self.show_adron_btn:SetValue(self.current_title_id ~= cur_adron_id)
	self.show_unwield_btn:SetValue(self.current_title_id == cur_adron_id)
	self.show_adron_interactable:SetValue(title_data:GetTitleActiveState(self.current_title_id))
end

function PlayerTitleView:OnFlush()
	self.title_id_list = TitleData.Instance:ResortTitleIdList(self.title_type)
	self:ChangeBtnState()
	self:FlushTitle()
	self:FlushAllHL()
	self:UpdateAttribute()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
	local buff_cfg_list = TitleData.Instance:GetTitleAddBuffList(self.current_title_id)
	for i=1,3 do
		self.add_buff_list[i].add_buff:SetValue(buff_cfg_list[i]/100)
		self.add_buff_list[i].show_buff:SetValue(buff_cfg_list[i] ~= 0)
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

function PlayerTitleView:SetRemindTime(remind_time)
	self.remian_time_text:SetValue(remind_time)
	if remind_time ~= "" then
		self.show_remind_time:SetValue(true)
	else
		self.show_remind_time:SetValue(false)
	end
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
	self.remian_time_text = self:FindVariable("remian_time_text")
end

function TitleCell:__delete()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
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
	-- self.remian_time_text:SetValue("")
	-- PlayerCtrl.Instance:SetTitleRemindTime("")
	self.expired_time = 0
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	for k,v in pairs(title_cfg.title_list) do
		if self.data == v.title_id then
			is_active = true
			local title_view = PlayerCtrl.Instance:GetTitleView()
			if v.expired_time ~= 0 and title_view:GetCurrentId() == self.data then
				self.expired_time = v.expired_time
				PlayerCtrl.Instance:SetTitleRemindTime(TitleData.Instance:ConvertTime(self.expired_time))
				-- local time_diff = v.expired_time - TimeCtrl.Instance:GetServerTime()
				-- self.count_down = CountDown.Instance:AddCountDown(time_diff, 1, BindTool.Bind(self.CountDown, self))
			end
		end
	end

	self.show_gray:SetValue(is_active)
end

function TitleCell:TitleOnClick(is_click)
	if is_click then
		local title_view = PlayerCtrl.Instance:GetTitleView()
		if title_view and title_view:GetCurrentId() ~= self.data then
			title_view:SetCurrentId(self.data)
			if self.expired_time == 0 then
				PlayerCtrl.Instance:SetTitleRemindTime("")
			end
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

function TitleCell:CountDown(elapse_time, total_time)
	if elapse_time < total_time then
		if self.expired_time > 0 then
			PlayerCtrl.Instance:SetTitleRemindTime(TitleData.Instance:ConvertTime(self.expired_time))
		end
	end
end



