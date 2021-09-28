	-- FileName: GuildRobRankList.lua
-- Author: lichenyang
-- Date: 14-11-5
-- Purpose: 军团抢粮pvp战
-- @module GuildRobRankList

module("GuildRobRankList",package.seeall)
require "script/ui/guild/guildrob/GuildRobBattleData"
require "script/ui/guild/guildrob/GuildRobBattleService"
require "script/ui/guild/guildrob/GuildAfterRobBattleLayer"
------------------------------[[ 模块常量 ]]------------------------------
local rankColor = {
	ccc3(0x00, 0xe4, 0xff),
	ccc3(192, 33, 316),
	ccc3(0x00, 0xff, 0x18),
}

------------------------------[[ 模块变量 ]]------------------------------
local _bgLayer = nil
local _layerSize = nil
local _touchPriority = nil
local _zOrder = nil
local _myKillLabel = nil
local _myRankLabel = nil
local _showButton = nil
local _hiddenButton = nil
local _rankInfo = nil
local _rankTable = nil
function init( ... )
	_bgLayer = nil
	_layerSize = nil
	_touchPriority = nil
	_zOrder = nil
	_myKillLabel = nil
	_myRankLabel = nil
	_showButton = nil
	_hiddenButton = nil
	_rankInfo = nil
	_rankTable = nil
end

-------------------------------[[ ui 创建方法 ]]---------------------------
function show( p_touchPriority,  p_zOrder, p_parentLayer)
	init()
	_bgLayer = p_parentLayer
	_touchPriority 	= p_touchPriority or -400
	_zOrder			= p_zOrder or 1
	--数据
	createRankList()
	GuildRobBattleService.registerPushTopN(topNPushCallback)			--军团pvp战斗结束推送
	return _bgLayer
end

--[[
	@des : 创建服务器列表
--]]
function createRankList( ... )
	_rankInfo = GuildRobBattleData.getRankInfo()
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	_bgLayer:addChild(menu, _zOrder + 10)
	menu:setTouchPriority(-_touchPriority-10)

	_showButton = CCMenuItemImage:create("images/guild_rob/rank_btn_n.png", "images/guild_rob/rank_btn_h.png")
	_showButton:setAnchorPoint(ccp(1, 0.5))
	_showButton:setPosition(ccps(1, 0.5))
	_showButton:registerScriptTapHandler(showServerButtonCallback)
	menu:addChild(_showButton)
	_showButton:setScale(MainScene.elementScale)

	_hiddenButton = CCMenuItemImage:create("images/star/btn_hidden_n.png", "images/star/btn_hidden_h.png")
	_hiddenButton:setAnchorPoint(ccp(1, 0.5))
	_hiddenButton:setPosition(ccps(1, 0.5))
	_hiddenButton:registerScriptTapHandler(hiddenServerButtonCallback)
	menu:addChild(_hiddenButton)
	_hiddenButton:setScale(MainScene.elementScale)
	_hiddenButton:setVisible(false)

	local fullRect = CCRectMake(0,0,75,75)
	local insetRect = CCRectMake(30,30,15,15)
	local serverListPanel = CCScale9Sprite:create("images/star/intimate/attr9s.png", fullRect, insetRect)
	serverListPanel:setContentSize(CCSizeMake(255, 400))
	serverListPanel:setAnchorPoint(ccp(0, 0.5))
	serverListPanel:setPosition(ccpsprite(0.87, 0.5, _hiddenButton))
	_hiddenButton:addChild(serverListPanel, 10)

	local fullRect_2 = CCRectMake(0,0,75,75)
	local insetRect_2 = CCRectMake(30,30,15,15)
	local listBg = CCScale9Sprite:create("images/star/intimate/attr9s_2.png", fullRect, insetRect)
	listBg:setContentSize(CCSizeMake(250, 310))
	listBg:setAnchorPoint(ccp(0.5, 1))
	listBg:setPosition(ccp( serverListPanel:getContentSize().width * 0.5, serverListPanel:getContentSize().height -40))
	serverListPanel:addChild(listBg)

	-- 标题
	local titleLabel = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("lcy_50117"), g_sFontName, 21)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x65))
	titleLabel:setAnchorPoint(ccp(0.5 , 1))
	titleLabel:setPosition(ccp(serverListPanel:getContentSize().width*0.5, serverListPanel:getContentSize().height * 0.98))
	serverListPanel:addChild(titleLabel)
	-- 我的击杀
	local myKillTitle = CCLabelTTF:create(GetLocalizeStringBy("lcy_50118"), g_sFontName, 21)
	myKillTitle:setColor(ccc3(0x78, 0x25, 0x00))
	myKillTitle:setAnchorPoint(ccp(1 , 0))
	myKillTitle:setPosition(ccp(serverListPanel:getContentSize().width*0.4, 8))
	serverListPanel:addChild(myKillTitle)

	_myKillLabel = CCLabelTTF:create(_rankInfo.myInfo.killNum .. "", g_sFontName, 21)
	_myKillLabel:setColor(ccc3(0x78, 0x25, 0x00))
	_myKillLabel:setAnchorPoint(ccp(0 , 0))
	_myKillLabel:setPosition(ccp(serverListPanel:getContentSize().width*0.42, 8))
	serverListPanel:addChild(_myKillLabel)
	--我的排行
	local myRankTitle = CCLabelTTF:create(GetLocalizeStringBy("lcy_50119"), g_sFontName, 21)
	myRankTitle:setColor(ccc3(0x00, 0x6d, 0x2f))
	myRankTitle:setAnchorPoint(ccp(1 , 0))
	myRankTitle:setPosition(ccp(serverListPanel:getContentSize().width*0.8, 8))
	serverListPanel:addChild(myRankTitle)

	_myRankLabel = CCLabelTTF:create(_rankInfo.myInfo.rank .. "", g_sFontName, 21)
	_myRankLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
	_myRankLabel:setAnchorPoint(ccp(0 , 0))
	_myRankLabel:setPosition(ccp(serverListPanel:getContentSize().width*0.82, 8))
	serverListPanel:addChild(_myRankLabel)

	local cellSize = CCSizeMake(250,46)			--计算cell大小
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif fn == "cellAtIndex" then

            a2 = createCell(_rankInfo[a1 + 1], a1+1 )
			r = a2
		elseif fn == "numberOfCells" then
			r = #_rankInfo
		elseif fn == "cellTouched" then
		elseif (fn == "scroll") then
		end
		return r
	end)
	_rankTable = LuaTableView:createWithHandler(h, CCSizeMake(listBg:getContentSize().width, listBg:getContentSize().height-10))
    _rankTable:setAnchorPoint(ccp(0,0))
	_rankTable:setBounceable(true)
	_rankTable:setPosition(ccpsprite(0, 0, listBg))
	_rankTable:setVerticalFillOrder(kCCTableViewFillTopDown)
	listBg:addChild(_rankTable)

	-- refreshAttrTableView()
