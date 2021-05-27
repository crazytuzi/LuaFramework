CrossServerData = CrossServerData or BaseClass(BaseController)

require("scripts/game/cross_server/cross_server_flop_data")

-- 1跨服BOSS争夺战 2跨服个人赛 3跨服帮派战 4跨服六界副本
CROSS_SERVER_TYPE = {
	BOSS_FIGHT = 1,
	PERSONAL_COMPETITION = 2,
	GUILD_WAR = 3,
	FUBEN = 4,
}

CROSS_SERVER_OPEN_DAY = 4								-- 跨服开服第3天开放
CROSS_SERVER_OPEN_TIME = 3600 * 72						-- 跨服开服多少秒后开放

local SixWorldCfg = SixWorldCfg							-- 跨服副本配置
local corss_pos_to_eq_type = AccessoryEquipTypePos		-- 配置索引->物品类型
local corss_eq_grade_to_item_id = Accessory_StageToItem	-- 装备阶数->物品id
local corss_pos_to_eq_index = {}						-- 配置索引->装备索引
local corss_eq_index_to_pos = {}						-- 装备索引->配置索引
local TurnOverCardsCfg = TurnOverCardsCfg

CrossServerData.COPY_DATA_CHANGE = "COPY_DATA_CHANGE"
CrossServerData.FLOP_DATA_CHANGE = "flop_data_change"
CrossServerData.CROSS_TUMO_ADD_TIME = "cross_tumo_add_time"

function CrossServerData:__init()
	if	CrossServerData.Instance then
		ErrorLog("[CrossServerData]:Attempt to create singleton twice!")
	end
	CrossServerData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.cross_server_state = 0
	-- self:InitCrossBattle()
	-- self:InitCrossEquip()
	self:InitCrossBrand()

	self.statue_info = {}

	self.copy_list = {} -- 跨服副本数据列表

	--翻牌数据
	self:InitFlopCard()
end

function CrossServerData:__delete()
	CrossServerData.Instance = nil
end

function CrossServerData.GetCrossBossRestCntBySceneId(scene_id)
	local rest_cnt = 3
	local data = nil
	if scene_id >= 152 and scene_id <= 157 then -- 蓬莱仙界
		data = PengLaiFairylandData.Instance:GetPengLaiFairyLandInfo()
		if data then
			rest_cnt = data.remaining_can_kill_boss_times
		end
	elseif scene_id == 158 then					-- 烈焰幻境
		data = FireVisionData.Instance:GetData()
		if data then
			rest_cnt = data.num
		end
	elseif scene_id == 159 then					-- 龙魂圣域
		data = DragonSoulData.Instance:GetData()
		if data then
			rest_cnt = data.num
		end
	elseif scene_id == 160 then					-- 圣兽宫
		rest_cnt = BeastPalaceData.Instance:GetNumber()
	elseif scene_id >= 161 and scene_id <= 166 then 	-- 轮回地狱
		data = RebirthHellData.Instance:GetData()
		if data then
			rest_cnt = data.number
		end
	end
	return rest_cnt
end

function CrossServerData:SetCrossServerState(state)
	self.is_cross_server = state
end

function CrossServerData:CrossServerIsOpen()
	local open_day = OtherData.Instance:GetOpenServerDays()
	return open_day >= CROSS_SERVER_OPEN_DAY or IS_ON_CROSSSERVER, string.format(Language.Common.FunOpenDayLimit, CROSS_SERVER_OPEN_DAY)
end

function CrossServerData:GetCrossBossTime()
	if not IS_ON_CROSSSERVER then
		local open_server_days = OtherData.Instance:GetOpenServerDays()
		local open_server_time = OtherData.Instance:GetOpenServerTime()
		local server_time = TimeCtrl.Instance:GetServerTime()
		local left_time = open_server_time + CROSS_SERVER_OPEN_TIME - server_time
		return TimeUtil.Format2TableHMS(left_time)
	else
		return TimeUtil.Format2TableHMS(0)
	end
end

