--领取在线奖励
CSWelfareOnlineReward = CSWelfareOnlineReward or BaseClass(BaseProtocolStruct)
function CSWelfareOnlineReward:__init()
	self.msg_type = 6602
	self.part = 0
end

function CSWelfareOnlineReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.part)
end

--点击世界时间的场景对象
CSWorldEventObjTouch = CSWorldEventObjTouch or BaseClass(BaseProtocolStruct)
function CSWorldEventObjTouch:__init()
	self.msg_type = 2859
	self.obj_id = 0
	self.reserve = 0
end

function CSWorldEventObjTouch:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.obj_id)
	MsgAdapter.WriteShort(self.reserve)
end

-- 鱼池所有信息
SCFishPoolAllInfo = SCFishPoolAllInfo or BaseClass(BaseProtocolStruct)
function SCFishPoolAllInfo:__init()
	self.msg_type = 2800
end

function SCFishPoolAllInfo:Decode()
	self.normal_info = {}
	self.normal_info.owner_uid = MsgAdapter.ReadInt()
	self.normal_info.owner_name = MsgAdapter.ReadStrN(32)
	self.normal_info.role_level = MsgAdapter.ReadInt()
	self.normal_info.pool_level = MsgAdapter.ReadInt()
	self.normal_info.pool_exp = MsgAdapter.ReadLL()
	self.normal_info.extend_capacity = MsgAdapter.ReadShort()
	self.normal_info.bullet_buy_times = MsgAdapter.ReadShort()
	self.normal_info.bullet_buy_num = MsgAdapter.ReadInt()
	self.normal_info.bullet_consume_num = MsgAdapter.ReadInt()

	self.day_record_count = MsgAdapter.ReadInt()
	self.day_raise_record_list = {}
	for i = 1, self.day_record_count do
		local vo = {}
		vo.fish_type = MsgAdapter.ReadShort()
		vo.day_raise_count = MsgAdapter.ReadShort()
		table.insert(self.day_raise_record_list, vo)
	end
end

-- 鱼塘鱼儿信息
SCFishPoolAllRaiseInfo = SCFishPoolAllRaiseInfo or BaseClass(BaseProtocolStruct)
function SCFishPoolAllRaiseInfo:__init()
	self.msg_type = 2801
end

function SCFishPoolAllRaiseInfo:Decode()
	self.owner_uid = MsgAdapter.ReadInt()
	self.raise_count = MsgAdapter.ReadInt()
	self.raise_list = {}
	for i = 1, self.raise_count do
		local vo = {}
		vo.fish_objid = MsgAdapter.ReadShort()
		vo.fish_type = MsgAdapter.ReadShort()
		vo.raise_timestamp = MsgAdapter.ReadUInt()
		table.insert(self.raise_list, vo)
	end
end

-- 普通信息
SCFishPoolCommonInfo = SCFishPoolCommonInfo or BaseClass(BaseProtocolStruct)
function SCFishPoolCommonInfo:__init()
	self.msg_type = 2802
end

function SCFishPoolCommonInfo:Decode()
	self.normal_info = {}
	self.normal_info.owner_uid = MsgAdapter.ReadInt()
	self.normal_info.owner_name = MsgAdapter.ReadStrN(32)
	self.normal_info.role_level = MsgAdapter.ReadInt()
	self.normal_info.pool_level = MsgAdapter.ReadInt()
	self.normal_info.pool_exp = MsgAdapter.ReadLL()
	self.normal_info.extend_capacity = MsgAdapter.ReadShort()
	self.normal_info.bullet_buy_times = MsgAdapter.ReadShort()
	self.normal_info.bullet_buy_num = MsgAdapter.ReadInt()
	self.normal_info.bullet_consume_num = MsgAdapter.ReadInt()
end

-- 鱼塘放养信息变化
SCFishPoolRaiseInfoChange = SCFishPoolRaiseInfoChange or BaseClass(BaseProtocolStruct)
function SCFishPoolRaiseInfoChange:__init()
	self.msg_type = 2803
end

function SCFishPoolRaiseInfoChange:Decode()
	self.owner_uid = MsgAdapter.ReadInt()
	self.fish_info = {}
	self.fish_info.fish_objid = MsgAdapter.ReadShort()
	self.fish_info.fish_type = MsgAdapter.ReadShort()
	self.fish_info.raise_timestamp = MsgAdapter.ReadUInt()
	self.fish_recoed = {}
	self.fish_recoed.fish_type = MsgAdapter.ReadShort()
	self.fish_recoed.day_raise_count = MsgAdapter.ReadShort()
