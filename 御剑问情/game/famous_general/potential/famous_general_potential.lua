FamousGeneralPotentialContent = FamousGeneralPotentialContent or BaseClass(BaseRender)


local ATTR_LIST_NUM = 3
local SKILL_NUM = 4
local VIEW_STATE =
{
	ONADVANCE = 1,
	NOADVANCE = 2,
}
function FamousGeneralPotentialContent:__init()
	self.cur_select_index = 1
	self.init_scorller_num = 0
	self.auto_advance = false
	self.role_cell_list = {}
	self.view_flag = self:FindVariable("view_flag")
	self.name = self:FindVariable("name")

	self.attr_list = {}
	for i=1, ATTR_LIST_NUM do
		self.attr_list[i] = {}
		self.attr_list[i].cur_attr = self:FindVariable("attr" .. i)
		self.attr_list[i].next_attr = self:FindVariable("next_attr" .. i)
	end

	self.cur_level = self:FindVariable("cur_level")
	self.next_level = self:FindVariable("next_level")
	self.show_effect = self:FindVariable("show_effect")

	self.blessing = self:FindVariable("blessing")
	self.blessing_num = self:FindVariable("blessing_num")
	self.total_blessing = self:FindVariable("total_blessing")

	self.have_num = self:FindVariable("have_num")
	self.need_num = self:FindVariable("need_num")
	self.fight_power = self:FindVariable("fight_power")

	local display = self:FindObj("Display")
	self.role_model = RoleModel.New()
	self.role_model:SetDisplay(display.ui3d_display)

	self.item_obj = self:FindObj("ItemCell")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.item_obj)

	self.role_list = self:FindObj("ListView")
	local list_delegate = self.role_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoleNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRoleCell, self)

	self.auto_buy_toggle = self:FindObj("auto_buy")
	self.auto_buy_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutuBuyChange, self))

	self.slider = self:FindObj("Slider").slider

	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("AutomaticAdvance", BindTool.Bind(self.AutomaticAdvance, self))
	self:InitData()
end

function FamousGeneralPotentialContent:InitData()
	self.view_flag:SetValue(VIEW_STATE.NOADVANCE)
end

function FamousGeneralPotentialContent:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
end

function FamousGeneralPotentialContent:GetRoleNum()
	return FamousGeneralData.Instance:GetListNum()
end

