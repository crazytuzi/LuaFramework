-- Filename：	UpgradeAlertTip.lua
-- Author：		Cheng Liang
-- Date：		2013-12-31
-- Purpose：		提示警告

module("UpgradeAlertTip", package.seeall)


require "script/ui/common/LuaMenuItem"
require "script/ui/main/MainScene"


Tag_Hall 		= 2001 -- 军团大厅/忠义堂
Tag_Guanyu 		= 2002 -- 关公殿
Tag_Shop 		= 2003 -- 军团商城
Tag_LiangCang 	= 2004 -- 军团粮仓
Tag_Book 		= 2005 -- 军团书院(军团任务)
Tag_Military	= 2006 -- 军机大厅

local b_buiding_infos = {}
b_buiding_infos[Tag_Hall] = {}
b_buiding_infos[Tag_Hall].name = GetLocalizeStringBy("key_1553")
b_buiding_infos[Tag_Hall].b_type = 1

b_buiding_infos[Tag_Guanyu] = {}
b_buiding_infos[Tag_Guanyu].name = GetLocalizeStringBy("key_1454")
b_buiding_infos[Tag_Guanyu].b_type = 2

b_buiding_infos[Tag_Shop] = {}
b_buiding_infos[Tag_Shop].name = GetLocalizeStringBy("key_2174")
b_buiding_infos[Tag_Shop].b_type = 3

b_buiding_infos[Tag_Military] = {}
b_buiding_infos[Tag_Military].name = GetLocalizeStringBy("key_1360")
b_buiding_infos[Tag_Military].b_type = 4

b_buiding_infos[Tag_Book] = {}
b_buiding_infos[Tag_Book].name = GetLocalizeStringBy("key_4025")
b_buiding_infos[Tag_Book].b_type = 5

b_buiding_infos[Tag_LiangCang] = {}
b_buiding_infos[Tag_LiangCang].name = GetLocalizeStringBy("lic_1282")
b_buiding_infos[Tag_LiangCang].b_type = 6


local _cormfirmCBFunc = nil 
local _cost_num = nil
local _b_type = nil

local alertLayer

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		alertLayer:registerScriptTouchHandler(onTouchesHandler, false, -5600, true)
		alertLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		alertLayer:unregisterScriptTouchHandler()
        alertLayer = nil
       
	end
end


function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(alertLayer) then
		alertLayer:removeFromParentAndCleanup(true)
		alertLayer = nil
	end

end

