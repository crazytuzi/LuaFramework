--复活商店购买
CSTerritoryWarReliveShopBuy = CSTerritoryWarReliveShopBuy or BaseClass(BaseProtocolStruct)
function CSTerritoryWarReliveShopBuy:__init()
	self.msg_type = 5900
	self.goods_id = 0
end

function CSTerritoryWarReliveShopBuy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.goods_id)
	MsgAdapter.WriteShort(0)
end

--战斗商店购买
CSTerritoryWarReliveFightBuy = CSTerritoryWarReliveFightBuy or BaseClass(BaseProtocolStruct)
function CSTerritoryWarReliveFightBuy:__init()
	self.msg_type = 5901
	self.type = 0
	self.goods_id = 0
end

function CSTerritoryWarReliveFightBuy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(self.goods_id)
end

--请求参战队伍信息
CSTerritoryWarQualification = CSTerritoryWarQualification or BaseClass(BaseProtocolStruct)
function CSTerritoryWarQualification:__init()
	self.msg_type = 5902
	self.type = 0
	self.goods_id = 0
end

function CSTerritoryWarQualification:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(self.goods_id)
end

--请求埋地雷
CSTerritorySetLandMine = CSTerritorySetLandMine or BaseClass(BaseProtocolStruct)
function CSTerritorySetLandMine:__init()
	self.msg_type = 5903
	self.landmine_type = 0
	self.pos_x = 0
	self.pos_y = 0
end

function CSTerritorySetLandMine:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.landmine_type)
	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
end

--变身形象广播
SCTerritoryWarApperance = SCTerritoryWarApperance or BaseClass(BaseProtocolStruct)
function SCTerritoryWarApperance:__init()
	self.msg_type = 5950
	self.obj_id = 0
	self.special_image = 0
end

function SCTerritoryWarApperance:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.special_image = MsgAdapter.ReadShort()
end

--全局信息（广播）
SCTerritoryWarGlobeInfo = SCTerritoryWarGlobeInfo or BaseClass(BaseProtocolStruct)
function SCTerritoryWarGlobeInfo:__init()
	self.msg_type = 5951
	self.red_guild_credit = 0
	self.blue_guild_credit = 0
	self.center_relive_side = 0
	self.red_fortress_max_hp = 0
	self.red_fortress_curr_hp = 0
	self.blue_fortress_max_hp = 0
	self.blue_fortress_curr_hp = 0
	self.center_relive_max_hp = 0
	self.center_relive_curr_hp = 0
	self.red_building_survive_flag = 0 				-- 按位取，1死亡， 0存活
	self.blue_building_survive_flag = 0 			-- 按位取，1死亡， 0存活
	self.m_read_next_can_buy_tower_wudi = 0
	self.m_blue_next_can_buy_tower_wudi = 0
	self.m_winner_side = -1
end

function SCTerritoryWarGlobeInfo:Decode()
	self.red_guild_credit = MsgAdapter.ReadInt()
	self.blue_guild_credit = MsgAdapter.ReadInt()
	self.center_relive_side = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.red_fortress_max_hp = MsgAdapter.ReadInt()
	self.red_fortress_curr_hp = MsgAdapter.ReadInt()
	self.blue_fortress_max_hp = MsgAdapter.ReadInt()
	self.blue_fortress_curr_hp = MsgAdapter.ReadInt()
	self.center_relive_max_hp = MsgAdapter.ReadInt()
	self.center_relive_curr_hp = MsgAdapter.ReadInt()
	self.red_building_survive_flag = MsgAdapter.ReadInt()
	self.blue_building_survive_flag = MsgAdapter.ReadInt()
	self.m_read_next_can_buy_tower_wudi = MsgAdapter.ReadUInt()
	self.m_blue_next_can_buy_tower_wudi = MsgAdapter.ReadUInt()
	self.m_winner_side = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()

end

--个人信息
SCTerritoryWarRoleInfo = SCTerritoryWarRoleInfo or BaseClass(BaseProtocolStruct)
function SCTerritoryWarRoleInfo:__init()
	self.msg_type = 5952
	self.current_credit = 0					-- 当前拥有积分
	self.history_credit = 0					-- 历史获得积分
	self.credit_reward_flag = 0				-- 积分奖励标志位
	self.kill_count = 0						-- 击杀玩家数
	self.assist_count = 0					-- 助攻击杀玩家数
	self.death_count = 0					-- 玩家死亡数
	self.side = 0							-- 1(红)，0(蓝)
	self.special_image_id = 0				-- 购买攻城车形象
	self.ice_landmine_count = 0				-- 拥有冰霜地雷数量
	self.fire_landmine_count = 0			-- 拥有火焰地雷数量
	self.skill_list = {}
