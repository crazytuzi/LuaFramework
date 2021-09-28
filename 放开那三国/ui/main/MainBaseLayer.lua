-- Filename: MainBaseLayer.lua
-- Author: fang
-- Date: 2013-07-04
-- Purpose: 该文件用于: 主场景中间层内容


-- 主场景中间层模块声明
module ("MainBaseLayer", package.seeall)
require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/main/MainScene"
require "script/ui/tip/AnimationTip"
require "script/audio/AudioUtil"
require "script/ui/mail/MailData"
require "script/ui/friend/FriendData"
require "script/ui/guild/city/CityData"
require "script/ui/guild/GuildDataCache"
require "script/ui/achie/AchieveInfoData"
require "script/ui/title/TitleData"

-- 图片路径
local IMG_PATH="images/main/"
local IMG_PATH_SUB = IMG_PATH .. "sub_icons/"

local _main_base_layer = nil

_ksTagRecycle      = 2002       -- 炼化炉
_ksTagMail         = 2003       -- 邮件
_ksTagFriend       = 2004       -- 好友
_ksTagChat         = 2005       -- 聊天
_ksTagMenu         = 2006       -- 菜单
_ksTagFair         = 3001       -- 名将
_ksTagHero         = 3002       -- 武将
_ksTagEquip        = 3003       -- 装备
_ksTagHoroscope    = 3004       -- 占星坛
_ksTagDestiny      = 3005       -- 天命
_ksTagBoss         = 3006       -- 世界boss
_ksTagArmyTeam     = 4001       -- 军团
_ksTagFightSoul    = 4002       -- 战魂
_ksTagEveryDay     = 4003       -- 每日任务
_ksTagPet          = 4004       -- 宠物
_ksTagShop         = 4005       -- 商店
_mask_layer_tag    = 5000
_ksTagAchievement  = 5002       -- 成就
_ksTagRank         = 5005       -- 排行榜系统入口   add by DJN
_ksConvert         = 5006       -- 转换按钮
_ksTagGodWeapon    = 5007       -- 神兵背包
_ksSeal            = 5008       -- 兵符
_ksTagTitle        = 5009       -- 称号系统 add by lgx 20160504
_ksTagChariot      = 5010       -- 战车系统 add by lgx 20160630

local ksNewEffectTag       = 10
local _nFirstLineCount     = 6     -- 第一排按钮下标
local _nSecondLineCount    = 12    -- 第二排按钮下标
local _isShowChatAnimation = false
local _isAstroAlert        = false
local _cmMenuBar           = nil
local everydayBtn          = nil
local menuPanel            = nil
local _menuPanelMenu       = nil
local _functionMaksLayer   = nil
local function_button      = nil
local _mainMenu            = nil
-- 子模块结构
local _sub_modules={
    -- 商店按钮
    {name="shop", tag=_ksTagShop, pos_x=20, pos_y=0},
    {name="recycle", tag=_ksTagRecycle, pos_x=120, pos_y=0},
    -- {name="godweapon", tag=_ksTagGodWeapon, pos_x=110, pos_y=0},
    {name="guild", tag=_ksTagArmyTeam, pos_x=225, pos_y=0},
    {name="pet", tag=_ksTagPet, pos_x=330, pos_y=0},
    -- {name="seal", tag=_ksSeal, pos_x=430, pos_y=0},
    -- 战车 add by lgx 20160630
    {name="chariot", tag=_ksTagChariot, pos_x=430, pos_y=0},
    {name="menu", tag=0, pos_x=530, pos_y=0},

    -- 第二栏数据
    {name="fair", tag=_ksTagFair, pos_x=20, pos_y= 0 },
    {name="hero", tag=_ksTagHero, pos_x=120, pos_y= 0},
    {name="equip", tag=_ksTagEquip, pos_x=225, pos_y=0},
    {name="horoscope", tag=_ksTagHoroscope, pos_x=330, pos_y=0},
    -- added by zhz 天命
    {name="destiny", tag=_ksTagDestiny, pos_x=420, pos_y=0},
    -- add by licong 战魂
    {name="fightSoul", tag=_ksTagFightSoul, pos_x=530, pos_y=0},

    -- 最后 上排
    {name="everyday", tag=_ksTagEveryDay, pos_x=265, pos_y=0, anchorPoint = ccp(0,1)},

}

-- 获取主页菜单图片完整路径
local function getImagePath(filename, isHighlighted)
    if isHighlighted then
        return IMG_PATH_SUB .. filename .. "_h.png"
    end
    return IMG_PATH_SUB .. filename .. "_n.png"
end

