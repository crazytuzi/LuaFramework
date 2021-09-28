local function LoadKillInfo()
	local t = {}
	t.killer_uid = MsgAdapter.ReadInt()
	t.killier_time = MsgAdapter.ReadUInt()
	t.killer_name = MsgAdapter.ReadStrN(32)
	return t
end

local KILLER_LIST_MAX_COUNT = 5
local function LoadBossInfo()
	local t = {}
	t.boss_id = MsgAdapter.ReadInt()
	t.status = MsgAdapter.ReadInt()
	t.killer_info_list = {}
	for i=1,KILLER_LIST_MAX_COUNT do
		t.killer_info_list[i] = LoadKillInfo()
	end
	return t
end

-- 下发击杀世界boss信息
SCWorldBossInfo = SCWorldBossInfo or BaseClass(BaseProtocolStruct)
function SCWorldBossInfo:__init()
	self.msg_type = 10101
	self.next_refresh_time = 0
end

function SCWorldBossInfo:Decode()
	self.next_refresh_time = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()
	self.boss_list = {}
	for i=1, self.count do
		self.boss_list[i] = LoadBossInfo()
	end
end

-- 世界Boss出生
SCWorldBossBorn = SCWorldBossBorn or BaseClass(BaseProtocolStruct)
function SCWorldBossBorn:__init()
	self.msg_type = 10102
end

function SCWorldBossBorn:Decode()

end

-- 返回世界boss个人伤害排名
SCWorldBossSendPersonalHurtInfo = SCWorldBossSendPersonalHurtInfo or BaseClass(BaseProtocolStruct)
function SCWorldBossSendPersonalHurtInfo:__init()
	self.msg_type = 10103
	self.my_hurt = 0
	self.self_rank = 0
	self.rank_count = 0
	self.rank_list = {}
end

function SCWorldBossSendPersonalHurtInfo:Decode()
	self.my_hurt = MsgAdapter.ReadInt()
	self.self_rank = MsgAdapter.ReadInt()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_count = math.min(self.rank_count, COMMON_CONSTS.MAX_BOSS_PERSONAL_DPS_COUNT)
	self.rank_list = {}
	for i = 1, self.rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].uid = MsgAdapter.ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
		self.rank_list[i].hurt = MsgAdapter.ReadInt()
	end
end

-- 返回世界boss公会伤害排名信息
SCWorldBossSendGuildHurtInfo = SCWorldBossSendGuildHurtInfo or BaseClass(BaseProtocolStruct)
function SCWorldBossSendGuildHurtInfo:__init()
	self.msg_type = 10104
	self.my_guild_hurt = 0
	self.my_guild_rank = 0
	self.rank_count = 0
	self.rank_list = {}
end

function SCWorldBossSendGuildHurtInfo:Decode()
	self.my_guild_hurt = MsgAdapter.ReadLL()
	self.my_guild_rank = MsgAdapter.ReadInt()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_count = math.min(self.rank_count, COMMON_CONSTS.MAX_BOSS_GUILD_DPS_COUNT)
	self.rank_list = {}
	for i = 1, self.rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].guild_id = MsgAdapter.ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
		self.rank_list[i].hurt = MsgAdapter.ReadLL()
	end
end

-- 返回世界boss击杀数量周榜排名信息
SCWorldBossWeekRankInfo = SCWorldBossWeekRankInfo or BaseClass(BaseProtocolStruct)
function SCWorldBossWeekRankInfo:__init()
	self.msg_type = 10105
	self.my_guild_kill_count = 0
	self.my_guild_rank = 0
	self.rank_count = 0
end

function SCWorldBossWeekRankInfo:Decode()
	self.my_guild_kill_count = MsgAdapter.ReadShort()
	self.my_guild_rank = MsgAdapter.ReadShort()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, self.rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].guild_id = MsgAdapter.ReadInt()
		self.rank_list[i].guild_name = MsgAdapter.ReadStrN(32)
		self.rank_list[i].guild_kill_count = MsgAdapter.ReadInt()
	end
end

-- 世界boss护盾被击破，通知玩家可摇点
SCWorldBossCanRoll = SCWorldBossCanRoll or BaseClass(BaseProtocolStruct)
function SCWorldBossCanRoll:__init()
	self.msg_type = 10106
	self.boss_id = 0
	self.index = 0
