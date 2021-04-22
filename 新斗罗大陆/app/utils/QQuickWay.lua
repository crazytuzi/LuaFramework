--
-- Author: xurui
-- Date: 2015-06-18 16:25:25
--
local QQuickWay = class("QQuickWay")

local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QVIPUtil = import("..utils.QVIPUtil")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QUIDialogMall = import("..ui.dialogs.QUIDialogMall")

QQuickWay.CLOSE_QUICK_WAY_DIALOG = 1     

--item
QQuickWay.ITEM_DROP_WAY = 1              	-- 突破材料掉落快捷途径

--resource
QQuickWay.RESOUCE_DROP_WAY = 2  			-- 资源掉落快捷途径

--special
QQuickWay.HERO_DROP_WAY = 3              	-- 魂师碎片掉落快捷途径
QQuickWay.SYNTHETIC_DROP_WAY = 4    		-- 合成品快捷途径
QQuickWay.TOKEN_DROP_WAY = 5             	-- 钻石掉落快捷途径

QQuickWay.REFRESH_QUICKINFO = "REFRESH_QUICKINFO"

function QQuickWay:ctor()
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

--[[
/**
* @return 
*	id, 物品id
*	type, 物品类型
*	name, 物品名称
*	decription, 物品描述
*/
]]
function QQuickWay:getItemInfoByDropType(dropType, info)
	if dropType == QQuickWay.SYNTHETIC_DROP_WAY then
		local itemCraft = QStaticDatabase:sharedDatabase():getItemCraftByItemId(info)
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemCraft.component_id_1)
		local name = q.replaceString(itemConfig.name, "(", "碎片(")
		return itemCraft.component_id_1, {}, ITEM_TYPE.ITEM, name, itemConfig.description
	elseif dropType == QQuickWay.HERO_DROP_WAY then
		local gradeInfo = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(info, 0)
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gradeInfo.soul_gem)
		local name = q.replaceString(itemConfig.name, "(", "碎片(")
		return gradeInfo.soul_gem, {}, ITEM_TYPE.ITEM, name, itemConfig.description
	elseif dropType == QQuickWay.RESOUCE_DROP_WAY then
		local walletInfo = remote.items:getWalletByType(info)
		if walletInfo == nil then
			walletInfo = {}
		end
		return nil, walletInfo, walletInfo.name, walletInfo.nativeName, walletInfo.description
	elseif dropType == QQuickWay.ITEM_DROP_WAY then
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(info)
		return info, {}, ITEM_TYPE.ITEM, itemConfig.name, itemConfig.description
	end
end

--[[
/**
* @param
*	dropType: 掉落材料的类型
*	dropInfo: 掉落为魂师碎片为相应的魂师actorID；
*		掉落为突破材料、觉醒道具时则为ItemID；
*		资源道具则为，资源类型
*	dropNum:掉落为魂师碎片为相应的魂师碎片总数；
*		掉落为突破材料是为需要突破材料总数；
*		其他情况为nil
*   isShowWord: 是否显示物品不足的悬浮提示
*/
]]
function QQuickWay:addQuickWay(dropType, dropInfo, dropNum, confirmCallback, isShowWord, tipWord, isPopCurrentDialog)
	-- add by Kumo at Sun Feb 21 21:58:31 2016
	-- print("[Kumo] QQuickWay:addQuickWay : ", dropType, dropInfo, dropNum, confirmCallback, isShowWord)
	local dropItemId, walletInfo = self:getItemInfoByDropType(dropType, dropInfo)
	if isPopCurrentDialog == nil then
		isPopCurrentDialog = true
	end

	if dropType == nil then return end

	if dropType == QQuickWay.HERO_LEVEL_DROP_WAY then
		app.tip:floatTip("魂师大人，魂师的等级未达到突破要求等级，快去提升魂师等级吧！~")
		return 
	end

	if isShowWord == nil then isShowWord = true end
	if isShowWord and dropType ~= QQuickWay.TOKEN_DROP_WAY then
		local needNum = dropNum or 0
		if needNum == 0 or needNum > remote.items:getItemsNumByID(dropItemId) or remote.items:getItemsNumByID(dropItemId) == 0 then
			local word = tipWord or self:getDescriptionWordByDropType(dropType, dropInfo)
			app.tip:floatTip(word)
		end
	end
	
    if confirmCallback then
    	self._confirmCallback = confirmCallback
    end

    if dropType ~= QQuickWay.TOKEN_DROP_WAY then
		self.itemDrop = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogItemDropInfo", 
			options = {itemId = dropItemId, dropType = dropType, count = dropNum, walletInfo = walletInfo, isfromHeroInfo = true}}, {isPopCurrentDialog = isPopCurrentDialog})
	else
		app:vipAlert({textType = VIPALERT_TYPE.NO_TOKEN, comfirmBack = confirmCallback}, false)
	end
end

function QQuickWay:getDescriptionWordByDropType(dropType, dropInfo)
	if dropType == QQuickWay.HERO_DROP_WAY then 
		return "碎片不足，请查看获取途径~"
	elseif dropType == QQuickWay.SYNTHETIC_DROP_WAY then
		return "碎片不足，请查看获取途径~"
	elseif dropType == QQuickWay.ITEM_DROP_WAY then
		return "道具不足，请查看获取途径~"
	elseif dropType == QQuickWay.RESOUCE_DROP_WAY then
		local walletInfo = remote.items:getWalletByType(dropInfo)
		return (walletInfo.nativeName or "").."不足，请查看获取途径~"
	else
		return "请查看获取途径~"
	end
end

function QQuickWay:clickGotoByIndex(index, param)
	-- 检查shortcut表
	local shortcutInfo = QStaticDatabase.sharedDatabase():getShortcut()
	local quickInfo = {}
	for _, value in pairs(shortcutInfo) do
		if value.ID == index then
			quickInfo = value
			break
		end
	end
	-- 检查item_user_link表
	if next(quickInfo) == nil then
		local linkInfo = QStaticDatabase.sharedDatabase():getItemUseLink()
		for _, value in pairs(linkInfo) do
			if value.id == index then
				quickInfo = value
				break
			end
		end
	end

	if next(quickInfo) then
		self:clickGoto(quickInfo, param)
	end
end

