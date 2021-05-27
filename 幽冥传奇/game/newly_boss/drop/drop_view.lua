local BossDropView = BaseClass(SubView)

function BossDropView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 1, {0}},
	}

	self.btn_info = {
		-- ViewDef.NewlyBossView.Drop.Native,
		ViewDef.NewlyBossView.Drop.Chiyou,
		ViewDef.NewlyBossView.Drop.FortureBoss,
		ViewDef.NewlyBossView.Drop.ReXue,
	}

	-- require("scripts/game/newly_boss/drop/boss_drop_view").New(ViewDef.NewlyBossView.Drop.Native, self)
	require("scripts/game/newly_boss/nrare_boss/chiyou_boss_view").New(ViewDef.NewlyBossView.Drop.Chiyou, self)
	require("scripts/game/newly_boss/nrare_boss/fortune_boss_view").New(ViewDef.NewlyBossView.Drop.FortureBoss, self)
	require("scripts/game/newly_boss/nrare_boss/rexue_boss_view").New(ViewDef.NewlyBossView.Drop.ReXue, self)
end

function BossDropView:__delete()
end

function BossDropView:ReleaseCallBack()
	if self.drop_tabbar then
		self.drop_tabbar:DeleteMe()
		self.drop_tabbar = nil
	end
end

function BossDropView:LoadCallBack(index, loaded_times)
	self.tabbar_index = 1
	-- XUI.AddClickEventListener(self.node_t_list.layout_common_bg.btn_tx.node, BindTool.Bind(self.OnClickBossTixing, self))

	if self.drop_tabbar then return end

	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.drop_tabbar = Tabbar.New()
	-- self.drop_tabbar:SetTabbtnTxtOffset(-10, 0)
	self.drop_tabbar:CreateWithNameList(self.node_t_list.layout_common_bg.node, 10, 505, function (index)
		self.tabbar_index = index
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end, name_list, false, ResPath.GetCommon("toggle_121"))

	self:NDropRemindTabbar()
	
	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.NEWLY_BOSS_REMIND, BindTool.Bind(self.NDropRemindTabbar, self))
end

function BossDropView:CloseCallBack()
	
end

function BossDropView:ShowIndexCallBack()
	FubenCtrl.GetFubenEnterInfo()
	NewBossCtrl.Instance:SendBossKillInfoReq()

	self:Flush()

	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.drop_tabbar:ChangeToIndex(k)
			return
		end
	end
end

function BossDropView:OnFlush(param_t)
	
end

-- 标签栏提醒
function BossDropView:NDropRemindTabbar()
	self.drop_tabbar:SetRemindByIndex(3, NewlyBossData.Instance:ReXueBossIsFlush())
end

return BossDropView