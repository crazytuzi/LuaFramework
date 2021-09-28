-- FileName : NotificationSwitchPanel.lua
-- Author   : YangRui
-- Date     : 2015-12-26
-- Purpose  : 

module("NotificationSwitchPanel", package.seeall)

require "script/ui/menu/NotificationSwitchData"
require "script/utils/NotificationUtil"
require "script/ui/tip/AlertTip2"

local _bgLayer       = nil
local _bgSp          = nil  -- bg
local _touchPriority = nil
local _zorder        = nil

local ksOn           = 0  -- 开启状态
local ksOff          = 1  -- 关闭状态

local ksNotiKey      = "NOTIFICATIONS_ID"  -- 通知中心

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer = nil
	_bgSp    = nil  -- bg
end

--[[
    @des    : 处理touches事件
    @para   : 
    @return : 
 --]]
function onTouchesHandler( eventType, x, y )
    return true
end

--[[
	@des 	: 回调onEnter和onExit事件
	@param 	: 
	@return : 
--]]
function onNodeEvent( pEvent )
    if pEvent == "enter" then
    	_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
    elseif pEvent == "exit" then
    	_bgLayer:unregisterScriptTouchHandler()
    end
end

--[[
	@des 	: 关闭方法
	@param 	: 
	@return : 
--]]
function closeSelfCallback( ... )
    if _bgLayer ~= nil then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
end

--[[
	@des 	: 跳转
	@param 	: 
	@return : 
--]]
function redirect2NotificationSetting( ... )
	if NotificationSwitchData.canRedirect() then
		local path = NSBundleInfo:getAppBundleID()
		PlatformUtil:redirect2Other(ksNotiKey,path)
	else
		print("can not redirect")
	end
	closeSelfCallback()
end

--[[
	@des 	: 开启关闭按钮的回调
	@param 	: 
	@return : 
--]]
function toggleBtnCallback( pSwitchTag, sender )
	local btn = tolua.cast(sender,"CCMenuItemToggle")
	local curState = btn:getSelectedIndex()
	-- 获取是否授权通知
	local isAllow = PlatformUtil:isAllowNotification()
	if isAllow then
		-- 若是 正常操作
		if curState == ksOff then
			-- 关闭操作
			NotificationSwitchData.cancleNotificationByTag(pSwitchTag)
		else
			-- 打开操作
			NotificationSwitchData.addNotificationByTag(pSwitchTag)
		end
	else
		-- 若否 弹出提示
		btn:setSelectedIndex(ksOff)
		-- 获取系统版本 yr_5006 设置
		local confirmTitle = nil
		if NotificationSwitchData.canRedirect() then
			-- 若为iOS8.0及其以后系统版本
			-- 可直接跳转
			confirmTitle = GetLocalizeStringBy("yr_5006")
		else
			-- 否则
			-- 不能直接跳转
		end
		AlertTip2.showAlert(GetLocalizeStringBy("yr_8006"),GetLocalizeStringBy("yr_8007"),redirect2NotificationSetting,false,nil,confirmTitle)
	end
end

