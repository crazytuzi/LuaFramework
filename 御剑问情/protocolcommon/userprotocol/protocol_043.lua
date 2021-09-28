--公会Boss红包详细信息
SCGuildBossRedBagInfo =  SCGuildBossRedBagInfo or BaseClass(BaseProtocolStruct)
function SCGuildBossRedBagInfo:__init()
	self.msg_type = 4300
end

function SCGuildBossRedBagInfo:Decode()
	self.total_gold_num = MsgAdapter.ReadInt()
	self.creater_uid = MsgAdapter.ReadInt()
	self.creater_name = MsgAdapter.ReadStrN(32)
	self.avatar_key_big = MsgAdapter.ReadInt()
	self.avatar_key_small = MsgAdapter.ReadInt()
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.creater_guild_id = MsgAdapter.ReadInt()
	self.creater_guild_name = MsgAdapter.ReadStrN(32)
	self.fetch_user_count = MsgAdapter.ReadInt()
	self.log_list = {}
	for i = 1, self.fetch_user_count do
		self.log_list[i] = {}
		self.log_list[i].uid = MsgAdapter.ReadInt()
		self.log_list[i].gold_num = MsgAdapter.ReadInt()
		self.log_list[i].name = MsgAdapter.ReadStrN(32)
	end
	local index = 0
	local gold = 0
	for k,v in pairs(self.log_list) do
		if gold < v.gold_num then
			gold = v.gold_num
			index = k
		end
	end
	if index > 0 then
		self.log_list[index].is_luck = true
	end
end

--  公会抛骰子
SCGulidSaiziInfo =  SCGulidSaiziInfo or BaseClass(BaseProtocolStruct)
function SCGulidSaiziInfo:__init()
	self.msg_type = 4301
end

function SCGulidSaiziInfo:Decode()
 	self.today_guild_pao_saizi_times = MsgAdapter.ReadInt() --每天公会抛骰子次数
 	self.today_last_guild_pao_saizi_time = MsgAdapter.ReadLL()  -- 最后一次抛骰子时间
 	self.today_guild_saizi_score = MsgAdapter.ReadInt() -- 每天骰子积分
 	self.pao_saizi_num = MsgAdapter.ReadInt() -- 抛到什么分数
 	self.guild_saizi_rank_list = {}  -- 排行信息
 	for i = 1,GUILD_PAWN.MAX_MEMBER_COUNT do
 		self.guild_saizi_rank_list[i] = {}
		self.guild_saizi_rank_list[i].uid = MsgAdapter.ReadInt()
		self.guild_saizi_rank_list[i].score = MsgAdapter.ReadInt()
		self.guild_saizi_rank_list[i].name = MsgAdapter.ReadStrN(32)
 	end
end



-- 公会抛骰子
CSGulidPaoSaizi = CSGulidPaoSaizi or BaseClass(BaseProtocolStruct)
function CSGulidPaoSaizi:__init()
	self.msg_type = 4302
end

function CSGulidPaoSaizi:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

end

-- 公会请求信息
CSReqGulidSaiziInfo = CSReqGulidSaiziInfo or BaseClass(BaseProtocolStruct)
function CSReqGulidSaiziInfo:__init()
	self.msg_type = 4303
end

function CSReqGulidSaiziInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 公会请求信息
CSGuildSetAutoClearReq = CSGuildSetAutoClearReq or BaseClass(BaseProtocolStruct)
function CSGuildSetAutoClearReq:__init()
	self.msg_type = 4304
end

function CSGuildSetAutoClearReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_auto_clear)
	MsgAdapter.WriteShort(self.reserve)
end


---------公会活跃活动

SCGuildTianCiTongBiResult =  SCGuildTianCiTongBiResult or BaseClass(BaseProtocolStruct)
function SCGuildTianCiTongBiResult:__init()
	self.msg_type = 4305
end

function SCGuildTianCiTongBiResult:Decode()
 	self.gather_count_list = {}
 	self.reward_item_id = 90002					-- 服务器说写死
 	self.reward_item_num = MsgAdapter.ReadInt()
 	self.reward_id_bigcoin = 65533				-- 服务器说写死
 	self.reward_num_bigcoin = MsgAdapter.ReadInt()
 	self.rank_pos = MsgAdapter.ReadInt()
 	for i = 1, 3 do
 		self.gather_count_list[i] = MsgAdapter.ReadInt()
 	end
end

