-- Filename：	FixedSelectLayer.lua
-- Author：		bzx
-- Date：		2015-05-28
-- Purpose：		定向变身选择界面

module ("FixedSelectLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "script/ui/item/ItemSprite"
require "script/ui/hero/HeroPublicLua"

local _layer 
local _touch_priority
local _zOrder
local _dialog
local _radio_menu_space
local _radio_menu
local _scroll_view
local _scroll_view_bg
local _aptitude
local _confirmCallback
local _selectedTagSprite
local _selectedHtid
local _selectedCountryIndex
local _cannotSelectCountry
local _hid
local _htid

function show(htid, hid, aptitude, confirmCallback, touch_priority, zOrder)
    local layer = create(htid, hid, aptitude, confirmCallback, touch_priority, zOrder)
    local runing_scene = CCDirector:sharedDirector():getRunningScene()
    runing_scene:addChild(layer, _zOrder)
end

function init(htid, hid, aptitude, confirmCallback, touch_priority, zOrder)
	_htid = tonumber(htid)
	_hid = hid
	_confirmCallback = confirmCallback
	_aptitude = aptitude
    _touch_priority = touch_priority or -500
    _zOrder = zOrder or 2000
    _radio_menu_space = 37
    _arrows = nil
    _selected_icon = nil
    _scroll_view = nil
    _selectedHtid = nil
    _selectedCountryIndex = 1
end

function create(htid, hid, aptitude, confirmCallback, touch_priority, zOrder)
    init(htid, hid, aptitude, confirmCallback, touch_priority, zOrder)
    _layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 100))
    _layer:registerScriptHandler(onNodeEvent)
    local dialog_info = {}
    dialog_info.title = GetLocalizeStringBy("key_10263")
    dialog_info.callbackClose = callbackClose
    dialog_info.size = CCSizeMake(613, 786)
    dialog_info.priority = _touch_priority - 10
    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _layer:addChild(_dialog)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(g_fScaleX)
    
    local radio_data = {
        touch_priority  = _touch_priority - 10,
        space         = _radio_menu_space,
        callback        = callbackCountry,
        items           ={
            {normal = "images/chat/wei_n.png", selected = "images/chat/wei_h.png"},
            {normal = "images/chat/shu_n.png", selected = "images/chat/shu_h.png"},
            {normal = "images/chat/wu_n.png", selected = "images/chat/wu_h.png"},
            {normal = "images/chat/qun_n.png", selected = "images/chat/qun_h.png"}
        }
    }
    _radio_menu = LuaCCSprite.createRadioMenu(radio_data)
    _dialog:addChild(_radio_menu)
    _radio_menu:setAnchorPoint(ccp(0.5, 0.5))
    _radio_menu:setPosition(ccp(_dialog:getContentSize().width * 0.5, _dialog:getContentSize().height - 80))

    loadButton()
    local tip = CCLabelTTF:create(GetLocalizeStringBy("key_10264"), g_sFontPangWa, 21)
    _dialog:addChild(tip)
    tip:setAnchorPoint(ccp(0.5, 0.5))
    tip:setPosition(dialog_info.size.width * 0.5, 120)
    tip:setColor(ccc3(0x78, 0x25, 0x00))
    loadScrollViewView()
    loadSwallowLayer()
    return _layer
end

function loadButton( ... )
	local menu = CCMenu:create()
	_dialog:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touch_priority - 10)
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png", "images/common/btn/btn1_n.png", CCSizeMake(170, 73), GetLocalizeStringBy("key_10114"), ccc3(0xfe, 0xdb, 0x1c), 32, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    menu:addChild(confirmBtn)
    confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
    confirmBtn:setPosition(ccp(_dialog:getContentSize().width * 0.5, 60))
    confirmBtn:registerScriptTapHandler(confirmCallback)
end

function callbackClose()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    close()
end

function close( ... )
    if _layer ~= nil then
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
    end
end

function confirmCallback( ... )
    if _selectedHtid == nil then
        close()
        return
    end
	local callback = function ( ... )
		close()
		if _confirmCallback ~= nil then
			_confirmCallback(_selectedHtid, _selectedCountryIndex)
		end
	end
	local countryIndex = _selectedCountryIndex
	if _cannotSelectCountry then
		countryIndex = 5
	end
	ActiveCache.heroTransfer(callback, _hid, countryIndex, _selectedHtid)