function QQuickWay:clickGoto(value, param)
    -- app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER) [for WOW-13980]
    QNotificationCenter:sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_CLOSE_QUICK_WAY_DIALOG})
    if self._confirmCallback ~= nil then
    	self._confirmCallback()
    end
	if value.configuration and app.unlock:checkLock(value.configuration, true) == false then
		return
	end
	QPrintTable(value)

	if value.cname == "TAVERN" then 
		self:tavernQuickWay()
	elseif value.cname == "ARENA_SHOP" then
		self:openShop(SHOP_ID.arenaShop)
	elseif value.cname == "SANCTRUARY_SHOP" then
		self:openShop(SHOP_ID.sanctuaryShop)
	elseif value.cname == "HERO_SHOP" then
		self:openShop(SHOP_ID.soulShop)
	elseif value.cname == "SHOP" then
		self:openShop(SHOP_ID.generalShop)
	elseif value.cname == "STORE" then
		self:mallQuickWay(2)
	elseif value.cname == "MAGIC_HERB_SHOP" then
		self:mallQuickWay(4)
	elseif value.cname == "ITEM_BAOSHI" then
		self:mallQuickWay(5)
	elseif value.cname == "成就" then
		self:achieveQuickWay()
	elseif value.cname == "BPPTY_BAY" then
		self:tiemMachineQuickWay(1)
	elseif value.cname == "EXPERIENCE_BAR" then
		self:tiemMachineQuickWay(2)
	elseif value.cname == "STRENGTH_TRIAL" then
		self:tiemMachineQuickWay(3)
	elseif value.cname == "SAPIENTIAL_TRIAL" then
		self:tiemMachineQuickWay(4)
	elseif value.cname == "BLACK_SHOP" then
		self:blackShopQuickWay()
	elseif value.cname == "SUNWELL_SHOP" then
		self:openShop(SHOP_ID.sunwellShop)
	elseif value.cname == "SUNWELL" then
		self:sunWellQuickWay()
	elseif value.cname == "GOLD" then
		self:moneyQuickWay()
	elseif value.cname == "ENERGY" then
		self:energyQuickWay()
	elseif value.cname == "ENERGY_CELL" then
		self:useEnergyBattery()
	elseif value.cname == "ENERGY_GIFT" then
		self:energyTask()
	elseif value.cname == "PAY" then
		self:addToken()
	elseif value.cname == "COMMON" then 
		if not self:openCopy(value) then
			self:instanceNormal()
		end
	elseif value.cname == "ELITE" then
		if not self:openCopy(value) then
			self:instanceElite()
		end
	elseif value.cname == "WELFARE" then
		if not self:openCopy(value) then
			self:instanceWelfare()
		end
	elseif value.cname == "COMMON_BOX" then 
		if not self:openCopy(value) then
			self:instanceNormalBox()
		end
	elseif value.cname == "ELITE_BOX" then
		if not self:openCopy(value) then
			self:instanceEliteBox()
		end
	elseif value.cname == "THUNDER_SAODANG_SHOP" then
		self:openShop(SHOP_ID.thunderShop)
	elseif value.cname == "ARENA" then
		self:arena()
	elseif value.cname == "STORM_ARENA" or value.cname == "STORM_ARENA_1" then
		self:stormArena()
	elseif value.cname == "THUNDER_SAODANG" then
		self:thunder()
	elseif value.cname == "HERO_RECYCLE" then
		self:heroReborn("recycle")
	elseif value.cname == "HERO_ENCHANT" then
		self:heroReborn("enchant")
	elseif value.cname == "HERO_DEBRIS_RECYCLE" then
		self:heroReborn("fragment")
	elseif value.cname == "MATERIAL_RECYCLE" then
		self:heroReborn("material")
	elseif value.cname == "TOWER_OF_GLORY" then
		self:openGloryTower()
	elseif value.cname == "UNION" then
		self:openUnion()
	elseif value.cname == "UNION_FATE" then
		self:openUnionBuilding()
	elseif value.cname == "UNION_SHOP" then
		self:openUnionShop()
	elseif value.cname == "FORTRESS" then
		self:openInvasion()
	elseif value.cname == "FORTRESS_SHOP" then
		self:openShop(SHOP_ID.invasionShop)
	elseif value.cname == "UPGRADE" then
		self:openHeroLevelUp(value.needHero)
	elseif value.cname == "TOWER_OF_GLORY_SHOP" then
		self:openShop(SHOP_ID.gloryTowerShop)
	elseif value.cname == "ENCHANT" then
		self:mallQuickWay(1)
	elseif value.cname == "ENCHANT_BOX" then
		self:openMallExchange()
	elseif value.cname == "DAILY_TASKS" then
		self:openDailyTask()
	elseif value.cname == "ARENA_JIFEN" then
		self:openArenaScore()
	elseif value.cname == "ZB_TP" or value.cname == "EQUIPMENT_UP" then
		self:openEquipmentStrong()
	elseif value.cname == "ZB_FM" then
		self:openEquipmentMagic()
	elseif value.cname == "JZ_TP" then
		self:openEquipmentEvolution(nil, false, EQUIPMENT_TYPE.JEWELRY1)
	elseif value.cname == "JZ_QH" then
		self:openEquipmentStrong(nil, false, EQUIPMENT_TYPE.JEWELRY1)
	elseif value.cname == "JZ_FM" then
		self:openEquipmentMagic(nil, false, EQUIPMENT_TYPE.JEWELRY1)
	elseif value.cname == "XL_TP" then
		self:openEquipmentEvolution(nil, false, EQUIPMENT_TYPE.JEWELRY2)
	elseif value.cname == "XL_QH" then
		self:openEquipmentStrong(nil, false, EQUIPMENT_TYPE.JEWELRY2)
	elseif value.cname == "XL_FM" then
		self:openEquipmentMagic(nil, false, EQUIPMENT_TYPE.JEWELRY2)
	elseif value.cname == "HERO" then
		self:heroOverviewQuickWay()
	elseif value.cname == "TRAIN" then
		self:openHeroTraining()
	elseif value.cname == "GLYPH" then
		self:openHeroGlyph()
	elseif value.cname == "SOCIETY_DUNGEON" then
		self:societyDungeonQuickWay()
	elseif string.find(value.cname, "HUODONG") then
		local tbl = string.split(value.cname, "_")
		local themeId = tonumber(tbl[2]) or 1
		self:openActivityPanel(themeId)
	elseif value.cname == "XIANSHI_ACTIVITY" then
		self:openActivityPanel(2)
	elseif value.cname == "SILVER_CHEST" then
		self:silverChestQuickWay()
	elseif value.cname == "SILVER_MINE" then
		self:silverMineQuickWay(param)
	elseif value.cname == "SILVER_SHOP" then
		self:openShop(SHOP_ID.silverShop)
	elseif value.cname == "NIGHTMARE" then
		self:nightmareQuickWay()
	elseif value.cname == "ZUOQI" then
		self:mountChestQuickWay()
	elseif value.cname == "ZUOQI_MAIN" then
		self:mountMainQuickWay()
	elseif value.cname == "ZUOQI_SHOP" then
		self:openShop(SHOP_ID.metalCityShop)
	elseif value.cname == "FRIEND" then
		self:friendQuickWay()
	elseif value.cname == "XILIAN" then
		self:openHeroRefine()
	elseif value.cname == "MAGIC_HERB" then
		self:openHeroMagicHerb()
	elseif value.cname == "MAGIC_HERB_BREED" then
		self:openHeroMagicHerbBreed()
	elseif value.cname == "ZUDUIPVE" then
		self:openBlackRockQuickWay()
	elseif value.cname == "XILIAN_SHOP" then
		self:openShop(SHOP_ID.blackRockShop)
	elseif value.cname == "YUNYING_HUODONG" then
		self:operationActivity()
	elseif value.cname == "ARTIFACT" then
		self:openArtifactDetail()
	elseif value.cname == "ARTIFACT_GRADE" then
		self:openArtifactGrade()
	elseif value.cname == "ARTIFACT_LEVEL" then
		self:openArtifactStrong()
	elseif value.cname == "MARITIME" then
		self:openMaritime()
	elseif value.cname == "SHENQI_SHOP" then
		self:openShop(SHOP_ID.maritimeShop)
	elseif value.cname == "GONGHUIKUANGZHAN" then
		self:openUnionPlunder(param)
	elseif value.cname == "SHIJIEBOSS" then
		self:openWorldBoss()
	elseif value.cname == "WN_SP" then
		self:openHeroExchange()
	elseif value.cname == "YX_JY" then
		self:openHeroEatExp(value.itemId)
	elseif value.cname == "ZQ_SW" then
		self:openMountStrong(nil, true)
	elseif value.cname == "MOUNT_GRADE" then
		self:openMountGrade(param, false)
	elseif value.cname == "MOUNT_GAIZAO" then
		self:openMountReform(param, false)
	elseif value.cname == "BA_TP" then
		self:openGemStoneEvolution(nil, true)
	elseif value.cname == "GEMSTONE_EVOLUTION" then
		self:openGemStoneAdvanced(nil, true)
	elseif value.cname == "GEMSTONE_MIX" then
		self:openGemStoneMix(nil, true)

	elseif value.cname == "KG_SP" or value.cname == "ARCHAEOLOGY" then
		self:openArchaeology()
	elseif value.cname == "ZB_L" then
		self:openActivityDivination()
	elseif value.cname == "ACTIVE_HALL" then
		self:openUnionActiveHall()
	elseif value.cname == "GONGHUIJULONG" then
		self:openUnionDragon()
	elseif value.cname == "RUSH_BUY_SCORE_SHOP" then
		self:openRushBuyShop()
	elseif value.cname == "RUSH_BUY_SCORE_ACTIVITY" then
		self:openRushBuyActivity()
	elseif value.cname == "SOCIATY_DRAGON_FIGHT" then
		self:openUnionDragonWar()
	elseif value.cname == "SOCIATY_DRAGON_SHOP" then
		self:openUnionDragonWarShop()
	elseif value.cname == "JIGNSHI_SHOP" then
		self:openShop(SHOP_ID.sparShop)
	elseif value.cname == "SPAR" then
		self:openSparField()
	elseif value.cname == "JS_QH" then
		self:openSparStrong(nil, true)
	elseif value.cname == "SOCIATY_DRAGON_TASK" then
		self:openDragonWarTask()
	elseif value.cname == "HERO_SKILLS" then
		self:openHeroSkill()
	elseif value.cname == "METALCITY" then
		self:openMetalCity()
	elseif value.cname == "FIGHT_CLUB" then
		self:openFightClub()
	elseif value.cname == "SANCTRUARY" then
		self:openSanctuary()
	elseif value.cname == "ITEM_JINGSHI" then
		self:mallQuickWay(2)
	elseif value.cname == "MONOPOLY" then
		remote.monopoly:openDialog()
	elseif value.cname == "STORM_SHOP" then
		self:openShop(SHOP_ID.artifactShop)
	elseif value.ID == 89003 then
		-- 领
		remote.union:openDialog(function()
				remote.redpacket:openDialog(remote.redpacket.GAIN)
			end)
	elseif value.ID == 89004 then
		-- 发
		remote.union:openDialog(function()
				remote.redpacket:openDialog(remote.redpacket.SEND)
			end)
	elseif value.cname == "SOUL_GRADE" then
		self:openSoulSpiritGrade(value.itemId)
	elseif value.cname == "SOUL_LEVEL" then
		self:openSoulSpiritLevel()
	elseif value.cname == "SOUL_INHERIT" then
		self:openSoulSpiritInherit()
	elseif value.cname == "SOUL_AWAKEN" then
		self:openSoulSpiritAwaken()

	elseif value.cname == "GOD_SKILL" then
		self:openSuperHeroGodSkill(param)
	elseif value.cname == "SOUL_TRIAL" then
		remote.soulTrial:openSoulTrial()
	elseif value.cname == "SEVENDAY_LOG_IN" then
		self:openSevenDay()
	elseif value.cname == "CARNIVAL" then
		self:openCarnival()
	elseif value.cname == "SOTO_TEAM" then
		self:openSotoTeam()
	elseif value.cname == "CRYSTAL_SHOP_GIFT" then
		self:openActivityCrystalShop()
	elseif value.cname == "COLLEGE_TRAIN" then 
		self:openCollegeTrain()
	elseif value.cname == "MOCK_BATTLE" then 
		self:openMockBattle()
	elseif value.cname == "SHENGZHUTIAOZHAN" then 
		remote.totemChallenge:openDialog()
	elseif value.cname == "SHENGZHUSHOP" then
		self:openShop(SHOP_ID.godarmShop)
	elseif value.cname == "GOD_ARM_GRADE" then
		self:openGodarmUpGrade(value.itemId)
	elseif value.cname == "GOD_ARM" then
		self:openGodarmStrength(value.itemId)
	elseif value.cname == "CHECK_IN_YUEDU" then
		remote.monthSignIn:openDialog()
	elseif value.cname == "BATTLE_PASS" then
		self:openDialogBattlePass()
	elseif value.cname == "SOUL_OCCULT" then
		self:openOccultDialog()
	elseif value.cname == "OFFER_REWARD" then
		self:openOfferRewardDialog()
	elseif value.cname == "ZHUANGBEIFUMO" then -- 装备觉醒功能跳转至觉醒宝箱界面
		self:openEnchantMallDialog()	
	elseif value.cname == "SOUL_TOWER" then
		self:openSoulTowerDialog()
	elseif value.cname == "SILVES_ARENA" then
		remote.silvesArena:openDialog()
	elseif value.cname == "SILVES_ARENA_SHOP" then
		self:openShop(SHOP_ID.silvesShop)
	elseif value.cname == "ACHIEVEMENT_COLLECTION" then
		self:openAchievementCollection()
	elseif value.cname == "ABYSS" then
		self:openMetalAbyss()		
	end
