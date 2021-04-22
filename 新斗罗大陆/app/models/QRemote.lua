--[[
    远程数据
]]

local QModelBase = import(".QModelBase")
local QRemote = class("QRemote", QModelBase)

local QStaticDatabase = import("..controllers.QStaticDatabase")

local QTeamManager = import("..network.models.QTeamManager")
local QFlag = import("..utils.QFlag")
local QItems = import("..utils.QItems")
local QTops = import("..utils.QTops")
local QTops = import("..utils.QTops")
local QTask = import("..utils.QTask")
local QMails = import("..utils.QMails")
local QArena = import("..utils.QArena")
local QAchieveUtils = import("..utils.QAchieveUtils")
local QUserProp = import("..utils.QUserProp")
local QInstance = import("..utils.QInstance")
local QActivityInstance = import("..utils.QActivityInstance")
local QHerosUtils = import("..utils.QHerosUtils")
local QUIViewController = import("..ui.QUIViewController")
local QShop = import("..utils.QShop")
local QDailySignIn = import("..utils.QDailySignIn")
local QActivity = import("..utils.QActivity")
local QHelpUtil = import("..utils.QHelpUtil")
local QStrongerUtil = import("..utils.QStrongerUtil")
local QActivityRounds = import("..utils.QActivityRounds")
local QActivityMonthFund = import("..utils.QActivityMonthFund")
local QTower = import("..utils.QTower")
local QUnion = import("..network.models.QUnion")
local QInvasion = import("..network.models.QInvasion")
local QMark = import("..network.models.QMark")
local QThunder = import("..network.models.QThunder")
local QWelfareInstance = import("..network.models.QWelfareInstance")
local QFriend = import("..network.models.QFriend")
local QArchaeology = import("..network.models.QArchaeology")
local QSunWar = import("..network.models.QSunWar")
local QRewardRecover = import("..network.models.QRewardRecover")
local QRobot = import("..network.models.QRobot")
local QLogFile = import("..utils.QLogFile")
local QExchangeShop = import("..utils.QExchangeShop")
local QGemstone = import("..network.models.QGemstone")
local QSilverMine = import("..network.models.QSilverMine")
local QPlunder = import("..network.models.QPlunder")
local QNightmare = import("..network.models.QNightmare")
local QStormArena = import("..utils.QStormArena")
local QMount = import("..network.models.QMount")
local QRedTips = import("..utils.QRedTips")
local QWorldBoss = import("..network.models.QWorldBoss")
local QBlackRock = import("..network.models.QBlackRock")
local QRedPoint = import("..network.models.QRedPoint")
local QArtifact = import("..network.models.QArtifact")
local QMaritime = import("..network.models.QMaritime")
local QCalendar = import("..network.models.QCalendar")
local QDragonTotem = import("..network.models.QDragonTotem")
local QDragon = import("..network.models.QDragon")
local QQuestion = import("..network.models.QQuestion")
local QConsortiaWar = import("..network.models.QConsortiaWar")
local QUnionDragonWar = import("..network.models.QUnionDragonWar")
local QSanctuary = import("..network.models.QSanctuary")
local QSparField = import("..network.models.QSparField")
local QSpar = import("..network.models.QSpar")
local QSoulTrial = import("..network.models.QSoulTrial")
local QPayFeedback = import("..network.models.QPayFeedback")
local QCelebrityHallRank = import("..network.models.QCelebrityHallRank")
local QMetalCity = import("..network.models.QMetalCity")
local QMonthSignIn = import("..network.models.QMonthSignIn")
local QHeadProp = import("..network.models.QHeadProp")
local QFightClub = import("..network.models.QFightClub")
local QSotoTeam = import("..network.models.QSotoTeam")
local QMonopoly = import("..network.models.QMonopoly")
local QHandBook = import("..network.models.QHandBook")
local QUnionRedPacket = import("..network.models.QUnionRedPacket")
local QHeroSkin = import("..network.models.QHeroSkin")
local QActivityCarnival = import("..utils.QActivityCarnival") 
local QUserComeBack = import("..network.models.QUserComeBack")
local QSecretary = import("..network.models.QSecretary")
local QUserDynamic = import("..network.models.QUserDynamic")
local QMagicHerb = import("..network.models.QMagicHerb")
local QActivityVipGift = import("..utils.QActivityVipGift")
local QBindingPhone = import("..network.models.QBindingPhone")
local QSoulSpirit = import("..network.models.QSoulSpirit")
local QGradePackage = import("..utils.QGradePackage")
local QPlayerRecall = import("..network.models.QPlayerRecall")
local QTrailer = import("..network.models.QTrailer")
local QRank = import("..network.models.QRank")
local QActivityCrystal = import("..utils.QActivityCrystal")
local QCollegeTrain = import("..utils.QCollegeTrain") 
local QMockBattle = import("..network.models.QMockBattle")
local QRecycle = import("..network.models.QRecycle")
local QTotemChallenge = import("..network.models.QTotemChallenge")
local QGodArm = import("..utils.QGodArm")
local QFashion = import("..network.models.QFashion")
local QOfferReward = import("..network.models.QOfferReward")
local QSoulTower = import("..network.models.QSoulTower")
local QGrowthFund = import("..network.models.QGrowthFund")
local QSilvesArena = import("..network.models.QSilvesArena")
local QAchievementCollection = import("..network.models.QAchievementCollection")
local QShareSDK = import("..network.models.QShareSDK")
local QAwakeningRebirth = import("..network.models.QAwakeningRebirth")
local QSuperHeroGrade = import("..network.models.QSuperHeroGrade")
local QMetalAbyss = import("..network.models.QMetalAbyss")

-- 定义属性
QRemote.schema = clone(cc.mvc.ModelBase.schema)
QRemote.schema["name"] = {"string"} -- 字符串类型，没有默认值

