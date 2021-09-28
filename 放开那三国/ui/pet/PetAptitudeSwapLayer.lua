-- FileName: PetAptitudeSwapLayer.lua
-- Author: shengyixian
-- Date: 2016-02-16
-- Purpose: 宠物资质互换
module("PetAptitudeSwapLayer",package.seeall)
require "script/ui/guildBossCopy/ProgressBar"
local _layer = nil
local _touchPriority = nil
local _topBg = nil
local _powerLabel = nil
local _silverLabel = nil
local _goldLabel = nil
local _layerSize = nil
-- 中间UI起始Y坐标
local _middleUIPosY = nil
-- 下部UI起始Y坐标
local _buttomUIPosY = nil
-- 当前宠物的id
local _curPetIndex = nil
-- 当前宠物的信息
local _curPetInfo = nil
-- 宠物Sp容器
local _petContSp = nil
-- 宠物Sp容器的尺寸
local _petContSize = nil
-- 替换的宠物Sp
local _swapPetSp = nil
-- 替换的宠物数据
local _swapPetInfo = nil
-- 当前宠物资质信息面板
local _curPetInfoPanel = nil
-- 替换的宠物资质信息面板
local _swapPetInfoPanel = nil
local _swapPetNameLabel = nil
-- 宠物品阶文本
local _petAdvanceLvLabel = nil
-- 替换的宠物品阶文本
local _swapAdvanceLvLabel = nil
function init( ... )
	-- body
	_layer = nil
    _touchPriority = nil
    _topBg = nil
    _powerLabel = nil
    _silverLabel = nil
    _goldLabel = nil
    _layerSize = nil
    _middleUIPosY = nil
    _buttomUIPosY = nil
    _curPetIndex = nil
    _curPetInfo = nil
    _petContSp = nil
    _petContSize = CCSizeMake(640, 240)
    _swapPetSp = nil
    _swapPetInfo = nil
    _curPetInfoPanel = nil
    _swapPetInfoPanel = nil
    _swapPetNameLabel = nil
    _petAdvanceLvLabel = nil
    _swapAdvanceLvLabel = nil
end

function onNodeHandler( eventType )
    -- body
    if eventType == "enter" then
        _layer:registerScriptTouchHandler(function ( eventType )
        	-- body
        	if eventType == "began" then
        		return true
        	end
        end,false,_touchPriority,true)
        _layer:setTouchEnabled(true)
    elseif eventType == "exit" then
        _layer:unregisterScriptTouchHandler()
    end
end

function createLayer( ... )
	-- body
	_layer = CCLayer:create()
	_layer:setContentSize(_layerSize)
	_layer:registerScriptHandler(onNodeHandler)
	local bg = CCSprite:create("images/destney/destney_bg.png")
	bg:setScale(g_fBgScaleRatio)
    bg:setAnchorPoint(ccp(0.5,1))
    bg:setPosition(ccpsprite(0.5,1.1,_layer))
	_layer:addChild(bg)
    createTopUI()
    createMiddleUI()
    createButtomUI()
	return _layer
end

