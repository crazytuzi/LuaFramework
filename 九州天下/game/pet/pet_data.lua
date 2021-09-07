-- LITTLE_PET_REQ_TYPE ={
-- 	LITTLE_PET_REQ_INTENSIFY_SELF = 0,						-- 强化自己宠物 param1 宠物索引，param2 强化点索引，param3格子索引
-- 	LITTLE_PET_REQ_INTENSIFY_LOVER = 1,						-- 强化爱人宠物 param1 宠物索引，param2 强化点索引，param3格子索引
-- 	LITTLE_PET_REQ_CHOUJIANG = 2,							-- 抽奖	param1  1:10
-- 	LITTLE_PET_REQ_RECYCLE = 3,								-- 回收	param1 物品id ，param2 物品数量， param3 是否绑定 1：0 默认绑定
-- 	LITTLE_PET_REQ_RELIVE = 4,								-- 放生	param1 宠物索引
-- 	LITTLE_PET_REQ_FEED = 5,								-- 喂养自己宠物	param1 宠物索引 , param2 自己：伴侣 1：0；
-- 	LITTLE_PET_REQ_PET_FRIEND_INFO = 6,						-- 宠友信息
-- 	LITTLE_PET_REQ_INTERACT = 7,							-- 互动 param1 宠物索引 param2 目标role uid param3 自己：伴侣 1：0
-- 	LITTLE_PET_REQ_EXCHANGE = 8,							-- 兑换 param1 兑换物品索引 param2 数量；
-- 	LITTLE_PET_REQ_CHANGE_PET = 9,                          -- 换宠 param1 宠物索引 param2 使用的物品id
-- 	LITTLE_PET_REQ_USING_PET = 10,							-- 使用形象 param1 形象id；
-- 	LITTLE_PET_REQ_FRIEND_PET_LIST = 11,					-- 好友小宠物列表；param1 朋友uid；
-- 	LITTLE_PET_REQ_INTERACT_LOG = 12,						-- 互动记录；
-- }

PET_MAX_QUALITY = 2

PET_FORGE_STAR = {
	GONG_JI = 1,
	QI_XUE = 2,
	FANG_YU = 3,
	MING_ZHONG = 4,
	SHAN_BI = 5,
	BAO_JI = 6,
	JIAN_REN = 7,
	TE_SHU = 8,
}

PET_CHOUJIANG_TYPE = {
	ONE = 1,
	TEN = 10,
}

-- LITTLE_PET_NOTIFY_INFO_TYPE ={
-- 	LITTLE_PET_NOTIFY_INFO_SCORE = 0,											--param1 积分信息
-- 	LITTLE_PET_NOTIFY_INFO_FREE_CHOU_TIMESTAMP = 1,								--param1 免费抽奖时间戳
-- 	LITTLE_PET_NOTIFY_INFO_INTERACT_TIMES = 2,									--param1 玩家互动次数
-- 	LITTLE_PET_NOTIFY_INFO_FEED_DEGREE = 3,										--param1 宠物索引 ， param2 饱食度，param3 自己：伴侣 ？ 1：0
-- 	LITTLE_PET_NOTIFY_INFO_PET_HU_DONG_TIMES = 4								--互动
-- }

PET_RUN_RANGE = {
	MIN = {X = -450 , Y = -300},
	MAX = {X = 450 , Y = 50},
}


PET_ROW = 5 --格子列数
PET_COLUMN = 3 --行数
PET_ALL_ROW = 25 --背包总列数

PetData = PetData or BaseClass()

function PetData:__init()
	if PetData.Instance then
		print_error("[PetData] Attemp to create a singleton twice !")
	end
	PetData.Instance = self
	self.all_info_list = {}
	self.change_pet_info = {}
	self.pet_friend_info = {}
	self.score_info = {}
	self.free_chou_jiang = {}
	self.pet_hu_dong = {}
	self.pet_friend_role_info = {}
	self.friend_pet_list_info = {}
	self.reward_list = {}
	self.is_mask = false
	self.is_free = false
	self.is_open_exchange = false
end

function PetData:__delete()
	PetData.Instance = nil
end

