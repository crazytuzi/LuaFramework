-- Filename：    ComprehendBatchLayer.lua
-- Author：      bzx
-- Date：        2015-04-30
-- Purpose：     批量领悟觉醒

module("ComprehendBatchLayer", package.seeall)

local _layer
local _zOrder
local _heroData
local _currentAwakenIndex
local _currentCostIndex
local _tabelView
local _costInfos
local _checkIndex
local _touchPriority

function show(p_heroHid, p_currentAwakenIndex, p_currentCostIndex, p_touchPriority, p_zOrder )
	_layer = create(p_heroHid, p_currentAwakenIndex, p_currentCostIndex, p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, p_zOrder)
end

function init(p_heroHid, p_currentAwakenIndex, p_currentCostIndex, p_touchPriority, p_zOrder )
	_layer = nil
	_zOrder = p_zOrder or 100
	_heroData = HeroModel.getHeroByHid(p_heroHid)
	_currentAwakenIndex = p_currentAwakenIndex
	_currentCostIndex = p_currentCostIndex
	_costInfos = ComprehendLayer.getCostInfo()
	_checkIndex = 0
	_touchPriority = p_touchPriority or -200
end

function create(p_heroHid, p_currentAwakenIndex, p_currentCostIndex, p_touchPriority, p_zOrder )
	init(p_heroHid, p_currentAwakenIndex, p_currentCostIndex, p_touchPriority, p_zOrder)
	require "script/ui/biography/STBatchComprehendLayer"
	_layer = STBatchComprehendLayer:create()
	_layer:setSwallowTouch(true)
	_layer:setTouchPriority(_touchPriority)
	_layer:setTouchEnabled(true)
	loadTableView()
	loadButton()
	refreshCurAwaken()
	refreshComprehendTimes()
	adaptive()
	return _layer
end

function refreshCurAwaken( ... )
	local curAwakenNameLabel = _layer:getMemberNodeByName("curAwakenNameLabel")
	local curAwakenDescLabel = _layer:getMemberNodeByName("curAwakenDescLabel")
	local curAwakenId = _heroData.talent.confirmed[tostring(_currentAwakenIndex)]
	if curAwakenId ~= nil then
		local curAwakenDb = DB_Hero_refreshgift.getDataById(curAwakenId)
		curAwakenNameLabel:setString(curAwakenDb.name)
		local nameColor = ComprehendLayer.getNameColorByStar(curAwakenDb.level)
		curAwakenNameLabel:setColor(nameColor)
		curAwakenDescLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
		curAwakenDescLabel:setString(curAwakenDb.des)
		curAwakenDescLabel:setDimensions(CCSizeMake(518, 0))
	else
		curAwakenNameLabel:setString(" ")
		curAwakenDescLabel:setString(GetLocalizeStringBy("key_8007"))
		curAwakenDescLabel:setColor(ccc3(0xff, 0xff, 0xff))
	end
end

function loadTableView( ... )
	_tabelView = _layer:getMemberNodeByName("ListView_1")
	local cell = _layer:getMemberNodeByName("cell")
	cell:removeFromParent()
	local cellSize = cell:getContentSize()
	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return cellSize
		elseif functionName == "cellAtIndex" then
			local cell = CCTableViewCell:create()
			local cellNode = STBatchComprehendLayer:createCell()
			cell:addChild(cellNode)
			cellNode:setPosition(ccp(0, 0))
			local awakenId = _heroData.talent.to_confirm[tostring(_currentAwakenIndex)][index]
			local awakenDb = DB_Hero_refreshgift.getDataById(awakenId)
			local awakenNameLabel = cellNode:getChildByName("awakenNameLabel")
			awakenNameLabel:setString(awakenDb.name)
			local nameColor = ComprehendLayer.getNameColorByStar(awakenDb.level)
			awakenNameLabel:setColor(nameColor)
			local awakenDescLabel = cellNode:getChildByName("awakenDescLabel")
			awakenDescLabel:setString(awakenDb.des)
			awakenDescLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
			awakenDescLabel:setDimensions(CCSizeMake(410, 200))
			local checkButton = cellNode:getChildByName("checkButton")
			checkButton:setScrollView(_tabelView)
			checkButton:setTag(index)
			checkButton:setClickCallback(checkCallback)
			checkButton:setTouchPriority(_touchPriority -  1)
			if index == _checkIndex then
				local checkTagSprite = STSprite:create("images/common/checked.png")
				checkButton:addChild(checkTagSprite)
			end
			return cell
		elseif functionName == "numberOfCells" then
			return getAwakenCount()
		end
	end
	_tabelView:setEventHandler(eventHandler)
	_tabelView:setTouchPriority(_touchPriority - 10)
	refreshTableView()
end

function refreshComprehendTimes( ... )
	local timesLabel = _layer:getMemberNodeByName("comprehendTimes")
	local count = getAwakenCount()
	timesLabel:setString(string.format(GetLocalizeStringBy("key_10203"), count))
end


function getAwakenCount( ... )
	local count = 0
	if _heroData.talent.to_confirm[tostring(_currentAwakenIndex)] ~= nil then
		count = #_heroData.talent.to_confirm[tostring(_currentAwakenIndex)] 
	end
	return count
end

function loadButton( ... )
	local closeButton = _layer:getMemberNodeByName("Button_1")
	closeButton:setClickCallback(closeCallback)
	closeButton:setTouchPriority(_touchPriority - 1)

	local replaceButton = _layer:getMemberNodeByName("replaceButton")
	replaceButton:setClickCallback(replaceCallback)
	replaceButton:setTouchPriority(_touchPriority - 1)

	local comprehendButton = _layer:getMemberNodeByName("comprehendButton")
	comprehendButton:setClickCallback(comprehendCallback)
	comprehendButton:setTouchPriority(_touchPriority - 1)
