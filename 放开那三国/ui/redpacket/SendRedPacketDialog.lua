-- Filename: SendRedPacketDialog.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 发送红包界面

module("SendRedPacketDialog" , package.seeall)

local _redPacketCountNumLabel 	= nil
local _redPacketGoldNumLabel 	= nil
local _masklayer 	 			= nil
local _priority  	 			= nil
local _runningScene  			= nil
local _leftGoldLabel 			= nil
local _editBox	   				= nil
local _maxTextNum    			= 0
local _sendType 				= 1

local function init( ... )
	_redPacketCountNumLabel = nil
	_redPacketGoldNumLabel 	= nil
	_masklayer 				= nil
	_runningScene 			= nil
	_leftGoldLabel  		= nil
	_editBox	   			= nil
	_maxTextNum     		= 20
	_sendType 				= 1
	_priority  				= -500
end

local function onTouchesHandlerMask( eventType, x, y )
	if (eventType == "began") then
		return true
	end
end

local function onNodeEventMask(event)
    if event == "enter" then
        _masklayer:registerScriptTouchHandler(onTouchesHandlerMask,false,_priority,true)
        _masklayer:setTouchEnabled(true)
    elseif eventType == "exit" then
        _masklayer:unregisterScriptTouchHandler()
    end
end
--关闭回掉
local function removeDialog( ... )
	_masklayer:removeFromParentAndCleanup(true)
	RedPacketController.getInfo(RedPacketLayer.freshUI,_sendType)
end

---------------------------------------------------------刷新BEGIN------------------------------------
--刷新红包个数
function freshRedPacketNumFunction( pNum )
	_redPacketCountNumLabel:setString(pNum)
end
--刷新红包金额
function freshRedPacketGoldNumFunction( pGoldNum )
	_redPacketGoldNumLabel:setString(pGoldNum)
end
---------------------------------------------------------刷新BEGIN------------------------------------

---------------------------------------------------------按钮回掉BEGIN------------------------------------
--发送到军团回掉
local function sendToGuildAction( ... )
	-- 判断是否有军团
	require "script/ui/guild/GuildDataCache"
	local guildId = GuildDataCache.getMineSigleGuildId()
	if(guildId == 0)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("llp_301"))
		return
	else
		_sendType = 1
		RedPacketController:sendRedPacket(removeDialog,_sendType,_redPacketGoldNumLabel,_redPacketCountNumLabel,_editBox:getString())
	end
end
--发送到世界回掉
local function sendToWorldAction( ... )
	_sendType = 2
	RedPacketController:sendRedPacket(removeDialog,_sendType,_redPacketGoldNumLabel,_redPacketCountNumLabel,_editBox:getString())
end

--选择红包个数回掉
local function chooseRedPacketNumAction()
	_editBox:setContentSize(CCSizeMake(0,0))
	require "script/ui/redpacket/ChooseCountDialog"
	local chooseCountDialog = ChooseCountDialog.createDialog()
	_masklayer:addChild(chooseCountDialog,999990)
end
--选择红包金额回掉
local function chooseRedPacketGoldNumAction()
	_editBox:setContentSize(CCSizeMake(0,0))
	require "script/ui/redpacket/ChooseGoldDialog"
	local chooseGoldCountDialog = ChooseGoldDialog.createDialog()
	_masklayer:addChild(chooseGoldCountDialog,999990)
end
---------------------------------------------------------按钮回掉BEND------------------------------------

---------------------------------------------------------创建BEGIN---------------------------------------
--创建添加屏蔽层
local function createAndAddMaskLayer()
	_masklayer =  CCLayerColor:create(ccc4(11,11,11,166))
    _masklayer:registerScriptHandler(onNodeEventMask)

    _runningScene = CCDirector:sharedDirector():getRunningScene()
    _runningScene:addChild(_masklayer,999)
