--------------------------------------------------------
-- 基础物品数据管理
--------------------------------------------------------
REMISSION_DRUG = 561
ItemData = ItemData or BaseClass()
ItemData.USE_ITEM_EFF_CACHE = nil

ItemData.ItemType = {		
	itUndefinedType = 0,		-- 未定义类型的物品
	itWeapon = 1,				-- 武器
	itDress = 2,				-- 衣服
	itHelmet = 3,				-- 头盔
	itNecklace = 4,				-- 项链
	itBracelet  = 5,			-- 手镯
	itRing = 6,					-- 戒指
	itGirdle = 7,				-- 腰带
	itShoes = 8,				-- 鞋子

	itBaseEquipment = 9,       -- 最大的基础装备物品类型id
	itEquipProduceTheBest = 9,     -- 产出极品属性最大的装备物品id

	itWarmBloodDivinesword =9,     --热血神兵
	itWarmBloodGodNail = 10,        --热血神甲
	itWarmBloodElbowPads = 11,      --热血面甲
	itWarmBloodShoulderPads = 12,	--热血护肩
	itWarmBloodPendant = 13,		--热血吊坠
	itWarmBloodKneecap = 14,		--热血护膝
	itKillArraySha = 15,			--杀阵_天煞
	itKillArrayMost = 16,			--杀阵_天绝


	itHandedDownDress = 17,		-- 传世_衣服
	itHandedDownHelmet = 18,	-- 传世_头盔
	itHandedDownNecklace = 19,	-- 传世_项链
	itHandedDownBracelet = 20,	-- 传世_手镯
	itHandedDownRing = 21,		-- 传世_戒指
	itHandedDownGirdle = 22,	-- 传世_腰带
	itHandedDownShoes = 23,		-- 传世_鞋子
	itHandedDownWeapon = 24,	-- 传世_武器
	itGlove = 25,	            -- 灭霸手套
	itSpecialRing = 26,			-- 特戒

	itSubmachineGun = 27,       --冲锋枪
	itOpenCar = 28,            	--敞篷车
	itAnCrown = 29,            	--皇冠
	itGoldenSkull = 30,         --金骷髅
	itGoldChain = 31,           -- 金链子
	itGoldPipe =32,            	--金烟斗
	itGoldDice = 33,            --金骰子
	itGlobeflower = 34,         --金莲花
	itJazzHat = 35,            	-- 爵士帽
	itRolex = 36,            	--劳力士
	itDiamondRing =37,          --钻戒
	itGentlemenBoots = 38,      --绅士靴


	itKillArrayRobbery = 39,	--杀阵_天劫
	itKillArrayLife = 40,		--杀阵_天命

	itGodWarHelmet = 41,		--战神_头盔
	itGodWarNecklace = 42,		--战神_项链
	itGodWarBracelet = 43,		--战神_手镯
	itGodWarRing = 44,			--战神_戒指
	itGodWarGirdle = 45,		--战神_腰带
	itGodWarShoes = 46,			--战神_鞋子

	itEquipMax = 46,                 -- 最大的装备ID

	itHeroEquipMin = 50,
	itHeroCuff = 50,             -- 战宠装备
	itHeroNecklace=51 ,          -- 装备2
	itHeroDecorations =52,       -- 装备3
	itHeroArmor =53,             -- 装备4 
	itHeroEquipMax = 53,         -- 最大的装备ID

	itQuestItem = 101,			-- 任务物品
	itFunctionItem = 102,		-- 功能物品，可以双击执行功能脚本的
	itMedicaments = 103,		-- 调用BUFFID类型
	itFastMedicaments = 104,	-- 瞬间恢复药品
	itItemDiamond = 105,          -- 宝石镶嵌材料
	itItemEquivalence = 106,     -- 材料
	itItemEquipEnhance = 107,    -- 装备强化类，比如强化石等
	itItemSkillMiji = 108,       -- 技能的秘籍
	itItemPetSkill = 109,         -- 宠物的技能书
	itPetMedicaments = 110,		-- 宠物普通药品
	itPetFastMedicaments = 111,	-- 宠物速回药品
	itPetSkinChange = 112,	    -- 宠物换皮肤道具
	itHpPot = 113,              -- 经验珠(杀怪自动注入经验)
	itMine = 114,               -- 矿物，和普通物品比它的耐久表示纯度和最大纯度
	itItemBox = 115, 			-- 宝箱(特殊的) 钻石萌宠系统产出

	itRune = 119,				-- 符文
	itFashion = 120,			-- 时装 
	itWuHuan = 121,				-- 幻武
	itShengXiao = 122,			-- 生肖
	itTreasureMap = 123,		-- 藏宝图
	itPokedex = 124,			-- 图鉴
	itGodWing = 125,			-- 神翼

	itHeartMin = 126,
	itFirstHeart = 126,			-- 首篇心法
	itPartOneHeart = 127,		-- 上篇心法
	itNoveletteHeart = 128,		-- 中篇心法
	itPartTwoHeart = 129,		-- 下篇心法
	itFinalChapterHeart = 130,	-- 终篇心法
	itHeartMax = 130,

	itHolyMin = 131,
	itDragonHoly = 131,			-- 青龙圣物
	itWhiteTigerHoly = 132,		-- 白虎圣物
	itRosefinchHoly = 133,		-- 朱雀圣物
	itXuanWuHoly = 134,			-- 玄武圣物
	itUnicornHoly = 135,		-- 麒麟对物
	itHolyMax = 135,

	itFeather = 136,			-- 飞羽
	itFiberFeather = 137,		-- 纤羽
	itCashmereFeather = 138,	-- 绒羽
	itLingFeather = 139,		-- 翎羽

	itShaYuDan = 140,			-- 砂玉丹
	itBloodYaDan = 141,			-- 血牙丹
	itChiHuangDan = 142,		-- 炽凰丹

	itZhanwen = 143,			-- 战纹

	itSelectItem = 144,			-- 可选物品

	itItemTypeCount = 144,			-- 物品类型的数量，最大值，类型值不一定是连续的
	itConstellationItem = 145,		-- 星魂物品
	itGuardEquip = 146,				-- 守护神装
	itWingEquip = 147, 				-- 翅膀装备
	itGenuineQi = 148, 				-- 真气

	-- 客户端自定义
	itLeftSpecialRing = 100000,			-- 左边特戒
	itRightSpecialRing = 100001,		-- 右边特戒
	itTheDragon = 100002,				-- 龙符
	itShield = 100003,					-- 护盾
	itGemStone = 100004,				-- 宝石
	itDragonSpirit = 100005,			-- 龙魂
	itShenDing = 100006,				-- 神鼎
}





