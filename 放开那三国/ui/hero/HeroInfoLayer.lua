-- Filename: HeroInfoLayer.lua
-- Author: fang
-- Date: 2013-08-05
-- Purpose: 该文件用于: 武将系统，信息页面

module("HeroInfoLayer", package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/ui/main/MenuLayer"
require "script/ui/hero/HeroPublicCC"
require "script/libs/LuaCC"
require "script/libs/LuaCCLabel"
require "script/libs/LuaCCSprite"
require "script/model/hero/HeroModel"
require "script/model/hero/FightForceModel"
require "script/model/affix/AffixDef"
require "script/ui/hero/HeroFightSimple"
require "db/DB_Awake_ability"
require "db/DB_Heroes"
require "db/skill"

local _isFromFormation             = nil    -- 标记是否从阵容中来
local _onRunningLayer              = nil    -- 当前正在运行的层
local _ccTitleLayer                = nil    -- 标题层
local _ccBottomLayer               = nil    -- 界面底部
local _heightOfHeroInfoLayer       = nil    -- 武将信息层所占高度
local _heightWithoutTitleAndBottom = nil    -- 刨去底层及标题栏所占高度
local _tHeroValue                  = nil
local _tParentParam                = nil    -- 来自父级界面的参数结构
local _cmiChangeHero               = nil
local _ccStrengthenButton          = nil    -- “强化”按钮
local _touchProperty               = nil
local _isHaveUpFormation           = nil
local _dressId                     = nil
local _delegation                  = nil
local _downArrowSp                 = nil
local _upArrowSp                   = nil
local _isExtHero                   = nil
local _zOrder                      = nil
local _bulletin_layer_is_visible   = nil
local _bgLayer                     = nil
local _contentScrollView           = nil

local affixScrollView              = nil
local changHeroCallbackFunc        = nil    -- 跟换武将事件
local heroInfoLayerDidLoad         = nil

local _ksTagChangeFriend           = 5001
local _ksTagDown                   = 5002
local _ksTagCloseBtn               = 1001   -- 关闭按钮tag


kHeroBagPos = 1
kFormationPos = 2


-- 模块进入初始化
function init( ... )
    _isFromFormation     = nil
    _cmiChangeHero       = nil
    _ccStrengthenButton  = nil
    _touchProperty       = nil
    _isExtHero           = nil
    _downArrowSp         = nil
    _upArrowSp           = nil
end

-- 创建英雄信息显示层, zOrder and touchPriority added by zhz
-- 既然页面要改版，那我就趁这个机会把这里写上必要的注释好了 added by Zhang Zihang
function createLayer(heroValue, tParam, zOrder, touchPriority, isHaveUpFormation, delegation, p_isExtHero)
    -- added by zhz
    init()
    _zOrder            = zOrder or 1500
    _touchProperty     = touchPriority or -700
    _isExtHero         = p_isExtHero
    _tHeroValue        = heroValue
    _delegation        = delegation
    _tParentParam      = tParam
    _isHaveUpFormation = isHaveUpFormation

    printTable("_tHeroValue", _tHeroValue)

    _bgLayer = CCLayer:create()
    -- 加载模块背景图
    local csBg = CCSprite:create("images/main/module_bg.png")
    csBg:setScale(g_fBgScaleRatio)
    _bgLayer:addChild(csBg)
    _bulletin_layer_is_visible = BulletinLayer.getLayer():isVisible()
    BulletinLayer.getLayer():setVisible(false)
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()

    -- 隐藏avatar层
    local ccObjAvatar = MainScene.getAvatarLayerObj()
    if not (tParam and tParam.isPanel) then
        ccObjAvatar:setVisible(false)
        MenuLayer.getObject():setVisible(false)
    end


    local layerRect = {}
    layerRect.width = g_winSize.width
    layerRect.height = g_winSize.height --- bulletinLayerSize.height*g_fScaleX
    _bgLayer:setContentSize(CCSizeMake(layerRect.width, layerRect.height))
    _bgLayer:setPosition(ccp(0, 0))

    -- 标题栏层
    -- 标题和关闭按钮那里
    local ccTitleLayer = createTitleLayer()
    local titleSize = ccTitleLayer:getContentSize()
    ccTitleLayer:setScale(g_fScaleX)
    ccTitleLayer:setPosition(ccp(0, layerRect.height-titleSize.height*g_fScaleX))
    -- 加入标题元素
    _bgLayer:addChild(ccTitleLayer, 10, -1)

    -- 内容区的实际高度
    local bgHeight = layerRect.height - ccTitleLayer:getContentSize().height*g_fScaleX

    -- 背景九宫格图
    local fullRect = CCRectMake(0, 0, 196, 198)
    local insetRect = CCRectMake(61, 80, 46, 36)
    local ccStarSellBG = CCScale9Sprite:create("images/hero/bg_ng.png", fullRect, insetRect)
    local preferredSize = {w=g_winSize.width, h = bgHeight+20}
    ccStarSellBG:setPreferredSize(CCSizeMake(preferredSize.w, preferredSize.h))
    ccStarSellBG:setPosition(ccp(0, -10))
    _bgLayer:addChild(ccStarSellBG)


    -- 创建界面底部元素
    local bottomHeight = createBottomPanel()
    local sizeOfHeroContent={width=g_winSize.width, height=bgHeight-bottomHeight}
    --主要内容的入口在这里 fnCreateDetailContentLayer 函数
    --好隐蔽的说
    local detailContentLayer, nHeight=fnCreateDetailContentLayer(sizeOfHeroContent)
    print("bottomHeight:", bottomHeight)
    detailContentLayer:setPosition(ccp(0, 5 + bottomHeight))
    _bgLayer:addChild(detailContentLayer)

    local function onTouches(event, x, y)
        return true
    end

    local  onNodeEvent = function ( pEvent )
        if pEvent == "enter" then
            _bgLayer:registerScriptTouchHandler(onTouches,false,_touchProperty,true)
            _bgLayer:setTouchEnabled(true)
        elseif pEvent == "exit" then
            _bgLayer:unregisterScriptTouchHandler()
            -- 停止英雄音效
            require "script/utils/SoundEffectUtil"
            SoundEffectUtil.stopHeroAudio()
        end
    end
    _bgLayer:registerScriptHandler(onNodeEvent)

    _onRunningLayer = _bgLayer

    if tParam and tParam.isPanel then
        csBg:setPosition(0, layerRect.height)
        csBg:setAnchorPoint(ccp(0, 1))
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        runningScene:addChild(_onRunningLayer, _zOrder, 1000)
    end
    if(heroInfoLayerDidLoad ~= nil) then
        heroInfoLayerDidLoad()
    end

    -- 英雄语音
    require "script/utils/SoundEffectUtil"
    local dbData = SoundEffectUtil.getHeroAudioDataByHtid(_tHeroValue.htid)
    if( dbData and dbData.information_sound )then
        SoundEffectUtil.playHeroAudio(dbData.information_sound)
    end

    return _bgLayer
end

-- 创建标题面板
function createTitleLayer( ... )
    require "script/libs/LuaCCSprite"
    local tLabel={
        text=GetLocalizeStringBy("key_1671"),
        fontsize=35,
        sourceColor=ccc3(0xff, 0xf0, 0x49),
        targetColor=ccc3(0xff, 0xa2, 0),
        tag=_ksTagCloseBtn,
        stroke_size=2,
        stroke_color=ccc3(0, 0, 0),
        anchorPoint=ccp(0.5, 0.5)
    }
    local csTitleBg = LuaCCSprite.createSpriteWithRenderLabel("images/common/title_bg.png", tLabel)
    local ccMenu = CCMenu:create()
    local cmiButtonClose = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    local tBgSize = csTitleBg:getContentSize()
    local tBtnSize = cmiButtonClose:getContentSize()
    cmiButtonClose:setAnchorPoint(ccp(1, 1))
    cmiButtonClose:setPosition(tBgSize.width+8, tBgSize.height+8)
    cmiButtonClose:registerScriptTapHandler(closeButtonCallback)
    ccMenu:setPosition(0, 0)

    ccMenu:setTouchPriority(_touchProperty-7 or -777)
    ccMenu:addChild(cmiButtonClose)
    csTitleBg:addChild(ccMenu)
    return csTitleBg
end

function fnCreateDetailContentLayer(viewSize)
    _contentScrollView = CCScrollView:create()
    _contentScrollView:setTouchPriority(_touchProperty-3 or -703)
    _contentScrollView:setViewSize(CCSizeMake(viewSize.width, viewSize.height+16))
    _contentScrollView:setDirection(kCCScrollViewDirectionVertical)
    local layer = CCLayer:create()
    _contentScrollView:setContainer(layer)

    local x=640/2
    local y=0
    local yOffset=8

    -- 简介
    local ccLayerIntroduction, nHeight = fnCreateIntroductionPanel()
    ccLayerIntroduction:setPosition(ccp(x, y))
    ccLayerIntroduction:setAnchorPoint(ccp(0.5, 0))
    layer:addChild(ccLayerIntroduction)
    y = y + nHeight + yOffset

    -- 觉醒
    print("创建觉醒中")
    print_t(_tHeroValue)

    --名字、国家
    local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
    if HeroModel.isNecessaryHero(_tHeroValue.htid) == true then
        --主角装备觉醒
        local ccSpriteAwaken, nHeight = fnCreateMasterTalentPanel()
        ccSpriteAwaken:setPosition(ccp(x, y))
        ccSpriteAwaken:setAnchorPoint(ccp(0.5, 0))
        layer:addChild(ccSpriteAwaken)
        y = y + nHeight + yOffset

    elseif(_tHeroValue.hid ~= nil) then
        local ccSpriteAwaken, nHeight = fnCreateAwakenPanel()
        ccSpriteAwaken:setPosition(ccp(x, y))
        ccSpriteAwaken:setAnchorPoint(ccp(0.5, 0))
        layer:addChild(ccSpriteAwaken)
        y = y + nHeight + yOffset
    end

    --武将天命
    if HeroModel.isNecessaryHero(_tHeroValue.htid) == false then
        if db_hero.star_lv >= 7 then
            local heroDestiny, nHeight = fnCreateHeroDestiny()
            heroDestiny:setPosition(ccp(x, y))
            heroDestiny:setAnchorPoint(ccp(0.5, 0))
            layer:addChild(heroDestiny)
            y = y + nHeight + yOffset
        end
    end

    -- 天赋
    local ccSpriteTalent, nHeight = fnCreateTalentPanel()
    ccSpriteTalent:setPosition(ccp(x, y))
    ccSpriteTalent:setAnchorPoint(ccp(0.5, 0))
    layer:addChild(ccSpriteTalent)
    y = y + nHeight + yOffset

    -- 羁绊
    local ccSpriteUnion, nHeight = fnCreateUnionPanel()
    if ccSpriteUnion then
        ccSpriteUnion:setPosition(ccp(x, y))
        ccSpriteUnion:setAnchorPoint(ccp(0.5, 0))
        layer:addChild(ccSpriteUnion)
        y = y + nHeight + yOffset
    end
    -- 神兵羁绊
    local ccSpriteGodUnion, nHeight = fnCreateGodUnionPanel()
    if ccSpriteGodUnion then
        ccSpriteGodUnion:setPosition(ccp(x, y))
        ccSpriteGodUnion:setAnchorPoint(ccp(0.5, 0))
        layer:addChild(ccSpriteGodUnion)
        y = y + nHeight + yOffset
    end
    -- 技能
    local ccSpriteSkill, nHeight = fnCreateSkillPanel()
    ccSpriteSkill:setPosition(ccp(x, y))
    ccSpriteSkill:setAnchorPoint(ccp(0.5, 0))
    layer:addChild(ccSpriteSkill)
    y = y + nHeight + yOffset
    -- 属性 武将三维
    local ccSpriteProperty,nHeight = fnCreatePropertyPanel()
    ccSpriteProperty:setPosition(ccp(x,y))
    ccSpriteProperty:setAnchorPoint(ccp(0.5,0))
    layer:addChild(ccSpriteProperty)
    y = y + nHeight + yOffset

    --背景
    local infoBgSprite = CCSprite:create("images/hero/info_bg.png")
    infoBgSprite:setAnchorPoint(ccp(0.5,0))
    infoBgSprite:setPosition(ccp(x,y))
    layer:addChild(infoBgSprite)
    y = y + infoBgSprite:getContentSize().height + yOffset

    
    --武将全身图
    local image_file = "images/base/hero/body_img/"..db_hero.body_img_id
    local dressId = _tHeroValue.dressId
    if(dressId and tonumber(dressId) > 0) then
        require "db/DB_Item_dress"
        require "script/model/utils/HeroUtil"
        local dressInfo = DB_Item_dress.getDataById(dressId)
        local genderId = HeroModel.getSex(_tHeroValue.htid)

        local dressImg =  HeroUtil.getStringByFashionString(dressInfo.changeBodyImg,genderId)
        if(dressImg) then
            image_file = "images/base/hero/body_img/" .. dressImg
        end
    end
    if _tHeroValue.hid then
        --武将加锁
        local menu = CCMenu:create()
        menu:setAnchorPoint(ccp(0, 0))
        menu:setPosition(0, 0)
        menu:setTouchPriority(_touchProperty -2)
        infoBgSprite:addChild(menu, 200)

        local lock = CCMenuItemImage:create("images/hero/hero_unlock_n.png", "images/hero/hero_unlock_h.png")
        lock:setAnchorPoint(ccp(0.5, 0.5))
        local unlock = CCMenuItemImage:create("images/hero/hero_lock_n.png", "images/hero/hero_lock_h.png")
        unlock:setAnchorPoint(ccp(0.5, 0.5))
        local heroLockBtn = CCMenuItemToggle:create(lock)
        heroLockBtn:addSubItem(unlock)
        heroLockBtn:setAnchorPoint(ccp(1, 1))
        heroLockBtn:setPosition(ccpsprite(0.97, 0.97, infoBgSprite))
        heroLockBtn:registerScriptTapHandler(heroLockBtnCallback)
        menu:addChild(heroLockBtn, 0)

        local lockStatus = HeroModel.getHeroLockStatusByHid(_tHeroValue.hid)
        if(lockStatus == 1) then
            heroLockBtn:setSelectedIndex(0)
        else
            heroLockBtn:setSelectedIndex(1)
        end
        if not HeroModel.getHeroByHid(_tHeroValue.hid) or HeroModel.isNecessaryHero(_tHeroValue.htid) then
            heroLockBtn:setVisible(false)
        end
        local heroDBInfo = DB_Heroes.getDataById(_tHeroValue.htid)
        if heroDBInfo then
            require "db/DB_Monsters_tmpl"
            heroDBInfo = DB_Monsters_tmpl.getDataById(_tHeroValue.htid)
        end
        if heroDBInfo.star_lv < 5 then
            heroLockBtn:setVisible(false)
        end
    end

    local yOffset = HeroPublicCC.getYOffset(db_hero.body_img_id)
    -- 全身像偏移量
    local genderId = HeroModel.getSex(_tHeroValue.htid)
    local offset = HeroUtil.getHeroBodySpriteOffsetByHTID(_tHeroValue.htid, dressId, _tHeroValue.turned_id)
    image_file = HeroUtil.getHeroBodyImgByHTID(_tHeroValue.htid, dressId, genderId, _tHeroValue.turned_id)
    local ccSpriteCardShow = CCSprite:create(image_file)
    ccSpriteCardShow:setPosition(infoBgSprite:getContentSize().width/2,60 - yOffset - offset)
    ccSpriteCardShow:setAnchorPoint(ccp(0.5,0))
    infoBgSprite:addChild(ccSpriteCardShow)

    local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    nameBgSprite:setPreferredSize(CCSizeMake(280,40))
    nameBgSprite:setAnchorPoint(ccp(0.5,0))
    nameBgSprite:setPosition(ccp(infoBgSprite:getContentSize().width/2,20))
    infoBgSprite:addChild(nameBgSprite)

    --名字
    --得到武将名称
    local heroName = _tHeroValue.name
    if _tHeroValue.hid then
        local heroInfo = HeroModel.getHeroByHid(_tHeroValue.hid)
        heroName = HeroModel.getHeroName(heroInfo)
    end
    if _tHeroValue.heorInfo then
        local heroInfo = HeroModel.getHeroByHid(_tHeroValue.heroInfo.hid)
        heroName = HeroModel.getHeroName(heroInfo)
    end

    local nameBgImage = "images/common/bg/bg_9s_2.png"
    if db_hero.star_lv == 8 then
        nameBgImage = "images/common/hero_name_bg.png"
    end
    local nameBgSprite = CCScale9Sprite:create(nameBgImage)
    nameBgSprite:setPreferredSize(CCSizeMake(280,40))
    nameBgSprite:setAnchorPoint(ccp(0.5,0))
    nameBgSprite:setPosition(ccp(infoBgSprite:getContentSize().width/2,20))
    infoBgSprite:addChild(nameBgSprite)
    if db_hero.star_lv == 8 then
        local nameBgEffect = XMLSprite:create("images/hero/mingmingdi/mingmingdi")
        nameBgEffect:setPosition(ccpsprite(0.5, 0.5, nameBgSprite))
        nameBgSprite:addChild(nameBgEffect)
    end

    local nameNode = {}
    nameNode[1] = CCRenderLabel:create(heroName,g_sFontPangWa,25,2,ccc3(0, 0, 0),type_stroke)
    nameNode[1]:setColor(HeroPublicLua.getCCColorByStarLevel(_tHeroValue.star_lv))
    if _tHeroValue.evolve_level and tonumber(_tHeroValue.evolve_level) > 0 then
        if(_tHeroValue.star_lv > 5) then
            nameNode[2] = LuaCC.createNumberSprite02("images/hero/transfer/numbers", _tHeroValue.evolve_level)
            nameNode[3] = CCRenderLabel:create(GetLocalizeStringBy("zzh_1159"), g_sFontPangWa, 25, 2, ccc3(0, 0, 0), type_stroke)
            nameNode[3]:setColor(ccc3(60, 239, 21))
        else
            nameNode[2] = CCSprite:create("images/hero/transfer/numbers/add.png")
            nameNode[3] = LuaCC.createNumberSprite02("images/hero/transfer/numbers", _tHeroValue.evolve_level)
        end
    end
    local nameAndEvolve = BaseUI.createHorizontalNode(nameNode)
    nameAndEvolve:setAnchorPoint(ccp(0.5,0.5))
    nameAndEvolve:setPosition(nameBgSprite:getContentSize().width/2,nameBgSprite:getContentSize().height/2)
    nameBgSprite:addChild(nameAndEvolve)

    --国家
    require "script/model/hero/HeroModel"
    local country_icon = HeroModel.getLargeCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
    local ccSpriteCountry = CCSprite:create(country_icon)
    ccSpriteCountry:setAnchorPoint(ccp(0.5,1))
    ccSpriteCountry:setPosition(ccp(0,nameBgSprite:getContentSize().height))
    nameBgSprite:addChild(ccSpriteCountry)

    --等级
    local lvSprite = CCSprite:create("images/common/lv.png")
    local lvLabel = CCRenderLabel:create(_tHeroValue.level,g_sFontPangWa,22,1,ccc3(0,0,0),type_stroke)
    lvLabel:setColor(ccc3(0xff,0xf6,0x00))

    local lvNode = BaseUI.createHorizontalNode({lvSprite,lvLabel})
    lvNode:setAnchorPoint(ccp(1,0))
    lvNode:setPosition(ccp(infoBgSprite:getContentSize().width/2 - 5,65))
    infoBgSprite:addChild(lvNode)

    --资质
    local ccSpriteFightValue = CCSprite:create("images/hero/potential.png")
    ccSpriteFightValue:setScale(28/38)
    local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
    local sFightValue = _tHeroValue.heroQuality
    if _tHeroValue.heroQuality == nil then
        sFightValue = db_hero.heroQuality
    end

    local ccLabelFightValue = CCRenderLabel:create(sFightValue, g_sFontPangWa,22,1,ccc3(0, 0, 0),type_stroke)
    ccLabelFightValue:setColor(ccc3(0xff,0x00,0))

    local qualityLabel = BaseUI.createHorizontalNode({ccSpriteFightValue,ccLabelFightValue})
    qualityLabel:setAnchorPoint(ccp(0,0))
    qualityLabel:setPosition(ccp(infoBgSprite:getContentSize().width/2 + 5,65))
    infoBgSprite:addChild(qualityLabel)

    --名将
    if db_hero.beauty_id then
        local csFamous = CCSprite:create("images/hero/famous.png")
        csFamous:setAnchorPoint(ccp(0.5,0))
        csFamous:setPosition(infoBgSprite:getContentSize().width - 115, 130)
        infoBgSprite:addChild(csFamous)
    end
    -- 设置container的坐标
    layer:setPosition(0, viewSize.height-y*g_fScaleX)
    layer:setContentSize(CCSizeMake(g_winSize.width, y))
    layer:setScale(g_fScaleX)

    if NewGuide.guideClass ~= ksGuideClose then
        local offset = _contentScrollView:getContentOffset()
        _contentScrollView:setContentOffset(ccp(offset.x, offset.y+50), false)
    end

    return _contentScrollView, y
end

--[[
    @des    :创建武将属性显示区域
    @param  :
    @return :创建好的区域
    @return :区域的高度   
--]]
function fnCreatePropertyPanel()
    local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=130}
    local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
    bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    -- 统帅、武力、智慧
    local tLabels = {
        {text=GetLocalizeStringBy("key_2739"), fontsize=25, color=ccc3(0x78, 0x25, 0)},
        {text=GetLocalizeStringBy("key_3340"), vOffset=15},
        {text=GetLocalizeStringBy("key_1090")},
    }

    local height_1 = 10
    local height_2 = 10
    local btnMap = {}
    if HeroModel.getHeroByHid(_tHeroValue.hid)then

        height_1 = 100
        height_2 = 100
        bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height + 100))
        if not HeroModel.isNecessaryHero(_tHeroValue.htid) then
            local forgeBtn = createButton(GetLocalizeStringBy("key_1277"), CCSizeMake(110, 60), fnHandlerOfStrengthenButton)
            _ccStrengthenButton = forgeBtn
            table.insert(btnMap, forgeBtn)
        end

        local evloveBtn = createButton(GetLocalizeStringBy("key_1730"), CCSizeMake(110, 60), evloveBtnCallback)
        table.insert(btnMap, evloveBtn)
        if HeroModel.isHeroCanPill(_tHeroValue.hid) then
            local pillBtn = createButton(GetLocalizeStringBy("lcyx_2023"), CCSizeMake(110, 60), pillBtnCallback)
            table.insert(btnMap, pillBtn)
        end

        local detailBtn = createButton(GetLocalizeStringBy("lcy_50109"), CCSizeMake(130, 60), checkFightSoulButtonCallback)
        table.insert(btnMap, detailBtn)
    end
    local btnNode = BaseUI.createHorizontalNode(btnMap, nil, nil, 35)
    btnNode:setAnchorPoint(ccp(1, 0.5))
    btnNode:setPosition(580, 50)
    bg_attr_ng:addChild(btnNode)

    local tLabel={text=GetLocalizeStringBy("key_1141"), fontsize=25, color=ccc3(0, 0, 0), pos=ccp(56, 20), anchor=ccp(0.5, 0.5)}
    local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)
    ccSpriteTitle:setAnchorPoint(ccp(0,0.5))
    ccSpriteTitle:setPosition(ccp(-5, bg_attr_ng:getContentSize().height))
    bg_attr_ng:addChild(ccSpriteTitle)

    local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
    tLabelObjs[1]:setPosition(ccp(30, height_1))
    bg_attr_ng:addChild(tLabelObjs[1])

    local sMagicDefend
    local sMagicAttack
    local sGeneralAttack
    local sPhysicalDefend
    local sPhysicalAttack
    local sHeroLife

    -- require "script/ui/hero/HeroFightForce"
    -- 如果武将没有hid，则表示为武魂数据
    local tForceValue
    -- 简单战斗力
    local tForceValue02
    if _tHeroValue.hid then
        tForceValue = FightForceModel.getHeroDisplayAffix(_tHeroValue.hid)
        sPhysicalDefend=tForceValue[AffixDef.PHYSICAL_DEFEND]
        sHeroLife=tForceValue[AffixDef.LIFE]
        sMagicDefend=tForceValue[AffixDef.MAGIC_DEFEND]
        sGeneralAttack=tForceValue[AffixDef.GENERAL_ATTACK]
    else
        tForceValue02 = HeroFightSimple.getAllForceValues(_tHeroValue)
        sMagicDefend=tForceValue02.magicDefend
        sGeneralAttack=tForceValue02.generalAttack
        sPhysicalDefend=tForceValue02.physicalDefend
        sHeroLife=tForceValue02.life
    end

    local tLabels = {}
    if tForceValue then
        table.insert(tLabels, {text=tForceValue[AffixDef.INTELLIGENCE], fontsize=25})
        table.insert(tLabels, {text=tForceValue[AffixDef.STRENGTH], vOffset=15})
        table.insert(tLabels, {text=tForceValue[AffixDef.COMMAND]})
    else
        table.insert(tLabels, {text=tForceValue02.intelligence, fontsize=25})
        table.insert(tLabels, {text=tForceValue02.strength, vOffset=15})
        table.insert(tLabels, {text=tForceValue02.command})
    end
    local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
    --兼容泰国版
    --added by Zhang Zihang
    if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
        tLabelObjs[1]:setPosition(ccp(105, height_1))
    else
        tLabelObjs[1]:setPosition(ccp(90, height_1))
    end
    bg_attr_ng:addChild(tLabelObjs[1])

    -- 基础属性值
    local tLabels = {
        {text=GetLocalizeStringBy("key_3032"), fontsize=22, color=ccc3(0x78, 0x25, 0)},
        {text=GetLocalizeStringBy("key_3033"), vOffset=6.5},
        {text=GetLocalizeStringBy("key_1649")},
        {text=GetLocalizeStringBy("key_1877")},
    }


    local addX = 200

    local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
    tLabelObjs[1]:setPosition(ccp(30+addX, height_2))
    bg_attr_ng:addChild(tLabelObjs[1])

    local tLabels = {
        -- 法防值
        {text=sMagicDefend, fontsize=22},
        -- 物防值
        {text=sPhysicalDefend, vOffset=6.5},
        -- 攻击值
        {text=sGeneralAttack},
        -- 生命值
        {text=sHeroLife},
    }
    local tLabelObjs = LuaCCLabel.createVerticalLabelHeelLabels(tLabels)
    --兼容泰国版
    --added by Zhang Zihang
    if(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
        tLabelObjs[1]:setPosition(ccp(105+addX, height_2))
    else
        tLabelObjs[1]:setPosition(ccp(90+addX, height_2))
    end
    bg_attr_ng:addChild(tLabelObjs[1])
    local nRealHeight = bg_attr_ng:getContentSize().height + ccSpriteTitle:getContentSize().height/2
    return bg_attr_ng,nRealHeight
end

-- 创建“简介”区域
function fnCreateIntroductionPanel()
    local tLabel={text=GetLocalizeStringBy("key_2371"), fontsize=25, color=ccc3(0, 0, 0), pos=ccp(56, 20), anchor=ccp(0.5, 0.5)}
    local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

    -- 九宫格图片原始九宫信息
    local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    -- 九宫格期望高度
    local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

    local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
    -- 武将描述信息
    local sHeroDesc = "        "
    if db_hero.desc then
        sHeroDesc = sHeroDesc .. db_hero.desc
    end
    local ccLabelDesc = LuaCCLabel.createMultiLineLabel({text=sHeroDesc, fontsize=22, color=ccc3(0x78, 0x25, 0), width=580})
    local x = 14
    local yOffset = 14
    local y = yOffset
    y = y + ccLabelDesc:getContentSize().height
    ccLabelDesc:setAnchorPoint(ccp(0, 1))
    ccLabelDesc:setPosition(x, y)
    bg_attr_ng:addChild(ccLabelDesc)
    -- 计算标题实际高度
    local nPreferredHeight = y + (yOffset + ccSpriteTitle:getContentSize().height)/2
    bg_attr_ng:addChild(ccSpriteTitle)
    -- 定位标题
    ccSpriteTitle:setPosition(ccp(-5, nPreferredHeight))
    ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

    bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, nPreferredHeight))
    local nRealHeight = nPreferredHeight + ccSpriteTitle:getContentSize().height/2
    return bg_attr_ng, nRealHeight
