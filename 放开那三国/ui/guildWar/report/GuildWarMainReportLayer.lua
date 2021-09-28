-- FileName: GuildWarMainReportLayer.lua 
-- Author: Zhang Zihang
-- Date: 15-1-20
-- Purpose:  军团战绩页面

module("GuildWarMainReportLayer", package.seeall)

require "script/ui/guildWar/report/GuildWarReportData"
require "script/ui/guildWar/report/GuildWarReportService"
require "script/ui/guildWar/GuildWarDef"
require "script/ui/guildWar/GuildWarMainData"
require "script/ui/tip/AnimationTip"
require "script/ui/guild/GuildUtil"
require "script/utils/TimeUtil"
require "script/utils/BaseUI"

local _touchPriority
local _zOrder
local _bgLayer
local _reportInfo			--战报信息
local _isOver 				--是否被淘汰

--==================== Init ====================
--[[
	@des 	:初始化函数
--]]
function init()
	_touchPriority = nil
	_zOrder = nil
	_bgLayer = nil
	_reportInfo = nil
	_isOver = false
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
	removeLayer()
	if _reportInfo[tonumber(p_tag)].type == GuildWarDef.AUDITION then
		require "script/ui/guildWar/report/GuildWarAuditionReportLayer"
		GuildWarAuditionReportLayer.showLayer(_touchPriority,p_zOrder,_reportInfo[tonumber(p_tag)].replayId)
	else
		require "script/ui/guildWar/report/GuildWarFinalsReportLayer"
		GuildWarFinalsReportLayer.showLayer(_touchPriority,p_zOrder,_reportInfo[tonumber(p_tag)].replayId)
	end
end

--==================== TableView ====================
--[[
	@des 	:创建cell
	@param  :cell信息
	@param  :cell下标
	@return :创建好的cell
--]]
function createCell(p_info,p_index)
	local tCell = CCTableViewCell:create()

	local menuTag = p_index

	local lineSprite = CCScale9Sprite:create("images/common/line02.png")
	lineSprite:setContentSize(CCSizeMake(555,5))
	lineSprite:setAnchorPoint(ccp(0.5,0))
	lineSprite:setPosition(ccp(565*0.5,0))
	tCell:addChild(lineSprite)

	--阶段标题
	local stageLabel
	--轮次node
	local roundNode
	local labelPos = 55
	--如果是海选赛
	if p_info.type == GuildWarDef.AUDITION then
		--海选赛
		stageLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1267"),g_sFontPangWa,18)
		--轮次
		roundNode = CCLabelTTF:create(GetLocalizeStringBy("zzh_1264",p_info.round),g_sFontPangWa,23)
		roundNode:setColor(ccc3(0xff,0xff,0xff))
	--淘汰赛
	else
		--冠军赛
		stageLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1268"),g_sFontPangWa,18)
		if (p_info.type == GuildWarDef.ADVANCED_16) or (p_info.type == GuildWarDef.ADVANCED_8) then
			local typeString
			--八分之一决赛
			if p_info.type == GuildWarDef.ADVANCED_16 then
				typeString = "1/8"
			--四分之一决赛
			else
				typeString = "1/4"
			end
			local roundLabel = CCLabelTTF:create(typeString,g_sFontPangWa,23)
			roundLabel:setColor(ccc3(0xff,0xff,0xff))
			local roundSprite = CCSprite:create("images/lord_war/battlereport/playoff_final.png")
			roundNode = BaseUI.createHorizontalNode({roundLabel,roundSprite})
		elseif p_info.type == GuildWarDef.ADVANCED_4 then
			roundNode = CCSprite:create("images/lord_war/battlereport/semi_final.png")
		else
			roundNode = CCSprite:create("images/lord_war/battlereport/champion_final.png")
		end
	end

	stageLabel:setColor(ccc3(0xff,0xf6,0x00))
	stageLabel:setAnchorPoint(ccp(0.5,0))
	stageLabel:setPosition(ccp(labelPos,60))
	tCell:addChild(stageLabel)

	roundNode:setAnchorPoint(ccp(0.5,0))
	roundNode:setPosition(ccp(labelPos,30))
	tCell:addChild(roundNode)

	local namePos = 320
	local halfCellHeight = 125*0.5

	--对手信息
	local opponentInfo = p_info.opponent

	--军团徽章id
	local guildIconId = opponentInfo.guild_badge
	local guildSprite = GuildUtil.getGuildIcon(guildIconId)
	guildSprite:setAnchorPoint(ccp(0.5,0.5))
	guildSprite:setPosition(ccp(175,halfCellHeight))
	tCell:addChild(guildSprite)

	--对手军团名字
	local guildNameLabel = CCLabelTTF:create(opponentInfo.guild_name,g_sFontName,25)
	guildNameLabel:setColor(ccc3(0x00,0xe4,0xff))
	guildNameLabel:setAnchorPoint(ccp(0.5,0))
	guildNameLabel:setPosition(ccp(namePos,60))
	tCell:addChild(guildNameLabel)
	--对手服务器名字
	local serverNameLabel = CCLabelTTF:create("(" .. opponentInfo.guild_server_name .. ")",g_sFontName,21)
	serverNameLabel:setColor(ccc3(0xff,0xff,0xff))
	serverNameLabel:setAnchorPoint(ccp(0.5,0))
	serverNameLabel:setPosition(ccp(namePos,30))
	tCell:addChild(serverNameLabel)

	--胜负图
	local resultSprite
	--胜利
	if p_info.result == GuildWarDef.VICTORY then
		resultSprite = CCSprite:create("images/guild/win.png")
	--失败
	else
		resultSprite = CCSprite:create("images/guild/lost.png")
	end

	resultSprite:setAnchorPoint(ccp(0.5,0.5))
	resultSprite:setPosition(ccp(460,halfCellHeight))
	tCell:addChild(resultSprite)

	--背景menu
	local cellMenu = CCMenu:create()
	cellMenu:setAnchorPoint(ccp(0,0))
	cellMenu:setPosition(ccp(0,0))
	cellMenu:setTouchPriority(_touchPriority - 2)
	tCell:addChild(cellMenu)

	local checkMenuItem = CCMenuItemImage:create("images/battle/battlefield_report/look_n.png","images/battle/battlefield_report/look_h.png")
	checkMenuItem:setAnchorPoint(ccp(0.5,0.5))
	checkMenuItem:setPosition(ccp(525,halfCellHeight))
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
			r = CCSizeMake(565,125)
		elseif fn == "cellAtIndex" then
			a2 = createCell(_reportInfo[a1 + 1],a1 + 1)
			r = a2
		elseif fn == "numberOfCells" then
			r = GuildWarReportData.getMainCellNum()
		end

		return r
	end)

	return LuaTableView:createWithHandler(h,CCSizeMake(565,610))