end

function QQuickWay:heroOverviewQuickWay()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview",
		options = {heroReborn = false}}, {isPopCurrentDialog = true})
end

function QQuickWay:tavernQuickWay()
	local config = QStaticDatabase:sharedDatabase():getConfiguration()

	return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTreasureChestDraw"},{isPopCurrentDialog = true})
	
end

function QQuickWay:mallQuickWay( tab )
	local tabType = ""

	if tab == 5 then
		tabType = QUIDialogMall.GEMSTONE_TYPE
	elseif tab == 4 then
		tabType = QUIDialogMall.MAGICHERB_TYPE
	elseif tab == 3 then
		tabType = QUIDialogMall.WEEK_MALL_TYPE
	elseif tab == 2 then
		tabType = QUIDialogMall.ITEM_MALL_TYPE
	else
		tabType = QUIDialogMall.ENCHANT_ORIENT_TYPE
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall", 
		options = {tab = tabType}}, {isPopCurrentDialog = true})
end

function QQuickWay:achieveQuickWay()
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAchievement"},{isPopCurrentDialog = true})  
end

function QQuickWay:tiemMachineQuickWay( tab )
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTimeMachine", 
        options = {initPage = tab, isQuickWay = true}}, {isPopCurrentDialog = true})
end

function QQuickWay:goldBattleQuickWay()
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGoldBattle"},{isPopCurrentDialog = true})
end

