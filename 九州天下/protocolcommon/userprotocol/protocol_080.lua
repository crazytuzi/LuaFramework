local function LoadLittlePetGridValue()
	local t = {}
	t.arrt_type = MsgAdapter.ReadShort()					--强化格子的数值类型
	t.grid_index = MsgAdapter.ReadShort()					--格子索引
	t.attr_value = MsgAdapter.ReadInt()						--数值
	return t
end

local function LoadLittlePetPointValue()
	local t = {}
	t.gridvaluelist = {}
	for i=1,LITTLEPET_QIANGHUAGRID_MAX_NUM  do
		t.gridvaluelist[i] = LoadLittlePetGridValue()
	end
	return t
end

local function LoadLittlePetReWarValue()
	local t = {}
	t.item_id = MsgAdapter.ReadInt()			--物品id
	t.num = MsgAdapter.ReadShort()			--物品数量
	t.is_bind = MsgAdapter.ReadShort()			--是否绑定
	return t
end

local function LoadLittlePetFriendInfo()
	local t = {}
	t.friend_uid = MsgAdapter.ReadInt()						--朋友id
	t.prof = MsgAdapter.ReadShort()							--头像
	t.sex = MsgAdapter.ReadShort()							--朋友的sex
	t.owner_name = MsgAdapter.ReadStrN(32)					--朋友的名字
	t.pet_num = MsgAdapter.ReadInt()						--宠物数量
	return t
end

local function LoadLittlePetFriendPet()
	local t = {}
	t.index = MsgAdapter.ReadInt()
	t.pet_id = MsgAdapter.ReadInt()
	t.info_type = MsgAdapter.ReadInt()
	t.pet_name = MsgAdapter.ReadStrN(32)
	t.interact_times = MsgAdapter.ReadShort()
	t.reserve = MsgAdapter.ReadShort()
	return t
end

local function LoadLittlePetInteractLogStruct()
	local t = {}
	t.name = MsgAdapter.ReadStrN(32)
	t.pet_id = MsgAdapter.ReadInt()
	t.timestamp = MsgAdapter.ReadUInt()
	t.pet_name = MsgAdapter.ReadStrN(32)
	return t
end

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

CSLittlePetREQ = CSLittlePetREQ or BaseClass(BaseProtocolStruct)
--操作请求
function CSLittlePetREQ:__init()
	self.msg_type = 8001
	self.opera_type = 0
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

--跨服挖矿操作请求
CSCrossMiningOperaReq = CSCrossMiningOperaReq or BaseClass(BaseProtocolStruct)
function CSCrossMiningOperaReq:__init()
	self.msg_type = 8020
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
	self.msg_type = 8025
end

function SCCrossMiningRoleInfo:Decode()
	self.uuid =	MsgAdapter.ReadLL()							--玩家唯一ID
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
	for i = 1, GameEnum.MINING_AREA_TYPE_NUM do
		self.hit_area_times_list[i] = MsgAdapter.ReadInt()
	end

	self.mine_num_list = {}									--矿石个数列表（以矿石类型为下标）
	for i = 1, GameEnum.MINING_MINE_TYPE_NUM do
		self.mine_num_list[i] = MsgAdapter.ReadInt()
	end
end

--跨服挖矿排行榜信息
SCCrossMiningRankInfo = SCCrossMiningRankInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiningRankInfo:__init()
	self.msg_type = 8026
end

function SCCrossMiningRankInfo:Decode()
	self.rank_item_count = MsgAdapter.ReadInt()
	self.rank_item_list = {} 								 --排行榜个数
	for i = 1, self.rank_item_count do
		local rank_item = {}
		rank_item.uuid = MsgAdapter.ReadLL()
		rank_item.name = MsgAdapter.ReadStrN(32)
		rank_item.score = MsgAdapter.ReadInt()
		table.insert(self.rank_item_list, rank_item)
	end
end

--跨服挖矿每次结果
SCCrossMiningResultInfo = SCCrossMiningResultInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiningResultInfo:__init()
	self.msg_type = 8027
end