end

--[[
	@des : 创建列表单元格
--]]
function createCell(p_rankInfo, p_index)

	print("p_index", p_index)
	printTable("p_rankInfo", p_rankInfo)

	local index = tonumber(p_index)

	local tCell = CCTableViewCell:create()
	local bgSprite = nil
	if(index%2 == 1)then
		bgSprite = CCSprite:create()
	else
		bgSprite = CCScale9Sprite:create( "images/star/intimate/item9s.png" )
	end
	bgSprite:setContentSize(CCSizeMake(250, 46))
	tCell:addChild(bgSprite)

	local bgSpriteSize = bgSprite:getContentSize()
	
	-- 索引
	local indexLabel = CCRenderLabel:create(index, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)--CCLabelTTF:create(index, g_sFontPangWa, 21)
	indexLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	indexLabel:setAnchorPoint(ccp(0.5, 0.5))
	indexLabel:setPosition(ccp(bgSpriteSize.width*0.1, bgSpriteSize.height*0.5))

	-- 属性名称
	local attrNameLabel = CCRenderLabel:create(p_rankInfo.uname, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow) --CCLabelTTF:create(p_rankInfo.name, g_sFontName, 21)
	attrNameLabel:setAnchorPoint(ccp(0, 0.5))
	attrNameLabel:setPosition(ccp(bgSpriteSize.width*0.28, bgSpriteSize.height*0.5))
	bgSprite:addChild(attrNameLabel)

	--击杀数
	local rannkLabel = CCRenderLabel:create(p_rankInfo.killNum, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)--CCLabelTTF:create(p_rankInfo.rank, g_sFontName, 21)
	rannkLabel:setAnchorPoint(ccp(0.5, 0.5))
	rannkLabel:setPosition(ccp(bgSpriteSize.width*0.78, bgSpriteSize.height*0.5))
	bgSprite:addChild(rannkLabel)

	if(index <= 3) then
		local indexBg = CCSprite:create("images/guild_rob/rand_index_bg.png")
		indexBg:setAnchorPoint(ccp(0.5, 0.5))
		indexBg:setPosition(ccp(bgSpriteSize.width*0.1, bgSpriteSize.height*0.5))
		bgSprite:addChild(indexBg)
		indexBg:addChild(indexLabel)
		indexLabel:setPosition(ccpsprite(0.5, 0.5, indexBg))

		attrNameLabel:setColor(rankColor[index])
		rannkLabel:setColor(ccc3(255, 0, 0))
	else
		attrNameLabel:setColor(ccc3(255, 255, 255))
		rannkLabel:setColor(ccc3(255, 0, 0))
		bgSprite:addChild(indexLabel)
	end

	return tCell
end

--[[
	@des: 关闭按钮回调事件
--]]
function showServerButtonCallback( ... )
	_showButton:setVisible(false)
	_hiddenButton:setVisible(true)
    local position = ccps(1, 0.5)
    position.x = position.x - 255 * MainScene.elementScale
	local action = CCMoveTo:create(0.5, position)
    _hiddenButton:stopAllActions()
	_hiddenButton:runAction(action)
end

--[[
	@des: 关闭按钮回调事件
--]]
function hiddenServerButtonCallback( ... )

	local position = ccps(1, 0.5)
    position.x = position.x + 255 * MainScene.elementScale
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveTo:create(0.5, position))
	actionArray:addObject(CCCallFunc:create(function ( ... )
		_showButton:setVisible(true)
		_hiddenButton:setVisible(false)
	end))
	local seqAction = CCSequence:create(actionArray)
    _hiddenButton:stopAllActions()
	_hiddenButton:runAction(seqAction)
end

--[[
	@des :排行榜推送回调
--]]
function topNPushCallback( ... )

	if tolua.cast(_myKillLabel, "CCLabelTTF") == nil then
		return
	end
	_rankInfo = GuildRobBattleData.getRankInfo()
	_rankTable:reloadData()
	_myKillLabel:setString(_rankInfo.myInfo.killNum .. "")
	_myRankLabel:setString(_rankInfo.myInfo.rank .. "")
end