function FamousGeneralPotentialContent:RefreshRoleCell(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.role_cell_list[cell]
	local data_list = FamousGeneralData.Instance:GetSortGeneralList()
	if not item_cell then
		item_cell = GeneralHeadRender.New(cell.gameObject)
		self.role_cell_list[cell] = item_cell

		self.init_scorller_num = self.init_scorller_num + 1
		if self.init_scorller_num == FamousGeneralData.Instance:GetListNum() then
		end
	end
	item_cell:SetIndex(cell_index)
	if data_list[cell_index] then
		item_cell:SetTabIndex(TabIndex.famous_general_potential)
		item_cell:SetData(data_list[cell_index])
		item_cell:SetClickCallBAck(function (data)
			self:OnClickRole(data)
		end)
	end
	item_cell:FlushHL(self.cur_select_index)
end

function FamousGeneralPotentialContent:OnFlush(param_list)
	if FamousGeneralCtrl.Instance:GetMainViewShowIndex() ~= TabIndex.famous_general_potential then
		self.auto_advance = false
		self.stop = true
		return
	end
	self:ConstructData()
	self:SetFlag()
	for k,v in pairs(param_list) do
		if k == "active" then
			self.role_list.scroller:ReloadData(0)
		elseif k == "uplevel" then
			self.auto_advance = false
			self:SetFlag()
		elseif k == "flush_model" then
			self:ModelFlush()
		elseif k == "on_uplevel" then
			if not self.stop then
				self.auto_advance = true
				self:AutoAdvance()
				self:SetFlag()
			end
		elseif k == "change_index" then
			self.slider.value = 0
		end
	end

	self:SetModel()
	self:SetInfo()
	self:SetProgress()
	self:SetItem()
	self.role_list.scroller:RefreshActiveCellViews()
end

function FamousGeneralPotentialContent:CloseCallBack()
	self.is_close = true
	self.auto_advance = false
end

function FamousGeneralPotentialContent:ConstructData()
	self.construct = true
	local data_instance = FamousGeneralData.Instance
	self.cur_level_value = data_instance:GetPotentialLevel(self.cur_select_index)
	self.name_value = data_instance:GetGeneralName(self.cur_select_index)
	self.next_level_value = data_instance:GetNextPotentialLevel(self.cur_select_index)
	self.seq = data_instance:GetDataSeq(self.cur_select_index)

	self.blessing_num_value = data_instance:GetBlessingNum(self.cur_select_index)
	self.total_bless_value = data_instance:GetTotalBless(self.cur_select_index)
	self.blessing_value = self.blessing_num_value / self.total_bless_value
	self.have_num_value = data_instance:GetPotentialHaveNum(self.cur_select_index)
	self.need_num_value = data_instance:GetPotentialNeedNum(self.cur_select_index)
	self.item_id = data_instance:GetPotentialItemId(self.cur_select_index)

	self.attr_list_values = {}
	for i=1, ATTR_LIST_NUM do
		self.attr_list_values[i] = {}
		self.attr_list_values[i].cur_attr = data_instance:GetPotentialAttr(self.cur_select_index, i)
		self.attr_list_values[i].next_attr = data_instance:GetPotentialNextAttr(self.cur_select_index, i)
	end
	local attr_list = {}
	for i=1, ATTR_LIST_NUM do
		attr_list[GameEnum.AttrList[i]] = self.attr_list_values[i].cur_attr
	end
	self.fight_power_value = CommonDataManager.GetCapabilityCalculation(attr_list)

	if self.role_res_id == data_instance:GetGeneralModel(self.cur_select_index) then
		self.set_model_flag = false
	else
		self.set_model_flag = true
		self.role_res_id = data_instance:GetGeneralModel(self.cur_select_index)
	end
end

function FamousGeneralPotentialContent:SetFlag()
	if self.auto_advance then
		self.view_flag:SetValue(VIEW_STATE.ONADVANCE)
		return
	else
		self.view_flag:SetValue(VIEW_STATE.NOADVANCE)
		return
	end
end

function FamousGeneralPotentialContent:SetModel()
	if self.construct == nil or not self.set_model_flag then
		return
	end

	local bundle, asset = ResPath.GetGeneralRes(self.role_res_id)
	self.role_model:SetMainAsset(bundle, asset, function ()
		self:ModelFlush()
	end)
	self.role_model:SetTrigger("attack3")
end

function FamousGeneralPotentialContent:ModelFlush()
	if self.role_model then
		local fazhen_objs = FindObjsByName(self.role_model.draw_obj:GetPart(SceneObjPart.Main).obj.transform, "fazhen_effect")
		local weapon_objs = FindObjsByName(self.role_model.draw_obj:GetPart(SceneObjPart.Main).obj.transform, "weapon_effect")
		for k,v in pairs(fazhen_objs) do
			v.gameObject:SetActive(FamousGeneralData.Instance:IsShowFaZhen(self.cur_select_index))
		end
		for k,v in pairs(weapon_objs) do
			v.gameObject:SetActive(FamousGeneralData.Instance:IsShowGuangWu(self.cur_select_index))
		end
	end
end

function FamousGeneralPotentialContent:SetInfo()
	if self.construct == nil then
		return
	end

	self.name:SetValue(self.name_value)
	self.cur_level:SetValue(self.cur_level_value)
	self.next_level:SetValue(self.next_level_value)

	for i=1, ATTR_LIST_NUM do
		self.attr_list[i].cur_attr:SetValue(self.attr_list_values[i].cur_attr)
		self.attr_list[i].next_attr:SetValue(self.attr_list_values[i].next_attr)
	end
	self.fight_power:SetValue(self.fight_power_value)
end

function FamousGeneralPotentialContent:SetProgress()
	if not self.construct then
		return
	end

	self.blessing_num:SetValue(self.blessing_num_value)
	self.total_blessing:SetValue(self.total_bless_value)

	self.blessing:SetValue(self.blessing_value)
end

function FamousGeneralPotentialContent:SetItem()
	self.item:SetData({item_id = self.item_id})
	local have_num_str = self.have_num_value
	if self.have_num_value < self.need_num_value then
		have_num_str = ToColorStr(have_num_str, TEXT_COLOR.RED)
	else
		have_num_str = ToColorStr(have_num_str, TEXT_COLOR.YELLOW1)
	end
	self.have_num:SetValue(have_num_str)
	self.need_num:SetValue(self.need_num_value)
end
------------------------------------点击事件---------------
function FamousGeneralPotentialContent:OnClickRole(index)
	if self.cur_select_index == index then
		return
	end
	self.cur_select_index = index
	for k,v in pairs(self.role_cell_list) do
		v:FlushHL(self.cur_select_index)
	end
	self.stop = true
	self.auto_advance = false
	self:Flush("change_index")
end

function FamousGeneralPotentialContent:OnClickHelp()
	
end

function FamousGeneralPotentialContent:AutomaticAdvance()
	if not self.construct then
		return
	end
	if self.auto_advance then
		self.auto_advance = false
		self.stop = true
		self:Flush()
		return
	end
	if self.have_num_value < self.need_num_value and not self.auto_buy then
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
				self:OnAutuBuyChange(true)
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nofunc, self.need_num_value - self.have_num_value)
		return
	end
	self.stop = false
	local auto_buy = self.auto_buy and 1 or 0
	FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GRAETE_SOLDIER_REQ_TYPE_POTENTIAL_LEVEL_UP, self.seq, auto_buy)
end

function FamousGeneralPotentialContent:AutoAdvance()
	if self.have_num_value >= self.need_num_value or (self.auto_buy and ShopData.Instance:CheckCanBuyItemByNum(self.item_id, self.need_num_value - self.have_num_value)) then
		local auto_buy = self.auto_buy and 1 or 0
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GRAETE_SOLDIER_REQ_TYPE_POTENTIAL_LEVEL_UP, self.seq, auto_buy)
	else
		self.auto_advance = false
		if self.auto_buy and not ShopData.Instance:CheckCanBuyItemByNum(self.item_id, self.need_num_value - self.have_num_value) then
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
end

function FamousGeneralPotentialContent:ShowEffect()
	if self.in_effect then
		return
	end
	self.in_effect = true
	self.show_effect:SetValue(true)
	GlobalTimerQuest:AddDelayTimer(function ()
		if self.show_effect then
			self.show_effect:SetValue(false)
			self.in_effect = false
		end
	end, 1)
end

function FamousGeneralPotentialContent:OnAutuBuyChange(isOn)
	self.auto_buy = isOn
end