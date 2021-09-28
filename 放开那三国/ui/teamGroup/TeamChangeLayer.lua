-- Filename：	TeamChangeLayer.lua
-- Author：		zhz
-- Date：		2013-2-19
-- Purpose：		更换队形

module("TeamChangeLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/ui/teamGroup/TeamGroupData"
require "script/model/user/UserModel"
require "script/ui/teamGroup/TeamChangeCell"


local _bgLayer= nil
local _formationbg				-- 组队变化的背景
local _myTableViewSp			-- 显示军团组队的背景
local _memberInfo


local function init( )

	_bgLayer= nil
	_formationbg = nil
	_myTableViewSp= nil
	_memberInfo= {}
end

local function layerToucCb(eventType, x, y)
	return true
end


-- 显示布阵的layer,
function showChangeTeamLayer(touchProperty, zOrder )
	
	init()

	_bgLayer= CCLayer:create()
	_touchProperty = touchProperty or -658
	_zOrder = zOrder or 650
	_bgLayer:registerScriptTouchHandler(layerToucCb,false,_touchProperty,true)
	_bgLayer:setTouchEnabled(true)

	local scene = CCDirector:sharedDirector():getRunningScene()
 	scene:addChild( _bgLayer,_zOrder)

 	local myScale =g_fElementScaleRatio --MainScene.elementScale
	local mySize = CCSizeMake(635,829)

	local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _formationbg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _formationbg:setContentSize(mySize)
    _formationbg:setScale(myScale)
    _formationbg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _formationbg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_formationbg)

    local menu= CCMenu:create()
    menu:setPosition(0,0)
    menu:setTouchPriority(_touchProperty-1)
    _formationbg:addChild(menu)

    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.01,mySize.height*1.05))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn,11)

    local sureBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200,71),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),36,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    sureBtn:setPosition(_formationbg:getContentSize().width/2,24)
    sureBtn:setAnchorPoint(ccp(0.5,0))
    sureBtn:registerScriptTapHandler(closeCb)
    menu:addChild(sureBtn)

    createTableView()

    require "script/network/PreRequest"
	PreRequest.registerTeamBattleDelegate(closeCb)

end


-- 创建修改队形的TableView
function createTableView( )
	
	if(_myTableViewSp~= nil) then
		_myTableViewSp:removeFromParentAndCleanup(true)
		_myTableViewSp= nil
	end

	_myTableViewSp= CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_myTableViewSp:setContentSize(CCSizeMake( 583,687))
	_myTableViewSp:setAnchorPoint(ccp(0.5,0))
	_myTableViewSp:setPosition(_formationbg:getContentSize().width/2,95)
	_formationbg:addChild(_myTableViewSp)

	_memberInfo= TeamGroupData.getTeamListByTeamId( UserModel.getUserUid())

	local teamInfo = TeamGroupData.getTeamInfo()
	print("teamInfo  is : ")
	print_t(teamInfo)
	print("   UserModel.getUserUid()  is : ", UserModel.getUserUid())
	print_t(_memberInfo)

	local cellSize= CCSizeMake(575, 170)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake( cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			a2 = TeamChangeCell.createCell(_memberInfo[a1+1], a1+1, #_memberInfo ,_touchProperty-1)
			r = a2
		elseif fn == "numberOfCells" then
			r =  #_memberInfo
		elseif fn == "cellTouched" then		
		elseif (fn == "scroll") then
			
		end
			return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(575, 687 ))
	_myTableView:setBounceable(true)
	_myTableView:setAnchorPoint(ccp(0, 0))
	_myTableView:setPosition(ccp(4, 3))
	_myTableView:setTouchPriority(_touchProperty -1)
	_myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_myTableViewSp:addChild(_myTableView)

end

-- 涮新tableView
function refreshTableView()
	-- 
	if(_bgLayer~= nil and _myTableViewSp~= nil ) then
		_memberInfo= TeamGroupData.getTeamListByTeamId( UserModel.getUserUid())
		_myTableView:reloadData()
	end
end



------------------------------------------------------  事件的回调函数 --------------------------------------

--关闭按钮的回调函数
function closeCb(tag,item)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if( _bgLayer ~= nil )then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
	end
end