end

-- 好友鱼池简要信息
SCFishPoolFriendsGeneralInfo = SCFishPoolFriendsGeneralInfo or BaseClass(BaseProtocolStruct)
function SCFishPoolFriendsGeneralInfo:__init()
	self.msg_type = 2804
end

function SCFishPoolFriendsGeneralInfo:Decode()
	self.info_count = MsgAdapter.ReadInt()
	self.info_list = {}
	for i = 1, self.info_count do
		local vo = {}
		vo.friend_uid = MsgAdapter.ReadInt()
		vo.friend_name = MsgAdapter.ReadStrN(32)
		vo.can_steal = MsgAdapter.ReadChar()
		vo.prof = MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		vo.pool_level = MsgAdapter.ReadInt()
		vo.avatar_key_big = MsgAdapter.ReadUInt()
		vo.avatar_key_small = MsgAdapter.ReadUInt()
		table.insert(self.info_list, vo)
	end
end

-- 仙盟成员鱼池简要信息
SCFishPoolGuildMemberGeneralInfo = SCFishPoolGuildMemberGeneralInfo or BaseClass(BaseProtocolStruct)
function SCFishPoolGuildMemberGeneralInfo:__init()
	self.msg_type = 2805
end

function SCFishPoolGuildMemberGeneralInfo:Decode()
	self.info_count = MsgAdapter.ReadInt()
	self.info_list = {}
	for i = 1, self.info_count do
		local vo = {}
		vo.friend_uid = MsgAdapter.ReadInt()
		vo.friend_name = MsgAdapter.ReadStrN(32)
		vo.can_steal = MsgAdapter.ReadChar()
		vo.prof = MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		vo.pool_level = MsgAdapter.ReadInt()
		vo.avatar_key_big = MsgAdapter.ReadUInt()
		vo.avatar_key_small = MsgAdapter.ReadUInt()
		table.insert(self.info_list, vo)
	end
end

-- 请求放养鱼儿
CSFishPoolRaiseReq = CSFishPoolRaiseReq or BaseClass(BaseProtocolStruct)
function CSFishPoolRaiseReq:__init()
	self.msg_type = 2850
	self.fish_type = 0
end

function CSFishPoolRaiseReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.fish_type)
	MsgAdapter.WriteShort(0)
end

-- 购买子弹请求
CSFishPoolBuyBulletReq = CSFishPoolBuyBulletReq or BaseClass(BaseProtocolStruct)
function CSFishPoolBuyBulletReq:__init()
	self.msg_type = 2851
end

function CSFishPoolBuyBulletReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 查询信息请求
CSFishPoolQueryReq = CSFishPoolQueryReq or BaseClass(BaseProtocolStruct)
function CSFishPoolQueryReq:__init()
	self.msg_type = 2852
	self.query_type = 0  -- 0:所有信息 1:放养信息 2:好友简要信息 3:仙盟成员简要信息
	self.query_uid = 0
end

function CSFishPoolQueryReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.query_type)
	MsgAdapter.WriteInt(self.query_uid)
end

-- 偷鱼请求
CSFishPoolStealFish = CSFishPoolStealFish or BaseClass(BaseProtocolStruct)
function CSFishPoolStealFish:__init()
	self.msg_type = 2853
	self.target_uid = 0
	self.fish_objid = 0
	self.raise_timestamp = 0
end

function CSFishPoolStealFish:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_uid)
	MsgAdapter.WriteShort(self.fish_objid)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteUInt(self.raise_timestamp)
end

-- 收获请求
CSFishPoolHarvest = CSFishPoolHarvest or BaseClass(BaseProtocolStruct)
function CSFishPoolHarvest:__init()
	self.msg_type = 2854
	self.fish_objid = 0
end

function CSFishPoolHarvest:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.fish_objid)
	MsgAdapter.WriteShort(0)
end

-- 拓展背包请求
CSFishPoolExtendCapacity = CSFishPoolExtendCapacity or BaseClass(BaseProtocolStruct)
function CSFishPoolExtendCapacity:__init()
	self.msg_type = 2855
	self.extend_type = 1 -- 1铜币 2元宝
end

function CSFishPoolExtendCapacity:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.extend_type)
	MsgAdapter.WriteShort(0)
end

