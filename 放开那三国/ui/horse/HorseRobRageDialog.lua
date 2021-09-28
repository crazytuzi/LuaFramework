-- Filename：	HorseRobRageDialog.lua
-- Author：		LLP
-- Date：		2016-4-8
-- Purpose：		信息

module ("HorseRobRageDialog", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/utils/BaseUI"
require "db/DB_Normal_config"
require "script/ui/tip/SingleTip"
require "script/utils/LuaUtil"
require "db/DB_Vip"
require "script/libs/LuaCCSprite"
require "script/libs/LuaCCLabel"
----------------------------------
local kRobTag 				= 101
local _bgLayer 				= nil	
local _horseInfor 			= nil
local _horseItem 			= nil
local _chooseRage 			= false
local _rewardData           = {}
local _layer_touch_priority = -450
------------------------------------------
local horseColorTable = {ccc3(0, 0xeb, 0x21),ccc3(0x51, 0xfb, 0xff),ccc3(255, 0, 0xe1),ccc3(255, 0x84, 0)}
local titleTable = {GetLocalizeStringBy("llp_370"),GetLocalizeStringBy("llp_371")}
local horseNameTable = {GetLocalizeStringBy("llp_361"),GetLocalizeStringBy("llp_362"),GetLocalizeStringBy("llp_363"),GetLocalizeStringBy("llp_364")}
-- 初始化
local function init( )
	_chooseRage 			= false
	_horseItem 				= nil
	_horseInfor 			= nil
	_bgLayer 				= nil
    _rewardData             = {}
end

-- create
function create()
	local bgLayerSize = _bgLayer:getContentSize()
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		return true
    elseif (eventType == "moved") then
	
    else
    	
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -1002, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
function closeAction( tag, itembtn )
    if(_bgLayer~=nil)then
    	require "script/audio/AudioUtil"
    	AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end 

function chooseMenuItemCallback( tag, itemBtn )
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if (itemBtn.isSelected) then
		itemBtn.isSelected = false
		itemBtn:unselected()
		_chooseRage = false
	else
        local dbInfo = DB_Mnlm_rule.getDataById(1)
        local costData = string.split(dbInfo.rage_cost,"|")
        if(tonumber(costData[2])>UserModel.getGoldNumber())then
            LackGoldTip.showTip(-5000)
            return
        end
		itemBtn.isSelected = true
		itemBtn:selected()
		_chooseRage = true
	end
end

function callbackConfirm( ... )
	-- body
	HorseController.rob(_horseInfor.uid,_chooseRage,_rewardData)
	closeAction()
end

--
local function createUI()
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local bgSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
    bgSprite:setPreferredSize(CCSizeMake(515, 337))

	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.45))
	bgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(bgSprite)

	local richInfo = {}
    richInfo.alignment = 2
    richInfo.labelDefaultSize = 25
    local str = GetLocalizeStringBy("llp_398").."[".._horseInfor.uname.."]"..GetLocalizeStringBy("llp_399")..horseNameTable[tonumber(_horseInfor.stage_id)]..GetLocalizeStringBy("llp_400")
    local sizeLable = CCLabelTTF:create(str,g_sFontName,25)
    if(sizeLable:getContentSize().width>500)then
        richInfo.width = 450
    else
        richInfo.width = sizeLable:getContentSize().width
    end
    richInfo.elements = 
    {
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("llp_398"),
            color = ccc3(0x78,0x25,0x00)
        },
        {
            type = "CCRenderLabel",
            text = "[".._horseInfor.uname.."]",
            font = g_sFontPangWa,
            color = ccc3(0, 0xeb, 0x21)
        },
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("llp_399"),
            color = ccc3(0x78,0x25,0x00)
        },
        {
            type = "CCRenderLabel",
            text = horseNameTable[tonumber(_horseInfor.stage_id)],
            color = horseColorTable[tonumber(_horseInfor.stage_id)]
        },
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("llp_400"),
            color = ccc3(0x78,0x25,0x00)
        },
    }
    require "script/libs/LuaCCLabel"
    local richLabel = LuaCCLabel.createRichLabel(richInfo)
    	  richLabel:setAnchorPoint(ccp(0.5,1))
    	  richLabel:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.8))
    bgSprite:addChild(richLabel)



    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-1002 - 1)

	-- 创建选择按钮1
	local chooseMenuItem1 = CCMenuItemImage:create("images/common/duigou_n.png","images/common/duigou_h.png")
	chooseMenuItem1:setAnchorPoint(ccp(0.5, 0.5))
	chooseMenuItem1:setPosition(ccp(bgSprite:getContentSize().width*0.3,bgSprite:getContentSize().height*0.5))
	closeMenuBar:addChild(chooseMenuItem1,1,1)
	chooseMenuItem1:registerScriptTapHandler(chooseMenuItemCallback)
	chooseMenuItem1.isSelected = false

	require "db/DB_Mnlm_rule"
    local dbInfo = DB_Mnlm_rule.getDataById(1)
    local costData = string.split(dbInfo.rage_cost,"|")

	local richInfo = {}
    richInfo.width = 500
    richInfo.alignment = 1
    richInfo.labelDefaultSize = 25
    richInfo.elements = 
    {
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("llp_432"),
            color = ccc3(0x78,0x25,0x00)
        },
        {
            type = "CCRenderLabel",
            text = costData[2],
            color = ccc3(0xff,0xf6,0x00)
        },
        {
            type = "CCSprite",
            newLine = false,
            image = "images/common/gold.png" 
        },
        {
            type = "CCLabelTTF",
            text = GetLocalizeStringBy("llp_401"),
            color = ccc3(0x78,0x25,0x00)
        },
        
    }
    require "script/libs/LuaCCLabel"
    local richLabel = LuaCCLabel.createRichLabel(richInfo)
    	  richLabel:setAnchorPoint(ccp(0,0.5))
    	  richLabel:setPosition(ccp(chooseMenuItem1:getContentSize().width,chooseMenuItem1:getContentSize().height*0.5))
    chooseMenuItem1:addChild(richLabel)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.97, bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(closeAction)

	local confirm_btn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_8022"),ccc3(255,222,0))
    closeMenuBar:addChild(confirm_btn)
    confirm_btn:setAnchorPoint(ccp(0.5,0.5))
    confirm_btn:setPosition(ccp(bgSprite:getContentSize().width*0.3, 80))
    confirm_btn:registerScriptTapHandler(callbackConfirm)

    local cancel_btn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("key_8023"),ccc3(255,222,0))
    closeMenuBar:addChild(cancel_btn)
    cancel_btn:setAnchorPoint(ccp(0.5,0.5))
    cancel_btn:setPosition(ccp(bgSprite:getContentSize().width*0.7, 80))
    cancel_btn:registerScriptTapHandler(closeAction)
end

function show(pData,pRewardData)
    local pLayer = createLayer(pData,pRewardData)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(pLayer,1000)
end

-- create
function createLayer(pData,pRewardData)
	init()
    _rewardData = pRewardData
	_horseInfor = pData
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	createUI()

	return _bgLayer
end