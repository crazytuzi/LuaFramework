-- Filename：	HorseTeamInfoDialog.lua
-- Author：		llp
-- Date：		2016-4-7
-- Purpose：		邀请其他玩家的layer

module ("HorseTeamInfoDialog", package.seeall)

require "script/ui/horse/HorseTeamInfoCell"
	
local _bgLayer 					= nil
local _touchProperty
local _zOrder
local _inviteBg				
local _myTableViewSp		
local _inviteMemberInfo 		= nil
local _uid 

local function init()
	_bgLayer				= nil
	_touchProperty			= nil
	_zOrder					= nil
	_inviteBg				= nil
	_myTableViewSp			= nil
	_inviteMemberInfo 		= nil
	_uid 					= nil
end

function layerTouch(eventType, x, y)
    return true   
end


--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerTouch,false,_touchProperty,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
	end
end

function showInviteLayer( touchProperty, zOrder, pUid)
	
	init()
	_uid = tonumber(pUid)
	_touchProperty= touchProperty or -551
    _zOrder= zOrder or 655

    _bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
	_bgLayer:registerScriptHandler(onNodeEvent)

	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _inviteBg= CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
    _inviteBg:setContentSize(CCSizeMake(640,578))
    _inviteBg:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(_inviteBg)
    _inviteBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _inviteBg:setAnchorPoint(ccp(0.5,0.5))

    -- 按钮
	local menu = CCMenu:create()
	menu:setTouchPriority(touchProperty-1)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_inviteBg:addChild(menu,16)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 1))
	closeButton:setPosition(ccp(_inviteBg:getContentSize().width*0.95, _inviteBg:getContentSize().height*1.03 ))
	closeButton:registerScriptTapHandler(closeBtnCb)
	menu:addChild(closeButton)

 	local sureBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,71) ,GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 	sureBtn:setPosition(_inviteBg:getContentSize().width*0.5, 24)
 	sureBtn:setAnchorPoint(ccp(0.5,0))
 	sureBtn:registerScriptTapHandler(closeBtnCb)
 	menu:addChild(sureBtn)

 	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_inviteBg:getContentSize().width*0.5,_inviteBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_inviteBg:addChild(titleBg)

	--标题
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("llp_388"), g_sFontPangWa,33,2,ccc3(0x0,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3( 0xff, 0xe4, 0x0))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

 	createTableView()
end

function createTableView()
	_inviteMemberInfo = HorseData.getTeamInfo()
 	_myTableViewSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_myTableViewSp:setContentSize(CCSizeMake(578, 450))
	_myTableViewSp:setAnchorPoint(ccp(0.5, 0))
	_myTableViewSp:setPosition(_inviteBg:getContentSize().width*0.5,96)
	_inviteBg:addChild(_myTableViewSp)

	_noTeamLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1500"), g_sFontPangWa , 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_noTeamLabel:setPosition(_myTableViewSp:getContentSize().width/2, _myTableViewSp:getContentSize().height/2)
	_noTeamLabel:setAnchorPoint(ccp(0.5,0.5))
	_myTableViewSp:addChild(_noTeamLabel)
	_noTeamLabel:setVisible(false)

	if( table.isEmpty( _inviteMemberInfo)) then
		_noTeamLabel:setVisible(true)
	end

	local cellSize= CCSizeMake(575, 213)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake( cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			_inviteMemberInfo[a1+1].lookuid = _uid
			a2 = HorseTeamInfoCell.createCell( _inviteMemberInfo[a1+1], _touchProperty-2, a1+1 )
			r = a2
		elseif fn == "numberOfCells" then
			r =  #_inviteMemberInfo
		elseif fn == "cellTouched" then	
		elseif (fn == "scroll") then
			
		end
			return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(575, 446 ))
	_myTableView:setBounceable(true)
	_myTableView:setAnchorPoint(ccp(0, 0))
	_myTableView:setPosition(ccp(4, 3))
	_myTableView:setTouchPriority(_touchProperty -1)
	_myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_myTableViewSp:addChild(_myTableView)

	print("_myTableView:getContentOffset().y is  ", _myTableView:getContentOffset().y)	
end

-- 刷新对应的tableView
function rfcTableView(  )
	_inviteMemberInfo= HorseData.getTeamInfo()

	_myTableView:reloadData()

	if(table.isEmpty( _inviteMemberInfo)) then
		_noTeamLabel:setVisible(true)
	else
		_noTeamLabel:setVisible(false)
	end

end

---------------------------------------------------[[ 回调函数]]------------------------------------------------------------
-- 关闭按钮的回调函数
function closeBtnCb(  )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer ~= nil)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end