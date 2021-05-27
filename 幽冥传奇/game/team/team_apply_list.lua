------------------------------------------------------------
-- 组队视图 (申请列表)
------------------------------------------------------------
local TeamApplyList = BaseClass(SubView)

function TeamApplyList:__init()
	self.texture_path_list[1] = 'res/xui/society.png'
	self.config_tab = {
		{"team_ui_cfg", 5, {0}}
	}

	self.player_list = nil
end

function TeamApplyList:__delete()

end

function TeamApplyList:ReleaseCallBack()

	if self.apply_list then
		self.apply_list:DeleteMe()
		self.apply_list = nil
	end

end

function TeamApplyList:LoadCallBack(index, loaded_times)
	self:CreateApplyList()

	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.TEAM_INFO_CHANGE, BindTool.Bind(self.FlushList, self))
	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.APPLY_LIST_CHANGE, BindTool.Bind(self.FlushList, self))
	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.INVITE_LIST_CHANGE, BindTool.Bind(self.FlushList, self))
end

--显示索引回调
function TeamApplyList:ShowIndexCallBack(index)
	self:FlushList()
end

----------视图函数----------

function TeamApplyList:CreateApplyList()
	if self.apply_list then return end
	local ph_team_grid = self.ph_list.ph_apply_list
	self.apply_list = ListView.New()
	self.apply_list:Create(ph_team_grid.x, ph_team_grid.y, ph_team_grid.w, ph_team_grid.h, nil, self.TeamApplyItemRender, nil, nil, self.ph_list.ph_apply_list_item)
	self.apply_list:SetMargin(5)
	self.apply_list:SetItemsInterval(5)
	self.apply_list:SetAutoSupply(true)
	self.apply_list:SetJumpDirection(ListView.Top)
	self.apply_list:SetSelectCallBack(BindTool.Bind1(self.SelectTeamItemCallBack, self))
	self.node_t_list.layout_apply_list.node:addChild(self.apply_list:GetView(), 100)
end

function TeamApplyList:FlushList()
	local list = {} -- 获取列表
	local has_team = TeamData.Instance:HasTeam()
	local is_leader = TeamData.Instance:IsLeader()
	if is_leader then
		list = TeamData.Instance:GetTeamApplyList()
	elseif not has_team then
		list = TeamData.Instance:GetTeamInivteList()
	end

	self.apply_list:SetDataList(list)
end

----------end----------

function TeamApplyList:SelectTeamItemCallBack(item)
	if item == nil or item:GetData() == nil then return end
	TeamData.Instance:SetSelectData(item:GetData())
end

------------------------------------------------------------
-- 申请列表
------------------------------------------------------------

TeamApplyList.TeamApplyItemRender = BaseClass(BaseRender)
local TeamApplyItemRender = TeamApplyList.TeamApplyItemRender

function TeamApplyItemRender:__init()
	
end

function TeamApplyItemRender:__delete()
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
end

function TeamApplyItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree["btn_agree"].node:addClickEventListener(BindTool.Bind(self.OnAgreeClicked, self))
	XUI.AddClickEventListener(self.node_tree["lbl_name"].node, BindTool.Bind(self.OnClickRoleName, self))
	-- 头像
	self.role_head = RoleHeadCell.New(false, false)
	self.node_tree["img9_bg"].node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
end

function TeamApplyItemRender:OnFlush()
	for k,v in pairs(self.view:getChildren()) do
		if v ~= self.node_tree["img9_bg"].node and v ~= self.select_effect and v.setVisible then
			v:setVisible(nil ~= self.data)
		end
	end
	if nil == self.data then return end
	self.node_tree.lbl_name.node:setString(self.data.name)
	local level_str = self.data.level .. Language.Common.Ji
	self.node_tree.lbl_level.node:setString(level_str)
	self.node_tree.lbl_profession.node:setString(Language.Common.ProfName[self.data.prof])
	local guild_name = self.data.guild_name or GuildData.Instance:GetGuildName()
	self.node_tree.lbl_guild_name.node:setString(guild_name == "" and Language.Common.No or guild_name)
	local is_grey = self.data.is_online == 0 or self.data.is_alive == 0
	self.role_head:SetRoleInfo(self.data.role_id, self.data.name, self.data.lbl_profession, not is_grey, self.data.sex or 0)
end

function TeamApplyItemRender:OnAgreeClicked()
	if TeamData.Instance:IsLeader() then
		TeamCtrl.Instance:SendJoinTeamApplyReply(self.data.role_id, 1)
	else
		TeamCtrl.Instance:SendJoinTeamInviteReply(self.data.name, 1, 0)
	end
end

function TeamApplyItemRender:OnClickRoleName()
	self.role_head:OpenMenu()
end


return TeamApplyList