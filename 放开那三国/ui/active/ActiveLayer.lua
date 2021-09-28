-- Filename：	ActiveLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-3
-- Purpose：		活动

module ("ActiveLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/ui/arena/AfterBattleLayer"
require "script/ui/bag/UseItemLayer" 

local _bgLayer 			= nil
local _refeshBg 		= nil
local _enemyRefreshBg 	= nil
local _curButton 	= nil
-- 比武
local matchBtn 		= nil
-- 仇人
local enemyBtn 		= nil
local _myTableView 	= nil

local _curData = {}

local _matchData 	= nil
local _enemyData 	= nil

-- 耐力值
local staminaNumLabel 	= nil
local e_staminaNumLabel = nil
-- 消耗耐力
local staminaMatchCostLabel	= nil
local staminaRobCostLabel	= nil
-- 对手UID
local oppUid = 0
-- 掉落
local dropInfo = {}
--按钮背景
local btnFrameSp = nil


-- 初始化
local function init( )
	_bgLayer 	 	= nil
	_refeshBg 	 	= nil
	_curButton 	 	= nil
	matchBtn 	 	= nil
	enemyBtn		= nil
	_myTableView 	= nil
	_curData	 	= {}
	_matchData 		= nil
	_enemyData 		= nil
	staminaMatchCostLabel = nil
	staminaRobCostLabel	= nil
	oppUid = 0
	dropInfo = {}
	btnFrameSp = nil
end 

-- 返回
local function backAction(tag, itembtn)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/active/ActiveList"
	local activeListr = ActiveList.createActiveListLayer()
	MainScene.changeLayer(activeListr, "activeListr")
	
end

-- 标签按钮
function matchRobAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	if (_curButton ~= itemBtn) then
		_curButton:unselected()
		_curButton = itemBtn
		_curButton:selected()
		if(_curButton == matchBtn) then
			_curData = _matchData
			-- _myTableView:reloadData()
			createTableView()
			_refeshBg:setVisible(true)
			_enemyRefreshBg:setVisible(false)
		elseif(_curButton == enemyBtn) then
			_curData = _enemyData
			if( table.isEmpty(_curData)) then
				RequestCenter.star_getFoeList(refreshEnemyListCallback, nil)
			else
				-- _myTableView:reloadData()
				createTableView()
			end
			_refeshBg:setVisible(false)
			_enemyRefreshBg:setVisible(true)
		end
		
	end
end

-- 获得仇人列表
function refreshEnemyListCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		_enemyData = {}
		
		if( not table.isEmpty(dictData.ret.foeList))then
			for t_uid, t_userinfo in pairs(dictData.ret.foeList) do
				t_userinfo.uid = t_uid
				table.insert(_enemyData, t_userinfo)
			end
		end
		
		_curData = _enemyData
		-- _myTableView:reloadData()
		createTableView()

	end
end

-- 刷新
local function refreshStaminaNumLabel()
	staminaNumLabel:setString( UserModel.getStaminaNumber().. "/" .. UserModel.getMaxStaminaNumber())
	e_staminaNumLabel:setString(UserModel.getStaminaNumber().. "/" .. UserModel.getMaxStaminaNumber())
	staminaMatchCostLabel:setString(costNextRob())
	staminaRobCostLabel:setString(costNextRob())
end

-- 创建刷新的底
local function createRefreshSprite ()

	local fullRect = CCRectMake(0,0,41,31)
	local insetRect = CCRectMake(15,12,11,7)
	--条件背景
	_refeshBg = CCSprite:create("images/common/bg/bottom.png")
	_refeshBg:setAnchorPoint(ccp(0.5, 0))
	_refeshBg:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height * 0.015))
	local myScale = _bgLayer:getContentSize().width/_refeshBg:getContentSize().width/_bgLayer:getElementScale()
	_refeshBg:setScale(myScale)
	_bgLayer:addChild(_refeshBg, 999)

	-- 耐力
	local staminaLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2268"), g_sFontName, 24)
	staminaLabel:setAnchorPoint(ccp(0, 0.5))
	staminaLabel:setColor(ccc3(0xff, 0xff, 0xff))
	staminaLabel:setPosition(ccp(_refeshBg:getContentSize().width* 15.0/560, _refeshBg:getContentSize().height*0.40))
    _refeshBg:addChild(staminaLabel)
    -- 耐力值
	staminaNumLabel = CCLabelTTF:create("20/50", g_sFontName, 24)
	staminaNumLabel:setAnchorPoint(ccp(0, 0.5))
	staminaNumLabel:setColor(ccc3(0x36, 0xff, 0x00))
	staminaNumLabel:setPosition(ccp(_refeshBg:getContentSize().width*75.0/560, _refeshBg:getContentSize().height*0.37))
    _refeshBg:addChild(staminaNumLabel)

    -- 比武消耗
    local matchLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1039"), g_sFontName, 24)
	matchLabel:setAnchorPoint(ccp(0, 0.5))
	matchLabel:setColor(ccc3(0xff, 0x27, 0x27))
	matchLabel:setPosition(ccp(_refeshBg:getContentSize().width*160.0/560, _refeshBg:getContentSize().height*0.40))
    _refeshBg:addChild(matchLabel)
    -- 消耗耐力
	staminaMatchCostLabel = CCLabelTTF:create("20", g_sFontName, 24)
	staminaMatchCostLabel:setAnchorPoint(ccp(0, 0.5))
	staminaMatchCostLabel:setColor(ccc3(0x36, 0xff, 0x00))
	staminaMatchCostLabel:setPosition(ccp(_refeshBg:getContentSize().width* 270.0/560, _refeshBg:getContentSize().height*0.37))
    _refeshBg:addChild(staminaMatchCostLabel)

    local matchMenuBar = CCMenu:create()
	matchMenuBar:setPosition(ccp(0, 0))
	_refeshBg:addChild(matchMenuBar)
	-- 比武
	local matchBtn = LuaCC.create9ScaleMenuItem("images/active/rob/btn_rob_n.png","images/active/rob/btn_rob_h.png",CCSizeMake(195, 70),GetLocalizeStringBy("key_3335"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontName,1, ccc3(0x00, 0x00, 0x00))
	
	matchBtn:setAnchorPoint(ccp(0, 0.5))
	matchBtn:setPosition(ccp(_refeshBg:getContentSize().width*350.0/560, _refeshBg:getContentSize().height*0.4))
	matchMenuBar:addChild(matchBtn, 2, 10001)

	matchBtn:registerScriptTapHandler(refeshUserBtnAction)

end

local function createEnemyRefreshBg()
	local fullRect = CCRectMake(0,0,41,31)
	local insetRect = CCRectMake(15,12,11,7)
	--条件背景
	_enemyRefreshBg = CCSprite:create("images/common/bg/bottom.png")
	_enemyRefreshBg:setAnchorPoint(ccp(0.5, 0))
	_enemyRefreshBg:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height * 0.015))
	local myScale = _bgLayer:getContentSize().width/_refeshBg:getContentSize().width/_bgLayer:getElementScale()
	_enemyRefreshBg:setScale(myScale)
	_bgLayer:addChild(_enemyRefreshBg, 999)
	_enemyRefreshBg:setVisible(false)

	-- 耐力
	local staminaLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2268"), g_sFontName, 24)
	staminaLabel:setAnchorPoint(ccp(0, 0.5))
	staminaLabel:setColor(ccc3(0xff, 0xff, 0xff))
	staminaLabel:setPosition(ccp(_enemyRefreshBg:getContentSize().width* 0.20, _enemyRefreshBg:getContentSize().height*0.40))
    _enemyRefreshBg:addChild(staminaLabel)
    -- 耐力值
	e_staminaNumLabel = CCLabelTTF:create("20/50", g_sFontName, 24)
	e_staminaNumLabel:setAnchorPoint(ccp(0, 0.5))
	e_staminaNumLabel:setColor(ccc3(0x36, 0xff, 0x00))
	e_staminaNumLabel:setPosition(ccp(_enemyRefreshBg:getContentSize().width*0.30, _enemyRefreshBg:getContentSize().height*0.37))
    _enemyRefreshBg:addChild(e_staminaNumLabel)

    -- 复仇消耗
    local matchLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2656"), g_sFontName, 24)
	matchLabel:setAnchorPoint(ccp(0, 0.5))
	matchLabel:setColor(ccc3(0xff, 0x27, 0x27))
	matchLabel:setPosition(ccp(_enemyRefreshBg:getContentSize().width*0.5, _enemyRefreshBg:getContentSize().height*0.40))
    _enemyRefreshBg:addChild(matchLabel)
    -- 消耗耐力
	staminaRobCostLabel = CCLabelTTF:create("20", g_sFontName, 24)
	staminaRobCostLabel:setAnchorPoint(ccp(0, 0.5))
	staminaRobCostLabel:setColor(ccc3(0x36, 0xff, 0x00))
	staminaRobCostLabel:setPosition(ccp(_enemyRefreshBg:getContentSize().width* 0.7, _enemyRefreshBg:getContentSize().height*0.37))
    _enemyRefreshBg:addChild(staminaRobCostLabel)
