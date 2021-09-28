-- FileName: WorldCarnivalBattleReportLayer.lua 
-- Author: bzx
-- Date: 2015/9/1
-- Purpose: 嘉年华战报界面

module("WorldCarnivalBattleReportLayer", package.seeall)

btimport "script/ui/world_carnival/STWorldCarnivalBattleReportLayer"


local _layer = nil
local _touchPriority = nil
local _zOrder = nil
local _reportInfo = nil
local _reportCellSize = nil

function show(p_reportInfo, p_touchPriority, p_zOrder)
	_layer = create(p_reportInfo, p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer)
end

function initData( p_reportInfo, p_touchPriority, p_zOrder )
	_reportInfo = p_reportInfo
	_touchPriority = p_touchPriority or -500
	_zOrder = p_zOrder or 300
end

function create( p_reportInfo, p_touchPriority, p_zOrder )
	initData(p_reportInfo, p_touchPriority, p_zOrder)
	_layer = STWorldCarnivalBattleReportLayer.create()
	_layer:setBgColor(ccc3(0x00, 0x00, 0x00))
	_layer:setSwallowTouch(true)
	_layer:setTouchPriority(_touchPriority)
	_layer:setTouchEnabled(true)
	loadTop()
	loadReportTableView()
	loadBtn()
	adaptive()
	return _layer
end

function loadTop( ... )
	local leftNameLabel = _layer:getMemberNodeByName("leftNameLabel")
	leftNameLabel:setString(_reportInfo.leftFighter.uname)
	leftNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(_reportInfo.leftFighter.htid)).potential))
	
	local leftServerNameLabel = _layer:getMemberNodeByName("leftServerNameLabel")
	leftServerNameLabel:setString(_reportInfo.leftFighter.server_name)

	local rightNameLabel = _layer:getMemberNodeByName("rightNameLabel")
	rightNameLabel:setString(_reportInfo.rightFighter.uname)
	rightNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(_reportInfo.rightFighter.htid)).potential))
	
	local rightServerNameLabel = _layer:getMemberNodeByName("rightServerNameLabel")
	rightServerNameLabel:setString(_reportInfo.rightFighter.server_name)
	
	local vsSprite = _layer:getMemberNodeByName("vsSprite")
end 

-- 战报列表
function loadReportTableView( ... )
	local reportTableView = _layer:getMemberNodeByName("reportTableView")
    local reportCell = _layer:getMemberNodeByName("reportCell")
    _reportCellSize = reportCell:getContentSize()
    reportCell:removeFromParent()
    local cellCount = #_reportInfo.result
    local eventHandler = function ( functionName, tableView, index, cell )
        if functionName == "cellSize" then
            return _reportCellSize
        elseif functionName == "cellAtIndex" then
            return createReportCell(index)
        elseif functionName == "numberOfCells" then
            return cellCount
        end
    end
    reportTableView:setEventHandler(eventHandler)
    reportTableView:setTouchPriority(_touchPriority - 5)
    reportTableView:reloadData()
end

-- 战报cell
function createReportCell( p_index )
	local cell = STWorldCarnivalBattleReportLayer:createReportCell()
	cell:setPosition(ccp(0, 0))

	local cellBg = cell:getChildByName("cellBg")
	local roundBg = cellBg:getChildByName("roundBg")
	local roundLabel = roundBg:getChildByName("roundLabel")
	local roundTexts = {GetLocalizeStringBy("key_10322"), GetLocalizeStringBy("key_10323"), GetLocalizeStringBy("key_10324"), GetLocalizeStringBy("key_10325"), GetLocalizeStringBy("key_10326")}
	roundLabel:setString(roundTexts[p_index])

	local leftFighterSprite = createHeadSprite(_reportInfo.leftFighter)
	cellBg:addChild(leftFighterSprite)
	leftFighterSprite:setAnchorPoint(ccp(0.5, 0.5))
	leftFighterSprite:setPosition(ccpsprite(0.2, 0.67, cellBg))

	local rightFighterSprite = createHeadSprite(_reportInfo.rightFighter)
	cellBg:addChild(rightFighterSprite)
	rightFighterSprite:setAnchorPoint(ccp(0.5, 0.5))
	rightFighterSprite:setPosition(ccpsprite(0.8, 0.67, cellBg))

	local checkReportBtn = cellBg:getChildByName("checkReportBtn")
	local fightResult = _reportInfo.result[p_index]
	checkReportBtn:setClickCallback(checkReportCallback, fightResult.brid)
	checkReportBtn:setTouchPriority(_touchPriority - 7)

    return cell
end

function checkReportCallback( p_tag, p_btn, brid )
	require "script/battle/BattleUtil"
	BattleUtil.playerBattleReportById(brid, nil, WorldCarnivalLayer.playBgm)
end


--[[
	@des 	:得到头像
	@param 	:头像信息
	@return :创建好的Sprite和名字+服务器名字
--]]
function createHeadSprite(p_playerInfo)
	local genderId = HeroModel.getSex(p_playerInfo.htid)
	local playerSprite
	if table.isEmpty(p_playerInfo.dress) then
		playerSprite = HeroUtil.getHeroIconByHTID(p_playerInfo.htid)
	else
		playerSprite = HeroUtil.getHeroIconByHTID(p_playerInfo.htid,p_playerInfo.dress["1"],genderId)
	end
	require "db/DB_Heroes"

	local nameLabel = CCRenderLabel:create(tostring(p_playerInfo.uname),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(p_playerInfo.htid)).potential))
	nameLabel:setAnchorPoint(ccp(0.5,1))
	nameLabel:setPosition(ccp(playerSprite:getContentSize().width/2,-5))
	playerSprite:addChild(nameLabel)

	local serverLabel = CCRenderLabel:create("(" .. p_playerInfo.server_name .. ")",g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	serverLabel:setColor(ccc3(0xff,0xff,0xff))
	serverLabel:setAnchorPoint(ccp(0.5,1))
	serverLabel:setVisible(not _inner)
	serverLabel:setPosition(ccp(nameLabel:getContentSize().width/2,-5))
	nameLabel:addChild(serverLabel)

	return playerSprite
end

-- 按钮
function loadBtn( ... )
	local closeBtn = _layer:getMemberNodeByName("closeBtn")
	closeBtn:setClickCallback(closeCallback)
	closeBtn:setTouchPriority(_touchPriority - 10)

	local confirmBtn = _layer:getMemberNodeByName("confirmBtn")
	confirmBtn:setClickCallback(closeCallback)
	confirmBtn:setTouchPriority(_touchPriority - 10)
end

-- 关闭
function closeCallback( ... )
	_layer:removeFromParent()
end

-- 适配
function adaptive( ... )
	local bgSprite = _layer:getMemberNodeByName("bgSprite")
	bgSprite:setScale(MainScene.elementScale)
end