-- 更新事件
QRemote.USER_UPDATE_EVENT = "USER_UPDATE_EVENT"
QRemote.DUNGEON_UPDATE_EVENT = "DUNGEON_UPDATE_EVENT"
QRemote.ACTIVITY_DUNGEON_UPDATE_EVENT = "ACTIVITY_DUNGEON_UPDATE_EVENT"
QRemote.HERO_UPDATE_EVENT = "HERO_UPDATE_EVENT"
QRemote.TEAMS_UPDATE_EVENT = "TEAMS_UPDATE_EVENT"
-- QRemote.TOPS_UPDATE_EVENT = "TOPS_UPDATE_EVENT"
-- QRemote.ZONES_UPDATE_EVENT = "ZONES_UPDATE_EVENT"
QRemote.PKUSERLIST_UPDATE_EVENT = "PKUSERLIST_UPDATE_EVENT"
QRemote.TASK_UPDATE_EVENT = "TASK_UPDATE_EVENT"
QRemote.STORES_UPDATE_EVENT = "STORES_UPDATE_EVENT"
QRemote.TIME_UPDATE_EVENT = "TIME_UPDATE_EVENT"

QRemote.GLORY_TOWER_LAST_FLOOR = "GLORY_TOWER_LAST_FLOOR"
QRemote.GLORY_TOWER_TITLE_REFRESH = "GLORY_TOWER_TITLE_REFRESH"

QRemote.dataModels = { "headProp", "monopoly", "handBook", "redpacket", "heroSkin", "activityCarnival", 
        "userComeBack", "userDynamic", "activityVipGift", "bindingPhone", "soulSpirit", "gradePackage", "playerRecall", 
        "strongerUtil", "trailer", "rank"
    }

function QRemote:ctor()
    QRemote.super.ctor(self)
    self.trailer = QTrailer.new()
    self.instance = QInstance.new()
    self.welfareInstance = QWelfareInstance.new()
    self.activityInstance = QActivityInstance.new()
    self.herosUtil = QHerosUtils.new()
    self.teamManager = QTeamManager.new()
    self.items = QItems.new()
    self.tops = QTops.new()
    self.flag = QFlag.new()
    self.task = QTask.new()
    self.achieve = QAchieveUtils.new()
    self.user = QUserProp.new()
    self.stores = QShop.new()
    self.daily = QDailySignIn.new()
    self.mails = QMails.new()
    self.arena = QArena.new()
    self.crystal = QActivityCrystal.new()
    self.collegetrain = QCollegeTrain.new()
    self.activity = QActivity.new()
    self.helpUtil = QHelpUtil.new()
    self.strongerUtil = QStrongerUtil.new()
    self.activityRounds = QActivityRounds.new()
    self.activityMonthFund = QActivityMonthFund.new()
    self.tower = QTower.new()
    self.union = QUnion.new()
    self.invasion = QInvasion.new()
    self.mark = QMark.new()
    self.thunder = QThunder.new()
    self.friend = QFriend.new()
    self.archaeology = QArchaeology.new()
    self.sunWar = QSunWar.new()
    self.rewardRecover = QRewardRecover.new()
    self.robot = QRobot.new()
    self.gemstone = QGemstone.new()
    self.silverMine = QSilverMine.new()
    self.plunder = QPlunder.new()
    self.exchangeShop = QExchangeShop.new()
    self.nightmare = QNightmare.new()
    self.stormArena = QStormArena.new()
    self.mount = QMount.new()
    self.redTips = QRedTips.new()
    self.worldBoss = QWorldBoss.new()
    self.blackrock = QBlackRock.new()
    self.redPoint = QRedPoint.new()
    self.artifact = QArtifact.new()
    self.maritime = QMaritime.new()
    self.calendar = QCalendar.new()
    self.sparField = QSparField.new()
    self.spar = QSpar.new()
    self.soulTrial = QSoulTrial.new()
    self.payFeedback = QPayFeedback.new()
    self.celebrityHallRank = QCelebrityHallRank.new()
    self.metalCity = QMetalCity.new()
    self.monthSignIn = QMonthSignIn.new()
    self.headProp = QHeadProp.new()
    self.fightClub = QFightClub.new()
    self.monopoly = QMonopoly.new()
    self.handBook = QHandBook.new()
    self.mockbattle = QMockBattle.new()
    self:initData()

    self.serverTime = nil
    self.serverResTime = nil

    self.dic_version = nil

    self.serverInfos = nil
    self.selectServerInfo = nil
    self.serverConfig = nil --服务器列表的信息

    self.recharge = {}
    self.firstRecharge = {}
    self._pushCallBack = {}
    self.notificationSetting = {}
end

function QRemote:initData( ... )
    -- body
    self.mockbattle = QMockBattle.new()
    self.activityVipGift = QActivityVipGift.new()
    self.gradePackage = QGradePackage.new()
    self.dragonTotem = QDragonTotem.new()
    self.dragon = QDragon.new()
    self.question = QQuestion.new()
    self.consortiaWar = QConsortiaWar.new()
    self.unionDragonWar = QUnionDragonWar.new()
    self.redpacket = QUnionRedPacket.new()
    self.awakeningRebirth = QAwakeningRebirth.new()
    self.superHeroGrade = QSuperHeroGrade.new()

    self.heroSkin = QHeroSkin.new()
    self.activityCarnival = QActivityCarnival.new()
    self.sanctuary = QSanctuary.new()
    self.sotoTeam = QSotoTeam.new()
    self.secretary = QSecretary.new()
    self.userComeBack = QUserComeBack.new()
    self.userDynamic = QUserDynamic.new()
    self.magicHerb = QMagicHerb.new()
    self.bindingPhone = QBindingPhone.new()
    self.soulSpirit = QSoulSpirit.new()
    self.playerRecall = QPlayerRecall.new()
    self.rank = QRank.new()
    self.recycle = QRecycle.new()
    self.totemChallenge = QTotemChallenge.new()
    self.godarm = QGodArm.new()
    self.fashion = QFashion.new()
    self.offerreward = QOfferReward.new()
    self.soultower = QSoulTower.new()
    self.growthFund = QGrowthFund.new()
    self.silvesArena = QSilvesArena.new()
    self.achievementCollege = QAchievementCollection.new()
    self.shareSDK = QShareSDK.new()
    self.metalAbyss = QMetalAbyss.new()
