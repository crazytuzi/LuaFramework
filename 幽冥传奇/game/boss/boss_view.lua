BossView = BossView or BaseClass(BaseView)
BossView.COLSE_BOSS_VIEW = "close_boss_view"
function BossView:__init()
	self.title_img_path = ResPath.GetWord("word_boss")
	self:SetModal(true)
	self.texture_path_list = {
		"res/xui/wangchengzhengba.png",
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}


	self.btn_info = {
		-- ViewDef.Boss.TypeBoss,
		ViewDef.Boss.MapInfo, 
		ViewDef.Boss.RareBoss, 
		ViewDef.Boss.MoshaBoss,
		ViewDef.Boss.PersonBoss,
		ViewDef.Boss.NoticeInfo, 
	}

	require("scripts/game/boss/personal_boss/personal_boss_view").New(ViewDef.Boss.PersonBoss, self)
	-- require("scripts/game/boss/wild_boss/wild_boss_view").New(ViewDef.Boss.WildBoss, self)
	-- require("scripts/game/boss/house_boss/house_boss_view").New(ViewDef.Boss.BossHome, self)
	-- require("scripts/game/boss/secret_boss/secret_boss_view").New(ViewDef.Boss.SecretBoss, self)
	-- require("scripts/game/boss/boss_integral/boss_integral_view").New(ViewDef.Boss.BossIntegral, self)

	require("scripts/game/boss/new_boss/map_info_view").New(ViewDef.Boss.MapInfo, self)
	require("scripts/game/boss/new_boss/rare_boss_view").New(ViewDef.Boss.RareBoss, self)
	require("scripts/game/boss/new_boss/rare_boss_view").New(ViewDef.Boss.MoshaBoss, self)
	require("scripts/game/boss/new_boss/kill_record_view").New(ViewDef.Boss.NoticeInfo, self)
	-- require("scripts/game/boss/new_boss/boss_type_view").New(ViewDef.Boss.TypeBoss, self)
	
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneChange, self))
end

function BossView:__delete()
end

function BossView:ReleaseCallBack()
	self.tabbar:DeleteMe()
end

function BossView:OnSceneChange()
	ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
end

function BossView:LoadCallBack(index, loaded_times)
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	-- self.tabbar:SetTabbtnTxtOffset(-10, 0)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 140, 580, function (index)
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end, name_list, false, ResPath.GetCommon("toggle_121"))
	self:BossRemindChange()
	EventProxy.New(WildBossData.Instance, self):AddEventListener(WildBossData.UPDATE_ROLE_DATA, BindTool.Bind(self.BossRemindChange, self))
	EventProxy.New(SecretBossData.Instance, self):AddEventListener(SecretBossData.UPDATA_SECRET_DATA, BindTool.Bind(self.BossRemindChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.BossRemindChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_ENERGY, BindTool.Bind(self.OnRoleAttrChange, self))

	NewBossCtrl.Instance:SendBossKillInfoReq()
end

function BossView:OpenCallBack()
end

function BossView:ShowIndexCallBack(index)
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
			return
		end
	end
end

function BossView:OnRoleAttrChange()
	self:BossRemindChange()
end

function BossView:BossRemindChange()
	-- self.tabbar:SetRemindByIndex(1, PersonalBossData.Instance:CanEnterBossFuben() > 0)
	-- self.tabbar:SetRemindByIndex(2, WildBossData.Instance:CanEnterWildBossNum() > 0)
	-- self.tabbar:SetRemindByIndex(3, NewBossData.Instance:GetRareBossKill() > 0)
	-- self.tabbar:SetRemindByIndex(4, SecretBossData.Instance:CanEnterSecretBossNum() > 0)
	-- self.tabbar:SetRemindByIndex(5, BossIntegralData.Instance:CanUpCrestLevel() > 0)
end

function BossView:OnFlush(param_t, index)
end

function BossView:CloseCallBack(is_all)
	 GlobalEventSystem:Fire(BossView.COLSE_BOSS_VIEW,true)
end
