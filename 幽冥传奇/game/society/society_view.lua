--------------------------------------------------------
-- 社交视图
--------------------------------------------------------
SocietyView = SocietyView or BaseClass(BaseView)

function SocietyView:__init()
	self.title_img_path = ResPath.GetWord("word_society")
	self.texture_path_list[1] = "res/xui/society.png"
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"society_ui_cfg", 1, {0}, false},
		{"society_ui_cfg", 2, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.tabbar_group = {ViewDef.Society.Friend, ViewDef.Society.Enemy, ViewDef.Society.BlackList, ViewDef.Society.ApplyList, ViewDef.Society.SearchAdd}
	require("scripts/game/society/society_list_view").New(ViewDef.Society.Friend, self)
	require("scripts/game/society/society_list_view").New(ViewDef.Society.Enemy, self)
	require("scripts/game/society/society_list_view").New(ViewDef.Society.BlackList, self)
	require("scripts/game/society/society_apply_list_view").New(ViewDef.Society.ApplyList, self)
	require("scripts/game/society/society_search_add_view").New(ViewDef.Society.SearchAdd, self)

end

function SocietyView:__delete()

end

function SocietyView:ReleaseCallBack()

	if self.scroll_tabbar then
		self.scroll_tabbar:DeleteMe()
		self.scroll_tabbar = nil
	end

	self:UnBindGlobalEvent(self.remind)
end

function SocietyView:LoadCallBack(index, loaded_times)
	self.node_t_list["img_checkbox_hook"].node:setVisible(false)

	self:CreateTabbarList()

	XUI.AddClickEventListener(self.node_t_list["layout_box_show_online"].node, BindTool.Bind(self.OnShowOnlineChck, self))
	EventProxy.New(SocietyData.Instance, self):AddEventListener(SocietyData.SOCIETY_LIST_CHANGE, BindTool.Bind(self.FlushTabBtnsText, self))

	self.remind = self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))
end

function SocietyView:ShowIndexCallBack(index)
	self:FlushTabBtnsText()
	
	self.node_t_list["layout_tab_scroll"].node:setVisible(true)
	self:FlushTabbarSelect()
end

function SocietyView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	SocietyCtrl.AskGetRelationshipList()
end

function SocietyView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	SocietyData.Instance:EmptySearchResult()

	SocietyData.Instance:SetShowRules(false)
end

--刷新相应界面
function SocietyView:OnFlush(flush_param_t, index)
	
end

-- 跳转到界面是更新tabbar
function SocietyView:FlushTabbarSelect()
	for k, v in pairs(self.tabbar_group) do
		if v.open then
			self.scroll_tabbar:ChangeToIndex(k, self.root_node)
			break
		end
	end
end

-- 创建标签列表
function SocietyView:CreateTabbarList()
	if self.scroll_tabbar then return end
	local tabgroup = {}
	for k, v in pairs(self.tabbar_group) do
		tabgroup[#tabgroup + 1] = v.name
	end
	self.scroll_tabbar = ScrollTabbar.New()
	self.scroll_tabbar.space_interval_V = 15

	self.scroll_tabbar:CreateWithNameList(self.node_t_list["scroll_tabbar"].node, 3, -5, 
										BindTool.Bind(self.OnSelectTabCallback, self), tabgroup, true, 
										ResPath.GetCommon("toggle_120")) 
	self.scroll_tabbar:GetView():setLocalZOrder(1)
end

function SocietyView:OnSelectTabCallback(index)
	ViewManager.Instance:OpenViewByDef(self.tabbar_group[index])	

	--刷新标签栏显示
	for k, v in pairs(self.tabbar_group) do
		if v.open then
			self.scroll_tabbar:ChangeToIndex(k, self.root_node)
			break
		end
	end
end

function SocietyView:FlushTabBtnsText()
	for i = 1, 3 do
		local name
		local sum_tbl = SocietyData.Instance.GetOnlineAndTotalNum(i)
		if next(sum_tbl) == nil then return end
		name = string.format(Language.Society.TabGroup[i], sum_tbl.online, sum_tbl.total)
		self.scroll_tabbar:SetNameByIndex(i, name)
	end
	self:OnRemindGroupChange()
end

function SocietyView:OnShowOnlineChck()
	local bool = not self.node_t_list["img_checkbox_hook"].node:isVisible()
	self.node_t_list["img_checkbox_hook"].node:setVisible(bool)

	SocietyData.Instance:SetShowRules(bool)
end

function SocietyView:OnRemindGroupChange()
	self.scroll_tabbar:SetRemindByIndex(4, RemindManager.Instance:GetRemindGroup(ViewDef.Society.ApplyList.remind_group_name) > 0)
end