ItemData.UseCondition = {
	ucLevel = 1,					--等级必须大于等于value级 如果为魂石则代表效果激活的装备等级
	ucGender = 2,						--性别编号必须等于value，0男1女
	ucJob = 3,						--职业编号必须等于value
	ucMarried = 4,					--结婚与否必须等于value
	ucMountSkillLevel = 5,  			--骑术等级
	ucCampTitle = 6,       			--需要阵营的官职
	ucAchievePoint = 7,       		--成就点必须大于等于value
	ucPhysicalAttackMax = 8, 		--物理攻击最大值必须大于等于value
	ucMagicAttackMax = 9, 			--魔法攻击最大值必须大于等于value
	ucWizardAttackMax = 10, 			--道术攻击最大值必须大于等于value
	ucSocialMask = 11,				--武林盟主
	ucBattlePower = 12,				--玩家的战力必须大于等于value
	ucMinCircle = 13,				--大于等于这个转生才能使用
	ucMaxCircle = 14,				--小于等于这个转生才能使用
	ucFamousPeople = 15,			--需要名人堂
	ucHeroTopLevel = 16,			--英雄的最高等级
	ucHeroTopCircle = 17,			--英雄的最高转数
	ucDiamondPower = 18,			--魂石战力
	ucRuneSuitID = 19,				--符文套id
	ucRuneTakeOnPos = 20,			--符文装备槽位
}

-- 定义物品的标志属性结构
ITEM_FLAG = {
	[0] = "recordLog",      				--是否记录流通日志
	[1] = "denyStorage",     				--是否禁止存仓库
	[2] = "autoBindOnTake",  				--是否在穿戴后自动绑定
	[3] = "autoStartTime",   				--是否在获得时即开始计算时间，如果不具有此标志则将在装备第一次被穿戴的时候开始计时
	[4] = "denyDeal",     					--是否禁止交易
	[5] = "denySell",						--是否禁止出售到商店
	[6] = "denyDestroy",					--是否禁止销毁
	[7] = "destroyOnOffline",				--是否在角色下线时自动消失
	[8] = "destroyOnDie",					--是否在角色死亡时自动消失
	[9] = "denyDropdown", 					--是否禁止在死亡时爆出
	[10] = "dieDropdown",					--是否在角色死亡时强制爆出
	[11] = "offlineDropdown", 				--是否在角色下线时强制爆出 
	[12] = "hideDura",          			--隐藏耐久
	[13] = "denySplite",        			--是否禁止在物品叠加后进行拆分（通常用于带有实现限制的物品）
	[14] = "asQuestItem",		 			--是否作为任务需求物品使用
	[15] = "monAlwaysDropdown",				--是否在怪物死亡爆出时不检查杀怪者等级差而均掉落
	[16] = "hideQualityName",  				--隐藏品质颜色
	[17] = "useOnPractice", 				--能否在操练的时候使用
	[18] = "inlayable",						--是否可打孔（打孔后才能镶嵌）
	[19] = "denyTipsAutoLine",  			--拒绝换行
	[20] = "showLootTips",    				--是否显示掉落提示
	[21] = "denyDropDua",					--死亡或攻击等时禁止扣除耐久
	[22] = "denyRepair",					--装备禁止修理
	[23] = "canDig",         				--能够挖矿
	[24] = "fullDel",         				--buff药，满了buff要消失，同时满了，是无法添加上buff
	[25] = "diamondAlwaysActive",			--忽略魂石激活条件，总是激活(装备配置)
	[26] = "denyBuffOverlay",  				--buff物品，时间不叠加的配置true
	[27] = "skillRemoveItem",				--标记是否能通过技能扣除物品
	[28] = "denyHeroUse",					--禁止英雄使用
	[29] = "matchAllSuit",        			--匹配所有的套装，用于稀有神器，穿上激活所有套装该部位的属性
	[30] = "notConsumeForCircleForge",		--转生锻造时不需要副装备
	[31] = "notShowAppear",					--不显示外观(用于装备)
	[32] = "canMoveAttr",					--该装备的附加属性是否可以转移
	[33] = "notAddToBag",					--是否可以加到背包,默认是可以为false
	[34] = "broadcast",						--掉落物品是否全服广播
	[35] = "notdura",						--新物品耐久度为0(用于灌泉物品等)
	[36] = "useOther",						--物品对别的玩家的使用 默认为false
	[37] = "autoSell",						--穿戴某件装备,身上的那件自动售卖
	[38] = "denyReclaim",					--是否不能再背包回收面板回收
	[39] = "getItemLog",					--玩家得到物品是否记录产生物品日记
	[40] = "superAttr",						--是否可以锻造极品属性
	[41] = "godEquip",     					--是否是神装
	[42] = "useCountLimit",					--使用次数限制(隔天清0)
	[43] = "isCanOnekeyUse",				--能否一键使用
}

--金钱的类型的定义
MoneyType = {
	BindCoin = 0,        	--不可交易的金钱，比如系统奖励的一些金钱 
	Coin = 1,			 	--可交易的金钱，如任务等发送的金钱
	BindYuanbao = 2,     	--不可交易的元宝，一般是系统奖励的 
	Yuanbao = 3,		 	--可交易的元宝，玩家充值兑换的
	StorePoint = 4,	  		--商城积分，消费元宝时产出
	Honour = 5,		  		--荣誉
	
	ZhanXun = 6,			--战勋
	Energy = 7,				--能量点
	RedDiamond = 8,			--红钻
	Yongzhe = 9, 			--勇者积分
	MoneyTypeStart = 0,
}

MoneyTypeDef = {
	[MoneyType.Coin] = 493,
	[MoneyType.Yuanbao] = 495,
	[MoneyType.RedDiamond] = 494,
}

ItemGetType = {
	OtherGetItem = 0,					-- 其它方式获取
	ScenePickup = 1,					-- 场景拾取
	DepotTakeOut = 2,					-- 仓库取出
	DealGetItem = 3,					-- 交易获得
	TakeOnItem = 4,						-- 穿上
	TakeOffItem = 5,					-- 脱下物品
	AwardItem = 7,						-- 奖励获得
	SplitItem = 8,						-- 拆分物品
	BrokedownItem = 9,					-- 分解物品
	ForgingItem = 10,					-- 合成,升级,强化,精炼,镶嵌之类,列为锻造
	GodEquipItem = 11,					-- 神装升级 锻造获得
}

