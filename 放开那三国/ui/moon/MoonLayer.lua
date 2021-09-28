-- Filename：	MoonLayer.lua
-- Author：		bzx
-- Date：		2015-04-27
-- Purpose：		水月之镜

module("MoonLayer", package.seeall)

btimport "script/cocostudio/ccs"
btimport "script/ui/moon/STMoonLayer"
btimport "script/ui/moon/MoonService"
btimport "script/ui/tip/RichAlertTip"

local _layer
local _touchPriority
local _zOrder
local _copyTabelView
local _dropTableView
local _curCopyId
local _curSmallCopyId
local _positionInfo
local _lastCopyBtn
local _copyCellSize
local _bossEffect
local _bossType

function show(touchPriority, zOrder, bossType)
	local requestCallback = function ( ... )
		_layer = create(touchPriority, zOrder, bossType)
		MainScene.changeLayer(_layer, "MoonLayer")
		MainScene.setMainSceneViewsVisible(false, false, false)
	end
	MoonService.getMoonInfo(requestCallback)
end

function create( touchPriority, zOrder, bossType)
	init(touchPriority, zOrder, bossType)
	_layer = STMoonLayer:create()
	loadedCopyTableView()
	loadedBtn()
	loadedDropTableView()
	refreshMapName()
	adaptive()
	refreshProgressLabel()
	return _layer
end

function init( touchPriority, zOrder, bossType )
	_touchPriority = touchPriority or -700
	_zOrder = zOrder or 180
	_curCopyId = 1
	_curSmallCopyId = 1
	_dropTableView = nil
	_bossEffect = nil
	_bossType = bossType or MoonData.kNormal
	initPositionInfo()
end

function playHighBossBgMusic( ... )
	AudioUtil.playBgm("audio/bgm/music12.mp3")
end

function closeHighBossBgMusic( ... )
	AudioUtil.playMainBgm()
end

function saveCurSmallCopyIndex( ... )
	-- local uid = UserModel.getUserUid()
	-- CCUserDefault:sharedUserDefault():setIntegerForKey("MoonLayerCurCellIndex" .. uid,  _curSmallCopyId)
	-- CCUserDefault:sharedUserDefault():flush()
end

function getCurHighSmallCopyIndex( ... )
	local moonInfo = MoonData.getMoonInfo()
	local curSmallCopyId = tonumber(moonInfo.max_nightmare_pass_copy)
	if curSmallCopyId < tonumber(moonInfo.max_pass_copy) then
		curSmallCopyId = curSmallCopyId + 1
	end
	return curSmallCopyId
end

function getCurSmallCopyIndex( ... )
	local moonInfo = MoonData.getMoonInfo()
	_curSmallCopyId = tonumber(moonInfo.max_pass_copy)
	_curSmallCopyId = _curSmallCopyId + 1
	if _curSmallCopyId > MoonData.getSmallCopyCount() then
		_curSmallCopyId = MoonData.getSmallCopyCount()
	end
	return _curSmallCopyId
	-- local uid = UserModel.getUserUid()
	-- _curSmallCopyId = CCUserDefault:sharedUserDefault():getIntegerForKey("MoonLayerCurCellIndex" .. uid)
	-- if _curSmallCopyId == 0 then
	-- 	_curSmallCopyId = 1
	-- end
	-- return _curSmallCopyId
end

-- 上面的副本按钮
function loadedCopyTableView( ... )
	_copyTabelView = _layer:getMemberNodeByName("copyTabelView")
	local cell = _layer:getMemberNodeByName("copyCell")
	cell:removeFromParent()
	_copyCellSize = cell:getContentSize()
	local pageCount = 1
	local moonInfo = MoonData.getMoonInfo()
	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return _copyCellSize
		elseif functionName == "cellAtIndex" then
			return createCopyCell(index)
		elseif functionName == "numberOfCells" then
			pageCount = math.ceil(tonumber(moonInfo.max_pass_copy + 1) / 5)
			if pageCount > MoonData.getCopyCount() then
				pageCount = MoonData.getCopyCount()
			end
			return pageCount
		elseif functionName == "moveEnd" then
			if _curCopyId ~= index then
				_curCopyId = index
				refreshMap()
				refreshMapName()
				refreshCopyBtn(1)
				saveCurSmallCopyIndex()
			end
		end
	end
	_copyTabelView:setEventHandler(eventHandler)
	_copyTabelView:setPageViewEnabled(true)
	_copyTabelView:setTouchPriority(_touchPriority - 10)
	_copyTabelView:reloadData()
	if _bossType == MoonData.kNormal then
		_curSmallCopyId = getCurSmallCopyIndex()
	else
		_curSmallCopyId = getCurHighSmallCopyIndex()
	end
	_curCopyId = math.ceil(_curSmallCopyId / 5)
	showCopyCell(_curCopyId)
	refreshCopyBtn((_curSmallCopyId - 1) % 5 + 1)
	local copyTvLeftSp = _layer:getMemberNodeByName("copyTvLeftSp")
	copyTvLeftSp:runAction(getArrowAction())
	local copyTvRightSp = _layer:getMemberNodeByName("copyTvRightSp")
	copyTvRightSp:runAction(getArrowAction())
	local borderListener = function (left, right, up, down)
		copyTvLeftSp:setVisible(left)
		copyTvRightSp:setVisible(right)
	end
	_copyTabelView:setBorderListener(borderListener)