end

--在用户准备登陆时调用
function QRemote:readyLogin()
    self.task:init()
    self.achieve:init()

    self.crystal:disappear()
    self.collegetrain:disappear()

    self.activity:init()
    self.helpUtil:init()

    self.herosUtil:initHero()
    self.activityInstance:init()
    -- self.sunWell:init()
    self.items:init()
    self.teamManager:didappear()
    self.instance:init()
    self.mails:didappear()
    self.herosUtil:didappear()
    self.arena:didappear()
    self.user:didappear()
    self.welfareInstance:init()
    self.friend:didappear()
    self.archaeology:init()
    self.sunWar:init()
    self.rewardRecover:init()
    self.robot:init()
    self.invasion:didappear()
    self.union:init()
    self.gemstone:didappear()
    self.silverMine:init()
    self.plunder:init()
    self.exchangeShop:didappear()
    self.nightmare:didappear()
    self.activityRounds:didappear()
    self.activityMonthFund:didappear()
    self.stormArena:didappear()
    self.mount:didappear()
    self.redTips:didappear()
    self.worldBoss:didappear()
    self.blackrock:didappear()
    self.redPoint:init()
    self.artifact:didappear()
    self.maritime:didappear()
    self.calendar:didappear()
    self.dragonTotem:didappear()
    self.dragon:init()
    self.question:didappear()
    self.consortiaWar:didappear()
    self.unionDragonWar:didappear()
    self.sanctuary:didappear()
    self.sotoTeam:didappear()
    self.secretary:didappear()
    self.sparField:didappear()
    self.spar:didappear()
    self.soulTrial:init()
    self.payFeedback:init()
    self.celebrityHallRank:init()
    self.metalCity:didappear()
    self.monthSignIn:didappear()
    self.headProp:didappear()
    self.fightClub:didappear()
    self.stores:didappear()
    self.monopoly:init()
    self.handBook:init()
    self.redpacket:init()
    self.heroSkin:init()
    self.activityCarnival:init()
    self.userComeBack:init()
    self.userDynamic:init()
    self.magicHerb:init()
    self.activityVipGift:didappear()
    self.bindingPhone:didappear()
    self.soulSpirit:init()
    self.gradePackage:didappear()
    self.playerRecall:init()
    self.strongerUtil:didappear()
    self.trailer:init()
    self.rank:init()
    self.mockbattle:init()
    self.recycle:didappear()
    self.totemChallenge:didappear()
    self.godarm:didappear()
    self.fashion:init()
    self.offerreward:didappear()
    self.soultower:didappear()
    self.growthFund:init()
    self.silvesArena:init()
    self.achievementCollege:didappear()
    self.shareSDK:didappear()
    self.metalAbyss:didappear()
end

--在用户准备登陆时调用
function QRemote:loginEnd()
    self.teamManager:loginEnd()
    -- self.sunWell:getNeedPass()
    self.crystal:loginEnd()    
    self.collegetrain:loginEnd()
    self.activity:requestActivityData()
    -- self.mails:requestMailList()
    self.instance:loginEnd()
    self.arena:requestSelfInfo()
    self.welfareInstance:welfareInfoRequets()
    self.invasion:loginEnd()
    self.friend:loginEnd()
    self.archaeology:loginEnd()
    self.sunWar:loginEnd()
    self.rewardRecover:loginEnd()
    self.robot:loginEnd()
    self.gemstone:getGemstoneRequest()
    self.silverMine:loginEnd()
    self.plunder:loginEnd()
    self.daily:loginEnd()
    self.nightmare:loginEnd()
    self.tower:loginEnd()
    self.activityRounds:loginEnd()
    self.activityMonthFund:loginEnd()
    self.stormArena:loginEnd()
    self.mount:loginEnd()
    self.worldBoss:loginEnd()
    self.blackrock:loginEnd()
    self.union:loginEnd()
    self.redPoint:loginEnd()
    self.artifact:loginEnd()
    self.maritime:loginEnd()
    self.calendar:loginEnd()
    self.dragonTotem:loginEnd()
    self.dragon:loginEnd()
    self.consortiaWar:loginEnd()
    self.unionDragonWar:loginEnd()
    self.sanctuary:loginEnd()
    self.sotoTeam:loginEnd()
    self.secretary:loginEnd()
    self.question:loginEnd()
    self.sparField:loginEnd()
    self.spar:loginEnd()
    self.soulTrial:loginEnd()
    self.payFeedback:loginEnd()
    self.celebrityHallRank:loginEnd()
    self.metalCity:loginEnd()
    self.monthSignIn:loginEnd()
    self.fightClub:loginEnd()
    self.mockbattle:loginEnd()
    self.recycle:loginEnd()
    self.totemChallenge:loginEnd()
    self.godarm:loginEnd()
    self.fashion:loginEnd()
    self.offerreward:loginEnd()
    self.soultower:loginEnd()
    self.growthFund:loginEnd()
    self.silvesArena:loginEnd()
    self.achievementCollege:loginEnd()
    self.shareSDK:loginEnd()
    self.metalAbyss:loginEnd()

end

