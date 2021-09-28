-- 挖矿常量
MINING_AREA_TYPE_NUM = 3
MINING_MINE_TYPE_NUM = 5

--单个宠物相关信息
local function LoadLittlePetSingleInfo()
	local single_pet = {}
	single_pet.index = MsgAdapter.ReadInt()					--宠物索引
	single_pet.id = MsgAdapter.ReadShort()						--宠物id
	single_pet.info_type = MsgAdapter.ReadShort()				--自己的，伴侣的 1: 0
	single_pet.pet_name = MsgAdapter.ReadStrN(32)				--小宠物名字
	local attr_list = {}
	attr_list.maxhp = MsgAdapter.ReadInt()							--属性(生命)
	attr_list.gongji = MsgAdapter.ReadInt()							--属性(攻击)
	attr_list.fangyu = MsgAdapter.ReadInt()							--属性(防御)
	attr_list.mingzhong = MsgAdapter.ReadInt()						--属性(命中)
	attr_list.shanbi = MsgAdapter.ReadInt()							--属性(闪避)
	attr_list.baoji = MsgAdapter.ReadInt()							--属性(暴击)
	attr_list.jianren = MsgAdapter.ReadInt()						--属性(抗暴)
	single_pet.attr_list = attr_list
	single_pet.baoshi_active_time = MsgAdapter.ReadUInt()		--上次饱食度满的时间戳
	single_pet.feed_degree = MsgAdapter.ReadShort()			--饱食度
	single_pet.interact_times = MsgAdapter.ReadShort()			--互动次数
	single_pet.feed_level = MsgAdapter.ReadShort()				--喂养等级
	single_pet.reserve_sh = MsgAdapter.ReadShort()

	single_pet.point_list = {}									--强化点列表
	for i=1, GameEnum.LITTLEPET_QIANGHUAPOINT_CURRENT_NUM do
		local grid_value_list = {}
		for i=1, GameEnum.LITTLEPET_QIANGHUAGRID_MAX_NUM  do
			local qiang_hua_item = {}
			qiang_hua_item.arrt_type = MsgAdapter.ReadShort()		--强化格子的数值类型
			qiang_hua_item.grid_index = MsgAdapter.ReadShort()		--格子索引
			qiang_hua_item.attr_value = MsgAdapter.ReadInt()		--数值
			grid_value_list[i] = qiang_hua_item
		end
		single_pet.point_list[i] = grid_value_list
	end

	single_pet.equipment_llist = {}							--装备列表(玩具)
	for i=1, GameEnum.LITTLEPET_EQUIP_INDEX_MAX_NUM do
		local single_equip = {}
		single_equip.equipment_id = MsgAdapter.ReadUShort()				--玩具id
		single_equip.level = MsgAdapter.ReadShort()						--玩具积分(等级)
		single_pet.equipment_llist[i] = single_equip
	end

	return single_pet
end

--操作请求
CSLittlePetREQ = CSLittlePetREQ or BaseClass(BaseProtocolStruct)
function CSLittlePetREQ:__init()
	self.msg_type = 8001
	self.opera_type = 0			--操作类型
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSLittlePetREQ:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

CSLittlePetRename = CSLittlePetRename or BaseClass(BaseProtocolStruct)
function CSLittlePetRename:__init()
	self.msg_type = 8002
	self.index = 0
	self.pet_name = ""
end

function CSLittlePetRename:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.index)
	MsgAdapter.WriteStrN(self.pet_name, 32)
end

SCLittlePetAllInfo = SCLittlePetAllInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetAllInfo:__init()
	self.msg_type = 8050
end

function SCLittlePetAllInfo:Decode()
	self.score = MsgAdapter.ReadInt() 							--积分
	self.last_free_chou_timestamp = MsgAdapter.ReadUInt()		--免费抽奖次数
	self.interact_times = MsgAdapter.ReadShort()				--玩家互动次数
	self.pet_count = MsgAdapter.ReadShort()						--宠物个数

	self.pet_list = {}
	if self.pet_count == 0 then return end

	for i = 1, self.pet_count do
		self.pet_list[i] = LoadLittlePetSingleInfo()
	end
