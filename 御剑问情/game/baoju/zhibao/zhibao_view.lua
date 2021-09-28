require("game/baoju/zhibao/zhibao_activedegree")
require("game/baoju/zhibao/zhibao_upgrade")

ZhiBaoView = ZhiBaoView or BaseClass(BaseRender)

function ZhiBaoView:__init()
	ZhiBaoView.Instance = self
	ZhiBaoCtrl.Instance:SetView(self)
	--活跃Toggle
	self.active_toggle = self:FindObj("ActiveToggle").toggle
	self.active_toggle.isOn = true
	self.active_toggle:AddValueChangedListener(BindTool.Bind(self.ToggleActiveChange, self))
	--升级Toggle
	self.upgrade_toggle = self:FindObj("UpgradeToggle").toggle
	self.upgrade_toggle.isOn = false
	self.upgrade_toggle:AddValueChangedListener(BindTool.Bind(self.ToggleUpgradeChange, self))
	self.red_point_list = {
		["Active"] = self:FindVariable("ActiveRedPoint"),
		["Upgrade"] = self:FindVariable("UpgradeRedPoint"),
	}

	--活跃
	-- self.activedegree_view = ZhiBaoActiveDegreeView.New(self:FindObj("ActiveDegree"))
	local activedegree_content = self:FindObj("ActiveDegree")
	activedegree_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.activedegree_view = ZhiBaoActiveDegreeView.New(obj)
	end)
	--升级
	-- self.upgrade_view = ZhiBaoUpgradeView.New(self:FindObj("Upgrade"), self)
	local upgrade_content = self:FindObj("Upgrade")
	upgrade_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.upgrade_view = ZhiBaoUpgradeView.New(obj)
		self.upgrade_view:OpenCallBack()
		self:FlushRedPint()
	end)
	self.is_loaded = true

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ZhiBao_Active)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ZhiBao_Upgrade)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ZhiBao_HuanHua)
end

function ZhiBaoView:GetUpGradeToggleisOn()
	return true
end

function ZhiBaoView:GetUpGradeView()
	if self.upgrade_view then
		return self.upgrade_view
	end
end

function ZhiBaoView:FlushActive()
	if self.is_loaded and self.activedegree_view then
		self.activedegree_view:OnProtocolChange()
		self:FlushRedPint()
	end
end

function ZhiBaoView:__delete()
	ZhiBaoView.Instance = nil

	if ZhiBaoCtrl.Instance ~= nil then
		ZhiBaoCtrl.Instance:SetView(nil)
	end

	if self.activedegree_view then
		self.activedegree_view:DeleteMe()
		self.activedegree_view = nil
	end

	if self.upgrade_view then
		self.upgrade_view:DeleteMe()
		self.upgrade_view = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function ZhiBaoView:RemindChangeCallBack(key, value)
	if key == RemindName.ZhiBao_Active then
		self.red_point_list["Active"]:SetValue(value > 0)
	elseif key == RemindName.ZhiBao_Upgrade or key == RemindName.ZhiBao_HuanHua then
		self.red_point_list["Upgrade"]:SetValue(RemindManager.Instance:GetRemind(RemindName.ZhiBao_Upgrade) +
		RemindManager.Instance:GetRemind(RemindName.ZhiBao_HuanHua) > 0)
	end
end

function ZhiBaoView:FlushRedPint()
	self.red_point_list["Active"]:SetValue(RemindManager.Instance:GetRemind(RemindName.ZhiBao_Active) > 0)
	self.red_point_list["Upgrade"]:SetValue(RemindManager.Instance:GetRemind(RemindName.ZhiBao_Upgrade) +
		RemindManager.Instance:GetRemind(RemindName.ZhiBao_HuanHua) > 0)
end

function ZhiBaoView:OpenCallBack()
	self:FlushRedPint()
	self.upgrade_toggle.isOn = false
	if self.active_toggle.isOn then
		if self.activedegree_view then
			self.activedegree_view:OpenCallBack()
		end
	else
		self.active_toggle.isOn = true
	end
end

function ZhiBaoView:ToggleActiveChange(isOn)
	if isOn then
		if self.activedegree_view then
			self.activedegree_view:OpenCallBack()
		end
	else
		--关闭特效界面
		TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.BaoJu)
		ZhiBaoData.Instance:SetStartFlyObj(nil)
	end
end

function ZhiBaoView:ToggleUpgradeChange(isOn)
	if isOn and self.upgrade_view then
		self.upgrade_view:OpenCallBack()
	end