-------------------------------------
-- 六界入口 begin
-------------------------------------
function CrossServerData:InitCrossBattle()
	self.cross_battle_data = {
		tumo_val = 0,
		can_buy_times = 0,
		consume = 0,
		get_val = 0,
	}

	self.entrance_state = 0		-- 0 未开启, 1 开启中 （弃用)
end

function CrossServerData:SetEntranceState(state)
	self.entrance_state = state
end

function CrossServerData:GetBattleIsOpenRemind()
	local info = self:BattleEntranceOpenInfo()
	local is_open = false
	if info.is_in_day then
		for k, v in pairs(info.times) do
			if v.is_in_time then
				is_open = true
				break
			end
		end
	end

	return is_open and 1 or 0
end

function CrossServerData:BattleEntranceOpenInfo()
	return TimeUtil.FormatTimeCfg(SixWorldCfg.openTime)
end

function CrossServerData:SetSceneValInfo(info)
	self.cross_battle_data.tumo_val = info.val
	self.cross_battle_data.can_buy_times = info.can_buy_times
	self.cross_battle_data.consume = info.consume
	self.cross_battle_data.get_val = info.get_val
end

function CrossServerData:TumoVal()
	return self.cross_battle_data.tumo_val
end

function CrossServerData:CrossBattleRule()
	return SixWorldCfg.ruleContent
end

function CrossServerData:GetEntrancesCfg(index)
	return SixWorldCfg.fubenList[index]
end

-- 可进入的战场入口索引
function CrossServerData:GetCanEnterEntranceIndex()
	local index = nil
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	for k, v in pairs(SixWorldCfg.fubenList) do
		if role_circle >= v.needmincircle and role_circle <= v.needmaxcircle then
			index = k
			break
		end
	end
	return index
end

-- 跨服战掉落物品（显示用）区分职业性别
function CrossServerData:GetEntrancesDrops(index)
	local drop_items = {}
	local cfg = self:GetEntrancesCfg(index)
	local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local role_prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if cfg then
		for _, v in pairs(cfg.ShowDrops) do
			if (nil == v.sex or v.sex == role_sex)
				and (nil == v.job or v.job == role_prof) then
				table.insert(drop_items, {item_id = v.id, num = v.count, is_bind = v.bind})
			end
		end
	end
	return drop_items
end

function CrossServerData:BuyTomoValueInfo()
	return self.cross_battle_data.can_buy_times, self.cross_battle_data.consume, self.cross_battle_data.get_val
end
-------------------------------------
-- 六界入口 end
-------------------------------------

-------------------------------------
-- 六界战装 begin
-------------------------------------
function CrossServerData.CreateCrossEquipData(equip_index, cfg_index)
	return {
		equip_index = equip_index or 0,
		cfg_index = cfg_index or 0,
		cross_stars = 0,	-- 总星级
		cross_grade = 0,	-- 阶数
	}
end

function CrossServerData:InitCrossEquip()
	for cfg_index, equip_type in pairs(corss_pos_to_eq_type) do
		local equip_index = EquipData.Instance:GetEquipIndexByType(equip_type)
		corss_pos_to_eq_index[cfg_index] = equip_index
		corss_eq_index_to_pos[equip_index] = cfg_index
	end
	self.cross_eq_list = {}	-- 装备升阶魔化数据列表
	for i = EquipData.EquipIndex.CrossEquipBeginIndex, EquipData.EquipIndex.CrossEquipEndIndex do
		self.cross_eq_list[i] = CrossServerData.CreateCrossEquipData(i, CrossServerData.ConverToCrossEqCfgIndex(i))
	end
end

function CrossServerData:SetCrossEquipData(equip_info_list, reason)
	for k, v in pairs(equip_info_list) do
		local equip_index = CrossServerData.ConverToCrossEqIndex(v.pos)
		local equip_data = self.cross_eq_list[equip_index]
		if equip_data then
			equip_data.cross_stars = v.total_star
			equip_data.cross_grade = v.grade
		end

		-- 更新装备数据
		local equip_data = EquipData.Instance:GetGridData(equip_index)
		if equip_data then
			EquipData.Instance:ChangeDataInGrid(equip_data)
		end
	end