end

-- 创建按钮
local function createMenu( )
	
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--按钮背景
	btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 100))
	btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height))
	btnFrameSp:setScale(g_fScaleX/MainScene.elementScale)
	_bgLayer:addChild(btnFrameSp)

	local matchMenuBar = CCMenu:create()
	matchMenuBar:setPosition(ccp(0, 0))
	btnFrameSp:addChild(matchMenuBar)
	-- 比武 createMenuItemSprite( “比武”, fontSize_n, fontSize_h, fontColor_n, fontColor_h )
	-- matchBtn = LuaMenuItem.createItemImage("images/active/rob/btn_title_n.png",  "images/active/rob/btn_title_h.png", matchRobAction, nil, GetLocalizeStringBy("key_2182"), 36, ccc3(0xff, 0xe4, 0x00) )
	matchBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_2182"))
	matchBtn:setAnchorPoint(ccp(0, 0))
	matchBtn:setPosition(ccp(btnFrameSp:getContentSize().width*0.04, btnFrameSp:getContentSize().height*0.1))
	matchBtn:registerScriptTapHandler(matchRobAction)
	matchMenuBar:addChild(matchBtn, 2, 10001)
	_curButton = matchBtn
	_curButton:selected()

	-- 仇人
	enemyBtn = LuaMenuItem.createMenuItemSprite( GetLocalizeStringBy("key_1999"))
	enemyBtn:setAnchorPoint(ccp(0, 0))
	enemyBtn:setPosition(ccp(btnFrameSp:getContentSize().width*0.32, btnFrameSp:getContentSize().height*0.1))
	enemyBtn:registerScriptTapHandler(matchRobAction)
	matchMenuBar:addChild(enemyBtn, 2, 10002)

	-- 返回的按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(0, 0.5))
	closeMenuItem:registerScriptTapHandler(backAction)
	closeMenuItem:setPosition(ccp(btnFrameSp:getContentSize().width*0.8, btnFrameSp:getContentSize().height*0.5))
	matchMenuBar:addChild(closeMenuItem)

