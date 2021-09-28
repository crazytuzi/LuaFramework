-- FileName: ShowStarExchangeTip.lua 
-- Author: licong 
-- Date: 14-7-14 
-- Purpose: 名将好感交换成功提示


module("ShowStarExchangeTip", package.seeall)

require "script/utils/BaseUI"

local _bgLayer                  = nil
local _backGround 				= nil
local _second_bg  				= nil
local _srcStarData 				= nil
local _disStarData				= nil

function init( ... )
	_bgLayer                    = nil
	_backGround 				= nil
	_second_bg  				= nil
	_srcStarData 				= nil
	_disStarData 				= nil
end

--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
local function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end


--[[
	@des 	:创建名将头像
	@param 	: p_starData 名将数据
	@return : sprite
--]]
function createHeroIcon( p_starData )
	-- 默认选择的icon
	local iconBgSprite  = CCSprite:create("images/everyday/headBg1.png")
	
	-- 头像icon
	local tempHtid = HeroUtil.getOnceOrangeHtid(p_starData.star_tid)
	local iconSprite = HeroUtil.getHeroIconByHTID(tempHtid)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(iconBgSprite:getContentSize().width*0.5, iconBgSprite:getContentSize().height*0.5))
	iconBgSprite:addChild(iconSprite)
	-- 名将名字
	local heroData = HeroUtil.getHeroLocalInfoByHtid(tempHtid)
    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	local heroName = CCRenderLabel:create(heroData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	heroName:setColor(nameColor)
	heroName:setAnchorPoint(ccp(0.5,1))
	heroName:setPosition(ccp(iconBgSprite:getContentSize().width*0.5 ,-2))
	iconBgSprite:addChild(heroName)
	-- 好感等级
	local loveLevel = CCRenderLabel:create(p_starData.level, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    loveLevel:setAnchorPoint(ccp(0,0.5))
    loveLevel:setColor(ccc3(0xff, 0xff, 0xff))
    iconBgSprite:addChild(loveLevel)
    -- 心
    local heartSp = CCSprite:create("images/star/intimate/heart_s.png")
    heartSp:setAnchorPoint(ccp(0, 0.5))
    iconBgSprite:addChild(heartSp)
    -- 坐标居中
    local posX = (iconBgSprite:getContentSize().width-loveLevel:getContentSize().width-heartSp:getContentSize().width-5)/2
    loveLevel:setPosition(ccp(posX, -heroName:getContentSize().height-20))
    heartSp:setPosition(ccp(loveLevel:getPositionX()+loveLevel:getContentSize().width+5, loveLevel:getPositionY()))

    return iconBgSprite
end


--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,-420,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(540, 360))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-420)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 二级背景
	_second_bg = BaseUI.createContentBg(CCSizeMake(475,215))
 	_second_bg:setAnchorPoint(ccp(0.5,1))
 	_second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-45))
 	_backGround:addChild(_second_bg)

 	-- 创建默认的名将icon
 	local srcHeroIcon = createHeroIcon(_srcStarData)
 	srcHeroIcon:setAnchorPoint(ccp(0, 1))
	srcHeroIcon:setPosition(ccp(26, _second_bg:getContentSize().height-26))
	_second_bg:addChild(srcHeroIcon)
 	
 	-- 创建选择的名将icon
 	local disHeroIcon = createHeroIcon(_disStarData)
 	disHeroIcon:setAnchorPoint(ccp(1, 1))
	disHeroIcon:setPosition(ccp(_second_bg:getContentSize().width-26, _second_bg:getContentSize().height-26))
	_second_bg:addChild(disHeroIcon)

	-- 交换成功
	local fontSp = CCSprite:create("images/star/font.png")
    fontSp:setAnchorPoint(ccp(0.5,1))
    fontSp:setPosition(ccp(_second_bg:getContentSize().width*0.5,_second_bg:getContentSize().height-32))
    _second_bg:addChild(fontSp)

	-- 互相箭头
    local arrowSp = CCSprite:create("images/star/arrow.png")
    arrowSp:setAnchorPoint(ccp(0.5,1))
    arrowSp:setPosition(ccp(_second_bg:getContentSize().width*0.5,fontSp:getPositionY()-fontSp:getContentSize().height-5))
    _second_bg:addChild(arrowSp)

    -- 确定按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    normalSprite:setContentSize(CCSizeMake(160,73))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSprite:setContentSize(CCSizeMake(160,73))
    local yesMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    yesMenuItem:setAnchorPoint(ccp(0.5,0))
    yesMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.5, 25))
    yesMenuItem:registerScriptTapHandler(closeButtonCallback)
    menu:addChild(yesMenuItem)
    local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1097"), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont1:setAnchorPoint(ccp(0.5,0.5))
    itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
    itemfont1:setPosition(ccp(yesMenuItem:getContentSize().width*0.5,yesMenuItem:getContentSize().height*0.5))
    yesMenuItem:addChild(itemfont1)
end


--[[
	@des 	:名将好感交换成功后提示框
	@param 	:p_srcStarId 默认名将id
	@param 	:p_disStarId 选择的名将id
	@return :
--]]
function showTip( p_srcStarId, p_disStarId )
	-- 初始化
	init()
	-- 数据
	_srcStarData = StarUtil.getStarInfoBySid(p_srcStarId)
	_disStarData = StarUtil.getStarInfoBySid(p_disStarId)
	-- print("_srcStarData")
	-- print_t(_srcStarData)
	-- print("_disStarData")
	-- print_t(_disStarData)
	-- 创建提示layer
	createTipLayer()
end






































