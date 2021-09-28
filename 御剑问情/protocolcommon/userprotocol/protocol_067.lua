-- 攻城战全局信息，（广播处理）
SCGCZGlobalInfo =  SCGCZGlobalInfo or BaseClass(BaseProtocolStruct)
function SCGCZGlobalInfo:__init()
	self.msg_type = 6701
end

function SCGCZGlobalInfo:Decode()
	self.is_finish = MsgAdapter.ReadChar()
	self.is_pochen = MsgAdapter.ReadChar()
	self.is_poqiang = MsgAdapter.ReadChar()

	local a = MsgAdapter.ReadChar()

	self.cu_def_guild_time = MsgAdapter.ReadUInt()
	self.shou_guild_id = MsgAdapter.ReadInt()
	self.shou_guild_name = MsgAdapter.ReadStrN(32)
	self.shou_totem_level = MsgAdapter.ReadInt()
	self.po_cheng_times = MsgAdapter.ReadInt()

	self.rank_list = {}

	local rank_count = MsgAdapter.ReadInt()
	if rank_count > 0 then
		for i = 1, rank_count do
			local item = {}
			item.rank = i

			item.guild_id = MsgAdapter.ReadInt()
			item.shouchen_time = MsgAdapter.ReadUInt()
			item.guild_name = MsgAdapter.ReadStrN(32)
			table.insert(self.rank_list, item)
		end
	end
end

-- 攻城战个人信息
SCGCZRoleInfo =  SCGCZRoleInfo or BaseClass(BaseProtocolStruct)
function SCGCZRoleInfo:__init()
	self.msg_type = 6702
end

function SCGCZRoleInfo:Decode()
	self.is_shousite = MsgAdapter.ReadChar()
	self.sos_times = MsgAdapter.ReadChar()
	local a = MsgAdapter.ReadShort()
	self.zhangong = MsgAdapter.ReadInt()

	self.rank_list = {}

	local rank_count = MsgAdapter.ReadInt()
	if rank_count > 0 then
		for i = 1, rank_count do
			local item = {}
			item.rank = i
			item.id = MsgAdapter.ReadInt()
			item.name = MsgAdapter.ReadStrN(32)
			item.zhangong = MsgAdapter.ReadInt()
			table.insert(self.rank_list, item)
		end
	end
end
-- 攻城战结算
SCGCZRewardInfo =  SCGCZRewardInfo or BaseClass(BaseProtocolStruct)
function SCGCZRewardInfo:__init()
	self.msg_type = 6703
end

function SCGCZRewardInfo:Decode()
	self.gongxun = MsgAdapter.ReadInt()
	self.gold_reward = MsgAdapter.ReadInt()
	self.shengwang_reward = MsgAdapter.ReadInt()
	local item_count = MsgAdapter.ReadInt()
	self.reward_list = {}
	if item_count > 0 then
		for i=1,item_count do
			local data = {}
			data.item_id = MsgAdapter.ReadUShort()
			data.num = MsgAdapter.ReadShort()
			table.insert(self.reward_list, data)
		end
	end
end

--城主信息
SCGongChengZhanOwnerInfo =  SCGongChengZhanOwnerInfo or BaseClass(BaseProtocolStruct)
function SCGongChengZhanOwnerInfo:__init()
	self.msg_type = 6704
end

function SCGongChengZhanOwnerInfo:Decode()
	self.owner_id = MsgAdapter.ReadInt()
	self.owner_name = MsgAdapter.ReadStrN(32)
	self.vip_level = MsgAdapter.ReadChar()
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.guild_id = MsgAdapter.ReadInt()
end

--攻城战-请求城主信息
CSGongChengZhanGetOwnerInfoReq =  CSGongChengZhanGetOwnerInfoReq or BaseClass(BaseProtocolStruct)
function CSGongChengZhanGetOwnerInfoReq:__init()
	self.msg_type = 6705
end

function CSGongChengZhanGetOwnerInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--攻城战-传送到旗子/资源区
CSGCZChangePlace =  CSGCZChangePlace or BaseClass(BaseProtocolStruct)
function CSGCZChangePlace:__init()
	self.msg_type = 6751
end

function CSGCZChangePlace:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.place_type)
end

-- 幸运列表 攻城战
SCZhanchangLuckyInfo =  SCZhanchangLuckyInfo or BaseClass(BaseProtocolStruct)
function SCZhanchangLuckyInfo:__init()
	self.msg_type = 6753
	self.next_lucky_timestamp = 0
	self.luck_user_namelist = {}
end

function SCZhanchangLuckyInfo:Decode()
	self.next_lucky_timestamp = MsgAdapter.ReadUInt()
	local luck_user_count = MsgAdapter.ReadInt()
	self.luck_user_namelist = {}
	for i= 1 , luck_user_count do
		self.luck_user_namelist[i] = MsgAdapter.ReadStrN(32)
	end
end

-- 幸运列表 领土战
SCTwLuckyRewardInfo =  SCTwLuckyRewardInfo or BaseClass(BaseProtocolStruct)
function SCTwLuckyRewardInfo:__init()
	self.msg_type = 5954
	self.next_lucky_timestamp = 0
	self.luck_user_namelist = {}
end

function SCTwLuckyRewardInfo:Decode()
	self.next_lucky_timestamp = MsgAdapter.ReadUInt()
	local luck_user_count = MsgAdapter.ReadInt()
	self.luck_user_namelist = {}
	for i= 1 , luck_user_count do
		self.luck_user_namelist[i] = MsgAdapter.ReadStrN(32)
	end
end

-- 幸运列表 公会争霸
SCGBLuckyRewardInfo =  SCGBLuckyRewardInfo or BaseClass(BaseProtocolStruct)
function SCGBLuckyRewardInfo:__init()
	self.msg_type = 6254
	self.next_lucky_timestamp = 0
	self.luck_user_namelist = {}
end

function SCGBLuckyRewardInfo:Decode()
	self.next_lucky_timestamp = MsgAdapter.ReadUInt()
	local luck_user_count = MsgAdapter.ReadInt()
	self.luck_user_namelist = {}
	for i= 1 , luck_user_count do
		self.luck_user_namelist[i] = MsgAdapter.ReadStrN(32)
	end
end

-- 幸运列表 群仙乱斗
SCQxdldLuckyRewardInfo =  SCQxdldLuckyRewardInfo or BaseClass(BaseProtocolStruct)
function SCQxdldLuckyRewardInfo:__init()
	self.msg_type = 4950
	self.next_lucky_timestamp = 0
	self.luck_user_namelist = {}
end

function SCQxdldLuckyRewardInfo:Decode()
	self.next_lucky_timestamp = MsgAdapter.ReadUInt()
	local luck_user_count = MsgAdapter.ReadInt()
	self.luck_user_namelist = {}
	for i= 1 , luck_user_count do
		self.luck_user_namelist[i] = MsgAdapter.ReadStrN(32)
	end
end

-- 攻城战膜拜信息
SCGCZWorshipInfo =  SCGCZWorshipInfo or BaseClass(BaseProtocolStruct)
function SCGCZWorshipInfo:__init()
	self.msg_type = 6754
	self.worship_times = 0
	self.next_worship_timestamp = 0
	self.next_interval_addexp_timestamp = 0
end

function SCGCZWorshipInfo:Decode()
	self.worship_times = MsgAdapter.ReadInt()
	self.next_worship_timestamp = MsgAdapter.ReadUInt()
	self.next_interval_addexp_timestamp = MsgAdapter.ReadUInt()
end

--攻城战-请求膜拜
CSGCZWorshipReq =  CSGCZWorshipReq or BaseClass(BaseProtocolStruct)
function CSGCZWorshipReq:__init()
	self.msg_type = 6756
end

function CSGCZWorshipReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end
