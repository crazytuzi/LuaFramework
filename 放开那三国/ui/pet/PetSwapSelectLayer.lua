-- FileName: PetSwapSelectLayer.lua
-- Author: shengyixian
-- Date: 2016-03-01
-- Purpose: 宠物资质互换选择界面
module("PetSwapSelectLayer",package.seeall)
require "script/ui/pet/pet_aptitude_swap/PetAptitudeSwapCell"
local _bgLayer = nil
local _layerSize = nil
-- 进行替换的宠物id
local _petId = nil
local _myTableView = nil
local _topTitleSprite = nil
local _bottomSprite = nil
local _canSwaPetInfo = nil
-- 被替换的宠物id
local _swapedPetID = nil
-- 已经存在的吞噬宠物
local _existSwapedPetID = nil
function init( ... )
	-- body
	_bgLayer = nil
	_layerSize = nil
	_petId = nil
    _myTableView = nil
    _topTitleSprite = nil
    _bottomSprite = nil
    _canSwaPetInfo = nil
    _swapedPetID = nil
    _existSwapedPetID = nil
end

function createLayer( ... )
	-- body
    _bgLayer = CCLayer:create()
    local bg = CCSprite:create("images/main/module_bg.png")
    bg:setScale(g_fBgScaleRatio)
    _bgLayer:addChild(bg)
    local menuLayerSize = MenuLayer.getLayerContentSize()
    _layerSize = PetUtil.getPetLayerSize()
    _bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))
    _bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
    createTitleLayer()
    local label = CCRenderLabel:create(GetLocalizeStringBy("key_2913"), g_sFontPangWa , 26, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    label:setPosition(_layerSize.width*0.5, _layerSize.height*0.5 )
    label:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(label)
    createButtomUI()
    createTableView()
    return _bgLayer
end

function showLayer( pPetId,pSwapPetID,pTouchPriority,pZOrder )
	-- body
    init()
    _petId = pPetId
    _touchPriority = pTouchPriority or -380
    _existSwapedPetID = pSwapPetID
   	local layer = createLayer()
   	MainScene.changeLayer(layer ,"PetSwapSelectLayer")
end

function createTitleLayer( )
    -- 标题背景
    _topTitleSprite = CCSprite:create("images/hero/select/title_bg.png")
    _topTitleSprite:setScale(g_fScaleX)
    -- 标题
    local ccSpriteTitle = CCSprite:create("images/pet/pet/choose_pet.png")
    ccSpriteTitle:setPosition(ccp(45, 50))
    _topTitleSprite:addChild(ccSpriteTitle)
    local tItems = {
        {normal="images/common/close_btn_n.png", highlighted="images/common/close_btn_h.png", pos_x=493, pos_y=40, cb=closeAction},
    }
    local menu = LuaCC.createMenuWithItems(tItems)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(-432)
    _topTitleSprite:addChild(menu)
    _topTitleSprite:setPosition(0, _layerSize.height)
    _topTitleSprite:setAnchorPoint(ccp(0, 1))
    _bgLayer:addChild(_topTitleSprite)
end

function closeAction( ... )
    -- 播放关闭音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/pet/PetAptitudeSwapLayer"
    local swapPetInfo = nil
    if _existSwapedPetID then
        swapPetInfo = PetData.getPetInfoById(_existSwapedPetID)
    end
    PetAptitudeSwapLayer.showLayer(_petId,swapPetInfo)
end

function createButtomUI( ... )
    -- body
    _bottomSprite = CCSprite:create("images/common/sell_bottom.png")
    _bottomSprite:setScale(g_fScaleX)
    _bgLayer:addChild(_bottomSprite, 10)
    -- 确定按钮
    local sureMenuBar = CCMenu:create()
    sureMenuBar:setPosition(ccp(0,0))
    _bottomSprite:addChild(sureMenuBar)
    sureMenuBar:setTouchPriority(_touchPriority-5 )
    local sureBtn= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150,73),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    sureBtn:setAnchorPoint(ccp(0.5,0.5))
    sureBtn:setPosition(ccp(_bottomSprite:getContentSize().width*560/640, _bottomSprite:getContentSize().height*0.4))
    sureBtn:registerScriptTapHandler(sureBtnAction)
    sureMenuBar:addChild(sureBtn)
end

function createTableView( )
    print("_petId111",_petId)
    _canSwaPetInfo= PetData.getSwapPetInfo(_petId)
    print(" ------------------ _canSwaPetInfo --------------------------- ")
    print_t(_canSwaPetInfo)

    local cellSize = CCSizeMake(640*g_fScaleX,160*g_fScaleX)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
            local swapPetID = _swapedPetID or _existSwapedPetID
            a2 = PetAptitudeSwapCell.createCell(_canSwaPetInfo[a1 + 1], _touchPriority-1 ,swapPetID)
            a2:setScale(g_fScaleX)
            r = a2
        elseif fn == "numberOfCells" then
            r = #(_canSwaPetInfo)
        end
        return r
    end)
    local height = _layerSize.height- _topTitleSprite:getContentSize().height*g_fScaleX - _bottomSprite:getContentSize().height* g_fScaleX
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_layerSize.width,height))
    _myTableView:setAnchorPoint(ccp(0,0))
    _myTableView:setBounceable(true)
    _myTableView:setTouchPriority(_touchPriority-1)
    _myTableView:setPosition(ccp(0, (_bottomSprite:getContentSize().height) * g_fScaleX))
    _bgLayer:addChild(_myTableView, 9)
end

function rfcTableView( ... )
    -- body
    local offset = _myTableView:getContentOffset()
    _myTableView:reloadData()
    _myTableView:setContentOffset(offset)
end
function setSwapedPetID( pPetId )
    -- body
    _swapedPetID = pPetId
end

function getSwapedPetID( ... )
    -- body
    return _swapedPetID
end
function sureBtnAction( ... )
    -- body
    -- 播放关闭音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/pet/PetAptitudeSwapLayer"
    if _existSwapedPetID and _swapedPetID == nil then
        _swapedPetID = _existSwapedPetID
    end
    local swapPetInfo = PetData.getPetInfoById(_swapedPetID)
    PetAptitudeSwapLayer.showLayer(_petId,swapPetInfo)
end