function QQuickWay:blackShopQuickWay()
    if remote.stores:checkMystoryStore(SHOP_ID.blackShop) and 
    	(remote.stores:checkMystoryStoreTimeOut(SHOP_ID.blackShop) or QVIPUtil:enableBlackMarketPermanent()) then
    	
		self:checkShopQuickWay(SHOP_ID.blackShop)
    	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStore", options = {type = SHOP_ID.blackShop}},{isPopCurrentDialog = true})
    else
		app.tip:floatTip("黑市商店暂未开启")
	end
end

function QQuickWay:sunWellQuickWay()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSunWar"},{isPopCurrentDialog = true})
end

function QQuickWay:moneyQuickWay()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual",
			options = {typeName=ITEM_TYPE.MONEY}})
end

function QQuickWay:energyQuickWay()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual",
			options = {typeName=ITEM_TYPE.ENERGY}})
end

function QQuickWay:useEnergyBattery()
    local items = {25, 26, 27}
	local isHave = false
	local itemId = nil
	for _, value in pairs(items) do
		if remote.items:getItemsNumByID(value) ~= 0 then
			itemId = value
			break
		end
	end
	if itemId ~= nil then
    	local dialog = app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBackpack",
			options = {tab = "TAB_ALL", itemID = itemId}})
	end
end

function QQuickWay:energyTask()
	remote.task:setCurTaskType(remote.task.TASK_TYPE_DAILY)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogDailyTask"})
end

function QQuickWay:addToken()
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

function QQuickWay:arena()
    remote.arena:openArena()
end

-- 打开成就收藏册
function QQuickWay:openAchievementCollection( )
	remote.achievementCollege:openDialog()
end
function QQuickWay:openCopy(info)
	if info.instanceType and info.unlockCopy and info.targetId and info.needNum then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogInstance", 
		    options = {instanceType = info.instanceType, needPassId = info.unlockCopy, targetId = info.targetId, targetNum = info.needNum, isQuickWay = true}})
		return true
	end
	return false
end

function QQuickWay:thunder()
	remote.thunder:openDilaog()
end

function QQuickWay:instanceNormal()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap", options = { instanceType = DUNGEON_TYPE.NORMAL, isQuickWay = true}})
end

function QQuickWay:instanceNormalBox()
	local index = remote.instance:getDungeonBoxInstanceID(DUNGEON_TYPE.NORMAL)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = { instanceType = DUNGEON_TYPE.NORMAL, currentIndex = index, isQuickWay = true}})
end

function QQuickWay:instanceElite()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap", options = { instanceType = DUNGEON_TYPE.ELITE, isQuickWay = true}})
end

function QQuickWay:instanceEliteBox()
	local index = remote.instance:getDungeonBoxInstanceID(DUNGEON_TYPE.ELITE)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInstance", options = { instanceType = DUNGEON_TYPE.ELITE, currentIndex = index, isQuickWay = true}})
end

function QQuickWay:instanceWelfare()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap", options = { instanceType = DUNGEON_TYPE.WELFARE, isQuickWay = true}})
end

function QQuickWay:heroReborn(tab)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroReborn", options = {tab = tab}})
end
	
function QQuickWay:openGloryTower()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:willPlayHide()
	remote.tower:openGloryTower()
end

function QQuickWay:openUnion()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:willPlayHide()
	remote.union:openDialog()
end

function QQuickWay:openUnionBuilding()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:willPlayHide()
	remote.union:unionOpenRequest(function (data)
			if next(data.consortia) then
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionBuilding"})
			else
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnion", options = {initButton = "onTriggerJoin"}})
			end
		end)
end

function QQuickWay:openManageBuilding()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:willPlayHide()
	remote.union:unionOpenRequest(function (data)
			if next(data.consortia) then
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionManage", options = {curSelectBtn = "onTriggerExamine"}})
			else
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnion", options = {initButton = "onTriggerJoin"}})
			end
		end)
end

function QQuickWay:openUnionShop()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:willPlayHide()
	remote.union:unionOpenRequest(function (data)
			if next(data.consortia) then
    	
				self:checkShopQuickWay(SHOP_ID.consortiaShop)
				remote.stores:openShopDialog(SHOP_ID.consortiaShop)
			else
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnion", options = {initButton = "onTriggerJoin"}})
			end
		end)
end

function QQuickWay:openInvasion()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page._scaling:willPlayHide()
    remote.invasion:getInvasionRequest(function(data)
		remote.stores:getShopInfoFromServerById(SHOP_ID.invasionShop)
    	return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasion", options = {}})
	end)
end

function QQuickWay:openMallExchange()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantExchange"})
end

function QQuickWay:openDailyTask()
	remote.task:setCurTaskType(remote.task.TASK_TYPE_NONE)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDailyTask"})
end

function QQuickWay:openArenaScore()
	-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArenaScore"})
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogArenaScore"})
end

function QQuickWay:societyDungeonQuickWay()
	local needLevel = remote.union:getSocietyNeedLevel()
	if (remote.union.consortia.level or 0) >= needLevel then
		remote.union:unionGetBossListRequest(function ( response )
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyMap", 
				options = {}}, {isPopCurrentDialog = true})
		end, function ( response )
			app.tip:floatTip("无法获取实时BOSS信息，请检查下当前网络是否稳定。")
		end)
	else
		app.tip:floatTip("宗门"..needLevel.."级开启宗门副本")
	end
end

function QQuickWay:silverChestQuickWay()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall",
		options = {tab = "GEMSTONE_TYPE"}})
end

function QQuickWay:silverMineQuickWay(param)
	local mineId
	if param then
		mineId = param.mineId
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMineMap", 
		options = {mineId = mineId}})
end

function QQuickWay:openActivityPanel( curTheme )
	if not remote.activity:checkIsAllThemeComplete(curTheme) then
		app.tip:floatTip("不在活动时间段内!")
		return
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel", options = {themeId = curTheme}})
end

function QQuickWay:nightmareQuickWay()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMapNightmare"})
end

function QQuickWay:mountChestQuickWay()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall",
		options = {tab = "MOUNT_TYPE"}})
end

function QQuickWay:mountMainQuickWay()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMountOverView"})
end

function QQuickWay:stormArena( )
	remote.stormArena:openDialog()
end

function QQuickWay:friendQuickWay()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFriend", options = {typeName = remote.friend.TYPE_LIST_FRIEND}})
end

function QQuickWay:openBlackRockQuickWay()
	-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRock"})
	remote.blackrock:openDialog()
end

function QQuickWay:openSoulTowerDialog( )
	remote.soultower:openDialog()
end

function QQuickWay:operationActivity()
	app.tip:floatTip("请关注近期活动")
end


function QQuickWay:openMaritime()
	remote.maritime:openDialog()
end

function QQuickWay:openUnionPlunder(param)
	local mineId
	if param and param.mineId then
		mineId = param.mineId
	end

	if ENABLE_PLUNDER and remote.plunder:checkPlunderUnlock() then
		local timeStr, color, isActive, isOpen = remote.plunder:updateTime()
		if isActive then
			remote.plunder:setCurCavePage( PAGE_NUMBER.ONE )
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPlunderMap", options = {mineId = mineId}})
		else
			self:openUnion()
		end
	end
end