local function menu_item_tap_handler(tag, item_obj)
    require "script/model/DataCache"

    --点击音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 炼化炉按钮事件
    if (tag == _ksTagRecycle) then
        ---[==[炼化炉 新手引导屏蔽层 第1步changLayer
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.06
        require "script/guide/NewGuide"
        require "script/guide/ResolveGuide"
        if(NewGuide.guideClass ==  ksGuideResolve and ResolveGuide.stepNum == 1) then
            ResolveGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]
        -- 功能节点判断
        if not DataCache.getSwitchNodeState(ksSwitchResolve) then
            return
        end
        require "script/ui/refining/RefiningMainLayer"
        RefiningMainLayer.createLayer(true)
        -- 邮件按钮事件
    elseif (tag == _ksTagMail) then
        local mailButton = getMainMenuItem(_ksTagMail)
        if(mailButton ~= nil)then
            local button = tolua.cast(mailButton,"CCMenuItemImage")
            if(button:getChildByTag(10) ~= nil)then
                button:removeChildByTag(10,true)
                require "script/ui/mail/MailData"
                MailData.setHaveNewMailStatus( "false" )
            end
        end
        -- 进入邮件系统
        require "script/ui/mail/Mail"
        MainScene.changeLayer(Mail.createMailLayer(), "Mail")
        -- 好友按钮事件
    elseif tag == _ksTagFriend then
        require "script/ui/friend/FriendLayer"
        local friendLayer = FriendLayer.creatFriendLayer()
        MainScene.changeLayer(friendLayer, "friendLayer")
        -- 聊天按钮事件
    elseif (tag == _ksTagChat) then
        require "script/ui/chat/ChatMainLayer"
        ChatMainLayer.showChatLayer()

    elseif (tag == _ksTagShop) then
        if not DataCache.getSwitchNodeState(ksSwitchShop, false) then
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip(GetLocalizeStringBy("fqq_009"))
            return
        end
        require "script/ui/shopall/ShoponeLayer"
        ShoponeLayer.show()
        -- 菜单按钮事件
    elseif tag == _ksTagMenu then
        require "script/ui/menu/CCMenuLayer"
        local ccMenuLayer = CCMenuLayer.createMenuLayer()
        MainScene.changeLayer(ccMenuLayer, "ccMenu")
        -- 排行榜系统按钮事件-------------add by DJN 20140916 ----------------
    elseif tag == _ksTagRank then
        require "script/model/user/UserModel"
        if(tonumber(UserModel.getHeroLevel()) >= 20)then
            require "script/ui/rank/RankLayer"
            local ccRankLayer = RankLayer.showLayer()
            MainScene.changeLayer(ccRankLayer, "RankLayer")
        else
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip(GetLocalizeStringBy("djn_51"))
        end
        -------------------------------------------------------------------
        -- 装备按钮事件
    elseif (tag == _ksTagEquip) then
        require "script/ui/bag/BagLayer"
        local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
        MainScene.changeLayer(bagLayer, "bagLayer")
        -- ”占星“按钮事件
    elseif (tag == _ksTagHoroscope) then
        ---[==[占星 新手引导屏蔽层
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.29
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuideAstrology) then
            require "script/guide/AstrologyGuide"
            AstrologyGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]
        if not DataCache.getSwitchNodeState(ksSwitchStar) then
            return
        end
        require "script/ui/astrology/AstrologyLayer"
        local astrologyLayer = AstrologyLayer.createAstrologyLayer()
        MainScene.changeLayer(astrologyLayer, "AstrologyLayer",AstrologyLayer.exitAstro)

        -- ”名将“按钮事件
    elseif (tag == _ksTagFair) then
        ---[==[名将 新手引导屏蔽层
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.29
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuideGreatSoldier) then
            require "script/guide/StarHeroGuide"
            StarHeroGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]
        ---[==[武将列传 新手引导屏蔽层
        ---------------------新手引导---------------------------------
        --add by licong 2014.5.27
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuideHeroBiography) then
            require "script/guide/LieZhuanGuide"
            LieZhuanGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]
        if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
            return
        end
        require "script/ui/star/StarLayer"
        local starLayer = StarLayer.createLayer()
        MainScene.changeLayer(starLayer, "starLayer")


        -- GetLocalizeStringBy("key_1453")按钮事件
    elseif (tag == _ksTagHero) then
        ---[==[强化所新手引导屏蔽层
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.06
        require "script/guide/NewGuide"
        if(NewGuide.guideClass ==  ksGuideForge) then
            require "script/guide/StrengthenGuide"
            StrengthenGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]
        if not DataCache.getSwitchNodeState(ksSwitchGeneralTransform) then
            return
        end
        -- 进入武将系统

        --武将进阶
        require "script/guide/NewGuide"
        require "script/guide/GeneralUpgradeGuide"
        if(NewGuide.guideClass ==  ksGuideGeneralUpgrade) then
            GeneralUpgradeGuide.changeLayer()
        end

        ---[==[武将进化 新手引导屏蔽层
        ---------------------新手引导---------------------------------
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuideHeroDevelop) then
            require "script/guide/HeroDevelopGuide"
            HeroDevelopGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]
        require "script/ui/hero/HeroLayer"
        MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")

    elseif(tag== _ksTagDestiny ) then
        ---[==[天命 新手引导屏蔽层
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.29
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuideDestiny) then
            require "script/guide/DestinyGuide"
            DestinyGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]
        ---[==[ 主角换技能 新手引导屏蔽层
        ---------------------新手引导---------------------------------
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuideChangeSkill) then
            require "script/guide/ChangeSkillGuide"
            ChangeSkillGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]
        -- 天命入口
        if not DataCache.getSwitchNodeState(ksSwitchDestiny) then
            return
        end
        require "script/ui/destiny/DestinyLayer"
        local destinyLayer = DestinyLayer.createLayer()
        MainScene.changeLayer(destinyLayer, "destinyLayer")
    elseif(tag== _ksTagArmyTeam) then
        -- 军团入口
        if not DataCache.getSwitchNodeState(ksSwitchGuild) then
            return
        end
        -- 设置小红圈false
        GuildDataCache.setIsShowRedTip(false)
        require "script/ui/guild/GuildImpl"
        GuildImpl.showLayer()
        -- require "script/ui/holidayhappy/HolidayHappyLayer"
        -- local layer = HolidayHappyLayer.create()
        -- MainScene.changeLayer(layer,"HolidayHappyLayer")

    elseif(tag== _ksTagFightSoul) then
        -- 战魂入口
        if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
            return
        end
        require "script/ui/huntSoul/HuntSoulLayer"
        local layer = HuntSoulLayer.createHuntSoulLayer()
        MainScene.changeLayer(layer, "huntSoulLayer")
    elseif(tag== _ksTagEveryDay) then
        -- -- 每日任务入口
        if not DataCache.getSwitchNodeState(ksSwitchEveryDayTask) then
            return
        end
        require "script/ui/everyday/EverydayLayer"
        EverydayLayer.showEverydayLayer()
    elseif(tag== _ksTagPet) then
        -- 宠物入口
        ---[==[宠物 新手引导屏蔽层
        ---------------------新手引导---------------------------------
        --add by licong 2013.09.29
        require "script/guide/NewGuide"
        if(NewGuide.guideClass == ksGuidePet) then
            require "script/guide/PetGuide"
            PetGuide.changLayer()
        end
        ---------------------end-------------------------------------
        --]==]
        if not DataCache.getSwitchNodeState(ksSwitchPet) then
            return
        end
        require "script/ui/pet/PetMainLayer"
        local layer= PetMainLayer.createLayer()
        MainScene.changeLayer(layer, "PetMainLayer")
    elseif(tag == _ksTagAchievement) then
        --成就入口
        print("achievement enter")
        require "script/ui/achie/AchievementLayer"
        showLayer = AchievementLayer.createLayer()
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        runningScene:addChild(showLayer, 1000)
    elseif(tag == _ksTagGodWeapon) then
        -- 神兵背包入口
        require "script/ui/bag/BagLayer"
        local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_GodWeapon)
        MainScene.changeLayer(bagLayer, "bagLayer")
    -- elseif(tag == _ksSeal) then
    --     -- 兵符入口
    --     if not DataCache.getSwitchNodeState(ksSwitchTally) then
    --         return
    --     end
    --     require "script/ui/bag/BagLayer"
    --     local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Tally)
    --     MainScene.changeLayer(bagLayer, "bagLayer")
    elseif(tag == _ksConvert) then
        --TODO 转换按钮
        require "script/ui/transform/TransformMainLayer"
        TransformMainLayer.showLayer()
    elseif(tag == _ksTagTitle) then
        -- 称号系统入口
        -- print("称号系统入口")
        require "script/ui/title/TitleMainLayer"
        TitleMainLayer.showLayer()
    elseif(tag == _ksTagChariot) then
        -- 战车系统入口
        print("进入战车系统")
        require "script/ui/chariot/ChariotMainLayer"
        ChariotMainLayer.showLayer()
    else
        error("error tag button");
    end
