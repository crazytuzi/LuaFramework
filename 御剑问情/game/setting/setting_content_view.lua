SettingContentView = SettingContentView or BaseClass(BaseRender)

local DIFFERENCE = 4

local QUALITY_VALUE =
{
	3, 	--低端
	2,  --普通
	1,  --良好
	0,  --最佳
}
function SettingContentView:__init(instance)
	SettingContentView.Instance = self
	self:InitView()
	self.is_init = true
	self.open_click = false
end

function SettingContentView:__delete()
	if SettingContentView.Instance ~= nil then
		 SettingContentView.Instance = nil
	end
end

function SettingContentView:InitView()
	self.toggle_list = {}
	self:ListenEvent("back_login_click", BindTool.Bind(self.BackLoginOnClick,self))
	self.auto_pick = self:FindObj("auto_pick").dropdown
	self.auto_recycle = self:FindObj("auto_pick2").dropdown
	self:ListenEvent("auto_pick_value_change", BindTool.Bind(self.AutoPickValueChange,self))
	self:ListenEvent("auto_pick_value_change2", BindTool.Bind(self.AutoRecycleValueChange,self))
	self:ListenEvent("select_role_click", BindTool.Bind(self.SelectRoleOnClick,self))
	self.frame_1 = self:FindObj("frame_1")
	self.frame_2 = self:FindObj("frame_2")
	self.show_hl_list = {}
	self.pic_toggle_list = {}
	local recommend_value = SettingData.Instance:GetRecommendQuality()
	self.show_recommend_list = {}
	for i=1,4 do
		self.show_hl_list[i] = self:FindVariable("show_hl_" .. i)
		self.pic_toggle_list[i] = self:FindObj("pic_toggle_" .. i)
		self.show_recommend_list[i] = self:FindVariable("show_recommend_" .. i)
		self.show_recommend_list[i]:SetValue(3 - recommend_value == i - 1)
		self:ListenEvent("pic_event_" .. i, BindTool.Bind2(self.QualityToggleClick, self, QUALITY_VALUE[i]))
	end
	self:FlushHl(UnityEngine.PlayerPrefs.GetInt("quality_level"))
	for i=1, SettingData.MAX_INDEX - DIFFERENCE do
		self:ListenEvent("event_"..i, BindTool.Bind2(self.ToggleOnClick,self,i))
		self.toggle_list[i] = self:FindObj("toggle_"..i)
	end

	self.set_flag_1 = {}
	self.set_flag_2 = {}
	for i=1,32 do
		self.set_flag_1[i] = 0
		self.set_flag_2[i] = 0
	end

	self.set_flag_1_dirty = false
	self.set_flag_2_dirty = false
	self.is_flush_tab_1 = false
	self.is_flush_tab_1 = false

	local setting_list = SettingData.Instance:GetSettingList()

	self.auto_pick.value = setting_list[SETTING_TYPE.AUTO_PICK_COLOR] or 0
	SettingData.Instance:SetPickLimitValue(self.auto_pick.value)
	self.auto_recycle.value = setting_list[SETTING_TYPE.AUTO_RECYCLE_COLOR] or 0
	SettingData.Instance:SetRecycleLimitValue(self.auto_recycle.value)
	self.is_first = true
end

function SettingContentView:FlushClick1()
	if self.is_flush_tab_1 == true then return end
	self.is_flush_tab_1 = true
	self.frame_1:SetActive(true)
	self.frame_2:SetActive(false)

	local setting_list = SettingData.Instance:GetSettingList()
	self.open_click = true
	for k,v in pairs(SettingPanel1) do
		if v > 20 then
			self.toggle_list[v - DIFFERENCE].toggle.isOn = setting_list[v]
		else
			self.toggle_list[v].toggle.isOn = setting_list[v]
		end
	end
	self.open_click = false
	self.flush_click_flag_1 = true
end

function SettingContentView:FlushClick2()
	if self.is_flush_tab_2 == true then return end
	self.is_flush_tab_2 = true
	self.frame_1:SetActive(false)
	self.frame_2:SetActive(true)
	local setting_list = SettingData.Instance:GetSettingList()
	self.open_click = true
	for k,v in pairs(SettingPanel2) do
		if v > 20 then
			self.toggle_list[v - DIFFERENCE].toggle.isOn = setting_list[v]
		else
			self.toggle_list[v].toggle.isOn = setting_list[v]
		end
	end
	self.open_click = false
	self.flush_click_flag_2 = true
end

function SettingContentView:SetFrame1Active(is_active)
	if self.is_init then
		return
	end
	self.frame_1:SetActive(is_active)
	self.frame_2:SetActive(not is_active)
end

