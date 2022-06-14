
global = {}

global.goldMineInterval = dataConfig.configs.ConfigConfig[0].goldMineInterval or 5 
global.lumberMillInterval = dataConfig.configs.ConfigConfig[0].lumberMillInterval or 5


global.getMaxGoldRatio =  function ()
	local level = dataManager.playerData:getVipLevel()
	return dataConfig.configs.vipConfig[level].maxGoldRatio
end

global.getMaxLumberRatio =  function ()
	local level = dataManager.playerData:getVipLevel()
	return dataConfig.configs.vipConfig[level].maxLumberRatio
end


--- 购买金币次数限制
global.buyGoldTimes =  function ()
	local level = dataManager.playerData:getVipLevel()
	return dataConfig.configs.vipConfig[level].buyGoldTimes
end

global.getSweepScrollID =  function ()
	return  dataConfig.configs.ConfigConfig[0].sweepScrollID
end

global.adventureConfig = dataConfig.configs.ConfigConfig[0].adventure



global.getShopRefreshTime = function ()
	local time  = os.date("!*t", dataManager.getServerTime() - dataManager.timezone * 60 * 60)
			
	local shopFresh = 	dataConfig.configs.ConfigConfig[0].shopRefleshTimes		
	local findIndex = 1
	for k, v in ipairs (shopFresh) do
		local i,j = string.find(v, ":")
		local hour = tonumber( string.sub(v,1,i-1)	)	
		local min = tonumber(string.sub(v,j+1,-1))
		if(time.hour  < hour )then
			 findIndex = k
			 break 
		elseif(time.hour == hour )then
			if(time.min  < min )then
				findIndex = k
			end
		end			
	end
	return shopFresh[findIndex]	
end

global.getShopRefreshCost = function ()
	
	local size = #dataConfig.configs.priceConfig
	local reSetNum = dataManager.shopData:getShopReFreshNum()	
	reSetNum  = math.min(reSetNum + 1,size)
	return dataConfig.configs.priceConfig[reSetNum].resetShop
end



global.tipBagFull = function (tipInfo)
	    tipInfo = tipInfo or "仓库空间不足，无法获得全部物品，请清理仓库后再继续"
		local nums = dataManager.bagData:getVecItemNums(enum.BAG_TYPE.BAG_TYPE_BAG)
		if(  nums >= 200)then
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = tipInfo });
		return 	true	
	end	
	
	return 	false
end	
global.openShop = function (shopType)
	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].shopLevelLimit)then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = dataConfig.configs.ConfigConfig[0].shopLevelLimit.."级开启商店" });
		return 		
	end			
				
	eventManager.dispatchEvent({name = global_event.SHOP_SHOW, shopType = shopType});
	
end

global.gotoPvpOfflineBattle = function ()

		global.changeGameState(function() 
			sceneManager.closeScene();
			eventManager.dispatchEvent( {name   = global_event.PVP_HIDE})
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			local btype =  enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE			
			game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = btype, planType = enum.PLAN_TYPE.PLAN_TYPE_PVE });	
		end);
			
end	

global.CleanPvpCdOffline = function ()
	sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_PVP_OFFLINE_CD, -1);
end

global.ResetOfflineBattleNum = function ()
	sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_PVP_OFFLINE_TIMES, -1);
end

global.getHeadIcon = function (id)
	local str = ""
	if(id > UNIT_ICON_SATRT_INDEX)then
		local c = dataConfig.configs.unitConfig[id - UNIT_ICON_SATRT_INDEX]
		if(c)then
			str  = c.icon
		end
	else
	
		local config = 	dataConfig.configs.iconConfig[id]
		if(config == nil)then
			config = 	dataConfig.configs.iconConfig[1]
		end
		if(config)then
			str = config.icon
		end
	end	
	return str
end

global.getMythsIcon = function (level)
	
	level = level or 1;
	
	if level == 0 then
		level = 1;
	end
	
	return dataManager.miracleData:getHeadFrame(level);
	
end




global.getHalfBodyImage = function (id)
	
	local config = dataConfig.configs.iconConfig[id];
	
	dump(config);
	
	if config then
		return config.image;
	else
		return dataConfig.configs.iconConfig[1].image;
	end
end

