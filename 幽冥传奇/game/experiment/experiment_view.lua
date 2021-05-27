ExperimentView = ExperimentView or BaseClass(BaseView)

function ExperimentView:__init()
	self.title_img_path = ResPath.GetWord("word_experiment")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/experiment.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}
	
	self.btn_info = {
		ViewDef.Experiment.Trial,
		ViewDef.Experiment.DigOre,
		ViewDef.Experiment.Babel,
	}

	-- 管理自定义对象
	self._objs = {}
	require("scripts/game/experiment/dig_ore_view").New(ViewDef.Experiment.DigOre)
	require("scripts/game/experiment/dig_ore_account_view").New(ViewDef.DigOreAccount)		--小号
	require("scripts/game/experiment/dig_ore_rob_view").New(ViewDef.DigOreRob)				--挖矿掠夺
	require("scripts/game/experiment/dig_ore_award_view").New(ViewDef.DigOreAward)			--挖矿掠夺
	require("scripts/game/experiment/dig_ore_rob_award_view").New(ViewDef.DigOreRobAward)	--掠夺奖励
	require("scripts/game/experiment/trial_view").New(ViewDef.Experiment.Trial)

	require("scripts/game/babel/babel_view").New(ViewDef.Experiment.Babel)
end

function ExperimentView:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack ExperimentView") end
		v:DeleteMe()
	end
	self._objs = {}
end

function ExperimentView:LoadCallBack(index, loaded_times)

	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, function (index)
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end, name_list, true, ResPath.GetCommon("toggle_110"), 25, true)
	self:AddObj("tabbar")

	self.data = ExperimentData.Instance				--数据

	-- ExperimentData.Instance:AddEventListener(ExperimentData.INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
	self.remind_event = GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChanged, self))

	--self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))

	self.data_event = GlobalEventSystem:Bind(BABEL_EVENET.DATA_CHANGE,BindTool.Bind1(self.ShilianPoint, self))
end


function ExperimentView:ShilianPoint( ... )
	local vis = false 
	if BabelData.Instance:GetCanSweep() or BabelData.Instance:GetRemianChoujiangNum() > 0 then
		vis = true
	end
	if self.tabbar then
		self.tabbar:SetRemindByIndex(3, vis)
	end
end

function ExperimentView:ShowIndexCallBack()
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
		end
		local vis = ViewManager.Instance:CanOpen(v)
		self.tabbar:SetToggleVisible(k, vis)
	end

	self:FlushRemindChange()
	self:ShilianPoint()
end

function ExperimentView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ExperimentView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ExperimentView:OnDataChange(vo)
end

-- 刷新红点
function ExperimentView:FlushRemindChange()
	-- self.tabbar:SetRemindByIndex(1, QianghuaData.Instance:GetCanStrengthNum() > 0)
	-- self.tabbar:SetRemindByIndex(2, StoneData.Instance:CanEquipInsetStone() > 0)
	-- self.tabbar:SetRemindByIndex(3, AuthenticateData.GetRemindIndex() > 0)
end

-- 红点提醒改变
function ExperimentView:OnRemindChanged(remind_name, num)
	-- if self.tabbar then
	-- 	if remind_name == RemindName.EquipStrengthen then
	-- 		self.tabbar:SetRemindByIndex(1, num > 0)
	-- 	end
	-- end
end


function ExperimentView:OnRemindGroupChange(remind_group_name)
	-- if remind_group_name == RemindGroupName.BabelTabbar then
	-- 	self:SetRemindByIndex(index)
	-- end
end

function ExperimentView:SetRemindByIndex(index)
	-- local btn_info = self.btn_info[index]
	-- if btn_info and btn_info.remind_group_name then
	-- 	-- print("ssssssssss",  RemindManager.Instance:GetRemindGroup(btn_info.remind_group_name), btn_info.remind_group_name)
	-- 	local vis = RemindManager.Instance:GetRemindGroup(btn_info.remind_group_name) > 0 and (not IS_ON_CROSSSERVER)
	-- 	self.tabbar:SetRemindByIndex(index, vis)
	-- end
end