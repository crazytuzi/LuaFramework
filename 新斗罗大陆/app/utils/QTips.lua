local QTips = class("QTips")

local QUIDialogUnlockSucceed = import("..ui.dialogs.QUIDialogUnlockSucceed")
local QUIDialogMystoryStoreAppear = import("..ui.dialogs.QUIDialogMystoryStoreAppear")
local QUIWidgetUnlockTutorialHandTouch = import("..ui.widgets.QUIWidgetUnlockTutorialHandTouch")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QTutorialDirector = import("..tutorial.QTutorialDirector")
local QTutorialDefeatedGuide = import("..tutorial.defeated.QTutorialDefeatedGuide")
local QUIWidgetTutorialHandTouch = import("..ui.widgets.QUIWidgetTutorialHandTouch")
local QUIDialogFloatForce = import("..ui.dialogs.QUIDialogFloatForce")

QTips.UNLOCK_TIP_ISTRUE = false --当前是否有解锁提示显示
QTips.SHOW_NEXT_UNLOCKTIP = "SHOW_NEXT_UNLOCKTIP"
QTips.UNLOCK_EVENT = "UNLOCK_EVENT"
QTips.UNLOCK_TUTORIAL_CLOSE = 0
QTips.UNLOCK_TUTORIAL_OPEN = 1
QTips.UNLOCK_TUTORIAL_END = 2
QTips.UNLOCK_TUTORIAL_TIP = 3

QTips.UNLOCK_SHOP_TIPS = "shop"                          -- 商店解锁提示
QTips.SOUL_SHOP_FADE = "soulShopFade"						 -- 魂师商店解锁
QTips.UNLOCK_GOBLINSHOP_TIPS = "goblin"                  -- 地精商店解锁提示
QTips.UNLOCK_BLACKSHOP_TIPS = "black"                    -- 黑市商店解锁提示
QTips.UNLOCK_SPACE_TIPS = "space"                        -- 活动试炼解锁提示
QTips.UNLOCK_ARENA_TIPS = "arena"                        -- 斗魂场解锁提示
QTips.UNLOCK_SUNWELL_TIPS = "sunwell"                    -- 太阳井解锁提示
QTips.UNLOCK_REBIRTH_TIPS = "rebirth"                    -- 重生殿解锁提示
QTips.UNLOCK_SOULSHOP_TIPS = "soul"                      -- 魂师商店解锁提示
QTips.UNLOCK_MATERIALRECYCLE_TIPS = "materialRecycle"    -- 材料回收解锁提示
QTips.UNLOCK_TOWER_OF_GLORY = "tower"                    -- 魂师大赛解锁提示
QTips.UNLOCK_UNION = "union"                             -- 宗门解锁提示
QTips.UNLOCK_THUNDER = "thunder"                         -- 雷电王座解锁提示
QTips.UNLOCK_ELITE = "elites"                         	 -- 精英副本解锁提示
QTips.UNLOCK_WELFARE = "welfare"                         -- 史诗副本解锁提示
QTips.UNLOCK_NIGHTMARE = "night"                         -- 噩梦副本解锁提示
QTips.UNLOCK_FORTRESS = "fortress"                       -- 要塞解锁提示
QTips.UNLOCK_ZHUBAO = "spar"							 -- 外附魂骨解锁提示
QTips.SOUL_TRIAL_UNLOCK = "soulTrial"					 -- 魂力试炼解锁提示
QTips.UNLOCK_SILVERMINE = "silverMine"					 -- 魂兽森林解锁提示
QTips.UNLOCK_MONOPOLY = "monopoly"					 	 -- 大富翁解锁提示
QTips.UNLOCK_SHILIAN_FADE = "shilianfade"				 -- 试炼秘境提示
QTips.UNLOCK_SILVES_ARENA = "silves"				     -- 西尔维斯提示
QTips.UNLOCK_ABYSS = "metalAbyss"				     	 -- 金属深渊提示