function QQuickWay:openWorldBoss()
	if app.unlock:getUnlockWorldBoss() then
    	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBoss"})	
	end
end

function QQuickWay:openHeroExchange()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroOverview", options = {exchangeModel = true}})
	--app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogExchangeHeroOverView", options = {}})
end

function QQuickWay:openHeroEatExp(itemId)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroOverview", options = {itemId = itemId}})
end

function QQuickWay:openArchaeology()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArchaeologyClient"})
end

function QQuickWay:openActivityDivination()
	local imp = remote.activityRounds:getDivination() or {}
	if imp.isOpen then
		remote.activityRounds:getDivination():requestDivinationInfo(function ( data )
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityDivination", options = {data = data.divinationGetResponse }})
		end)
	else
		app.tip:floatTip("占卜活动尚未开启")
	end
end

function QQuickWay:openUnionActiveHall()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionActiveHall", 
        options = {}}, {isPopCurrentDialog = true})
end

function QQuickWay:openUnionDragon()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonTrain"}, {isPopCurrentDialog = true})
end

function QQuickWay:openRushBuyActivity( )
	-- body
	local imp = remote.activityRounds:getRushBuy()
	if imp and imp.isOpen then
		imp:requestGoodsInfo(function ()
			imp:requestBuyInfos(function ( )
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityRushBuy", options = {} })
			end)
		end)
	else
		app.tip:floatTip("6元夺宝活动尚未开启")
	end
end

function QQuickWay:openRushBuyShop( )
	-- body
	local imp = remote.activityRounds:getRushBuy()
	if imp and imp.isOpen then

		self:checkShopQuickWay(SHOP_ID.rushBuyShop)

		remote.stores:openShopDialog(SHOP_ID.rushBuyShop)
	else
		app.tip:floatTip("6元夺宝活动尚未开启")
	end
end

function QQuickWay:openUnionDragonWar()
	remote.unionDragonWar:openDragonWarDialog()
end

function QQuickWay:openUnionDragonWarShop()
	if remote.unionDragonWar:checkDragonWarUnlock(true) then

		self:checkShopQuickWay(SHOP_ID.dragonWarShop)
		remote.stores:openShopDialog(SHOP_ID.dragonWarShop)
	end
end

function QQuickWay:openShop(shopId)
	if shopId == nil then return end

	self:checkShopQuickWay(shopId)

	remote.stores:openShopDialog(shopId)
end

function QQuickWay:openSparField()
	remote.sparField:openSparField()
end

function QQuickWay:openDragonWarTask()
    remote.dragon:openDragonTask()
end

function QQuickWay:openMetalCity()
	remote.metalCity:openDialog()
end

function QQuickWay:openMetalAbyss()
	remote.metalAbyss:openDialog()
end



function QQuickWay:openFightClub()
	remote.fightClub:openDialog()
end

function QQuickWay:openSanctuary()
	remote.sanctuary:openDialog()
end

function QQuickWay:openSotoTeam()
	remote.sotoTeam:openDialog()
end

function QQuickWay:openMockBattle()
	remote.mockbattle:openMockBattleDialog()
end

function QQuickWay:openActivityCrystalShop( )
	local nowTime = q.serverTime()
	local openServerTime = (remote.user.openServerTime or 0) / 1000
	local offsetTime = (nowTime - openServerTime) / DAY
	if offsetTime > 14 then 
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel", 
			options = {themeId = remote.activity.THEME_ACTIVITY_LIMIT,curActivityID = remote.activity.TYPE_CRYSTAL_SHOP}})
	else
		app.tip:floatTip("活动未开启")
	end
end

function QQuickWay:openCollegeTrain()
   remote.collegetrain:openMainDialog()
end
function QQuickWay:openSevenDay()
	if app.unlock:checkLock("UNLOCK_SEVEN_ENTRY") and remote.activity:checkSevenEntryAllComplete(remote.activity.TYPE_SEVEN_ENTRY1) then 
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySevenDay"})
	else
		app.tip:floatTip("活动未开启")
	end
end

function QQuickWay:openCarnival()
	if app.unlock:checkLock("UNLOCK_CARNIVAL") and remote.activity:checkIsAllComplete(remote.activity.TYPE_ACTIVITY_FOR_SEVEN) then 
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityForSeven", options = {curActivityType = 1}})
	else
		app.tip:floatTip("活动未开启")
	end
end

------------------------------------------------------------------------------------------------
---------------------------------------------重構之後---------------------------------------------
------------------------------------------------------------------------------------------------
---------------------------
---------------------------QUIDialogHeroInformation.start---------------------------
--[[
	打開英雄的技能升級界面
]]
function QQuickWay:openHeroSkill(actorId, isMaxForce)
	self:_openHeroInformation("HERO_SKILL", false, actorId, isMaxForce)
end
--[[
	打開SS級英雄的神技升級界面
]]
function QQuickWay:openSuperHeroGodSkill(actorId, isMaxForce)
	self:_openHeroInformation("HERO_SKILL", true, actorId, isMaxForce)
end
--[[
	打開英雄的培養界面
]]
function QQuickWay:openHeroTraining(actorId, isMaxForce)
	self:_openHeroInformation("HERO_TRAINING", false, actorId, isMaxForce)
end
--[[
	打開英雄的升級界面
]]
function QQuickWay:openHeroLevelUp(actorId, isMaxForce)
	self:_openHeroInformation("HERO_UPGRADE", false, actorId, isMaxForce)
end
--[[
	打開英雄的雕紋界面
]]
function QQuickWay:openHeroGlyph(actorId, isMaxForce)
	self:_openHeroInformation("HERO_GLYPH", false, actorId, isMaxForce)
end
--[[
	打開英雄的洗鍊界面
]]
function QQuickWay:openHeroRefine(actorId, isMaxForce)
	self:_openHeroInformation("HERO_REFINE", false, actorId, isMaxForce)
end
--[[
	打開英雄的仙品界面
]]
function QQuickWay:openHeroMagicHerb(actorId, isMaxForce)
	local actorId = actorId or remote.magicHerb:getActorIdWithMagicHerb()
	if actorId == nil then
		app.tip:floatTip("当前没有魂师装备仙品")
		return
	end
	self:_openHeroInformation("HERO_MAGICHERB", false, actorId, isMaxForce)
end


--[[
	打開英雄的仙品培养界面
]]
function QQuickWay:openHeroMagicHerbBreed(actorId, isMaxForce)
	local actorId = actorId or remote.magicHerb:getActorIdWithMagicHerb()
	if actorId == nil then
		app.tip:floatTip("当前没有魂师装备仙品")
		return
	end
	self:_openHeroInformation("HERO_MAGICHERB", false, actorId, isMaxForce)
end