function createTopUI( )
	local bulletinLayerSize = BulletinLayer.getLayerFactSize()
	-- 上标题栏 显示战斗力，银币，金币
    _topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,_layer:getContentSize().height)
    _topBg:setScale(g_fScaleX)
    _layer:addChild(_topBg, 10)
    local topBgSize = _topBg:getContentSize()
    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
    _topBg:addChild(powerDescLabel)
    
    _powerLabel = CCRenderLabel:create( UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(_powerLabel)
    
    -- modified by yangrui at 2015-12-03
    _silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,18)
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_silverLabel)
    
    _goldLabel = CCLabelTTF:create(UserModel.getGoldNumber()  ,g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_goldLabel)
	-- 上面的花边
    local border_filename = "images/recharge/mystery_merchant/border.png"
    local border_top = CCSprite:create(border_filename)
    border_top:setAnchorPoint(ccp(0, 0))
    border_top:setScale(g_fScaleX)
    border_top:setScaleY(-g_fScaleX)
    local border_top_y = _layerSize.height - topBgSize.height * g_fScaleX
    border_top:setPosition(0, border_top_y)
    _layer:addChild(border_top)
    _middleUIPosY = border_top_y - border_top:getContentSize().height * g_fScaleX - 15 * g_fScaleY
    local titleSp = CCSprite:create("images/pet/pet/zizhihuhuan_sp.png")
    titleSp:setAnchorPoint(ccp(0.5,1))
    titleSp:setPosition(ccp(_layerSize.width * 0.5,_layerSize.height - (topBgSize.height + 18) * g_fScaleX))
    titleSp:setScale(g_fScaleX)
    _layer:addChild(titleSp)
    local desSp = CCSprite:create("images/pet/pet/zizhihuhuan_desc_sp.png")
    desSp:setAnchorPoint(ccp(0.5,1))
    desSp:setPosition(ccpsprite(0.5,-0.2,titleSp))
    titleSp:addChild(desSp)
    -- 返回按钮
    local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 10)
	_layer:addChild(menu)
	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	backItem:setScale(MainScene.elementScale * 0.9)
    backItem:registerScriptTapHandler(closeBtnHandler)
    backItem:setScale(MainScene.elementScale)
    backItem:setAnchorPoint(ccp(0,1))
    backItem:setPosition(ccp(_layerSize.width - 100 * MainScene.elementScale, _layerSize.height - (topBgSize.height + 10) * g_fScaleX))
	menu:addChild(backItem)
end

function createMiddleUI( ... )
    -- body
    _petContSp = CCSprite:create()
    _petContSp:setContentSize(_petContSize)
    _petContSp:setAnchorPoint(ccp(0,1))
    _petContSp:setPosition(ccp(0,_middleUIPosY))
    _petContSp:setScaleX(g_fScaleX)
    _petContSp:setScaleY(g_fScaleY)
    _layer:addChild(_petContSp)
    -- 宠物脚下特效
    local img_path = CCString:create("images/pet/effect/fazhenfaguang/fazhenfaguang")
    local petBottomEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), -1,CCString:create(""))
    petBottomEffect:setPosition( _petContSize.width*0.25 ,30)
    petBottomEffect:setAnchorPoint(ccp(0.5,0))
    petBottomEffect:setScale(0.8)
    _petContSp:addChild(petBottomEffect)
    -- 宠物脚下特效
    local img_path = CCString:create("images/pet/effect/fazhenfaguang/fazhenfaguang")
    local petBottomEffect2 =  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), -1,CCString:create(""))
    petBottomEffect2:setPosition( _petContSize.width*0.75 ,30)
    petBottomEffect2:setAnchorPoint(ccp(0.5,0))
    petBottomEffect2:setScale(0.8)
    _petContSp:addChild(petBottomEffect2)

    local _petSp = createPetSp(_curPetInfo)
    _petSp:setPositionX(_petContSize.width * 0.25 - 10 * g_fScaleX)
    _petContSp:addChild(_petSp)
    local nameBg,advanceLvLabel = createNameArea(_curPetInfo)
    _petAdvanceLvLabel = advanceLvLabel
    nameBg:setPosition(ccpsprite(0.25,0,_petContSp))
    _petContSp:addChild(nameBg)
    -- 箭头
    local arrow = CCSprite:create("images/common/arrow1.png")
    arrow:setAnchorPoint(ccp(0.5, 0.5))
    arrow:setPosition(ccp(_petContSize.width * 0.5, _petContSize.height * 0.45))
    _petContSp:addChild(arrow)

    --右侧按钮层
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 10)
    _petContSp:addChild(menu)

    local normalSp = CCSprite:create()
    normalSp:setContentSize(CCSizeMake(100,100))
    local selectSp = CCSprite:create()
    selectSp:setContentSize(CCSizeMake(100,100))
    local menuItem = CCMenuItemSprite:create(normalSp,selectSp)
    menuItem:setAnchorPoint(ccp(0.5,0.5))
    menuItem:setPosition(ccp(_petContSize.width * 0.75,_petContSize.height * 0.4))
    menu:addChild(menuItem)
   
    menuItem:registerScriptTapHandler(addMenuItemCallBack)

    if not table.isEmpty(_swapPetInfo) then
        -- 选好的目标宠物
        _swapPetSp = createPetSp(_swapPetInfo)
        -- _swapPetSp:setAnchorPoint(ccp(0.5,0.5))
        _swapPetSp:setPositionX(_petContSize.width * 0.75 - 10 * g_fScaleX)
        _petContSp:addChild(_swapPetSp)

        _swapPetNameLabel,_swapAdvanceLvLabel = createNameArea(_swapPetInfo)
        _swapPetNameLabel:setPosition(ccpsprite(0.75,0,_petContSp))
        _petContSp:addChild(_swapPetNameLabel)
    else
        -- 加号按钮      
        local addSprite = ItemSprite.createLucencyAddSprite()
        addSprite:setAnchorPoint(ccp(0.5,0.5))
        addSprite:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
        menuItem:addChild(addSprite)
    end