UNLOCK_INFO = {
	UNLOCK_ELITE = {tutorialMark = nil, event = QTutorialDefeatedGuide.ELITE, options = {instanceType = nil,showType = "UNLOCK_ELITE",isShowTanNian = true,}},
	SOUL_SHOP_FADE = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE,options = {}},
	UNLOCK_SHILIAN_FADE = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE,options = {}},
	UNLOCK_SHOP_2 = {tutorialMark = "black", event = QTutorialDefeatedGuide.SHOP, options = {className = "QUIDialogArenaStore", shopId = SHOP_ID.blackShop}},
	UNLOCK_BPPTY_BAY = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {initPage = 1}},
	UNLOCK_SHOP = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {className = "QUIDialogArenaStore", shopId = SHOP_ID.generalShop}},
	UNLOCK_SUNWELL = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {}},
	UNLOCK_REBIRTH = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {tab = "material"}},
	UNLOCK_MATERIAL_RECYCLE = {tutorialMark = nil, event = QTutorialDefeatedGuide.REBIRTH, options = {tab = "material"}},
	UNLOCK_TOWER_OF_GLORY = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {}},
	UNLOCK_UNION = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {}},
	UNLOCK_THUNDER = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {}},
	UNLOCK_FULIFUBEN_TRIAL = {tutorialMark = nil, event = QTutorialDefeatedGuide.ELITE, options = {instanceType = nil,showType = "UNLOCK_FULIFUBEN_TRIAL",isShowTanNian = true}},
	UNLOCK_CHAT = {tutorialMark = nil, event = nil},
	UNLOCK_DWARF_CELLAR = {tutorialMark = nil, event = QTutorialDefeatedGuide.TIMEMACHINE, options = {initPage = 2,isShowTanNian = true}},
	UNLOCK_STRENGTH_TRIAL = {tutorialMark = "activity", event = QTutorialDefeatedGuide.TIMEMACHINE, options = {initPage = 3}},
	UNLOCK_SAPIENTIAL_TRIAL = {tutorialMark = nil, event = QTutorialDefeatedGuide.TIMEMACHINE, options = {initPage = 4}},
	UNLOCK_ENHANCE_ADVANCED = {tutorialMark = nil, event = QTutorialDefeatedGuide.GROW},
	UNLOCK_FORTRESS = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {}},
	UNLOCK_FRIEND = {tutorialMark = nil, event = QTutorialDefeatedGuide.FRIEND, options = {}},
	UNLOCK_HAOHUAZHAOHUA = {tutorialMark = nil, event = QTutorialDefeatedGuide.TAVERN, options = {}},
	UNLOCK_HELP_1 = {tutorialMark = nil, event = nil},
	UNLOCK_HELP_2 = {tutorialMark = nil, event = nil},
	UNLOCK_HELP_3 = {tutorialMark = nil, event = nil},
	UNLOCK_HELP_4 = {tutorialMark = nil, event = nil},
	UNLOCK_SOUL_SHOP = {tutorialMark = nil, event = QTutorialDefeatedGuide.SHOP, options = {className = "QUIDialogArenaStore", shopId = SHOP_ID.soulShop}},
	SPACE_TIME_TRANSMITTER = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {initPage = 1}},
	UNLOCK_ARENA = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {}},
	UNLOCK_GOLD = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {}},
	UNLOCK_ARCHAEOLOGY = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {}},
	UNLOCK_TRAIN = {tutorialMark = nil, event = QTutorialDefeatedGuide.TRAIN},
	UNLOCK_GAD = {tutorialMark = nil, event = QTutorialDefeatedGuide.GROW},
	UNLOCK_BADGE = {tutorialMark = nil, event = QTutorialDefeatedGuide.GROW},
	UNLOCK_ENCHANT = {tutorialMark = nil, event = QTutorialDefeatedGuide.GROW,options = {isShowTanNian = true}},
	UNLOCK_TUANDUIBEN = {tutorialMark = nil, event = nil},
	UNLOCK_SHIJIEBOSS = {tutorialMark = nil, event = nil},
	UNLOCK_GONGHUIZHAN = {tutorialMark = nil, event = nil},
	UNLOCK_ACTIVITY_QUICK_FIGHT = {tutorialMark = nil, event = nil},
	UNLOCK_ARENA_QUICK_FIGHT = {tutorialMark = nil, event = nil},
	UNLOCK_THUNDER_QUICK_FIGHT = {tutorialMark = nil, event = nil},
	HUODONGBENXIAO_CD = {tutorialMark = nil, event = nil},
	UNLOCK_GEMSTONE = {tutorialMark = nil, event = QTutorialDefeatedGuide.GEMSTONE},
	GLYPH_SYSTEMS = {tutorialMark = nil, event = QTutorialDefeatedGuide.GROW},
	UNLOCK_STORM_ARENA = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE, options = {}},
	UNLOCK_XILIAN = {tutorialMark = nil, event = QTutorialDefeatedGuide.GROW},
	UNLOCK_ZHUBAO = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_FIGHT_CLUB = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	SOUL_TRIAL_UNLOCK = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SILVERMINE = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SEVEN_ENTRY = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_CARNIVAL = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_METALCITY = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_BINGHUOLIANGYIYAN = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_ARTIFACT = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SANCTRUARY = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SECRETARY = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_MAGIC_HERB = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SOUL_SPIRIT = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SOUL_TECHNOLOGY = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_BLACKROCK = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SOTO_TEAM = {tutorialMark = nil, event = QTutorialDefeatedGuide.BACKMAINPAGE},
	GEMSTONE_EVOLUTION = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_COLLEGE_TRAIN = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_COLLEGE_TRAIN_2 = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_COLLEGE_TRAIN_3 = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_MOCK_BATTLE = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_GOD_ARM = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_MOCK_BATTLE2 = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_WEEKLY_MISSION = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SOUL_TECHNOLOGY = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SOUL_TOWER = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_SILVES_ARENA = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
	UNLOCK_ABYSS = {tutorialMark = nil,event = QTutorialDefeatedGuide.BACKMAINPAGE},
}