--[[
	私有方法
	打開英雄的指定界面，默認第一個英雄
	@detailType 界面類型
	@isSuperHero 是否跳到SS級英雄
	@actorId 可指定英雄（現有）（第一優先級）
	@isMaxForce 可指定戰力最高的英雄（第二優先級）
]]
function QQuickWay:_openHeroInformation(detailType, isSuperHero, actorId, isMaxForce)
	local heroIds = isSuperHero and remote.herosUtil:getHaveSuperHero() or remote.herosUtil:getHaveHero()
	if #heroIds == 0 then
		if isSuperHero then
			app.tip:floatTip("您还没有拥有SS魂师")
		else
			app.tip:floatTip("您还没有拥有魂师")
		end
		return
	end

	local pos = 1
	local maxForce = 0
	local isFindAppointActor = false
	for index, heroId in ipairs(heroIds) do
		if heroId == actorId then
			isFindAppointActor = true
			pos = index
			break
		end
		if isMaxForce then
			local heroInfo = remote.herosUtil:getHeroByID(heroId)
			if heroInfo.force > maxForce then
				maxForce = heroInfo.force
				pos = index
			end
		end
	end
	if actorId and not isFindAppointActor then
		if isMaxForce then
			app.tip:floatTip("您还没有拥有该魂师，跳转到战力最高的符合条件的魂师")
		else
			app.tip:floatTip("您还没有拥有该魂师")
			return
		end
	end
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname == "QUIDialogHeroInformation" then
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end
	
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, 
		uiClass="QUIDialogHeroInformation", options = {hero = heroIds, pos = pos, detailType = detailType, isQuickWay = true}})
end
---------------------------QUIDialogHeroInformation.end---------------------------
---------------------------
---------------------------QUIDialogHeroEquipmentDetail.start---------------------------
--[[
	打開英雄裝備的強化界面
]]
function QQuickWay:openEquipmentStrong(actorId, isMaxForce, equipmentType)
	self:_openHeroEquipmentDetail("TAB_STRONG", false, actorId, isMaxForce, equipmentType)
end
--[[
	打開英雄裝備的突破界面
]]
function QQuickWay:openEquipmentEvolution(actorId, isMaxForce, equipmentType)
	self:_openHeroEquipmentDetail("TAB_EVOLUTION", false, actorId, isMaxForce, equipmentType)
end
--[[
	打開英雄裝備的附魔界面
]]
function QQuickWay:openEquipmentMagic(actorId, isMaxForce, equipmentType)
	self:_openHeroEquipmentDetail("TAB_MAGIC", false, actorId, isMaxForce, equipmentType)
end
--[[
	私有方法
	打開英雄裝備的指定界面，默認第一個英雄
	@initTab 界面類型
	@isSuperHero 是否跳到SS級英雄
	@actorId 可指定英雄（現有）（第一優先級）
	@isMaxForce 可指定戰力最高的英雄（第二優先級）
	@equipmentType 裝備位置，默認為武器（EQUIPMENT_TYPE.WEAPON）
]]
function QQuickWay:_openHeroEquipmentDetail(initTab, isSuperHero, actorId, isMaxForce, equipmentType)
	local heroIds = isSuperHero and remote.herosUtil:getHaveSuperHero() or remote.herosUtil:getHaveHero()
	if #heroIds == 0 then
		if isSuperHero then
			app.tip:floatTip("您还未拥有SS魂师")
		else
			app.tip:floatTip("您还未拥有魂师")
		end
		return
	end

	local pos = 1
	local maxForce = 0
	local isFindAppointActor = false
	for index, heroId in ipairs(heroIds) do
		if heroId == actorId then
			isFindAppointActor = true
			pos = index
			break
		end
		if isMaxForce then
			local heroInfo = remote.herosUtil:getHeroByID(heroId)
			if heroInfo.force > maxForce then
				maxForce = heroInfo.force
				pos = index
			end
		end
	end
	if actorId and not isFindAppointActor then
		if isMaxForce then
			app.tip:floatTip("您还未拥有该魂师，跳转到战力最高的符合条件的魂师")
		else
			app.tip:floatTip("您还未拥有该魂师")
			return
		end
	end

	local heroId = heroIds[pos]
	local heroInfo = remote.herosUtil:getHeroByID(heroId)

	local equipmentType = equipmentType or EQUIPMENT_TYPE.WEAPON
    local itemId = 0
    for _, value in pairs(heroInfo.equipments) do
    	local id = value.itemId
    	if remote.herosUtil:getEquipeName(heroId, id) == equipmentType then
			itemId = id
			break
		end
    end
    if itemId == 0 then
		app.tip:floatTip("魂师指定位置没有找到装备")
		return
	end

    local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname == "QUIDialogHeroEquipmentDetail" then
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, 
		uiClass = "QUIDialogHeroEquipmentDetail", 
		options = {itemId = itemId, equipmentPos = equipmentType, heros = heroIds, pos = pos, initTab = initTab, parentOptions = {}, isQuickWay = true}})
end
---------------------------QUIDialogHeroEquipmentDetail.end---------------------------
---------------------------
---------------------------QUIDialogHeroArtifactDetail.start---------------------------
--[[
	打開英雄武魂真身的信息界面
]]
function QQuickWay:openArtifactDetail(actorId, isMaxForce)
	self:_openHeroArtifactDetail("TAB_DETAIL", actorId, isMaxForce)
end
--[[
	打開英雄武魂真身的強化界面
]]
function QQuickWay:openArtifactStrong(actorId, isMaxForce)
	self:_openHeroArtifactDetail("TAB_LEVEL", actorId, isMaxForce)
end
--[[
	打開英雄武魂真身的升星界面
]]
function QQuickWay:openArtifactGrade(actorId, isMaxForce)
	self:_openHeroArtifactDetail("TAB_GRADE", actorId, isMaxForce)
end
--[[
	私有方法
	打開英雄裝備的指定界面，默認第一個英雄
	@initTab 界面類型
	@actorId 可指定英雄（現有已觉醒武魂真身）（第一優先級）
	@isMaxForce 可指定戰力最高的英雄（第二優先級）
]]
function QQuickWay:_openHeroArtifactDetail(initTab, actorId, isMaxForce)
	local heroIds = remote.artifact:getHerosAndPos()
	if #heroIds == 0 then
		app.tip:floatTip("未找到已觉醒武魂真身的魂师哦～")
		return
	end

	local pos = 1
	local maxForce = 0
	local isFindAppointActor = false
	for index, heroId in ipairs(heroIds) do
		if heroId == actorId then
			isFindAppointActor = true
			pos = index
			break
		end
		if isMaxForce then
			local heroInfo = remote.herosUtil:getHeroByID(heroId)
			if heroInfo.force > maxForce then
				maxForce = heroInfo.force
				pos = index
			end
		end
	end
	if actorId and not isFindAppointActor then
		if isMaxForce then
			app.tip:floatTip("该魂师尚未觉醒武魂真身，跳转到战力最高的符合条件的魂师")
		else
			app.tip:floatTip("该魂师尚未觉醒武魂真身")
			return
		end
	end
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname == "QUIDialogHeroArtifactDetail" then
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end
	
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, 
		uiClass="QUIDialogHeroArtifactDetail", options = {heros = heroIds, pos = pos, initTab = initTab, isQuickWay = true}})
end
---------------------------QUIDialogHeroArtifactDetail.end---------------------------
---------------------------
---------------------------QUIDialogHeroGemstoneDetail.start---------------------------
--[[
	打開英雄魂骨的信息界面
]]
function QQuickWay:openGemStoneDetail(actorId, isMaxForce)
	self:_openHeroGemstoneDetail("TAB_DETAIL", actorId, isMaxForce)
