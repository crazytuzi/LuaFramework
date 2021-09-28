-- FileName: MonSignCharge.lua 
-- Author: DJN 
-- Date: 14-10-13
-- Purpose: 月签到VIP等级不足提示充值界面


module("MonSignCharge", package.seeall)
--require "script/utils/BaseUI"

local _bgLayer  
local _touchPriority --触摸优先级
local _ZOrder		 --Z轴值
local _VIPnum

function init()
	
	_bgLayer = nil
	_touchPriority = nil
	_ZOrder		   = nil
	_VIPnum = nil
	
end
----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
	if eventType == "began" then
		print("onTouchesHandler,began")
	    return true
    elseif eventType == "moved" then
    	print("onTouchesHandler,moved")
    else
        print("onTouchesHandler,else")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif event == "exit" then
		print("背景释放")
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des 	:按钮回调
	@param 	:
	@return :
--]]
local function BtnCallBack(tag)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print("执行回调")
	-- print("按钮tag",tag)
	if(tag == 1)then
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		require "script/ui/shop/RechargeLayer"
		--转向充值界面
    	local chargeLayer = RechargeLayer.createLayer(_touchPriority-100)
    	local curScene = CCDirector:sharedDirector():getRunningScene()
    	curScene:addChild(chargeLayer,_ZOrder)
    	close()
	elseif(tag == 2)then
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		close()
	end
	
end
--[[
	@des 	:关闭界面函数
	@param 	:
	@return :
--]]
function close( ... )
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end


----------------------------------------UI函数
--[[
	@des 	:创建背景
	@param 	:
	@return :
--]]
 function createBgUI()
	require "script/ui/main/MainScene"
	local bgSize = CCSizeMake(550,300)
	local bgScale = MainScene.elementScale
    
	--主黄色背景
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
	bgSprite:setScale(bgScale)
	_bgLayer:addChild(bgSprite)

    --当日签到奖励已经领取 那句话
    local strA = CCLabelTTF:create(GetLocalizeStringBy("djn_64"),g_sFontPangWa,23)
	strA:setColor(ccc3(0x78,0x25,0x00))
	strA:setAnchorPoint(ccp(0.5,0))
	strA:setPosition(ccp(bgSprite:getContentSize().width *0.5,190))
	bgSprite:addChild(strA)

	--充值升级到VIP X 可领取双倍，是否充值？ 那句话
	local strB = CCLabelTTF:create(GetLocalizeStringBy("key_2219"),g_sFontPangWa,23)
	strB:setColor(ccc3(0x78,0x25,0x00))
    strB:setAnchorPoint(ccp(0,0.5))
	strB:setPosition(ccp(50,150))
	bgSprite:addChild(strB)
	-- strC = CCLabelTTF:create(GetLocalizeStringBy("djn_61").._VIPnum,g_sFontPangWa,23)
	-- strC:setColor(ccc3(0x00,0x00,0x00))
	-- VIP图标
    local vip_lv = CCSprite:create ("images/common/vip.png")
    vip_lv:setAnchorPoint(ccp(0,0.5))
    vip_lv:setPosition(ccp(strB:getContentSize().width + strB:getPositionX()+1,strB:getPositionY()))
    bgSprite:addChild(vip_lv)

    -- VIP对应级别
    require "script/libs/LuaCC"
    local vip_lv_num = LuaCC.createSpriteOfNumbersForMonthSign("images/main/vip", _VIPnum, 20)
    
    vip_lv_num:ignoreAnchorPointForPosition(false)
    vip_lv_num:setAnchorPoint(ccp(0,0.5))
    vip_lv_num:setPosition(ccp(vip_lv:getContentSize().width + vip_lv:getPositionX()+1,strB:getPositionY()))
    bgSprite:addChild(vip_lv_num)

	local strD = CCLabelTTF:create(GetLocalizeStringBy("djn_65"),g_sFontPangWa,23)
	strD:setAnchorPoint(ccp(0,0.5))
	strD:setColor(ccc3(0x78,0x25,0x00))
	strD:setPosition(ccp(vip_lv_num:getContentSize().width + vip_lv_num:getPositionX()+1,strB:getPositionY()))
	bgSprite:addChild(strD)
	
	-- local firstNode = BaseUI.createHorizontalNode({strB,vip_lv,vip_lv_num,strD})
 --    firstNode:ignoreAnchorPointForPosition(false)
 --    firstNode:setAnchorPoint(ccp(0,1))
 --    firstNode:setPosition(ccp(50,170))
 --    bgSprite:addChild(firstNode)

    local MenuBar = CCMenu:create()
	MenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(MenuBar)
	MenuBar:setTouchPriority(_touchPriority-50)

	
    local chargeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",
    	                    CCSizeMake(145, 80),GetLocalizeStringBy("key_1170"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    chargeMenuItem:setScale(0.8)
    chargeMenuItem:setAnchorPoint(ccp(0.5,0))
    chargeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,45))
    chargeMenuItem:registerScriptTapHandler(BtnCallBack)
    MenuBar:addChild(chargeMenuItem)
    chargeMenuItem:setTag(1)

    -- 关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(BtnCallBack)
    MenuBar:addChild(closeBtn)
    closeBtn:setTag(2)


    -- local cancelMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2326"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    -- cancelMenuItem:setAnchorPoint(ccp(0.5,0))
    -- cancelMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.75,35))
    -- cancelMenuItem:registerScriptTapHandler(BtnCallBack)
    -- MenuBar:addChild(cancelMenuItem)
    -- cancelMenuItem:setTag(2)

end
------------入口函数
function showLayer(tag,p_touchPriority,p_ZOrder)
	init()
	_touchPriority = p_touchPriority or -599
	_ZOrder = p_ZOrder or 999
	_VIPnum = tag

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	--_bgLayer:setScale(g_fScaleX)
	local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder)

    createBgUI()

	return _bgLayer
	-- body
end