UNLOCK_TUTORIAL_TIPS_TYPE = {
	unlockSkill = "UNLOCK_SKILLS",
	unlockArena = "UNLOCK_ARENA",
	unlockEnchant = "UNLOCK_ENCHANT",
	unlockEnhance = "UNLOCK_ENHANCE",
	unlockHeroShop = "UNLOCK_SOUL_SHOP",
	unlockTrain = "UNLOCK_TRAIN",
	unlockArchaeology = "UNLOCK_ARCHAEOLOGY", 
	unlockBadge = "UNLOCK_BADGE", 
	unlockGad = "UNLOCK_GAD", 
	unlockAddmoney = "UNLOCK_GOLD",
	unlockHelper = "UNLOCK_HELP_1",
	unlockHero3 = "UNLOCK_THE_THIRD",
	unlockHero4 = "UNLOCK_THE_FOURTH",
	unlockAutoSkill = "UNLOCK_AUTO_SKILL",
	unlockGemstone = "UNLOCK_GEMSTONE",
	unlockGlyph = "GLYPH_SYSTEMS",
	unlockMount = "UNLOCK_ZUOQI",
	unlockMetalCity = "UNLOCK_METALCITY",
	unlockSpar = "UNLOCK_ZHUBAO",
	unlockFightClub = "UNLOCK_FIGHT_CLUB",
	unlockStrengthTrial = "UNLOCK_STRENGTH_TRIAL",
	unlockSapientialTrial = "UNLOCK_SAPIENTIAL_TRIAL",
	unlockMonopoly = "UNLOCK_BINGHUOLIANGYIYAN",
	unlockStormArena = "UNLOCK_STORM_ARENA",
	unlockArtifact = "UNLOCK_ARTIFACT",
	unlockSanctuary = "UNLOCK_SANCTRUARY",
	unlockSecretary = "UNLOCK_SECRETARY",
	unlockMagicHerb = "UNLOCK_MAGIC_HERB",
	unlockSoulSpirit = "UNLOCK_SOUL_SPIRIT",
	unlockBlackRock = "UNLOCK_BLACKROCK",
	unlockDwarfCellar = "UNLOCK_DWARF_CELLAR",
	unlockElites = "UNLOCK_ELITE",
	unlockShopFade = "SOUL_SHOP_FADE",
	unlockSotoTeam = "UNLOCK_SOTO_TEAM",
	unlockSSGemstone = "GEMSTONE_EVOLUTION",
	unlockCollegeTrain = "UNLOCK_COLLEGE_TRAIN",
	unlockCollegeTrain2 = "UNLOCK_COLLEGE_TRAIN_2",
	unlockCollegeTrain3 = "UNLOCK_COLLEGE_TRAIN_3" ,
	unlockMockBattle = "UNLOCK_MOCK_BATTLE",
	unlockGodarm = "UNLOCK_GOD_ARM",
	unlockMockBattle2 = "UNLOCK_MOCK_BATTLE2",
	unlockWeeklyMission = "UNLOCK_WEEKLY_MISSION",
	unlockSoulSpiritOccult = "UNLOCK_SOUL_TECHNOLOGY",
	unlockSoulTower = "UNLOCK_SOUL_TOWER",
	unlockSilvesArena = "UNLOCK_SILVES_ARENA",
	unlockMetalAbyss = "UNLOCK_ABYSS",
}


function QTips:ctor()
	self._floatTip = nil

	self.unLockTipsNum = 0
	self.unLockTipsType = {}
	self._unlockTip = nil
	self._unlockHandTouch = nil
	self:ctorUnlockTutorial()

	-- 解锁提示相关信息结构
	self.unLockInformation = {
		{type = QUIDialogMystoryStoreAppear.FIND_GOBLIN_SHOP, icon = "icon/item/goblin_merchant.png", name = "地精商店", description = "魂师大人，发现出售稀有道具的特殊商人，是否前往采购"},
		{type = QUIDialogMystoryStoreAppear.FIND_BLACK_MARKET_SHOP, icon = "icon/item/black_marketeer.png", name = "黑市商店", description = "魂师大人，稀有道具的黑市商人来了，副本通关后有概率出现，每次停留一个小时哦~"},
	}
	
	-- 解锁引导相关信息结构
	self.unlockTutorialInfo = {
		shop = {type = QTips.UNLOCK_SHOP_TIPS, node = "shop_node", word = "新开启商店", direction = "right", callFunc = "onTriggerShops", configuration = "UNLOCK_SHOP",  index = 4},
		soulShopFade = {QTips.SOUL_SHOP_FADE, node = "shop_node",word = "新开启魂师商店",direction = "right",callFunc = "onTriggerShops",configuration = "SOUL_SHOP_FADE",tutorialTip = true,index = 6},
		space = {type = QTips.UNLOCK_SPACE_TIPS, node = "time_node", word = "新开启试炼宝屋", direction = "up", callFunc = "onTimeMachine", configuration = "UNLOCK_BPPTY_BAY", tutorialTip = true, index = 6},
		arena = {type = QTips.UNLOCK_ARENA_TIPS, node = "arena_node", word = "新开启斗魂场", direction = "up", callFunc = "onArena", configuration = "UNLOCK_ARENA", index = 5},
		sunwell = {type = QTips.UNLOCK_SUNWELL_TIPS, node = "sunwell_node", word = "新开启海神岛", direction = "up", callFunc = "onSunwell", configuration = "UNLOCK_SUNWELL", tutorialTip = true, index = 6},
		rebirth = {type = QTips.UNLOCK_REBIRTH_TIPS, node = "recycle_node", word = "新开启重生天使", direction = "up", callFunc = "onHeroReborn", configuration = "UNLOCK_REBIRTH", index = 1},
		-- {type = QTips.UNLOCK_SOULSHOP_TIPS, node = "soul_shop", word = "新开启魂师商店", direction = "down"},
		materialRecycle = {type = QTips.UNLOCK_MATERIALRECYCLE_TIPS, node = "recycle_node", word = "新开启材料分解", direction = "up", callFunc = "onHeroReborn", configuration = "UNLOCK_MATERIAL_RECYCLE", index = 1},
		tower = {type = QTips.UNLOCK_TOWER_OF_GLORY, node = "glory_node", word = "新开启大魂师赛", direction = "left", callFunc = "onMilitaryRank", configuration = "UNLOCK_TOWER_OF_GLORY", index = 3},
		union = {type = QTips.UNLOCK_UNION, node = "union_node", word = "新开启宗门", direction = "left", callFunc = "onUnion", configuration = "UNLOCK_UNION", tutorialTip = true, index = 6},
		thunder = {type = QTips.UNLOCK_THUNDER, node = "thunder_node", word = "新开启杀戮之都", direction = "up", callFunc = "onTriggerThunder", configuration = "UNLOCK_THUNDER", tutorialTip = true, index = 6},
		elites = {type = QTips.UNLOCK_ELITE, node = "btn_elite", word = "新开启精英副本", direction = "down", callFunc = "", configuration = "UNLOCK_ELITE", index = 6},
		welfare = {type = QTips.UNLOCK_WELFARE, node = "btn_welfare", word = "新开启史诗副本", direction = "left", callFunc = "", configuration = "UNLOCK_FULIFUBEN_TRIAL", index = 6},
		night = {type = QTips.UNLOCK_NIGHTMARE, node = "btn_nightmare", word = "新开启噩梦副本", direction = "left", callFunc = "", configuration = "UNLOCK_NIGHTMARE", index = 1},
		fortress = {type = QTips.UNLOCK_FORTRESS, node = "fortress_node", word = "新开启魂兽入侵", direction = "up", callFunc = "onInvasion", configuration = "UNLOCK_FORTRESS", tutorialTip = true, index = 6},
		soulTrial = {type = QTips.SOUL_TRIAL_UNLOCK, node = "soulTrial_node", word = "新开启魂力试炼", direction = "right", callFunc = "onSoulTrial", configuration = "SOUL_TRIAL_UNLOCK", tutorialTip = true, index = 6},
		silverMine = {type = QTips.UNLOCK_SILVERMINE, node = "silvermine_node", word = "新开启魂兽森林", direction = "left", callFunc = "onSilverMine", configuration = "UNLOCK_SILVERMINE", index = 5},
		monopoly = {type = QTips.UNLOCK_MONOPOLY, node = "monopoly_node", word = "新开启大富翁", direction = "left", callFunc = "onTriggerMonopoly", configuration = "UNLOCK_BINGHUOLIANGYIYAN", index = 5},
	}

	self._unlockInfos = QStaticDatabase:sharedDatabase():getUnlock()

	--减负功能解锁状态
	self._reduceUnlock = {
						["eliteFastBattle10"] = {unlock = "COPY_AND_BRUSH", state = 0}, 
						["arenaFastBattle"] = {unlock = "UNLOCK_ARENA_QUICK_FIGHT", state = 0},
						["train10"] = {unlock = "UNLOCK_TRAIN_10", state = 0}, 
						["activeFastBattle"] = {unlock = "UNLOCK_ACTIVITY_QUICK_FIGHT", state = 0}, 
						["thunderFastBattle"] = {unlock = "UNLOCK_THUNDER_QUICK_FIGHT", state = 0}, 
						["sunWarFastBattl"] = {unlock = "UNLOCK_SUNWELL_QUICK_FIGHT", state = 0}, 
						["towerAutoBattle"] = {unlock = "TOWER_OF_GLORY_UNLOCK_SKIP", state = 0}, 
						["shopQuickBuy"] = {unlock = "UNLOCK_EASY_BUY", state = 0}, 
						["battleRobot"] = {unlock = "UN_LOCK_YIJIAN_SAODANG", state = 0}, 
					}	
