ScoietyData = ScoietyData or BaseClass()
-- 邀请类型
ScoietyData.InviteType = {
	FriendType = 1,
	GuildType = 2,
	WorldType = 3,
	NearType = 4
}

--申请列表类型
APPLY_OPEN_TYPE = {
	JOIN = 1,
	FRIEND = 2,
	TEAM = 3,
	PET = 4,
}

-- 提示类型
ScoietyData.TipType = {
	FriendType = 1,
	TeamType = 2,
	JoinType = 3,
}

-- 特殊选择类型
ScoietyData.DetailType = {
	CampKing = "camp_king",					-- 国王
	EnemyType = "enemy",		-- 仇人
	BlackType = "black",		-- 黑名单
	Guild = "guild",			-- 公会
	GuildTuanZhang = "guild_tuan_zhang",	-- 公会会长
	CrossTeam = "cross_team",	-- 跨服组队
	Default = "default",		-- 默认
}

--组队邀请界面打开类型
ScoietyData.InviteOpenType = {
	Normal = "normal",				--普通
	ExpFuBen = "expfuben",			--经验副本
	ManyFuBen = "manyfuben",		--多人副本
}

ScoietyData.DetailData = {
	{name = Language.Menu.RecallPost, style = "recall_post"},							--罢免官职
	{name = Language.Menu.PrivateChat, style = "chat"},									--私聊
	{name = Language.Menu.InviteToSitMount, style = "sit_mount"},						--邀请同乘
	{name = Language.Menu.Trade, style = "trade"},									--交易(暂时屏蔽交易)
	{name = Language.Menu.ShowInfo, style = "info"},									--查看资料
	{name = Language.Menu.AddFriend, style = "addfriend"},								--添加好友
	{name = Language.Menu.SendMail, style = "mail"},									--发送邮件
	{name = Language.Menu.InviteTeam, style = "team"},									--组队邀请
	{name = Language.Menu.KickOutTeam, style = "kickout_team"},							--踢出队伍
	{name = Language.Menu.ChangeLeader, style = "give_leader"},							--移交队长
	{name = Language.Menu.GuildInvite, style = "guild_invite"},							--公会邀请
	{name = Language.Menu.GiveFlower, style = "flower"},								--赠送鲜花
	{name = Language.Menu.Blacklist, style = "black"},									--添加黑名单
	{name = Language.Menu.RemoveBlacklist, style = "remove_black"},						--移除黑名单
	{name = Language.Menu.DeleteFriend, style = "delete"},								--删除好友
	{name = Language.Menu.DeleteEnemy, style = "delenemy"},								--删除仇人
	{name = Language.Menu.Trace, style = "trace"},										--追踪
	{name = Language.Menu.KickoutGuild, style = "kickout"},								--踢出公会
	{name = Language.Menu.ChangeLeader, style = "change_leader_cross"},					--移交队长（跨服）
	{name = Language.Menu.ChangePost, style = "change_post"},							--任免职务
	{name = Language.Menu.TransferHuiZhang, style = "transfer_hui_zhang"},				--转让会长
}

MAIL_VIRTUAL_ITEM_BATTLEFIELDHONOR = 0					-- 战场荣誉
MAIL_VIRTUAL_ITEM_EXP = 1								-- 经验
MAIL_VIRTUAL_ITEM_GUILDGONGXIAN = 2						-- 仙盟贡献
MAIL_VIRTUAL_ITEM_SHENGWANG = 3							-- 声望
MAIL_VIRTUAL_ITEM_BIND_GOLD = 4							-- 绑定钻石
MAIL_VIRTUAL_ITEM_GOLD = 5								-- 钻石
MAIL_VIRTUAL_ITEM_BIND_COIN = 6							-- 绑定铜币
MAIL_VIRTUAL_ITEM_CROSS_HONOR = 7						-- 跨服荣誉
MAIL_VIRTUAL_ITEM_COIN = 8								-- 铜币
MAIL_VIRTUAL_ITEM_GONGXUN = 9							-- 功勋
MAIL_VIRTUAL_ITEM_CONVERTSHOP_MOJING = 10				-- 魔晶（商店）
MAIL_VIRTUAL_ITEM_CONVERTSHOP_SHENGWANG = 11			-- 声望（商店）
MAIL_VIRTUAL_ITEM_CONVERTSHOP_GONGXUN = 12				-- 功勋（商店）
MAIL_VIRTUAL_ITEM_CONVERTSHOP_WEIWANG = 13				-- 威望（商店）
MAIL_VIRTUAL_ITEM_CONVERTSHOP_GUOJIAQIYUN = 14			-- 国家气运
MAIL_VIRTUAL_ITEM_CONVERTSHOP_DAILYSCORE = 15 			-- 日常积分-兑换商店货币
MAIL_VIRTUAL_ITEM_FISHING_SCORE = 16					-- 钓鱼积分

