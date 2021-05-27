local LuxuryEquipComposeView = BaseClass(SubView)

function LuxuryEquipComposeView:__init()
	self.config_tab = {
		{"luxury_equip_ui_cfg", 2, {0}},
	}
	self.btn_info = {ViewDef.CrossBoss.LuxuryEquipCompose.WanHaoCompose, ViewDef.CrossBoss.LuxuryEquipCompose.JinHaoCompose, ViewDef.CrossBoss.LuxuryEquipCompose.XionghaoCompose,}
	require("scripts/game/luxury_equip/luxury_equip_jinhao_compose_view").New(ViewDef.CrossBoss.LuxuryEquipCompose.JinHaoCompose)
	require("scripts/game/luxury_equip/luxury_equip_wanhao_compose_view").New(ViewDef.CrossBoss.LuxuryEquipCompose.WanHaoCompose)
	require("scripts/game/luxury_equip/luxury_equip_xionghao_compose_view").New(ViewDef.CrossBoss.LuxuryEquipCompose.XionghaoCompose)
end


function LuxuryEquipComposeView:__delete()
	-- body
end

function LuxuryEquipComposeView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil 
	end
end

function LuxuryEquipComposeView:LoadCallBack()
	self:CreateTabbar()

	 self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))
end

function LuxuryEquipComposeView:CreateTabbar()
	if nil == self.tabbar then
		local ph = self.ph_list["ph_tabbar"]
		self.exchange_layout = self.node_t_list.layout_tabbar
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.exchange_layout.node, ph.x, ph.y - 3,
			function(index) self:ChangeToIndex(index) end, 
			Language.LuxuryEquip.TabGroup1, false, ResPath.GetCommon("toggle_121"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetSpaceInterval(5)
	end	
end


function LuxuryEquipComposeView:ChangeToIndex(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
end

function LuxuryEquipComposeView:OpenCallBack()
	-- body
end

function LuxuryEquipComposeView:ShowIndexCallBack()
	self:FlushBtns()
end

function LuxuryEquipComposeView:CloseCallBack()
	-- body
end


function LuxuryEquipComposeView:OnGameCondChange()
	self:FlushBtns()
end

function LuxuryEquipComposeView:FlushBtns()
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
		end
		self:FlushBtnRemind(k)
		local vis = (ViewManager.Instance:CanOpen(v))
		self.tabbar:SetToggleVisible(k, vis)
	end
end

function LuxuryEquipComposeView:OnRemindGroupChange(remind_group_name)
	if remind_group_name == RemindGroupName.WanHaoCanComposeTabbar then
		self:FlushBtnRemind(1)
	elseif remind_group_name == RemindGroupName.JinHaoCanComposeTabbar then
		self:FlushBtnRemind(2)
	elseif remind_group_name == RemindGroupName.XiongHaoCanComposeTabbar then
		self:FlushBtnRemind(3)
	end
end


function LuxuryEquipComposeView:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_group_name then
		local vis = RemindManager.Instance:GetRemindGroup(btn_info.remind_group_name) > 0 and (not IS_ON_CROSSSERVER)
		self.tabbar:SetRemindByIndex(index, vis)
	end
end



return LuxuryEquipComposeView