math.randomseed(dataManager.getServerTime())
global.randomPlayerName = function (args)
	--[[
	local first ={"赵", "钱", "孙", "李", "周", "吴", "郑", "王", "陈", "蒋", "沈", "韩", "杨", "朱", "秦", "尤", "许", "何", "吕", "施", "张", "孔", "曹", "严", "华", "金", "魏", "陶", "姜", "戚", "谢", "邹", "喻", "柏", "水", "窦", "章", "云", "苏", "潘", "葛", "奚", "范", "彭", "郎", "鲁", "韦", "昌", "马", "苗", "凤", "花", "方", "俞", "任", "袁", "柳", "鲍", "史", "唐", "费", "鲍", "史", "唐", "费", "殷", "罗", "毕", "郝", "邬", "安", "常", "乐", "于", "傅", "皮", "齐", "康", "伍", "余", "顾", "孟", "黄", "和", "穆", "萧", "尹", "姚", "邵", "湛", "汪", "祁", "毛", "禹", "狄", "米", "贝", "宋", "庞", "熊", "纪", "舒", "屈", "项", "祝", "董", "梁", "杜", "阮", "蓝", "江", "童", "颜", "郭", "梅", "林", "徐", "邱", "骆", "高", "夏", "蔡", "田", "樊", "胡", "凌", "虞", "霍", "万", "柯", "卢", "莫", "丁", "宣", "洪", "程", "陆", "乌", "刘", "叶", "白", "牛", "庄", "蔡", "甄", "卓", "庾", "欧", "龙", "敖", "万俟", "司马", "上官", "欧阳", "夏侯", "诸葛", "闻人", "东方"};
	local second ={"斌", "林", "志", "庆", "贤", "吉", "兴", "华", "强",
	  "超", "霸", "刀", "平", "建", "炜", "非", "飞", "欣", "阳", "名", "达", "杠", "气", "炼", "狱",
	  "钦", "青", "来", "伟", "达", "炎", "燕", "森", "税", "荤", "靖", "绪", "愈", "硕", "巧", "朋",
	  "羽", "贵", "禾", "保", "苟", "佼", "玄", "乘", "裔", "延", "植", "环", "燃", "叔", "圣", "御",
	  "夫", "仆", "镇", "藩", "寒", "少", "字", "桥", "板", "斐", "独", "千", "势", "嘉", "塔", "锋", 
	  "闪", "始", "星", "南", "天", "接", "暴", "地", "速", "禚", "腾", "潮", "镜", "似", "澄", "潭", 
	  "謇", "纵", "渠", "奈", "风", "春", "濯", "沐", "茂", "英", "兰", "檀", "藤", "枝", "检", "生",
	  "折", "登", "驹", "骑", "格", "庆", "喜", "及", "普", "建", "营", "巨", "望", "玛", "道", "载", 
	  "声", "漫", "犁", "力", "贸", "勤", "修", "信", "闽", "北", "守", "坚", "勇", "汉", "五", "令", 
	  "将", "旗", "军", "行", "奉", "敬", "恭", "仪", "特", "堂", "丘", "义", "礼", "瑞", "孝", "理", 
	  "伦", "卿", "问", "永", "辉", "位", "让", "神", "雉", "犹", "介", "承", "市", "所", "苑", "杞",
	  "剧", "第", "谌", "忻", "迟", "鄞", "战", "候", "丸", "励", "萨", "邝", "覃", "初", "楼", "城", 
	  "区", "泉", "麦", "健", "枫", "迪", "燎", "悟", "瑟", "仙", "海", "杰", "俊", "龙", "怨", "元", 
	  "心", "乾", "坤","玲", "雪", "婉", "凤", "淑", "惠", "矫", "诗", "琦", "波", "碧", "盈", "希", 
	  "母", "慈", "尧", "依", "宛", "娟", "霜", "莉", "丽", "媛", "静", "玉", "佳", "儿", "萦", "美", 
	  "妖", "芸", "茹", "娇", "乔", "姫", "英", "蝉", "香", "尚", "倩", "茜", "卉", "紫", "秋", "苗", 
	  "柔", "善", "纯", "衣", "蝶", "施", "珍", "妹", "真", "寒", "偲", "双", "琴", "瑶", "春", "兰", 
	  "岚", "芷", "若", "彤", "娜", "馨", "蕾", "姗", "丝", "雅", "梦", "悠", "薇", "萱", "桃", "青", 
	  "嫚", "念", "音", "涵", "柏", "虹", "云", "晨", "慧", "含", "雨", "晴", "烟", "芯", "婷", "艳",
	  "妮", "徽", "妱", "忆", "夏", "惜", "语", "蓉", "蕊", "映", "晓", "媚", "娆", "佟", "荷", "菊",
	  "初", "恋", "听", "芹", "书", "怜", "璇", "凝", "花", "萍", "莲", "夜", "乐", "雁", "丹", "妙",
	  "笑", "枫", "妍", "筱", "曦", "夕", "羽", "月", "浅", "沫", "柳", "玫", "妃", "姬", "星", "霓",
	  "舞", "琳", "裳", "茵", "芝", "琪", "菲", "芳", "颖", "嫣", "薰", "姿", "洁", "嫦", "怡", "雯"};
		return   first[math.random(1,#first)]..second[math.random(1,#second)]  
		--]]

		if(not g_nameConfig1)then
			g_nameConfig1 = {}
			g_nameConfig2 = {}
			g_nameConfig3 = {}
			local size = #dataConfig.configs.nameConfig
			for i,v in pairs(dataConfig.configs.nameConfig) do
				if(v.name1)then
					table.insert(g_nameConfig1,v.name1)
				end
				if(v.name2)then
					table.insert(g_nameConfig2,v.name2)
				end
				if(v.name3)then
					table.insert(g_nameConfig3,v.name3)
				end
			end	
		end
		
	function getName()
		local s1 = math.random(1,#g_nameConfig1)
		local s2 = math.random(1,#g_nameConfig2)
		local s3 = math.random(1,#g_nameConfig3)
		s1 = g_nameConfig1[s1]
		s2 = g_nameConfig2[s2]
		s3 = g_nameConfig3[s3]
		local randomName = s1..s2..s3
		return  math.getStrWithByteSize( randomName,PLAYER_NAME_MAX_SIZE)	
	end		

	if(args) then
		return getName()
	end
end

--global.getBattleTypeInfo(battlePrepareScene.getBattleType()).pause 
global.getBattleTypeInfo = function (battleType )
	
	local t = {}
	--无效情况
	t[enum.BATTLE_TYPE.BATTLE_TYPE_INVALID] = { speedUp = true,countdown = false ,pause = true,AutoBattle = true, canSkipAtBegin = false, } 
	-- 推图普通
	t[enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE] = { speedUp = true,countdown = false ,pause = true,AutoBattle = true, canSkipAtBegin = false, } 
	-- 推图精英
	t[enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE] = { speedUp = true,countdown = false ,pause = true,AutoBattle = true, canSkipAtBegin = false,} 
	-- 在线PVP
 	t[enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE] = { speedUp = false,countdown = true ,pause = false,AutoBattle = true, canSkipAtBegin = false,} 
	-- 离线PVP
 	t[enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE] = { speedUp = true,countdown = true ,pause = true,AutoBattle = true, canSkipAtBegin = false,} 
	-- 领地事件
	t[enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT] = { speedUp = true,countdown = false,pause = true,AutoBattle = true, canSkipAtBegin = false,} 
	-- 急速挑战
	t[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED] = { speedUp = true,countdown = false,pause = true,AutoBattle = true, canSkipAtBegin = false,} 
	
	-- 副本挑战
	t[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL] = { speedUp = true,countdown = false ,pause = true,AutoBattle = true, canSkipAtBegin = true,} 
	t[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE] = { speedUp = true,countdown = false ,pause = true,AutoBattle = true, canSkipAtBegin = true,} 
	t[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL] = { speedUp = true,countdown = false ,pause = true,AutoBattle = true, canSkipAtBegin = true,} 

	
	-- 伤害输出挑战 
	t[enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE] = { speedUp = true,countdown = false ,pause = true,AutoBattle = true, canSkipAtBegin = false,} 
 
 	-- 远征
 	t[enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE] = { speedUp = true, countdown = false, pause = true, AutoBattle = true, canSkipAtBegin = false,} 
 	
 	-- 掠夺
 	t[enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER] = { speedUp = true, countdown = false, pause = true, AutoBattle = true, canSkipAtBegin = true,}
 	
 	-- 复仇
 	t[enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE] = { speedUp = true, countdown = false, pause = true, AutoBattle = true, canSkipAtBegin = true,}
	
	-- 切磋
 	t[enum.BATTLE_TYPE.BATTLE_TYPE_FIGHT] = { speedUp = true, countdown = false, pause = true, AutoBattle = true, canSkipAtBegin = true,}
 	
 	-- 公会战
 	t[enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR] = { speedUp = true, countdown = false, pause = true, AutoBattle = true, canSkipAtBegin = false,} 
 	
	if(battleType)then
		return t[battleType]
	end
 
	return t[enum.BATTLE_TYPE.BATTLE_TYPE_INVALID]
end

global.oppsiteForce = function(force)
	if force == enum.FORCE.FORCE_ATTACK then
		return enum.FORCE.FORCE_GUARD;
	else
		return enum.FORCE.FORCE_ATTACK;
	end
end
--- 得到一艘船的的战力
global.getOneShipPower = function(star,quality,soldierNUM,EQUIP_ATTR_ATTACK,EQUIP_ATTR_DEFENCE,EQUIP_ATTR_CRITICAL,EQUIP_ATTR_RESILIENCE )	
		
		if(EQUIP_ATTR_ATTACK == nil or EQUIP_ATTR_ATTACK < 0)then
			EQUIP_ATTR_ATTACK = 0
		end	
		if(EQUIP_ATTR_DEFENCE == nil or EQUIP_ATTR_DEFENCE < 0)then
			EQUIP_ATTR_DEFENCE = 0
		end	
			
		if(EQUIP_ATTR_CRITICAL == nil or EQUIP_ATTR_CRITICAL < 0)then
			EQUIP_ATTR_CRITICAL = 0
		end	
			
		if(EQUIP_ATTR_RESILIENCE == nil or EQUIP_ATTR_RESILIENCE < 0)then
			EQUIP_ATTR_RESILIENCE = 0
		end	
			
			
		
		local A = dataConfig.configs.ConfigConfig[0].fightingCapacityRatioA
		local B = dataConfig.configs.ConfigConfig[0].fightingCapacityRatioB
		
		local startLevelRatio = dataConfig.configs.ConfigConfig[0].startLevelRatio
		local classLevelRatio = dataConfig.configs.ConfigConfig[0].classLevelRatio	
		
		function _getShipPower( star,quality,soldierNUM,EQUIP_ATTR_ATTACK,EQUIP_ATTR_DEFENCE,EQUIP_ATTR_CRITICAL,EQUIP_ATTR_RESILIENCE )	
			local starR =  startLevelRatio[star] or 1
			local qualityR =  classLevelRatio[quality] or 1
			 
			local powerA = soldierNUM * A * starR * qualityR
			
			--local attAll = math.sqrt( EQUIP_ATTR_ATTACK +  EQUIP_ATTR_DEFENCE + EQUIP_ATTR_CRITICAL + EQUIP_ATTR_RESILIENCE)
			local attAll = EQUIP_ATTR_ATTACK +  EQUIP_ATTR_DEFENCE + EQUIP_ATTR_CRITICAL + EQUIP_ATTR_RESILIENCE
			local powerB = attAll * B
			return  math.ceil(powerA + powerB)
		end	
	return _getShipPower( star,quality,soldierNUM,EQUIP_ATTR_ATTACK,EQUIP_ATTR_DEFENCE,EQUIP_ATTR_CRITICAL,EQUIP_ATTR_RESILIENCE )	
	
end	
--- 得到所有魔法的战力
global.getAllMagicPower = function(magicsStar,KingIntelligence)	
		local C = dataConfig.configs.ConfigConfig[0].fightingCapacityRatioC
		local magicLevelRatio = dataConfig.configs.ConfigConfig[0].magicLevelRatio	
		_getMagicPower = function(star)	
			local magicRatio =  magicLevelRatio[star] or 1
			return KingIntelligence*magicRatio*C/7
		end
		local magicPower = 0
		for i,v in ipairs (magicsStar)do
			magicPower = magicPower + _getMagicPower(v)
		end
	return magicPower
end



global.getSelfOneShipPower = function (_planType,shipIndex)	
			local oneShipPower = 0
			local shipList = 	shipData.shiplist		
	
			local cardType =  PLAN_CONFIG.getShipCardType(shipIndex, _planType)	
			local cardInstance = cardData.getCardInstance(cardType)
			if(cardInstance == nil)then
				return 0
			end	
			
			local star = cardInstance:getStar()
			local quality = cardInstance:getConfig().quality  
			
			local v = shipList[shipIndex]
			
			if(v)then
				local soldierNUM = v:getSoldier(); 
			
				oneShipPower =  global.getOneShipPower(star,quality,soldierNUM,
				v:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK),
				v:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE),
				v:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL),
				v:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE))
			
			end
		return    oneShipPower
end	



--自己的战力
global.battlePower = function(_planType)
		local shipList = 	shipData.shiplist		
		local  powerShipAll = 0
		for i,v in ipairs(shipList) do
			powerShipAll = powerShipAll +  global.getSelfOneShipPower(_planType,i)
		end
		--- 总战斗力=∑_船1^船6?船战斗力  +国王智力*∑_魔法1^魔法7?魔法星级系数*战斗力系数C/7
		
		local cardType =  PLAN_CONFIG.getShipCardType(shipIndex, _planType)	
		
		
		local plan =  PLAN_CONFIG.getPlan(_planType)
		local magicStars = {}
		if(plan)then
			for i,v in pairs (plan.magic) do
				if(v.id > 0)then
					local magicInstance = dataManager.kingMagic:getMagic(v.id);
					if(magicInstance )then
						table.insert(magicStars,magicInstance:getStar())
					end
				end
			end			
		end
		powerShipAll = powerShipAll + global.getAllMagicPower(magicStars,dataManager.playerData:getIntelligence())
	return math.ceil(powerShipAll)
end


-- tips 响应
-- window 是注册事件的window， 
-- tipsType表示类型 buff, skill, magic
-- aligned 表示对齐方式
-- 


function _onSkillTipsShowEvent(args)
	local clickImage = LORD.toWindowEventArgs(args).window;
	local userdata = clickImage:GetUserData();
	local userdata2 = clickImage:GetUserData2();
		
	local rect = clickImage:GetUnclippedOuterRect();
	if g_aligned[clickImage] == "left" then
		offsetX = -5;
	elseif g_aligned[clickImage]  == "right" then
		offsetX = 5;
	elseif g_aligned[clickImage]  == "top" then
		offsetY = -5;
	elseif g_aligned[clickImage]  == "bottom" then
		offsetY = 5;
	end

		if userdata > 0 or g_tipsType[clickImage]  == "time" then
			local magicLevel = nil;
			local intelligence = nil;
			if g_tipsType[clickImage]  == "magic" then
				magicLevel, intelligence = dataManager.kingMagic:parseLevelIntelligence(userdata2);
			end
			eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = g_tipsType[clickImage] , id = userdata, 
					windowRect = rect, dir = g_aligned[clickImage] , offsetX = offsetX, offsetY = offsetY, magicLevel = magicLevel, intelligence = intelligence });
		end
