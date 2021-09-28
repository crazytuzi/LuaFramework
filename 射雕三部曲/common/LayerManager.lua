--[[
    文件名：LayerManager.lua
    描述：Layer切换管理类
    创建人：liaoyuangang
    创建时间：2016.3.30
-- ]]

LayerManager = {layerStack={}, accCount=0, bgMusicInfo = {}, curMusicItem = nil}

-- 提示信息对象
FlashHintObj = nil
-- 语音消息任务对象
VoiceMsgTaskObj = nil
-- 聊天消息任务对象
ChatMsgHintObj = nil

local sharedDirector = cc.Director:getInstance()

-- 是否只能做栈底layer，当打开这些layer时，需要清空 layerStack 数据
local function isRootLayer(layerName)
    if not layerName then
        return false
    end
    local rootLayerNames = {
        ["home.HomeLayer"] = true,  -- 游戏大厅页面
        ["team.TeamLayer"] = true, -- 队伍页面
        ["battle.BattleMainLayer"] = true, -- 副本页面
        ["challenge.ChallengeLayer"] = true, -- 挑战页面
        ["practice.PracticeLayer"] = true, -- 修炼页面
        ["login.StartGameLayer"] = true, -- 游戏开始页面
        ["login.GameLoginLayer"] = true, -- 账户登录页面
    }
    return rootLayerNames[layerName] or false
end

-- 获取承载layer的场景对象
local function getMainScene(layerName)
    local currScene = sharedDirector:getRunningScene()
    if not currScene then  -- 如果Scene不是 MainScene ，则需要创建该Scene
        currScene = require("MainScene").new()
        sharedDirector:runWithScene(currScene)
    elseif currScene.__cname ~= "MainScene" or
        currScene.__cname == "MainScene" and (layerName == "login.GameLoginLayer" or layerName == "login.StartGameLayer") then
        currScene = require("MainScene").new()
        sharedDirector:replaceScene(currScene)
    end

    -- 添加常驻飘窗提示界面(需要时显示)
    if not currScene.flashHintLayer or tolua.isnull(currScene.flashHintLayer) then
        FlashHintObj = require("commonLayer.FlashHintLayer").new()
        currScene:addChild(FlashHintObj, 1024)
        currScene.flashHintLayer = FlashHintObj
    end

    -- 检查并创建语音消息任务对象
    if not currScene.voiceMsgTaskObj or tolua.isnull(currScene.voiceMsgTaskObj) then
        VoiceMsgTaskObj = require("Chat.chatSubView.VoiceMsgTaskView"):create()
        currScene:addChild(VoiceMsgTaskObj)
        currScene.voiceMsgTaskObj = VoiceMsgTaskObj
    end

    -- 检查并创建语音消息任务对象
    if not currScene.ChatMsgHintObj or tolua.isnull(currScene.ChatMsgHintObj) then
        ChatMsgHintObj = require("Chat.ChatHintLayer"):create()
        currScene:addChild(ChatMsgHintObj, 1024)
        currScene.ChatMsgHintObj = ChatMsgHintObj
    end

    -- 添加走马灯界面并设置为最高
    local msgLayer = currScene.marqueeMessageLayer
    if Player.mIsLogin then  -- 玩家已登录
        if not msgLayer or tolua.isnull(msgLayer) then
            local tempLayer = require("commonLayer.MarqueeMsgLayer").new()
            currScene:addChild(tempLayer, Enums.ZOrderType.eNetErrorMsg)

            currScene.marqueeMessageLayer = tempLayer
        end
    else
        if not tolua.isnull(msgLayer) then
            msgLayer:removeFromParent()
            currScene.marqueeMessageLayer = nil
        end
    end

    return currScene
end
LayerManager.getMainScene = getMainScene

LayerManager.bgMusicInfo = {
    ["star"] = {  -- 登录界面音乐
        musicList = {"loginmusic.mp3"}, -- 循环播放列表
        needLoop = true, -- 是否需要循环
    },
    ["battle"] = { -- 战斗中播放的背景音乐
        musicList = {"battle1.mp3", "battle2.mp3", "battle3.mp3", "battle4.mp3", "battle5.mp3"}, -- 循环播放列表
        needLoop = true, -- 是否需要循环
    },
    ["copy"] = { -- 江湖中播放的背景音乐
        musicList = {"jianghu1.mp3", "jianghu2.mp3",}, -- 循环播放列表
        needLoop = true, -- 是否需要循环
    },

    ["normal"] = {  -- 普通页面的背景音乐
        musicList = {"backgroundmusic1.mp3", "backgroundmusic2.mp3", "backgroundmusic3.mp3", "backgroundmusic4.mp3", "backgroundmusic5.mp3", "backgroundmusic6.mp3"}, -- 循环播放列表
        needLoop = true, -- 是否需要循环
    },
    ["special"] = {  -- 历炼页面的背景音乐
        musicList = {"xiangyang.mp3", "xiangyang1.mp3"}, -- 循环播放列表
        needLoop = true, -- 是否需要循环
    },
    ["pinJiu"] = {  -- 拼酒页面的背景音乐
        musicList = {"hejiu_huanjing.mp3",}, -- 循环播放列表
        needLoop = true, -- 是否需要循环
    },
    ["fightWin"] = {  -- 战斗胜利
        musicList = {"battlesuccess.mp3"}, -- 循环播放列表
        needLoop = false, -- 是否需要循环
    },
    ["fightFail"] = {  -- 战斗失败
        musicList = {"battlefail.mp3"}, -- 循环播放列表
        needLoop = false, -- 是否需要循环
    },
}