end

function SCTerritoryWarRoleInfo:Decode()
	self.current_credit = MsgAdapter.ReadInt()
	self.history_credit = MsgAdapter.ReadInt()
	self.credit_reward_flag = MsgAdapter.ReadInt()
	self.kill_count = MsgAdapter.ReadShort()
	self.assist_count = MsgAdapter.ReadShort()
	self.death_count = MsgAdapter.ReadShort()
	self.side = MsgAdapter.ReadShort()
	self.special_image_id = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.ice_landmine_count = MsgAdapter.ReadShort()
	self.fire_landmine_count = MsgAdapter.ReadShort()
	self.skill_list = {}
	for i = 1, 2 do
		self.skill_list[i] = {}
		self.skill_list[i].index = i
		self.skill_list[i].skill_index = MsgAdapter.ReadInt()
		self.skill_list[i].last_perform_time = MsgAdapter.ReadUInt()
		self.skill_list[i].next_time = self.skill_list[i].last_perform_time + 5
	end
end

----下发参战队伍信息
SCTerritoryWarQualification = SCTerritoryWarQualification or BaseClass(BaseProtocolStruct)
function SCTerritoryWarQualification:__init()
	self.msg_type = 5953
	self.guild_rank_list = {}
	self.territorywar_rank_list = {}
end

function SCTerritoryWarQualification:Decode()
	self.guild_rank_list = {}
	self.territorywar_rank_list = {}
	for i = 1, 10 do
		self.guild_rank_list[i] = MsgAdapter.ReadInt()
	end
	for i =1, 10 do
		self.territorywar_rank_list[i] = MsgAdapter.ReadInt()
	end
end


SCFightingChallengeBaseInfo = SCFightingChallengeBaseInfo or BaseClass(BaseProtocolStruct)
function SCFightingChallengeBaseInfo:__init()
	self.msg_type = 5959
	self.challenge_day_times = 0
	self.challenge_score = 0
	self.next_add_challenge_timestamp = 0
	self.next_auto_reflush_time = 0
end

function SCFightingChallengeBaseInfo:Decode()
	self.challenge_score = MsgAdapter.ReadInt()
	self.challenge_day_times = MsgAdapter.ReadChar() 	-- 剩余次数
	self.vip_buy_times = MsgAdapter.ReadChar()
	self.reserve_sh = MsgAdapter.ReadShort()
	self.next_add_challenge_timestamp = MsgAdapter.ReadUInt()
	self.next_auto_reflush_time = MsgAdapter.ReadUInt()
end

SCFightingChallengeList = SCFightingChallengeList or BaseClass(BaseProtocolStruct)
function SCFightingChallengeList:__init()
	self.msg_type = 5961
	self.opponent_list = {}
end

function SCFightingChallengeList:Decode()
	for i=1, GameEnum.FIGHTING_CHALLENGE_OPPONENT_COUNT do
		local role_info = {}
		role_info.camp = MsgAdapter.ReadChar()
		role_info.prof = MsgAdapter.ReadChar()
		role_info.sex = MsgAdapter.ReadChar()
		role_info.is_win = MsgAdapter.ReadChar()
		role_info.reserve_sh = MsgAdapter.ReadShort()
		role_info.random_name_num = MsgAdapter.ReadShort()
		role_info.name = MsgAdapter.ReadStrN(32)
		role_info.capability = MsgAdapter.ReadInt()
		role_info.appearance = ProtocolStruct.ReadRoleAppearance()
		self.opponent_list[i] = role_info
	end
end

-- 挖矿请求
CSFightingMiningReq = CSFightingMiningReq or BaseClass(BaseProtocolStruct)
function CSFightingMiningReq:__init()
	self.msg_type = 5955
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSFightingMiningReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

----5956  挖矿基础信息
SCFightingMiningBaseInfo = SCFightingMiningBaseInfo or BaseClass(BaseProtocolStruct)
function SCFightingMiningBaseInfo:__init()
	self.msg_type = 5956
	self.today_mining_times = 0 			-- 今日已挖矿次数
	self.today_buy_times = 0 				-- 今日已购买次数
	self.today_rob_mine_times = 0 			-- 今日已抢劫矿次数
	self.mining_type = 0 					-- 当前矿类型
	self.mining_been_rob_times = 0 			-- 当前矿被挖的次数
	self.mining_end_time = 0 				-- 当前矿结束挖的时间戳