function SCCrossMiningResultInfo:Decode()
	self.result_type = MsgAdapter.ReadInt() --结果时间类型
	self.param_1 = MsgAdapter.ReadInt()
	self.param_2 = MsgAdapter.ReadInt()
	self.param_3 = MsgAdapter.ReadInt()
end

--跨服挖矿采集物的信息
SCCrossMiningGatherPosInfo = SCCrossMiningGatherPosInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiningGatherPosInfo:__init()
	self.msg_type = 8028
end

function SCCrossMiningGatherPosInfo:Decode()
	self.pos_count 	= MsgAdapter.ReadInt()
	self.pos_list = {}
	for i = 1, self.pos_count do
		self.pos_list[i] = ProtocolStruct.ReadPosiInfo()
	end
end

--跨服挖矿采集物刷新提示
SCCrossMiningRefreshNotiy = SCCrossMiningRefreshNotiy or BaseClass(BaseProtocolStruct)
function SCCrossMiningRefreshNotiy:__init()
	self.msg_type = 8029
end

function SCCrossMiningRefreshNotiy:Decode()

end

--跨服挖矿强盗掠夺信息
SCCrossMiningBeStealedInfo = SCCrossMiningBeStealedInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiningBeStealedInfo:__init()
	self.msg_type = 8030
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


SCLittlePetAllInfo = SCLittlePetAllInfo or BaseClass(BaseProtocolStruct)
function SCLittlePetAllInfo:__init()
	self.msg_type = 8050
end

function SCLittlePetAllInfo:Decode()
	self.score = MsgAdapter.ReadInt() 						--积分
	self.free_chou_timestamp = MsgAdapter.ReadUInt()		--免费抽奖次数
	self.interact_times = MsgAdapter.ReadShort()			--玩家互动次数
	self.pet_count = MsgAdapter.ReadShort()

	self.pet_list = {}
	if self.pet_count == 0 then
		return
	end
	for i = 1, self.pet_count do
		self.pet_list[i] = LoadLittlePetSingleInfo()
	end
end

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
	self.pet_index = MsgAdapter.ReadChar()		--宠物索引
	self.is_self = MsgAdapter.ReadChar()		--自己：伴侣 1:0
	self.point_type = MsgAdapter.ReadChar()		--强化点
	self.grid_index = MsgAdapter.ReadChar()		--格子索引
	self.gridvalue = LoadLittlePetGridValue()	--格子的数值
end

SCLittlePetChouRewardList = SCLittlePetChouRewardList or BaseClass(BaseProtocolStruct)
function SCLittlePetChouRewardList:__init()
	self.msg_type = 8053
end

function SCLittlePetChouRewardList:Decode()
	self.list_count = MsgAdapter.ReadInt()
	self.final_reward_seq = MsgAdapter.ReadInt()
	if self.list_count == 0 then
		return
	end
	self.reward_list = {}
	for i = 1, self.list_count do
		self.reward_list[i] = LoadLittlePetReWarValue()
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
	if self.count == 0 then
		return
	end
	self.pet_friend_list = {}
	for i=1,self.count do
		self.pet_friend_list[i] = LoadLittlePetFriendInfo()
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
	if self.count == 0 then
		return
	end
	self.pet_list = {}
	for i=1, self.count do
		self.pet_list[i] = LoadLittlePetFriendPet()
	end
end

SCLittlePetInteractLog = SCLittlePetInteractLog or BaseClass(BaseProtocolStruct)
function SCLittlePetInteractLog:__init()
	self.msg_type = 8058
end

function SCLittlePetInteractLog:Decode()
	self.count = MsgAdapter.ReadInt()
	if self.count == 0 then
		return
	end
	self.log_list = {}
	for i=1,self.count do
		self.log_list[i] = LoadLittlePetInteractLogStruct()
	end
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

SCLittlePetRename = SCLittlePetRename or BaseClass(BaseProtocolStruct)
function SCLittlePetRename:__init()
	self.msg_type = 8059
end

function SCLittlePetRename:Decode()
	self.index = MsgAdapter.ReadShort()
	self.info_type = MsgAdapter.ReadShort()
	self.pet_name = MsgAdapter.ReadStrN(32)
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