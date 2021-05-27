------------------------------------------------------------
-- 队伍视图 (我的队伍,附近队伍)
------------------------------------------------------------

local TeamList = BaseClass(SubView)

function TeamList:__init()
	self.texture_path_list[1] = 'res/xui/society.png'
	self.config_tab = {
		{"team_ui_cfg", 3, {0}}
	}

	self.team_list = nil
	self.select_index = 1
end

function TeamList:__delete()

end

function TeamList:ReleaseCallBack()

	if self.team_list then
		self.team_list:DeleteMe()
		self.team_list = nil
	end

end

function TeamList:LoadCallBack(index, loaded_times)
	self:CreateTeamList()

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list.btn_left.node, BindTool.Bind(self.OnPageChange, self, true))
	XUI.AddClickEventListener(self.node_t_list.btn_right.node, BindTool.Bind(self.OnPageChange, self, false))
	self.node_t_list.btn_left.node:setVisible(false)
	self.node_t_list.btn_right.node:setVisible(false)

	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.TEAM_INFO_CHANGE, BindTool.Bind(self.FlushList, self))

end

--显示索引回调
function TeamList:ShowIndexCallBack(index)
	self:FlushList()
	self.select_index = 1
	self:SetSelectIndex()
end

----------视图函数----------

function TeamList:CreateTeamList()
	-- if self.team_list then return end
	-- local ph_team_grid = self.ph_list.ph_team_grid
	-- self.team_list = BaseGrid.New()
	-- local grid_node = self.team_list:CreateCells({w=ph_team_grid.w, h=ph_team_grid.h, cell_count = 20, col = 3, row = 1, itemRender = self.TeamItemRender, ui_config=self.ph_list.ph_team_item})
	-- grid_node:setAnchorPoint(0.5, 0.5)
	-- grid_node:setPosition(ph_team_grid.x, ph_team_grid.y)
	-- self.team_list:SetSelectCallBack(BindTool.Bind(self.SelectTeamItemCallBack, self))
	-- self.team_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	-- self.node_t_list.layout_team_list.node:addChild(grid_node, 1)

	if self.team_list then return end
	local ph = self.ph_list.ph_team_grid
	self.team_list = ListView.New()
	self.team_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, TeamList.TeamItemRender, nil, nil, self.ph_list.ph_team_item)
	self.team_list:ChangeToIndex(1)
	self.team_list:SetJumpDirection(ListView.Top)
	self.team_list:SetSelectCallBack(BindTool.Bind(self.SelectTeamItemCallBack, self))
	-- self.team_list:SetItemsInterval(14)
	self.node_t_list.layout_team_list.node:addChild(self.team_list:GetView(), 100)
end

function TeamList:RefreshGridBtnShow()
	local page = self.team_list:GetCurPageIndex()
	self.node_t_list.btn_left.node:setVisible(1 ~= page)
	self.node_t_list.btn_right.node:setVisible(page ~= self.team_list:GetPageCount())
end

function TeamList:FlushList()
	local list = {}
	local getlist = nil -- 获取列表
	local index = self:GetViewDef()
	if index == ViewDef.Team.MyTeam then
		getlist = TeamData.Instance:GetMemberList()

	elseif index == ViewDef.Team.NearTeam then
		getlist = TeamData.Instance:GetNearTeamList()
	end
	-- for i,v in ipairs(getlist) do
	-- 	if nil == list[0] then
	-- 		list[0] = v
	-- 	else
	-- 		table.insert(list, v)
	-- 	end
	-- end
	self.team_list:SetDataList(getlist)
end

function TeamList:SetSelectIndex()
	local index = self:GetViewDef()
	if index == ViewDef.Team.MyTeam then
		getlist = TeamData.Instance:GetMemberList()

	elseif index == ViewDef.Team.NearTeam then
		getlist = TeamData.Instance:GetNearTeamList()
	end

	-- PrintTable(getlist[self.select_index])
	self.team_list:ChangeToIndex(self.select_index)
	TeamData.Instance:SetSelectData(getlist[self.select_index])
end

----------end----------

function TeamList:OnPageChangeCallBack()
	self:RefreshGridBtnShow()
end

function TeamList:SelectTeamItemCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	-- TeamData.Instance:SetSelectData(item:GetData())

	self.select_index = index
	self:SetSelectIndex()
end

function TeamList:OnPageChange(to_left)
	local page = self.team_list:GetCurPageIndex()
	if to_left then
		 self.team_list:ChangeToPage(page - 1)
	else
		 self.team_list:ChangeToPage(page + 1)
	end
end


------------------------------------------------------------
-- 队伍显示配置
------------------------------------------------------------

TeamList.TeamItemRender = BaseClass(BaseRender)
local TeamItemRender = TeamList.TeamItemRender

function TeamItemRender:__init()
	-- self:AddClickEventListener()
end

function TeamItemRender:__delete()
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
end

function TeamItemRender:CreateChild()
	BaseRender.CreateChild(self)
	-- 头像
	self.role_head = RoleHeadCell.New(false, false)
	self.role_head:SetPosition(90, 286)
	self.role_head:AddClickEventListener()
	self.layout_content = self.node_tree.layout_team_content
	self.layout_content.node:addChild(self.role_head:GetView(), 1000)

	self.cap_num = NumberBar.New()
	self.cap_num:SetRootPath(ResPath.GetCommon("num_133_"))
	self.cap_num:SetPosition(100, 130)
	self.cap_num:SetGravity(NumberBarGravity.Center)
	self.layout_content.node:addChild(self.cap_num:GetView(), 300, 300)
end

function TeamItemRender:OnFlush()
	self.layout_content.node:setVisible(self.data ~= nil)
	
	if nil == self.data then return end
	local is_grey = self.data.is_online == 0 or self.data.is_alive == 0
	self.role_head:SetRoleInfo(self.data.role_id, self.data.name, self.data.prof, not is_grey, self.data.sex or 0)
	self.cap_num:SetNumber(self.data.capacity)
	self.cap_num:SetScale(0.75)

	self.node_tree.img_icon.node:loadTexture(ResPath.GetBigPainting("team_head_" .. self.data.sex))

	self.layout_content.lbl_name.node:setString(self.data.name)
	local level_str = self.data.level .. Language.Common.Ji
	self.layout_content.lbl_level.node:setString(level_str)
	self.layout_content.lbl_prof.node:setString(Language.Common.ProfName[self.data.prof])
	local guild_name = self.data.guild_name or GuildData.Instance:GetGuildName()
	self.layout_content.lbl_guild.node:setString(guild_name == "" and "无" or guild_name)
	self:ShowLeaderIcon(self.data.is_teammate and TeamData.Instance:IsLeader(self.data.role_id))
end

function TeamItemRender:ShowLeaderIcon(show)
	if show and nil == self.equip_stamp then
		local size = self.view:getContentSize()
		self.equip_stamp = XUI.CreateImageView(size.width - 35, size.height - 110, ResPath.GetCommon("stamp_leader"))
		self.layout_content.node:addChild(self.equip_stamp, 1001)
	elseif self.equip_stamp then
		self.equip_stamp:setVisible(show)
	end
end

function TeamItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999)
end

return TeamList