-- 切换页面时背景音乐切换
local function changeBgMusic(layerName, clearLayerName)
    local musicInfo = LayerManager.bgMusicInfo
    local musicItem
    if Player.mIsLogin then -- 玩家已登录
        local fightResultLayer = {  -- 战斗结算页面
            -- 战斗成功
            ["fightResult.PveWinLayer"] = true,
            ["fightResult.PvpWinLayer"] = true,

            -- 战斗失败
            ["fightResult.PveLoseLayer"] = true,
            ["fightResult.PvpLoseLayer"] = true,
        }

        local tempMap = {
            ["practice.LightenStarLayer"] = musicInfo.pinJiu,
            ["practice.PracticeLayer"] = musicInfo.special,

            -- 战斗场景背景音乐
            ["ComBattle.BattleLayer"] = musicInfo.battle,
            ["practice.BsxyGameLayer"] = musicInfo.battle,

            -- 江湖场景背景音乐
            ["battle.BattleMainLayer"] = musicInfo.copy,
            ["battle.BattleNormalNodeLayer"] = musicInfo.copy,
            ["battle.ConFightLayer"] = musicInfo.copy,

            -- 战斗成功
            ["fightResult.PveWinLayer"] = musicInfo.fightWin,
            ["fightResult.PvpWinLayer"] = musicInfo.fightWin,

            -- 战斗失败
            ["fightResult.PveLoseLayer"] = musicInfo.fightFail,
            ["fightResult.PvpLoseLayer"] = musicInfo.fightFail,

            -- 片头动画页面不需要背景音乐
            ["login.CgLayer"] = {},
        }

        local tempName = fightResultLayer[layerName] and layerName or clearLayerName
        musicItem = tempMap[layerName] or tempName and tempMap[tempName] or musicInfo.normal
    else
        musicItem = musicInfo.star
    end

    -- 没有找到最新的背景音乐信息，表示不改变当前的背景音乐
    if not musicItem or not musicItem.musicList then
        return
    end

    -- 如果上一次在该页面播放背景音乐是否和当前的背景音乐相同，则无需切换
    local curMusic = LayerManager.curMusicItem
    if curMusic and musicItem.musicList[1] == curMusic.musicList[1] then
        return
    end

    -- 循环该页面的下一首
    local listLen = #musicItem.musicList
    musicItem.playIndex = musicItem.playIndex or 0 -- 标识当前播放的序号
    musicItem.playIndex = (musicItem.playIndex >= listLen) and 1 or (musicItem.playIndex + 1)
    -- 不循环播放背景音乐，在Player定时器中下一曲
    MqAudio.playMusic(musicItem.musicList[musicItem.playIndex], not Player.mIsLogin)
    -- 保存当前的播放列表(引用，方便下一曲时修改index)
    LayerManager.curMusicItem = musicItem
end