ScoietyData.MailVirtualItem = {
	[MAIL_VIRTUAL_ITEM_BATTLEFIELDHONOR] = 90004,
	[MAIL_VIRTUAL_ITEM_EXP] = 90050,
	[MAIL_VIRTUAL_ITEM_GUILDGONGXIAN] = 90009,
	[MAIL_VIRTUAL_ITEM_SHENGWANG] = 90002,
	[MAIL_VIRTUAL_ITEM_BIND_GOLD] = 65533,
	[MAIL_VIRTUAL_ITEM_GOLD] = 65534,
	[MAIL_VIRTUAL_ITEM_BIND_COIN] = 65535,
	[MAIL_VIRTUAL_ITEM_CROSS_HONOR] = 90004,
	[MAIL_VIRTUAL_ITEM_COIN] = 65536,
	[MAIL_VIRTUAL_ITEM_GONGXUN] = 90004,
	[MAIL_VIRTUAL_ITEM_CONVERTSHOP_MOJING] = 90002,
	[MAIL_VIRTUAL_ITEM_CONVERTSHOP_SHENGWANG] = 90003,
	[MAIL_VIRTUAL_ITEM_CONVERTSHOP_GONGXUN] = 90004,
	[MAIL_VIRTUAL_ITEM_CONVERTSHOP_WEIWANG] = 90005,
	[MAIL_VIRTUAL_ITEM_CONVERTSHOP_GUOJIAQIYUN] = 90013,
	[MAIL_VIRTUAL_ITEM_CONVERTSHOP_DAILYSCORE] = 90012,
	[MAIL_VIRTUAL_ITEM_FISHING_SCORE] = 90015,
	-- [MAIL_VIRTUAL_ITEM_CONVERTSHOP_DAILYSCORE] = 90012
	-- [MAIL_VIRTUAL_ITEM_FISHING_SCORE] = 90011
	}	-- 附件虚拟物品对应的ID

local UPDATE = 0
local DELETE = 1

function ScoietyData:__init()
	if ScoietyData.Instance then
		print_error("[ScoietyData] Attemp to create a singleton twice !")
	end
	ScoietyData.Instance = self

	self.have_team = false			--是否拥有队伍
	self.invite_type = ScoietyData.InviteType.FriendType			--邀请类型

	self.friend_intimacy_cfg = ListToMap(self:GetFriendCfg().intimacy, "level")

	self.job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job or {}
	self.wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto") or {}
	self.main_role = GameVoManager.Instance.main_role_vo

	self.team_list = {}
	self.join_team_info = {}
	self.team_user_list = {}
	self.invite_info = {}		--被邀请信息

	self.friend_list = {}
	self.friend_route_info = {}
	self.random_role_list = {}
	self.role_vo_list = {}
	self.near_team_list = {}

	self.team_member_health_list = {}			--队伍血量信息列表

	self.req_team_index_list = {}				--记录请求的队伍index列表

	self.friend_apply_list = {}
	self.send_gift_times = 0			--送礼次数
	self.get_gift_times = 0				--收礼次数
	self.gift_record_list = {}			--收礼记录

	self.ref_addfriend = false			--是否拒接添加好友

	self.mail_list = {}
	self.mail_index_list = {}

	self.send_mail_name = ""			--收件人的名字

	self.mail_detail_list = {}		-- 邮件详细信息列表
	self.mail_state = false			-- 是否存在未读邮件
	self.mail_detail_info = {}

	RemindManager.Instance:Register(RemindName.ScoietyFriend, BindTool.Bind(self.GetFriendRemind, self))
	RemindManager.Instance:Register(RemindName.ScoietyMail, BindTool.Bind(self.GetMailRemind, self))
end

function ScoietyData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ScoietyFriend)
	RemindManager.Instance:UnRegister(RemindName.ScoietyMail)
	
	self.mail_detail_info = {}
	self.near_team_list = {}
	ScoietyData.Instance = nil
end

function ScoietyData:GetFriendCfg()
	if not self.friendcfg_auto then
		self.friendcfg_auto = ConfigManager.Instance:GetAutoConfig("friendcfg_auto")
	end
	return self.friendcfg_auto