end
	
	
g_tipsType= {} 	g_aligned= {}
global.onSkillTipsShow = function(window, tipsType, aligned)
	
	local offsetX = 0;
	local offsetY = 0;
	g_tipsType[window] = tipsType
	g_aligned[window] = aligned

	if window then
		window:removeEvent("WindowTouchDown");
		window:subscribeEvent("WindowTouchDown", "_onSkillTipsShowEvent");
	end
end

-- 物品tips处理
-- itemType 的类型有item， magicexp， cardexp
global.onItemTipsShow = function(window, itemType, aligned)
	
	if window == nil then
		return;
	end
	
	window:SetUserData2(itemType);
	
	local offsetX = 0;
	local offsetY = 0;
	
	if aligned == "left" then
		offsetX = -5;
	elseif aligned == "right" then
		offsetX = 5;
	elseif aligned == "top" then
		offsetY = -5;
	elseif aligned == "bottom" then
		offsetY = 5;
	end
	
	function _onItemTipsShowEvent(args)

	  local clickImage = LORD.toWindowEventArgs(args).window;
		local userdata = clickImage:GetUserData();
		local userdata2 = clickImage:GetUserData2();
		
		local rect = clickImage:GetUnclippedOuterRect();
		
		local id = userdata;
		local level = nil;
		
		if userdata2 == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
			id, level = dataManager.kingMagic:parseIDLevel(userdata);
		end

		eventManager.dispatchEvent({name = global_event.ITEMTIPS_SHOW, tipsType = userdata2, id = id, 
				windowRect = rect, level = level, dir = aligned, offsetX = offsetX, offsetY = offsetY });

	end
	
	if window then
		window:removeEvent("WindowTouchDown");
		window:subscribeEvent("WindowTouchDown", "_onItemTipsShowEvent");
	end