end

function ZhiBaoView:ZhiBaoInfoChange()
	self:FlushRedPint()
	if self.upgrade_view then
		self.upgrade_view:Flush()
	end
end

--实际刷新的函数
local doFlushView =
{
	[TabIndex.baoju_zhibao_active] = function(self)
		self.active_toggle.isOn = true
	end,
	[TabIndex.baoju_zhibao_upgrade] = function(self)
		self.upgrade_toggle.isOn = true
	end,
}

function ZhiBaoView:ShowView(index)
	doFlushView[index](self)
end

-----------------------------------------------
--通用动画勋章
AniMedalIcon = AniMedalIcon or BaseClass()

function AniMedalIcon:__init(mother_view, max_value, callback, get_icon_callback)
	self.turning = false
	self.mother_view = mother_view

	self.left_arrow = mother_view:FindObj("LeftArrow")
	self.right_arrow = mother_view:FindObj("RightArrow")
	self.left_arrow.button:AddClickListener(BindTool.Bind(self.LeftClick, self))
	self.right_arrow.button:AddClickListener(BindTool.Bind(self.RightClick, self))

	local ani_manager = mother_view:FindObj("MedalAnimator")
	self.ani_callback = callback
	self.get_icon_callback = get_icon_callback
	self.max_value = max_value

	self.main_icon = ani_manager:FindObj("MainIcon")
	self.sub_icon = ani_manager:FindObj("SubIcon")

	self.animator = ani_manager.animator
	self.animator:ListenEvent("Exit", BindTool.Bind(self.AniFinish, self))
	self.animator:ListenEvent("FlushData", BindTool.Bind(self.FlushData, self))

	self:InitCallBack()
	self:IconSetData(self.main_icon)
end

function AniMedalIcon:__delete()

end

--打开时重置显示
function AniMedalIcon:OpenCallBack()
	self:IconSetData(self.main_icon)
	self.left_arrow:SetActive(self.mother_view.selet_data_index > 1)
	self.right_arrow:SetActive(self.mother_view.selet_data_index < self.max_value)
	self.ani_callback()
end

--外部调用，刷新主勋章
function AniMedalIcon:FlushMainIcon()
	self:IconSetData(self.main_icon)
end

--勋章 刷新数据
function AniMedalIcon:IconSetData(icon)
	local bundle, asset = self.get_icon_callback()
	icon.image:LoadSprite(bundle, asset)
end

--左换页
function AniMedalIcon:LeftClick()
	if self.turning or self.mother_view.selet_data_index - 1 <= 0 then
		return
	end
	self.mother_view.selet_data_index = self.mother_view.selet_data_index - 1
	self:IconSetData(self.main_icon)
	self:AniFinish()
end

--右换页
function AniMedalIcon:RightClick()
	if self.turning or self.mother_view.selet_data_index + 1 > self.max_value then
		return
	end
	local cur_level = ZhiBaoData.Instance:GetZhiBaoLevel()
	local active_index = ZhiBaoData.Instance:GetJsByLevel(cur_level)
	if active_index >= self.mother_view.selet_data_index then
		self.mother_view.selet_data_index = self.mother_view.selet_data_index + 1
	end
	self:IconSetData(self.main_icon)
	self:AniFinish()
end

--动画将要播放完时，刷新数据
function AniMedalIcon:FlushData()
	self:IconSetData(self.main_icon)
end

--动画播放完时
function AniMedalIcon:AniFinish()
	self.left_arrow:SetActive(self.mother_view.selet_data_index > 1)
	self.right_arrow:SetActive(self.mother_view.selet_data_index < self.max_value)
	self.ani_callback()
	self.turning = false
end

function AniMedalIcon:InitCallBack()
end

AniMedalIconPlus = AniMedalIconPlus or BaseClass(AniMedalIcon)

function AniMedalIconPlus:InitCallBack(ani_manager)
	local table = self.main_icon.gameObject:GetComponent(typeof(UINameTable))
	self.main_icon.wearing = table:Find("IsWearing")
	-- self.sub_icon.wearing = self.sub_icon:FindObj("IsWearing")
end

function AniMedalIconPlus:IconSetData(icon)
	local bundle, asset, is_show_wearing = self.get_icon_callback()
	icon.image:LoadSprite(bundle, asset)
	if icon.wearing then
		icon.wearing:SetActive(is_show_wearing)
	end
end

