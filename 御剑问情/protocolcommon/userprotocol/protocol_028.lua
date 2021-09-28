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

-- 鱼塘鱼儿信息
SCFishPoolAllRaiseInfo = SCFishPoolAllRaiseInfo or BaseClass(BaseProtocolStruct)
function SCFishPoolAllRaiseInfo:__init()
	self.msg_type = 2801
end

function SCFishPoolAllRaiseInfo:Decode()
	self.owner_uid = MsgAdapter.ReadInt()
	self.fish_quality = MsgAdapter.ReadInt()				--鱼的品质
	self.fish_num = MsgAdapter.ReadInt()					--鱼的数量
	self.fang_fish_time = MsgAdapter.ReadInt()				--放鱼的时间
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
	self.normal_info.bullet_buy_times = MsgAdapter.ReadInt()						-- 购买子弹的次数
	self.normal_info.bullet_buy_num = MsgAdapter.ReadInt()							-- 购买子弹的数量
	self.normal_info.bullet_consume_num = MsgAdapter.ReadInt()						-- 消耗子弹的数量
	self.normal_info.today_fang_fish_times = MsgAdapter.ReadInt()					-- 今天养鱼的次数
	self.normal_info.today_buy_fang_fish_tims = MsgAdapter.ReadInt()				-- 今天购买养鱼次数
end

--随机可偷鱼的玩家列表
SCFishPoolWorldGeneralInfo = SCFishPoolWorldGeneralInfo or BaseClass(BaseProtocolStruct)
function SCFishPoolWorldGeneralInfo:__init()
	self.msg_type = 2804
end

function SCFishPoolWorldGeneralInfo:Decode()
	local info_count = MsgAdapter.ReadInt()
	self.general_list = {}
	for i = 1, info_count do
		self.general_list[i] = {}
		self.general_list[i].owner_uid = MsgAdapter.ReadInt()			-- 偷鱼者的id
		self.general_list[i].owner_name = MsgAdapter.ReadStrN(32)		-- 偷鱼者的名字
		self.general_list[i].fish_quality = MsgAdapter.ReadInt()		-- 偷鱼者鱼的品质
		self.general_list[i].fish_num = MsgAdapter.ReadInt()			-- 偷鱼者鱼的数量
		self.general_list[i].fang_fish_time = MsgAdapter.ReadInt()		-- 偷鱼者放鱼的时间戳
		self.general_list[i].is_fake_pool = MsgAdapter.ReadInt()		-- 是否假鱼池
		self.general_list[i].is_fuchou = MsgAdapter.ReadInt()			-- 是否已复仇(无用)
		self.general_list[i].be_steal_quality = MsgAdapter.ReadInt()	-- 被偷的品质(无用)
		self.general_list[i].steal_fish_time = MsgAdapter.ReadInt()		-- 偷鱼的时间(无用)
	end
end

--偷鱼者信息列表
SCFishPoolStealGeneralInfo = SCFishPoolStealGeneralInfo or BaseClass(BaseProtocolStruct)
function SCFishPoolStealGeneralInfo:__init()
	self.msg_type = 2805
end

function SCFishPoolStealGeneralInfo:Decode()
	local info_count = MsgAdapter.ReadInt()
	self.general_list = {}
	for i = 1, info_count do
		self.general_list[i] = {}
		self.general_list[i].owner_uid = MsgAdapter.ReadInt()			-- 偷鱼者的id
		self.general_list[i].owner_name = MsgAdapter.ReadStrN(32)		-- 偷鱼者的名字
		self.general_list[i].fish_quality = MsgAdapter.ReadInt()		-- 偷鱼者鱼的品质
		self.general_list[i].fish_num = MsgAdapter.ReadInt()			-- 偷鱼者鱼的数量
		self.general_list[i].fang_fish_time = MsgAdapter.ReadInt()		-- 偷鱼者放鱼的时间戳
		self.general_list[i].is_fake_pool = MsgAdapter.ReadInt()		-- 是否假鱼池(无用)
		self.general_list[i].is_fuchou = MsgAdapter.ReadInt()			-- 是否已复仇
		self.general_list[i].be_steal_quality = MsgAdapter.ReadInt()	-- 被偷的品质
		self.general_list[i].steal_fish_time = MsgAdapter.ReadInt()		-- 偷鱼的时间
	end
end

-- 请求放养鱼儿
CSFishPoolRaiseReq = CSFishPoolRaiseReq or BaseClass(BaseProtocolStruct)
function CSFishPoolRaiseReq:__init()
	self.msg_type = 2850
end

function CSFishPoolRaiseReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
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
	self.query_type = 0
end

function CSFishPoolQueryReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.query_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(0)
end

-- 偷鱼请求
CSFishPoolStealFish = CSFishPoolStealFish or BaseClass(BaseProtocolStruct)
function CSFishPoolStealFish:__init()
	self.msg_type = 2853
	self.target_uid = 0
	self.is_fake_pool = 0
	self.quality = 0
	self.fish_type = 0
end

function CSFishPoolStealFish:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_uid)
	MsgAdapter.WriteChar(self.is_fake_pool)
	MsgAdapter.WriteChar(self.quality)
	MsgAdapter.WriteChar(self.fish_type)
	MsgAdapter.WriteChar(0)
end

-- 收获请求
CSFishPoolHarvest = CSFishPoolHarvest or BaseClass(BaseProtocolStruct)
function CSFishPoolHarvest:__init()
	self.msg_type = 2854
end

function CSFishPoolHarvest:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
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

--提高鱼的品质结果
SCUpFishQualityRet = SCUpFishQualityRet or BaseClass(BaseProtocolStruct)
function SCUpFishQualityRet:__init()
	self.msg_type = 2862
end

function SCUpFishQualityRet:Decode()
	self.quality = MsgAdapter.ReadInt()
end

--鱼数量变化
SCFishPoolChange = SCFishPoolChange or BaseClass(BaseProtocolStruct)
function SCFishPoolChange:__init()
	self.msg_type = 2863
end

function SCFishPoolChange:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.fish_num = MsgAdapter.ReadInt()
	self.fish_quality = MsgAdapter.ReadInt()
	self.is_steal_succ = MsgAdapter.ReadInt()					-- 0偷鱼失败，1偷鱼成功，2更新信息
end

--收获奖励
SCFishPoolShouFishRewardInfo = SCFishPoolShouFishRewardInfo or BaseClass(BaseProtocolStruct)
function SCFishPoolShouFishRewardInfo:__init()
	self.msg_type = 2810
end

function SCFishPoolShouFishRewardInfo:Decode()
	self.reward_info = {}
	self.reward_info.item_id = MsgAdapter.ReadInt()
	self.reward_info.item_num = MsgAdapter.ReadInt()
	self.reward_info.exp = MsgAdapter.ReadLL()
	self.reward_info.rune_score = MsgAdapter.ReadInt()
	self.reward_info.fish_quality = MsgAdapter.ReadInt()
end