end

--组队Set--------------------------
function ScoietyData:SetMenberCount(value)
	self.member_count = value
end

function ScoietyData:SetTeamInfo(info)
	self.team_list = info
	self:SetTeamUserList()
end

function ScoietyData:SCTeamMemberPosList(protocol)
	self.member_info_list = protocol.member_list
end

function ScoietyData:CheckIsLeaveScene(role_id)
	local scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(self.member_info_list) do
		if v.role_id == role_id then
			return v.scene_id == scene_id
		end
	end
end

function ScoietyData.SortMember(a, b)
	local member_a = {}
	local member_b = {}
	local team_member_list = ScoietyData.Instance.team_list.team_member_list or {}
	for k, v in ipairs(team_member_list) do
		if v.role_id == a then
			member_a = v
		end
		if v.role_id == b then
			member_b = v
		end
	end
	if member_a.is_online > member_b.is_online then
		return true
	else
		return false
	end
end

function ScoietyData:SetTeamUserList()
	self.team_user_list = {}
	local team_member_list = self.team_list.team_member_list or {}
	for k, v in ipairs(team_member_list) do
		if k == self.team_list.team_leader_index + 1 then
			table.insert(self.team_user_list, 1, v.role_id)
		else
			table.insert(self.team_user_list, v.role_id)
		end
	end
	table.sort(self.team_user_list, ScoietyData.SortMember)
	GlobalEventSystem:Fire(OtherEventType.TEAM_INFO_CHANGE)
end

function ScoietyData:OutOfTeamInfo(info)
	local main_role_id = Scene.Instance:GetMainRole():GetRoleId()
	if info.user_id == main_role_id then
		self.team_list = {}
		self.team_user_list = {}
		self.role_vo_list = {}
		self.have_team = false
		self.team_member_health_list = {}
		self.req_team_index_list = {}
	end
	GlobalEventSystem:Fire(OtherEventType.TEAM_INFO_CHANGE)
end

function ScoietyData:AddInviteInfo(info)
	info = TableCopy(info)
	for k, v in ipairs(self.invite_info) do
		if v.inviter == info.inviter then
			self.invite_info[k] = info
			return
		end
	end
	table.insert(self.invite_info, info)
end

function ScoietyData:RemoveInviteInfoById(role_id)
	for k, v in ipairs(self.invite_info) do
		if v.inviter == role_id then
			table.remove(self.invite_info, k)
			return
		end
	end
end

function ScoietyData:GetMemberList()
	local team_info = self:GetTeamInfo()
	local team_member_list = team_info.team_member_list or {}
	local team_user_list = self:GetTeamUserList()
	local member_list = {}
	for k, v in ipairs(team_user_list) do
		for i, j in ipairs(team_member_list) do
			if v == j.role_id then
				table.insert(member_list, j)
			end
		end
	end
	return member_list
end

function ScoietyData:ClearInviteInfo()
	self.invite_info = {}
end

function ScoietyData:SetTeamState(value)
	self.have_team = value
end

function ScoietyData:SetInviteType(value)
	if value then
		self.invite_type = value
	end
end

function ScoietyData:AddJoinTeamInfo(info)
	info = TableCopy(info)
	for k, v in ipairs(self.join_team_info) do
		if v.req_role_id == info.req_role_id then
			self.join_team_info[k] = info
			return
		end
	end
	table.insert(self.join_team_info, info)
end

function ScoietyData:RemoveJoinTeamInfoByRoleId(role_id)
	for k, v in ipairs(self.join_team_info) do
		if role_id == v.req_role_id then
			table.remove(self.join_team_info, k)
			return
		end
	end
end

function ScoietyData:SetTeamListAck(info)
	for i,v in pairs(info.team_list) do
		if self.main_role.camp == v.leader_camp then
			table.insert(self.near_team_list,v)
		end
	end
end

function ScoietyData:DelTeamListAck()
	self.near_team_list = {}
end

function ScoietyData:ChangeTeamList(info)
	local team_member_list = self.team_list.team_member_list or {}
	for k, v in ipairs(team_member_list) do
		if v.role_id == info.role_id then
			v.hp = info.hp
			v.max_hp = info.max_hp
			break
		end
	end
end

function ScoietyData:SetIsAutoJoinTeam(value)
	self.is_auto_apply_join_team = value
end

