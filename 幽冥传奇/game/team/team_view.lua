------------------------------------------------------------
-- 组队主视图
------------------------------------------------------------

TeamView = TeamView or BaseClass(BaseView)

TEAM_BTN_TYPE = {
	CJ = 1,			--创建队伍 
	JS = 2,			--解散队伍 
	SQ = 3,			--申请入队
	YQ = 4,			--邀请组队
	TYRD = 5,		--同意入队
	JJRD = 6,		--拒绝入队
	YC = 7,			--踢出队伍
	TC = 8,			--退出队伍
	JSYQ = 9, 		--接受邀请 
	JJYQ = 10,		--拒绝邀请
	QBTY = 11,		--全部同意
	QBJJ = 12,		--全部拒绝
}

function TeamView:__init()
	self.title_img_path = ResPath.GetWord("word_team")
	self.texture_path_list[1] = "res/xui/society.png"
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"team_ui_cfg", 1, {0}},
		{"team_ui_cfg", 2, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.tabbar_group = {
		ViewDef.Team.MyTeam,
		ViewDef.Team.NearTeam,
		ViewDef.Team.NearPlayer,
		ViewDef.Team.MyGoodFriend,
		ViewDef.Team.MyGuild,
		ViewDef.Team.TeamApplyList
	}
	require("scripts/game/team/team_list").New(ViewDef.Team.MyTeam, self)
	require("scripts/game/team/team_list").New(ViewDef.Team.NearTeam, self)
	require("scripts/game/team/team_player").New(ViewDef.Team.NearPlayer, self)
	require("scripts/game/team/team_player").New(ViewDef.Team.MyGoodFriend, self)
	require("scripts/game/team/team_player").New(ViewDef.Team.MyGuild, self)
	require("scripts/game/team/team_apply_list").New(ViewDef.Team.TeamApplyList, self)

	self.check_box_list = {}
	self.team_info = {}
	self.index = nil
	self.btn_type_t = {}
end

function TeamView:__delete()
end

function TeamView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self.btn_type_t = {}
end

function TeamView:LoadCallBack(index, loaded_times)	
	self:InitTabbar()
	for i = 0, 2 do
		self:CreateCheckBox(i, self.node_t_list["layout_organize_" .. i].node)
	end
	self.node_t_list.btn_operate_1.node:addClickEventListener(BindTool.Bind(self.OnClickTeamHandler, self, 1))
	self.node_t_list.btn_operate_2.node:addClickEventListener(BindTool.Bind(self.OnClickTeamHandler, self, 2))

	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.TEAM_INFO_CHANGE, BindTool.Bind(self.UpdateHandleBtn, self))
	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.APPLY_LIST_CHANGE, BindTool.Bind(self.UpdateHandleBtn, self))
	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.INVITE_LIST_CHANGE, BindTool.Bind(self.UpdateHandleBtn, self))
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))

end

function TeamView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TeamView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

-- 显示索引回调
function TeamView:ShowIndexCallBack(index)

	self:FlushTabbarView()

	self:UpdateHandleBtn() -- 刷新按钮显示和按钮的作用

	TeamData.Instance:ResetSelectData() -- 重置选择的玩家
end

function TeamView:CreateCheckBox(key, parent)
	local state = key == TeamData.Instance.GetOrganizeType(key)

	self.check_box_list[key] = {}
	self.check_box_list[key].state = state
	self.check_box_list[key].node = XUI.CreateImageView(18, 20, ResPath.GetCommon("bg_checkbox_hook2"), true)
	self.check_box_list[key].node:setVisible(self.check_box_list[key].state)
	parent:addChild(self.check_box_list[key].node, 19)
	XUI.AddClickEventListener(parent, BindTool.Bind(self.OnShowCheck, self, key), true)
end

function TeamView:OnShowCheck(key)
	if nil == self.check_box_list[key] then return end

	TeamData.Instance.SetOrganizeType(key)
	local cur_type = TeamData.Instance.GetOrganizeType()
	for i = 0, 2 do
		self.check_box_list[i].state = (i == cur_type)
		self.check_box_list[i].node:setVisible(i == cur_type)
	end
end

function TeamView:InitTabbar()
	if nil == self.tabbar then
		local tabgroup = {}
		for k, v in pairs(self.tabbar_group) do
			tabgroup[#tabgroup + 1] = v.name
		end
		self.tabbar = ScrollTabbar.New()
		self.tabbar.space_interval_V = 15
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 3, -5,
									BindTool.Bind1(self.SelectTabCallback, self), tabgroup, 
									true, ResPath.GetCommon("toggle_120"))
		self.tabbar:GetView():setLocalZOrder(1)
	end
end

function TeamView:SelectTabCallback(index)
	ViewManager.Instance:OpenViewByDef(self.tabbar_group[index])

	self:FlushTabbarView()
	
end

-- 刷新标签栏显示和self.index
function TeamView:FlushTabbarView()
	for k, v in pairs(self.tabbar_group) do
		if v.open then
			self.tabbar:ChangeToIndex(k)
			self.index = k
			break
		end
	end
	self:OnRemindGroupChange()
end