end

-- 注册tips关闭事件
global.onTipsHide = function(window)
	function _onTipsHideEvent(args)
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	
	window:removeEvent("WindowTouchUp");
	window:removeEvent("MotionRelease");
	window:subscribeEvent("WindowTouchUp", "_onTipsHideEvent");
	window:subscribeEvent("MotionRelease", "_onTipsHideEvent");
end

global.onItemTipsHide = function(window)
	function _onItemTipsHideEvent(args)
		eventManager.dispatchEvent({name = global_event.ITEMTIPS_HIDE});
	end
	
	window:subscribeEvent("WindowTouchUp", "_onItemTipsHideEvent");
	window:subscribeEvent("MotionRelease", "_onItemTipsHideEvent");
	window:subscribeEvent("WindowLongTouchCancel", "_onItemTipsHideEvent");
end
 
global.mergeReward = function(resultList, rewardType, rewardID, rewardCount)
		
		-- 遍历之前所有merged的奖励，找到类型，id一样的合并起来
		local merged = false;
		for rewardKey, rewardData in ipairs(resultList) do
			if rewardData.type == rewardType and rewardData.id == rewardID then
				rewardData.count = rewardData.count + rewardCount;
				merged = true;
				break;
			end
		end
		
		-- 没找到新加入一个
		if merged == false then
			local reward = {};
			reward.type = rewardType;
			reward.id = rewardID;
			reward.count = rewardCount;
			table.insert(resultList, reward);
		end
		
