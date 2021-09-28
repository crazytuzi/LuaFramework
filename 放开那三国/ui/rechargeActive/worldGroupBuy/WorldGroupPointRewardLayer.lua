-- Filename：    WorldGroupPointRewardLayer.lua
-- Author：      bzx
-- Date：        2015-8-11
-- Purpose：    跨服团购积分奖励

module ("WorldGroupPointRewardLayer", package.seeall)

btimport "script/ui/rechargeActive/worldGroupBuy/STWorldGroupPointRewardLayer"
btimport "script/ui/rechargeActive/worldGroupBuy/WorldGroupData"
btimport "script/ui/rechargeActive/worldGroupBuy/WorldGroupService"


local _layer = nil
local _touchPriority = nil
local _zOrder = nil
local _tableView = nil
local _cellSize = nil
local _innerCellSize = CCSizeMake(125, 125)
local _rewardList = nil

function show(p_touchPriority, p_zOrder)
	_layer = create(p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function create( p_touchPriority, p_zOrder )
	init(p_touchPriority, p_zOrder)

	_layer = STWorldGroupPointRewardLayer:create()
	_layer:setBgColor(ccc3(0, 0, 0))
	_layer:setBgOpacity(200)
	_layer:setSwallowTouch(true)
    _layer:setTouchPriority(_touchPriority)
    _layer:setTouchEnabled(true)

	loadTableView()
	loadButton()
	adaptive()
	return _layer
end

function init( p_touchPriority, p_zOrder )
	_touchPriority = p_touchPriority or -400
	_zOrder = p_zOrder or 500
end

function initRewardList( ... )
	_rewardList = table.hcopy(WorldGroupData.getPointRewardList(), {})
	table.sort(_rewardList, rewardListComparator)
end

function rewardListComparator( reward1, reward2 )
	local pointValue = 1
	local receivedValue = 2
	local value1 = 0
	local value2 = 0
	if tonumber(reward1.point) < tonumber(reward2.point) then
		value1 = value1 + pointValue
	else
		value2 = value2 + pointValue
	end

	if WorldGroupData.rewardIsReceived(reward1.point) then
		value1 = value1 - receivedValue
	end
	if WorldGroupData.rewardIsReceived(reward2.point) then
		value2 = value2 - receivedValue
	end
	return value1 > value2
end

function loadTableView( ... )
	_tableView = _layer:getMemberNodeByName("tableView")
	local cell = _layer:getMemberNodeByName("cell")
	_cellSize = cell:getContentSize()
	cell:removeFromParent()
	initRewardList()
	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return _cellSize
		elseif functionName == "cellAtIndex" then
			return createCell(index)
		elseif functionName == "numberOfCells" then
			return #_rewardList
		end
	end
	_tableView:setEventHandler(eventHandler)
	_tableView:setTouchPriority(_touchPriority - 10)
	_tableView:reloadData()
end

function createCell( p_index )
	local cell = STTableViewCell:create()
	local stCell = STWorldGroupPointRewardLayer:createCell()
	cell:addChild(stCell)
	stCell:setAnchorPoint(ccp(0, 0))
	stCell:setPosition(ccp(0, 0))

	local rewardData = _rewardList[p_index]
	local cellBg = stCell:getChildByName("cellBg")
	local titleBg = cellBg:getChildByName("titleBg")
	local rewardNameLabel = titleBg:getChildByName("rewardNameLabel")
	rewardNameLabel:setString(string.format(GetLocalizeStringBy("key_10292"), rewardData.point))

	local innerBg = cellBg:getChildByName("innerBg")
	local rewardTableView = innerBg:getChildByName("rewardTableView")
	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return _innerCellSize
		elseif functionName == "cellAtIndex" then
			return createInnerCell(rewardData.items[index])
		elseif functionName == "numberOfCells" then
			return #rewardData.items
		end
	end
	rewardTableView:setEventHandler(eventHandler)
	rewardTableView:setTouchPriority(_touchPriority - 10)
	rewardTableView:reloadData()

	local userInfo = WorldGroupData.getUserInfo()
	local receiveBtn = cellBg:getChildByName("receiveBtn")
	receiveBtn:setClickCallback(receiveCallback)
	receiveBtn:setTouchPriority(_touchPriority - 5)
	receiveBtn:setTag(p_index)


	local receivedSprite = cellBg:getChildByName("receivedSprite")
	receivedSprite:setVisible(false)

	if tonumber(userInfo.point) < tonumber(rewardData.point) then
		receiveBtn:setEnabled(false)
		local receiveDisabledLabel = receiveBtn:getDisabledLabel()
		receiveDisabledLabel:setColor(ccc3(125, 125, 125))
	else
		local isReceived = WorldGroupData.rewardIsReceived(rewardData.point)
		if isReceived then
			receiveBtn:removeFromParent()
			receivedSprite:setVisible(true)
		end
	end

	local progressLabel = cellBg:getChildByName("progressLabel")
	local richInfo = progressLabel:getRichInfo()
	richInfo.elements = {}
	local element = {}
	element.text = string.format("%s/%s", userInfo.point, rewardData.point)
	if tonumber(userInfo.point) >= tonumber(rewardData.point) then
		element.color = ccc3(0x00, 0xff, 0x18)
	end
	table.insert(richInfo.elements, element)
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10293"), richInfo)
	progressLabel:setRichInfo(newRichInfo)
	return cell
end

function receiveCallback(p_tag)
	if(WorldGroupControler.isInTwelve(true))then
		return
	end
	if ItemUtil.isBagFull(true) then
		close()
		return
	end
	local rewardIndex = p_tag
	local rewardData = _rewardList[rewardIndex]
	local requestCallback = function ( ... )
		initRewardList()
		_tableView:reloadData()
		require "script/ui/item/ReceiveReward"
	    ReceiveReward.showRewardWindow(rewardData.items, nil, nil, _touchPriority - 50)
	    WorldGroupLayer.setRewardTip(WorldGroupData.ifPointReward())
	end
	WorldGroupService.getPointReward(rewardData.point, requestCallback)
end

function createInnerCell( p_itemData )
	local cell = STTableViewCell:create()
    cell:setContentSize(_innerCellSize)

	local icon, itemName, itemColor = ItemUtil.createGoodsIcon(p_itemData, _touchPriority - 5, 10001, _touchPriority - 50, nil,nil,nil,false)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    cell:addChild(icon)
    icon:setPosition(ccpsprite(0.5, 0.58, cell))

 	local itemNameLabel = CCRenderLabel:create(itemName, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
    itemNameLabel:setColor(itemColor)
    itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
    itemNameLabel:setPosition(icon:getContentSize().width*0.5,-icon:getContentSize().height*0.13)
    icon:addChild(itemNameLabel)

    return cell
end

function loadButton( ... )
	local closeBtn = _layer:getMemberNodeByName("backBtn")
	closeBtn:setTouchPriority(_touchPriority - 5)
	closeBtn:setClickCallback(closeCallback)
end

function closeCallback( ... )
	close()
end

function close( ... )
	_layer:removeFromParent()
end

function adaptive( ... )
	local bgSprite = _layer:getMemberNodeByName("bgSprite")
	bgSprite:setScale(MainScene.elementScale)
end
function refreshTableView( ... )
	if(tolua.isnull(_layer) )then
		return
	end
	initRewardList()
	_tableView:reloadData()

end