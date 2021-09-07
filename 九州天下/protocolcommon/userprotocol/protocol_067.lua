-- 攻城战全局信息，（广播处理）
SCGCZGlobalInfo = SCGCZGlobalInfo or BaseClass(BaseProtocolStruct)
function SCGCZGlobalInfo:__init()
	self.msg_type = 6701
end

function SCGCZGlobalInfo:Decode()
	self.is_finish = MsgAdapter.ReadChar()
	self.is_pochen = MsgAdapter.ReadChar()
	self.is_poqiang = MsgAdapter.ReadChar()
	self.camp_type = MsgAdapter.ReadChar()
	self.current_shou_cheng_time = MsgAdapter.ReadUInt()
	self.totem_level = MsgAdapter.ReadInt()

	local rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, rank_count do
		local data = {}
		data.camp_type = MsgAdapter.ReadInt()
		data.shouchen_time = MsgAdapter.ReadUInt()
		self.rank_list[i] = data
	end

	-- local a = MsgAdapter.ReadChar()

	-- self.cu_def_guild_time = MsgAdapter.ReadUInt()
	-- self.shou_guild_id = MsgAdapter.ReadInt()
	-- self.shou_guild_name = MsgAdapter.ReadStrN(32)
	-- self.shou_totem_level = MsgAdapter.ReadInt()
	-- self.po_cheng_times = MsgAdapter.ReadInt()

	-- print_error("999999")
	-- self.rank_list = {}

	-- local rank_count = MsgAdapter.ReadInt()
	-- if rank_count > 0 then
	-- 	for i = 1, rank_count do
	-- 		local item = {}
	-- 		item.rank = i

	-- 		item.guild_id = MsgAdapter.ReadInt()
	-- 		item.shouchen_time = MsgAdapter.ReadUInt()
	-- 		item.guild_name = MsgAdapter.ReadStrN(32)
	-- 		table.insert(self.rank_list, item)
	-- 	end
	-- end
end

-- 攻城战个人信息
SCGCZRoleInfo =  SCGCZRoleInfo or BaseClass(BaseProtocolStruct)
function SCGCZRoleInfo:__init()
	self.msg_type = 6702
end

function SCGCZRoleInfo:Decode()
	self.is_shousite = MsgAdapter.ReadChar()
	local x = MsgAdapter.ReadChar()
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
	self.daily_chestshop_score = MsgAdapter.ReadInt()
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

--攻城战-膜拜 接收数据
SCGCZWorshipInfo =  SCGCZWorshipInfo or BaseClass(BaseProtocolStruct)
function SCGCZWorshipInfo:__init()
	self.msg_type = 6706
end

function SCGCZWorshipInfo:Decode()
	self.worship_time = MsgAdapter.ReadInt()     					--玩家点击次数
	self.next_worship_timestamp = MsgAdapter.ReadUInt()  		 	--玩家下次可点击时间戳
	self.next_interval_addexp_timestamp = MsgAdapter.ReadUInt() 	--玩家下次加经验时间戳
end

--通知活动开启结束
SCGCZWorshipActivityInfo =  SCGCZWorshipActivityInfo or BaseClass(BaseProtocolStruct)
function SCGCZWorshipActivityInfo:__init()
	self.msg_type = 6707
end

function SCGCZWorshipActivityInfo:Decode() 
	self.worship_is_open = MsgAdapter.ReadChar() 		--膜拜活动开启
	MsgAdapter.ReadChar()  
	MsgAdapter.ReadShort() 
	self.worship_end_timestamp = MsgAdapter.ReadUInt()	--膜拜活动结束时间戳.
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

-- 点击膜拜 攻城战
CSGCZWorshipReq =  CSGCZWorshipReq or BaseClass(BaseProtocolStruct)
function CSGCZWorshipReq:__init()
	self.msg_type = 6753
end

function CSGCZWorshipReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


-- 幸运列表 领土战------------------------------------------------------------------------------------------------------------
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
	self.msg_type = 6254000
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