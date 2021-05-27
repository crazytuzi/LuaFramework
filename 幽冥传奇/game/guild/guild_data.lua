GuildData = GuildData or BaseClass()

GUILD_RELATIONSHIP = {
	NULL = 0,
	UNION = 1,
	ENEMY = 2,
}

GUILD_RELATIONSHIP_OPT = {
	UNION = 1,					-- 联盟
	CANCEL_UNION = 3,			-- 解除联盟
}

GUILD_DONATE_OPT = {
	GET_REWARD = 0,					-- 获得奖励
	BIND_COIN = 1,					-- 绑金捐献
	GOLD = 2,						-- 元宝捐献
}

GUILD_FLAG_CFG = {
	INIT_LEVEL = 1,
	LEVEL_UP_STEP = 5,
}

function GuildData:__init()
	if GuildData.Instance then
		ErrorLog("[GuildData]:Attempt to create singleton twice!")
	end
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	GuildData.Instance = self

	self.joinhanleresult = 1
	self:InitGuildData()
end

function GuildData:__delete()
	GuildData.Instance = nil
end

-- 事件监听
GuildData.GuildInfoChange        = "guild_info_change"
GuildData.GuildListChange        = "guild_list_change"
GuildData.JoinReqListChange      = "join_req_list_change"
GuildData.MemberListChange       = "member_list_change"
GuildData.SearchMemberListChange = "search_member_list_change"
GuildData.UpdataGuildList        = "updata_guild_list"
GuildData.StorageListChange      = "storage_list_change"
GuildData.EventListChange        = "event_list_change"
GuildData.RedEnvelopeChange      = "red_envelope_change"
GuildData.HaveGuildStateChange   = "have_guild_statechange"
GuildData.GuildOffer 			 = "guild_offer"
GuildData.GUILD_IMPEACH 		 = "guild_impeach"

-- 角色数据变化
function GuildData:RoleDataChangeCallBack(vo)
	if vo.key == OBJ_ATTR.ACTOR_GUILD_CON then
		self:DispatchEvent(GuildData.StorageListChange)
	end
	if vo.key == OBJ_ATTR.ACTOR_GUILD_ID then
		self:DispatchEvent(GuildData.HaveGuildStateChange)
	end
end

function GuildData:HaveGuild()
	return RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID) > 0
end

-- 初始化行会信息
function GuildData:InitGuildData()
	self.guild_info = self.CreateGuildInfo()
	self.guild_list = self.guild_list or {}
	self.events_list = {}
	self.red_envelope_info = {
		sender_name = "",			-- 发送者名字
		hb_total_gold = 0,			-- 红包总元宝
		hb_total_num = 0,			-- 红包总数量
		left_hb_num = 0,			-- 红包剩余数量
		left_hb_gold = 0,			-- 红包剩余元宝
		left_time = 0,				-- 领取剩余时间
		receive_member_num = 0,		-- 已领取红包的人数
		get_data_client_time = 0,
	}
	self.all_hb_rec_info = {}
	self.red_envelope_list = {}	--弃用
	self.join_req_list = {}
	self.member_list = {}
	self.member_list_without_me = {}
	self.search_member_list = {}
	self.storage_list = {}
	self.guild_bag_list = {}
	self.guild_league_req_t ={}
	self.call_guild_member_t ={}
	self.guild_invite_t = {}
	self.guild_hb_record_list = {}
	self.offer_score = 0
	self.item_rew = {}
	self.task_list = {}
	self:SetGuildMemberList()
end

function GuildData.CreateGuildInfo()
	return {
		guild_rank = 0,
		self_position = SOCIAL_MASK_DEF.GUILD_COMMON,
		leader_role_id = 0,
		guild_name = "",
		leader_name = "",
		founder_name = "",
		private_affiche = Language.Guild.Nothing,
		public_affiche = "",
		guild_max_level = 0,
		max_member_num = 0,
		cur_member_num = 0,
		today_donate_val = 0,
		guild_bankroll = 0,
		guild_QQ_id = "",
		voice_channel_type = 0,
		voice_channel_id = "",
		voice_channel_declaration = "",
		guild_join_handle = 0,
		guild_title_id = 0,
		guild_affiche = "",
		contribution = 0,
		today_donate_ybval = 0,
		cur_guild_level = 0,
		guild_exp = 0,
		personal_guild_integral =0 ,
		personal_guild_integral_rank = 0,
		guild_flag_level = 0,
		guild_flag_exp = 0,
		collect_times = 0,
		exorcism_times = 0,
		transportation_times = 0,
	}
