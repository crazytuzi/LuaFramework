--------------------------------------------------------
-- 特戒  配置
--------------------------------------------------------
SpecialRingView = BaseClass(BaseView)

function SpecialRingView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("word_special_ring")
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"special_ring_ui_cfg", 7, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	self.btn_info = {
		ViewDef.SpecialRing.Advanced,
		ViewDef.SpecialRing.Fusion,
		ViewDef.SpecialRing.Part,
	}

	require("scripts/game/special_ring/special_ring_advanced_view").New(ViewDef.SpecialRing.Advanced, self)
	require("scripts/game/special_ring/special_ring_fusion_view").New(ViewDef.SpecialRing.Fusion, self)
	require("scripts/game/special_ring/special_ring_part_view").New(ViewDef.SpecialRing.Part, self)
end

function SpecialRingView:__delete()
	-- body
end

function SpecialRingView:ReleaseCallBack()
	if self.remind_event then
		GlobalEventSystem:UnBind(self.remind_event)
		self.remind_event = nil
	end
end

function SpecialRingView:LoadCallBack()
	if nil == self.tabbar then
		local ph = self.ph_list["ph_tabbar2"]
		self.exchange_layout = self.node_t_list.layout_common_tabbar
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.exchange_layout.node, ph.x, ph.y - 3,
			BindTool.Bind(self.TabSelectCellBack, self),
			Language.ReXueGodEquip.TabGroup3, false, ResPath.GetCommon("toggle_121"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetSpaceInterval(5)
		self:AddObj("tabbar")
	end

	self.remind_event = GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChanged, self))
	self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
end

function SpecialRingView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	self.tabbar:ChangeToIndex(index)
end


function SpecialRingView:OpenCallBack()
	
end

function SpecialRingView:CloseCallBack()

end

function SpecialRingView:ShowIndexCallBack(index)
	self:Flush()
end

function SpecialRingView:OnFlush()
	for i, view_def in ipairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(view_def) then
			self.tabbar:ChangeToIndex(i)
		end

		self:FlushBtnRemind(i)
		local vis = (ViewManager.Instance:CanOpen(view_def))
		self.tabbar:SetToggleVisible(i, vis)
	end
end

function SpecialRingView:OnGameCondChange()
	for i, view_def in ipairs(self.btn_info) do
		self:FlushBtnRemind(i)
		local vis = (ViewManager.Instance:CanOpen(view_def))
		self.tabbar:SetToggleVisible(i, vis)
	end
end

function SpecialRingView:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_name then
		local vis = RemindManager.Instance:GetRemind(btn_info.remind_name) > 0 and (not IS_ON_CROSSSERVER)
		self.tabbar:SetRemindByIndex(index, vis)
	end
end

-- 红点提醒改变
function SpecialRingView:OnRemindChanged(remind_name, num)
	if remind_name == RemindName.SpecialRingSynthetic then
		self.tabbar:SetRemindByIndex(1, num > 0 and (not IS_ON_CROSSSERVER))
	end
end

return SpecialRingView