end

function QTips:_createTouchNode(target)
  	self._touchNode = CCNode:create()
    self._touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    self._touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._touchNode:setTouchSwallowEnabled(true)
    target:addChild(self._touchNode)
	self._touchNode:setTouchEnabled( true )
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
end

function QTips:removeouchNode()
	if self._touchNode ~= nil then
		self._touchNode:setTouchEnabled( false )
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
end

function QTips:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._CP ~= nil and event.x >=  self._CP.x - self._size.width/2 and event.x <= self._CP.x + self._size.width/2 and
			event.y >=  self._CP.y - self._size.height/2 and event.y <= self._CP.y + self._size.height/2  then
			if self._handTouchFunc then
				local fun = self._handTouchFunc
				fun( self._handTouchData )
			end
			self:unlockTutorialClose(self._handTouchData.type)
		else
			if self._handTouch and self._handTouch.showFocus then
				self._handTouch:showFocus( self._CP )
			end
		end
	end
end

function QTips:ctorUnlockTutorial()
	self.unlockTutorial = {shop = 0, goblin = 0, black = 0, space = 0, sunwell = 0, endUp = 0, fortress = 0, night = 0, soulTrial = 0, silverMine = 0,
			rebirth = 0, soul = 0, elites = 0, materialRecycle = 0, tower = 0, union = 0, thunder = 0, welfare = 0, daliy = 0, monopoly = 0}
end

--获取解锁提示
function QTips:getUnlockTutorial()
	return self.unlockTutorial
end

--获取解锁引导信息
function QTips:getUnlockTutorialInfo()
	return self.unlockTutorialInfo
end

--保存解锁提示进度
function QTips:setUnlockTutorial(unlockTutorial)
	self.unlockTutorial = unlockTutorial
	local tutorialIsFinished = true
	--   self.unlockTutorial.endUp = 0
	if self.unlockTutorial.endUp == 0 then
		for k, v in pairs(self.unlockTutorial) do
			if v ~= 2 then
				if k ~= "endUp" then
					tutorialIsFinished = false
				end
			end
		end
	end

	if tutorialIsFinished == true then
		self.unlockTutorial.endUp = 1
	end

	local _value = table.formatString(self.unlockTutorial, "^", ";")
	remote.flag:set(remote.flag.FLAG_UNLOCK_TUTORIAL, _value)
end

--刷新本地解锁提示标志位
function QTips:initUnlockTutorial(unlockTutorial)
	if unlockTutorial == nil then
		return
	end
	local value = string.split(unlockTutorial, ";")
	for _, v1 in pairs(value) do
		local val = string.split(v1, "^")
		self.unlockTutorial[val[1]] = tonumber(val[2])
	end
end

--检查解锁提示是否全部完成
function QTips:isUnlockTutorialFinished()
	if self.unlockTutorial.endUp == 1 then
		return true
	end
	return false