end 

function createTableView()

	if(_myTableView)then
		_myTableView:removeFromParentAndCleanup(true)
		_myTableView = nil
	end
	local cellBg = CCSprite:create("images/active/rob/bg_cell_rob.png")
	local cellSize = cellBg:getContentSize()			--计算cell大小

    local myScale = _bgLayer:getContentSize().width/cellBg:getContentSize().width/_bgLayer:getElementScale()
	
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			
			if (_curButton == matchBtn) then
				require "script/ui/active/MatchCell"
            	a2 = MatchCell.createCell(_curData[a1+1], matchActionCallback)
            elseif( _curButton == enemyBtn) then
            	require "script/ui/active/EnemyCell"
            	a2 = EnemyCell.createCell(_curData[a1+1], enemyActionCallback)
            end
           
            a2:setScale(myScale)
   
			r = a2
		elseif fn == "numberOfCells" then
			r = #_curData
		elseif fn == "cellTouched" then
			-- print("cellTouched: " .. (#curData - a1:getIdx()))
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	local bgLayerSize = _bgLayer:getContentSize()
	print("g_fScaleX===", g_fScaleX,  btnFrameSp:getContentSize().height,  _refeshBg:getContentSize().height, _bgLayer:getContentSize().height)
	-- _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width/_bgLayer:getElementScale(),_bgLayer:getContentSize().height* 775.0/960/_bgLayer:getElementScale()))
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width/_bgLayer:getElementScale(), (_bgLayer:getContentSize().height - _refeshBg:getContentSize().height*g_fScaleX - btnFrameSp:getContentSize().height*g_fScaleX)/_bgLayer:getElementScale()))
    _myTableView:setPosition(ccp(0, _refeshBg:getContentSize().height*g_fScaleX))
	_myTableView:setBounceable(true)
	-- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- _myTableView:setScale(1/_bgLayer:getElementScale())
	_bgLayer:addChild(_myTableView)
end  

-- create
function create()
	local bgLayerSize = _bgLayer:getContentSize()

----------------------------- 创建按钮 ------------------------
	createMenu()

----------------------------- 创建Tableview ------------------
	createRefreshSprite()
	createEnemyRefreshBg()

end

