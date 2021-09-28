-- FileName: GuildWarFinalsReportLayer.lua 
-- Author: Zhang Zihang
-- Date: 15-1-20
-- Purpose:  淘汰赛详细战报界面

module("GuildWarFinalsReportLayer", package.seeall)

require "script/ui/guildWar/report/GuildWarReportData"
require "script/ui/guildWar/report/GuildWarReportService"
require "script/ui/hero/HeroPublicLua"

local _touchPriority
local _zOrder
local _bgLayer
local _curIndex				--当前标签下标
local _bgMenu 				--背景menu层
local _reportTableView 		--战报tableView
local _reportInfo 			--战报信息
local _tableViewInfo 		--要显示的信息

--==================== Init ====================
--[[
	@des 	:初始化函数
--]]
function init()
	_touchPriority = nil
	_zOrder = nil
	_bgLayer = nil
	_bgMenu = nil
	_reportTableView = nil
	_reportInfo = nil
	_tableViewInfo = nil
	_curIndex = 1
end

--==================== TouchEvent ====================
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

--==================== CallBack ====================
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

--[[
	@des 	:查看战报回调
	@param  :tag值
--]]
function checkCallBack(p_tag)
	--removeLayer()
	require "script/battle/BattleUtil"
	BattleUtil.playerBattleReportById(_tableViewInfo[tonumber(p_tag)].brid,nil,nil,false)
end

--[[
	@des 	:切换组别回调
	@param  :tag值
--]]
function changeCallBack(p_tag)
	--当前点击的按钮点亮
	tolua.cast(_bgMenu:getChildByTag(p_tag),"CCMenuItemSprite"):selected()

	--如果点击当前的界面则没有反应
	if _curIndex == p_tag then
		return
	end

	--原先的按钮还原
	tolua.cast(_bgMenu:getChildByTag(_curIndex),"CCMenuItemSprite"):unselected()
	--设置当前点击按钮为当前的
	_curIndex = p_tag
	_tableViewInfo = _reportInfo[_curIndex]

	--重新加载tableView
	_reportTableView:reloadData()
end