end

function QTips:addTipEventListener()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTips.SHOW_NEXT_UNLOCKTIP , QTips.showNextTip, self)
end

function QTips:removeTipEventListener()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTips.SHOW_NEXT_UNLOCKTIP , QTips.showNextTip, self)
end

--战队升级后，检查是否有新功能解锁
function QTips:checkUnlock(newLevel, oldLevel)
	local unlockTutorial = self.unlockTutorial

	for key, unlockInfo in pairs(self._unlockInfos) do
		if unlockInfo.dungeon == nil then
			local isTutorial = false
			for k, value in pairs(UNLOCK_TUTORIAL_TIPS_TYPE) do
				if value == unlockInfo.key then
					isTutorial = true
					break
				end
			end

			local level = tonumber(unlockInfo.team_level) or 0
			if isTutorial == false and newLevel >= level and oldLevel < level and unlockInfo.power_on_off ~= 2  then
				-- self:addUnlockTips(unlockInfo.key)
				for k, unlock in pairs(self.unlockTutorialInfo) do
					if unlockTutorial[unlock.type] ~= nil and unlockTutorial[unlock.type] == 0 and unlock.configuration == unlockInfo.key then
						unlockTutorial[unlock.type] = QTips.UNLOCK_TUTORIAL_OPEN
						break
					end
				end

				-- if unlockInfo.key == "UNLOCK_SHOP_2" then
					-- if remote.stores.blackShop.shelves == nil then
					-- 	remote.stores:getShopInfoFromServerById(SHOP_ID.blackShop)
					-- end
				-- end
			end
		end
	end
	self:setUnlockTutorial(unlockTutorial)

	self:initReduceUnlokState()
end

--副本通关后，检查是否有新功能解锁
function QTips:checkUnlockByPassDungeon()
	local unlockTutorial = self.unlockTutorial
	local isChange = false

 	if unlockTutorial.elites == QTips.UNLOCK_TUTORIAL_CLOSE and app.unlock:getUnlockElite() then
        unlockTutorial.elites = QTips.UNLOCK_TUTORIAL_OPEN
		isChange = true
	end 

 	if unlockTutorial.night == QTips.UNLOCK_TUTORIAL_CLOSE and app.unlock:checkLock("UNLOCK_NIGHTMARE") then
        unlockTutorial.night = QTips.UNLOCK_TUTORIAL_OPEN
		isChange = true
	end 

	if isChange then
		self:setUnlockTutorial(unlockTutorial)
	end
end

--弹出解锁提示
function QTips:showUnlockTips(type)
	if type == QUIDialogMystoryStoreAppear.FIND_GOBLIN_SHOP or type == QUIDialogMystoryStoreAppear.FIND_BLACK_MARKET_SHOP then
		self._unlockTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMystoryStoreAppear", options = {type = type}})
	else
		self._unlockTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnlockSucceed", options = {type = type}})
	end
end

--显示下一个解锁提示
function QTips:showNextTip()
	if self._unlockTip == nil and self.unLockTipsNum ~= 0 then
		local type = self.unLockTipsType[1]
		table.remove(self.unLockTipsType, 1)
		self.unLockTipsNum = self.unLockTipsNum - 1
		self:showUnlockTips(type)
	end
end

--添加一个解锁提示
function QTips:addUnlockTips(type)
	for k, value in pairs (self._unlockInfos) do
		if type == value.key then
			if value.power_on_off ~= 1 then
				return
			end	
		end
	end

	for i = 1, #self.unLockTipsType, 1 do
		if self.unLockTipsType[i] == type then
			return
		end
	end
	if self._unlockTip ~= nil and self._unlockTip.type == type then
		return
	end

	self.unLockTipsNum = self.unLockTipsNum + 1
	table.insert(self.unLockTipsType, type)
end

--根据类型获取解锁提示相关信息
function QTips:getUnlockTipInformation(type)
	for k, value in pairs(self.unLockInformation) do
		if type == value.type then
			self.lockInformation = self.unLockInformation[k]
		end
	end
	return self.lockInformation
end

--创建解锁提示
function QTips:createUnlockTutorialTip(typeInfo, target)
	local unlockInfo = {}
	for k, value in pairs(self.unlockTutorialInfo) do
		if value.type == typeInfo then
			unlockInfo = clone(value)
		end
	end
	if unlockInfo.node == nil or target._ccbOwner[unlockInfo.node] == nil then return nil end

	-- self:_createTouchNode(target:getView())

	if typeInfo ~= "soul" then
		self._unlockHandTouch = typeInfo
	end

	local unlockTip = QUIWidgetUnlockTutorialHandTouch.new({word = unlockInfo.word, direction = unlockInfo.direction, typeInfo = unlockInfo.type})
	local position = target._ccbOwner[unlockInfo.node]:getContentSize()
	unlockTip:setPosition(position.width/2, position.height/2)
	target._ccbOwner[unlockInfo.node]:addChild(unlockTip)
	unlockTip:addEventListener(QUIWidgetUnlockTutorialHandTouch.UNLOCK_TUTORIAL_EVENT_CLICK, handler(target, target._closeUnlockTutorial))


	-- local node = target._ccbOwner[unlockInfo.node]
	-- self._size = {width = 80, height = 80}
	-- self._CP = node:convertToWorldSpaceAR(ccp(0, 0))
	-- self._handTouchFunc = handler(target, target._closeUnlockTutorial)
	-- self._handTouchData = {type = typeInfo}
	-- self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true, pos = self._CP})
	-- node:addChild(self._handTouch)
	-- self._handTouch:setPosition(node:getContentSize().width/2, node:getContentSize().height/2)

	return unlockTip
	-- return self._handTouch