--设置销毁
function QRemote:disappear()
    self.instance:disappear()
    self.crystal:disappear()
    self.collegetrain:disappear()
    self.activityInstance:disappear()
    self.herosUtil:disappear()
    self.teamManager:disappear()
    self.items:disappear()
    self.tops:disappear()
    self.flag:disappear()
    self.task:disappear()
    self.achieve:disappear()
    self.user:disappear()
    self.stores:disappear()
    self.daily:disappear()
    self.mails:disappear()
    self.arena:disappear()
    -- self.sunWell:disappear()
    self.activity:disappear()
    self.activityRounds:disappear()
    self.activityMonthFund:disappear()
    self.tower:disappear()
    self.friend:disappear()
    self.welfareInstance:disappear()
    self.archaeology:disappear()
    self.sunWar:disappear()
    self.rewardRecover:disappear()
    self.robot:disappear()
    self.gemstone:disappear()
    self.silverMine:disappear()
    self.plunder:disappear()
    self.exchangeShop:disappear()
    self.nightmare:disappear()
    self.stormArena:disappear()
    self.mount:disappear()
    self.redTips:disappear()
    self.worldBoss:disappear()
    self.blackrock:disappear()
    self.union:disappear()
    self.redPoint:disappear()
    self.artifact:disappear()
    self.maritime:disappear()
    self.calendar:disappear()
    self.dragonTotem:disappear()
    self.dragon:disappear()
    self.question:disappear()
    self.consortiaWar:disappear()
    self.unionDragonWar:disappear()
    self.sanctuary:disappear()
    self.sotoTeam:disappear()
    self.secretary:disappear()
    self.sparField:disappear()
    self.spar:disappear()
    self.soulTrial:disappear()
    self.payFeedback:disappear()
    self.metalCity:disappear()
    self.monthSignIn:disappear()
    self.headProp:disappear()
    self.fightClub:disappear()
    self.monopoly:disappear()
    self.handBook:disappear()
    self.redpacket:disappear()
    self.heroSkin:disappear()
    self.activityCarnival:disappear()
    self.userComeBack:disappear()
    self.userDynamic:disappear()
    self.magicHerb:disappear()
    self.activityVipGift:disappear()
    self.bindingPhone:disappear()
    self.soulSpirit:disappear()
    self.gradePackage:disappear()
    self.playerRecall:disappear()
    self.strongerUtil:disappear()
    self.trailer:disappear()
    self.rank:disappear()
    self.mockbattle:disappear()
    self.recycle:disappear()
    self.totemChallenge:disappear()
    self.godarm:disappear() 
    self.fashion:disappear()
    self.offerreward:didappear()
    self.soultower:disappear()
    self.growthFund:disappear()
    self.silvesArena:disappear()
    self.achievementCollege:disappear()
    self.shareSDK:disappear()
    self.metalAbyss:disappear()
    
end

