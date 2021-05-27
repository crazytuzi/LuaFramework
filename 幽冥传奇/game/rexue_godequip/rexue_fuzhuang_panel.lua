local  ReXueFuZhuangPanel = BaseClass(SubView)

function ReXueFuZhuangPanel:__init( ... )
	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"rexue_god_equip_ui_cfg", 7, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
	self.btn_info = {ViewDef.MainGodEquipView.ReXueFuzhuang.MeiBaShouTao, ViewDef.MainGodEquipView.ReXueFuzhuang.ZhanChongShenHZuang, ViewDef.MainGodEquipView.ReXueFuzhuang.WingShenZhuang,}

	require("scripts/game/rexue_godequip/rexue_wing_compose_panel").New(ViewDef.MainGodEquipView.ReXueFuzhuang.WingShenZhuang)
	require("scripts/game/rexue_godequip/rexue_zhanchong_compose_panel").New(ViewDef.MainGodEquipView.ReXueFuzhuang.ZhanChongShenHZuang)
end


function ReXueFuZhuangPanel:__delete( ... )
	-- body
end

function ReXueFuZhuangPanel:LoadCallBack( ... )
	if nil == self.tabbar then
		local ph = self.ph_list["ph_tabbar2"]
		self.exchange_layout = self.node_t_list.layout_common_tabbar
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.exchange_layout.node, ph.x, ph.y - 3,
			BindTool.Bind(self.TabSelectCellBack, self),
			Language.ReXueGodEquip.TabGroup2, false, ResPath.GetCommon("toggle_121"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetSpaceInterval(5)
	end	
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))

	-- self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
end

function ReXueFuZhuangPanel:TabSelectCellBack(index)
	if ViewManager.Instance:CanOpen(self.btn_info[index]) then
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
		self.tabbar:ChangeToIndex(self:GetShowIndex())
	else
		local view_def = self.btn_info[index] 
		SysMsgCtrl.Instance:FloatingTopRightText(GameCond[view_def.v_open_cond].Tip or "策划需在cond配置")
	end
end

function ReXueFuZhuangPanel:ReleaseCallBack( ... )
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil 
	end
end

function ReXueFuZhuangPanel:OpenCallBack( ... )
	if self.tabbar then
		self.tabbar:SelectIndex(1)
	end
end

function ReXueFuZhuangPanel:CloseCallBack( ... )
	-- body
end

function ReXueFuZhuangPanel:ShowIndexCallBack(index)
	self:Flush(index)
end

function ReXueFuZhuangPanel:OnFlush(param_t)
	for k, v in pairs(self.btn_info) do
		self:FlushBtnRemind(k)
	end
	for k, v in pairs(param_t) do
		if k == "second_tabbbar_change" then
			if ViewManager.Instance:CanOpen(self.btn_info[v.child_index]) then
				ViewManager.Instance:OpenViewByDef(self.btn_info[v.child_index])
				self.tabbar:ChangeToIndex(v.child_index)
				ViewManager.Instance:CloseViewByDef(self.btn_info[1])
			else
				ViewManager.Instance:OpenViewByDef(1)
				self.tabbar:ChangeToIndex(1)
			end
		end
	end
end


function ReXueFuZhuangPanel:OnRemindGroupChange( remind_group_name)
	--print(remind_group_name)
	if remind_group_name == RemindGroupName.MiebaShouTaoTabbar then
		self:FlushBtnRemind(1)
	elseif remind_group_name == RemindGroupName.ZhanChongComposeTabbar then
		self:FlushBtnRemind(2)
	elseif remind_group_name == RemindGroupName.WingComposeTabbar then
		self:FlushBtnRemind(3)
	end
end



function ReXueFuZhuangPanel:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_group_name then
		local vis = RemindManager.Instance:GetRemindGroup(btn_info.remind_group_name) > 0 and (not IS_ON_CROSSSERVER)
		self.tabbar:SetRemindByIndex(index, vis)
	end
end


return ReXueFuZhuangPanel