end
--[[
	打開英雄魂骨的突破界面
]]
function QQuickWay:openGemStoneEvolution(actorId, isMaxForce)
	self:_openHeroGemstoneDetail("TAB_EVOLUTION", actorId, isMaxForce)
end
--[[
	打開英雄魂骨的进阶或者化神界面
]]
function QQuickWay:openGemStoneAdvanced(actorId, isMaxForce)
    if not app.unlock:checkLock("GEMSTONE_EVOLUTION",false) then
    	app.tip:floatTip("魂骨进阶功能尚未开启，请提升战队等级")
		return
    end
	self:_openHeroGemstoneDetail("TAB_ADVANCED", actorId, isMaxForce)
end

function QQuickWay:openGemStoneMix(actorId, isMaxForce)
	self:_openHeroGemstoneDetail("TAB_FUSE", actorId, isMaxForce)
end

--[[
	打開英雄魂骨的强化界面
]]
function QQuickWay:openGemStoneStrong(actorId, isMaxForce)
	self:_openHeroGemstoneDetail("TAB_STRONG", actorId, isMaxForce)
end
--[[
	私有方法
	打開英雄裝備的指定界面，默認第一個英雄
	@initTab 界面類型
	@actorId 可指定英雄（現有已装备魂骨）（第一優先級）
	@isMaxForce 可指定戰力最高的英雄（第二優先級）
]]
function QQuickWay:_openHeroGemstoneDetail(initTab, actorId, isMaxForce)
	local heroIds = remote.gemstone:getHeros()
	if #heroIds == 0 then
		app.tip:floatTip("未找到已装备魂骨的魂师哦～")
		return
	end

	local pos = 1
	local gemstonePos = 1
	local maxForce = 0
	local isFindAppointActor = false
	for index, heroId in ipairs(heroIds) do
		if heroId == actorId then
			local heroInfo = remote.herosUtil:getHeroByID(heroId)
			isFindAppointActor = true
			pos = index
			gemstonePos = heroInfo.gemstones[1].position
			break
		end
		if isMaxForce then
			local heroInfo = remote.herosUtil:getHeroByID(heroId)
			if initTab == "TAB_FUSE" then --武魂融合的快捷跳转需要判断魂骨是否时S魂骨
				if heroInfo.gemstones[1] and heroInfo.gemstones[1].itemId then
					local itemId = heroInfo.gemstones[1].itemId
					local itemConfig = db:getItemByID(itemId)
					if itemConfig.gemstone_quality >= APTITUDE.S  then
						if heroInfo.force > maxForce then
							maxForce = heroInfo.force
							pos = index
							gemstonePos = heroInfo.gemstones[1].position
						end
					end
				end
			else

				if heroInfo.force > maxForce then
					maxForce = heroInfo.force
					pos = index
					gemstonePos = heroInfo.gemstones[1].position
				end
			end


		end
	end
	if actorId and not isFindAppointActor then
		if isMaxForce then
			app.tip:floatTip("该魂师尚未装备魂骨，跳转到战力最高的符合条件的魂师")
		else
			app.tip:floatTip("该魂师尚未装备魂骨")
			return
		end
	end
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname == "QUIDialogHeroGemstoneDetail" then
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end
	
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, 
		uiClass="QUIDialogHeroGemstoneDetail", options = {heros = heroIds, pos = pos, gemstonePos = gemstonePos, initTab = initTab, isQuickWay = true}})
end
---------------------------QUIDialogHeroGemstoneDetail.end---------------------------
---------------------------
---------------------------QUIDialogHeroSparDetail.start---------------------------
--[[
	打開英雄外附魂骨的信息界面
]]
function QQuickWay:openSparDetail(actorId, isMaxForce)
	self:_openHeroSparDetail("TAB_DETAIL", actorId, isMaxForce)
end
--[[
	打開英雄外附魂骨的强化界面
]]
function QQuickWay:openSparStrong(actorId, isMaxForce)
	self:_openHeroSparDetail("TAB_STRONG", actorId, isMaxForce)
end
--[[
	打開英雄外附魂骨的升星界面
]]
function QQuickWay:openSparGrade(actorId, isMaxForce)
	self:_openHeroSparDetail("TAB_GRADE", actorId, isMaxForce)
end
--[[
	私有方法
	打開英雄裝備的指定界面，默認第一個英雄
	@initTab 界面類型
	@actorId 可指定英雄（現有已装备外附魂骨）（第一優先級）
	@isMaxForce 可指定戰力最高的英雄（第二優先級）
]]
function QQuickWay:_openHeroSparDetail(initTab, actorId, isMaxForce)
	local heroIds = remote.spar:getHeros()
	if #heroIds == 0 then
		app.tip:floatTip("未找到已装备外附魂骨的魂师哦～")
		return
	end

	local pos = 1
	local sparIndex = 1
	local maxForce = 0
	local isFindAppointActor = false
	for index, heroId in ipairs(heroIds) do
		if heroId == actorId then
			isFindAppointActor = true
			pos = index
			break
		end
		if isMaxForce then
			local heroInfo = remote.herosUtil:getHeroByID(heroId)
			if heroInfo.force > maxForce then
				maxForce = heroInfo.force
				pos = index
			end
		end
	end
	if actorId and not isFindAppointActor then
		if isMaxForce then
			app.tip:floatTip("该魂师尚未装备外附魂骨，跳转到战力最高的符合条件的魂师")
		else
			app.tip:floatTip("该魂师尚未装备外附魂骨")
			return
		end
	end
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname == "QUIDialogHeroSparDetail" then
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end
	
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, 
		uiClass="QUIDialogHeroSparDetail", options = {heros = heroIds, pos = pos, index = sparIndex, initTab = initTab, isQuickWay = true}})
end
---------------------------QUIDialogHeroSparDetail.end---------------------------
---------------------------
---------------------------QUIDialogHeroMountDetail.start---------------------------
--[[
	打開英雄暗器的精煉界面
]]
function QQuickWay:openMountStrong(mountId, isMaxForce)
	self:_openHeroMountDetail("TAB_STRONG", mountId, isMaxForce)
end
--[[
	打開英雄暗器的升星界面
]]
function QQuickWay:openMountGrade(mountId, isMaxForce)
	self:_openHeroMountDetail("TAB_GRADE", mountId, isMaxForce)
end
--[[
	打開英雄暗器的升星界面
]]
function QQuickWay:openMountReform(mountId, isMaxForce)
	self:_openHeroMountDetail("TAB_CHANGE", mountId, isMaxForce)
end

function QQuickWay:openGodarmUpGrade(itemId)
	local godList = remote.godarm:getHaveGodarmList() or {}
	local godarmId = nil
	for _,v in pairs(godList) do
		local info = db:getGradeByHeroActorLevel(v.id, v.grade) or {}
		if next(info) ~= nil and info.soul_gem == itemId then
			 godarmId = v.id
		end
	end
	if godarmId then
		local godarmInfo = remote.godarm:getGodarmById(godarmId) or {}
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmInfomation", 
	    	options={godarmId = godarmId,tab = "TAB_DETAILS"}}, {isPopCurrentDialog = false})
	else
		app.tip:floatTip("你还未拥有该神器哦～")
	end
