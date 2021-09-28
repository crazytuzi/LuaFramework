-- Filename: TitleDisappearDialog.lua
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号失效提示界面

module("TitleDisappearDialog", package.seeall)

require "script/ui/title/TitleData"
require "script/utils/BaseUI"

local _touchPriority 	= nil	-- 触摸优先级
local _zOrder 		 	= nil	-- 显示层级
local _bgLayer 		 	= nil	-- 背景层

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
end

--[[
	@desc 	: 显示界面方法
	@param 	: pTitleId 称号ID
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showDialog( pTitleId, pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -800
	_zOrder = pZorder or 800

	if (pTitleId == nil or tonumber(pTitleId) <= 0) then
		return
	end

    local layer = createDialog(pTitleId,_touchPriority, _zOrder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc 	: 背景层触摸回调
	@param 	: eventType 事件类型 x,y 触摸点
	@return : 
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc 	: 回调onEnter和onExit事件
	@param 	: event 事件名
	@return : 
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc 	: 创建Dialog及UI
	@param 	: pTitleId 称号ID
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createDialog( pTitleId, pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -800
	_zOrder = pZorder or 800

	-- 背景层
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景框
	local bgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(520,305))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setScale(g_fElementScaleRatio)
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	_bgLayer:addChild(bgSprite)

	-- 返回按钮Menu
	local backMenu = CCMenu:create()
    backMenu:setPosition(ccp(0, 0))
    backMenu:setAnchorPoint(ccp(0,0))
    backMenu:setTouchPriority(_touchPriority-30)
    bgSprite:addChild(backMenu, 10)

    -- 返回按钮
    local backItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
    backItem:setAnchorPoint(ccp(0.5,0.5))
    backItem:setPosition(ccp(bgSprite:getContentSize().width*0.955, bgSprite:getContentSize().height*0.975))
    backItem:registerScriptTapHandler(backItemCallback)
    backMenu:addChild(backItem,1)

    -- 确定按钮
    require "script/libs/LuaCC"
	local okItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(120, 64), GetLocalizeStringBy("key_10114"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	okItem:setAnchorPoint(ccp(0.5, 0.5))
	okItem:registerScriptTapHandler(backItemCallback)
	okItem:setPosition(ccp(bgSprite:getContentSize().width*0.5, 50))
	backMenu:addChild(okItem,1)

	local titleInfo = TitleData.getTitleInfoById(pTitleId)

	-- 称号名称
	local signNameLabel = CCLabelTTF:create(titleInfo.signname,g_sFontPangWa,36)
 	signNameLabel:setColor(ccc3(0x78,0x25,0x00))
 	signNameLabel:setAnchorPoint(ccp(0.5, 0.5))
 	signNameLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-50))
 	bgSprite:addChild(signNameLabel)

    -- 文字背景
	local infoViewBg = BaseUI.createContentBg(CCSizeMake(455,140))
 	infoViewBg:setAnchorPoint(ccp(0.5,1))
 	infoViewBg:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height-85))
 	bgSprite:addChild(infoViewBg)

 	-- 途径
 	local signDesLabel = CCLabelTTF:create(titleInfo.signdes,g_sFontPangWa,18)
 	signDesLabel:setColor(ccc3(0xff,0xff,0xff))
 	signDesLabel:setAnchorPoint(ccp(0, 0.5))
 	signDesLabel:setPosition(ccp(15,infoViewBg:getContentSize().height-30))
 	infoViewBg:addChild(signDesLabel)

 	-- 装备属性
 	local attrLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1035"),g_sFontPangWa,18)
    attrLabel:setColor(ccc3(0xff,0xff,0xff))
    attrLabel:setAnchorPoint(ccp(0,0.5))
    attrLabel:setPosition(ccp(15,infoViewBg:getContentSize().height-60))
    infoViewBg:addChild(attrLabel)

    -- 属性数值
    require "script/ui/item/ItemUtil"
    local attrInfo = TitleData.getTitleEquipAttrInfoById(pTitleId)
    local i = 0
    for k,v in pairs(attrInfo) do
    	local row = math.floor(i/2)+1
			local col = i%2+1
    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v)
    	local attrStr = affixDesc.sigleName .. "+" .. displayNum
    	local attrStrLabel = CCLabelTTF:create(attrStr,g_sFontPangWa,18)
		attrStrLabel:setColor(ccc3(0xff,0xff,0xff))
		attrStrLabel:setAnchorPoint(ccp(0,0.5))
		attrStrLabel:setPosition(ccp(115+110*(col-1), infoViewBg:getContentSize().height-(60+30*(row-1))))
		infoViewBg:addChild(attrStrLabel,2)
    	i = i+1
    end

 	-- 此称号已失效
 	local noteLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1043"),g_sFontPangWa,36)
    noteLabel:setColor(ccc3(0xff,0x00,0x00))
    noteLabel:setAnchorPoint(ccp(0.5,0.5))
    noteLabel:setPosition(ccp(infoViewBg:getContentSize().width*0.5,25))
    infoViewBg:addChild(noteLabel)

    return _bgLayer
end

--[[
	@desc 	: 返回/确认 按钮回调,关闭界面
	@param 	: 
	@return : 
--]]
function backItemCallback()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    -- 移除本地失效称号ID
	TitleData.setLastDisappearTitleId(0)

    -- 刷新主界面中间按钮
    require "script/ui/main/MainMenuLayer"
	MainMenuLayer.updateMiddleButton()
	
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end