end

-- 获取行会成员列表
function GuildData:GetGuildMemberList()
	return self.member_list
end

-- 获取行会成员列表（不包含自己）
function GuildData:GetGuildMemberListWithoutMe()
	return self.member_list_without_me
end

-- 设置行会成员总列表
function GuildData:SetGuildMemberList(list)
	self.member_list = list or {}
	self:SortGuildMemberList()
	self:SetGuildMemberListWithoutMe()
	GlobalEventSystem:Fire(OtherEventType.GUILDMEMBER_CHANGE)
	self:DispatchEvent(GuildData.MemberListChange)
end

function GuildData:SortGuildMemberList()
	if next(self.member_list) then
		table.sort(self.member_list, GuildData.SortGuildMemberFunc())
	end
end

function GuildData.SortGuildMemberFunc()
	return function(a, b)
		local order_a = 100000
		local order_b = 100000

		if a["is_online"] == 1 then
			order_a = order_a + 10000
		end
		if  b["is_online"] == 1 then
			order_b = order_b + 10000
		end

		if a["is_online"] == 1 and b["is_online"] == 1 then
			if a["position"] > b["position"] then
				order_a = order_a + 1000
			elseif a["position"] < b["position"] then
				order_b = order_b + 1000
			end
		end

		if a["is_online"] ~= 1 and b["is_online"] ~= 1 then
			if a["login_time"] > b["login_time"] then
				order_a = order_a + 1000
			elseif a["login_time"] < b["login_time"] then
				order_b = order_b + 1000
			end
		end

		if a["capacity"] > b["capacity"] then
			order_a = order_a + 100
		elseif a["capacity"] < b["capacity"] then
			order_b = order_b + 100
		end

		return order_a > order_b
	end
end

function GuildData:SetGuildMemberListWithoutMe()
	self.member_list_without_me = {}
	for i,v in ipairs(self.member_list) do
		if v.role_id ~= RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID) then
			table.insert(self.member_list_without_me, v)
		end
	end
end

-- 行会成员列表 添加/删除 成员
function GuildData:ChangeGuildMemberList(protocol)
	if protocol.opt_type == 1 then			--1添加成员
		table.insert(self.member_list, protocol.data)
	elseif protocol.opt_type == 2 then		--2删除成员
		local del_member_key = nil
		for i,v in ipairs(self.member_list) do
			if v.role_id == protocol.data.role_id then
				del_member_key = i
			end
		end
		if del_member_key then
			table.remove(self.member_list, del_member_key)
		end
	end

	self:SortGuildMemberList()
	self:SetGuildMemberListWithoutMe()
	GlobalEventSystem:Fire(OtherEventType.GUILDMEMBER_CHANGE)
	self:DispatchEvent(GuildData.MemberListChange)
end

-- 行会成员列表成员信息改变
function GuildData:FlushGuildMemberInfo(protocol)
	for i,v in ipairs(self.member_list) do
		if v.role_id == protocol.role_id then
			v.is_online = protocol.is_online
			v.level = protocol.level
			v.contribution = protocol.contribution
			v.position = protocol.position
			if v.is_online == 0 then
				v.login_time = TimeCtrl.Instance:GetServerTime()
			end

			self:SortGuildMemberList()
			self:SetGuildMemberListWithoutMe()
			GlobalEventSystem:Fire(OtherEventType.GUILDMEMBER_CHANGE)
			return
		end
	end
	self:DispatchEvent(GuildData.MemberListChange)
end

-- 行会成员列表成员职位改变
function GuildData:FlushGuildMemberPosition(protocol)
	for i,v in ipairs(self.member_list) do
		if v.role_id == protocol.role_id then
			v.position = protocol.position
			return
		end
	end
	self:DispatchEvent(GuildData.MemberListChange)
end

-- 设置行会列表
function GuildData:SetGuildList(protocol)
	self.guild_list = protocol.list
	self:DispatchEvent(GuildData.GuildListChange)
end

-- 更新行会列表
function GuildData:UpdateGuildList(protocol)
	for i,v in ipairs(self.guild_list) do
		for i_2,v_2 in ipairs(protocol.on_war_list) do
			if v.guild_name == v_2.guild_name then
				v.relationship = v_2.relationship
				v.war_left_time = v_2.war_left_time
			end
		end
	end
	self:DispatchEvent(GuildData.UpdataGuildList)
