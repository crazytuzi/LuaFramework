-- FileName: RedCardDestinyAttrDialog.lua 
-- Author: llp
-- Date: 16-6-14 
-- Purpose: 属性详细信息

module("RedCardDestinyAttrDialog", package.seeall)


local _bgLayer                  	= nil
local _backGround 					= nil

local _showAttrTab 					= nil
local _showzOrder 					= nil
local _showLayerPriority 			= nil
local _titleString 					= nil

function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil

	_showAttrTab 					= nil
	_showzOrder 					= nil
	_showLayerPriority 				= nil
	_titleString 					= nil
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
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )
	
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,_showLayerPriority,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,19003,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(550, 350))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

    local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_467"),g_sFontName,22)
    	  tipLabel:setAnchorPoint(ccp(0.5,0))
    	  tipLabel:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height*0.15))
    	  tipLabel:setColor(ccc3(255,0,0))
    _backGround:addChild(tipLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_showLayerPriority-1)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(_titleString, g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

   	-- 遍历属性数组
   	local scrollView = CCScrollView:create()
	scrollView:setViewSize(CCSizeMake(_backGround:getContentSize().width - 14, _backGround:getContentSize().height -120))
	scrollView:setPosition(ccp(0, 70))
	_backGround:addChild(scrollView)
	scrollView:setDirection(kCCScrollViewDirectionVertical)
	scrollView:setContentSize(CCSizeMake(_backGround:getContentSize().width - 14, 45 * (#_showAttrTab/2 + 1) + 80))
	scrollView:setContentOffset(ccp(0, scrollView:getViewSize().height - scrollView:getContentSize().height))
	scrollView:setTouchPriority(-9110)

	
   	local posY = scrollView:getContentSize().height - 40
   	local posX = {80,300}
   	for i=1,#_showAttrTab do
   		-- 属性名字
   		local attrName = CCLabelTTF:create(_showAttrTab[i].name .. " :",g_sFontName,25)
   		attrName:setColor(ccc3(0x78, 0x25, 0x00))
   		attrName:setAnchorPoint(ccp(0,0.5))
   		scrollView:addChild(attrName)
   		if(i%2 == 1)then
   			if(i > 1)then
   				posY = posY - attrName:getContentSize().height - 20
   			end
   			attrName:setPosition(ccp(posX[1],posY))
   		else
   			attrName:setPosition(ccp(posX[2],posY))
   		end
   		
   		-- 属性数值
   		local valueNum = CCLabelTTF:create(_showAttrTab[i].value,g_sFontName,25)
   		valueNum:setColor(ccc3(0x00, 0x00, 0x00))
   		valueNum:setAnchorPoint(ccp(0,0.5))
   		valueNum:setPosition(ccp(attrName:getPositionX()+attrName:getContentSize().width,attrName:getPositionY()))
   		scrollView:addChild(valueNum)
   	end

end


--[[
	@des 	: 详细信息
	@param 	: p_hid 武将hid,tip_zOrderNum 弹窗的z，tip_layer_priority 弹窗的优先级
	@return :
--]]
function showTip( p_htid, p_hid, tip_zOrderNum, tip_layer_priority,p_info,p_string)
	-- 初始化
	init()

	_showAttrTab = p_info

	_titleString = p_string or GetLocalizeStringBy("lic_1252")

	_showzOrder = tip_zOrderNum or 1010
	_showLayerPriority = tip_layer_priority or -420

	-- 创建提示layer
	createTipLayer()
end