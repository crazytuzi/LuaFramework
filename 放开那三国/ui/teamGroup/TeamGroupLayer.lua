-- Filename: TeamGroupLayer.lua
-- Author: zhz
-- Date: 2013-2-17
-- Purpose: 该文件用于: 组队战斗的UI

module ("TeamGroupLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/ui/guild/GuildDataCache"
require "script/utils/TimeUtil"
require "script/ui/guild/GuildUtil"
require "script/ui/teamGroup/TeamGroupData"
require "script/ui/teamGroup/TeamGruopService"
require "script/ui/teamGroup/TeamGroupCell"
require "script/model/user/UserModel"
require "db/DB_Stronghold"
require "script/network/PreRequest"
require "script/ui/login/LoginScene"
require "script/utils/BaseUI"
require "script/ui/teamGroup/TeamInviteLayer"
require "script/ui/common/CheckBoxItem"


local _bgLayer				= nil
local _touchProperty		= nil
local _zOrder				= nil

local _teamGroupBg			-- 面板的背景
local _limitType			--组队成员限制 1.没限制 2.成员必须属于同一阵营   3.成员必须属于同一公会
 
local _groupType 			--type:1表示创建队伍界面，2表示队长开战(即玩家为队长)，3表示加入队伍（玩家为队员）界面
local _copyTeamId	 		

local _tagCreateTeam		= 101
local _tagChat				= 102
local _tagInvite			= 103
local _tagDismiss			= 104
local _tagQuit				= 105
local _tagSequence			= 106

local _chatBtn
local _createTeamBtn
local _formationBtn
local _sequenceBtn
local _sequenceGray
local _dismissBtn
local _quitBtn

local _teamListNumLabel			-- 显示有多少部队的文字

local _myTableViewSp
local _myTableView

local _teamGroupCloseDelegate
local _netKey = "TeamGroupLayer_netBorken"
local _aftCreateDelegate		-- layer创建之后的delegate

local _autoBoxItem 			-- 玩家的人满自动开战的按钮，队长才可以点击
local _unableAutoBoxItem	    -- 队员点击的按钮，弹出提示

local _isAutoStart				-- 判断是否自动开启,1 是自动开启，0不是

local function init( )
	_bgLayer= nil
	_teamGroupBg= nil
	_touchProperty= nil
	_zOrder= nil 
	_groupType= nil

	_myTableViewSp= nil
	_myTableView= nil

	_chatBtn= nil
	_createTeamBtn= nil
	_formationBtn= nil
	_sequenceBtn= nil
	_sequenceGray= nil
	_dismissBtn= nil
	_quitBtn= nil
	_teamListNumLabel= nil
	_teamCloseDelegate= nil
	_aftCreateDelegate= nil
	_autoBoxItem     =nil
	_unableAutoBoxItem=nil
	_isAutoStart = 0 
end

function setGroupType( gruopType )
	_groupType= gruopType
end

function getGroupType( )
	return _groupType
end

local function layerToucCb(eventType, x, y)
	-- print(" layerToucCb ")
	return true
end

--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCb,false,_touchProperty,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("...................hi fanglog, ")
		if g_network_status == g_network_connected then
			TeamGruopService.leaveTeam()   --Network.rpc( leaveTeamCb, "team.enter", "team.enter", args, true)
		end
		TeamGroupData.cleanData()

		if(_teamGroupCloseDelegate~= nil and g_network_status == g_network_connected) then
			_teamGroupCloseDelegate()
		end

		LoginScene.removeObserverForNetBroken(_netKey)

	end
end


function registerTeamCloseDelegate( delegate )
	_teamGroupCloseDelegate = delegate
end

local function createItems( )
	local menuBar= CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(_touchProperty-1 )
	_teamGroupBg:addChild(menuBar)

	-- 创建队伍
	_createTeamBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_3044"),ccc3(0xfe, 0xdb, 0x1c),36,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_createTeamBtn:setPosition(_teamGroupBg:getContentSize().width*0.25, 41 )
	_createTeamBtn:setAnchorPoint(ccp(0.5,0))
	_createTeamBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(_createTeamBtn,1, _tagCreateTeam)

	-- 聊天
	_chatBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_n.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_1492"),ccc3(0xfe, 0xdb, 0x1c),36,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_chatBtn:setPosition(_teamGroupBg:getContentSize().width*0.75, 41 )
	_chatBtn:setAnchorPoint(ccp(0.5,0))
	_chatBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(_chatBtn,1,_tagChat)

	-- 出战顺序
	_sequenceBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_n.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_2347"),ccc3(0xfe, 0xdb, 0x1c),36,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_sequenceBtn:setPosition(_teamGroupBg:getContentSize().width*0.25, 20)
	_sequenceBtn:setAnchorPoint(ccp(0.5,0))
	_sequenceBtn:setVisible(false)
	menuBar:addChild(_sequenceBtn,1, _tagSequence  )
	_sequenceBtn:registerScriptTapHandler(menuAction)

	_sequenceGray= BTGraySprite:create("images/common/btn/btn_green_n.png")
	_sequenceGray:setPosition(_teamGroupBg:getContentSize().width*0.25, 20)
	_sequenceGray:setAnchorPoint(ccp(0.5,0))
	_teamGroupBg:addChild(_sequenceGray)
	local sequenceLabel= CCRenderLabel:create(GetLocalizeStringBy("key_2347"), g_sFontPangWa , 36, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	sequenceLabel:setAnchorPoint(ccp(0.5,0.5))
	sequenceLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	sequenceLabel:setPosition(_sequenceGray:getContentSize().width/2, _sequenceGray:getContentSize().height/2)
	_sequenceGray:addChild(sequenceLabel)
	_sequenceGray:setVisible(false)

	-- 解散队伍
	_dismissBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_2367"),ccc3(0xfe, 0xdb, 0x1c),36,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_dismissBtn:setPosition(_teamGroupBg:getContentSize().width*0.25, 90)
	_dismissBtn:setAnchorPoint(ccp(0.5,0))
	menuBar:addChild(_dismissBtn,1, _tagDismiss)
	_dismissBtn:setVisible(false)
	_dismissBtn:registerScriptTapHandler(menuAction)

	-- 离开队伍
	_quitBtn= LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_3252"),ccc3(0xfe, 0xdb, 0x1c),36,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_quitBtn:setPosition(_teamGroupBg:getContentSize().width*0.25, 90)
	_quitBtn:setAnchorPoint(ccp(0.5,0))
	menuBar:addChild(_quitBtn,1, _tagQuit)
	_quitBtn:setVisible(false)
	_quitBtn:registerScriptTapHandler(menuAction)

	-- 邀请队员
	_inviteBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_n.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_3321"),ccc3(0xfe, 0xdb, 0x1c),36,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))	
	_inviteBtn:setPosition(_teamGroupBg:getContentSize().width*0.75, 90)
	_inviteBtn:setAnchorPoint(ccp(0.5,0))
	_inviteBtn:setVisible(false)
	_inviteBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(_inviteBtn,1, _tagInvite)

	-- -- 邀请队员＋灰色按钮
	-- _inviteGray= BTGraySprite:create("images/common/btn/btn_green_n.png")
	-- _inviteGray:setPosition(_teamGroupBg:getContentSize().width*0.75, 92)
	-- _inviteGray:setAnchorPoint(ccp(0.5,0))
	-- _teamGroupBg:addChild(_inviteGray)
	-- local _inviteLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3321"), g_sFontPangWa , 36, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	-- _inviteLabel:setAnchorPoint(ccp(0.5,0.5))
	-- _inviteLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
	-- _inviteLabel:setPosition(_inviteGray:getContentSize().width/2, _inviteGray:getContentSize().height/2)
	-- _inviteGray:addChild(_inviteLabel)
	-- _inviteGray:setVisible(false)


	-- refreshItem()


end

-- 涮下Ui的方法
function refreshItem( )
	
	if(_groupType== 1) then
		_createTeamBtn:setVisible(true)
		_sequenceBtn:setVisible(false)
		_dismissBtn:setVisible(false)
		_sequenceGray:setVisible(false)
		_quitBtn:setVisible(false)
		_chatBtn:setPosition(_teamGroupBg:getContentSize().width*0.75, 41)
		_inviteBtn:setVisible(false)
		-- _inviteGray:setVisible(false)

	elseif(_groupType == 2) then
		_dismissBtn:setVisible(true)
		_sequenceBtn:setVisible(true)
		_sequenceGray:setVisible(false)
		_quitBtn:setVisible(false)
		_chatBtn:setVisible(true)
		_chatBtn:setPosition(_teamGroupBg:getContentSize().width*0.75, 22)
		_createTeamBtn:setVisible(false)
		_inviteBtn:setVisible(true)
		-- _inviteGray:setVisible(false)

	elseif(_groupType== 3) then
		_dismissBtn:setVisible(false)
		_sequenceBtn:setVisible(false)
		_sequenceGray:setVisible(true)
		_quitBtn:setVisible(true)
		_chatBtn:setVisible(true)
		_chatBtn:setPosition(_teamGroupBg:getContentSize().width*0.75, 22)
		_createTeamBtn:setVisible(false)	
		_inviteBtn:setVisible(true)
		-- _inviteGray:setVisible(true)
	end

	refreshAutoItem()
end

-- 创建顶部的UI
function createTopUI( )

	-- 彩色sprite
	local bgSpriteSize= _teamGroupBg:getContentSize()
	local t_sprite = CCSprite:create("images/copy/border.png")
	t_sprite:setAnchorPoint(ccp(0.5,1))
	t_sprite:setPosition(ccp(bgSpriteSize.width*0.5, bgSpriteSize.height - 13))
	_teamGroupBg:addChild(t_sprite)

	local copyInfo = TeamGroupData.getCopyInfo()
	local icon = DB_Stronghold.getDataById(tonumber(copyInfo.strongHold)).icon

	-- icon
	local potentialSprite = CCSprite:create("images/copy/ncopy/fortpotential/3.png")
	potentialSprite:setAnchorPoint(ccp(0, 1))
	potentialSprite:setPosition(ccp(27, bgSpriteSize.height - 27))
	_teamGroupBg:addChild(potentialSprite)
	-- 图片 
	local icon_sp = CCSprite:create("images/base/hero/head_icon/" ..icon)
	icon_sp:setAnchorPoint(ccp(0.5, 0.5))
	icon_sp:setPosition(ccp(potentialSprite:getContentSize().width * 0.5, potentialSprite:getContentSize().height *0.53))
	potentialSprite:addChild(icon_sp)

	-- 名称背景
    local nameBg = CCSprite:create("images/common/bg/name_bg.png" )
    nameBg:setAnchorPoint(ccp(0, 1))
    nameBg:setPosition(ccp(198, bgSpriteSize.height - 27))
    _teamGroupBg:addChild(nameBg)
    --副本名称
    local nameSpriteIcon = "images/copy/guildcopy/nameimage/" .. copyInfo.img
    -- local nameSprite = CCRenderLabel:create(copyInfo.name , g_sFontPangWa, 33, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    local nameSprite= CCSprite:create(nameSpriteIcon)
    nameSprite:setAnchorPoint(ccp(0.5,0.5))
    -- nameSprite:setColor(ccc3(0xff,0xe4,0x00))
    nameSprite:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2);
    nameBg:addChild(nameSprite)

    local sliverNum= copyInfo.silver or 0
    if(sliverNum and sliverNum>0 ) then 
	    local silverBg= CCScale9Sprite:create("images/common/bg/9s_2.png")
	    silverBg:setContentSize(CCSizeMake(154,33))
	    silverBg:setAnchorPoint(ccp(0,1))
	    silverBg:setPosition(ccp(220, bgSpriteSize.height - 72))
	    _teamGroupBg:addChild(silverBg)
	    local silverSp= CCSprite:create("images/common/coin_silver.png")
	    silverSp:setPosition(ccp(10, silverBg:getContentSize().height/2))
	    silverSp:setAnchorPoint(ccp(0,0.5))
	    silverBg:addChild(silverSp)
	    local silverNumLabel = CCRenderLabel:create(copyInfo.silver , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	    silverNumLabel:setAnchorPoint(ccp(0,0.5))
	    silverNumLabel:setPosition(50, silverBg:getContentSize().height/2)
	    silverBg:addChild(silverNumLabel)
	end

	--"协助攻击只获得副本银币奖励"
	local helpDesc = CCLabelTTF:create(GetLocalizeStringBy("zz_134"), g_sFontName, 24)
	helpDesc:setColor(ccc3(0xfe,0xdb,0x1c))
	helpDesc:setAnchorPoint(ccp(0,0))
	helpDesc:setPosition(170,bgSpriteSize.height - 135)
	_teamGroupBg:addChild(helpDesc)

    local soulNum= copyInfo.soul or 0
    if(soulNum and soulNum >0) then
    	local soulBg= CCScale9Sprite:create("images/common/bg/9s_2.png")
	    soulBg:setContentSize(CCSizeMake(154,33))
	    soulBg:setAnchorPoint(ccp(0,1))
	    soulBg:setPosition(ccp(220, bgSpriteSize.height - 112))
	    _teamGroupBg:addChild(soulBg)
	    local soulSp= CCSprite:create("images/common/icon_soul.png")
	    soulSp:setPosition(ccp(10, soulBg:getContentSize().height/2))
	    soulSp:setAnchorPoint(ccp(0,0.5))
	    soulBg:addChild(soulSp)
	    local soulNumLabel = CCRenderLabel:create(copyInfo.soul , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	    soulNumLabel:setAnchorPoint(ccp(0,0.5))
	    soulNumLabel:setPosition(50, soulBg:getContentSize().height/2)
	    soulBg:addChild(soulNumLabel)
	end
	
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(_touchProperty-1)
	_teamGroupBg:addChild(menu)

	local dropItem= CCMenuItemImage:create("images/common/btn/btn_drop/btn_drop_n.png","images/common/btn/btn_drop/btn_drop_h.png" )
	dropItem:setPosition( 497 ,bgSpriteSize.height -61)
	dropItem:setAnchorPoint(ccp(0,1))
	menu:addChild(dropItem)
	dropItem:registerScriptTapHandler(dropAction)

	_teamListNumLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1884") .. copyInfo.armyNum, g_sFontName, 24)
	_teamListNumLabel:setColor(ccc3(0x00,0xff,0x18))
	_teamListNumLabel:setPosition(dropItem:getContentSize().width/2, -20)
	_teamListNumLabel:setAnchorPoint(ccp(0.5,1))
	dropItem:addChild(_teamListNumLabel)

	-- 文本：同军团组队成员获得双倍银币
	local sliverDoubleLabel= CCRenderLabel:create(GetLocalizeStringBy("key_2682"), g_sFontPangWa, 21,1, ccc3(0x00,0x00,0x00), type_stroke)
	sliverDoubleLabel:setColor(ccc3(0xff,0xe4,0x00))
	local sliverSp= CCSprite:create("images/common/coin.png")
	local upSp= CCSprite:create("images/common/xiangshang.png")
	require "db/DB_Legion_copy"
	local rate= tonumber(DB_Legion_copy.getDataById(1).sameLogionAddSilver)/100

	local doubleLabel = CCRenderLabel:create( rate.. "%", g_sFontName,24,1, ccc3(0x00,0x00,0x00), type_stroke)
	doubleLabel:setColor(ccc3(0x00,0xff,0x18))

	local sliverDoubleNode= BaseUI.createHorizontalNode({sliverDoubleLabel ,sliverSp,upSp,doubleLabel})
	sliverDoubleNode:setAnchorPoint(ccp(0.5,0))
	sliverDoubleNode:setPosition( bgSpriteSize.width*0.46 ,bgSpriteSize.height - 187)
	_teamGroupBg:addChild(sliverDoubleNode)

end



-- 创建 显示队员的tableView
function createTableView(  )

	if(_myTableViewSp~= nil) then
		_myTableViewSp:removeFromParentAndCleanup(true)
		_myTableViewSp= nil
	end


	-- _groupType ＝= 1 时，teamInfo 为team.enter 时所有的玩家信息
	-- _groupType ＝= 2时，teamInfo 为玩家为队长，时所以的信息
	-- 当 _groupType ＝= 3时，teamInfo 为玩家为队员，时所以的信息
	local teamInfo = {}
	local gildName
	local height=114
	local viewHeight= 535
	if(_groupType ==1 ) then
		teamInfo = TeamGroupData.getLimitTeamInfo()
		height= 114
		viewHeight= 535

	elseif(_groupType == 2) then 
		height= 200
		viewHeight= 460
		-- teamInfo = TeamGroupData.getMemberInfo()
		teamInfo=TeamGroupData.getTeamListByTeamId( TeamGroupData.getLeaderId()) 
	elseif(_groupType == 3) then
		height= 200
		viewHeight= 460
		teamInfo=TeamGroupData.getTeamListByTeamId( TeamGroupData.getOwnTeamId()) 

	else 
		teamInfo = {}
	end 

	_myTableViewSp= CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	_myTableViewSp:setContentSize(CCSizeMake( 583,viewHeight))
	_myTableViewSp:setAnchorPoint(ccp(0.5,0))
	_myTableViewSp:setPosition(_teamGroupBg:getContentSize().width/2, height)
	_teamGroupBg:addChild(_myTableViewSp,11)


	if(_groupType == 1 and table.isEmpty( teamInfo)) then
		local noTeamLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2862"), g_sFontPangWa , 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		noTeamLabel:setPosition(_myTableViewSp:getContentSize().width/2, _myTableViewSp:getContentSize().height/2)
		noTeamLabel:setAnchorPoint(ccp(0.5,0.5))
		_myTableViewSp:addChild(noTeamLabel)
	end
	
	local cellSize= CCSizeMake(575, 210)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake( cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then
			a2 = TeamGroupCell.createCell(teamInfo[a1+1],  a1+1, #teamInfo, _groupType , _touchProperty-1)
			r = a2
		elseif fn == "numberOfCells" then
			r =  #teamInfo
		elseif fn == "cellTouched" then		
		elseif (fn == "scroll") then
			
		end
			return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(575, viewHeight-20 ))
	_myTableView:setBounceable(true)
	_myTableView:setAnchorPoint(ccp(0, 0))
	_myTableView:setPosition(ccp(4, 3))
	_myTableView:setTouchPriority(_touchProperty -1)
	_myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_myTableViewSp:addChild(_myTableView)

end

-- 创建UI, 主要时网络回调后的Ui
function createUI( )
	-- createTableView()
	createTopUI()
end

-- 创建自动开始按钮 ， 勾选后若玩家队伍人满则自动开战，只有队长可勾选，
--其他队员的勾选项显灰，点击后提示“只有队长可以勾选自动开战”。
local function createAutoItem( )

	-- if()

	local menu= CCMenu:create()
	menu:setPosition(0,0)
	menu:setTouchPriority(_touchProperty -1)
	_teamGroupBg:addChild(menu)

	local height= 160

	_autoBoxItem= CheckBoxItem.create()
	_autoBoxItem:setPosition(237,height)
	_autoBoxItem:setAnchorPoint(ccp(0,0))
	_autoBoxItem:registerScriptTapHandler(autoAction)
	menu:addChild(_autoBoxItem)

	local grayBoxSprite= BTGraySprite:create("images/common/checkbg.png")
	_unableAutoBoxItem= CCMenuItemSprite:create(grayBoxSprite, grayBoxSprite)
	_unableAutoBoxItem:setPosition(237,height)
	_unableAutoBoxItem:registerScriptTapHandler(unableAutoAction)
	menu:addChild(_unableAutoBoxItem)

	_autoDescLabel= CCRenderLabel:create(GetLocalizeStringBy("key_4011"), g_sFontPangWa , 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_autoDescLabel:setColor(ccc3(0xff,0xf6,0x00))
	_autoDescLabel:setAnchorPoint(ccp(0,0.5))
	_autoDescLabel:setPosition( 245+ _autoBoxItem:getContentSize().width,height+_autoBoxItem:getContentSize().height/2 )
	_teamGroupBg:addChild(_autoDescLabel)
	refreshAutoItem()


end

function refreshAutoItem( )
	if(_groupType==1 ) then
		_autoBoxItem:setVisible(false)
		_unableAutoBoxItem:setVisible(false)
	elseif(_groupType==2) then
		_autoBoxItem:setVisible(true)
		_unableAutoBoxItem:setVisible(false)
	else
		_autoBoxItem:setVisible(false)
		_unableAutoBoxItem:setVisible(true)
	end
end

-- 创建队伍之后得UI涮新
function rfcAftCreateTeam( )
	_groupType= 2
	TeamGroupData.setIsleader(true)
	TeamGroupData.setLeaderId(UserModel.getUserUid())
	TeamGroupData.setOwnTeadId(UserModel.getUserUid())
	TeamGroupData.initTeamLeaderInfo()

	createTableView()
	refreshItem()

end

-- 加入时的UI刷新
function rfcAftJoin( )
	
	_groupType =3
	refreshItem()
	TeamGroupData.setIsleader(false)
end

-- 离开队伍后的UI刷新
function rfcAftQuit( )
	
	_groupType=1
	refreshItem()
end

-- 解散队伍后的UI刷新
function rfcAftDismiss( ... )
	--added by zhangqiang
	--已经向服务器发送解散队伍请求，服务器中该组数据已清除，不需要调用 TeamGruopService.setAutoStart(callBackFunc, isAutoStart )，调用则报错
	_isAutoStart = 0
	_autoBoxItem:unselected()

	refreshItem()
end

-- 展示layer
function showLayer( copyteam_id, limitType,gruopType ,touchProperty, zOrder , delegate)

	init()
	_aftCreateDelegate = delegate
	_bgLayer= CCLayerColor:create(ccc4(11,11,11,166))

	_touchProperty = touchProperty or -400
	_zOrder = zOrder or 1000

	_limitType= limitType or 1
	_groupType= gruopType or 1
	_copyTeamId= copyteam_id
	TeamGroupData._copyId= _copyTeamId
	TeamGroupData._limitType = _limitType

	_bgLayer:registerScriptHandler(onNodeEvent)
	local scene = CCDirector:sharedDirector():getRunningScene()
 	scene:addChild( _bgLayer,_zOrder)


 	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(635,853)

	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _teamGroupBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _teamGroupBg:setContentSize(mySize)
    _teamGroupBg:setScale(myScale)
    _teamGroupBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _teamGroupBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_teamGroupBg)

    local menu= CCMenu:create()
    menu:setPosition(0,0)
    menu:setTouchPriority(_touchProperty-1)
    _teamGroupBg:addChild(menu,11)

    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.01,mySize.height*1.01))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn,11)

    -- createLeftNum()

    -- if(_groupType ==1) then
    	TeamGruopService.getTeamInfo( function ( ... )
    		getTeamInfoCB()
    	end, copyteam_id )
   	--end

   	createItems()
   	createTopUI()
   	createAutoItem()
   	PreRequest.registerTeamBattleDelegate(closeCb)
   	LoginScene.addObserverForNetBroken(_netKey, closeCb)

end

local function createInviteLayer(  )
	TeamInviteLayer.showInviteLayer( _touchProperty-4, _zOrder +4)
end


 ----------------------------------------------------------  按钮事件得回调 和网络回调函数 -------------------------

function menuAction( tag,item )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(tag== _tagCreateTeam ) then
		TeamGruopService.createTeam(rfcAftCreateTeam, _copyTeamId,_limitType )

	elseif(tag== _tagChat ) then

		require "script/ui/chat/ChatMainLayer"
        ChatMainLayer.showChatLayer(3,-420, 1010)

    -- 邀请
	elseif( tag== _tagInvite) then

		createInviteLayer()
		-- TeamGruopService.getGuildInviteInfo( createInviteLayer ,_copyTeamId )  

	elseif(tag==  _tagDismiss) then
		TeamGruopService.dismissTeam(rfcAftDismiss )  


	elseif(tag == _tagSequence) then
		require "script/ui/teamGroup/TeamChangeLayer"	
		local touchProperty= _touchProperty-4
		TeamChangeLayer.showChangeTeamLayer(touchProperty, _zOrder+10)
	elseif(tag == _tagQuit) then
		TeamGruopService.quit(rfcAftDismiss)  
	end

end


function getTeamInfoCB(  )
	createTableView()
	if(_aftCreateDelegate~= nil) then
		_aftCreateDelegate()
	end

end


-- 关闭按钮的回调函数
function closeCb()

	if(_bgLayer~= nil) then
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
	end
end


function dropAction( )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/teamGroup/VictoryDropLayer"
	local items=  TeamGroupData.getCopyItems()
	print_t(items)

	VictoryDropLayer.showLayer(items, _touchProperty-1, _zOrder+1)
end

-- 自动开始的按钮回调函数
function autoAction( tag, item)	
	--刷新状态与后端同步
	local function selectedCb()
		_isAutoStart= 1
		item:selected()
	end

	local function unselectedCb()
		_isAutoStart= 0
		item:unselected()
	end

	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(_isAutoStart== 0) then 
		-- _isAutoStart= 1
		-- item:selected()
		--TeamGruopService.setAutoStart(nil, _isAutoStart)
		TeamGruopService.setAutoStart(selectedCb, 1)
	elseif(_isAutoStart ==1) then
		-- _isAutoStart= 0
		-- item:unselected()
		--TeamGruopService.setAutoStart(nil, _isAutoStart)
		TeamGruopService.setAutoStart(unselectedCb, 0)
	end	
end

-- 队员点击时的弹出
function unableAutoAction( )

	AnimationTip.showTip(GetLocalizeStringBy("key_4010"))
end

