LittlePetData = LittlePetData or BaseClass(BaseEvent)

LITTLE_PET_TYPE = {			-- 服务端定义
	MINE_PET = 1,			-- 我的宠物
	LOVER_PET = 0, 			-- 对方的宠物
}

LITTLE_PET_TOY_PART_ITEM_TYPE = {
	[1] = GameEnum.E_TYPE_LITTLEPET_1, 			--小宠物玩具1
	[2] = GameEnum.E_TYPE_LITTLEPET_2, 			--小宠物玩具2
	[3] = GameEnum.E_TYPE_LITTLEPET_3, 			--小宠物玩具3
	[4] = GameEnum.E_TYPE_LITTLEPET_4, 			--小宠物玩具4
}

LITTLE_PET_CHOUJIANG_TYPE = {
	ONE = 1,
	TEN = 10,
}

local PERSON_CULTIVATE_MAX_NUM = 6
local COMMON_LITTLE_PET_MAX_NUM = 5

function LittlePetData:__init()
	if LittlePetData.Instance then
		print_error("[LittlePetData] Attempt to create singleton twice!")
		return
	end
	LittlePetData.Instance = self

	self.cfg = ConfigManager.Instance:GetAutoConfig("littlepet_auto") or {}
	--宠物喂养
	local feed_cfg = self:GetFeedStuffCfg()
	self.feed_stuff_cfg = ListToMap(feed_cfg,"feed_level")
	self.up_level_materials = self.cfg.little_pet_equipment_uplevel or {}
	self.up_level_materials_list = ListToMapList(self.up_level_materials,"equip_index")

	self.all_info_list = {}
	self.mine_pet_list = {}
	self.lover_pet_list = {}
	self.shop_chou_jiang_reward_list = {}
	self.is_can_play_chou_jiang_ani = true
	self.shop_warehouse_list = {}
	self.little_pet_warehouse_list = {}
	self.reward_seq = -1
	self.toy_auto_buy_flag = false
	self.cur_take_off_pet_id = 0 					-- 当前卸掉的宠物id
	self.cur_scene_show_pet_id = 0 					-- 当前场景显示的宠物id

	RemindManager.Instance:Register(RemindName.LittlePetHome, BindTool.Bind(self.GetLittlePetHomeRemind, self))
	RemindManager.Instance:Register(RemindName.LittlePetFeed, BindTool.Bind(self.GetLittlePetFeedRemind, self))
	RemindManager.Instance:Register(RemindName.LittlePetToy, BindTool.Bind(self.GetLittlePetToyRemind, self))
	RemindManager.Instance:Register(RemindName.LittlePetShop, BindTool.Bind(self.GetLittlePetShopRemind, self))
	RemindManager.Instance:Register(RemindName.LittlePetWarehouse, BindTool.Bind(self.GetLittlePetWarehouseRemind, self))
end

function LittlePetData:__delete()
	LittlePetData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.LittlePetHome)
	RemindManager.Instance:UnRegister(RemindName.LittlePetFeed)
	RemindManager.Instance:UnRegister(RemindName.LittlePetToy)
	RemindManager.Instance:UnRegister(RemindName.LittlePetShop)
	RemindManager.Instance:UnRegister(RemindName.LittlePetWarehouse)
end

-------------------------------配置相关---------------------------------
-- 获取小宠物other配置
function LittlePetData:GetOtherCfg()
	return self.cfg.other or {}
end

-- 获取小宠物品质配置
function LittlePetData:GetQualityCfg()
	return self.cfg.quality_cfg or {}
end

-- 获取小宠物配置
function LittlePetData:GetLittlePetCfg()
	return self.cfg.little_pet or {}
end

-- 获取小宠物强化配置
function LittlePetData:GetQianghuaCfg()
	return self.cfg.qianghua_cfg or {}
end

-- 获取小宠物抽奖配置
function LittlePetData:GetChoujiangCfg()
	return self.cfg.chou_cfg or {}
end

-- 获取小宠物兑换配置
function LittlePetData:GetExchangeCfg()
	return self.cfg.exchange or {}
end

-- 获取宠物喂养配置
function LittlePetData:GetFeedStuffCfg()
	return self.cfg.little_pet_feed or {}
end

-- 获取小宠物商店显示配置
function LittlePetData:GetShopShowCfg()
	return self.cfg.shop_show or {}
end

-- 获取特殊小宠物配置
function LittlePetData:GetSpecialLittlePetCfg()
	return self.cfg.conversion_special_pet_need_pet[1]
end
-----------------------------配置相关结束-------------------------------

-----------------------------协议信息-----------------------------

--所有宠物格子信息
function LittlePetData:OnSCLittlePetAllInfo(protocol)
	self.mine_pet_list = {}
	self.lover_pet_list = {}
	local all_info_list = {}
	all_info_list.score = protocol.score											-- 当前积分
	all_info_list.count = protocol.pet_count 										-- 宠物个数(自己+对方)
	all_info_list.last_free_chou_timestamp = protocol.last_free_chou_timestamp		-- 免费抽奖时间戳
	self.all_info_list = all_info_list

	if self.all_info_list.count == 0 then return end

	local pet_list = protocol.pet_list 												-- 宠物列表(自己+对方)
	self:ClassifyPetList(pet_list)
end

--单个宠物格子信息(更新宠物列表)
function LittlePetData:OnSCLittlePetSingleInfo(protocol)
	self:ClassifyPetList({protocol.pet_single})
end

--抽奖返回
function LittlePetData:OnSCLittlePetChouRewardList(protocol)
	self.shop_chou_jiang_reward_list = protocol.reward_list
	self.reward_seq = protocol.final_reward_seq
end

function LittlePetData:OnSCLittlePetNotifyInfo(protocol)
	if protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_SCORE and self.all_info_list then
		self.all_info_list.score = protocol.param1				--积分信息
	elseif protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_FREE_CHOU_TIMESTAMP and self.all_info_list then
		self.all_info_list.last_free_chou_timestamp = protocol.param1			--免费时间信息
	end
end

-- 分类宠物信息（自己装备宠物列表和伴侣装备宠物列表分开）
function LittlePetData:ClassifyPetList(all_pet_list)
	if nil == all_pet_list and nil == next(all_pet_list) then
		return
	end

	local flag = false
	for k,v in pairs(all_pet_list) do
		if v.info_type == LITTLE_PET_TYPE.MINE_PET then
			for k1,v1 in pairs(self.mine_pet_list) do
				if v1.index == v.index then			-- 遍历列表，该Index有宠物则覆盖，没有则插入
					if v.id == 0 then				-- id为0表示卸下
						self.mine_pet_list[k1] = nil
					else
						self.mine_pet_list[k1] = v
					end
					flag = true
					break
				end
			end
			if flag == false then
				table.insert(self.mine_pet_list, v)
			end
		elseif v.info_type == LITTLE_PET_TYPE.LOVER_PET then
			for k1,v1 in pairs(self.lover_pet_list) do
				if v1.index == v.index then
					if v.id == 0 then				-- id为0表示卸下
						self.lover_pet_list[k1] = nil
					else
						self.lover_pet_list[k1] = v
					end
					flag = true
					break
				end
			end
			if flag == false then
				table.insert(self.lover_pet_list, v)
			end
		end
		flag = false
	end
end

-- 特殊宠物协议信息返回
function LittlePetData:OnSCConversionPetInfo(protocol)
	self.can_received_pet_flag = bit:d2b(protocol.can_received_pet_flag)						-- 收集小宠物标记
	self.received_pet_flag = protocol.received_pet_flag											-- 已经购买或领取宠物标记
	self.conversion_special_pet_end_timestamp = protocol.conversion_special_pet_end_timestamp	-- 兑换时间结束时间戳

	self.little_target_can_fetch_flag = protocol.little_target_can_fetch_flag					-- 小目标可领取标记
	self.little_target_have_fetch_flag = protocol.little_target_have_fetch_flag					-- 小目标已领取标记
end

-----------------------------协议信息结束-----------------------------