ItemSpecialType = {
	ChangeNameCard = 1,			-- 改名卡
	ExpBead = 2,				-- 经验珠
	TeteportStone = 3,		    -- 传送石(不在这处理)
	GiftPacket = 4,		        -- 奖励礼包
	NGBead = 5,		            -- 内功珠
}

-- 有时间限制的物品
ItemData.IsShowTimeItem = {
}

ItemData.IsFashionCard = {
	MINCARD = 1685,
	MAXCARD = 1704,
}
ItemData.IsHuanWuCard = {
	MINCARD = 1982,
	MAXCARD = 1991,
}

ItemData.BatchStatus = {
	BatchUse = 2,				-- 大于等于时批量使用
	OpenView = 10,				-- 弹窗推荐效果
	OpenViewAndBatchUse = 11,	-- 弹窗+批量使用
}

----返回一个背包数据结构
local function SetBag(list)
	local list_ = {}
	for i,v in ipairs(list) do
		list_[v] = true
	end
	return list_
end

ItemData.ItHandedDownProp = SetBag{3468, 3469, 3470, 3471, 3472, 3473, 3474, 3475}	--传世模具
ItemData.ItMedicaments = SetBag{3559, 3560, 3561, 3562, 3563,3614,3615}				--药品

function ItemData:__init()
	if ItemData.Instance then
		ErrorLog("[ItemData] Attemp to create a singleton twice !")
	end
	ItemData.Instance = self
	
	self.time_list = {}								--时间限制物品boss召唤令
	
	self.item_config_list = {}
	self.item_config_query_list = {}
	self.item_config_query_timer = nil
	self.item_config_callback_list = {}				-- 获得物品配置回调
	self.item_use_limit_t = {}

	self.virtual_item_id_inc = 1000000 -- 虚拟物品id起始值

	self:InitItemConfig()


end

function ItemData:__delete()
	ItemData.Instance = nil

	self.equip_data_list = nil
	self.item_config_callback_list = {}
	self.daley_item_list = {}
	GlobalTimerQuest:CancelQuest(self.item_daley_timer)
	self.item_daley_timer = nil
	self:DeleteSpareTimer()
end

function ItemData:InitItemConfig()
end

-- 基础属性加成
function ItemData.GetBasePlusAttrs(item_cfg)
	local base_plus = item_cfg.basePlus
	if base_plus then
		return CommonDataManager.MulAtt(CommonDataManager.GetBaseAttrs(item_cfg.staitcAttrs), base_plus / 100)
	else
		return {}
	end
end

-- 物品极属性
function ItemData:GetJipingAttrs(item_data)
	if nil == item_data.jipin_level then
		return {}
	end
	local attr = self:GetItemConfig(item_data.item_id).staitcAttrs
	return CommonDataManager.MulAtt(CommonDataManager.GetBaseAttrs(attr), item_data.jipin_level / 100)
end

-- 实际属性
-- 计算加成之后的属性
function ItemData.GetRealAttrs(item_cfg)
	if nil == base_plus then return item_cfg.staitcAttrs end

	--calc
	local calc_attr = DeepCopy(item_cfg.staitcAttrs)
	local base_plus = item_cfg.basePlus / 100
	
	local calc_plus = function (num, plus)
		return num + math.floor(num * plus)
	end
	--属性加成
	for i,v in ipairs(calc_attr) do
		v.value = calc_plus(v.value, base_plus)
	end
	return calc_attr
end

function ItemData.GetStaitcAttrs(item_cfg)
	local base_plus = item_cfg.basePlus
	if base_plus then
		return CommonDataManager.AddAttr(item_cfg.staitcAttrs, ItemData.GetBasePlusAttrs(item_cfg))
	else
		return item_cfg.staitcAttrs
	end
end

-- 基础属性加成
function ItemData.GetFusionAttrs(attrs, item_data)
	local fusion_lv = EquipmentFusionData.GetFusionLv(item_data)
	if fusion_lv > 0 then
		local equip_type = ItemData.GetIsBasisEquip(item_id) and 1 or 2
		local cfg = EquipMeltCfg or {}
		local meltcfg = cfg.meltcfg and cfg.meltcfg[equip_type] or {}
		local cur_meltcfg = meltcfg[fusion_lv] or {}
		local attrrate = cur_meltcfg.attrrate or 0
		return CommonDataManager.MulAtt(attrs, 1 + attrrate / 10000)
	else
		return attrs
	end
end

--获得物品分数
function ItemData:GetItemScoreByData(item_data, is_flush)
	if item_data == nil then
		return 0
	end

	local cfg = self:GetItemConfig(item_data.item_id)
	return self:GetItemScore(cfg, item_data, is_flush)
end

-- 获得物品分数
-- is_flush 为 ture 时,重新改算分数,否则直接取item_data中的评分
function ItemData:GetItemScore(item_cfg, item_data, is_flush)
	if item_cfg == nil then
		return 0
	end

	local pingfen
	if is_flush or item_data == nil or item_data.score == nil then
		if item_cfg.type == ItemData.ItemType.itSpecialRing then -- 特戒评分
			if item_data then
				pingfen = SpecialRingData.GetSpecialRingPower(item_data)
			else
				pingfen = SpecialRingData.GetSpecialRingPower(item_cfg)
			end
		else
			local attrs = self.GetStaitcAttrs(item_cfg)
			if item_data then
				-- 融合属性
				attrs = ItemData.GetFusionAttrs(attrs, item_data)

				-- 极品属性
				-- attrs = CommonDataManager.AddAttr(attrs, self:GetJipingAttrs(item_data))

				-- 鉴定属性
				-- local authenticate_attr = item_data.authenticate and item_data.authenticate.attr or {}
				-- attrs = CommonDataManager.AddAttr(attrs, authenticate_attr)
			end

			local prof_limit = self:GetItemLimit(item_cfg.item_id, ItemData.UseCondition.ucJob)
			if prof_limit == 0 then
				prof_limit = RoleData.Instance:GetRoleBaseProf()
			end

			pingfen = CommonDataManager.GetAttrSetScore(attrs, prof_limit)
		end

		if item_data then
			item_data.score = pingfen
		end
	else
		pingfen = item_data.score
	end

	return pingfen