end


-- 创建“技能”区域面板
function fnCreateSkillPanel()
    local tLabel={text=GetLocalizeStringBy("key_1084"), fontsize=25, color=ccc3(0, 0, 0), pos=ccp(56, 20), anchor=ccp(0.5, 0.5)}
    local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

    -- cocos2d-x控件，是个二维数组 行x列.
    local ccObjs = {}
    local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=220}
    local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

    local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
    local normalSkill = skill.getDataById(db_hero.normal_attack)
    local rageSkill = skill.getDataById(db_hero.rage_skill_attack)

    --主角更换技能需要
    --added by Zhang Zihang
    --如果是主角
    require "script/model/user/UserModel"
    if HeroModel.isNecessaryHero(_tHeroValue.htid) and tostring(_tHeroValue.name) == UserModel.getUserName() then
        rageSkill = skill.getDataById(UserModel.getUserRageSkill())
        normalSkill = skill.getDataById(UserModel.getUserNormalSkill())
    end

    if _tHeroValue.attack_skill ~= nil then
        normalSkill = skill.getDataById(_tHeroValue.attack_skill)
    end

    if _tHeroValue.rage_skill ~= nil then
        rageSkill = skill.getDataById(_tHeroValue.rage_skill)
    end

    -- 同一行中的
    local tLabel = {text=GetLocalizeStringBy("key_2064"), color=ccc3(255, 255, 255), fontsize=25, tag=101}
    local ccSpriteAnger = LuaCCSprite.createSpriteWithLabel("images/hero/info/anger.png", tLabel)
    local sSkillName = rageSkill.name or ""
    local ccLabelSkill=CCLabelTTF:create(sSkillName.." ", g_sFontName, 22)
    ccLabelSkill:setColor(ccc3(0x85, 0, 0x7a))

    local nVarWidth = 542-ccLabelSkill:getContentSize().width
    local tLabel={text=rageSkill.des, width=nVarWidth,}
    -- 下面多行文本显示测试
    local ccLabelDesc = LuaCCLabel.createMultiLineLabel(tLabel)
    ccObjs[#ccObjs+1] = {}
    table.insert(ccObjs[#ccObjs], ccSpriteAnger)
    table.insert(ccObjs[#ccObjs], ccLabelSkill)
    table.insert(ccObjs[#ccObjs], ccLabelDesc)

    -- 同一行中的
    local tLabel = {text=GetLocalizeStringBy("key_1129"), color=ccc3(0xff, 0xff, 0xff), fontsize=25, tag=101}
    local ccSpriteNormal = LuaCCSprite.createSpriteWithLabel("images/hero/info/normal.png", tLabel)
    local skillName = normalSkill.name or ""
    local ccLabelSkill=CCLabelTTF:create(skillName.." ", g_sFontName, 22)
    ccLabelSkill:setColor(ccc3(0x85, 0, 0x7a))

    local nVarWidth = 542-ccLabelSkill:getContentSize().width
    local ccLabelDesc = LuaCCLabel.createMultiLineLabel({text=normalSkill.des, width=nVarWidth})
    ccObjs[#ccObjs+1] = {}
    table.insert(ccObjs[#ccObjs], ccSpriteNormal)
    table.insert(ccObjs[#ccObjs], ccLabelSkill)
    table.insert(ccObjs[#ccObjs], ccLabelDesc)

    local x=10
    local nHeightOfPanel = 10
    local nMaxHeightOnSameLine = 0
    if HeroModel.getHeroByHid(_tHeroValue.hid) and HeroModel.isNecessaryHero(_tHeroValue.htid) then
        nHeightOfPanel = 80
        local detailBtn = createButton(GetLocalizeStringBy("djn_30"), CCSizeMake(130, 60), changeSkillButtonCallback)
        detailBtn:setAnchorPoint(ccp(1, 0))
        detailBtn:setPosition(580, 10)
        bg_attr_ng:addChild(detailBtn, 20)
    end

    local arrCount = table.maxn(ccObjs)
    for i=1, arrCount do
        nMaxHeightOnSameLine = 0
        x = 10
        local objsLine = ccObjs[i]
        local nHeight02 = objsLine[2]:getContentSize().height
        local nHeight03 = objsLine[3]:getContentSize().height
        for k=1, table.maxn(objsLine) do
            if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
                nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
            end
            bg_attr_ng:addChild(objsLine[k])
        end
        local xOffset=10
        if nHeight03 > nHeight02 then
            local sizes = {}
            for k=1, table.maxn(objsLine) do
                sizes[k] = objsLine[k]:getContentSize()
            end
            objsLine[1]:setPosition(x, nHeightOfPanel + nHeight03 - sizes[1].height+((sizes[1].height-sizes[2].height)/2))
            x = x + sizes[1].width
            objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03 - sizes[2].height)
            x = x + sizes[2].width
            objsLine[3]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
            nHeightOfPanel = nHeightOfPanel + 6
        else
            local tCCNodes = {}
            for k=1, table.maxn(objsLine) do
                table.insert(tCCNodes, {ccObj=objsLine[k]})
            end
            tCCNodes[2].xOffset=10
            objsLine[1]:setPosition(x, nHeightOfPanel)
            LuaCC.hAlignCCNodesAsFirst(tCCNodes)
        end

        nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
    end
    nHeightOfPanel = nHeightOfPanel+4

    -- 设置9宫格实际高度
    nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    preferredSize.height = nHeightOfPanel
    bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    bg_attr_ng:addChild(ccSpriteTitle)
    -- 定位标题
    ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
    ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

    local nHeightOfSkillArea = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2

    return bg_attr_ng, nHeightOfSkillArea
end

-- 创建“天赋”区域面板
function fnCreateTalentPanel()
    local tLabel={text=GetLocalizeStringBy("key_2640"), fontsize=25, color=ccc3(0, 0, 0), pos=ccp(56, 20), anchor=ccp(0.5, 0.5)}
    local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

    -- 九宫格图片原始九宫信息
    local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    -- 九宫格期望高度
    local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

    local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
    local arrAwakeId = nil
    if db_hero.awake_id then
        arrAwakeId = string.split(db_hero.awake_id, ",")
    end
    local arrGrowAwakeId = nil
    if db_hero.grow_awake_id then
        arrGrowAwakeId = string.split(db_hero.grow_awake_id, ",")
    end
    -- 如果存在天赋ID
    local tAwakes = {}
    if arrAwakeId then
        for i=1, #arrAwakeId do
            tAwakes[#tAwakes+1] = {}
            local awake =  tAwakes[#tAwakes]
            awake.id = arrAwakeId[i]
            awake.evolve_level = 0
            awake.level = 0
        end
    end
    if arrGrowAwakeId then
        for i=1, #arrGrowAwakeId do
            tAwakes[#tAwakes+1] = {}
            local awake =  tAwakes[#tAwakes]
            local levelAndId = string.split(arrGrowAwakeId[i], "|")
            local awkae_type = tonumber(levelAndId[1])
            if awkae_type == 1 then
                awake.id = tonumber(levelAndId[3])
                awake.level = tonumber(levelAndId[2])
                awake.evolve_level = 0
            elseif awkae_type == 2 then
                awake.id = tonumber(levelAndId[3])
                awake.evolve_level = tonumber(levelAndId[2])
                awake.level = 0
            end
        end
    end

    local ccObjs = {}
    for i=1, #tAwakes do
        local v = tAwakes[i]
        local data = DB_Awake_ability.getDataById(v.id)
        local labelColor01 = ccc3(0xff, 0, 0)
        local labelColor02 = ccc3(0x78, 0x25, 0)

        local bLowLevel=false
        local bLowerEvolveLevel=false
        --print("_tHeroValue.level", _tHeroValue.level)
        --print("v.level", v.level)
        if _tHeroValue.evolve_level == nil then
            bLowLevel = true
        elseif tonumber(_tHeroValue.level) < v.level then
            bLowLevel = true
        end
        if _tHeroValue.evolve_level == nil then
            bLowerEvolveLevel = true
        elseif not bLowLevel and tonumber(_tHeroValue.evolve_level) < v.evolve_level then
            bLowerEvolveLevel = true
        end
        if bLowLevel or bLowerEvolveLevel then
            labelColor01 = ccc3(0x50, 0x50, 0x50)
            labelColor02 = ccc3(0x50, 0x50, 0x50)
        end

        ccObjs[#ccObjs+1] = {}
        local ccObj01 = CCLabelTTF:create(data.name, g_sFontName, 22)
        ccObj01:setAnchorPoint(ccp(0, 1))
        ccObj01:setColor(labelColor01)
        local ccObj02
        local richTextInfo = {}
        richTextInfo.width = 500 - ccObj01:getContentSize().width
        if bLowLevel and v.level > 0 then
            richTextInfo[2] = {content=data.des, ntype="label", color=labelColor02}
            richTextInfo[1] = {content=GetLocalizeStringBy("key_2162")..v.level..GetLocalizeStringBy("key_1066"), ntype="label", color=ccc3(0xff, 128,0)}
            ccObj02 = LuaCCLabel.createRichText(richTextInfo)
        elseif bLowerEvolveLevel then

            richTextInfo[2] = {content=data.des, ntype="label", color=labelColor02}
            local contentText = GetLocalizeStringBy("key_1648")
            if(tonumber(_tHeroValue.star_lv) == 6) then
                contentText =GetLocalizeStringBy("lcy_50112")
            end
            if(tonumber(_tHeroValue.star_lv) == 7) then
                contentText =GetLocalizeStringBy("lcyx_1973")
            end
            richTextInfo[1] = {content=contentText..v.evolve_level..GetLocalizeStringBy("key_1066"), ntype="label", color=ccc3(0xff, 128,0)}
            ccObj02 = LuaCCLabel.createRichText(richTextInfo)
        else
            richTextInfo[1] = {content=data.des, ntype="label", color=labelColor02}
            ccObj02 = LuaCCLabel.createRichText(richTextInfo)
        end
        table.insert(ccObjs[#ccObjs], ccObj01)
        table.insert(ccObjs[#ccObjs], ccObj02)
    end

    -- 如果武将没有天赋则显示“该武将没有天赋”标签
    if #ccObjs==0 then
        local ccObj01 = CCLabelTTF:create(GetLocalizeStringBy("key_2510"), g_sFontName, 22)
        ccObj01:setColor(ccc3(0x78, 0x25, 0))
        local ccObj02 = CCLabelTTF:create("  ", g_sFontName, 22)
        ccObj02:setColor(ccc3(0x78, 0x25, 0))
        ccObjs[#ccObjs+1] = {}
        ccObj01:setAnchorPoint(ccp(0, 1))
        ccObj02:setAnchorPoint(ccp(0, 1))
        table.insert(ccObjs[#ccObjs], ccObj01)
        table.insert(ccObjs[#ccObjs], ccObj02)
    end
    local tSorted = table.reverse(ccObjs)
    ccObjs = tSorted
    local x=60
    local nHeightOfPanel = 10
    local nMaxHeightOnSameLine = 0

    local arrCount = table.maxn(ccObjs)
    for i=1, arrCount do
        nMaxHeightOnSameLine = 0
        local objsLine = ccObjs[i]
        local nHeight02 = objsLine[1]:getContentSize().height
        local nHeight03 = objsLine[2]:getContentSize().height
        for k=1, table.maxn(objsLine) do
            if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
                nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
            end
            bg_attr_ng:addChild(objsLine[k])
        end
        local xOffset=10
        x=60
        if nHeight03 > nHeight02 then
            local sizes = {}
            for k=1, table.maxn(objsLine) do
                sizes[k] = objsLine[k]:getContentSize()
            end
            objsLine[1]:setPosition(x, nHeightOfPanel+ nHeight03) -- sizes[1].height)
            x = x + sizes[1].width
            objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
        else
            local tCCNodes = {}
            for k=1, table.maxn(objsLine) do
                table.insert(tCCNodes, {ccObj=objsLine[k]})
            end
            tCCNodes[2].xOffset=10
            objsLine[1]:setPosition(x, nHeightOfPanel+nHeight02)
            LuaCC.hAlignCCNodesAsFirst(tCCNodes)
        end

        nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
    end
    --
    nHeightOfPanel = nHeightOfPanel+4

    -- 设置9宫格实际高度
    nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    preferredSize.height = nHeightOfPanel
    bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    bg_attr_ng:addChild(ccSpriteTitle)
    -- 定位标题
    ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
    ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

    local nRealHeight = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2

    return bg_attr_ng, nRealHeight
end


-- 创建“觉醒”区域面板
function fnCreateAwakenPanel ()
    local tLabel={text=GetLocalizeStringBy("lcy_1001"), fontsize=25, color=ccc3(0, 0, 0), pos=ccp(56, 20), anchor=ccp(0.5, 0.5)} --觉醒
    local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

    -- 九宫格图片原始九宫信息
    local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    -- 九宫格期望高度
    local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

    local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
    local arrAwakeId = nil
    if db_hero.awake_id then
        arrAwakeId = string.split(db_hero.awake_id, ",")
    end
    local arrGrowAwakeId = nil
    if db_hero.grow_awake_id then
        arrGrowAwakeId = string.split(db_hero.grow_awake_id, ",")
    end


    require "db/DB_Awake_ability"
    -- 如果存在天赋ID
    local tAwakes = {}
    if arrAwakeId then
        for i=1, #arrAwakeId do
            tAwakes[#tAwakes+1] = {}
            local awake =  tAwakes[#tAwakes]
            awake.id = arrAwakeId[i]
        end
    end
    if arrGrowAwakeId then
        for i=1, #arrGrowAwakeId do
            tAwakes[#tAwakes+1] = {}
            local awake =  tAwakes[#tAwakes]
            local levelAndId = string.split(arrGrowAwakeId[i], "|")
            local awkae_type = tonumber(levelAndId[1])
            if awkae_type == 1 then
                awake.id = tonumber(levelAndId[3])
                awake.level = tonumber(levelAndId[2])
                awake.evolve_level = 0
            elseif awkae_type == 2 then
                awake.id = tonumber(levelAndId[3])
                awake.evolve_level = tonumber(levelAndId[2])
                awake.level = 0
            end
        end
    end

    local ccObjs = {}

    --查询武将第七天赋
    -- added by zhz :下面两行是有朱华智修改的
    ---[[当前版本不上
    local db_hero = DB_Heroes.getDataById(tonumber( _tHeroValue.htid))
    --print(" _tHeroValue.hid  is : ", _tHeroValue.hid)
    if(_tHeroValue.hid ~= nil and tonumber(db_hero.star_lv) >= 5) then
        local hero_copy_id      = DB_Heroes.getDataById(_tHeroValue.htid).hero_copy_id
        local hero_copy_talent  = string.split(hero_copy_id, ",")
        local levelTips = {"lgx_1023","lgx_1023","lgx_1024"}
        for i=1,#hero_copy_talent do
            local hero_copy_id_info = hero_copy_talent[i]
            local heroInfo          = HeroModel.getHeroByHid(_tHeroValue.hid)
            local sevenTalentText   = nil
            local talentNameText    = nil
            local cColorGreen       = ccc3(0, 0x6d, 0x2f)
            -- 去掉武将列传Id判断，heroes表修改 20160407 lgx
            local neeedPotential = tonumber(string.split(hero_copy_id_info, "|")[1])
            local evolveLevel       = tonumber(string.split(hero_copy_id_info,"|")[2])
            local isSealed          = false
            if(heroInfo["talent"]["sealed"] ~= nil and heroInfo["talent"]["sealed"][tostring(i)] ~= nil and heroInfo["talent"]["sealed"][tostring(i)] ~= 0) then
                isSealed = true
            end
            --print("evolveLevel:",evolveLevel)
            require "script/ui/star/StarUtil"
            require "db/DB_Hero_refreshgift"
            local labelColor        = ccc3(96,96,96)
            local name_color = ccc3(255, 255, 255)

            -- 是否满足进阶等级要求
            local isLevelOpen = tonumber(db_hero.potential) > neeedPotential or (tonumber(db_hero.potential) == neeedPotential and tonumber(_tHeroValue.evolve_level) >= evolveLevel)

            if(HeroModel.isNecessaryHeroByHid(_tHeroValue.hid) == false) then
                if(isLevelOpen == false
                    and heroInfo["talent"]["confirmed"][tostring(i)] == nil
                    and isSealed == false) then
                    sevenTalentText     = GetLocalizeStringBy(levelTips[i]) .. (evolveLevel or 7) .. GetLocalizeStringBy("key_8034") .. ")"
                    talentNameText      = GetLocalizeStringBy("lcy_" .. tostring(1001 + i))
                else
                    if(isSealed == false and heroInfo["talent"] ~= nil
                        and heroInfo["talent"]["confirmed"][tostring(i)] ~= nil
                        and tonumber(heroInfo["talent"]["confirmed"][tostring(i)]) ~= 0
                        and isLevelOpen == true) then
                        --如果通过了武将列传并且武将进阶等级满足能力开启等级
                        local talentId      = heroInfo["talent"]["confirmed"][tostring(i)]
                        local talentInfo    = DB_Hero_refreshgift.getDataById(talentId)
                        sevenTalentText     = talentInfo.des
                        talentNameText      = talentInfo.name
                        labelColor          = ccc3(0x78,0x25,0x00)
                        require "script/ui/biography/ComprehendLayer"
                        name_color = ComprehendLayer.getNameColorByStar(talentInfo.level)
                    elseif(isSealed == false and heroInfo["talent"] ~= nil
                        and heroInfo["talent"]["confirmed"][tostring(i)] ~= nil
                        and tonumber(heroInfo["talent"]["confirmed"][tostring(i)]) ~= 0
                        and isLevelOpen == false) then
                        --如果通过了武将列传并且武将进阶等级不满足能力开启等级
                        local openTips = {"lgx_1020","lgx_1020","lgx_1021"}
                        local talentId      = heroInfo["talent"]["confirmed"][tostring(i)]
                        local talentInfo    = DB_Hero_refreshgift.getDataById(talentId)
                        sevenTalentText     = talentInfo.des .. "(" .. GetLocalizeStringBy(openTips[i]) .. evolveLevel .. GetLocalizeStringBy("lic_1342") .. ")"
                        talentNameText      = talentInfo.name
                        labelColor          = ccc3(100,100,100)
                        name_color          = ccc3(255,255,255)
                        -- require "script/ui/biography/ComprehendLayer"
                        --  name_color = ComprehendLayer.getNameColorByStar(talentInfo.level)
                    elseif(isSealed == true and heroInfo["talent"]["confirmed"][tostring(i)] ~= nil and tonumber(heroInfo["talent"]["confirmed"][tostring(i)]) ~= 0) then
                        local talentId      = heroInfo["talent"]["confirmed"][tostring(i)]
                        local talentInfo    = DB_Hero_refreshgift.getDataById(talentId)
                        sevenTalentText     = talentInfo.des .. GetLocalizeStringBy("lcy_" .. tostring(50097+i))
                        talentNameText      = talentInfo.name
                    else
                        sevenTalentText     = GetLocalizeStringBy("key_1605")
                        talentNameText      = GetLocalizeStringBy("lcy_" .. tostring(1001 + i))
                    end
                end
                local nameLabel = CCRenderLabel:create( talentNameText, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
                nameLabel:setAnchorPoint(ccp(0, 1))
                nameLabel:setColor(name_color)

                local sevenTalentTextInfo = {{content=sevenTalentText, ntype="label", color=labelColor, tag=1001}}
                sevenTalentTextInfo.width = 420
                local desLabel = LuaCCLabel.createRichText(sevenTalentTextInfo)
                ccObjs[#ccObjs+1] = {}
                table.insert(ccObjs[#ccObjs], nameLabel)
                table.insert(ccObjs[#ccObjs], desLabel)
            end
        end
    end
    --]]
    -- 如果武将没有天赋则显示“该武将没有天赋”标签
    if #ccObjs==0 then
        local ccObj01 = CCLabelTTF:create(GetLocalizeStringBy("key_2510"), g_sFontName, 22)
        ccObj01:setColor(ccc3(0x78, 0x25, 0))
        local ccObj02 = CCLabelTTF:create("  ", g_sFontName, 22)
        ccObj02:setColor(ccc3(0x78, 0x25, 0))
        ccObjs[#ccObjs+1] = {}
        ccObj01:setAnchorPoint(ccp(0, 1))
        ccObj02:setAnchorPoint(ccp(0, 1))
        table.insert(ccObjs[#ccObjs], ccObj01)
        table.insert(ccObjs[#ccObjs], ccObj02)
    end
    local tSorted = table.reverse(ccObjs)
    ccObjs = tSorted or {}
    local x=60
    local nHeightOfPanel = 10
    local nMaxHeightOnSameLine = 0

    --定位装备觉醒按钮 add by Fu QiongQiong
    if(_tHeroValue.hid ~= nil and HeroModel.isNecessaryHero(_tHeroValue.htid) == true) then
        nHeightOfPanel = 80
        local detailBtn = createButton(GetLocalizeStringBy("fqq_041"), CCSizeMake(130, 60), equipAwakeCallback)
        detailBtn:setAnchorPoint(ccp(1, 0))
        detailBtn:setPosition(580, 10)
        bg_attr_ng:addChild(detailBtn, 20)
    elseif HeroModel.getHeroByHid(_tHeroValue.hid) then
        nHeightOfPanel = 80
        local detailBtn = createButton(GetLocalizeStringBy("key_2522"), CCSizeMake(130, 60), talentButtonCallback)
        detailBtn:setAnchorPoint(ccp(1, 0))
        detailBtn:setPosition(580, 10)
        bg_attr_ng:addChild(detailBtn, 20)
    end

    local arrCount = table.maxn(ccObjs)
    for i=1, arrCount do
        nMaxHeightOnSameLine = 0
        local objsLine = ccObjs[i]
        local nHeight02 = objsLine[1]:getContentSize().height
        local nHeight03 = objsLine[2]:getContentSize().height
        for k=1, table.maxn(objsLine) do
            if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
                nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
            end
            bg_attr_ng:addChild(objsLine[k])
        end
        local xOffset=10
        x=60
        if nHeight03 > nHeight02 then
            local sizes = {}
            for k=1, table.maxn(objsLine) do
                sizes[k] = objsLine[k]:getContentSize()
            end
            objsLine[1]:setPosition(x, nHeightOfPanel+ nHeight03) -- sizes[1].height)
            x = x + sizes[1].width
            objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
        else
            local tCCNodes = {}
            for k=1, table.maxn(objsLine) do
                table.insert(tCCNodes, {ccObj=objsLine[k]})
            end
            tCCNodes[2].xOffset=10
            objsLine[1]:setPosition(x, nHeightOfPanel+nHeight02)
            LuaCC.hAlignCCNodesAsFirst(tCCNodes)
        end

        nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
    end
    --
    nHeightOfPanel = nHeightOfPanel+4

    -- 设置9宫格实际高度
    nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    preferredSize.height = nHeightOfPanel
    bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    bg_attr_ng:addChild(ccSpriteTitle)
    -- 定位标题
    ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
    ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

    local nRealHeight = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    return bg_attr_ng, nRealHeight
end



-- 创建主角"装备觉醒"
function fnCreateMasterTalentPanel ()
    print("fnCreateMasterTalentPanel")
    local tLabel={text=GetLocalizeStringBy("lcy_1001"), fontsize=25, color=ccc3(0, 0, 0), pos=ccp(56, 20), anchor=ccp(0.5, 0.5)} --觉醒
    local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

    -- 九宫格图片原始九宫信息
    local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    -- 九宫格期望高度
    local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
    local ccObjs = {}
    local masterTalentInfo = {}

    if(_tHeroValue.masterTalent ~= nil)then
        masterTalentInfo = _tHeroValue.masterTalent
    else
        masterTalentInfo = HeroModel.getHeroByHid(_tHeroValue.hid).masterTalent or {}
    end

    local nameMap = {
        GetLocalizeStringBy("lcy_1002"),
        GetLocalizeStringBy("lcy_1003"),
        GetLocalizeStringBy("lcy_1004"),
    }

    for i=1,3 do
        local titleText = nameMap[i]
        local desText = GetLocalizeStringBy("lcyx_2025")
        local awakeId = masterTalentInfo[tostring(i)]
        if awakeId then
            titleText = DB_Awake_ability.getDataById(awakeId).name
            desText = DB_Awake_ability.getDataById(awakeId).des

            local nameLabel = CCRenderLabel:create( titleText, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            nameLabel:setAnchorPoint(ccp(0, 1))
            nameLabel:setColor(ccc3(255, 0, 0xe1))

            local sevenTalentTextInfo = {{content=desText, ntype="label", color=ccc3(0x78, 0x25, 0), tag=1001}}
            sevenTalentTextInfo.width = 420
            local desLabel = LuaCCLabel.createRichText(sevenTalentTextInfo)
            ccObjs[#ccObjs+1] = {}
            table.insert(ccObjs[#ccObjs], nameLabel)
            table.insert(ccObjs[#ccObjs], desLabel)
        else
            local nameLabel = CCRenderLabel:create( titleText, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            nameLabel:setAnchorPoint(ccp(0, 1))
            nameLabel:setColor(ccc3(0xff, 0xff, 0xff))

            local sevenTalentTextInfo = {{content=desText, ntype="label", color=ccc3(100, 100, 100), tag=1001}}
            sevenTalentTextInfo.width = 420
            local desLabel = LuaCCLabel.createRichText(sevenTalentTextInfo)
            ccObjs[#ccObjs+1] = {}
            table.insert(ccObjs[#ccObjs], nameLabel)
            table.insert(ccObjs[#ccObjs], desLabel)
        end
    end
    -- 如果武将没有天赋则显示“该武将没有天赋”标签
    if #ccObjs==0 then
        local ccObj01 = CCLabelTTF:create(GetLocalizeStringBy("key_2510"), g_sFontName, 22)
        ccObj01:setColor(ccc3(0x78, 0x25, 0))
        local ccObj02 = CCLabelTTF:create("  ", g_sFontName, 22)
        ccObj02:setColor(ccc3(0x78, 0x25, 0))
        ccObjs[#ccObjs+1] = {}
        ccObj01:setAnchorPoint(ccp(0, 1))
        ccObj02:setAnchorPoint(ccp(0, 1))
        table.insert(ccObjs[#ccObjs], ccObj01)
        table.insert(ccObjs[#ccObjs], ccObj02)
    end
    local tSorted = table.reverse(ccObjs)
    ccObjs = tSorted or {}
    local x=60
    local nHeightOfPanel = 80
    local nMaxHeightOnSameLine = 0
    if(_tHeroValue.hid ~= nil and DataCache.getSwitchNodeState(ksSwitchStarSoul, false))then
        --定位装备觉醒按钮 add by Fu QiongQiong
        local detailBtn = createButton(GetLocalizeStringBy("fqq_041"), CCSizeMake(130, 60), equipAwakeCallback)
        detailBtn:setAnchorPoint(ccp(1, 0))
        detailBtn:setPosition(580, 10)
        bg_attr_ng:addChild(detailBtn, 20)
    end


    local arrCount = table.maxn(ccObjs)
    for i=1, arrCount do
        nMaxHeightOnSameLine = 0
        local objsLine = ccObjs[i]
        local nHeight02 = objsLine[1]:getContentSize().height
        local nHeight03 = objsLine[2]:getContentSize().height
        for k=1, table.maxn(objsLine) do
            if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
                nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
            end
            bg_attr_ng:addChild(objsLine[k])
        end
        local xOffset=10
        x=60
        if nHeight03 > nHeight02 then
            local sizes = {}
            for k=1, table.maxn(objsLine) do
                sizes[k] = objsLine[k]:getContentSize()
            end
            objsLine[1]:setPosition(x, nHeightOfPanel+ nHeight03) -- sizes[1].height)
            x = x + sizes[1].width
            objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
        else
            local tCCNodes = {}
            for k=1, table.maxn(objsLine) do
                table.insert(tCCNodes, {ccObj=objsLine[k]})
            end
            tCCNodes[2].xOffset=10
            objsLine[1]:setPosition(x, nHeightOfPanel+nHeight02)
            LuaCC.hAlignCCNodesAsFirst(tCCNodes)
        end

        nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
    end
    --
    nHeightOfPanel = nHeightOfPanel+4

    -- 设置9宫格实际高度
    nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    preferredSize.height = nHeightOfPanel
    bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    bg_attr_ng:addChild(ccSpriteTitle)
    -- 定位标题
    ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
    ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

    local nRealHeight = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    return bg_attr_ng, nRealHeight
end



-- 创建武将天命天赋
function fnCreateHeroDestiny()
    print("fnCreateMasterTalentPanel")
    local tLabel={text=GetLocalizeStringBy("lcyx_3007"), fontsize=25, color=ccc3(0, 0, 0), pos=ccp(56, 20), anchor=ccp(0.5, 0.5)} --觉醒
    local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

    -- 九宫格图片原始九宫信息
    local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    -- 九宫格期望高度
    local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)
    local heroInfo = nil
    local db_hero = DB_Heroes.getDataById(_tHeroValue.htid)
    if _tHeroValue.heroInfo then
        heroInfo = _tHeroValue.heroInfo
    elseif _tHeroValue.hid then
        heroInfo = HeroModel.getHeroByHid(_tHeroValue.hid)
    end
    local destiny = 0
    local destinyAwake = string.split(db_hero.destinyAwake, ",")
    if heroInfo then
        destiny = tonumber(heroInfo.destiny) or 0
    end
    local tAwakes = {}
    for k,v in pairs(destinyAwake) do
        local vInfo = string.split(v, "|")
        local info = {}
        info.needNum = vInfo[1]
        info.awakeId = vInfo[2]
        table.insert(tAwakes, info)
    end
    printTable("tAwakes", tAwakes)
    local ccObjs = {}
    for i=1, #tAwakes do
        local v = tAwakes[i]
        local data = DB_Awake_ability.getDataById(v.awakeId)
        local labelColor01 = ccc3(0xff, 0, 0)
        local labelColor02 = ccc3(0x78, 0x25, 0)
        ccObjs[#ccObjs+1] = {}
        local ccObj01 = CCLabelTTF:create(data.name, g_sFontName, 22)
        ccObj01:setAnchorPoint(ccp(0, 1))
        ccObj01:setColor(labelColor01)
        local ccObj02
        local richTextInfo = {}
        richTextInfo.width = 500 - ccObj01:getContentSize().width
        if tonumber(v.needNum) > destiny then
            ccObj01:setColor(ccc3(128, 128, 128))
            richTextInfo[2] = {content=data.des, ntype="label", color=ccc3(128, 128, 128)}
            richTextInfo[1] = {content=GetLocalizeStringBy("lcyx_3008", v.needNum), ntype="label", color=ccc3(0xff, 128, 0)}
            ccObj02 = LuaCCLabel.createRichText(richTextInfo)
        else
            richTextInfo[1] = {content=data.des, ntype="label", color=labelColor02}
            ccObj02 = LuaCCLabel.createRichText(richTextInfo)
        end
        table.insert(ccObjs[#ccObjs], ccObj01)
        table.insert(ccObjs[#ccObjs], ccObj02)
    end


    -- 如果武将没有天赋则显示“该武将没有天赋”标签
    if #ccObjs==0 then
        local ccObj01 = CCLabelTTF:create(GetLocalizeStringBy("lcyx_3009"), g_sFontName, 22)
        ccObj01:setColor(ccc3(0x78, 0x25, 0))
        local ccObj02 = CCLabelTTF:create("  ", g_sFontName, 22)
        ccObj02:setColor(ccc3(0x78, 0x25, 0))
        ccObjs[#ccObjs+1] = {}
        ccObj01:setAnchorPoint(ccp(0, 1))
        ccObj02:setAnchorPoint(ccp(0, 1))
        table.insert(ccObjs[#ccObjs], ccObj01)
        table.insert(ccObjs[#ccObjs], ccObj02)
    end
    local tSorted = table.reverse(ccObjs)
    ccObjs = tSorted
    local x=60
    local nHeightOfPanel = 10
    local nMaxHeightOnSameLine = 0

    --添加点亮天赋按钮
    if(_tHeroValue.hid ~= nil and HeroModel.isNecessaryHero(_tHeroValue.htid) == false) then
        nHeightOfPanel = 80
        local detailBtn = createButton(GetLocalizeStringBy("lcyx_3010"), CCSizeMake(130, 60), heroDestinyBtnCallback)
        detailBtn:setAnchorPoint(ccp(1, 0))
        detailBtn:setPosition(580, 10)
        bg_attr_ng:addChild(detailBtn, 20)
    end
    local arrCount = table.maxn(ccObjs)
    for i=1, arrCount do
        nMaxHeightOnSameLine = 0
        local objsLine = ccObjs[i]
        local nHeight02 = objsLine[1]:getContentSize().height
        local nHeight03 = objsLine[2]:getContentSize().height
        for k=1, table.maxn(objsLine) do
            if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
                nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
            end
            bg_attr_ng:addChild(objsLine[k])
        end
        local xOffset=10
        x=60
        if nHeight03 > nHeight02 then
            local sizes = {}
            for k=1, table.maxn(objsLine) do
                sizes[k] = objsLine[k]:getContentSize()
            end
            objsLine[1]:setPosition(x, nHeightOfPanel+ nHeight03) -- sizes[1].height)
            x = x + sizes[1].width
            objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
        else
            local tCCNodes = {}
            for k=1, table.maxn(objsLine) do
                table.insert(tCCNodes, {ccObj=objsLine[k]})
            end
            tCCNodes[2].xOffset=10
            objsLine[1]:setPosition(x, nHeightOfPanel+nHeight02)
            LuaCC.hAlignCCNodesAsFirst(tCCNodes)
        end

        nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
    end
    --
    nHeightOfPanel = nHeightOfPanel+4

    -- 设置9宫格实际高度
    nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    preferredSize.height = nHeightOfPanel
    bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    bg_attr_ng:addChild(ccSpriteTitle)
    -- 定位标题
    ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
    ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

    local nRealHeight = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    return bg_attr_ng, nRealHeight
end

-- 创建“羁绊”区域面板
function fnCreateUnionPanel()
    -- 检测数据有效性
    -- 连携属性ID组(字符串)
    require "db/DB_Heroes"
    local heroBaseHtid = DB_Heroes.getDataById(_tHeroValue.htid).model_id
    local tDB = DB_Heroes.getDataById(_tHeroValue.htid)
    local sLinkIDs = tDB.link_group1
    -- 连携属性ID组(Lua表数组结构)
    local tArrLinkIDs
    if sLinkIDs == nil then
        tArrLinkIDs = {}
    else
        tArrLinkIDs = string.split(sLinkIDs, ",")
    end
    local tLabel={text=GetLocalizeStringBy("key_3231"), fontsize=25, color=ccc3(0, 0, 0), pos=ccp(56, 20), anchor=ccp(0.5, 0.5)}
    local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel)

    -- 背景九宫格图
    local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

    -- 三种显示颜色
    local cColorGray = ccc3(0x50, 0x50, 0x50)
    local cColorGreen = ccc3(0, 0x6d, 0x2f)
    local cColorYellow = ccc3(0x78, 0x25, 0)

    -- cocos2d-x控件，是个二维数组 行x列.
    local ccObjs = {}
    for i=1, #tArrLinkIDs do
        local tDB = DB_Union_profit.getDataById(tArrLinkIDs[i])
        --把方老师的判断羁绊方法删了，改用大一统的判断羁绊方法
        local bCondition = false
        local isLoyalty  = false

        if _tHeroValue.hid then
            require "script/ui/star/loyalty/LoyaltyData"
            bCondition = UnionProfitUtil.isHeroParticularUnionOpen(tArrLinkIDs[i],_tHeroValue.hid)
        end
        isLoyalty = LoyaltyData.isUnionCanOpen(tArrLinkIDs[i])
        print("isLoyalty", isLoyalty, "hid:", _tHeroValue.hid)

        local color01 = cColorGreen
        local color02 = cColorYellow
        if not bCondition then
            color01 = cColorGray
            color02 = cColorGray
        end
        local ccLabelName=CCLabelTTF:create(tDB.union_arribute_name, g_sFontName, 22)
        ccLabelName:setColor(color01)
        local ccLabelDesc = LuaCCLabel.createMultiLineLabel({text=tDB.union_arribute_desc, color=color02, width=450})
        ccObjs[#ccObjs+1] = {}
        ccObjs[#ccObjs].isLoyalty = isLoyalty
        table.insert(ccObjs[#ccObjs], ccLabelName)
        table.insert(ccObjs[#ccObjs], ccLabelDesc)
    end
    if #ccObjs == 0 then
        local ccObj01=CCLabelTTF:create(GetLocalizeStringBy("key_1341"), g_sFontName, 22)
        ccObj01:setColor(cColorGreen)
        local ccObj02=CCLabelTTF:create(" ", g_sFontName, 22)
        ccObj02:setColor(ccc3(0, 0, 0))
        ccObjs[#ccObjs+1] = {}
        table.insert(ccObjs[#ccObjs], ccObj01)
        table.insert(ccObjs[#ccObjs], ccObj02)
    end

    local x=60
    local nHeightOfPanel = 10
    local nMaxHeightOnSameLine = 0

    local arrCount = table.maxn(ccObjs)
    printTable("羁绊ccObjs", ccObjs)
    for i=1, arrCount do
        nMaxHeightOnSameLine = 0
        local objsLine = ccObjs[arrCount-i+1]
        local nHeight02 = objsLine[1]:getContentSize().height
        local nHeight03 = objsLine[2]:getContentSize().height
        for k=1, table.maxn(objsLine) do
            if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
                nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
            end
            bg_attr_ng:addChild(objsLine[k])
        end
        local xOffset=10
        x=60

        local junIcon = CCSprite:create("images/hero/jun.png")
        junIcon:setAnchorPoint(ccp(1, 0))
        bg_attr_ng:addChild(junIcon)
        junIcon:setVisible(false)
        if objsLine.isLoyalty then
            junIcon:setVisible(true)
        end
        if nHeight03 > nHeight02 then
            local sizes = {}
            for k=1, table.maxn(objsLine) do
                sizes[k] = objsLine[k]:getContentSize()
            end
            objsLine[1]:setPosition(x, nHeightOfPanel+ nHeight03 - sizes[1].height)
            junIcon:setPosition(x-7, nHeightOfPanel+ nHeight03 - sizes[1].height)
            x = x + sizes[1].width
            objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
        else
            local tCCNodes = {}
            for k=1, table.maxn(objsLine) do
                table.insert(tCCNodes, {ccObj=objsLine[k]})
            end
            tCCNodes[2].xOffset=10
            objsLine[1]:setPosition(x, nHeightOfPanel)
            LuaCC.hAlignCCNodesAsFirst(tCCNodes)
            junIcon:setPosition(x-7, nHeightOfPanel)
        end

        nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
    end
    nHeightOfPanel = nHeightOfPanel+4

    -- 设置9宫格实际高度
    nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    preferredSize.height = nHeightOfPanel
    bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    bg_attr_ng:addChild(ccSpriteTitle)
    -- 定位标题
    ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
    ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))

    local nHeightOfUnionArea = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2

    return bg_attr_ng, nHeightOfUnionArea
end

-- 创建“神兵羁绊”区域面板
function fnCreateGodUnionPanel()
    -- 检测数据有效性
    -- 连携属性ID组(字符串)
    require "db/DB_Heroes"
    local heroBaseHtid = DB_Heroes.getDataById(_tHeroValue.htid).model_id
    local tDB = DB_Heroes.getDataById(_tHeroValue.htid)
    local sLinkIDs = tDB.godarm_link
    -- 连携属性ID组(Lua表数组结构)
    local tArrLinkIDs
    if sLinkIDs == nil then
        tArrLinkIDs = {}
    else
        tArrLinkIDs = string.split(sLinkIDs, ",")
    end
    local tLabel={text=GetLocalizeStringBy("lcyx_1956"), fontsize=25, color=ccc3(0, 0, 0), pos=ccp(18, 20), anchor=ccp(0, 0.5)}
    local ccSpriteTitle = LuaCC.createSpriteWithLabel("images/hero/info/title_bg.png", tLabel, CCSizeMake(147,41))

    -- 背景九宫格图
    local fullRect = CCRectMake(0, 0, 61, 47)
    local insetRect = CCRectMake(24, 16, 10, 4)
    local preferredSize={width=604, height=120}
    local bg_attr_ng = CCScale9Sprite:create("images/common/bg/white_text_ng.png", fullRect, insetRect)

    -- 三种显示颜色
    local cColorGray = ccc3(0x50, 0x50, 0x50)
    local cColorGreen = ccc3(0, 0x6d, 0x2f)
    local cColorYellow = ccc3(0x78, 0x25, 0)

    -- cocos2d-x控件，是个二维数组 行x列.
    local ccObjs = {}
    for i=1, #tArrLinkIDs do
        local tDB = DB_Union_profit.getDataById(tArrLinkIDs[i])
        --把方老师的判断羁绊方法删了，改用大一统的判断羁绊方法
        local bCondition = false

        if _tHeroValue.hid then
            bCondition = UnionProfitUtil.isHeroParticularUnionOpen(tArrLinkIDs[i],_tHeroValue.hid)
        end

        local color01 = cColorGreen
        local color02 = cColorYellow
        if not bCondition then
            color01 = cColorGray
            color02 = cColorGray
        end
        local ccLabelName=CCLabelTTF:create(tDB.union_arribute_name, g_sFontName, 22)
        ccLabelName:setColor(color01)
        local ccLabelDesc = LuaCCLabel.createMultiLineLabel({text=tDB.union_arribute_desc, color=color02, width=430})
        ccObjs[#ccObjs+1] = {}
        table.insert(ccObjs[#ccObjs], ccLabelName)
        table.insert(ccObjs[#ccObjs], ccLabelDesc)
    end
    if #ccObjs == 0 then
        local ccObj01=CCLabelTTF:create(GetLocalizeStringBy("lcyx_1957"), g_sFontName, 22)
        ccObj01:setColor(cColorGreen)
        local ccObj02=CCLabelTTF:create(" ", g_sFontName, 22)
        ccObj02:setColor(ccc3(0, 0, 0))
        ccObjs[#ccObjs+1] = {}
        table.insert(ccObjs[#ccObjs], ccObj01)
        table.insert(ccObjs[#ccObjs], ccObj02)
    end

    local x=60
    local nHeightOfPanel = 10
    local nMaxHeightOnSameLine = 0

    local arrCount = table.maxn(ccObjs)
    for i=1, arrCount do
        nMaxHeightOnSameLine = 0
        local objsLine = ccObjs[arrCount-i+1]
        local nHeight02 = objsLine[1]:getContentSize().height
        local nHeight03 = objsLine[2]:getContentSize().height
        for k=1, table.maxn(objsLine) do
            if nMaxHeightOnSameLine < objsLine[k]:getContentSize().height then
                nMaxHeightOnSameLine = objsLine[k]:getContentSize().height
            end
            bg_attr_ng:addChild(objsLine[k])
        end
        local xOffset=10
        x=60
        if nHeight03 > nHeight02 then
            local sizes = {}
            for k=1, table.maxn(objsLine) do
                sizes[k] = objsLine[k]:getContentSize()
            end
            objsLine[1]:setPosition(x, nHeightOfPanel+ nHeight03 - sizes[1].height)
            x = x + sizes[1].width
            objsLine[2]:setPosition(x+xOffset, nHeightOfPanel + nHeight03)
        else
            local tCCNodes = {}
            for k=1, table.maxn(objsLine) do
                table.insert(tCCNodes, {ccObj=objsLine[k]})
            end
            tCCNodes[2].xOffset=10
            objsLine[1]:setPosition(x, nHeightOfPanel)
            LuaCC.hAlignCCNodesAsFirst(tCCNodes)
        end

        nHeightOfPanel = nHeightOfPanel + nMaxHeightOnSameLine + 4
    end
    nHeightOfPanel = nHeightOfPanel+4

    -- 设置9宫格实际高度
    nHeightOfPanel = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    preferredSize.height = nHeightOfPanel
    bg_attr_ng:setPreferredSize(CCSizeMake(preferredSize.width, preferredSize.height))
    bg_attr_ng:addChild(ccSpriteTitle)
    -- 定位标题
    ccSpriteTitle:setPosition(ccp(-5, preferredSize.height))
    ccSpriteTitle:setAnchorPoint(ccp(0, 0.5))
    local nHeightOfUnionArea = nHeightOfPanel + ccSpriteTitle:getContentSize().height/2
    return bg_attr_ng, nHeightOfUnionArea
end

-- 创建底部按钮面板
function createBottomPanel( ... )
    if _tHeroValue.addPos ~= HeroInfoLayer.kFormationPos then
        return 0
    end

    local bg = CCSprite:create("images/common/sell_bottom.png")
    bg:setScale(g_fScaleX)
    bg:setPosition(ccp(0, 0))
    _bgLayer:addChild(bg, 200)

    local menu = CCMenu:create()
    bg:addChild(menu)
    menu:setTouchPriority( _touchProperty-1 or -701)
    menu:setPosition(ccp(0, 0))

    --当前武将是否可以领悟天赋
    local isAbleTalent = true
    -- 更换小伙伴
    if _tParentParam and _tParentParam.needChangeFriend then
        -- 更换小伙伴
        local cs9miChangeFriend = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_2079"), ccc3(255,222,0))
        local y=8

        cs9miChangeFriend:setPosition(70, y)
        cs9miChangeFriend:registerScriptTapHandler(fnHandlerOfChangeFriend)
        menu:addChild(cs9miChangeFriend, 0, _ksTagChangeFriend)
        --卸下
        local cs9miDown = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_2592"), ccc3(255,222,0))
        cs9miDown:registerScriptTapHandler(fnHandlerOfChangeFriend)
        cs9miDown:setPosition(360, y)
        menu:addChild(cs9miDown, 0, _ksTagDown)
        local height = bg:getContentSize().height*g_fScaleX
        return height
    end

    -- 更换助战军
    if _tParentParam and _tParentParam.needChangeSecFriend then
        -- 更换小伙伴
        local cs9miChangeFriend = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("lic_1496"), ccc3(255,222,0))
        local y=8

        cs9miChangeFriend:setPosition(70, y)
        cs9miChangeFriend:registerScriptTapHandler(fnHandlerOfChangeSecFriend)
        menu:addChild(cs9miChangeFriend, 0, _ksTagChangeFriend)
        --卸下
        local cs9miDown = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(210,73), GetLocalizeStringBy("key_2592"), ccc3(255,222,0))
        cs9miDown:registerScriptTapHandler(fnHandlerOfChangeSecFriend)
        cs9miDown:setPosition(360, y)
        menu:addChild(cs9miDown, 0, _ksTagDown)
        local height = bg:getContentSize().height*g_fScaleX
        return height
    end

    local y=8

    local isAvatar = HeroModel.isNecessaryHero(_tHeroValue.htid)
    if _tParentParam.needChangeHeroBtn then
        --更换武将
        local ccBtnChangeHero = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(190,73), GetLocalizeStringBy("key_2278"), ccc3(255,222,0))
        _cmiChangeHero = ccBtnChangeHero
        ccBtnChangeHero:setPosition(bg:getContentSize().width * 0.5, y)
        ccBtnChangeHero:setAnchorPoint(ccp(0.5, 0))
        ccBtnChangeHero:registerScriptTapHandler(fnHandlerOfChangeHero)
        menu:addChild(ccBtnChangeHero)
        if not _tParentParam.needChangeHeroBtn or isAvatar then
            ccBtnChangeHero:setEnabled(false)
        end
    else
        -- --返回
        local ccBtnClose = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", CCSizeMake(190,73), GetLocalizeStringBy("key_1951"), ccc3(255,222,0))
        ccBtnClose:registerScriptTapHandler(closeButtonCallback)
        ccBtnClose:setPosition(bg:getContentSize().width * 0.5, y)
        ccBtnClose:setAnchorPoint(ccp(0.5, 0))
        menu:addChild(ccBtnClose)
    end

    local height = bg:getContentSize().height*g_fScaleX
    return height
end


-- “更换武将”按钮事件回调处理
function fnHandlerOfChangeHero(tag, obj)
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if(changHeroCallbackFunc ~= nil) then
        changHeroCallbackFunc()
    end
    require "script/ui/formation/ChangeOfficerLayer"
    MainScene.changeLayer(ChangeOfficerLayer.createLayer(_tParentParam.reserved2, _tParentParam.reserved), "ChangeOfficerLayer")
end
-- “强化”按钮点击事件处理
function fnHandlerOfStrengthenButton(tag, obj)
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    closeButtonCallback()
    --等级礼包新手引导
    require "script/guide/NewGuide"
    if(NewGuide.guideClass == ksGuideFiveLevelGift) then
        require "script/guide/LevelGiftBagGuide"
        LevelGiftBagGuide.changLayer()
    end
    _isFromFormation = true
    require "script/ui/hero/HeroStrengthenLayer"
    MainScene.changeLayer(HeroStrengthenLayer.createLayer(_tHeroValue), "ChangeOfficerLayer")

    -- 等级礼包第15步 自动添加
    --新手引导
    require "script/guide/NewGuide"
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 14) then
        local levelGiftBagGuide_button = HeroStrengthenLayer.getCardStrengthenButtonForGuide(3)
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(15, touchRect)
    end
end

-- 更换小伙伴回调处理
function fnHandlerOfChangeFriend(tag, obj)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if tag == _ksTagChangeFriend then
        require "script/ui/formation/ChangeOfficerLayer"
        MainScene.changeLayer(ChangeOfficerLayer.createLayer(_tParentParam.reserved2, _tParentParam.reserved, true), "ChangeOfficerLayer")
    elseif tag ==  _ksTagDown then
        _tParentParam.fnCreate(_tParentParam.reserved, _tParentParam.reserved2)
    end
end

-- 更换助战军回调处理
function fnHandlerOfChangeSecFriend(tag, obj)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if tag == _ksTagChangeFriend then
        require "script/ui/formation/ChangeOfficerLayer"
        MainScene.changeLayer(ChangeOfficerLayer.createLayer(_tParentParam.reserved2, _tParentParam.reserved, nil,true), "ChangeOfficerLayer")
    elseif tag ==  _ksTagDown then
        _tParentParam.fnCreate(_tParentParam.reserved, _tParentParam.reserved2)
    end
end

--[[
    @des:进阶按钮回调事件
--]]
function evloveBtnCallback(tag, obj)
    _onRunningLayer:removeFromParentAndCleanup(true)
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/ui/hero/HeroTransferLayer"
    local tArgs={selectedHeroes=_tHeroValue}
    tArgs.fnCreate = FormationLayer.createLayer
    tArgs.sign = _tParentParam.sign
    tArgs.reserved = _tParentParam.reserved
    tArgs.reserved2 = reserved2
    tArgs.htid = _tHeroValue.htid
    tArgs.addPos = _tHeroValue.addPos
    MainScene.changeLayer(HeroTransferLayer.createLayer(tArgs), "HeroTransferLayer")
end

-- 更换技能按钮回调 来自武将 add by DJN
function changeSkillButtonCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    require "script/ui/replaceSkill/EquipmentLayer"
    _onRunningLayer:removeFromParentAndCleanup(true)

    local closeCb = function ( ... )
        if _tHeroValue.addPos == HeroInfoLayer.kFormationPos then
            MainScene.changeLayer(FormationLayer.createLayer(), "fromation")
        else
            MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
        end
    end
    EquipmentLayer.showLayer(closeCb)
end

-- 武将解锁的回调函数
function fnLockedHandler(tag, item )
    local hid= tonumber(tag)
    local args= CCArray:create()
    args:addObject(CCInteger:create(hid))
    Network.rpc(unlLockHeroCallbck, "hero.unlockHero" , "hero.unlockHero", args, true)
end

-- 武将加锁的回调函数
function fnUnLockedHandler( tag, item)
    local hid= tonumber(tag)
    local args= CCArray:create()
    args:addObject(CCInteger:create(hid))
    Network.rpc(lockHeroCallbck, "hero.lockHero" , "hero.lockHero", args, true)
end

function heroLockBtnCallback(pTag, pSender)
    local item = tolua.cast(pSender, "CCMenuItemToggle")
    local selectIndex = item:getSelectedIndex()
    if selectIndex == 1 then
        fnLockedHandler(_tHeroValue.hid)
    else
        fnUnLockedHandler(_tHeroValue.hid)
    end
end

function unlLockHeroCallbck(cbFlag, dictData, bRet)
    if(dictData.err ~= "ok" )then
        return
    end
    AnimationTip.showTip(GetLocalizeStringBy("key_2782"))
    HeroModel.setHeroLockStatusByHid( _tHeroValue.hid,0)
end

function lockHeroCallbck(cbFlag, dictData, bRet)
    if(dictData.err ~= "ok" )then
        return
    end
    AnimationTip.showTip(GetLocalizeStringBy("key_2548"))
    HeroModel.setHeroLockStatusByHid( _tHeroValue.hid,1 )
end

-- 领悟天赋按钮回调
function talentButtonCallback( tag,item )
    local hid = _tHeroValue.hid
    require "script/ui/biography/ComprehendLayer"
    ComprehendLayer.show(hid,closeButtonCallback, true)
end

function upFormationCallback( ... )
    closeButtonCallback()
    require("script/ui/formation/FormationLayer")
    local formationLayer = FormationLayer.createLayer(_tHeroValue.hid, false, false, true)
    MainScene.changeLayer(formationLayer, "formationLayer")
    require "script/ui/tip/AlertTip"
    AlertTip.showAlert(GetLocalizeStringBy("key_1995"), nil, false, nil)
end

--武将进化按钮
function tapCCBtnDevelopCb( p_tag, p_item )
    require "script/ui/develop/DevelopLayer"
    DevelopLayer.showLayer(p_tag, DevelopLayer.kOldLayerTag.kFormationTag)
end

--[[
    @des: 详细信息按钮会掉
--]]
function checkFightSoulButtonCallback( ... )
    require "script/ui/hero/FightSoulAttrDialog"
    FightSoulAttrDialog.showTip(_tHeroValue.htid,_tHeroValue.hid, _zOrder + 1000, _touchProperty-100)
end

--[[
    @des:装备觉醒回调
--]]
function equipAwakeCallback( ... )
    print("装备觉醒回调~~~")
    require "script/ui/hero/equipAwake/EquipAwakeLayer"
    local hid = _tHeroValue.hid
    EquipAwakeLayer.show(hid,closeButtonCallback,true)
end

--[[
    @des:丹药按钮回调事件
--]]
function pillBtnCallback( ... )
    closeButtonCallback()
    require "script/ui/pill/PillLayer"
    local layer = PillLayer.createLayer(1, function ()
        if _tHeroValue.addPos == HeroInfoLayer.kFormationPos then
            MainScene.changeLayer(FormationLayer.createLayer(), "fromation")
        else
            MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
        end
    end,nil,nil,_tHeroValue.hid)
    MainScene.changeLayer(layer, "pillLayer")
end


-- 关闭按钮回调处理
function closeButtonCallback(tag, item_obj)
    -- added by bzx
    BulletinLayer.getLayer():setVisible(_bulletin_layer_is_visible)
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _tParentParam and _tParentParam.isPanel then
        _onRunningLayer:removeFromParentAndCleanup(true)
        if(_delegation) then
            _delegation()
        end
        return
    elseif _tParentParam and _tParentParam.needChangeFriend then
        _onRunningLayer:removeFromParentAndCleanup(true)
        MainScene.changeLayer(FormationLayer.createLayer(nil,false,true),"formationLayer")
        return
    elseif _tParentParam and _tParentParam.needChangeSecFriend then
        _onRunningLayer:removeFromParentAndCleanup(true)
        local laye = FormationLayer.createLayer(nil, false, nil, nil,nil,nil,true,_tParentParam.reserved2)
        MainScene.changeLayer(laye,"formationLayer")
        return
    end
    -- 进入武将layer
    require "script/ui/main/MainScene"
    if _tParentParam then
        MainScene.changeLayer(_tParentParam.fnCreate(_tParentParam.reserved, false), _tParentParam.sign)
    else
        require "script/ui/hero/HeroLayer"
        MainScene.getAvatarLayerObj():setVisible(true)
        MenuLayer.getObject():setVisible(true)
        MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
    end
end

function heroDestinyBtnCallback( ... )
    closeButtonCallback()
    require "script/ui/redcarddestiny/RedCardDestinyLayer"
    local enterType = 1
    if _tHeroValue.addPos == HeroInfoLayer.kFormationPos then
        enterType = 2
    end
    local layer = RedCardDestinyLayer.showLayer(enterType, _tHeroValue.hid)
    MainScene.changeLayer(layer, "RedCardDestinyLayer")
    MainScene.setMainSceneViewsVisible(false,false,false)
end

-- 新手引导
-- 获得“更换武将”按钮
function getChangeHeroButton( ... )
    return _cmiChangeHero
end
-- 新手引导
-- 获得“强化”按钮
function getStrengthenButton( ... )


    return _ccStrengthenButton
end

--add by lichenyang
function registerChangeHeroCallback( p_callback )
    changHeroCallbackFunc = p_callback
end

function registerHeroInfoLayerCallback( p_callback )
    heroInfoLayerDidLoad = p_callback
end

function createButton( pText, pSize, pAction)
    local normal  = CCScale9Sprite:create("images/common/btn/org_btn_n.png")
    normal:setContentSize(pSize)
    local hight  = CCScale9Sprite:create("images/common/btn/org_btn_h.png")
    hight:setContentSize(pSize)

    local itemSprite = CCSprite:create()
    itemSprite:setContentSize(normal:getContentSize())
    itemSprite:setAnchorPoint(ccp(0.5, 0.5))
    local menu = CCMenu:create()
    menu:setContentSize(itemSprite:getContentSize())
    menu:setAnchorPoint(ccp(0.5, 0.5))
    menu:setPosition(ccpsprite(0.5, 0.5, itemSprite))
    menu:ignoreAnchorPointForPosition(false)
    menu:setTouchPriority(_touchProperty - 20)
    itemSprite:addChild(menu)

    local button = CCMenuItemSprite:create(normal,hight)
    button:setAnchorPoint(ccp(0.5,0.5))
    button:setPosition(pSize.width/2 , pSize.height/2)
    button:registerScriptTapHandler(pAction)
    menu:addChild(button)

    local textLable = CCRenderLabel:create(pText, g_sFontPangWa, 22, 2, ccc3(0, 0, 0), type_stroke)
    textLable:setAnchorPoint(ccp(0.5, 0.5))
    textLable:setPosition(ccpsprite(0.5, 0.5, button))
    button:addChild(textLable)
    textLable:setColor(ccc3(230, 246, 10))
    return itemSprite
end


