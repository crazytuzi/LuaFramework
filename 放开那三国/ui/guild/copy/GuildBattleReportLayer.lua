-- Filename：	GuildBattleReportLayer.lua
-- Author：		Zhang zihang
-- Date：		2014-2-22
-- Purpose：		军团战报面板

module("GuildBattleReportLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"

local _priority
local _zOrder
local _reportNum

local _myScale
local _mySize

local _isVisible

local _bgLayer
local _viewBg

local _reportInfo

local _tableViewWidth
local _tableViewHeight

local _ccMenuTag
local _ccBarTag

local _allData
local _showFightForce = nil

local function init()
	_priority        = nil
	_zOrder          = nil
	_reportNum       = 0
	
	_myScale         = nil
	_mySize          = nil
	
	_isVisible       = nil
	
	_bgLayer         = nil
	_viewBg          = nil
	
	_reportInfo      = {}
	_allData         = {}
	
	_tableViewWidth  = nil
	_tableViewHeight = nil
	_showFightForce  = nil
	_ccMenuTag       = 9988
	_ccBarTag        = 2000
end

local function layerToucCb(eventType, x, y)
	return true
end

local function closeAction()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

local function createBackGround()
	local reportBg = CCScale9Sprite:create("images/common/viewbg1.png")
    reportBg:setContentSize(_mySize)
    reportBg:setScale(_myScale)
    reportBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    reportBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(reportBg)

    local bgSize = reportBg:getContentSize()

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(bgSize.width*0.5, bgSize.height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	reportBg:addChild(titleBg)

	local titleSize = titleBg:getContentSize()

	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_3414"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setPosition(ccp(titleSize.width*0.5,titleSize.height*0.5))
	titleBg:addChild(labelTitle)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-1)
    reportBg:addChild(menu)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(bgSize.width*1.03,bgSize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeAction)
    menu:addChild(closeBtn)

    _viewBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _viewBg:setContentSize(CCSizeMake(555,615))
    _viewBg:setPosition(ccp(bgSize.width/2,bgSize.height/2))
    _viewBg:setAnchorPoint(ccp(0.5,0.5))
    reportBg:addChild(_viewBg)

    _tableViewWidth = _viewBg:getContentSize().width
    _tableViewHeight = _viewBg:getContentSize().height
end

function battleBack(cbFlag, dictData, bRet)
	if not bRet then
        return
    end
    if cbFlag == "battle.getRecord" then
    	require "script/battle/BattleLayer"
    	BattleLayer.showBattleWithString(dictData.ret,nil,nil,nil,nil,nil,nil,nil,true)
    end
end

local function checkReportAction(tag,item)
	require "script/network/RequestCenter"
	local createParams = CCArray:create()
   	createParams:addObject(CCInteger:create(tag))
	local backMes = RequestCenter.battle_getRecord(battleBack,createParams)
	print(backMes)
end

local function getImageByServer(serverId)
	if tonumber(serverId) >= 2000 then
		local memberTable = {}
		memberTable = _allData.server.team1.memberList
		for i = 1,#memberTable do
			if serverId == tonumber(memberTable[i].uid) then
				return memberTable[i].htid,memberTable[i].name,memberTable[i].dress
			end
		end
		
		memberTable = {}
		memberTable = _allData.server.team2.memberList
		for i = 1,#memberTable do
			if serverId == tonumber(memberTable[i].uid) then
				return memberTable[i].htid,memberTable[i].name,memberTable[i].dress
			end
		end
	else
		require "db/DB_Army"
		require "db/DB_Team"
		require "db/DB_Heroes"
		local teamName = _allData.server.team2.memberList[serverId].name
		local armyInfo = DB_Army.getDataById(tonumber(teamName))
		local teamInfo = DB_Team.getDataById(tonumber(armyInfo.monster_group))
		local monsterTid = teamInfo.copyTeamShowId
		local monsterInfo = DB_Heroes.getDataById(tonumber(monsterTid))
		local heroName = monsterInfo.name

		return monsterTid,heroName
	end
end

local function createCell(nowTable,cellWidth,cellHeight)
	local ccCell = CCTableViewCell:create()

	local bgSprite
	local titleSprite
	local flowerSprite
	local resultSprite

	if nowTable.result == true then
		bgSprite = CCScale9Sprite:create("images/guild/battlereport/winbg.png")
		titleSprite = CCSprite:create("images/guild/battlereport/wintitle.png")
		flowerSprite = CCSprite:create("images/guild/battlereport/flower.png")
		resultSprite = CCSprite:create("images/guild/battlereport/win.png")
	else
		bgSprite = CCScale9Sprite:create("images/guild/battlereport/winbg.png")
		titleSprite = CCSprite:create("images/guild/battlereport/losstitle.png")
		flowerSprite = CCSprite:create("images/guild/battlereport/break.png")
		resultSprite = CCSprite:create("images/guild/battlereport/loss.png")
	end

	bgSprite:setContentSize(CCSizeMake(cellWidth,cellHeight))
	bgSprite:setAnchorPoint(ccp(0,0))
	ccCell:addChild(bgSprite)

	flowerSprite:setAnchorPoint(ccp(0.5,0.5))
	flowerSprite:setPosition(ccp(cellWidth/2,cellHeight/2+20))
	bgSprite:addChild(flowerSprite)

	resultSprite:setAnchorPoint(ccp(0.5,0.5))
	resultSprite:setPosition(ccp(cellWidth/2,cellHeight/2+20))
	bgSprite:addChild(resultSprite)

	titleSprite:setAnchorPoint(ccp(0.5,1))
	titleSprite:setPosition(ccp(cellWidth/2,cellHeight+10))
	bgSprite:addChild(titleSprite)

	local ccTitleSize = titleSprite:getContentSize()

	local roundNum = CCRenderLabel:create(GetLocalizeStringBy("key_2886") .. nowTable.no .. GetLocalizeStringBy("key_1464"), g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
	roundNum:setAnchorPoint(ccp(0.5,0.5))
	roundNum:setPosition(ccp(ccTitleSize.width/2,ccTitleSize.height/2))
	roundNum:setColor(ccc3(0xff,0xe4,0x00))
	titleSprite:addChild(roundNum)

	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	bgSprite:addChild(menuBar,1, _ccMenuTag)
	
	local checkReportButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(160, 64),GetLocalizeStringBy("key_2849"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	checkReportButton:setAnchorPoint(ccp(0.5, 0))
    checkReportButton:setPosition(ccp(cellWidth/2, 10))
    checkReportButton:registerScriptTapHandler(checkReportAction)
    menuBar:addChild(checkReportButton,1,tonumber(nowTable.bId))
    menuBar:setTouchPriority(_priority-3)

    if _isVisible == false then
    	checkReportButton:setVisible(false)
    end

    require "script/model/utils/HeroUtil"
    print("nowTable.atk",nowTable.atk)
    local playerDress = {}
    local playerImageId , playerName , playerDress = getImageByServer(nowTable.atk)
    print("playerImageId , playerName , playerDress",playerImageId , playerName , playerDress)
    require "script/model/hero/HeroModel"
    local genderId = HeroModel.getSex(playerImageId)
	local playerImage
	print(GetLocalizeStringBy("key_1073"))
	print_t(playerDress)
	print(playerDress[1])
	if (table.count(playerDress) == 0 ) then
		playerImage = HeroUtil.getHeroIconByHTID(playerImageId)
	else
		print("i am here")
		playerImage = HeroUtil.getHeroIconByHTID(playerImageId,playerDress["1"],genderId)
	end

    playerImage:setAnchorPoint(ccp(0,1))
    playerImage:setPosition(ccp(35,cellHeight-35))
    bgSprite:addChild(playerImage)

    local atkName = CCRenderLabel:create(playerName, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    atkName:setColor(ccc3(0xff,0xff,0xff))
    atkName:setAnchorPoint(ccp(0.5,1))
    atkName:setPosition(ccp(playerImage:getContentSize().width/2,-3))
    playerImage:addChild(atkName)

    if tonumber(nowTable.def) >= 2000 then
    	local playerDress = {}
	    local playerImageId , playerName , playerDress = getImageByServer(nowTable.def)
	    require "script/model/hero/HeroModel"
	    local genderId = HeroModel.getSex(playerImageId)
		local playerImage
		print(GetLocalizeStringBy("key_1073"))
		print_t(playerDress)
		print(playerDress[1])
		if (table.count(playerDress) == 0 ) then
			playerImage = HeroUtil.getHeroIconByHTID(playerImageId)
		else
			print("i am here")
			playerImage = HeroUtil.getHeroIconByHTID(playerImageId,playerDress["1"],genderId)
		end

	    playerImage:setAnchorPoint(ccp(1,1))
	    playerImage:setPosition(ccp(cellWidth-35,cellHeight-35))
	    bgSprite:addChild(playerImage)

	    local atkName = CCRenderLabel:create(playerName, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	    atkName:setColor(ccc3(0xff,0xff,0xff))
	    atkName:setAnchorPoint(ccp(0.5,1))
	    atkName:setPosition(ccp(playerImage:getContentSize().width/2,-3))
	    playerImage:addChild(atkName)
    else
	    local monsterImageId , monsterName = getImageByServer(nowTable.def)
	    local monsterImage = HeroUtil.getHeroIconByHTID(tonumber(monsterImageId))
	    monsterImage:setAnchorPoint(ccp(1,1))
	    monsterImage:setPosition(ccp(cellWidth-35,cellHeight-35))
	    bgSprite:addChild(monsterImage)

	    local defName = CCRenderLabel:create(monsterName, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	    defName:setColor(ccc3(0xff,0xff,0xff))
	    defName:setAnchorPoint(ccp(0.5,1))
	    defName:setPosition(ccp(monsterImage:getContentSize().width/2,-3))
	    monsterImage:addChild(defName)
	end

	return ccCell
end

local function createContent()
	local cellWidth = 530
	local cellHeight = 175
	
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r

		if (fn == "cellSize") then
			r = CCSizeMake(cellWidth,cellHeight+20)
		elseif (fn == "cellAtIndex") then
			local len = _reportNum
			local nowTable = _reportInfo[len-a1]
			a2 = createCell(nowTable,cellWidth,cellHeight)
			r = a2
		elseif (fn == "numberOfCells") then
			r = _reportNum
		end
		
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(cellWidth, _tableViewHeight))
	tableView:setAnchorPoint(ccp(0,0))
	tableView:setBounceable(true)

	_viewBg:addChild(tableView)
	tableView:setPosition(ccp((_tableViewWidth-cellWidth)/2,0))
	tableView:setTouchPriority(_priority-2)
end

local function createUI()
	createBackGround()

	createContent()
end

local function isInTeamOne(id)
	local isIn = false
	local teamOne = _allData.server.team1.memberList
	for i = 1 , #teamOne do
		if tonumber(id) == tonumber(teamOne[i].uid) then
			isIn = true
		end
	end

	return isIn
end

--allData 战斗信息
--isInBattle 布尔值，是否在战斗中调用
--priority 优先级
--zOrder z轴
function showLayer(allData,isInBattle,priority,zOrder, showFightForce)
	init()

	_allData = allData

	print(GetLocalizeStringBy("key_2616"))
	print_t(_allData)

	--传入信息处理
	_priority = priority or -550
	_zOrder = zOrder or 999
	_showFightForce = showFightForce
	local allBattleReport = {}
	local arrProcessInfo = {}
	arrProcessInfo = _allData.server.arrProcess
	for i = 1,#arrProcessInfo do
		for j = 1,#arrProcessInfo[i] do
			if (not table.isEmpty(arrProcessInfo[i][j])) then
				_reportNum = _reportNum+1
				local everyBattle = {}
				if tonumber(arrProcessInfo[i][j].attacker) >= 2000 then
					if isInTeamOne(tonumber(arrProcessInfo[i][j].attacker)) then
						everyBattle.playerId = tonumber(arrProcessInfo[i][j].attacker)
						everyBattle.battleResult = arrProcessInfo[i][j].appraise
						everyBattle.monsterId = tonumber(arrProcessInfo[i][j].defender)
					else
						everyBattle.playerId = tonumber(arrProcessInfo[i][j].defender)
						if arrProcessInfo[i][j].appraise ~= "F" then
							everyBattle.battleResult = "F"
						else
							everyBattle.battleResult = "SSS"
						end
						everyBattle.monsterId = tonumber(arrProcessInfo[i][j].attacker)
					end
				else
					everyBattle.playerId = tonumber(arrProcessInfo[i][j].defender)
					if arrProcessInfo[i][j].appraise ~= "F" then
						everyBattle.battleResult = "F"
					else
						everyBattle.battleResult = "SSS"
					end
					everyBattle.monsterId = tonumber(arrProcessInfo[i][j].attacker)
				end
				everyBattle.battleId = arrProcessInfo[i][j].brid
				allBattleReport[#allBattleReport+1] = everyBattle
			end
		end
	end

	_isVisible = not isInBattle

	--循环初始化战报表信息
	for i = 1,_reportNum do
		local tempT = {}
		tempT.no = i

		if allBattleReport[i].battleResult ~= "F" then
			tempT.result = true
		else
			tempT.result = false
		end

		tempT.atk = allBattleReport[i].playerId
		tempT.def = allBattleReport[i].monsterId
		tempT.bId = allBattleReport[i].battleId

		table.insert(_reportInfo,tempT)
	end

	--创建底层图
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))

	_bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,_priority,true)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    _myScale = MainScene.elementScale
	_mySize = CCSizeMake(600,700)

	createUI()
end