end

function createButtomUI( ... )
    -- body
    _buttomUIPosY = _middleUIPosY - _petContSize.height * g_fScaleX
    local infoPanelPosY = (_buttomUIPosY - 80 * g_fScaleX) * 0.07 + 80 * g_fScaleX
    -- 宠物资质信息
    _curPetInfoPanel = createAptitudeInfoSp(_curPetInfo)
    -- _curPetInfoPanel:setAnchorPoint(ccp(0.5,0))
    _curPetInfoPanel:setPosition(ccp(_layerSize.width * 0.25,infoPanelPosY))
    -- _curPetInfoPanel:setScaleX(g_fScaleX)
    -- _curPetInfoPanel:setScaleY(g_fScaleY)
    _layer:addChild(_curPetInfoPanel)
    if not table.isEmpty(_swapPetInfo) then
        _swapPetInfoPanel = createAptitudeInfoSp(_swapPetInfo)
        -- _swapPetInfoPanel:setAnchorPoint(ccp(0.5,0))
        _swapPetInfoPanel:setPosition(ccp(_layerSize.width * 0.75,infoPanelPosY))
        -- _swapPetInfoPanel:setScaleX(g_fScaleX)
        -- _swapPetInfoPanel:setScaleY(g_fScaleY)
        _layer:addChild(_swapPetInfoPanel)
    end
    -- 箭头
    local arrow = CCSprite:create("images/common/arrow1.png")
    arrow:setAnchorPoint(ccp(0.5, 0.5))
    arrow:setPosition(ccp(_layerSize.width * 0.5,infoPanelPosY + _curPetInfoPanel:getContentSize().height * g_fScaleY / 2))
    arrow:setScaleX(g_fScaleX)
    arrow:setScaleY(g_fScaleY)
    _layer:addChild(arrow)
    createSwapBtn()
