-- Filename：	TransferLayer.lua
-- Author：		bzx
-- Date：		2014-09-05
-- Purpose：		武将变身

module ("TransferLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "db/DB_Heroes"
require "script/utils/BaseUI"
require "script/ui/rechargeActive/ActiveCache"
require "script/ui/tip/SingleTip"
require "script/ui/rechargeActive/transfer/TransferData"

local FIXED = 1
local NORMAL = 2

local _layer
local _countryMasks
local _touchPriority        = -128
local _transferBtn
local _retransferBtn
local _cancelBtn
local _replaceBtn
local _fixedTransferBtn
local _fixedReplaceBtn
local _selectedHeroData
local _backBtn
local _oldHeroData         
local _newHeroData
local _selectedTagSprite
local _selectedCountryIndex
local _transferCost
local _oldHeroSprite
local _newHeroSprite
local _menu
local _transferType = NORMAL
local _radioData
local _selectBar
local _cannotSelectCountry
local _selectBg
local _layerSize = nil

function init()
    _countryMasks = {}
    _selectedTagSprite = nil
    _newHeroData = nil
    _oldHeroSprite = nil
    _newHeroSprite = nil
    _fixedReplaceBtn = nil
    -- test 
    --_oldHeroData =  HeroModel.getHeroByHid(10010932)
    _oldHeroData = _selectedHeroData or ActiveCache.getTransferHero()
    if _oldHeroData ~= nil and _selectedHeroData == nil then
        _newHeroData = table.hcopy(_oldHeroData, {})
        _newHeroData.htid = _oldHeroData.transfer
        if _oldHeroData.dxtrans == "1" or _oldHeroData.localInfo.heroQuality == 15 then
            _transferType = FIXED
        end
    end
    _selectedHeroData = nil
    _layerSize = nil
end

function create( p_layerSize )
    init()
    _layerSize = p_layerSize
    _layer = CCLayer:create()
    _layer:setContentSize(_layerSize)
    loadBg()
    -- loadTop()
    loadCenter()
    loadBottom()
    return _layer
end

function loadBg()
    local bg = CCSprite:create("images/destney/destney_bg.png")
    _layer:addChild(bg)
    bg:setScale(MainScene.bgScale)
end

function loadTop()
    local bulletinHeight = RechargeActiveMain.getTopSize().height
    local activeBarHeight = RechargeActiveMain.getBgWidth()
    local transferTitle = CCSprite:create("images/recharge/transfer/hero_transfer.png")
    _layer:addChild(transferTitle)
    transferTitle:setAnchorPoint(ccp(0.5, 1))
    transferTitle:setPosition(ccp(_layerSize.width * 0.5, _layerSize.height - bulletinHeight * g_fScaleX - activeBarHeight))
    transferTitle:setScale(MainScene.elementScale)
    
    local line = CCSprite:create("images/recharge/transfer/line.png")
    transferTitle:addChild(line)
    line:setAnchorPoint(ccp(0.5, 1))
    line:setPosition(ccpsprite(0.5, 0, transferTitle))
end

function previewCallback()
    require "script/ui/rechargeActive/transfer/PreviewLayer"
    PreviewLayer.show(_touchPriority - 300, 2000)
end

function loadCenter()
    refreshOldHero()
    -- local transferTip = CCSprite:create("images/recharge/transfer/transfer.png")
    -- _layer:addChild(transferTip)
    -- transferTip:setAnchorPoint(ccp(0.5, 0.5))
    -- transferTip:setPosition(ccp(_layerSize.width * 0.5, 0.65 * _layerSize.height))
    -- transferTip:setScale(MainScene.elementScale)
    local arrow = CCSprite:create("images/hero/transfer/arrow.png")
    _layer:addChild(arrow)
    arrow:setAnchorPoint(ccp(0.5, 0.5))
    arrow:setPosition(ccp(_layerSize.width * 0.5, 0.7* _layerSize.height))
    arrow:setScale(0.7 * MainScene.elementScale)
    refreshNewHero()
    
    local menu = CCMenu:create()
    _layer:addChild(menu)
    menu:setPosition(ccp(0, 0))
    local previewBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", CCSizeMake(160, 73), GetLocalizeStringBy("key_8317"), ccc3(0xfe, 0xdb, 0x1c), 30, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(previewBtn)
    previewBtn:setAnchorPoint(ccp(0.5, 0))
    previewBtn:setPosition(ccp(_layerSize.width * 0.5, _layerSize.height * 0.5))
    previewBtn:setScale(MainScene.elementScale)
    previewBtn:registerScriptTapHandler(previewCallback)
end

function refreshOldHero()
    if _oldHeroSprite ~= nil then
        _oldHeroSprite:removeFromParentAndCleanup(true)
    end
     _oldHeroSprite = createHero(_oldHeroData, "+")
     _layer:addChild(_oldHeroSprite)
    _oldHeroSprite:setAnchorPoint(ccp(0.5, 0))
    _oldHeroSprite:setPosition(150 * MainScene.elementScale, 0.5* _layerSize.height)
    _oldHeroSprite:setScale(MainScene.elementScale)
end

function refreshNewHero()
    if _newHeroSprite ~= nil then
        _newHeroSprite:removeFromParentAndCleanup(true)
    end
    _newHeroSprite = createHero(_newHeroData, "?")
    _layer:addChild(_newHeroSprite)
    _newHeroSprite:setAnchorPoint(ccp(0.5, 0))
    _newHeroSprite:setPosition(ccp(_layerSize.width  - 150 * MainScene.elementScale, 0.5* _layerSize.height))
    _newHeroSprite:setScale(MainScene.elementScale)
end

function loadBottom()
    local selectBg = CCScale9Sprite:create("images/common/bg/9s_1.png")
    _selectBg = selectBg
    _layer:addChild(selectBg)
    selectBg:setContentSize(CCSizeMake(640, 222))
    selectBg:setAnchorPoint(ccp(0.5, 0))
    selectBg:setPosition(ccp(_layerSize.width * 0.5,  20*MainScene.elementScale))
    selectBg:setScale(MainScene.elementScale)
    
    local tip = CCRenderLabel:create(GetLocalizeStringBy("key_8318"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    selectBg:addChild(tip)
    tip:setAnchorPoint(ccp(0.5, 0))
    tip:setPosition(ccp(selectBg:getContentSize().width * 0.5, selectBg:getContentSize().height + 5))
    
    local selectLimitTip = CCRenderLabel:create(GetLocalizeStringBy("key_8338"), g_sFontName, 18, 1, ccc3(0, 0, 0), type_shadow)
    selectBg:addChild(selectLimitTip)
    selectLimitTip:setAnchorPoint(ccp(1, 0.5))
    selectLimitTip:setPosition(ccp(selectBg:getContentSize().width - 10, selectBg:getContentSize().height - 20))
    selectLimitTip:setColor(ccc3(0x00, 0xe4, 0xff))
    local selectTip = CCSprite:create("images/recharge/transfer/select_tip.png")
    selectBg:addChild(selectTip)
    selectTip:setAnchorPoint(ccp(0, 1))
    selectTip:setPosition(ccp(20, selectBg:getContentSize().height - 7))
    local cannotSelectCountry = false
    if _oldHeroData ~= nil then
        local heroDb = DB_Heroes.getDataById(_oldHeroData.htid)
        if heroDb.heroQuality == 13 or heroDb.heroQuality == 15 then
            cannotSelectCountry = true
        end
    end
    _cannotSelectCountry = cannotSelectCountry
    local radioData = {
        touch_priority      = _touchPriority,   -- 触摸优先级
        space               = 40,              -- 按钮间距
        callback            = selectedCountryCallback, -- 按钮回调
        direction           = 1,                -- 方向 1为水平，2为竖直
        items = {}
    }
    _radioData = radioData
    if _cannotSelectCountry == true then
        radioData.defaultIndex = 0
    else
        if _newHeroData ~= nil then
            local heroDb = DB_Heroes.getDataById(_newHeroData.htid)
            radioData.defaultIndex = heroDb.country
        end
    end
    local countryImages = {
        {normal = "images/chat/wei_n.png", selected = "images/chat/wei_h.png"},
        {normal = "images/chat/shu_n.png", selected = "images/chat/shu_h.png"},
        {normal = "images/chat/wu_n.png", selected = "images/chat/wu_h.png"},
        {normal = "images/chat/qun_n.png", selected = "images/chat/qun_h.png"}
    }
    for i = 1, #countryImages do
        local countryImage = countryImages[i]
        local normal = CCSprite:create("images/recharge/transfer/country_bg.png")
        local bgMask = CCSprite:create("images/recharge/transfer/country_bg_mask.png")
        normal:addChild(bgMask)
        bgMask:setAnchorPoint(ccp(0.5, 0.5))
        bgMask:setPosition(ccpsprite(0.5, 0.5, normal))
        local countryNormal = CCSprite:create(countryImage.normal)
        normal:addChild(countryNormal)
        countryNormal:setAnchorPoint(ccp(0.5, 0.5))
        countryNormal:setPosition(ccpsprite(0.5, 0.5, normal))
        local selected = CCSprite:create("images/recharge/transfer/country_bg.png")
        local countrySelected = CCSprite:create(countryImage.selected)
        selected:addChild(countrySelected)
        countrySelected:setAnchorPoint(ccp(0.5, 0.5))
        countrySelected:setPosition(ccpsprite(0.5, 0.5, selected))
        radioData.items[i] = CCMenuItemSprite:create(normal, nil, selected)
    end    
    local selectBar = LuaCCSprite.createRadioMenuWithItems(radioData)
    selectBg:addChild(selectBar)
    selectBar:setAnchorPoint(ccp(0.5, 0.5))
    selectBar:setPosition(ccp(selectBg:getContentSize().width * 0.5, 130))
    if _cannotSelectCountry == true then
        selectBar:setTouchEnabled(false)
        _selectedCountryIndex = 5
    end
    if _transferType == FIXED then
        selectBar:setTouchEnabled(false)
    end
    _selectBar = selectBar
    _menu = CCMenu:create()
    selectBg:addChild(_menu)
    _menu:setPosition(ccp(0, 0))
    local btnImage_n = "images/common/btn/btn_purple2_n.png"
    local btnImage_h = "images/common/btn/btn_purple2_h.png"
    local btnTextColor = ccc3(0xfe, 0xdb, 0x1c)
    local btnY = 36
    
    _transferCost = ActiveCache.getTransferCost(_oldHeroData) or 0
    local transferBtnInfo = {
        normal      = btnImage_n,                   -- 正常状态的图片
        selected    = btnImage_h,                   -- 按下状态的图片
        disabled    = nil,                          -- 不可点击时的图片
        size        = CCSizeMake(240, 73),          -- 按钮尺寸
        icon        = "images/common/gold.png",     -- 数字前的小图标
        text        = GetLocalizeStringBy("key_8320"),                        -- 按钮上的文字
        text_size   = 32,                           -- 文字的尺寸
        number      = tostring(_transferCost),       -- 数字 string类型的
        number_size = 21,                           -- 数字尺寸
    }
    _transferBtn = LuaCCSprite.createNumberMenuItem(transferBtnInfo)
    _menu:addChild(_transferBtn)
    _transferBtn:setAnchorPoint(ccp(0.5, 0.5))
    _transferBtn:setPosition(ccp(selectBg:getContentSize().width * 0.3, btnY))
    _transferBtn:registerScriptTapHandler(transferCallback)
    

    _backBtn = LuaCC.create9ScaleMenuItem(btnImage_n, btnImage_h, CCSizeMake(240, 73), GetLocalizeStringBy("key_10014"), btnTextColor, 32, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(_backBtn)
    _backBtn:setAnchorPoint(ccp(0.5, 0.5))
    _backBtn:setPosition(ccp(selectBg:getContentSize().width * 0.3, btnY))
    _backBtn:registerScriptTapHandler(backCallback)
    -- TODO
    _fixedTransferBtn = LuaCC.create9ScaleMenuItem(btnImage_n, btnImage_h, CCSizeMake(240, 73), GetLocalizeStringBy("key_10263"), btnTextColor, 32, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(_fixedTransferBtn)
    _fixedTransferBtn:setAnchorPoint(ccp(0.5, 0.5))
    _fixedTransferBtn:setPosition(ccp(selectBg:getContentSize().width * 0.7, btnY))
    _fixedTransferBtn:registerScriptTapHandler(fixedTransferCallback)

    
    _cancelBtn = LuaCC.create9ScaleMenuItem(btnImage_n, btnImage_h, CCSizeMake(170, 73), GetLocalizeStringBy("key_8321"), btnTextColor, 32, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(_cancelBtn)
    _cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
    _cancelBtn:setPosition(ccp(100, btnY))
    _cancelBtn:registerScriptTapHandler(cancelCallback)
    
     local retransferBtnInfo = {
        normal      = btnImage_n,                   -- 正常状态的图片
        selected    = btnImage_h,                   -- 按下状态的图片
        disabled    = nil,                          -- 不可点击时的图片
        size        = CCSizeMake(240, 73),          -- 按钮尺寸
        icon        = "images/common/gold.png",     -- 数字前的小图标
        text        = GetLocalizeStringBy("key_8322"),                    -- 按钮上的文字
        text_size   = 32,                           -- 文字的尺寸
        number      = tostring(_transferCost),       -- 数字 string类型的
        number_size = 21,                           -- 数字尺寸
    }
    _retransferBtn = LuaCCSprite.createNumberMenuItem(retransferBtnInfo)
    _menu:addChild(_retransferBtn)
    _retransferBtn:setAnchorPoint(ccp(0.5, 0.5))
    _retransferBtn:setPosition(ccp(selectBg:getContentSize().width * 0.5, btnY))
    _retransferBtn:registerScriptTapHandler(retransferCallback)
    
    _replaceBtn = LuaCC.create9ScaleMenuItem(btnImage_n, btnImage_h, CCSizeMake(170, 73), GetLocalizeStringBy("key_8323"), btnTextColor, 32, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    _menu:addChild(_replaceBtn)
    _replaceBtn:setAnchorPoint(ccp(0.5, 0.5))
    _replaceBtn:setPosition(ccp(640 - 100, btnY))
    _replaceBtn:registerScriptTapHandler(replaceCallback)
    refreshBtn()
end

function fixedTransferCallback( ... )
    if _oldHeroData == nil then
        SingleTip.showTip(GetLocalizeStringBy("key_8324"))
        return
    end
    require "script/ui/rechargeActive/transfer/FixedSelectLayer"
    local oldHeroDb = DB_Heroes.getDataById(_oldHeroData.htid)
    FixedSelectLayer.show(_oldHeroData.htid, _oldHeroData.hid, oldHeroDb.heroQuality, selectedCallback, _touchPriority - 300, 2000)
end

function selectedCallback( htid, countryIndex )
    if htid ~= nil then
        if _radioData.last_item ~= nil then
            _radioData.last_item:setEnabled(true)
        end
        local menuItem = _radioData.items[countryIndex]
        menuItem:setEnabled(false)
        selectedCountryCallback(countryIndex, menuItem)
        _selectBar:setTouchEnabled(false)
        _radioData.last_item = menuItem
    end
    local heroData = HeroUtil.getHeroInfoByHid(_oldHeroData.hid)
    heroData.transfer = htid
    _newHeroData = table.hcopy(heroData, {})
    _newHeroData.htid = htid
    _transferType = FIXED
    refreshNewHero()
    refreshBtn()
end


function transferCallback()
    _transferType = NORMAL
    if _oldHeroData == nil then
        SingleTip.showTip(GetLocalizeStringBy("key_8324"))
        return
    end
    -- 是否在阵容里
    require "script/ui/hero/HeroPublicLua"
    if HeroPublicLua.isBusyWithHid(_oldHeroData.hid) then
        SingleTip.showTip(GetLocalizeStringBy("key_8325"))
        return
    end
    -- 是否是小伙伴
    require "script/ui/formation/LittleFriendData"
    if LittleFriendData.isInLittleFriend(_oldHeroData.hid) then
        SingleTip.showTip(GetLocalizeStringBy("key_8326"))
        return
    end
    -- 是否是助战军
    require "script/ui/formation/secondfriend/SecondFriendData"
    if SecondFriendData.isInSecondFriendByHid(_oldHeroData.hid) then
        SingleTip.showTip(GetLocalizeStringBy("key_8555"))
        return
    end
    _transferCost = ActiveCache.getTransferCost(_oldHeroData) or 0
    local goldCount = UserModel.getGoldNumber()
    if goldCount < _transferCost then
        SingleTip.showTip(GetLocalizeStringBy("key_8327"))
        return
    end
    if _cannotSelectCountry then
        _selectedCountryIndex = 5
    end
    ActiveCache.heroTransfer(handleTransfer, _oldHeroData.hid, _selectedCountryIndex)
end

function handleTransfer(htid)
    UserModel.addGoldNumber(-_transferCost)
    local heroData = HeroUtil.getHeroInfoByHid(_oldHeroData.hid)
    heroData.transfer = htid
    _newHeroData = table.hcopy(heroData, {})
    _newHeroData.htid = htid
    refreshNewHero()
    refreshBtn()
end

function backCallback( ... )
    ActiveCache.heroTransferCancel(handleCancel, _oldHeroData.hid)
end


function cancelCallback()
    require "script/ui/tip/AlertTip"
    AlertTip.showAlert(GetLocalizeStringBy("key_8339"), cancel, true, nil)
end

function cancel(is_confirmed, arg)
    if is_confirmed == true then
        ActiveCache.heroTransferCancel(handleCancel, _oldHeroData.hid)
    end
end

function handleCancel()
    if _cannotSelectCountry then
        if _radioData.last_item ~= nil then
            _radioData.last_item:setEnabled(true)
            if _selectedTagSprite ~= nil then
                _selectedTagSprite:removeFromParentAndCleanup(true)
                _selectedTagSprite = nil
            end
        end
    else
        _selectBar:setTouchEnabled(true)
    end
    local heroData = HeroUtil.getHeroInfoByHid(_oldHeroData.hid)
    _transferCost = ActiveCache.getTransferCost(_oldHeroData)
    heroData.transfer = "0"
    heroData.dxtrans = "0"
    _newHeroData = nil
    refreshNewHero()
    refreshBtn()
end

function retransferCallback()
    transferCallback()
end

function replaceCallback()
    -- 是否在阵容里
    require "script/ui/hero/HeroPublicLua"
    if HeroPublicLua.isBusyWithHid(_oldHeroData.hid) then
        SingleTip.showTip(GetLocalizeStringBy("key_8328"))
        return
    end
    -- 是否是小伙伴
    require "script/ui/formation/LittleFriendData"
    if LittleFriendData.isInLittleFriend(_oldHeroData.hid) then
        SingleTip.showTip(GetLocalizeStringBy("key_8329"))
        return
    end
    -- 是否在神兵阵容的副本里
    require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
    if GodWeaponCopyData.isOnCopyFormationBy(_oldHeroData.hid) then
        SingleTip.showTip(GetLocalizeStringBy("key_8472"))
        return
    end
    -- 是否是助战军
    require "script/ui/formation/secondfriend/SecondFriendData"
    if SecondFriendData.isInSecondFriendByHid(_oldHeroData.hid) then
        SingleTip.showTip(GetLocalizeStringBy("key_8556"))
        return
    end

    require "script/ui/tip/AlertTip"
    AlertTip.showAlert(GetLocalizeStringBy("key_8330"), replace, true, nil)
end
 
function replace(is_confirmed, arg)
    if is_confirmed == true then
        ActiveCache.heroTransferConfirm(handleReplace, _oldHeroData.hid)
    end
end

function handleReplace(hid)
    if _transferType == FIXED then
        UserModel.addGoldNumber(-_transferCost)
    end
    HeroModel.deleteHeroByHid(_oldHeroData.hid)
    _oldHeroData = _newHeroData
    _oldHeroData.hid = hid
    _newHeroData = nil
    _menu:setTouchEnabled(false)
    local placeEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/bianshen/bianshen"), -1, CCString:create(""))
    placeEffectSprite:setPosition(ccp(_layerSize.width * 0.5, 0.72 * _layerSize.height))
    placeEffectSprite:setAnchorPoint(ccp(0.5,0))
    placeEffectSprite:setScale((_layerSize.width * 0.5 - 150 * MainScene.elementScale) / 170)
    --placeEffectSprite:setScale(MainScene.elementScale)
    _layer:addChild(placeEffectSprite,9999)
    local animationDelegate = BTAnimationEventDelegate:create()
	placeEffectSprite:setDelegate(animationDelegate)

	local animationEndCb = function()
        refreshNewHero()
        refreshOldHero()
        _menu:setTouchEnabled(true)
		placeEffectSprite:removeFromParentAndCleanup(true)
	end

	local animationChangedCb = function()

	end
	animationDelegate:registerLayerEndedHandler(animationEndCb)
	animationDelegate:registerLayerChangedHandler(animationChangedCb)
    refreshBtn()
end

function refreshBtn()
    if _newHeroData == nil then
        _cancelBtn:setVisible(false)
        _replaceBtn:setVisible(false)
        _backBtn:setVisible(false)
        _retransferBtn:setVisible(false)
        _fixedTransferBtn:setVisible(true)
        if _fixedReplaceBtn ~= nil then
            _fixedReplaceBtn:setVisible(false)
        end
        if _oldHeroData ~= nil and _oldHeroData.localInfo.heroQuality == 15 then
            _transferBtn:setVisible(false)
            _fixedTransferBtn:setPosition(ccp(_selectBg:getContentSize().width * 0.5, _fixedTransferBtn:getPositionY()))
        else
            _transferBtn:setVisible(true)
            _fixedTransferBtn:setPosition(ccp(_selectBg:getContentSize().width * 0.7, _fixedTransferBtn:getPositionY()))
        end
    else
        if _transferType == FIXED then
            _backBtn:setVisible(true)
            if _fixedReplaceBtn ~= nil then
                _fixedReplaceBtn:removeFromParentAndCleanup(true)
            end
            _transferCost = TransferData.getFixedTransferCost(_oldHeroData)
            local fixedReplaceBtnInfo = {
                normal      = "images/common/btn/btn_purple2_n.png",                   -- 正常状态的图片
                selected    = "images/common/btn/btn_purple2_h.png",                   -- 按下状态的图片
                disabled    = nil,                          -- 不可点击时的图片
                size        = CCSizeMake(240, 73),          -- 按钮尺寸
                icon        = "images/common/gold.png",     -- 数字前的小图标
                text        = GetLocalizeStringBy("key_8323"),                        -- 按钮上的文字
                text_size   = 32,                           -- 文字的尺寸
                number      = _transferCost,                -- 数字 string类型的
                number_size = 21,                           -- 数字尺寸
            }
            _fixedReplaceBtn = LuaCCSprite.createNumberMenuItem(fixedReplaceBtnInfo)
            _menu:addChild(_fixedReplaceBtn)
            _fixedReplaceBtn:setAnchorPoint(ccp(0.5, 0.5))
            _fixedReplaceBtn:setPosition(ccp(640 * 0.7, 36))
            _fixedReplaceBtn:registerScriptTapHandler(fixedReplaceCallback)
            _cancelBtn:setVisible(false)
            _fixedTransferBtn:setVisible(false)
            _retransferBtn:setVisible(false)
            _replaceBtn:setVisible(false)
            _transferBtn:setVisible(false)
        elseif _transferType == NORMAL then
            _backBtn:setVisible(false)
            _cancelBtn:setVisible(true)
            _retransferBtn:setVisible(true)
            _replaceBtn:setVisible(true)
            _transferBtn:setVisible(false)
            _fixedTransferBtn:setVisible(false)
        end
    end
end

function fixedReplaceCallback( ... )
    local goldCount = UserModel.getGoldNumber()
    if goldCount < _transferCost then
        SingleTip.showTip(GetLocalizeStringBy("key_8327"))
        return
    end
    replaceCallback()
    _selectBar:setTouchEnabled(true)
end

function selectedCountryCallback(tag, menuItem)
    _selectedCountryIndex = tag
    if _selectedTagSprite == nil then
        _selectedTagSprite = CCSprite:create("images/common/checked.png")
        _selectedTagSprite:setAnchorPoint(ccp(0.5, 0))
        _selectedTagSprite:setPosition(ccp(menuItem:getContentSize().width * 0.5, 10))
    else
        _selectedTagSprite:retain()
        _selectedTagSprite:removeFromParentAndCleanup(true)
        _selectedTagSprite:autorelease()
    end
    menuItem:addChild(_selectedTagSprite)
end

function lookHeroCallback()
    if _newHeroData == nil then
        return
    end
    require "script/ui/hero/HeroInfoLayer"
    local heroDb = DB_Heroes.getDataById(tonumber(_newHeroData.htid))
    _newHeroData.name = heroDb.name
    _newHeroData.star_lv = heroDb.star_lv
    HeroInfoLayer.createLayer(_newHeroData, {isPanel=true})
end


function selectedHeroCallback(tag, menuItem)
    if _newHeroData ~= nil then
        SingleTip.showTip(GetLocalizeStringBy("key_8331"))
        return
    end
    require "script/ui/hero/HeroSelectLayer"
	require "script/ui/main/MainScene"

	local tArgsOfModule = {withoutExp=true, isSingle=true}
	tArgsOfModule.sign="TransferLayer"
	tArgsOfModule.fnCreate = function(selected_data)
        local hero_data = nil
        if #selected_data.selectedHeroes >= 1 then
            hero_data = selected_data.selectedHeroes[1]
        else
            hero_data = selected_data.selectedHeroes
            if table.isEmpty(hero_data) then
                hero_data = nil
            end
        end
        _selectedHeroData = hero_data
        if _selectedHeroData ~= nil then
            _selectedHeroData.localInfo = DB_Heroes.getDataById(_selectedHeroData.htid)
        end
        -- local layer = RechargeActiveMain.create(RechargeActiveMain._tagTransfer)
        -- MainScene.changeLayer(layer, "layer")
        require "script/ui/transform/TransformMainLayer"
        TransformMainLayer.showLayer(TransformMainLayer.ksHeroType)
    end
    
    tArgsOfModule.selected = {}
    if _oldHeroData ~= nil then
        if ActiveCache.couldTransfers(_oldHeroData) == true then
            table.insert(tArgsOfModule.selected, tostring(_oldHeroData.hid))
        end
    end
    tArgsOfModule.filters = ActiveCache.getTransferHeroesFileter()
    tArgsOfModule.touchPriority = -500
	MainScene.changeLayer(HeroSelectLayer.createLayer(tArgsOfModule), "HeroSelectLayer")
end

function createHero(heroData, heroType)
    local seat = CCSprite:create("images/olympic/kingChair.png")
    -------------------------------------------------------------------------特效
    local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hongguang/hongguang" ), -1,CCString:create(""))
    spellEffectSprite:setPosition(ccp(seat:getContentSize().width * 0.5, 90))
    spellEffectSprite:setAnchorPoint(ccp(0.5, 0))
    seat:addChild(spellEffectSprite)
    -------------------------------------------------------------------------特效结束
            
    local menu = CCMenu:create()
    seat:addChild(menu)
    menu:setPosition(ccp(0, 0))
    local normal = CCLayerColor:create(ccc4(0xff, 0, 0, 0))
    local addBtnSize = CCSizeMake(200, 200)
    normal:setContentSize(addBtnSize)
    local selectBtn = CCMenuItemSprite:create(normal, normal, normal)
    menu:addChild(selectBtn)
    selectBtn:setAnchorPoint(ccp(0.5, 0.5))
    selectBtn:setPosition(ccp(seat:getContentSize().width * 0.5, 100))
    if heroType == "+" then
        selectBtn:registerScriptTapHandler(selectedHeroCallback)
    elseif heroType == "?" then
        selectBtn:registerScriptTapHandler(lookHeroCallback)
    end
    
    if heroData == nil then
        if heroType == "+" then
            local addSprite = CCSprite:create("images/common/add_new.png")
            seat:addChild(addSprite)
            addSprite:setAnchorPoint(ccp(0.5, 0.5))
            addSprite:setPosition(ccp(seat:getContentSize().width * 0.5, 170))
            local blinkArray = CCArray:create()
            blinkArray:addObject(CCFadeOut:create(0.8))
            blinkArray:addObject(CCFadeIn:create(0.8))
            blinkArray:addObject(CCDelayTime:create(0.2))
            addSprite:runAction(CCRepeatForever:create(CCSequence:create(blinkArray)))
        
            local addTip = CCRenderLabel:create(GetLocalizeStringBy("key_8332"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
            seat:addChild(addTip)
            addTip:setAnchorPoint(ccp(0.5, 0.5))
            addTip:setPosition(ccp(seat:getContentSize().width * 0.5, 130))
            addTip:setColor(ccc3(0x00, 0xff, 0x18))
        elseif heroType == "?" then
            local unknow = CCSprite:create("images/common/question_mask.png")
            seat:addChild(unknow)
            unknow:setAnchorPoint(ccp(0.5, 0.5))
            unknow:setPosition(ccp(seat:getContentSize().width * 0.5, 155))
        end
    else
        -- 武将
        local hero = HeroUtil.getHeroBodySpriteByHTID(heroData.htid)
        seat:addChild(hero)
        local bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(heroData.htid)
		hero:setPosition(ccp(seat:getContentSize().width *0.5, 70 - bodyOffset))
		hero:setAnchorPoint(ccp(0.5, 0))
        hero:setScale(0.5)

        -- 资质
        local heroQualityBg = CCSprite:create("images/recharge/transfer/di.png")
        seat:addChild(heroQualityBg)
        heroQualityBg:setAnchorPoint(ccp(0.5, 0.5))
        heroQualityBg:setPosition(ccp(seat:getContentSize().width * 0.5, 15))
        local heroQualityTitle = CCSprite:create("images/hero/potential.png")
        heroQualityBg:addChild(heroQualityTitle)
        heroQualityTitle:setAnchorPoint(ccp(0, 0.5))
        heroQualityTitle:setPosition(ccp(0, heroQualityBg:getContentSize().height * 0.5))
        heroQualityTitle:setScale(0.8)
        local heroDb = DB_Heroes.getDataById(tonumber(heroData.htid))
        local heroQualityLabel = CCRenderLabel:create(tostring(heroDb.heroQuality), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
        heroQualityBg:addChild(heroQualityLabel)
        heroQualityLabel:setAnchorPoint(ccp(0, 0.5))
        heroQualityLabel:setPosition(ccp(65, heroQualityBg:getContentSize().height * 0.5))
        local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
        seat:addChild(nameBg)
        nameBg:setAnchorPoint(ccp(0.5, 0.5))
        nameBg:setPosition(ccp(seat:getContentSize().width * 0.5, -20))
        nameBg:setContentSize(CCSizeMake(228, 32))
        -- 国家
        local x = 10
        local countryImage = HeroModel.getCiconByCidAndlevel(heroDb.country, heroDb.star_lv)
        local countryIcon = CCSprite:create(countryImage)
        nameBg:addChild(countryIcon)
        countryIcon:setAnchorPoint(ccp(0.5, 1))
        countryIcon:setPosition(x, nameBg:getContentSize().height)
        x = x + countryIcon:getContentSize().width * 0.5
        -- 等级
        local lvSprite = CCSprite:create("images/common/lv.png")
        nameBg:addChild(lvSprite)
        lvSprite:setAnchorPoint(ccp(0, 0.5))
        lvSprite:setPosition(ccp(x, nameBg:getContentSize().height * 0.5))
        x = x + lvSprite:getContentSize().width
        local lvLabel = CCRenderLabel:create(heroData.level, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
        nameBg:addChild(lvLabel)
        lvLabel:setAnchorPoint(ccp(0, 0.5))
        lvLabel:setPosition(ccp(x, nameBg:getContentSize().height * 0.5))
        lvLabel:setColor(ccc3(0xff, 0xf6, 0x00))
        x = x + 40
        -- 名字
        local nameLabel = CCRenderLabel:create(heroDb.name, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
        nameBg:addChild(nameLabel)
        nameLabel:setAnchorPoint(ccp(0, 0.5))
        nameLabel:setPosition(ccp(x, nameBg:getContentSize().height * 0.5))
        local nameColor = HeroPublicLua.getCCColorByStarLevel(heroDb.star_lv)
        nameLabel:setColor(nameColor)
        x = x + nameLabel:getContentSize().width + 3
        -- 进阶等级
        local evolveLevelLabel = CCRenderLabel:create("+" .. heroData.evolve_level, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
        nameBg:addChild(evolveLevelLabel)
        evolveLevelLabel:setAnchorPoint(ccp(0, 0.5))
        evolveLevelLabel:setPosition(ccp(x, nameBg:getContentSize().height * 0.5))
        evolveLevelLabel:setColor(ccc3(0x00, 0xff, 0x18))
        -- 星级
        local starBg = CCSprite:create("images/recharge/transfer/star_bg.png")
        seat:addChild(starBg)
        starBg:setAnchorPoint(ccp(0.5, 0.5))
        starBg:setPosition(ccp(seat:getContentSize().width * 0.5, 280))
        local starNode = CCNode:create()
        starBg:addChild(starNode)
        starNode:setAnchorPoint(ccp(0.5, 0.5))
        starNode:setPosition(ccpsprite(0.5, 0.5, starBg))
        for i = 1, heroDb.star_lv do
            local star = CCSprite:create("images/digCowry/star.png")
            starNode:addChild(star)
            star:setAnchorPoint(ccp(0, 0.5))
            star:setPosition(ccp((i - 1) * 26, 40))
        end
        starNode:setContentSize(CCSizeMake(heroDb.star_lv * 26, starBg:getContentSize().height))
    end
    return seat
end