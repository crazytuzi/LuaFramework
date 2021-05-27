-- 跨服Boss
local CrossBossView = BaseClass(BaseView)

function CrossBossView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("CrossBoss")
	
	self.texture_path_list = {
		"res/xui/cross_boss.png",
		"res/xui/wangchengzhengba.png",
		'res/xui/boss.png',
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}	

	self.btn_info = {
		ViewDef.CrossBoss.CrossBossInfo, 
		ViewDef.CrossBoss.FlopCard, 
		ViewDef.CrossBoss.LuxuryEquipCompose,
		-- ViewDef.BossRewardPreview,
	}

	require("scripts/game/cross_server/cross_boss_info_view").New(ViewDef.CrossBoss.CrossBossInfo)
	require("scripts/game/cross_server/cross_flop_card_view").New(ViewDef.CrossBoss.FlopCard)
	require("scripts/game/luxury_equip/luxury_equip_compose_view").New(ViewDef.CrossBoss.LuxuryEquipCompose)	
end

function CrossBossView:__delete()
end

function CrossBossView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossBossView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossBossView:LoadCallBack(index, loaded_times)
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end

	self.tabbar = Tabbar.New()
	self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:SetClickItemValidFunc(function(index)
		self.tabbar_index = index
		return ViewManager.Instance:CanOpen(self.btn_info[index]) 
	end)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
		name_list, true, ResPath.GetCommon("toggle_110"), 25, true)

	EventProxy.New(CrossServerData.Instance, self):AddEventListener(CrossServerData.COPY_DATA_CHANGE, BindTool.Bind(self.FlushRemind, self, 1))
	EventProxy.New(CrossServerData.Instance, self):AddEventListener(CrossServerData.FLOP_DATA_CHANGE, BindTool.Bind(self.FlushRemind, self, 2))
end

--选择标签回调
function CrossBossView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	--刷新标签栏显示
	for k, v in pairs(self.btn_info) do
		if v.open then
			self.tabbar:ChangeToIndex(k)
			break
		end
	end
end

function CrossBossView:ReleaseCallBack()
	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function CrossBossView:ShowIndexCallBack(index)
	self:FlushRemind(1)
	self:FlushRemind(2)
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
			return
		end
	end
end

function CrossBossView:FlushRemind(idx)
	local num = 0
	if idx == 2 then
		num = CrossServerData.Instance:GetBrandRemind()
	elseif idx == 1 then
		num = CrossServerData.Instance:GetCrossBossInfoRemind()
	end
	self.tabbar:SetRemindByIndex(idx, num > 0)
end

return CrossBossView