end


----------------------------------------------------------------------
-- 创建tipsprite图片
function createTipSprite(item )
    require "script/ui/rechargeActive/ActiveCache"
    require "script/utils/ItemDropUtil"

    local tipSprite= CCSprite:create("images/common/tip_2.png")
    tipSprite:setPosition(ccp(item:getContentSize().width*0.97, item:getContentSize().height*0.98))
    tipSprite:setAnchorPoint(ccp(1,1))
    item:addChild(tipSprite,1)

    if(ActiveCache.hasTipInActive() == false) then
        tipSprite:setVisible(false)
    end
end


--刷新功能按钮上的红点
function refreshRedBtn()
    -- body
    if(_main_base_layer~=nil)then
        local isRed = AchieveInfoData.getRedStatus()
        print("isRed2",isRed)
        -- 添加称号红点
        local isNeedShow = TitleData.isNeedShowRedTip()
        -- print("refreshRedBtn isNeedShow",isNeedShow)
        -- 兵符按钮上的提示红圈
        -- local isShowTip = BagUtil.isShowTallyTipSprite()
        -- showTipSprite(_main_base_layer:getChildByTag(999):getChildByTag(0),(isRed or isNeedShow) or isShowTip)
        showTipSprite(_main_base_layer:getChildByTag(999):getChildByTag(0),isRed or isNeedShow)
        showTipSprite(_main_base_layer:getChildByTag(1):getChildByTag(1):getChildByTag(_ksTagAchievement),isRed)
        showTipSprite(_main_base_layer:getChildByTag(1):getChildByTag(1):getChildByTag(_ksTagTitle),isNeedShow)
        -- showTipSprite(_main_base_layer:getChildByTag(1):getChildByTag(1):getChildByTag(_ksSeal),isShowTip)
    end
end