--==================== TableView ====================
--[[
	@des 	:创建cell
	@param  :cell下标
	@return :创建好的cell
--]]
function createCell(p_index)
	local tCell = CCTableViewCell:create()

	local menuTag = p_index

	local lineSprite = CCScale9Sprite:create("images/common/line02.png")
	lineSprite:setContentSize(CCSizeMake(555,5))
	lineSprite:setAnchorPoint(ccp(0.5,0))
	lineSprite:setPosition(ccp(565*0.5,0))
	tCell:addChild(lineSprite)

	local cellHalfHeight = 90*0.5

	--轮次
	local roundLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1264",p_index),g_sFontPangWa,21)
	roundLabel:setColor(ccc3(0xff,0xf6,0x00))
	roundLabel:setAnchorPoint(ccp(0.5,0.5))
	roundLabel:setPosition(ccp(55,cellHalfHeight))
	tCell:addChild(roundLabel)

	local cellInfo = _tableViewInfo[p_index]

	--我方名字
	local ourNameLabel = CCRenderLabel:create(cellInfo.ownName,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	ourNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(GuildWarReportData.getHeroQuality(cellInfo.ownHtid)))
	ourNameLabel:setAnchorPoint(ccp(0.5,0.5))
	ourNameLabel:setPosition(ccp(185,cellHalfHeight))
	tCell:addChild(ourNameLabel)

	if cellInfo.ownCommbo ~= nil and tonumber(cellInfo.ownCommbo) >= GuildWarDef.DEFAULT_WIN_NUM then
		local commboSprite = CCSprite:create("images/guild_war/liansheng.png")
		commboSprite:setAnchorPoint(ccp(0.5,0))
		commboSprite:setPosition(ccp(185,5))
		tCell:addChild(commboSprite)

		local commboSize = commboSprite:getContentSize()

		--我方连胜次数
		local ourCommboLabel = CCRenderLabel:create(cellInfo.ownCommbo .. GetLocalizeStringBy("zzh_1274"),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
		ourCommboLabel:setColor(ccc3(0xff,0xff,0xff))
		ourCommboLabel:setAnchorPoint(ccp(0.5,0.5))
		ourCommboLabel:setPosition(ccp(commboSize.width*0.5,commboSize.height*0.5))
		commboSprite:addChild(ourCommboLabel)
	end

	--对手名字
	local opponentNameLabel = CCRenderLabel:create(cellInfo.opponentName,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
	opponentNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(GuildWarReportData.getHeroQuality(cellInfo.opponentHtid)))
	opponentNameLabel:setAnchorPoint(ccp(0.5,0.5))
	opponentNameLabel:setPosition(ccp(345,cellHalfHeight))
	tCell:addChild(opponentNameLabel)

	if cellInfo.opponentCommbo ~= nil and tonumber(cellInfo.opponentCommbo) >= GuildWarDef.DEFAULT_WIN_NUM then
		local commboSprite = CCSprite:create("images/guild_war/liansheng.png")
		commboSprite:setAnchorPoint(ccp(0.5,0))
		commboSprite:setPosition(ccp(345,5))
		tCell:addChild(commboSprite)

		local commboSize = commboSprite:getContentSize()

		--敌方连胜次数
		local opponentCommboLabel = CCRenderLabel:create(cellInfo.opponentCommbo .. GetLocalizeStringBy("zzh_1274"),g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_shadow)
		opponentCommboLabel:setColor(ccc3(0xff,0xff,0xff))
		opponentCommboLabel:setAnchorPoint(ccp(0.5,0.5))
		opponentCommboLabel:setPosition(ccp(commboSize.width*0.5,commboSize.height*0.5))
		commboSprite:addChild(opponentCommboLabel)
	end

	--胜负图
	local resultSprite
	--胜利
	if cellInfo.result == GuildWarDef.VICTORY then
		resultSprite = CCSprite:create("images/guild/win.png")
	--失败
	elseif cellInfo.result == GuildWarDef.FAILED then
		resultSprite = CCSprite:create("images/guild/lost.png")
	else
		resultSprite = CCLabelTTF:create(GetLocalizeStringBy("zzh_1280"),g_sFontName,30)
		resultSprite:setColor(ccc3(0x00,0xff,0x18))
	end

	resultSprite:setAnchorPoint(ccp(0.5,0.5))
	resultSprite:setPosition(ccp(465,cellHalfHeight))
	tCell:addChild(resultSprite)

	--背景menu
	local cellMenu = CCMenu:create()
	cellMenu:setAnchorPoint(ccp(0,0))
	cellMenu:setPosition(ccp(0,0))
	cellMenu:setTouchPriority(_touchPriority - 2)
	tCell:addChild(cellMenu)

	local checkMenuItem = CCMenuItemImage:create("images/battle/battlefield_report/look_n.png","images/battle/battlefield_report/look_h.png")
	checkMenuItem:setAnchorPoint(ccp(0.5,0.5))
	checkMenuItem:setPosition(ccp(525,cellHalfHeight))
	checkMenuItem:registerScriptTapHandler(checkCallBack)
	cellMenu:addChild(checkMenuItem,1,menuTag)

	return tCell
end

--[[
	@des 	:创建tableView
	@return :创建好的tableView
--]]
function createTableView()
	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(565,90)
		elseif fn == "cellAtIndex" then
			a2 = createCell(GuildWarReportData.getDetailCellNum(_curIndex) - a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = GuildWarReportData.getDetailCellNum(_curIndex)
		end

		return r
	end)

	return LuaTableView:createWithHandler(h,CCSizeMake(565,610))
end

--==================== UI ====================
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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1263"),g_sFontPangWa,33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleBgSize.width*0.5,titleBgSize.height*0.5))
	titleBgSprite:addChild(titleLabel)

	--二级背景框
	local secBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secBgSprite:setContentSize(CCSizeMake(565,620))
	secBgSprite:setAnchorPoint(ccp(0.5,0))
	secBgSprite:setPosition(ccp(bgSize.width*0.5,90))
	bgSprite:addChild(secBgSprite)

	--内部标题背景
	local fullRect = CCRectMake(0,0,74,63)
	local insetRect = CCRectMake(34,18,4,1)
	local barSize = CCSizeMake(570,65)
	local titleBarSprite = CCScale9Sprite:create("images/guild/city/titleBg.png",fullRect,insetRect)
	titleBarSprite:setContentSize(barSize)
	titleBarSprite:setAnchorPoint(ccp(0.5,1))
	titleBarSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height - 100))
	bgSprite:addChild(titleBarSprite)

	--标题栏名字位置
	local namePosTable = { 60,195,350,490 }
	--标题栏名字图片路径
	local namePathTable = {
								"images/lord_war/battlereport/round.png",
								"images/guild/soldier.png",
								"images/guild/opponent.png",
								"images/lord_war/battlereport/final.png",
						  }
	--标题栏分割线位置
	local linePosTable = { 110,270,425 }

	local nameNum = 4
	for i = 1,nameNum do
		if i ~= nameNum then
			local lineSprite = CCSprite:create("images/guild/city/fen.png")
			lineSprite:setAnchorPoint(ccp(0.5,1))
			lineSprite:setPosition(ccp(linePosTable[i],barSize.height - 5))
			titleBarSprite:addChild(lineSprite)
		end

		local barNameSprite = CCSprite:create(namePathTable[i])
		barNameSprite:setAnchorPoint(ccp(0.5,0.5))
		barNameSprite:setPosition(ccp(namePosTable[i],barSize.height/2 + 5))
		titleBarSprite:addChild(barNameSprite)
	end

	local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1265"),g_sFontPangWa,21)
	tipLabel:setColor(ccc3(0x78,0x25,0x00))
	tipLabel:setAnchorPoint(ccp(0.5,0.5))
	tipLabel:setPosition(ccp(bgSize.width*0.5,60))
	bgSprite:addChild(tipLabel)

	--背景按钮层
	_bgMenu = CCMenu:create()
	_bgMenu:setAnchorPoint(ccp(0,0))
	_bgMenu:setPosition(ccp(0,0))
	_bgMenu:setTouchPriority(_touchPriority - 1)
	bgSprite:addChild(_bgMenu)
	--关闭按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeMenuItem:setAnchorPoint(ccp(1,1))
	closeMenuItem:setPosition(ccp(bgSize.width*1.03,bgSize.height*1.03))
	closeMenuItem:registerScriptTapHandler(closeCallBack)
	_bgMenu:addChild(closeMenuItem)

	local changeGapLenth = barSize.width*0.2
	local changeBeginPosX = (bgSize.width - barSize.width)*0.5 + changeGapLenth*0.5

	--五组切换按钮
	for i = 1,5 do
		local changeMenuItem = LuaCC.create9ScaleMenuItem("images/recycle/btn_title_h.png","images/recycle/btn_title_n.png",CCSizeMake(140,65),GetLocalizeStringBy("zzh_1266",i),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
		changeMenuItem:setAnchorPoint(ccp(0.5,0))
		changeMenuItem:setScale(0.8)
		changeMenuItem:setPosition(ccp(changeBeginPosX + (i - 1)*changeGapLenth,bgSize.height - 100))
		changeMenuItem:registerScriptTapHandler(changeCallBack)
		_bgMenu:addChild(changeMenuItem,1,i)
	end
	
	--设置当前index
	_curIndex = 1

	tolua.cast(_bgMenu:getChildByTag(_curIndex),"CCMenuItemSprite"):selected()

	_reportInfo = GuildWarReportData.dealAndGetDetailReportInfo()
	_tableViewInfo = _reportInfo[_curIndex]

	--创建tableView
	_reportTableView = createTableView()
	_reportTableView:setAnchorPoint(ccp(0,0))
	_reportTableView:setPosition(ccp(0,0))
	_reportTableView:setTouchPriority(_touchPriority - 3)
	secBgSprite:addChild(_reportTableView)
end

--==================== Entrance ====================
--[[
	@des 	:入口函数
	@param 	: $ p_touchPriority 	: 触摸优先级，默认为 -550
	@param 	: $ p_zOrder 			: Z轴，默认为 999
	@param 	: $ p_idTable 			: replayId的Table
--]]
function showLayer(p_touchPriority,p_zOrder,p_idTable)
	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	--创建背景屏蔽层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    GuildWarReportService.getReplayDetail(p_idTable,createUI)
end