end

function onNodeEvent(event)
	if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
        if _selected_icon ~= nil then
            _selected_icon:autorelease()
        end
	end
end

function loadScrollViewView()
    local full_rect = CCRectMake(0,0,75, 75)
	local inset_rect = CCRectMake(30,30,15,15)
	_scroll_view_bg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", full_rect, inset_rect)
	_scroll_view_bg:setPreferredSize(CCSizeMake(565, 520))
    _dialog:addChild(_scroll_view_bg)
    _scroll_view_bg:setAnchorPoint(ccp(0.5, 1))
	_scroll_view_bg:setPosition(ccp(_dialog:getContentSize().width * 0.5, _radio_menu:getPositionY() - _radio_menu:getContentSize().height * 0.5 - 10))
    
    _arrows = CCSprite:create("images/chat/arrows.png")
    _scroll_view_bg:addChild(_arrows)
    _arrows:setAnchorPoint(ccp(0.5, 0))
    _arrows:setPosition(ccp(80, _scroll_view_bg:getContentSize().height - 1))
    
    _scroll_view = CCScrollView:create()
    _scroll_view_bg:addChild(_scroll_view)
    _scroll_view:setAnchorPoint(ccp(0.5, 0))
    _scroll_view:setPosition(ccp(_scroll_view_bg:getContentSize().width * 0.5, 0))
	_scroll_view:setContentSize(CCSizeMake(547, 510))
	_scroll_view:setViewSize(CCSizeMake(547, 510))
 	_scroll_view:setTouchPriority(_touch_priority - 10)
	_scroll_view:setDirection(kCCScrollViewDirectionVertical)
    _scroll_view:ignoreAnchorPointForPosition(false)
    refreshScrollView(1)
end

function loadSwallowLayer()
    local swallowLayer = CCLayer:create()
    _layer:addChild(swallowLayer)
    swallowLayer:registerScriptTouchHandler(onTouchesSwallowHandler, false, _touch_priority - 5, true)
    swallowLayer:setTouchEnabled(true)
end

function refreshScrollView(countryIndex)
    if _scroll_view == nil then
        return
    end
    local layer = _scroll_view:getContainer()
    layer:removeAllChildrenWithCleanup(true)
    
    local countryHtids = parseDB(DB_Normal_config.getDataById(1))[ string.format("changeCard%d", countryIndex)]
    if countryHtids  == nil then
        return
    end
    local height = 0
    local aptitudeText = {GetLocalizeStringBy("key_8334"), GetLocalizeStringBy("key_8335"), GetLocalizeStringBy("key_10278"), GetLocalizeStringBy("key_10278")}
    _cannotSelectCountry = true
    local i = nil
    if _aptitude == 12 then
    	i = 1
        _cannotSelectCountry = false
    elseif _aptitude == 13 then
    	i = 2
    elseif _aptitude == 15 then
        local heroDb = DB_Heroes.getDataById(_htid)
        local srcHeroDb = DB_Heroes.getDataById(heroDb.model_id)
        if srcHeroDb.heroQuality == 12 then
            i = 3
        elseif srcHeroDb.heroQuality == 13 then
            i = 4
        end
    end
    local countryHtidsTemp = countryHtids[i]
    local htidCount = #countryHtidsTemp
    local lineCount = math.ceil(htidCount / 4)
    
    local full_rect = CCRectMake(0,0,116, 124)
    local inset_rect = CCRectMake(50,60,10,10)
    local bg1 = CCScale9Sprite:create("images/common/bg/change_bg.png", full_rect, inset_rect)
    layer:addChild(bg1)
    bg1:setContentSize(CCSizeMake(539, 80 + 130 * lineCount))
    bg1:setAnchorPoint(ccp(0.5, 0))
    bg1:setPosition(ccp(layer:getContentSize().width * 0.5, height))
    
    local aptitudeBg = CCSprite:create("images/digCowry/star_bg.png")
    bg1:addChild(aptitudeBg)
    aptitudeBg:setAnchorPoint(ccp(0, 1))
    aptitudeBg:setPosition(ccp(0, bg1:getContentSize().height))
    
    local aptitudeLabel = CCLabelTTF:create(aptitudeText[i], g_sFontPangWa, 21)
    aptitudeBg:addChild(aptitudeLabel)
    aptitudeLabel:setAnchorPoint(ccp(0.5, 0.5))
    aptitudeLabel:setPosition(ccpsprite(0.5, 0.57, aptitudeBg))
    aptitudeLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    local bg2 = CCScale9Sprite:create("images/common/bg/goods_bg.png")
    bg1:addChild(bg2)
    bg2:setAnchorPoint(ccp(0.5, 0))
    bg2:setPosition(ccp(bg1:getContentSize().width * 0.5, 25))
    bg2:setContentSize(CCSizeMake(490, bg1:getContentSize().height - 70))
    for j = 1, htidCount do
        local heroDb = DB_Heroes.getDataById(countryHtidsTemp[j])
        local heroHead = createHead(countryHtidsTemp[j], countryHtidsTemp[j], selectCallback, _touch_priority - 1) 
        bg2:addChild(heroHead)
        heroHead:setAnchorPoint(ccp(0, 1))
        heroHead:setPosition(ccp(14 + math.mod(j - 1, 4) * 120, bg2:getContentSize().height - math.floor((j - 1) / 4) * 130 - 9))
    end
    height = height + bg1:getContentSize().height + 15
    _scroll_view:setContentSize(CCSizeMake(_scroll_view:getContentSize().width, height))
    layer:setPositionY(_scroll_view:getViewSize().height - height)
