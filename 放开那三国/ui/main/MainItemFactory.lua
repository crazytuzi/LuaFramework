-- Filename：    MainUtil.lua
-- Author：      chengliang
-- Date：        2015-1-16
-- Purpose：     主界面工具类

module("MainItemFactory" , package.seeall)

require "script/model/utils/ActivityConfigUtil"


local _itemArray = {}
--上部按钮
local SIGNIN        = 1     -- 签到
local ACTIVITY      = 2     -- 精彩活动
local EVERYDAY      = 3     -- 每日任务
local WORLD         = 4     -- 跨服争霸赛
local MISSION       = 5     -- 悬赏榜
local SEVENS_LOTTERY= 6     -- 七星台
local ONLINE        = 7     -- 在线奖励
local LEVE_REWARD   = 8     -- 等级礼包
local SERVER_GIFT   = 9     -- 开服礼包
local OPEN_ACT      = 10    -- 开服活动
local CARNIVAL      = 11    -- 节日狂欢
local REWARD_CENTER = 12    -- 领奖中心
local PLAY_BACK     = 13    -- 重回三国

--中部按钮
local RES_RECOVER      = 51 --资源追回
local CITY_WAR         = 52 --城池战
local GUILD_INVITE     = 53 --军团副本邀请
local TOWER_MYSTERIOUS = 54 --试炼塔神秘层
local ROB_BATTLE       = 55 --抢粮战按钮
local COUNTRY_WAR      = 56 --国战
local RED_PACKAGEG     = 57 --红包
local HORSE_INVITE     = 58 --木牛流马协助邀请
local TITLE_DISAPPEAR  = 59 --装备称号失效
local RES_TREAS        = 60 --资源库宝藏

--下部按钮
local STARHERO      = 101--名将
local HERO          = 102--武将
local EQUIP         = 103--装备
local ASTROLOGY     = 104--占星
local DESTINY       = 105--天命
local FIGHTSOUL     = 106--战魂
local RECYCLE       = 107--炼化炉
local GUILD         = 108--军团
local PET           = 109--宠物
local CHAT          = 110--聊天
local OTHER         = 111--功能
local SHOP          = 112--商店



function getBottomBtnPos()
    local pos = {}
    pos[STARHERO]  = ccp(65,234)
    pos[HERO]      = ccp(170,234)
    pos[EQUIP]     = ccp(270,234)
    pos[ASTROLOGY] = ccp(376,234)
    pos[DESTINY]   = ccp(477,234)
    pos[FIGHTSOUL] = ccp(575,234)
    pos[SHOP]      = ccp(65,86)
    pos[RECYCLE]   = ccp(170,86)
    pos[GUILD]     = ccp(270,86)
    pos[PET]       = ccp(376,86)
    pos[CHAT]      = ccp(477,86)
    pos[OTHER]     = ccp(575,86)
    return pos
end

function getMiddleBtnArray()
    local btnAttay = {
        RES_RECOVER,
        CITY_WAR,
        GUILD_INVITE,
        TOWER_MYSTERIOUS,
        ROB_BATTLE,
        COUNTRY_WAR,
        RED_PACKAGEG,
        HORSE_INVITE,
        TITLE_DISAPPEAR,
        RES_TREAS,
    }
    return btnAttay
end

function getTopBtnAarray()
    local btnAttay = {
        SIGNIN,
        ACTIVITY,
        EVERYDAY,
        WORLD,
        MISSION,
        SEVENS_LOTTERY,
        ONLINE,
        OPEN_ACT,
        CARNIVAL,
        LEVE_REWARD,
        SERVER_GIFT,
        REWARD_CENTER,
        PLAY_BACK
    }
    return btnAttay
end

function getButtonCreateArray()
    return _itemArray
end

--名将按钮
_itemArray[STARHERO] = {}
_itemArray[STARHERO].createButton = function ( ... )
    local norImg = "images/main/sub_icons/fair_n.png"
    local higImg = "images/main/sub_icons/fair_h.png"
    local item = createButton(norImg, higImg, _itemArray[STARHERO].actionCallback)
    --小红点
    require "script/ui/star/StarUtil"
    local isShowTip = StarUtil.isHaveTip()
    showTipSprite(menuItem,isShowTip)
    return item
end
_itemArray[STARHERO].actionCallback = function ( ... )
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuideGreatSoldier) then
        require "script/guide/StarHeroGuide"
        StarHeroGuide.changLayer()
    end
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuideHeroBiography) then
        require "script/guide/LieZhuanGuide"
        LieZhuanGuide.changLayer()
    end
    if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
        return
    end
    require "script/ui/star/StarLayer"
    local starLayer = StarLayer.createLayer()
    MainScene.changeLayer(starLayer, "starLayer")
end

--武将将按钮
_itemArray[HERO] = {}
_itemArray[HERO].createButton = function ( ... )
    local norImg = "images/main/sub_icons/hero_n.png"
    local higImg = "images/main/sub_icons/hero_h.png"
    local item = createButton(norImg, higImg, _itemArray[HERO].actionCallback)
    --小红点
    require "script/model/hero/HeroModel"
    HeroModel.initNewHero()
    if(HeroModel.isHaveNewHero() == true) then
        local newAnimSprite = XMLSprite:create("images/mail/new/new")
        newAnimSprite:setPosition(ccp(item:getContentSize().width*0.5-20,item:getContentSize().height-20))
        item:addChild(newAnimSprite,3)
    end
    require "script/ui/hero/HeroSoulLayer"
    print(GetLocalizeStringBy("key_1097"), HeroSoulLayer.getFuseSoulNum())
    if(HeroSoulLayer.getFuseSoulNum() > 0) then
        local tipSprite = CCSprite:create("images/common/tip_2.png")
        tipSprite:setAnchorPoint(ccp(0.5, 0.5))
        tipSprite:setPosition(ccpsprite(0.85,0.85, item))
        item:addChild(tipSprite)
    end
    return item
