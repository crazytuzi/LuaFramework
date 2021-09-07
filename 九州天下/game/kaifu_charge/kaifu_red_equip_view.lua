RedEquipActivity = RedEquipActivity or BaseClass(BaseRender)
local model_cfg = {
	rotation = Vector3(0, 0, 0),
	scale = Vector3(0.8, 0.8, 0.8),
}
function RedEquipActivity:__init(instance)
	self.equip_list_cell = {}
	self.count = 0
end

function RedEquipActivity:__delete()
	self.odd_time = nil
	self.display = nil
	self.listview = nil
	self.gray_btn = nil
	self.show_btn = nil
	for i,v in ipairs(self.equip_list_cell) do
		v:DeleteMe()
	end
	self.equip_list_cell = {}
	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	self.count = 0
	self.gray_btn = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

function RedEquipActivity:LoadCallBack(instance)
    self:ListenEvent("GetFashionEquipClick", BindTool.Bind(self.GetFashionEquipClick, self))
	self:ListenEvent("GetWay", BindTool.Bind(self.GetWay, self))

	self.odd_time = self:FindVariable("TimeText")
	self.gray_btn = self:FindVariable("GrayBtn")
	self.btn_text = self:FindVariable("BtnText")

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}}

	self.display = self:FindObj("Display")
	self.list_data = KaiFuChargeData.Instance:GetRedEquipInfo()
	self.equip_list = self:FindObj("ListView")
	local equip_list_delegate = self.equip_list.list_simple_delegate
	equip_list_delegate.NumberOfCellsDel = function()
		return #self.list_data or 0
	end
	equip_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)
	self:FlushModel()
	self:Flush()
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateTimer, self), 1)
end

function RedEquipActivity:RefreshListView(cell, data_index)
	data_index = data_index + 1
	local list_cell = self.equip_list_cell[cell]
	if nil == list_cell then
		list_cell = EquipListItem.New(cell.gameObject)
	    self.equip_list_cell[cell] = list_cell
	end
	local data = self.list_data[data_index]
	list_cell:SetIndex(data_index)
	list_cell:SetData(data)
end

function RedEquipActivity:OnFlush() 
	local is_get = RedEquipData.Instance:GetReward()
	self.gray_btn:SetValue(is_get)

	local cur_num = RedEquipData.Instance:GetRewardIsGet()
	local text = Language.RedEquip.RedEquipBtnText[cur_num]
	self.btn_text:SetValue(text)
	self.equip_list.scroller:RefreshActiveCellViews()
end

function RedEquipActivity:FlushModel()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.display.ui3d_display)
	end
	local fashion_body = KaiFuChargeData.Instance:GetFashionEquip(1)
	local fashion_wuqi = KaiFuChargeData.Instance:GetFashionEquip(2)
	self.temp_vo.appearance.fashion_body = fashion_body
	self.temp_vo.appearance.fashion_wuqi = fashion_wuqi
	if self.role_model then
		-- self.role_model:ResetRotation()
		self.role_model:SetModelResInfo(self.temp_vo)
		-- local cfg_pos = self.role_model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE], 001001, DISPLAY_PANEL.RED_EQUIP_ACT)
		self.role_model:SetTransform(model_cfg)
	end
end

function RedEquipActivity:GetFashionEquipClick()
	local is_get, num = RedEquipData.Instance:GetReward()
	if is_get and num ~= 0 then
		RedEquipCtrl.Instance:SendRedEquipInfo(COMMON_OPERATE_TYPE.COT_REQ_RED_EQUIP_COLLECT_FETCH_ATC_REWARD, num - 1)
	end
   
end

function RedEquipActivity:GetWay()
	ViewManager.Instance:Open(ViewName.RedEquipView)
end

function RedEquipActivity:UpdateTimer()
	if not self.odd_time then return end
	local star_time = TimeCtrl.Instance:GetServerRealStartTime()
	local avtivity_end_time = star_time + GameEnum.NEW_SERVER_DAYS * 24 * 60 * 60
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local time_str = TimeUtil.FormatSecond2DHMS(avtivity_end_time - cur_time)
	self.odd_time:SetValue(time_str)
end

-----------------------------------------------------------------------------------------------------

EquipListItem = EquipListItem or BaseClass(BaseCell)
function EquipListItem:__init(instance)
	self.icon_list = {}
	for i = 1, 3 do
		self.icon_list[i] = self:FindVariable("Icon"..i) 
	end

	self.name_text = self:FindVariable("NameText")
	self.equip_number = self:FindVariable("Number")
	self.show_icon_3 = self:FindVariable("ShowIcon3")
	self.achieve = self:FindVariable("Achieve")
end

function EquipListItem:__delete()
	self.name_text = nil
	self.equip_number = nil
	self.show_icon_3 = nil
	self.achieve = nil
end

function EquipListItem:OnFlush()
	self.name_text:SetValue(self.data[1].reward_name)
	for i = 1, #self.data do
        self.icon_list[i]:SetAsset(ResPath.GetSystemIcon(self.data[i].reward_icon))
        self:ListenEvent("IconClick"..i, BindTool.Bind(self.IconClick, self, i))
	end
    local number = RedEquipData.Instance:GetStarsInfo(self.data[1].seq - 1).item_count --获取已激活的数量
	self.achieve:SetValue(number == 8)
	self.equip_number:SetValue(string.format(Language.RedEquip.RedEquipActivity,number))
end

function EquipListItem:IconClick(index)
	local client_cfg = self.data[index].Redget_way
	if client_cfg then
		local param_list = Split(client_cfg, "#")
		if param_list[2] then
			ViewManager.Instance:OpenByCfg(client_cfg, nil, param_list[2] .. "_index")
		else
			ViewManager.Instance:OpenByCfg(client_cfg)
		end
	end
end