--[[
	@des 	: 创建开启关闭按钮
	@param 	: 
	@return : 
--]]
function createToggleBtn( pSwitchTag )
	-- 开启状态背景
	local swOnBg = CCScale9Sprite:create("images/common/bg/green_bg.png")
	swOnBg:setPreferredSize(CCSizeMake(120,50))
	swOnBg:setAnchorPoint(ccp(0.5,0.5))
	-- swOnBg:setScale(0.7)
	-- 开启文字
	local onSp = CCSprite:create("images/common/on.png")
	onSp:setAnchorPoint(ccp(0,0.5))
	onSp:setPosition(ccp(10,swOnBg:getContentSize().height/2))
	swOnBg:addChild(onSp)
	-- 圆球
	local circleOnSp = CCSprite:create("images/common/orange_circle.png")
	circleOnSp:setAnchorPoint(ccp(0.5,0.5))
	circleOnSp:setPosition(ccp(swOnBg:getContentSize().width-circleOnSp:getContentSize().width/2+5,swOnBg:getContentSize().height/2-3))
	circleOnSp:setScale(0.9)
	swOnBg:addChild(circleOnSp)
	-- 关闭状态背景
	local swOffBg = CCScale9Sprite:create("images/common/bg/orange_bg.png")
	swOffBg:setPreferredSize(CCSizeMake(120,50))
	swOffBg:setAnchorPoint(ccp(0.5,0.5))
	-- swOffBg:setScale(0.7)
	-- 关闭文字
	local offSp = CCSprite:create("images/common/off.png")
	offSp:setAnchorPoint(ccp(1,0.5))
	offSp:setPosition(ccp(swOffBg:getContentSize().width-10,swOffBg:getContentSize().height/2))
	swOffBg:addChild(offSp)
	-- 圆球
	local circleOffSp = CCSprite:create("images/common/green_circle.png")
	circleOffSp:setAnchorPoint(ccp(0.5,0.5))
	circleOffSp:setPosition(ccp(circleOffSp:getContentSize().width/2,swOffBg:getContentSize().height/2-3))
	circleOffSp:setScale(0.9)
	swOffBg:addChild(circleOffSp)
	-- 按钮的两种状态
	local onState = CCMenuItemSprite:create(swOnBg,swOnBg)
	onState:setAnchorPoint(ccp(0.5,0.5))
	local offState = CCMenuItemSprite:create(swOffBg,swOffBg)
	offState:setAnchorPoint(ccp(0.5,0.5))
	-- create btn
	local swBtn = CCMenuItemToggle:create(onState)
	swBtn:addSubItem(offState)
	local state = NotificationSwitchData.getSwStateByTag(pSwitchTag)
	local isAllow = PlatformUtil:isAllowNotification()
	if( isAllow )then
		swBtn:setSelectedIndex(state)
	else
		swBtn:setSelectedIndex(ksOff)
	end

	return swBtn
end

--[[
	@des 	: 创建推送开关设置选项
	@param 	: pSwitchTag:开关的tag  pDesc:描述  pIsShowLine:是否显示下方的线
	@return : 
--]]
function createNotificationSwitch( pSwitchTag, pDesc, pIsShowLine )
    local switchSp = CCScale9Sprite:create()
    switchSp:setPreferredSize(CCSizeMake(500,65))
    -- Desc
    local descLabel = CCRenderLabel:createWithAlign(pDesc,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke,CCSizeMake(300,30),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
    descLabel:setAnchorPoint(ccp(1,0.5))
    descLabel:setPosition(ccp(switchSp:getContentSize().width*2/5,switchSp:getContentSize().height/2))
    descLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    switchSp:addChild(descLabel)
    -- MenuBar
    local btnMenuBar = CCMenu:create()
    btnMenuBar:setPosition(ccp(0,0))
    btnMenuBar:setTouchPriority(_touchPriority-20)
    switchSp:addChild(btnMenuBar)
    -- ToggleBtn
	local toggleBtn = createToggleBtn(pSwitchTag)
	toggleBtn:setAnchorPoint(ccp(0,0.5))
	toggleBtn:setPosition(ccp(switchSp:getContentSize().width*2/3,switchSp:getContentSize().height/2))
	toggleBtn:registerScriptTapHandler(toggleBtnCallback)
	btnMenuBar:addChild(toggleBtn,1,pSwitchTag)
    -- 是否创建下方的分割线
    if pIsShowLine then
    	local line = CCScale9Sprite:create("images/common/line01.png")
    	line:setContentSize(CCSizeMake(400,4))
    	line:setAnchorPoint(ccp(0.5,1))
    	line:setPosition(ccp(switchSp:getContentSize().width/2,-5))
    	switchSp:addChild(line)
    end

    return switchSp
end

--[[
	@des 	: 创建通知项的cell
	@param 	: 
	@return : 
--]]
function createNotificationSwitchCell( pTab, pIsShowLine )
	local cell = CCTableViewCell:create()
	cell:setContentSize(CCSizeMake(520,75))
	local switch = nil
	for key,str in pairs(pTab) do
		switch = createNotificationSwitch(tonumber(key),str,pIsShowLine)
	end
	switch:setPosition(ccpsprite(0,0,cell))
	cell:addChild(switch)

	return cell
end

--[[
	@des 	: 创建推送开关二级界面
	@param 	: 
	@return : 
--]]
function createInnerLayer( ... )
	-- inner bg
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(520,350))
	innerBgSp:setAnchorPoint(ccp(0.5,0))
	innerBgSp:setPosition(ccp(_bgSp:getContentSize().width/2,110))
	_bgSp:addChild(innerBgSp)
	-- 支持滚动 为以后添加做准备
	local tableViewSize = CCSizeMake(innerBgSp:getContentSize().width,innerBgSp:getContentSize().height-20)
	local cellSize = CCSizeMake(520,75)
	local notifiArr = NotificationSwitchData.getNotificationArray()
	local notifiArrLen = table.count(notifiArr)
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local ret
			if fn == "cellSize" then
				ret = cellSize
			elseif fn == "cellAtIndex" then
				local index = a1+1
				-- 是不是最后一个
				if index == #notifiArr then
					ret = createNotificationSwitchCell(notifiArr[index],false)
				else
					ret = createNotificationSwitchCell(notifiArr[index],true)
				end
			elseif fn == "numberOfCells" then
				ret = notifiArrLen
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	local tableView = LuaTableView:createWithHandler(luaHandler,tableViewSize)
	tableView:setTouchPriority(_touchPriority-30)
	tableView:setBounceable(true)
	tableView:setDirection(kCCScrollViewDirectionVertical)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:setAnchorPoint(ccp(0,0))
	tableView:setPosition(ccp(0,10))
	innerBgSp:addChild(tableView)
	if notifiArrLen <= 4 then
		tableView:setTouchEnabled(false)
	end