end
_itemArray[HERO].actionCallback = function ( ... )
    require "script/guide/NewGuide"
    if(NewGuide.guideClass ==  ksGuideForge) then
        require "script/guide/StrengthenGuide"
        StrengthenGuide.changLayer()
    end
    require "script/guide/NewGuide"
    require "script/guide/GeneralUpgradeGuide"
    if(NewGuide.guideClass ==  ksGuideGeneralUpgrade) then
        GeneralUpgradeGuide.changeLayer()
    end
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuideHeroDevelop) then
        require "script/guide/HeroDevelopGuide"
        HeroDevelopGuide.changLayer()
    end
    if not DataCache.getSwitchNodeState(ksSwitchGeneralTransform) then
        return
    end
    require "script/ui/hero/HeroLayer"
    MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
end

--装备按钮
_itemArray[EQUIP] = {}
_itemArray[EQUIP].createButton = function ( ... )
    local norImg = "images/main/sub_icons/equip_n.png"
    local higImg = "images/main/sub_icons/equip_h.png"
    local item = createButton(norImg, higImg, _itemArray[EQUIP].actionCallback)
    --小红点
    local isShowTip = BagUtil.isShowTipSprite()
    showTipSprite(item,isShowTip)
    return item
end
_itemArray[EQUIP].actionCallback = function ( ... )
    require "script/ui/bag/BagLayer"
    local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
    MainScene.changeLayer(bagLayer, "bagLayer")
end

--占星
_itemArray[ASTROLOGY] = {}
_itemArray[ASTROLOGY].createButton = function ( ... )
    local norImg = "images/main/sub_icons/horoscope_n.png"
    local higImg = "images/main/sub_icons/horoscope_h.png"
    local item = createButton(norImg, higImg, _itemArray[ASTROLOGY].actionCallback)
    --小红点
    local alertSprite = CCSprite:create("images/common/tip_2.png")
    alertSprite:setAnchorPoint(ccp(0.5,0.5))
    alertSprite:setPosition(ccp(item:getContentSize().width*0.8,item:getContentSize().height*0.8))
    item:addChild(alertSprite,1,1915)
    alertSprite:setVisible(_isAstroAlert)
    return item
end
_itemArray[ASTROLOGY].actionCallback = function ( ... )
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuideAstrology) then
        require "script/guide/AstrologyGuide"
        AstrologyGuide.changLayer()
    end
    if not DataCache.getSwitchNodeState(ksSwitchStar) then
        return
    end
    require "script/ui/astrology/AstrologyLayer"
    local astrologyLayer = AstrologyLayer.createAstrologyLayer()
    MainScene.changeLayer(astrologyLayer, "AstrologyLayer",AstrologyLayer.exitAstro)
end

--天命
_itemArray[DESTINY] = {}
_itemArray[DESTINY].createButton = function ( ... )
    local norImg = "images/main/sub_icons/destiny_n.png"
    local higImg = "images/main/sub_icons/destiny_h.png"
    local item = createButton(norImg, higImg, _itemArray[DESTINY].actionCallback)
    --武将学技能小红点
    require "script/ui/replaceSkill/ReplaceSkillData"
    local isShowTip = ReplaceSkillData.isShowTip()
    showTipSprite(item, isShowTip)
    --天命小红点
    if DataCache.getSwitchNodeState(ksSwitchDestiny, false) then
        require "script/ui/destiny/DestinyData"
        if DestinyData.canUpDestiny() then
            local alertSprite = CCSprite:create("images/common/tip_2.png")
            alertSprite:setAnchorPoint(ccp(0.5,0.5))
            alertSprite:setPosition(ccp(item:getContentSize().width*0.8,item:getContentSize().height*0.8))
            item:addChild(alertSprite,1,1998)
        end
    end
    return item
end
_itemArray[DESTINY].actionCallback = function ( ... )
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuideDestiny) then
        require "script/guide/DestinyGuide"
        DestinyGuide.changLayer()
    end
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuideChangeSkill) then
        require "script/guide/ChangeSkillGuide"
        ChangeSkillGuide.changLayer()
    end
    if not DataCache.getSwitchNodeState(ksSwitchDestiny) then
        return
    end
    require "script/ui/destiny/DestinyLayer"
    local destinyLayer = DestinyLayer.createLayer()
    MainScene.changeLayer(destinyLayer, "destinyLayer")
end

--战魂
_itemArray[FIGHTSOUL] = {}
_itemArray[FIGHTSOUL].createButton = function ( ... )
    local norImg = "images/main/sub_icons/fightSoul_n.png"
    local higImg = "images/main/sub_icons/fightSoul_h.png"
    local item = createButton(norImg, higImg, _itemArray[FIGHTSOUL].actionCallback)
    return item
end
_itemArray[FIGHTSOUL].actionCallback = function ( ... )
    -- 战魂入口
    if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
        return
    end
    require "script/ui/huntSoul/HuntSoulLayer"
    local layer = HuntSoulLayer.createHuntSoulLayer()
    MainScene.changeLayer(layer, "huntSoulLayer")
end

--商店
_itemArray[SHOP] = {}
_itemArray[SHOP].createButton = function ( ... )
    local norImg = "images/main/sub_icons/shop_n.png"
    local higImg = "images/main/sub_icons/shop_h.png"
    local item = createButton(norImg, higImg, _itemArray[FIGHTSOUL].actionCallback)
    return item
end
_itemArray[SHOP].actionCallback = function ( ... )
    require "script/ui/shopall/ShoponeLayer"
    ShoponeLayer.show()
end