end
--[[
    @des    :创建兑换按钮
    @param  :
    @return :
--]]
function createSwapBtn( ... )
    -- body
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 10)
    _layer:addChild(menu)
    --按钮
    local normalSp = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    normalSp:setContentSize(CCSizeMake(190,75))
    local selectSp = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSp:setContentSize(CCSizeMake(190,75))
    local swapBtn = CCMenuItemSprite:create(normalSp,selectSp)
    swapBtn:setAnchorPoint(ccp(0.5,1))
    swapBtn:setPosition(ccp(_layerSize.width * 0.5,80 * g_fScaleX))
    menu:addChild(swapBtn)
    swapBtn:setScale(g_fScaleX)
    swapBtn:registerScriptTapHandler(swapCallBack)
    local richInfo = {
        linespace = 2, -- 行间距
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontPangWa,
        labelDefaultColor = ccc3(0xfe, 0xdb, 0x1c),
        labelDefaultSize = 30,
        defaultType = "CCRenderLabel",
        elements =
        {
            {
                type = "CCRenderLabel",
                newLine = false,
                text = GetLocalizeStringBy("syx_1088"),
                renderType = 2,-- 1 描边， 2 投影
            },
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png"
            },
            {
                type = "CCRenderLabel",
                newLine = false,
                text = PetData.getSwapGoldCost(),
                renderType = 2,-- 1 描边， 2 投影
            },
        }
    }
    require "script/libs/LuaCCLabel"
    local refreshLabel = LuaCCLabel.createRichLabel(richInfo)
    refreshLabel:setAnchorPoint(ccp(0.5, 0.5))
    refreshLabel:setPosition(ccp(swapBtn:getContentSize().width*0.5,swapBtn:getContentSize().height * 0.5))
    swapBtn:addChild(refreshLabel)
end

function swapCallBack( ... )
    -- body
    PetController.exchange(_curPetInfo,_swapPetInfo)
end

function addMenuItemCallBack( ... )
    -- body
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/pet/PetSwapSelectLayer"
    PetSwapSelectLayer.showLayer(_curPetInfo.petid,_swapedPetID)
end

function createPetSp( pPetInfo )
    local petTid = nil 
    local petDb = nil
    if(pPetInfo.petDesc) then 
        petTid= pPetInfo.petDesc.id
        petDb = DB_Pet.getDataById(petTid)
    end
    local offsetY = 0
    if petDb ~= nil then
        offsetY = petDb.Offset or 0
        if tonumber(offsetY) == 98 or tonumber(offsetY) == 95 then
            offsetY = 40
        end
    end
    local petSprite =  PetUtil.getPetIMGById(petTid ,1)
    petSprite:setAnchorPoint(ccp(0.5,0))
    petSprite:setPosition(ccp( 0 , (25 - offsetY)))
    petSprite:setScale(0.4)
    -- petSprite:setScale(MainScene.elementScale/g_fScaleX * 0.5)
    return petSprite