end

-- 该部位是否激活
function CrossServerData:IsCrossEquipAct(equip_index)
	-- return nil ~= EquipData.Instance:GetGridData(equip_index)
	return self:GetCrossEquipData(equip_index).cross_grade > 0
end

-- 获取跨服装备数据
function CrossServerData:GetCrossEquipData(equip_index)
	return self.cross_eq_list[equip_index]
		or CrossServerData.CreateCrossEquipData()
end

-- 装备的索引转为配置的索引
function CrossServerData.ConverToCrossEqCfgIndex(equip_index)
	return corss_eq_index_to_pos[equip_index]
end

-- 配置的索引转为装备的索引
function CrossServerData.ConverToCrossEqIndex(cfg_index)
	return corss_pos_to_eq_index[cfg_index]
end

-- 获取跨服装备升阶的配置
function CrossServerData.GetCrossEqUpgradeCfg(cfg_index)
	if nil == cfg_index or nil == corss_pos_to_eq_index[cfg_index] then
		return
	end
	return ConfigManager.Instance:GetServerConfig("misc/Accessory/UpAccessory_" .. cfg_index .. "_Cfg")[1]
end

-- 获取跨服装备魔化的配置
function CrossServerData.GetCrossEqMohuaCfg(cfg_index)
	if nil == cfg_index or nil == corss_pos_to_eq_index[cfg_index] then
		return
	end
	return ConfigManager.Instance:GetServerConfig("misc/Accessory/StrongAccessory_" .. cfg_index .. "_Cfg")[1]
end

-- 获取跨服装备魔化装备属性的配置
function CrossServerData.GetCrossEqMohuaAttrsCfg(cfg_index)
	if nil == cfg_index or nil == corss_pos_to_eq_index[cfg_index] then
		return
	end
	return ConfigManager.Instance:GetServerConfig("misc/Accessory/AttrAccessory/AttrAccessory_" .. cfg_index .. "_Cfg")[1]
end