end

--[[
	@des 	: 关闭按钮回调
	@param 	: 
	@return : 
--]]
function closeBtnCallback( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	closeSelfCallback()
end

--[[
	@des 	: 创建UI
	@param 	: 
	@return : 
--]]
function createUI( ... )
	-- panel bg
	_bgSp = CCScale9Sprite:create("images/common/viewbg1.png")
    _bgSp:setContentSize(CCSizeMake(580,560))
    _bgSp:setAnchorPoint(ccp(0.5,0.5))
    _bgSp:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
    _bgSp:setScale(g_fScaleX)
    _bgLayer:addChild(_bgSp)
	-- title bg
	local titleSp = CCSprite:create("images/common/viewtitle1.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_bgSp:getContentSize().width/2,_bgSp:getContentSize().height*0.988))
	_bgSp:addChild(titleSp)
	-- title
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_8000"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2,titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)
	-- Tip
	local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("yr_8001"),g_sFontPangWa,24)
	tipLabel:setAnchorPoint(ccp(0.5,1))
	tipLabel:setPosition(ccp(_bgSp:getContentSize().width/2,titleSp:getPositionY()-titleSp:getContentSize().height+tipLabel:getContentSize().height/2))
	tipLabel:setColor(ccc3(0x78,0x25,0x00))
	_bgSp:addChild(tipLabel)
    -- MenuBar
    local closeMenuBar = CCMenu:create()
    closeMenuBar:setPosition(ccp(0,0))
    closeMenuBar:setTouchPriority(_touchPriority-10)
    _bgSp:addChild(closeMenuBar)
    -- X 按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setAnchorPoint(ccp(0.5,0.5))
    closeBtn:setPosition(ccp(_bgSp:getContentSize().width*0.97,_bgSp:getContentSize().height*0.98))
    closeBtn:registerScriptTapHandler(closeBtnCallback)
    closeMenuBar:addChild(closeBtn)
    -- 关闭按钮
    local closeMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180,73),GetLocalizeStringBy("key_1284"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    closeMenuItem:setAnchorPoint(ccp(0.5,0))
    closeMenuItem:setPosition(ccp(_bgSp:getContentSize().width/2,30))
    closeMenuItem:registerScriptTapHandler(closeBtnCallback)
    closeMenuBar:addChild(closeMenuItem)
    -- 创建推送开关二级界面
    createInnerLayer()
end

--[[
	@des 	: 创建Layer
	@param 	: 
	@return : 
--]]
function createLayer( pTouchPriority, pZorder )
	-- init
	init()
	_touchPriority = pTouchPriority or -600
	_zorder = pZorder or 1000
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,100))
	_bgLayer:registerScriptHandler(onNodeEvent)
	-- createUI
	createUI()

	return _bgLayer
end

--[[
	@des 	: 显示Layer
	@param 	: 
	@return : 
--]]
function show( pTouchPriority, pZorder )
	_touchPriority = pTouchPriority or -600
	_zorder = pZorder or 1000
	local isSupport = NotificationUtil.isSupportPackage()
	if isSupport then
		local layer = createLayer( pTouchPriority, pZorder )
		local runningScene = CCDirector:sharedDirector():getRunningScene()
	    runningScene:addChild(layer,_zorder)
	else
		print("===|老包不支持|===")
		AnimationTip.showTip(GetLocalizeStringBy("yr_8008"))
	end
end