end

global.setMaskIcon = function(staticImage, maskIcon)
	-- 碎片的处理
	if maskIcon and maskIcon ~= "" then
		staticImage:setMaterial(LORD.GUIMaterialType_MASK);
		staticImage:setMaskTextureName(maskIcon);
	else
		staticImage:setMaterial(LORD.GUIMaterialType_CULL_BACK);
		staticImage:setMaskTextureName("");
	end
end

function global.parseTextFloatArray(magicID)
	
	local SET_FUNC_NAME_PRE = "$$设置浮点数组%("
	local SET_FUNC_NAME_ = "%)";
	local text = dataConfig.configs.magicConfig[magicID].text
	
	local i,j = string.find(text, SET_FUNC_NAME_PRE)
	
	local _i,_j = string.find(text, SET_FUNC_NAME_)
	local subStr = string.sub(text,j+1 ,_i- 1)
	return  string.split(subStr,",")	
 
end	

 

function global.parseHurtLimitFormText(magicID,intelligence,level)
	
	local skillFloatArray  = 	global.parseTextFloatArray(magicID)
	
	local HURT_LIMIT_NAME_PRE = "伤害的上限为%$%$"
	local HURT_LIMIT_NAME_END = "%$%$"
	
	local text = dataConfig.configs.magicConfig[magicID].text
	local i,j = string.find(text, HURT_LIMIT_NAME_PRE)
	local _i,_j = string.find(text, HURT_LIMIT_NAME_END,j)
	
	local subStr = string.sub(text,j+1 ,_i- 1)
	
	local temp = skillFloatArray[level]  or 1
  
	local MAGIC_LEVEL = "获取浮点元素%(魔法等级%)"
	local KING_INTELLIGENCE = "国王智力";
	local convert = string.gsub(subStr, MAGIC_LEVEL, "tempRation");
	convert = string.gsub(convert, KING_INTELLIGENCE, "tempintelligence");
 


	
	dataManager.kingMagic:setTipsMagicID(magicID);
	dataManager.kingMagic:setTipsMagicLevel(temp);
	dataManager.kingMagic:setTipsMagicIntelligence(intelligence);
	
 	convert = 
			"local tempRation = dataManager.kingMagic:getTipsMagicLevel();\
			 local tempintelligence = dataManager.kingMagic:getTipsMagicIntelligence();\
				return "..convert;
		
	local value = loadstring(convert);
	local ret = value();
 
	 
	return ret
end	



global.sendPacket_id = nil


function global.WAIT()
		if(global.sendPacket_id)then
			eventManager.dispatchEvent({name = global_event.LOADING_SHOW})		
		end
end	

function global.OnpacketHandler(packetID)
	
	if(global.sendPacket_id)then
		local pm = packetMap[global.sendPacket_id] 
		if( pm and pm.response == true and  table.find( pm.packet,packetID) )then
			eventManager.dispatchEvent({name = global_event.LOADING_HIDE})	
			global.sendPacket_id = nil
		end
	end
end

function global.OnPacketSend(packetID)
	
	local pm = packetMap[packetID] 
	if( pm and pm.response == true )then
		global.sendPacket_id = packetID	
		scheduler.performWithDelayGlobal(global.WAIT, PACKET_TIP_WAIT_TIMR)
	end
end

function global.getBattleMagicLevel(force, id)
	if battlePlayer.attackMagics and force == enum.FORCE.FORCE_ATTACK then

		for k,v in pairs(battlePlayer.attackMagics) do
			if v.id == id then
				return v.level;
			end
		end
		
	elseif battlePlayer.guardMagics then

		for k,v in pairs(battlePlayer.guardMagics) do
			if v.id == id then
				return v.level;
			end
		end
			
	end
	
	return 0;
	
end

function global.changeGameState(func, delay)

	delay = delay or 0.5;
	
	eventManager.dispatchEvent({name = global_event.CHANGESCENE_SHOW, func = func, params = params, delay = delay });
--[[
	function delayHideChangeSceneUI()
		eventManager.dispatchEvent({name = global_event.CHANGESCENE_HIDE});
	end
		
	scheduler.performWithDelayGlobal(delayHideChangeSceneUI, delay);
	--]]	
	--func(params);
