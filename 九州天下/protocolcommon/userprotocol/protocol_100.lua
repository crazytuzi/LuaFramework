-- 请求个人排行返回
SCGetPersonRankListAck = SCGetPersonRankListAck or BaseClass(BaseProtocolStruct)
function SCGetPersonRankListAck:__init()
	self.msg_type = 10000
	self.last_snapshot_time = 0
	self.rank_type = 0
	self.rank_list = {}
end

function SCGetPersonRankListAck:Decode()
	self.last_snapshot_time = MsgAdapter.ReadUInt()
	self.rank_type = MsgAdapter.ReadInt()

	local count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, count do
		local rank_info = {}
		rank_info.user_id = MsgAdapter.ReadInt()
		rank_info.user_name = MsgAdapter.ReadStrN(32)
		rank_info.flexible_name = MsgAdapter.ReadStrN(32)
		rank_info.reserve = MsgAdapter.ReadChar()
		rank_info.sex = MsgAdapter.ReadChar()
		rank_info.prof = MsgAdapter.ReadChar()
		rank_info.camp = MsgAdapter.ReadChar()
		rank_info.vip_level = MsgAdapter.ReadChar()
		rank_info.reserved1 = MsgAdapter.ReadChar()
		rank_info.record_index = MsgAdapter.ReadShort()
		rank_info.exp = MsgAdapter.ReadLL()
		rank_info.level = MsgAdapter.ReadInt()
		rank_info.rank_value = MsgAdapter.ReadLL()
		rank_info.flexible_int= MsgAdapter.ReadInt()     	  --精灵榜时表示 精灵幻化id
		rank_info.flexible_ll = MsgAdapter.ReadLL()		 	  --精灵榜时表示 精灵id
		rank_info.avatar_key_big = MsgAdapter.ReadUInt()
		rank_info.avatar_key_small = MsgAdapter.ReadUInt()
		table.insert(self.rank_list, rank_info)
	end
end



-- 仙盟排行返回
SCGetGuildRankListAck = SCGetGuildRankListAck or BaseClass(BaseProtocolStruct)
function SCGetGuildRankListAck:__init()
	self.msg_type = 10001
	self.rank_type = 0
	self.rank_list = {}
end

function SCGetGuildRankListAck:Decode()
	-- self.rank_type = MsgAdapter.ReadInt()
	-- local count = MsgAdapter.ReadInt()
	-- self.rank_list = {}
	-- for i = 1, count do
	-- 	local rank_info = {}
	-- 	rank_info.guild_id = MsgAdapter.ReadInt()
	-- 	rank_info.guild_name = MsgAdapter.ReadStrN(32)
	-- 	rank_info.tuan_zhang_uid = MsgAdapter.ReadInt()
	-- 	rank_info.tuan_zhang_name = MsgAdapter.ReadStrN(32)
	-- 	rank_info.guild_level = MsgAdapter.ReadShort()
	-- 	rank_info.max_member_count = MsgAdapter.ReadShort()
	-- 	rank_info.camp = MsgAdapter.ReadShort()
	-- 	rank_info.member_count = MsgAdapter.ReadShort()

	-- 	if self.rank_type == GuildRankType.Guild then
	-- 		rank_info.crate_time = MsgAdapter.ReadUInt()
	-- 		rank_info.member_count = MsgAdapter.ReadShort()
	-- 		rank_info.rank_value = MsgAdapter.ReadShort()
	-- 	elseif self.rank_type == GuildRankType.ZhanLi then
	-- 		rank_info.level = MsgAdapter.ReadInt()
	-- 		rank_info.zhan_li = MsgAdapter.ReadInt()
	-- 	else
	-- 		rank_info.rank_value = MsgAdapter.ReadLL()
	-- 	end

	-- 	table.insert(self.rank_list, rank_info)
	-- end
	self.rank_type = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, count do
		local rank_info = {}
		rank_info.guild_id = MsgAdapter.ReadInt()
		rank_info.guild_name = MsgAdapter.ReadStrN(32)
		rank_info.tuan_zhang_uid = MsgAdapter.ReadInt()
		rank_info.tuan_zhang_capability = MsgAdapter.ReadInt()
		rank_info.tuan_zhang_name = MsgAdapter.ReadStrN(32)
		rank_info.guild_level = MsgAdapter.ReadShort()
		rank_info.max_member_count = MsgAdapter.ReadShort()
		rank_info.camp = MsgAdapter.ReadShort()
		rank_info.member_count = MsgAdapter.ReadShort()

		-- if self.rank_type == GuildRankType.Guild then
			-- rank_info.crate_time = MsgAdapter.ReadUInt()
			-- rank_info.member_count = MsgAdapter.ReadShort()
			-- rank_info.rank_value = MsgAdapter.ReadShort()
		-- elseif self.rank_type == GuildRankType.ZhanLi then
			-- rank_info.level = MsgAdapter.ReadInt()
			-- rank_info.zhan_li = MsgAdapter.ReadInt()
		-- else
			rank_info.rank_value = MsgAdapter.ReadLL()
		-- end
		table.insert(self.rank_list, rank_info)
	end