-- 获取小宠物other配置
function PetData:GetOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("littlepet_auto").other
end

-- 获取小宠物品质配置
function PetData:GetQualityCfg()
	return ConfigManager.Instance:GetAutoConfig("littlepet_auto").quality_cfg
end

-- 获取小宠物配置
function PetData:GetLittlePetCfg()
	return ConfigManager.Instance:GetAutoConfig("littlepet_auto").little_pet
end

-- 获取小宠物强化配置
function PetData:GetQianghuaCfg()
	return ConfigManager.Instance:GetAutoConfig("littlepet_auto").qianghua_cfg
end

-- 获取小宠物抽奖配置
function PetData:GetChoujiangCfg()
	return ConfigManager.Instance:GetAutoConfig("littlepet_auto").chou_cfg
end

-- 获取小宠物兑换配置
function PetData:GetExchangeCfg()
	return ConfigManager.Instance:GetAutoConfig("littlepet_auto").exchange
end

function PetData:OnSCLittlePetChouRewardList(protocol)
	self.reward_list = protocol.reward_list
end

function PetData:OnSCLittlePetAllInfo(protocol)
	local all_info_list = {}
	local classify_petList = self:ClassifyPetList(protocol.pet_list)
	all_info_list.pet_list = protocol.pet_list
	all_info_list.pet_list_mine = classify_petList.mine
	all_info_list.pet_list_lover = classify_petList.lover
	all_info_list.free_chou_timestamp = protocol.free_chou_timestamp
	all_info_list.pet_count_mine = #all_info_list.pet_list_mine
	all_info_list.pet_count_lover = #all_info_list.pet_list_lover
	all_info_list.pet_count = protocol.pet_count
	all_info_list.interact_times = protocol.interact_times
	all_info_list.score = protocol.score
	self.all_info_list = all_info_list
end

function PetData:OnSCLittlePetFriendInfo(protocol)
	local pet_friend_info = {}
	pet_friend_info.friend_count = protocol.count
	pet_friend_info.pet_friend_list = {}
	for i=1,pet_friend_info.friend_count do
		pet_friend_info.pet_friend_list[i] = {}
		pet_friend_info.pet_friend_list[i].friend_uid = protocol.pet_friend_list[i].friend_uid   			--朋友id
		pet_friend_info.pet_friend_list[i].prof = protocol.pet_friend_list[i].prof							--头像
		pet_friend_info.pet_friend_list[i].sex = protocol.pet_friend_list[i].sex							--朋友的sex
		pet_friend_info.pet_friend_list[i].owner_name = protocol.pet_friend_list[i].owner_name				--朋友的名字
		pet_friend_info.pet_friend_list[i].pet_num = protocol.pet_friend_list[i].pet_num 					--宠物数量
	end
	self.pet_friend_info = pet_friend_info
end

function PetData:OnSCLittlePetChangeInfo(protocol)
	self:ForgeMineOrLoverPet(self.all_info_list.pet_list, protocol)
	if protocol.is_self == 1 then
		self:ForgeMineOrLoverPet(self.all_info_list.pet_list_mine, protocol)
	elseif protocol.is_self == 0 then
		self:ForgeMineOrLoverPet(self.all_info_list.pet_list_lover, protocol)
	end
end

function PetData:ForgeMineOrLoverPet(list, protocol)
	for k,v in pairs(list) do
		if v.info_type == protocol.is_self and v.index == protocol.pet_index then
			v.point_list[protocol.point_type + 1].gridvaluelist[protocol.grid_index + 1] = protocol.gridvalue
			break
		end
	end
end