end
function pack_sort_item(a,b)
		if( a:getType() ~= b:getType() )then
			if(a:isUsedItem()) then
				return true
			end
			if(b:isUsedItem()) then
				return false
			end	
			if(a:isMatrial()) then
				return true
			end
			if(b:isMatrial()) then
				return false
			end	
			if(a:isEquip()) then
				return true
			end
			if(b:isEquip()) then
				return false
			end
			if(a:isDebris()) then
				return true
			end
			if(b:isDebris()) then
				return false
			end

			return false
		else
			if(a:isEquip()) then
				 if( a:getStar() == b:getStar() )then
					if(a:getUseLevel() == b:getUseLevel())then
					
						if(a:getSubId() == b:getSubId())then
							return a:getEnhanceLevel() > b:getEnhanceLevel() 
						else
							return a:getSubId() < b:getSubId() 
						end	
					else
						return a:getUseLevel() > b:getUseLevel()
					end
			
				end
			end
			if(a:isDebris()) then
				 if( a:getStar() == b:getStar() )then
					return a:getProductUseLevel() > b:getProductUseLevel()
				end
			end

			if( a:getStar() ~= b:getStar() )then
				return a:getStar() >  b:getStar()
			else
				local c1,g1 = a:canScale() 
				local c2,g2 = b:canScale() 
				
				return  g1 >  g2
			end
		end	
	end

global.newCardMagicList = {};

function global.triggerNewCardAndMagic()
	
	print("triggerNewCardAndMagic");	
	if #global.newCardMagicList > 0 then
	
		local data = global.newCardMagicList[1];
		
		if data.promptType == "newcard" then
			eventManager.dispatchEvent({name = global_event.GETANEWCARD_SHOW, data = data });
		elseif data.promptType == "magiclevelup" then
			eventManager.dispatchEvent({name = global_event.MAGICLEVELUP_SHOW, data = data });
		elseif data.promptType == "cardlevelup" then
			eventManager.dispatchEvent({name = global_event.CARDLEVELUP_SHOW, data = data });
		end
	
	end
	
end

function global.gotoarena_pvpOnline()
		
		local day = dataManager.getServerOpenDay()
		if(day < 1)then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "开服第一天不开放同步PVP活动" });
			return
		end
		
		global.changeGameState(function() 
			sceneManager.closeScene();
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			local btype =  enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE --enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE 		
			game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = btype, planType = enum.PLAN_TYPE.PLAN_TYPE_PVE });		
		end);

end


function global.getBuildLevelupTime(homelandType)
	
	if homelandType == enum.HOMELAND_BUILD_TYPE.GOLD then
		return dataManager.goldMineData:getLevelUpRemainTime();
	elseif homelandType == enum.HOMELAND_BUILD_TYPE.WOOD then
		return dataManager.lumberMillData:getLevelUpRemainTime();
	elseif homelandType == enum.HOMELAND_BUILD_TYPE.MAGIC then
		return dataManager.magicTower:getLevelUpRemainTime();
	elseif homelandType == enum.HOMELAND_BUILD_TYPE.BASE then
		return dataManager.mainBase:getLevelUpRemainTime();
	end
	
	return nil;
end

function global.isInTimeLimit(beginTimeString, endTimeString)

	local h, m, s = dataManager.getLocalTime();
	local nowTime = h*3600 + m*60 + s;
	
	local bhour, bminute = stringToTime(beginTimeString);
	local ehour, eminute = stringToTime(endTimeString);
			
	local beginTime = bhour*3600 + bminute*60;
	local endTime = ehour*3600 + eminute*60;
	
	local time24 = 24 * 3600;
	if beginTime < endTime then
		-- 当天
		if nowTime >= beginTime and nowTime < endTime then
			return true;
		else
			return false;
		end
	else
		-- 跨天了
		if (nowTime>= beginTime and nowTime <= time24) or (nowTime>= 0 and nowTime <= endTime) then
			return true
		else
			return false;
		end
	end
end

function global.filterText(text)
	
	local sub = {
		[1] = "*";
		[2] = "**";
		[3] = "***";
		[4] = "****";
		[5] = "*****";
		[6] = "******";
		[7] = "*******";
		[8] = "********";
	};
	
	local result = LORD.GUIString(text);
	for k,v in ipairs(dataConfig.configs.filterConfig) do
		
		local filter = LORD.GUIString(v.filter);
		local len = filter:length();
		local index = result:find(filter);
		
		if index < result:length() then
			local substring = sub[len] or sub[8];
			result = result:replace(index, len, LORD.GUIString(substring));
		end
		
	end
	
	return result;
end

function global.hasfilterText(text)
	 
	
	local result = LORD.GUIString(text);
	for k,v in ipairs(dataConfig.configs.filterConfig) do
		local filter = LORD.GUIString(v.filter);
		local len = filter:length();
		local index = result:find(filter);
		if index >= 0 and index < result:length() then
			 return true
		end
	end
	return false;
end
-- 
global.flags = {};

function global.setFlag(key, value)
	global.flags[key] = value;
end

function global.getFlag(key)
	return global.flags[key];
end

function global.openOfflinePvp( refresh)
		if global.tipBagFull() then
			return;
		end
		eventManager.dispatchEvent({name = global_event.ARENA_HIDE})
		eventManager.dispatchEvent({name = global_event.PVP_SHOW,refresh = refresh});
end

function global.HasNewNoticeWithEquip( )
	for i=1, 6 do
		local shipInstance = shipData.getShipInstance(i);
		if shipInstance and shipInstance:isActive() and shipInstance:hasEquippedStronger() then
			return true
		end
	end
	return false
end	
	

