-- FileName:CountryWarCheerListLayer.lua
-- Author:FQQ
-- Data:2015-11-22
-- Purpose:国战助威界面
module ("CountryWarCheerListLayer",package.seeall)
require "script/ui/countryWar/cheer/CountryWarCheerService"
require "script/ui/countryWar/cheer/CountryWarCheerController"
require "script/ui/countryWar/cheer/CountryWarCheerData"
require "script/ui/tip/AlertTip"
require "script/ui/countryWar/rank/CountryWarRankLayer"
local kLeftSupportId = 1
local kRightSupoortId = 2
local _priority = nil   --优先级
local _zOrder   = nil   --z轴
local _layer    = nil
local _centerLayer = nil
local _centerSize = nil
local countryId1 = nil
local countryId2 = nil
local _serverIdMap = nil
-- local _btnTabel = nil
local mySupportHero = nil
local width = nil
local height = nil
local forceId = nil
local _user =nil
local _enterBtn = nil

function init( ... )
    _priority = nil
    _zOrder = nil
    _layer = nil
    _centerLayer = nil
    _centerSize = nil
    _serverIdMap = nil
    countryId1 = nil
    -- _btnTabel = nil
    mySupportHero = nil
    countryId2 = nil
    width = nil
    height = nil
    forceId = nil
    _user =nil
    _enterBtn = nil

end

local kCampImagePathMap = {
    "images/country_war/signup/wei.png",
    "images/country_war/signup/shu.png",
    "images/country_war/signup/wu.png",
    "images/country_war/signup/qun.png",
}

--事件注册
function onTouchesHandler( eventType )
    if(eventType == "began")then
        return true
    elseif(eventType == "moved")then
        print("moved")
    elseif(eventType == "end")then
        print("end")
    end
end

function onNodeEvent( event )
    if(event == "enter")then
        _layer:registerScriptTouchHandler(onTouchesHandler,false,_priority,true)
        _layer:setTouchEnabled(true)
    elseif(event == "exit")then
        _layer:unregisterScriptTouchHandler()
        CountryWarObserver.removeListener(phaseChangedCallBack)
    end
end



