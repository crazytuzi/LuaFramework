------------------------------------------------------------
--人物相关主View
------------------------------------------------------------
RoleView = RoleView or BaseClass(BaseView)

function RoleView:__init()
	self.title_img_path = ResPath.GetWord("word_role")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
		--{"common_ui_cfg", 3, {0}},
	}

	self.btn_info = {ViewDef.Role.RoleInfoList, ViewDef.Role.Level, ViewDef.Role.Deify, ViewDef.Role.ZhuanSheng,
		--[[ViewDef.Role.Skill, ViewDef.Role.Inner,]] ViewDef.Role.LunHui}
	self.remind_list = {}
	for k, v in pairs(self.btn_info) do
		if v.remind_group_name then
			self.remind_list[v.remind_group_name] = k
		end
	end

	require("scripts/game/role/view/role_info_list").New(ViewDef.Role.RoleInfoList)
	require("scripts/game/role/inner/role_inner_view").New(ViewDef.Role.Inner)
	require("scripts/game/role/zhuansheng/zhuansheng_view").New(ViewDef.Role.ZhuanSheng)
	require("scripts/game/role/level/level_view").New(ViewDef.Role.Level)
	require("scripts/game/role/deify/deify_view").New(ViewDef.Role.Deify)
	--require("scripts/game/role/horoscope/horoscope").New(ViewDef.Role.Horoscope)
	require("scripts/game/role/lunhui/lunhui_view").New(ViewDef.Role.LunHui)
end

function RoleView:__delete()
end

function RoleView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function RoleView:LoadCallBack(index, loaded_times)
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:SetClickItemValidFunc(function(index)
		return ViewManager.Instance:CanOpen(self.btn_info[index]) 
	end)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
		name_list, true, ResPath.GetCommon("toggle_110"), 25, true)

	-- 请求轮回数据
	local is_open = GameCondMgr.Instance:GetValue("CondId18")
	if is_open then
		LunHuiCtrl.SendLunHuiReq(3)
	end

    self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))
end

--选择标签回调
function RoleView:TabSelectCellBack(index)
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.OnCrossServerTip)
		self.tabbar:ChangeToIndex(1)
		return
	else
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end
end

function RoleView:OpenCallBack()
end

function RoleView:ShowIndexCallBack(index)
	self:FlushBtns()
end

function RoleView:OnFlush(param_t, index)
end

function RoleView:CloseCallBack(is_all)
end

--------------------------------------------------------------
function RoleView:OnGameCondChange(cond_def)
	self:FlushBtns()
end

function RoleView:OnRemindGroupChange(group_name, num)
	
	if self.remind_list[group_name] then
		self:FlushBtnRemind(self.remind_list[group_name])
	end
end

function RoleView:FlushBtns()
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
		end
		self:FlushBtnRemind(k)
		local vis = (ViewManager.Instance:CanOpen(v))
		self.tabbar:SetToggleVisible(k, vis)
	end
end

function RoleView:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_group_name then
		local vis = RemindManager.Instance:GetRemindGroup(btn_info.remind_group_name) > 0 and (not IS_ON_CROSSSERVER)
		self.tabbar:SetRemindByIndex(index, vis)
	end
end