end

function checkCallback(tag, button )
	local lastCheckIndex = _checkIndex
	_checkIndex = tag
	_tabelView:updateCellAtIndex(lastCheckIndex)
	_tabelView:updateCellAtIndex(_checkIndex)
end

function refreshTableView()
	_tabelView:reloadData()
end

function closeCallback( ... )
	local callback = function(p_confirmed)
		if not p_confirmed then
			return
		end
		if not table.isEmpty(_heroData.talent.to_confirm[tostring(_currentAwakenIndex)]) then
			local requestCallback = function ( cbFlag, dictData, bRet )
				if not bRet then
					return
				end
				_heroData.talent.to_confirm = {}
				_layer:removeFromParent()
				ComprehendLayer.refreshAfterComprehend()
			end
			local args = Network.argsHandler(_heroData.hid, _currentAwakenIndex)
	   	 	RequestCenter.heroKeepTalent(requestCallback, args)
   	 	else
   	 		_layer:removeFromParent()
   	 	end
	end
	
	local maxLevel = getMaxLevel()
    if maxLevel >= 8 then
	    local richInfo =
	    {
	        elements =
	        {
	            {
	                text = GetLocalizeStringBy("key_10204"),
	            },
	        }
	    }
	    require "script/ui/tip/RichAlertTip"
	    RichAlertTip.showAlert(richInfo, callback, true, nil, GetLocalizeStringBy("key_2864"))
	else
		callback(true)
	end
end

function replaceCallback( ... )
	if _checkIndex == 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_10205"))
		return
	end
	local awakenId = _heroData.talent.to_confirm[tostring(_currentAwakenIndex)][_checkIndex]
	local args = Network.argsHandler(_heroData.hid, _currentAwakenIndex, awakenId)
	local requestCallback = function(cbFlag, dictData, bRet)
		if not bRet then
		end
		_heroData.talent.confirmed[tostring(_currentAwakenIndex)] = _heroData.talent.to_confirm[tostring(_currentAwakenIndex)][_checkIndex]
		_heroData.talent.to_confirm = {}
		_layer:removeFromParent()
		ComprehendLayer.refreshAfterComprehend()
	end
	RequestCenter.heroActivateTalentConfirm(requestCallback, args)
end

function comprehend(heroData, currentAwakenIndex, currentCostIndex, costInfos, callback)
	local costInfo = costInfos[currentCostIndex]
	local jewelTimes = -1
	if costInfo.jewel > 0 then
	 	jewelTimes = math.floor(UserModel.getJewelNum() / costInfo.jewel)
	end
	local goldTimes = -1
	if costInfo.gold > 0 then
		goldTimes = math.floor(UserModel.getGoldNumber() / costInfo.gold)
	end
	local itemCount = ItemUtil.getCacheItemNumBy(costInfo.item_id)
	local itemTimes = -1
	if costInfo.item_count > 0 then
		itemTimes = math.floor(itemCount / costInfo.item_count)
	end
	local timesInfo = {jewelTimes, goldTimes, itemTimes}
	local times = 10
	for i = 1, #timesInfo do
		if timesInfo[i] ~= -1 then
			if timesInfo[i] < times then
				times = timesInfo[i]
			end
		end
	end
	local args = Network.argsHandler(heroData.hid, currentAwakenIndex, currentCostIndex, 1, times)
	local requestCallback = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		heroData.talent.to_confirm[tostring(currentAwakenIndex)] = dictData.ret
		local jewelCount = costInfo.jewel * times
		UserModel.addJewelNum(-jewelCount)
		local goldCount = costInfo.gold * times
		UserModel.addGoldNumber(-goldCount)
		local itemCount = costInfo.item_count * times
		ComprehendLayer.addItemCount(-itemCount)
		if callback ~= nil then
			_checkIndex = 0
			callback()
		end
	end
    RequestCenter.heroComprehendTalent(requestCallback, args)
end

function comprehendCallback( ... )
	local itemIsEnough = ComprehendLayer.checkItemIsfull(_currentCostIndex)
    if not itemIsEnough then
        return
    end
    function callback( p_confirmed )
    	if not p_confirmed then
    		return
    	end
    	local refresh = function ( ... )
			refreshTableView()
			refreshComprehendTimes()
			ComprehendLayer.refreshAfterComprehend()
		end
		comprehend(_heroData, _currentAwakenIndex, _currentCostIndex, _costInfos, refresh)
    end
    local maxLevel = getMaxLevel()
    if maxLevel >= 8 then
    	local richInfo =
	    {
	        elements =
	        {
	            {
	                text = GetLocalizeStringBy("key_10206"),
	            },
	        }
	    }
	    require "script/ui/tip/RichAlertTip"
	    RichAlertTip.showAlert(richInfo, callback, true, nil, GetLocalizeStringBy("key_2864"))
    else
    	callback(true)
    end
end

function getMaxLevel()
	local maxLevel = 0
	if _heroData.talent.to_confirm[tostring(_currentAwakenIndex)] ~= nil then
		for i = 1, #_heroData.talent.to_confirm[tostring(_currentAwakenIndex)] do
			local awakenId = _heroData.talent.to_confirm[tostring(_currentAwakenIndex)][i]
			local awakenDb = DB_Hero_refreshgift.getDataById(awakenId)
			if awakenDb.level > maxLevel then
				maxLevel = awakenDb.level
			end
		end
	end
	return maxLevel
end

function adaptive( ... )
	local bgLayer = _layer:getMemberNodeByName("bgLayer")
	bgLayer:setContentSize(g_winSize)
	local bgSprite = _layer:getMemberNodeByName("bgSprite")
	bgSprite:setScale(MainScene.elementScale)
end