end

function GuildData:GetGuildRelationship(guild_name)
	local i, j = 0, 0
	for loop_count = 1, 100 do
		local i1, j1 = string.find(guild_name, "(%[.-%])", j + 1)
		if nil == i1 or nil == j1 then
			break
		end 
		i, j = i1, j1
	end
	if j == #guild_name then
		guild_name = string.sub(guild_name, 0, i - 1)
	end

	for i,v in ipairs(self.guild_list) do
		if guild_name == v.guild_name then
			return v.relationship or GUILD_RELATIONSHIP.NULL 
		end
	end
	return GUILD_RELATIONSHIP.NULL
end

function GuildData:HasEnemyGuild()
	for i,v in ipairs(self.guild_list) do
		if v.relationship == GUILD_RELATIONSHIP.ENEMY then
			return true
		end
	end
	return false
end

-- 主动刷新行会列表宣战时间
function GuildData:FlushWarTime(change_num)
	local is_in_war = false
	for k,v in pairs(self.guild_list) do
		v.war_left_time = v.war_left_time + change_num
		if not is_in_war and v.war_left_time > 0 then
			is_in_war = true
		end
	end
	return is_in_war
end

-- 设置行会事件数据
function GuildData:SetEventsList(list)
	-- if self.events_list ~= list then
		self.events_list = list
		table.sort(self.events_list, function(a, b)
			return a.time > b.time
		end)
		self:DispatchEvent(GuildData.EventListChange)
	-- end
end

-- 设置行会红包数据
function GuildData:SetRedEnvelopeInfo(protocol)
	self.red_envelope_info.sender_name = protocol.sender_name
	self.red_envelope_info.hb_total_gold = protocol.money
	self.red_envelope_info.hb_total_num = protocol.total_num
	self.red_envelope_info.left_time = protocol.left_time
	self.red_envelope_info.get_data_client_time = protocol.get_data_client_time
	self.red_envelope_info.left_hb_gold = protocol.left_money
	self.red_envelope_info.receive_member_num = protocol.receive_member_num
	self.red_envelope_info.left_hb_num = protocol.total_num - protocol.receive_member_num
	self:SetEnvelopeRecordList(protocol.receive_list)
end

function GuildData:SetGuildHbRecInfo(protocol)
	self.red_envelope_info.sender_name = protocol.sent_name
	self.red_envelope_info.hb_total_num = protocol.hb_num
	self.red_envelope_info.receive_member_num = protocol.rec_hb_role_num
	self.red_envelope_info.left_hb_num = protocol.hb_num - protocol.rec_hb_role_num
	self.all_hb_rec_info = protocol.all_hb_rec_info
	self:UpdateGuildHbRecordInfo()
	self:DispatchEvent(GuildData.RedEnvelopeChange)
end

function GuildData:SetGuildHbResult(protocol)
	self.red_envelope_info.sender_name = protocol.sender_name
	self.red_envelope_info.left_hb_num = protocol.left_num
	self.red_envelope_info.left_time = protocol.left_time
	self.red_envelope_info.get_data_client_time = protocol.get_data_client_time
	self.red_envelope_info.hb_total_gold = protocol.total_gold_num
	self.all_hb_rec_info = protocol.rec_hb_list
	self:UpdateGuildHbRecordInfo()
	self:DispatchEvent(GuildData.RedEnvelopeChange)
end

-- 更新行会红包记录信息
function GuildData:UpdateGuildHbRecordInfo()
	self.guild_hb_record_list = {}
	local sender_info = {role_name = self.red_envelope_info.sender_name, sent_hb_gold = self.red_envelope_info.hb_total_gold, rec_hb_gold = 0}
	table.insert(self.guild_hb_record_list, sender_info)
	for k, v in pairs(self.all_hb_rec_info) do
		local rec_info = {role_name = v.name, sent_hb_gold = 0, rec_hb_gold = v.gold_num}
		table.insert(self.guild_hb_record_list, rec_info)
	end
end

-- 行会红包记录列表
function GuildData:GetGuildHbRecordList()
	return self.guild_hb_record_list
end