end

function QTips:checkMainMenuMove()
	if self._unlockHandTouch == nil or self._unlockHandTouch == QTips.UNLOCK_ELITE or self._unlockHandTouch == QTips.UNLOCK_WELFARE or self._unlockHandTouch == QTips.UNLOCK_NIGHTMARE then return end
	if app.tutorial then
		app.tutorial:startTutorial(QTutorialDirector.Stage_16_Unlock)
	end
end

--标志解锁提示完成
function QTips:unlockTutorialClose(typeInfo)
	if typeInfo == nil then return end
	local unlockTutorial = clone(self.unlockTutorial)

	unlockTutorial[typeInfo] = QTips.UNLOCK_TUTORIAL_END
	self._unlockHandTouch = nil
	self:setUnlockTutorial(unlockTutorial)
end

--删除解锁提示
function QTips:removeUnlockTips(target)
	if target ~= nil then
		target:removeAllEventListeners()
		target:removeFromParent()
		target = nil
	end
	
	return nil
end

--浮动提示
function QTips:floatTip(content, offsetX, offsetY, time)
	-- if self._floatTipTimeGuard and q.time() - self._floatTipTimeGuard < 1.0 then
	-- 	return
	-- end
	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFloatTip", 
		options = {words = content, offsetX = offsetX, offsetY = offsetY, time = time}}, {isPopCurrentDialog = true})
	-- self._floatTipTimeGuard = q.time()
end


--浮动战力提示
function QTips:floatForce(endForce, startForce, offsetX, offsetY, time)
	-- self:refreshTip()
	-- self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFloatForce", 
	-- 	options = {endForce = endForce, startForce = startForce, offsetX = offsetX, offsetY = offsetY, time = time}}, {isPopCurrentDialog = true})
	-- print("QTips:floatForce()", endForce, startForce, offsetX, offsetY, time)
	local startForce = tonumber(startForce) or remote.user.localForce
	remote.user.localForce = endForce
	if startForce and startForce < endForce then
		if self._floatForceTip then
			self._floatForceTip:exit()
			self._floatForceTip = nil
		end
		app.floatForceNode:removeAllChildren()
		self._floatForceTip = QUIDialogFloatForce.new({endForce = endForce, startForce = startForce, offsetX = offsetX, offsetY = offsetY, time = time})
		app.floatForceNode:addChild(self._floatForceTip:getView())
	end
end

--大富翁浮动获奖提示
function QTips:floatAward(content, offsetX, offsetY, time)
	-- if self._floatTipTimeGuard and q.time() - self._floatTipTimeGuard < 1.0 then
	-- 	return
	-- end

	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFloatAward", 
		options = {words = content, offsetX = offsetX, offsetY = offsetY, time = time}}, {isPopCurrentDialog = true})
	-- self._floatTipTimeGuard = q.time()
end

--天降红包浮动获奖提示
function QTips:skyfloatAward(content, offsetX, offsetY, time)
	-- if self._floatTipTimeGuard and q.time() - self._floatTipTimeGuard < 1.0 then
	-- 	return
	-- end

	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSkyFallFloatAward", 
		options = {words = content, offsetX = offsetX, offsetY = offsetY, time = time}}, {isPopCurrentDialog = true})
	-- self._floatTipTimeGuard = q.time()
end

--浮动获奖提示
function QTips:flyAwardTips(content, offsetX, offsetY, time , callback)
	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFlyAwardTips", 
		options = {content = content, offsetX = offsetX, offsetY = offsetY, time = time , callback = callback}}, {isPopCurrentDialog = true})
end

--缓存战力提示
function QTips:delayAndCacheFloatForce(state)
	-- print("QTips:delayAndCacheFloatForce()", state, remote.user.cacheForce, remote.user.localForce, remote.herosUtil:getMostHeroBattleForce())
	if state == 1 and not remote.user.cacheForce then
		remote.user.cacheForce = remote.user.localForce
		remote.user.localForce = nil
	elseif state == 2 and remote.user.cacheForce then
		remote.user.localForce = remote.user.cacheForce
		remote.user.cacheForce = nil
		self:floatForce(remote.herosUtil:getMostHeroBattleForce())
	end
end

--强化和觉醒大师升级提示
function QTips:masterTip(masterType, level, actorId, oldCurObj, upLevel)
	if self._masterTip ~= nil then
		app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TO_CURRENT_PAGE)
		self._masterTip = nil
	end
	self._masterTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMasterUpGrade", 
		options = {masterType = masterType , level = level, actorId = actorId, oldCurObj = oldCurObj, upLevel = upLevel}}, {isPopCurrentDialog = true})
end

--强化和觉醒大师升级提示
function QTips:gemstoneMasterTip(level1, level2, masterType, actorId, oldCurObj)
	if self._masterTip ~= nil then
		app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TO_CURRENT_PAGE)
		self._masterTip = nil
	end
	self._masterTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMasterUpGrade", 
		options = {masterType = masterType , level = level2, upLevel = level2-level1, actorId = actorId, oldCurObj = oldCurObj}}, {isPopCurrentDialog = true})
	return self._masterTip
end

--仙品升级大师提示
function QTips:magicHerbMasterTip(level1, level2, masterType, actorId)
	if self._masterTip ~= nil then
		app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TO_CURRENT_PAGE)
		self._masterTip = nil
	end
	self._masterTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbMasterUp", 
		options = {masterType = masterType, actorId = actorId, upLevel = level2-level1}}, {isPopCurrentDialog = true})
	return self._masterTip
end