-- 当前播放列表执行下一曲(在Player定时器中被调用)
function LayerManager.nextCurrentMusic()
    local musicItem = LayerManager.curMusicItem
    if not MqAudio.isMusicPlaying() and musicItem.needLoop then
        -- 播放列表中的下一首背景音乐
        musicItem.playIndex = (musicItem.playIndex >= #musicItem.musicList) and 1 or (musicItem.playIndex + 1)
        MqAudio.playMusic(musicItem.musicList[musicItem.playIndex], false)
    end
end

-- 显示Loading 页面
function LayerManager.showLoading()
    local currScene = getMainScene()
    if not tolua.isnull(currScene.loadingLayer) then
        currScene.loadingLayer:setVisible(true)
    else
        local tempLayer = require("commonLayer.WaitingLayer").new()
        currScene:addChild(tempLayer, Enums.ZOrderType.eWaiting)
        currScene.loadingLayer = tempLayer
    end
end

-- 隐藏Loading页面
function LayerManager.hideLoading()
    local currScene = getMainScene()
    if not tolua.isnull(currScene.loadingLayer) then
        currScene.loadingLayer:setVisible(false)
    end
end

--- 根据功能模块ID跳入相应的界面
--[[
-- 参数
    subModuleId: 模块ID, 在EnumsCoinfig.lua 文件的 ModuleSub 中定义
    data: 可选参数，需要传递给新layer的参数
    cleanUp: 可选参数，默认为true表示显示时需要清除其它界面，如弹窗类需要设置为false
    zOrder: 可选参数，默认为0
--]]
function LayerManager.showSubModule(subModuleId, data, cleanUp, zOrder)
    if not ModuleInfoObj:moduleIsOpenInServer(subModuleId) then
        ui.showFlashView({text = TR("暂未开放")})
        return
    end

    --判定该模块是否开启P
    if not ModuleInfoObj:moduleIsOpen(subModuleId, true) then
        return
    end

    data = data or {}
    local params = {
        data    = data,
        zOrder  = zOrder,
        cleanUp = cleanUp,
    }

    if subModuleId == ModuleSub.ePlayer then -- "玩家"(1000)
    elseif subModuleId == ModuleSub.eHero -- "人物"(1100)
        or subModuleId == ModuleSub.eBagHeroDebris then -- "人物碎片" (1302)
        local tempList = {
            [ModuleSub.eHero] = BagType.eHeroBag,
            [ModuleSub.eBagHeroDebris] = BagType.eHeroDebrisBag,
        }
        params.name = "bag.BagLayer"
        data.subPageType = BagType.eHeroBag -- 人物和碎片共用tag
    elseif subModuleId == ModuleSub.eBagFashionDebris then -- “时装碎片” (1305)

    elseif subModuleId == ModuleSub.eBag  -- "背包" (1300)
        or subModuleId == ModuleSub.eBagProps -- 道具 (1301)
        or subModuleId == ModuleSub.eBagTreasure -- "神兵背包" (1307)
        or subModuleId == ModuleSub.eBagFashionDebris -- "神兵背包" (1305)
        or subModuleId == ModuleSub.eBagPets then -- "外功背包"(1306)
        -- 模块与背包的映射表(道具背包)
        local tempList = {
            [ModuleSub.eBag] = BagType.eGoodsBag,
            [ModuleSub.eBagProps] = BagType.eGoodsBag,
            [ModuleSub.eBagTreasure] = BagType.eTreasureBag,
            [ModuleSub.eBagPets] = BagType.eZhenjue, -- 外功和内功tag共用
            [ModuleSub.eBagFashionDebris] = BagType.eZhenjue, -- 时装碎片和内功tag共用
        }
        params.name = "bag.BagLayer"
        data.subPageType = tempList[subModuleId] or BagType.eGoodsBag
    elseif subModuleId == ModuleSub.eEquip  -- "装备" (1400)
        or subModuleId == ModuleSub.eBagEquipDebris then -- "装备碎片"(1303)
        -- 模块与背包的映射表(装备背包)
        local tempList = {
            [ModuleSub.eEquip] = BagType.eEquipBag,
            [ModuleSub.eBagEquipDebris] = BagType.eEquipDebrisBag,
        }
        params.name = "bag.BagLayer"
        data.subPageType = BagType.eEquipBag -- 装备和碎片共用tag
        if subModuleId == ModuleSub.eBagEquipDebris then
            data.thirdSubTag = BagType.eEquipDebrisBag
        end     
    elseif subModuleId == ModuleSub.eHeroLvUp then -- "人物强化"(1101)
        params.name = "hero.HeroTrainingLayer"
        data.originalTag = ModuleSub.eHeroLvUp
    elseif subModuleId == ModuleSub.eHeroStepUp then -- "人物突破"(1102)
        params.name = "hero.HeroTrainingLayer"
        data.originalTag = ModuleSub.eHeroStepUp
    elseif subModuleId == ModuleSub.eIllusion then -- "人物幻化"(10200)
        params.name = "hero.HeroTrainingLayer"
        data.originalTag = ModuleSub.eIllusion
    elseif subModuleId == ModuleSub.eReborn then -- "人物经脉"(7700)
        params.name = "hero.HeroTrainingLayer"
        data.originalTag = ModuleSub.eReborn
    elseif subModuleId == ModuleSub.eHeroChoiceTalent then -- "人物天赋"(1103)
        params.name = "hero.HeroTrainingLayer"
        data.originalTag = ModuleSub.eHeroChoiceTalent
    elseif subModuleId == ModuleSub.eFashion then -- "人物绝学"(1103)
        params.name = "hero.HeroTrainingLayer"
        data.originalTag = ModuleSub.eFashion
    elseif subModuleId == ModuleSub.eHeroQuench then -- "人物淬体"(1104)
        params.name = "hero.HeroTrainingLayer"
        data.originalTag = ModuleSub.eHeroQuench
    elseif subModuleId == ModuleSub.eFormation then -- "阵容"(1200)
        params.name = "team.TeamLayer"
    elseif subModuleId == ModuleSub.eEquipLvUp -- "装备强化"(1401)
        or subModuleId == ModuleSub.eEquipStepUp -- "装备洗炼"(1403)
        or subModuleId == ModuleSub.eEquipStarUp then -- "装备升星"(1411)
        params.name = "team.TeamLayer"
    elseif subModuleId == ModuleSub.eTreasureLvUp  -- "神兵强化"(1402)
            or subModuleId == ModuleSub.eTreasureStepUp then -- "神兵精炼"(1404)
        params.name = "team.TeamLayer"
    elseif subModuleId == ModuleSub.eDisassemble then -- "炼化重生" (1500)
        params.name = "disassemble.DisassembleLayer"
    elseif subModuleId == ModuleSub.eHeroConversion then -- "大侠之魂转化" (1507)
        params.name = "disassemble.DisassembleLayer"
        data.currTag = Enums.DisassemblePageType.eConversion
    elseif subModuleId == ModuleSub.eSkill then -- = 1600,    -- "技能"
        -- Todo
    elseif subModuleId == ModuleSub.eFriend then -- "好友" (1700)
        params.name = "more.FriendLayer"
    elseif subModuleId == ModuleSub.eFriendRewardSTA then -- "领取耐力" (1701)
        params.name = "more.FriendLayer"
        data.pageType = FriendPageType.eGetSTA
    elseif subModuleId == ModuleSub.eChat then -- = 1800,    -- "聊天"
        -- Todo
    elseif subModuleId == ModuleSub.eEmail  -- "邮件" (1900)
        or subModuleId == ModuleSub.eEmailBattle -- "战斗邮件" (1901)
        or subModuleId == ModuleSub.eEmailFriend -- "好友邮件" (1902)
        or subModuleId == ModuleSub.eEmailSystem then -- "系统邮件" (1903)
        params.name = "more.MailLayer"
        local tempList = {
            [ModuleSub.eEmail] = ModuleSub.eEmailSystem,
        }
        data = tempList[subModuleId] or subModuleId
    elseif subModuleId == ModuleSub.eStore  -- "商城" (2000)
        or subModuleId == ModuleSub.eStoreProps -- "道具商城" (2002)
        or subModuleId == ModuleSub.eStoreGiftBag  -- "礼包商城" (2003)
        or subModuleId == ModuleSub.eRecruit -- "人物招募" (3800)
        or subModuleId == ModuleSub.eHeroRecruit then -- "人物召唤" (3801)
        params.name = "shop.ShopLayer"
        data.moduleSub = (subModuleId ~= ModuleSub.eStore and subModuleId ~= ModuleSub.eRecruit) and subModuleId or nil
    elseif subModuleId == ModuleSub.eMysteryShop then -- "神秘商店" (2100)
        params.name = "mysteryshop.MysteryShopLayer"
    elseif subModuleId == ModuleSub.eBattle or -- "出战" (2200)
        subModuleId == ModuleSub.eBattleNormal then -- "普通副本" (2201)
        params.name = "battle.BattleMainLayer"
    elseif subModuleId == ModuleSub.eBattleElite  then-- "挑战武林谱" (2202)
        params.data.subPageType = ModuleSub.eBattleElite
        params.name = "battle.BattleMainLayer"
     elseif subModuleId == ModuleSub.eBattleBoss then -- "行侠仗义" (2203)
        params.name = "challenge.BattleBossLayer"
    elseif subModuleId == ModuleSub.ePractice then -- "修行" (2300)
        params.name = "practice.PracticeLayer"
    elseif subModuleId == ModuleSub.eTeacher then -- "拜师学艺" (8200)
        params.name = "practice.BsxyLayer"
    elseif subModuleId == ModuleSub.ePracticeLightenStar then -- "仙脉" (2302)
        params.name = "practice.LightenStarLayer"
    elseif subModuleId == ModuleSub.ePracticeKiss then -- "聚灵阵" (2303)
        -- Todo
    elseif subModuleId == ModuleSub.ePracticeRefreshKissReward then -- "开启刷新校花之吻奖励" (2304)
        -- Todo
    elseif subModuleId == ModuleSub.ePracticeZB then -- "集魂" (2305)
        -- Todo
    elseif subModuleId == ModuleSub.ePracticeCallStar then -- "猎妖" (2306)
    elseif subModuleId == ModuleSub.eXXBZ then -- "保卫襄阳" (2317)
        params.name = "teambattle.TeambattleHomeLayer"
    elseif subModuleId == ModuleSub.eQuickExp then  -- "闯荡江湖" (2326)
        params.name = "quickExp.QuickExpLayer"
    elseif subModuleId == ModuleSub.ePracticeBloodyDemonDomain then -- "比武招亲" (2334)
        params.name = "challenge.BddLayer"
    elseif subModuleId == ModuleSub.eRewardCenter then -- "领奖中心" (2400)
        params.name = "more.RewardCenterLayer"
        params.cleanUp = false
    elseif subModuleId == ModuleSub.eChallenge then -- "挑战" (2500)
        params.name = "challenge.ChallengeLayer"
    elseif subModuleId == ModuleSub.eChallengeGrab then -- "寻宝" (2501)
        params.name = "challenge.ForgingMainLayer"
    elseif subModuleId == ModuleSub.eChallengeArena then -- "苍茫榜" (2502)
        params.name = "challenge.PvpLayer"
    elseif subModuleId == ModuleSub.eChallengeWrestle then -- "武林大会" (2503)
        params.name = "challenge.GDDHLayer"
    elseif subModuleId == ModuleSub.eXrxs then -- "血刃悬赏" (2515)
        params.name = "challenge.GGZJLayer"
    elseif subModuleId == ModuleSub.eOpenActivity  -- "成就奖励" (2600)
        or subModuleId == ModuleSub.eSuccessReward then -- "七日大奖" (4900)
        local hasDrawSuccessReward = PlayerAttrObj:getPlayerAttrByName("HasDrawSuccessReward")
        if hasDrawSuccessReward == 0 then
            params.name = "achievement.AchievementMainLayer"
        elseif hasDrawSuccessReward >= 1 then
            params.name = "achievement.SevenDayMainLayer"
        end
    elseif subModuleId == ModuleSub.eExtraActivity    -- "精彩活动" (2700)
        or subModuleId == ModuleSub.eExtraActivityRebate -- "好礼回馈页面" (2702)
        or subModuleId == ModuleSub.eExtraActivityGrowPlan -- "成长计划页面" (2703)
        or subModuleId == ModuleSub.eExtraActivityVIPWelfare -- "VIP福利页面" (2704)
        or subModuleId == ModuleSub.eExtraActivityDailyShare -- "每日分享页面" (2705)
        or subModuleId == ModuleSub.eExtraActivityDinner -- "体力便当页面" (2706)
        or subModuleId == ModuleSub.eExtraActivityLimitTime -- "限时招摹页面" (2707)
        or subModuleId == ModuleSub.eExtraActivityInviteFriend -- "好友邀请页面" (2708)
        or subModuleId == ModuleSub.eExtraActivityMonthCard -- "月卡" (2709)
        or subModuleId == ModuleSub.eExtraActivityDayDayFund -- "天天基金" (2710)
        or subModuleId == ModuleSub.eLuckySymbol -- "招财树" (2711)
        or subModuleId == ModuleSub.eMonthSign -- "月签到" (2712)
        -- or subModuleId == ModuleSub.eExtraActivityWeChat -- "微信关注" (2713)
        or subModuleId == ModuleSub.eDailyShareWX -- "每日分享页面_微信" (2714)
        or subModuleId == ModuleSub.eDailyShareWB then-- "每日分享页面_微博" (2715)
        --
        params.name = "activity.ActivityMainLayer"
        data.moduleId =  ModuleSub.eExtraActivity
        data.showSubModelId = (subModuleId ~= ModuleSub.eExtraActivity) and subModuleId or nil
    elseif subModuleId == ModuleSub.eTimedActivity                  -- "限时活动"(4400)
        or subModuleId == ModuleSub.eTimedChargeSingle              -- "限时-单笔充值"(4401)
        or subModuleId == ModuleSub.eTimedChargeTotal               -- "限时-累积充值"(4402)
        or subModuleId == ModuleSub.eTimedUseTotal                  -- "限时-累积消费"(4403)
        or subModuleId == ModuleSub.eTimedRecruit                   -- "限时-招募"(4404)
        or subModuleId == ModuleSub.eChargeDays                     -- "限时-累计充值天数"(4405)
        or subModuleId == ModuleSub.eTimedExchange                  -- "限时-兑换"(4406)
        or subModuleId == ModuleSub.eTimeDoubleDiamond              -- "双倍元宝"(4407)
        or subModuleId == ModuleSub.eTimedWishingTree               -- "许愿树"(4409)
        or subModuleId == ModuleSub.eTimedMagic                     -- "限时神兵"(4410)
        or subModuleId == ModuleSub.eTimedLuckDraw                  -- "宝库抽奖" (4412)
        or subModuleId == ModuleSub.eTimedWelfareMaxJJC             -- "福利多多-天道榜"(4413)
        or subModuleId == ModuleSub.eTimedWelfareMaxDWDH            -- "福利多多-传承之战"(4414)
        or subModuleId == ModuleSub.eTimedWelfareMaxYCJK            -- "福利多多-丹神古墓" (4415)
        or subModuleId == ModuleSub.eTimedWelfareMaxEquip           -- "福利多多-装备召唤打折"(4416)
        or subModuleId == ModuleSub.eTimedWelfareMaxHero            -- "福利多多-人物召唤打折" (4417)
        or subModuleId == ModuleSub.eTimedWelfareEquipCompareCrid   -- "福利多多-装备合成暴击" (4418)
        or subModuleId == ModuleSub.eTimedWelfareEquipCallCrid      -- "福利多多-装备召唤暴击"(4419)
        or subModuleId == ModuleSub.eTimedWelfareMaxBDD             -- "福利多多-装备中心战功翻倍"(4420)
        or subModuleId == ModuleSub.eTimedBossDrop                  -- "福利多多-BOSS战特殊掉落" (4421)
        or subModuleId == ModuleSub.eTimedMoneyTree                 -- "限时-摇钱树" (4422)
        or subModuleId == ModuleSub.eTimedSmashingEggs              -- "限时彩蛋活动"(4423)
        or subModuleId == ModuleSub.eTimedAcumulateLogin            -- "限时-累计登录"(4424)
        or subModuleId == ModuleSub.eTimedCSSX                      -- "限时-财神送喜" (4425)
        or subModuleId == ModuleSub.eTimedPointsMall                -- "限时-积分商城"(4426)
        or subModuleId == ModuleSub.eTimedDailyChallenge            -- "限时-每日挑战"(4445)
        or subModuleId == ModuleSub.eTimedAcumulateCharge then      -- "限时-新累计充值"(4427)
        -- 判断是否有当前的活动
        params.name = "activity.ActivityMainLayer"
        data.moduleId =  ModuleSub.eTimedActivity
        data.showSubModelId = (subModuleId ~= ModuleSub.eTimedActivity) and subModuleId or nil
    -- 节日活动相关
    elseif subModuleId == ModuleSub.eChristmasActivity  -- "圣诞活动" (6100)
        or subModuleId == ModuleSub.eChristmasActivity1 -- "圣诞活动-累计充值" (6101)
        or subModuleId == ModuleSub.eChristmasActivity2 -- "圣诞活动-单笔充值"(6102)
        or subModuleId == ModuleSub.eChristmasActivity3 -- "圣诞活动-兑换"(6103)
        or subModuleId == ModuleSub.eChristmasActivity4 -- "圣诞活动-宝库抽奖" (6104)
        or subModuleId == ModuleSub.eChristmasActivity5 -- "圣诞活动-摇钱树" (6105)
        or subModuleId == ModuleSub.eChristmasActivity6 -- "圣诞活动-砸金蛋" (6106)
        or subModuleId == ModuleSub.eChristmasActivity7 -- "节日活动-财神送喜"(6107)
        or subModuleId == ModuleSub.eChristmasActivity8 -- "节日活动-累计登录"(6108)
        or subModuleId == ModuleSub.eChristmasActivity9 -- "节日活动-消费送" (6109)
        or subModuleId == ModuleSub.eChristmasActivity10 -- "节日活动-BOSS掉落" (6110)
        or subModuleId == ModuleSub.eChristmasActivity11 -- "节日活动-积分商城" (6111)
        or subModuleId == ModuleSub.eChristmasActivity12 -- "节日活动-新累计充值" (6112)
        or subModuleId == ModuleSub.eTimedHolidayDrop -- "节日活动-限时掉落" (6115)
        or subModuleId == ModuleSub.eChristmasActivity17 then -- "限时-美食盛宴"（6117）
        -- 判断是否有当前的活动
        params.name = "activity.ActivityMainLayer"
        data.moduleId =  ModuleSub.eChristmasActivity
        data.showSubModelId = (subModuleId ~= ModuleSub.eChristmasActivity) and subModuleId or nil
    elseif  subModuleId == ModuleSub.eCommonHoliday  -- "通用节日活动" (6800)
        or subModuleId == ModuleSub.eCommonHoliday1 --  "通用活动-累计充值" ( 6801)
        or subModuleId == ModuleSub.eCommonHoliday2 --   "通用活动-单笔充值"( 6802)
        or subModuleId == ModuleSub.eCommonHoliday3 --  "通用活动-兑换"( 6803)
        or subModuleId == ModuleSub.eCommonHoliday4 -- "通用活动-宝库抽奖" ( 6804)
        or subModuleId == ModuleSub.eCommonHoliday5 --  "通用节日-灵玉矿" ( 6805)
        or subModuleId == ModuleSub.eCommonHoliday6 then --  "通用节日-砸金蛋"( 6806)
        -- 判断是否有当前的活动
        params.name = "activity.ActivityMainLayer"
        data.moduleId =  ModuleSub.eCommonHoliday
        data.showSubModelId = (subModuleId ~= ModuleSub.eCommonHoliday) and subModuleId or nil
    elseif subModuleId == ModuleSub.eDaliyTask then -- "每日任务" （3000）
        params.name = "dailytask.DailyTaskLayer"
        params.cleanUp = false
    elseif subModuleId == ModuleSub.eTimedShoottarget then -- "射靶活动" （4460）
        if ActivityObj:getActivityItem(ModuleSub.eTimedShoottarget) then
            params.name = "activity.ActivityShootArrowLayer"
        else
            ui.showFlashView(TR("活动暂未开放"))
        end
    elseif subModuleId == ModuleSub.eFirstRecharge then -- "首冲豪礼" (3100)
        params.name = "recharge.FirstRechargeLayer"
    elseif subModuleId == ModuleSub.eBulletin then -- = 3200,    -- "公告"
        -- Todo
    elseif subModuleId == ModuleSub.eCharge -- = 3300,    -- "充值"
        or subModuleId == ModuleSub.eVIP then 
        params.name = "recharge.RechargeLayer"
    elseif subModuleId == ModuleSub.eGuild then -- "社团" (3400)
        local guildInfo = GuildObj:getGuildInfo()
        if guildInfo.Id == EMPTY_ENTITY_ID then
            params.name = "guild.GuildSearchLayer"
        else
            params.name = "guild.GuildHomeLayer"
        end
    elseif subModuleId == ModuleSub.eGongHuiShop then -- 帮派商店
        if not ModuleInfoObj:moduleIsOpen(ModuleSub.eGuild, true) then
                return
            end
            local function gotoGuildShopLayer()
                LayerManager.addLayer({
                    name = "guild.GuildStoreLayer",
                    cleanUp = true
                })
            end

            -- 判断是否已加入帮派
            if not Utility.isEntityId(GuildObj:getGuildInfo().Id) then
                ui.showFlashView(TR("您尚未加入任何帮派"))
                return
            end
            -- 判断建筑信息是否为空
            if (table.nums(GuildObj:getGuildBuildInfo()) > 0) then
                gotoGuildShopLayer()
                return 
            end

            HttpClient:request({
                svrType = HttpSvrType.eGame,
                moduleName = "Guild",
                methodName = "GetGuildInfo",
                svrMethodData = {},
                callbackNode = self,
                callback = function(response)
                    if not response or response.Status ~= 0 then
                        ui.showFlashView(TR("获取帮派详细信息出错"))
                    else
                        GuildObj:updateGuildInfo(response.Value)
                        gotoGuildShopLayer()
                    end
                end,
            })
    elseif subModuleId == ModuleSub.eGuildBuild then -- 帮派建设
        local guildInfo = GuildObj:getGuildInfo()
        if guildInfo.Id == EMPTY_ENTITY_ID then
            params.name = "guild.GuildSearchLayer"
        else
            params.name = "guild.GuildBuildLayer"
        end
    elseif subModuleId == ModuleSub.eOnlineReward then -- "在线奖励" (3700)
        -- Todo
    elseif subModuleId == ModuleSub.eTeambattle then -- 西漠(2315)
        print("添加细末主页1")
        params.name = "teambattle.TeambattleHomeLayer"
    elseif subModuleId == ModuleSub.eTeambattleShop then  -- 六道天轮商店
        params.name = "teambattle.TeambattleShop"
    elseif subModuleId == ModuleSub.eTrader then -- 限时商店
        -- Todo
    elseif subModuleId == ModuleSub.ePetLvUp        -- 外功秘籍升级
        or subModuleId == ModuleSub.ePetInherit     -- 外功秘籍吞噬
        or subModuleId == ePetStudySkill then       -- 外功秘籍兽决
        params.name = "pet.PetUpgradeLayer"
        data.pageType = subModuleId
    elseif subModuleId == ModuleSub.eBattleForTen then --副本10次
        params.name = "battle.BattleNormalNodeLayer"
    elseif subModuleId == ModuleSub.eChallengeGrab then --武器锻造
        params.name = "challenge.ForgingMainLayer"
    elseif subModuleId == ModuleSub.eExpedition or subModuleId == ModuleSub.eStartBattle then --组队副本
        params.name = "challenge.ExpediDifficultyLayer"
    elseif subModuleId == ModuleSub.eZhenjue        -- 内功心法
        or subModuleId == ModuleSub.eZhenjueExtra then --内功洗炼
        params.name = "team.TeamZhenjueLayer"
    elseif subModuleId == ModuleSub.ePVPInter then  -- 群雄争霸
        params.name = "challenge.PvpInterLayer"
    elseif subModuleId == ModuleSub.eShengyuanWars then  -- 决战桃花岛
        params.name = "shengyuan.ShengyuanWarsStartLayer"
    elseif subModuleId == ModuleSub.eMedicine then  -- 炼丹炉
        params.name = "quench.QuenchAlchemyLayer"
    elseif subModuleId == ModuleSub.eTimedMountExchange then --飞机活动
        local tempStatus = ActivityObj:getActivityItem(ModuleSub.eTimedMountExchange) and true or false
        if tempStatus then
            params.name = "activity.ActivityAdvanced"
        else
            ui.showFlashView(TR("活动暂未开放"))
        end
    elseif subModuleId == ModuleSub.eZhenyuan
        or subModuleId == ModuleSub.eZhenyuanRecruit then  -- 真元练气
        params.name = "zhenyuan.ZhenYuanTabLayer"
    elseif subModuleId == ModuleSub.eKillerValley then  -- 绝情谷
        params.name = "killervalley.KillerValleyHomeLayer"
    elseif subModuleId == ModuleSub.eWhosTheGod then  -- 一统武林
        -- 是否是比赛时间(星期天)
        --转换出服务器日期
        local days = MqTime.getLocalDate()
        local inOpenTime = false
        if days.wday == 1 and (((days.hour >= 18 and days.min >=30) or days.hour >= 19) and days.hour <= 21) then
            inOpenTime = true
        end
        if inOpenTime then
            params.name = "challenge.PvpTopHomeLayer"
        else
            params.name = "challenge.PvpTopWorshipLayer"
        end
    elseif subModuleId == ModuleSub.eDisassembleFashion then  -- 绝学分解
        params.name = "fashion.FashionHomeLayer"
        data.defaultTag = 3
    elseif subModuleId == ModuleSub.eNeiliMingxiang then  -- 绝学分解
        params.name = "hero.MeditationLayer"
    elseif subModuleId == ModuleSub.eBrewing then  -- 酿酒
        params.name = "brew.BrewHomeLayer"
    elseif subModuleId == ModuleSub.eZhenshouLaoyu then  -- 珍兽塔
        params.name = "zsly.ZslyMainLayer"
    elseif subModuleId == ModuleSub.eZhenshouLaoyuShop then  -- 珍兽商店
        params.name = "zsly.ZslyShopLayer"
    elseif subModuleId == ModuleSub.eSect then  -- 八大门派
        SectObj:getSectInfo(function(response)
            if response.IsJoinIn then
                LayerManager.addLayer({name = "sect.SectLayer", data = {}})
            else
                LayerManager.addLayer({name = "sect.SectSelectLayer", data = {}})
            end
        end)
        return
    elseif subModuleId == ModuleSub.eDrama then  -- 侠影戏
        params.name = "more.DramaHomeLayer"
    elseif subModuleId == ModuleSub.eTitle then  -- 名望
        params.name = "more.PlayerTitleLayer"
    elseif subModuleId == ModuleSub.ePet then  -- 外功
        params.name = "team.TeamLayer"
    elseif subModuleId == ModuleSub.eIllustrated then  -- 群侠谱
        params.name = "hero.IllustrateHomeLayer"
    elseif subModuleId == ModuleSub.eJiangHuKill then  -- 江湖杀
        params.name = "jianghuKill.JianghuKillMapLayer"
    elseif subModuleId == ModuleSub.eZhenshou then  -- 珍兽
        params.name = "zhenshou.ZhenshouMainLayer"
    elseif subModuleId == ModuleSub.eSectPalace then  -- 门派地宫
        params.name = "sect.SectPalaceHomeLayer"
    else
        print(string.format("没有找到该功能模块ID::%s", subModuleId))
        return
    end

    if not params.name or params.name == "" then
        return
    end

    if not params.data and data then
        params.data = data
    end
    return LayerManager.addLayer(params)
end

-- 修改游戏内显示layer的方法
--[[
    params:
    Table:
    {
        name: Layer路径名，如”login.StartGameLayer“
        zOrder: 可选参数，默认为0
        data: 可选参数，需要传递给新layer的参数
        cleanUp: 可选参数，默认为true表示显示时需要清除其它界面，如弹窗类需要设置为false
        needRestore: 是否需要恢复 cleanUp 为 fasle的页面，默认为false
        allowSameName: 是否允许创建 name 相同的窗体，如果为true，则不会删除栈里同名窗体，只有cleanUp为false时有效，默认为false
        needAction: 切换页面是否需要动画效果
        isRootLayer: 是否是根页面，默认为false
    }
--]]
function LayerManager.addLayer(params)
    if not params.name then
        return
    end
    -- 默认为true表示显示时需要清除其它界面
    params.cleanUp = (params.cleanUp == nil) and true or params.cleanUp

    -- 控制自动资源释放
    if LayerManager.accCount > 10 then
        cc.Director:getInstance():purgeCachedData()
        LayerManager.accCount = 0
    end

    -- 特殊处理 需要添加的layer和当前显示的layer都是 "ComBattle.BattleLayer" 的情况
    if params.name == "ComBattle.BattleLayer" then  -- 进入战斗之前需要释放资源
        cc.Director:getInstance():purgeCachedData()
        LayerManager.accCount = 0

        local stackSize = table.getn(LayerManager.layerStack)
        local cleanIndex
        for i = stackSize, 1, -1 do
            local indexItem = LayerManager.layerStack[i]
            if indexItem.cleanUp then
                cleanIndex = i
                break
            end
        end
        local tempItem = cleanIndex and LayerManager.layerStack[cleanIndex]
        if tempItem and tempItem.name == params.name and not tolua.isnull(tempItem.layer) then
            for i = stackSize, cleanIndex, -1 do
                local indexItem = LayerManager.layerStack[i]
                if not tolua.isnull(indexItem.layer) then
                    indexItem.layer:removeFromParent()
                end
                table.remove(LayerManager.layerStack, i)
            end
        end
    end

    -- 特殊处理 从冰火岛地图离开，需断开连接
    if LayerManager.getTopCleanLayerName() == "ice.IcefireMapLayer" and params.cleanUp then
        require("ice.IcefireHelper")
        IcefireHelper:leave()
    end

    -- 如mac平台，自动重新requre当前页面
    if device.platform == "mac" then
        package.loaded[params.name] = nil
    end
    -- 创建新空间需要放在最前面，避免因为创建失败造成栈管理混乱
    local newLayer = require(params.name).new(params.data or {})

    -- 添加layer数据到栈顶
    local parent = getMainScene(params.name)
    local stackSize = table.getn(LayerManager.layerStack)

    -- 更新Layer恢复参数
    if params.cleanUp then
        changeBgMusic(params.name)
        for i = stackSize, 1, -1 do
            local tempItem = LayerManager.layerStack[i]
            if not tolua.isnull(tempItem.layer) and tempItem.layer.getRestoreData then
                tempItem.data = tempItem.layer:getRestoreData()
            end
        end
    else
        local tempLayerName
        for i = stackSize, 1, -1 do
            local tempItem = LayerManager.layerStack[i]
            if tempItem.cleanUp then
                tempLayerName = tempItem.name
                break
            end
        end
        changeBgMusic(params.name, tempLayerName)
    end

    local rootLayer = params.isRootLayer or isRootLayer(params.name)
    -- 栈里原来的layer对象
    local needRemoveLayer, oldZorder = {}, 0
    for i = stackSize, 1, -1 do
        local indexItem = LayerManager.layerStack[i]
        -- 检查栈里是否有同名的Layer
        if indexItem.name == params.name and (params.cleanUp or not params.cleanUp and not params.allowSameName) then
            if not tolua.isnull(indexItem.layer) then
                oldZorder = indexItem.layer:getLocalZOrder()
                indexItem.layer:removeFromParent()
            end
            print("删除历史相同Layer, 避免循环:", indexItem.name)
            table.remove(LayerManager.layerStack, i)
        elseif params.cleanUp or rootLayer ~= false then
            if not tolua.isnull(indexItem.layer) then
                table.insert(needRemoveLayer, indexItem.layer)
            end
            indexItem.layer = nil
        else
            if not tolua.isnull(indexItem.layer) then
                local tempZOrder = indexItem.layer:getLocalZOrder()
                oldZorder = math.max(oldZorder, tempZOrder)
            end
        end
    end

    -- 如果新加入的layer始终位于栈底位置，则需要清空栈并且删除其中的layer对象
    if rootLayer ~= false then
        LayerManager.layerStack = {}
    end
    local stackSize = table.getn(LayerManager.layerStack)
    params.zOrder = params.zOrder or math.max(stackSize, oldZorder)

    -- 新加Layer
    parent:addChild(newLayer, params.zOrder)
    params.layer = newLayer
    print("添加新Layer:", params.name) -- 添加新layer， cleanUp为false时仍然加入
    table.insert(LayerManager.layerStack, params)

    if params.needAction then
        -- 播放动画效果
        if rootLayer == false then
            newLayer:setScale(0.3)
            local array = {cc.ScaleTo:create(0.3, 1),
                cc.CallFunc:create(function()
                    if newLayer.onAddActionEnd then
                        newLayer:onAddActionEnd()
                    end
                end)
            }
            newLayer:runAction(cc.Sequence:create(array))
        elseif newLayer.onAddActionEnd then
            newLayer:onAddActionEnd()
        end
        for _, layer in pairs(needRemoveLayer) do
            print("删除Layer:", layer.__cname)
            local array = {cc.ScaleTo:create(0.3, 2),
                cc.CallFunc:create(function()
                    if layer.onRemoveActionEnd then
                        layer:onRemoveActionEnd()
                    end
                    layer:removeFromParent()
                end)
            }
            layer:runAction(cc.Sequence:create(array))
        end
    else
        for _, layer in pairs(needRemoveLayer) do
            print("删除Layer:", layer.__cname)
            if layer.onRemoveActionEnd then
                layer:onRemoveActionEnd()
            end
            layer:removeFromParent()
        end
    end

    -- 资源计数器增加
    LayerManager.accCount = LayerManager.accCount + 1

    return newLayer
end

-- 删除当前显示的layer的方法
--[[
    params:
    oldLayer: 需要删除的layer， 一般传self
    needAction: 切换页面是否需要动画效果
--]]
function LayerManager.removeLayer(oldLayer, needAction)
    if tolua.isnull(oldLayer) then
        print("LayerManager.removeLayer 无效的Layer")
        return
    end
    -- 删除layer时，暂停异步加载的动画，避免异步回调出错
    --sp.SkeletonExtend:clearAsyncRequest()
    -- 是否需要特殊删除缓存
    local purgeCache = false
    -- 从栈中移除layer
    local orignSize = table.getn(LayerManager.layerStack)
    local isLayerCleanUp, layerIndex = false, nil
    for i = orignSize, 1, -1 do
        local stackValue = LayerManager.layerStack[i]
        if stackValue.layer == oldLayer then
            layerIndex = i
            isLayerCleanUp = stackValue.cleanUp
            if stackValue.name == "ComBattle.BattleLayer" then
                purgeCache = true
            end
            break
        end
    end
    if isLayerCleanUp then
        for i = orignSize, layerIndex, -1 do
            local stackValue = LayerManager.layerStack[i]
            if i > layerIndex and not tolua.isnull(stackValue.layer) then
                stackValue.layer:removeFromParent()
            end
            table.remove(LayerManager.layerStack, i)
        end
    elseif layerIndex then
        table.remove(LayerManager.layerStack, layerIndex)
    end


    local newLayerList = {}
    -- 恢复上层layer
    local curSize = table.getn(LayerManager.layerStack)
    if orignSize > curSize and curSize > 0 and isLayerCleanUp then
        -- 不需要恢复的layer
        local notRestoreLayer = {
            ["ComBattle.BattleLayer"] = true,
            ["ice.IcefireMapLayer"] = true,
            ["Login.CgLayer"] = true,
        }
        for i = curSize, 1, -1 do
            local stackValue = LayerManager.layerStack[i]
            if notRestoreLayer[stackValue.name] then
                table.remove(LayerManager.layerStack, i)  -- 删除需要恢复的纪录（斗场景layer 和 Cg动画场景）
            else
                if stackValue.cleanUp or stackValue.needRestore then  -- 找到了需要恢复的最下层窗体 获取需要恢复的弹窗
                    local newLayer = require(stackValue.name).new(stackValue.data or {})
                    getMainScene(stackValue.name):addChild(newLayer, stackValue.zOrder)
                    stackValue.layer = newLayer
                    table.insert(newLayerList, newLayer)
                    print("恢复显示Layer:", stackValue.name)

                    if stackValue.cleanUp then
                        changeBgMusic(stackValue.name)
                        break
                    end
                else
                    table.remove(LayerManager.layerStack, i) -- 删除至cleanUp=true为止的不需要恢复弹窗记录
                end
            end
        end
    end

    if needAction then
        -- 播放动画效果
        local array = {cc.ScaleTo:create(0.3, 0.1),
            cc.CallFunc:create(function()
                if oldLayer.onRemoveActionEnd then
                    oldLayer:onRemoveActionEnd()
                end
                oldLayer:removeFromParent()
                -- 特殊清空缓存
                if purgeCache then
                    cc.Director:getInstance():purgeCachedData()
                    LayerManager.accCount = 0
                end
            end)
        }
        oldLayer:runAction(cc.Sequence:create(array))

        if #newLayerList > 0 then
            for _, layer in ipairs(newLayerList) do
                layer:setScale(2)
                local array = {cc.ScaleTo:create(0.3, 1),
                    cc.CallFunc:create(function()
                        if layer.onAddActionEnd then
                            layer:onAddActionEnd()
                        end
                    end)
                }
                layer:runAction(cc.Sequence:create(array))
            end
        end
    else
        if oldLayer.onRemoveActionEnd then
            oldLayer:onRemoveActionEnd()
        end
        oldLayer:removeFromParent()
        if purgeCache then
            cc.Director:getInstance():purgeCachedData()
            LayerManager.accCount = 0
        end
    end
    -- 当栈为空时，如果玩家已经登录，则跳转到HomeLayer，否则跳转到登录页面
    if table.getn(LayerManager.layerStack) == 0 then
        if Player.mIsLogin then
            LayerManager.addLayer({name = "home.HomeLayer"})
        else
            LayerManager.addLayer({name = "login.GameLoginLayer"})
        end
    end
end

-- 删除顶层页面, 比 LayerManager.removeLayer  的执行效率低，所以避免使用该函数
--[[
-- 参数
    isCleanUpLayer: 是否删除 顶层cleanUp为true 的页面， 默认为 false
]]
function LayerManager.removeTopLayer(isCleanUpLayer)
    local orignSize = table.getn(LayerManager.layerStack)
    for i = orignSize, 1, -1 do
        local stackValue = LayerManager.layerStack[i]
        if isCleanUpLayer then
            if stackValue.cleanUp and not tolua.isnull(stackValue.layer) then
                LayerManager.removeLayer(stackValue.layer)
                return
            end
        else
            if not tolua.isnull(stackValue.layer) then
                LayerManager.removeLayer(stackValue.layer)
                return
            end
        end
    end
end

-- 清空页面显示（包括清空栈数据）
--[[
-- 参数
    needClearStack： 是否需要清空栈，默认为ture
 ]]
function LayerManager.clearLayer(needClearStack)
    -- 删除历史layer
    for _, v in ipairs(LayerManager.layerStack) do
        if not tolua.isnull(v.layer) then
            print("删除Layer:", v.name)
            v.layer:removeFromParent()
        end
        v.layer = nil
    end

    if needClearStack ~= false then
        -- 检查是否需要清除记录栈
        print("清空Layer栈")
        LayerManager.layerStack = {}
    end
end

-- 获取栈顶需要清空的layer名称
function LayerManager.getTopCleanLayerName()
    local stackSize = table.getn(LayerManager.layerStack)
    for i = stackSize, 1, -1 do
        local indexItem = LayerManager.layerStack[i]
        if indexItem.cleanUp then
            return indexItem.name
        end
    end
end

-- 获取显示最高层Layer名
function LayerManager.getTopLayer()
    local stackSize = table.getn(LayerManager.layerStack)
    return LayerManager.layerStack[stackSize].layer
end

-- 获取对应页面的重创建参数
--[[
	params:
	    name: 需要获取数据的layer的名称
--]]
function LayerManager.getRestoreData(name)
    for i = #LayerManager.layerStack, 1, -1 do
        local stackItem = LayerManager.layerStack[i]
        if stackItem.name == name then
            print("获取构建参数Layer:", name)
            return stackItem.data
        end
    end
end

-- 修改对应页面的重创建参数
--[[
	params:
	    name: 需要修改的恢复layer名
	    restoreData: 替换用参数
--]]
function LayerManager.setRestoreData(name, restoreData)
    for i = #LayerManager.layerStack, 1, -1 do
        local stackItem = LayerManager.layerStack[i]
        if stackItem.name == name then
            print("修改构建参数Layer:", name)
            stackItem.data = restoreData
            break
        end
    end
end

-- 根据名称删除栈中的条目, 只负责删除条目，不负责重构下层layer, 慎重使用
--[[
	params:
	    name: 需要删除Layer的名称
--]]
function LayerManager.deleteStackItem(name)
    for i = #LayerManager.layerStack, 1, -1 do
        local stackItem = LayerManager.layerStack[i]
        if stackItem.name == name then
            if not tolua.isnull(stackItem.layer) then
                stackItem.layer:removeFromParent()
            end
            print("删除历史相同Layer, 避免循环:", stackItem.name)
            table.remove(LayerManager.layerStack, i)
            break
        end
    end
end

-- 添加新手引导页面
function LayerManager.addGuideLayer(layer, parent)
    LayerManager.removeGuideLayer()

    -- 注册退出事件
    layer:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            LayerManager.guideLayer = nil
        end
    end)

    local currentScene = parent or display.getRunningScene()
    currentScene:addChild(layer, Enums.ZOrderType.eNewbieGuide)

    LayerManager.guideLayer = layer
end

-- 移除新手引导页面
function LayerManager.removeGuideLayer()
    if (LayerManager.guideLayer ~= nil) then
        local layer = LayerManager.guideLayer
        LayerManager.guideLayer = nil

        if not tolua.isnull(layer) then
            layer:removeFromParent()
        end
    end
end
