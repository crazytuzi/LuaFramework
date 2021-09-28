-- FileName: OnekeyLayer.lua 
-- Author: licong 
-- Date: 16/9/20 
-- Purpose: 一键兑换材料界面 


module("OnekeyLayer", package.seeall)

require "script/ui/forge/ForgeData"

local _bgLayer                  	= nil
local _backGround 					= nil
local _second_bg  					= nil

local _methoodId 					= nil
local _needItemTid 					= nil
local _needItemTab 					= nil
local _needAllPoint 				= nil

local _touchPriority 				= nil

local _callBack 					= nil

function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil
	_second_bg  					= nil

	_methoodId 						= nil
	_needItemTid 					= nil
	_needItemTab 					= nil
	_needAllPoint 					= nil

	_touchPriority 					= nil
	_callBack 						= nil
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
	@des 	:确认按钮回调
	@param 	:
	@return :
--]]
function confirmBtnCallback( tag, sender )
	-- 积分不足
	local curPoint = FindTreasureData.getTotalPoint()
	if(curPoint < _needAllPoint )then 
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1852"))
		return
	end
	--是否背包满
	if(ItemUtil.isBagFull() == true )then
		closeButtonCallback()
		return
	end
	
    local nextCallFun = function ( ... )
    	closeButtonCallback()
    	-- 扣除积分
    	FindTreasureData.subPoint(_needAllPoint)
    	-- 刷新回调
    	if(_callBack)then
    		_callBack()
    	end
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1854"))
    end
    ForgeService.composeQuickBuy( _methoodId, _needItemTid, nextCallFun )
end

--[[
	@des 	:创建物品列表
	@param 	:
	@return :
--]]
function createGoodsView()
	local posX = {30,140,260,380}
    local posY = _second_bg:getContentSize().height-110
    for i=0,#_needItemTab-1 do 
    	local curPosY = posY-math.floor(i/4)*130
    	local goodIcon = ItemUtil.createGoodsIcon(_needItemTab[i+1], _touchPriority - 1, 1010, _touchPriority - 10)
		goodIcon:setAnchorPoint(ccp(0,0))
		goodIcon:setPosition(ccp(posX[i%4+1], curPosY ))
		_second_bg:addChild(goodIcon)
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
    _bgLayer:registerScriptTouchHandler(layerTouch,false,_touchPriority,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(600,570))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority-5)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 标题
    local titlePanel = CCScale9Sprite:create("images/common/viewtitle1.png")
    titlePanel:setContentSize(CCSizeMake(350,61))
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)

	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1848"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 提示1
	local methoodData = ForgeData.getDBdataByMethoodId(_methoodId)
	local desItemData = ItemUtil.getItemById(methoodData.orangeId)
	local desItemQuality = methoodData.orange_quality or desItemData.quality
    local textInfo = {
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontPangWa,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
	        defaultType = "CCLabelTTF",
	        linespace = 10, -- 行间距
	        elements =
	        {	
	        	{
	            	type = "CCLabelTTF", 
	            	text = desItemData.name,
	            	color = HeroPublicLua.getCCColorByStarLevel(desItemQuality),
	        	},
	        }
	 	}
 	local tipNode1 = GetLocalizeLabelSpriteBy_2("lic_1849", textInfo)
 	tipNode1:setAnchorPoint(ccp(0.5,0))
 	tipNode1:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-85))
 	_backGround:addChild(tipNode1)

	-- 二级背景
	_second_bg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	_second_bg:setContentSize(CCSizeMake(500,300))
 	_second_bg:setAnchorPoint(ccp(0.5,1))
 	_second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,tipNode1:getPositionY()-20))
 	_backGround:addChild(_second_bg)

 	-- 创建物品列表
 	createGoodsView()
 	
 	-- 提示2
    local textInfo = {
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontPangWa,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
	        defaultType = "CCLabelTTF",
	        linespace = 10, -- 行间距
	        elements =
	        {	
	        	{
	            	type = "CCRenderLabel", 
	            	text = GetLocalizeStringBy("lic_1851"),
	            	color = ccc3(0xff, 0xe4, 0x00),
	            	strokeColor = ccc3(0x00, 0x00, 0x00),
	        	},
	        	{
	            	type = "CCSprite",
	            	image = "images/forge/xunlongjifen_icon.png"
	        	},
	        	{
	            	type = "CCRenderLabel", 
	            	text = _needAllPoint,
	            	color = ccc3(0x00, 0xff, 0x18),
	            	strokeColor = ccc3(0x00, 0x00, 0x00),
	        	},
	        }
	 	}
 	local tipNode2 = GetLocalizeLabelSpriteBy_2("lic_1850", textInfo)
 	tipNode2:setAnchorPoint(ccp(0.5,0))
 	tipNode2:setPosition(ccp(_backGround:getContentSize().width*0.5,_second_bg:getPositionY()-_second_bg:getContentSize().height-40))
 	_backGround:addChild(tipNode2)

 	--确定按钮
    local confirmMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180,73),GetLocalizeStringBy("key_1465"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    confirmMenuItem:setAnchorPoint(ccp(0.5,0))
    confirmMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.3,40))
    confirmMenuItem:registerScriptTapHandler(confirmBtnCallback)
    menu:addChild(confirmMenuItem)
    --取消按钮
    local closeMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180,73),GetLocalizeStringBy("key_2326"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    closeMenuItem:setAnchorPoint(ccp(0.5,0))
    closeMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.7,40))
    closeMenuItem:registerScriptTapHandler(closeButtonCallback)
    menu:addChild(closeMenuItem)
end

--[[
	@des 	:显示奖励预览
	@param 	:
	@return :
--]]
function showView( p_touchPriority, pMethoodId, pNeedItemTid, pCallBack )
	-- 初始化
	init()

	_touchPriority = p_touchPriority or -500
	_methoodId 	= pMethoodId
	print("_methoodId",_methoodId)
	_needItemTid = pNeedItemTid
	print("_needItemTid",_needItemTid)
	_needItemData = ItemUtil.getItemById(_needItemTid)
	print_t(_needItemData)
	_needItemTab = ForgeData.getNeedFragmentsArr( _methoodId,_needItemTid )
	_needAllPoint = ForgeData.getNeedAllPoint( _needItemTab )

	_callBack = pCallBack
	-- 创建提示layer
	createTipLayer()
end