--炼化炉
_itemArray[RECYCLE] = {}
_itemArray[RECYCLE].createButton = function ( ... )
    local norImg = "images/main/sub_icons/recycle_n.png"
    local higImg = "images/main/sub_icons/recycle_h.png"
    local item = createButton(norImg, higImg, _itemArray[RECYCLE].actionCallback)
    return item
end
_itemArray[RECYCLE].actionCallback = function ( ... )
    require "script/guide/NewGuide"
    require "script/guide/ResolveGuide"
    if(NewGuide.guideClass ==  ksGuideResolve and ResolveGuide.stepNum == 1) then
        ResolveGuide.changLayer()
    end
    if not DataCache.getSwitchNodeState(ksSwitchResolve) then
        return
    end
    require "script/ui/refining/RefiningMainLayer"
    RefiningMainLayer.createLayer(true)
end

--军团
_itemArray[GUILD] = {}
_itemArray[GUILD].createButton = function ( ... )
    local norImg = "images/main/sub_icons/guild_n.png"
    local higImg = "images/main/sub_icons/guild_h.png"
    local item = createButton(norImg, higImg, _itemArray[GUILD].actionCallback)
    require "script/ui/guild/GuildDataCache"
    if( GuildDataCache.getIsShowRedTip() )then
        local alertSprite = CCSprite:create("images/common/tip_2.png")
        alertSprite:setAnchorPoint(ccp(0.5,0.5))
        alertSprite:setPosition(ccp(item:getContentSize().width*0.8,item:getContentSize().height*0.8))
        item:addChild(alertSprite,1,1998)
    end
    return item
end
_itemArray[GUILD].actionCallback = function ( ... )
    -- 军团入口
    if not DataCache.getSwitchNodeState(ksSwitchGuild) then
        return
    end
    -- 设置小红圈false
    GuildDataCache.setIsShowRedTip(false)
    require "script/ui/guild/GuildImpl"
    GuildImpl.showLayer()
end

--宠物
_itemArray[PET] = {}
_itemArray[PET].createButton = function ( ... )
    local norImg = "images/main/sub_icons/pet_n.png"
    local higImg = "images/main/sub_icons/pet_h.png"
    local item = createButton(norImg, higImg, _itemArray[PET].actionCallback)
    --宠物小红点
    require "script/ui/pet/PetData"
    if PetData.isShowTip() or PetData.productTip() then
        local alertSprite = CCSprite:create("images/common/tip_2.png")
        alertSprite:setAnchorPoint(ccp(0.5,0.5))
        alertSprite:setPosition(ccp(item:getContentSize().width*0.8,item:getContentSize().height*0.8))
        item:addChild(alertSprite,1,1998)
    end
    return item
end
_itemArray[PET].actionCallback = function ( ... )
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuidePet) then
        require "script/guide/PetGuide"
        PetGuide.changLayer()
    end
    if not DataCache.getSwitchNodeState(ksSwitchPet) then
        return
    end
    require "script/ui/pet/PetMainLayer"
    local layer= PetMainLayer.createLayer()
    MainScene.changeLayer(layer, "PetMainLayer")
end

--聊天
_itemArray[CHAT] = {}
_itemArray[CHAT].createButton = function ( ... )
    local norImg = "images/main/sub_icons/chat_n.png"
    local higImg = "images/main/sub_icons/chat_h.png"
    local item = createButton(norImg, higImg, _itemArray[PET].actionCallback)

    local animSprite = XMLSprite:create("images/base/effect/chat/liaotian")
    animSprite:setAnchorPoint(ccp(0.5,0.5))
    animSprite:setPosition(ccp(item:getContentSize().width*0.52,item:getContentSize().height*0.55))
    item:addChild(animSprite,1,1911)
    animSprite:setVisible(_isShowChatAnimation)

    -- 私人聊天的提示 , added by zhz
    local pChatTipSp= CCSprite:create("images/common/tip_2.png")
    pChatTipSp:setAnchorPoint(ccp(1,1))
    pChatTipSp:setPosition(ccp(item:getContentSize().width*0.97 ,item:getContentSize().height*0.98))
    item:addChild(pChatTipSp,1,1914)
    require "script/ui/chat/ChatMainLayer"
    pChatTipSp:setVisible(ChatMainLayer.getNewPmCount() > 0)
    return item
end
_itemArray[CHAT].actionCallback = function ( ... )
    require "script/ui/chat/ChatMainLayer"
    ChatMainLayer.showChatLayer()
end


--功能按钮
_itemArray[OTHER] = {}
_itemArray[OTHER].createButton = function ( ... )
    require "script/ui/main/FunctionButtonUtil"
    local item = FunctionButtonUtil.createButton()
    --设置z轴
    _itemArray[OTHER].zOrder = 300
    return item
end


--签到
_itemArray[SIGNIN] = {}
_itemArray[SIGNIN].createButton = function ( ... )
    require "script/ui/sign/SignRewardLayer"
    local item = SignRewardLayer.createSingBtn()
    local button = createButtonWithItem(item)
    _itemArray[SIGNIN].item = item
    return button
end
_itemArray[SIGNIN].isShow = function ( ... )
    local item = _itemArray[SIGNIN].item
    if item:isVisible() then
        return true
    end
    return false
end

--精彩活动
_itemArray[ACTIVITY] = {}
_itemArray[ACTIVITY].createButton = function ( ... )
    local norImg = "images/main/sub_icons/highlights_n.png"
    local higImg = "images/main/sub_icons/highlights_h.png"
    local item = CCMenuItemImage:create(norImg, higImg)
    item:setAnchorPoint(ccp(0.5, 0.5))
    item:registerScriptTapHandler(_itemArray[ACTIVITY].actionCallback)
    local button = createButtonWithItem(item)
    _itemArray[ACTIVITY].item = item
    _itemArray[ACTIVITY].update()
    return button
