local NrareBossView = BaseClass(SubView)

function NrareBossView:__init()
	self.texture_path_list = {
		--'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 6, {0}},
	}

	self.btn_info = {
		ViewDef.NewlyBossView.Rare.VipBoss,
		-- ViewDef.NewlyBossView.Rare.FortureBoss,
		ViewDef.NewlyBossView.Rare.MiJing,
		ViewDef.NewlyBossView.Rare.XhBoss,
		ViewDef.NewlyBossView.Rare.MoyuBoss,
		ViewDef.NewlyBossView.Rare.ShenWei,
	}

	-- require("scripts/game/newly_boss/nrare_boss/chiyou_boss_view").New(ViewDef.NewlyBossView.Rare.Chiyou, self)
	-- require("scripts/game/newly_boss/nrare_boss/fortune_boss_view").New(ViewDef.NewlyBossView.Rare.FortureBoss, self)
	require("scripts/game/newly_boss/wild_boss/vip_boss_view").New(ViewDef.NewlyBossView.Rare.VipBoss, self)
	require("scripts/game/newly_boss/nrare_boss/xh_boss_view").New(ViewDef.NewlyBossView.Rare.XhBoss, self)
	require("scripts/game/newly_boss/nrare_boss/mijing_boss_view").New(ViewDef.NewlyBossView.Rare.MiJing, self)
	-- require("scripts/game/newly_boss/nrare_boss/rexue_boss_view").New(ViewDef.NewlyBossView.Rare.ReXue, self)
	require("scripts/game/newly_boss/wild_boss/circle_boss_view").New(ViewDef.NewlyBossView.Rare.MoyuBoss, self)
	require("scripts/game/newly_boss/nrare_boss/xh_boss_view").New(ViewDef.NewlyBossView.Rare.ShenWei, self)
end

function NrareBossView:__delete()
end

function NrareBossView:ReleaseCallBack()
	if self.rare_tabbar then
		self.rare_tabbar:DeleteMe()
		self.rare_tabbar = nil
	end
end

function NrareBossView:CloseCallBack()
	-- if self.rare_tabbar then
	-- 	self.rare_tabbar:DeleteMe()
	-- 	self.rare_tabbar = nil
	-- end
end

function NrareBossView:LoadCallBack(index, loaded_times)
	if self.rare_tabbar then return end

	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.rare_tabbar = Tabbar.New()
	-- self.rare_tabbar:SetTabbtnTxtOffset(-10, 0)
	self.rare_tabbar:CreateWithNameList(self.node_t_list.layout_common_bg1.node, 8, 501, function (index)
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end, name_list, false, ResPath.GetCommon("toggle_121"))
	self:NrareRemindTabbar()
	
	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.NEWLY_BOSS_REMIND, BindTool.Bind(self.NrareRemindTabbar, self))
end

function NrareBossView:ShowIndexCallBack()

	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.rare_tabbar:ChangeToIndex(k)
			return
		end
	end
end

function NrareBossView:OnFlush(param_t)
end

-- 标签栏提醒
function NrareBossView:NrareRemindTabbar()
	self.rare_tabbar:SetRemindByIndex(1, NewlyBossData.Instance:GetBossRemid(2) > 0)
	self.rare_tabbar:SetRemindByIndex(2, ExploreData.Instance.GetRareplaceRemind() > 0)
	self.rare_tabbar:SetRemindByIndex(3, NewlyBossData.Instance:GetBossRemid(3) > 0)
	-- self.rare_tabbar:SetRemindByIndex(5, NewlyBossData.Instance:ReXueBossIsFlush())
	self.rare_tabbar:SetRemindByIndex(5, NewlyBossData.Instance:GetBossRemid(8) > 0)
end


return NrareBossView