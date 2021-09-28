-- Filename：	AthenaPreviewLayer.lua
-- Author：		bzx
-- Date：		2015-06-02
-- Purpose：		星魂录

module("AthenaPreviewLayer", package.seeall)

btimport "script/ui/athena/STAthenaPreviewLayer"

local _layer
local _touchPriority
local _zOrder
local _cellSize
local _tableView

function show(touchPriority, zOrder)
	_layer = create(touchPriority, zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function create( touchPriority, zOrder )
	init(touchPriority, zOrder)
	_layer = STAthenaPreviewLayer:create()
	_layer:setSwallowTouch(true)
	_layer:setTouchPriority(_touchPriority)
	_layer:setTouchEnabled(true)
	loadTableView()
	loadBtn()
	adaptive()
	return _layer
end

function init( touchPriority, zOrder )
	_touchPriority = touchPriority or -800
	_zOrder = zOrder or 1000
end

function loadBtn( ... )
	local backBtn = _layer:getMemberNodeByName("backBtn")
	backBtn:setClickCallback(backCallback)
	backBtn:setTouchPriority(_touchPriority - 1)
end

function backCallback( ... )
	_layer:removeFromParent()
end

function loadTableView( ... )
	_tableView = _layer:getMemberNodeByName("tableView")
	local cell = _layer:getMemberNodeByName("cell")
	_cellSize = cell:getContentSize()
	cell:removeFromParent()
	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return _cellSize
		elseif functionName == "cellAtIndex" then
			return createCell(index)
		elseif functionName == "numberOfCells" then
			return AthenaData.totalMapNum()
		end
	end
	_tableView:setEventHandler(eventHandler)
	_tableView:setTouchPriority(_touchPriority - 10)
	_tableView:reloadData()
end

function createCell( index )
	local cell = STTableViewCell:create()
	local stCell = STAthenaPreviewLayer:createCell()
	cell:addChild(stCell)
	stCell:setAnchorPoint(ccp(0, 0))
	stCell:setPosition(ccp(0, 0))

	local skillType = AthenaData.getSkillType(index)
	local treeDb = DB_Tree.getDataById(index)
	local cellBg = stCell:getChildByName("cellBg")

	local floorNameLabel = cellBg:getChildByName("floorNameLabel")
	floorNameLabel:setString(treeDb.tree_name)

	--特殊技能按钮层
	local SSBgMenu = CCMenu:create()
	SSBgMenu:setAnchorPoint(ccp(0,0))
	SSBgMenu:setPosition(ccp(0,0))
	--SSBgMenu:setTouchPriority(kTouchPirority - 1)
	stCell:addChild(SSBgMenu, 1)

	local SSId = nil
	if skillType == AthenaData.kAwakeSkillType then
		SSId = treeDb.awake_ability
	else
		SSId = AthenaData.getSSkillId(treeDb)[1]
	end
	local icon = cellBg:getChildByName("icon")
	local iconAnchorPoint = icon:getAnchorPoint()
	local iconPosition = ccp(icon:getPositionX(), icon:getPositionY() + 8)
	icon:removeFromParent()
	--特殊技能按钮
	local SSMenuItem = AthenaUtils.getSpecialSkillMenuItem(index)
	SSMenuItem:setAnchorPoint(iconAnchorPoint)
	SSMenuItem:setPosition(iconPosition)
	SSBgMenu:addChild(SSMenuItem,1,SSId)	

	local itemSize = SSMenuItem:getContentSize()
	local skillInfo = AthenaData.getSSDBInfo(SSId, skillType)

	local nameLabel = cellBg:getChildByName("nameLabel")
	nameLabel:setString(skillInfo.name)

	local descLabel = cellBg:getChildByName("descLabel")
	local des = nil
	if skillType == AthenaData.kAwakeSkillType then
		des = skillInfo.des
	else
		des = string.sub(skillInfo.des, 9)
	end
	descLabel:setString(des)
	descLabel:setDimensions(CCSizeMake(300, 0))
	descLabel:setHorizontalAlignment(kCCTextAlignmentLeft)

	local normalSprite = cellBg:getChildByName("normalSprite")
	normalSprite:setVisible(skillType == AthenaData.kNormaoSkillType)
	local angerSprite = cellBg:getChildByName("angerSprite")
	angerSprite:setVisible(skillType == AthenaData.kAngrySkillType)
	local awakeSprite = cellBg:getChildByName("awakeSprite")
	awakeSprite:setVisible(skillType == AthenaData.kAwakeSkillType)
	return cell
end

function adaptive( ... )
	_layer:setContentSize(g_winSize)
	local bgLayer = _layer:getMemberNodeByName("bgLayer")
	bgLayer:setContentSize(g_winSize)
	local bgSprite = _layer:getMemberNodeByName("bgSprite")
	bgSprite:setScale(MainScene.elementScale)
end