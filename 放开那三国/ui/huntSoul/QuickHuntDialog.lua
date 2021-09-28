-- FileName: QuickHuntDialog.lua 
-- Author: licong 
-- Date: 14-10-9 
-- Purpose: 快速猎魂弹出框 10次 or 50次


module("QuickHuntDialog", package.seeall)

local _bgLayer                  	= nil
local _backGround 					= nil


function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil

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
	@des 	:关闭按钮回调
	@param 	:p_normalFile 按钮normal图片, p_selectFile 按钮select图片, p_NameFile 按钮名字图片,p_NamePosY 名字的Y坐标
	@return : MenuItem
--]]
function createBtn( p_normalFile, p_selectFile, p_NameFile, p_NamePosY)
	local meunItem = CCMenuItemImage:create(p_normalFile,p_selectFile)
	-- 名字
	local nameFont = CCSprite:create(p_NameFile)
	nameFont:setAnchorPoint(ccp(0.5,0))
	nameFont:setPosition(ccp(meunItem:getContentSize().width*0.5,p_NamePosY))
	meunItem:addChild(nameFont,10)
	return meunItem
end

--[[
	@des 	:猎10次回调
	@param 	:
	@return :
--]]
function tenMenuItemCallFun( tag, itemBtn )
	-- 关闭自己
	closeButtonCallback()
	-- 调召唤一次函数
	SearchSoulLayer.huntTenMenuAction()
end

--[[
	@des 	:猎50次回调
	@param 	:
	@return :
--]]
function fiftyMenuItemCallFun( tag, itemBtn )
	-- 关闭自己
	closeButtonCallback()
	-- 猎50次回调
	SearchSoulLayer.fiftyHuntCallFun()
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
    _backGround:setContentSize(CCSizeMake(525, 500))
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

	-- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1254"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)
	
	-- 猎10次按钮
	local oneMenuItem = createBtn( "images/hunt/one_n.png","images/hunt/one_h.png", "images/hunt/hunt_ten.png", 1)
	oneMenuItem:setAnchorPoint(ccp(0.5,0.5))
	oneMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.27, _backGround:getContentSize().height*0.55))
	menu:addChild(oneMenuItem)
	oneMenuItem:registerScriptTapHandler(tenMenuItemCallFun)

	-- 猎50次按钮
	local tenMenuItem = createBtn( "images/hunt/ten_n.png","images/hunt/ten_h.png", "images/hunt/hunt_fifty.png", 10)
	tenMenuItem:setAnchorPoint(ccp(0.5,0.5))
	tenMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.73, _backGround:getContentSize().height*0.55))
	menu:addChild(tenMenuItem)
	tenMenuItem:registerScriptTapHandler(fiftyMenuItemCallFun)

	--猎魂50次提示
	local tenTip = CCSprite:create("images/hunt/hunt_fifty_des.png")
	tenTip:setAnchorPoint(ccp(0.5,1))
	tenTip:setPosition(ccp(tenMenuItem:getContentSize().width*0.5,tenMenuItem:getContentSize().height-50))
	tenMenuItem:addChild(tenTip,10)

	--主角等级达到%d后开启猎50次
	local isOpne,needLeve,needVip = HuntSoulData.getIsOpenHuntFifty()
	local tipFont = CCLabelTTF:create(string.format(GetLocalizeStringBy("lic_1253"),needVip,needLeve), g_sFontPangWa, 21)
	tipFont:setColor(ccc3(0x78, 0x25, 0x00))
	tipFont:setAnchorPoint(ccp(0.5, 0))
	tipFont:setPosition(ccp(_backGround:getContentSize().width*0.5,50))
	_backGround:addChild(tipFont)
end


--[[
	@des 	:选择猎取次数的提示框
	@param 	:
	@return :
--]]
function showTip()
	-- 初始化
	init()

	-- 创建提示layer
	createTipLayer()
end