end

--单个宠物信息
SCLittlePetSingleInfo = SCLittlePetSingleInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetSingleInfo:__init()
	self.msg_type = 8051
end

function SCLittlePetSingleInfo:Decode()
	self.pet_single = LoadLittlePetSingleInfo()
end

SCLittlePetChangeInfo = SCLittlePetChangeInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetChangeInfo:__init()
	self.msg_type = 8052
end

function SCLittlePetChangeInfo:Decode()
	self.pet_index = MsgAdapter.ReadChar()			--宠物索引
	self.is_self = MsgAdapter.ReadChar()			--自己：伴侣 1:0
	self.point_type = MsgAdapter.ReadChar()			--强化点
	self.grid_index = MsgAdapter.ReadChar()			--格子索引
	local grid_item = {}
	grid_item.arrt_type = MsgAdapter.ReadShort()	--强化格子的数值类型
	grid_item.grid_index = MsgAdapter.ReadShort()	--格子索引
	grid_item.attr_value = MsgAdapter.ReadInt()		--数值
	self.gridvalue = grid_item						--格子的数值
end

--宠物商店抽奖
SCLittlePetChouRewardList = SCLittlePetChouRewardList or BaseClass(BaseProtocolStruct)
function SCLittlePetChouRewardList:__init()
	self.msg_type = 8053
end

function SCLittlePetChouRewardList:Decode()
	self.list_count = MsgAdapter.ReadInt()
	self.final_reward_seq = MsgAdapter.ReadInt()
	self.reward_list = {}
	if self.list_count == 0 then return end

	for i=1, self.list_count do
		local reward_item = {}
		reward_item.item_id = MsgAdapter.ReadInt()					-- 物品id
		reward_item.item_num = MsgAdapter.ReadShort()					-- 物品数量
		reward_item.is_bind = MsgAdapter.ReadShort()					-- 是否绑定
		self.reward_list[i] = reward_item
	end
end

SCLittlePetNotifyInfo = SCLittlePetNotifyInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetNotifyInfo:__init()
	self.msg_type = 8054
end

function SCLittlePetNotifyInfo:Decode()
	self.param_type = MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadUInt()
	self.param2 = MsgAdapter.ReadInt()
	self.param3 = MsgAdapter.ReadInt()
	self.param4 = MsgAdapter.ReadUInt()
end

SCLittlePetFriendInfo = SCLittlePetFriendInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetFriendInfo:__init()
	self.msg_type = 8055
end

function SCLittlePetFriendInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.pet_friend_list = {}
	if self.count == 0 then return end

	for i=1, self.count do
		local pet_friend = {}
		pet_friend.friend_uid = MsgAdapter.ReadInt()					--朋友id
		pet_friend.prof = MsgAdapter.ReadShort()						--头像
		pet_friend.sex = MsgAdapter.ReadShort()							--朋友的性别
		pet_friend.owner_name = MsgAdapter.ReadStrN(32)					--朋友的名字
		pet_friend.pet_num = MsgAdapter.ReadInt()						--宠物数量
		self.pet_friend_list[i] = pet_friend
	end
end

SCLittlePetUsingImg = SCLittlePetUsingImg or BaseClass(BaseProtocolStruct)
function SCLittlePetUsingImg:__init()
	self.msg_type = 8056
end

function SCLittlePetUsingImg:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.using_pet_id = MsgAdapter.ReadInt()
	self.pet_name = MsgAdapter.ReadStrN(32)
end

SCLittlePetFriendPetListInfo = SCLittlePetFriendPetListInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetFriendPetListInfo:__init()
	self.msg_type = 8057
end

function SCLittlePetFriendPetListInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.pet_list = {}
	if self.count == 0 then return end
	
	for i=1, self.count do
		local pet_item = {}
		pet_item.index = MsgAdapter.ReadInt()
		pet_item.pet_id = MsgAdapter.ReadInt()
		pet_item.info_type = MsgAdapter.ReadInt()
		pet_item.pet_name = MsgAdapter.ReadStrN(32)
		pet_item.interact_times = MsgAdapter.ReadShort()		--互动次数
		pet_item.reserve = MsgAdapter.ReadShort()
		self.pet_list[i] = pet_item
	end
end

SCLittlePetInteractLog = SCLittlePetInteractLog or BaseClass(BaseProtocolStruct)
function SCLittlePetInteractLog:__init()
	self.msg_type = 8058
end

function SCLittlePetInteractLog:Decode()
	self.count = MsgAdapter.ReadInt()
	self.log_list = {}
	if self.count == 0 then return end
	
	for i=1, self.count do
		local log_item = {}
		log_item.name = MsgAdapter.ReadStrN(32)
		log_item.pet_id = MsgAdapter.ReadInt()
		log_item.timestamp = MsgAdapter.ReadUInt()
		log_item.pet_name = MsgAdapter.ReadStrN(32)
		self.log_list[i] = log_item
	end
end

SCLittlePetRename = SCLittlePetRename or BaseClass(BaseProtocolStruct)
function SCLittlePetRename:__init()
	self.msg_type = 8059
end

function SCLittlePetRename:Decode()
	self.index = MsgAdapter.ReadShort()
	self.info_type = MsgAdapter.ReadShort()
	self.pet_name = MsgAdapter.ReadStrN(32)
end

SCConversionPetInfo = SCConversionPetInfo or BaseClass(BaseProtocolStruct)
function SCConversionPetInfo:__init()
	self.msg_type = 8061
end

function SCConversionPetInfo:Decode()
	self.can_received_pet_flag = MsgAdapter.ReadShort()					-- 可领取小宠物标记
	self.received_pet_flag = MsgAdapter.ReadShort()						-- 已经购买或领取宠物标记
	self.conversion_special_pet_end_timestamp = MsgAdapter.ReadUInt()	-- 兑换时间结束时间戳

	self.little_target_can_fetch_flag = MsgAdapter.ReadChar()			-- 小目标可领取标记
	self.little_target_have_fetch_flag = MsgAdapter.ReadChar()			-- 小目标已领取标记
	self.reserve_sh = MsgAdapter.ReadShort()
end

----------------------------------衣橱-------------------------------------
--衣橱操作请求
CSDressingRoomOpera = CSDressingRoomOpera or BaseClass(BaseProtocolStruct)
function CSDressingRoomOpera:__init()
	self.msg_type = 8070
	self.opera_type = 0
end

function CSDressingRoomOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
end

--所有套装部位激活信息
SCDressingRoomInfo = SCDressingRoomInfo or BaseClass(BaseProtocolStruct)
function SCDressingRoomInfo:__init()
	self.msg_type = 8071
end

function SCDressingRoomInfo:Decode()
	self.single_img_count = MsgAdapter.ReadInt() 						--套装数量
	self.info_list = {}													-- 套装部件激活情况列表
	if self.single_img_count == 0 then return end

	for i = 1, self.single_img_count do
		 self.info_list[i] = MsgAdapter.ReadInt()							
	end
end

--单个套装部位激活信息变化
SCDressingRoomSingleInfo = SCDressingRoomSingleInfo or BaseClass(BaseProtocolStruct)
function SCDressingRoomSingleInfo:__init()
	self.msg_type = 8072
end

function SCDressingRoomSingleInfo:Decode()
	self.is_active = MsgAdapter.ReadInt()				-- 1:0  激活:取消激活
	self.info = {}										-- 单个信息变化
	self.info.suit_index = MsgAdapter.ReadShort() 		-- 套装索引
	self.info.img_index = MsgAdapter.ReadShort()		-- 套装部位
end

