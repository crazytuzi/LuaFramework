require("game/baoju/achieve/achieve_title")
require("game/baoju/achieve/achieve_overview")

AchieveView = AchieveView or BaseClass(BaseRender)

function AchieveView:__init()
	--Toggle
	self.title_toggle = self:FindObj("TitleToggle").toggle
	self.overview_toggle = self:FindObj("OverviewToggle").toggle
	self.overview_toggle:AddValueChangedListener(BindTool.Bind(self.ToggleOverviewChange, self))
	self.title_toggle:AddValueChangedListener(BindTool.Bind(self.ToggleTitleChange, self))
	--子面板
	-- self.title_view = AchieveTitleView.New(self:FindObj("TitleView"))
	-- self.overview_view = AchieveOverViewView.New(self:FindObj("OverviewView"), self)

	local title_content = self:FindObj("TitleView")
	title_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.title_view = AchieveTitleView.New(obj)
	end)

	local overview_content = self:FindObj("OverviewView")
	overview_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.overview_view = AchieveOverViewView.New(obj, self)
	end)

	--红点
	self.red_point_list = {
		[RemindName.Achieve_Overview] = self:FindVariable("TitleRedPoint"),
		[RemindName.Achieve_Title] = self:FindVariable("OverviewRedPoint"),
	}

	AchieveCtrl.Instance.view = self

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function AchieveView:__delete()
	if self.title_view then
		self.title_view:DeleteMe()
		self.title_view = nil
	end

	if self.overview_view then
		self.overview_view:DeleteMe()
		self.overview_view = nil
	end

	if AchieveCtrl.Instance ~= nil then
		AchieveCtrl.Instance.view = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function AchieveView:OpenCallBack()
	self:FlushRedPint()
	self.overview_toggle.isOn = false
	self.title_toggle.isOn = false
	self.title_toggle.isOn = true
end

function AchieveView:RemindChangeCallBack(key, value)
	if self.red_point_list[key] then
		self.red_point_list[key]:SetValue(value > 0)
	end
end

function AchieveView:FlushRedPint()
	for k,v in pairs(self.red_point_list) do
		self.red_point_list[k]:SetValue(RemindManager.Instance:GetRemind(k))
	end
end

function AchieveView:FlushView()
	self:FlushRedPint()
	if self.title_view and self.title_view.root_node.gameObject.activeSelf then
		self.title_view:UpdateAchieveProcess()
	end
	if self.overview_view and self.overview_view.root_node.gameObject.activeSelf then
		self.overview_view:OnAchieveChange()
	end
end

function AchieveView:ToggleOverviewChange(isOn)
	if isOn and self.overview_view then
		self.overview_view:OpenCallBack()
	end
end

function AchieveView:ToggleTitleChange(isOn)
	if isOn and self.title_view then
		self.title_view:OpenCallBack()
	end
end

--实际刷新的函数
local doFlushView =
{
	[TabIndex.baoju_achieve_title] = function(self)
		self.title_toggle.isOn = true
	end,
	[TabIndex.baoju_achieve_overview] = function(self)
		self.overview_toggle.isOn = true
	end,
}

function AchieveView:ShowView(index)
	doFlushView[index](self)
end