function global.getSpeedChallengeRewardList()
	local t ={}
	local index = 0
	for k, reward in ipairs (dataConfig.configs.challengeSpeedConfig )do
		index = index +1
		t[index] = t[index]  or {}
		t[index].rank = reward.rank
		for i,v in ipairs 	(reward.rewardType) do
			table.insert(t[index] ,dataManager.playerData:getRewardInfo(v, reward.rewardID[i], reward.rewardCount[i]))
		end
	end
	return t
end

function global.getPushInfo()
	local pushInfoTable = {};
		
	for k,v in ipairs(dataConfig.configs.pushConfig) do
		local pushData = {};
		
		pushData.id = k;
		pushData.desc = v.text;
		pushData.time = 0;
		
		if v.pushCondition == enum.PUSH_CONDITION.PUSH_CONDITION_TIME then
			-- 固定时间
			pushData.timeType = "fixed";
			pushData.repeatType = "day";
			local hour, minute = stringToTime(v.conditionDate);
			--pushData.time = hour*60*60 + minute*60;
			
			local triggerSecond = hour*enum.SEC_PER_HOUR + minute*enum.SEC_PER_MIN;
			local h, m, s = dataManager.getLocalTime();
			local nowSecond = h*enum.SEC_PER_HOUR + m*enum.SEC_PER_MIN + s;
			
			if nowSecond < triggerSecond then
				
				pushData.time = triggerSecond - nowSecond;
				
			elseif nowSecond > triggerSecond then
			
				pushData.time = enum.SEC_PER_DAY - (nowSecond - triggerSecond);
				
			end
			
		elseif v.pushCondition == enum.PUSH_CONDITION.PUSH_CONDITION_GATHER then
			-- 采集
			pushData.timeType = "alterable";
			pushData.repeatType = "none";		
			
			if v.conditionDate == "金矿" then
				pushData.time = dataManager.goldMineData:gatherFullRemainTime();
			elseif v.conditionDate == "伐木场" then
				pushData.time = dataManager.lumberMillData:gatherFullRemainTime();
			end
			
		elseif v.pushCondition == enum.PUSH_CONDITION.PUSH_CONDITION_DRAWCARD then
			
			-- 免费抽卡
			pushData.timeType = "alterable";
			pushData.repeatType = "none";		
			
			pushData.time = dataManager.playerData:getNextFreeCardRemainTime();
			
		elseif v.pushCondition == enum.PUSH_CONDITION.PUSH_CONDITION_LEVELUP then
			
			-- 建筑升级完成
			pushData.timeType = "alterable";
			pushData.repeatType = "none";

			if v.conditionDate == "金矿" then
				pushData.time = dataManager.goldMineData:getLevelUpRemainTime();
			elseif v.conditionDate == "伐木场" then
				pushData.time = dataManager.lumberMillData:getLevelUpRemainTime();
			elseif v.conditionDate == "主基地" then
				pushData.time = dataManager.mainBase:getLevelUpRemainTime();
			elseif v.conditionDate == "法师塔" then
				pushData.time = dataManager.magicTower:getLevelUpRemainTime();
			end
								
		end
		
		if pushData.time > 0 then
		
			-- 检测是不是在 23：00 到 8：00之间
			-- 这里的time 是剩余时间
			
			local pushAbsoluteTime = dataManager.getServerTime() + pushData.time;
			local timeTable = os.date("!*t", pushAbsoluteTime - dataManager.timezone * 60 * 60);
			local hour = timeTable.hour;
			local minute = timeTable.min;
			local second = timeTable.sec;
				
			
			if not (hour >=8 and hour <= 23) then
				-- 延迟推送
				if hour >= 0 and hour < 8 then
					pushData.time = pushData.time + (8*enum.SEC_PER_HOUR - hour*enum.SEC_PER_HOUR - minute*enum.SEC_PER_MIN - second);
				else
					pushData.time = pushData.time + 8*enum.SEC_PER_HOUR + (24*enum.SEC_PER_HOUR - hour*enum.SEC_PER_HOUR - minute*enum.SEC_PER_MIN - second);
				end
			end
			
			table.insert(pushInfoTable, pushData);
		end
		
	end
	
	return pushInfoTable;
end

function global.dayText(day)
	
	local zeroClock = dataManager.getServerBeginTime();
	local dayTime = zeroClock + (day-1)*enum.SEC_PER_DAY + 1;
	
	dayTime = dayTime - dataManager.timezone * 60 * 60; 	
	local timeTable = os.date("!*t", dayTime);
	
	local text = timeTable.month.."月"..timeTable.day.."日";
	
	return text;
	
end

function global.roleDayText(day)

	local createRoleTime = dataManager.playerData:getCreateRoleTime();
	-- 计算角色创建那天时间的0点时间	
	local zeroClock = 24 * 60 * 60 * math.floor((createRoleTime-dataManager.timezone*3600) / (24 * 60 * 60)) + dataManager.timezone*3600;
		
	local dayTime = zeroClock + (day-1)*enum.SEC_PER_DAY + 1;
	
	dayTime = dayTime - dataManager.timezone * 60 * 60;
	local timeTable = os.date("!*t", dayTime);
	
	local text = timeTable.month.."月"..timeTable.day.."日";
	
	return text;
	
end

function global.parseDayText(text)

	local result = "";
	
	local splitTexts = string.split(text, "$$");
	
	for k,v in ipairs(splitTexts) do
		if string.find(v, "global.") == 1 then
			result = result..loadstring("return "..v)();
		else
			result = result..v;
		end
	end
	
	--print(result);
	
	return result;
end