function create()
    everydayBtn = nil
    _main_base_layer = MainScene.createBaseLayer(nil, true, true, true)

    _mainMenu = CCMenu:create()
    _cmMenuBar = _mainMenu
    -- _mainMenu:setPosition(0, _main_base_layer:getContentSize().height*0.05)
    _mainMenu:setPosition(0, 0)
    _mainMenu:setAnchorPoint(ccp(0, 0))

    -- 第一排
    local y_01 = _main_base_layer:getContentSize().height*0.05
    -- 第二排
    local y_02 = _main_base_layer:getContentSize().height*0.23

    -- 每日任务专用
    local y_03 = _main_base_layer:getContentSize().height*0.98
    -- 资源矿临时
    local y_04 = _main_base_layer:getContentSize().height*0.5
    for i=1, _nFirstLineCount do
        _sub_modules[i].pos_y = y_01
    end
    for i=_nFirstLineCount+1, _nSecondLineCount do
        _sub_modules[i].pos_y = y_02
    end

    -- 每日任务专用
    _sub_modules[#_sub_modules].pos_y = y_03
    
    for i=1, #_sub_modules do

        local menu_item = nil
        if(_sub_modules[i].name == "menu") then
            --创建功能按钮
            local normal = CCMenuItemImage:create("images/main/sub_icons/function_h.png", "images/main/sub_icons/function_h.png")
            local hight  = CCMenuItemImage:create("images/main/sub_icons/function_n.png", "images/main/sub_icons/function_n.png")
            hight:setAnchorPoint(ccp(0.5, 0.5))
            normal:setAnchorPoint(ccp(0.5, 0.5))
            menu_item = CCMenuItemToggle:create(normal)
            menu_item:setAnchorPoint(ccp(0, 0))
            menu_item:addSubItem(hight)
            menu_item:registerScriptTapHandler(function_button_callback)
            function_button = menu_item

            local menu = CCMenu:create()
            menu:setAnchorPoint(ccp(0,0))
            menu:setPosition(ccp(0, 0))
            menu:setTouchPriority(-400)
            _main_base_layer:addChild(menu,3002,999)
            menu:addChild(menu_item, 3, _sub_modules[i].tag)

            -- added by zhz 功能按钮，怎家小红圈
            -- if(FriendData.getIsShowTipSprite() or MailData.getHaveNewMailStatus()== "true" or MailData.getHaveNewMailStatus()== true) then
            --     showTipSprite(menu_item,true)
            -- end

        else
            menu_item=CCMenuItemImage:create(getImagePath(_sub_modules[i].name), getImagePath(_sub_modules[i].name, true))
            menu_item:registerScriptTapHandler(menu_item_tap_handler)
            _mainMenu:addChild(menu_item, 1, _sub_modules[i].tag)
        end
        -- menu_item:setPosition(MainScene.getMenuPositionInTruePointByLayer(_main_base_layer,_main_base_layer:getContentSize().width*(_sub_modules[i].pos_x/g_originalDeviceSize.width), _sub_modules[i].pos_y))
        menu_item:setPosition(ccp(_sub_modules[i].pos_x*g_fScaleX/MainScene.elementScale, _sub_modules[i].pos_y/MainScene.elementScale))
        if(_sub_modules[i].anchorPoint)then
            menu_item:setAnchorPoint(_sub_modules[i].anchorPoint)
        else
            menu_item:setAnchorPoint(ccp(0,0))
        end

        if(_sub_modules[i].name=="chat")then
            local animSprite = XMLSprite:create("images/base/effect/chat/liaotian")
            animSprite:setAnchorPoint(ccp(0.5,0.5))
            animSprite:setPosition(ccp(menu_item:getContentSize().width*0.52,menu_item:getContentSize().height*0.55))
            menu_item:addChild(animSprite,1,1911)
            animSprite:setVisible(_isShowChatAnimation)

            -- 私人聊天的提示 , added by zhz
            local pChatTipSp= CCSprite:create("images/common/tip_2.png")
            pChatTipSp:setAnchorPoint(ccp(1,1))
            pChatTipSp:setPosition(ccp(menu_item:getContentSize().width*0.97 ,menu_item:getContentSize().height*0.98))
            menu_item:addChild(pChatTipSp,1,1914)
            require "script/ui/chat/ChatMainLayer"
            pChatTipSp:setVisible(ChatMainLayer.getNewPmCount() > 0)
        end

        -- if(_sub_modules[i].name=="horoscope")then
        --     local alertSprite = CCSprite:create("images/common/tip_2.png")
        --     alertSprite:setAnchorPoint(ccp(0.5,0.5))
        --     alertSprite:setPosition(ccp(menu_item:getContentSize().width*0.8,menu_item:getContentSize().height*0.8))
        --     menu_item:addChild(alertSprite,1,1915)
        --     alertSprite:setVisible(_isAstroAlert)
        -- end
        -- if _sub_modules[i].name== "guild" then
        --     -- 军团小红圈
        --     -- print("CityData.getIsShowTip()",CityData.getIsShowTip())
        --     -- print("GuildDataCache.isShowTip()",GuildDataCache.isShowTip())
        --     -- print("GuildDataCache.getIsShowRedTip()",GuildDataCache.getIsShowRedTip())
        --     if( GuildDataCache.getIsShowRedTip() )then
        --         local alertSprite = CCSprite:create("images/common/tip_2.png")
        --         alertSprite:setAnchorPoint(ccp(0.5,0.5))
        --         alertSprite:setPosition(ccp(menu_item:getContentSize().width*0.8,menu_item:getContentSize().height*0.8))
        --         menu_item:addChild(alertSprite,1,1998)
        --     end
        -- end
        if _sub_modules[i].name== "everyday" then
            everydayBtn = menu_item
            everydayBtn:setVisible(false)
        end

        require "script/ui/pet/PetData"
        if _sub_modules[i].name == "pet" then
            if PetData.isShowTip() or PetData.productTip() then
                local alertSprite = CCSprite:create("images/common/tip_2.png")
                alertSprite:setAnchorPoint(ccp(0.5,0.5))
                alertSprite:setPosition(ccp(menu_item:getContentSize().width*0.8,menu_item:getContentSize().height*0.8))
                menu_item:addChild(alertSprite,1,1998)
            end
        end

        -- 如果功能节点开启天命，DataCache.getSwitchNodeState(ksSwitchDestiny, false) 中的 false 表示不显示提示框
        -- if _sub_modules[i].name == "destiny" and DataCache.getSwitchNodeState(ksSwitchDestiny, false) then
        --     require "script/ui/destiny/DestinyData"
        --     --如果当前有天命可以点
        --     if DestinyData.canUpDestiny() then
        --         local alertSprite = CCSprite:create("images/common/tip_2.png")
        --         alertSprite:setAnchorPoint(ccp(0.5,0.5))
        --         alertSprite:setPosition(ccp(menu_item:getContentSize().width*0.8,menu_item:getContentSize().height*0.8))
        --         menu_item:addChild(alertSprite,1,1998)
        --     end
        -- end

    end

    -- init function panel
    menuPanel = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
    menuPanel:setContentSize(CCSizeMake(520,147))
    menuPanel:setAnchorPoint(ccp(1, 0))
    menuPanel:setPosition(function_button:getPositionX()*MainScene.elementScale + function_button:getContentSize().width/2*MainScene.elementScale, function_button:getPositionY()*MainScene.elementScale + function_button:getContentSize().height/2*MainScene.elementScale)
    _main_base_layer:addChild(menuPanel, 3000, 1)
    function_button:setSelectedIndex(0)
    menuPanel:setScale(0)

    _menuPanelMenu = CCMenu:create()
    _menuPanelMenu:setAnchorPoint(ccp(0,0))
    _menuPanelMenu:setPosition(ccp(0,0))
    menuPanel:addChild(_menuPanelMenu,1,1)
    _menuPanelMenu:setTouchPriority(-400)

    --好友按钮
    local friendButton=CCMenuItemImage:create(getImagePath("friend"), getImagePath("friend", true))
    friendButton:registerScriptTapHandler(menu_item_tap_handler)
    _menuPanelMenu:addChild(friendButton, 1, _ksTagFriend)
    friendButton:setAnchorPoint(ccp(0, 0.5))
    --邮件按钮
    local mailButton=CCMenuItemImage:create(getImagePath("mail"), getImagePath("mail", true))
    mailButton:registerScriptTapHandler(menu_item_tap_handler)
    _menuPanelMenu:addChild(mailButton, 1, _ksTagMail)
    mailButton:setAnchorPoint(ccp(0, 0.5))

    --成就按钮
    local achievementButton=CCMenuItemImage:create(getImagePath("achiev"), getImagePath("achiev", true))
    achievementButton:registerScriptTapHandler(menu_item_tap_handler)
    _menuPanelMenu:addChild(achievementButton, 1, _ksTagAchievement)
    achievementButton:setAnchorPoint(ccp(0, 0.5))
    -- local isRed = AchieveInfoData.getRedStatus()
    -- print("isRed1",isRed)
    -- showTipSprite(achievementButton,isRed)

    --菜单按钮
    local menuButton=CCMenuItemImage:create(getImagePath("menu"), getImagePath("menu", true))
    menuButton:registerScriptTapHandler(menu_item_tap_handler)
    _menuPanelMenu:addChild(menuButton, 1, _ksTagMenu)
    menuButton:setAnchorPoint(ccp(0, 0.5))

    --add by DJN 2014/9/3 新增排行榜系统 -------------------------------------------------------------------------------
    require "script/model/user/UserModel"
    --if(UserModel.getHeroLevel()>20)then
    --排行榜系统按钮
    local rankButton  = CCMenuItemImage:create(getImagePath("rank"), getImagePath("rank", true))
    rankButton:registerScriptTapHandler(menu_item_tap_handler)
    _menuPanelMenu:addChild(rankButton, 1, _ksTagRank)
    rankButton:setAnchorPoint(ccp(0, 0.5))

    --聊天按钮
    local chatButton = CCMenuItemImage:create(getImagePath("chat"), getImagePath("chat", true))
    chatButton:registerScriptTapHandler(menu_item_tap_handler)
    _menuPanelMenu:addChild(chatButton, 1, _ksTagChat)
    chatButton:setAnchorPoint(ccp(0, 0.5))

    --转换按钮
    local convertButton  = CCMenuItemImage:create(getImagePath("convert"), getImagePath("convert", true))
    convertButton:registerScriptTapHandler(menu_item_tap_handler)
    _menuPanelMenu:addChild(convertButton, 1, _ksConvert)
    convertButton:setAnchorPoint(ccp(0, 0.5))

    -- 增加称号系统按钮 add by lgx 20160504
    local titleButton = CCMenuItemImage:create(getImagePath("title"), getImagePath("title", true))
    titleButton:registerScriptTapHandler(menu_item_tap_handler)
    _menuPanelMenu:addChild(titleButton, 1, _ksTagTitle)
    titleButton:setAnchorPoint(ccp(0, 0.5))

    -- 将兵符按钮移入功能 add by lgx 20160713
    -- local sealButton = CCMenuItemImage:create(getImagePath("seal"), getImagePath("seal", true))
    -- sealButton:registerScriptTapHandler(menu_item_tap_handler)
    -- _menuPanelMenu:addChild(sealButton, 1, _ksSeal)
    -- sealButton:setAnchorPoint(ccp(0, 0.5))

    -- 添加 成就 称号红点提示
    refreshRedBtn()

    menuPanel:setContentSize(CCSizeMake(450,130*2))
    -- menuPanel:setContentSize(CCSizeMake(450,130*3))
    local mw = 400/4
    local mh = 125
    local py = 130/2
    --第一排
    convertButton:setPosition(17 + mw*0,py + mh*1)
    rankButton:setPosition(17 + mw*1,py + mh*1)
    friendButton:setPosition(27 + mw*2, py + mh*1)
    achievementButton:setPosition(27 + mw*3, py + mh*1)
    --第二排
    titleButton:setPosition(27+ mw*0, py)
    mailButton:setPosition(27 +mw*1, py)
    chatButton:setPosition(27+ mw*2, py)
    menuButton:setPosition(27+ mw*3, py)
    --第三排
    -- sealButton:setPosition(27+ mw*0, py + mh*2)

    _main_base_layer:addChild(_mainMenu,0,7327)

    addWorldCarnivalButton()


    addTopButton()
    addMiddleButton()
    -- 新邮件提示 new

    MailData.isHaveNewMail = MailData.getHaveNewMailStatus()
    print("MainBaseLayer isHaveNewMail",MailData.isHaveNewMail)
    if(MailData.isHaveNewMail == "true" or MailData.isHaveNewMail == true )then
        require "script/ui/main/MainBaseLayer"
        local mailButton = MainBaseLayer.getMainMenuItem(_ksTagMail)
        if(mailButton ~= nil)then
            local button = tolua.cast(mailButton,"CCNode")
            if(button:getChildByTag(10) == nil)then
                local newAnimSprite = XMLSprite:create("images/mail/new/new")
                newAnimSprite:setPosition(ccp(button:getContentSize().width*0.5-20,button:getContentSize().height-10))
                button:addChild(newAnimSprite,3,10)
            end
        end
    end

    -- -- 天命按钮上提示红圈 added by zhangqiang
    -- require "script/ui/replaceSkill/ReplaceSkillData"
    -- local isShowTip = ReplaceSkillData.isShowTip()
    -- local menuItem = getMainMenuItem(_ksTagDestiny)
    -- showTipSprite(menuItem, isShowTip)

    -- 好友按钮上提示红圈
    -- require "script/ui/friend/FriendData"
    -- local isShowTip = FriendData.getIsShowTipSprite()
    -- local menuItem = getMainMenuItem( _ksTagFriend )
    -- print("friend isShowTip ---", isShowTip)
    -- showTipSprite(menuItem,isShowTip)

    -- 装备按钮上的提示红圈
    -- local isShowTip = BagUtil.isShowTipSprite()
    -- local menuItem = getMainMenuItem( _ksTagEquip )
    -- showTipSprite(menuItem,isShowTip)

    -- 名将按钮上的提示红圈
    -- require "script/ui/star/StarUtil"
    -- local isShowTip = StarUtil.isHaveTip()
    -- local menuItem = getMainMenuItem( _ksTagFair )
    -- showTipSprite(menuItem,isShowTip)

    --商店按钮的提示红圈
    require "script/ui/rechargeActive/ActiveCache"
    local isShowTip = ActiveCache.secretTip()
    local menuItem = getMainMenuItem( _ksTagShop )
    showTipSprite(menuItem,isShowTip)

    -- 兵符按钮上的提示红圈
    -- local isShowTip = BagUtil.isShowTallyTipSprite()
    -- local menuItem = getMainMenuItem( _ksSeal )
    -- showTipSprite(menuItem,isShowTip)

    -- 控制台
    if g_debug_mode then
        require "script/consoleExe/ConsoleBtn"
        ConsoleBtn.createConsoleBtn(_main_base_layer)
    end
    --武将按钮
    local heroButton = getMainMenuItem(_ksTagHero)
    require "script/model/hero/HeroModel"
    HeroModel.initNewHero()
    if(HeroModel.isHaveNewHero() == true) then
        local newAnimSprite = XMLSprite:create("images/mail/new/new")
        newAnimSprite:setPosition(ccp(heroButton:getContentSize().width*0.5-20,heroButton:getContentSize().height-20))
        heroButton:addChild(newAnimSprite,3,ksNewEffectTag)

        print("add new hero effect!!!")
    end
    
    -- if HeroModel.isShowHeroTip() then
    --     local tipSprite = CCSprite:create("images/common/tip_2.png")
    --     tipSprite:setAnchorPoint(ccp(0.5, 0.5))
    --     tipSprite:setPosition(ccpsprite(0.85,0.85, heroButton))
    --     heroButton:addChild(tipSprite)
    -- end

    return _main_base_layer
end

function setVisible(visible)
    if (type(visible) ~= type(true)) then
        CCLuaLog ("MainBaseLayer.setVisible needs a parameter.")
        return
    end
    if visible then
        _main_base_layer:setVisible(true)
    else
        _main_base_layer:setVisible(false)
    end
end

function showChatAnimation(isShow)
    _isShowChatAnimation = isShow
    local animSprite = nil
    if tolua.isnull(_menuPanelMenu) then
        return
    end
    if not tolua.isnull(_menuPanelMenu:getChildByTag(7327)) then
        if not tolua.isnull(_menuPanelMenu:getChildByTag(7327):getChildByTag(_ksTagChat)) then
            if _menuPanelMenu:getChildByTag(7327):getChildByTag(_ksTagChat):getChildByTag(1911) then
                animSprite = _menuPanelMenu:getChildByTag(7327):getChildByTag(_ksTagChat):getChildByTag(1911)
            end
        end
    end
    if animSprite then
        if(_isShowChatAnimation==true)then
            animSprite:setVisible(true)
        else
            animSprite:setVisible(false)
        end
    end
end


-- 显示聊天的小红圈, added by zhz
function showChatTip( tipNum)
    local tipNum= tonumber(tipNum)
    local tipSprite = nil 
    if tolua.isnull(_menuPanelMenu) then
        return
    end
    if not tolua.isnull(_menuPanelMenu:getChildByTag(7327)) then
        if not tolua.isnull(_menuPanelMenu:getChildByTag(7327):getChildByTag(_ksTagChat)) then
            if _menuPanelMenu:getChildByTag(7327):getChildByTag(_ksTagChat):getChildByTag(1914) then
                tipSprite = _menuPanelMenu:getChildByTag(7327):getChildByTag(_ksTagChat):getChildByTag(1914)
            end
        end
    end
    if tipSprite then
        if(tipNum> 0)then
            tipSprite:setVisible(true)
        else
            tipSprite:setVisible(false)
        end
    end
end

function showAstroAlert(isShow)
    _isAstroAlert = isShow
    --    print("showChatAnimation:",isShow,_main_base_layer,_main_base_layer:getChildByTag(7327))
    -- if(_main_base_layer~=nil and _main_base_layer:getChildByTag(7327)~=nil)then
    --     if(_isAstroAlert==true)then
    --         local animSprite = _main_base_layer:getChildByTag(7327):getChildByTag(_ksTagHoroscope):getChildByTag(1915)
    --         animSprite:setVisible(true)
    --     else
    --         local animSprite = _main_base_layer:getChildByTag(7327):getChildByTag(_ksTagHoroscope):getChildByTag(1915)
    --         animSprite:setVisible(false)
    --     end
    -- end
end

function exit( ... )
    _main_base_layer = nil
    _cmMenuBar  = nil
end

-- 释放“主场景中间层”所占资源
function release()

end

-- addBy licong 2013.09.06 用于新手引导
-- 获得菜单项各个项的对象
-- 参数为item的tag值
function getMainMenuItem(tag)
    print("_cmMenuBar == ",_cmMenuBar)
    print("tag == ",tag)
    if(_cmMenuBar == nil )then
        return
    end
    if(_cmMenuBar:getChildByTag(tag) ~= nil) then
        return _cmMenuBar:getChildByTag(tag)
    else
        return _menuPanelMenu:getChildByTag(tag)
    end
end

-- 得到每日任务按钮
function getEverydayBtn( ... )
    return everydayBtn
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


--[[
    @des :  删除新武将按钮提示
--]]
function removeNewHeroButton( ... )
    local menuItem  = getMainMenuItem(_ksTagHero)
    if(menuItem == nil ) then
        return
    end
    local effectNoe = tolua.cast(menuItem:getChildByTag(ksNewEffectTag), "CCNode")
    if(effectNoe == nil) then
        return
    end
    effectNoe:removeFromParentAndCleanup(true)
    print("remove new hero effect")
end

--[[
    @des    :   武将按钮添加new提示
--]]

function addNewHeroButton( ... )
    local heroButton = getMainMenuItem(_ksTagHero)
    if(heroButton == nil) then
        return
    end
    local effectNoe = tolua.cast(heroButton:getChildByTag(ksNewEffectTag), "CCNode")
    if(heroButton ~= nil and effectNoe == nil) then
        local newAnimSprite = XMLSprite:create("images/mail/new/new");
        newAnimSprite:setPosition(ccp(heroButton:getContentSize().width*0.5-20,heroButton:getContentSize().height-20))
        heroButton:addChild(newAnimSprite,3,ksNewEffectTag)
    end
end


--[[
    @des:功能按钮回调函数
--]]
function function_button_callback(tag, sender)
    local toggleItem  = tolua.cast(sender, "CCMenuItemToggle")
    local selectIndex = toggleItem:getSelectedIndex()

    if(selectIndex == 0) then
        print("toogle 0 select index:", selectIndex)
        menuPanel:stopAllActions()
        local action = CCScaleTo:create(0.2, 0)
        menuPanel:runAction(action)
        if(_functionMaksLayer) then
            _functionMaksLayer:removeFromParentAndCleanup(true)
        end
    else
        print("toogle select index:",selectIndex)
        showFuctionMaskLayer()
        menuPanel:stopAllActions()
        local action = CCScaleTo:create(0.2, 1 * MainScene.elementScale)
        menuPanel:runAction(action)
    end
end

--[[
    @des:显示功能按钮子菜单
--]]
function showFuctionMaskLayer( ... )
    local touchRect = getSpriteScreenRect(menuPanel)
    local layer = CCLayer:create()
    layer:setPosition(ccp(0, 0))
    layer:setAnchorPoint(ccp(0, 0))
    layer:setTouchEnabled(true)
    layer:setTouchPriority(-300)
    layer:registerScriptTouchHandler(function ( eventType,x,y )
        if(eventType == "began") then
            if(touchRect:containsPoint(ccp(x,y))) then
                return false
            else
                closeFunctionLayer()
                return true
            end
        end
    end,false, -300, true)
    local gw,gh = g_winSize.width/MainScene.elementScale, g_winSize.height/MainScene.elementScale
    local layerColor = CCLayerColor:create(ccc4(0,0,0,layerOpacity or 150),gw,gh)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0,0))
    layer:addChild(layerColor)
    _functionMaksLayer = layer
    local onRunningLayer = MainScene.getOnRunningLayer()
    onRunningLayer:addChild(layer,2500, _mask_layer_tag)