function create(p_touchPriority, p_zOrder)
    init()
    _priority = p_touchPriority or -500
    _zOrder = p_zOrder or 10
    _layer = CCLayer:create()
    _layer:registerScriptHandler(onNodeEvent)
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setAnchorPoint(ccp(0,0))
    _layer:addChild(menu)
    menu:setTouchPriority(-610)

    _centerLayer = CCLayer:create()
    _layer:addChild(_centerLayer)


    -- 进入赛场按钮
    _enterBtn = LuaCC.create9ScaleMenuItem("images/common/btn/anniu_blue_btn_n.png","images/common/btn/anniu_blue_btn_h.png",CCSizeMake(180,70),GetLocalizeStringBy("fqq_021"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    _enterBtn:setAnchorPoint(ccp(0.5,1))
    _enterBtn:setPosition(ccps(0.5, 0.19))
    _enterBtn:setScale(g_fScaleX)
    menu:addChild(_enterBtn)
    _enterBtn:registerScriptTapHandler(enterCallfunc)

    -- 特效
    _enterBtneffect = XMLSprite:create("images/country_war/effect/jinrusaichang/jinrusaichang",60)
    _enterBtneffect:setScale(0.85)
    _enterBtneffect:setVisible(false)
    _enterBtneffect:setAnchorPoint(ccp(0.5,0.5))
    _enterBtneffect:setPosition(ccpsprite(0.5,0.5,_enterBtn))
    _enterBtn:addChild(_enterBtneffect)

    -- 注册对阶段变更的侦听
    CountryWarObserver.registerListener(phaseChangedCallBack)

    local curStage = CountryWarMainData.getCurStage()
    if(curStage >= CountryWarDef.FINALTION_READY)then
        phaseChangedCallBack(curStage)
    end
    --倒计时
    local cuntdownTime = CountryWarUtil.getCountdownSprite()
    cuntdownTime:setAnchorPoint(ccp(0.5, 1))
    cuntdownTime:setScale(g_fScaleX)
    cuntdownTime:setPosition(ccps(0.5, 0.1))
    _layer:addChild(cuntdownTime, 50)
    addSubLayer()

    return _layer
end
function phaseChangedCallBack( phase )
    if (phase >= CountryWarDef.FINALTION_READY) then
        _enterBtneffect:setVisible(true)
    else
        _enterBtneffect:setVisible(false)
    end
end
function addSubLayer( ... )
    --判断切入哪个界面
    local stage = CountryWarMainData.getCurStage()
    if stage == CountryWarDef.FINALTION_READY  or stage == CountryWarDef.FINALTION then
        --创建我的助威界面
        createMySupportInfoLayer()
        return
    end
    -- local side = CountryWarCheerData.isSupportedSide()F
    if CountryWarCheerData.isSupportedSide() then
        createCheerSideLayer()
    else
        if CountryWarCheerData.isSupportedUser() == false then
            --创建助威选手界面
            createCheerPlayerLayer()
        else
            --创建我的助威界面
            createMySupportInfoLayer()
        end
    end
end


--第一个界面
function createCheerSideLayer( ... )

    local width = g_winSize.width
    local height = g_winSize.height
    --国战.大决战背景
    local redSprite = CCSprite:create("images/country_war/redsprite.png")
    redSprite:setAnchorPoint(ccp(0.5,1))
    redSprite:setPosition(ccp(width*0.5,height*0.87))
    redSprite:setScale(g_fScaleX)
    _centerLayer:addChild(redSprite)

    print("国家~~~~~")
    print_t(countryId)

    local forceInfo = CountryWarCheerData.getForceInfo()
    local leftInfo = forceInfo["1"]
    -- --左边势力
    local leftSprite = CCSprite:create(kCampImagePathMap[tonumber(leftInfo[1])])
    leftSprite:setAnchorPoint(ccp(0,1))
    leftSprite:setScale(g_fScaleX*0.4)
    leftSprite:setPosition(ccp(15,height*0.75))
    _centerLayer:addChild(leftSprite)


    local leftSprite2 = CCSprite:create(kCampImagePathMap[tonumber(leftInfo[2])])
    leftSprite2:setAnchorPoint(ccp(0,1))
    leftSprite2:setScale(g_fScaleX*0.4)
    leftSprite2:setPosition(ccp(leftSprite:getPositionX()+leftSprite:getContentSize().width*g_fScaleX*0.2,height*0.75))
    _centerLayer:addChild(leftSprite2)

    -- --右边势力
    local forceInfo = CountryWarCheerData.getForceInfo()
    local rightInfo = forceInfo["2"]

    local rightSprite = CCSprite:create(kCampImagePathMap[tonumber(rightInfo[1])])
    rightSprite:setScale(g_fScaleX*0.4)
    rightSprite:setAnchorPoint(ccp(1,1))
    rightSprite:setPosition(ccp(g_winSize.width - 15*g_fScaleX,height*0.75))
    _centerLayer:addChild(rightSprite)

    local rightSprite2 = CCSprite:create(kCampImagePathMap[tonumber(rightInfo[2])])
    rightSprite2:setScale(g_fScaleX*0.4)
    rightSprite2:setAnchorPoint(ccp(1,1))
    rightSprite2:setPosition(ccp(g_winSize.width - 15*g_fScaleX - rightSprite:getContentSize().width*g_fScaleX*0.2,height*0.75))
    _centerLayer:addChild(rightSprite2)


    --中间vs图标
    local vsSprite = CCSprite:create("images/arena/vs.png")
    vsSprite:setScale(g_fScaleX)
    vsSprite:setAnchorPoint(ccp(0.5,1))
    vsSprite:setPosition(ccp(width*0.5,height*0.7))
    _centerLayer:addChild(vsSprite)
    local menu = CCMenu:create()
    menu:setTouchPriority(-610)
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    _centerLayer:addChild(menu)
    --左右助威按钮
    local btn = CCMenuItemImage:create("images/country_war/zhuwei.png","images/country_war/zhuwei2.png")
    btn:setScale(g_fScaleX)
    btn:setAnchorPoint(ccp(0,1))
    btn:setPosition(ccp(leftSprite2:getPositionX() + leftSprite2:getContentSize().width*g_fScaleX*0.5*0.2,height*0.48))
    menu:addChild(btn,1,kLeftSupportId)
    btn:registerScriptTapHandler(cheerTeamCallfunc)
    print("1")
    local btn2 = CCMenuItemImage:create("images/country_war/zhuwei.png","images/country_war/zhuwei2.png")
    btn2:setAnchorPoint(ccp(1,1))
    btn2:setScale(g_fScaleX)
    btn2:setPosition(ccp(rightSprite2:getPositionX()-15*g_fScaleX,height*0.48))
    menu:addChild(btn2,1,kRightSupoortId)
    btn2:registerScriptTapHandler(cheerTeamCallfunc)
    print("2")

    --请选择助威势力
    local chooseLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_024"),g_sFontName,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    chooseLabel:setColor(ccc3(0x00,0xe4,0xff))
    chooseLabel:setScale(g_fScaleX)
    chooseLabel:setAnchorPoint(ccp(0.5,1))
    chooseLabel:setPosition(ccp(width*0.5,height*0.38))
    _centerLayer:addChild(chooseLabel)
    --让字体闪动
    arrowAction(chooseLabel)
    --获得可获得金币
    local richInfo = {
        lineAlignment = 2,
        labelDefaultColor = ccc3( 0xff, 0xff, 0xff),
        labelDefaultFont = g_sFontPangWa,
        labelDefaultSize = 25,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png",
            },
            {
                text = CountryWarCheerData.getSideIncon(),
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0xf6, 0x00),
            }
        }
    }
    local priceLabel = GetLocalizeLabelSpriteBy_2("fqq_023", richInfo)
    priceLabel:setScale(g_fScaleX)
    priceLabel:setAnchorPoint(ccp(0, 1))
    priceLabel:setPosition(ccp(width*0.27,height*0.33))
    _centerLayer:addChild(priceLabel)
