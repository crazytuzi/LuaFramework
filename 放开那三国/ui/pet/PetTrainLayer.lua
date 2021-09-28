-- FileName: PetTrainLayer.lua
-- Author: shengyixian
-- Date: 2016-02-03
-- Purpose: 宠物培养
module("PetTrainLayer",package.seeall)
require "script/ui/guildBossCopy/ProgressBar"
-- 标志页面状态的值
local kTrainStatus = 0
local kToConfirm = 1

local _layer = nil
local _heroInfoPanel = nil
local _touchPriority = nil
local _scrollView = nil
local _scrollSize = nil
local _middleUIPosY = nil
local _buttonUIPosY = nil
local _petSp = nil
-- 被选择的单选按钮
local _selectedBtn = nil
-- 返回按钮
local _returnBtn = nil
-- 培养*1 按钮
local _train1Btn = nil
-- 培养*10 按钮
local _train10Btn = nil
-- 维持按钮
local _keepBtn = nil
-- 替换按钮
local _replaceBtn = nil
local _touchBeganPos = nil
local _nameBg = nil
local _nameLabel = nil
local _curLv = nil
local _advanceLvLabel = nil
-- 当前消耗的精魄数量文本
local _costValueLabel = nil
-- 当前选择的档位
local _gradeValue = nil
-- 待确定的属性值文本字典
-- 当前界面的状态：可培养状态或者培养后待确认状态
local _status = nil
-- 正在进行的是否是培养10次
local _isTrain10 = nil
-- 宠物信息
local _petInfoAry = nil
-- 进度条数组
local _progressBarAry = nil
-- 进度文本数组
local _progressLabelAry = nil
-- 培养属性数组
local _curAttrLabelAry = nil
-- 绿色箭头数组
local _arrowAry = nil
-- 材料数量文本数组
local _itemNumLabelAry = nil
local _arrowContainer = nil
local _lvLabel = nil
local _curPetInfo = nil
local _radioPanel   = nil
function init( ... )
	-- body
	_layer = nil
	_heroInfoPanel = nil
    _touchPriority = nil
    _scrollView = nil
    _scrollSize = CCSizeMake(640, 265)
    _middleUIPosY = nil
    _petSp = nil
    _selectedBtn = nil
    _touchBeganPos = nil
    _nameBg = nil
    _nameLabel = nil
    _curLv = nil
    _advanceLvLabel = nil
    _costValueLabel = nil
    _gradeValue = 1
    _petInfoAry = PetData.getIsEvolvePetInfo()
    _progressBarAry = nil
    _progressLabelAry = nil
    _curAttrLabelAry = nil
    _arrowAry = nil
    _status = nil
    _itemNumLabelAry = nil
    _arrowContainer = nil
    _lvLabel = nil
    _radioPanel   = nil
end

function createTopUI( ... )
	-- body
	local bulletinLayerSize = BulletinLayer.getLayerFactSize()
	createHeroInfoPanel()
	-- 上面的花边
    local border_filename = "images/recharge/mystery_merchant/border.png"
    local border_top = CCSprite:create(border_filename)
    border_top:setAnchorPoint(ccp(0, 0))
    border_top:setScale(g_fBgScaleRatio)
    border_top:setScaleY(-g_fBgScaleRatio)
    border_top:setVisible(false)
    local border_top_y = _layerSize.height - _heroInfoPanel:getContentSize().height * g_fBgScaleRatio
    border_top:setPosition(0, border_top_y)
    _layer:addChild(border_top)
    _middleUIPosY = border_top_y - border_top:getContentSize().height * g_fBgScaleRatio
    local titleSp = CCSprite:create("images/pet/train/train_title.png")
    titleSp:setAnchorPoint(ccp(0.5,1))
    titleSp:setPosition(ccp(_layerSize.width * 0.5,_layerSize.height - (_heroInfoPanel:getContentSize().height + 18) * g_fScaleX))
    titleSp:setScale(g_fScaleX)
    _layer:addChild(titleSp)
    local desSp = CCSprite:create("images/pet/train/train_say.png")
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
    backItem:setPosition(ccp(_layerSize.width - 100 * MainScene.elementScale, _layerSize.height - (_heroInfoPanel:getContentSize().height + 10) * g_fScaleX))
	menu:addChild(backItem)