function PetData:OnSCLittlePetNotifyInfo(protocol)
	if protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_SCORE then
		self.all_info_list.score = protocol.param1
	elseif protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_FREE_CHOU_TIMESTAMP then
		self.free_chou_jiang = protocol.param1
		self.all_info_list.free_chou_timestamp = protocol.param1
		PetAchieveView.Instance:OpenFreeTimer()
		PetCtrl.Instance:GetView():SetRedPoint()
	elseif protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_INTERACT_TIMES then
		self.pet_hu_dong = protocol.param1
		self.all_info_list.interact_times = protocol.param1

	elseif protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_PET_HU_DONG_TIMES then
		local index = 0
		for k,v in pairs(self.friend_pet_list_info.pet_list) do
			if v.index == protocol.param2 then
				v.interact_times = protocol.param1
			end
		end
		PetParkView.Instance:GoFriendPark()
	elseif protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_FEED_DEGREE then
		local feed_info = {}
		feed_info.param1 = protocol.param1  --param1 宠物索引 ， param2 饱食度，param3 自己：伴侣 ？ 1：0
		feed_info.param2 = protocol.param2
		feed_info.param3 = protocol.param3
		feed_info.param4 = protocol.param4
		self:FeedPet(feed_info)
	end
end

function PetData:OnSCLittlePetRename(protocol)
	for k,v in pairs(self.all_info_list.pet_list) do
		if v.info_type == protocol.info_type and v.index == protocol.index then
			v.pet_name = protocol.pet_name
			break
		end
	end
	if protocol.info_type == 1 then
		self:RenameMineOrLoverPet(self.all_info_list.pet_list_mine, protocol.index, protocol.pet_name)
	else
		self:RenameMineOrLoverPet(self.all_info_list.pet_list_lover, protocol.index, protocol.pet_name)
	end
end

function PetData:OnSCLittlePetSingleInfo(protocol)

	for k,v in pairs(self.all_info_list.pet_list_mine) do
		if v.info_type == protocol.pet_single.info_type then
			if v.index == protocol.pet_single.index then
				table.remove(self.all_info_list.pet_list_mine, k)
				break
			else
				table.insert(self.all_info_list.pet_list_mine, protocol.pet_single)
				break
			end
		end
	end

	for k,v in pairs(self.all_info_list.pet_list_lover) do
		if v.info_type == protocol.pet_single.info_type then
			if v.index == protocol.pet_single.index then
				table.remove(self.all_info_list.pet_list_lover, k)
				break
			else
				table.insert(self.all_info_list.pet_list_lover, protocol.pet_single)
				break
			end
		end
	end

	for k,v in pairs(self.all_info_list.pet_list) do
		if v.index == protocol.pet_single.index then
			table.remove(self.all_info_list.pet_list, k)
			break
		else
			table.insert(self.all_info_list.pet_list, protocol.pet_single)
			break
		end
	end

	if protocol.pet_single.info_type == 1 and self.all_info_list.pet_count_mine == 0 then
		table.insert(self.all_info_list.pet_list_mine, protocol.pet_single)
	elseif protocol.pet_single.info_type == 0 and self.all_info_list.pet_count_lover == 0 then
		table.insert(self.all_info_list.pet_list_lover, protocol.pet_single)
	end

	if self.all_info_list.pet_count == 0 then
		table.insert(self.all_info_list.pet_list, protocol.pet_single)
	end

	self.all_info_list.pet_count = #self.all_info_list.pet_list
	self.all_info_list.pet_count_mine = #self.all_info_list.pet_list_mine
	self.all_info_list.pet_count_lover = #self.all_info_list.pet_list_lover

	-- print_error("######更新宠物信息#######",self.all_info_list.pet_list)
	if PetCtrl.Instance:GetView():GetShowIndex() == 1 then
		for k,v in pairs(self.all_info_list.pet_list) do
			if v.index == protocol.pet_single.index and v.info_type == protocol.pet_single.info_type then
				PetParkView.Instance:CancelPetMoveTimerByIndex(k)
				PetParkView.Instance:FlushPetByIndex(k)
				PetParkView.Instance:InitPetPosition(k)
				PetParkView.Instance:PetMove(k)
			end
		end
	end
end

function PetData:RenameMineOrLoverPet(list, index, name)
	for k,v in pairs(list) do
		if v.index == index then
			v.pet_name = name
			break
		end
	end
end