end
--创建添加背景板子以及关闭按钮
local function createAndAddDialogBg()
	local dialogBgSprite = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    	  dialogBgSprite:setContentSize(CCSizeMake(620,557))
    	  dialogBgSprite:setScale(MainScene.elementScale)
    	  dialogBgSprite:setAnchorPoint(ccp(0.5,0.5))
    	  dialogBgSprite:setPosition(ccp(_masklayer:getContentSize().width * 0.5,_masklayer:getContentSize().height * 0.5))

    local title_bg = CCSprite:create("images/formation/changeformation/titlebg.png")
    	  title_bg:setAnchorPoint(ccp(0.5,0.5))
    	  title_bg:setPosition(ccp(dialogBgSprite:getContentSize().width * 0.5, dialogBgSprite:getContentSize().height - 6))
    dialogBgSprite:addChild(title_bg)

    local titleLable = CCLabelTTF:create(GetLocalizeStringBy("llp_271"), g_sFontPangWa, 33)
    	  titleLable:setColor(ccc3(0xff, 0xe4, 0x00))
    	  titleLable:setAnchorPoint(ccp(0.5, 0.5))
    	  titleLable:setPosition(ccp(title_bg:getContentSize().width * 0.5, title_bg:getContentSize().height * 0.5))
    title_bg:addChild(titleLable)

    local closeMenu = CCMenu:create()
    	  closeMenu:setPosition(ccp(0,0))
    	  closeMenu:setTouchPriority(_priority - 1)
    dialogBgSprite:addChild(closeMenu, 10)
    
    local close_btn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
    	  close_btn:setAnchorPoint(ccp(1, 1))
    	  close_btn:setPosition(dialogBgSprite:getContentSize().width + 10, dialogBgSprite:getContentSize().height + 15)
    	  close_btn:registerScriptTapHandler(removeDialog)
    closeMenu:addChild(close_btn)
    
    return dialogBgSprite
end
--创建底部两个发送按钮
local function createBottomMenu()
	local bottomMenu = CCMenu:create()
		  bottomMenu:setTouchPriority(_priority - 1)
	local sendToGuildItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  sendToGuildItem:setAnchorPoint(ccp(0, 0))
		  sendToGuildItem:setPosition(ccp(0, 0))
		  sendToGuildItem:registerScriptTapHandler(sendToGuildAction)
	bottomMenu:addChild(sendToGuildItem)
	local sendToWorldItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  sendToGuildItem:setAnchorPoint(ccp(0, 0))
		  sendToGuildItem:setPosition(ccp(sendToGuildItem:getContentSize().width+10, 0))
		  sendToGuildItem:registerScriptTapHandler(sendToWorldAction)
	bottomMenu:addChild(sendToWorldItem)
	return bottomMenu
end
--创建当前还可发**金币红包Label
local function creteLeftGoldLabel( ... )
	--三个lable拼成一个pLabelSprite
	local packetData = RedPacketData.getRedPocketData()
	local pLabelSprite = CCSprite:create()

	local frontLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_265"),g_sFontPangWa,21)
		  frontLabel:setColor(ccc3(0xff,0xf6,0x00))
		  frontLabel:setAnchorPoint(ccp(0,0))
		  frontLabel:setPosition(ccp(0,0))
	pLabelSprite:addChild(frontLabel)
	local frontLabelWidth = frontLabel:getContentSize().width

	local leftGoldNum = packetData.canSendToday

	_leftGoldLabel = CCLabelTTF:create(leftGoldNum,g_sFontPangWa,21)
	_leftGoldLabel:setColor(ccc3(0xff, 0x00, 0x00))
	_leftGoldLabel:setAnchorPoint(ccp(0,0))
	_leftGoldLabel:setPosition(ccp(frontLabel:getContentSize().width,0))
	pLabelSprite:addChild(_leftGoldLabel)
	local leftGoldLabelWidth = _leftGoldLabel:getContentSize().width

	local backLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_266"),g_sFontPangWa,21)
		  backLabel:setColor(ccc3(0xff,0xf6,0x00))
		  backLabel:setAnchorPoint(ccp(0,0))
		  backLabel:setPosition(ccp(frontLabel:getContentSize().width+_leftGoldLabel:getContentSize().width,0))
	pLabelSprite:addChild(backLabel)
	local backLabelWidth = backLabel:getContentSize().width
	local backLabelHeight = backLabel:getContentSize().heitht
	pLabelSprite:setContentSize(CCSizeMake(frontLabelWidth+leftGoldLabelWidth+backLabelWidth,backLabelHeight))
	return pLabelSprite
