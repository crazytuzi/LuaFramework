require("game/setting/setting_content_view")
require("game/setting/setting_custom_view")
require("game/setting/reward_content_view")

local SETTING_TAB_INDEX =
{
	TabIndex.setting_xianshi,
 	TabIndex.setting_system,
 	TabIndex.setting_notice,
 	TabIndex.setting_custom,
}

SettingView = SettingView or BaseClass(BaseView)

function SettingView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/settingview","SettingView"}
	self.full_screen = false
	self.play_audio = true
	self.the_index = 2812
end

function SettingView:LoadCallBack()
	self:ListenEvent("close_view",BindTool.Bind(self.BackOnClick,self))

	self.setting_content_view = SettingContentView.New(self:FindObj("setting_content_view"))
	self.setting_custom_view = SettingCustomView.New(self:FindObj("gm_content_view"))
	self.reward_content_view = RewardContentView.New(self:FindObj("reward_content_view"))
	if self.reward_content_view then
		self.reward_content_view:FlushRewrdInfo()
	end
	SettingCtrl.Instance:SendHotkeyInfoReq()
	self.reward_red_point = self:FindVariable("show_red_point")
	self.show_xianshi_view = self:FindVariable("show_xianshi_view")										--已修改
	self.show_system_view = self:FindVariable("show_system_view")
	self.show_notice_view = self:FindVariable("show_notice_view")
	self.show_custom_view = self:FindVariable("show_custom_view")
	self.toggle_list = {}
	for i=1,4 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, SETTING_TAB_INDEX[i]))
		self.toggle_list[i] = self:FindObj("toggle_"..i)

		if IS_AUDIT_VERSION and (i == 3 or i == 4) then
			self.toggle_list[i]:SetActive(false)
		end
	end

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
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

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	-- 清理变量和对象
	self.reward_red_point = nil
	self.show_xianshi_view = nil
	self.show_system_view = nil
	self.show_notice_view = nil
	self.show_custom_view = nil
	self.toggle_list = nil
end

function SettingView:OpenCallBack()
	self:SetRedPoint()
	if self.toggle_list[2].toggle.isOn then
		self.setting_content_view:FlushClick2()
		self.setting_content_view:SetActive(true)
	elseif self.toggle_list[1].toggle.isOn then
		self.setting_content_view:FlushClick1()
		self.setting_content_view:SetActive(true)
	end
	--self:ShowPanel(self.the_index)
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

function SettingView:OnToggleClick(i,is_click)
	if is_click then
		self:ChangeToIndex(i)
		self:ShowIndexCallBack(i)
		self.the_index = i
		self:ShowPanel(i)
	end
end

function SettingView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			if self.the_index == TabIndex.setting_notice then
				if self.reward_content_view then
					self.reward_content_view:FlushRewrdInfo()
				end
			end
		elseif k == "flush_reward_content" then
			if self.reward_content_view then
				self.reward_content_view:FlushRewrdInfo()
			end
		end
	end	
	self:SetRedPoint()
end

function SettingView:ShowIndexCallBack(index)
	if IS_AUDIT_VERSION and index == TabIndex.setting_notice then
			self.toggle_list[1].toggle.isOn = true
		return
	end

	if index == TabIndex.setting_xianshi then
		self.setting_content_view:FlushClick1()
	elseif index == TabIndex.setting_system then
		self.setting_content_view:FlushClick2()
	elseif index == TabIndex.setting_notice then
		self.setting_content_view:SetActive(false)
		self.setting_custom_view:OpenCustom()
	else
		self.setting_content_view:SetActive(false)
	end
end

function SettingView:ShowPanel(index)
	self.show_xianshi_view:SetValue(index == TabIndex.setting_xianshi)
	self.show_system_view:SetValue(index == TabIndex.setting_system)
	self.show_notice_view:SetValue(index == TabIndex.setting_notice)
	self.show_custom_view:SetValue(index == TabIndex.setting_custom)
end

function SettingView:GetCurIndex()
	return self.the_index
end