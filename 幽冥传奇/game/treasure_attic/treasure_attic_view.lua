TreasureAtticView = TreasureAtticView or BaseClass(BaseView)

function TreasureAtticView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		-- 'res/xui/treasure_attic.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}
	self.tabbar_group = {ViewDef.TreasureAttic.ZhenBaoGe, ViewDef.TreasureAttic.DragonBall}
	require("scripts/game/treasure_attic/zhenbaoge_view").New(ViewDef.TreasureAttic.ZhenBaoGe, self)
	require("scripts/game/treasure_attic/dragon_ball_view").New(ViewDef.TreasureAttic.DragonBall, self)
end

function TreasureAtticView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	GlobalEventSystem:UnBind(self.remind_event_h)
end

function TreasureAtticView:LoadCallBack(index, loaded_times)
	self.tabbar = Tabbar.New()
	self.tabbar:SetTabbtnTxtOffset(-10, 0)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 1103, 650, BindTool.Bind(self.TabSelectCellBack, self),
		{"珍宝阁", "龙珠"}, true, ResPath.GetCommon("toggle_110"), 25)

	EventProxy.New(ZhenBaoGeData.Instance, self):AddEventListener(ZhenBaoGeData.LayerRewardChange, BindTool.Bind(self.ZhenBaoGeRemindChange, self))
	EventProxy.New(ZhenBaoGeData.Instance, self):AddEventListener(ZhenBaoGeData.ExchangeListUpdate, BindTool.Bind(self.ZhenBaoGeRemindChange, self))
	self.remind_event_h = GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
end

--显示指数回调
function TreasureAtticView:ShowIndexCallBack(index)
	local boor = RemindManager.Instance:GetRemind(RemindName.ZhenBaoGeReward) > 0 or RemindManager.Instance:GetRemind(RemindName.ZhenBaoGeExchange) > 0
	self.tabbar:SetRemindByIndex(1, boor)
	local boor = RemindManager.Instance:GetRemind(RemindName.DragonBallLevelCanUp) > 0 or RemindManager.Instance:GetRemind(RemindName.DragonBallPhaseCanUp) > 0
	self.tabbar:SetRemindByIndex(2, boor)

	for k, v in pairs(self.tabbar_group) do
		if v.open then
			self.tabbar:ChangeToIndex(k, self.root_node)
			break
		end
	end
end

function TreasureAtticView:ZhenBaoGeRemindChange()
	local boor = RemindManager.Instance:GetRemind(RemindName.ZhenBaoGeReward) > 0 or RemindManager.Instance:GetRemind(RemindName.ZhenBaoGeExchange) > 0
	self.tabbar:SetRemindByIndex(1, boor)
end


--选择标签回调
function TreasureAtticView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.tabbar_group[index])
	-- 刷新标签栏显示
	for k, v in pairs(self.tabbar_group) do
		if v.open then
			self.tabbar:ChangeToIndex(k, self.root_node)
			break
		end
	end
end

function TreasureAtticView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TreasureAtticView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TreasureAtticView:OnBagDataChange()
	-- self.tabbar[]
end

function TreasureAtticView:RemindChange(remind_name, num)
	if self and self.tabbar then
	    if remind_name == RemindName.DragonBallLevelCanUp then
	        self.tabbar:SetRemindByIndex(2, num > 0)
	    elseif remind_name == RemindName.DragonBallPhaseCanUp then
	        self.tabbar:SetRemindByIndex(2, num > 0)
	    end
	end
end
