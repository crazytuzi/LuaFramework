------------------------------------------------------------
-- 组队视图 (附近玩家, 我的好友, 我的行会)
------------------------------------------------------------

local TeamPlayer = BaseClass(SubView)

function TeamPlayer:__init()
	self.texture_path_list[1] = 'res/xui/society.png'
	self.config_tab = {
		{"team_ui_cfg", 4, {0}}
	}

	self.player_list = nil
end

function TeamPlayer:__delete()

end

function TeamPlayer:ReleaseCallBack()

	if self.player_list then
		self.player_list:DeleteMe()
		self.player_list = nil
	end

end

function TeamPlayer:LoadCallBack(index, loaded_times)
	self:CreatePlayerList()

	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.APPLY_LIST_CHANGE, BindTool.Bind(self.FlushList, self))

end

--显示索引回调
function TeamPlayer:ShowIndexCallBack(index)
	self:FlushList()
end

----------视图函数----------

function TeamPlayer:CreatePlayerList()
	if self.player_list then return end
	local ph = self.ph_list.ph_player_list
	self.player_list = ListView.New()
	self.player_list:Create(ph.x, ph.y, ph.w, ph.h, nil, self.TeamPlayerItemRender, nil, nil, self.ph_list.ph_player_list_item)
	self.player_list:SetMargin(5)
	self.player_list:SetItemsInterval(5)
	self.player_list:SetAutoSupply(true)
	self.player_list:SetJumpDirection(ListView.Top)
	self.player_list:SetSelectCallBack(BindTool.Bind1(self.SelectTeamItemCallBack, self))
	self.node_t_list.layout_player_list.node:addChild(self.player_list:GetView(), 100)
end

function TeamPlayer:FlushList()
	local list = {}
	local index = self:GetViewDef()
	if index == ViewDef.Team.NearPlayer then
		for k,v in pairs(Scene.Instance:GetRoleList()) do
			local role_vo = v:GetVo()
			local vo = {}
			vo.role_id = role_vo.obj_id
			vo.name = role_vo.name
			vo.level = role_vo[OBJ_ATTR.CREATURE_LEVEL]
			vo.prof = role_vo[OBJ_ATTR.ACTOR_PROF]
			vo.avatar_id = role_vo[OBJ_ATTR.ENTITY_AVATAR_ID]
			vo.sex = role_vo[OBJ_ATTR.ACTOR_SEX]
			vo.guild_name = role_vo.guild_name
			vo.capacity = role_vo[OBJ_ATTR.ACTOR_BATTLE_POWER]
			vo.zhuan = role_vo[OBJ_ATTR.ACTOR_CIRCLE]
			table.insert(list, vo)
		end
	elseif index == ViewDef.Team.MyGoodFriend then
		list = SocietyData.Instance:GetFriendList()
	elseif index == ViewDef.Team.MyGuild then
		local guild_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
		list = GuildData.Instance:GetGuildMemberListWithoutMe()
	end
	self.player_list:SetDataList(list)
end

----------end----------

function TeamPlayer:SelectTeamItemCallBack(item)
	if item == nil or item:GetData() == nil then return end
	TeamData.Instance:SetSelectData(item:GetData())
end

------------------------------------------------------------
-- 队伍显示配置
------------------------------------------------------------

TeamPlayer.TeamPlayerItemRender = BaseClass(BaseRender)
local TeamPlayerItemRender = TeamPlayer.TeamPlayerItemRender

function TeamPlayerItemRender:__init()
	
end

function TeamPlayerItemRender:__delete()
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
end

-- 玩家列表

function TeamPlayerItemRender:CreateChild()

	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree["lbl_name"].node, BindTool.Bind(self.OnClickRoleName, self))
	self.role_head = RoleHeadCell.New(false, false)
	self.node_tree["img9_bg"].node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
end

function TeamPlayerItemRender:OnFlush()
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
	local color = is_grey and COLOR3B.G_W or COLOR3B.WHITE
	self.node_tree.lbl_name.node:setColor(color)
	self.node_tree.lbl_level.node:setColor(color)
	self.node_tree.lbl_profession.node:setColor(color)
	self.node_tree.lbl_guild_name.node:setColor(color)
	self.role_head:SetRoleInfo(self.data.role_id, self.data.name, self.data.lbl_profession, not is_grey, self.data.sex or 0)
end

function TeamPlayerItemRender:OnClickRoleName()
	self.role_head:OpenMenu()
end


return TeamPlayer