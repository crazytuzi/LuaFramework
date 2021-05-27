--------------------------------------------------------
-- 日常活动视图
--------------------------------------------------------

ActivityView = ActivityView or BaseClass(BaseView)

function ActivityView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	self.btn_info = {ViewDef.Activity.Active, ViewDef.Activity.Activity}

	require("scripts/game/activity/activity_chlid_view").New(ViewDef.Activity.Activity, self)
	require("scripts/game/shending/shending_view").New(ViewDef.Activity.Active, self)
end

function ActivityView:__delete()
end

function ActivityView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

end

function ActivityView:LoadCallBack(index, loaded_times)	
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, function (index)
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end, name_list, true, ResPath.GetCommon("toggle_110"), 25, true)

	EventProxy.New(ShenDingData.Instance, self):AddEventListener(ShenDingData.TASK_DATA_CHANGE, BindTool.Bind(self.FlushActTabbar, self))
	self:FlushActTabbar()
end

function ActivityView:FlushActTabbar()
	if self.tabbar then
		self.tabbar:SetRemindByIndex(1, ShenDingData.GetRemindIndex() > 0)
	end
end

function ActivityView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActivityView:ShowIndexCallBack(index)
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			if v == ViewDef.Activity.Activity then
				self:CreateTopTitle(ResPath.GetWord("word_activity"))
			elseif v == ViewDef.Activity.Active then
				self:CreateTopTitle(ResPath.GetWord("word_active_degree"))
			elseif v == ViewDef.Activity.Offline then
				self:CreateTopTitle(ResPath.GetWord("word_offline"))
			end
			self.tabbar:ChangeToIndex(k)
			return
		end
	end
end

function ActivityView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

end

--刷新界面
function ActivityView:OnFlush(param_t, index)

end