end

-- 箭头的动画
function getArrowAction()
	local arrActions = CCArray:create()
	arrActions:addObject(CCFadeOut:create(1))
	arrActions:addObject(CCFadeIn:create(1))
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)
	return action
end

-- 刷新按钮状态
function refreshCopyBtn(btnIndex)
	local cell = _copyTabelView:cellAtIndex(_curCopyId)
	local cellNode = cell:getChildByName("cellNode")
	local btn1 = cellNode:getChildByName("btn" .. btnIndex)
	btn1:pushEvent(STButtonEvent.CLICKED)
end

-- 初始化地块的位置
function initPositionInfo()
	if _positionInfo ~= nil then
		return
	end
	_positionInfo = {}
	local copyCount = MoonData.getCopyCount()
	local dir = "db/moonCXml/"
	for i = 1, copyCount do
		local treasureCopymapDb = DB_Treasure_copymap.getDataById(i)
		if _positionInfo[treasureCopymapDb.land] == nil then
			_positionInfo[treasureCopymapDb.land] = {}
			for j = 1, 5 do
				_positionInfo[treasureCopymapDb.land][j] = {}
				local filename = string.format("%s_%d", treasureCopymapDb.land, j)
				btimport (dir .. filename, true)
				for k = 1, #MoonPosition.models.normal do
					local positionInfo = MoonPosition.models.normal[k]
					local positionId = tonumber(positionInfo.looks.look.armyID)
					if positionId > 200 then
						positionId = positionId % 100
					end
					_positionInfo[treasureCopymapDb.land][j][positionId] = {x = tonumber(positionInfo.x), y = tonumber(positionInfo.y)}
				end
			end
		end
	end
end

-- 刷新地图
function refreshMap( ... )
	local treasureCopymapDb = DB_Treasure_copymap.getDataById(_curCopyId)
	local bg = _layer:getMemberNodeByName("copyBg")
	bg:setFilename(string.format("images/moon/copy_bg/%s", treasureCopymapDb.map))
	local land = _layer:getMemberNodeByName("copyLand")
	land:removeAllChildren()
	land:setFilename(string.format("images/moon/land/%s/land.png", treasureCopymapDb.land))
	local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(_curSmallCopyId)
	local moonInfo = MoonData.getMoonInfo()
	local landSize = land:getContentSize()
	local gridInfos = MoonData.getGridInfos(_curSmallCopyId)
	local gridDbs = parseField(treasureSmallcopyDb.copy_nine, 2)
	local positionInfo = _positionInfo[treasureCopymapDb.land][(_curSmallCopyId - 1) % 5 + 1]
	for i = 1, table.count(gridInfos) do
		local gridStatus = tostring(gridInfos[tostring(i)])
		if gridStatus == MoonData.GridStatus.LOCKED then
			local landBlock = STMoonLayer:createLand1()
			land:addChild(landBlock)
			landBlock:setFilename(string.format("images/moon/land/%s/land_%d.png", treasureCopymapDb.land, i))
			landBlock:setAnchorPoint(ccp(1, 0))
			landBlock:setPosition(ccp(positionInfo[100 + i].x, landSize.height - positionInfo[100 + i].y))
			landBlock:setGray(true)
		elseif gridStatus == MoonData.GridStatus.OPENED then
			local gridDb = gridDbs[i]
			local btn = STMoonLayer:createButton1()
			land:addChild(btn, 1)
			btn:setClickCallback(gridCallback)
			btn:setTag(i)
			btn:setAnchorPoint(ccp(0.5, 0))
			btn:setPosition(ccp(positionInfo[i].x, landSize.height - positionInfo[i].y))
			btn:setSelectedScale(0.9)
			local nameLabel = btn:getChildByName("name1")
			-- 据点
			if gridDb[1] == 1 then
				local strongholdDb = DB_Stronghold.getDataById(gridDb[2])
				local icon = STSprite:create("images/base/hero/head_icon/" .. strongholdDb.icon)
				local normalSprite = btn:getNormalNode()
				normalSprite:removeAllChildren()
				normalSprite:addChild(icon)
				icon:setPercentPosition(0.5, 0.54)
				icon:setAnchorPoint(ccp(0.5, 0.5))
				normalSprite:setScale(0.8)
    			local starCount = strongholdDb.strongholdLevel
				normalSprite:setFilename(string.format("images/copy/ncopy/fortpotential/%d.png", starCount))
				local starsLayer = STLayer:create()
				normalSprite:addChild(starsLayer)
				starsLayer:setAnchorPoint(ccp(0.5, 0))
				starsLayer:setPercentPosition(0.5, 1)
				for i = 1, starCount do
					local starSprite = STSprite:create("images/moon/star.png")
					starsLayer:addChild(starSprite)
					starSprite:setPosition(ccp(starSprite:getContentSize().width * (i - 1), 0))
					if i == 1 then
						starsLayer:setContentSize(CCSizeMake(starSprite:getContentSize().width * starCount, starSprite:getContentSize().height))
					end
				end
				nameLabel:setString(strongholdDb.name)
				nameLabel:setColor(getSmallCopyNameColor(strongholdDb.strongholdLevel))
			-- 宝箱
			elseif gridDb[1] == 2 then
				btn:setNormalImage("images/moon/box_n.png")
				btn:setSelectedImage("images/moon/box_h.png")
				nameLabel:removeFromParent()
			end
		elseif gridStatus == MoonData.GridStatus.PASSED then

		end
	end
	refreshBossBody()
	refreshAttackBoss()