function ScoietyData:ChangeRoleVo(info, callback)
	local team_member_list = self.team_list.team_member_list or {}
	for k, v in ipairs(team_member_list) do
		if v.role_id == info.role_id then
			self.role_vo_list[v.role_id] = TableCopy(info)
			callback()
			break
		end
	end
end

function ScoietyData:RemoveRoleVo(role_id)
	for k, v in pairs(self.role_vo_list) do
		if role_id == v.role_id then
			self.role_vo_list[role_id] = nil
		end
	end
end

--清除队伍信息
function ScoietyData:ClearTeamInfo()
	if self.have_team then
		--之前有队伍就清空请求队伍index列表
		self.req_team_index_list = {}
	end
	self.have_team = false
	self.team_list = {}
	self.join_team_info = {}
	self.team_user_list = {}
	self.team_member_health_list = {}
end

--记录队伍血量信息
function ScoietyData:SetTeamMemberHpList(role_id, health)
	self.team_member_health_list[role_id] = health
end

function ScoietyData:RemoveTeamMemberHpList(role_id)
	for k, v in pairs(self.team_member_health_list) do
		if role_id == k then
			self.team_member_health_list[k] = nil
		end
	end
end

--记录请求加入队伍的index
function ScoietyData:SetReqTeamIndex(team_index, value)
	self.req_team_index_list[team_index] = value
end

--清空队伍index列表
function ScoietyData:ClearReqTeamIndexList()
	self.req_team_index_list = {}
end

--组队Get---------------------
function ScoietyData:GetReqTeamIndexList()
	return self.req_team_index_list
end

function ScoietyData:GetReqTeamIndexByIndex(team_index)
	return self.req_team_index_list[team_index]
end

function ScoietyData:GetTeamMemberHpList()
	return self.team_member_health_list
end

function ScoietyData:GetTeamMemberHpByRoleId(role_id)
	return self.team_member_health_list[role_id] or 1
end

function ScoietyData:GetTeamInfo()
	return self.team_list or {}
end

-- 获取队伍的总人数
function ScoietyData:GetTeamNum()
	return self.team_list.team_member_list and #self.team_list.team_member_list or 0
end

function ScoietyData:GetTeamIndex()
	return self.team_list.team_index or 0
end

function ScoietyData:GetTeamLeaderIndex()
	return self.team_list.team_leader_index or 0
end

function ScoietyData:GetInviteInfo()
	return self.invite_info
end

function ScoietyData:GetInviteInfoByIndex(index)
	local invite_list = {}
	for k, v in ipairs(self.invite_info) do
		if k == index then
			invite_list = v
			break
		end
	end
	return invite_list
end

function ScoietyData:IsLeaderById(id)
	if not self.have_team then
		return false
	else
		local member_list = self.team_list.team_member_list or {}
		local leader_index = self:GetTeamLeaderIndex() + 1
		if member_list[leader_index] and member_list[leader_index].role_id == id then
			return true
		end
	end
	return false
end

function ScoietyData:GetReqJoinTeamInfo()
	return self.join_team_info or {}
end

function ScoietyData:GetJoinRoleInfoByIndex(index)
	for k, v in ipairs(self.join_team_info) do
		if k == index then
			return v
		end
	end
	return {}
end

function ScoietyData:GetTeamState()
	return self.have_team
end

function ScoietyData:GetInviteType()
	return self.invite_type
end

function ScoietyData:GetTeamListAck()
	return self.near_team_list or {}
end

function ScoietyData:GetIsAutoJoinTeam()
	return self.is_auto_apply_join_team
end

function ScoietyData:GetTeamUserList()
	return self.team_user_list
end

function ScoietyData:GetMemberInfoByRoleId(role_id)
	local member_list = self.team_list.team_member_list or {}
	for k, v in ipairs(member_list) do
		if role_id == v.role_id then
			return v
		end
	end
	return {}
end

function ScoietyData:IsTeamMember(role_id)
	local member_list = self.team_list.team_member_list or {}
	for k, v in ipairs(member_list) do
		if role_id == v.role_id then
			return true
		end
	end
	return false
end

--好友Set---------------------------
function ScoietyData.SortFriendList(a, b)
	if a.is_online ~= b.is_online then
		return a.is_online > b.is_online
	else
		if a.gift_count ~= b.gift_count then
			return a.gift_count < b.gift_count
		end
		return a.intimacy > b.intimacy
	end
end

function ScoietyData:SetFriendInfo(info)
	self.friend_list = info.friend_list
	table.sort(self.friend_list, ScoietyData.SortFriendList)
