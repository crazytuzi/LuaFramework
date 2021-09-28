-- FileName: CallDragonDialog.lua 
-- Author: licong 
-- Date: 14-7-15 
-- Purpose: 召唤神龙弹出框 选择召唤一次 or 召唤十次


module("CallDragonDialog", package.seeall)

local _bgLayer                  	= nil
local _backGround 					= nil

local _shenlonglingNum 				= nil
local _shenOpneId					= nil
local _needGoldNum					= nil
local _needItemId 					= nil

function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil

	_shenlonglingNum 				= nil
	_shenOpneId						= nil
	_needGoldNum					= nil
	_needItemId 					= nil
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
	@param 	:p_normalFile 按钮normal图片, p_selectFile 按钮select图片, p_NameFile 按钮名字图片,
	@param 	:p_costNum 消耗金币数量, p_needNum 消耗神龙令个数, p_NamePosY 名字的Y坐标, p_CostPosY 花费的Y坐标
	@return : MenuItem
--]]
function createBtn( p_normalFile, p_selectFile, p_NameFile, p_costNum, p_needNum, p_NamePosY, p_CostPosY)
	-- 召唤一次按钮
	local meunItem = CCMenuItemImage:create(p_normalFile,p_selectFile)
	-- 名字
	local nameFont = CCSprite:create(p_NameFile)
	nameFont:setAnchorPoint(ccp(0.5,0))
	nameFont:setPosition(ccp(meunItem:getContentSize().width*0.5,p_NamePosY))
	meunItem:addChild(nameFont,10)
	-- 花费
    local goldIcon = CCSprite:create("images/common/gold.png")
	goldIcon:setAnchorPoint(ccp(0, 0.5))
	meunItem:addChild(goldIcon)
	local goldFont = CCRenderLabel:create( p_costNum .. GetLocalizeStringBy("lic_1149"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_stroke)
	goldFont:setColor(ccc3(0xff, 0xf6, 0x00))
	goldFont:setAnchorPoint(ccp(0, 0.5))
	meunItem:addChild(goldFont)
	local shenIcon = CCSprite:create("images/common/shenlongling.png")
	shenIcon:setAnchorPoint(ccp(0, 0.5))
	meunItem:addChild(shenIcon)
	local shenNumFont = CCRenderLabel:create( p_needNum, g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_stroke)
	shenNumFont:setColor(ccc3(0xff, 0xf6, 0x00))
	shenNumFont:setAnchorPoint(ccp(0, 0.5))
	meunItem:addChild(shenNumFont)

	-- 居中
	local posX = (meunItem:getContentSize().width-goldIcon:getContentSize().width-goldFont:getContentSize().width-shenIcon:getContentSize().width-shenNumFont:getContentSize().width)/2
	local posY = p_CostPosY
	goldIcon:setPosition(posX, posY)
	goldFont:setPosition(goldIcon:getPositionX()+goldIcon:getContentSize().width, posY)
	shenIcon:setPosition(goldFont:getPositionX()+goldFont:getContentSize().width, posY)
	shenNumFont:setPosition(shenIcon:getPositionX()+shenIcon:getContentSize().width, posY)

	return meunItem
end

--[[
	@des 	:召唤一次按钮回调
	@param 	:
	@return :
--]]
function oneMenuItemCallFun( tag, itemBtn )
	-- 关闭自己
	closeButtonCallback()
	-- 调召唤一次函数
	SearchSoulLayer.oneSomeroCallFun()
end

--[[
	@des 	:召唤十次按钮回调
	@param 	:
	@return :
--]]
function tenMenuItemCallFun( tag, itemBtn )
	-- 关闭自己
	closeButtonCallback()
	-- 召唤十次回调
	SearchSoulLayer.tenSomeroCallFun()
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
    _backGround:setContentSize(CCSizeMake(525, 540))
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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1147"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 拥有神龙令个数
	local font1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1148"), g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_stroke)
	font1:setColor(ccc3(0x00, 0xe4, 0xff))
	font1:setAnchorPoint(ccp(0, 0.5))
	_backGround:addChild(font1)
	local shenIcon = CCSprite:create("images/common/shenlongling.png")
	shenIcon:setAnchorPoint(ccp(0, 0.5))
	_backGround:addChild(shenIcon)
	-- 拥有数
	_shenlonglingNum = ItemUtil.getCacheItemNumBy(_needItemId)
	local shenNumFont = CCRenderLabel:create(":" .. _shenlonglingNum, g_sFontPangWa, 25, 1, ccc3(0, 0, 0), type_stroke)
	shenNumFont:setColor(ccc3(0x00, 0xe4, 0xff))
	shenNumFont:setAnchorPoint(ccp(0, 0.5))
	_backGround:addChild(shenNumFont)
	-- 居中
	local posX = (_backGround:getContentSize().width-font1:getContentSize().width-shenIcon:getContentSize().width-shenNumFont:getContentSize().width)/2
	local posY = _backGround:getContentSize().height-78
	font1:setPosition(posX, posY)
	shenIcon:setPosition(font1:getPositionX()+font1:getContentSize().width, posY)
	shenNumFont:setPosition(shenIcon:getPositionX()+shenIcon:getContentSize().width, posY)
	
	-- 召唤一次按钮
	local oneMenuItem = createBtn( "images/hunt/one_n.png","images/hunt/one_h.png", "images/hunt/one_font.png", _needGoldNum, 1, 1, -30)
	oneMenuItem:setAnchorPoint(ccp(0.5,0.5))
	oneMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.27, _backGround:getContentSize().height*0.5))
	menu:addChild(oneMenuItem)
	oneMenuItem:registerScriptTapHandler(oneMenuItemCallFun)

	-- 召唤十次按钮
	local tenMenuItem = createBtn( "images/hunt/ten_n.png","images/hunt/ten_h.png", "images/hunt/ten_font.png", _needGoldNum*10, 10, 10, -20)
	tenMenuItem:setAnchorPoint(ccp(0.5,0.5))
	tenMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.73, _backGround:getContentSize().height*0.5))
	menu:addChild(tenMenuItem)
	tenMenuItem:registerScriptTapHandler(tenMenuItemCallFun)

	--召唤十次提示
	local tenTip = CCSprite:create("images/hunt/ten_tip.png")
	tenTip:setAnchorPoint(ccp(0.5,1))
	tenTip:setPosition(ccp(tenMenuItem:getContentSize().width*0.5,tenMenuItem:getContentSize().height-50))
	tenMenuItem:addChild(tenTip,10)

	-- 优先消耗神龙令
	local tipFont = CCLabelTTF:create(GetLocalizeStringBy("lic_1150"), g_sFontPangWa, 21)
	tipFont:setColor(ccc3(0x78, 0x25, 0x00))
	tipFont:setAnchorPoint(ccp(0.5, 0))
	tipFont:setPosition(ccp(_backGround:getContentSize().width*0.5,30))
	_backGround:addChild(tipFont)
end


--[[
	@des 	:选择召唤次数的提示框
	@param 	:
	@return :
--]]
function showTip()
	-- 初始化
	init()

	-- 召唤神龙
	_shenOpneId,_needGoldNum,_needItemId = HuntSoulData.getOpenShenLongCost()

	-- 创建提示layer
	createTipLayer()
end