-- 摇钱树3(幸运宝箱) -------------------------------------
SCRAMoneyTreeInfoThree = SCRAMoneyTreeInfoThree or BaseClass(BaseProtocolStruct)
function SCRAMoneyTreeInfoThree:__init()
	self.msg_type = 2864
	self.money_tree_total_times = 0
	self.money_tree_free_timestamp = 0
	self.server_total_pool_gold = 0
	self.server_reward_has_fetch_reward_flag = 0
end

function SCRAMoneyTreeInfoThree:Decode()
	self.money_tree_total_times = MsgAdapter.ReadInt()
	self.money_tree_free_timestamp = MsgAdapter.ReadUInt()
	self.server_total_pool_gold = MsgAdapter.ReadInt()
	self.server_reward_has_fetch_reward_flag = MsgAdapter.ReadInt()
end
-- 摇钱树3(幸运宝箱)抽奖结果
SCRAMoneyTreeChouResultInfoThree = SCRAMoneyTreeChouResultInfoThree or BaseClass(BaseProtocolStruct)
function SCRAMoneyTreeChouResultInfoThree:__init()
	self.msg_type = 2865
	self.reward_req_list_count = 0
	self.reward_req_list = {}
end

function SCRAMoneyTreeChouResultInfoThree:Decode()
	self.reward_req_list_count = MsgAdapter.ReadInt()
	self.reward_req_list = {}
	for i = 1, self.reward_req_list_count do
		self.reward_req_list [i] = MsgAdapter.ReadChar()
	end
end
-- 摇钱树4(幸运扭蛋机) -------------------------------------
SCRAMoneyTreeInfoFour = SCRAMoneyTreeInfoFour or BaseClass(BaseProtocolStruct)
function SCRAMoneyTreeInfoFour:__init()
	self.msg_type = 2866
	self.money_tree_total_times = 0
	self.money_tree_free_timestamp = 0
	self.server_total_pool_gold = 0
	self.server_reward_has_fetch_reward_flag = 0
end

function SCRAMoneyTreeInfoFour:Decode()
	self.money_tree_total_times = MsgAdapter.ReadInt()
	self.money_tree_free_timestamp = MsgAdapter.ReadUInt()
	self.server_total_pool_gold = MsgAdapter.ReadInt()
	self.server_reward_has_fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 摇钱树4抽奖结果
SCRAMoneyTreeChouResultInfoFour = SCRAMoneyTreeChouResultInfoFour or BaseClass(BaseProtocolStruct)
function SCRAMoneyTreeChouResultInfoFour:__init()
	self.msg_type = 2867
	self.reward_req_list_count = 0
	self.reward_req_list = {}
end

function SCRAMoneyTreeChouResultInfoFour:Decode()
	self.reward_req_list_count = MsgAdapter.ReadInt()
	self.reward_req_list = {}
	for i = 1, self.reward_req_list_count do
		self.reward_req_list [i] = MsgAdapter.ReadChar()
	end
end

--大射天下 -------------------------------------
SCRAMoneyTreeFiveInfo = SCRAMoneyTreeFiveInfo or BaseClass(BaseProtocolStruct)
function SCRAMoneyTreeFiveInfo:__init()
	self.msg_type = 2868
	self.money_tree_total_times = 0
	self.money_tree_free_timestamp = 0
	self.server_total_pool_gold = 0
	self.server_reward_has_fetch_reward_flag = 0
end

function SCRAMoneyTreeFiveInfo:Decode()
	self.money_tree_total_times = MsgAdapter.ReadInt()
	self.money_tree_free_timestamp = MsgAdapter.ReadUInt()
	self.server_total_pool_gold = MsgAdapter.ReadInt()
	self.server_reward_has_fetch_reward_flag = MsgAdapter.ReadInt()
end

-- 抽奖结果
SCRAMoneyTreeFiveChouResultInfo = SCRAMoneyTreeFiveChouResultInfo or BaseClass(BaseProtocolStruct)
function SCRAMoneyTreeFiveChouResultInfo:__init()
	self.msg_type = 2869
	self.reward_req_list_count = 0
	self.reward_req_list = {}
end

function SCRAMoneyTreeFiveChouResultInfo:Decode()
	self.reward_req_list_count = MsgAdapter.ReadInt()
	self.reward_req_list = {}
	for i = 1, self.reward_req_list_count do
		self.reward_req_list [i] = MsgAdapter.ReadChar()
	end
end