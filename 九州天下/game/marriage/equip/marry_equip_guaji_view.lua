MarryEquipGuajiView = MarryEquipGuajiView or BaseClass(BaseView)

function MarryEquipGuajiView:__init()
	self.ui_config = {"uis/views/marriageview","MarryEquipGuaji"}
	self.play_audio = true

	self.select_toggle_index = 0 				--选择的挂机吸收的装备品质
	self.gua_ji_select_list = {}
end

function MarryEquipGuajiView:__delete()

end

function MarryEquipGuajiView:ReleaseCallBack()
	self.gua_ji_select_list = {}
end

function MarryEquipGuajiView:OpenCallBack()
	self.select_toggle_index = SettingData.Instance:GetMarryEquipIndex()
	for k, v in ipairs(self.gua_ji_select_list) do
		v.isOn = self.select_toggle_index == k
	end
end

function MarryEquipGuajiView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickSave",BindTool.Bind(self.OnClickSave, self))

	for i = 1, 4 do
		local toggle = self:FindObj("Toggle" .. i).toggle
		toggle:AddValueChangedListener(BindTool.Bind(self.SelectToggleChange, self, i))
		self.gua_ji_select_list[i] = toggle
	end
end

function MarryEquipGuajiView:SelectToggleChange(i, isOn)
	if isOn then
		self.select_toggle_index = i
	else
		self.select_toggle_index = 0
	end
end

function MarryEquipGuajiView:OnClickSave()
	SettingData.Instance:SetMarryEquipIndex(self.select_toggle_index)
	SysMsgCtrl.Instance:ErrorRemind(Language.Role.FashionSaveTips[2])
	self:Close()
end