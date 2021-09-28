-- Filename：	PurgatoryRewardPreviewLayer.lua
-- Author：		bzx
-- Date：		2015-06-11
-- Purpose：		炼狱排行奖励预览

module("PurgatoryRewardPreviewLayer", package.seeall)

btimport "script/ui/purgatorychallenge/STPurgatoryRewardPreviewLayer"
btimport "script/ui/purgatorychallenge/PurgatoryServes"
btimport "script/ui/purgatorychallenge/PurgatoryData"
btimport "db/DB_Lianyutiaozhan_reward"

local _layer
local _touchPriority
local _zOrder
local _cellSize
local _tableView

function show(p_touchPriority, p_zOrder)
	local _layer = create(p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function create( p_touchPriority, p_zOrder )
	init(p_touchPriority, p_zOrder)
	_layer = STPurgatoryRewardPreviewLayer:create()
	_layer:setSwallowTouch(true)
	_layer:setTouchPriority(_touchPriority)
	_layer:setTouchEnabled(true)
	loadTipLabel()
	loadTableView()
	loadBtn()
	adaptive()
	return _layer
end

function init( p_touchPriority, p_zOrder )
	_touchPriority = p_touchPriority or -800
	_zOrder = p_zOrder or 1000
end

function loadBtn( ... )
	local closeBtn = _layer:getMemberNodeByName("closeBtn")
	closeBtn:setClickCallback(closeCallback)
	closeBtn:setTouchPriority(_touchPriority - 1)
end

function closeCallback( ... )
	_layer:removeFromParent()
end

function getRewardCount( ... )
	return table.count(DB_Lianyutiaozhan_reward.Lianyutiaozhan_reward)
end

function loadTipLabel( ... )
	local tipLabel = _layer:getMemberNodeByName("tipLabel")
	local richInfo = tipLabel:getRichInfo()
	richInfo.elements = {
		{
			text = GetLocalizeStringBy("zzh_1285"),
			color = ccc3(0x08, 0x78, 0x00)
		}
	}
	richInfo = GetNewRichInfo(GetLocalizeStringBy("key_10266"), richInfo)
	tipLabel:setRichInfo(richInfo)
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
			return getRewardCount()
		end
	end
	_tableView:setEventHandler(eventHandler)
	_tableView:setTouchPriority(_touchPriority - 10)
	_tableView:reloadData()
end

function createCell( index )
	local rewardDb = DB_Lianyutiaozhan_reward.getDataById(index)
	local cell = STPurgatoryRewardPreviewLayer:createCell()
	cell:setAnchorPoint(ccp(0, 0))
	cell:setPosition(ccp(0, 0))

	local cellBg = cell:getChildByName("cellBg")
	local titleBg = cellBg:getChildByName("titleBg")
	local rewardNameLabel = titleBg:getChildByName("rewardNameLabel")
	rewardNameLabel:setString(rewardDb.desc)
	local rankTextFormat = {GetLocalizeStringBy("key_10251"), GetLocalizeStringBy("key_10252"), GetLocalizeStringBy("key_10253")}

	local innerBg = cellBg:getChildByName("innerBg")
	local rewardTableView = innerBg:getChildByName("rewardTableView")
	local rewardItems = ItemUtil.getItemsDataByStr(rewardDb.reward)
	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return CCSizeMake(125, 125)
		elseif functionName == "cellAtIndex" then
			return createRewardCell(rewardItems, index)
		elseif functionName == "numberOfCells" then
			return #rewardItems
		end
	end
	rewardTableView:setEventHandler(eventHandler)
	rewardTableView:setTouchPriority(_touchPriority - 10)
	rewardTableView:reloadData()
	return cell
end

function createRewardCell( p_rewardItems, p_index )
	local cell = STTableViewCell:create()
    cell:setContentSize(CCSizeMake(125, 125))

	local icon, itemName, itemColor = ItemUtil.createGoodsIcon(p_rewardItems[p_index], _touchPriority - 1, 9999, _touchPriority - 50, nil,nil,nil,false)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    cell:addChild(icon)
    icon:setPosition(ccpsprite(0.5, 0.58, cell))

 	local itemNameLabel = CCRenderLabel:create(itemName, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
    itemNameLabel:setColor(itemColor)
    itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
    itemNameLabel:setPosition(icon:getContentSize().width*0.5,-icon:getContentSize().height*0.15)
    icon:addChild(itemNameLabel)

    return cell
end

function adaptive( ... )
	_layer:setContentSize(g_winSize)
	local bgLayer = _layer:getMemberNodeByName("bgLayer")
	bgLayer:setContentSize(g_winSize)
	local bgSprite = _layer:getMemberNodeByName("bgSprite")
	bgSprite:setScale(MainScene.elementScale)
end