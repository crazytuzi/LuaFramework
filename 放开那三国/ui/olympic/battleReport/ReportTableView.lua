-- Filename: ReportTableView.lua
-- Author: Zhang Zihang
-- Date: 2014-07-16
-- Purpose: 战报TableView

module("ReportTableView",package.seeall)

require "script/ui/olympic/OlympicData"
require "script/model/utils/HeroUtil"

--[[
	@des 	:创建tableView
	@param 	:所有战报table
	@return :创建好的tableView
--]]
function createWholeTableView(p_wholeTable)
	--local wholeReportInfo = OlympicData.getAllReportInfo()

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(555, 210)
		elseif fn == "cellAtIndex" then
			--用a1+1做下标创建cell
			a2 = createReportCell(p_wholeTable[#p_wholeTable - a1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #p_wholeTable
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(555, 560))
end

--[[
	@des 	:创建tableView的cell
	@param 	:战报信息
	@return :创建好的cell
--]]
function createReportCell(p_info)
	--p_info结构
	--    attacker:int
	--    defender:int
	--    brid:int
	--    result:string
	--    logType:string

	print("")

	local tCell = CCTableViewCell:create()

	local cellBgSprite = CCScale9Sprite:create("images/guild/battlereport/winbg.png")
	cellBgSprite:setContentSize(CCSizeMake(540,180))
	cellBgSprite:setAnchorPoint(ccp(0,0))
	cellBgSprite:setPosition(ccp(7,15))
	tCell:addChild(cellBgSprite)

	local titleSprite = CCSprite:create("images/guild/battlereport/wintitle.png")
	titleSprite:setAnchorPoint(ccp(0.5,1))
	titleSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,cellBgSprite:getContentSize().height+10))
	cellBgSprite:addChild(titleSprite)

	local titleLabel = CCLabelTTF:create(p_info.logType,g_sFontPangWa,25)
	titleLabel:setColor(ccc3(0xff,0xf6,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
	titleSprite:addChild(titleLabel)

	local winSprite = CCSprite:create("images/olympic/win.png")

	local lostSprite = CCSprite:create("images/olympic/lost.png")

	--攻方败
	if (p_info.result == "F") or (p_info.result == "E") then
		lostSprite:setAnchorPoint(ccp(0,1))
		lostSprite:setPosition(ccp(0,cellBgSprite:getContentSize().height))
		winSprite:setAnchorPoint(ccp(1,1))
		winSprite:setPosition(ccp(cellBgSprite:getContentSize().width,cellBgSprite:getContentSize().height))
	else
		winSprite:setAnchorPoint(ccp(0,1))
		winSprite:setPosition(ccp(0,cellBgSprite:getContentSize().height))
		lostSprite:setAnchorPoint(ccp(1,1))
		lostSprite:setPosition(ccp(cellBgSprite:getContentSize().width,cellBgSprite:getContentSize().height))
	end

	cellBgSprite:addChild(lostSprite)
	cellBgSprite:addChild(winSprite)

	--攻方信息
	local attackerInfo = OlympicData.getBattlePlayerInfo(p_info.attacker)
	local attackerSprite = createHeaderSprite(attackerInfo)
	attackerSprite:setAnchorPoint(ccp(0,1))
	attackerSprite:setPosition(ccp(60,cellBgSprite:getContentSize().height - 20))
	cellBgSprite:addChild(attackerSprite)

	--守方信息
	local defenderInfo = OlympicData.getBattlePlayerInfo(p_info.defender)
	local defenderSprite = createHeaderSprite(defenderInfo)
	defenderSprite:setAnchorPoint(ccp(1,1))
	defenderSprite:setPosition(ccp(cellBgSprite:getContentSize().width - 60,cellBgSprite:getContentSize().height - 20))
	cellBgSprite:addChild(defenderSprite)

	local vsSprite = CCSprite:create("images/arena/vs.png")
    vsSprite:setAnchorPoint(ccp(0.5,0.5))
    vsSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,cellBgSprite:getContentSize().height/2 + 20))
    cellBgSprite:addChild(vsSprite)

	require "script/ui/olympic/battleReport/CheckBattleReportLayer"

	local cellMenu = CCMenu:create()
	cellMenu:setPosition(ccp(0,0))
	cellMenu:setTouchPriority(CheckBattleReportLayer.getTouchPriority() - 2)
	cellBgSprite:addChild(cellMenu)

	local checkReportMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(160, 64),GetLocalizeStringBy("key_2849"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	checkReportMenuItem:setAnchorPoint(ccp(0.5,0))
    checkReportMenuItem:setPosition(ccp(cellBgSprite:getContentSize().width/2, 10))
    checkReportMenuItem:registerScriptTapHandler(checkReportCallBack)
    cellMenu:addChild(checkReportMenuItem,1,tonumber(p_info.brid))

	return tCell
end

--[[
	@des 	:创建头像信息
	@param 	:玩家信息
	@return :创建好的玩家头像
--]]
function createHeaderSprite(p_playerInfo)
	--p_playerInfo结构
	-- 		sign_up_index:int    报名位置
	--    	olympic_index:int    比赛位置
	--    	final_rank:int        排名
	--    	uid:int
	--    	uname:int
	--    	dress:array
	--   	htid:int
	local genderId = HeroModel.getSex(p_playerInfo.htid)
	local playerSprite
	if table.isEmpty(p_playerInfo.dress) then
		playerSprite = HeroUtil.getHeroIconByHTID(p_playerInfo.htid)
	else
		playerSprite = HeroUtil.getHeroIconByHTID(p_playerInfo.htid,p_playerInfo.dress["1"],genderId)
	end

	local nameLabel = CCLabelTTF:create(tostring(p_playerInfo.uname),g_sFontName,21)
	nameLabel:setColor(ccc3(0xff,0xf6,0x00))
	nameLabel:setAnchorPoint(ccp(0.5,1))
	nameLabel:setPosition(ccp(playerSprite:getContentSize().width/2,-5))
	playerSprite:addChild(nameLabel)

	return playerSprite
end

--[[
	@des 	:创建tableView
	@param 	:
	@return :创建好的tableView
--]]
function createPersonalTableView(p_personalTable)
	--local personalReportInfo = 

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(555, 210)
		elseif fn == "cellAtIndex" then
			--用a1+1做下标创建cell
			a2 = createReportCell(p_personalTable[#p_personalTable - a1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #p_personalTable
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(555, 560))
end

--[[
	@des 	:查看战报回调
	@param 	:按钮tag
	@return :
--]]
function checkReportCallBack(tag)
	-- local battleCallBack = function(cbFlag,dictData,bRet)
	-- 	if not bRet then
	--         return
	--     end
	--     if cbFlag == "battle.getRecord" then
	--     	require "script/battle/BattleLayer"
	--     	BattleLayer.showBattleWithString(dictData.ret,nil,nil,nil,nil,nil,nil,nil,true)
	--     end
	-- end
	
	-- require "script/network/RequestCenter"
	-- local createParams = CCArray:create()
 --   	createParams:addObject(CCInteger:create(tag))
	-- local backMes = RequestCenter.battle_getRecord(battleCallBack,createParams)

	require "script/battle/BattleUtil"
	BattleUtil.playerBattleReportById(tag)
end