end

function createHeroInfoPanel( ... )
    if _heroInfoPanel then
        _heroInfoPanel:removeFromParentAndCleanup(true)
        _heroInfoPanel = nil
    end
    _heroInfoPanel = PetUtil.createHeroInfoPanel()
    _heroInfoPanel:setAnchorPoint(ccp(0,1))
    _heroInfoPanel:setPosition(ccp(0,_layerSize.height))
    _heroInfoPanel:setScale(g_fScaleX)
    _layer:addChild(_heroInfoPanel)
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
	local bg = CCSprite:create("images/pet/pet_bg_2.jpg")
    bg:setAnchorPoint(ccp(0.5,1))
    bg:setPosition(ccpsprite(0.5,1.1,_layer))
    bg:setScale(g_fBgScaleRatio)	
    _layer:addChild(bg)
    createTopUI()
    createButtomUI()
    createMiddleUI()
	return _layer
end

function showLayer( pPetId,pTouchPriority,pZOrder )
	-- body
	init()
	_curPetIndex = PetData.getEvolvePetIndex(pPetId) or 1
    _curPetInfo = _petInfoAry[_curPetIndex]
	_touchPriority = pTouchPriority or -380
	pZOrder = pZOrder or 600
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
	_layerSize = CCSizeMake(0,0)
	_layerSize.width= g_winSize.width 
	_layerSize.height = g_winSize.height - (bulletinLayerSize.height + menuLayerSize.height) * g_fScaleX
	local layer = createLayer()
	layer:setPosition(ccp(0,menuLayerSize.height * g_fScaleX))
	MainScene.changeLayer(layer,"PetTrainLayer")
    if PetData.getIsConfirm(_curPetInfo)  then
        setStatus(kToConfirm)
    end
end

function onTouchHandler( eventType,x,y )
    if eventType == "began" then
        _touchBeganPos = ccp(x,y)
        local beganInNodePos = _scrollView:convertToNodeSpace(ccp(x,y))
        if x > 0 and x < _scrollSize.width * g_fScaleX and beganInNodePos.y > 0 and beganInNodePos.y < _scrollSize.height then
            return true
        end
    elseif eventType == "moved" then
        _scrollView:setContentOffset(ccp(x - _touchBeganPos.x - (_curPetIndex-1) * _scrollSize.width, 0))
    else
        -- local feededPetInfo = PetData.getIsEvolvePetInfo()
        local xOffset = x - _touchBeganPos.x
        if xOffset < -20 * g_fScaleX then
            setCurPetIndex(_curPetIndex + 1)
        elseif xOffset > 20 * g_fScaleX then
            setCurPetIndex(_curPetIndex - 1)
        end
        _scrollView:setContentOffsetInDuration(ccp(-(_curPetIndex -1)*_scrollSize.width, 0),0.2)
    end
end

function createMiddleUI( ... )
	-- body
    createScrollView()
    -- 名字的背景
    local fullRect = CCRectMake(0,0,111,32)
    local insetRect = CCRectMake(39,15,2,2)
    _nameBg= CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    _nameBg:setPreferredSize(CCSizeMake(245,35))
    _nameBg:setScale(g_fBgScaleRatio)
    _nameBg:setAnchorPoint(ccp(0.5,0))
    _nameBg:setPosition(_layerSize.width * 0.5 , _scrollView:getPositionY() - _scrollView:getContentSize().height * g_fBgScaleRatio)
    _layer:addChild(_nameBg,17)
    _nameLabel = CCRenderLabel:create(_curPetInfo.petDesc.roleName,g_sFontPangWa,25,1,ccc3(0,0,0),type_shadow)
    _nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_curPetInfo.petDesc.quality))
    _nameLabel:setAnchorPoint(ccp(0.5,0))
    _nameLabel:setPosition(ccpsprite(0.5,0,_nameBg))
    _nameBg:addChild(_nameLabel)
    _advanceLvLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",_curLv),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
    _advanceLvLabel:setColor(ccc3(0xff,0xf6,0x00))
    _advanceLvLabel:setAnchorPoint(ccp(0,0.5))
    _advanceLvLabel:setPosition(ccpsprite(1.1,0.5,_nameLabel))
    _nameLabel:addChild(_advanceLvLabel)
    createPetInfoPanel()
    local lvSp= CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0))
    lvSp:setPosition(ccpsprite(-0.05,0.2,_nameBg))
    _nameBg:addChild(lvSp)
    _lvLabel= CCLabelTTF:create(_curPetInfo.level,g_sFontPangWa, 21)-- 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _lvLabel:setColor(ccc3(0xff,0xf6,0x00))
    _lvLabel:setAnchorPoint(ccp(0,0.5))
    _lvLabel:setPosition(ccpsprite(1,0.5,lvSp))
    lvSp:addChild(_lvLabel)
