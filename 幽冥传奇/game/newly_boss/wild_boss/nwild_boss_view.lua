local NwildBossView = BaseClass(SubView)

function NwildBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 1, {0}},
	}

	self.btn_info = {
		ViewDef.NewlyBossView.Wild.WildBoss,
		ViewDef.NewlyBossView.Wild.GongDian,
		ViewDef.NewlyBossView.Wild.MayaBoss,
		ViewDef.NewlyBossView.Wild.Specially,
		ViewDef.NewlyBossView.Wild.CircleBoss,
	}

	require("scripts/game/newly_boss/wild_boss/field_boss_view").New(ViewDef.NewlyBossView.Wild.WildBoss, self)
	require("scripts/game/newly_boss/wild_boss/gongdian_boss_view").New(ViewDef.NewlyBossView.Wild.GongDian, self)
	require("scripts/game/newly_boss/wild_boss/maya_boss_view").New(ViewDef.NewlyBossView.Wild.MayaBoss, self)
	require("scripts/game/newly_boss/wild_boss/tequan_boss_view").New(ViewDef.NewlyBossView.Wild.Specially, self)
	require("scripts/game/newly_boss/wild_boss/circle_boss_view").New(ViewDef.NewlyBossView.Wild.CircleBoss, self)
end

function NwildBossView:__delete()
end

function NwildBossView:ReleaseCallBack()
	if self.wild_tabbar then
		self.wild_tabbar:DeleteMe()
		self.wild_tabbar = nil
	end
end

function NwildBossView:LoadCallBack(index, loaded_times)
	self.tabbar_index = 1
	XUI.AddClickEventListener(self.node_t_list.layout_common_bg.btn_tx.node, BindTool.Bind(self.OnClickBossTixing, self))

	if self.wild_tabbar then return end

	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.wild_tabbar = Tabbar.New()
	-- self.wild_tabbar:SetTabbtnTxtOffset(-10, 0)
	self.wild_tabbar:CreateWithNameList(self.node_t_list.layout_common_bg.node, 10, 505, function (index)
		self.tabbar_index = index
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end, name_list, false, ResPath.GetCommon("toggle_121"))
	
	self:NwildRemindTabbar()

	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.NEWLY_BOSS_REMIND, BindTool.Bind(self.NwildRemindTabbar, self))
end

function NwildBossView:CloseCallBack()
	-- if self.wild_tabbar then
	-- 	-- self.wild_tabbar:SetRemindByIndex(1, 0)
	-- 	-- -- self.wild_tabbar:SetRemindByIndex(2, 1)
	-- 	-- self.wild_tabbar:SetRemindByIndex(3, 0)
	-- 	-- self.wild_tabbar:SetRemindByIndex(4, 0)

	-- 	self.wild_tabbar:DeleteMe()
	-- 	self.wild_tabbar = nil
	-- end
end

function NwildBossView:ShowIndexCallBack()
	FubenCtrl.GetFubenEnterInfo()

	self:Flush()

	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.wild_tabbar:ChangeToIndex(k)
			return
		end
	end
end

function NwildBossView:OnFlush(param_t)
	self.node_t_list.layout_common_bg.btn_tx.node:setVisible(self.tabbar_index == 1 or self.tabbar_index == 5)
end

function NwildBossView:OnClickBossTixing()
	local boss_list = self:TabbarIndexData(self.wild_tabbar:GetCurSelectIndex())
	ViewManager.Instance:OpenViewByDef(ViewDef.BossRefreshRemind)
	ViewManager.Instance:FlushViewByDef(ViewDef.BossRefreshRemind, 0, nil, {data = boss_list})
end

-- 标签页数据
function NwildBossView:TabbarIndexData(index)
	local data = {}
	if index == 1 then
		data = NewBossData.Instance:SetRareBossInfo(1)
	-- elseif index == 2 then
		-- data = PersonalBossData.Instance:GetPersonalBossList()
	-- elseif index == 4 then
	-- 	data = NewBossData.Instance:SetRareBossInfo(4)
	elseif index == 5 then
		data = NewBossData.Instance:SetRareBossInfo(4)
	-- elseif index == 6 then
	-- 	data = NewBossData.Instance:SetRareBossInfo(9)
	end
	return data
end

-- 标签栏提醒
function NwildBossView:NwildRemindTabbar()
	self.wild_tabbar:SetRemindByIndex(1, NewlyBossData.Instance:GetBossRemid(1) > 0)
	-- self.wild_tabbar:SetRemindByIndex(2, 1)
	-- self.wild_tabbar:SetRemindByIndex(4, NewlyBossData.Instance:GetBossRemid(4) > 0)
	self.wild_tabbar:SetRemindByIndex(5, NewlyBossData.Instance:GetBossRemid(4) > 0)
	-- self.wild_tabbar:SetRemindByIndex(6, NewlyBossData.Instance:GetBossRemid(9) > 0)
end


return NwildBossView