end
function setEditBoxContentSize( ... )
	-- body
	_editBox:setContentSize(CCSizeMake(380,60))
end
--创建输入框块
local function createEditBoxSprite()
	local editBoxSprite = CCScale9Sprite:create(CCRectMake(30, 30, 15, 15),"images/common/bg/bg_ng_attr.png")
    	  editBoxSprite:setContentSize(CCSizeMake(470,100))
    	  editBoxSprite:setAnchorPoint(ccp(0.5,0))
    
    _editBox = CCEditBox:create(CCSizeMake(380,60), CCScale9Sprite:create())
    _editBox:setAnchorPoint(ccp(0.5,0))
    _editBox:setPlaceHolder(GetLocalizeStringBy("llp_267"))
    _editBox:setPlaceholderFontColor(ccc3(0xff, 0xff, 0xff))
    _editBox:setMaxLength(_maxTextNum)
    _editBox:setReturnType(kKeyboardReturnTypeDone)
    _editBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
    _editBox:setTouchPriority(_priority -2)
    editBoxSprite:addChild(_editBox)

    local maxInputLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_268"),g_sFontPangWa,21)
    	  maxInputLabel:setColor(ccc3(0xff,0xf6,0x00))
		  maxInputLabel:setAnchorPoint(ccp(0.5,0))
		  maxInputLabel:setPosition(ccp(editBoxSprite:getContentSize().width*0.5,0))
	editBoxSprite:addChild(maxInputLabel)

	_editBox:setPosition(ccp(editBoxSprite:getContentSize().width*0.5,maxInputLabel:getContentSize().height))

    return editBoxSprite
end
--创建红包金额行块
local function createRedPacketGoldLine()
	local parentSprite = CCSprite:create()
		  parentSprite:setContentSize(CCSizeMake(620,70))

	local redPacketGoldLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_270"),g_sFontPangWa,25)
		  redPacketGoldLabel:setColor(ccc3(0xff, 0x00, 0x00))
		  redPacketGoldLabel:setAnchorPoint(ccp(0.5,0.5))
		  redPacketGoldLabel:setPosition(ccp(parentSprite:getContentSize().width*0.2,32.5))
	parentSprite:addChild(redPacketGoldLabel)

	local goldBgSprite = CCScale9Sprite:create("images/common/checkbg.png")
		  goldBgSprite:setContentSize(CCSizeMake(170, 65))
		  goldBgSprite:setAnchorPoint(ccp(0.5, 0))
		  goldBgSprite:setPosition(ccp(parentSprite:getContentSize().width*0.5, 0))
	parentSprite:addChild(goldBgSprite)

	_redPacketGoldNumLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_272"),g_sFontPangWa,25)
	_redPacketGoldNumLabel:setColor(ccc3(0xff,0xf6,0x00))
	_redPacketGoldNumLabel:setAnchorPoint(ccp(0.5,0.5))
	_redPacketGoldNumLabel:setPosition(ccp(goldBgSprite:getContentSize().width*0.5,goldBgSprite:getContentSize().height*0.5))
	goldBgSprite:addChild(_redPacketGoldNumLabel)

	local chooseGoldMenu = CCMenu:create()
		  chooseGoldMenu:setPosition(ccp(0,0))
		  chooseGoldMenu:setTouchPriority(_priority - 1)
	parentSprite:addChild(chooseGoldMenu)

	local chooseGoldMenuItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  chooseGoldMenuItem:setAnchorPoint(ccp(0.5,0))
		  chooseGoldMenuItem:setPosition(ccp(parentSprite:getContentSize().width*0.8, 0))
		  chooseGoldMenuItem:registerScriptTapHandler(chooseRedPacketGoldNumAction)
	chooseGoldMenu:addChild(chooseGoldMenuItem)

	return parentSprite
