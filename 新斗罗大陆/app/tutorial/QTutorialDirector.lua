
local QTutorialDirector = class("QTutorialDirector")

local QNavigationController = import("..controllers.QNavigationController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QTips = import("..utils.QTips")

QTutorialDirector.Stage_1_FirstBattle = "Stage_1_FirstBattle" 		 	    	-- 新手战斗
QTutorialDirector.Force_Stage_Treasure = "Force_Stage_Treasure"             	-- 宝箱引导
QTutorialDirector.Force_Stage_TeamAndDungeon = "Force_Stage_TeamAndDungeon"		-- 阵容和副本引导
QTutorialDirector.Force_Stage_Equipment = "Force_Stage_Equipment"           	-- 魂师装备引导
QTutorialDirector.Force_Stage_Copy1_2 = "Force_Stage_Copy1_2"                   -- 强制引导进入副本1-2
QTutorialDirector.Force_Stage_Copy1_5 = "Force_Stage_Copy1_5"                   -- 强制引导进入副本1-5
QTutorialDirector.Force_Stage_Ywd2_4 = "Force_Stage_Ywd2_4"						-- 通关副本2-4强制引导杨无敌

QTutorialDirector.Stage_25_AddHeroYwd = "Stage_25_AddHeroYwd"       			-- 杨无敌上阵引导
QTutorialDirector.Stage_5_Skill = "Stage_5_Skill"                           	-- 魂师技能引导
QTutorialDirector.Stage_6_Intensify = "Stage_6_Intensify"                   	-- 魂师升级引导
QTutorialDirector.Stage_7_Breakthrough = "Stage_7_Breakthrough"             	-- 魂师突破引导
QTutorialDirector.Stage_8_Strengthen = "Stage_8_Strengthen"                 	-- 新魂师引导
QTutorialDirector.Stage_9_Enchant = "Stage_9_Enchant"                       	-- 战队解锁引导
QTutorialDirector.Stage_10_ArenaAddName = "Stage_10_ArenaAddName"         		-- 斗魂场起名引导
QTutorialDirector.Stage_11_Activity = "Stage_11_Activity"            			-- 活动副本引导
QTutorialDirector.Stage_12_Achieve = "Stage_12_Achieve"             			-- 成就引导
QTutorialDirector.Stage_14_CallHero = "Stage_14_CallHero"            			-- 魂师召唤引导
-- QTutorialDirector.Stage_15_MaterialRecycle = 14     							-- 材料回收引导
QTutorialDirector.Stage_16_Unlock = "Stage_16_Unlock"              				-- 解锁引导
QTutorialDirector.Stage_17_UnlockHelp = "Stage_17_UnlockHelp"         			-- 副将解锁引导
QTutorialDirector.Stage_18_UnlockAddMoeny = "Stage_18_UnlockAddMoeny"      		-- 点金手解锁引导
QTutorialDirector.Stage_19_UnlockTraining = "Stage_19_UnlockTraining"      		-- 培养解锁引导
QTutorialDirector.Stage_20_UnlockJewelry = "Stage_20_UnlockJewelry"       		-- 饰品解锁引导
QTutorialDirector.Stage_21_UnlockArchaeology = "Stage_21_UnlockArchaeology" 	-- 考古解锁引导
QTutorialDirector.Stage_22_UnlockConvey = "Stage_22_UnlockConvey"        		-- 传送门引导
QTutorialDirector.Stage_23_UnlockAddHero = "Stage_23_UnlockAddHero"       		-- 魂师上阵引导
QTutorialDirector.Stage_24_UnlockArena = "Stage_24_UnlockArena"         		-- 斗魂场引导
QTutorialDirector.Stage_25_UnlockHeroStore = "Stage_25_UnlockHeroStore"     	-- 魂师商店引导
QTutorialDirector.Stage_EliteBox = "Stage_EliteBox"     						-- 副本宝箱引导
QTutorialDirector.Stage_EliteStarBox = "Stage_EliteStarBox"     				-- 副本星级宝箱引导
QTutorialDirector.Stage_Gemstone = "Stage_Gemstone"     						-- 宝石功能引导
QTutorialDirector.Stage_SilverMine = "Stage_SilverMine"     					-- 银魂兽森林引导
QTutorialDirector.Stage_NightMare = "Stage_NightMare"     						-- 噩梦副本引导
QTutorialDirector.Stage_Glyph = "Stage_Glyph"     								-- 体技引导
QTutorialDirector.Stage_Refine = "Stage_Refine"     							-- 洗练引导
QTutorialDirector.Stage_DragonTotem = "Stage_DragonTotem"     					-- 图腾引导
QTutorialDirector.Stage_Spar = "Stage_Spar"     								-- 晶石引导
QTutorialDirector.Stage_Thunder = "Stage_Thunder"     							-- 杀戮之都剧情
QTutorialDirector.Stage_Invasion = "Stage_Invasion"     						-- 魂兽入侵剧情
QTutorialDirector.Stage_SunWar = "Stage_SunWar"     							-- 海神岛剧情
QTutorialDirector.Stage_GloryTower = "Stage_GloryTower"     					-- 大魂师赛剧情
QTutorialDirector.Stage_MetalCity = "Stage_MetalCity"     						-- 金属之城剧情
QTutorialDirector.Stage_MountEquip = "Stage_MountEquip"     					-- 暗器装备
QTutorialDirector.Stage_FightClub = "Stage_FightClub"     						-- 地狱杀戮场
QTutorialDirector.Stage_Monopoly = "Stage_Monopoly"     						-- 大富翁
QTutorialDirector.Stage_StormArena = "Stage_StormArena"     					-- 索托斗魂场
QTutorialDirector.Stage_Artifact = "Stage_Artifact"     						-- 武魂真身
QTutorialDirector.Stage_Sanctuary = "Stage_Sanctuary"     						-- 全大陆精英赛
QTutorialDirector.Stage_Secretary = "Stage_Secretary"     						-- 小助手
QTutorialDirector.Stage_UseSkin = "Stage_UseSkin"     							-- 使用皮肤
QTutorialDirector.Stage_Maritime = "Stage_Maritime"     						-- 仙品聚宝盆
QTutorialDirector.Stage_Maritime_Top = "Stage_Maritime_Top"     				-- 仙品聚宝盆_特级仙品引导
QTutorialDirector.Stage_MagicHerb = "Stage_MagicHerb"     						-- 仙品引导
QTutorialDirector.Stage_SoulSpirit = "Stage_SoulSpirit"     					-- 魂灵
QTutorialDirector.Stage_BlackRock = "Stage_BlackRock"     						-- 组队战
QTutorialDirector.Stage_SSGemstone = "Stage_SSGemstone"							-- SS魂骨
QTutorialDirector.Stage_SotoTeam = "Stage_SotoTeam"     						-- 云顶之战
QTutorialDirector.Stage_CollegeTrain = "Statge_CollegeTrain"					-- 训练关
QTutorialDirector.Statge_MockBattle = "Statge_MockBattle"					    -- 大师赛
QTutorialDirector.Statge_Godarm = "Statge_Godarm"								-- 神器
QTutorialDirector.Statge_TotemChallenge = "Statge_TotemChallenge"				-- 圣柱挑战
QTutorialDirector.Statge_MonthSignIn = "Statge_MonthSignIn"						-- 月度签到
QTutorialDirector.Statge_MockBattle2 = "Statge_MockBattle2"					    -- 双队模拟赛
QTutorialDirector.Statge_WeeklyMission = "Statge_WeeklyMission"					-- 周常任务
QTutorialDirector.Statge_SoulSpiritOccult = "Statge_SoulSpiritOccult"			-- 魂灵密术
QTutorialDirector.Statge_SoulTower = "Statge_SoulTower"							-- 升灵台
QTutorialDirector.Statge_TotemChallengeChoose = "Statge_TotemChallengeChoose"	-- 圣柱挑战困难模式选择
QTutorialDirector.Statge_TotemChallengeQuickPass = "Statge_TotemChallengeQuickPass"	-- 圣柱挑战困难模式选择
QTutorialDirector.Statge_SilvesArena = "Statge_SilvesArena"						-- 西尔维斯大斗魂场
QTutorialDirector.Statge_SilvesArena_Fighting = "Statge_SilvesArena_Fighting"	-- 西尔维斯大斗魂场开战期
QTutorialDirector.Statge_OfferReward = "Statge_OfferReward"						-- 悬赏任务
QTutorialDirector.Statge_Handbook = "Statge_Handbook"							-- 新版魂师图鉴
QTutorialDirector.Statge_SoulTower_change = "Statge_SoulTower_change"			-- 升灵台改版
QTutorialDirector.Statge_SilvesArena_Peak = "Statge_SilvesArena_Peak"			-- 西尔维斯大斗魂场巅峰赛
QTutorialDirector.Statge_MetalAbyss = "Statge_MetalAbyss"					    -- 大师赛

QTutorialDirector.Guide_Start = 0                   -- 引导开始
QTutorialDirector.Guide_End = 1                     -- 引导结束
QTutorialDirector.FORCED_GUIDE_STOP = 6             -- 强制引导结束
QTutorialDirector.Guide_Second_Start = 1            -- 引导开启第二次
QTutorialDirector.Guide_Third_Start = 2            -- 引导开启第三次

local UNCLOSE_MAIN_DIALOGS = {
	"QUIDialogTavernAchieve", "QUIDialogShowHeroAvatar"
}
local UNCLOSE_MID_DIALOGS = {
	"QUIDialogTeamUp", "QUIDialogGrade", "QUIDialogAwardsAlert", "QUIDialogAchieveCard", 
	"QUIDialogBuyVirtual", "QUIDialogHeroRebornReturns", "QUIDialogCombinationAchieve", "QUIDialogAssistHeroSkillAchieve", "QUIDialogRobotInformation"
}

local tutorialInfos = {
		Stage_1_FirstBattle = {index = 0, class = ".firstBattle.QTutorialStageFirstBattleNew"}, 
		Force_Stage_Treasure = {index = 1, class = ".Treasure.QTutorialStageTreasure"},
		Force_Stage_TeamAndDungeon = {index = 2, class = ".team&dungeon.QTutorialStageTeamAndDungeon"}, 
		Force_Stage_Equipment = {index = 3, class = ".equipment.QTutorialStageEquipment"},
		Force_Stage_Copy1_2 = {index = 4, class = ".enterCopy.QTutorialStageEnterCopy"}, 
		Force_Stage_Copy1_5 = {index = 5, class = ".enterCopy.QTutorialStageEnterCopy"}, 
		Force_Stage_Ywd2_4 = {class = ".heroYwd.QTutorialStageHeroYwd"},

		Stage_25_AddHeroYwd = {class = ".addHeroYwd.QTutorialStageAddHeroYwd"},
		Stage_5_Skill = {class = ".skill.QTutorialStageSkill"}, 
		Stage_6_Intensify = {class = ".Intensify.QTutorialStageIntensify"}, 
		Stage_7_Breakthrough = {class = ".breakthrough.QTutorStageBreakthrough"}, 
		Stage_8_Strengthen = {class = ".equipmentstrengthen.QTutorialStageEquipmentStrengthen"}, 
		Stage_9_Enchant = {class = ".equipmentenchant.QTutorialStageEquipmentEnchant"}, 
		Stage_10_ArenaAddName = {class = ".addName.QTutorialStageArenaAddName"}, 
		Stage_11_Activity = {class = ".activity.QTutorialStageActivity"}, 
		Stage_12_Achieve = {class = ".achieve.QTutorialStageAchieve"}, 
		Stage_14_CallHero = {class = ".callhero.QTutorialStageCallHero"}, 
		Stage_16_Unlock = {class = ".unlock.QTutorialStageUnlock"}, 
		Stage_17_UnlockHelp = {class = ".unlockHelp.QTutorialStageUnlockHelp"}, 
		Stage_18_UnlockAddMoeny = {class = ".addMoney.QTutorialStageAddMoney"}, 
		Stage_19_UnlockTraining = {class = ".training.QTutorialStageTraining"}, 
		Stage_20_UnlockJewelry = {class = ".jewelry.QTutorialStageJewelry"}, 
		Stage_21_UnlockArchaeology = {class = ".archaeology.QTutorialStageArchaeology"}, 
		Stage_22_UnlockConvey = {class = ".convey.QTutorialStageConvey"}, 
		Stage_23_UnlockAddHero = {class = ".addHero.QTutorialStageAddHero"}, 
		Stage_24_UnlockArena = {class = ".arena.QTutorialStageArena"}, 
		Stage_25_UnlockHeroStore = {class = ".heroStore.QTutorialStageHeroStore"},
		Stage_EliteBox = {class = ".elitesBox.QTutorialStageEliteBox"},
		Stage_EliteStarBox = {class = ".eliteStarBox.QTutorialStageEliteStarBox"},
		Stage_Gemstone = {class = ".gemstone.QTutorialStageGemstone"},
		Stage_SilverMine = {class = ".silverMine.QTutorialStageSilverMine"},
		Stage_NightMare = {class = ".nightMare.QTutorialStageNightMare"},
		Stage_Glyph = {class = ".glyph.QTutorialStageGlyph"},
		Stage_Refine = {class = ".refine.QTutorialStageRefine"},
		Stage_DragonTotem = {class = ".totem.QTutorialStageDragonTotem"},
		Stage_Spar = {class = ".spar.QTutorialStageSpar"},
		Stage_Thunder = {class = ".thunder.QTutorialStageThunder"},
		Stage_Invasion = {class = ".invasion.QTutorialStageInvasion"},
		Stage_SunWar = {class = ".sunWar.QTutorialStageSunWar"}, 
		Stage_GloryTower = {class = ".gloryTower.QTutorialStageGloryTower"},
		Stage_MetalCity = {class = ".metalCity.QTutorialStageMetalCity"},
		Stage_MountEquip = {class = ".mount.QTutorialStageMount"},
		Stage_FightClub = {class = ".fightClub.QTutorialStageFightClub"},
		Stage_Monopoly = {class = ".monopoly.QTutorialStageMonopoly"},
		Stage_StormArena = {class = ".storm.QTutorialStageStromArena"},
		Stage_Artifact = {class = ".artifact.QTutorialStageArtifact"},
		Stage_Sanctuary = {class = ".sanctuary.QTutorialStageSanctuary"},
		Stage_Secretary = {class = ".secretary.QTutorialStageSecretary"},
		Stage_UseSkin = {class = ".useSkin.QTutorialStageUseSkin"},
		Stage_Maritime = {class = ".maritime.QTutorialStageMaritime"},
		Stage_Maritime_Top = {class = ".maritime.QTutorialStageMaritimeTop"},
		Stage_MagicHerb = {class = ".magicHerb.QTutorialStageMagicHerb"},
		Stage_SoulSpirit = {class = ".soulSpirit.QTutorialStageSoulSpirit"},
		Stage_BlackRock = {class = ".blackRock.QTutorialStageBlackRock"},
		Stage_SotoTeam = {class = ".sotoTeam.QTutorialStageSotoTeam"},
		Stage_SSGemstone = {class = ".ssGemStone.QTutorialStageSSGemStone"},
		Statge_CollegeTrain = {class = ".collegeTrain.QTutorialStateCollegeTrain"},
		Statge_MockBattle = {class = ".mockBattle.QTutorialStateMockBattle"},
		Statge_Godarm = {class = ".godArm.QTutorialStateGodarm"},
		Statge_TotemChallenge = {class = ".totemChallenge.QTutorialStateTotemChallenge"},
		Statge_MonthSignIn = {class = ".monthSignIn.QTutorialStateMonthSignIn"},
		Statge_MockBattle2 = {class = ".mockBattle.QTutorialStateMockBattle"},
		Statge_WeeklyMission = {class = ".weeklyMission.QTutorialStateWeeklyMission"},
		Statge_SoulSpiritOccult = {class = ".soulSpiritOccult.QTutorialSoulSpiritOccult"},
		Statge_SoulTower = {class = ".soultower.QTutorialStageSoulTower"},
		Statge_TotemChallengeChoose = {class = ".totemChallenge.QTutorialStateTotemChallengeChoose"},
		Statge_TotemChallengeQuickPass = {class = ".totemChallenge.QTutorialStateTotemChallengeQuickPass"},
		Statge_SilvesArena = {class = ".silves.QTutorialStateSilvesArena"},
		Statge_SilvesArena_Fighting = {class = ".silves.QTutorialStateSilvesArenaFighting"},
		Statge_OfferReward = {class = ".offerReward.QTutorialStageOfferReward"},
		Statge_Handbook = {class = ".handbook.QTutorialStageHandbook"},
		Statge_SoulTower_change = {class = ".soultower.QTutorialStageSoulTowerChange"},
		Statge_SilvesArena_Peak = {class = ".silves.QTutorialStateSilvesArenaPeak"},
		Statge_MetalAbyss = {class = ".metalAbyss.QTutorialStageMetalAbyss"},
	}

function QTutorialDirector:ctor()
	self._runingStage = nil
	self._runingStageId = nil
	self._stage = {forced = 0, intencify = 0, breakth = 0, skill = 0, strengthen = 0, enchant = 0, eliteBox = 0, refine = 0, storm = 0,
		call = 0, guideEnd = 0, unlockHelp = 0, addMoney = 0, training = 0, jewelry = 0, eliteStar = 0, convey = 0, spar = 0, archaeology = 0, 
		addHero = 0, arena = 0, heroShop = 0, activity = 0, gemstone = 0, silver = 0, night = 0, glyph = 0, dragonTotem = 0, thunder = 0, 
		invasion = 0, sunWar = 0, gloryTower = 0, metal = 0, mount = 0, fightClub = 0, monopoly = 0, artifact = 0, sanctuary = 0, secretary = 0,
		useSkin = 0, magicHerb = 0, maritime = 0, maritimeTop = 0, soulSpirit = 0, blackRock = 0,heroYwd = 0,addHeroYwd=0, sotoTeam = 0,ssgemstone = 0,collegeTrain=0,
		mockBattle = 0, totemChallenge = 0,godarm = 0, monthSignIn = 0, mockBattle2 = 0, weeklyMission = 0 ,soulSpiritOccult =0,soulTower = 0, totemChallengeChoose = 0,
		totemChallengeQuickPass = 0, silvesArena = 0, silvesArenaFighting = 0, offerReward = 0, handbook = 0,soultowerChange = 0, silvesArenaPeak = 0, metalAbyss = 0}
end

function QTutorialDirector:getStage()
	return self._stage
end

function QTutorialDirector:setStage(stage)
	self._stage = stage
	for k, value in pairs(self._stage) do
		if value == 0 and k ~= "guideEnd" then
			return
		elseif (k == "call" or k == "jewelry" or k == "unlockHelp") and value < 2 then
			return 
		end
	end
	self._stage.guideEnd = 1
end

function QTutorialDirector:setFlag()
	local _value = table.formatString(self._stage, "^", ";")
	remote.flag:set(remote.flag.FLAG_TUTORIAL_STAGE, _value)
end

function QTutorialDirector:initStage(stage)
	if stage == nil then
		return
	end
	local _stage = string.split(stage, ";")
	for _, v1 in pairs(_stage) do
		local val = string.split(v1, "^")
		self._stage[val[1]] = tonumber(val[2])
	end

	local isNewTutorial = false
	if self._stage.guideEnd == 1 then
		for k, value in pairs(self._stage) do
			if value == 0 then
				isNewTutorial = true
				break
			end
		end
	end
	if isNewTutorial then
		self._stage.guideEnd = 0
		self:setFlag()
	end
end

function QTutorialDirector:checkCurrentDialog()
	local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()
	local dialog2 = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname ~= "QUIPageEmpty" then
		for _, value in pairs(UNCLOSE_MID_DIALOGS) do
			if dialog.class.__cname == value then
				return false
			end
		end
		app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	end
	if dialog2 ~= nil and dialog2.class.__cname ~= "QUIPageEmpty" then
		for _, value in pairs(UNCLOSE_MAIN_DIALOGS) do
			if dialog2.class.__cname == value then
				return false
			end
		end
	end
	return true
end

function QTutorialDirector:splitTutorialWord(id)
    local tutorialInfo = QStaticDatabase:sharedDatabase():getGuidenceWordById(id)
    local talkWords = string.split(tutorialInfo.dialogue, ";")
    local sounds = string.split(tutorialInfo.sound or "", ";") or {}
    local talkWord = {}
    for i = 1, #talkWords do
        local wordInfo = string.split(talkWords[i], "^")
        table.insert(talkWord, wordInfo)
    end
    local sound = {}
    for i = 1, #sounds do
        if sounds[i] ~= "" then
        	table.insert(sound, sounds[i])
        end
    end
    if talkWord[1][4] ~= nil then
    	local words = string.split(talkWord[1][4], "&")
		local newWord = ""
		for _, word in pairs(words) do
			if word == "USER_NAME" then
				newWord = newWord..(remote.user.nickname or "")
			else
				newWord = newWord..word
			end
		end
    	talkWord[1][4] = newWord
    end

    return talkWord, sound
end

function QTutorialDirector:isTutorialFinished()
	if SKIP_TUTORIAL == true then
		return true
	end

	return self._stage.guideEnd > 0
end

function QTutorialDirector:canStartTutorial(stage)
	if stage == nil then
		return false
	end

	return self._stage.guideEnd < 1
end

function QTutorialDirector:checkTutorialStage()
	if self:getStage().forced == tutorialInfos[self.Force_Stage_Treasure].index then
		self:startTutorial(self.Force_Stage_Treasure)
	elseif remote.user.nickname == nil or remote.user.nickname == "" then
		self:startTutorial(self.Stage_10_ArenaAddName)
	elseif self:getStage().forced == tutorialInfos[self.Force_Stage_TeamAndDungeon].index and remote.instance:checkIsPassByDungeonId("wailing_caverns_1") == false then
		self:startTutorial(self.Force_Stage_TeamAndDungeon)
	elseif self:getStage().forced <= tutorialInfos[self.Force_Stage_Equipment].index and remote.instance:checkIsPassByDungeonId("wailing_caverns_1") == true then
		self:startTutorial(self.Force_Stage_Equipment)
	elseif self:getStage().forced == tutorialInfos[self.Force_Stage_Copy1_2].index and 
		(remote.instance:checkIsPassByDungeonId("wailing_caverns_2") == false or remote.instance:checkIsPassByDungeonId("wailing_caverns_3") == false or 
			remote.instance:checkIsPassByDungeonId("wailing_caverns_4") == false ) then
		self:startTutorial(self.Force_Stage_Copy1_2)
	elseif self:getStage().breakth == self.Guide_Start and remote.instance:checkIsPassByDungeonId("wailing_caverns_4") == true then
		self:startTutorial(self.Stage_7_Breakthrough)
	elseif self:getStage().eliteBox == self.Guide_Start and self:getEliteBossBoxUnlock() and remote.instance:checkIsPassByDungeonId("wailing_caverns_5") == false then
		self:startTutorial(self.Stage_EliteBox)
 	elseif self:getStage().forced == tutorialInfos[self.Force_Stage_Copy1_5].index and remote.instance:checkIsPassByDungeonId("wailing_caverns_5") == false then
 		app.tutorial:startTutorial(self.Force_Stage_Copy1_5)
 	elseif self:getStage().heroYwd == self.Guide_Start and remote.instance:checkIsPassByDungeonId("wailing_caverns_16") == true and remote.instance:checkIsPassByDungeonId("wailing_caverns_17") == false then
 		self:startTutorial(self.Force_Stage_Ywd2_4)
 	elseif self:getStage().eliteStar == self.Guide_Start and self:getEliteStarBoxUnlock() and remote.instance:checkIsPassByDungeonId("wailing_caverns_6") == false then
 		app.tutorial:startTutorial(self.Stage_EliteStarBox)
 	elseif self:getStage().useSkin == self.Guide_Start  and remote.instance:checkIsPassByDungeonId("deadmine_4") and not remote.instance:checkIsPassByDungeonId("deadmine_5") then
 		self:startTutorial(self.Stage_UseSkin)
    elseif self:getStage().call == self.Guide_Start and app.unlock:getUnlockTeam3() then
       self:startTutorial(self.Stage_14_CallHero)
	elseif self:getStage().intencify== self.Guide_Start and app.unlock:getUnlockTeam3() == true then
		self:startTutorial(self.Stage_6_Intensify)
	elseif self:getStage().skill == self.Guide_Start and app.unlock:getUnlockSkill() then
		self:startTutorial(self.Stage_5_Skill)
	elseif self:getStage().strengthen == self.Guide_Start and app.unlock:getUnlockEnhance() then
		self:startTutorial(self.Stage_8_Strengthen)
    elseif self:getStage().call == self.Guide_Second_Start and app.unlock:getUnlockTeam4() then
       self:startTutorial(self.Stage_14_CallHero)
	elseif self:getStage().enchant == self.Guide_Start and app.unlock:getUnlockEnchant() then
		self:startTutorial(self.Stage_9_Enchant)
    elseif self:getStage().addMoney == self.Guide_Start and app.unlock:getUnlockAddMoney() then
        self:startTutorial(self.Stage_18_UnlockAddMoeny)
    elseif self:getStage().training == self.Guide_Start and app.unlock:getUnlockTraining() then
        self:startTutorial(self.Stage_19_UnlockTraining)
    elseif self:getStage().jewelry == self.Guide_Start and app.unlock:checkLock("UNLOCK_BADGE") then
        self:startTutorial(self.Stage_20_UnlockJewelry)
    elseif self:getStage().archaeology == self.Guide_Start and app.unlock:getUnlockArchaeology() then
        self:startTutorial(self.Stage_21_UnlockArchaeology)
    elseif self:getStage().arena == self.Guide_Start and app.unlock:getUnlockArena() then
       self:startTutorial(self.Stage_24_UnlockArena)
    elseif self:getStage().heroShop == self.Guide_Start and app.unlock:getUnlockHeroStore() and remote.stores:checkShopCanTutorial(SHOP_ID.soulShop) then
       self:startTutorial(self.Stage_25_UnlockHeroStore)
    elseif self:getStage().activity == self.Guide_Start and app.unlock:getUnlockStrengthTrial() then
        self:startTutorial(self.Stage_11_Activity)
    elseif self:getStage().jewelry == self.Guide_Second_Start and app.unlock:checkLock("UNLOCK_GAD") then
        self:startTutorial(self.Stage_20_UnlockJewelry)
	elseif self:getStage().collegeTrain == self.Guide_Start and app.unlock:checkLock("UNLOCK_COLLEGE_TRAIN") then
		self:startTutorial(self.Stage_CollegeTrain) 	        
    elseif self:getStage().gemstone == self.Guide_Start and app.unlock:getUnlockGemStone() then
        self:startTutorial(self.Stage_Gemstone)
	elseif self:getStage().collegeTrain == self.Guide_Second_Start and app.unlock:checkLock("UNLOCK_COLLEGE_TRAIN_2") then
		self:startTutorial(self.Stage_CollegeTrain)         
    elseif self:getStage().glyph == self.Guide_Start and app.unlock:getUnlockGlyph() then
        self:startTutorial(self.Stage_Glyph)
    elseif self:getStage().refine == self.Guide_Start and app.unlock:getUnlockRefine() then
        self:startTutorial(self.Stage_Refine)
    elseif self:getStage().mount == self.Guide_Start and app.unlock:getUnlockMount() then
        self:startTutorial(self.Stage_MountEquip)
    elseif self:getStage().metal == self.Guide_Start and app.unlock:checkLock("UNLOCK_METALCITY") then
        self:startTutorial(self.Stage_MetalCity)
    elseif self:getStage().spar == self.Guide_Start and app.unlock:checkLock("UNLOCK_ZHUBAO") then
        self:startTutorial(self.Stage_Spar)
    elseif self:getStage().fightClub == self.Guide_Start and app.unlock:checkLock("UNLOCK_FIGHT_CLUB") then
        self:startTutorial(self.Stage_FightClub)   
    elseif self:getStage().soulSpirit == self.Guide_Start and remote.soulSpirit:checkSoulSpiritUnlock() then
		self:startTutorial(self.Stage_SoulSpirit)
	elseif self:getStage().blackRock == self.Guide_Start and remote.blackrock:blackRockIsOpen() then
		self:startTutorial(self.Stage_BlackRock) 
	elseif self:getStage().collegeTrain == self.Guide_Third_Start and app.unlock:checkLock("UNLOCK_COLLEGE_TRAIN_3") then
		self:startTutorial(self.Stage_CollegeTrain) 	
	elseif self:getStage().monopoly == self.Guide_Start and app.unlock:checkLock("UNLOCK_BINGHUOLIANGYIYAN") then
		self:startTutorial(self.Stage_Monopoly)   
	elseif self:getStage().artifact == self.Guide_Start and app.unlock:checkLock("UNLOCK_ARTIFACT") then
		self:startTutorial(self.Stage_Artifact)   
	elseif self:getStage().storm == self.Guide_Start and app.unlock:getUnlockStormArena() then
		self:startTutorial(self.Stage_StormArena)
	elseif self:getStage().sanctuary == self.Guide_Start and app.unlock:checkLock("UNLOCK_SANCTRUARY") then
		self:startTutorial(self.Stage_Sanctuary)
	elseif self:getStage().sanctuary == self.Guide_Second_Start and remote.sanctuary:checkGuideEnterSanctuary() then
		self:startTutorial(self.Stage_Sanctuary)
	elseif self:getStage().ssgemstone == self.Guide_Start and app.unlock:checkLock("GEMSTONE_EVOLUTION") then
		self:startTutorial(self.Stage_SSGemstone) 		
	elseif self:getStage().sotoTeam == self.Guide_Start and app.unlock:checkLock("UNLOCK_SOTO_TEAM") then
		self:startTutorial(self.Stage_SotoTeam) 
	elseif self:getStage().secretary == self.Guide_Start and app.unlock:checkLock("UNLOCK_SECRETARY") then
		self:startTutorial(self.Stage_Secretary) 
	elseif self:getStage().magicHerb == self.Guide_Start and app.unlock:checkLock("UNLOCK_MAGIC_HERB") then
		self:startTutorial(self.Stage_MagicHerb) 
	elseif self:getStage().maritime == self.Guide_Start and app.unlock:checkLock("UNLOCK_MARITIME") then
		self:startTutorial(self.Stage_Maritime)
	elseif self:getStage().mockBattle == self.Guide_Start and app.unlock:checkLock("UNLOCK_MOCK_BATTLE") then
		self:startTutorial(self.Statge_MockBattle) 	
	elseif self:getStage().mockBattle2 == self.Guide_Start and app.unlock:checkLock("UNLOCK_MOCK_BATTLE2") then
		self:startTutorial(self.Statge_MockBattle2) 			
	elseif self:getStage().godarm == self.Guide_Start and remote.godarm:checkGodArmUnlock() then
		self:startTutorial(self.Statge_Godarm)
	elseif self:getStage().totemChallenge == self.Guide_Start and remote.totemChallenge:checkTotemChallengeUnlock() then
		self:startTutorial(self.Statge_TotemChallenge) 	
	elseif self:getStage().monthSignIn == self.Guide_Start and remote.monthSignIn:isNewMonthSignInOpen() then
		self:startTutorial(self.Statge_MonthSignIn) 
	elseif self:getStage().weeklyMission == self.Guide_Start and app.unlock:checkLock("UNLOCK_WEEKLY_MISSION") then
		self:startTutorial(self.Statge_WeeklyMission) 		
	elseif self:getStage().soulSpiritOccult == self.Guide_Start and app.unlock:checkLock("UNLOCK_SOUL_TECHNOLOGY") then
		self:startTutorial(self.Statge_SoulSpiritOccult) 	
	elseif self:getStage().soulTower == self.Guide_Start and app.unlock:checkLock("UNLOCK_SOUL_TOWER") then
		self:startTutorial(self.Statge_SoulTower) 		
	elseif self:getStage().offerReward == self.Guide_Start and app.unlock:checkLock("UNLOCK_OFFER_REWARD") and  remote.union:checkHaveUnion() then
		self:startTutorial(self.Statge_OfferReward) 	
	elseif self:getStage().silvesArena == self.Guide_Start and remote.silvesArena:checkUnlock() then
		self:startTutorial(self.Statge_SilvesArena) 	
	elseif self:getStage().soultowerChange == self.Guide_Start and self:getStage().soulTower == self.Guide_End and app.unlock:checkLock("UNLOCK_SOUL_TOWER")
		and remote.soultower:checkScore() then
			self:startTutorial(self.Statge_SoulTower_change) 	
	elseif self:getStage().metalAbyss == self.Guide_Start and remote.metalAbyss:checkMetalAbyssIsUnLock() then
		self:startTutorial(self.Statge_MetalAbyss) 	
    else
    	return false
    end
end 

function QTutorialDirector:getJewelryUnlock(level)
	if level == nil then return false end
	local heros = remote.herosUtil:getHaveHero()
	for i = 1, #heros, 1 do
		local heroInfo = remote.herosUtil:getHeroByID(heros[i])
		if heroInfo.level >= level then
			return true
		end
	end
	return false
end 

function QTutorialDirector:getEliteBossBoxUnlock()
	local dungeonInfo = remote.instance:getDungeonById("wailing_caverns_4")
	if dungeonInfo == nil then return false end

	if  dungeonInfo.dungeon_isboss == true and dungeonInfo.info and dungeonInfo.info.bossBoxOpened == false then
		return true
	end
	return false
end 

function QTutorialDirector:getEliteStarBoxUnlock()
	local starNum = 0
	for i = 1, 5 do
		local dungeonInfo = remote.instance:getDungeonById("wailing_caverns_"..i)
		if dungeonInfo and dungeonInfo.info then
			local num = dungeonInfo.info.star or 0
			starNum = starNum + num
		end
	end
	local isHave = false
	local dropInfo = remote.instance:getDropBoxInfoById(100101, function(data)
			if data ~= nil and data.isDraw1 then
				isHave = true
			end
		end)
	if starNum >= 13 and isHave == false then
		return true
	end 
	return false
end 

function QTutorialDirector:startTutorial(stage)
	print("stage = " , stage)
	if stage == nil then
		return false
	end

	if self._runingStage ~= nil then
		return false
	end

	--  if ONLY_BATTLE_TUTORIAL == true then
	--    if stage == QTutorialDirector.Stage_1_FirstBattle then
	--      self._runingStage = QTutorialStageFirstBattle.new()
	--    else
	--      return
	--    end
	--  else
	print(tutorialInfos[stage], tutorialInfos[stage].class)
	if tutorialInfos[stage] and tutorialInfos[stage].class then
		print("start tutorial",tutorialInfos[stage].class)
        local stageClass = import(app.packageRoot .. ".tutorial" .. tutorialInfos[stage].class)
        self._runingStage = stageClass.new()
	else
		return false
	end
	--  end

	if self._runingStage == nil then
		return false
	end

	self._runingStageId = stage;

	self._delayStartStageHandle = scheduler.performWithDelayGlobal(function()
		self._delayStartStageHandle = nil
		self._runingStage:start()
		self._frameHandle = scheduler.scheduleUpdateGlobal(handler(self, QTutorialDirector._onFrame))
		return true
	end, 0)

end

function QTutorialDirector:_onFrame(dt)
	if self._runingStage:isStageFinished() == true then
		self._runingStage:ended()
		scheduler.unscheduleGlobal(self._frameHandle)
		self._frameHandle = nil
		self._runingStage = nil
		self._runingStageId = nil
		return
	end

	self._runingStage:visit(dt)
end

function QTutorialDirector:ended()
	if self._delayStartStageHandle then
		scheduler.unscheduleGlobal(self._delayStartStageHandle)
		self._delayStartStageHandle = nil
	end

	if self._frameHandle then
		scheduler.unscheduleGlobal(self._frameHandle)
		self._frameHandle = nil
	end

	if self._runingStage then
		self._runingStage:jumpFinished()
		self._runingStage = nil
		self._runingStageId = nil
	end
	
	app.tutorialNode:removeAllChildren()
end

function QTutorialDirector:isInTutorial()
	return (self._runingStage ~= nil)
end

function QTutorialDirector:getRuningStage()
	return self._runingStage
end

function QTutorialDirector:getRuningStageId()
	return self._runingStageId
end

function QTutorialDirector:getRuningStageIndex()
	if not self._runingStageId then
		return nil
	end
	local stageInfo = tutorialInfos[self._runingStageId]
	return stageInfo.index
end

return QTutorialDirector