end

--[[
    @des:关闭功能菜单
--]]
function closeFunctionLayer()
    if not tolua.isnull(_functionMaksLayer) then
        menuPanel:stopAllActions()
        local action = CCScaleTo:create(0.2, 0)
        menuPanel:runAction(action)
        _functionMaksLayer:removeFromParentAndCleanup(true)
        _functionMaksLayer = nil
        function_button:setSelectedIndex(0)
    end
end



-- 添加测试按钮
function addHighlightsButton1()
    require "script/ui/main/MenuLayer"
    local cmiiHighlights = CCMenuItemImage:create("images/main/sub_icons/highlights_n.png", "images/main/sub_icons/highlights_h.png")
    cmiiHighlights:setPosition(185*g_fScaleX/MainScene.elementScale, _main_base_layer:getContentSize().height*0.78/MainScene.elementScale )
    cmiiHighlights:setAnchorPoint(ccp(0, 1))
    cmiiHighlights:registerScriptTapHandler(function ( )
        -- 符印背包入口
        require "script/ui/bag/BagLayer"
        local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Rune)
        MainScene.changeLayer(bagLayer, "bagLayer")
    end)
    local menu= CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:addChild(cmiiHighlights)
    _main_base_layer:addChild(menu,101)

end


function addTestBattleButton( ... )
    require "script/ui/main/MenuLayer"
    local cmiiHighlights = CCMenuItemImage:create("images/main/sub_icons/highlights_n.png", "images/main/sub_icons/highlights_h.png")
    cmiiHighlights:setPosition(285*g_fScaleX/MainScene.elementScale, _main_base_layer:getContentSize().height*0.58/MainScene.elementScale )
    cmiiHighlights:setAnchorPoint(ccp(0, 1))
    cmiiHighlights:registerScriptTapHandler(function ( )
        -- 符印背包入口
        print("new battle test")
        require "script/fight/FightScene"
        -- FightScene.showCopyFight(1, 1001, 0)
        FightScene.showFightWithString()
    end)
    local menu= CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:addChild(cmiiHighlights)
    _main_base_layer:addChild(menu,101)
