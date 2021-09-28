-- Filename：    WorldGroupBuyRecord.lua
-- Author：      bzx
-- Date：        2015-8-10
-- Purpose：    跨服团购记录

module ("WorldGroupBuyRecordLayer", package.seeall)

btimport "script/ui/rechargeActive/worldGroupBuy/STWorldGroupBuyRecordLayer"
btimport "script/ui/rechargeActive/worldGroupBuy/WorldGroupData"


local _layer = nil
local _touchPriority = nil
local _zOrder = nil
local _tableView = nil
local _cellSize = nil
local _recordDatas = nil
local _goodsId = nil

function show(p_goodsId, p_touchPriority, p_zOrder)
	_layer = create(p_goodsId, p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function create(p_goodsId, p_touchPriority, p_zOrder )
	init(p_goodsId, p_touchPriority, p_zOrder)

	_layer = STWorldGroupBuyRecordLayer:create()
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

function init(p_goodsId, p_touchPriority, p_zOrder )
	_goodsId = p_goodsId
	_touchPriority = p_touchPriority or -400
	_zOrder = p_zOrder or 500
end

function loadTableView( ... )
	_tableView = _layer:getMemberNodeByName("tableView")
	local cell = _layer:getMemberNodeByName("cell")
	_cellSize = cell:getContentSize()
	cell:removeFromParent()
	-- if _goodsId then
	-- 	_recordDatas = WorldGroupData.getRecordById(_goodsId)
	-- else
		_recordDatas = WorldGroupData.getRecord()
	--end
	print("_recordDatas===")
	print_t(_recordDatas)
	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return _cellSize
		elseif functionName == "cellAtIndex" then
			return createCell(index)
		elseif functionName == "numberOfCells" then
			return #_recordDatas
		end
	end
	_tableView:setEventHandler(eventHandler)
	_tableView:setTouchPriority(_touchPriority - 10)
	_tableView:setVerticalFillOrder(kCCTableViewFillBottomUp)
	_tableView:reloadData()
end

function createCell( p_index )
	local recordData = _recordDatas[p_index]
	local cell = STTableViewCell:create()
	local stCell = STWorldGroupBuyRecordLayer:createCell()
	cell:addChild(stCell)
	stCell:setAnchorPoint(ccp(0, 0))
	stCell:setPosition(ccp(0, 0))

	local cellBg = stCell:getChildByName("cellBg")
	local timeLabel = cellBg:getChildByName("timeLabel")
	local textBg = cellBg:getChildByName("cellTextBg")
	local textLabel = textBg:getChildByName("textLabel")

	timeLabel:setString(TimeUtil.getTimeFormatYMDHMS(tonumber(recordData.buyTime)))
	local textColor = ccc3(0xff, 0xf6, 0x00)
	local richInfo = textLabel:getRichInfo()
	richInfo.alignment = 1
	richInfo.width = textBg:getContentSize().width - 30
	richInfo.elements = {}

	local activeData = WorldGroupData.getActiveDataByID(recordData.goodId)
	local itemDatas = ItemUtil.getItemsDataByStr(activeData.item)
	local itemData = itemDatas[1]
	local itemName = activeData.good_name

	local element ={
			text = itemName,
			color = textColor,
	}
	table.insert(richInfo.elements, element)
	
	local costText = ""
	if tonumber(recordData.gold) ~= 0 then
		costText = costText .. string.format(GetLocalizeStringBy("lic_1504"), recordData.gold)
	end
	if tonumber(recordData.coupon) ~= 0 then
		costText = costText .. "," .. string.format(GetLocalizeStringBy("key_10288"), recordData.coupon)
	end
	element = {
		text = costText,
		color = textColor,
	}
	table.insert(richInfo.elements, element)
	local point = tonumber(recordData.gold) + tonumber(recordData.coupon)
	element = {
		text = string.format(GetLocalizeStringBy("key_10289"), point),
		color = textColor,
	}
	table.insert(richInfo.elements, element)


	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10290"), richInfo)
	textLabel:setRichInfo(newRichInfo)
	return cell
end

function loadButton( ... )
	local closeBtn = _layer:getMemberNodeByName("backBtn")
	closeBtn:setTouchPriority(_touchPriority - 5)
	closeBtn:setClickCallback(closeCallback)
end

function closeCallback( ... )
	_layer:removeFromParent()
end

function adaptive( ... )
	local bgSprite = _layer:getMemberNodeByName("bgSprite")
	bgSprite:setScale(MainScene.elementScale)
end