SCGuildSyncTianCiTongBi = SCGuildSyncTianCiTongBi or BaseClass(BaseProtocolStruct)
function SCGuildSyncTianCiTongBi:__init()
	self.msg_type = 4306
end

function SCGuildSyncTianCiTongBi:Decode()
	self.guild_id = MsgAdapter.ReadInt()
	self.is_open = MsgAdapter.ReadInt()
end

SCGuildTianCiTongBiNotice =  SCGuildTianCiTongBiNotice or BaseClass(BaseProtocolStruct)
function SCGuildTianCiTongBiNotice:__init()
	self.msg_type = 4307
end

function SCGuildTianCiTongBiNotice:Decode()
 	self.notice_reason = MsgAdapter.ReadInt()
end

SCGuildTianCiTongBiUserGatherChange =  SCGuildTianCiTongBiUserGatherChange or BaseClass(BaseProtocolStruct)
function SCGuildTianCiTongBiUserGatherChange:__init()
	self.msg_type = 4308
end

function SCGuildTianCiTongBiUserGatherChange:Decode()
 	self.gather_type = MsgAdapter.ReadInt()
 	self.gather_num = MsgAdapter.ReadInt()
 	self.tianci_tongbi_tree_maturity_degree = MsgAdapter.ReadInt()
 	self.tianci_tongbi_max_gather_num = MsgAdapter.ReadInt()
 	self.tianci_tongbi_tree_max_maturity_degree = MsgAdapter.ReadInt()
end

SCGuildTianCiTongBiRankInfo =  SCGuildTianCiTongBiRankInfo or BaseClass(BaseProtocolStruct)
function SCGuildTianCiTongBiRankInfo:__init()
	self.msg_type = 4309
end

function SCGuildTianCiTongBiRankInfo:Decode()
	self.rank_item_list = {}
 	self.tianci_tongbi_close_time = MsgAdapter.ReadUInt()
 	self.rank_count = MsgAdapter.ReadShort()
 	self.gather_type = MsgAdapter.ReadShort()

 	for i = 1, self.rank_count do
		local data = {}
		data.uid = MsgAdapter.ReadInt()
		data.user_name = MsgAdapter.ReadStrN(32)
		data.longhun = MsgAdapter.ReadInt()
		data.coin_bind = MsgAdapter.ReadInt()
		data.rank_info = MsgAdapter.ReadInt()
		self.rank_item_list[i] = data
	end
end

CSGuildTianCiTongBiReq = CSGuildTianCiTongBiReq or BaseClass(BaseProtocolStruct)
function CSGuildTianCiTongBiReq:__init()
	self.msg_type = 4320
	self.guild_id = 0
	self.role_id = 0
end

function CSGuildTianCiTongBiReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.role_id)
end

CSGuildTianCiTongBiUseGather = CSGuildTianCiTongBiUseGather or BaseClass(BaseProtocolStruct)
function CSGuildTianCiTongBiUseGather:__init()
	self.msg_type = 4321
end

function CSGuildTianCiTongBiUseGather:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


SCGuildTianCiTongBiNpcinfo = SCGuildTianCiTongBiNpcinfo or BaseClass(BaseProtocolStruct)
function SCGuildTianCiTongBiNpcinfo:__init()
	self.msg_type = 4322
end

function SCGuildTianCiTongBiNpcinfo:Decode()
 	self.npc_x = MsgAdapter.ReadInt()
 	self.npc_y = MsgAdapter.ReadInt()
 	self.tianci_tongbi_readiness_time = MsgAdapter.ReadInt()
end

SCGuildBonfireNextSkillPerformTime = SCGuildBonfireNextSkillPerformTime or BaseClass(BaseProtocolStruct)
function SCGuildBonfireNextSkillPerformTime:__init()
	self.msg_type = 4323
end

function SCGuildBonfireNextSkillPerformTime:Decode()
 	self.next_add_mucai_time = MsgAdapter.ReadUInt()
 	self.next_gather_time = MsgAdapter.ReadUInt()
end

-- 仙盟篝火加木材次数
SCGuildBonfireMucaiTimes = SCGuildBonfireMucaiTimes or BaseClass(BaseProtocolStruct)
function SCGuildBonfireMucaiTimes:__init()
	self.msg_type = 4324
end

function SCGuildBonfireMucaiTimes:Decode()
 	self.obj_id = MsgAdapter.ReadUShort()
 	self.add_mucai_times = MsgAdapter.ReadShort()
end