end

--第二个界面
function createCheerPlayerLayer( )

    local width = g_winSize.width
    local height = g_winSize.height

    --快捷助威
    createMemberList()
    --我的助威势力
    createMySupportSide()

    if(CountryWarCheerData.isSupportedUser() == false)then
        -- 特效
        local effect = XMLSprite:create("images/country_war/effect/yingxiongbang/yingxiongbang",60)
        effect:setAnchorPoint(ccp(0.5,0))
        effect:setPosition(ccp(width*0.5,height*0.71))
        effect:setScale(g_fScaleX)
        _centerLayer:addChild(effect)

        local menu = CCMenu:create()
        menu:setPosition(ccp(0,0))
        menu:setAnchorPoint(ccp(0,0))
        menu:setTouchPriority(-610)
        effect:addChild(menu)

        --英雄榜
        local width1 = effect:getContentSize().width
        local height1 = effect:getContentSize().height
        _btn = CCMenuItemImage:create("images/country_war/signup/hero_h.png","images/country_war/signup/hero_n.png")
        _btn:setScale(0.9)
        _btn:setAnchorPoint(ccp(0.5,0.5))
        _btn:setPosition(ccp(width1*0.5,height1*0.5))
        menu:addChild(_btn)
        _btn:registerScriptTapHandler(heroRankCallback)

        -- 点击英雄榜助威
        local label = CCRenderLabel:create(GetLocalizeStringBy("fqq_028"),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
        label:setColor(ccc3(0x00,0xe4,0xff))
        label:setScale(g_fScaleX)
        label:setPosition(ccp(width*0.4,height*0.65))
        _centerLayer:addChild(label)
        arrowAction(label)
        --获得可获得金币
        local richInfo = {
            lineAlignment = 2,
            labelDefaultColor = ccc3(0xff, 0xff, 0xff),
            labelDefaultFont = g_sFontPangWa,
            labelDefaultSize = 21,
            defaultType = "CCRenderLabel",
            elements = {
                {
                    ["type"] = "CCSprite",
                    image = "images/common/gold.png",
                },
                {
                    text = CountryWarCheerData.getUserIncon(),
                    type = "CCRenderLabel",
                    color = ccc3(0xff, 0xf6, 0x00),
                }
            }
        }
        local priceLabel = GetLocalizeLabelSpriteBy_2("fqq_025", richInfo)
        priceLabel:setScale(g_fScaleX)
        priceLabel:setAnchorPoint(ccp(0,0))
        priceLabel:setPosition(ccp(width*0.3,height*0.58))
        _centerLayer:addChild(priceLabel)


    end
end

--第三个界面
function createMySupportInfoLayer( ... )
    local width = g_winSize.width
    local height = g_winSize.height

    --我的助威势力
    createMySupportSide()
    --快捷助威
    createMemberList()
    print("第三界面快捷助威")
    local supportLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_022"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    supportLabel:setColor(ccc3(0xff,0xf6,0x00))
    supportLabel:setScale(g_fScaleX)
    supportLabel:setPosition(ccp(_centerLayer:getContentSize().width*0.1,height*0.72))
    _centerLayer:addChild(supportLabel)

    --创建我助威的英雄
    local  mySupportHero = CountryWarCheerData.getMySupportUserInfo()
    print("创建我的助威~~~~~~")
    print_t(mySupportHero)
    --若没有助威玩家
    if table.isEmpty(mySupportHero)  then
        local label = CCRenderLabel:create(GetLocalizeStringBy("fqq_029"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
        label:setColor(ccc3(0xff, 0xff, 0xff))
        label:setScale(g_fScaleX)
        label:setPosition(ccp(width*0.13+supportLabel:getContentSize().width*g_fScaleX,height*0.72))
        _centerLayer:addChild(label)
        return
    end
    local dressId = 0
    if mySupportHero.dress then
        dressId = mySupportHero.dress["1"] or 0
    end
    -- 宝座
    local baseChairSp = CCSprite:create("images/carnival/normal_stage.png")
    baseChairSp:setAnchorPoint(ccp(0.5,1))
    baseChairSp:setPosition(ccps(0.5,0.7))
    baseChairSp:setScale(g_fScaleX*0.75)
    _centerLayer:addChild(baseChairSp)

    print("mySupportHero.htid",mySupportHero.htid)
    print("dressId",dressId)
    local heroIncon =  HeroUtil.getHeroBodySpriteByHTID(mySupportHero.htid, dressId)
    heroIncon:setScale(0.3)
    heroIncon:setAnchorPoint(ccp(0.5,0))
    heroIncon:setPosition(ccpsprite(0.5, 0.3, baseChairSp))
    baseChairSp:addChild(heroIncon)

    --玩家名字
    local nameStr = mySupportHero.uname or " "
    local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    name:setColor(ccc3(0x00,0xe4,0xff))
    name:setAnchorPoint(ccp(0.5,0))
    name:setPosition(ccpsprite(0.5, -0.2, baseChairSp))
    baseChairSp:addChild(name)
    --服务器名字
    local serverName = mySupportHero.server_name or ""
    print("serverName",serverName)
    local serverNameLabel = CCRenderLabel:create( serverName , g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    serverNameLabel:setColor(ccc3(0xff,0xff,0xff))
    serverNameLabel:setAnchorPoint(ccp(0.5,0))
    serverNameLabel:setPosition(ccpsprite(0.5, -0.5, baseChairSp))
    baseChairSp:addChild(serverNameLabel)

    local richInfo = {
        lineAlignment = 2,
        labelDefaultColor = ccc3(0xff, 0xff, 0xff),
        labelDefaultFont = g_sFontPangWa,
        labelDefaultSize = 21,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png",
            },
            {
                text = CountryWarCheerData.getUserIncon(),
                type = "CCRenderLabel",
                color = ccc3(0xff, 0xf6, 0x00),
            }
        }
    }
    local priceLabel = GetLocalizeLabelSpriteBy_2("fqq_039", richInfo)
    priceLabel:setScale(g_fScaleX)
    priceLabel:setAnchorPoint(ccp(0,0))
    priceLabel:setPosition(ccp(width*0.65,height*0.7))
    _centerLayer:addChild(priceLabel)

end


--[[
    @des:创建快捷助威选手
--]]
function createMemberList( ... )

    local width = g_winSize.width
    local height = g_winSize.height
    --标题
    local titleBg = CCSprite:create("images/country_war/signup/wenzi1.png")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(ccp(g_winSize.width / 2,height * 0.57))
    titleBg:setScale(g_fScaleX)
    _centerLayer:addChild(titleBg)
    -- 标题两遍的装饰
    local decorationLeft = CCSprite:create("images/country_war/signup/decoration.png")
    decorationLeft:setAnchorPoint(ccp(0,0.5))
    decorationLeft:setPosition(ccp( 5,height * 0.55))
    decorationLeft:setScale(g_fScaleX*0.9)
    _centerLayer:addChild(decorationLeft)
    local decorationRight = CCSprite:create("images/country_war/signup/decoration.png")
    decorationRight:setAnchorPoint(ccp(0,0.5))
    decorationRight:setPosition(ccp(width -5,decorationLeft:getPositionY()))
    decorationRight:setRotation(180)
    decorationRight:setScale(g_fScaleX*0.9)
    decorationRight:setFlipY(true)
    _centerLayer:addChild(decorationRight)

    --获取助威的选手
    local memberInfo =  CountryWarCheerData.getMemberInfo()
    print("获取助威的选手")
    print_t(memberInfo)
    -- _btnTabel = {}
    _serverIdMap = {}
    for k,v in pairs(memberInfo) do
        print(k,v)
    -- end
    -- for i=1,#memberInfo do
        -- local member = memberInfo[i]
        local member = memberInfo[k]
        print("member.pid",member.pid)
        print("member.server_id",member.server_id)
        _serverIdMap[tonumber(member.pid)] = tonumber(member.server_id)
        -- 宝座
        local baseChairSp = CCSprite:create("images/carnival/normal_stage.png")
        baseChairSp:setAnchorPoint(ccp(0.5,1))
        baseChairSp:setPosition(ccps(0.125+0.25*(k-1), 0.4))
        baseChairSp:setScale(g_fScaleX*0.92)
        _centerLayer:addChild(baseChairSp)


        local dressId = member.dress["1"] or 0
        print("member.htid",member.htid)
        print("dressId",dressId)
        local heroIncon =  HeroUtil.getHeroBodySpriteByHTID(member.htid, dressId)
        heroIncon:setScale(0.35)
        heroIncon:setAnchorPoint(ccp(0.5,0))
        heroIncon:setPosition(ccpsprite(0.5, 0.3, baseChairSp))
        baseChairSp:addChild(heroIncon)

        --玩家名字
        local nameStr = member.uname or " "
        local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        name:setColor(ccc3(0x00,0xe4,0xff))
        name:setAnchorPoint(ccp(0.5,0))
        name:setPosition(ccpsprite(0.5, -0.15, baseChairSp))
        baseChairSp:addChild(name)
        --服务器名字
        local serverName = member.server_name or ""
        local serverNameLabel = CCRenderLabel:create( serverName , g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        serverNameLabel:setColor(ccc3(0xff,0xff,0xff))
        serverNameLabel:setAnchorPoint(ccp(0.5,0))
        serverNameLabel:setPosition(ccpsprite(0.5, -0.48, baseChairSp))
        baseChairSp:addChild(serverNameLabel)

        --人气
        local renqi = CCRenderLabel:create(GetLocalizeStringBy("fqq_032"),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
        renqi:setColor(ccc3(0xff,0xf6,0x00))
        renqi:setAnchorPoint(ccp(0,1))
        renqi:setPosition(ccp(15,10-name:getContentSize().height - serverNameLabel:getContentSize().height))
        baseChairSp:addChild(renqi)

        local fansNum = tonumber(member.fans_num) or ""
        local fansNumLabel = CCRenderLabel:create(fansNum,g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
        fansNumLabel:setColor(ccc3(0xff,0xf6,0x00))
        fansNumLabel:setAnchorPoint(ccp(0,1))
        fansNumLabel:setPosition(ccp(15+renqi:getContentSize().width,10-name:getContentSize().height - serverNameLabel:getContentSize().height))
        baseChairSp:addChild(fansNumLabel)

        local normalSprite  = CCSprite:create("images/country_war/zhuwei.png")
        local selectSprite  = CCSprite:create("images/country_war/zhuwei2.png")
        local disabledSprite = BTGraySprite:create("images/country_war/zhuwei.png")

        local menu = CCMenu:create()
        menu:setPosition(ccp(0,0))
        menu:setAnchorPoint(ccp(0,0))
        menu:setTouchPriority(-610)
        baseChairSp:addChild(menu)

        local btn = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
        btn:setScale(0.9)
        btn:setAnchorPoint(ccp(0.5,1))
        btn:setPosition(ccpsprite(0.48, -0.98, baseChairSp))
        menu:addChild(btn,1,tonumber(member.pid))
        btn:registerScriptTapHandler(cheerCallfunc)
        if CountryWarCheerData.isSupportedUser() then
            btn:setEnabled(false)
        end
        local curStage = CountryWarMainData.getCurStage()
        if curStage >  CountryWarDef.SUPPORT then
            btn:setEnabled(false)
        end
    end
end

--[[
    @des:创建我的助威势力
--]]
function createMySupportSide()
    local width = g_winSize.width
    local height = g_winSize.height
    -- local mySide = CountryWarCheerData.getSide()
    --我助威的势力
    local label1 = CCRenderLabel:create(GetLocalizeStringBy("fqq_019"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    label1:setColor(ccc3(0xff,0xf6,0x00))
    label1:setScale(g_fScaleX)
    label1:setAnchorPoint(ccp(0,0))
    label1:setPosition(ccp(_centerLayer:getContentSize().width*0.1,height*0.8))
    _centerLayer:addChild(label1)
    --如果没有助威势力
    if CountryWarCheerData.isSupportedSide() then

        local label = CCRenderLabel:create(GetLocalizeStringBy("fqq_029"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
        label:setColor(ccc3(0xff, 0xff, 0xff))
        label:setScale(g_fScaleX)
        label:setPosition(ccp(width*0.017+label1:getPositionX()+label1:getContentSize().width*g_fScaleX,height*0.833))
        _centerLayer:addChild(label)
    return
    end
    local spriteOfForce = {
        "images/country_war/signup/sw.png",
        "images/country_war/signup/ss.png",
        "images/country_war/signup/ssw.png",
        "images/country_war/signup/sq.png",
    }
    local mySide = CountryWarCheerData.getSide()

    local forceInfo = CountryWarCheerData.getForceInfo()
    local counrtyInfo = forceInfo[tostring(mySide)]
    local forceCountry = CCSprite:create(spriteOfForce[tonumber(counrtyInfo[1])])
    forceCountry:setScale(g_fScaleX)
    forceCountry:setPosition(ccp(label1:getPositionX()+label1:getContentSize().width*g_fScaleX,height*0.77))
    _centerLayer:addChild(forceCountry)
    local forceCountry2 = CCSprite:create(spriteOfForce[tonumber(counrtyInfo[2])])
    forceCountry2:setScale(g_fScaleX)
    forceCountry2:setPosition(ccp(forceCountry:getPositionX()+forceCountry:getContentSize().width*g_fScaleX ,height*0.77))
    _centerLayer:addChild(forceCountry2)

    local richInfo = {
        lineAlignment = 2,
        labelDefaultColor = ccc3(0xff, 0xff, 0xff),
        labelDefaultFont = g_sFontPangWa,
        labelDefaultSize = 21,
        defaultType = "CCRenderLabel",
        elements = {
            {
                text = GetLocalizeStringBy("keybu0_101"),
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0xff, 0xff),
            },
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png",
            },
            {
                text = CountryWarCheerData.getSideIncon(),
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0xf6, 0x00),
            }
        }
    }
    local priceLabel = LuaCCLabel.createRichLabel(richInfo)
    priceLabel:setScale(g_fScaleX)
    priceLabel:setAnchorPoint(ccp(0,0))
    priceLabel:setPosition(ccp(width*0.65,height*0.8))
    _centerLayer:addChild(priceLabel)
end


--助威势力
function cheerTeamCallfunc( tag,item )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local showCallfunc = function ( ... )
        local side = tag
        --助威国家
        local callback = function ( ... )
            -- --把当前界面清除掉
            _centerLayer:removeFromParentAndCleanup(true)
            _centerLayer = CCLayer:create()
            _layer:addChild(_centerLayer)
            --创建助威选手界面
            createCheerPlayerLayer()
        end
        CountryWarCheerController.supportOneCountry(side, callback)
    end

    AlertTip.showAlert( GetLocalizeStringBy("fqq_027"), showCallfunc, false, nil)
end

--助威玩家的回调
function cheerCallfunc( tag,item )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local showCallfunc = function ( ... )
        local playerPid = tag
        local serverId  = _serverIdMap[playerPid]
        print("playerPid",playerPid)
        print("serverId",serverId)
        local requestCallback = function ( ... )
            --刷新助威列表
            updateSupportInfo()
        end
        CountryWarCheerController.supportOneUser(playerPid, serverId, requestCallback)
    end
    AlertTip.showAlert( GetLocalizeStringBy("fqq_027"), showCallfunc, false, nil)
end

function updateSupportInfo( )
    --助威某个人
    _centerLayer:removeFromParentAndCleanup(true)
    _centerLayer = CCLayer:create()
    _layer:addChild(_centerLayer)
    createMySupportInfoLayer()
end

function heroRankCallback( ... )
    CountryWarRankLayer.show()
end

-- --进入决赛按钮的回调
function enterCallfunc( ... )

    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local curStage = CountryWarMainData.getCurStage()
    --决赛没有开始
    if curStage <  CountryWarDef.FINALTION_READY then
        AnimationTip.showTip(GetLocalizeStringBy("lcyx_2007"))
        return
    end
    --没有报名不能进入赛场
    if not CountryWarSignData.isSignedUp() then
        AnimationTip.showTip(GetLocalizeStringBy("fqq_033"))
        return
    end
    --是否拥有决赛资格
    if not CountryWarMainData.isEnterFinal() then
        AnimationTip.showTip(GetLocalizeStringBy("fqq_033"))
        return
    end
    require "script/ui/countryWar/war/CountryWarPlaceLayer"
    CountryWarPlaceLayer.showLayer()
end

function arrowAction( arrow)
    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(1))
    arrActions_2:addObject(CCFadeIn:create(1))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    arrow:runAction(action_2)
end




























