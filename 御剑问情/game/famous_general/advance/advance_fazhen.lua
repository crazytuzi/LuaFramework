FamousGeneralFaZhenView = FamousGeneralFaZhenView or BaseClass(BaseView)
local ATTR_LIST_NUM = 3
local SKILL_NUM = 4
local VIEW_STATE =
{
	NO_ACTIVE = 1,
	ACTIVE = 2,
	FIGHTOUT = 3,
	FIGHTOUTED = 4,
}
function FamousGeneralFaZhenView:__init()
	self.ui_config = {"uis/views/famous_general_prefab", "FamousGeneralFaZhen"}
end

function FamousGeneralFaZhenView:__delete()

end

function FamousGeneralFaZhenView:LoadCallBack()
	self.cur_select_index = 1
	self.view_flag = self:FindVariable("view_flag")

	self.attr_list = {}
	for i=1, ATTR_LIST_NUM do
		self.attr_list[i] = {}
		self.attr_list[i].cur_attr = self:FindVariable("attr" .. i)
		self.attr_list[i].next_attr = self:FindVariable("next_attr" .. i)
	end

	self.cur_level = self:FindVariable("cur_level")
	self.target_level = self:FindVariable("target_level")
	self.show_effect = self:FindVariable("show_effect")

	self.have_num = self:FindVariable("have_num")
	self.fight_power = self:FindVariable("fight_power")

	local display = self:FindObj("Display")
	self.role_model = RoleModel.New()
	self.role_model:SetDisplay(display.ui3d_display)

	self.item_obj = self:FindObj("ItemCell")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.item_obj)

	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickUpLevel", BindTool.Bind(self.AutomaticAdvance, self))
end

function FamousGeneralFaZhenView:ReleaseCallBack()
	self.cur_select_index = nil
	self.view_flag = nil
	self.target_level = nil
	self.fight_power = nil

	
	for i=1, ATTR_LIST_NUM do
		self.attr_list[i] = {}
		self.attr_list[i].cur_attr = nil
		self.attr_list[i].next_attr = nil
	end
	self.attr_list = {}

	self.cur_level = nil

	self.have_num = nil

	local display = nil
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	self.item_obj = nil
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
	self.show_effect = nil
end

function FamousGeneralFaZhenView:OpenCallBack()
	self:ConstructData()
	self:SetFlag()
	FamousGeneralData.Instance:SetLookFaZhen()
end

function FamousGeneralFaZhenView:CloseCallBack()
	ViewManager.Instance:FlushView(ViewName.FamousGeneralView)
	RemindManager.Instance:Fire(RemindName.General_Info)
end

function FamousGeneralFaZhenView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "set_index" then
			self.cur_select_index = v.index
			self:FlushModel()
		end
	end
	self:ConstructData()
	self:SetFlag()
	self:SetInfo()
	self:SetItem()
end

function FamousGeneralFaZhenView:FlushModel()
	self:ConstructData()
	self:SetFlag()
	self:SetModel()
end

function FamousGeneralFaZhenView:ConstructData()
	self.construct = true
	local data_instance = FamousGeneralData.Instance
	self.cur_level_value = data_instance:GetFaZhenLevel(self.cur_select_index)
	self.seq = data_instance:GetDataSeq(self.cur_select_index)

	self.have_num_value = data_instance:GetFaZhenItemNum()
	self.item_id = data_instance:GetFaZhenItem()
	self.active_level = data_instance:GetFaZhenActiveLevel(self.cur_select_index)

	local attr_list = data_instance:GetFaZhenAttr(self.cur_level_value)
	self.attr_list_values = {}
	for i=1, ATTR_LIST_NUM do
		self.attr_list_values[i] = {}
		self.attr_list_values[i].cur_attr = attr_list[GameEnum.AttrList[i]]
		self.attr_list_values[i].next_attr = data_instance:GetFaZhenAttr(self.cur_level_value + 1)[GameEnum.AttrList[i]]
	end
	self.role_res_id = data_instance:GetGeneralModel(self.cur_select_index)
	self.fight_power_value = CommonDataManager.GetCapabilityCalculation(attr_list)
end

function FamousGeneralFaZhenView:SetFlag()
	
end

function FamousGeneralFaZhenView:SetModel()
	if self.construct == nil then
		return
	end

	local bundle, asset = ResPath.GetGeneralRes(self.role_res_id)
	self.role_model:SetMainAsset(bundle, asset, function ()
		local fazhen_objs = FindObjsByName(self.role_model.draw_obj:GetPart(SceneObjPart.Main).obj.transform, "fazhen_effect")
		local weapon_objs = FindObjsByName(self.role_model.draw_obj:GetPart(SceneObjPart.Main).obj.transform, "weapon_effect")
		for k,v in pairs(fazhen_objs) do
			-- v.gameObject:SetActive(self.cur_level_value >= self.active_level)
			v.gameObject:SetActive(true)
		end
		for k,v in pairs(weapon_objs) do
			v.gameObject:SetActive(FamousGeneralData.Instance:IsShowGuangWu(self.cur_select_index))
		end
	end)
	
	self.role_model:SetTrigger("attack3")
end

function FamousGeneralFaZhenView:SetInfo()
	if self.construct == nil  then
		return
	end

	self.cur_level:SetValue(self.cur_level_value)

	for i=1, ATTR_LIST_NUM do
		self.attr_list[i].cur_attr:SetValue(self.attr_list_values[i].cur_attr)
		self.attr_list[i].next_attr:SetValue(self.attr_list_values[i].next_attr - self.attr_list_values[i].cur_attr)
	end
	self.target_level:SetValue(self.active_level)
	self.fight_power:SetValue(self.fight_power_value)
end

function FamousGeneralFaZhenView:SetItem()
	self.item:SetData({item_id = self.item_id, num = self.have_num_value})
	local num_str = self.have_num_value
	if self.have_num_value == 0 then
		 num_str = ToColorStr(num_str, TEXT_COLOR.RED)
	end
	self.have_num:SetValue(num_str)
end

function FamousGeneralFaZhenView:AutomaticAdvance()
	if not self.construct then
		return
	end
	FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_SHENWU_LEVEL_UP, self.seq)
end

function FamousGeneralFaZhenView:OnClickHelp()
	
end

function FamousGeneralFaZhenView:ShowEffect()
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