-- 衣橱兑换操作请求
CSDressingRoomExchange = CSDressingRoomExchange or BaseClass(BaseProtocolStruct)
function CSDressingRoomExchange:__init()
	self.msg_type = 8073
	self.suit_index = -1 				-- 套装id 从0开始
	self.sub_index = -1 				-- 部位id 从0开始
end

function CSDressingRoomExchange:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.suit_index)
	MsgAdapter.WriteInt(self.sub_index)
end

--------------------------------衣橱结束-------------------------------------

--跨服挖矿操作请求
CSCrossMiningOperaReq = CSCrossMiningOperaReq or BaseClass(BaseProtocolStruct)
function CSCrossMiningOperaReq:__init()
	self.msg_type = 8750
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSCrossMiningOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param1)
	MsgAdapter.WriteUShort(self.param2)
	MsgAdapter.WriteUShort(self.param3)
end

--跨服挖矿信息
SCCrossMiningRoleInfo = SCCrossMiningRoleInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiningRoleInfo:__init()
	self.msg_type = 8751
end

function SCCrossMiningRoleInfo:Decode()
	self.role_id = MsgAdapter.ReadUInt()
	self.plat_id = MsgAdapter.ReadUInt()
	self.uuid =	self.role_id + (self.plat_id * (2 ^ 32))	--玩家唯一ID
	self.name = MsgAdapter.ReadStrN(32)						--玩家名字
	self.status = MsgAdapter.ReadInt()						--玩家状态
	self.combo_times = MsgAdapter.ReadInt()					--连击次数
	self.max_combo_times = MsgAdapter.ReadInt()				--最大连击次数
	self.used_mining_times = MsgAdapter.ReadShort()			--已经挖矿次数
	self.add_mining_times = MsgAdapter.ReadShort()			--增加挖矿次数
	self.score = MsgAdapter.ReadInt()						--玩家积分
	self.start_mining_timestamp = MsgAdapter.ReadUInt()		--玩家开始挖矿时间戳
	self.enter_scene_timestamp = MsgAdapter.ReadUInt()		--玩家进入场景时间戳

	self.hit_area_times_list = {}							--玩家挖中各区域次数列表（以挖矿类型为下标）
	for i = 1, MINING_AREA_TYPE_NUM do
		self.hit_area_times_list[i] = MsgAdapter.ReadInt()
	end

	self.mine_num_list = {}									--矿石个数列表（以矿石类型为下标）
	for i = 1, MINING_MINE_TYPE_NUM do
		self.mine_num_list[i] = MsgAdapter.ReadInt()
	end
	self.buy_buff_times = MsgAdapter.ReadInt() 					--购买次数
	self.buff_end_time = MsgAdapter.ReadUInt() 					--购买结束时间
	self.use_skill_times = MsgAdapter.ReadInt() 				--技能已使用次数
	self.next_skill_perfrom_timestamp = MsgAdapter.ReadUInt() 	--技能下一次可使用的时间
end

--跨服挖矿排行榜信息
SCCrossMiningRankInfo = SCCrossMiningRankInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiningRankInfo:__init()
	self.msg_type = 8752
end

function SCCrossMiningRankInfo:Decode()
	self.rank_item_count = MsgAdapter.ReadInt()
	self.rank_item_list = {} 								 --排行榜个数
	for i = 1, self.rank_item_count do
		local rank_item = {}
		rank_item.role_id = MsgAdapter.ReadUInt()
		rank_item.plat_id = MsgAdapter.ReadUInt()
		rank_item.uuid = rank_item.role_id + (rank_item.plat_id * (2 ^ 32))
		--rank_item.uuid = MsgAdapter.ReadLL()
		rank_item.name = MsgAdapter.ReadStrN(32)
		rank_item.score = MsgAdapter.ReadInt()
		table.insert(self.rank_item_list, rank_item)
	end
end

--跨服挖矿每次结果
SCCrossMiningResultInfo = SCCrossMiningResultInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiningResultInfo:__init()
	self.msg_type = 8753