end

function ScoietyData:ChangeFriendInfo(info)
	if not next(info.friend_info) then return end
	local changestate = tonumber(info.changestate)
	if changestate == UPDATE then
		local is_update = false
		for k,v in ipairs(self.friend_list) do
			if v.user_id == info.friend_info.user_id then
				is_update = true
				self.friend_list[k] = TableCopy(info.friend_info)
				break
			end
		end
		if is_update == false then
			table.insert(self.friend_list, TableCopy(info.friend_info))
		end
	elseif changestate == DELETE then
		if next(self.friend_list) then
			for k,v in ipairs(self.friend_list) do
				if v.user_id == info.friend_info.user_id then
					table.remove(self.friend_list, k)
					break
				end
			end
		end
	end
	table.sort(self.friend_list, ScoietyData.SortFriendList)
end

--改变好友在线状态
function ScoietyData:ChangeFriendIsOnlineState(role_id, is_online)
	for k, v in ipairs(self.friend_list) do
		if v.user_id == role_id then
			v.is_online = is_online
			break
		end
	end
	table.sort(self.friend_list, ScoietyData.SortFriendList)
end

function ScoietyData:SetFriendRoute(info)
	self.friend_route_info = info
end

function ScoietyData:SetRandomRoleList(info)
	self.random_role_list = info.auto_addfriend_list
end

function ScoietyData:SetOpenTipType(open_type)
	self.open_type = open_type
end

function ScoietyData:SetOpenDetailType(open_type)
	self.detail_type = open_type
end

function ScoietyData:SetSelectRoleInfo(data)
	self.select_role_info = data
end

function ScoietyData:SetBlackList(info)
	self.black_list = info.blacklist or {}
end

function ScoietyData:ChangeBlackList(info)
	if not next(info) then return end
	local changestate = tonumber(info.changstate)
	if changestate == UPDATE then
		local is_update = false
		for k,v in ipairs(self.black_list) do
			if v.user_id == info.user_id then
				is_update = true
				self.black_list[k] = TableCopy(info)
				break
			end
		end
		if is_update == false then
			table.insert(self.black_list, TableCopy(info))
		end
	elseif changestate == DELETE then
		for k, v in ipairs(self.black_list) do
			if v.user_id == info.user_id then
				table.remove(self.black_list, k)
				break
			end
		end
	end
end

--获取可进入副本的队伍人数
function ScoietyData:GetCanEnterCount()
	local member_list = self.team_list.team_member_list or {}
	local count = 0
	for _, v in ipairs(member_list) do
		if v.is_online == 1 then
			count = count + 1
		end
	end
	return count
end

--获取当前队伍的经验加成
function ScoietyData:GetTeamAddExp()
	local exp = 0
	local scene_id = Scene.Instance:GetSceneId()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local member_list = self.team_list.team_member_list or {}
	for k,v in ipairs(member_list) do
		if v.is_online == 1 and scene_id == v.scene_id and v.role_id ~= role_id then
			exp = exp + 30
		end
	end
	return exp
end

function ScoietyData:ChangeAddFriendState(value)
	self.ref_addfriend = value
end

--添加好友请求列表
function ScoietyData:AddFirendApplyList(info)
	info = TableCopy(info)
	for k, v in ipairs(self.friend_apply_list) do
		if v.req_user_id == info.req_user_id then
			self.friend_apply_list[k] = info
			return
		end
	end
	table.insert(self.friend_apply_list, info)
end

--删除好友请求列表
function ScoietyData:RemoveFriendApplyInfoByRoleId(role_id)
	for k, v in ipairs(self.friend_apply_list) do
		if role_id == v.req_user_id then
			table.remove(self.friend_apply_list, k)
			return
		end
	end
end

--设置送礼次数
function ScoietyData:SetSendGiftTimes(times)
	self.send_gift_times = times
end

--设置收礼次数
function ScoietyData:SetGetGiftTimes(times)
	self.get_gift_times = times
end

function ScoietyData:SetIsCheckGift(state)
	self.is_check_gift = state
end

local function SortGiftRecordList(a, b)
	if a.shou_gift_time > b.shou_gift_time then
		return true
	end
	return false
end

--设置收礼列表
function ScoietyData:SetGiftRecordList(list)
	self.gift_record_list = list
	table.sort(self.gift_record_list, SortGiftRecordList)
end