function PetData:FeedPet(feed_info)
	for k,v in pairs(self.all_info_list.pet_list) do
		if v.index == feed_info.param1 and v.info_type == feed_info.param3 then
			self.all_info_list.pet_list[k].feed_degree = feed_info.param2
			self.all_info_list.pet_list[k].baoshi_active_time = feed_info.param4
			if feed_info.param3 == 1 then
				self:FeedMineOrLoverPet(self.all_info_list.pet_list_mine, v.index, feed_info)
			elseif feed_info.param3 == 0 then
				self:FeedMineOrLoverPet(self.all_info_list.pet_list_lover, v.index, feed_info)
			end
			if PetCtrl.Instance:GetView():IsOpen() then
				PetParkView.Instance:FlushPetSliderByIndex(k)
			end
			break
		end
	end
end

function PetData:FeedMineOrLoverPet(list, index,feed_info)
	for k,v in pairs(list) do
		if v.index == index then
			list.feed_degree = feed_info.param2
			list.baoshi_active_time = feed_info.param4
			break
		end
	end
end

function PetData:OnSCLittlePetFriendPetListInfo(protocol)
	local friend_pet_list_info = {}
	friend_pet_list_info.pet_list = protocol.pet_list
	friend_pet_list_info.count = protocol.count
	self.friend_pet_list_info = friend_pet_list_info
end

function PetData:OnSCLittlePetInteractLog(protocol)
	local interact_info = {}
	interact_info.count = protocol.count
	interact_info.log_list = protocol.log_list
	function sortfun(a, b)
		return a.timestamp > b.timestamp
	end
	if interact_info.log_list ~= nil then
		table.sort(interact_info.log_list, sortfun)
	end
	self.interact_info = interact_info
end

function PetData:SetFriendId(friend_uid)
	self.friend_uid = friend_uid
end

function PetData:GetFriendId()
	return self.friend_uid
end

--获取互动信息
function PetData:GetInteractInfo()
	return self.interact_info
end

--获取宠友宠物数据
function PetData:GetFriendPetListInfo()
	return self.friend_pet_list_info
end

--获取奖励数据
function PetData:GetRewardList()
	return self.reward_list
end

--获取自身所有宠物信息
function PetData:GetAllInfoList()
	return self.all_info_list
end

--获得改变的宠物数据
function PetData:GetChangePetInfo()
	return self.change_pet_info
end

function PetData:GetMineOrLoverPet(info_type, index)
	if info_type == 1 then
		for k,v in pairs(self.all_info_list.pet_list_mine) do
			if v.info_type == info_type and v.index == index then
				return v
			end
		end
	elseif info_type == 0 then
		for k,v in pairs(self.all_info_list.pet_list_lover) do
			if v.info_type == info_type and v.index == index then
				return v
			end
		end
	end
end