end

function SCCrossMiningResultInfo:Decode()
	self.result_type = MsgAdapter.ReadInt() -- 结果时间类型
	self.mining_area = MsgAdapter.ReadInt() -- 该物品的区域类型（普通、高级、稀有） 
	self.param_1 = MsgAdapter.ReadInt()     -- 奖励物品的id
	self.param_2 = MsgAdapter.ReadInt() 	-- 数量
	self.param_3 = MsgAdapter.ReadInt() 	-- 是否绑定
end

--跨服挖矿采集物的信息
SCCrossMiningGatherPosInfo = SCCrossMiningGatherPosInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiningGatherPosInfo:__init()
	self.msg_type = 8754
end

function SCCrossMiningGatherPosInfo:Decode()
	self.pos_count 	= MsgAdapter.ReadInt()
	self.pos_list = {}
	for i = 1, self.pos_count do
		local gather_id = MsgAdapter.ReadInt()
		self.pos_list[i] = ProtocolStruct.ReadPosiInfo()
		self.pos_list[i].gather_id = gather_id
	end
end

--跨服挖矿采集物刷新提示
SCCrossMiningRefreshNotiy = SCCrossMiningRefreshNotiy or BaseClass(BaseProtocolStruct)
function SCCrossMiningRefreshNotiy:__init()
	self.msg_type = 8755
end

function SCCrossMiningRefreshNotiy:Decode()

end

--跨服挖矿强盗掠夺信息
SCCrossMiningBeStealedInfo = SCCrossMiningBeStealedInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiningBeStealedInfo:__init()
	self.msg_type = 8756
end

function SCCrossMiningBeStealedInfo:Decode()
	self.item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.item_count do
		local item = {}
		item.mining_type = MsgAdapter.ReadShort()
		item.num = MsgAdapter.ReadShort()
		table.insert(self.item_list, item)
	end
end

-- 溜宠物
SCLittlePetWalk = SCLittlePetWalk or BaseClass(BaseProtocolStruct)
function SCLittlePetWalk:__init()
	self.msg_type = 8060
end

function SCLittlePetWalk:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.reserve_sh = MsgAdapter.ReadShort()
	self.pet_id = MsgAdapter.ReadInt()				--id为0表示宠物消失
	self.pet_name = MsgAdapter.ReadStrN(32)	
end

SCRAOfflineSingleChargeInfo = SCRAOfflineSingleChargeInfo or BaseClass(BaseProtocolStruct)
function SCRAOfflineSingleChargeInfo:__init()
	self.msg_type = 8080
	self.reward_times = {}
	self.act_id = 0
	self.charge_max_value = 0
end

function SCRAOfflineSingleChargeInfo:Decode()
	self.act_id = MsgAdapter.ReadInt()
	self.charge_max_value = MsgAdapter.ReadInt()
	for i = 1, 10 do
		self.reward_times[i] = MsgAdapter.ReadInt()
	end
end

SCRAOfflineTotalChargeInfo = SCRAOfflineTotalChargeInfo or BaseClass(BaseProtocolStruct)
function SCRAOfflineTotalChargeInfo:__init()
	self.msg_type = 8081
	self.act_id = 0
	self.charge_max_value = 0
	self.reward_flag = {}
end

function SCRAOfflineTotalChargeInfo:Decode()
	self.act_id = MsgAdapter.ReadInt()
	self.charge_max_value = MsgAdapter.ReadInt()
	self.reward_flag = MsgAdapter.ReadInt()
end

SCPlantingTreeRankInfo = SCPlantingTreeRankInfo or BaseClass(BaseProtocolStruct)
function SCPlantingTreeRankInfo:__init()
	self.msg_type = 8082
	self.rank_type = 0
	self.rank_list_count = 0
	self.opera_times = 0
	self.rank_list = {}
end