end

-- 队伍排行返回
SCGetTeamRankListAck = SCGetTeamRankListAck or BaseClass(BaseProtocolStruct)
function SCGetTeamRankListAck:__init()
	self.msg_type = 10002
	self.rank_type = 0
	self.rank_list = {}
end

function SCGetTeamRankListAck:Decode()
	self.rank_type = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		local rank_info = {}
		local member_list = {}
			for j = 1, 5 do
				local member = {}
				member.uid = MsgAdapter.ReadInt()
				member.user_name = MsgAdapter.ReadStrN(32)
				member.camp = MsgAdapter.ReadInt()
				table.insert(member_list, member)
			end
		rank_info.member_list = member_list
		rank_info.rank_value = MsgAdapter.ReadLL()
		rank_info.flexible_int = MsgAdapter.ReadInt()
		rank_info.flexible_ll = MsgAdapter.ReadLL()

		table.insert(self.rank_list, rank_info)
	end
end

-- 顶级玩家信息返回
SCGetPersonRankTopUserAck = SCGetPersonRankTopUserAck or BaseClass(BaseProtocolStruct)
function SCGetPersonRankTopUserAck:__init()
	self.msg_type = 10003
	self.rank_type = 0
	self.user_id = 0
	self.user_name =""
	self.sex = 0
	self.prof = 0
	self.camp = 0
	self.reserved = 0
	self.level = 0
	self.rank_value = 0
end

function SCGetPersonRankTopUserAck:Decode()
	self.rank_type = MsgAdapter.ReadInt()
	self.user_id = MsgAdapter.ReadInt()
	self.user_name = MsgAdapter.ReadStrN(32)
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.reserved = MsgAdapter.ReadChar()
	self.level = MsgAdapter.ReadInt()
	self.rank_value = MsgAdapter.ReadLL()
end

-- 世界等级信息返回
SCGetWorldLevelAck = SCGetWorldLevelAck or BaseClass(BaseProtocolStruct)
function SCGetWorldLevelAck:__init()
	self.msg_type = 10004
	self.world_level = 0
	self.top_user_level = 0
end

function SCGetWorldLevelAck:Decode()
	self.world_level = MsgAdapter.ReadInt()
	self.top_user_level = MsgAdapter.ReadInt()
	self.server_level = MsgAdapter.ReadInt()
end

-- 获取角色阵营排行榜
SCGetRoleCampRankListAck = SCGetRoleCampRankListAck or BaseClass(BaseProtocolStruct)
function SCGetRoleCampRankListAck:__init()
	self.msg_type = 10005
end

function SCGetRoleCampRankListAck:Decode()
	self.camp = MsgAdapter.ReadInt()
	self.rank_type = MsgAdapter.ReadInt()
	self.my_rank = MsgAdapter.ReadInt()							-- 自己的排名
	self.my_rank_val = MsgAdapter.ReadInt()						-- 自己的排名数值
	self.ignore_camp_post = MsgAdapter.ReadInt()				-- 是否忽略了官职
	self.count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.user_id = MsgAdapter.ReadInt()
		vo.user_name = MsgAdapter.ReadStrN(32)
		vo.level = MsgAdapter.ReadInt()
		vo.rank_value = MsgAdapter.ReadInt()
		vo.lover_avatar_key_big = MsgAdapter.ReadUInt()
		vo.lover_avatar_key_small = MsgAdapter.ReadUInt()

		self.rank_list[i] = vo
	end
end


-- 婚宴人气排行榜
SCGetCoupleRankListAck = SCGetCoupleRankListAck or BaseClass(BaseProtocolStruct)
function SCGetCoupleRankListAck:__init()
	self.msg_type = 10006
