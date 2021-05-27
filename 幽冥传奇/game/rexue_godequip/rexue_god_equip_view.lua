ReXueGodEquipView = ReXueGodEquipView or BaseClass(BaseView)

function ReXueGodEquipView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("title_rexue")

	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	self.tabbar = nil

	self.btn_info = {ViewDef.MainGodEquipView.RexueGodEquip, ViewDef.MainGodEquipView.ReXueFuzhuang,ViewDef.MainGodEquipView.RexueGodEquipDuiHuan, ViewDef.MainGodEquipView.RexueShenzhu}
	require("scripts/game/rexue_godequip/new_rexue_god_equip_panel").New(ViewDef.MainGodEquipView.RexueGodEquip)
	require("scripts/game/rexue_godequip/rexue_fuzhuang_panel").New(ViewDef.MainGodEquipView.ReXueFuzhuang)
	require("scripts/game/rexue_godequip/rexue_god_duihuan_panel").New(ViewDef.MainGodEquipView.RexueGodEquipDuiHuan)
	require("scripts/game/rexue_godequip/rexue_shenzhu_view").New(ViewDef.MainGodEquipView.RexueShenzhu)
end

function ReXueGodEquipView:__delete()
end

function ReXueGodEquipView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.remind_event then
		GlobalEventSystem:UnBind(self.remind_event)
		self.remind_event = nil
	end
end

function ReXueGodEquipView:LoadCallBack(index, loaded_times)
	if  nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:SetTabbtnTxtOffset(2, 12)
		self.tabbar:SetClickItemValidFunc(function(index)
			return ViewManager.Instance:CanOpen(self.btn_info[index]) 
		end)
		self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
			Language.ReXueGodEquip.TabGroup, true, ResPath.GetCommon("toggle_110"), 25, true)
	end
	
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))
	self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	self:BindGlobalEvent(OPEN_VIEW_EVENT.OpenEvent,BindTool.Bind1(self.TabbarChangeToIndex, self))
end

function ReXueGodEquipView:TabbarChangeToIndex(index)
	if self.tabbar then
		self.tabbar:SelectIndex(index)
	end
end


function ReXueGodEquipView:TabSelectCellBack(index)
	if index == 2 then
		ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.ReXueFuzhuang.MeiBaShouTao)
	else
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end
end


function ReXueGodEquipView:OpenCallBack()
	if self.tabbar then
		self.tabbar:SelectIndex(1)
	end
end

function ReXueGodEquipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ReXueGodEquipView:OnFlush(param_t)
	for k, v in pairs(self.btn_info) do
		self:FlushBtnRemind(k)
	end
	self:OnGameCondChange()

	for k, v in pairs(param_t) do
		if k == "tabbar_change" then
			ViewManager.Instance:CloseViewByDef(self.btn_info[1])	
			if self.tabbar then
				self.tabbar:ChangeToIndex(v.index)
			end
			ViewManager.Instance:OpenViewByDef(self.btn_info[v.index])
			ViewManager.Instance:FlushViewByDef(self.btn_info[v.index], 0, "second_tabbbar_change", {child_index = v.child_index})	
		end
	end
end

function ReXueGodEquipView:CloseCallBack()
	self.index = 1
end

function ReXueGodEquipView:OnGameCondChange()
	for k, v in pairs(self.btn_info) do
		self:FlushBtnRemind(k)
		local vis = (ViewManager.Instance:CanOpen(v))
		self.tabbar:SetToggleVisible(k, vis)
	end
end

function ReXueGodEquipView:OnRemindGroupChange(remind_group_name)
	if remind_group_name == RemindGroupName.GodEquipRexueDuiHuanTabbar then
		self:FlushBtnRemind(3)
	elseif remind_group_name == RemindGroupName.RexueShenBinUpTabbar then
		self:FlushBtnRemind(1)
	elseif remind_group_name == RemindGroupName.FuZhuangTabbar then
		self:FlushBtnRemind(2)
	elseif remind_group_name == RemindGroupName.ShenzhuTabbar then
		self:FlushBtnRemind(4)
	end
end


function ReXueGodEquipView:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_group_name then
		local vis = RemindManager.Instance:GetRemindGroup(btn_info.remind_group_name) > 0 and (not IS_ON_CROSSSERVER)
		self.tabbar:SetRemindByIndex(index, vis)
	end
end

function ReXueGodEquipView:OnRemindChanged(remind_name, num)
	-- if remind_name == RemindName.SpecialRingSynthetic then
	-- 	self.tabbar:SetRemindByIndex(2, num > 0 and (not IS_ON_CROSSSERVER))
	-- end
end
