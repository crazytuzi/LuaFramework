-- Filename: SendRedPacketDialog.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 发送红包界面

module("SendPacketDialog", package.seeall)

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
	_maxTextNum     		= 14
	_sendType 				= 1
	_priority  				= -550
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

function afterRemove( pInfo )
	_editBox=nil
	_masklayer:removeFromParentAndCleanup(true)
	_masklayer = nil
	RedPacketLayer.freshUI(pInfo)
end
--关闭回掉
local function removeDialog( ... )
	require "script/ui/redpacket/RedPacketController"
	RedPacketController.getInfo(afterRemove,_sendType)
end

local function afterSend( ... )
	_editBox=nil
	_masklayer:removeFromParentAndCleanup(true)
	_masklayer = nil
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
function getStringLength( text )
	-- body
	local charsCount = 0
    local len = string.len(text)
    local i = 1
    while i <= len do
        local charFirstByte = string.byte(text, i)
        local charByteCount = 1
        if charFirstByte >= 0xfc then
            charByteCount = 6
        elseif charFirstByte >= 0xf8 then
            charByteCount = 5
        elseif charFirstByte >= 0xf0 then
            charByteCount = 4
        elseif charFirstByte >= 0xe0 then
            charByteCount = 3
        elseif charFirstByte >= 0xc0 then
            charByteCount = 2
        end
        charsCount = charsCount + 1
        i = i + charByteCount
    end
    return charsCount
end
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
		local goldNum = tonumber(_redPacketGoldNumLabel:getString())
		local countNum = tonumber(_redPacketCountNumLabel:getString())
		if(countNum==nil)then
			AnimationTip.showTip(GetLocalizeStringBy("llp_311"))
			return
		end
		if(goldNum==nil)then
			AnimationTip.showTip(GetLocalizeStringBy("llp_310"))
			return
		end
		local packetData = RedPacketData.getRedPacketData()
		if(tonumber(packetData.canSendToday)==0)then
			AnimationTip.showTip(GetLocalizeStringBy("llp_313"))
			return
		end
		_sendType = 2
		local str = ""
		if(string.len(_editBox:getText())==0)then
			str = GetLocalizeStringBy("llp_267")
		else
			if(getStringLength(_editBox:getText())>_maxTextNum)then
				_editBox:setText("")
				AnimationTip.showTip(GetLocalizeStringBy("llp_323"))
				return
			else
				str = string.gsub(_editBox:getText(), " ", "")
			end
		end
		RedPacketController.sendRedPacket(afterSend,_sendType,_redPacketGoldNumLabel:getString(),_redPacketCountNumLabel:getString(),str)
	end
end
--发送到世界回掉
local function sendToWorldAction( ... )
	local goldNum = tonumber(_redPacketGoldNumLabel:getString())
	local countNum = tonumber(_redPacketCountNumLabel:getString())
	if(countNum==nil)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_311"))
		return
	end
	if(goldNum==nil)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_310"))
		return
	end
	local packetData = RedPacketData.getRedPacketData()
	if(tonumber(packetData.canSendToday)==0)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_313"))
		return
	end
	_sendType = 1
	local str = ""
	if(string.len(_editBox:getText())==0)then
		str = GetLocalizeStringBy("llp_267")
	else
		if(getStringLength(_editBox:getText())>_maxTextNum)then
			_editBox:setText("")
			AnimationTip.showTip(GetLocalizeStringBy("llp_323"))
			return
		else
			str = string.gsub(_editBox:getText(), " ", "")
		end
	end
	RedPacketController.sendRedPacket(afterSend,_sendType,_redPacketGoldNumLabel:getString(),_redPacketCountNumLabel:getString(),str)
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
	_masklayer:addChild(chooseGoldCountDialog,999990,343)
end
---------------------------------------------------------按钮回掉BEND------------------------------------