function QRemote:updateData(data)
    --记录登录的用户数据到本地
    if data.api == "USER_LOGIN" or data.api == "DLDL_USER_LOGIN" then
        app:getUserData():setUserName(remote.user.userId)
        QUtility:setUserId(remote.user.userId)
    end

    -------------------------------推送数据-----------------------------
    if data.sendMarkResponse ~= nil then
        self.mark:analysisMark(data.sendMarkResponse.mark)
    end

    if data.sendRemoveActivityResponse ~= nil then
        self.activity:removeActivity(data.sendRemoveActivityResponse.activityIds)
    end

    if data.tokenChangeResponse ~= nil then
        self.user:updateTokenChange(data.tokenChangeResponse)
    end
    
    if data.intrusionChangeResponse ~= nil then
        self.invasion:pushInvasion(data.intrusionChangeResponse)
    end

    if data.sendBlackRockInviteResponse ~= nil then
        self.blackrock:sendBlacRockInvite(data.sendBlackRockInviteResponse)
    end

    if data.silvesArenaSendInviteResponse ~= nil then
        self.silvesArena:sendSilvesArenaInvite(data.silvesArenaSendInviteResponse)
    end

    if data.sendBlackRockInviteRejectResponse ~= nil then
        self.blackrock:sendBlacRockInviteReject(data.sendBlackRockInviteRejectResponse)
    end

    if data.sendIntrusionAwardMarkResponse ~= nil then
        self.invasion:setKillAwardTipState(true)
    end

    if data.sendGroupBuyingChangeResponse ~= nil then
        self.activityRounds:dispatchEvent({name = self.activityRounds.GROUPBUY_GOODSCHANGE})
    end

    if data.sendRushBuyChangeResponse ~= nil then
        self.activityRounds:dispatchEvent({name = self.activityRounds.RUSHBUY_CHANGE})
    end

    ------------------------------推送结束-------------------------------

    --物品数据更新
    if data.items then
        self.items:setItems(data.items, data.api)
    end
    
    --用户信息更新
    if self.user.level ~= nil and data.level ~= nil and self.user.level ~= data.level then
        self.oldUser = {level = self.user.level, exp = self.user.exp}
    end

    if self.user:update(data) == true then
        self:dispatchEvent({name = QRemote.USER_UPDATE_EVENT})
    end

    if data.api == "USER_LOGIN" or data.api == "DLDL_USER_LOGIN" then
        app:getUserData():setUserName(remote.user.userId)
        QUtility:setUserId(remote.user.userId)
    end

    --考古学数据更新 要在魂师之前
    if data.apiArchaeologyInfoResponse ~= nil and data.apiArchaeologyInfoResponse.archaeologyInfo ~= nil then
        local id = data.apiArchaeologyInfoResponse.archaeologyInfo.last_enable_fragment_id
        self.user:update({ArchaeologyId = id})
        self.archaeology:setLastEnableFragmentID(id)
    end
    if data.apiArchaeologyEnableResponse ~= nil and data.apiArchaeologyEnableResponse.archaeologyInfo ~= nil then
        local id = data.apiArchaeologyEnableResponse.archaeologyInfo.last_enable_fragment_id
        self.user:update({ArchaeologyId = id})
        self.archaeology:setLastEnableFragmentID(id)
    end

    if data.serverInfos then
        self.serverInfos = data.serverInfos
    end

    -- 后台量表版本（产生时间）
    if data.dic_version then
        self.dic_version = data.dic_version
    end

    -- 服务器返回版本，需要检查本地是否一致，否则强行登出
    if data.staticVersion then
        if ENABLE_VERSION_CHECK and app.packageVersion and app.packageVersion ~= data.staticVersion then
            QLogFile:error(function ( ... )
                return string.format("Version incompatible -- client: %s, server: %s", app.packageVersion, data.staticVersion)
            end)

            app:alert({content = "魂师大人，检测到有新的内容更新，请您退出游戏重新进入哦~", title = "系统提示", 
                    callback = function(state)
                        if state == ALERT_TYPE.CONFIRM then
                            app:relaunchGame(true)
                        end
                    end, isAnimation = false}, true, true)          
        end
    end

    --更新副本的星星宝箱数据
    if data.mapStars then
        self.instance:updateDropBoxInfoById(data.mapStars)
    end
    
    --副本数据更新
    if data.dungeons then
        self.instance:updateInstanceInfo(data.dungeons)
        self.welfareInstance:updateInstanceInfo(data.dungeons)
        self.nightmare:updateInstanceInfo()
        self:dispatchEvent({name = QRemote.DUNGEON_UPDATE_EVENT})
        printInfo("self:dispatchEvent({name = QRemote.DUNGEON_UPDATE_EVENT})")

        if self.activityInstance:updateActivityInfo(data.dungeons) == true then
            self:dispatchEvent({name = QRemote.ACTIVITY_DUNGEON_UPDATE_EVENT})
            printInfo("self:dispatchEvent({name = QRemote.ACTIVITY_DUNGEON_UPDATE_EVENT})")
        end
    end

    -- 邮件
    if data.newMailResponse then
        if self.mails:updateMail(data.newMailResponse) then
            self.mails:dispatchEvent({name = self.mails.MAILS_UPDATE_EVENT})
        end
    end

    --全队属性的体技
    --printInfo(" ~~~~~~~~~~~~~~ data.heroTeamGlyphs == %s ~~~~~~~~~~~~~~~~~~", data.heroTeamGlyphs)
    if data.heroTeamGlyphs then
        self.herosUtil:updateGlyphTeamInfo(data.heroTeamGlyphs)
    end

    -- 魂师数据更新
    --[[
        魂师数据更新
        heros 更新魂师数据
        addHeros 增加魂师
        deleteHeroActorIds 删除魂师
        heroForceModifies 魂师战力数据
    ]]
    if data.heros or data.addHeros or data.deleteHeroActorIds or data.heroForceModifies then
        if data.heros then
            local heros = {}
            for _,value in pairs(data.heros) do
                heros[value.actorId] = value
            end
            self.herosUtil:updateHeros(heros, data.api ~= nil)
        end
        if data.deleteHeroActorIds then
            local deletedHeroIds = {}
            for k, v in ipairs(data.deleteHeroActorIds) do
                deletedHeroIds[v] = v
            end
            self.herosUtil:removeHeroes(deletedHeroIds)
        end
        if data.heroForceModifies then
            self.herosUtil:updateHerosForce(data.heroForceModifies)
        end
        self:dispatchEvent({name = QRemote.HERO_UPDATE_EVENT})
        printInfo("self:dispatchEvent({name = QRemote.HERO_UPDATE_EVENT})")
    end

    -- 魂力试炼
    if data.soulTrial and data.soulTrial > 0 then
        self.herosUtil:addSoulTrialProp()
        -- 這裡在登入的時候，由於Qtrail本身還沒註冊對應的事件，所以這裡update實際不起作用，這裡是針對遊戲中的點亮行為
        -- 為什麼寫在這裡，是因為，魂力試煉的點亮，不僅僅是api請求，還有戰鬥結束的進階
        app.taskEvent:updateTaskEventProgress(app.taskEvent.SOULTRIAL_ACTIVE_EVENT, 1, false, false, {compareNum = data.soulTrial})
    end

    -- 魂灵秘术
    if data.userSoulSpiritOccultResponse then
        self.soulSpirit:updateSoulSpiritOccult(data.userSoulSpiritOccultResponse)
    end

    --战队数据更新
    if data.fomation then
        remote.teamManager:setInitTeamData(remote.teamManager.INSTANCE_TEAM, data.fomation)
    end

    --宝石数据更新
    if data.gemstones then
        self.gemstone:setGemstones(data.gemstones)
    end

    --仙品数据更新
    if data.magicHerbs then
        self.magicHerb:setMagicHerbs(data.magicHerbs)
    end

    --魂灵数据更新
    if data.soulSpirit then
        self.soulSpirit:updateSoulSpirit(data.soulSpirit)
    end

    if data.zuoqiUpdateResponse then
        self.mount:responseHandler(data)
    end

    --魂灵历史数据更新
    if data.soulSpiritHistory then
        self.soulSpirit:updateSoulSpiritHistory(data.soulSpiritHistory)
    end

    --魂灵图鉴数据更新
    if data.soulSpiritCollectInfo then
        self.soulSpirit:updateSoulSpiritHandBook(data.soulSpiritCollectInfo)
    end

    --神器数据更新
    if data.godArmList then
        self.godarm:updateGodarmList(data.godArmList)
    end
    --魂灵升级道具的消耗更新
    if data.soulSpiritLevelUpConsume then
        self.soulSpirit:updateSoulSpiritLevelUpConsume(data.soulSpiritLevelUpConsume)
    end

    --魂灵传承道具的消耗更新
    if data.soulSpiritDevourConsume then
        self.soulSpirit:updateSoulSpiritDevourConsume(data.soulSpiritDevourConsume)
    end

    --任务更新
    if data.dailyTaskCompleted then
        self.task:updateComplete(data.dailyTaskCompleted)
        self:dispatchEvent({name = QRemote.TASK_UPDATE_EVENT})
        printInfo("self:dispatchEvent({name = QRemote.TASK_UPDATE_EVENT})")
    end
    --周常任务更新
    if data.userWeekTaskInfo then
        self.task:updateUserWeekTaskInfo(data.userWeekTaskInfo)
        self:dispatchEvent({name = QRemote.TASK_UPDATE_EVENT})
        printInfo("self:dispatchEvent({name = QRemote.TASK_UPDATE_EVENT}) -- weekly")
    end
    --成就更新
    if data.achievements then
        self.achieve:updateComplete(data.achievements)
    end
    if data.missedAchievements then
        self.achieve:setMissedAchievements(data.missedAchievements)
    end
    if data.dailyTask and data.dailyTask.achievements then
        self.achieve:updateComplete(data.dailyTask.achievements)
    end
    if data.dailyTask and data.dailyTask.missedAchievements then
        self.achieve:setMissedAchievements(data.dailyTask.missedAchievements)
    end

    --新功能预告
    if data.userLevelGoals then
        self.trailer:updateData(data.userLevelGoals)
    end
    
    --商店更新
    if data.shops then
        self.stores:updateComplete(data.shops)
        self:dispatchEvent({name = QRemote.STORES_UPDATE_EVENT})
        printInfo("self:dispatchEvent({name = QRemote.STORES_UPDATE_EVENT})")
    end
    if data.exchangeShops then
        self.exchangeShop:updateShopInfo(data.exchangeShops)
    end
    
    if data.checkin then
        self.daily:updateComplete(data.checkin, data.checkinAt, data.checkinTimesRes)
        printInfo("self:dispatchEvent({name = QRemote.DAILYSIGN_UPDATE_EVENT})")
    end
    
    if data.addupCheckinAward or data.addupCheckinCount then
        self.daily:updateAddUpSignInNum(data.addupCheckinCount, data.addupCheckinAward)
        printInfo("self:dispatchEvent({name = QRemote.ADDUP_DAILYSIGN_UPDATE_EVENT})")
    end

    --太阳井关卡信息
    -- if data.sunwellDungeons then
    --     self.sunWell:setInstanceInfo(data.sunwellDungeons)
    -- end

    -- if data.selfSunwellHeros then
    --     self.sunWell:updateHeroInfo(data.selfSunwellHeros)
    -- end

    -- if data.sunwellResetAt ~= nil or data.sunwellResetCount ~= nil then
    --     self.sunWell:updateCount(data.sunwellResetCount, data.sunwellResetAt)
    -- end

    -- if data.sunwellLastFightDungeonIndex ~= nil then
    --     self.sunWell:setNeedPass(data.sunwellLastFightDungeonIndex + 1)
    -- end

    -- if data.sunwellLuckydrawCompletedIndex ~= nil then
    --     self.sunWell:setSunwellLuckyDraw(data.sunwellLuckydrawCompletedIndex)
    -- end

    -- if data.sunwellStarRewardInfo ~= nil then
    --     self.sunWell:setStarRewardInfo(data.sunwellStarRewardInfo)
    -- end

    -- if data.sunwellHistoryHighestStarCount ~= nil then
    --     self.sunWell:setHistoryHighestStarCount(data.sunwellHistoryHighestStarCount)
    -- end

    --活动面板更新
    if data.activities ~= nil then
        self.activity:setData(data.activities)
    end
    if data.is8To14DayActivityOpen then
        self.activity.is8To14DayActivityOpen = data.is8To14DayActivityOpen
    end
    
    if data.jubaoInfo ~= nil then
        self.activity:setOtherData(remote.activity.TYPE_ACTIVITY_FOR_TIGER, data.jubaoInfo)
    end

    if data.activityTargetRecordTotalStatus ~= nil then
        self.activity:setHalfActivity(data.activityTargetRecordTotalStatus)
    end

    -- 新首充
    if data.firstRechargeReward then
        self.firstRecharge.firstRechargeReward = data.firstRechargeReward
    end

    --好友信息更新
    if data.friendCtlInfo ~= nil then
        self.friend:updateFriendCtlInfo(data.friendCtlInfo)
    end
    if data.friendChangeResponse ~= nil then
        self.friend:friendChangeResponse(data.friendChangeResponse)
    end

    -- 魂师大赛结算
    if data.towerAvatarAccountFloor ~= nil then
        self.user:update({towerAvatarAccountFloor = data.towerAvatarAccountFloor})
        self:dispatchEvent({name = QRemote.GLORY_TOWER_LAST_FLOOR, rank = data.towerAvatarAccountFloor})
    end
    -- 魂师大赛结算
    if data.gloryCompetitionWeekRank ~= nil then
        self:dispatchEvent({name = QRemote.GLORY_TOWER_TITLE_REFRESH, rank = data.gloryCompetitionWeekRank})
    end

    -- -- 累计登录天数
    -- if data.loginDaysCount then
    --     self.loginDaysCount = data.loginDaysCount
    -- end

    --跟新 成员等级
    if data.consortiaChangeResponse then
        self.union:handleUnionPush(data.consortiaChangeResponse)
    end

    if data.consortia and data.consortia.level and table.nums(data.consortia) == 1 then
        -- 登入的时候，拿下宗门等级，登入的时候，data.consortia这个结构体里只有level一个数据
        self.union:unionResponse(data, function() end)
    end

    -- 小红点
    if data.marks then
        self.mark:analysisMarks(data.marks) 
    end

    -- 公告
    if data.notices then
        app.notice:updateNoticeList(data.notices)
    end
    
    --
    if data.directionalInfos then
        self.activityRounds:setActivitysInfoByLogin(data.directionalInfos)
    end

    -- if data.userLuckyDrawDirectionalInfo then
    --     self.activityRounds:updateSelfInfo(data.userLuckyDrawDirectionalInfo)
    -- end

    if data.luckyDrawDirectionalChangeResponse then
        self.activityRounds:handleNotify(data.luckyDrawDirectionalChangeResponse)
    end

    if data.prizeWheelMoneyGot then
        local prizeWheelRound = self.activityRounds:getPrizaWheel()
        if prizeWheelRound then
            prizeWheelRound:addPrizeWheelMoney(data.prizeWheelMoneyGot)
        end
    end

    if data.silverMineEventPushResponse then
        self.silverMine:pushHandler(data.silverMineEventPushResponse)
    end

    --魂师大赛 争霸赛
    if data.api == "SEND_GLORY_COMPETITION_INVITE" and data.gloryCompetitionInviteResponse then
        self.tower:handleYaoqingNotify(data.gloryCompetitionInviteResponse)
    end

    if data.api == "SEND_MONTH_FUND_CHANGE" then
        if data.sendMonthFundChangeResponse and data.sendMonthFundChangeResponse.monthFundInfo then
            self.activityMonthFund:updateMonthFundDataInfo(data.sendMonthFundChangeResponse.monthFundInfo)
        end
    end
    -- 周基金激活
    if data.api == "SEND_WEEK_FUND_ACTIVATE" then
        local weekFund = self.activityRounds:getWeekFund()
        if weekFund then
            weekFund:setWeekFundInfo(data)
        end
    end
    -- 新服基金激活
    if data.api == "SEND_NEW_WEEK_FUND_ACTIVATE" then
        local newServiceFund = self.activityRounds:getNewServiceFund()
        if newServiceFund then
            newServiceFund:setWeekFundInfo(data)
            newServiceFund:createAlarmClock()
        end
    end
    if data.api == "NEW_SERVER_RECHARGE_INFO_PUSH" then
        local newServerRechargeFund = self.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.NEW_SERVER_RECHARGE)
        if newServerRechargeFund then
            newServerRechargeFund:updateSvrData(data)
        end
    end



    --动态推荐
    if data.api == "SEND_USER_DYNSMIC" and data.dynamicInfo then
        self.userDynamic:sendUserDynamicMessage(data.dynamicInfo[1])
    end

    if data.pushMessageResponse and data.pushMessageResponse.messages then
        for _, value in pairs(data.pushMessageResponse.messages) do
            if value.messageType == "WORLD_BOSS_NEW_HP" then
                self.worldBoss:receiveServerSendBossInfo(value)
            elseif value.messageType == "BLACK_ROCK_MEMBER_CHAT" then
                app:getServerChatData():onNewTeamMessageReceived(value)
            elseif value.messageType == "BLACK_ROCK_MEMBER_CHAT_NOTICE" then
                app:getServerChatData():onNewTeamMessageReceived(value)
            elseif value.messageType == "MARITIME_SHIP_LOOTED" then
                self.maritime:updateReplayTip(true)
            elseif value.messageType == "MARITIME_ESCORT_FIGHT_FAIL" then
                self.maritime:updateProjectReplayTip(true)
            elseif value.messageType == "SILVER_MINE_INVITE_ASSIST" then
                self.silverMine:silvermineGetMyInfoRequest()
            elseif value.messageType == "CELEBRITY_HALL_TOP_RANK_INFO" then
                self.user.celebrityHallTopRank = value.params
            elseif value.messageType == "FIGHT_CLUB_RANK_CHANGE" then
                self.fightClub:requestFightClubInfo()
            elseif value.messageType == "FIGHT_CLUB_BE_ATTACK" then
                self.fightClub:fightClubBeAttack()
            elseif value.messageType == "KUAFU_MINE_CAVE_BE_ATTACK" then
                self.plunder:pushHandler(value)
            elseif value.messageType == "STORM_BE_ATTACK" then
                self.stormArena:setStormArenaRecordTip(true, true)
            elseif value.messageType == "DRAGON_WAR_DO_HURT" then
                self.unionDragonWar:setDragonHurtInfo(value)
            elseif value.messageType == "COMMON_POP_UP_MESSAGE" then
                app:alert({btns = {ALERT_BTN.BTN_OK}, lineWidth = 400, fontSize = 22, colorful = true, autoCenter = false, 
                    content = value.params or "", title = "系统提示"}, true, true)          
            end
            local callbacks = self._pushCallBack[value.messageType]
            if callbacks ~= nil then
                for _,v in ipairs(callbacks) do
                    v.method(v.obj, value)
                end
            end
        end
    end

    -- 玩家福利追回功能
    if data.playerRecoverInfo then
        if data.dailyTeamLevel then
            self.rewardRecover:saveDailyTeamLevel(data.dailyTeamLevel)
        end
        self.rewardRecover:savePlayerRecoverInfo(data.playerRecoverInfo)
    end

    -- 老玩家追回
    if data.userComeBackInfo then
        self.userComeBack:setInfo(data.userComeBackInfo)
    end

    -- 老玩家回归老服版
    if (data.api == "USER_LOGIN" or data.api == "USER_QUICK_LOGIN") and data.playerComeBackUserInfoResponse and data.playerComeBackUserInfoResponse.userInfo then
        self.playerRecall:setInfo(data.playerComeBackUserInfoResponse.userInfo)
    elseif data.playerComeBackUserInfoResponse and data.playerComeBackUserInfoResponse.userInfo then
        self.playerRecall:updateInfo(data.playerComeBackUserInfoResponse.userInfo)
    end

    if data.api == "DO_RECHARGE_TOKEN" and data.error == "NO_ERROR" and remote.playerRecall:isOpen() then
        self.playerRecall:playerComeBackGetInfoRequest()
    end

    --从其他途径获得的晶石
    if data.spars then
        self.spar:setSpars(data.spars)
    end

    --金属之城登录信息
    if data.userMetalCity then
        self.metalCity:updateMetalServerInfo({userMetalCity = data.userMetalCity})
    end

    --金属之城登录信息
    if data.activityQuestion then
        self.activity:setQuestionnaire(data.activityQuestion)
    end

    -- 头像框解锁更新
    if data.api == "SEND_USERTITLE_CHANGE" then
        self.headProp:requestHeadList()
    end

    -- 等级礼包开启更新
    if data.api == "SEND_USER_LEVEL_REWARD_CHANGE" then
        self.gradePackage:setUserGradePackageInfo(data.userLevelRewards)
    end
    --皮肤开启
    if data.heroSkins then
        self.heroSkin:setActivationHeroSkins(data.heroSkins)
        self.fashion:setActivityHeroSkins(data.heroSkins)
    end

    --時裝
    if data.skinWardrobeIds or data.skinPictureIds then
        self.fashion:setActivityInfo(data)
    end

    --排行榜奖励推送
    if data.api == "SEND_SERVER_GOAL_COMPLETE" and data.serverGoalUserInfo then
        self.rank:serverSendRankAwardInfo(data.serverGoalUserInfo)
    end

    --新魂师图鉴
    if data.heroHandbookResponse and data.heroHandbookResponse.heroHandbookList then
        self.handBook:updateHeroHandbookList(data.heroHandbookResponse.heroHandbookList)
    end
    if data.handbookEpicPoint then
        self.handBook.handbookEpicPoint = data.handbookEpicPoint
    end

    if data.receivedCdk then
        self.user:update({receivedCdk = data.receivedCdk})
    end

    -- 月卡补领
    if data.monthCardSupplementResponse then
        self.user:update({monthCardSupplementResponse = data.monthCardSupplementResponse})
    end