end
_itemArray[ACTIVITY].actionCallback = function ( ... )
    require "script/ui/rechargeActive/RechargeActiveMain"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local layer = RechargeActiveMain.create()
    MainScene.changeLayer(layer, "layer")
end
_itemArray[ACTIVITY].update = function ( ... )
    local item = _itemArray[ACTIVITY].item
    if item.tipSprite then
        item.tipSprite:removeFromParentAndCleanup(true)
        item.tipSprite = nil
    end
    --小红点
    require "script/ui/rechargeActive/ActiveCache"
    if ActiveCache.hasTipInActive() then
        require "script/utils/ItemDropUtil"
        local tipSprite= CCSprite:create("images/common/tip_2.png")
        tipSprite:setPosition(ccp(item:getContentSize().width*0.97, item:getContentSize().height*0.98))
        tipSprite:setAnchorPoint(ccp(1,1))
        item:addChild(tipSprite,1)
        item.tipSprite = tipSprite
        print("add activity tip sprite")
    end
end
_itemArray[ACTIVITY].isShow = function ( ... )
    return true
end

--每日任务
_itemArray[EVERYDAY] = {}
_itemArray[EVERYDAY].createButton = function ( ... )
    local norImg = "images/main/sub_icons/everyday_n.png"
    local higImg = "images/main/sub_icons/everyday_h.png"
    local item = CCMenuItemImage:create(norImg, higImg)
    item:setAnchorPoint(ccp(0.5, 0.5))
    item:registerScriptTapHandler(_itemArray[EVERYDAY].actionCallback)
    _itemArray[EVERYDAY].item = item
    _itemArray[EVERYDAY].update()
    local button = createButtonWithItem(item)
    return button
end
_itemArray[EVERYDAY].actionCallback = function ( ... )
    -- 每日任务入口
    if not DataCache.getSwitchNodeState(ksSwitchEveryDayTask) then
        return
    end
    require "script/ui/everyday/EverydayLayer"
    EverydayLayer.showEverydayLayer()
end
_itemArray[EVERYDAY].update = function ( ... )
    local item = _itemArray[EVERYDAY].item
    if item.tipSprite then
        item.tipSprite:removeFromParentAndCleanup(true)
        item.tipSprite = nil
    end
    require "script/ui/everyday/EverydayData"
    local isShowTip = EverydayData.getIsShowTipSprite()
    local tipSprite = CCSprite:create("images/common/tip_2.png")
    tipSprite:setAnchorPoint(ccp(0.5,0.5))
    tipSprite:setPosition(ccp(item:getContentSize().width*0.8,item:getContentSize().height*0.8))
    item:addChild(tipSprite,1,1915)
    tipSprite:setVisible(isShowTip)
    item.tipSprite = tipSprite
end
_itemArray[EVERYDAY].isShow = function ( ... )
    return true
end

--悬赏榜
_itemArray[MISSION] = {}
_itemArray[MISSION].createButton = function ( ... )
    local norImg = "images/main/sub_icons/mission_btn_n.png"
    local higImg = "images/main/sub_icons/mission_btn_h.png"
    local item = CCMenuItemImage:create(norImg, higImg)
    item:setAnchorPoint(ccp(0.5, 0.5))
    item:registerScriptTapHandler(_itemArray[MISSION].actionCallback)


    _itemArray[MISSION].item = item
    _itemArray[MISSION].update()
    local button = createButtonWithItem(item)
    return button
end
_itemArray[MISSION].actionCallback = function ( ... )
    -- 悬赏榜入口
    require "script/ui/mission/MissionMainLayer"
    MissionMainLayer.showLayer()
end
_itemArray[MISSION].update = function ( ... )
    --闪光特效
    local item = _itemArray[MISSION].item
    if item.effect then
        item.effect:removeFromParentAndCleanup(true)
        item.effect = nil
    end
    local effect = XMLSprite:create("images/base/effect/xuanshangbangtubiao/xuanshangbangtubiao")
    effect:setPosition(ccpsprite(0.5, 0.5, item))
    item:addChild(effect)
    effect:setVisible(false)
    item.effect = item.effect
    require "script/ui/mission/MissionMainData"
    if MissionMainData.isCanDonate() then
        effect:setVisible(true)
    end
    --小红点
    if item.tipSprite then
        item.tipSprite:removeFromParentAndCleanup(true)
        item.tipSprite = nil
    end
    local isShowTip = MissionMainData.isShowRedTip()
    local tipSprite = CCSprite:create("images/common/tip_2.png")
    tipSprite:setAnchorPoint(ccp(0.5,0.5))
    tipSprite:setPosition(ccp(item:getContentSize().width*0.8,item:getContentSize().height*0.8))
    item:addChild(tipSprite,1,1915)
    tipSprite:setVisible(isShowTip)
    item.tipSprite = tipSprite
end
_itemArray[MISSION].isShow = function ( ... )
    require "script/ui/mission/MissionMainData"
    if MissionMainData.isCanJion() and MissionMainData.getTeamId() >0 then
        return true
    end
    return false
end

--七星台
_itemArray[SEVENS_LOTTERY] = {}
_itemArray[SEVENS_LOTTERY].createButton = function ( ... )
    local norImg = "images/main/sub_icons/sevens_lottery_n.png"
    local higImg = "images/main/sub_icons/sevens_lottery_h.png"
    local item = CCMenuItemImage:create(norImg, higImg)
    item:setAnchorPoint(ccp(0.5, 0.5))
    item:registerScriptTapHandler(_itemArray[SEVENS_LOTTERY].actionCallback)
    _itemArray[SEVENS_LOTTERY].item = item
    local button = createButtonWithItem(item)
    return button