-- 升级回调
function upgradeCallback( cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		if(dictData.ret == "noexp")then
			require "script/ui/tip/AnimationTip"
			AnimationTip.showTip(GetLocalizeStringBy("lic_1401"))
			return
		elseif(dictData.ret == "ok")then
			GuildDataCache.addGuildDonate(-_cost_num)
			GuildDataCache.addGuildLevelBy(b_buiding_infos[_b_type].b_type+1, 1, _cost_num)

			if(alertLayer) then
				alertLayer:removeFromParentAndCleanup(true)
				alertLayer = nil
			end

			-- 回调
			if (_cormfirmCBFunc) then
				_cormfirmCBFunc(_b_type)
			end
		else
		end
	end
end

-- 按钮响应
function menuAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local args = Network.argsHandler(b_buiding_infos[_b_type].b_type)
	RequestCenter.guild_upgradeGuild(upgradeCallback, args)

end

--[[
	@desc	alertView
	@para 	tipText, 		 显示文字 string
			confirmCBFunc,   回调 func
			isNeedCancel,	 是否需要取消按钮 bool
	 		argsCB,			 回调传参  
	@return void
--]]
function showAlert( b_type, cost, curLv, confirmCBFunc)
	_cormfirmCBFunc = confirmCBFunc
	_cost_num = tonumber(cost)
	_b_type = tonumber(b_type)

	confirmTitle = confirmTitle or GetLocalizeStringBy("key_2864")
	cancelTitle = cancelTitle or GetLocalizeStringBy("key_2326")
	if(alertLayer) then
		alertLayer:removeFromParentAndCleanup(true)
		alertLayer = nil
	end

	-- layer
	alertLayer = CCLayerColor:create(ccc4(0,0,0,155))
	alertLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(alertLayer, 2000)

	-- 背景
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local alertBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	alertBg:setPreferredSize(CCSizeMake(520, 360))
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	alertBg:setPosition(ccp(alertLayer:getContentSize().width*0.5, alertLayer:getContentSize().height*0.5))
	alertLayer:addChild(alertBg)
	alertBg:setScale(g_fScaleX)	

	local alertBgSize = alertBg:getContentSize()

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	alertBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-5601)
	-- 关闭按钮
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:registerScriptTapHandler(closeAction)
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(alertBg:getContentSize().width*0.95, alertBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	-- 标题
	-- local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
 --    -- titleLabel:setSourceAndTargetColor(ccc3( 0xff, 0xed, 0x55), ccc3( 0xff, 0x8f, 0x00));
 --    titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
 --    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
 --    titleLabel:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height*0.8))
 --    alertBg:addChild(titleLabel)

	-- 描述
	local descLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2149"), g_sFontName, 25)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 0.5))
	descLabel:setPosition(ccp(alertBgSize.width*0.1, alertBgSize.height*0.7))
	alertBg:addChild(descLabel)
	-- 花费
	local costLabel = CCRenderLabel:create(_cost_num, g_sFontName, 28, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    costLabel:setColor(ccc3(0xff, 0xff, 0x60))
    costLabel:setAnchorPoint(ccp(0, 0.5))
    costLabel:setPosition(ccp(alertBgSize.width*0.1 + descLabel:getContentSize().width, alertBgSize.height*0.7))
    alertBg:addChild(costLabel)
    -- 
    local descLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("key_3210") .. curLv .. GetLocalizeStringBy("key_2469") .. b_buiding_infos[_b_type].name , g_sFontName, 25)
	descLabel_2:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel_2:setAnchorPoint(ccp(0, 0.5))
	local width_2 = alertBgSize.width*0.1 + descLabel:getContentSize().width + costLabel:getContentSize().width
	descLabel_2:setPosition(ccp(width_2, alertBgSize.height*0.7))
	alertBg:addChild(descLabel_2)
	-- 描述
	local descLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("key_2219"), g_sFontName, 25)
	descLabel_1:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel_1:setAnchorPoint(ccp(0, 0.5))
	descLabel_1:setPosition(ccp(alertBgSize.width*0.1, alertBgSize.height*0.55))
	alertBg:addChild(descLabel_1)
	-- level
	local lvLabel = CCRenderLabel:create(curLv+1, g_sFontName, 28, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvLabel:setColor(ccc3(0x00, 0xe4, 0xff))
    lvLabel:setAnchorPoint(ccp(0, 0.5))
    lvLabel:setPosition(ccp(alertBgSize.width*0.1 + descLabel_1:getContentSize().width, alertBgSize.height*0.55))
    alertBg:addChild(lvLabel)
    --
    local descLabel_3 = CCLabelTTF:create(GetLocalizeStringBy("key_2009"), g_sFontName, 25)
	descLabel_3:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel_3:setAnchorPoint(ccp(0, 0.5))
	local width_3 = alertBgSize.width*0.1 + descLabel_1:getContentSize().width + lvLabel:getContentSize().width
	descLabel_3:setPosition(ccp(width_3, alertBgSize.height*0.55))
	alertBg:addChild(descLabel_3)

	if(b_buiding_infos[_b_type].b_type ~=1 )then
		-- tishi
		local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1960"), g_sFontPangWa, 21)
		tipLabel:setColor(ccc3(0x78, 0x25, 0x00))
		tipLabel:setAnchorPoint(ccp(0.5, 0))
		tipLabel:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height*0.35))
		alertBg:addChild(tipLabel)
	end

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-5601)
	alertBg:addChild(menuBar)

	-- 确认
	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), confirmTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
    confirmBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(confirmBtn, 1, 10001)
	
	-- 取消
	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), cancelTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
    cancelBtn:registerScriptTapHandler(closeAction)
	menuBar:addChild(cancelBtn, 1, 10002)

	confirmBtn:setPosition(ccp(alertBgSize.width*0.3, alertBgSize.height*0.2))
	cancelBtn:setPosition(ccp(alertBgSize.width*0.7, alertBgSize.height*0.2))
	
end