end
-- 打开魂师手札界面
function QQuickWay:openDialogBattlePass(  )
	local canOpen = false
	local themeList = remote.activity:getActivityThemeList()
	for _, theme in pairs(themeList) do
		if theme.id == remote.activity.THEME_ACTIVITY_SOUL_LETTER then
			canOpen = true
			break
		end
	end
	if canOpen then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySoulLetter", 
			options = {}})
	else
		app.tip:floatTip("活动未开启")
	end
end

function QQuickWay:openGodarmStrength(itemId)
	local godList = remote.godarm:getHaveGodarmIdList() or {}
	if next(godList) == nil then
		app.tip:floatTip("请先去获得一件神器～")
		return
	end
	if godList[1] then
		-- local godarmInfo = remote.godarm:getGodarmById(godList[1].id)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmInfomation", 
	    	options={godarmId = godList[1],tab = "TAB_STRENGTH"}}, {isPopCurrentDialog = false})
	end
end
--[[
	私有方法
	打開英雄裝備的指定界面，默認第一個英雄
	@initTab 界面類型
	@mountId 可指定暗器（第一優先級）
	@isMaxForce 可指定戰力最高的英雄（第二優先級）
]]
function QQuickWay:_openHeroMountDetail(initTab, mountId, isMaxForce)
	if mountId then
		local mountInfo = remote.mount:getMountById(mountId)
		if not mountInfo then
			app.tip:floatTip("你还未拥有该暗器哦～")
			return
		end
	else	
		local mountMap = remote.mount:getMountMap()
		local haveMounts = {}
		for i, v in pairs(mountMap) do
			table.insert(haveMounts, v)
		end
		if #haveMounts == 0 then
			app.tip:floatTip("你还未拥有暗器哦～")
			return
		end
		table.sort( haveMounts, function(a, b)
            if a.force ~= b.force then
				return a.force > b.force
			elseif a.aptitude ~= b.aptitude then
				return a.aptitude > b.aptitude
			elseif a.grade ~= b.grade then
				return a.grade > b.grade
			elseif a.reformLevel and b.reformLevel and a.reformLevel ~= b.reformLevel then
				return a.reformLevel > b.reformLevel
			elseif a.enhanceLevel ~= b.enhanceLevel then
				return a.enhanceLevel > b.enhanceLevel
			else
				return a.zuoqiId > b.zuoqiId
			end
		end)
		if initTab == "TAB_CHANGE" then
			for i, v in pairs(haveMounts) do
				if v.aptitude then
					mountId = v.zuoqiId
					break
				end
			end
			if not mountId then
				app.tip:floatTip("你还未拥有SS暗器哦～")
			end
		else
			mountId = haveMounts[1].zuoqiId
		end
	end
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname == "QUIDialogMountInformation" then
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end
	
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, 
		uiClass="QUIDialogMountInformation", options = {mountId = mountId, tab = initTab, isQuickWay = true}})
end
---------------------------QUIDialogHeroMountDetail.end---------------------------
---------------------------
---------------------------QUIDialogSoulSpiritDetail.start---------------------------
--[[
	打開魂灵的吞噬界面
]]
function QQuickWay:openSoulSpiritLevel()
	self:_openSoulSpiritDetail("TAB_LEVEL")
end

function QQuickWay:openSoulSpiritInherit()
	self:_openSoulSpiritDetail("TAB_INHERIT")
end

function QQuickWay:openSoulSpiritAwaken()
	if app.unlock:checkLock("UNLOCK_SOUL_AWAKEN" ,true) then
		self:_openSoulSpiritDetail("TAB_AWAKEN")
	end
end

--[[
	打開魂灵的升星界面
]]
function QQuickWay:openSoulSpiritGrade(fragmentId)
	local id = remote.soulSpirit:getSoulSpiritIdByFragmentId(fragmentId)
	self:_openSoulSpiritDetail("TAB_GRADE", id)
end

--打开魂灵秘术界面
function QQuickWay:openOccultDialog( )
	if app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false) then
		app.sound:playSound("common_small")
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritOccultGuide"})
	end
end

--打开魂灵秘术界面
function QQuickWay:openOfferRewardDialog( )
	if app.unlock:checkLock("UNLOCK_OFFER_REWARD", false) then
		app.sound:playSound("common_small")
		remote.offerreward:openDialogForQuick()
	end
end

function QQuickWay:openEnchantMallDialog( )
	if app.unlock:getUnlockEnchant() then
		app.sound:playSound("common_small")
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall", options = {tab = "ENCHANT_ORIENT_TYPE"}})
	end
end
--[[
	私有方法
	打開魂灵裝備的指定界面，默認第一個魂灵
	@initTab 界面類型
	@actorId 可指定魂灵（現有）（第一優先級）
]]
function QQuickWay:_openSoulSpiritDetail(initTab, actorId)
	local soulSpiritList = remote.soulSpirit:getMySoulSpiritInfoList()
	if #soulSpiritList == 0 then
		app.tip:floatTip("您还未拥有魂灵")
		return
	end

	table.sort(soulSpiritList, function(a, b)
			if a.aptitude ~= b.aptitude then
				return a.aptitude > b.aptitude
			elseif a.grade ~= b.grade then
				return a.grade > b.grade
			elseif a.level ~= b.level then
				return a.level > b.level
			else
				return a.id > b.id
			end
		end)

	local soulSpiritIdList = {}
	for _, info in ipairs(soulSpiritList) do
		table.insert(soulSpiritIdList, info.id)
	end

	local pos = 1

	if "TAB_INHERIT" == initTab or "TAB_AWAKEN" == initTab then
		actorId = 0
		local needQuality = APTITUDE.S
		if "TAB_INHERIT" == initTab then
			needQuality = APTITUDE.SS
		end

		for index, soulSpiritId in ipairs(soulSpiritIdList) do
			local characterConfig = db:getCharacterByID(soulSpiritId)
    		local quality = characterConfig.aptitude
    		if quality >= needQuality then
    			actorId = soulSpiritId
    			pos = index
    			break
    		end
		end
		if actorId == 0 then
			if "TAB_INHERIT" == initTab then
				app.tip:floatTip("您尚未拥有可以传承的魂灵")
				return
			else
				app.tip:floatTip("您尚未拥有可以觉醒的魂灵")
				return				
			end
		end
	else
		if actorId then
			local isFindAppointActor = false
			for index, soulSpiritId in ipairs(soulSpiritIdList) do
				if soulSpiritId == actorId then
					isFindAppointActor = true
					pos = index
					break
				end
			end
			if actorId and not isFindAppointActor then
				app.tip:floatTip("该魂灵您尚未拥有")
				return
			end
		end		
	end
	
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname == "QUIDialogSoulSpiritDetail" then
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end
	
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, 
		uiClass="QUIDialogSoulSpiritDetail", options = {soulSpiritIdList = soulSpiritIdList, id = soulSpiritIdList[pos], tab = initTab}})
end
---------------------------QUIDialogSoulSpiritDetail.end---------------------------


function QQuickWay:checkShopQuickWay(shopId)
	if shopId == nil then return end

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local shopConfig = remote.stores:getShopResousceByShopId(shopId)
	if dialog and shopConfig.className == dialog.class.__cname then
    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end
end


return QQuickWay