end

function SCWorldBossCanRoll:Decode()
	self.boss_id = MsgAdapter.ReadInt()
	self.index = MsgAdapter.ReadInt()
end

-- 返回玩家摇点点数
SCWorldBossRollInfo = SCWorldBossRollInfo or BaseClass(BaseProtocolStruct)
function SCWorldBossRollInfo:__init()
	self.msg_type = 10107
	self.roll_point = 0
	self.hudun_index = 0
end

function SCWorldBossRollInfo:Decode()
	self.roll_point = MsgAdapter.ReadInt()
	self.hudun_index = MsgAdapter.ReadInt()
end

-- 返回最高点信息
SCWorldBossRollTopPointInfo = SCWorldBossRollTopPointInfo or BaseClass(BaseProtocolStruct)
function SCWorldBossRollTopPointInfo:__init()
	self.msg_type = 10108
	self.boss_id = 0
	self.hudun_index = 0
	self.top_roll_point = 0
	self.top_roll_name = ""
end

function SCWorldBossRollTopPointInfo:Decode()
	self.boss_id = MsgAdapter.ReadInt()
	self.hudun_index = MsgAdapter.ReadInt()
	self.top_roll_point = MsgAdapter.ReadInt()
	self.top_roll_name = MsgAdapter.ReadStrN(32)
end

--boss击杀列表信息
local WORLD_KILLER_LIST_MAX_COUNT = 5
SCWorldBossKillerList = SCWorldBossKillerList or BaseClass(BaseProtocolStruct)
function SCWorldBossKillerList:__init()
	self.msg_type = 10109
	self.killer_info_list = {}
end

function SCWorldBossKillerList:Decode()
	for i=1,WORLD_KILLER_LIST_MAX_COUNT do
		self.killer_info_list[i] = {}
		self.killer_info_list[i].killer_uid = MsgAdapter.ReadInt()
		self.killer_info_list[i].killier_time = MsgAdapter.ReadUInt()
		self.killer_info_list[i].killer_name = MsgAdapter.ReadStrN(32)
	end
end

-- 请求世界boss击杀列表
CSWorldBossKillerInfoReq = CSWorldBossKillerInfoReq or BaseClass(BaseProtocolStruct)
function CSWorldBossKillerInfoReq:__init()
	self.msg_type = 10150
	self.boss_id = 0
end

function CSWorldBossKillerInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.boss_id)
end

-- 请求世界boss信息
CSGetWorldBossInfo = CSGetWorldBossInfo or BaseClass(BaseProtocolStruct)
function CSGetWorldBossInfo:__init()
	self.msg_type = 10151
	self.boss_type = 0 --1：世界boss，2：精英bos
end

function CSGetWorldBossInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.boss_type)
end

-- 世界boss个人伤害排名请求
CSWorldBossPersonalHurtInfoReq = CSWorldBossPersonalHurtInfoReq or BaseClass(BaseProtocolStruct)
function CSWorldBossPersonalHurtInfoReq:__init()
	self.msg_type = 10152
	self.boss_id = 0
end

function CSWorldBossPersonalHurtInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.boss_id)
end

-- 世界boss公会伤害排名请求
CSWorldBossGuildHurtInfoReq = CSWorldBossGuildHurtInfoReq or BaseClass(BaseProtocolStruct)
function CSWorldBossGuildHurtInfoReq:__init()
	self.msg_type = 10153
	self.boss_id = 0
end

function CSWorldBossGuildHurtInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.boss_id)
end

-- 世界boss击杀数量周榜排名请求
CSWorldBossWeekRankInfoReq = CSWorldBossWeekRankInfoReq or BaseClass(BaseProtocolStruct)
function CSWorldBossWeekRankInfoReq:__init()
	self.msg_type = 10154
end

function CSWorldBossWeekRankInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 玩家请求摇点
CSWorldBossRollReq = CSWorldBossRollReq or BaseClass(BaseProtocolStruct)
function CSWorldBossRollReq:__init()
	self.msg_type = 10155
	self.boss_id = 0
	self.index = 0
end

function CSWorldBossRollReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.boss_id)
	MsgAdapter.WriteInt(self.index)
end