end
--创建红包个数行块
local function createRedPacketCountLine()
	local parentSprite = CCSprite:create()
		  parentSprite:setContentSize(CCSizeMake(620,70))

	local redPacketCountLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_269"),g_sFontPangWa,25)
		  redPacketCountLabel:setColor(ccc3(0xff, 0x00, 0x00))
		  redPacketCountLabel:setAnchorPoint(ccp(0.5,0.5))
		  redPacketCountLabel:setPosition(ccp(parentSprite:getContentSize().width*0.2,32.5))
	parentSprite:addChild(redPacketCountLabel)

	local countBgSprite = CCScale9Sprite:create("images/common/checkbg.png")
		  countBgSprite:setContentSize(CCSizeMake(170, 65))
		  countBgSprite:setAnchorPoint(ccp(0.5, 0))
		  countBgSprite:setPosition(ccp(parentSprite:getContentSize().width*0.5, 0))
	parentSprite:addChild(countBgSprite)

	_redPacketCountNumLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_272"),g_sFontPangWa,25)
	_redPacketCountNumLabel:setColor(ccc3(0xff,0xf6,0x00))
	_redPacketCountNumLabel:setAnchorPoint(ccp(0.5,0.5))
	_redPacketCountNumLabel:setPosition(ccp(countBgSprite:getContentSize().width*0.5,countBgSprite:getContentSize().height*0.5))
	countBgSprite:addChild(_redPacketCountNumLabel)

	local chooseCountMenu = CCMenu:create()
		  chooseCountMenu:setPosition(ccp(0,0))
		  chooseCountMenu:setTouchPriority(_priority - 1)
	parentSprite:addChild(chooseCountMenu)

	local chooseCountMenuItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  chooseCountMenuItem:setAnchorPoint(ccp(0.5, 0))
		  chooseCountMenuItem:setPosition(ccp(parentSprite:getContentSize().width*0.8, 0))
		  chooseCountMenuItem:registerScriptTapHandler(chooseRedPacketNumAction)
	chooseCountMenu:addChild(chooseCountMenuItem)

	return parentSprite
end
--总创建弹板
function createDialog()
	init()
	--创建遮罩屏蔽层
	createAndAddMaskLayer()
	--创建Dialog
	local pDialog = createAndAddDialogBg()
	--创建底层按钮
	local pClickMenu = createBottomMenu()
		  pClickMenu:setAnchorPoint(ccp(0,0))
		  pClickMenu:setPosition(ccp(pDialog:getContentSize().width*0.25,30))
	pDialog:addChild(pClickMenu)
	--创建剩余金币Label
	local leftGoldLabel = creteLeftGoldLabel()
		  leftGoldLabel:setAnchorPoint(ccp(0.5,0))
		  leftGoldLabel:setPosition(ccp(pDialog:getContentSize().width*0.5,70+50))
	pDialog:addChild(leftGoldLabel)
	--创建祝福语输入框
	local editBoxSprite = createEditBoxSprite()
		  editBoxSprite:setPosition(ccp(pDialog:getContentSize().width*0.5,70+leftGoldLabel:getContentSize().height+90))
	pDialog:addChild(editBoxSprite)
	--创建红包金额行
	local redpacketGoldLine = createRedPacketGoldLine()
		  redpacketGoldLine:setAnchorPoint(ccp(0.5,0))
		  redpacketGoldLine:setPosition(ccp(pDialog:getContentSize().width*0.5,editBoxSprite:getPositionY()+editBoxSprite:getContentSize().height+60))
	pDialog:addChild(redpacketGoldLine)
	-- --创建红包个数行
	local redPacketCountLine = createRedPacketCountLine()
		  redPacketCountLine:setAnchorPoint(ccp(0.5,0))
		  redPacketCountLine:setPosition(ccp(pDialog:getContentSize().width*0.5,redpacketGoldLine:getPositionY()+redpacketGoldLine:getContentSize().height))
	pDialog:addChild(redPacketCountLine)
	return pDialog
end
---------------------------------------------------------创建END---------------------------------------
--显示弹板
function showDialog()
	local dialog = createDialog()
	_masklayer:addChild(dialog)
end