end

function SCFightingMiningBaseInfo:Decode()
	self.today_mining_times = MsgAdapter.ReadChar()
	self.today_buy_times = MsgAdapter.ReadChar()
	self.today_rob_mine_times = MsgAdapter.ReadChar()
	self.mining_type = MsgAdapter.ReadChar()
	self.mining_been_rob_times = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.mining_end_time = MsgAdapter.ReadUInt()
end

-- 被抢劫历史列表
SCFightingMiningBeenRobList = SCFightingMiningBeenRobList or BaseClass(BaseProtocolStruct)
function SCFightingMiningBeenRobList:__init()
	self.msg_type = 5957
	self.mining_rob_list = {}
end

function SCFightingMiningBeenRobList:Decode()
	self.mining_rob_list = {}
	local info = {}

	local show_index = 1
	for i = 1, 20 do
		info = {}
		info.owner_name = MsgAdapter.ReadStrN(32) 		-- 抢劫者名字
		info.rob_time = MsgAdapter.ReadUInt()			-- 抢劫时间
		info.has_revenge = MsgAdapter.ReadChar() 		-- 是否已报仇
		info.real_index = MsgAdapter.ReadChar() 		-- 在数据库存储里面的下标（用于复仇）
		info.cur_type = MsgAdapter.ReadChar() 			-- 矿品质
		info.sex = MsgAdapter.ReadChar() 				-- 
		info.prof = MsgAdapter.ReadChar() 				-- 
		MsgAdapter.ReadChar() 		
		MsgAdapter.ReadShort()
		info.rob_level = 1
		info.capability = MsgAdapter.ReadInt()	
		
		if info.real_index ~= -1 and info.rob_time ~= 0 then 
			self.mining_rob_list[show_index] = info
			show_index = show_index + 1
		end
	end

	table.sort(self.mining_rob_list, SortTools.KeyUpperSorters("rob_time"))
end

----5958  矿列表
SCFightingMiningList = SCFightingMiningList or BaseClass(BaseProtocolStruct)
function SCFightingMiningList:__init()
	self.msg_type = 5958

	self.mine_count = 0
	self.mine_list = {}
end

function SCFightingMiningList:Decode()
	self.mine_count = MsgAdapter.ReadInt()
	self.mine_list = {}
	local info = {}
	for i = 1, self.mine_count do
		info = {}
		info.owner_uid = MsgAdapter.ReadInt()

		info.random_index = MsgAdapter.ReadInt()
		info.owner_name = MsgAdapter.ReadStrN(32)

		info.mining_end_time = MsgAdapter.ReadUInt()
		info.cur_type = MsgAdapter.ReadChar()   -- // 当前矿类型
		info.robot_index = MsgAdapter.ReadChar()   -- 机器人ID(0 - 7)
		info.sex = MsgAdapter.ReadChar()
		info.prof = MsgAdapter.ReadChar()
		info.capability = MsgAdapter.ReadInt()

		info.rob_level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		self.mine_list[i] = info
	end
end

----5960 战斗结果通知
SCFightingResultNotify = SCFightingResultNotify or BaseClass(BaseProtocolStruct)
function SCFightingResultNotify:__init()
	self.msg_type = 5960
	self.is_win = 0
	self.fighting_type = 0
	self.reward_exp = 0
	self.item_list = {}
end

function SCFightingResultNotify:Decode()
	self.is_win = MsgAdapter.ReadChar()
	self.fighting_type = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.reward_exp = MsgAdapter.ReadLL()
	self.item_list = {}
	local info = {}
	for i = 1, 3 do
		info = {}
		info.item_id = MsgAdapter.ReadUShort()
		info.num = MsgAdapter.ReadShort()
		info.is_bind = 0
		self.item_list[i] = info
	end
end

----5965 战斗结果通知
SCFightingCountDownNotify = SCFightingCountDownNotify or BaseClass(BaseProtocolStruct)
function SCFightingCountDownNotify:__init()
	self.msg_type = 5965
	self.start_fighting_time = 0
end

function SCFightingCountDownNotify:Decode()
	self.start_fighting_time = MsgAdapter.ReadUInt()
end