function global.checkBlockVIP()
	
	if not GLOBAL_CONFIG_BLOCK_VIP then
		return;
	end
	
	for k, v in pairs(dataConfig.configs.blockVIPConfig) do
	
		for uiIndex, uiName in pairs(v.windowName) do
		
			local window = LORD.GUIWindowManager:Instance():GetGUIWindow(uiName);
			if window and window:IsVisible() then
				window:SetVisible(false);
			end
			
		end
	
	end
	
end


 GUIWindowType = {}
 
GUIWindowType.GWT_DEFAULT_WINDOW = 0
GUIWindowType.GWT_STATIC_IMAGE = 1
GUIWindowType.GWT_STATIC_TEXT= 2
GUIWindowType.GWT_BUTTON= 3
GUIWindowType.GWT_EDIT= 4
GUIWindowType.GWT_CHECK= 5
GUIWindowType.GWT_RADIO= 6
GUIWindowType.GWT_PROGRESS= 7
GUIWindowType.GWT_SLIDER= 8
GUIWindowType.GWT_ACTOR= 9
GUIWindowType.GWT_LIST= 10
GUIWindowType.GWT_LAYOUT= 11
GUIWindowType.GWT_MULTILINE_EDIT= 12
GUIWindowType.GWT_BUBBLE_CONTAIN= 13	
GUIWindowType.GWT_BUBBLE_CONTAINEX= 14
GUIWindowType.GWT_INPUT_BOX= 15
GUIWindowType.GWT_SCENE_MAP= 16
GUIWindowType.GWT_TABLE_VIEW= 17
GUIWindowType.GWT_GRID_VIEW= 18
GUIWindowType.GWT_PAGE_VIEW= 19
GUIWindowType.GWT_SCROLLED_CONTAINER= 20
GUIWindowType.GWT_SCROLLABLE_PANE= 21
GUIWindowType.GWT_SCROLL_CARD= 22
GUIWindowType.GWT_ANIMATE= 23
		
 

-- 单位是分
function global.getRmbTextFromPrice(rmb)
	
	local text = string.format("%.0f", rmb / 100);
	
	return text;
end

function global_scalewnd(wnd,scale,textscale)
	scale = scale or 1
	textscale = textscale or scale
	local _scale = LORD.UDim(0, scale)
	
	local w = wnd:GetWidth();
	local h = wnd:GetHeight();
	local pos = wnd:GetPosition();
	if(wnd)then
	
		wnd:SetPosition(LORD.UVector2(pos.x * _scale,pos.y * _scale ));
		wnd:SetWidth(w * _scale)
		wnd:SetHeight(h * _scale)
		local size = wnd:GetChildCount() 
		for i = 0 ,size-1 do
			global_scalewnd(wnd:GetChildByIndex(i),scale,textscale)
		end
		--if(wnd:GetType() == GUIWindowType.GWT_STATIC_TEXT )then
			wnd:SetProperty("TextScale",textscale)
		--end
		
	end
end

-- 
function global.getUserConfigFileName()
	
	return string.format("user%d.cfg", dataManager.playerData:getPlayerId());
	
end

--
function global.battleRecordTimeToDays(time)
	
	local detal = dataManager.getServerTime() - time;
	
	local str = "刚刚"
	if(detal >=  24*60*60)then
		str = "1天以上" 
	elseif(detal >= 60*60)then
		 str = "1小时以上" 
	elseif(detal >= 30*60)then
		  str = "30分钟以上" 
	elseif(detal >= 5*60)then
		   str = "5分钟以上" 
	end
		
	return str
	
end

-- 判断是不是需要调整奖励
function global.needAdjustReward(config, rewardType, rewardID)
	
	return config and 
				(rewardType == enum.REWARD_TYPE.REWARD_TYPE_MONEY) and 
				(rewardID == enum.MONEY_TYPE.MONEY_TYPE_GOLD or rewardID == enum.MONEY_TYPE.MONEY_TYPE_LUMBER)
end


function pack_sort_buddy(a,b)
		 
		local ra = a:getrecvFromFriendFlags()
		local rb = b:getrecvFromFriendFlags()
		
		local __ra = a:isOnline()
		local __rb = b:isOnline()
		
	
		if(ra )then
			if(rb)then
				if(__ra == __rb) then
					return false
				end
				if(__ra)then
					return true
				end
				return false
			end
			return true
		else
			if(rb)then
				return false
			end
			
				if(__ra == __rb) then
					return false
				end
				if(__ra)then
					return true
				end
				return false
		end	 
end
-- 请求攻略录像
function global.askGlobalReplay(battleType, satgeId)
	sendAskGlobalReplay(battleType,satgeId)
end
-- 请求攻略录像最牛B玩家名字
function global.askGlobalReplaySummary (battleType, satgeId)
	global.GlobalReplaySummaryInfo = {}
	sendAskGlobalReplaySummary (battleType,satgeId)
end


function global.isShowBestRepaly (battleType)
	
	if (battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE)then
		 return true
	end
	if (battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL)then
		 return true
	end
	if (battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE )then
		 return true
	end
	if (battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL)then
		 return true
	end
	
	if (battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED)then
		 return true
	end
	if (battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE)then
		 return true
	end
	return false
end
global.GlobalReplaySummaryInfo = {}
global.GlobalReplaySummaryInfo.battleType = nil
global.GlobalReplaySummaryInfo.progressID = nil
global.GlobalReplaySummaryInfo.name = nil
global.GlobalReplaySummaryInfo.icon = nil
global.GlobalReplaySummaryInfo.isPrepareSceneAskBestBattleRecord = nil