end

_itemArray[SEVENS_LOTTERY].isShow = function ( ... )
    require "script/ui/sevenlottery/SevenLotteryData"
    local isShow = SevenLotteryData.isShow()
    return isShow
end
_itemArray[SEVENS_LOTTERY].actionCallback = function ( ... )
    -- 七星台入口
    require "script/ui/sevenlottery/SevenLotteryLayer"
    SevenLotteryLayer.showLayer()
end

--回归三国
_itemArray[PLAY_BACK] = {}
_itemArray[PLAY_BACK].createButton = function ( ... )
    local norImg = "images/main/sub_icons/play_back_n.png"
    local higImg = "images/main/sub_icons/play_back_h.png"
    local item = CCMenuItemImage:create(norImg, higImg)
    item:setAnchorPoint(ccp(0.5, 0.5))
    item:registerScriptTapHandler(_itemArray[PLAY_BACK].actionCallback)
    _itemArray[PLAY_BACK].item = item
    local button = createButtonWithItem(item)
     --小红点
    if item.tipSprite then
        item.tipSprite:removeFromParentAndCleanup(true)
        item.tipSprite = nil
    end
    require "script/ui/playerBack/PlayerBackData"
    local isShowTip = PlayerBackData.isRedTip()
    local tipSprite = CCSprite:create("images/common/tip_2.png")
    tipSprite:setAnchorPoint(ccp(0.5,0.5))
    tipSprite:setPosition(ccp(item:getContentSize().width*0.8,item:getContentSize().height*0.8))
    item:addChild(tipSprite,1,1915)
    tipSprite:setVisible(isShowTip)
    item.tipSprite = tipSprite
    return button
end

_itemArray[PLAY_BACK].isShow = function ( ... )
    require "script/ui/playerBack/PlayerBackData"
    local isShow = PlayerBackData.isOpen()
    return isShow
end
_itemArray[PLAY_BACK].actionCallback = function ( ... )
    -- 回归三国
    require "script/ui/playerBack/PlayerBackLayer"
    PlayerBackLayer.show()
end


--在线奖励
_itemArray[ONLINE] = {}
_itemArray[ONLINE].createButton = function ( ... )
    local item = CCSprite:create()
    item:setContentSize(CCSizeMake(100, 100))
    require "script/ui/online/OnlineRewardBtn"
    require "script/ui/main/MainScene"
    OnlineRewardBtn.createOnlineRewardBtn(item)
    _itemArray[ONLINE].item = item
    return item
end

_itemArray[ONLINE].isShow = function ( ... )
    require "script/ui/online/OnlineRewardBtn"
    local isShow = OnlineRewardBtn.isShow()
    return isShow
end

--等级礼包
_itemArray[LEVE_REWARD] = {}
_itemArray[LEVE_REWARD].createButton = function ( ... )

    local item = CCSprite:create()
    item:setContentSize(CCSizeMake(100, 100))
    require "script/ui/level_reward/LevelRewardBtn"
    LevelRewardBtn.createLevelRewardBtn(item)
    _itemArray[LEVE_REWARD].item = item
    return item
end

_itemArray[LEVE_REWARD].isShow = function ( ... )
    require "script/ui/level_reward/LevelRewardBtn"
    local isShow = LevelRewardBtn.isShow()
    return isShow
end

--开服礼包
_itemArray[SERVER_GIFT] = {}
_itemArray[SERVER_GIFT].createButton = function ( ... )
    local item = CCSprite:create()
    item:setContentSize(CCSizeMake(100, 100))
    require "script/ui/sign/AccSignRewardLayer"
    AccSignRewardLayer.createAccSingBtn(item)
    _itemArray[SERVER_GIFT].item = item
    return item
end

_itemArray[SERVER_GIFT].isShow = function ( ... )
    require "script/ui/sign/AccSignRewardLayer"
    local isShow = AccSignRewardLayer.isShow()
    return isShow
end

--开服活动
_itemArray[OPEN_ACT] = {}
_itemArray[OPEN_ACT].createButton = function ( ... )
    local item= CCMenuItemImage:create("images/main/sub_icons/open_act_btn_n.png", "images/main/sub_icons/open_act_btn_h.png")
    item:registerScriptTapHandler(_itemArray[OPEN_ACT].actionCallback)
    item:setContentSize(CCSizeMake(100, 100))

    require "script/ui/newServerActivity/NewServerActivityData"
    local isShowTip = NewServerActivityData.isRedTip()
    showTipSprite(item, isShowTip)
    local button = createButtonWithItem(item)
    return button
end
_itemArray[OPEN_ACT].actionCallback = function ( ... )
    require "script/ui/newServerActivity/NewServerActivityLayer"
    NewServerActivityLayer.show()
end

_itemArray[OPEN_ACT].isShow = function ( ... )
    require "script/ui/newServerActivity/NewServerActivityData"
    local isShow = NewServerActivityData.isOpen()
    return isShow
end

--节日狂欢
_itemArray[CARNIVAL] = {}
_itemArray[CARNIVAL].createButton = function ( ... )
    local item= CCMenuItemImage:create("images/main/sub_icons/carnival_act_btn_n.png", "images/main/sub_icons/carnival_act_btn_n.png")
    item:registerScriptTapHandler(_itemArray[CARNIVAL].actionCallback)
    item:setContentSize(CCSizeMake(100, 100))

    local newAnimSprite = XMLSprite:create("images/holidayhappy/effect/jierikuanghuan/jierikuanghuan")
    newAnimSprite:setPosition(ccp(item:getContentSize().width/2,item:getContentSize().height/2))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)
    local data = HolidayHappyData.getDataOfAll()
    if(table.isEmpty(data))then
        showTipSprite(item, false)
        local button = createButtonWithItem(item)
        return button
    else
        require "script/ui/holidayhappy/HolidayHappyData"
        local isShowTip = HolidayHappyData.isRedTipOfMainLayer()
        showTipSprite(item, isShowTip)
        local button = createButtonWithItem(item)
        return button
    end 
