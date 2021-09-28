-- FileName: WarTableView.lua 
-- Author: Zhang Zihang
-- Date: 2014/8/5
-- Purpose: 战报tableView

module("WarTableView", package.seeall)

require "script/model/utils/HeroUtil"
require "script/model/hero/HeroModel"

local _touchPriority
local _atkInfo
local _defInfo
local _battleInfo
local _inner
--[[
	@des 	:创建tableView
	@param 	:战报数据
	@return :创建好的tableView
--]]
function createTableView(p_battleInfo,p_atkInfo,p_defInfo,p_inner)
	require "script/ui/lordWar/warReport/WarReportLayer"
	print("创建tableView")
	print_t(p_battleInfo)
	print("atk信息")
	print_t(p_atkInfo)
	print("放手信息")
	print_t(p_defInfo)
	_touchPriority = WarReportLayer.getTouchPriority()
	_inner = p_inner

	local cellNum = table.count(p_battleInfo)
	_battleInfo = p_battleInfo

	_atkInfo = p_atkInfo
	_defInfo = p_defInfo

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(555, 210)
		elseif fn == "cellAtIndex" then
			a2 = createReportCell(p_battleInfo[cellNum - a1],cellNum - a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = cellNum
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(555, 560))
end

--[[
	@des 	:创建cell
	@param 	:$ p_cellInfo cell的信息
	@param 	:$ p_index 场次索引
	@return :创建好的cell
--]]
function createReportCell(p_cellInfo,p_index)
	local tCell = CCTableViewCell:create()

	--背景
	local cellBgSprite = CCScale9Sprite:create("images/guild/battlereport/winbg.png")
	cellBgSprite:setContentSize(CCSizeMake(540,180))
	cellBgSprite:setAnchorPoint(ccp(0,0))
	cellBgSprite:setPosition(ccp(7,15))
	tCell:addChild(cellBgSprite)

	--标题背景
	local titleSprite = CCSprite:create("images/guild/battlereport/wintitle.png")
	titleSprite:setAnchorPoint(ccp(0.5,1))
	titleSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,cellBgSprite:getContentSize().height+10))
	cellBgSprite:addChild(titleSprite)

	--第几场
	local roundLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2886") .. p_index .. GetLocalizeStringBy("key_1464"),g_sFontPangWa,24)
	roundLabel:setColor(ccc3(0xff,0xf6,0x00))
	roundLabel:setAnchorPoint(ccp(0.5,0.5))
	roundLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
	titleSprite:addChild(roundLabel)

	local winSprite = CCSprite:create("images/olympic/win.png")
	local lostSprite = CCSprite:create("images/olympic/lost.png")

	local atkSprite
	local defSprite
	if tonumber(p_cellInfo.atk.uid) == tonumber(_atkInfo.uid) then
		atkSprite = createHeadSprite(_atkInfo)
		defSprite = createHeadSprite(_defInfo)
	else
		atkSprite = createHeadSprite(_defInfo)
		defSprite = createHeadSprite(_atkInfo)
	end

	atkSprite:setAnchorPoint(ccp(0.5,0.5))
	defSprite:setAnchorPoint(ccp(0.5,0.5))
	atkSprite:setPosition(ccp(105,cellBgSprite:getContentSize().height - 65))
	defSprite:setPosition(ccp(cellBgSprite:getContentSize().width - 105,cellBgSprite:getContentSize().height - 65))

	if tonumber(p_cellInfo.res) == 0 then
		winSprite:setAnchorPoint(ccp(0,1))
		winSprite:setPosition(ccp(0,cellBgSprite:getContentSize().height))

		lostSprite:setAnchorPoint(ccp(1,1))
		lostSprite:setPosition(ccp(cellBgSprite:getContentSize().width,cellBgSprite:getContentSize().height))
	else
		lostSprite:setAnchorPoint(ccp(0,1))
		lostSprite:setPosition(ccp(0,cellBgSprite:getContentSize().height))

		winSprite:setAnchorPoint(ccp(1,1))
		winSprite:setPosition(ccp(cellBgSprite:getContentSize().width,cellBgSprite:getContentSize().height))
	end

	cellBgSprite:addChild(winSprite)
	cellBgSprite:addChild(lostSprite)
	cellBgSprite:addChild(atkSprite)
	cellBgSprite:addChild(defSprite)

	--VS标识
	local vsSprite = CCSprite:create("images/arena/vs.png")
    vsSprite:setAnchorPoint(ccp(0.5,0.5))
    vsSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,cellBgSprite:getContentSize().height/2 + 20))
    cellBgSprite:addChild(vsSprite)

    require "script/ui/olympic/battleReport/CheckBattleReportLayer"

	local cellMenu = CCMenu:create()
	cellMenu:setPosition(ccp(0,0))
	cellMenu:setTouchPriority(_touchPriority - 2)
	cellBgSprite:addChild(cellMenu)

	local checkReportMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(160, 64),GetLocalizeStringBy("key_2849"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	checkReportMenuItem:setAnchorPoint(ccp(0.5,0))
    checkReportMenuItem:setPosition(ccp(cellBgSprite:getContentSize().width/2, 10))
    checkReportMenuItem:registerScriptTapHandler(checkReportCallBack)
    cellMenu:addChild(checkReportMenuItem,1,tonumber(p_index))

	return tCell
end

--[[
	@des 	:战报回调
	@param 	:tag
	@return :
--]]
function checkReportCallBack(p_tag)
	require "script/ui/lordWar/warReport/WarReportLayer"
	WarReportLayer.closeCallBack()
	require "script/battle/BattleUtil"
	require "script/ui/lordWar/LordWarMainLayer"
	print("战报id",_battleInfo[p_tag].replyId)
	BattleUtil.playerBattleReportById(_battleInfo[p_tag].replyId,nil,LordWarMainLayer.playBgm)
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

	local serverLabel = CCRenderLabel:create("(" .. p_playerInfo.serverName .. ")",g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	serverLabel:setColor(ccc3(0xff,0xff,0xff))
	serverLabel:setAnchorPoint(ccp(0.5,1))
	serverLabel:setVisible(not _inner)
	serverLabel:setPosition(ccp(nameLabel:getContentSize().width/2,-5))
	nameLabel:addChild(serverLabel)

	return playerSprite
end

function createOneTableView(p_atkInfo,p_defInfo,p_inner)
	require "script/ui/lordWar/warReport/WarReportLayer"
	_touchPriority = WarReportLayer.getTouchPriority()
	_inner = p_inner

	_atkInfo = p_atkInfo
	_defInfo = p_defInfo

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(555, 210)
		elseif fn == "cellAtIndex" then
			a2 = createOneReportCell()
			r = a2
		elseif fn == "numberOfCells" then
			r = 1
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(555, 560))
end

function createOneReportCell()
	local tCell = CCTableViewCell:create()

	--背景
	local cellBgSprite = CCScale9Sprite:create("images/guild/battlereport/winbg.png")
	cellBgSprite:setContentSize(CCSizeMake(540,180))
	cellBgSprite:setAnchorPoint(ccp(0,0))
	cellBgSprite:setPosition(ccp(7,15))
	tCell:addChild(cellBgSprite)

	--标题背景
	local titleSprite = CCSprite:create("images/guild/battlereport/wintitle.png")
	titleSprite:setAnchorPoint(ccp(0.5,1))
	titleSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,cellBgSprite:getContentSize().height+10))
	cellBgSprite:addChild(titleSprite)

	--第几场
	local roundLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2886") .. 1 .. GetLocalizeStringBy("key_1464"),g_sFontPangWa,24)
	roundLabel:setColor(ccc3(0xff,0xf6,0x00))
	roundLabel:setAnchorPoint(ccp(0.5,0.5))
	roundLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
	titleSprite:addChild(roundLabel)

	--VS标识
	local vsSprite = CCSprite:create("images/arena/vs.png")
    vsSprite:setAnchorPoint(ccp(0.5,0.5))
    vsSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,cellBgSprite:getContentSize().height/2 + 20))
    cellBgSprite:addChild(vsSprite)

    local atkSprite = createHeadSprite(_atkInfo)
    local defSprite = createHeadSprite(_defInfo)

    atkSprite:setAnchorPoint(ccp(0.5,0.5))
	defSprite:setAnchorPoint(ccp(0.5,0.5))
	atkSprite:setPosition(ccp(105,cellBgSprite:getContentSize().height - 65))
	defSprite:setPosition(ccp(cellBgSprite:getContentSize().width - 105,cellBgSprite:getContentSize().height - 65))
	cellBgSprite:addChild(atkSprite)
	cellBgSprite:addChild(defSprite)

	return tCell
end