end

-- 选项卡的回调
function callbackCountry(index, item)
	_selectedCountryIndex = index
    require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    if _arrows ~= nil then
        _arrows:setPositionX(80 + (index - 1) * (96 + _radio_menu_space))
    end
    refreshScrollView(index)
end

function onTouchesSwallowHandler(eventType, x, y)
    if eventType == "began" then
        local point = _scroll_view_bg:convertToNodeSpace(ccp(x, y))
        local boundingBox = _scroll_view:boundingBox()
        if boundingBox:containsPoint(point) then
            return false
        else
            return true
        end
    end
end

function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
		return true
	end
end

function selectCallback( tag, menuItem )
	if tag == _htid then
		SingleTip.showTip(GetLocalizeStringBy("key_10265"))
		return
	end
	_selectedHtid = tag
	if not tolua.isnull(_selectedTagSprite) then
		_selectedTagSprite:removeFromParentAndCleanup(true)
	end
	_selectedTagSprite = CCSprite:create("images/common/checked.png")
    _selectedTagSprite:setAnchorPoint(ccp(0.5, 0.5))
    _selectedTagSprite:setPosition(ccpsprite(0.5, 0.5, menuItem))
	menuItem:addChild(_selectedTagSprite)
end


-- 创建头像
function createHead( htid, tag, callback, touch_priority)
	-- 查找名将的信息
	local heroDb = DB_Heroes.getDataById(htid)
	local bgSprite = CCSprite:create("images/base/potential/officer_" .. heroDb.star_lv .. ".png")
	local iconFile = "images/base/hero/head_icon/" .. heroDb.head_icon_id

	-- 按钮Bar
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
    if touch_priority ~= nil then
        menuBar:setTouchPriority(touch_priority)
    end
	bgSprite:addChild(menuBar)
	-- 按钮
	local item_btn = CCMenuItemImage:create(iconFile,iconFile)
	item_btn:registerScriptTapHandler(callback)
	item_btn:setAnchorPoint(ccp(0.5, 0.5))
	item_btn:setPosition(ccp(bgSprite:getContentSize().width * 0.5, bgSprite:getContentSize().height * 0.5))
	menuBar:addChild(item_btn, 1, tag)

    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroDb.star_lv)
	local nameLabel = CCRenderLabel:create(heroDb.name, g_sFontName, 23, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5, 1))
    nameLabel:setPosition(ccp(item_btn:getContentSize().width * 0.5, -10))
    item_btn:addChild(nameLabel)

	return bgSprite
end