--好友Get-----------------------------
--是否显示送礼红点
function ScoietyData:IsSetGiftRedPoint()
	local can_set = false
	--查看过则不再显示
	if self.is_check_gift then
		return can_set
	end
	--先检查是否存在鲜花
	local is_enough_num = false
	for k, v in ipairs(FLOWER_ID_LIST) do
		is_enough_num = ItemData.Instance:GetItemNumIsEnough(v, 1)
		if not is_enough_num and k == 1 then
			local free_time = FlowersData.Instance:GetFreeFlowerTime()
			local max_free = FlowersData.Instance:GetSendFlowerCfgFreeTime()
			local times = max_free - free_time
			is_enough_num = times > 0
		end
		if is_enough_num then
			break
		end
	end

	if is_enough_num then
		--再判断是否有好友在线
		for k, v in ipairs(self.friend_list) do
			if v.is_online == 1 and v.gift_count <= 0 then
				can_set = true
				break
			end
		end
	end

	return can_set
end

function ScoietyData:GetCanShowGiftRed()
	return self.can_show_gift_red_point
end

function ScoietyData:GetIsCheckGift()
	return self.is_check_gift
end

function ScoietyData:GetSendGiftTimes()
	return self.send_gift_times
end

function ScoietyData:GetShouGiftTimes()
	return self.get_gift_times
end

function ScoietyData:GetGiftRecordList()
	return self.gift_record_list
end

function ScoietyData:GetFriendInfo()
	return self.friend_list or {}
end

--根据性别/阵营来获取好友列表
function ScoietyData:GetFriendInfoBySex(sex, camp)
	local friend_list = {}
	for k, v in ipairs(self.friend_list) do
		if v.sex == sex then
			if camp and v.camp == camp then
				table.insert(friend_list, v)
			end
		end
	end
	return friend_list
end

function ScoietyData:GetFriendNameById(role_id)
	local name = ""
	for k, v in ipairs(self.friend_list) do
		if v.user_id == role_id then
			name = v.gamename
			break
		end
	end
	return name
end

--获取好友是否在线
function ScoietyData:GetFriendIsOnlineById(role_id)
	local is_online = 0
	for k, v in ipairs(self.friend_list) do
		if v.user_id == role_id then
			is_online = v.is_online
			break
		end
	end
	return is_online
end

function ScoietyData:GetIsOnLineFriendInfo()
	local online_info = {}
	for k, v in ipairs(self.friend_list) do
		if v.is_online == 1 then
			if self.main_role.camp == v.camp then
				table.insert(online_info, v)
			end
			
		end
	end
	return online_info
end

function ScoietyData:GetAllOnLineFriendInfo()
	local online_info = {}
	for k, v in ipairs(self.friend_list) do
		if v.is_online == 1 then
			table.insert(online_info, v)
		end
	end
	return online_info
end

function ScoietyData:GetFriendInfoByName(name)
	local friend_info = {}
	for k,v in pairs(self.friend_list) do
		if v.gamename == name then
			friend_info = v
			break
		end
	end
	return friend_info
end

function ScoietyData:GetFriendInfoById(role_id)
	local friend_info = {}
	for k,v in pairs(self.friend_list) do
		if v.user_id == role_id then
			friend_info = v
			break
		end
	end
	return friend_info
end

function ScoietyData:GetFriendRoute()
	return self.friend_route_info or {}
end

function ScoietyData:GetFriendRouteName()
	return self.friend_route_info.req_gamename or ""
end

function ScoietyData:GetRandomRoleList()
	return self.random_role_list or {}
end

function ScoietyData:IsFriend(name)
	for k, v in ipairs(self.friend_list) do
		if v.gamename == name then
			return true
		end
	end
	return false
end

function ScoietyData:IsFriendById(role_id)
	for k, v in ipairs(self.friend_list) do
		if v.user_id == role_id then
			return true
		end
	end
	return false
end

function ScoietyData:GetFriendIdByName(name)
	for k, v in ipairs(self.friend_list) do
		if v.gamename == name then
			return v.user_id
		end
	end
	return nil
end

function ScoietyData:GetOpenTipType()
	return self.open_type or 0
end

function ScoietyData:GetOpenDetailType()
	return self.detail_type or ""
end

function ScoietyData:GetSelectRoleInfo()
	return self.select_role_info or {}
end

function ScoietyData:GetSelectRoleIsOnline()
	if self.select_role_info == nil or next(self.select_role_info) == nil then 
		return false
	end
	return self.select_role_info.is_online == 1
end