end

--[[
    @des:巴别嘉年华入口
--]]
function addWorldCarnivalButton()
    local menu= CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setAnchorPoint(ccp(0,0))
    _main_base_layer:addChild(menu,101)

    local button= CCMenuItemImage:create("images/main/sub_icons/carnival_btn_n.png", "images/main/sub_icons/carnival_btn_h.png")
    button:setAnchorPoint(ccp(0.5, 0.5))
    button:setPosition(ccp(g_winSize.width*0.5/MainScene.elementScale, g_winSize.height*0.4/MainScene.elementScale))
    menu:addChild(button)

    local effect = XMLSprite:create("images/base/effect/shenvsshentubiao/shenvsshentubiao")
    effect:setPosition(ccpsprite(0.5, 0.5, button))
    button:addChild(effect)

    button:registerScriptTapHandler(function ( ... )
        require "script/ui/world_carnival/WorldCarnivalLayer"
        WorldCarnivalLayer.show()
    end)
    require "script/ui/world_carnival/WorldCarnivalData"
    if not WorldCarnivalData.isShowEnterButton() then
        button:setVisible(false)
    end
end

--[[
    @des:主界面上部按钮
--]]
function addTopButton()
    require "script/ui/main/MainMenuLayer"
    local avatarHeight = MainScene.getAvatarLayerContentSize().height
    local topButtonSprite = MainMenuLayer.createTopButton()
    local size = _main_base_layer:getContentSize()
    topButtonSprite:setPosition(ccp(0.5*size.width, size.height + 20))
    topButtonSprite:setAnchorPoint(ccp(0.5, 1))
    _main_base_layer:addChild(topButtonSprite)
end

--[[
    @des:中部小圈按钮
--]]
function addMiddleButton()
    require "script/ui/main/MainMenuLayer"
    local avatarHeight = MainScene.getAvatarLayerContentSize().height
    local topButtonSprite = MainMenuLayer.createMiddleButton()
    local size = _main_base_layer:getContentSize()
    topButtonSprite:setPosition(ccp(0.5*size.width, size.height*0.5))
    topButtonSprite:setAnchorPoint(ccp(0.5, 0.5))
    _main_base_layer:addChild(topButtonSprite)
end