--刷新tips信息
function QTips:refreshTip()
	if self._floatTip ~= nil or self._unlockTip ~= nil or self._masterTip ~= nil then
		app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TO_CURRENT_PAGE)
		self._floatTip = nil
		self._unlockTip = nil
		self._masterTip = nil
	end
end

--奖励提示	otherRole 显示荣荣的头像
function QTips:awardsTip(awards, title, callBack , otherRole)
	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAwardsTip",
		options = {awards = awards, title = title, callBack = callBack , otherRole = otherRole }}, {isPopCurrentDialog = true})
end

--qsy 用于商城购买的icon点击使用，数据是服务器封装前端解析
function QTips:itemTipByItemInfo( itemInfo ,isDetail)
	local itemId = itemInfo.id
	if not itemId or itemId == 0 then
		itemId = itemInfo.item_id
	end

	local itemConfig = db:getItemByID(itemId)
	if itemConfig == nil then
		local configs = remote.items:getWalletByType(itemInfo.itemType or itemInfo.item_type or itemInfo.moneyType)
		if configs then
			-- QPrintTable(configs)
			-- itemConfig = db:getItemByID(configs.item or 0)
			-- if itemConfig == nil then 
			-- 	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsInfo",
			-- 			options = {itemType = itemInfo.itemType or itemInfo.item_type or itemInfo.moneyType, itemId = 0}})
			-- 	return true
			-- end
			-- itemId = configs.item
			self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsInfo",
					options = {itemType = itemInfo.itemType or itemInfo.item_type or itemInfo.moneyType, itemId = 0}})
			return true
		else
			return false
		end
	end

	local itemType = remote.items:getItemType(itemId) or ITEM_TYPE.ITEM
	self:itemTip(itemType , itemId , isDetail)
	return true
end


--物品信息提示 isDetail是否详细介绍
function QTips:itemTip(itemType, itemId, isDetail, params)
	local itemConfig = nil
	if itemType ~= ITEM_TYPE.HERO and itemId ~= nil then
		itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
		if itemConfig ~= nil then
			if itemConfig.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
				itemType = ITEM_TYPE.GEMSTONE_PIECE
			elseif itemConfig.type == ITEM_CONFIG_TYPE.GEMSTONE then
				itemType = ITEM_TYPE.GEMSTONE
			elseif itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
				itemType = ITEM_TYPE.HERO_PIECE
			elseif itemConfig.type == ITEM_CONFIG_TYPE.GARNET or itemConfig.type == ITEM_CONFIG_TYPE.OBSIDIAN then
				itemType = ITEM_TYPE.SPAR
			elseif itemConfig.type == ITEM_CONFIG_TYPE.SPAR_PIECE then
				itemType = ITEM_TYPE.SPAR_PIECE
			elseif itemConfig.type == ITEM_CONFIG_TYPE.ARTIFACT then
				self:ArtifactTip(itemId)
				return
			elseif itemConfig.type == ITEM_CONFIG_TYPE.SKIN_ITEM and itemConfig.content then
				local skinId = string.split(itemConfig.content, "^")
				if skinId[2] then
        			remote.heroSkin:openSkinDetailDialog(skinId[2])
        		end
				return
        	elseif itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB then
        		self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbSuitView",
					options = {itemId = itemId}})
				return
			end
		end
	end

	-- 预览类型
	if itemConfig ~= nil and itemConfig.preview_type then
		if itemConfig.preview_type == 1 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMallVipPreview", 
				options = {itemInfo = {id = itemId} } },{isPopCurrentDialog = false})
		elseif itemConfig.preview_type == 2 then
			local useTypes = string.split(itemConfig.use_type, ";")
	        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
	            options = {chooseType = 2, awardsId = itemId, confirmText = "确  定", useTypes = useTypes, titleText = "礼包预览", showOkBtn = true}, isDuplicate = true },{isPopCurrentDialog = false})
		else
			self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsInfo",
				options = {itemType = itemType, itemId = itemId}})
		end
		return
	end


	-- 是否详细介绍
	if isDetail then
		-- 英雄tips
		if itemType == ITEM_TYPE.HERO then
			self._floatTip = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroDetailInfoNew", 
		        options={actorId = itemId}}, {isPopCurrentDialog = false})
		elseif itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
			local actorId = db:getActorIdBySoulId(itemId, 0) or 0
			self._floatTip = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroDetailInfoNew", 
		        options={actorId = actorId}}, {isPopCurrentDialog = false})

		-- 暗器tips
		elseif itemType == ITEM_TYPE.ZUOQI then
			self._floatTip = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountDetailInfoNew", 
		        options={mountId = itemId, params = params}}, {isPopCurrentDialog = false})
		elseif itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.ZUOQI then
			local mountId = db:getActorIdBySoulId(itemId, 0) or 0
			self._floatTip = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountDetailInfoNew", 
		        options={mountId = mountId}}, {isPopCurrentDialog = false})
		
		-- 魂灵tips
		elseif itemType == ITEM_TYPE.SOUL_SPIRIT then
			self._floatTip = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritDetailInfo", 
		        options={soulSpiritId = itemId}}, {isPopCurrentDialog = false})
		elseif itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.SOULSPIRIT_PIECE then
			local soulSpiritId = db:getActorIdBySoulId(itemId, 0) or 0
			self._floatTip = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritDetailInfo", 
		        options={soulSpiritId = soulSpiritId}}, {isPopCurrentDialog = false})

		-- 神器碎片tips
		elseif itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.GODARM_PIECE then
			local godarmId = db:getActorIdBySoulId(itemId, 0) or 0
			self._floatTip = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodArmDetailInfoNew", 
		        options={godarmId = godarmId}}, {isPopCurrentDialog = false})

		else
			self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsInfo",
				options = {itemType = itemType, itemId = itemId}})
		end
	else
		self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsInfo",
			options = {itemType = itemType, itemId = itemId}})
	end