end

--==================== UI ====================
--[[
	@des 	:当前阶段显示的提示
	@return :创建好的提示
--]]
function createOverLabel()
	--当前阶段
	local curStage = GuildWarMainData.getRound()
	--显示的string
	local showString
	--当前时间
	local curTime = tonumber(TimeUtil.getSvrTimeByOffset())

	--如果比赛已结束
	if GuildWarMainData.isGameOver() then
		showString = GetLocalizeStringBy("zzh_1273")
	--海选赛阶段
	elseif curStage == GuildWarDef.AUDITION then
		if _isOver then
			showString = GetLocalizeStringBy("zzh_1270")
		elseif curTime > tonumber(GuildWarMainData.getEndTime(GuildWarDef.AUDITION)) then
			showString = " "
		else
			showString = GetLocalizeStringBy("zzh_1269")
		end
	--淘汰赛阶段
	elseif curStage >= GuildWarDef.ADVANCED_16 and curStage <= GuildWarDef.ADVANCED_2 then
		if _isOver then
			showString = GetLocalizeStringBy("zzh_1272")
		else
			showString = GetLocalizeStringBy("zzh_1271")
		end
	end

	local tipLabel = CCLabelTTF:create(showString,g_sFontPangWa,21,CCSizeMake(525,0),kCCTextAlignmentCenter)
	tipLabel:setColor(ccc3(0x78,0x25,0x00))

	return tipLabel
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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1262"),g_sFontPangWa,33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleBgSize.width*0.5,titleBgSize.height*0.5))
	titleBgSprite:addChild(titleLabel)

	--二级背景框
	local secBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secBgSprite:setContentSize(CCSizeMake(565,635))
	secBgSprite:setAnchorPoint(ccp(0.5,0))
	secBgSprite:setPosition(ccp(bgSize.width*0.5,140))
	bgSprite:addChild(secBgSprite)

	--内部标题背景
	local fullRect = CCRectMake(0,0,74,63)
	local insetRect = CCRectMake(34,18,4,1)
	local barSize = CCSizeMake(570,65)
	local titleBarSprite = CCScale9Sprite:create("images/guild/city/titleBg.png",fullRect,insetRect)
	titleBarSprite:setContentSize(barSize)
	titleBarSprite:setAnchorPoint(ccp(0.5,1))
	titleBarSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height - 45))
	bgSprite:addChild(titleBarSprite)

	--标题栏名字位置
	local namePosTable = { 55,265,490 }
	--标题栏名字图片路径
	local namePathTable = {
								"images/lord_war/battlereport/round.png",
								"images/guild/vs_guild.png",
								"images/lord_war/battlereport/final.png",
						  }
	--标题栏分割线位置
	local linePosTable = { 105,425 }

	local nameNum = 3
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

	_reportInfo,_isOver = GuildWarReportData.dealAndGetMainReportInfo()

	local overTipLabel = createOverLabel()
	overTipLabel:setAnchorPoint(ccp(0.5,0.5))
	overTipLabel:setPosition(ccp(bgSize.width*0.5,80))
	bgSprite:addChild(overTipLabel)

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
end

--==================== Entrance ====================
--[[
	@des 	:入口函数
	@param 	: $ p_touchPriority 	: 触摸优先级，默认为 -550
	@param 	: $ p_zOrder 			: Z轴，默认为 999
--]]
function showLayer(p_touchPriority,p_zOrder)
	--判断是否显示
	--如果未报名
	if not GuildWarMainData.isSignUp() then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1278"))
		return
	elseif tonumber(TimeUtil.getSvrTimeByOffset()) <= tonumber(GuildWarMainData.getStartTime(GuildWarDef.AUDITION)) then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1279"))
		return
	end

	init()

	_touchPriority = p_touchPriority or -550
	_zOrder = p_zOrder or 999

	--创建背景屏蔽层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    GuildWarReportService.getHistoryFightInfo(createUI)
end