end
--[[
    @des    :创建品阶信息面板
    @param  :
    @return :
--]]
function createQualitySp( ... )
    -- body
    -- 品阶
    local retSprite = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
    retSprite:setContentSize(CCSizeMake(250, 75))
    retSprite:setAnchorPoint(ccp(0.5,1))
    retSprite:setScale(g_fScaleX)
    -- 标题背景
    local titleSp = CCSprite:create("images/common/red_2.png")
    titleSp:setAnchorPoint(ccp(0.5,0.5))
    titleSp:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height))
    retSprite:addChild(titleSp)
    -- 标题
    local titleFont = CCRenderLabel:create(GetLocalizeStringBy("syx_1087") ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleFont:setColor(ccc3(0xff,0xf6,0x00))
    titleFont:setAnchorPoint(ccp(0.5,0.5))
    titleFont:setPosition(ccp(titleSp:getContentSize().width*0.5,titleSp:getContentSize().height*0.5))
    titleSp:addChild(titleFont)
    return retSprite
end
--[[
    @des    :创建资质信息面板
    @param  :
    @return :
--]]
function createAptitudeInfoSp( pPetInfo )
	-- body
    local size = CCSizeMake(250, 200)
    -- 资质
    local aptitudeSp = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
    aptitudeSp:setContentSize(size)
    -- 标题背景
    local aptitudeTitleSp = CCSprite:create("images/common/red_2.png")
    aptitudeTitleSp:setAnchorPoint(ccp(0.5,0.5))
    aptitudeTitleSp:setPosition(ccp(aptitudeSp:getContentSize().width*0.5,aptitudeSp:getContentSize().height))
    aptitudeSp:addChild(aptitudeTitleSp)
    -- 标题
    local aptitudeTitleFont = CCRenderLabel:create(GetLocalizeStringBy("syx_1076") ,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    aptitudeTitleFont:setColor(ccc3(0xff,0xf6,0x00))
    aptitudeTitleFont:setAnchorPoint(ccp(0.5,0.5))
    aptitudeTitleFont:setPosition(ccp(aptitudeTitleSp:getContentSize().width*0.5,aptitudeTitleSp:getContentSize().height*0.5))
    aptitudeTitleSp:addChild(aptitudeTitleFont)
    -- 资质配置
    local aptitudeConfig = {
        {title = GetLocalizeStringBy("syx_1078"),attrID = "100"},
        {title = GetLocalizeStringBy("syx_1080"),attrID = "54"},
        {title = GetLocalizeStringBy("syx_1081"),attrID = "55"},
        {title = GetLocalizeStringBy("syx_1079"),attrID = "51"}
    }
    -- 资质
    local curPetAttrTable = {}
    if pPetInfo.va_pet then
        if pPetInfo.va_pet.confirmed then
            curPetAttrTable = pPetInfo.va_pet.confirmed
        end
    end
    local limitValueTable = PetData.getTrainAttrLimit(pPetInfo)
    for i,info in ipairs(aptitudeConfig) do
        local attrValue = curPetAttrTable[info.attrID] or 0
        local limitValue = limitValueTable[tonumber(info.attrID)] or 0
        local displayNum = PetData.getAttrDisplayNumByAttrID(pPetInfo,info.attrID,attrValue)
        -- 资质标题
        local titleLabel = CCRenderLabel:create(info.title,g_sFontName,20,1,ccc3(0,0,0),type_shadow)
        titleLabel:setColor(ccc3(0xff,0xff,0xff))
        titleLabel:setAnchorPoint(ccp(0,1))
        titleLabel:setPosition(ccp(10 * g_fScaleX / g_fScaleY,size.height * (11 - i * 2) / 11))
        aptitudeSp:addChild(titleLabel)
        -- 进度条
        local progressWidth = 170
        local progressBg = ProgressBar:create("images/hero/strengthen/bg_exp_bar.png", "images/hero/strengthen/green_bar.png", progressWidth, 100, nil,nil,false)
        progressBg:setAnchorPoint(ccp(0,0.5))
        progressBg:setPosition(ccpsprite(1,0.45,titleLabel))
        progressBg:setProgress(displayNum/limitValue)
        titleLabel:addChild(progressBg)
        -- 进度文本
        local progressLabel = progressBg:getProgressLabel()
        progressLabel:setString(displayNum .. "/" .. limitValue)
    end
    aptitudeSp:setAnchorPoint(ccp(0.5,0))
    aptitudeSp:setScaleX(g_fScaleX)
    aptitudeSp:setScaleY(g_fScaleY)
    return aptitudeSp
end

function showLayer( pPetId,pSwapPetInfo,pTouchPriority,pZOrder )
	-- body
	init()
	_curPetIndex = PetData.getFeededPetIndex(pPetId) or 1
    _curPetInfo = PetData.getFeededPetInfo()[_curPetIndex]
    _swapPetInfo = pSwapPetInfo or {}
    _swapedPetID = _swapPetInfo.petid
	_touchPriority = pTouchPriority or -380
	pZOrder = pZOrder or 600
    _layerSize = PetUtil.getPetLayerSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
	local layer = createLayer()
	layer:setPosition(ccp(0,menuLayerSize.height * g_fScaleX))
	MainScene.changeLayer(layer,"PetAptitudeSwapLayer")
end

function closeBtnHandler( ... )
	if not tolua.isnull(_layer) then
        -- 播放关闭音效
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
		require "script/ui/pet/PetMainLayer"
    	local layer = PetMainLayer.createLayer(PetMainLayer.getCurPetIndex())
    	MainScene.changeLayer(layer,"PetMainLayer")
	end
end

function createSwapSp( pPetInfo )
    -- body
    pPetInfo = pPetInfo or _curPetInfo
    if _swapPetSp then
        _swapPetSp:removeFromParentAndCleanup(true)
        _swapPetSp = nil
    end
    _swapPetSp = createPetSp(pPetInfo)
    _swapPetSp:setPositionX(_petContSize.width * 0.75)
    _petContSp:addChild(_swapPetSp)
end

function createNameArea( pPetInfo )
    -- body
    local pPetInfo = pPetInfo or _curPetInfo
    -- 名字的背景
    local fullRect = CCRectMake(0,0,111,32)
    local insetRect = CCRectMake(39,15,2,2)
    local nameBg= CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    nameBg:setPreferredSize(CCSizeMake(245,35))
    nameBg:setAnchorPoint(ccp(0.5,1))
    local nameLabel = CCRenderLabel:create(pPetInfo.petDesc.roleName,g_sFontPangWa,25,1,ccc3(0,0,0),type_shadow)
    nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(pPetInfo.petDesc.quality))
    nameLabel:setAnchorPoint(ccp(0.5,0))
    nameLabel:setPosition(ccpsprite(0.5,0,nameBg))
    nameBg:addChild(nameLabel)
    local evolveLevel = 0
    if pPetInfo.va_pet then
        evolveLevel = pPetInfo.va_pet.evolveLevel or 0
    end
    local advanceLvLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",evolveLevel),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
    advanceLvLabel:setColor(ccc3(0xff,0xf6,0x00))
    advanceLvLabel:setAnchorPoint(ccp(0,0.5))
    advanceLvLabel:setPosition(ccpsprite(1.1,0.5,nameLabel))
    nameLabel:addChild(advanceLvLabel)
    local lvSp= CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0))
    lvSp:setPosition(ccpsprite(-0.05,0.2,nameBg))
    nameBg:addChild(lvSp)
    local lvLabel= CCLabelTTF:create(pPetInfo.level,g_sFontPangWa, 21)-- 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvLabel:setColor(ccc3(0xff,0xf6,0x00))
    lvLabel:setAnchorPoint(ccp(0,0.5))
    lvLabel:setPosition(ccpsprite(1,0.5,lvSp))
    lvSp:addChild(lvLabel)
    return nameBg,advanceLvLabel