end

function createScrollView( ... )
    -- body
    _curLv = tonumber(_curPetInfo.va_pet.evolveLevel) or 0
    _scrollView= CCScrollView:create()
    _scrollView:setViewSize(CCSizeMake(_scrollSize.width,_scrollSize.height))
    _scrollView:setContentSize(CCSizeMake(_scrollSize.width * table.count(_petInfoAry), _scrollSize.height ))
    _scrollView:setContentOffset(ccp(0,0))
    _scrollView:setScale(g_fBgScaleRatio)
    _scrollView:setAnchorPoint(ccp(0,1))
    _scrollView:ignoreAnchorPointForPosition(false)
    _scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    _scrollView:setPosition((_layerSize.width - _scrollSize.width*g_fBgScaleRatio)/2,_middleUIPosY)
    _layer:addChild(_scrollView,11)
    local scrollLayer = CCLayer:create()
    scrollLayer:setContentSize( CCSizeMake( _scrollSize.width*table.count(_petInfoAry), _scrollSize.height ))
    _scrollView:setContainer(scrollLayer)
    for i,petInfo in ipairs(_petInfoAry) do
        local petTid = nil 
        local petDb = nil
        if(petInfo.petDesc) then 
            petTid= petInfo.petDesc.id
            petDb = DB_Pet.getDataById(petTid)
        end
        local showStatus=  petInfo.showStatus
        local slotIndex= i
        local petSprite =  PetUtil.getPetIMGById(petTid ,showStatus, slotIndex)
        petSprite:setAnchorPoint(ccp(0.5,0))
        local offsetY = 0
        if petDb ~= nil then
            offsetY = petDb.Offset or 0
            if tonumber(offsetY) == 98 or tonumber(offsetY) == 95 then
                offsetY = 40
            end
        end
        petSprite:setPosition(ccp(_scrollSize.width*(i-0.5) , 25 - offsetY))
        petSprite:setScale(0.55)
        scrollLayer:addChild(petSprite,1)
    end
    _scrollView:setContentOffset(ccp(-(_curPetIndex -1)*_scrollSize.width , 0))
end