end

function SCGetCoupleRankListAck:Decode()
	self.rank_type = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()				

	self.rank_item_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.uid_1 = MsgAdapter.ReadInt()
		vo.uid_2 = MsgAdapter.ReadInt()
		vo.prof_1 = MsgAdapter.ReadChar()
		vo.prof_2 = MsgAdapter.ReadChar()
		vo.sex_1 = MsgAdapter.ReadChar()
		vo.sex_2 = MsgAdapter.ReadChar()
		vo.avatar_key_big_1 = MsgAdapter.ReadInt()		
		vo.avatar_key_small_1 = MsgAdapter.ReadInt()				
		vo.avatar_key_big_2 = MsgAdapter.ReadInt()						
		vo.avatar_key_small_2 = MsgAdapter.ReadInt()
		vo.rank_value = MsgAdapter.ReadInt()
		vo.name_1 = MsgAdapter.ReadStrN(32)
		vo.name_2 = MsgAdapter.ReadStrN(32)
		self.rank_item_list[i] = vo
	end
end

-- 国家同盟信息
SCGetCampAllianceRankListAck = SCGetCampAllianceRankListAck or BaseClass(BaseProtocolStruct)
function SCGetCampAllianceRankListAck:__init()
	self.msg_type = 10007
end

function SCGetCampAllianceRankListAck:Decode()
	self.rank_list = {}
	for i = 1, 3 do
		local vo = {}
		vo.camp_type = MsgAdapter.ReadInt()						-- 阵营类型
		vo.alliance_camp = MsgAdapter.ReadInt()					-- 同盟阵营
		vo.qiyun_value = MsgAdapter.ReadInt()					-- 昨日气运值
		vo.rank_list = {}
		for i = 1, 5 do
			local _vo = {}
			_vo.user_id = MsgAdapter.ReadInt()
			_vo.user_name = MsgAdapter.ReadStrN(32)
			_vo.level = MsgAdapter.ReadInt()
			_vo.kill_role_num = MsgAdapter.ReadInt()
			_vo.prof = MsgAdapter.ReadShort()
			_vo.sex = MsgAdapter.ReadShort()
			_vo.avatar_key_big = MsgAdapter.ReadUInt()
			_vo.avatar_key_small = MsgAdapter.ReadUInt()
			vo.rank_list[i] = _vo
		end
		self.rank_list[i] = vo
	end
end

-- 请求个人排行
CSGetPersonRankListReq = CSGetPersonRankListReq or BaseClass(BaseProtocolStruct)
function CSGetPersonRankListReq:__init()
	self.msg_type = 10050
	self.rank_type = 0
end

function CSGetPersonRankListReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

--请求军团排行
CSGetGuildRankListReq = CSGetGuildRankListReq or BaseClass(BaseProtocolStruct)
function CSGetGuildRankListReq:__init()
	self.msg_type = 10051
	self.rank_type = 0
end

function CSGetGuildRankListReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

-- 请求队伍排行
CSGetTeamRankListReq = CSGetTeamRankListReq or BaseClass(BaseProtocolStruct)
function CSGetTeamRankListReq:__init()
	self.msg_type = 10052
	self.rank_type = 0
end

function CSGetTeamRankListReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

-- 请求顶级玩家信息
CSGetPersonRankTopUserReq = CSGetPersonRankTopUserReq or BaseClass(BaseProtocolStruct)
function CSGetPersonRankTopUserReq:__init()
	self.msg_type = 10053
	self.rank_type = 0
end

function CSGetPersonRankTopUserReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)
end

-- 请求阵营排行数据
CSGetRoleCampRankList = CSGetRoleCampRankList or BaseClass(BaseProtocolStruct)
function CSGetRoleCampRankList:__init()
	self.msg_type = 10054
	self.rank_type = 0
	self.ignore_camp_post = 0
end

function CSGetRoleCampRankList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.rank_type)				-- 请求排行的类型
	MsgAdapter.WriteInt(self.ignore_camp_post)		-- 是否忽略官职
end

-- 请求婚宴排行榜信息
CSGetCoupleRankList = CSGetCoupleRankList or BaseClass(BaseProtocolStruct)
function CSGetCoupleRankList:__init()
	self.msg_type = 10055
	self.rank_type = 0
end

function CSGetCoupleRankList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.rank_type)		
end