end
_itemArray[CARNIVAL].actionCallback = function ( ... )
    require "script/ui/holidayhappy/HolidayHappyLayer"
    HolidayHappyLayer.show()
end

_itemArray[CARNIVAL].isShow = function ( ... )
    require "script/ui/holidayhappy/HolidayHappyData"
    
    if(HolidayHappyData.isOpen() and not table.isEmpty(HolidayHappyData.getDataOfAll()))then
        return true
    else    
        return false
    end
end

--奖励中心
_itemArray[REWARD_CENTER] = {}
_itemArray[REWARD_CENTER].createButton = function ( ... )

    local btnSprite = CCScale9Sprite:create("images/common/transparent.png", CCRectMake(0, 0, 3, 3), CCRectMake(1, 1, 1, 1))
    btnSprite:setPreferredSize(CCSizeMake(100, 100))
    local rewardCenterBtn = CCMenuItemSprite:create(btnSprite, btnSprite)
    rewardCenterBtn:setPosition(0, 0)
    rewardCenterBtn:setAnchorPoint(ccp(0, 0))
    rewardCenterBtn:registerScriptTapHandler(_itemArray[REWARD_CENTER].actionCallback)

    local menu = CCMenu:create()
    menu:setPosition(0, 0)
    menu:setAnchorPoint(ccp(0, 0))
    menu:addChild(rewardCenterBtn)

    local _itemSprite = CCSprite:create()
    _itemSprite:setContentSize(CCSizeMake(100, 100))
    _itemSprite:setAnchorPoint(ccp(0.5, 0.5))
    _itemSprite:addChild(menu)

    local imgPath = "images/base/effect/baoxiang/baoxiang"
    local effect = XMLSprite:create(imgPath)
    effect:setPosition(ccpsprite(0.5, 0.23, _itemSprite))
    _itemSprite:addChild(effect)

    _itemArray[REWARD_CENTER].item = _itemSprite
    return _itemSprite
end
_itemArray[REWARD_CENTER].actionCallback = function ( ... )
    require "script/ui/rewardCenter/RewardCenterView"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local runScene = CCDirector:sharedDirector():getRunningScene()
    local rewardLayer  = RewardCenterView.create()
    runScene:addChild(rewardLayer,1500)
end
_itemArray[REWARD_CENTER].isShow = function ( ... )
    if DataCache.getRewardCenterStatus() then
        return true
    end
    return false
end

--跨服战
_itemArray[WORLD] = {}
_itemArray[WORLD].createButton = function ( ... )
    require "script/ui/main/WorldButtonUtil"
    local button = WorldButtonUtil.createButton()
    _itemArray[WORLD].zOrder = 500
    return button
end
_itemArray[WORLD].isShow = function ( ... )
    require "script/ui/main/WorldButtonUtil"
    local isShow = WorldButtonUtil.isShow()
    return isShow
end

--资源回收
_itemArray[RES_RECOVER] = {}
_itemArray[RES_RECOVER].createButton = function ( ... )
    require "script/model/DataCache"
    local item= CCMenuItemImage:create("images/retrieve/retrieve_n.png", "images/retrieve/retrieve_h.png")
    item:registerScriptTapHandler(_itemArray[RES_RECOVER].actionCallback)
    require "script/ui/recover/ReResourceData"
    local isFirst = ReResourceData.getIsFirst()
    if(isFirst)then
        item:setVisible(false)
    else
        item:setVisible(true)
    end
    local newAnimSprite = XMLSprite:create("images/base/effect/yao/yao");
    newAnimSprite:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height/2+5))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)
    local button = createButtonWithItem(item)
    return button
end
_itemArray[RES_RECOVER].actionCallback = function ( ... )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/recover/ReResourceLayer"
    local isHaveRetrive = ReResourceData.ifHaveReward()
    if(isHaveRetrive)then
        local runScene = CCDirector:sharedDirector():getRunningScene()
        local rewardLayer  = ReResourceLayer.create()
        runScene:addChild(rewardLayer,1500)
    end
end
_itemArray[RES_RECOVER].isShow = function ( ... )
    require "script/model/DataCache"
    local isShow = DataCache.getReResourceStatus()
    return isShow
end

--军团邀请
_itemArray[GUILD_INVITE] = {}
_itemArray[GUILD_INVITE].createButton = function ( ... )
    require "script/model/DataCache"
    local item= CCMenuItemImage:create("images/guild/invite/invite_n.png", "images/guild/invite/invite_h.png")
    item:registerScriptTapHandler(_itemArray[GUILD_INVITE].actionCallback)

    local newAnimSprite = XMLSprite:create("images/base/effect/yao/yao")
    newAnimSprite:setPosition(ccp(item:getContentSize().width/2,item:getContentSize().height/2))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)

    local button = createButtonWithItem(item)
    return button
end
_itemArray[GUILD_INVITE].actionCallback = function ( ... )
    require "script/ui/teamGroup/ReceiveInviteLayer"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local updateCallback = function ()
        require "script/ui/main/MainMenuLayer"
        MainMenuLayer.updateMiddleButton()
    end
    ReceiveInviteLayer.showLayer(updateCallback)
end
_itemArray[GUILD_INVITE].isShow = function ( ... )
    require "script/ui/teamGroup/TeamGroupData"
    local isShow = TeamGroupData.hasInviteMem()
    return isShow
end