function createPetInfoPanel( ... )
    -- body
    local paneHeight = _nameBg:getPositionY()-_radioPanel:getPositionY()-_radioPanel:getContentSize().height*g_fElementScaleRatio-10*g_fElementScaleRatio
    local temHeight = paneHeight/g_fElementScaleRatio 
    local temData = 150
    if(temHeight > temData)then
        temHeight = temData
    end
    local panelSize = CCSizeMake(600,temHeight)
    --宠物属性显示面板
    local infoPanle  = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
    infoPanle:setContentSize(panelSize)
    infoPanle:setAnchorPoint(ccp(0.5, 0))
    infoPanle:setPosition(ccp(_layerSize.width / 2,10 * g_fScaleX + 70 * g_fElementScaleRatio * 0.9 + 182 * g_fElementScaleRatio))
    infoPanle:setScale(g_fElementScaleRatio)
    _layer:addChild(infoPanle)
    -- 箭头
    _arrowContainer = CCSprite:create()
    _arrowContainer:setContentSize(panelSize)
    infoPanle:addChild(_arrowContainer)
    _buttonUIPosY = infoPanle:getPositionY() - infoPanle:getContentSize().height * g_fScaleX
    local attrInfoAry = PetData.getTrainAttrData(_curPetInfo)
    local aptitudeInfoAry = {}
    -- 是否是确认洗脸属性的状态
    local isToConfirm = false
    _progressLabelAry = {}
    _progressBarAry = {}
    _curAttrLabelAry = {}
    _arrowAry = {}
    for i,attrDesc in ipairs(attrInfoAry) do
        local tempTable = {}
        tempTable.title = attrDesc.sigleName.."："
        tempTable.attrValue = 0
        tempTable.toConfirmValue = nil
        tempTable.id = attrDesc.id
        if _curPetInfo.va_pet.toConfirm then
            tempTable.toConfirmValue = tonumber(_curPetInfo.va_pet.toConfirm[tostring(attrDesc.id)]) or 0
            isToConfirm = true
        else
            isToConfirm = false
        end
        if _curPetInfo.va_pet.confirmed then
            tempTable.attrValue = tonumber(_curPetInfo.va_pet.confirmed[tostring(attrDesc.id)]) or 0
        else
            tempTable.attrValue = 0
        end
        tempTable.attrValue = PetData.getAttrDisplayNumByAttrID(_curPetInfo,attrDesc.id,tempTable.attrValue)
        tempTable.toConfirmValue = PetData.getAttrDisplayNumByAttrID(_curPetInfo,attrDesc.id,tempTable.toConfirmValue)
        table.insert(aptitudeInfoAry,tempTable)
    end
    local posY = {0.7,0.7,0.3,0.3}
    for i,info in ipairs(aptitudeInfoAry) do
        -- 资质标题
        local titleLabel =  CCRenderLabel:create(info.title,g_sFontName,25,1,ccc3(0x00,0x00,0x00),type_shadow)
        -- 红绿箭头
        local arrowTempAry = {}
        table.insert(_arrowAry,arrowTempAry)
        local greenArrowSprite = CCSprite:create("images/item/equipFixed/up.png")
        greenArrowSprite:setScale(0.8)
        _arrowContainer:addChild(greenArrowSprite)
        -- greenArrowSprite:setVisible(false)
        table.insert(arrowTempAry,greenArrowSprite)
        local redArrowSprite = CCSprite:create("images/item/equipFixed/down.png")
        redArrowSprite:setScale(0.8)
        _arrowContainer:addChild(redArrowSprite)
        -- redArrowSprite:setVisible(false)
        table.insert(arrowTempAry,redArrowSprite)
        if i % 2 == 0 then
            titleLabel:setAnchorPoint(ccp(0,0.5))
            titleLabel:setPosition(ccp(panelSize.width / 2 + 10 ,panelSize.height*posY[i]))
            greenArrowSprite:setAnchorPoint(ccp(1,0.5))
            greenArrowSprite:setPosition(ccpsprite(0.97,posY[i],infoPanle))
            redArrowSprite:setAnchorPoint(ccp(1,0.5))
            redArrowSprite:setPosition(ccpsprite(0.97,posY[i],infoPanle))
        else
            titleLabel:setAnchorPoint(ccp(0,0.5))
            titleLabel:setPosition(ccp(20,panelSize.height*posY[i]))
            greenArrowSprite:setAnchorPoint(ccp(0.5,0.5))
            greenArrowSprite:setPosition(ccpsprite(0.47,posY[i],infoPanle))
            redArrowSprite:setAnchorPoint(ccp(0.5,0.5))
            redArrowSprite:setPosition(ccpsprite(0.47,posY[i],infoPanle))
        end
        -- titleLabel:setScale(1.1)
        infoPanle:addChild(titleLabel)
        -- 可培养属性值上限
        local limitValue = PetData.getTrainAttrLimit( _curPetInfo )[info.id]
        -- 进度条
        local progressWidth = 120
        local progressBg = ProgressBar:create("images/hero/strengthen/bg_exp_bar.png", "images/hero/strengthen/green_bar.png", progressWidth, 100, nil,nil,false)
        progressBg:setAnchorPoint(ccp(0,0.5))
        progressBg:setPosition(ccpsprite(1,0.45,titleLabel))
        progressBg:setProgress(info.attrValue/limitValue)
        titleLabel:addChild(progressBg)
        table.insert(_progressBarAry,progressBg)
        -- 进度文本
        local progressLabel = progressBg:getProgressLabel()
        progressLabel:setString(info.attrValue .. "/" .. limitValue)
        table.insert(_progressLabelAry,progressLabel)
        -- 培养属性
        local trainedLabel = CCRenderLabel:create("+"..0,g_sFontName,22,1,ccc3(0x00,0x00,0x00),type_shadow)
        trainedLabel:setAnchorPoint(ccp(0,0.5))
        trainedLabel:setPosition(ccpsprite(1.05,0.5,progressBg))
        progressBg:addChild(trainedLabel)
        table.insert(_curAttrLabelAry,trainedLabel)
        local trainedLabelColor = nil
        if info.toConfirmValue ~= nil and info.toConfirmValue ~= 0 then
            info.toConfirmValue = info.toConfirmValue - info.attrValue
        else 
            info.toConfirmValue = 0
        end
        if info.toConfirmValue >= 0 then
            trainedLabelColor = ccc3(0x00,0xff,0x18)
            trainedLabel:setString("+"..info.toConfirmValue)
            _arrowAry[i][1]:setVisible(true)
            _arrowAry[i][2]:setVisible(false)
        else
            trainedLabelColor = ccc3(0xff,0x00,0x00)
            trainedLabel:setString(info.toConfirmValue)
            _arrowAry[i][1]:setVisible(false)
            _arrowAry[i][2]:setVisible(true)
        end
        trainedLabel:setColor(trainedLabelColor)
        if not isToConfirm then
            trainedLabel:setVisible(false)
            _arrowContainer:setVisible(false)
        end
    end
    -- 背景
    -- local sayBg = CCScale9Sprite:create("images/pet/evolve/lv_bg.png")
    -- sayBg:setContentSize(CCSizeMake(400,34))
    -- sayBg:setAnchorPoint(ccp(0.5,0))
    -- sayBg:setPosition(ccpsprite(0.5,0.1,infoPanle))
    -- infoPanle:addChild(sayBg)
    -- local saySp = CCSprite:create("images/pet/train/say_sp.png")
    -- saySp:setAnchorPoint(ccp(0.5,0.5))
    -- saySp:setPosition(ccpsprite(0.5,0.5,sayBg))
    -- sayBg:addChild(saySp)
