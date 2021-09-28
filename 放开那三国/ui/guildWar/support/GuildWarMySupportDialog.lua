-- Filename: GuildWarMySupportDialog.lua
-- Author: bzx
-- Date: 2015-1-19
-- Purpose: 我的助威

module("GuildWarMySupportDialog", package.seeall)

require "script/ui/guildWar/support/GuildWarSupportService"
require "script/ui/guildWar/support/GuildWarSupportData"

local _touchPriority
local _zOrder
local _bgLayer
local _cherrNum
--[[
	@des 	:初始化函数
--]]
function init()
	_touchPriority = nil
	_zOrder = nil
	_bgLayer = nil
	_cherrNum = nil
end

--[[
	@des 	:点击事件函数
--]]
function onTouchesHandler()
	return true
end

--[[
	@des 	:事件函数
	@param 	:事件
--]]
function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif eventType == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des 	:入口函数
	@param 	: $ p_touchPriority 	: 触摸优先级，默认为 -550
	@param 	: $ p_zOrder 			: Z轴，默认为 999
	@param 	: $ p_idTable 			: replayId的Table
--]]
function show(p_touchPriority,p_zOrder)
	init()
	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999
	local layer = GuildWarMySupportDialog.crateLayer()
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

function crateLayer()
	--创建背景屏蔽层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	GuildWarSupportService.getHistoryCheerInfo(function ()
		createUI()
	end)
	return _bgLayer
end

--[[
	@des 	:创建UI
--]]
function createUI()
	local bgSize = CCSizeMake(625,850)
	--背景图
	local bgSprite = CCScale9Sprite:create(CCRectMake(100,80,10,20),"images/common/viewbg1.png")
	bgSprite:setContentSize(bgSize)
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	bgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(bgSprite)
	--标题背景
	local titleBgSprite = CCSprite:create("images/common/viewtitle1.png")
	titleBgSprite:setAnchorPoint(ccp(0.5,0.5))
	titleBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height - 6))
	bgSprite:addChild(titleBgSprite)
	--标题背景大小
	local titleBgSize = titleBgSprite:getContentSize()
	--标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_82"),g_sFontPangWa,33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleBgSize.width*0.5,titleBgSize.height*0.5))
	titleBgSprite:addChild(titleLabel)

	--二级背景框
	local secBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secBgSprite:setContentSize(CCSizeMake(565,675))
	secBgSprite:setAnchorPoint(ccp(0.5,0))
	secBgSprite:setPosition(ccp(bgSize.width*0.5,90))
	bgSprite:addChild(secBgSprite)

	local fullRect = CCRectMake(0,0,74,63)
	local insetRect = CCRectMake(34,18,4,1)
	local titleListBg = CCScale9Sprite:create("images/guild/city/titleBg.png", fullRect, insetRect)
	titleListBg:setContentSize(CCSizeMake(575,65))
	titleListBg:setAnchorPoint(ccp(0.5,1))
	titleListBg:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 70))
	bgSprite:addChild(titleListBg)

	--2条分割线
	local triLineXTable = {165,425}
	local spriteNameTable = {
								[1] = "images/lord_war/battlereport/round.png",
								[2] = "images/lord_war/supportdetail.png",
							}
	local nameXTable = {90,282}
	for i = 1,2 do
		-- if i ~= 2 then
			local lineSprite = CCSprite:create("images/guild/city/fen.png")
			lineSprite:setAnchorPoint(ccp(0.5,1))
			lineSprite:setPosition(ccp(triLineXTable[i],titleListBg:getContentSize().height - 5))
			titleListBg:addChild(lineSprite)
		-- end

		local listNameSprite = CCSprite:create(spriteNameTable[i])
		listNameSprite:setAnchorPoint(ccp(0.5,0.5))
		listNameSprite:setPosition(ccp(nameXTable[i],titleListBg:getContentSize().height/2 + 5))
		titleListBg:addChild(listNameSprite)
	end


	--背景按钮层
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	bgSprite:addChild(bgMenu)
	--关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeMenuItem:setAnchorPoint(ccp(1,1))
	closeMenuItem:setPosition(ccp(bgSize.width*1.03,bgSize.height*1.03))
	closeMenuItem:registerScriptTapHandler(closeCallBack)
	bgMenu:addChild(closeMenuItem)
	
	--创建tableView
	local reportTableView = createTableView()
	reportTableView:setAnchorPoint(ccp(0,0))
	reportTableView:setPosition(ccp(0,0))
	reportTableView:setTouchPriority(_touchPriority - 3)
	secBgSprite:addChild(reportTableView)


	local contentInfo = {}
    contentInfo.labelDefaultColor = ccc3(0x78,0x25,0x00)
    contentInfo.labelDefaultSize = 21
    contentInfo.defaultType = "CCRenderLabel"
    contentInfo.lineAlignment = 1
    contentInfo.labelDefaultFont = g_sFontPangWa
    contentInfo.elements = {
    	{
			text = _cherrNum,
			color = ccc3(0x00, 0xff, 0x18)
		},
	}
	local mySupportNum =  GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10184"), contentInfo)
	mySupportNum:setAnchorPoint(ccp(0.5, 0.5))
	mySupportNum:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 60))
	bgSprite:addChild(mySupportNum)

end