--城池战
_itemArray[CITY_WAR] = {}
_itemArray[CITY_WAR].createButton = function ( ... )
    require "script/model/DataCache"
    local item= CCMenuItemImage:create("images/main/sub_icons/city_war_n.png", "images/main/sub_icons/city_war_h.png")
    item:registerScriptTapHandler(_itemArray[CITY_WAR].actionCallback)

    local newAnimSprite = XMLSprite:create("images/base/effect/yao/yao")
    newAnimSprite:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height/2))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)

    local button = createButtonWithItem(item)
    return button
end
_itemArray[CITY_WAR].actionCallback = function ( ... )
    require "script/ui/guild/city/CityData"
    CityData.setIsEnterCityTip(true)
    require "script/ui/copy/CityTipLayer"
    CityTipLayer.show()
end
_itemArray[CITY_WAR].isShow = function ( ... )
    require "script/ui/guild/city/CityData"
    local isShow = CityData.getMianBtnIsShow()
    return isShow
end

--神秘层
_itemArray[TOWER_MYSTERIOUS] = {}
_itemArray[TOWER_MYSTERIOUS].createButton = function ( ... )

    local item= CCMenuItemImage:create("images/main/sub_icons/mysterious_n.png", "images/main/sub_icons/mysterious_h.png")
    item:registerScriptTapHandler(_itemArray[TOWER_MYSTERIOUS].actionCallback)

    local newAnimSprite = XMLSprite:create("images/base/effect/yao/yao")
    newAnimSprite:setPosition(ccp(item:getContentSize().width/2,item:getContentSize().height/2))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)

    local button = createButtonWithItem(item)
    return button
end
_itemArray[TOWER_MYSTERIOUS].actionCallback = function ( ... )
    require "script/ui/tower/TowerMainLayer"
    local towerMainLayer = TowerMainLayer.createLayer()
    MainScene.changeLayer(towerMainLayer, "towerMainLayer")
end
_itemArray[TOWER_MYSTERIOUS].isShow = function ( ... )
    require "script/ui/tower/TowerCache"
    local isShow = TowerCache.haveOrNotSceret()
    return isShow
end

--抢粮战
_itemArray[ROB_BATTLE] = {}
_itemArray[ROB_BATTLE].createButton = function ( ... )

    local item=  CCMenuItemImage:create("images/guild_rob_list/tip_n.png", "images/guild_rob_list/tip_h.png")
    item:registerScriptTapHandler(_itemArray[ROB_BATTLE].actionCallback)

    local newAnimSprite = XMLSprite:create("images/base/effect/yao/yao")
    newAnimSprite:setPosition(ccp(item:getContentSize().width/2,item:getContentSize().height/2))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)

    local button = createButtonWithItem(item)
    return button
end
_itemArray[ROB_BATTLE].actionCallback = function ( ... )
    local handleGetGuildInfo = function( cbFlag, dictData, bRet )
        if dictData.err ~= "ok" then
            return
        end
        GuildDataCache.setGuildInfo(dictData.ret)
        local myGuildRobInfo = GuildRobData.getMyGuildRobInfo()
        if myGuildRobInfo.robId ~= nil and myGuildRobInfo.robId ~= 0 then
            GuildRobBattleLayer.show()
        end
    end
    RequestCenter.guild_getGuildInfo(handleGetGuildInfo)
end
_itemArray[ROB_BATTLE].isShow = function ( ... )
    require "script/ui/guild/guildRobList/GuildRobData"
    require "script/ui/guild/GuildDataCache"
    require "script/ui/guild/guildrob/GuildRobBattleLayer"
    local isShow = GuildRobData.isRobbing()
    return isShow
end

--国战
_itemArray[COUNTRY_WAR] = {}
_itemArray[COUNTRY_WAR].createButton = function ( ... )

    local item=  CCMenuItemImage:create("images/country_war/quick_btn_n.png", "images/country_war/quick_btn_h.png")
    item:registerScriptTapHandler(_itemArray[COUNTRY_WAR].actionCallback)

    local newAnimSprite = XMLSprite:create("images/base/effect/yao/yao")
    newAnimSprite:setPosition(ccp(item:getContentSize().width/2,item:getContentSize().height/2))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)

    local button = createButtonWithItem(item)
    return button
end
_itemArray[COUNTRY_WAR].actionCallback = function ( ... )
    require "script/ui/countryWar/CountryWarMainLayer"
    CountryWarMainLayer.show()
end
_itemArray[COUNTRY_WAR].isShow = function ( ... )
    require "script/ui/countryWar/CountryWarMainData"
    local isShow = CountryWarMainData.isShowQuickIcon()
    return isShow
end

--红包
_itemArray[RED_PACKAGEG] = {}
_itemArray[RED_PACKAGEG].createButton = function ( ... )

    local item=  CCMenuItemImage:create("images/redpacket/redicon1.png", "images/redpacket/redicon2.png")
    item:registerScriptTapHandler(_itemArray[RED_PACKAGEG].actionCallback)

    local newAnimSprite = XMLSprite:create("images/base/effect/yao/yao")
    newAnimSprite:setPosition(ccpsprite(0.5, 0.6, item))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)

    local button = createButtonWithItem(item)
    return button
end
_itemArray[RED_PACKAGEG].actionCallback = function ( ... )
    require "script/ui/rechargeActive/RechargeActiveMain"
    local monthSignLayer = RechargeActiveMain.create(RechargeActiveMain._tagRedPacket)
    MainScene.changeLayer(monthSignLayer,"monthSignLayer")
end
_itemArray[RED_PACKAGEG].isShow = function ( ... )
    require "script/ui/redpacket/RedPacketData"
    local isShow = RedPacketData.isShowRed()
    print("【RED_PACKAGEG】show:",isShow)
    return isShow
end

