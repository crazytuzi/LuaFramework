--itemEntry.lua
require "base.base"
--------------------------------------------------------------------------------

itemTable = {}

function parseEmailString(str)
    local id, count, bind = 0, 0, 0
    local i, j = string.find(str, '#')
    local k, l = string.find(str, '&')

    if i and i <= j and k and k <= l then
        id = tonumber(string.sub(str, 1, i-1))
        count = tonumber(string.sub(str, j+1, k-1))
        bind = string.sub(str, l+1, #str)
    end
    return id, count, bind
end

function parseDateOff(strDate)
	if strDate == nil or string.len(strDate) < 14 then
		return 0
	end
	local len = string.len(strDate)

	local date = {year = tonumber(string.sub(strDate, 1, len - 10)), month = tonumber(string.sub(strDate, len - 9, len - 8)), day = tonumber(string.sub(strDate, len - 7, len - 6)),
					hour = tonumber(string.sub(strDate, len - 5, len - 4)), min = tonumber(string.sub(strDate, len - 3, len - 2)), sec = tonumber(string.sub(strDate, len - 1, len))}
	
	return os.time(date)
end


--物品表
function loadItemConfig()
	local itemDatas = require "data.ItemDB"
	local equipDatas = require "data.EquipDB"

	local itemProto = ItemPrototype:new()
	for _, record in pairs(itemDatas or {}) do
		itemTable[record.q_name] = record.q_id
		itemProto.id = record.q_id or 0
		itemProto.name = record.q_name or ""
		itemProto.type = record.q_type or 0
		itemProto.bind = record.q_bind or 0
		itemProto.job = record.q_job or 0
		itemProto.maxStack = record.q_max or 0

		itemProto.buy_price = record.q_buy_price or 0
		itemProto.sell = (record.q_sell == 1)
		itemProto.sell_price = record.q_sell_price or 0
		itemProto.drop = (record.q_drop == 1)
		itemProto.level = record.q_level or 0

		itemProto.max_strengthen = record.q_max_strengthen or 0
		itemProto.max_inlay = record.q_max_inlay or 0

		itemProto.mergeId = record.mergeId or 0
		itemProto.splitId = record.splitId or 0
		itemProto.cooldown = record.q_cooldown or 0
		itemProto.cooldown_level = record.q_cooldown_level or 0
		itemProto.cooldown_type = record.q_cooldown_type or 0
		itemProto.transfer_times = record.q_transfer_times or 0
		itemProto.query_type = record.q_query_type or 0

		itemProto.gem = record.q_gem or 0		
		itemProto.gem_num = record.q_gem_num or 0

		itemProto.max_create = record.q_max_create or 0	
		itemProto.notice = record.q_notice or 0
		itemProto.log = (record.q_log == 1)
		itemProto.defaultColor = record.q_default or 0
		itemProto.effect_type = record.q_effect_type or 0
		itemProto.auto_use = (record.q_auto_use == 1)

		itemProto.whether_batch = (record.q_whether_batch == 1)
		itemProto.save_warehouse = (record.q_save_warehouse == 1)

		itemProto.item_equip_buff = record.q_item_equip_buff or 0
		itemProto.item_equip_effects = record.q_item_equip_effects or 0
		itemProto.item_pack_buff = record.q_item_pack_buff or 0
		itemProto.item_bag_effects = record.q_item_bag_effects or 0
		itemProto.recoverytime = record.q_recoverytime or 0
		itemProto.item_limit = record.q_item_limit or 0
		itemProto.equip_randompro = record.q_equip_randompro or 0

		itemProto.trade = (record.q_trade == 1)
		itemProto.numcontrol = record.q_numcontrol or 0	
		itemProto.item_equip_skill = record.q_item_equip_skill or 0
		itemProto.use_type_limittime = record.q_use_type_limittime or 0
		itemProto.expball_max = record.q_expball_max or 0
		itemProto.expball_min = record.q_expball_min or 0

		itemProto.insure = record.q_insure or 0	
		itemProto.limit_time = record.q_limit_time or 0	
		itemProto.limit_count = tonumber(record.q_limit_count) or 0	
		itemProto.skill_exp = record.q_skill_exp or 0
		itemProto.rare = record.q_rare or 0
		itemProto.compound = record.q_compound or 0
		itemProto.canBatch = record.q_whether_batch and tonumber(record.q_whether_batch) == 1 or false
		itemProto.getNotify = record.getNotify and tonumber(record.getNotify) == 1 or false
		itemProto.oreLv = tonumber(record.OreLv) or 1
		
		--物品限价
		itemProto.min_price = record.Min_price or 0
		itemProto.max_price = record.Max_price or 0
		itemProto.is_drop = record.IS_drop or 0
		itemProto.isno_owner = record.q_isNoOwner or 0

		itemProto.rlz = tonumber(record.q_rlx or 0)
		itemProto.qicaiMin = tonumber(record.q_qicai1 or 0)
		itemProto.qicaiMax = tonumber(record.q_qicai2 or 0)
		itemProto.qicaiRate = tonumber(record.q_qicai_rate or 100)
		
		itemProto.keyItem = record.q_keyItem or 0

		itemProto.dateOff = parseDateOff(record.q_dateoff)

		--检查装备表是否有
		if record.q_type and (tonumber(record.q_type) == 1 or tonumber(record.q_type) == 22) then
			local has = false
			for _, rd in pairs(equipDatas or {}) do
				if tonumber(rd.q_id) == tonumber(record.q_id) then
					has = true
				end
			end
			if has then
				g_configMgr:addItemProto(record.q_id, itemProto)
			else
				--print("装备配置错误:装备表找不到该ID的装备", record.q_id)
			end
		else
			g_configMgr:addItemProto(record.q_id, itemProto)
		end
		if record.q_limit_count and record.q_limit_period and record.q_limit_count > 0 and record.q_limit_period > 0 then
			g_configMgr:addDropLimit(record.q_id, record.q_limit_count, record.q_limit_period)
		end		
	end
	itemProto:delete()
end

--装备表
function loadEquipConfig()
	local equipDatas = require "data.EquipDB"
	
	local equipProto = EquipPrototype:new()
	for _, record in pairs(equipDatas or {}) do
		equipProto.id = tonumber(record.q_id) or 0
		equipProto.kind = tonumber(record.q_kind) or 0
		equipProto.sex = tonumber(record.q_sex) or 0
		equipProto.promoteType = tonumber(record.q_promoteType) or 1
		
		equipProto.attack_min = tonumber(record.q_attack_min) or 0
		equipProto.attack_max = tonumber(record.q_attack_max) or 0
		equipProto.defence_min = tonumber(record.q_defence_min) or 0
		equipProto.defence_max = tonumber(record.q_defence_max) or 0	
		equipProto.magic_attack_min = tonumber(record.q_magic_attack_min) or 0
		equipProto.magic_attack_max = tonumber(record.q_magic_attack_max) or 0
		equipProto.magic_defence_min = tonumber(record.q_magic_defence_min) or 0
		equipProto.magic_defence_max	= tonumber(record.q_magic_defence_max) or 0		
		equipProto.sc_attack_min = tonumber(record.q_sc_attack_min) or 0
		equipProto.sc_attack_max = tonumber(record.q_sc_attack_max) or 0

		equipProto.crit = tonumber(record.q_crit) or 0
		equipProto.hit = tonumber(record.q_hit) or 0		
		equipProto.dodge = tonumber(record.q_dodge) or 0
		equipProto.att_dodge = tonumber(record.q_att_dodge) or 0
		equipProto.mac_dodge = tonumber(record.q_mac_dodge) or 0
		equipProto.max_hp = tonumber(record.q_max_hp) or 0
		equipProto.max_mp = tonumber(record.q_max_mp) or 0

		equipProto.tenacity = tonumber(record.q_tenacity) or 0
		equipProto.project = tonumber(record.q_project) or 0
		equipProto.projectDef = tonumber(record.q_projectDef) or 0
		equipProto.benumb = tonumber(record.q_benumb) or 0
		equipProto.benumbDef = tonumber(record.q_benumbDef) or 0

		equipProto.attack_speed = tonumber(record.q_attack_speed) or 0
		equipProto.luck = tonumber(record.q_luck) or 0
		equipProto.levelUpID = tonumber(record.q_levelUpID) or 0
		equipProto.suitID = tonumber(record.q_suidId) or 0	
		equipProto.specialPropType = tonumber(record.q_equipSpecialPropType) or 0	
		equipProto.specialValue = tonumber(record.q_AddNumPre) or 0	
		equipProto.equipSpecialNum = tonumber(record.q_equipSpecialNum) or 0	
		equipProto.specialPropRate = tonumber(record.q_equipSpecialPropRate) or 0	
		



		if record.jihuo then
			local levelStrenthPropTB = unserialize(record.jihuo)

			local protolevel10 = levelStrenthPropTB[10]
			local protolevel15 = levelStrenthPropTB[15]
			local protolevel20 = levelStrenthPropTB[20]
			equipProto:clearLevelStengthProp()
			for propId, value in pairs(protolevel10) do
				equipProto:addLevelStengthProp(propId, value[1] or 0, value[2] or 0,10)
				break
			end

			for propId, value in pairs(protolevel15) do
				equipProto:addLevelStengthProp(propId, value[1] or 0, value[2] or 0,15)
				break
			end
			
			for propId, value in pairs(protolevel20) do
				equipProto:addLevelStengthProp(propId, value[1] or 0, value[2] or 0,20)
				break
			end
		end
		g_configMgr:addEquipProto(record.q_id, equipProto)
		
	end
	equipProto:delete()
end

--装备强化表
function loadEquipStrengthConfig()
	local equipStrengthDatas = require "data.EquipStrengthDB"
	local equipStrengthProto = EquipStrengthCost:new()
	for _, record in pairs(equipStrengthDatas or {}) do
		equipStrengthProto.equipType = tonumber(record.q_type) or 0
		equipStrengthProto.strengthLevel = tonumber(record.q_level) or 0
		equipStrengthProto.needMatID = tonumber(record.q_needMatID) or 0
		equipStrengthProto.needMatNum = tonumber(record.q_needMatNum) or 0
		equipStrengthProto.sucRate = tonumber(record.q_sucRate) or 0
		equipStrengthProto.needMoney = tonumber(record.q_needMoney) or 0
		equipStrengthProto.needSpecailMatID = tonumber(record.q_needSpecailMatID) or 0
		equipStrengthProto.needSpecailMatNum = tonumber(record.q_needSpecailMatNum) or 0
		equipStrengthProto.needInheritMatID = tonumber(record.q_needInheritMatID) or 0
		equipStrengthProto.needInheritMatNum = tonumber(record.q_needInheritMatNum) or 0
		equipStrengthProto.inheritNeedMoney = tonumber(record.q_inheritNeedMoney) or 0
		equipStrengthProto.freeCostLevel = tonumber(record.q_freeCostLevel) or 0
		equipStrengthProto.downRate = tonumber(record.q_downRate) or 0

		--熔炼返还材料
		equipStrengthProto:ClearSmelterGet()
		local smelterGet = unserialize(tostring(record.q_smelter)) or {}
		for i,v in pairs(smelterGet) do
			if i>0 and v>0 then
				equipStrengthProto:AddSmelterGet(i,v)
			end
		end

		--物品限价
		equipStrengthProto.min_price = tonumber(record.Min_price) or 0
		equipStrengthProto.max_price = tonumber(record.Max_price) or 0
		g_configMgr:addEquipStrengthProto(equipStrengthProto)
	end
	equipStrengthProto:delete()
end

--装备强化属性表
function loadEquipStrengthPropConfig()
	local totalDatas = require "data.EuipStrengthPropDB"
	
	local proto = EquipStrengthProp:new()
	for _, record in pairs(totalDatas or {}) do
		proto.id = record.q_id or 0

		proto.attack_min = tonumber(record.q_attack_min) or 0
		proto.attack_max = tonumber(record.q_attack_max) or 0
		proto.magic_attack_min = tonumber(record.q_magic_attack_min) or 0
		proto.magic_attack_max = tonumber(record.q_magic_attack_max) or 0
		proto.sc_attack_min = tonumber(record.q_sc_attack_min) or 0
		proto.sc_attack_max = tonumber(record.q_sc_attack_max) or 0
		proto.defence_min = tonumber(record.q_defence_min) or 0
		proto.defence_max = tonumber(record.q_defence_max) or 0
		proto.magic_defence_min = tonumber(record.q_magic_defence_min) or 0
		proto.magic_defence_max = tonumber(record.q_magic_defence_max) or 0
		proto.max_hp = tonumber(record.q_max_hp) or 0

		proto.crit = tonumber(record.q_crit) or 0
		proto.hit = tonumber(record.q_hit) or 0		
		proto.dodge = tonumber(record.q_dodge) or 0
		proto.luck = tonumber(record.q_luck) or 0
		proto.tenacity = tonumber(record.q_tenacity) or 0
		proto.project = tonumber(record.q_project) or 0
		proto.projectDef = tonumber(record.q_projectDef) or 0
		proto.benumb = tonumber(record.q_benumb) or 0
		proto.benumbDef = tonumber(record.q_benumbDef) or 0

		g_configMgr:addEquipStrengthPropProto(proto)
	end
	proto:delete()
end

--纹饰属性表
function loadEmblazonryConfig()
	local totalDatas = require "data.EmblazonryDB"
	
	local proto = EmblazonryProp:new()
	for _, record in pairs(totalDatas or {}) do
		proto.id = tonumber(record.q_id) or 0
		proto.job = tonumber(record.q_job) or 0
		proto.activeType = tonumber(record.q_activeType) or 0

		proto.attack_min = tonumber(record.q_attack_min) or 0
		proto.attack_max = tonumber(record.q_attack_max) or 0
		proto.magic_attack_min = tonumber(record.q_magic_attack_min) or 0
		proto.magic_attack_max = tonumber(record.q_magic_attack_max) or 0
		proto.sc_attack_min = tonumber(record.q_sc_attack_min) or 0
		proto.sc_attack_max = tonumber(record.q_sc_attack_max) or 0
		proto.defence_min = tonumber(record.q_defence_min) or 0
		proto.defence_max = tonumber(record.q_defence_max) or 0
		proto.magic_defence_min = tonumber(record.q_magic_defence_min) or 0
		proto.magic_defence_max = tonumber(record.q_magic_defence_max) or 0
		proto.max_hp = tonumber(record.q_max_hp) or 0

		proto.crit = tonumber(record.q_crit) or 0
		proto.hit = tonumber(record.q_hit) or 0		
		proto.dodge = tonumber(record.q_dodge) or 0
		proto.luck = tonumber(record.q_luck) or 0
		proto.tenacity = tonumber(record.q_tenacity) or 0
		proto.project = tonumber(record.q_project) or 0
		proto.projectDef = tonumber(record.q_projectDef) or 0
		proto.benumb = tonumber(record.q_benumb) or 0
		proto.benumbDef = tonumber(record.q_benumbDef) or 0

		proto.battle = tonumber(record.q_battle) or 0
		proto.decomposeNum = tonumber(record.q_decomposeNum) or 0
		proto.activeNum = tonumber(record.q_activeNum) or 0
		proto.suitID = tonumber(record.q_suitID) or 0

		g_configMgr:addEmblazonryPropProto(proto)
	end
	proto:delete()
end

--勋章属性表
function loadMableStrengthPropConfig()
	local totalDatas = require "data.MedalDB"
	
	local proto = EquipStrengthProp:new()
	for _, record in pairs(totalDatas or {}) do
		proto.attack_min = tonumber(record.q_attack_min) or 0
		proto.attack_max = tonumber(record.q_attack_max) or 0
		proto.magic_attack_min = tonumber(record.q_magic_attack_min) or 0
		proto.magic_attack_max = tonumber(record.q_magic_attack_max) or 0
		proto.sc_attack_min = tonumber(record.q_sc_attack_min) or 0
		proto.sc_attack_max = tonumber(record.q_sc_attack_max) or 0
		proto.defence_min = tonumber(record.q_defence_min) or 0
		proto.defence_max = tonumber(record.q_defence_max) or 0
		proto.magic_defence_min = tonumber(record.q_magic_defence_min) or 0
		proto.magic_defence_max = tonumber(record.q_magic_defence_max) or 0
		proto.max_hp = tonumber(record.q_max_hp) or 0

		proto.crit = tonumber(record.q_crit) or 0
		proto.hit = tonumber(record.q_hit) or 0		
		proto.dodge = tonumber(record.q_dodge) or 0
		proto.luck = tonumber(record.q_luck) or 0
		proto.tenacity = tonumber(record.q_tenacity) or 0
		proto.project = tonumber(record.q_project) or 0
		proto.projectDef = tonumber(record.q_projectDef) or 0
		proto.benumb = tonumber(record.q_benumb) or 0
		proto.benumbDef = tonumber(record.q_benumbDef) or 0
		proto.cost = tonumber(record.q_cost) or 0
		proto.equipType = tonumber(record.q_nextID) or 0
		proto.battle = tonumber(record.battle) or 0

		g_configMgr:addMableStrengthPropProto(record.q_ID, proto)
	end
	proto:delete()
end


--装备进阶表
function loadEquipPromoteConfig()
	local totalDatas = require "data.EquipPromoteDB"
	
	local proto = EquipPromoteCost:new()
	for _, record in pairs(totalDatas or {}) do
		proto.id = tonumber(record.q_id) or 0
		proto.needMatID = tonumber(record.q_needMatID) or 0
		proto.needMatNum = tonumber(record.q_needMatNum) or 0
		proto.needLevel = tonumber(record.q_needLevel) or 0
		proto.needMoney = tonumber(record.q_needMoney) or 0

		g_configMgr:addEquipPromoteProto(record.q_id, proto)
	end
	proto:delete()
end

--祝福油表
function loadBlessOilConfig()
	local totalDatas = require "data.BlessOilDB"
	
	local proto = BlessOilProp:new()
	for _, record in pairs(totalDatas or {}) do
		proto.ratelevel = tonumber(record.q_lvl) or 0
		proto.rateType = tonumber(record.q_type) or 0
		proto.succPer = tonumber(record.q_succPer) or 0
		proto.failPer = tonumber(record.q_failPer) or 0
		proto.degradePer = tonumber(record.q_degradePer) or 0
		proto.needMoney = tonumber(record.q_needMoney) or 0

		g_configMgr:addBlessOilProto(proto)
	end
	proto:delete()
end

--杀人诅咒表
function loadKillerCurseConfig()
	local totalDatas = require "data.KillerCurseDB"
	
	local proto = KillerCurse:new()
	for _, record in pairs(totalDatas or {}) do
		proto.downRate = tonumber(record.downRate) or 0
		g_configMgr:addKillerCurseProto(tonumber(record.luck), proto)
	end
	proto:delete()
end

--套装信息表
function loadEquipSuitConfig()
	local totalDatas = require "data.EquipSuitDB"
	
	local proto = SuitPrototype:new()
	for _, record in pairs(totalDatas or {}) do
		proto.id = tonumber(record.q_suidId) or 0
		proto.suitNum = tonumber(record.q_suitNum) or 0	
		proto.attack_min = tonumber(record.q_attack_min) or 0
		proto.attack_max = tonumber(record.q_attack_max) or 0
		proto.defence_min = tonumber(record.q_defence_min) or 0
		proto.defence_max = tonumber(record.q_defence_max) or 0	
		proto.magic_attack_min = tonumber(record.q_magic_attack_min) or 0
		proto.magic_attack_max = tonumber(record.q_magic_attack_max) or 0
		proto.magic_defence_min = tonumber(record.q_magic_defence_min) or 0
		proto.magic_defence_max	= tonumber(record.q_magic_defence_max) or 0		
		proto.sc_attack_min = tonumber(record.q_sc_attack_min) or 0
		proto.sc_attack_max = tonumber(record.q_sc_attack_max) or 0

		proto.crit = tonumber(record.q_crit) or 0
		proto.hit = tonumber(record.q_hit) or 0		
		proto.dodge = tonumber(record.q_dodge) or 0
		proto.max_hp = tonumber(record.q_max_hp) or 0
		proto.max_mp = tonumber(record.q_max_mp) or 0
		proto.attack_speed = tonumber(record.q_attack_speed) or 0
		proto.luck = tonumber(record.q_luck) or 0
		proto.tenacity = tonumber(record.q_tenacity) or 0
		proto.project = tonumber(record.q_project) or 0
		proto.projectDef = tonumber(record.q_projectDef) or 0
		proto.benumb = tonumber(record.q_benumb) or 0
		proto.benumbDef = tonumber(record.q_benumbDef) or 0
		proto.specialSkill1 = tonumber(record.Special_Skill1) or 0
		proto.specialNum1 = tonumber(record.Special_Num1) or 0
		proto.specialSkill2 = tonumber(record.Special_Skill2) or 0
		proto.specialNum2 = tonumber(record.Special_Num2) or 0
		

		g_configMgr:addEquipSuitProto(proto)
	end
	proto:delete()
end

--随机属性表
function loadRandPropConfig()
	local totalDatas = require "data.EquipRandPropDB"
	
	local proto = EquipRandPropProto:new()
	for _, record in pairs(totalDatas or {}) do
		proto.maxFloor = tonumber(record.q_maxFloor) or 2
		proto.attack = tonumber(record.q_attack) or 0
		proto.magic_attack = tonumber(record.q_magic_attack) or 0
		proto.sc_attack = tonumber(record.q_sc_attack) or 0
		proto.defence = tonumber(record.q_defence) or 0		
		proto.magic_defence = tonumber(record.q_magic_defence) or 0
		proto.crit = tonumber(record.q_crit) or 0
		proto.hit = tonumber(record.q_hit) or 0		
		proto.dodge = tonumber(record.q_dodge) or 0
		proto.max_hp = tonumber(record.q_max_hp) or 0
		proto.luck = tonumber(record.q_luck) or 0
		proto.tenacity = tonumber(record.q_tenacity) or 0
		proto.project = tonumber(record.q_project) or 0
		proto.projectDef = tonumber(record.q_projectDef) or 0
		proto.benumb = tonumber(record.q_benumb) or 0
		proto.benumbDef = tonumber(record.q_benumbDef) or 0
		
		if tonumber(record.q_id) > 0 then
			g_configMgr:addEquipRandProp(tonumber(record.q_id), proto)
		end
	end
	proto:delete()
end

--装备随机权重表表
function loadWeightConfig()
	local totalDatas = require "data.weightDB"
	
	for _, record in pairs(totalDatas or {}) do
		local floorNum = tonumber(record.q_floor)
		for i=1,floorNum do
			local field = 'q_value'..i
			local fieldValue = tonumber(record[field])
			g_configMgr:addWeightProto(floorNum, fieldValue)
		end
	end
end

function loadDropItem()
    local drop_map = require "data.DropDB" 
	local dropItem = DropItem:new()   
    for _, record in pairs(drop_map or {}) do
        dropItem.itemID = record.q_item or 0
        dropItem.count = record.q_count or 0
		dropItem.bind = (tonumber(record.bdlx) == 1)
        dropItem.on_rank = tonumber(record.q_onrank) or 0
		dropItem.strength = tonumber(record.q_strength) or 0
		dropItem.qtdl = tonumber(record.qtdl) or 0
		dropItem.rate = tonumber(record.q_property) or 0
		dropItem.qfdl = tonumber(record.qfdl) or 0
		dropItem.show = (tonumber(record.show) == 1)
		dropItem.showtime = tonumber(record.showtime) or 0
		dropItem.droptime = tonumber(record.droptime) or 0
		
		g_configMgr:addDropPrototype(record.q_id, record.q_group, dropItem)
    end
	dropItem:delete()
end
function reloadDropItem()
	g_configMgr:clearDropPrototype()
	reloadModule("data.DropDB")
	loadDropItem()
	print("DropDB reloaded")
end

function changeDropItem(dropID)
	print('changeDropItem:',dropID)
	local drop_map = reloadModule("data.DropDB")
	g_configMgr:eraseDropPrototype(dropID)
	local dropItem = DropItem:new()
    for _, record in pairs(drop_map or {}) do
    	if tonumber(record.q_id) == dropID then
	        dropItem.itemID = record.q_item or 0
	        dropItem.count = record.q_count or 0
			dropItem.bind = (tonumber(record.bdlx) == 1)
	        dropItem.on_rank = tonumber(record.q_onrank) or 0
			dropItem.strength = tonumber(record.q_strength) or 0
			dropItem.qtdl = tonumber(record.qtdl) or 0
			dropItem.rate = tonumber(record.q_property) or 0
			dropItem.qfdl = tonumber(record.qfdl) or 0
			dropItem.show = (tonumber(record.show) == 1)
			dropItem.showtime = tonumber(record.showtime) or 0
			dropItem.droptime = tonumber(record.droptime) or 0		
			g_configMgr:addDropPrototype(record.q_id, record.q_group, dropItem)
		end
    end
	dropItem:delete()
end

function loadNewFuncConfig()
	local activeCfg = require "data.NewFunctionCfgDB"	
	for _, info in pairs(activeCfg) do
		g_configMgr:addNewFuncConfig(tonumber(info.q_ID), tonumber(info.q_level))
	end
end

function loadPotionDB()
	local potionCfg = require "data.Potion"	
	for _, info in pairs(potionCfg) do
		local level = info.q_level
		local info_item = unserialize(info.q_refresh)
		for id, hm_v in pairs(info_item) do
			if hm_v[1] > 0 then	
				g_configMgr:addHPRecover(id, level, hm_v[1])
			end
			if hm_v[2] > 0 then	
				g_configMgr:addMPRecover(id, level, hm_v[1])
			end
		end
	end
end

function loadEquipCompoundConfig()
	local compoundCfg = require "data.Forge"
	local cfgInfo = EquipCompoundProp:new()
	for i,v in pairs(compoundCfg or {}) do
		cfgInfo:ClearData()
		cfgInfo.nOptionType = tonumber(v.q_sort or 0)
		cfgInfo.nCompoundType = tonumber(v.q_menu or 0)
		local itemIDTmp = tostring(v.q_itemID or "")
		local itemIDList = unserialize(itemIDTmp)

		local itemNum = 0
		for i,v in pairs(itemIDList or {}) do
			if type(v) == "table" then
				itemNum = itemNum + 1
				for j,k in pairs(v) do
					if j>0 and k>0 then
						cfgInfo:AddTargetItemID(i,j,k)
					end
				end
			end
		end
		if itemNum > 1 then
			cfgInfo.nSexLimit = 1
		end
		
		local forgecostTmp = tostring(v.q_forgeCost or "")
		local forgecostList = unserialize(forgecostTmp)
	
		for i,v in pairs(forgecostList or {}) do
			if i>0 and v>0 then
				cfgInfo:AddMatCost(i,v)
			end
		end
		g_configMgr:addEquipCompoundProto(tonumber(v.q_id), cfgInfo)
	end
	cfgInfo:delete()
end

function loadStallConfig()
	local stallCfg = require "data.TransactionLimit"
	for _, info in pairs(stallCfg or {}) do
		if info.q_query_type > 0 and info.q_LimitMin > 0 and info.q_LimitMax > 0  and info.q_MaxNum2 > 0 then
			g_configMgr:addStallPrice(info.q_ItemId, info.q_LimitMax, info.q_LimitMin, info.q_query_type, info.q_MaxNum2)
		end
	end
end