function ScoietyData:GetBlackList()
	return self.black_list or {}
end

function ScoietyData:IsBlack(role_id)
	for k, v in ipairs(self.black_list or {}) do
		if role_id == v.user_id then
			return true
		end
	end
	return false
end

function ScoietyData:IsBlackByName(role_name)
	for k, v in ipairs(self.black_list or {}) do
		if role_name == v.gamename then
			return true
		end
	end
	return false
end

function ScoietyData:GetAddFriendState()
	return self.ref_addfriend
end

function ScoietyData:GetIntimacyCfg()
	return self.friend_intimacy_cfg
end

--获取好友申请列表
function ScoietyData:GetFriendApplyList()
	return self.friend_apply_list or {}
end

function ScoietyData:GetFriendApplyInfoByIndex(index)
	for k, v in ipairs(self.friend_apply_list) do
		if k == index then
			return v
		end
	end
	return {}
end

--仇人Set-----------------------------
function ScoietyData.SortEnemyList(a, b)
	if a.is_online > b.is_online then
		return true
	elseif a.is_online == b.is_online then
		if a.kill_count > b.kill_count then
			return true
		else
			return false
		end
	end
	return false
end

function ScoietyData:SetEnemyList(info)
	self.enemy_list = info.enemy_list or {}
	table.sort(self.enemy_list, ScoietyData.SortEnemyList)
end

function ScoietyData:ChangeEnemyList(info)
	if not next(info.enemy_info) then return end
	local changestate = tonumber(info.changstate)
	if changestate == UPDATE then
		local is_update = false
		for k,v in ipairs(self.enemy_list) do
			if v.user_id == info.enemy_info.user_id then
				is_update = true
				self.enemy_list[k] = TableCopy(info.enemy_info)
				break
			end
		end
		if is_update == false then
			table.insert(self.enemy_list, TableCopy(info.enemy_info))
		end
	elseif changestate == DELETE then
		for k, v in ipairs(self.enemy_list) do
			if v.user_id == info.enemy_info.user_id then
				table.remove(self.enemy_list, k)
				break
			end
		end
	end
	table.sort(self.enemy_list, ScoietyData.SortEnemyList)
end


--改变仇人在线状态
function ScoietyData:ChangeEnemyOnlineState(role_id, is_online)
	for k,v in ipairs(self.enemy_list) do
		if v.user_id == role_id then
			v.is_online = is_online
			break
		end
	end
	table.sort(self.enemy_list, ScoietyData.SortEnemyList)
end

--仇人Get-----------------------------
function ScoietyData:GetEnemyList()
	return self.enemy_list or {}
end

function ScoietyData:IsEnemy(role_id)
	for k, v in ipairs(self.enemy_list or {}) do
		if role_id == v.user_id then
			return true
		end
	end
	return false
end

--邮件Set-----------------------------
function ScoietyData.SortMailIndex(a, b)
	local mail_a = ScoietyData.Instance:GetMailByIndex(a)
	local mail_b = ScoietyData.Instance:GetMailByIndex(b)
	if not next(mail_a) or not next(mail_b) then
		return false
	end
	if mail_a.mail_status.is_read < mail_b.mail_status.is_read then
		return true
	else
		if mail_a.mail_status.is_read == mail_b.mail_status.is_read then
			-- 判断是否有未领取的附件
			local a_isget = ScoietyData.Instance:IsNotGet(a)
			local b_isget = ScoietyData.Instance:IsNotGet(b)
			if a_isget and not b_isget then
				return true
			else
				return false
			end
			if mail_a.mail_status.recv_time > mail_b.mail_status.recv_time then
				return true
			end
		end
		return false
	end
end

function ScoietyData:SetMailList(list)
	self.mail_list = list
	self:SetMailIndexList()
end

function ScoietyData:SortMailIndexList()
	table.sort(self.mail_index_list, ScoietyData.SortMailIndex)
end

function ScoietyData:SetMailIndexList()
	local mails = self.mail_list.mails or {}
	self.mail_index_list = {}
	for k, v in ipairs(mails) do
		table.insert(self.mail_index_list, v.mail_index)
	end
	table.sort(self.mail_index_list, ScoietyData.SortMailIndex)
end

function ScoietyData:SetMailDetail(info)
	self.mail_detail_info = info
	-- table.insert(self.mail_detail_list, info)
end

function ScoietyData:DelMailDetail()
	self.mail_detail_info = {}
end