end

--宝石信息提示
function QTips:gemstoneTip(itemType, gemstronSid)
	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsInfo",
		options = {itemType = itemType, gemstronSid = gemstronSid}})
end

--外附魂骨信息提示
function QTips:sparTip(itemType, itemId, sparInfo)
	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsInfo",
		options = {itemType = itemType, itemId = itemId, sparInfo = sparInfo}})
end

--怪物信息提示
function QTips:monsterTip(info, config,isHideLevel)
	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsMonsterInfo",
		options = {info = info, config = config,isHideLevel = isHideLevel}})
end

--技能信息提示
function QTips:skillTip(skillId, slotLevel, isShort, params)
	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsSkillInfo",
		options = {skillId = skillId, slotLevel = slotLevel, isShort = isShort, params = params}})
end

--技能信息提示
function QTips:ArtifactTip(artifactId, params)
	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsArtifact",
		options = {artifactId = artifactId}})
end

function QTips:wordsTip(words)
	self:refreshTip()
	self._floatTip = app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTipsInfo",
		options = {words = words}})
end


function QTips:assistSkillTip(actorId, callback)
    self._assistSkillInfos = {}
    self._combnationInfos = {}
    self._currentHero = actorId
    local assistInfos = QStaticDatabase:sharedDatabase():getAllAssistSkillByActorId(actorId)
    for _, value in pairs(assistInfos) do
	   	local assistHero, haveAssistHero = remote.herosUtil:checkHeroHaveAssistHero(value.hero)
        if assistHero and haveAssistHero then
        	self._assistSkillInfos[#self._assistSkillInfos+1] = value
        end
    end

    local combinationInfos = QStaticDatabase:sharedDatabase():getCombinationInfoByactorId(actorId)
    for _, value in pairs(combinationInfos) do
	   	local isActive = remote.herosUtil:checkHeroCombination(value.hero_id, value)
        if isActive then
        	self._combnationInfos[#self._combnationInfos+1] = value
        end
    end

    self._assistSkillIndex = 1
    self._combinationIndex = 1
    self:creatAssistSkillTip(callback)
end

function QTips:creatAssistSkillTip(callback)
    if next(self._assistSkillInfos) ~= nil then
        local assistActorId = self._assistSkillInfos[self._assistSkillIndex].hero
        local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(assistActorId, "3")

        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAssistHeroSkillAchieve", 
            options = {actorId = assistActorId, skillId = skillId, assistSkillInfo = self._assistSkillInfos[self._assistSkillIndex], assistHero = self._currentHero, callBack = callback}}, {isPopCurrentDialog = false})
        self._assistSkillInfos[self._assistSkillIndex] = nil
        self._assistSkillIndex = self._assistSkillIndex + 1
    else
    	if next(self._combnationInfos) ~= nil then
    		self:creatCombinationTip(callback)
        elseif callback ~= nil then
            callback()
        end
    end
end

function QTips:creatCombinationTip(callback)
    if next(self._combnationInfos) ~= nil then
        local actorId = self._combnationInfos[self._combinationIndex].hero_id
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCombinationAchieve", 
            options = {actorId = actorId, combinationInfo = self._combnationInfos[self._combinationIndex], combnationHeros = self._currentHero , callBack = callback}}, {isPopCurrentDialog = false})
        self._combnationInfos[self._combinationIndex] = nil
        self._combinationIndex = self._combinationIndex + 1
    else
        if callback ~= nil then
            callback()
        end
    end
end

function QTips:getCombinationIndex()
	return self._combinationIndex or 1
end

function QTips:creatMountCombinationTip(mountId, callBack)
	local isHave = remote.mount:checkMountHavePast(mountId, true)
	if app.unlock:getUnlockMount() == false or isHave then 
        if callBack ~= nil then
            callBack()
        end
		return 
	end
	
	local combinations = QStaticDatabase:sharedDatabase():getCombinationByMountId(tonumber(mountId))
    if remote.mount:checkMountCombination(combinations) then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountCombiantionAchieve", 
			options = { combinationInfo = combinations, combniationMount = mountId, callBack = callBack}}, {isPopCurrentDialog = false})
    else
        if callBack ~= nil then
            callBack()
        end
    end
end

function QTips:resetTip()
	self:ctorUnlockTutorial()
end

----------------------------- 减负功能解锁相关代码 --------------------------------

function QTips:initReduceUnlokState()
	local unlockState = app:getUserOperateRecord():getReduceFunctionUnlockState()
	for key, value in pairs(self._reduceUnlock)do
		if app.unlock:checkLock(value.unlock) then
			if unlockState[key] == nil or unlockState[key] == 0 then
				value.state = 1
			else
				value.state = unlockState[key]
			end
		end
	end
end

function QTips:setReduceUnlockState(unlockType, state)
	if self._reduceUnlock[unlockType] then
		self._reduceUnlock[unlockType].state = state
	end

	app:getUserOperateRecord():setReduceFunctionUnlockState(self._reduceUnlock)
end 

-- state == 0, 未解锁; state == 1, 已解锁，未引导； state == 2, 已解锁，已引导
function QTips:checkReduceUnlokState(unlockType)
	if unlockType == nil then return false end

	if self._reduceUnlock[unlockType] == nil then
		return false
	end

	local isShowTutorial = false
	if self._reduceUnlock[unlockType].state == 1 then
		isShowTutorial = true
	end

	return isShowTutorial
end

return QTips