----5962  航海基础信息
SCFightingSailingBaseInfo = SCFightingSailingBaseInfo or BaseClass(BaseProtocolStruct)
function SCFightingSailingBaseInfo:__init()
	self.msg_type = 5962
	self.today_mining_times = 0 			-- 今日已挖矿次数
	self.today_buy_times = 0 				-- 今日已购买次数
	self.today_rob_mine_times = 0 			-- 今日已抢劫矿次数
	self.mining_type = 0 					-- 当前矿类型
	self.mining_been_rob_times = 0 			-- 当前矿被挖的次数
	self.mining_end_time = 0 				-- 当前矿结束挖的时间戳
end

function SCFightingSailingBaseInfo:Decode()
	self.today_mining_times = MsgAdapter.ReadChar()
	self.today_buy_times = MsgAdapter.ReadChar()
	self.today_rob_mine_times = MsgAdapter.ReadChar()
	self.mining_type = MsgAdapter.ReadChar()
	self.mining_been_rob_times = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.mining_end_time = MsgAdapter.ReadUInt()
end

-- 被抢劫历史列表
SCFightingSailingBeenRobList = SCFightingSailingBeenRobList or BaseClass(BaseProtocolStruct)
function SCFightingSailingBeenRobList:__init()
	self.msg_type = 5963
	self.mining_rob_list = {}
end

function SCFightingSailingBeenRobList:Decode()
	self.mining_rob_list = {}
	local info = {}

	local show_index = 1
	for i = 1, 20 do
		info = {}
		info.owner_name = MsgAdapter.ReadStrN(32) 		-- 抢劫者名字
		info.rob_time = MsgAdapter.ReadUInt()			-- 抢劫时间
		info.has_revenge = MsgAdapter.ReadChar() 		-- 是否已报仇
		info.real_index = MsgAdapter.ReadChar() 		-- 在数据库存储里面的下标（用于复仇）
		info.cur_type = MsgAdapter.ReadChar() 			-- 矿品质
		info.sex = MsgAdapter.ReadChar() 				-- 
		info.prof = MsgAdapter.ReadChar() 				-- 
		MsgAdapter.ReadChar() 		
		MsgAdapter.ReadShort()
		info.rob_level = 1
		info.capability = MsgAdapter.ReadInt()	
		
		if info.real_index ~= -1 and info.rob_time ~= 0 then 
			self.mining_rob_list[show_index] = info
			show_index = show_index + 1
		end
	end

	table.sort(self.mining_rob_list, SortTools.KeyUpperSorters("rob_time"))
end

----5964  航行列表
SCFightingSailingList = SCFightingSailingList or BaseClass(BaseProtocolStruct)
function SCFightingSailingList:__init()
	self.msg_type = 5964

	self.mine_count = 0
	self.mine_list = {}
end

function SCFightingSailingList:Decode()
	self.mine_count = MsgAdapter.ReadInt()
	self.mine_list = {}
	local info = {}
	for i = 1, self.mine_count do
		info = {}
		info.owner_uid = MsgAdapter.ReadInt()

		info.random_index = MsgAdapter.ReadInt()
		info.owner_name = MsgAdapter.ReadStrN(32)

		info.mining_end_time = MsgAdapter.ReadUInt()
		info.cur_type = MsgAdapter.ReadChar()   -- // 当前矿类型
		info.robot_index = MsgAdapter.ReadChar()   -- 机器人ID(0 - 7)
		info.sex = MsgAdapter.ReadChar()
		info.prof = MsgAdapter.ReadChar()
		info.capability = MsgAdapter.ReadInt()

		info.rob_level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		self.mine_list[i] = info
	end
end

----5966  挖矿，航海-有新的抢夺记录（发送给被掠夺玩家本人，没查看之前一直有提示，重新登录也一样）
SCFightingBeenRobNotify = SCFightingBeenRobNotify or BaseClass(BaseProtocolStruct)
function SCFightingBeenRobNotify:__init()
	self.msg_type = 5966
	self.type = 0 					--0 挖矿，1 航海
end

function SCFightingBeenRobNotify:Decode()
	self.type = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

----5967  挖矿，航海-有新的抢夺记录（广播给所有人，只在抢夺时发一次）
SCFightingRobingNotify = SCFightingRobingNotify or BaseClass(BaseProtocolStruct)
function SCFightingRobingNotify:__init()
	self.msg_type = 5967
	self.rober_name = ""
	self.been_rob_name = ""
	self.type = 0 					--0 挖矿，1 航海
	self.quality = 0 				--品质
end

function SCFightingRobingNotify:Decode()
	self.rober_name = MsgAdapter.ReadStrN(32)
	self.been_rob_name = MsgAdapter.ReadStrN(32)
	self.type = MsgAdapter.ReadChar()
	self.quality = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end