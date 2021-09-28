-- Filename：	ReceiveInviteLayer.lua
-- Author：		zhz
-- Date：		2013-3-17
-- Purpose：		邀请其他玩家的layer

module ("ReceiveInviteLayer", package.seeall)

require "script/ui/teamGroup/TeamGroupData"
require "script/ui/teamGroup/ReceiveInviteCell"
require "script/ui/tip/AnimationTip"

local _receiveLayer
local _inviteBg
local _myTableViewSp
local _myTableView
local _closeDelegate
-- local _noTeamLabel


local function init(  )
	_receiveLayer = nil
	_inviteBg= nil
	_myTableViewSp= nil
	_myTableView= nil
	-- _noTeamLabel= nil
end


local function layerTouch( eventType,x,y)
	return true
end

-- 
function showLayer( closeDelegate , touchProperty, zOrder)
	init()

	if(TeamGroupData.hasInviteMem()== false) then
		return
	end

	TeamGroupData.setIsNewInvited(false)

	local callBack = function ( ... )
		--TeamGroupData.getOnlineGuildInviteMem()方法：
		--根据在线队伍信息和收到的邀请队伍信息，筛选得出在线的邀请信息，并将收到的邀请队伍信息重置为空
		_inviteListInfo = TeamGroupData.getOnlineGuildInviteMem()

		if( table.isEmpty(_inviteListInfo) ) then 
			AnimationTip.showTip(GetLocalizeStringBy("key_3360"))

			if closeDelegate ~= nil then
				--移除主界面的邀请信息按钮
				closeDelegate()
			end
		else
			createLayer(closeDelegate , touchProperty, zOrder)
		end
	end
	require "script/ui/teamGroup/TeamGruopService"
	--获取在线队伍信息
 	TeamGruopService.getOnlineTeamInfo(callBack)
end

-- 
function createLayer( closeDelegate,touchProperty, zOrder)

	_closeDelegate= closeDelegate

	_touchProperty= touchProperty or -551
    _zOrder= zOrder or 900
    
   	_receiveLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_receiveLayer:registerScriptTouchHandler(layerTouch,false,_touchProperty,true)
	_receiveLayer:setTouchEnabled(true)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_receiveLayer,1000,900)

    local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _inviteBg= CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
    _inviteBg:setContentSize(CCSizeMake(640,828))
    _inviteBg:setScale(g_fElementScaleRatio)
    _receiveLayer:addChild(_inviteBg,11)
    _inviteBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _inviteBg:setAnchorPoint(ccp(0.5,0.5))


   	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_inviteBg:getContentSize().width*0.5,_inviteBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_inviteBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1996"), g_sFontPangWa,33,2,ccc3(0x0,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3( 0xff, 0xe4, 0x0))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)


	local menu = CCMenu:create()
	menu:setTouchPriority(_touchProperty-1)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_inviteBg:addChild(menu,16)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 1))
	closeButton:setPosition(ccp(_inviteBg:getContentSize().width*0.95, _inviteBg:getContentSize().height*1.01 ))
	closeButton:registerScriptTapHandler(closeBtnCb)
	menu:addChild(closeButton)

 	local sureBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,71) ,GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 	sureBtn:setPosition(_inviteBg:getContentSize().width*0.5, 24)
 	sureBtn:setAnchorPoint(ccp(0.5,0))
 	sureBtn:registerScriptTapHandler(closeBtnCb)
 	menu:addChild(sureBtn)

 	-- require "script/ui/teamGroup/TeamGruopService"
 	-- TeamGruopService.getOnlineTeamInfo(createInviteList )
 	createInviteList()
 	

end

-- 创建邀请的List
function createInviteList(  )
	_myTableViewSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_myTableViewSp:setContentSize(CCSizeMake(578, 677))
	_myTableViewSp:setAnchorPoint(ccp(0.5, 0))
	_myTableViewSp:setPosition(_inviteBg:getContentSize().width*0.5,96)
	_inviteBg:addChild(_myTableViewSp)

	-- _inviteListInfo = TeamGroupData.getOnlineGuildInviteMem()
	-- print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	-- print_t(_inviteListInfo )


	-- _noTeamLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1105"), g_sFontPangWa , 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- _noTeamLabel:setPosition(_myTableViewSp:getContentSize().width/2, _myTableViewSp:getContentSize().height/2)
	-- _noTeamLabel:setAnchorPoint(ccp(0.5,0.5))
	-- _myTableViewSp:addChild(_noTeamLabel)
	-- _noTeamLabel:setVisible(false)

	-- if( table.isEmpty(_inviteListInfo) ) then 
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_3360"))
	-- 	_noTeamLabel:setVisible(true)
	-- end

	local cellSize= CCSizeMake(575, 213)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake( cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			a2 = ReceiveInviteCell.createCell( _inviteListInfo[a1+1], _touchProperty-2 , a1+1)
			r = a2
		elseif fn == "numberOfCells" then
			r =  #_inviteListInfo
		elseif fn == "cellTouched" then	
		elseif (fn == "scroll") then
			
		end
			return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(575, 657 ))
	_myTableView:setBounceable(true)
	_myTableView:setAnchorPoint(ccp(0, 0))
	_myTableView:setPosition(ccp(4, 3))
	_myTableView:setTouchPriority(_touchProperty -1)
	_myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_myTableViewSp:addChild(_myTableView)
end

function rfcTableView(  )

	if( _inviteBg and _receiveLayer ) then
		_inviteListInfo = TeamGroupData.getOnlineGuildInviteMem()
		local offSet = _myTableView:getContentOffset()
		_myTableView:reloadData()
		_myTableView:setContentOffset(offSet)

	end
	
end



------------------------------------------------------------[[ 回调事件]]--------------------------------------------------------------------
function closeBtnCb( tag, item)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_receiveLayer ~= nil)then
		_receiveLayer:removeFromParentAndCleanup(true)
		_receiveLayer = nil
	end
	if(_closeDelegate~= nil) then
		_closeDelegate()
	end
end