end

--注册推送的callback
function QRemote:registerPushMessage(messageType, obj, method)
    if self._pushCallBack[messageType] == nil then
        self._pushCallBack[messageType] = {}
    end
    table.insert(self._pushCallBack[messageType], {obj = obj, method = method})
end

--删除推送的callback
function QRemote:removePushMessage(messageType, obj, method)
    if self._pushCallBack[messageType] ~= nil then
        for index,v in ipairs(self._pushCallBack[messageType]) do
            if v.obj == obj and v.method == method then
                table.remove(self._pushCallBack[messageType], index)
                break
            end
        end
    end
end

--[[
    刷新时间
]]
function QRemote:refreshUserTime(serverTime)
    if serverTime ~= nil then
        self.user:serverTimeUpdate(serverTime)
    end
end

function QRemote:dispatchUpdateEvent()
    self:dispatchEvent({name = QRemote.USER_UPDATE_EVENT})
end

function QRemote:updateServerTime(time, sendTime)
    time = time/1000
    local currTime = QUtility:getTime()
    local isPatch = false
    if self.serverTime == nil then
        self.serverTime = time
        self.serverResTime = currTime
        isPatch = true
    elseif math.abs(q.serverTime() - time) > 5 then
        if DEBUG > 0 then
            local timeOffset = q.serverTime() - time
            if timeOffset > 0 then
                timeOffset = math.abs(timeOffset)
                app.tip:floatTip("时间往后调整至".. q.timeToHourMinuteSecond(timeOffset))
            elseif timeOffset < 0 then
                timeOffset = math.abs(timeOffset)
                app.tip:floatTip("时间往前调整至".. q.timeToHourMinuteSecond(timeOffset))
            end
        end
        self.serverTime = time
        self.serverResTime = currTime
    elseif sendTime ~= nil and (currTime - sendTime) < 0.5 then
        self.serverTime = time
        self.serverResTime = currTime
    end
    if isPatch == true then
        self:dispatchEvent({name = QRemote.TIME_UPDATE_EVENT})
    end