end

-- 得到名字颜色
function getSmallCopyNameColor( strongholdLevel )
	if strongholdLevel > 4 then
		strongholdLevel = 4
	end
	local colors = {ccc3(0xff, 0xff, 0xff), ccc3(0, 0xeb, 0x21), ccc3(0x51, 0xfb, 0xff), ccc3(255, 0, 0xe1)}
	return colors[strongholdLevel]
end

-- 加载掉落预览
function loadedDropTableView( ... )
	_dropTableView = _layer:getMemberNodeByName("dropTableView")
	local cellSize = CCSizeMake(100, 100)
	local eventHandler = function( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return cellSize
		elseif functionName == "cellAtIndex" then
			return createDropCell(index)
		elseif functionName == "numberOfCells" then
			local dropItems = MoonData.getDropItems(_curSmallCopyId, _bossType)
			return #dropItems
		end
	end
	_dropTableView:setEventHandler(eventHandler)
	_dropTableView:setTouchPriority(_touchPriority - 10)
	refreshDropTableView()
	local dropTvLeftSp = _layer:getMemberNodeByName("dropTvLeftSp")
	dropTvLeftSp:runAction(getArrowAction())
	local dropTvRightSp = _layer:getMemberNodeByName("dropTvRightSp")
	dropTvRightSp:runAction(getArrowAction())
	local borderListener = function (left, right, up, down)
		dropTvLeftSp:setVisible(left)
		dropTvRightSp:setVisible(right)
	end
	_dropTableView:setBorderListener(borderListener)
end

-- 刷新掉落预览
function refreshDropTableView( ... )
	if _dropTableView == nil then
		return
	end
	_dropTableView:reloadData()
end

-- 掉落预览Cell
function createDropCell( index )
	local dropItems = MoonData.getDropItems(_curSmallCopyId, _bossType)
	local dropItem = dropItems[index]
	local cell = CCTableViewCell:create()
	cell:setContentSize(CCSizeMake(100, 90))
	local itemInfo = ItemUtil.getItemsDataByStr(string.format("%d|%d|0", dropItem[1], dropItem[2]))
    local icon, itemName, itemColor = ItemUtil.createGoodsIcon(itemInfo[1], _touchPriority - 1, _zOrder + 10, _touchPriority - 50, nil,nil,nil,false)
    cell:addChild(icon)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon:setPosition(ccpsprite(0.5, 0.5, cell))
	local numberStr = ""
	if dropItem[4] == nil then
		numberStr = tostring(dropItem[3])
	else
		numberStr = string.format("%d~%d", dropItem[3], dropItem[4])
	end
	local numberLabel =  CCRenderLabel:create(numberStr , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
	numberLabel:setColor(ccc3(0x00,0xff,0x18))
	numberLabel:setAnchorPoint(ccp(0,0))
	local width = icon:getContentSize().width - numberLabel:getContentSize().width - 6
	numberLabel:setPosition(ccp(width,5))
	icon:addChild(numberLabel)
	return cell
end

-- 副本Cell
function createCopyCell(index)
	local cell = STTableViewCell:create()
	local cellNode = STMoonLayer:createCopyCell()
	cell:addChild(cellNode)
	cellNode:setPosition(ccp(0, 0))
	cellNode:setAnchorPoint(ccp(0, 0))
	cellNode:setName("cellNode")
	local polygons = {
		{{14, 14}, {91, 12}, {145, 156}, {14, 156}},
		{{10, 12}, {182, 12}, {128, 156}, {65, 156}},
		{{65, 12}, {128, 12}, {181, 156}, {12, 156}},
		{{10, 14}, {182, 12}, {128, 156}, {65, 156}},
		{{65, 12}, {142, 12}, {143, 156}, {12, 156}},
	}
	local copyId = index
	local treasureCopymapDb = DB_Treasure_copymap.getDataById(copyId)
	for i = 1, #polygons do
		local smallCopyIds = parseField(treasureCopymapDb.copy_id)
		local smallCopyId = smallCopyIds[i]
		local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(smallCopyId)
		local btn = cellNode:getChildByName("btn" .. i)
		local normalSprite = btn:getNormalNode()
		local normalFilename = string.format("images/moon/copy_item/%s_1.png", treasureSmallcopyDb.icon)
		normalSprite:setFilename(normalFilename)
		local SelectedSprite = btn:getSelectedNode()
		local SelectedFilename = string.format("images/moon/copy_item/%s_2.png", treasureSmallcopyDb.icon)
		SelectedSprite:setFilename(SelectedFilename)
		if not MoonData.copyIsOpened(smallCopyId) then
			local disabledSprite = STSprite:createGraySprite(normalFilename)
			btn:setDisabledNode(disabledSprite)
			btn:setEnabled(false)
		end
		local nameBg = btn:getChildByName(string.format("name%d_bg", i))
		local nameLabel = nameBg:getChildByName(string.format("name%d_label", i))
		nameLabel:setString(treasureSmallcopyDb.name)
		local polygon = polygons[i]
		for j = 1, #polygon do
			polygon[j][2] = 169 - polygon[j][2]
		end
		btn:setPolygon(polygon)
		btn:setTag(i)
		btn:setTouchPriority(_touchPriority - 1)
		btn:setClickCallback(selectedCopyCallback)
	end
	return cell
end

-- 选择副本的回调
function selectedCopyCallback(tag, btn)
	if not tolua.isnull(_lastCopyBtn) then
		_lastCopyBtn:setEnabled(true)
	end
	btn:setEnabled(false)
	_lastCopyBtn = btn
	_bossType = MoonData.kNormal
	local treasureCopymapDb = DB_Treasure_copymap.getDataById(_curCopyId)
	local smallCopyIds = parseField(treasureCopymapDb.copy_id)
	_curSmallCopyId = smallCopyIds[tag]
	saveCurSmallCopyIndex()
	refreshMap()
	refreshDropTableView()
	refreshProgressLabel()
	refreshChangeBossBtn()
	refreshSweepBtn()
end

-- 小据点回调
function gridCallback( tag )
	local gridIndex = tag
	local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(_curSmallCopyId)
	local gridDbs = parseField(treasureSmallcopyDb.copy_nine, 2)
	local gridDb = gridDbs[gridIndex]
	if gridDb[1] == 1 then
		local requestCallback = function ( data )
			local attackMonsterInfo = MoonData.getAttackMonsterInfo()
		 	local endCallFunc = function ( )
		 		refreshMap()
		 		refreshProgressLabel()
		 	end
			btimport "script/ui/moon/MoonFightResultLayer"
			local resultLayer = MoonFightResultLayer.create(data, _curSmallCopyId, gridIndex, _bossType, _touchPriority - 1000)
			require "script/battle/BattleLayer"
			BattleLayer.showBattleWithString(data.fightRet, endCallFunc, resultLayer, nil, nil, nil, nil, nil, false)
		end
		MoonService.attackMonster(requestCallback, _curSmallCopyId, gridIndex)
	elseif gridDb[1] == 2 then
		if ItemUtil.isBagFull() then
        	return 
    	end
		local requestCallback = function ( ... )
			local giftDb = DB_Treasure_copygift.getDataById(gridDb[2])
    		local itemsData = ItemUtil.getItemsDataByStr(giftDb.reward)
			refreshMap()
			refreshProgressLabel()
			require "script/ui/item/ReceiveReward"
            ReceiveReward.showRewardWindow(itemsData, nil, nil, _touchPriority - 50)
            ItemUtil.addRewardByTable(itemsData)
		end
		MoonService.openBox(requestCallback, _curSmallCopyId, gridIndex)
	end
end

-- 刷新上面的副本按钮
function refreshCopyTableView()
	_copyTabelView:updateCellAtIndex(_curCopyId)
end

-- 加载界面上的按钮
function loadedBtn( ... )
	-- 兵符
	local tallyBtn = _layer:getMemberNodeByName("tallyBtn")
	if DataCache.getSwitchNodeState(ksSwitchTally, false) then
		tallyBtn:setClickCallback(tallyCallback)
	else
		tallyBtn:setVisible(false)
	end
	-- 天工阁
	local moonShopBtn = _layer:getMemberNodeByName("moonShopBtn")
	moonShopBtn:setClickCallback(moonShopCallback)
	-- 返回
	local backBtn = _layer:getMemberNodeByName("backBtn")
	backBtn:setClickCallback(backCallback)
end

-- 刷新地图名字
function refreshMapName( ... )
	local nameLightSprite = _layer:getMemberNodeByName("nameLightSprite")
	local nameSprite = _layer:getMemberNodeByName("nameSprite")
	local treasureCopymapDb = DB_Treasure_copymap.getDataById(_curCopyId)
	local nameLightFilenames = {"green.png", "blue.png", "purple.png", "orange.png" , "red.png"}
	local nameLightFilename = "images/moon/" .. nameLightFilenames[treasureCopymapDb.title]
	nameLightSprite:setFilename(nameLightFilename)
	nameSprite:setFilename("images/moon/copy_title/" .. treasureCopymapDb.copy_name .. ".png")
end

-- 刷新挑战Boss操作层
function refreshAttackBoss( ... )
	local bossControlLayer = _layer:getMemberNodeByName("bossControlLayer")
	local attackCountLayer = _layer:getMemberNodeByName("attackCountLayer")
	local highAttackCountLayer = _layer:getMemberNodeByName("highAttackCountLayer")
	if not MoonData.bossIsShow(_curSmallCopyId) then
		bossControlLayer:setVisible(false)
		if not tolua.isnull(highAttackCountLayer) then
			highAttackCountLayer:setVisible(false)
		end
		attackCountLayer:setVisible(false)
		return
	end
	bossControlLayer:setVisible(true)
	if not tolua.isnull(highAttackCountLayer) then
		highAttackCountLayer:setVisible(true)
	end
	attackCountLayer:setVisible(true)

	-- 挑战Boss
	local attackBossBtn = _layer:getMemberNodeByName("attackBossBtn")
	attackBossBtn:setClickCallback(attackBossCallback)
	-- 增加挑战次数
	local addAttackCountBtn = _layer:getMemberNodeByName("addAttackCountBtn")
	addAttackCountBtn:setClickCallback(addAttackCountCallback)
	refreshAttackRemainCount()
	refreshSweepBtn()
	if DataCache.getSwitchNodeState(ksSwitchTally, false) then
		-- 增加恶梦挑战次数
		local highAttackCountLayer = _layer:getMemberNodeByName("highAttackCountLayer")
		if highAttackCountLayer == nil then
			local highAttackCountLayer = _layer:createHighAttackCountLayer(true)
			local topSprite = _layer:getMemberNodeByName("topSprite")
			topSprite:addChild(highAttackCountLayer)
		end
		local highAddAttackCountBtn = _layer:getMemberNodeByName("highAddAttackCountBtn")
		highAddAttackCountBtn:setClickCallback(addHighAttackCountCallback)
		refreshHighAttackRemainCount()

		-- 恶梦副本与普通副本的切换
		refreshChangeBossBtn()
		refreshSweepBtn()
	end
end

-- 刷新扫荡按钮
function refreshSweepBtn( ... )
	local sweepBtn = _layer:getMemberNodeByName("sweepBtn")
	sweepBtn:setVisible(false)
	sweepBtn:setClickCallback(sweepCallback)
	sweepBtn:getDisabledLabel():setColor(ccc3(0x7d, 0x7d, 0x7d))
	local moonInfo = MoonData.getMoonInfo()
	if _bossType == MoonData.kNormal then
		if _curSmallCopyId <= tonumber(moonInfo.max_pass_copy) then
			sweepBtn:setVisible(true)
			sweepBtn:setEnabled(MoonData.getAttackNum() > 0)
		end
	else
		if _curSmallCopyId <= tonumber(moonInfo.max_nightmare_pass_copy) then
			sweepBtn:setVisible(true)
			sweepBtn:setEnabled(MoonData.getHighAttackNum() > 0)
		end
	end
end

-- 扫荡的回调
function sweepCallback( ... )
	if ItemUtil.isBagFull() then
        return
    end
	local alertCallback = function ( isConfirm )
		if not isConfirm then
			return
		end
		local nightmare = nil
		if _bossType == MoonData.kNormal then
			nightmare = 0
		else
			nightmare = 1
		end
		local moonInfo = MoonData.getMoonInfo()
		local requestCallback = function ( data )
			local smallCopyId = 0
			if _bossType == MoonData.kNormal then
				MoonData.setAttackNum(0)
				refreshAttackRemainCount()
				smallCopyId = tonumber(moonInfo.max_pass_copy)
			else
				MoonData.setHighAttackNum(0)
				refreshHighAttackRemainCount()
				smallCopyId = tonumber(moonInfo.max_nightmare_pass_copy)
			end
			refreshSweepBtn()
			local smallCopyDb = DB_Treasure_smallcopy.getDataById(smallCopyId)
			strongholdDb = DB_Stronghold.getDataById(smallCopyDb.boss_id)
			require "script/ui/moon/MoonMultiplyFightResultLayer"
			MoonMultiplyFightResultLayer.show(strongholdDb.name, data, _touchPriority - 1000)
		end
		-- local data = {
		-- 	{{"1","0","13000"},{"21","0","9"},{"7","60106","7"},{"7","60107","8"},{"7","30112","1"}},
		-- 	{{"1","0","13000"},{"21","0","9"},{"7","60106","7"},{"7","60107","8"},{"7","30112","1"}},
		-- 	{{"1","0","13000"},{"21","0","9"},{"7","60106","7"},{"7","60107","8"},{"7","30112","1"}}
		-- }
		-- requestCallback(data)
		MoonService.sweep(requestCallback, nightmare)
	end
	local alertText = nil
	if _bossType == MoonData.kNormal then
		alertText = GetLocalizeStringBy("key_10366")
	else
		alertText = GetLocalizeStringBy("key_10367")
	end
	AlertTip.showAlert(alertText, alertCallback, true, nil)
end

-- 刷新恶梦副本与普通副本的切换按钮
function refreshChangeBossBtn( ... )
		
	if not DataCache.getSwitchNodeState(ksSwitchTally, false) then
		return
	end
	local bossControlLayer = _layer:getMemberNodeByName("bossControlLayer")
	local changeBossBtn = _layer:getMemberNodeByName("changeBossBtn")
	if changeBossBtn == nil then
		changeBossBtn = _layer:createChangeBossBtn(true)
		bossControlLayer:addChild(changeBossBtn)
		changeBossBtn:setClickCallback(changeBossCallback)
		changeBossBtn:setSelectedScale(0.9)
	end

	local normalImage = nil
	local selectedImage = nil
	if _bossType == MoonData.kNormal then
		if MoonData.highBossIsLocked(_curSmallCopyId) then
			-- 锁

			normalImage = "images/moon/locked.png"
			selectedImage = "images/moon/locked.png"
		else
			-- 梦魇

			normalImage = "images/moon/high.png"
			selectedImage = "images/moon/high.png"
		end
	else
		-- 水月

		normalImage = "images/moon/normal.png"
		selectedImage = "images/moon/normal.png"
	end
	changeBossBtn:setNormalImage(normalImage)
	changeBossBtn:setSelectedImage(selectedImage)
end

function changeBossCallback( ... )
	if _bossType == MoonData.kNormal then
		if MoonData.highBossIsLocked(_curSmallCopyId) then
			AnimationTip.showTip(GetLocalizeStringBy("key_10343"))
		else
			_bossType = MoonData.kHigh
			showHighBoss()
			refreshDropTableView()
			refreshChangeBossBtn()
			refreshSweepBtn()
		end
	else
		_bossType = MoonData.kNormal
		closeHighBoss()
		refreshDropTableView()
		refreshChangeBossBtn()
		refreshSweepBtn()
	end
end



-- 刷新剩余挑战次数
function refreshAttackRemainCount( ... )
	local attackCountLayer = _layer:getMemberNodeByName("attackCountLayer")
	local addAttackCountBtn = _layer:getMemberNodeByName("addAttackCountBtn")
	local moonInfo = MoonData.getMoonInfo()
	local attackCountLabel = _layer:getMemberNodeByName("attackCountLabel")
	local attackRemainCount = moonInfo.atk_num
	attackCountLabel:setString(string.format(GetLocalizeStringBy("key_10344"), attackRemainCount))
	addAttackCountBtn:setPositionX(attackCountLabel:getContentSize().width)
	local width = addAttackCountBtn:getContentSize().width + attackCountLabel:getContentSize().width
	attackCountLayer:setWidth(width)
end

-- 刷新恶梦副本剩余挑战次数
function refreshHighAttackRemainCount( ... )
	local highAttackCountLayer = _layer:getMemberNodeByName("highAttackCountLayer")
	if tolua.isnull(highAttackCountLayer) then
		return
	end
	local highAddAttackCountBtn = _layer:getMemberNodeByName("highAddAttackCountBtn")
	local moonInfo = MoonData.getMoonInfo()
	local highAttackCountLabel = _layer:getMemberNodeByName("highAttackCountLabel")
	local attackRemainCount = MoonData.getHighAttackNum()
	highAttackCountLabel:setString(string.format(GetLocalizeStringBy("key_10345"), attackRemainCount))
	highAddAttackCountBtn:setPositionX(highAttackCountLabel:getContentSize().width)
	local width = highAddAttackCountBtn:getContentSize().width + highAttackCountLabel:getContentSize().width
	highAttackCountLayer:setWidth(width)
end
-- 显示boss
function refreshBossBody( ... )
	local bossBgLayer = _layer:getMemberNodeByName("bossBgLayer")
	local bossLayer = _layer:getMemberNodeByName("bossLayer")
	if MoonData.bossIsShow(_curSmallCopyId) then
		bossBgLayer:setVisible(true)
		bossLayer:setVisible(true)
		local treasureSmallcopyDb = DB_Treasure_smallcopy.getDataById(_curSmallCopyId)
		local strongholdDb = DB_Stronghold.getDataById(treasureSmallcopyDb.boss_id)
		local armyIds = parseField(strongholdDb.army_ids_simple, 1)
		local armyId = armyIds[#armyIds]
		local bossTag = 1235
		bossLayer:removeChildByTag(bossTag)
		local hero = HeroUtil.getBossBoyImgByArmyId(armyId)
		bossLayer:addChild(hero)
		hero:setTag(bossTag)
		hero:setAnchorPoint(ccp(0.5, 0.5))
		hero:setPosition(ccpsprite(0.5, 0.5, bossLayer))
		if _bossType == MoonData.kNormal then
			closeHighBoss()
		else
			showHighBoss()
		end
	else
		bossBgLayer:setVisible(false)
		bossLayer:setVisible(false)
	end
end

-- 展示恶梦boss
function showHighBoss( ... )
	local bossLayer = _layer:getMemberNodeByName("bossLayer")
	if _bossEffect == nil then
		_bossEffect = XMLSprite:create("images/base/effect/ziseyanwu/ziseyanwu")
		bossLayer:addChild(_bossEffect, -1)
		_bossEffect:setScale(g_fBgScaleRatio / MainScene.elementScale + 0.01)
	else
		_bossEffect:setVisible(true)
	end
	playHighBossBgMusic()
end

-- 关闭恶梦boss
function closeHighBoss( ... )
	if _bossEffect then
		_bossEffect:setVisible(false)
		closeHighBossBgMusic()
	end
end

-- 返回的回调
function backCallback( ... )
	saveCurSmallCopyIndex()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/active/ActiveList"
    local  activeList = ActiveList.createActiveListLayer()
    MainScene.changeLayer(activeList, "activeList")
	MainScene.setMainSceneViewsVisible(true, false, true)
end

-- 天工阁回调
function moonShopCallback()
	btimport "script/ui/moon/MoonShopLayer"
	MoonShopLayer.show(_touchPriority - 100)
end

-- 兵符回调
function tallyCallback( ... )
	-- 兵符背包入口
	require "script/ui/shopall/tally/TallyShopLayer"
	TallyShopLayer.showLayer(_touchPriority - 100)
end

-- 挑战恶梦boss
function attackHighBoss( ... )
	if MoonData.highBossIsLocked(_curSmallCopyId) then
		AnimationTip.showTip(GetLocalizeStringBy("key_10343"))
		return
	end
	local moonInfo = MoonData.getMoonInfo()
	local maxPassCopy = tonumber(moonInfo.max_nightmare_pass_copy)
	if MoonData.getHighAttackNum() <= 0 then
		addHighAttackCountCallback()
		--AnimationTip.showTip(GetLocalizeStringBy("key_10073"))
		return
	end
	if ItemUtil.isBagFull() then
        return 
    end
	local requestCallback = function ( data )
		local endCallFunc = function ( ... )
			refreshHighAttackRemainCount()
			refreshSweepBtn()
			if maxPassCopy ~= tonumber(moonInfo.max_nightmare_pass_copy) then
				if tonumber(moonInfo.max_pass_copy) > maxPassCopy then
					AnimationTip.showTip(GetLocalizeStringBy("key_10346"))
				end
			end
			if _bossType == MoonData.kHigh then
				playHighBossBgMusic()
			end
		end
		btimport "script/ui/moon/MoonFightResultLayer"
		local resultLayer = MoonFightResultLayer.create(data, _curSmallCopyId, nil, _bossType, _touchPriority - 1000)
		require "script/battle/BattleLayer"
		BattleLayer.showBattleWithString(data.fightRet, endCallFunc, resultLayer, nil, nil, nil, nil, nil, false)
	end
	MoonService.attackBoss(requestCallback, _curSmallCopyId, _bossType)
end

-- 挑战Boss
function attackBossCallback( ... )
	if _bossType == MoonData.kNormal then
		attackBoss()
	else
		attackHighBoss()
	end
end

function attackBoss( ... )
	local moonInfo = MoonData.getMoonInfo()
	local maxPassCopy = tonumber(moonInfo.max_pass_copy)
	if tonumber(moonInfo.atk_num) <= 0 then
		addAttackCountCallback()
		return
	end
	if ItemUtil.isBagFull() then
        return 
    end
	local requestCallback = function ( data )
		local endCallFunc = function ( ... )
			refreshAttackRemainCount()
			refreshSweepBtn()
			if maxPassCopy ~= tonumber(moonInfo.max_pass_copy) then
				local btnIndex = _curSmallCopyId % 5 + 1
				if btnIndex == 1 then
					if _curCopyId < MoonData.getCopyCount() then
						_curCopyId = _curCopyId + 1
						showCopyCell(_curCopyId)
					end
				else
					refreshCopyTableView()
				end
				refreshProgressLabel()
				refreshCopyBtn(btnIndex)
			end
		end
		btimport "script/ui/moon/MoonFightResultLayer"
		local resultLayer = MoonFightResultLayer.create(data, _curSmallCopyId, nil, _bossType, _touchPriority - 1000)
		require "script/battle/BattleLayer"
		BattleLayer.showBattleWithString(data.fightRet, endCallFunc, resultLayer, nil, nil, nil, nil, nil, false)
	end
	MoonService.attackBoss(requestCallback, _curSmallCopyId, _bossType)
end

function showCopyCell(cellIndex )
	_copyTabelView:reloadData()
	local offset = _copyTabelView:getContentOffset()
	offset.x = -_copyCellSize.width * (cellIndex - 1)
	_copyTabelView:setContentOffset(offset)
	_copyTabelView:updateCellAtIndex(cellIndex)
	refreshMapName()
end

-- 刷新秘境探索度
function refreshProgressLabel( ... )
	local progressLabel = _layer:getMemberNodeByName("progressLabel")
	if MoonData.bossIsShow(_curSmallCopyId) then
		progressLabel:setVisible(false)
		return
	else
		progressLabel:setVisible(true)
	end
    local gridInfos = MoonData.getGridInfos(_curSmallCopyId)
    local gridCount = table.count(gridInfos)
    local progress = 0
    for gridIndex, gridStatus in pairs(gridInfos) do
        if tostring(gridStatus) == MoonData.GridStatus.PASSED then
            progress = progress + 1
        end
    end
    progressLabel:setString(string.format(GetLocalizeStringBy("key_10217"), progress, gridCount))
end

-- 购买挑战Boss的次数
function addAttackCountCallback( ... )
	local moonInfo = MoonData.getMoonInfo()
	local curBuyCount = tonumber(moonInfo.buy_num)
	local treasureCopy = DB_Treasure_copy.getDataById(1)
	local priceInfos = parseField(treasureCopy.price, 2)
	local buyCountLimit = #priceInfos
	if curBuyCount >= buyCountLimit then
		AnimationTip.showTip(GetLocalizeStringBy("key_10219"))
		return
	end
	local cost = priceInfos[curBuyCount + 1][2]
	local richInfo = {
		elements = {
			{
				["type"] = "CCSprite",
                image = "images/common/gold.png"
			},
			{
				text = cost
			},
			{
				text = 1
			}
		}
	}
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10081"), richInfo)
	local alertCallback = function ( isConfirm, _argsCB )
		if not isConfirm then
			return
		end
		if cost > UserModel.getGoldNumber() then
			require "script/ui/tip/LackGoldTip"
	    	LackGoldTip.showTip()
	    	return
		end
		local requestCallback = function ( ... )
			UserModel.addGoldNumber(-cost)
			refreshHighAttackRemainCount()
			refreshAttackRemainCount()
			refreshSweepBtn()
		end
		MoonService.addAttackNum(requestCallback)
	end
	RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"),nil, nil, nil, nil, nil, nil, true)
end

-- 购买挑战恶梦Boss的次数
function addHighAttackCountCallback( ... )
	local moonInfo = MoonData.getMoonInfo()
	local curBuyCount = tonumber(moonInfo.nightmare_buy_num)
	local treasureCopy = DB_Treasure_copy.getDataById(1)
	local priceInfos = parseField(treasureCopy.price2, 2)
	local buyCountLimit = #priceInfos
	if curBuyCount == buyCountLimit then
		AnimationTip.showTip(GetLocalizeStringBy("key_10219"))
		return
	end
	local cost = priceInfos[curBuyCount + 1][2]
	
	local richInfo = {
		elements = {
			{
				["type"] = "CCSprite",
                image = "images/common/gold.png"
			},
			{
				text = cost
			},
			{
				text = 1
			}
		}
	}
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10081"), richInfo)
	local alertCallback = function ( isConfirm, _argsCB )
		if not isConfirm then
			return
		end
		if cost > UserModel.getGoldNumber() then
			require "script/ui/tip/LackGoldTip"
	    	LackGoldTip.showTip()
	    	return
		end
		local requestCallback = function ( ... )
			UserModel.addGoldNumber(-cost)
			refreshHighAttackRemainCount()
			refreshSweepBtn()
		end
		MoonService.addAttackNum(requestCallback, 1)
	end
	RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"),nil, nil, nil, nil, nil, nil, true)
end

-- 0点刷新
function refresh( ... )
	if tolua.isnull(_layer) then
		return
	end
	MoonData.resetMoonInfo()
	refreshAttackRemainCount()
	refreshHighAttackRemainCount()
	refreshSweepBtn()
end

-- 适配
function adaptive()
	local copyBg = _layer:getMemberNodeByName("copyBg")
	copyBg:setScale(g_fBgScaleRatio)
	local topSprite = _layer:getMemberNodeByName("topSprite")
	topSprite:setScale(g_fScaleX)
	local bossLayer = _layer:getMemberNodeByName("bossLayer")
	bossLayer:setScale(MainScene.elementScale)
	local bottom = _layer:getMemberNodeByName("bottom")
	bottom:setScale(g_fScaleX)
	local bossBgLayer = _layer:getMemberNodeByName("bossBgLayer")
	bossBgLayer:setContentSize(g_winSize)
	local copyLand = _layer:getMemberNodeByName("copyLand")
	copyLand:setScale(MainScene.elementScale)
end