function SettingContentView:FlushHl(quality_value)
	for i=1,4 do
		self.show_hl_list[i]:SetValue(i-1 == 3-quality_value)
		self.pic_toggle_list[i].toggle.isOn = i-1 == 3-quality_value
	end
end

function SettingContentView:ToggleOnClick(i,is_click)
	for k,v in pairs(SETTING_TYPE) do
		if i < 20 then
			if i == v then
				self:SetFlag(SETTING_TYPE[k],is_click)
			end
		else
			if i + DIFFERENCE == v then
				self:SetFlag(SETTING_TYPE[k],is_click)
			end
		end
	end
end

function SettingContentView:QualityToggleClick(i,is_click)
	if is_click then
		QualityConfig.QualityLevel = i
		UnityEngine.PlayerPrefs.SetInt("quality_level", i)
		self:FlushHl(i)
	end
end

function SettingContentView:SelectRoleOnClick()
	local sure_func = function()
		if IS_ON_CROSSSERVER then
			UserVo.Instance.plat_name = UserVo.Instance.old_plat_name
		else
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			ReportManager:ReportRoleInfo(main_role_vo.server_id, main_role_vo.name, main_role_vo.role_id, main_role_vo.level, "", "LoginOut")
		end
		UtilU3d.CacheData("select_role_state", 1)
		UtilU3d.CacheData("select_role_plat_name", GameVoManager.Instance:GetUserVo().plat_name)
		GameRoot.Instance:Restart()
	end
	TipsCtrl.Instance:ShowCommonTip(sure_func, nil, Language.Common.IsLeaveSelectRole)
end

function SettingContentView:BackLoginOnClick()
	local sure_func = function()
		GlobalEventSystem:Fire(LoginEventType.LOGOUT)
		-- GameRoot.Instance:Restart()
	end
	TipsCtrl.Instance:ShowCommonTip(sure_func, nil, Language.Common.IsLeaveLogin)
end

function SettingContentView:SetFlag(index,is_click)
	if not self.open_click then  -- 手动点击的才记录
		for k, v in pairs(FixBugSettting) do
			if v == index then
				SettingData.Instance:SetBugFixRecordValue(index, is_click)
			end
		end
	end

	if index <= 16 then
		if is_click then
			self.set_flag_1[33 - index] = 1
		else
			self.set_flag_1[33 - index] = 0
		end

		if not self.open_click then  --确保赋值过flag_1
			self.set_flag_1_dirty = true
			SettingData.Instance:SetHasSetting(index)
		end
	else
		if is_click then
			self.set_flag_2[33 - index + 16] = 1
		else
			self.set_flag_2[33 - index + 16] = 0
		end

		if not self.open_click then --确保赋值过flag_2
			self.set_flag_2_dirty = true
		end
	end

	local setting_data = SettingData.Instance
	setting_data:SetSettingData(index, is_click)
	if not self.open_click then
		setting_data:AfterSystemAutoSetting(index, is_click)
	end
end

function SettingContentView:CloseCallBack()

	if self.set_flag_1_dirty then
		self.set_flag_1_dirty = false
		SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.SYS_SETTING_1, bit:b2d(self.set_flag_1))
	end

	if self.set_flag_2_dirty then
		self.set_flag_2_dirty = false
		self.set_flag_2[33 - SETTING_TYPE.AUTO_RECYCLE_EQUIP + 16] = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_EQUIP) and 1 or 0
		self.set_flag_2[33 - SETTING_TYPE.AUTO_RECYCLE_BLUE + 16] = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_BLUE) and 1 or 0
		self.set_flag_2[33 - SETTING_TYPE.AUTO_RECYCLE_PURPLE + 16] = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_PURPLE) and 1 or 0
		self.set_flag_2[33 - SETTING_TYPE.AUTO_RECYCLE_ORANGE + 16] = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_ORANGE) and 1 or 0
		self.set_flag_2[33 - SETTING_TYPE.AUTO_RECYCLE_RED + 16] = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_RED) and 1 or 0
		SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.SYS_SETTING_2, bit:b2d(self.set_flag_2))
	end

	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.SYS_SETTING_DROPDOWN_1, self.auto_pick.value)
	SettingCtrl.Instance:SendHotkeyInfoReq()
	self.is_flush_tab_1 = false
	self.is_flush_tab_2 = false
end

function SettingContentView:AutoPickValueChange(value)
	SettingData.Instance:SetPickLimitValue(value)
end


function SettingContentView:AutoRecycleValueChange(value)
	-- SettingData.Instance:SetRecycleLimitValue(value)
end

function SettingContentView:AutoUpgradeValueChange(value)
	if self.is_first then
		self.is_first = false
		return
	end
	SettingData.Instance:SetUgradeLimitValue(value)
end