end

-- a,b 指 a <= x <= b
-- a,  指 a <= x
-- ,b  指 x <= b
function QRemote:checkOpenServerDays(beginDay, endDay, beginHour)
    if remote.user.openServerTime ~= nil and remote.user.openServerTime > 0 then
        local beginDate = q.date("*t", (remote.user.openServerTime or 0) /1000)
        beginDate.hour = beginHour or 0
        beginDate.min = 0
        beginDate.sec = 0

        local beginTime = 0
        local endTime = 0
        local nowTime = q.serverTime()

        -- 是否设置起始开服天数
        if beginDay == nil or beginDay <= 0 then
            beginTime = q.OSTime(beginDate)
        else
            beginTime = q.OSTime(beginDate) + (beginDay - 1) * DAY
        end

        -- 是否设置结束开服天数
        if endDay == nil or endDay <= 0 then
            endTime = nowTime + 1
        else
            endTime = beginTime + endDay * DAY
        end

        if beginTime < nowTime and nowTime < endTime then
            return true
        end
        return false
    end

    return true
end

function QRemote:updateNotifiCationSystemSetting( key, value )
    -- body
    local isFind = false
    for k, v in pairs(self.notificationSetting) do
        if v.key == key then
            v.value = value
            isFind = true
            break;
        end
    end
    if not isFind then
        table.insert( self.notificationSetting , {key = key, value = value} )
    end
    