---------------------------------家园-----------------------------------
-- 初始化家园地图
function LittlePetData:InitMap(width, height)
	self.home_map = {}

	self.tile_len = 10
	self.all_width = width
	self.all_height = height
	self.width_len = math.floor(width / self.tile_len)
	self.height_len = math.floor(height / self.tile_len)

	self.mask_table = {}							-- 阻挡信息，二维数组
	self.start_pos = {x = 0, y = 0}					-- 起点
	self.end_pos = {x = 0, y = 0}					-- 终点
	self.open_list = {}								-- 开放列表
	self.map = {}									-- 寻路信息缓存
	self.ran_list = {}
	self.way_list = {}
	self.pet_hinder_list = {}

	-- 初始化障碍区
	local mask_list = {}
	for i = 0, self.width_len do
		if mask_list[i] == nil then
			mask_list[i] = {}
		end
		for j = 0, self.height_len do

			if i < 2 or i > 95 then
				mask_list[i][j] = 1
			end

			if j < 10 or j > 53 then
				mask_list[i][j] = 1
			end

			if i < 70 and j < 25 then
				mask_list[i][j] = 1
			end

			if i > 52 and i < 72 then
				if j > 50 then
					mask_list[i][j] = 1
				end
			end

		end
	end

	-- 取得可移动的区域
	for i = 0, self.width_len - 1 do
		for j = 0, self.height_len - 1 do
			if self.way_list[i] == nil then
				self.way_list[i] = {}
			end

			self.way_list[i][j] = {}
			self.way_list[i][j].x = i
			self.way_list[i][j].y = j
			if mask_list[i] ~= nil and mask_list[i][j] ~= nil and mask_list[i][j] == 1 then
				self.way_list[i][j].is_block = true
			else
				self.way_list[i][j].is_block = false
				if self.ran_list[i] == nil then
					self.ran_list[i] = {}
				end
				self.ran_list[i][j] = {}
				self.ran_list[i][j].x = i
				self.ran_list[i][j].y = j
				if i > 20 then
					self.ran_list[i][j].other_black = true
				else
					self.ran_list[i][j].other_black = false
				end
			end
		end
	end
end

function LittlePetData:PointInfo()
	return {
		x = 0,
		y = 0,
		block = false,
		g = 0,
		h = 0,
		parent = nil,
		dir = 0,
	}
end

function LittlePetData:Reset()
	self.open_list = {}

	self.map = {}
	for x = 0, self.width_len-1 do
		self.map[x] = {}
		for y = 0, self.height_len-1 do
			self.map[x][y] = self:PointInfo()
		end
	end
end

function LittlePetData:IsBlock(x, y)
	return self.way_list[x][y].is_block
end

-- 根据坐标计算出对应的格子下标
function LittlePetData:GetIndexByPos(pos)
	local pos_t = {x = 0, y = 0}
	if self.tile_len == nil or pos == nil then
		return pos_t
	end

	pos_t.x = math.abs(math.floor((pos.x + self.all_width * 0.5) / self.tile_len))
	pos_t.y = math.abs(math.floor((pos.y + self.all_height * 0.5) / self.tile_len))

	return pos_t
end

-- 根据格子下标计算出对应的坐标
function LittlePetData:GetPosByIndex(index)
	local pos = {x = 0, y = 0}
	if self.tile_len == nil or index == nil then
		return pos
	end
	pos.x = index.x  * self.tile_len + self.tile_len * 0.5 - self.all_width * 0.5
	pos.y = index.y  * self.tile_len + self.tile_len * 0.5 - self.all_height * 0.5

	return pos
end