function CrossServerData:GetCrossEquipList()
	local list = {}
	for i = EquipData.EquipIndex.CrossEquipBeginIndex, EquipData.EquipIndex.CrossEquipHeartMirror do
		list[#list + 1] = {equip_index = i}
	end
	return list
end

-- 部位可升阶/魔化的次数
function CrossServerData:GetCrossEquipRemindByIndex(equip_index)
	if nil == equip_index then
		return 0
	end
	return (self:CrossEqCanMohua(equip_index) and 1 or 0) + (self:CrossEqCanUpgrade(equip_index) and 1 or 0)
end

-- 获取该部位是否可以魔化(需要先激活才可魔化)
function CrossServerData:CrossEqCanMohua(equip_index)
	if nil == equip_index then
		return false
	end
	if not CrossServerData.Instance:IsCrossEquipAct(equip_index) then
		return false
	end
	local consume = self:GetCrossEquipMohuaConsume(equip_index)
	for k, v in pairs(consume.fujiao_rich_contents) do
		if not v.is_ok then
			return false
		end
	end
	for k, v in pairs(consume.items) do
		local num = BagData.Instance:GetItemNumInBagById(v.item_id)
		if num < v.num then
			return false
		end
	end
	return true
end

-- 获取该部位是否可以升阶
function CrossServerData:CrossEqCanUpgrade(equip_index)
	if nil == equip_index then
		return false
	end

	-- 星数 >= (阶数 * 10) 才可升阶
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	if cross_eq_data.cross_stars < cross_eq_data.cross_grade * 10 then
		return
	end

	local consume = self:GetCrossEquipUpgradeConsume(equip_index)
	for k, v in pairs(consume.fujiao_rich_contents) do
		if not v.is_ok then
			return false
		end
	end
	for k, v in pairs(consume.items) do
		local num = BagData.Instance:GetItemNumInBagById(v.item_id)
		if num < v.num then
			return false
		end
	end
	return true
end

-- 收集跨服装备所有需要监听变化的物品id
function CrossServerData:GetCrossEquipListenItems()
	if nil == self.cross_eq_listen_items then
		self.cross_eq_listen_items = {}
		for i = EquipData.EquipIndex.CrossEquipBeginIndex, EquipData.EquipIndex.CrossEquipHeartMirror do
			-- 魔化消耗物品id
			local mohua_cfg = CrossServerData.GetCrossEqMohuaCfg(CrossServerData.ConverToCrossEqCfgIndex(i))
			if mohua_cfg and mohua_cfg[1] then
				self.cross_eq_listen_items[mohua_cfg[1].consume[1].id] = 1
			end
			-- 升阶消耗物品id
			local upgrande_cfg = CrossServerData.GetCrossEqUpgradeCfg(CrossServerData.ConverToCrossEqCfgIndex(i))
			if upgrande_cfg and upgrande_cfg[0] then
				self.cross_eq_listen_items[upgrande_cfg[0].consume[2].id] = 1
			end
			-- 所有跨服装备id
			for _, v in pairs(corss_eq_grade_to_item_id) do
				for __, item_id in pairs(v) do
					self.cross_eq_listen_items[item_id] = 1
				end
			end
		end
		self.GetCrossEquipListenItems = function(self)
			return self.cross_eq_listen_items
		end
	end
	return self:GetCrossEquipListenItems()
end

-- 尝试提醒，如需要则Do Remind
function CrossServerData:TryRemindCrossEqByItemId(item_id)
	if nil ~= item_id then
  		local listen_items = self:GetCrossEquipListenItems()
		if listen_items[item_id] then
		  	RemindManager.Instance:DoRemind(RemindName.CrossEquipCanUp)
		  	return true
		end
  	end
  	return false
end

-- 所有跨服装备可操作的次数
function CrossServerData:GetCrossEquipUpRemind()
	local num = 0
	for i = EquipData.EquipIndex.CrossEquipBeginIndex, EquipData.EquipIndex.CrossEquipHeartMirror do
		num = num + self:GetCrossEquipRemindByIndex(i)
	end
	return num
end

-- 装备的ui显示的特效资源id 从升阶配置中获取
function CrossServerData:GetCrossEquipEffid(equip_index)
	local effid = 50
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	-- local mohua_cfg = CrossServerData.GetCrossEqMohuaCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	-- if mohua_cfg and cross_eq_data and mohua_cfg[cross_eq_data.cross_stars] then
	-- 	effid = mohua_cfg[cross_eq_data.cross_stars].item_eff
	-- elseif mohua_cfg then
	-- 	effid = mohua_cfg[1].item_eff
	-- end

	local upgrande_cfg = CrossServerData.GetCrossEqUpgradeCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	if upgrande_cfg and upgrande_cfg[cross_eq_data.cross_grade] then
		effid = upgrande_cfg[cross_eq_data.cross_grade].item_eff
	end
	return effid
end

-- 装备的名字 从升阶配置中获取
function CrossServerData:GetCrossEquipName(equip_index)
	local name = ""
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	-- local mohua_cfg = CrossServerData.GetCrossEqMohuaCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	-- if mohua_cfg and cross_eq_data and mohua_cfg[cross_eq_data.cross_stars] then
	-- 	name = mohua_cfg[cross_eq_data.cross_stars].name
	-- elseif mohua_cfg then
	-- 	name = mohua_cfg[1].name
	-- end

	local upgrande_cfg = CrossServerData.GetCrossEqUpgradeCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	if upgrande_cfg and upgrande_cfg[cross_eq_data.cross_grade] then
		name = upgrande_cfg[cross_eq_data.cross_grade].name
	end
	return name
end

-- 装备升阶的消耗 从升阶配置中获取
function CrossServerData:GetCrossEquipUpgradeConsume(equip_index)
	local is_max = false
	local consume = {items = {}, fujiao_rich_contents = {}}
	local upgrande_cfg = CrossServerData.GetCrossEqUpgradeCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	local grade = cross_eq_data.cross_grade
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if upgrande_cfg and upgrande_cfg[grade] then
		is_max = nil == upgrande_cfg[grade + 1]
		if is_max then
			--满阶显示
			table.insert(consume.fujiao_rich_contents, {content = string.format("{colorandsize;ff2828;26;%s}", Language.LunHuiEquip.MaxJie), is_ok = false})
		else
			for k, v in pairs(upgrande_cfg[grade].consume) do
				if k > 1 then	-- 过滤第一条装备消耗(写死)
					table.insert(consume.items, ItemData.FormatItemData(v))
				end
			end

			-- 转生需求
			local need_circle = upgrande_cfg[grade].circle
			local need_level = upgrande_cfg[grade].level
			local is_ok = (role_circle >= need_circle) and (role_level >= need_level)
			local color = is_ok and "1eff00" or "ff2828"
			local str = is_ok and Language.Common.DaCheng or Language.Common.WeiDaCheng
			table.insert(consume.fujiao_rich_contents, {content = string.format(Language.CrossServer.NeedCircleLevelStr, color, need_circle, need_level, str), is_ok = is_ok})
		end
	end
	return consume, is_max
end

-- 装备魔化的消耗 从魔化配置中获取
function CrossServerData:GetCrossEquipMohuaConsume(equip_index)
	local is_max = false
	local consume = {items = {}, fujiao_rich_contents = {}}
	local mohua_cfg = CrossServerData.GetCrossEqMohuaCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	local stars = cross_eq_data.cross_stars
	local grade = cross_eq_data.cross_grade
	local next_stars = stars + 1
	if mohua_cfg and mohua_cfg[next_stars] then
		for k, v in pairs(mohua_cfg[next_stars].consume) do
			table.insert(consume.items, ItemData.FormatItemData(v))
		end

		-- 装备阶级需求
		local need_grade = mohua_cfg[next_stars].startStage
		local is_ok = grade >= need_grade
		local color = is_ok and "1eff00" or "ff2828"
		local str = is_ok and Language.Common.DaCheng or Language.Common.WeiDaCheng
		table.insert(consume.fujiao_rich_contents, {content = "", is_ok = is_ok})
	end
	is_max = mohua_cfg and (nil == mohua_cfg[next_stars])
	if is_max then
		-- 满星
		table.insert(consume.fujiao_rich_contents, {content = string.format("{colorandsize;ff2828;26;%s}", Language.LunHuiEquip.MaxLevel), is_ok = false})
	end

	return consume, is_max
end

-- 装备当前阶数已满
function CrossServerData:IsCrossEqMaxGrade(equip_index)
	local upgrande_cfg = CrossServerData.GetCrossEqUpgradeCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	local grade = cross_eq_data.cross_grade
	return upgrande_cfg and nil == upgrande_cfg[grade + 1]
end

-- 装备当前阶数的星级已达最高
function CrossServerData:IsCurGradeMaxMohuaStar(equip_index)
	return self:GetCrossEquipMohuaStarNum(equip_index) == 10
end

function CrossServerData:GetCrossEquipMohuaStarNum(equip_index)
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	return cross_eq_data.cross_stars - (cross_eq_data.cross_grade - 1) * 10
end

-- 从升阶配置中取下阶的物品id
function CrossServerData:GetNextUpgradeEquipData(equip_index)
	local upgrande_cfg = CrossServerData.GetCrossEqUpgradeCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	local grade = cross_eq_data.cross_grade
	if upgrande_cfg and upgrande_cfg[grade] then
		return ItemData.FormatItemData(upgrande_cfg[grade].award)
	end 
end

-- 对应部位、阶数的升阶属性 读装备数据需要监听装备配置
function CrossServerData:GetUpgradeEquipAttrs(equip_index, grade)
	-- local upgrande_cfg = CrossServerData.GetCrossEqUpgradeCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	-- if upgrande_cfg and upgrande_cfg[grade] then
	-- 	return upgrande_cfg[grade].attr
	-- end
	local cfg_index = CrossServerData.ConverToCrossEqCfgIndex(equip_index)
	local attrs = {}
	local item_id = corss_eq_grade_to_item_id[cfg_index] and corss_eq_grade_to_item_id[cfg_index][grade]
	if item_id and ItemData.Instance:GetItemConfig(item_id) then
		attrs = ItemData.Instance:GetItemConfig(item_id).staitcAttrs
	end

	return attrs
end

-- 对应部位当前的升阶和魔化属性
function CrossServerData:GetCurUpgradeEquipAttrs(equip_index)
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	local mohua_attrs = self:GetMohuaEquipAttrs(equip_index, cross_eq_data.cross_stars)
	local upgrande_attrs = self:GetUpgradeEquipAttrs(equip_index, cross_eq_data.cross_grade)
	return CommonDataManager.AddAttr(mohua_attrs, upgrande_attrs)
end

-- 对应部位下一阶的升阶和魔化属性
function CrossServerData:GetNextUpgradeEquipAttrs(equip_index)
	local cross_eq_data = self:GetCrossEquipData(equip_index)
	local mohua_attrs = self:GetMohuaEquipAttrs(equip_index, cross_eq_data.cross_stars)
	local upgrande_attrs = self:GetUpgradeEquipAttrs(equip_index, cross_eq_data.cross_grade + 1)
	return CommonDataManager.AddAttr(mohua_attrs, upgrande_attrs)
end

-- 对应部位星数的魔化属性
function CrossServerData:GetMohuaEquipAttrs(equip_index, stars)
	local attrs_cfg = CrossServerData.GetCrossEqMohuaAttrsCfg(CrossServerData.ConverToCrossEqCfgIndex(equip_index))
	return attrs_cfg and attrs_cfg[stars]
end

-- 对应部位总属性（魔化 + 升阶）
function CrossServerData:GetEquipAllAttrs(equip_index)
	local attrs = {}
	if equip_index then
		local cross_eq_data = self:GetCrossEquipData(equip_index)
		local mohua_attrs = self:GetMohuaEquipAttrs(equip_index, cross_eq_data.cross_stars)
		local upgrande_attrs = self:GetUpgradeEquipAttrs(equip_index, cross_eq_data.cross_grade)
		attrs = CommonDataManager.AddAttr(mohua_attrs, upgrande_attrs)
	end
	return attrs
end

-------------------------------------
-- 六界战装 end
-------------------------------------

-------------------------------------
-- 名人堂雕像 end
-------------------------------------
function CrossServerData:SetStatuesInfo(protocol)
	for k, v in pairs(protocol.statue_info) do
		if v.exsit == 1 then
			local role_vo = {}
			for k, v in pairs(v.attr) do
				role_vo[k] = v
			end

			role_vo[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = v.statue_idx + 35 - 1
			local names = Split(v.all_name, "\\")
			role_vo.name = names[1] or ""
			role_vo.guild_name = names[3] or ""
			role_vo.partner_name = names[6] or ""
			role_vo.dir = GameMath.MDirDown

			self.statue_info[v.statue_idx] = role_vo

			local npc = Scene.Instance:GetNpcByNpcId(v.statue_idx + NPC_ID.MINGREN1 - 1)
			if npc then
				npc:UpdateAllShow()
			end
		end
	end
end

function CrossServerData:GetStatueInfoByNpcId(npc_id)
	return self.statue_info[npc_id - NPC_ID.MINGREN1 + 1]
end
-------------------------------------
-- 名人堂雕像 end
-------------------------------------

----------跨服副本数据----------

--[[
	"跨服副本数据列表"包含
	跨服副本ID, 跨服副本的场景数据, 跨服副本的场景数量, 跨服boss数据列表

	"跨服副本的场景数据"包含
	场景id, 当前场景玩家数量, boss数量,
`
	"跨服boss数据列表"包含
	boss_id			boss id
	refresh_time 	下一次刷新时间, 0为已刷新 单位：秒
	monster_type 	怪物类型
	player_id 		归属者id
	player_name 	归属者名
	now_time 		接收数据的时间(用于效准)
]]--

-- 设置跨服场景数据列表
function CrossServerData:SetCopyData(protocol)
	-- 用副本id作为索引
	local copy_id = protocol.copy_id
	if nil == self.copy_list[copy_id] then
		self.copy_list[copy_id] = {}
		self.copy_list[copy_id].copy_id = copy_id
		self.copy_list[copy_id].scene_num = protocol.scene_num
		self.copy_list[copy_id].scene_list = protocol.scene_list
		self.copy_list[copy_id].boss_list = protocol.boss_list
	else
		for k, v in pairs(protocol.scene_list) do
			self.copy_list[copy_id].scene_list[k] = v
		end
		for k, v in pairs(protocol.boss_list) do
			self.copy_list[copy_id].boss_list[k] = v
		end
	end
	self:DispatchEvent(CrossServerData.COPY_DATA_CHANGE)
end

function CrossServerData:GetCrossBossInfoById(id)
	for i,v in pairs(self.copy_list) do
		if v.boss_list[id] then
			return v.boss_list[id]
		end
	end
end

-- 获取跨服副本数据列表(只需获取一次)
function CrossServerData:GetCopyData()
	return self.copy_list
end

-- 根据副本id获取跨服boss数据列表
function CrossServerData:GetBossDataList(copy_id)
	if self.copy_list[copy_id] then
		return self.copy_list[copy_id].boss_list
	end
end

-- 根据副本id获取跨服场景数据列表
function CrossServerData:GetBossSceneList(copy_id)
	if self.copy_list[copy_id] then
		return self.copy_list[copy_id].scene_list
	end
end

-- 获取BOSS刷新时间
function CrossServerData:GetBossRefreshTime(boss_data)
	local time = boss_data.refresh_time - (Status.NowTime - boss_data.now_time)

	return math.max(time, 0)
end

CrossServerData.BossModCfgIndex = {
	[1] = 11,
	[2] = 12,
	[3] = 13,
	[4] = 14,
} 

-- 获取层boss数据
function CrossServerData:GetBossInfoByIdx(tabbar_idx)
end

function CrossServerData:GetSceneDataByIdx(tabbar_idx)
	local boss_list = {}
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if circle < ModBossConfig[CrossServerData.BossModCfgIndex[1]][1].circle then
		circle = ModBossConfig[CrossServerData.BossModCfgIndex[1]][1].circle + 1
	end

	local open_server_days = OtherData.Instance:GetOpenServerDays()
	for k, v in pairs(ModBossConfig[CrossServerData.BossModCfgIndex[tabbar_idx]]) do
		-- 远古boss根据转生范围筛选
		if (tabbar_idx == 1 and v.circle >= circle - 1 and v.circle <= circle + 1) or tabbar_idx ~= 1 then
			if open_server_days >= v.opensvrday then
				table.insert(boss_list, DeepCopy(v))
			end
		end
	end

	local function get_state(data)
		local boss_info = self:GetCrossBossInfoById(data.BossId) or {refresh_time = 0, now_time = 0}
		local is_enough = BossData.BossIsEnoughAndTip(data)
		local is_kill = (boss_info.refresh_time - Status.NowTime + boss_info.now_time) > 0
		local is_rem = BossData.Instance:GetRemindFlag(data.type, BossData.Instance:GetRemindex(data.type, data.BossId) or 0) == 0
		local state = is_rem and (is_enough and (is_kill and 3 or 0) or 2) or 1	
		return state   --0表示可以击杀1表示击杀2未开启
	end

	table.sort(boss_list, function (a, b)
		if get_state(a) ~= get_state(b) then
			return get_state(a) < get_state(b)
		else
			return a.BossId < b.BossId
		end
	end)

	return boss_list
	-- return ModBossConfig[CrossServerData.BossModCfgIndex[tabbar_idx]]
	-- return CrossConfig.crossFBConfigList[tabbar_idx].SceneInfo
end

-- 获得boss等级
function CrossServerData:GetBossLv(data)
	local lv = 0
	local lv_list = {}
	for k, v in pairs(data) do
		if lv ~= v.boss_lv then
			local vo = {
				boss_lv = v.boss_lv,
				scene_id = v.scene_id,
				id_cfg = self:GetBossIdNUm(v.scene_id, v.boss_lv)
			}
			table.insert(lv_list, vo)
		end
		lv = v.boss_lv
	end
	return lv_list
end
----------end----------