function ScoietyData:DelMailInfo(index)
	local mail_list = self.mail_list.mails or {}
	for k, v in ipairs(mail_list) do
		if index == v.mail_index then
			table.remove(mail_list, k)
			self:DelMailIndexListByIndex(index)
			break
		end
	end
end

function ScoietyData:DelMailIndexListByIndex(index)
	for k, v in ipairs(self.mail_index_list) do
		if v == index then
			table.remove(self.mail_index_list, k)
		end
	end
end

function ScoietyData:AddMailInfo(info)
	self.mail_list.mails = self.mail_list.mails or {}
	table.insert(self.mail_list.mails, info)
	self:AddMailIndexListByIndex(info.mail_index)
end

function ScoietyData:AddMailIndexListByIndex(index)
	table.insert(self.mail_index_list, 1, index)
end

function ScoietyData:ChangeMailList(info)
	if info.ret == 0 then
		self.mail_list.mails = self.mail_list.mails or {}
		for k, v in ipairs(self.mail_list.mails) do
			if v.mail_index == info.mail_index then
				v.mail_status.is_read = 1
				if info.item_index == -1 then
					v.has_attachment = 0
				end
				table.sort(self.mail_index_list, ScoietyData.SortMailIndex)
				break
			end
		end
	end
end

function ScoietyData:SetSendName(name)
	self.send_mail_name = name
end

function ScoietyData:SetIsPriviteMail(state)
	self.mail_privite_state = state
end

--邮件Get-----------------------------
function ScoietyData:GetMailByIndex(index)
	local mails = self.mail_list.mails or {}
	for k, v in ipairs(mails) do
		if v.mail_index == index then
			return v
		end
	end
	return {}
end

function ScoietyData:GetMailIndexList()
	return self.mail_index_list
end

function ScoietyData:GetSendName()
	return self.send_mail_name
end

function ScoietyData:GetIsPriviteMail()
	return self.mail_privite_state
end

function ScoietyData:GetMailList()
	return self.mail_list or {}
end

function ScoietyData:GetMailDetail()
	return self.mail_detail_info or {}
	-- for k, v in ipairs(self.mail_detail_list) do
	-- 	if v.mail_index == mail_index then
	-- 		return v
	-- 	end
	-- end
	-- return {}
end

--判断是否未领取附件
function ScoietyData:IsNotGet(mail_index)
	local mail_list = self.mail_list.mails or {}
	for k, v in ipairs(mail_list) do
		if v.mail_index == mail_index then
			if v.has_attachment == 1 then
				return true
			else
				return false
			end
		end
	end
	return false
end

--判断所有邮件是否已领取附件
function ScoietyData:IsAllGet()
	local mail_list = self.mail_list.mails or {}
	for k, v in ipairs(mail_list) do
		if v.has_attachment == 1 then
			return false
		end
	end
	return true
end

--判断所有邮件是否已读
function ScoietyData:IsAllRead()
	local mail_list = self.mail_list.mails or {}
	for k, v in ipairs(mail_list) do
		if v.mail_status and v.mail_status.is_read == 0 then
			return false
		end
	end
	return true
end

--设置邮件红点状态
function ScoietyData:ChangeMailState(state)
	self.mail_state = state
end

function ScoietyData:GetMailState()
	return self.mail_state
end

function ScoietyData:GetTeamExp(team_list)
	local exp = 0
	local scene_id = Scene.Instance:GetSceneId()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local count = 1
	for k,v in pairs(team_list) do
		if v.is_online == 1 and scene_id == v.scene_id and v.role_id ~= role_id then
			count = count + 1
			if count == 2 then
				exp = exp + 30
			elseif count == 3 then
				exp = exp + 30
			elseif count == 4 then
				exp = exp + 40
			end
		end
	end
	return exp
end

function ScoietyData:GetFriendRemind()
	return self:IsSetGiftRedPoint() and 1 or 0
end

function ScoietyData:GetMailRemind()
	return self:GetMailState() and 1 or 0
end

function ScoietyData:MainRoleIsCap()
	local id = GameVoManager.Instance:GetMainRoleVo().role_id
	return self:IsLeaderById(id)
end

function ScoietyData:GetMemberPosState(member_id, member_scene_id, is_online)
	if is_online ~= 1 then return Language.Society.OutLine end

	local scene_id = Scene.Instance:GetSceneId()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if role_id == member_id then
		return Language.Society.InNear
	else
		return member_scene_id == scene_id and Language.Society.InNear or Language.Society.InFar
	end
end