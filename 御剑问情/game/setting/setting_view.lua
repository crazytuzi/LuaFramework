require("game/setting/setting_content_view")
require("game/setting/setting_custom_view")
require("game/setting/reward_content_view")
require("game/setting/setting_apperance_content_view")

local SETTING_TAB_INDEX =
{
	TabIndex.setting_xianshi,
 	TabIndex.setting_system,
 	TabIndex.setting_apperance,
 	TabIndex.setting_notice,
 	TabIndex.setting_custom,
}

SettingView = SettingView or BaseClass(BaseView)

function SettingView:__init()
	self.ui_config = {"uis/views/settingview_prefab","SettingView"}
	self.full_screen = false
	self.play_audio = true
	self.def_index = 1
end

function SettingView:LoadCallBack()
	self:ListenEvent("close_view",BindTool.Bind(self.BackOnClick,self))

	self.setting_content_view = SettingContentView.New(self:FindObj("setting_content_view"))
	self.setting_custom_view = SettingCustomView.New(self:FindObj("gm_content_view"))
	self.reward_content_view = RewardContentView.New(self:FindObj("reward_content_view"))
	self.apperance_content_view = SettingApperanceContentView.New(self:FindObj("ApperanceContent"))
	self.reward_content_view:OnFlush()
	SettingCtrl.Instance:SendHotkeyInfoReq()
	self.reward_red_point = self:FindVariable("show_red_point")
	self.toggle_list = {}
	for i=1,5 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, SETTING_TAB_INDEX[i]))
		self.toggle_list[i] = self:FindObj("toggle_"..i)
	end

	if IS_AUDIT_VERSION then
		self.toggle_list[4]:SetActive(false)
	end
end

function SettingView:ReleaseCallBack()
	if self.setting_content_view ~= nil then
		self.setting_content_view:DeleteMe()
		self.setting_content_view = nil
	end

	if self.setting_custom_view ~= nil then
		self.setting_custom_view:DeleteMe()
		self.setting_custom_view = nil
	end

	if self.reward_content_view ~= nil then
		self.reward_content_view:DeleteMe()
		self.reward_content_view = nil
	end

	if self.apperance_content_view ~= nil then
		self.apperance_content_view:DeleteMe()
		self.apperance_content_view = nil
	end

	-- 清理变量和对象
	self.reward_red_point = nil
	self.show_system_view = nil
	self.show_notice_view = nil
	self.show_custom_view = nil
	self.toggle_list = nil
end

function SettingView:OpenCallBack()
	self:SetRedPoint()
end

function SettingView:BackOnClick()
	self:Close()
end

function SettingView:CloseCallBack()
	if self.setting_content_view then
		self.setting_content_view:CloseCallBack()
	end
end

function SettingView:SetRedPoint()
	local state = SettingData.Instance:GetRedPointState()
	if self.reward_red_point then
		self.reward_red_point:SetValue(state)
	end
	if self.reward_content_view then
		self.reward_content_view:SetRedPoint(state)
	end
end

function SettingView:OnToggleClick(i)
	self:ChangeToIndex(i)
end

function SettingView:OnFlush()
	if self.show_index == TabIndex.setting_notice then
		self.reward_content_view:OnFlush()
	end
	self:SetRedPoint()
end

function SettingView:ShowIndexCallBack(index)
	if index == TabIndex.setting_xianshi then
		self.toggle_list[1].toggle.isOn = true
		self.setting_content_view:FlushClick1()
	elseif index == TabIndex.setting_system then
		self.toggle_list[2].toggle.isOn = true
		self.setting_content_view:FlushClick2()
	elseif index == TabIndex.setting_apperance then
		self.toggle_list[3].toggle.isOn = true
		self.apperance_content_view:Flush()
	elseif index == TabIndex.setting_notice then
		self.toggle_list[4].toggle.isOn = true
		self.reward_content_view:OnFlush()
	elseif index == TabIndex.setting_custom then
		self.toggle_list[5].toggle.isOn = true
		self.setting_custom_view:OpenCustom()
	end
end