-- 比武完成回调
function matchActionCallback(cbFlag, dictData, bRet  )
	if(dictData.err == "ok") then
		
		-- local result_str = dictData.ret.ret
		-- if(result_str == "suc")then
		-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2703"))
		-- else
		-- 	AnimationTip.showTip(GetLocalizeStringBy("key_1955"))
		-- end
		if( not table.isEmpty(dictData.ret.robList))then
			_matchData = {}
			for t_uid, t_userinfo in pairs(dictData.ret.robList) do
				t_userinfo.uid = t_uid
				table.insert(_matchData, t_userinfo)
			end
		end
		_curData = _matchData
		-- _myTableView:reloadData()
		reduceStaminaFunc()
		createTableView()
		refreshStaminaNumLabel()
		-- local appraisal = "F"
		-- if(dictData.ret.ret and dictData.ret.ret=="suc")then
		-- 	appraisal = "S"
		-- end
		-- require "script/battle/BattleLayer"
		-- BattleLayer.showBattleWithString(dictData.ret.fightRet, doMatchBattleOverDelegate, AfterBattleLayer.createAfterBattleLayer( dictData.ret.ret, oppUid, nil, nil, false ), "ducheng.jpg")
		require "script/ui/common/CafterBattleLayer"
		BattleLayer.showBattleWithString(dictData.ret.fightRet, doMatchBattleOverDelegate, CafterBattleLayer.createAfterBattleLayer( dictData.ret.ret, oppUid,nil,nil,nil, nil,nil ), "ducheng.jpg")
		dropInfo = {}
		dropInfo.drop = dictData.ret.drop
		if(dictData.ret.exp and tonumber(dictData.ret.exp)>0)then
			dropInfo.exp = tonumber(dictData.ret.exp)
		end
	end
end

-- 复仇回调
function enemyActionCallback(cbFlag, dictData, bRet  )
	if(dictData.err == "ok") then
		_enemyData = {}
		-- local result_str = dictData.ret.ret
		-- if(result_str == "suc")then
		-- 	AnimationTip.showTip(GetLocalizeStringBy("key_3372"))
		-- else
		-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2513"))
		-- end
		reduceStaminaFunc()
		
		for t_uid, t_userinfo in pairs(dictData.ret.foeList) do
			t_userinfo.uid = t_uid
			table.insert(_enemyData, t_userinfo)
		end
		_curData = _enemyData
		-- _myTableView:reloadData()
		createTableView()
		refreshStaminaNumLabel()
		-- require "script/battle/BattleLayer"
		-- BattleLayer.showBattleWithString(dictData.ret.fightRet, doRobBattleOverDelegate, AfterBattleLayer.createAfterBattleLayer( dictData.ret.ret, oppUid, nil, nil, false ), "ducheng.jpg")
		require "script/ui/common/CafterBattleLayer"
		BattleLayer.showBattleWithString(dictData.ret.fightRet, doMatchBattleOverDelegate, CafterBattleLayer.createAfterBattleLayer( dictData.ret.ret, oppUid, nil,nil,nil, nil,nil  ), "ducheng.jpg")

		dropInfo = {}
		dropInfo.drop = dictData.ret.drop
		if(dictData.ret.exp and tonumber(dictData.ret.exp)>0)then
			dropInfo.exp = tonumber(dictData.ret.exp)
		end
	end
end

-- 刷新对手
function refreshRobListCallback( cbFlag, dictData, bRet )
	_matchData = {}
	if(dictData and dictData.err == "ok" and dictData.ret.robList) then
		for t_uid, t_userinfo in pairs(dictData.ret.robList) do
			t_userinfo.uid = t_uid
			table.insert(_matchData, t_userinfo)
		end
	end
	--print_table("_matchData", _matchData)
	_curData = _matchData
	createTableView()
	-- if(_myTableView == nil) then
	-- 	createTableView()
	-- else
	-- 	_myTableView:reloadData()
	-- end
	refreshStaminaNumLabel()
end

-- 减少
function reduceStaminaFunc()
	
	UserModel.addStaminaNumber(-costNextRob())
	
	DataCache.addRobNum(1)
end

-- 下次比武的消耗
function costNextRob()
	require "db/DB_Star_all"
	local star_all = DB_Star_all.getDataById(1)
	return (tonumber(star_all.needEndurance)+tonumber(star_all.enduranceIncrease)*DataCache.getRobNum())
end

function refeshUserBtnAction(  )
	RequestCenter.star_refreshRobList(refreshRobListCallback, nil)
end


-- 战斗结束回调
function doMatchBattleOverDelegate( ... )
	if(not table.isEmpty(dropInfo))then
		UseItemLayer.showDropResult( dropInfo.drop, 2, dropInfo.exp, true )
	end
end

function doRobBattleOverDelegate( ... )
	if(not table.isEmpty(dropInfo))then
		UseItemLayer.showDropResult( dropInfo.drop, 3, dropInfo.exp, true )
	end
end

function createLayer()
	init()
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false,true)
	RequestCenter.star_getRobList(refreshRobListCallback, nil)
	create()
	_bgLayer:runAction(seq)

	return _bgLayer
end