--[[
	@des 	:创建cell
	@parap  :cell信息
	@param  :cell下标
	@return :创建好的cell
--]]
function createCell(p_cellInfo,p_index)
	local tCell = CCTableViewCell:create()

	local menuTag = p_index

	local lineSprite = CCScale9Sprite:create("images/common/line02.png")
	lineSprite:setContentSize(CCSizeMake(555,5))
	lineSprite:setAnchorPoint(ccp(0.5,0))
	lineSprite:setPosition(ccp(565*0.5,0))
	tCell:addChild(lineSprite)

	local cellHalfHeight = 90

	local warTitle = CCRenderLabel:create(GetLocalizeStringBy("key_10185"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	warTitle:setAnchorPoint(ccp(0.5,0.5))
	warTitle:setPosition(ccp(60,cellHalfHeight * 0.73 ))
	tCell:addChild(warTitle)

	--轮次
	local isLabelVisible = true
	local desFilename = ""
	local roundStr = ""
	if tonumber(p_cellInfo.round) == GuildWarDef.ADVANCED_4 then
		desFilename = "images/lord_war/halfbattle.png"
		isLabelVisible = false
	elseif tonumber(p_cellInfo.round) == GuildWarDef.ADVANCED_2 then
		desFilename = "images/lord_war/lastmatch.png"
		isLabelVisible = false
	elseif tonumber(p_cellInfo.round) == GuildWarDef.ADVANCED_16 then
		desFilename = "images/lord_war/battlematch.png"
		roundStr = "1/8"
	elseif tonumber(p_cellInfo.round) == GuildWarDef.ADVANCED_8 then
		desFilename = "images/lord_war/battlematch.png"
		roundStr = "1/4"
	else
		error("error round support")
	end

	local roundLabel = CCLabelTTF:create(roundStr,g_sFontPangWa,19)
	roundLabel:setColor(ccc3(0xff,0xf6,0x00))

	local desSprite = CCSprite:create(desFilename)
	desSprite:setAnchorPoint(ccp(0.5, 0.5))

	local titleNodeTable = {}
	if isLabelVisible then
		titleNodeTable[1] = roundLabel
		titleNodeTable[2] = desSprite
	else
		titleNodeTable[1] = desSprite
	end
	local titleNode = BaseUI.createHorizontalNode(titleNodeTable)
	titleNode:setAnchorPoint(ccp(0.5, 0.5))
	titleNode:setPosition(ccp(60, cellHalfHeight * 0.25))
	tCell:addChild(titleNode)

	--我方名字
	local serverName = CCRenderLabel:create(p_cellInfo.guild_name,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	serverName:setAnchorPoint(ccp(0.5,0.5))
	serverName:setPosition(ccp(285,cellHalfHeight * 0.75))
	tCell:addChild(serverName)
	serverName:setColor(ccc3(0x00, 0xe4, 0xff))

	--我方名字
	local servertIdLabel = CCRenderLabel:create(p_cellInfo.server_name,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	servertIdLabel:setAnchorPoint(ccp(0.5,0.5))
	servertIdLabel:setPosition(ccp(285,cellHalfHeight * 0.25))
	tCell:addChild(servertIdLabel)


	local resultInfo = {
		["2"] =  "images/lord_war/pass.png",
		["3"] =  "images/lord_war/notpass.png",
	}
	if tonumber(p_cellInfo.guildState) >1 then
		local resultSprite = CCSprite:create(resultInfo[p_cellInfo.guildState])
		resultSprite:setAnchorPoint(ccp(0.5,0.5))
		resultSprite:setPosition(ccp(500,cellHalfHeight * 0.75))
		tCell:addChild(resultSprite)
	end
	if tonumber(p_cellInfo.guildState) == 1 then
		local resultSprite = CCRenderLabel:create(GetLocalizeStringBy("key_10186"),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
		resultSprite:setAnchorPoint(ccp(0.5,0.5))
		resultSprite:setPosition(ccp(500,cellHalfHeight * 0.75))
		tCell:addChild(resultSprite)
	end

	--奖励
	local resultInfo = {
		["0"] =  GetLocalizeStringBy("key_10187"),
		["1"] =  GetLocalizeStringBy("key_10188"),
	}
	local rewardStatusLabel = CCRenderLabel:create(p_cellInfo.rewardState,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	rewardStatusLabel:setAnchorPoint(ccp(0.5,0.5))
	rewardStatusLabel:setPosition(ccp(500,cellHalfHeight * 0.25))
	tCell:addChild(rewardStatusLabel)
	rewardStatusLabel:setString(resultInfo[p_cellInfo.rewardState])
	
	return tCell
end

--[[
	@des 	:创建tableView
	@return :创建好的tableView
--]]
function createTableView()
	local supportInfo = GuildWarSupportData.getMySupportTableData()
	local cellNum = #supportInfo
	_cherrNum = cellNum
	print("createTableView")
	printTable("supportInfo", supportInfo)
	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(565,90)
		elseif fn == "cellAtIndex" then
			a2 = createCell(supportInfo[cellNum - a1],cellNum - a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = #supportInfo
		end
		return r
	end)

	return LuaTableView:createWithHandler(h,CCSizeMake(565,640))
end


--[[
	@des 	:删除页面
--]]
function removeLayer()
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des 	:关闭回调
--]]
function closeCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	removeLayer()
end