function SCPlantingTreeRankInfo:Decode()
	self.rank_type = MsgAdapter.ReadInt()
	self.opera_times = MsgAdapter.ReadInt()
	self.rank_list_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, self.rank_list_count do
		local temp = {}
		temp.uid = MsgAdapter.ReadInt()
		temp.name = MsgAdapter.ReadStrN(32)
		temp.opera_items = MsgAdapter.ReadInt()
		temp.prof = MsgAdapter.ReadChar()
		temp.sex = MsgAdapter.ReadChar()
		local res = MsgAdapter.ReadShort()
		self.rank_list[i] = temp
	end
end

SCPlantingTreeTreeInfo = SCPlantingTreeTreeInfo or BaseClass(BaseProtocolStruct)
function SCPlantingTreeTreeInfo:__init()
	self.msg_type = 8083
	self.name = ""
	self.vanish_time = 0
	self.watering_times = 0
end

function SCPlantingTreeTreeInfo:Decode()
	self.name = MsgAdapter.ReadStrN(32)
	self.vanish_time = MsgAdapter.ReadUInt()
	self.watering_times = MsgAdapter.ReadInt()
end

SCPlantingTreeMiniMapInfo = SCPlantingTreeMiniMapInfo or BaseClass(BaseProtocolStruct)
function SCPlantingTreeMiniMapInfo:__init()
	self.msg_type = 8084
	self.tree_info_list = {}
end

function SCPlantingTreeMiniMapInfo:Decode()
	local count = MsgAdapter.ReadInt()

	for i = 1, count do
		local temp = {}
		temp.obj_id = MsgAdapter.ReadInt()
		temp.pos_x = MsgAdapter.ReadShort()
		temp.pos_y = MsgAdapter.ReadShort()
		
		self.tree_info_list[i] = temp
	end
end

SCRAChongzhiRankTwoInfo = SCRAChongzhiRankTwoInfo or BaseClass(BaseProtocolStruct)
function SCRAChongzhiRankTwoInfo:__init()
	self.msg_type = 8085
	self.chongzhi_num = 0
end

function SCRAChongzhiRankTwoInfo:Decode()
	self.chongzhi_num = MsgAdapter.ReadUInt()
end

SCRAConsumeGoldRankTwoInfo = SCRAConsumeGoldRankTwoInfo or BaseClass(BaseProtocolStruct)
function SCRAConsumeGoldRankTwoInfo:__init()
	self.msg_type = 8086
	self.consume_gold_num = 0
end

function SCRAConsumeGoldRankTwoInfo:Decode()
	self.consume_gold_num = MsgAdapter.ReadUInt()

end

--登陆奖励信息
SCRALoginActiveGiftInfo = SCRALoginActiveGiftInfo or BaseClass(BaseProtocolStruct)
function SCRALoginActiveGiftInfo:__init()
	self.msg_type = 8087
end

function SCRALoginActiveGiftInfo:Decode()
	self.is_today_login = MsgAdapter.ReadShort()
	self.total_login_days = MsgAdapter.ReadShort()
	self.login_fetch_flag = MsgAdapter.ReadUInt()  --登录奖励领取标记
	self.vip_fetch_flag= MsgAdapter.ReadUInt()       --vip登录奖励领取标记
	self.total_login_fetch_flag = MsgAdapter.ReadUInt()   --累计登录奖励领取标记
end
-----------疯狂礼包-----------------------
SCRACrazyGiftInfo = SCRACrazyGiftInfo or BaseClass(BaseProtocolStruct)
function SCRACrazyGiftInfo:__init()
    self.msg_type = 8088
    self.buy_times_list = {}   --每个礼包的购买信息
end

function SCRACrazyGiftInfo:Decode()
	self.buy_times_list = {}
	for i = 1, GameEnum.RA_CRAZY_GIFT_GIFT_TYPE_MAX  do
			self.buy_times_list[i] = {}
			for j= 1,GameEnum.RA_CRAZY_GIFT_CFG_COUNT_MAX do
			  self.buy_times_list[i][j] = MsgAdapter.ReadShort()
			end
	end









end