SettingApperanceContentView = SettingApperanceContentView or BaseClass(BaseRender)

local ApperanceType =
{
	SETTING_APPERANCE_TYPE.SHIELD_OTHER_TOUSHI,
	SETTING_APPERANCE_TYPE.SHIELD_OTHER_MIANSHI,
	SETTING_APPERANCE_TYPE.SHIELD_OTHER_QILINBI,
	SETTING_APPERANCE_TYPE.SHIELD_OTHER_LINGZHU,
	SETTING_APPERANCE_TYPE.SHIELD_OTHER_YAOSHI,
}

function SettingApperanceContentView:__init()
	self.toggle_list = {}
	for k,v in ipairs(ApperanceType) do
		self.toggle_list[k] = self:FindObj("Toggle" .. k)
	end

	-- 检查设置面板的协议是否已经收到
	self.first_sync = BindTool.Bind(self.SyncSetting, self)
	SettingData.Instance:SetFirstMsgCallBack(self.first_sync)
end

function SettingApperanceContentView:__delete()
	if self.first_sync and SettingData.Instance then
		SettingData.Instance:RemoveFirstMsgCallBack(self.first_sync)
		self.first_sync = nil
	end
end

function SettingApperanceContentView:SyncSetting()
	for k,v in ipairs(self.toggle_list) do
		local isOn = SettingData.Instance:GetApperanceSetting(ApperanceType[k])
		v.toggle.isOn = isOn
		v.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick, self, k))
	end
end

function SettingApperanceContentView:OnToggleClick(index, isOn)
	SettingData.Instance:SetApperanceSetting(ApperanceType[index], isOn)
end