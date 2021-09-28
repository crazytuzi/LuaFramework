-- Filename：	PreviewLayer.lua
-- Author：		bzx
-- Date：		2014-09-18
-- Purpose：		武将变身预览

module ("PreviewLayer", package.seeall)

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

function show(touch_priority, zOrder)
    local layer = create(touch_priority, zOrder)
    local runing_scene = CCDirector:sharedDirector():getRunningScene()
    runing_scene:addChild(layer, _zOrder)
end

function init(touch_priority, zOrder)
    _touch_priority = touch_priority or -500
    _zOrder = zOrder or 2000
    _radio_menu_space = 37
    _arrows = nil
    _selected_icon = nil
    _scroll_view = nil
end

function create(touch_priority, zOrder)
    init(touch_priority, zOrder)
    _layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 100))
    _layer:registerScriptHandler(onNodeEvent)
    local dialog_info = {}
    dialog_info.title = GetLocalizeStringBy("key_8317")
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
    
    local tip = CCLabelTTF:create(GetLocalizeStringBy("key_8333"), g_sFontPangWa, 21)
    _dialog:addChild(tip)
    tip:setAnchorPoint(ccp(0.5, 0.5))
    tip:setPosition(dialog_info.size.width * 0.5, 50)
    tip:setColor(ccc3(0x78, 0x25, 0x00))
    loadScrollViewView()
    loadSwallowLayer()
    return _layer
end

function callbackClose()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _layer ~= nil then
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
    end
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
	_scroll_view_bg:setPreferredSize(CCSizeMake(565, 591))
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
	_scroll_view:setContentSize(CCSizeMake(547, 581))
	_scroll_view:setViewSize(CCSizeMake(547, 581))
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
    if countryHtids[4] ~= nil then
        for i = 1, #countryHtids[4] do
            table.insert(countryHtids[3], countryHtids[4][i])
        end
        countryHtids[4] = nil
    end
    if countryHtids  == nil then
        return
    end
    local height = 0
    local aptitudeText = {GetLocalizeStringBy("key_8334"), GetLocalizeStringBy("key_8335"), GetLocalizeStringBy("key_10278")}
    for i = #countryHtids, 1, -1 do
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
            local heroHead = ItemSprite.getHeroIconItemByhtid(countryHtidsTemp[j],  _touch_priority - 1, _zOrder + 10) 
            bg2:addChild(heroHead)
            heroHead:setAnchorPoint(ccp(0, 1))
            heroHead:setPosition(ccp(14 + math.mod(j - 1, 4) * 120, bg2:getContentSize().height - math.floor((j - 1) / 4) * 130 - 9))
            local nameColor = HeroPublicLua.getCCColorByStarLevel(heroDb.star_lv)
            local nameLabel = CCRenderLabel:create(heroDb.name, g_sFontName, 23, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
            nameLabel:setColor(nameColor)
            nameLabel:setAnchorPoint(ccp(0.5, 1))
            nameLabel:setPosition(ccp(heroHead:getContentSize().width * 0.5, -2))
            heroHead:addChild(nameLabel)
        end
        
        height = height + bg1:getContentSize().height + 15
    end
    _scroll_view:setContentSize(CCSizeMake(_scroll_view:getContentSize().width, height))
    layer:setPositionY(_scroll_view:getViewSize().height - height)
end

-- 选项卡的回调
function callbackCountry(index, item)
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