-- 设置行会详细信息
function GuildData:SetGuildInfo(protocol)
	if nil ~= protocol.info and nil ~= self.guild_info then
		if protocol.info.cur_guild_level ~= self.guild_info.cur_guild_level then
			GlobalEventSystem:Fire(OtherEventType.GUILDLEVEL_CHANGE, protocol.info.cur_guild_level)
		end
	end
	self.guild_info = next(protocol.info) and protocol.info or self.CreateGuildInfo()
	self.guild_info.is_join_guild = protocol.is_join_guild
	self:SetJoinHandleResult(self.guild_info.guild_join_handle)
	self:DispatchEvent(GuildData.GuildInfoChange)
end

-- 设置红包记录列表
function GuildData:SetEnvelopeRecordList(list)
	self.red_envelope_list = list
end

-- 设置申请加入行会列表
function GuildData:SetJoinReqList(list)
	if self.join_req_list ~= list then
		self.join_req_list = list
		self:DispatchEvent(GuildData.JoinReqListChange)
	end
end

-- 设置搜索符合邀请的玩家列表
function GuildData:SetSearchMemberList(list)
	if self.search_member_list ~= list then
		self.search_member_list = list
		self:DispatchEvent(GuildData.SearchMemberListChange)
	end
end

-- 设置行会仓库所有物品数据
function GuildData:SetGuildStorageList(list)
	if self.storage_list ~= list then
		self.storage_list = list
		self:SortStorageList()
		self:DispatchEvent(GuildData.StorageListChange)
	end
end

function GuildData:SortStorageList()
	local function sort_baglist()
		return function(a, b)
			if a.type and a.type ~= b.type then
				return a.type < b.type
			elseif a.item_id ~= b.item_id then
				return a.item_id > b.item_id
			elseif a.num ~= b.num then
				return a.num < b.num
			else
				return a.is_bind < b.is_bind
			end
		end
	end

	table.sort(self.storage_list, sort_baglist())
end

-- 获取搜索符合邀请的玩家列表
function GuildData:GetSearchMemberList()
	return self.search_member_list
end

-- 获取行会事件数据
function GuildData:GetEventsList()
	return self.events_list
end

-- 获取行会列表
function GuildData:GetGuildList()
	return self.guild_list
end

-- 获取行会详细信息
function GuildData:GetGuildInfo()
	return self.guild_info
end

-- 获取自己行会名称
function GuildData:GetGuildName()
	return self.guild_info.guild_name
end

-- 获取行会抢红包信息
function GuildData:GetRedEnvelopeInfo()
	return self.red_envelope_info
end

-- 获取行会抢红包记录列表
function GuildData:GetEnvelopeRecordList()
	return self.red_envelope_list
end

-- 获取申请加入列表
function GuildData:GetJoinReqList()
	return self.join_req_list
end

-- 获取行会仓库列表
function GuildData:GetStorageList()
	return self.storage_list
end

-- 行会关系String
function GuildData.GetGuildRelationshipText(key)
	return Language.Guild.Relationship[key] or "--"
end

-- 行会职位String
function GuildData:GetGuildPosition(key)
	return Language.Guild.PositionName[key] or ""
end

-- 获取行会等级配置
function GuildData.GetGuildLevelCfgBylevel(level)
	return GuildConfig.guildLevel[level]
end

-- 获取行会等级配置
function GuildData.GetGuildMaxDepotBagCount(level)
	return GuildConfig.guildLevel[level] and GuildConfig.guildLevel[level].maxDepotBagCount or 1
end

-- 行会红包剩余时间(实时)
function GuildData:GetRedEnvelopeLeftTime()
	local left_time = self.red_envelope_info.left_time - (NOW_TIME - self.red_envelope_info.get_data_client_time)
	if left_time < 0 then
		left_time = 0
	end

	return left_time
end

-- 获取行会下一级所需总经验
function GuildData:GetGuildNextLevelNeedExp()
	local cur_level = self.guild_info.cur_guild_level
	if self.GetGuildLevelCfgBylevel(cur_level) then
		return self.GetGuildLevelCfgBylevel(cur_level).needExp
	end

	return 0
end

-- 判断是否可编辑公告
function GuildData:IsCanEditAffiche()
	local jurisdiction = false
	if RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_LEADER)
		or RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_ASSIST_LEADER) then
		jurisdiction = true
	end
	return jurisdiction
end

-- 行会总配置
function GuildData.GetGuildCfg()
	return GuildConfig
end

-- 获取角色当前行会职位索引
function GuildData.GetSelfGuildPosition()
	for i = SOCIAL_MASK_DEF.GUILD_COMMON, SOCIAL_MASK_DEF.GUILD_LEADER do
		if RoleData.Instance:IsSocialMask(i) then
			return i
		end
	end
	return nil