function TeamView:UpdateHandleBtn()

	self.btn_type_t = {}
	local has_team = TeamData.Instance:HasTeam()
	local is_leader = TeamData.Instance:IsLeader()
	local index = self.index
	
	if index == TabIndex.team_info then
		if not has_team then
			self.btn_type_t = {nil, TEAM_BTN_TYPE.CJ}
		elseif is_leader then
			self.btn_type_t = {TEAM_BTN_TYPE.YC, TEAM_BTN_TYPE.JS}
		else
			self.btn_type_t = {nil, TEAM_BTN_TYPE.TC}
		end
	elseif index == TabIndex.team_near_t then
		if not has_team then
			if data then
				self.btn_type_t = {TEAM_BTN_TYPE.SQ, TEAM_BTN_TYPE.CJ}
			else
				self.btn_type_t = {nil, TEAM_BTN_TYPE.CJ}
			end
		elseif is_leader then
			self.btn_type_t = {nil, TEAM_BTN_TYPE.JS}
		else
			self.btn_type_t = {nil, TEAM_BTN_TYPE.TC}
		end
	elseif index == TabIndex.team_near_r then
		if not has_team then
			self.btn_type_t = {nil, TEAM_BTN_TYPE.CJ}
		elseif is_leader then
			self.btn_type_t = {TEAM_BTN_TYPE.YQ, TEAM_BTN_TYPE.JS}
		else
			self.btn_type_t = {nil, TEAM_BTN_TYPE.TC}
		end
	elseif index == TabIndex.team_friend then
		if not has_team then
			self.btn_type_t = {nil, TEAM_BTN_TYPE.CJ}
		elseif is_leader then
			self.btn_type_t = {TEAM_BTN_TYPE.YQ, TEAM_BTN_TYPE.JS}
		else
			self.btn_type_t = {nil, TEAM_BTN_TYPE.TC}
		end
	elseif index == TabIndex.team_guild then
		if not has_team then
			self.btn_type_t = {nil, TEAM_BTN_TYPE.CJ}
		elseif is_leader then
			self.btn_type_t = {TEAM_BTN_TYPE.YQ, TEAM_BTN_TYPE.JS}
		else
			self.btn_type_t = {nil, TEAM_BTN_TYPE.TC}
		end
	elseif index == TabIndex.team_apply then
		local team_info = nil
		if not has_team then
			team_info = TeamData.Instance:GetTeamInivteList()
			if #team_info > 0 then
				self.btn_type_t = {nil, TEAM_BTN_TYPE.QBJJ}
			else
				self.btn_type_t = {nil, TEAM_BTN_TYPE.CJ}
			end
		elseif is_leader then
			team_info = TeamData.Instance:GetTeamApplyList()
			if #team_info > 0 then
				self.btn_type_t = {TEAM_BTN_TYPE.QBTY, TEAM_BTN_TYPE.QBJJ}
			else
				self.btn_type_t = {nil, TEAM_BTN_TYPE.JS}
			end
		else
			self.btn_type_t = {nil, TEAM_BTN_TYPE.TC}
		end
	end
	for i = 1, 2 do
		local btn_type = self.btn_type_t[i]
		self.node_t_list["btn_operate_" .. i].node:setVisible(btn_type ~= nil)
		if btn_type then
			self.node_t_list["btn_operate_" .. i].node:setTitleText(Language.Team.TeamBtnList[btn_type])
		end
	end
end


function TeamView:OnClickTeamHandler(btn_index)
	local btn_type = self.btn_type_t[btn_index]
	local data = TeamData.Instance:GetSelectData()

	if btn_type == nil then return end
	if btn_type == TEAM_BTN_TYPE.CJ then 			--创建队伍 
		TeamCtrl.SendCreateTeamReq()
	elseif btn_type == TEAM_BTN_TYPE.JS then 		--解散队伍 
		TeamCtrl.SendDismissTeam()
	elseif btn_type == TEAM_BTN_TYPE.SQ then		--申请入队
		if data then
			TeamCtrl.SendApplyJoinTeam(data.name)
		end
	elseif btn_type == TEAM_BTN_TYPE.YQ then		--邀请组队
		if data then
			TeamCtrl.SendInviteJoinTeam(data.name)
		end
	elseif btn_type == TEAM_BTN_TYPE.TYRD then		--同意入队
		if data then
			TeamCtrl.Instance:SendJoinTeamApplyReply(data.role_id, 1)
		end
	elseif btn_type == TEAM_BTN_TYPE.JJRD then		--拒绝入队
		if data then
			TeamCtrl.Instance:SendJoinTeamApplyReply(data.role_id, 0)
		end
	elseif btn_type == TEAM_BTN_TYPE.YC then		--踢出队伍
		if data then
			TeamCtrl.SendRemoveTeammate(data.role_id)
		end
	elseif btn_type == TEAM_BTN_TYPE.TC then		--退出队伍
		TeamCtrl.SendQuitTeamReq()
	elseif btn_type == TEAM_BTN_TYPE.JSYQ then		--接受邀请
		if data then
			TeamCtrl.Instance:SendJoinTeamInviteReply(data.name, 1, 0)
		end
	elseif btn_type == TEAM_BTN_TYPE.JJYQ then		--拒绝邀请
		if data then
			TeamCtrl.Instance:SendJoinTeamInviteReply(data.name, 0, 0)
		end
	elseif btn_type == TEAM_BTN_TYPE.QBTY then		--全部同意
		if TeamData.Instance:IsLeader() then
			TeamCtrl.Instance:AllJoinTeamApplyReply(1)
		else
			TeamCtrl.Instance:AllJoinTeamInviteReply(1)
		end
	elseif btn_type == TEAM_BTN_TYPE.QBJJ then		--全部拒绝
		if TeamData.Instance:IsLeader() then
			TeamCtrl.Instance:AllJoinTeamApplyReply(0)
		else
			TeamCtrl.Instance:AllJoinTeamInviteReply(0)
		end
	end
end

function TeamView:OnRemindGroupChange()
	self.tabbar:SetRemindByIndex(6, RemindManager.Instance:GetRemindGroup(ViewDef.Team.TeamApplyList.remind_group_name) > 0)
end