---------------------------------------------------------创建BEGIN---------------------------------------
--创建添加屏蔽层
local function createAndAddMaskLayer()
	_masklayer =  CCLayerColor:create(ccc4(11,11,11,166))
    _masklayer:registerScriptHandler(onNodeEventMask)

    _runningScene = CCDirector:sharedDirector():getRunningScene()
    _runningScene:addChild(_masklayer,999,343)
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
	local sendToGuildItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(150, 70), GetLocalizeStringBy("llp_306"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  sendToGuildItem:setAnchorPoint(ccp(0, 0))
		  sendToGuildItem:setPosition(ccp(0, 0))
		  sendToGuildItem:registerScriptTapHandler(sendToGuildAction)
	bottomMenu:addChild(sendToGuildItem)
	local sendToWorldItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(150, 70), GetLocalizeStringBy("llp_307"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  sendToWorldItem:setAnchorPoint(ccp(0, 0))
		  sendToWorldItem:setPosition(ccp(sendToGuildItem:getContentSize().width+30, 0))
		  sendToWorldItem:registerScriptTapHandler(sendToWorldAction)
	bottomMenu:addChild(sendToWorldItem)
	return bottomMenu
end
--创建当前还可发**金币红包Label
local function creteLeftGoldLabel( ... )
	--三个lable拼成一个pLabelSprite
	require "script/ui/redpacket/RedPacketData"
	local packetData = RedPacketData.getRedPacketData()
	local pLabelSprite = CCSprite:create()

	local frontLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_265"),g_sFontPangWa,28,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		  frontLabel:setColor(ccc3(255,255,0))
		  frontLabel:setAnchorPoint(ccp(0,0))
		  frontLabel:setPosition(ccp(0,0))
	pLabelSprite:addChild(frontLabel)
	local frontLabelWidth = frontLabel:getContentSize().width

	local leftGoldNum = packetData.canSendToday

	_leftGoldLabel = CCRenderLabel:create(leftGoldNum,g_sFontPangWa,28,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
	_leftGoldLabel:setColor(ccc3(0,255,0))
	_leftGoldLabel:setAnchorPoint(ccp(0,0))
	_leftGoldLabel:setPosition(ccp(frontLabel:getContentSize().width,0))
	pLabelSprite:addChild(_leftGoldLabel)
	local leftGoldLabelWidth = _leftGoldLabel:getContentSize().width

	local backLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_266"),g_sFontPangWa,28,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		  backLabel:setColor(ccc3(255,255,0))
		  backLabel:setAnchorPoint(ccp(0,0))
		  backLabel:setPosition(ccp(frontLabel:getContentSize().width+_leftGoldLabel:getContentSize().width,0))
	pLabelSprite:addChild(backLabel)
	local backLabelWidth = backLabel:getContentSize().width
	local backLabelHeight = backLabel:getContentSize().height
	pLabelSprite:setContentSize(CCSizeMake(frontLabelWidth+leftGoldLabelWidth+backLabelWidth,backLabelHeight))
	return pLabelSprite
end
function setEditBoxContentSize( ... )
	-- body
	if(_editBox~=nil)then
		_editBox:setContentSize(CCSizeMake(380,60))
	end
end
--创建输入框块
local function createEditBoxSprite()
	local editBoxSprite = CCScale9Sprite:create(CCRectMake(30, 30, 15, 15),"images/common/bg/bg_ng_attr.png")
    	  editBoxSprite:setContentSize(CCSizeMake(470,100))
    	  editBoxSprite:setAnchorPoint(ccp(0.5,0))
    
    _editBox = CCEditBox:create(CCSizeMake(470,100), CCScale9Sprite:create())
    _editBox:setAnchorPoint(ccp(0,1))
    _editBox:setPosition(ccp(0,0))
    _editBox:setFont(g_sFontName,21)
    _editBox:setPlaceHolder(GetLocalizeStringBy("llp_267"))
    _editBox:setPlaceholderFontColor(ccc3(192,191, 189))
    _editBox:setMaxLength(28)
    -- _editBox:setReturnType(kKeyboardReturnTypeDone)
    _editBox:setInputFlag (kEditBoxInputModeSingleLine)
    _editBox:setTouchPriority(_priority -2)
    editBoxSprite:addChild(_editBox)

    local maxInputLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_268"),g_sFontPangWa,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		  maxInputLabel:setAnchorPoint(ccp(0.5,1))
		  maxInputLabel:setPosition(ccp(editBoxSprite:getContentSize().width*0.5,0))
	editBoxSprite:addChild(maxInputLabel)

	_editBox:setPosition(ccp(0,editBoxSprite:getContentSize().height))

    return editBoxSprite
end
--创建红包金额行块
local function createRedPacketGoldLine()
	local goldBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_3.png")
		  goldBgSprite:setContentSize(CCSizeMake(250, 45))
		  goldBgSprite:setAnchorPoint(ccp(0.5, 0))

	local redPacketGoldLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_270"),g_sFontPangWa,27)
		  redPacketGoldLabel:setColor(ccc3(0xc3, 0x1c, 0x00))
		  redPacketGoldLabel:setAnchorPoint(ccp(1,0.5))	  
	goldBgSprite:addChild(redPacketGoldLabel)

	_redPacketGoldNumLabel = CCLabelTTF:create(ActiveCache.getRedPacketMinGold(),g_sFontPangWa,27)
	_redPacketGoldNumLabel:setColor(ccc3(0,0, 0))
	_redPacketGoldNumLabel:setAnchorPoint(ccp(0,0.5))
	goldBgSprite:addChild(_redPacketGoldNumLabel)

	local chooseGoldMenu = CCMenu:create()
		  chooseGoldMenu:setPosition(ccp(0,0))
		  chooseGoldMenu:setTouchPriority(_priority - 1)
	goldBgSprite:addChild(chooseGoldMenu)

	local chooseGoldMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(140, 64), GetLocalizeStringBy("llp_309"),ccc3(0xfe, 0xdb, 0x1c),27,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  chooseGoldMenuItem:setAnchorPoint(ccp(0,0.5))
		  chooseGoldMenuItem:setPosition(ccp(goldBgSprite:getContentSize().width*1.1, goldBgSprite:getContentSize().height*0.5))
		  chooseGoldMenuItem:registerScriptTapHandler(chooseRedPacketGoldNumAction)
	chooseGoldMenu:addChild(chooseGoldMenuItem)

	redPacketGoldLabel:setPosition(ccp(goldBgSprite:getContentSize().width*0.7,goldBgSprite:getContentSize().height*0.5))
	_redPacketGoldNumLabel:setPosition(ccp(goldBgSprite:getContentSize().width*0.7,goldBgSprite:getContentSize().height*0.5))
	return goldBgSprite
end
--创建红包个数行块
local function createRedPacketCountLine()
	local countBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_3.png")
		  countBgSprite:setContentSize(CCSizeMake(250, 45))
		  countBgSprite:setAnchorPoint(ccp(0.5, 0))

	local redPacketCountLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_269"),g_sFontPangWa,27)
		  redPacketCountLabel:setColor(ccc3(0xc3, 0x1c, 0x00))
		  redPacketCountLabel:setAnchorPoint(ccp(1,0.5))
	countBgSprite:addChild(redPacketCountLabel)

	_redPacketCountNumLabel = CCLabelTTF:create("1",g_sFontPangWa,27)
	_redPacketCountNumLabel:setColor(ccc3(0,0,0))
	_redPacketCountNumLabel:setAnchorPoint(ccp(0,0.5))
	countBgSprite:addChild(_redPacketCountNumLabel)

	local chooseCountMenu = CCMenu:create()
		  chooseCountMenu:setPosition(ccp(0,0))
		  chooseCountMenu:setTouchPriority(_priority - 1)
	countBgSprite:addChild(chooseCountMenu)

	local chooseCountMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(140, 64), GetLocalizeStringBy("llp_308"),ccc3(0xfe, 0xdb, 0x1c),27,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		  chooseCountMenuItem:setAnchorPoint(ccp(0, 0.5))
		  chooseCountMenuItem:setPosition(ccp(countBgSprite:getContentSize().width*1.1, countBgSprite:getContentSize().height*0.5))
		  chooseCountMenuItem:registerScriptTapHandler(chooseRedPacketNumAction)
	chooseCountMenu:addChild(chooseCountMenuItem)

	redPacketCountLabel:setPosition(ccp(countBgSprite:getContentSize().width*0.7,countBgSprite:getContentSize().height*0.5))
	_redPacketCountNumLabel:setPosition(ccp(countBgSprite:getContentSize().width*0.7,countBgSprite:getContentSize().height*0.5))

	return countBgSprite
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
	--创建祝福语输入框
	local editBoxSprite = createEditBoxSprite()
		  editBoxSprite:setPosition(ccp(pDialog:getContentSize().width*0.5,70+90))
	pDialog:addChild(editBoxSprite)
	--创建红包金额行
	local redpacketGoldLine = createRedPacketGoldLine()
		  redpacketGoldLine:setAnchorPoint(ccp(1,0))
		  redpacketGoldLine:setPosition(ccp(pDialog:getContentSize().width*0.55,editBoxSprite:getPositionY()+editBoxSprite:getContentSize().height+30))
	pDialog:addChild(redpacketGoldLine)
	-- --创建红包个数行
	local redPacketCountLine = createRedPacketCountLine()
		  redPacketCountLine:setAnchorPoint(ccp(1,0))
		  redPacketCountLine:setPosition(ccp(pDialog:getContentSize().width*0.55,redpacketGoldLine:getPositionY()+redpacketGoldLine:getContentSize().height+35))
	pDialog:addChild(redPacketCountLine)

	--创建剩余金币Label
	local leftGoldLabel = creteLeftGoldLabel()
		  leftGoldLabel:setAnchorPoint(ccp(0.5,0))
		  leftGoldLabel:setPosition(ccp(pDialog:getContentSize().width*0.5,redPacketCountLine:getPositionY()+redPacketCountLine:getContentSize().height+30))
	pDialog:addChild(leftGoldLabel)
	return pDialog
end
---------------------------------------------------------创建END---------------------------------------
--显示弹板
function showDialog()
	local dialog = createDialog()
	_masklayer:addChild(dialog)
end