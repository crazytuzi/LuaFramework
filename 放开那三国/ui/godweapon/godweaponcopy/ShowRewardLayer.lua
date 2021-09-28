-- Filename：	ShowRewardLayer.lua
-- Author：		LLP
-- Date：		2014-12-12
-- Purpose：		显示获得奖励界面

module("ShowRewardLayer", package.seeall)

require "script/ui/godweapon/godweaponcopy/RewardMenuSprite"
require "script/ui/godweapon/godweaponcopy/GodWeaponChest"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyService"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"

kTypeNormalBox 	= 1001
kTypeGodBox		= 1002

local _bgLayer
local _copyInfo
local _rewardInfo

local _openBoxType = nil

function init()
	_bgLayer = nil
	_copyInfo = nil
	_rewardInfo = nil
	_openBoxType = nil
end

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then

    else

	end
end

-- --获取奖励信息
-- local function getRewardInfo()
-- 	_rewardInfo = GodWeaponCopyData.getRewardInfo()
-- end

-- --发送获取奖励命令
-- local function sendCommond()
-- 	--获取当前在第几关
-- 	_copyInfo = GodWeaponCopyData.getCopyInfo()
-- 	--获取奖励信息命令参数
-- 	local args = CCArray:create()
-- 	args:addObject(CCInteger:create(tonumber(_copyInfo.cur_base)))
-- 	args:addObject(CCInteger:create(0))
-- 	--调用获取奖励命令
-- 	GodWeaponCopyService.rewardInfo(getRewardInfo,args)
-- end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -550, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

function makeSure()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
	if(not table.isEmpty(_copyInfo["va_pass"]["chestShow"]) and tonumber(_copyInfo["va_pass"]["chestShow"]["goldChest"])==1 and not table.isEmpty(_copyInfo["va_pass"]["buffShow"]))then
		if( GodWeaponCopyData.justRemainOnce() == true )then
			-- 如果其他任务都已经完成所有
			GodWeaponCopyMainLayer.nextSenceEffect()
		else
			GodWeaponCopyMainLayer.refreshFunc()
		end

	elseif(not table.isEmpty(_copyInfo["va_pass"]["chestShow"]) and tonumber(_copyInfo["va_pass"]["chestShow"]["goldChest"])==0)then
		-- 设置普通宝箱已经完成
		GodWeaponCopyData.setNormalBoxOver()
		GodWeaponChest.showLayer()
	end
end

function createBackGround()
	_copyInfo = GodWeaponCopyData.getCopyInfo()
    local titleBg= CCSprite:create("images/godweaponcopy/getreward.png")
	titleBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*2/3))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	titleBg:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(titleBg)

	local rewardmenuSprite = RewardMenuSprite.createRewardMenuSprite(_rewardInfo)
	rewardmenuSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(rewardmenuSprite,10)
	rewardmenuSprite:setAnchorPoint(ccp(0.5,0.5))
	rewardmenuSprite:ignoreAnchorPointForPosition(false)

	rewardmenuSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.47))

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    _bgLayer:addChild(menu,99)

    local ccBtnSure = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 64), GetLocalizeStringBy("key_2229"), ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0, 0, 0))
    ccBtnSure:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.3))
    ccBtnSure:setAnchorPoint(ccp(0.5,0.5))
    ccBtnSure:setScale(g_fElementScaleRatio)
    ccBtnSure:registerScriptTapHandler(makeSure)
    menu:addChild(ccBtnSure)
end

function createLayer( ... )
	-- 隐藏中间
	GodWeaponCopyMainLayer.setMiddleItemVisible(false)

	_bgLayer = CCLayerColor:create(ccc4(0,0,0, 200))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBackGround()

	return _bgLayer
end

function showLayer(p_type)
	init()

	_openBoxType = p_type
	_rewardInfo = GodWeaponCopyData.getRewardInfo()

	createLayer()

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,100,1500)
end