end

function updateAfterExchange( ... )
    -- body
    local infoPanelPosY = (_buttomUIPosY - 80 * g_fScaleX) * 0.07 + 80 * g_fScaleX
    if _curPetInfoPanel then
        _curPetInfoPanel:removeFromParentAndCleanup(true)
        _curPetInfoPanel = nil
    end
    -- 宠物资质信息
    _curPetInfoPanel = createAptitudeInfoSp(_curPetInfo)
    _curPetInfoPanel:setPosition(ccp(_layerSize.width * 0.25,infoPanelPosY))
    _layer:addChild(_curPetInfoPanel)

    if _swapPetInfoPanel then
        _swapPetInfoPanel:removeFromParentAndCleanup(true)
        _swapPetInfoPanel = nil
    end
    -- 宠物资质信息
    _swapPetInfoPanel = createAptitudeInfoSp(_swapPetInfo)
    _swapPetInfoPanel:setPosition(ccp(_layerSize.width * 0.75,infoPanelPosY))
    _layer:addChild(_swapPetInfoPanel)

    _petAdvanceLvLabel:setString(GetLocalizeStringBy("syx_1089",_curPetInfo.va_pet.evolveLevel))
    _swapAdvanceLvLabel:setString(GetLocalizeStringBy("syx_1089",_swapPetInfo.va_pet.evolveLevel))
    _goldLabel:setString(UserModel.getGoldNumber())
    _silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
end