end

function createButtomUI( ... )
	-- body
    -- 创建按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 10)
    _layer:addChild(menu)
    -- local posY = 20 * g_fScaleX
    local posY = 8 * g_fScaleX
    _returnBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("key_10014"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _returnBtn:setAnchorPoint(ccp(0.5,0))
    _returnBtn:setPosition(_layerSize.width * 0.2,posY )
    _returnBtn:registerScriptTapHandler(closeBtnHandler)
    _returnBtn:setScale(MainScene.elementScale * 0.9)
    menu:addChild(_returnBtn)
    _replaceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200,75),GetLocalizeStringBy("key_2370"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _replaceBtn:setAnchorPoint(ccp(0.5,0))
    _replaceBtn:setPosition(_layerSize.width * 0.8,posY )
    _replaceBtn:registerScriptTapHandler(replaceCallBack)
    _replaceBtn:setScale(MainScene.elementScale * 0.9)
    _replaceBtn:setVisible(false)
    menu:addChild(_replaceBtn)
    _train1Btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("syx_1083"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _train1Btn:setAnchorPoint(ccp(0.5,0))
    _train1Btn:setPosition(_layerSize.width * 0.5,posY )
    _train1Btn:registerScriptTapHandler(trainHandler)
    _train1Btn:setScale(MainScene.elementScale * 0.9)
    menu:addChild(_train1Btn)
    _keepBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("key_2326"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _keepBtn:setAnchorPoint(ccp(0.5,0))
    _keepBtn:setPosition(_layerSize.width * 0.2,posY )
    _keepBtn:registerScriptTapHandler(keepCallBack)
    _keepBtn:setScale(MainScene.elementScale * 0.9)
    _keepBtn:setVisible(false)
    menu:addChild(_keepBtn)
    _train10Btn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("syx_1084"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _train10Btn:setAnchorPoint(ccp(0.5,0))
    _train10Btn:setPosition(_layerSize.width * 0.8,posY )
    _train10Btn:registerScriptTapHandler(train10Handler)
    _train10Btn:setScale(MainScene.elementScale * 0.9)
    menu:addChild(_train10Btn)
    --单选按钮组
    _radioPanel = createRadioMenu()
    _radioPanel:setAnchorPoint(ccp(0.5, 0))
    -- _radioPanel:setPosition(ccp(g_winSize.width / 2,_buttonUIPosY + 10 * g_fScaleX))
    _radioPanel:setPosition(ccp(g_winSize.width / 2,posY + 70 * g_fElementScaleRatio * 0.9))
    _layer:addChild(_radioPanel)
    -- _radioPanel:setScale(g_fScaleX * 0.8)
    _radioPanel:setScale(g_fElementScaleRatio)
end
--[[
    @des:   单次洗练按钮回调事件
--]]
function trainHandler( pTag,pItem )
    -- body
    local isForce = 0
    if _status == kToConfirm then
        isForce = 1
    end
    local callBack = function ( ... )
        _arrowContainer:setVisible(true)
        updateCurAttrValueLabel()
        setStatus(kToConfirm)
        _itemNumLabelAry[_gradeValue]:setString(PetData.getItemIdByTrainGrade(_curPetInfo ,_gradeValue) - PetData.getItemCostNumByPetNowAttNum(_curPetInfo ))
    end
    PetController.wash(_curPetInfo,_gradeValue,1,callBack,isForce)
end

function train10Handler( pData,pNum )
    -- body
    local isForce = 0
    if _status == kToConfirm then
        isForce = 1
    end
    PetController.wash(_curPetInfo,_gradeValue,10,train10CallBack,isForce)
end
function train10CallBack( pData,pNum )
    -- body
    _arrowContainer:setVisible(true)
    _isTrain10 = true
    updateCurAttrValueLabel()
    setStatus(kToConfirm)
    _itemNumLabelAry[_gradeValue]:setString(PetData.getItemIdByTrainGrade(_curPetInfo,_gradeValue) - PetData.getItemCostNumByPetNowAttNum(_curPetInfo) * pNum)
end
--[[
    @des:   舍弃属性
--]]
function keepCallBack( ... )
    -- body
    local callBack = function ( isConfirm )
        -- body
        if not isConfirm then
            return
        end
        local callBack = function ( ... )
            -- body
            _isTrain10 = false
            setStatus(kTrainStatus)
            updateCurAttrValueLabel()
            _arrowContainer:setVisible(false)
        end
        PetController.giveUp(_curPetInfo,callBack)
    end
    AlertTip.showAlert(GetLocalizeStringBy("syx_1100"),callBack,true)
end
--[[
    @des:   替换属性
--]]
function replaceCallBack( ... )
    -- body
    local callBack = function ( ... )
        -- body
        _isTrain10 = false
        setStatus(kTrainStatus)
        updateProgressUI()
        updateCurAttrValueLabel()
        _arrowContainer:setVisible(false)
        _costValueLabel:setString(PetData.getItemCostNumByPetNowAttNum(_curPetInfo))
    end
    PetController.ensure(_curPetInfo,callBack)
end
--[[
    @des: 更新当前培养的属性文本
--]]
function updateCurAttrValueLabel( ... )
    -- body
    local toConfirm = _curPetInfo.va_pet.toConfirm
    local confirmed = _curPetInfo.va_pet.confirmed
    if confirmed == nil then
        confirmed = {}
    end
    if toConfirm == nil then
        for i,label in ipairs(_curAttrLabelAry) do
            label:setVisible(false)
        end
    else
        local attrData = PetData.getTrainAttrData(_curPetInfo)
        for i,info in ipairs(attrData) do
            local attrValue = tonumber(toConfirm[tostring(info.id)]) or 0
            local nowValue = tonumber(confirmed[tostring(info.id)]) or 0
            if attrValue ~= 0 then
                attrValue = PetData.getAttrDisplayNumByAttrID(_curPetInfo,info.id,attrValue)
                nowValue = PetData.getAttrDisplayNumByAttrID(_curPetInfo,info.id,nowValue)
                attrValue = attrValue - nowValue
            end
            local labelColor = nil
            if attrValue >= 0 then
                labelColor = ccc3(0x00,0xff,0x18)
                _curAttrLabelAry[i]:setString("+"..attrValue)
                _arrowAry[i][1]:setVisible(true)
                _arrowAry[i][2]:setVisible(false)
            else
                labelColor = ccc3(0xff,0x00,0x00)
                _curAttrLabelAry[i]:setString(attrValue)
                _arrowAry[i][1]:setVisible(false)
                _arrowAry[i][2]:setVisible(true)
            end
            _curAttrLabelAry[i]:setVisible(true)
            _curAttrLabelAry[i]:setColor(labelColor)
        end
    end
end
--[[
    @des: 更新属性进度UI
--]]
function updateProgressUI( ... )
    -- body
    local confirmed = _curPetInfo.va_pet.confirmed
    local limitValueMap = PetData.getTrainAttrLimit(_curPetInfo)
    local attrData = PetData.getTrainAttrData(_curPetInfo)
    for i,info in ipairs(attrData) do
        local limitValue = limitValueMap[info.id]
        local attrValue = 0
        if confirmed then
            attrValue = tonumber(confirmed[tostring(info.id)]) or 0
            attrValue = PetData.getAttrDisplayNumByAttrID(_curPetInfo,info.id,attrValue)
        end
        _progressBarAry[i]:setProgress(attrValue/limitValue)
        _progressLabelAry[i]:setString(attrValue.."/"..limitValue)
    end
end

--[[
    @des:   单选按钮回调事件
]]
function radioCallback( tag, item )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- 切换按钮状态
    _selectedBtn:unselected()
    _selectedBtn = item
    _selectedBtn:selected()
    _gradeValue = tag
end

--[[
    @des    :设置当前宠物的索引变量
    @param  :
    @return :
--]]
function setCurPetIndex( pValue )
    if pValue > table.count(_petInfoAry) then
        pValue = table.count(_petInfoAry)
    elseif pValue < 1 then
        pValue = 1
    end
    if _curPetIndex ~= pValue then
        _curPetIndex = pValue
        _curPetInfo = _petInfoAry[_curPetIndex]
        _nameLabel:setString(_curPetInfo.petDesc.roleName)
        _nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(_curPetInfo.petDesc.quality))
        _curLv = _curPetInfo.va_pet.evolveLevel or 0
        _advanceLvLabel:setString(GetLocalizeStringBy("syx_1089",_curLv))
        _advanceLvLabel:setPosition(ccpsprite(1.1,0.5,_nameLabel))
        updateAttrPanel()
    end
end

--[[
    @des:   创建洗练档次选择按钮
]]
function createRadioMenu( ... )
    local bgPanel =  CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
    bgPanel:setContentSize(CCSizeMake(600, 180))
    local petInfo = _petInfoAry[_curPetIndex]
    local btMenu  = CCMenu:create()
    btMenu:setPosition(ccp(0, 0))
    btMenu:setAnchorPoint(ccp(0, 0))
    btMenu:setTouchPriority(_touchPriority - 10)
    bgPanel:addChild(btMenu)
    local itemIDAry = {60108,60109,60110}
    local imageNameAry = {}
    for i,itemID in ipairs(itemIDAry) do
        imageNameAry[i] = DB_Item_normal.getDataById(itemID).icon_little
    end
    local radioConfig = {
        {icon = "images/base/props/"..imageNameAry[1],nameSp = "images/pet/train/chu.png",num = PetData.getItemIdByTrainGrade(petInfo,1)},
        {icon = "images/base/props/"..imageNameAry[2],nameSp = "images/pet/train/gao.png",num = PetData.getItemIdByTrainGrade(petInfo,2)},
        {icon = "images/base/props/"..imageNameAry[3],nameSp = "images/pet/train/shen.png",num = PetData.getItemIdByTrainGrade(petInfo,3)},
    }
    _itemNumLabelAry = {}
    for i,config in ipairs(radioConfig) do
        local btn = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png")
        btn:setPosition(45 * g_fScaleX / g_fScaleY, bgPanel:getContentSize().height * (0.85 - (i - 1) * 0.25))
        btn:setAnchorPoint(ccp(0.5, 0.5))
        btn:registerScriptTapHandler(radioCallback)
        btMenu:addChild(btn,1,i)
        if i == 1 then
            --设置默认选择
            _selectedBtn = btn
            _selectedBtn:selected()
        end
        -- 精魄名称sp
        local nameSp = CCSprite:create(radioConfig[i].nameSp)
        nameSp:setAnchorPoint(ccp(0,0.5))
        nameSp:setPosition(ccpsprite(1.5,0.45,btn))
        btn:addChild(nameSp)
        -- 剩余
        local ownNumLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1093"),g_sFontName,21,1,ccc3(0,0,0),type_shadow)
        ownNumLabel:setAnchorPoint(ccp(0,0.5))
        ownNumLabel:setPosition(ccpsprite(1.5,0.45,nameSp))
        nameSp:addChild(ownNumLabel)
        -- icon
        local icon = CCSprite:create(radioConfig[i].icon)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(ccpsprite(1,0.45,ownNumLabel))
        ownNumLabel:addChild(icon)
        -- 数量文本
        local numLabel = CCRenderLabel:create(config.num,g_sFontName,21,1,ccc3(0,0,0),type_shadow)
        numLabel:setAnchorPoint(ccp(0,0.5))
        numLabel:setPosition(ccpsprite(1.1,0.45,icon))
        icon:addChild(numLabel)
        table.insert(_itemNumLabelAry,numLabel)
    end
    local sayLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1094"),g_sFontName,21,1,ccc3(0,0,0),type_shadow)
    sayLabel:setAnchorPoint(ccp(0.5,0))
    sayLabel:setPosition(ccpsprite(0.5,0.05,bgPanel))
    bgPanel:addChild(sayLabel)
    _costValueLabel = CCRenderLabel:create(PetData.getItemCostNumByPetNowAttNum(petInfo),g_sFontName,18,1,ccc3(0,0,0),type_shadow)
    _costValueLabel:setAnchorPoint(ccp(0,0.5))
    _costValueLabel:setColor(ccc3(0x00,0xff,0x18))
    _costValueLabel:setPosition(ccpsprite(1,0.5,sayLabel))
    sayLabel:addChild(_costValueLabel)
    return bgPanel
end

function closeBtnHandler( ... )
	if not tolua.isnull(_layer) then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
		require "script/ui/pet/PetMainLayer"
    	local layer = PetMainLayer.createLayer(PetMainLayer.getCurPetIndex())
    	MainScene.changeLayer(layer,"PetMainLayer")
	end
end

function setStatus( pStatus )
    -- body
    if _status ~= pStatus then
        _status = pStatus
        local posY = 8 * g_fScaleX
        if _status == kTrainStatus then
            _replaceBtn:setEnabled(false)
            _replaceBtn:setVisible(false)
            _keepBtn:setVisible(false)
            _keepBtn:setEnabled(false)
            _train1Btn:setVisible(true)
            _train1Btn:setEnabled(true)
            _train1Btn:setPosition(ccp(_layerSize.width * 0.5,posY))
            _train10Btn:setVisible(true)
            _train10Btn:setEnabled(true)
            _train10Btn:setPosition(ccp(_layerSize.width * 0.8,posY))
            _returnBtn:setEnabled(true)
            _returnBtn:setVisible(true)
            _arrowContainer:setVisible(false)
        else
            _returnBtn:setEnabled(false)
            _returnBtn:setVisible(false)
            _replaceBtn:setVisible(true)
            _replaceBtn:setEnabled(true)
            _keepBtn:setVisible(true)
            _keepBtn:setEnabled(true)
            _arrowContainer:setVisible(true)
            if _isTrain10 then
                -- 显示培养10次按钮
                _train10Btn:setVisible(true)
                _train10Btn:setEnabled(true)
                _train1Btn:setVisible(false)
                _train1Btn:setEnabled(false)
                _train10Btn:setPosition(ccp(_layerSize.width * 0.5,posY))
            else
                _train1Btn:setVisible(true)
                _train1Btn:setEnabled(true)
                _train1Btn:setPosition(ccp(_layerSize.width * 0.5,posY))
                _train10Btn:setVisible(false)
                _train10Btn:setEnabled(false)
            end
        end
    end
end
--[[
    @des    :选择宠物后更新属性面板
    @param  :
    @return :
--]]
function updateAttrPanel( ... )
    -- body
    updateCurAttrValueLabel()
    updateProgressUI()
    if PetData.getIsConfirm(_curPetInfo) then
        setStatus(kToConfirm)
    else
        setStatus(kTrainStatus)
    end
    _costValueLabel:setString(PetData.getItemCostNumByPetNowAttNum(_curPetInfo))
end