end

--添加虚拟物品配置
function ItemData:AddVirtualItemConfig(item_cfg, item_id)
	if nil == item_cfg then
		return
	end

	-- 未指定物品id使用虚拟物品id自增量
	if nil == item_id then
		self.virtual_item_id_inc = self.virtual_item_id_inc + 1
		item_id = self.virtual_item_id_inc
	end
	item_cfg.item_id = item_id
	item_cfg.id = item_id

	self.item_config_list[item_id] = item_cfg

	return item_id
end

--添加物品配置
function ItemData:AddItemConfig(item_config_t)
	for k, v in pairs(item_config_t) do
		self.item_config_list[v.item_id] = v
		self.item_config_query_list[v.item_id] = nil
	end
end

--获得物品配置
function ItemData:GetItemConfig(item_id)
	if nil == item_id or item_id <= 0 then
		return CommonStruct.ItemConfig()
	end
	

	if nil == self.item_config_list[item_id] then
		if (item_id >= 10000) then
			local info = ConfigManager.Instance:GetClientConfig("virtualItem_cfg/" .. item_id)
			if info then
				info.item_id = info.id
				self.item_config_list[item_id] = info		-- 配置
			end
		else
			local item_cfg = ConfigManager.Instance:GetItemConfig(item_id)
			if item_cfg then
				item_cfg.item_id = item_cfg.id
				self.item_config_list[item_id] = item_cfg
			end
		end
	end
	return self.item_config_list[item_id] or CommonStruct.ItemConfig()
end

function ItemData:GetExpenseItemConfig(item_id)
	return ConfigManager.Instance:GetAutoItemConfig("expense_auto") [item_id]
end

--获取礼包配置
function ItemData:GetGiftConfig(gift_id)
	local gift_cfg = ConfigManager.Instance:GetAutoItemConfig("gift_auto") [gift_id]
	if gift_cfg then
		local giftData = DeepCopy(gift_cfg)
		giftData.item_data = {}
		for i = 1, giftData.item_num do
			giftData.item_data[i] = DeepCopy(self:GetItemConfig(giftData["item_" .. i .. "_id"]))
			giftData.item_data[i].num = giftData["item_" .. i .. "_num"]
			giftData.item_data[i].isbind = giftData["is_bind_" .. i]
		end
		return giftData
	end
	return nil
end


-- 获取装备类型名字
function ItemData.GetEquipTypeName(sub_type)
	if sub_type == GameEnum.EQUIP_TYPE_TOUKUI then
		return Language.EquipTypeName.TouKui							--头盔
	elseif sub_type == GameEnum.EQUIP_TYPE_YIFU then
		return Language.EquipTypeName.YiFu								--衣服
	elseif sub_type == GameEnum.EQUIP_TYPE_YAODAI then
		return Language.EquipTypeName.YaoDai							--腰带
	elseif sub_type == GameEnum.EQUIP_TYPE_HUTUI then
		return Language.EquipTypeName.HuTui								--护腿
	elseif sub_type == GameEnum.EQUIP_TYPE_XIEZI then
		return Language.EquipTypeName.XieZi								--鞋子
	elseif sub_type == GameEnum.EQUIP_TYPE_HUSHOU then
		return Language.EquipTypeName.HuShou							--护手
	elseif sub_type == GameEnum.EQUIP_TYPE_XIANGLIAN then
		return Language.EquipTypeName.XianLian							--项链
	elseif sub_type == GameEnum.EQUIP_TYPE_WUQI then
		return Language.EquipTypeName.WuQi								--武器 剑 刺 笔 杖
	elseif sub_type == GameEnum.EQUIP_TYPE_JIEZHI then
		return Language.EquipTypeName.JieZhi							--戒指 
	end
	return ""
end

-- 根据装备品质获取装备品质百分比
function ItemData.GetEquipQualityPercent(quality)
	local equipforge_auto = EquipmentData.GetConfig()
	local up_quality = equipforge_auto.up_quality --品质表
	for k, v in pairs(up_quality) do
		if v.quality == quality then
			return v.attr_percent
		end
	end
	return nil
end

-- 根据装备品质获取装备品质加成百分比
function ItemData.GetEquipQualityAddPercent(quality)
	local equipforge_auto = EquipmentData.GetConfig()
	local up_quality = equipforge_auto.up_quality --品质表
	local min_percent = up_quality[1] and up_quality[1].attr_percent or 0
	for k, v in pairs(up_quality) do
		if v.quality == quality and min_percent > 0 then
			return math.floor((v.attr_percent - min_percent) / min_percent * 100)
		end
	end
	return nil
end

-- 根据强化等级获取装备强化百分比
function ItemData.GetEquipStrengthPercent(strength_level)
	local equipforge_auto = EquipmentData.GetConfig()
	local up_quality = equipforge_auto.strength_base --强化操作表
	for k, v in pairs(up_quality) do
		if v.strength_level == strength_level then
			return v.add_percent
		end
	end
	return nil
end

-- 是否可以合成
function ItemData.IsCompose(item_id)
	-- local compose_list = ConfigManager.Instance:GetAutoConfig("compose_auto").compose_list
	-- for k,v in pairs(compose_list) do
	-- 	for i=1,4 do 	--最多4种材料
	-- 		if v["stuff_id_" .. i] == item_id and v.type ~= 0 and v.type ~= 5 then
	-- 			return true
	-- 		end
	-- 	end
	-- end
	return false
end

function ItemData.CreateItemBaseVo(config)
	if not config then
		return
	end
	local vo = DeepCopy(config)
	vo.item_id = config.id --配置命名不一样
	return vo
end

function ItemData:GetItemSellPrice(item_id)
	local basecfg, bigtype = self:GetItemConfig(item_id)
	if not basecfg then
		return 0
	end
	return basecfg.sellprice
end

function ItemData:GetItemRecycleGet(item_id)
	local basecfg, bigtype = self:GetItemConfig(item_id)
	if not basecfg then
		return 0
	end
	return basecfg.recyclget
end