--木牛流马邀请
_itemArray[HORSE_INVITE] = {}
_itemArray[HORSE_INVITE].createButton = function ( ... )

    local item=  CCMenuItemImage:create("images/horse/invite.png", "images/horse/invite.png")
    item:registerScriptTapHandler(_itemArray[HORSE_INVITE].actionCallback)

    local newAnimSprite = XMLSprite:create("images/horse/mnlm_yao/mnlm_yao")
    newAnimSprite:setPosition(ccpsprite(0.5, 0.5, item))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)

    local button = createButtonWithItem(item)
    return button
end
_itemArray[HORSE_INVITE].actionCallback = function ( ... )
    require "script/ui/horse/HorseReceiveInviteLayer"
    HorseReceiveInviteLayer.showLayer(nil,-1000,1000)
end
_itemArray[HORSE_INVITE].isShow = function ( ... )
    require "script/ui/horse/HorseData"
    local isShow = HorseData.isHaveInvite()
    print("HORSE_INVITE:",isShow)
    return isShow
end

--装备称号失效
_itemArray[TITLE_DISAPPEAR] = {}
_itemArray[TITLE_DISAPPEAR].createButton = function ( ... )
    local item=  CCMenuItemImage:create("images/title/disappear_n.png", "images/title/disappear_h.png")
    item:registerScriptTapHandler(_itemArray[TITLE_DISAPPEAR].actionCallback)

    local newAnimSprite = XMLSprite:create("images/title/effect/shixiao/shixiao")
    newAnimSprite:setPosition(ccpsprite(0.5, 0.5, item))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)

    local button = createButtonWithItem(item)
    return button
end
_itemArray[TITLE_DISAPPEAR].actionCallback = function ( ... )
    require "script/ui/title/TitleDisappearDialog"
    local titleId = TitleData.getLastDisappearTitleId()
    TitleDisappearDialog.showDialog(titleId,-1000,1000)
end
_itemArray[TITLE_DISAPPEAR].isShow = function ( ... )
    require "script/ui/title/TitleData"
    local isShow = TitleData.isHadDisappearTitle()
    print("TITLE_DISAPPEAR:",isShow)
    return isShow
end

--资源库宝藏
_itemArray[RES_TREAS] = {}
_itemArray[RES_TREAS].createButton = function ( ... )
    local item=  CCMenuItemImage:create("images/main/round_btn/res_btn_n.png", "images/main/round_btn/res_btn_h.png")
    item:registerScriptTapHandler(_itemArray[RES_TREAS].actionCallback)

    local newAnimSprite = XMLSprite:create("images/main/round_effect/baozang/baozang")
    newAnimSprite:setPosition(ccpsprite(0.5, 0.5, item))
    newAnimSprite:setAnchorPoint(ccp(0.5,0.5))
    item:addChild(newAnimSprite,-1)

    local button = createButtonWithItem(item)
    return button
end
_itemArray[RES_TREAS].actionCallback = function ( ... )
    require "script/ui/active/mineral/MineralLayer"
    local mineralLayer = MineralLayer.createLayer()
    MainScene.changeLayer(mineralLayer, "mineralLayer")
end
_itemArray[RES_TREAS].isShow = function ( ... )
    require "script/ui/active/mineral/MineralElvesData"
    local isShow = MineralElvesData.isShow()
    return isShow
end

-- 按钮上边的提示小红圈
-- 添加对象  item
-- isVisible 是否显示
function showTipSprite( item, isVisible )
    if(item == nil)then
        return
    end
    if( item:getChildByTag(1915) ~= nil )then
        local tipSprite = tolua.cast(item:getChildByTag(1915),"CCSprite")
        tipSprite:setVisible(isVisible)
    else
        local tipSprite = CCSprite:create("images/common/tip_2.png")
        tipSprite:setAnchorPoint(ccp(0.5,0.5))
        tipSprite:setPosition(ccp(item:getContentSize().width*0.8,item:getContentSize().height*0.8))
        item:addChild(tipSprite,1,1915)
        tipSprite:setVisible(isVisible)
    end
end

function createButton( pNorImg, pHigImg, pAction )
    local normalSprite = CCSprite:create(pNorImg)
    local highSprite   = CCSprite:create(pHigImg)

    local itemSprite = CCSprite:create()
    itemSprite:setContentSize(normalSprite:getContentSize())
    itemSprite:setAnchorPoint(ccp(0.5, 0.5))
    local menu = CCMenu:create()
    menu:setContentSize(itemSprite:getContentSize())
    menu:setAnchorPoint(ccp(0.5, 0.5))
    menu:setPosition(ccpsprite(0.5, 0.5, itemSprite))
    menu:ignoreAnchorPointForPosition(false)
    itemSprite:addChild(menu)

    local item = CCMenuItemSprite:create(normalSprite, highSprite)
    item:setAnchorPoint(ccp(0.5, 0.5))
    item:setPosition(ccpsprite(0.5, 0.5, menu))
    item:registerScriptTapHandler(pAction)
    menu:addChild(item, 80)
    return itemSprite
end

function createButtonWithItem( pItem )
    local itemSprite = CCSprite:create()
    itemSprite:setContentSize(pItem:getContentSize())
    itemSprite:setAnchorPoint(ccp(0.5, 0.5))

    local menu = CCMenu:create()
    menu:setContentSize(itemSprite:getContentSize())
    menu:setAnchorPoint(ccp(0.5, 0.5))
    menu:setPosition(ccpsprite(0.5, 0.5, itemSprite))
    menu:ignoreAnchorPointForPosition(false)
    itemSprite:addChild(menu)

    pItem:setAnchorPoint(ccp(0.5, 0.5))
    pItem:setPosition(ccpsprite(0.5, 0.5, menu))
    menu:addChild(pItem)

    return itemSprite
end