end

-- 根据等级获取行会战旗配置
function GuildData.GetGuildFlagCfg(level)
	level = level or GUILD_FLAG_CFG.INIT_LEVEL
	local cfg = GuildData.GetGuildCfg().GuildFlagBufs
	local mexLevel = #cfg
	level = level > GUILD_FLAG_CFG.INIT_LEVEL and level or GUILD_FLAG_CFG.INIT_LEVEL
	level = level < mexLevel and level or mexLevel

	return cfg[level]
end

-- 获取当前行会战旗等级
function GuildData:GetGuildFlagLevel()
	return GUILD_FLAG_CFG.INIT_LEVEL + math.floor((self.guild_info.cur_guild_level - 1) / GUILD_FLAG_CFG.LEVEL_UP_STEP)
end

-- 根据战旗等级获取战旗资源id
function GuildData.GetGuildFlagShowId(level)
	level = level or GUILD_FLAG_CFG.INIT_LEVEL
	return GuildData.GetGuildCfg().global.GuildFlagModelIdBegin + level - 1
end

-- 获取背包可捐献的所有装备
function GuildData:GetDonateEquipList()
	local bag_list = BagData.Instance:GetItemDataList()
	self.guild_bag_list = {}
	local order = 0
	for k,v in pairs(bag_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			if v.is_bind ~= 1 then
				if item_cfg.contri > 0 then
					self.guild_bag_list[order] = v
					order = order + 1
				end
			end
		else
			return self.guild_bag_list
		end
	end
	return self.guild_bag_list
end

function GuildData:AddGuildLeague(info)
	local data = {}
	data.guild_id = info.guild_id
	data.role_id = info.role_id
	data.guild_name = info.guild_name
	data.role_name = info.role_name
	data.cur_member_num = info.cur_member_num
	data.max_member_num = info.max_member_num
	table.insert(self.guild_league_req_t, data)
end

function GuildData:GetGuildLeagueList()
	return self.guild_league_req_t
end

function GuildData:AddCallGuildMember(info)
	local data = {}
	data.call_type = info.call_type
	data.role_name = info.role_name
	data.scene_id = info.scene_id
	data.scene_name = info.scene_name
	data.x = info.x
	data.y = info.y
	table.insert(self.call_guild_member_t, data)
end

function GuildData:GetCallGuildMemberList()
	return self.call_guild_member_t
end

function GuildData:AddGuildInvite(info)
	local data = {}
	data.guild_id = info.guild_id
	data.obj_id = info.obj_id
	data.guild_name = info.guild_name
	data.role_name = info.role_name
	data.cur_member_num = info.cur_member_num
	data.guild_total_num = info.guild_total_num
	table.insert(self.guild_invite_t, data)
end

function GuildData:GetGuildInviteList()
	return self.guild_invite_t
end

function GuildData:GetGuildRedEnvelopeNum()
	local num = 0
	if 0 < self.red_envelope_info.left_hb_num 
		and 0 < self:GetRedEnvelopeLeftTime() then
		num = 1
	end

	return num
end

function GuildData:SetJoinHandleResult(result)
	if self.joinhanleresult ~= result then
		self.joinhanleresult = result
		self:DispatchEvent(GuildData.JoinReqListChange)
	end
end

function GuildData:GetJoinHandleResult()
	return self.joinhanleresult
end

-------------------行会悬赏---------------------------
function GuildData:SetGuildOfferResult(protocol)
	self.offer_score = protocol.score
	self.item_rew = bit:d2b(protocol.rew_sign)
	self.task_list = protocol.task_list
	
	self:DispatchEvent(GuildData.GuildOffer)
end

local offer_cfg = {
	[1] = {view_def = ViewDef.Guild.GuildView.GuildBuild, npc_id = nil, boss_cfg = nil},
	[2] = {view_def = ViewDef.NewlyBossView, npc_id = nil, boss_cfg = nil},
	[3] = {view_def = ViewDef.Shop.Bind_yuan, npc_id = nil, boss_cfg = nil},
	[4] = {view_def = ViewDef.Explore, npc_id = nil, boss_cfg = nil},
	[5] = {view_def = ViewDef.Shop.Prop, npc_id = nil, boss_cfg = nil},
	[6] = {view_def = ViewDef.ZsVip.Recharge, npc_id = nil, boss_cfg = nil},
	[7] = {view_def = nil, npc_id = nil, boss_cfg = {type = 15, boss_id = 1786},},
	[8] = {view_def = nil, npc_id = nil, boss_cfg = nil},
	[9] = {view_def = ViewDef.DiamondPet, npc_id = nil, boss_cfg = nil},
	[10] = {view_def = nil, npc_id = 20, boss_cfg = nil},
}

function GuildData:SetOfferTaskData()
	local data = {}
	local cfg = GuildRewardCfg.tasks
	for k, v in pairs(self.task_list) do
		local vo = {
			task_id = v.task_id,
			task_state = v.task_state,
			complete_num = v.complete_num,
			is_reward = v.is_reward,
			desc = cfg[v.task_id].desc,
			btn_days = cfg[v.task_id].onkeyFinish.opendays,
			max_num = cfg[v.task_id].condition[1],
			get_score = cfg[v.task_id].integral,
			quick_com = cfg[v.task_id].onkeyFinish.consumes[1],
			reward = cfg[v.task_id].awards,
			open_btn = offer_cfg[v.task_id],
		}
		table.insert(data, vo)
	end
	-- print("======task_list=====")
	return data
end

function GuildData:GetOfferScore()
	return self.offer_score, self.item_rew
end

-- 获取行会悬赏是够显示红点
function GuildData:GetOfferRemind()
	local num = 0

	local offer_score, item_rew = GuildData.Instance:GetOfferScore()
	local cfg = GuildRewardCfg or {}
	local integral_awards = cfg.integralawards or {}
	for i,v in ipairs(integral_awards) do
		if offer_score >= v.integral and item_rew[33 - i] == 0 then
			num = 1
			break
		end
	end

	if num < 1 then
		for k1, v1 in pairs(GuildData.Instance:SetOfferTaskData()) do
			if v1.task_state == 2 and v1.is_reward == 0 then
				num = 1
				break
			end
		end
	end

	return num
end

-- 获取需要显示的任务
function GuildData:GetShowTask()
	local task_data
	for k,v in pairs(self:SetOfferTaskData()) do
		if v.task_state == 2 and v.is_reward == 0 then
			task_data = v
			break
		elseif v.task_state == 1 then
			task_data = v
			break
		end
	end

	return task_data
end

-- 所有任务是否做完
function GuildData:GetAllTaskState()
	local is_com = 0
	for k,v in pairs(GuildData.Instance:SetOfferTaskData()) do
		if v.task_state ~= 2 or (v.task_state == 2 and v.is_reward == 0) then
			is_com = 1
		end
		break
	end
	return is_com
end

------------------------------------------------------------
-- 行会弹劾
------------------------------------------------------------

-- 设置行会弹劾数据
-- key = 0-会长本次的登录时间 1-会长上次的下线时间 2-弹劾开始时间  3-上次弹劾结束时间  4-发起弹劾玩家id  5-赞成票数  6-反对票数
function GuildData:SetGuildImpeachInfo(protocol)
	self.guild_impeach_info = self.guild_impeach_info or {}
	self.guild_impeach_info = protocol.info
	for key, value in pairs(protocol.info) do
		self.guild_impeach_info[key] = value
	end
	self:DispatchEvent(GuildData.GUILD_IMPEACH)
end

-- 获取行会弹劾数据
function GuildData:GetGuildImpeachInfo()
	return self.guild_impeach_info or {}
end

-- 设置玩家投票数据
function GuildData:SetGuildImpeachVote(protocol)
	self.guild_impeach_vote = protocol.vote
	self:DispatchEvent(GuildData.GUILD_IMPEACH)
end

-- 获取玩家投票数据
function GuildData:GetGuildImpeachVote()
	return self.guild_impeach_vote or 0
end

-- 获取弹劾剩余时间
function GuildData.GetGuildImpeachLeftTimes()
	local server_time_offset = COMMON_CONSTS.SERVER_TIME_OFFSET
	local global = GuildConfig and GuildConfig.global or {}

	 -- key = 0-会长本次的登录时间 1-会长上次的下线时间 2-弹劾开始时间  3-上次弹劾结束时间  4-发起弹劾玩家id  5-赞成票数  6-反对票数
	local impeach_info = GuildData.Instance:GetGuildImpeachInfo()
	local impeach_start_times = impeach_info[2] or 0
	local impeach_left_times = impeach_start_times + server_time_offset + global.uImpeachmentTime - os.time()

	return math.max(impeach_left_times, 0)
end