function ItemData:GetItemAllConfig()  ---优化？
	local item_all_config = {[GameEnum.ITEM_BIGTYPE_EQUIPMENT] = ConfigManager.Instance:GetAutoItemConfig("equipment_auto"),	--装备
	[GameEnum.ITEM_BIGTYPE_EXPENSE] = ConfigManager.Instance:GetAutoItemConfig("expense_auto"),				--消耗
	[GameEnum.ITEM_BIGTYPE_GIF] = ConfigManager.Instance:GetAutoItemConfig("gift_auto"),					--礼包
	[GameEnum.ITEM_BIGTYPE_OTHER] = ConfigManager.Instance:GetAutoItemConfig("other_auto"),					--其他
	[GameEnum.ITEM_BIGTYPE_VIRTUAL] = ConfigManager.Instance:GetAutoItemConfig("virtual_auto"),				--虚拟
	}
	return item_all_config
end

-- 得到有颜色物品的名字富文本格式
function ItemData:GetItemNameRich(item_id, size)
	item_id = tonumber(item_id)
	local item_cfg, big_type = self:GetItemConfig(item_id)
	if item_cfg == nil then
		return "error"
	end
	local item_color = string.format("%06x", item_cfg.color)

	if nil ~= size then
		return string.format("{colorandsize;%s;%d;%s}", item_color, size, item_cfg.name)
	else
		return string.format("{color;%s;%s}", item_color, item_cfg.name)
	end
end

function ItemData:GetItemName(item_id, equip_data, is_html, size)
	item_id = tonumber(item_id)
	local item_cfg, big_type = self:GetItemConfig(item_id)
	if item_cfg == nil then
		return "error"
	end
	local name = item_cfg.name
	if is_html then
		local color = self:GetItemColor(item_id, equip_data)
		name = HtmlTool.GetHtml(name, color, size)
	end
	return name
end

function ItemData:GetItemColor(item_id, equip_data)
	local item_cfg, big_type = self:GetItemConfig(item_id)
	if item_cfg == nil then
		return COLOR3B.WHITE
	end

	return Str2C3b(string.format("%06x", item_cfg.color))
end

--是否是心法
function ItemData:IsHeart(item_id)
	local item_cfg = self:GetItemConfig(item_id)
	if item_cfg.type >= ItemData.ItemType.itHeartMin and item_cfg.type <= ItemData.ItemType.itHeartMax then
		return true
	end
	return false
end

--是否是圣物
function ItemData:IsHoly(item_id)
	local item_cfg = self:GetItemConfig(item_id)
	if item_cfg.type >= ItemData.ItemType.itHolyMin and item_cfg.type <= ItemData.ItemType.itHolyMax then
		return true
	end
	return false
end

--是否是传送石
function ItemData.GetIsTransferStone(item_id)
	if item_id == 454 or item_id == 455 then
		return true
	end
	return false
end

--是否是药品
function ItemData.GetIsStuff(item_type)
	if item_type == ItemData.ItemType.itFunctionItem then
		return true
	end
	return false
end

--是否是药品
function ItemData.GetIsDrug(item_type)
	if item_type == ItemData.ItemType.itFastMedicaments then
		return true
	end
	return false
end