-- 随机获取可移动位置
function LittlePetData:GetPetHinderList(start_index, pet_index)
	local pos = {x = 0, y = 0}
	if self.ran_list == nil or self.width_len == nil or self.height_len == nil then
		return pos
	end
	self.pet_hinder_list[pet_index] = start_index
	local check_list = TableCopy(self.ran_list)

	for k,v in pairs(self.pet_hinder_list) do
		if v ~= nil then
			local x_value = -10
			for i = 1, 21 do
				local y_value = -15
				for j = 1, 31 do
					if check_list[v.x + x_value] ~= nil then
						check_list[v.x + x_value][v.y + y_value] = nil
					end
					y_value = y_value + 1
				end
				x_value = x_value + 1
			end
		end
	end

	if start_index ~= nil and check_list[start_index.x] ~= nil then
		check_list[start_index.x][start_index.y] = nil
	end

	local can_list = {}
	for k,v in pairs(check_list) do
		for k1,v1 in pairs(v) do
			if v1 ~= nil then
				table.insert(can_list, {x = v1.x, y = v1.y})
			end
		end
	end

	if #can_list == 0 then
		return pos
	end
	local pos_index_1 = math.random(1, #can_list * pet_index)
	local read_index = pos_index_1 % #can_list
	read_index = read_index <=0 and 1 or read_index
	read_index = read_index >= #can_list and #can_list or read_index
	self.pet_hinder_list[pet_index] = can_list[read_index]
	return can_list[read_index]
end

-- 寻路
function LittlePetData:FindWay(start_pos, end_pos)
	if start_pos.x < 0 or start_pos.x >= self.width_len or start_pos.y < 0 or start_pos.y >= self.height_len then
		return false
	end
	if end_pos.x < 0 or end_pos.x >= self.width_len or end_pos.y < 0 or end_pos.y >= self.height_len then
		return false
	end

	self:Reset()
 
	self.start_pos = start_pos
	self.end_pos = end_pos

	if self:IsBlock(start_pos.x, start_pos.y) or self:IsBlock(end_pos.x, end_pos.y) then
		return false
	end

	-- 起点 终点 相同，直接返回
	if start_pos.x == end_pos.x and start_pos.y == end_pos.y then
		return false
	end

	local cur_pos = {x = start_pos.x, y = start_pos.y}
	for loops1 = 1, 1000000 do
		-- 将当前点置为已经检查过
		self.map[cur_pos.x][cur_pos.y].block = true
		self.map[cur_pos.x][cur_pos.y].x = cur_pos.x
		self.map[cur_pos.x][cur_pos.y].y = cur_pos.y

		local offset_list = {{1, 0, false}, {1, 1, true},{0, 1, false}, {-1, 1, true}, {-1, 0, false}, {-1, -1, true},{0, -1, false}, {1, -1, true}}	-- 八个方向
		for k, v in pairs(offset_list) do
			local x, y = cur_pos.x + v[1], cur_pos.y + v[2]
			if x >= 0 and x < self.width_len and y >= 0 and y < self.height_len and not self.map[x][y].block and not self:IsBlock(x, y) then
				-- 终点
				if x == end_pos.x and y == end_pos.y then
					self.map[x][y].parent = self.map[cur_pos.x][cur_pos.y]
					self.map[x][y].x = x
					self.map[x][y].y = y
					self.map[x][y].dir = k
					return true
				end

				-- 检查相邻位置加入open列表
				self:CalcWeight(x, y, cur_pos, v[3], k)
			end
		end

		local cant_find = true
		for loops2 = 1, 10000 do
			local next_open = table.remove(self.open_list, 1)
			if nil == next_open then break end

			if not self.map[next_open.x][next_open.y].block then
				cur_pos.x = next_open.x
				cur_pos.y = next_open.y
				cant_find = false
				break
			end
		end

		-- 开放列表为空（没有找到路径）
		if cant_find then return false end
	end

	return false
end

function LittlePetData:CalcWeight(next_x, next_y, cur_pos, is_slash, next_dir)
	local next_p = self.map[next_x][next_y]
	local cur_p = self.map[cur_pos.x][cur_pos.y]
	local g = cur_p.g + (is_slash and 14142 or 10000)

	if is_slash then
		if self:IsBlock(next_x, cur_pos.y) or self:IsBlock(cur_pos.x, next_y) then
			return
		end
	end

	if next_p.g == 0 or next_p.g > g then
		next_p.g = g
		next_p.parent = cur_p
		next_p.dir = next_dir						-- 记录当前与parent的dir

		if next_p.h == 0 then
			next_p.h = 10000 * self:CalH(next_x, next_y)
		end

		local f = next_p.h + next_p.g
		table.insert(self.open_list, {x = next_x or 0, y = next_y or 0, f = f or 0,})
	end
end

function LittlePetData:CalH(pos_x, pos_y)
	local x_dis = math.abs(pos_x - self.end_pos.x)
	local y_dis = math.abs(pos_y - self.end_pos.y)

	return x_dis + y_dis;
end

-- 取得到目标点的移动路径，路径为格子
function LittlePetData:GetMovePathPoint(start_pos, end_pos)
	local pos_path_list = {}
	if nil ~= self.map[end_pos.x][end_pos.y] then
		local getpath
		getpath = function (pos_point)
			if pos_point.parent ~= nil and "table" == type(pos_point.parent) then
				getpath(pos_point.parent)
			end
			table.insert(pos_path_list, {x = pos_point.x, y = pos_point.y, dis = pos_point.dir})
		end
		getpath(self.map[end_pos.x][end_pos.y])
	end

	return pos_path_list
end

-- 通过移动的格子路径，取得相对应的移动坐标，除了起始点，其他格子都走中间
function LittlePetData:GetReadMoveList(index_list, start_pos)
	local move_list = {}
	if index_list == nil then
		return move_list
	end

	local z = 0
	for i = 2 ,#index_list - 1 do
		local pos = Vector3(0, 0, z)
		pos.x = index_list[i].x  * self.tile_len + self.tile_len * 0.5 - self.all_width * 0.5
		pos.y = index_list[i].y  * self.tile_len + self.tile_len * 0.5 - self.all_height * 0.5
		table.insert(move_list, pos)
	end

	local end_index = index_list[#index_list]
	local end_pos = Vector3(0, 0, z)
	minx = end_index.x * self.tile_len - self.all_width * 0.5
	maxx = minx + self.tile_len * 0.5
	end_pos.x = math.random(minx, maxx)

	miny = end_index.y * self.tile_len 	- self.all_height * 0.5
	maxy = miny + self.tile_len * 0.5
	end_pos.y = math.random(miny, maxy)
	table.insert(move_list, end_pos)

	return move_list
end

--得到背包中宠物玩具列表
function LittlePetData:GetBagLittlePetToyDataList()
	local equip_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	local pet_toy_list = {}

	for _, v in pairs(equip_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg
			and GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type
			and EquipData.IsLittlePetToyType(item_cfg.sub_type) then
			table.insert(pet_toy_list, v)
		end
	end

	return pet_toy_list
end

-- 根据类型获取背包中宠物物品
function LittlePetData:GetBagLittlePetDataList()
	local bag_item_data_list = ItemData.Instance:GetBagItemDataList()
	local pet_list = {}

	for _, v in pairs(bag_item_data_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg
			and GameEnum.ITEM_BIGTYPE_EXPENSE == big_type
			and item_cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET
			and item_cfg.icon_id ~= self:GetSpecialLittlePetItemID() then
				table.insert(pet_list, v)
		end
	end

	return pet_list
end

-- 获取背包中的回收列表
function LittlePetData:GetLittlePetRecycleData()
	local pet_toy_list = self:GetBagLittlePetToyDataList()
	local pet_list = self:GetBagLittlePetDataList()
	local sort_pet_toy_list = self:GetBagBestLittlePet(pet_toy_list)
	local sort_pet_list = self:GetBagBestLittlePet(pet_list)
	for i,v in ipairs(sort_pet_toy_list) do
		table.insert(sort_pet_list, v)
	end
	return sort_pet_list
end

-- 宠物排序
function LittlePetData:GetBagBestLittlePet(data_list)
	if nil == next(data_list) then
		return {}
	end

	local list = {}
	local temp_list = {}
	local color = -1
	local temp_color = -1
	local list_lengh = 0
	local last_sort_list = {}
	for k, v in pairs(data_list) do
		table.insert(temp_list, v)
	end

	table.sort(temp_list, function (a, b)
		if not a then
			a = {item_id = 0}
			return a.item_id > b.item_id
		end
		if not b then
			b = {item_id = 0}
			return a.item_id > b.item_id
		end
		local item_cfg_a = ItemData.Instance:GetItemConfig(a.item_id)
		local item_cfg_b = ItemData.Instance:GetItemConfig(b.item_id)
		if item_cfg_a.click_use ~= item_cfg_b.click_use then
			return item_cfg_a.click_use > item_cfg_b.click_use
		end
		if item_cfg_a.color ~= item_cfg_b.color then
			return item_cfg_a.color > item_cfg_b.color
		end
		if a.item_id == b.item_id and a.param and b.param and a.param.strengthen_level ~= b.param.strengthen_level then
			return a.param.strengthen_level > b.param.strengthen_level
		end
		if a.item_id == b.item_id and a.param and b.param and a.param.param1 ~= b.param.param1 then
			return a.param.param1 > b.param.param1
		end

		if item_cfg_a.bag_type ~= item_cfg_b.bag_type then
			return item_cfg_a.bag_type < item_cfg_b.bag_type
		end

		return a.item_id > b.item_id
	end)

	return temp_list
end

-- 获取背包宠物列表
function LittlePetData:GetLittlePetHomePackageBestList()
	local pet_list = self:GetBagLittlePetDataList()
	local best_pet_list = self:GetBagBestLittlePet(pet_list)
	return best_pet_list or nil
end

function LittlePetData:GetLittlePetIDByItemID(item_id)
	local little_pet_cfg = self:GetLittlePetCfg()
	for k,v in pairs(little_pet_cfg) do
		if v.active_item_id == item_id then
			return v.id or 0
		end
	end
	return 0
end

function LittlePetData:GetLittlePetItemIDByID(id)
	local little_pet_cfg = self:GetLittlePetCfg()
	if nil == next(little_pet_cfg) or nil == little_pet_cfg[id] then
		return 0
	end

	return little_pet_cfg[id].active_item_id or 0
end

function LittlePetData:GetMyLittlePetIDbyIndex(index)
	for k,v in pairs(self.mine_pet_list) do
		if v.index == index then
			return v.id
		end
	end
	return 0
end

function LittlePetData:PackageCheckIsLowerQuality(selected_item_id, equipped_index)
	local equipped_id = self:GetMyLittlePetIDbyIndex(equipped_index)
	-- id等于0即没有装备，直接返回false
	if equipped_id == 0 then
		return false
	end
	local equipped_item_id = self:GetLittlePetItemIDByID(equipped_id)
	local selected_item_cfg = ItemData.Instance:GetItemConfig(selected_item_id)
	local equipped_item_cfg = ItemData.Instance:GetItemConfig(equipped_item_id)

	if nil == selected_item_cfg or nil == equipped_item_cfg then
		return false
	end
	return selected_item_cfg.color < equipped_item_cfg.color
end

-- 计算宠物基础战力(id_flag为false表示传入item_id，id_flag为true表示传入id)
function LittlePetData:CalPetBaseFightPower(id_flag, id)
	local little_pet_attr_cfg = self:GetLittlePetCfg()
	if nil == next(little_pet_attr_cfg) then
		return 0
	end

	local pet_id = id_flag and id or self:GetLittlePetIDByItemID(id)
	local single_little_pet_attr_cfg = little_pet_attr_cfg[pet_id]
	local attr_list = {}

	if nil == single_little_pet_attr_cfg then
		return 0
	end
	-- 设置属性列表
	attr_list.maxhp = single_little_pet_attr_cfg.attr_value_0 or 0
	attr_list.gongji = single_little_pet_attr_cfg.attr_value_1 or 0
	attr_list.fangyu = single_little_pet_attr_cfg.attr_value_2 or 0

	local fight_power = CommonDataManager.GetCapabilityCalculation(attr_list)
	return fight_power
end

-- 特殊小宠物基础战力（自身战力和装备小宠物战力加成）
function LittlePetData:GetSpecialLittlePetPower(lover_flag)
	local special_little_pet_item_id = self:GetSpecialLittlePetItemID()
	local special_little_pet_id = LittlePetData.Instance:GetLittlePetIDByItemID(special_little_pet_item_id)
	local little_pet_cfg = self:GetLittlePetCfg()
	if next(little_pet_cfg) == nil or little_pet_cfg[special_little_pet_id] == nil then
		return 0
	end

	local attr_addition = little_pet_cfg[special_little_pet_id].attr_addition

	-- 已装备宠物基础战力
	local equip_list = self:GetHomeEquipPetDataList(lover_flag)
	local equip_pet_power = 0
	for k,v in pairs(equip_list) do
		if v ~= nil and v.item_id ~= special_little_pet_item_id then
			local base_power = self:CalPetBaseFightPower(true, v.id)
			equip_pet_power = equip_pet_power + base_power * attr_addition / 10000
		end
	end

	-- 特殊宠物战力
	local special_pet_base_power = self:CalPetBaseFightPower(true, special_little_pet_id)

	equip_pet_power = math.ceil(equip_pet_power + special_pet_base_power)
	return equip_pet_power
end

-- 计算宠物基础战力，区分普通小宠物和特殊小宠物
-- lover_flag为false计算自己的特殊小宠物，为true计算伴侣的特殊小宠物
-- id_flag为false表示传入item_id，id_flag为true表示传入id)
function LittlePetData:GetLittlePetBasePower(lover_flag, id_flag, id)
	local pet_id = id_flag and id or self:GetLittlePetIDByItemID(id)
	local special_pet_id = self:GetSpecialLittlePetID()
	if pet_id ~= special_pet_id then
		return self:CalPetBaseFightPower(id_flag, id)
	elseif pet_id == special_pet_id then
		return self:GetSpecialLittlePetPower(lover_flag)
	else
		return 0
	end
end

-- 获取小宠物基本属性
function LittlePetData:GetLittlePetBaseAttr(item_id)
	local little_pet_attr_cfg = self:GetLittlePetCfg()
	if nil == next(little_pet_attr_cfg) then
		return {}
	end
	local pet_id = self:GetLittlePetIDByItemID(item_id)
	local single_little_pet_attr_cfg = little_pet_attr_cfg[pet_id]
	local attr_list = {}

	if nil == single_little_pet_attr_cfg then
		return {}
	end
	-- 设置属性列表
	attr_list.maxhp = single_little_pet_attr_cfg.attr_value_0 or 0
	attr_list.gongji = single_little_pet_attr_cfg.attr_value_1 or 0
	attr_list.fangyu = single_little_pet_attr_cfg.attr_value_2 or 0

	return attr_list
end

function LittlePetData:GetEquipPetCfgDataList(lover_flag)
	local pet_list = lover_flag and self.lover_pet_list or self.mine_pet_list
	local pet_cfg = self:GetLittlePetCfg()
	local equip_pet_list = {}
	for k,v in pairs(pet_list) do
		if nil == pet_cfg[v.id] then
			return {}
		end
		local temp_list = {}
		temp_list.lover_flag = lover_flag or false
		temp_list.id = v.id or 0
		temp_list.index = v.index or 0
		temp_list.feed_level = v.feed_level or 0
		temp_list.item_id = pet_cfg[v.id].active_item_id or 0
		temp_list.name = pet_cfg[v.id].name or ""
		temp_list.res_id = pet_cfg[v.id].using_img_id or 0
		temp_list.info_type = lover_flag and LITTLE_PET_TYPE.LOVER_PET or LITTLE_PET_TYPE.MINE_PET
		equip_pet_list[v.index + 1] = temp_list
	end
	return equip_pet_list
end

function LittlePetData:GetAllEquipPetCfgDataList()
	local my_equip_pet_list = self:GetEquipPetCfgDataList(false)
	local lover_equip_pet_list = self:GetEquipPetCfgDataList(true)
	for k,v in pairs(lover_equip_pet_list) do
		table.insert(my_equip_pet_list, v)
	end
	return my_equip_pet_list
end

function LittlePetData:GetHomeEquipPetDataList(lover_flag)
	local home_list = {}
	local equip_pet_list = self:GetEquipPetCfgDataList(lover_flag)
	for k,v in pairs(equip_pet_list) do
		home_list[v.index + 1] = v
	end
	return home_list
end

function LittlePetData:GetRecycleDataByItemID(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return 0, 0
	end
	local recycle_score = item_cfg.recyclget or 0
	local recycle_type = item_cfg.recycltype or 0
	return recycle_score, recycle_type
end

function LittlePetData:GetLittlePetResIDByItemID(item_id)
	local little_pet_cfg = self:GetLittlePetCfg()
	for k,v in pairs(little_pet_cfg) do
		if item_id == v.active_item_id then
			return v.using_img_id or 0
		end
	end
	return 0
end

-- 家园选择框红点
function LittlePetData:CheckHomeSelectedBoxIsShowRedPoint(index)
	local bag_pet_list = self:GetBagLittlePetDataList()
	local my_equip_list = self:GetHomeEquipPetDataList(false)

	-- 背包没有小宠物，不提醒
	if #bag_pet_list <= 0 then
		return false
	end

	-- 当前无装备小宠物，背包有小宠物，红点提醒
	if my_equip_list[index] == nil and #bag_pet_list > 0 then
		return true
	end

	-- 当前有小宠物，背包有更高品质的小宠物，红点提醒
	if my_equip_list[index] ~= nil then
		local current_power = self:CalPetBaseFightPower(true, my_equip_list[index].id)
		for k,v in pairs(bag_pet_list) do
			local bag_item_power = self:CalPetBaseFightPower(false, v.item_id)
			if bag_item_power > current_power then
				return true
			end
		end
	end

	return false
end

-- 家园红点
function LittlePetData:GetLittlePetHomeRemind()
	for i = 1, COMMON_LITTLE_PET_MAX_NUM do
		if self:CheckHomeSelectedBoxIsShowRedPoint(i) then
			return 1
		end
	end

	-- 称号红点
	if self:GetLittleTargetCanFetchFlag() == 1 and self:GetLittleTargetHaveFetchFlag() == false then
		return 1
	end

	-- 特殊小宠物红点
	if self:GetSpecialPetRedPoint() == 1 then
		return 1
	else
		return 0
	end
end

-- 特殊宠物红点
function LittlePetData:GetSpecialPetRedPoint()
	local is_can_get = LittlePetData.Instance:GetIsCanReceivePetFlag(0)
	local is_got = LittlePetData.Instance:GetIsReceivedFlag()
	local is_active = LittlePetData.Instance:GetSpecialPetIsActive()

	if is_active == 1 then
		return 0
	end

	if is_can_get == 1 and is_got ~= 1 then
		return 1
	end

	if is_got == 1 and self:GetSpecialPetIsInBag() == 1 then
		return 1
	end

	return 0
end

-- 判断当前item是否比自身装备宠物的战力值高
function LittlePetData:CheckIsHigherPowerPet(item_id)
	local select_power = self:CalPetBaseFightPower(false, item_id)
	local my_equip_list = self:GetHomeEquipPetDataList(false)

	for i = 1, COMMON_LITTLE_PET_MAX_NUM do
		if my_equip_list[i] == nil then
			return true
		else
			local equip_power = self:CalPetBaseFightPower(true, my_equip_list[i].id)
			if equip_power < select_power then
				return true
			end
		end
	end
	return false
end

-- 判断当前item是否比自身装备玩具的战力值高
function LittlePetData:CheckIsHigherPowerToy(item_id, item_cfg, big_type)
	if nil == item_cfg and GameEnum.ITEM_BIGTYPE_EQUIPMENT ~= big_type then
		return true
	end

	for k,v in pairs(self.mine_pet_list) do
		for k1,v1 in pairs(v.equipment_llist) do
			if LITTLE_PET_TOY_PART_ITEM_TYPE[k1] == item_cfg.sub_type then
				if v1.equipment_id == 0 then
					return true
				else
					local equip_item_cfg = ItemData.Instance:GetItemConfig(v1.equipment_id)
					if nil == equip_item_cfg then
						return true
					end
					if equip_item_cfg.color < item_cfg.color then
						return true
					end
				end
			end
		end
	end
	return false
end

-- 判断是否比自身装备的宠物或宠物玩具等级高
function LittlePetData:CheckIsHigherEquip(item_id)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return false, 0
	end

	-- 判断宠物item
	if GameEnum.ITEM_BIGTYPE_EXPENSE == big_type then
		return self:CheckIsHigherPowerPet(item_id), item_cfg.color
	end

	-- 判断宠物玩具item
	if GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type then
		return self:CheckIsHigherPowerToy(item_id, item_cfg), item_cfg.color
	end

	return false, item_cfg.color
end

-- 比较宠物item与对应格子上宠物的战力
function LittlePetData:ComparePetWithEquippedPet(item_id, equip_index)
	local my_equip_list = self:GetHomeEquipPetDataList(false)
	if nil == my_equip_list[equip_index] then
		return true
	end
	local equipped_pet = my_equip_list[equip_index].id
	local equipped_power = self:CalPetBaseFightPower(true, equipped_pet)
	local item_power = self:CalPetBaseFightPower(false, item_id)
	return item_power > equipped_power
end

-- 获取所有的战力
function LittlePetData:GetAllFightPower()
	local power = 0
	for k,v in pairs(self.mine_pet_list) do
		local temp_power = 0
		local data = v
		local base_power = LittlePetData.Instance:GetLittlePetBasePower(false, true, data.id)
		local item_id = self:GetLittlePetItemIDByID(data.id)
		local feed_power = LittlePetData.Instance:GetFeedAttrCfgByIndex(data.index, data.info_type, item_id)
		local toy_power = LittlePetData.Instance:GetSinglePetToyPower(data.index, data.info_type)
		temp_power = base_power + feed_power + toy_power
		power = power + temp_power
	end
	for k,v in pairs(self.lover_pet_list) do
		local temp_power = 0
		local data = v
		local item_id = self:GetLittlePetItemIDByID(data.id)
		local base_power = LittlePetData.Instance:GetLittlePetBasePower(true, true, data.id)
		local feed_power = LittlePetData.Instance:GetFeedAttrCfgByIndex(data.index, data.info_type, item_id)
		local toy_power = LittlePetData.Instance:GetSinglePetToyPower(data.index, data.info_type)
		temp_power = base_power + feed_power + toy_power
		power = power + temp_power
	end
	
	return power
end

-- 免费活动结束时间戳
function LittlePetData:GetSpecialPetRemainFreeTime()
	local remain_time = self.conversion_special_pet_end_timestamp or 0
	if remain_time == 0 then
		return 0
	end
	local now_time = TimeCtrl.Instance:GetServerTime()
	return remain_time - now_time
end

-- 特殊小宠物是否可领取
function LittlePetData:GetIsCanReceivePetFlag(index)
	if self.can_received_pet_flag == nil then
		return 0
	end
	return self.can_received_pet_flag[32 - index] or 0
end

-- 特殊小宠物是否已获得（取得物品卡未使用）
function LittlePetData:GetIsReceivedFlag()
	if self.received_pet_flag == nil then
		return 0
	end
	if self.received_pet_flag == 1 or self:GetSpecialPetIsInBag() == 1 or self:GetSpecialPetIsActive() == 1 then
		return 1
	else
		return 0
	end
end

function LittlePetData:GetIsReceivedFlagFromServer()
	return self.received_pet_flag or 0
end

-- 特殊小宠物是否已激活
function LittlePetData:GetSpecialPetIsActive()
	local little_pet_home_list = self:GetHomeEquipPetDataList(false)
	if nil == next(little_pet_home_list) then
		return 0
	end
	if little_pet_home_list[GameEnum.LITTLE_PET_SPECIAL_INDEX] ~= nil then
		return 1
	else
		return 0
	end
end

-- 伴侣特殊小宠物是否已激活
function LittlePetData:GetLoverSpecialPetIsActive()
	local lover_pet_home_list = self:GetHomeEquipPetDataList(true)
	if nil == next(lover_pet_home_list) then
		return 0
	end
	if lover_pet_home_list[GameEnum.LITTLE_PET_SPECIAL_INDEX] ~= nil then
		return 1
	else
		return 0
	end
end

-- 获得特殊小宠物的item_id
function LittlePetData:GetSpecialLittlePetItemID()
	local conversion_special_pet_need_pet = LittlePetData.Instance:GetSpecialLittlePetCfg()
	if conversion_special_pet_need_pet == nil or next(conversion_special_pet_need_pet) == nil then
		return 0
	end
	return conversion_special_pet_need_pet.active_item_id or 0
end

-- 获取特殊小宠物id
function LittlePetData:GetSpecialLittlePetID()
	local item_id = self:GetSpecialLittlePetItemID()
	local id = self:GetLittlePetIDByItemID(item_id)
	return id
end

-- 设置特殊小宠物的基础信息（配置表）
function LittlePetData:SetSpecialLittlePetAllCfg()
	local other_cfg = self:GetOtherCfg()
	local special_pet_cfg = self:GetSpecialLittlePetCfg()
	local little_pet_cfg = self:GetLittlePetCfg()
	if next(other_cfg) == nil or special_pet_cfg == nil or next(little_pet_cfg) == nil then
		return
	end

	local temp_list = {}
	temp_list.buy_special_pet_need_gold = other_cfg[1].buy_special_pet_need_gold or 0
	temp_list.can_conversion_time_h = other_cfg[1].can_conversion_time_h or 0
	temp_list.index = special_pet_cfg.index or 0
	temp_list.pet_id_list = {}
	temp_list.pet_id_list.pet_id_1 = special_pet_cfg.pet_id_1 or 0
	temp_list.pet_id_list.pet_id_2 = special_pet_cfg.pet_id_2 or 0
	temp_list.pet_id_list.pet_id_3 = special_pet_cfg.pet_id_3 or 0
	temp_list.pet_id_list.pet_id_4 = special_pet_cfg.pet_id_4 or 0
	temp_list.pet_id_list.pet_id_5 = special_pet_cfg.pet_id_5 or 0
	temp_list.active_item_id = special_pet_cfg.active_item_id or 0

	local special_pet_id = self:GetLittlePetIDByItemID(special_pet_cfg.active_item_id)
	local special_little_pet_cfg = little_pet_cfg[special_pet_id]
	if special_little_pet_cfg == nil then
		return
	end
	temp_list.using_img_id = special_little_pet_cfg.using_img_id or 0
	temp_list.attr_list = {}
	temp_list.attr_list.attr_value_0 = special_little_pet_cfg.attr_value_0 or 0
	temp_list.attr_list.attr_value_1 = special_little_pet_cfg.attr_value_1 or 0
	temp_list.attr_list.attr_value_2 = special_little_pet_cfg.attr_value_2 or 0
	temp_list.attr_list.attr_addition = special_little_pet_cfg.attr_addition or 0

	self.special_pet_all_cfg = temp_list
end

-- 获取特殊小宠物的所有基础信息
function LittlePetData:GetSpecialLittlePetAllCfg()
	if self.special_pet_all_cfg == nil then
		self:SetSpecialLittlePetAllCfg()
	end

	return self.special_pet_all_cfg
end

-- 设置小目标称号的信息（配置表）
function LittlePetData:SetTargetTitleAllCfg()
	local other_cfg = self:GetOtherCfg()
	if next(other_cfg) == nil then
		return
	end

	local temp_list = {}
	temp_list.little_target_activate_reward = other_cfg[1].little_target_activate_reward
	temp_list.little_target_buy_need_gold = other_cfg[1].little_target_buy_need_gold or 0
	local title_cfg = ItemData.Instance:GetItemConfig(temp_list.little_target_activate_reward.item_id)
	if title_cfg == nil then
		return 0
	end
	temp_list.title_id = title_cfg.param1 or 0
	temp_list.power = title_cfg.power or 0
	temp_list.time_stamp = self:GetSpecialPetRemainFreeTime()

	self.target_title_all_cfg = temp_list
end

-- 获取特殊小宠物的所有基础信息
function LittlePetData:GetTargetTitleAllCfg()
	if self.target_title_all_cfg == nil then
		self:SetTargetTitleAllCfg()
	end

	return self.target_title_all_cfg
end

-- 背包是否有特殊小宠物激活卡
function LittlePetData:GetSpecialPetIsInBag()
	local item_id = self:GetSpecialLittlePetItemID()
	local index = ItemData.Instance:GetItemIndex(item_id)
	if index < 0 then
		return 0
	end

	return 1
end

-- 小宠物小目标奖励是否可领取
function LittlePetData:GetLittleTargetCanFetchFlag()
	return self.little_target_can_fetch_flag
end

-- 小宠物小目标奖励是否已经领取
function LittlePetData:GetLittleTargetHaveFetchFlag()
	return self.little_target_have_fetch_flag == 1 or self:GetLittlePetTitleIsInBag() or self:GetSpecialPetIsActive() == 1
end

function LittlePetData:GetLittlePetTitleIsInBag()
	local target_title_cfg = self:GetTargetTitleAllCfg()
	if target_title_cfg == nil then
		return false
	end
	local bag_index = ItemData.Instance:GetItemIndex(target_title_cfg.little_target_activate_reward.item_id)
	return bag_index ~= -1
end

-------------------------------家园结束---------------------------------

---------------------------------喂养-----------------------------------

--根据喂养等级获取宠物喂养配置
function LittlePetData:GetFeedLevelCfg(feed_level)
	if nil == feed_level then 
		return
	end
	return self.feed_stuff_cfg[feed_level]
end

--根据喂养等级获取喂养材料
function LittlePetData:GetGridUpgradeStuffDataListByLevel(feed_level)
	local stuff_list = {}
	local cfg = self:GetFeedLevelCfg(feed_level)
	if cfg == nil then
		return stuff_list
	end

	for i=0,3 do
		local data = {}
		data.item_id = cfg["stuff_id_"..i]
		data.need_stuff_num = cfg["stuff_num_"..i]
		data.is_bind = 0
		stuff_list[i] = data
	end
	return stuff_list
end

--通过获取宠物喂养属性战力,index为宠物下标,is_lover代表是自己的还是伴侣的
function LittlePetData:GetFeedAttrCfgByIndex(index, is_lover, item_id)
	local all_power = 0
	if next(self.lover_pet_list) == nil and next(self.mine_pet_list) == nil then
		return 0
	end
	--通过index得到喂养等级
	local feed_level = 0
	if is_lover == 0 and self.lover_pet_list ~= nil and next(self.lover_pet_list) ~= nil then
		for k,v in pairs(self.lover_pet_list) do
			if index == v.index then
				feed_level = v.feed_level
			end
		end
	end
	if is_lover == 1 and self.mine_pet_list ~= nil and next(self.mine_pet_list) ~= nil then 
		for k,v in pairs(self.mine_pet_list) do
			if index == v.index then
				feed_level = v.feed_level
			end
		end
	end
	local feed_cfg = self:GetFeedLevelCfg(feed_level)
	local percent = feed_cfg.base_attr_add_per / 10000
	--计算小宠物基础属性百分比加成
	local pet_base_add_power = self:GetSinglePetFeedBaseAddPower(item_id, percent)
	local attr_list = {}
	--设置属性列表
	attr_list.maxhp = feed_cfg.max_hp or 0
	attr_list.fangyu = feed_cfg.fangyu or 0
	attr_list.gongji = feed_cfg.gongji or 0
	local fight_power = CommonDataManager.GetCapabilityCalculation(attr_list) 
	all_power = pet_base_add_power + fight_power
	return all_power
end

function LittlePetData:GetSinglePetFeedBaseAddPower(item_id, percent)
	local base_capability = 0
	local pet_attr = self:GetLittlePetBaseAttr(item_id)
	if nil == pet_attr or nil == pet_attr.maxhp then
		return base_capability
	end
	local base_attr = {}
	base_attr.maxhp = pet_attr.maxhp * percent or 0
	base_attr.fangyu = pet_attr.fangyu * percent or 0
	base_attr.gongji = pet_attr.gongji * percent or 0
	base_capability = CommonDataManager.GetCapabilityCalculation(base_attr)
	return base_capability
end

function LittlePetData:GetFeedAttrCfgByLevel(feed_level)
	local feed_cfg = {}
	feed_cfg = self:GetFeedLevelCfg(feed_level)
	return feed_cfg
end

function LittlePetData:GetMaxFeedLevel()
	local max_feed_level = 0
	if self.feed_stuff_cfg ~= nil and next(self.feed_stuff_cfg) then 
		max_feed_level = self.feed_stuff_cfg[#self.feed_stuff_cfg].feed_level 
	end
	return max_feed_level
end

--根据等级判断是否可以喂养宠物
function LittlePetData:CanFeedPetByFeedLevel(feed_level)
	local feed_flag = 1
	local max_feed_level = self:GetMaxFeedLevel()
	if feed_level < max_feed_level then
		local stuff_list = self:GetGridUpgradeStuffDataListByLevel(feed_level)
		if stuff_list ~= nil and next(stuff_list) ~= nil then
			for i=1,4 do
				if stuff_list[i-1] then
					local data = stuff_list[i-1]
					local stuff_num = ItemData.Instance:GetItemNumInBagById(data.item_id)
					if data.need_stuff_num > stuff_num then
						feed_flag = 0       --不能喂养
					end
				end
			end
		end
	else
		feed_flag = 0     --不能喂养
	end
	return feed_flag
end

--判断是否有宠物可以喂养
function LittlePetData:GetLittlePetFeedRemind()
	local equip_pet_list = self:GetSortAllPetList()
	local feed_flag = 0
	if equip_pet_list == nil or next(equip_pet_list) == nil then
		return feed_flag
	end
	for k,v in pairs(equip_pet_list) do
		if v.feed_level then
			feed_flag = self:CanFeedPetByFeedLevel(v.feed_level)
			if feed_flag == 1 then        --只要有一只宠物可以喂养， 就返回1
				return feed_flag 
			end
		end
	end
	return feed_flag
end

-------------------------------喂养结束---------------------------------

---------------------------------玩具-----------------------------------
--排序宠物列表
function LittlePetData:GetSortAllPetList()
	local all_pet_list = {}
	local mine_pet_list = self.mine_pet_list or {}
	local lover_pet_list = self.lover_pet_list or {}

	for k,v in pairs(mine_pet_list) do
		table.insert(all_pet_list, v)
	end

	for k,v in pairs(lover_pet_list) do
		table.insert(all_pet_list, v)
	end

	if #all_pet_list > 1 then
		table.sort(all_pet_list, LittlePetData.PetSort("info_type", "index"))
	end

	return all_pet_list
end

--排序方法
function LittlePetData.PetSort(sort_key_name1, sort_key_name2)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] > b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] < b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a > order_b end

		if a[sort_key_name2] < b[sort_key_name2] then
	   		order_a = order_a + 1000
		elseif a[sort_key_name2] > b[sort_key_name2] then
			order_b = order_b + 1000
		end

		return order_a > order_b
	end
end

--得到背包中宠物玩具列表(根据玩具部位1~4)
function LittlePetData:GetBagLittlePetToyDataListByToyPart(toy_part)
	local equip_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	local pet_toy_list = {}

	for _, v in pairs(equip_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg and GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type
			and item_cfg.sub_type == LITTLE_PET_TOY_PART_ITEM_TYPE[toy_part] then
			table.insert(pet_toy_list, v)
		end
	end

	if #pet_toy_list > 1 then
		--按品质排序
		pet_toy_list = self:GetBagBestLittlePet(pet_toy_list)
	end

	return pet_toy_list
end

--记录宠物玩具是否自动购买状态
function LittlePetData:SetToyUpLevelAutoBuyFlag(flag)
	self.toy_auto_buy_flag = flag
end

function LittlePetData:GetToyUpLevelAutoBuyFlag()
	return self.toy_auto_buy_flag
end

--单个玩具部位的配置
function LittlePetData:GetSingleEquipToyCfgByIndexAndLevel(equip_index, level)
	local single_toy_cfg = {}
	if nil == next(self.up_level_materials_list) or nil == self.up_level_materials_list[equip_index] or
	 nil == self.up_level_materials_list[equip_index][level] then
	 	return single_toy_cfg
	end

	single_toy_cfg = self.up_level_materials_list[equip_index][level]

	return single_toy_cfg
end

--单个玩具部位可升的最大等级
function LittlePetData:GetToySinglePartMaxLevelByIndex(equip_index)
	local max_level = 0
	if nil == equip_index or nil == next(self.up_level_materials_list) or nil == self.up_level_materials_list[equip_index - 1] then
	 	return max_level
	end

	local part_list = self.up_level_materials_list[equip_index - 1]
	max_level = part_list[#part_list] and part_list[#part_list].level or 0

	return max_level
end

--单个宠物玩具装备信息
function LittlePetData:GetSinglePetEquipInfo(pet_index, pet_info_type)
	local data_list = {}
	if nil == pet_info_type or pet_info_type < 0 or nil == pet_index then return data_list end

	local pet_info_list = pet_info_type == LITTLE_PET_TYPE.MINE_PET and self.mine_pet_list or self.lover_pet_list
	for k,v in pairs(pet_info_list) do
		if v.index == pet_index then
			data_list = v.equipment_llist
		end
	end

	return data_list
end

--单个宠物玩具部位装备信息
function LittlePetData:GetSinglePetEquipPartInfo(pet_index, pet_info_type, toy_part_index)
	local part_data_list = {}
	if nil == pet_info_type or pet_info_type < 0 or nil == pet_index or nil == toy_part_index then return part_data_list end

	local equip_pet_list = self:GetSinglePetEquipInfo(pet_index, pet_info_type)
	if nil == equip_pet_list or nil == next(equip_pet_list) then return part_data_list end

	local part_data_list = equip_pet_list[toy_part_index]

	return part_data_list
end

--flag == true 计算当前部位下一等级
--单个宠物玩具部位总战力
function LittlePetData:GetSinglePetToyPartPower(pet_index, pet_info_type, toy_part_index, flag)
	local power = 0
	local next_level_flag = flag or false
	if nil == pet_info_type or pet_info_type < 0 or nil == pet_index or nil == toy_part_index then return power end

	local equip_part_list = self:GetSinglePetEquipPartInfo(pet_index, pet_info_type, toy_part_index)
	if nil == equip_part_list or nil == equip_part_list.equipment_id then return power end

	local equipment_id = equip_part_list.equipment_id
	local level = next_level_flag and equip_part_list.level + 1 or equip_part_list.level
	if equipment_id == 0 then return power end

	local part_cfg = self:GetSingleEquipToyCfgByIndexAndLevel(toy_part_index - 1, level + 1)
	local part_power = self:GetPartPower(part_cfg)
	power = power + part_power

	local percent = part_cfg.base_attr_add_per or 0
	local item_cfg = ItemData.Instance:GetItemConfig(equipment_id)
	local base_power = self:GetBasePower(item_cfg, percent)
	power = power + base_power

	return power
end

--单个宠物玩具部位战力
function LittlePetData:GetPartPower(part_cfg)
	local part_capability = 0
	if nil == part_cfg or nil == part_cfg.maxhp then return part_capability end

	local part_attr = CommonStruct.Attribute()
	part_attr.max_hp =  part_cfg.maxhp
	part_attr.gong_ji = part_cfg.gongji
	part_attr.fang_yu = part_cfg.fangyu
	part_capability = CommonDataManager.GetCapabilityCalculation(part_attr)
	return part_capability
end

--单个宠物玩具部位基础战力
function LittlePetData:GetBasePower(item_cfg, percent)
	local base_capability = 0
	if nil == item_cfg or nil == item_cfg.hp then return base_capability end

	local base_attr = CommonStruct.Attribute()
	local per = 1 + percent / 10000
	base_attr.max_hp = item_cfg.hp * per
	base_attr.gong_ji = item_cfg.attack * per
	base_attr.fang_yu = item_cfg.fangyu * per
	base_capability = CommonDataManager.GetCapabilityCalculation(base_attr)

	return base_capability 
end

--单个玩具部位属性值
function LittlePetData:GetSinglePetToyPartAttr(part_cfg)
	local part_attr = {}
	if nil == part_cfg or nil == part_cfg.maxhp then return part_attr end

	local percent = part_cfg.base_attr_add_per
	local per = percent and percent / 100 or 0
	part_attr.max_hp = part_cfg.maxhp
	part_attr.gong_ji = part_cfg.gongji
	part_attr.fang_yu = part_cfg.fangyu
	part_attr.per = per

	return part_attr 
end

--单个宠物玩具战力
function LittlePetData:GetSinglePetToyPower(pet_index, pet_info_type)
	local power = 0
	for i=1, GameEnum.LITTLEPET_EQUIP_INDEX_MAX_NUM do
		local part_power = self:GetSinglePetToyPartPower(pet_index, pet_info_type, i) or 0
		power = power + part_power
	end

	return power
end

--单个宠物玩具红点相关
function LittlePetData:SinglePetToyRemind(pet_index, info_type)
	local is_remind = false
	local remind_list = {}
	local can_equip_part_list = {}
	local can_replace_list = {}
	local can_up_level_list = {}
	local pet_equip_info = self:GetSinglePetEquipInfo(pet_index, info_type)
	if nil == next(pet_equip_info) then 
		return is_remind, remind_list 
	end

	for k,v in pairs(pet_equip_info) do
		--升级
		local is_up_level = self:SinglePetIsCanUpLevel(k, v)
		if is_up_level then
			is_remind = true
			can_up_level_list[k] = k
		end

		if info_type == LITTLE_PET_TYPE.MINE_PET then
			--穿戴
			local is_can = self:SinglePetIsCanEquipToy(k, v)
			if is_can then
				is_remind = true
				can_equip_part_list[k] = k
			end
			--替换
			local is_replace = self:SinglePetIsCanReplace(k, v)
			if is_replace then
				is_remind = true
				can_replace_list[k] = k
			end
		end
	end

	remind_list.can_equip_part_list = can_equip_part_list
	remind_list.can_replace_list = can_replace_list
	remind_list.can_up_level_list = can_up_level_list

	return is_remind, remind_list
end

--单个玩具部位是否有可装备的玩具
function LittlePetData:SinglePetIsCanEquipToy(part_num, list)
	local is_can = false
	local pet_equip_info = list 
	if nil == pet_equip_info or nil == pet_equip_info.equipment_id or pet_equip_info.equipment_id ~= 0 then return is_can end

	local list = self:GetBagLittlePetToyDataListByToyPart(part_num)
	if list and #list > 0 then
		is_can = true
	end

	return is_can
end

--单个玩具部位是否有高品质装备可替换
function LittlePetData:SinglePetIsCanReplace(part_num, list)
	local is_have = false
	local pet_equip_info = list 
	if nil == pet_equip_info or nil == pet_equip_info.equipment_id or pet_equip_info.equipment_id == 0 then return is_have end

	local list = self:GetBagLittlePetToyDataListByToyPart(part_num)
	if nil == list or #list <= 0 then return is_have end

	local item_cfg = ItemData.Instance:GetItemConfig(pet_equip_info.equipment_id)
	local color = item_cfg and item_cfg.color or 0
		
	for k,v in pairs(list) do
		local item_id = v.item_id or 0
		local cfg = ItemData.Instance:GetItemConfig(item_id)
		if cfg and cfg.color > color then
			is_have = true
			break
		end
	end

	return is_have
end

--单个玩具部位是否可升级
function LittlePetData:SinglePetIsCanUpLevel(part_num, list)
	local is_up_level = false
	local pet_equip_info = list
	if nil == pet_equip_info or nil == pet_equip_info.equipment_id or pet_equip_info.equipment_id == 0 then return is_up_level end

	local cur_toy_level = pet_equip_info.level or 0
	local max_lexel = self:GetToySinglePartMaxLevelByIndex(part_num)
	if max_lexel > 0 and cur_toy_level >= max_lexel or max_lexel <= 0 then return is_up_level end

	local cfg = self:GetSingleEquipToyCfgByIndexAndLevel(part_num - 1, cur_toy_level + 1)
	if nil == next(cfg) then return is_up_level end

	local need_num = cfg.stuff_num
	local stuff_item_id = cfg.stuff_id or 0
	local has_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id)
	if need_num and has_num >= need_num then
		is_up_level = true
	end

	return is_up_level
end

--宠物玩具红点
function LittlePetData:GetLittlePetToyRemind()
	local remind_num = 0

	local data_list = self:GetSortAllPetList()
	if nil == data_list or nil == next(data_list) then return remind_num end

	for k,v in pairs(data_list) do
		local pet_index = v.index
		local info_type = v.info_type
		local is_remind = self:SinglePetToyRemind(pet_index, info_type)
		if is_remind then
			remind_num = 1
			break
		end
	end

	return remind_num
end
-------------------------------玩具结束---------------------------------

---------------------------------商店-----------------------------------
--获得需要展示的宠物形象id
function LittlePetData:GetShowRandomZhenXiUseImgId()
	local pet_list = {}
	local cfg = self:GetLittlePetCfg()
	if nil == next(cfg) then return pet_list end

	for i = 1, 2 do
		local pet_cfg = cfg[#cfg - i]
		if pet_cfg then
			table.insert(pet_list, pet_cfg)
		end
	end

	return pet_list
end

-- 是否有免费抽奖次数
function LittlePetData:IsHaveFreeTimesByInfo()
	local is_free = false
	local other_cfg = self:GetOtherCfg()
	-- 当前时间 大于 last_free_chou_timestamp + 配置免费抽奖间隔小时 * 3600 是免费
	if self.all_info_list and self.all_info_list.last_free_chou_timestamp and other_cfg[1] then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local free_time = self.all_info_list.last_free_chou_timestamp
		local free_jian_ge = other_cfg[1].free_chou_interval_h or 0
		is_free = sever_time > (free_time + free_jian_ge * 3600)
	end

	return is_free
end

--抽奖元宝是否足够
function LittlePetData:GetChouJiangGoldIsEnough(price)
	local is_enough = false
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local have_gold = vo and vo.gold or 0
	local need_gold = price

	if have_gold >= need_gold then
		is_enough = true
	end

	return is_enough
end

--是否播放抽奖动画状态
function LittlePetData:SetChouJiangAniState(is_on)
	self.is_can_play_chou_jiang_ani = not value
end

function LittlePetData:GetChouJiangAniState()
	return self.is_can_play_chou_jiang_ani
end

--宠物商店抽奖得到奖励数据
function LittlePetData:GetChouJiangRewardDataList()
	return self.shop_chou_jiang_reward_list or {}
end

-- 抽奖动画最后停的位置
function LittlePetData:GetChouJiangAngleSeq()
	local chou_jiang_cfg = self:GetChoujiangCfg()
	local angle_index = 0
	if nil == next(chou_jiang_cfg) or nil == self.reward_seq or self.reward_seq < -1 then return angle_index end

	local info_seq = self.reward_seq == -1 and 0 or self.reward_seq
	for k,v in pairs(chou_jiang_cfg) do
		if v.seq == info_seq then
			angle_index = v.caowei
			break
		end
	end

	return angle_index
end

--宠物商店红点
function LittlePetData:GetLittlePetShopRemind()
	if self:IsHaveFreeTimesByInfo() then
		return 1
	end
	--宠物仓库红点
	local warehouse_point = self:GetLittlePetWarehouseRemind()
	if warehouse_point > 0 then
		return 1
	end

	return 0
end

-------------------------------商店结束---------------------------------

---------------------------------兑换-----------------------------------
--获取当前积分
function LittlePetData:GetCurJiFenByInfo()
	local ji_fen = self.all_info_list and self.all_info_list.score or 0
	return ji_fen
end
-------------------------------兑换结束---------------------------------

---------------------------------仓库-----------------------------------
--宠物仓库信息
function LittlePetData:SetLittlePetWarehouseList(list)
	if #list > 1 then
		self:GetBagBestLittlePet(list)
	end
	self.little_pet_warehouse_list = list
end

function LittlePetData:GetLittlePetWarehouseList()
	return self.little_pet_warehouse_list
end

--宠物仓库信息
function LittlePetData:IsHavePetReward(protocol)
	local list = self:GetLittlePetRewardList(protocol)
	self:SetLittlePetWarehouseList(list)
end

--筛选出宠物相关数据信息
function LittlePetData:GetLittlePetRewardList(list)
	local reward_list = {}
	if nil == list then return reward_list end

	for k,v in pairs(list) do
		local item_id = v.item_id
		local is_pet_item = self:IsLittlePetItem(item_id)
		if is_pet_item then
			table.insert(reward_list, v)
		end
	end

	return reward_list
end

--是否是宠物相关   flag为是否需要判断玩具道具标识
function LittlePetData:IsLittlePetItem(item_id, flag)
	local is_flag = flag or false
	local is_pet_item = false
	local cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if nil == cfg then return is_pet_item end

	--宠物
	if GameEnum.ITEM_BIGTYPE_EXPENSE == big_type and cfg.use_type == GameEnum.USE_TYPE_LITTLE_PET then
		is_pet_item = true
	end

	--喂养材料/玩具升级材料
	if cfg.search_type == GameEnum.USE_TYPE_LITTLE_PET_FEED then
		is_pet_item = true
	end

	if not is_flag then return is_pet_item end

	--玩具道具
	if GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type and EquipData.IsLittlePetToyType(cfg.sub_type) then
		is_pet_item = true
	end
	
	return is_pet_item
end

--宠物仓库红点
function LittlePetData:GetLittlePetWarehouseRemind()
	local warehouse_list = self:GetLittlePetWarehouseList()
	if #warehouse_list > 0 then
		return 1
	end 
	return 0
end
-------------------------------仓库结束---------------------------------

--------------------------------场景显示---------------------------------
--得到小宠物模型出现间隔
function LittlePetData:GetLittlePetAppearInterval()
	local other_cfg = self:GetOtherCfg()
	appera_interval = other_cfg[1]and other_cfg[1].pet_appear or 0
	return appera_interval
end

--当前自己装备的宠物的数量
function LittlePetData:GetMineEquipPetCount()
	local count = 0
	local list = {}
	if nil == self.mine_pet_list then return count end

	for k,v in pairs(self.mine_pet_list) do
		table.insert(list, v)
	end

	count = #list

	return count
end

--根据pet_id得到单个宠物的配置
function LittlePetData:GetSinglePetCfgByPetId(pet_id)
	local pet_list = {}
	local cfg = self:GetLittlePetCfg()
	if nil == next(cfg) or nil == pet_id then return pet_list end

	for k,v in pairs(cfg) do
		if pet_id == v.id then
			pet_list = v
			break
		end
	end

	return pet_list
end

--是否请求协议
function LittlePetData:IsRequirePetWalkPro()
	local is_require = false
	local mine_pet_count = self:GetMineEquipPetCount()
	local is_open = OpenFunData.Instance:CheckIsHide("littlepet")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()

	if is_open and mine_pet_count > 0 and fb_scene_cfg.pb_pet and fb_scene_cfg.pb_pet ~= 1 then 
		is_require = true 
	end

	return is_require
end

--卸掉的宠物id
function LittlePetData:SetTakeOffPetId(id)
	self.cur_take_off_pet_id = id or 0
end

function LittlePetData:GetTakeOffPetId()
	return self.cur_take_off_pet_id
end

--场景中显示的宠物id
function LittlePetData:SetSceneShowPetId(id)
	self.cur_scene_show_pet_id = id or 0
end

function LittlePetData:GetSceneShowPetId()
	return self.cur_scene_show_pet_id
end

--卸掉的宠物是否是场景中显示的宠物
function LittlePetData:IsScenceShowPetId()
	local is_same = false
	local take_off_pet_id = self:GetTakeOffPetId()
	local scene_show_pet_id = self:GetSceneShowPetId()

	if take_off_pet_id == 0 or scene_show_pet_id == 0 then return is_same end

	if take_off_pet_id == scene_show_pet_id then
		is_same = true
		self:SetSceneShowPetId(0)
		self:SetTakeOffPetId(0)
	end

	return is_same
end
----------------------------场景显示结束---------------------------------