end

function QRemote:getNotifiCationSystemSetting( key )
    -- body
    for k, v in pairs(self.notificationSetting) do
        if v.key == key then
            return v.value
        end
    end
end

function QRemote:triggerBeforeStartGameBuriedPoint(id)
    if id == nil then
        return
    end
    print("triggerBeforeStartGameBuriedPoint", id)

    if self._maxBuriedPoints == nil then
        self._maxBuriedPoints = app:getUserData():getValueForKey("MAX_BURIED_POINT", tonumber(id)) or 0
    end

    -- to implement
    if tonumber(id) and tonumber(self._maxBuriedPoints) < tonumber(id) then 
        local opgameId = app:getOpgameID()
        local opId = FinalSDK.getChannelID()
        local deviceId = FinalSDK.getDeviceUUID() and FinalSDK.getDeviceUUID() or ""
        local actionId = id
        local time = q.serverTime()
        local verify = crypto.md5(opgameId..opId..deviceId..actionId..time.."1GQPp0RAQNKNVGa7QvQQ")

        local param = string.format("/device_rcd?opgameId=%s&opId=%s&deviceId=%s&actionId=%s&time=%s&verify=%s", opgameId, opId, deviceId, actionId, time, verify)
        if POINT_URL then
            local pointRequest = nil
            local responseFunc = function(event)
                local ok = (event.name == "completed")
                local request = event.request
                
                if not ok then
                    -- 请求失败，显示错误代码和错误消息
                    QLogFile:debug(function ( ... )
                        return string.format("Trigger Buried Point %s is Fialed !, Erroe code: %s, Erroe message: %s", id, request:getErrorCode(), request:getErrorMessage())
                    end)
                else
                    local code = request:getResponseStatusCode()
                    if code ~= 200 then
                        print(code)
                    else
                        -- 请求成功，显示服务端返回的内容
                        local response = request:getResponseString()
                        QLogFile:info(function ( ... )
                            return string.format("Trigger Buried Point %s is Success ! response: %s", id, response)
                        end)

                        self._maxBuriedPoints = tonumber(id)
                        app:getUserData():setValueForKey("MAX_BURIED_POINT", tonumber(id))
        
                    end
                end
                request:release()
            end
            local url = POINT_URL..param
            print(url)
            pointRequest = network.createHTTPRequest(responseFunc, url, "GET")
            pointRequest:setTimeout(1)
            pointRequest:retain()
            pointRequest:start()
        end
    end
end

return QRemote