--是否是符文
function ItemData.GetIsFuwen(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type == ItemData.ItemType.itRune then
		return true
	end
	return false
end

--是否是时装
function ItemData.GetIsFashion(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type == ItemData.ItemType.itFashion then
		return true
	end
	return false
end

--是否是幻武
function ItemData.GetIsHuanWu(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type == ItemData.ItemType.itWuHuan then
		return true
	end
	return false
end

--是否是真气
function ItemData.GetIsZhenqi(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type == ItemData.ItemType.itGenuineQi then
		return true
	end
	return false
end

--是否是生肖
function ItemData.GetIsShengXiao(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type == ItemData.ItemType.itShengXiao then
		return true
	end
	return false
end

--是否是装备
function ItemData.GetIsEquip(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type < ItemData.ItemType.itEquipMax then
		return true
	end
	return false
end

--是否是基础装备
function ItemData.GetIsBasisEquip(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type < ItemData.ItemType.itBaseEquipment then
		return true
	end
	return false
end

--是否是星魂装备
function ItemData.GetIsConstellation(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type == ItemData.ItemType.itConstellationItem then
		return true
	end
	return false
end

--是否是影翼装备
function ItemData.GetIsWingEquip(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type == ItemData.ItemType.itWingEquip then
		return true
	end
	return false
end

--是否是特戒
function ItemData.IsSpecialRing(item_type)
	return item_type == ItemData.ItemType.itSpecialRing
end

--是否是守护神装
function ItemData.IsGuardEquip(item_type)
	return item_type == ItemData.ItemType.itGuardEquip
end

--是否是灭霸手套
function ItemData.GetIHandEquip(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type == ItemData.ItemType.itGlove then
		return true
	end
	return false
end

--是否战神装备
function ItemData.IsZhanShenEquip(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type >= ItemData.ItemType.itGodWarHelmet and item_cfg.type <= ItemData.ItemType.itGodWarShoes then
		return true
	end

	return false
end

--是否是杀神装备
function ItemData.IsShaShenEquip(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg.type == ItemData.ItemType.itKillArraySha or
	  item_cfg.type == ItemData.ItemType.itKillArrayMost or 
	  item_cfg.type == ItemData.ItemType.itKillArrayRobbery or 
	  item_cfg.type == ItemData.ItemType.itKillArrayLife then
	  return true
	end 
	return false
end

--是否为热血装备
function ItemData.IsReXueEquip(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type >= ItemData.ItemType.itWarmBloodDivinesword and item_cfg.type <= ItemData.ItemType.itWarmBloodKneecap then
		return true
	end
	return false
end

--是否为翅膀装备
function ItemData.IsWingEquip(item_id)
	local bool = false
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type == ItemData.ItemType.itWingEquip then
		local slot = WingData.Instance:GetWingIndex(item_id)
		bool = slot >= 12 and slot <= 16 -- 12-16
	end

	return bool
end

--是否是预览物品
function ItemData.GetIsPreViewItem(item_id)
	if ItemData.GetIsCard(item_id) then 
		return true
	-- elseif ItemData.GetIsFashion(item_id) then
	-- 	return true
	end
	return false
end

local BASE_EQUIP_TYPE_MAP = {
	[ItemData.ItemType.itWeapon] = 1,				-- 武器
	[ItemData.ItemType.itDress] = 1,				-- 衣服
	[ItemData.ItemType.itHelmet] = 1,				-- 头盔
	[ItemData.ItemType.itNecklace] = 1,				-- 项链
	[ItemData.ItemType.itBracelet]  = 1,			-- 手镯
	[ItemData.ItemType.itRing] = 1,					-- 戒指
	[ItemData.ItemType.itGirdle] = 1,				-- 腰带
	[ItemData.ItemType.itShoes] = 1,				-- 鞋子
	
	[ItemData.ItemType.itSpecialRing] = 1,			-- 特戒

	[ItemData.ItemType.itSubmachineGun] = 1,        --冲锋枪
	[ItemData.ItemType.itOpenCar] = 1,              --敞篷车
	[ItemData.ItemType.itAnCrown] = 1,              --皇冠
	[ItemData.ItemType.itGoldenSkull] = 1,          --金骷髅
	[ItemData.ItemType.itGoldChain] = 1,            -- 金链子
	[ItemData.ItemType.itGoldPipe] = 1,             --金烟斗
	[ItemData.ItemType.itGoldDice] = 1,             --金骰子
	[ItemData.ItemType.itGlobeflower] = 1,          --金莲花
	[ItemData.ItemType.itJazzHat] = 1,              -- 爵士帽
	[ItemData.ItemType.itRolex] = 1,                --劳力士
	[ItemData.ItemType.itDiamondRing] = 1,                --钻戒
	[ItemData.ItemType.itGentlemenBoots] = 1,                --绅士靴


	-- [ItemData.ItemType.itConstellationItem] = 1,                --星魂物品
	-- [ItemData.ItemType.itGuardEquip] = 1,                --守护神装
}

--是否是基础装备类型
function ItemData.IsBaseEquipType(item_type)
	return 1 == BASE_EQUIP_TYPE_MAP[item_type]
end

--是否是传世装备
function ItemData.IsPeerlessEquip(item_type)
	if item_type == ItemData.ItemType.itHandedDownWeapon
		or item_type == ItemData.ItemType.itHandedDownDress
		or item_type == ItemData.ItemType.itHandedDownHelmet
		or item_type == ItemData.ItemType.itHandedDownNecklace
		or item_type == ItemData.ItemType.itHandedDownBracelet
		or item_type == ItemData.ItemType.itHandedDownRing
		or item_type == ItemData.ItemType.itHandedDownGirdle
		or item_type == ItemData.ItemType.itHandedDownShoes
		then
		return true
	end
	return false
end

--是否是图鉴
function ItemData.GetIsCard(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type == ItemData.ItemType.itPokedex then
		return true
	end
	return false
end

--是否是传世装备
function ItemData.GetIsHandedDown(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type >= ItemData.ItemType.itHandedDownDress and item_cfg.type <= ItemData.ItemType.itHandedDownWeapon then
		return true
	end
	return false
end


--是否是装备
function ItemData.GetIsEquipType(item_type)
	if item_type and item_type < ItemData.ItemType.itEquipMax then
		return true
	end
	return false
end

--是否是战纹
function ItemData.GetIsZhanwen(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type ~= 0 and item_cfg.type == ItemData.ItemType.itZhanwen then
		return true
	end
	return false
end

--是否是战纹
function ItemData.GetIsZhanwenType(item_type)
	if item_type == ItemData.ItemType.itZhanwen then
		return true
	end
	return false
end

--是否是英雄装备/战宠装备
function ItemData.GetIsHeroEquip(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type >= ItemData.ItemType.itHeroCuff and item_cfg.type <= ItemData.ItemType.itHeroArmor then
		return true
	end
	return false
end

--是否是神羽
function ItemData.GetIsShenyu(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.type >= ItemData.ItemType.itFeather and item_cfg and item_cfg.type <= ItemData.ItemType.itFeather then
		return true
	end
	return false
end

--是否是新热血装备
function ItemData.IsRexue(item_type)
	return IS_TYPE_REXUE[item_type] == 1
end

-- 同位置星魂是否更好
function ItemData.GetXinghunTip(xh_index, equip_data, xh_type)
	local data = HoroscopeData.Instance:GetConstellationData(xh_index)
	local old_score = ItemData.Instance:GetItemScoreByData(data)
	local new_score = ItemData.Instance:GetItemScoreByData(equip_data)
	local item = EquipData.Instance:GetEquipSlotByType(xh_type, 0)
	if new_score > old_score then
		return true, 0, item
	end
	return false
end

-- 同位置守护神装是否更好
function ItemData.GetGuardEquipTip(sh_index, equip_data, xh_type)
	local data = GuardEquipData.Instance:GetAllGuardEquipInfo()
	local old_score = ItemData.Instance:GetItemScoreByData(data[sh_index])
	local new_score = ItemData.Instance:GetItemScoreByData(equip_data)
	local item = EquipData.Instance:GetEquipSlotByType(xh_type, 0)
	if new_score > old_score then
		return true, 0, item
	end
	return false
end

-- 同位置翅膀装备是否更好
function ItemData.GetWingEquipTip(cb_index, equip_data, cd_type)
	local data = WingData.Instance:GetWingEquipByIndex(cb_index)
	local old_score = ItemData.Instance:GetItemScoreByData(data)
	local new_score = ItemData.Instance:GetItemScoreByData(equip_data)
	if new_score > old_score then
		return true, 0, data
	end
	return false
end

-- 同位置战宠装备是否更好
function ItemData.GetZhanjiangTip(equip_data, zj_type)
	local zhanjiang_data = ZhanjiangCtrl.Instance:GetData(HERO_TYPE.ZC)
	local data = zhanjiang_data:GetZhaongChongDataByType(zj_type)
	local old_score = ItemData.Instance:GetItemScoreByData(data)
	local new_score = ItemData.Instance:GetItemScoreByData(equip_data)
	if new_score > old_score then
		return true, 0, data
	end
	return false
end

--物品类型名字
function ItemData.GetConsignmentTypeName(item_type)
	if item_type >= 100 then
		return Language.Common.Stuff
	end
	for k, v in pairs(ConsignmentType.typeList) do
		for k1, v1 in pairs(v.types) do
			if v1 == item_type then
				return v.name
			end
		end
	end
	return ""
end

--物品类型名字
function ItemData.GetItemTypeName(item_type)
	for k, v in pairs(Language.EquipTypeName) do
		if k == item_type then
			return v
		end
	end
	if item_type >= 100 then
		return Language.Common.Stuff
	end
	return ""
end

function ItemData.CanUseItemType(item_type)
	if item_type == ItemData.ItemType.itFunctionItem
	or item_type == ItemData.ItemType.itMedicaments
	or item_type == ItemData.ItemType.itFastMedicaments
	or item_type == ItemData.ItemType.itItemSkillMiji
	or item_type == ItemData.ItemType.itHpPot
	or item_type == ItemData.ItemType.itSelectItem
	or item_type == ItemData.ItemType.itItemBox then
		return true
	end
	return false
end


function ItemData.IsJinYanZhuUseItemType(item_type)
	if item_type == ItemData.ItemType.itHpPot then
		return true
	end
	return false
end

function ItemData.GetViewNameByFlyType(fly_type)
	if fly_type == 1 then			--经验条
		return NodeName.MainuiRoleExp
	elseif fly_type == 2 then		--人物
		return NodeName.MainuiRoleBar
	elseif fly_type == 3 then		--背包
		return "Bag"
	elseif fly_type == 4 then		--神炉
		return "GodFurnace"
	elseif fly_type == 5 then		--成就
		return ""
	elseif fly_type == 6 then		--战将
		return ""
	elseif fly_type == 7 then		--挑战BOSS
		return "Boss"
	elseif fly_type == 8 then		--翅膀
		return "Wing"
	end
end

-- 物品数据格式转换 sex性别 job职业 传入true时不跳过
function ItemData.InitItemDataByCfg(cfg, num, sex ,job)
	if type(cfg) ~= "table" then return end
	local job = job or math.max(RoleData.Instance:GetRoleBaseProf(), GameEnum.ROLE_PROF_1) -- 获取角色基础职业,默认是战士
	local sex = sex or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) -- 性别
	local num = num or cfg.count or 0

	local item
	if sex == true or cfg.sex == nil or cfg.sex == sex then
		if job == true or cfg.job == nil or cfg.job == job or cfg.job == 0 then
			if cfg.type == tagAwardType.qatEquipment then
				item = {["item_id"] = cfg.id, ["num"] = num, ["is_bind"] = cfg.bind or 0, ["job"] = cfg.job, ["sex"] = cfg.sex, ["effectId"] = cfg.effectId}
			else
				local virtual_item_id = ItemData.GetVirtualItemId(cfg.type)
				if virtual_item_id then
					item = {["item_id"] = virtual_item_id, ["num"] = num, ["is_bind"] = cfg.bind or 0, ["job"] = cfg.job, ["sex"] = cfg.sex, ["effectId"] = cfg.effectId}
				end
			end
		end
	end

	return item
end

function ItemData.FormatItemData(data)
	local item_data = nil
	if data.type ~= tagAwardType.qatEquipment then
		local virtual_item_id = ItemData.GetVirtualItemId(data.type)
		if virtual_item_id then
			return {["item_id"] = virtual_item_id, ["num"] = data.count, ["is_bind"] = 0}
		end
	end
	return {["item_id"] = data.id, ["num"] = data.count, ["is_bind"] = data.bind or 0, effectId = data.effectId}
end

-- 是否可以自动回收
function ItemData:CanCleanUpAutoUse(data)
	local item_cfg = self:GetItemConfig(data.item_id)
	if nil ~= item_cfg and ItemData.BatchStatus.OpenView == item_cfg.batchStatus or ItemData.BatchStatus.OpenViewAndBatchUse == item_cfg.batchStatus then
		return true
	end
	return false
end

function ItemData:GetExpBallIsFull(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil ~= item_cfg then
		return tonumber(data.durability) >= tonumber(item_cfg.dura)
	else
		return false
	end
end


-- 是否可回收
function ItemData.GetIsCanRecycle(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then
		return false
	end
	
	if item_cfg.type == ItemData.ItemType.itRune then
		return true
	end
	
	if item_cfg.type < ItemData.ItemType.itEquipMax then
		if item_cfg.flags and item_cfg.flags.denyReclaim == true then
			return false
		end
		return true
	end
	
	return false
end

-- 获取物品等级
local level_cache = {}	-- 做个缓存，寻宝需要高效接口
function ItemData.GetItemLevel(item_id)
	if nil ~= level_cache[item_id] then
		return level_cache[item_id].limit_level, level_cache[item_id].zhuan
	end
	
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local limit_level = 0
	local zhuan = 0
	if item_cfg then
		for k, v in pairs(item_cfg.conds) do
			if v.cond == ItemData.UseCondition.ucLevel then
				limit_level = v.value
			end
			if v.cond == ItemData.UseCondition.ucMinCircle then
				zhuan = v.value
			end
		end
		level_cache[item_id] = {limit_level = limit_level, zhuan = zhuan}
	end
	return limit_level, zhuan
end

-- 获取物品等级
local fuwen_cache = {}
function ItemData.GetItemFuwenIndex(item_id)
	if nil ~= fuwen_cache[item_id] then
		return fuwen_cache[item_id].boss_index, fuwen_cache[item_id].index
	end
	
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local boss_index = 0
	local index = 0
	if item_cfg then
		for k, v in pairs(item_cfg.conds) do
			if v.cond == ItemData.UseCondition.ucRuneSuitID then
				boss_index = v.value
			end
			if v.cond == ItemData.UseCondition.ucRuneTakeOnPos then
				index = v.value
			end
		end
		fuwen_cache[item_id] = {boss_index = boss_index, index = index}
	end
	
	return boss_index, index
end


-- 通过类型获取虚拟物品id
function ItemData.GetVirtualItemId(type)
	return tagAwardItemIdDef[type]
end

-- 通过类型获取虚拟物品角色对应数据枚举
function ItemData.GetRoleAttrEnumByType(tag_type)
	if tag_type == tagAwardType.qatRingCrystal then
		return OBJ_ATTR.ACTOR_RING_CRYSTAL
	end
end

function ItemData:CheckItemIsOverdue(data)
	--展示物品无绑定时间，不提示时间
	local time = data.use_time
	if ItemData.IsShowTimeItem[data.item_id] and time then
		return TimeCtrl.Instance:GetServerTime() > time
	else
		return false
	end
end

-- 是否是红装
function ItemData:IsGodEquip(item_id)
	local item_cfg = self:GetItemConfig(item_id)
	if item_cfg.showQuality == 5 then
		return true
	end
end

-- 获取物品的条件限制
function ItemData:GetItemLimit(item_id, cond)
	local item_cfg = self:GetItemConfig(item_id)
	for k, v in pairs(item_cfg.conds or {}) do
		if v.cond == cond then
			return v.value
		end
	end
	return nil
end

-------------------------------------------------------------------------------------------------------
-- 以下可能废弃
-------------------------------------------------------------------------------------------------------
----------------物品使用次数限制------------
function ItemData:SetItemUseLimit(id,time)
	self.item_use_limit_t[id] = time
end

function ItemData:ClearItemUseLimit()
	self.item_use_limit_t = {}
end

function ItemData:GetItemUseLimit(id)
	if self.item_use_limit_t[id] then
		return self.item_use_limit_t[id] <= 0
	else
		return false
	end
end

-------------------------------------------
--boss召唤令
--当物品使用时间剩余半小时在主面板提醒
-------------------------------------------
-- 更新具有时间限制物品列表
function ItemData:UpdateTimeItemList(vo)
	table.insert(self.time_list, vo)
	self:GetTimeItemList()
	self:CreateCallBossSpareTimer()
end

function ItemData:CheckBossItemIsHave(series)
	for k, v in pairs(self.time_list) do
		if series == v.series then
			return true
		end
	end
	return false
end

function ItemData:DestoryBossItemBySeries(series)
	for k, v in pairs(self.time_list) do
		if series == v.series then
			table.remove(self.time_list, k)
			break
		end
	end
end

function ItemData:GetTimeItemList()
	table.sort(self.time_list, function(a, b)
		if a and b then
			return a.use_time < b.use_time
		end
	end)
end

function ItemData:CreateCallBossSpareTimer()
	if self.item_spare_timer then
		self:DeleteSpareTimer()
	end
	self.item_spare_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)
end

function ItemData:UpdateSpareTime()
	for k, v in pairs(self.time_list) do	
		local spare_time = v.use_time - TimeCtrl.Instance:GetServerTime()
		if spare_time <= 0 then
			table.remove(self.time_list, k)
		end
	end
	
	if nil == next(self.time_list) and self.item_spare_timer then
		self:DeleteSpareTimer()
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.CALL_BOSS, 0)
		return
	end
	
	local f_time = self.time_list[1].use_time
	local f_now_time = TimeCtrl.Instance:GetServerTime()
	local f_spare_time = f_time - f_now_time
	
	if self.time_list[1] and f_spare_time <= 1800 and f_spare_time > 0 then
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.CALL_BOSS, #self.time_list, function()
			ViewManager.Instance:Open(ViewName.CallBoss)
			ViewManager.Instance:FlushView(ViewName.CallBoss, 0, "flush_data", {series = self.time_list[1].series})
		end)
	end
end

function ItemData:DeleteSpareTimer()
	if self.item_spare_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.item_spare_timer)
		self.item_spare_timer = nil
	end
end 

function ItemData:CheckItemIsLimitUseByIdAndPlayTip(id)
	local cfg = self:GetItemConfig(id)
	for k,v in pairs(cfg.conds) do
		if v.cond == ItemData.UseCondition.ucLevel then
			if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < v.value then
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.LimitTip.Tip1, v.value))
				return true
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) < v.value then
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.LimitTip.Tip2, v.value))
				return true
			end
		end
	end
	return false
end 


-------------------------------------------------------------------------------------------------------
-- 以下废弃
-------------------------------------------------------------------------------------------------------
function ItemData:SortBagList()
end

function ItemData:SetDaley(value)
	BagData.Instance:SetDaley(value)
	-- print("----------------------ItemData.Instance:SetDaley(value) is not use; please use BagData.Instance:SetDaley(value)---------------------") 
end

function ItemData:SetDataList(datalist)
end

function ItemData:DeleteOneItem(series)
end

function ItemData:AddOneItem(item, reason)
end

function ItemData:BagItemNumChange(series, num)
end

function ItemData:BagItemInfoChange(equip)
end

--获得背包里的所有物品，一般只在初始化显示时来取
function ItemData:GetBagItemDataList()
	return {}
end

function ItemData:GetBagItemDataListByType(item_type)
	local list = {}
	return list
end

function ItemData:GetEmptyNum()
	return 0
end

function ItemData:UpdateBagItemCount()
end

--获得背包里的物品数量 
-- @item_id:物品id @bind_type: nil 不区分 0非绑 1绑
function ItemData:GetItemNumInBagById(item_id, bind_type)
	return 0
end

--获得背包里的物品数量 
-- @item_id:物品id @bind_type: nil 不区分 0非绑 1绑
function ItemData:GetItemDurabilityInBagById(item_id, bind_type)
	return 0
end

--获得背包里的物品数量
function ItemData:GetItemNumInBagByIndex(index, item_id)
	return 0
end

--获得背包里的物品数量
function ItemData:GetItemNumInBagBySeries(series)
	return 0
end

--获得背包里的物品
function ItemData:GetItemInBagBySeries(series)
	return nil
end

--获得背包里的序列号
function ItemData:GetItemSeriesInBagById(id)
	return nil
end

--获得背包里时装卡列表
function ItemData:GetFashionListInBag()
	local fashion_card_list = {}
	return fashion_card_list
end

--获得背包里幻武卡列表
function ItemData:GetHuanWuListInBag()
	local huanwu_card_list = {}
	return huanwu_card_list
end

function ItemData:NoticeItemChange(change_type, change_item_id, change_item_index, series, reason, old_num, new_num)
end

function ItemData:Update(now_time, elapse_time)
	
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function ItemData:NotifyDataChangeCallBack(callback)
end

--移除绑定回调
function ItemData:UnNotifyDataChangeCallBack(callback)
end


--绑定数据改变时的回调方法.用于获取物品配置回调
function ItemData:NotifyItemConfigCallBack(callback)
end

--移除绑定回调
function ItemData:UnNotifyItemConfigCallBack(callback)
end

function ItemData:GetCanEquipRemind()
	local remind_m = RemindManager.Instance
	return 0
end

function ItemData:GetEquipNormal()
	local num = 0

	return num
end

function ItemData:GetCanCrossEquipRemind()
	local num = 0
	return num
end

function ItemData:GetCanPeerEquipRemind()
	local num = 0
	return num
end

function ItemData:GetEquipLunhuiRemind()
	local num = 0
	return num
end