--获得宠物朋友的个人信息
function PetData:GetShowFriendData()
	local all_friend_info = ScoietyData.Instance:GetFriendInfo()
	local pet_friend_role_info = {}
	for k,v in pairs(all_friend_info) do
		for m,n in pairs(self.pet_friend_info.pet_friend_list) do
			if v.user_id == n.friend_uid then
				pet_friend_role_info[#pet_friend_role_info + 1] = v
			end
		end
	end
	return pet_friend_role_info
end


-- 获取珍稀列表
function PetData:GetZhenXiList()
	local list = self:GetLittlePetCfg()
	local new_list = {}
	for k,v in pairs(list) do
		if v.quality_type == PET_MAX_QUALITY then
			new_list[#new_list + 1] = v.using_img_id
		end
	end
	return new_list
end

--随机获得需要展示的珍稀形象id
function PetData:GetShowRandomZhenXiUseImgId()
	local list = self:GetZhenXiList()
	return math.random(list[1],list[#list])
end

--获得需要展示的res_id
function PetData:GetShowResId(using_img_id)
	local temp_res_id = 0
	if using_img_id == 11 then
		temp_res_id = GODDESS_MODEL_ID_1
	elseif using_img_id == 12 then
		temp_res_id = GODDESS_MODEL_ID_2
	elseif using_img_id == 13 then
		temp_res_id = GODDESS_MODEL_ID_3
	elseif using_img_id == 14 then
		temp_res_id = GODDESS_MODEL_ID_4
	elseif using_img_id == 15 then
		temp_res_id = GODDESS_MODEL_ID_5
	end
	return temp_res_id
end

function PetData:GetRewardIndex(item_id, item_num)
	local list = self:GetChoujiangCfg()
	for k,v in pairs(list) do
		if v.reward_item.item_id == item_id and v.reward_item.num == item_num then
			return v.seq
		end
	end
end

function PetData:GetAngle(cur_index, reward_index)
	return (reward_index - cur_index)*(-45) - 2160
end

function PetData:GetSinglePetInfo(index,info_type)
	for k,v in pairs(self.all_info_list.pet_list) do
		if v.index == index and v.info_type == info_type then
			return v
		end
	end
end

function PetData:GetStarName(star_index)
	local name = ""
	if star_index == PET_FORGE_STAR.GONG_JI then
		name = "攻击"
	elseif star_index == PET_FORGE_STAR.QI_XUE then
		name = "气血"
	elseif star_index == PET_FORGE_STAR.FANG_YU then
		name = "防御"
	elseif star_index == PET_FORGE_STAR.MING_ZHONG then
		name = "命中"
	elseif star_index == PET_FORGE_STAR.SHAN_BI then
		name = "闪避"
	elseif star_index == PET_FORGE_STAR.BAO_JI then
		name = "暴击"
	elseif star_index == PET_FORGE_STAR.JIAN_REN then
		name = "抗暴"
	elseif star_index == PET_FORGE_STAR.TE_SHU then
		name = "全能"
	end
	return name
end

function PetData:GetSelectAttri(arrt_type)
	local name = ""
	if arrt_type == 0 then
		name = "生命"
	elseif arrt_type == 1 then
		name = "攻击"
	elseif arrt_type == 2 then
		name = "防御"
	elseif arrt_type == 3 then
		name = "命中"
	elseif arrt_type == 4 then
		name = "闪避"
	elseif arrt_type == 5 then
		name = "暴击"
	elseif arrt_type == 6 then
		name = "抗暴"
	elseif arrt_type == 7 then
		name = "全能"
	end
	return name
end

--得到需要展示的宠物列表
function PetData:GetShowPetInfoList(index)
	local info_list = {}
	for i=1,3 do
		if self.all_info_list.pet_list[3*index - 3 + i] == nil then
			info_list[i] = {}
		else
			info_list[i] = self.all_info_list.pet_list[3*index - 3 + i]
		end
	end
	return info_list
end

--获取单个品质一列
function PetData:GetSingleQuality(id)
	local pet_cfg = self:GetLittlePetCfg()
	local quality_type = -1
	for k,v in pairs(pet_cfg) do
		if v.id == id then
			quality_type = v.quality_type
		end
	end
	local quality_cfg = self:GetQualityCfg()
	for k,v in pairs(quality_cfg) do
		if v.quality_type == quality_type then
			return v
		end
	end
end

--根据grid_num返回4,5格子是否现实
function PetData:GetIsShowGrid(grid_num)
	local list = {}
	local show_4_grid = false
	local show_5_grid = false
	if grid_num == 4 then
		show_4_grid = true
	elseif grid_num == 5 then
		show_4_grid = true
		show_5_grid = true
	end
	list[1] = show_4_grid
	list[2] = show_5_grid
	return list
end

--根据星索引获得强化点索引
function PetData:GetStarCfgIndex(star_index)
	local index = 0
	if star_index == PET_FORGE_STAR.GONG_JI then
		index = 0
	elseif star_index == PET_FORGE_STAR.QI_XUE then
		index = 1
	elseif star_index == PET_FORGE_STAR.FANG_YU then
		index = 2
	elseif star_index == PET_FORGE_STAR.MING_ZHONG then
		index = 3
	elseif star_index == PET_FORGE_STAR.SHAN_BI then
		index = 4
	elseif star_index == PET_FORGE_STAR.BAO_JI then
		index = 5
	elseif star_index == PET_FORGE_STAR.JIAN_REN then
		index = 6
	elseif star_index == PET_FORGE_STAR.TE_SHU then
		index = 7
	end
	return index
end

--分类宠物信息(自己的，爱人的)
function PetData:ClassifyPetList(all_pet_list)
	local list = {}
	list.mine = {}
	list.lover = {}
	for k,v in pairs(all_pet_list) do
		if v.info_type == 1 then
			list.mine[#list.mine + 1] = v
		else
			list.lover[#list.lover + 1] = v
		end
	end
	return list
end

--获得宠物强化的最大值
function PetData:GetPetForgeMax(forge_list, arrt_type)
	local max_value = 0
	if arrt_type == 0 then
		max_value = forge_list.max_0
	elseif arrt_type == 1 then
		max_value = forge_list.max_1
	elseif arrt_type == 2 then
		max_value = forge_list.max_2
	elseif arrt_type == 3 then
		max_value = forge_list.max_3
	elseif arrt_type == 4 then
		max_value = forge_list.max_4
	elseif arrt_type == 5 then
		max_value = forge_list.max_5
	elseif arrt_type == 6 then
		max_value = forge_list.max_6
	end
	return max_value
end

function PetData:GetSingleQianghuaCfg(quality_type, point_type)
	local qianghua_cfg = self:GetQianghuaCfg()
	for k,v in pairs(qianghua_cfg) do
		if v.quality_type == quality_type and v.point_type == point_type then
			return v
		end
	end
end

function PetData:IsRichFeed(id,feed)
	return feed >= self:GetSingleQuality(id).max_feed_degree
end

--获得可换宠物
function PetData:GetPetCanActiveItem(quality_type)
	local pet_cfg = self:GetLittlePetCfg()
	local new_list = {}
	for k,v in pairs(pet_cfg) do
		if v.quality_type == quality_type then
			new_list[#new_list + 1] = v
		end
	end
	local new_list_2 = {}
	local bag_list = {} -- 无用代码
	for k,v in pairs(new_list) do
		for m,n in pairs(bag_list) do
			if v.active_item_id == n.item_id and n.num > 0 then
				new_list_2[#new_list_2 + 1] = n
			end
		end
	end
	return new_list_2
end

function PetData:GetPetCountByUserId(user_id)
	if self.pet_friend_info.pet_friend_list == nil then
		return nil
	end
	for k,v in pairs(self.pet_friend_info.pet_friend_list) do
		if v.friend_uid == user_id then
			return v.pet_num
		end
	end
end

--单个宠物配置
function PetData:GetSinglePetCfg(pet_id)
	for k,v in pairs(self:GetLittlePetCfg()) do
		if v.id == pet_id then
			return v
		end
	end
end

--获得需要展示的兑换集合
function PetData:GetShowExchangeList(index)
	local new_list = {}
	local show_list = {}
	for k,v in pairs(self:GetExchangeCfg()) do
		new_list[#new_list + 1] = v.exchage_item
	end
	for i=1,4 do
		show_list[i] = new_list[(index - 1)*4 + i]
	end

	return show_list
end

--单个兑换配置
function PetData:GetSingleExchangeCfg(item_id)
	local list = self:GetExchangeCfg()
	for k,v in pairs(list) do
		if v.exchage_item.item_id == item_id then
			return v
		end
	end
end

--通过索引获得仓库的格子对应的编号
function PetData:GetCellIndexList(cell_index)
	local cell_index_list = {}
	local x = math.floor(cell_index/PET_ROW)
	if x > 0 and x * PET_ROW ~= cell_index then
		cell_index = cell_index + PET_ROW * (PET_COLUMN - 1) * x
	elseif x > 1 and x * PET_ROW == cell_index then
		cell_index = cell_index + PET_ROW * (PET_COLUMN - 1) * (x - 1)
	end
	for i=1,5 do
		if i == 1 then
			cell_index_list[i] = cell_index + i - 1
		else
			cell_index_list[i] = cell_index + PET_ROW * (i - 1)
		end
	end
	return cell_index_list
end

--获取宠物品质颜色名字
function PetData:GetPetQualityName(pet_info)
	local quality_type = self:GetSingleQuality(pet_info.id).quality_type
	local name = self:GetSinglePetInfo(pet_info.index, pet_info.info_type).pet_name
	if quality_type == 0 then
		name = ToColorStr(name, COLOR.BLUE)
	elseif quality_type == 1 then
		name = ToColorStr(name, COLOR.PURPLE)
	elseif quality_type == 2 then
		name = ToColorStr(name, COLOR.ORANGE)
	end
	return name
end

function PetData:GetPetQualityNameById(pet_id, name)
	local quality_type = self:GetSingleQuality(pet_id).quality_type
	if quality_type == 0 then
		name = ToColorStr(name, COLOR.BLUE)
	elseif quality_type == 1 then
		name = ToColorStr(name, COLOR.PURPLE)
	elseif quality_type == 2 then
		name = ToColorStr(name, COLOR.ORANGE)
	end
	return name
end

--当前强化星的总战力
function PetData:GetStarPower(point_index,the_index)
	local attr = {}
	attr.gongji = 0
	attr.maxhp = 0
	attr.fangyu = 0
	attr.mingzhong = 0
	attr.shanbi = 0
	attr.baoji = 0
	attr.jianren = 0
	for k,v in pairs(self.all_info_list.pet_list[the_index].point_list[point_index + 1].gridvaluelist) do
		if v.arrt_type == 0 then
			attr.maxhp = attr.maxhp + v.attr_value
		elseif v.arrt_type == 1 then
			attr.gongji = attr.gongji + v.attr_value
		elseif v.arrt_type == 2 then
			attr.fangyu = attr.fangyu + v.attr_value
		elseif v.arrt_type == 3 then
			attr.mingzhong = attr.mingzhong + v.attr_value
		elseif v.arrt_type == 4 then
			attr.shanbi = attr.shanbi + v.attr_value
		elseif v.arrt_type == 5 then
			attr.baoji = attr.baoji + v.attr_value
		elseif v.arrt_type == 6 then
			attr.jianren = attr.jianren + v.attr_value
		--elseif v.arrt_type == 7 then
		end
	end

	return CommonDataManager.GetCapabilityCalculation(attr)
end

--获得peslist中的排序索引
function PetData:GetPetListIndex(info_type, index)
	for k,v in pairs(self.all_info_list.pet_list) do
		if v.info_type == info_type and v.index == index then
			return k
		end
	end
end

function PetData:GetIsMask()
	return self.is_mask
end

function PetData:SetIsMask(is_mask)
	self.is_mask = is_mask
end

--是否是放生操作
function PetData:IsFreeOperation()
	return self.is_free
end

function PetData:SetFreeOperation(is_free)
	self.is_free =is_free
end

--是否打开过兑换界面
function PetData:GetIsOpenedExchange()
	return self.is_open_exchange
end

function PetData:SetIsOpenedExchange(is_open)
	self.is_open_exchange = is_open
end

function PetData:GetExchangeRedPointStatus()
	if self.all_info_list.score then
		return (self.all_info_list.score >= 30 and not PetData.Instance:GetIsOpenedExchange())
	else
		return false
	end
end

function PetData:GetFreeRewardRedPointStatus()
	local all_pet_info = self:GetAllInfoList()
	local free_chou_interval_h = self:GetOtherCfg()[1].free_chou_interval_h
	local can_chest_time = all_pet_info.free_chou_timestamp
	if can_chest_time then
		can_chest_time = can_chest_time + (free_chou_interval_h * 3600)
		local server_time = math.floor(TimeCtrl.Instance:GetServerTime())

		if can_chest_time < server_time then
			return true
		end
	end
	return false
end

function PetData:GetRedPointStatus()
	return self:GetExchangeRedPointStatus() or self:GetFreeRewardRedPointStatus()
end

function PetData:IsPetType(item_id)
	if not item_id then return false end

	for k, v in pairs(self:GetLittlePetCfg()) do
		if v.active_item_id == item_id then
			return true
		end
	end
	return false
end

function PetData:GetReturnItemNum(pet_info)
	local base_num = self:GetSinglePetCfg(pet_info.id).return_item.num --基础返回数
	local add_num = 0
	for k,v in pairs(pet_info.point_list) do  --强化过的格子返回10
		for k1,v1 in pairs(v.gridvaluelist) do
			if v1.attr_value ~= 0 then
				add_num = add_num + self:GetOtherCfg()[1].fangsheng_grid_add_num
			end
		end
	end

	return base_num + add_num
end