-- Filename：	TravelShopLayer.lua
-- Author：		bzx
-- Date：		2015-9-6
-- Purpose：		云游商人

module ("TravelShopLayer", package.seeall)

btimport "script/ui/rechargeActive/travelShop/STTravelShopLayer"
btimport "script/ui/rechargeActive/travelShop/TravelShopService"
btimport "script/ui/tip/RichAlertTip"
btimport "script/utils/BTNumerLabel"
require "script/ui/rechargeActive/travelShop/TravelShopBuyLayer"
local TAG_ZKDJ = 1
local TAG_CZYH = 2
local TAG_PTTQ = 3

local _layer = nil
local _lastSelectedBtn = nil
local _selectedLayer = nil
local _progressSprite = nil
local _progressLabel = nil
local _progressScrollView = nil
local _progressEffect = nil
local _touchPriority = nil
local _travelShopInfo = nil
local _zkdjCellSize = nil
local _pttqCellSize = nil
local _curTravelShopConfig = nil
local _lastBuyCount = nil
local _curShowTag = TAG_ZKDJ
local _pttqTableView = nil
local _goodsTableView = nil
local _goodsTableViewOffset = nil
local _payBackGoldCount = 0
local __pttqTipSprite= nil

function create(p_touchPriority)
	initData(p_touchPriority)
	_layer = STTravelShopLayer:create()
	loadSelectBtn()
	loadDescBtn()
	adaptive()
	local rpcCallback = function ( ... )
		_travelShopInfo = TravelShopData.getTravelShopInfo()
		showZkdj()
	end
	TravelShopService.getInfo(rpcCallback)
	return _layer
end

function initData( p_touchPriority)
	_touchPriority = p_touchPriority or -400
	_curShowTag = TAG_ZKDJ
end

-- 活动说明按钮
function loadDescBtn( ... )
	local descBtn = _layer:getMemberNodeByName("descBtn")
	descBtn:setClickCallback(descCallback)
	descBtn:setScale(MainScene.elementScale * descBtn:getScale())
end

-- 活动说明的回调
function descCallback( ... )
	btimport "script/utils/DescLayer"
	DescLayer.show(GetLocalizeStringBy("lcy_10048"), 6, _touchPriority - 50, 1000)
end

function loadSelectBtn( ... )
	-- 折扣道具
	local zkdjSelectBtn = _layer:getMemberNodeByName("zkdjSelectBtn")
	zkdjSelectBtn:setTag(TAG_ZKDJ)
	zkdjSelectBtn:setTouchPriority(_touchPriority - 10)
	zkdjSelectBtn:setClickCallback(selectedCallback)
	zkdjSelectBtn:getNormalLabel():setColor(ccc3(0xb9, 0x6e, 0x00))

	-- 充值优惠
	local czyhSelectBtn = _layer:getMemberNodeByName("czyhSelectBtn")
	czyhSelectBtn:setTag(TAG_CZYH)
	czyhSelectBtn:setTouchPriority(_touchPriority - 10)
	czyhSelectBtn:setClickCallback(selectedCallback)
	czyhSelectBtn:getNormalLabel():setColor(ccc3(0xb9, 0x6e, 0x00))
	
	-- 普天同庆
	local pttqSelectBtn = _layer:getMemberNodeByName("pttqSelectBtn")
	pttqSelectBtn:setTag(TAG_PTTQ)
	pttqSelectBtn:setTouchPriority(_touchPriority - 10)
	pttqSelectBtn:setClickCallback(selectedCallback)
	pttqSelectBtn:getNormalLabel():setColor(ccc3(0xb9, 0x6e, 0x00))
	refreshPttqTip()
end

function refreshPttqTip( ... )
	if TravelShopData.canReceive() then
		local pttqSelectBtn = _layer:getMemberNodeByName("pttqSelectBtn")
		if tolua.isnull(_pttqTipSprite) then
			_pttqTipSprite = CCSprite:create("images/common/tip_2.png")
			pttqSelectBtn:addChild(_pttqTipSprite)
			_pttqTipSprite:setAnchorPoint(ccp(0.5, 0.5))
			_pttqTipSprite:setPosition(ccpsprite(0.85, 0.8, pttqSelectBtn))
		end
	else
		if not tolua.isnull(_pttqTipSprite) then
			_pttqTipSprite:removeFromParentAndCleanup(true)
		end
	end
 end

-- 显示折扣道具界面
function showZkdj( ... )
	local zkdjSelectBtn = _layer:getMemberNodeByName("zkdjSelectBtn")
	selectedCallback(TAG_ZKDJ, zkdjSelectBtn)
end

-- 页签的回调
function selectedCallback(p_tag, p_button )
	if not tolua.isnull(_lastSelectedBtn) then
		_lastSelectedBtn:setEnabled(true)
	end
	p_button:setEnabled(false)
	_lastSelectedBtn = p_button
	if p_tag == TAG_PTTQ then
		local rpcCallback = function ( ... )
			_travelShopInfo = TravelShopData.getTravelShopInfo()
			showSelectedLayer(p_tag)
			_lastBuyCount = tonumber(_travelShopInfo.sum)
		end
		TravelShopService.getInfo(rpcCallback)
	else
		showSelectedLayer(p_tag)
	end
end

-- 通过界面的tag来显示当前选中的界面
function showSelectedLayer( p_tag )
	if not tolua.isnull(_goodsTableView) then
		_goodsTableViewOffset = _goodsTableView:getContentOffset()
	end
	if not tolua.isnull(_selectedLayer) then
		_selectedLayer:removeFromParent()
	end
	if p_tag == TAG_ZKDJ then
		_selectedLayer = createZkdjLayer()
	elseif p_tag == TAG_CZYH then
		_selectedLayer = createCzyhLayer()
	elseif p_tag == TAG_PTTQ then
		_selectedLayer = createPttqLayer()
	end
	local contentBgSprite = _layer:getMemberNodeByName("contentBgSprite")
	contentBgSprite:addChild(_selectedLayer)
	_selectedLayer:setContentSize(contentBgSprite:getContentSize())
	_curShowTag = p_tag
end

-- 创建折扣道具界面
function createZkdjLayer()
	local layer = _layer:createZkdjLayer(true)
	_progressSprite = _layer:getMemberNodeByName("zkdjProgressSprite")
	_progressLabel = _layer:getMemberNodeByName("zkdjProgressLabel")
	_progressScrollView = _layer:getMemberNodeByName("zkdjProgressScrollView")
	refreshProgress()
	loadZkdjGoodsTableView()
	loadZkdjYhczBtn()
	loadZkdjTimeTipLabel()
	openZkdjRefreshTimer(layer)
	initPayBackGoldCount()
	return layer
end

-- 如果开启优惠充值了，优惠时间过了要刷新界面
function openZkdjRefreshTimer( p_layer )
	if not TravelShopData.isOpenCzyh() then
		return
	end
	local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(TravelShopData.getCzyhRemainTime()))
    local refreshZkdj = function  ( ... )
    	TravelShopData.resetScoreProgress()
    	showSelectedLayer(_curShowTag)
    end
    actionArray:addObject(CCCallFunc:create(refreshZkdj))
    p_layer:runAction(CCSequence:create(actionArray))
end

-- 活动时间
function loadZkdjTimeTipLabel( ... )
	local timeTipLabel = _layer:getMemberNodeByName("timeTipLabel")
	local startYMD = TimeUtil.getTimeFormatChnYMDHM(TravelShopData.getStartTime())
	local endYMD = TimeUtil.getTimeFormatChnYMDHM(TravelShopData.getEndTime())
	timeTipLabel:setString(string.format(GetLocalizeStringBy("key_10309"), startYMD, endYMD))
end

-- 折扣道具界面的充值优惠按钮
function loadZkdjYhczBtn( ... )
	local yhczBtn = _layer:getMemberNodeByName("yhczBtn")
	yhczBtn:setTouchPriority(_touchPriority - 10)
	yhczBtn:setClickCallback(yhczCallback)

	local zkdjReceiveBtn = _layer:getMemberNodeByName("zkdjReceiveBtn")
	if TravelShopData.canReceiveCzyhReward() then
		zkdjReceiveBtn:setClickCallback(czyhReceiveCallback)
 		zkdjReceiveBtn:setTouchPriority(_touchPriority - 10)
		yhczBtn:removeFromParent()
	else
		yhczBtn:setClickCallback(yhczCallback)
		yhczBtn:setTouchPriority(_touchPriority - 10)
		if TravelShopData.isOpenCzyh() then
			local effect = XMLSprite:create("images/base/effect/chongzhiyouhui/chongzhiyouhui")
			yhczBtn:addChild(effect)
			effect:setPosition(ccpsprite(0.5, 0.5, yhczBtn))
		end
		zkdjReceiveBtn:removeFromParent()
	end
end

-- 充值优惠按钮回调
function yhczCallback( ... )
	if not TravelShopData.isOpenCzyh() then
		AnimationTip.showTip(GetLocalizeStringBy("key_10310"))
		return
	end
	require "script/ui/shop/RechargeLayer"
	local rechargeSucceedCallback = function ( ... )
		if tolua.isnull(_layer) then
			RechargeLayer.registerChargeGoldCb(nil)
			return
		end
		local rpcCallback = function ( ... )
			showSelectedLayer(_curShowTag)
		end
		TravelShopService.getInfo(rpcCallback)
	end
	RechargeLayer.registerChargeGoldCb(rechargeSucceedCallback)
   	RechargeLayer.showLayer( nil, nil, true )
end

-- 折扣道具列表
function loadZkdjGoodsTableView( ... )
	local goodsTableView = _layer:getMemberNodeByName("goodsTableView")
	goodsTableView:setHeight(g_winSize.height / MainScene.elementScale * 0.366)
    local goodsCell = _layer:getMemberNodeByName("goodsCell")
    _zkdjCellSize = _zkdjCellSize or goodsCell:getContentSize()
    goodsCell:removeFromParent()
    _curTravelShopConfig = TravelShopData.getCurTravelShopConfig()

    local cellCount = math.ceil(#_curTravelShopConfig / 3)
    local eventHandler = function ( functionName, tableView, index, cell )
        if functionName == "cellSize" then
            return _zkdjCellSize
        elseif functionName == "cellAtIndex" then
            return createZkdjGoodsCell(index)
        elseif functionName == "numberOfCells" then
            return cellCount
        end
    end
    goodsTableView:setEventHandler(eventHandler)
    goodsTableView:setTouchPriority(_touchPriority - 5)
    goodsTableView:reloadData()
    if _goodsTableViewOffset ~= nil then
    	goodsTableView:setBounceable(false)
    	goodsTableView:setContentOffset(_goodsTableViewOffset)
    	goodsTableView:setBounceable(true)
    end
    _goodsTableView = goodsTableView
end

-- 创建折扣道具cell
function createZkdjGoodsCell(p_index)
	local cell = STTravelShopLayer:createGoodsCell()
	cell:setPosition(ccp(0, 0))
	for i = 1, 3 do
		local config = _curTravelShopConfig[(p_index - 1) * 3 + i]
		if config == nil then
			break
		end
		local goodsSprite = STTravelShopLayer:createGoodsSprite()
		cell:addChild(goodsSprite)
		goodsSprite:setAnchorPoint(ccp(0, 0.5))
		goodsSprite:setPosition(ccp(210 * (i - 1), _zkdjCellSize.height * 0.5))
		local itemData = ItemUtil.getItemsDataByStr(config.item)[1]
		local icon, itemName, itemColor = ItemUtil.createGoodsIcon(itemData, _touchPriority - 5, 10001, _touchPriority - 300, nil,nil,nil,false)
    	local goodsIcon = goodsSprite:getChildByName("goodsIcon")
    	goodsSprite:addChild(icon)
    	icon:setAnchorPoint(goodsIcon:getAnchorPoint())
    	icon:setPosition(goodsIcon:getPosition())
    	goodsIcon:removeFromParent()


	 	local itemNameLabel = CCRenderLabel:create(itemName, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
	    itemNameLabel:setColor(itemColor)
	    itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
	    itemNameLabel:setPosition(icon:getContentSize().width*0.5,-icon:getContentSize().height*0.13)
	    icon:addChild(itemNameLabel)

	    local getConcisenessNumText = function (p_num)
	    	if p_num >= 10000 then
	    		return string.format(GetLocalizeStringBy("key_10094"), p_num / 10000)
	    	else
	    		return p_num
	    	end
	    end
		local oldPriceLabel = goodsSprite:getChildByName("oldPriceLabel")
		local oldPriceRichInfo = oldPriceLabel:getRichInfo()
		local oldPriceData = ItemUtil.getItemsDataByStr(config.base_price)[1]	
		oldPriceRichInfo.elements = {
			{
				text = GetLocalizeStringBy("key_10311"),
				color = ccc3(0xff, 0x00, 0x00)
			},
			{
				["type"] =  "CCNode",
				create = function ( ... )
					return ItemUtil.getSmallSprite(oldPriceData)
				end
			},
			{
				text = getConcisenessNumText(oldPriceData.num)
			}
		}
		oldPriceLabel:setRichInfo(oldPriceRichInfo)

			--大减价
		local noSprite = CCSprite:create("images/recharge/limit_shop/no_more.png")
		noSprite:setAnchorPoint(ccp(0,0.5))
		noSprite:setPosition(ccp(-10,oldPriceLabel:getContentSize().height * 0.5))
		oldPriceLabel:addChild(noSprite)
		noSprite:setScaleX(0.7)

		local newPriceLabel = goodsSprite:getChildByName("newPriceLabel")
		local newPriceData = ItemUtil.getItemsDataByStr(config.new_price)[1]
		local newPriceRichInfo = newPriceLabel:getRichInfo()
		newPriceRichInfo.elements = {
			{
				text = GetLocalizeStringBy("key_10312"),
				color = ccc3(0x00, 0xff, 0x18)
			},
			{
				["type"] = "CCNode",
				create = function ( ... )
					return ItemUtil.getSmallSprite(newPriceData)
				end
			},
			{
				text = getConcisenessNumText(newPriceData.num)
			}
		}
		newPriceLabel:setRichInfo(newPriceRichInfo)

		local buyGoodsBtn = goodsSprite:getChildByName("buyGoodsBtn")
		buyGoodsBtn:setClickCallback(buyGoodsCallback, config)

		local remainBuyCountLabel = goodsSprite:getChildByName("remainBuyCountLabel")
		local remainBuyCount = TravelShopData.getGoodsRemainBuyCount(nil, config)
		remainBuyCountLabel:setString(string.format(GetLocalizeStringBy("key_10313"), remainBuyCount))
	end
	return cell
end

-- 购买商品回调
function buyGoodsCallback(p_tag, p_btn, config)
	if ItemUtil.isBagFull(true) then
		return
	end
	local remainBuyCount = TravelShopData.getGoodsRemainBuyCount(nil, config)
	if remainBuyCount <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_10314"))
		return
	end
	TravelShopBuyLayer.showPurchaseLayer(p_tag,config)
	-- local newPriceData = ItemUtil.getItemsDataByStr(config.new_price)[1]
	-- local isFull = ItemUtil.checkItemCountByType(newPriceData.type, newPriceData.num, true, _touchPriority - 100, 1000)
	-- local items = ItemUtil.getItemsDataByStr(config.item)
	-- if isFull then
	-- 	local buy = function ()
	-- 		local rpcCallback = function ()
	-- 			TravelShopData.addScore(tonumber(config.score))
	-- 			showSelectedLayer(TAG_ZKDJ)
	-- 			ItemUtil.addRewardByTable({{["type"] = newPriceData.type, num = -newPriceData.num}})
	-- 			require "script/ui/item/ReceiveReward"
	-- 	    	ReceiveReward.showRewardWindow(items, nil, nil, _touchPriority - 50)
	-- 		end
	-- 		TravelShopService.buy(rpcCallback, config.id, 1)
	-- 	end
	-- 	if newPriceData.type == "gold" then
	-- 		local richInfo = {
	-- 			elements = {
	-- 				{
	-- 					["type"] = "CCNode",
	-- 					create = function ( ... )
	-- 						return ItemUtil.getSmallSprite(newPriceData)
	-- 					end
	-- 				},
	-- 				{
	-- 					text = newPriceData.num
	-- 				},
	-- 				{
	-- 					text = items[1].num
	-- 				},
	-- 				{
	-- 					text = ItemUtil.getItemNameByTid(items[1].tid)
	-- 				}
	-- 			}
	-- 		}
	-- 		local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10315"), richInfo)
	-- 		local alertCallback = function ( isConfirm, _argsCB )
	-- 			if not isConfirm then
	-- 				return
	-- 			end
	-- 			buy()
	-- 		end
	-- 		RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)  --确定
	-- 	else
	-- 		buy()
	-- 	end
	-- end
end

-- 创建充值优惠界面
function createCzyhLayer( ... )
	local layer = nil
	if TravelShopData.isOpenCzyh() or TravelShopData.canReceiveCzyhReward() then
		layer = _layer:createCzyhFinishLayer(true)
		_progressSprite = _layer:getMemberNodeByName("czyh1ProgressSprite")
		_progressLabel = _layer:getMemberNodeByName("czyh1ProgressLabel")
		_progressScrollView = _layer:getMemberNodeByName("czyh1ProgressScrollView")
		loadCzyhTip()
		loadCzyhCzyhBtn()
		startRefreshCzyhRemainTime(layer)
	else
		layer = _layer:createCzyhUnfinishedLayer(true)
		_progressSprite = _layer:getMemberNodeByName("czyh2ProgressSprite")
		_progressLabel = _layer:getMemberNodeByName("czyh2ProgressLabel")
		_progressScrollView = _layer:getMemberNodeByName("czyh2ProgressScrollView")
		local goBuyBtn = _layer:getMemberNodeByName("goBuyBtn")
		goBuyBtn:setClickCallback(goBuyCallback)
	end
	refreshProgress()
	return layer
end

-- 充值优惠按钮
function loadCzyhCzyhBtn( ... )
	local czyhBtn = _layer:getMemberNodeByName("czyhBtn")
	local czyhReceiveBtn = _layer:getMemberNodeByName("czyhReceiveBtn")
	if TravelShopData.canReceiveCzyhReward() then
		czyhReceiveBtn:setClickCallback(czyhReceiveCallback)
 		czyhReceiveBtn:setTouchPriority(_touchPriority - 10)
		czyhBtn:removeFromParent()
	else
		czyhBtn:setClickCallback(yhczCallback)
		czyhBtn:setTouchPriority(_touchPriority - 10)
		if TravelShopData.isOpenCzyh() then
			local effect = XMLSprite:create("images/base/effect/chongzhiyouhui/chongzhiyouhui")
			czyhBtn:addChild(effect)
			effect:setPosition(ccpsprite(0.5, 0.5, czyhBtn))
		end
		czyhReceiveBtn:removeFromParent()
	end
end

-- 领取充值返利
function czyhReceiveCallback( ... )
	local rpcCallback = function ( ... )
		AnimationTip.showTip(string.format(GetLocalizeStringBy("key_10316"), _payBackGoldCount))
		UserModel.addGoldNumber(_payBackGoldCount)
		showSelectedLayer(_curShowTag)
	end
	TravelShopService.getPayback(rpcCallback, table.count(_travelShopInfo.payback))
end

function initPayBackGoldCount( ... )
	--if TravelShopData.canReceiveCzyhReward() then
		local czyhRewardInfo = TravelShopData.getCurCzyhRewardInfo()
		_payBackGoldCount = czyhRewardInfo[3]
	--end
end

function loadCzyhTip( ... )
	local czyhRewardInfo = TravelShopData.getCurCzyhRewardInfo()
	local payTipLabel = _layer:getMemberNodeByName("payTipLabel")
	initPayBackGoldCount()
	payTipLabel:setString(string.format(GetLocalizeStringBy("key_10317"), czyhRewardInfo[2], _payBackGoldCount))
	local payProgressLabel = _layer:getMemberNodeByName("payProgressLabel")
	local payProgressRichInfo = payProgressLabel:getRichInfo()
	payProgressRichInfo.elements = {}
	local element = {}
	local curBuyGoldCount = TravelShopData.getCurBuyGoldCount()
	element.text = curBuyGoldCount
	if curBuyGoldCount > czyhRewardInfo[2] then
		element.color = ccc3(0x00, 0xff, 0x18)
	else
		element.color = ccc3(0xff, 0x00, 0x00)
	end
	table.insert(payProgressRichInfo.elements, element)
	element = {}
	element.text = czyhRewardInfo[2]
	element.color = ccc3(0x00, 0xff, 0x18)
	table.insert(payProgressRichInfo.elements, element)
	local newPayProgressRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10318"), payProgressRichInfo)
	payProgressLabel:setRichInfo(newPayProgressRichInfo)
end

-- 启动刷新优惠剩余时间的定时器	
function startRefreshCzyhRemainTime(p_layer)
	local remainTimeTipLabel = _layer:getMemberNodeByName("remainTimeTipLabel")
	if TravelShopData.canReceiveCzyhReward() then
		remainTimeTipLabel:removeFromParent()
		return
	end
	refreshCzyhRemainTime()
	schedule(p_layer, refreshCzyhRemainTime, 1)
end

-- 刷新优惠剩余时间
function refreshCzyhRemainTime( ... )
	local remainTimeTipLabel = _layer:getMemberNodeByName("remainTimeTipLabel")	
	local remainTime = TravelShopData.getCzyhRemainTime()
	if remainTime <= 0 then
		showSelectedLayer(TAG_CZYH)
		return
	end
	local richInfo = remainTimeTipLabel:getRichInfo()
	richInfo.elements = {
		{
			text = TimeUtil.getTimeString(remainTime),
			color = ccc3(0x00, 0xff, 0x18)
		}
	}
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10319"), richInfo)
	remainTimeTipLabel:setRichInfo(newRichInfo)
end

-- 去购买
function goBuyCallback( ... )
	local zkdjSelectBtn = _layer:getMemberNodeByName("zkdjSelectBtn")
	selectedCallback(TAG_ZKDJ, zkdjSelectBtn);
end

-- 创建普天同庆
function createPttqLayer( ... )
	local layer = _layer:createPttqLayer(true)
	loadPttqLine2()
	loadPttqTableView()
	loadBuyCount()
	return layer
end

function loadPttqLine2( ... )
	local pttqLine2Label = _layer:getMemberNodeByName("pttqLine2Label")
	local richInfo = pttqLine2Label:getRichInfo()
	richInfo.elements = {
		{
			text = GetLocalizeStringBy("key_10308"),
			color = ccc3(0xff, 0x00, 0x00)
		}
	}
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10320"), richInfo)
	pttqLine2Label:setRichInfo(newRichInfo)
end

-- 普天同庆的领取列表
function loadPttqTableView( ... )
	local rewardTableView = _layer:getMemberNodeByName("rewardTableView")
	rewardTableView:setHeight(g_winSize.height / MainScene.elementScale * 0.366)
	local rewardCell = _layer:getMemberNodeByName("pttqCell")
    _pttqCellSize = _pttqCellSize or rewardCell:getContentSize()
    rewardCell:removeFromParent()
	local allRewardInfo = TravelShopData.getAllRewardInfo()
    local cellCount = #allRewardInfo
    local eventHandler = function ( functionName, tableView, index, cell )
        if functionName == "cellSize" then
            return _pttqCellSize
        elseif functionName == "cellAtIndex" then
            return createPttqRewardCell(index, allRewardInfo[index])
        elseif functionName == "numberOfCells" then
            return cellCount
        end
    end
    rewardTableView:setEventHandler(eventHandler)
    rewardTableView:setTouchPriority(_touchPriority - 5)
    rewardTableView:reloadData()
    _pttqTableView = rewardTableView
end

-- 普天同庆领取列表的cell
function createPttqRewardCell(p_index, p_rewardInfo)
	local cell = _layer:createPttqCell(true)
	cell:setPosition(ccp(0, 0))
	cell:setAnchorPoint(ccp(0, 0))

	local itemIcon = _layer:getMemberNodeByName("itemIcon")

	local icon, itemName, itemColor = ItemUtil.createGoodsIcon(p_rewardInfo.items[1], _touchPriority - 5, 10001, _touchPriority - 300, nil,nil,nil,false)
	itemIcon:getParent():addChild(icon)
	icon:setAnchorPoint(itemIcon:getAnchorPoint())
	icon:setPosition(itemIcon:getPosition())
	itemIcon:removeFromParent()

 	local itemNameLabel = CCRenderLabel:create(itemName, g_sFontName, 18, 1, ccc3( 0x10, 0x10, 0x10), type_stroke)
    itemNameLabel:setColor(itemColor)
    itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
    itemNameLabel:setPosition(icon:getContentSize().width*0.5,-icon:getContentSize().height*0.13)
    icon:addChild(itemNameLabel)

	local receiveTipLabel = _layer:getMemberNodeByName("receiveTipLabel")
	local richInfo = receiveTipLabel:getRichInfo()
	richInfo.alignment = 1
	richInfo.elements = {
		{
			newLine = true,
			text = p_rewardInfo.needBuyCount,
			color = ccc3(0x00, 0x6d, 0x2f)
		}
	}
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10321"), richInfo)
	receiveTipLabel:setRichInfo(newRichInfo)

	local receiveBtn = _layer:getMemberNodeByName("receiveBtn")
	receiveBtn:setClickCallback(pttqReceiveCallback, p_rewardInfo)
	local rewardId = p_rewardInfo.id
	receiveBtn:setTag(rewardId)
	local receiveDisabledLabel = receiveBtn:getDisabledLabel()
	receiveDisabledLabel:setColor(ccc3(0x88, 0x88, 0x88))
	if p_rewardInfo.needBuyCount > tonumber(_travelShopInfo.sum) then
		receiveBtn:setEnabled(false)
	end
	if TravelShopData.rewardIsReceived(rewardId) then
		receiveDisabledLabel:setString(GetLocalizeStringBy("lcyx_1958"))
		receiveBtn:setEnabled(false)
	end
	return cell
end

-- 普天同庆领取按钮回调
function pttqReceiveCallback(p_tag, p_btn, p_rewardInfo)
	if ItemUtil.isBagFull(true) then
		return
	end
	local rpcCallback = function ( ... )
		ItemUtil.addRewardByTable(p_rewardInfo.items)
		if not tolua.isnull(_pttqTableView) then
			local offset = _pttqTableView:getContentOffset()
			_pttqTableView:reloadData()
			_pttqTableView:setContentOffset(offset)
		end
		refreshPttqTip()
		require "script/ui/item/ReceiveReward"
		ReceiveReward.showRewardWindow(p_rewardInfo.items, nil, nil, _touchPriority - 50)
	end
	local rewardId = p_tag
	TravelShopService.getReward(rpcCallback, rewardId)
end

-- 普天同庆界面的购买总人次
function loadBuyCount( ... )
	local buyCountBg = _layer:getMemberNodeByName("buyCountBg")
	local scrollViewContentSize = nil
	local numBgWidth = nil
	for i = 1, 5 do
		local numBgSprite = CCSprite:create("images/common/bg/9s_9.png")
		buyCountBg:addChild(numBgSprite)
		numBgSprite:setAnchorPoint(ccp(0, 0))
		numBgSprite:setPosition(ccp(numBgSprite:getContentSize().width * (i - 1) + 8, 8))
		if scrollViewContentSize == nil then
			numBgWidth = numBgSprite:getContentSize().width
			scrollViewContentSize = CCSizeMake(numBgSprite:getContentSize().width * 5, numBgSprite:getContentSize().height)
		end
	end
	-- _lastBuyCount = 12
	-- _travelShopInfo.sum = 13 
	local count = nil
	if _lastBuyCount == nil or _lastBuyCount > tonumber(_travelShopInfo.sum) then
		count = tonumber(_travelShopInfo.sum)
	else
		count = _lastBuyCount
	end
	local scrollView = CCScrollView:create()
	buyCountBg:addChild(scrollView)
	scrollView:setTouchEnabled(false)
	scrollView:setViewSize(scrollViewContentSize)
	scrollView:setContentSize(scrollViewContentSize)
	scrollView:setPosition(ccp(8, 8))

	local numLabel = BTNumerLabel:createWithPath("images/common", count)
	numLabel:setBitNum(5)
	scrollView:addChild(numLabel)
	numLabel:setAnchorPoint(ccp(0, 0.5))
	numLabel:setPosition(ccp(0, scrollView:getContentSize().height * 0.5))
	local numScale = 0.5
	local numWidth = numBgWidth / numScale
	numLabel:setScale(numScale)
	numLabel:setBitWidth(numWidth)

	if count < tonumber(_travelShopInfo.sum) then
		local countStr = tostring(count)
		local sumStr = tostring(_travelShopInfo.sum)
		if string.len(countStr) < string.len(sumStr) then
			countStr = string.rep("0", string.len(sumStr) - string.len(countStr)) .. countStr
		end 
		local startBit = nil
		for i = string.len(sumStr), 1, -1 do
			if string.byte(sumStr, i) ~= string.byte(countStr, i) then
				startBit = i
			end
		end
		local moveCountStr = string.sub(sumStr, startBit)
		local moveLabel = BTNumerLabel:createWithPath("images/common", moveCountStr)
		scrollView:addChild(moveLabel)
		moveLabel:setAnchorPoint(ccp(1, 0.5))
		moveLabel:setPosition(ccp(scrollViewContentSize.width, scrollViewContentSize.height))
		moveLabel:runAction(CCMoveTo:create(0.5, ccp(scrollViewContentSize.width, scrollViewContentSize.height * 0.5)))
		moveLabel:setScale(numScale)
		moveLabel:setBitWidth(numWidth)
		for i=1, string.len(moveCountStr) do
			local numSprite = numLabel:getNumSprite(i)
			numSprite:runAction(CCMoveBy:create(0.5, ccp(0, -numLabel:getContentSize().height)))
		end
	end
end

-- 刷新购买积分进度
function refreshProgress( ... )
	local score = TravelShopData.getScore()
	if score > TravelShopData.getScoreLimit() then
		score = TravelShopData.getScoreLimit()
	end
	_progressLabel:setString(string.format("%d/%d", score, TravelShopData.getScoreLimit()))
	_progressScrollView:setViewSize(CCSizeMake(_progressScrollView:getContentSize().width * score / 100, _progressScrollView:getContentSize().height))
	if tolua.isnull(_progressEffect) or _progressSprite:getSubNode() ~= _progressEffect:getParent() then
		_progressEffect = XMLSprite:create("images/base/effect/astro/zhanxinglizi")
		_progressEffect:setAnchorPoint(ccp(0, 0.5));
    	_progressEffect:setPosition(_progressScrollView:getContentSize().width*0.45, _progressScrollView:getContentSize().height*0.5);
    	_progressSprite:addChild(_progressEffect);
	end 
end

-- 零点刷新
function refresh( ... )
	if not tolua.isnull(_layer) then
		local rpcCallback = function ( ... )
			_travelShopInfo = TravelShopData.getTravelShopInfo()
			showSelectedLayer(_curShowTag)
		end
		TravelShopService.getInfo(rpcCallback)
	end
end

-- 适配
function adaptive( ... )
	local centerLayer = _layer:getMemberNodeByName("centerLayer")
	local bulletinHeight = RechargeActiveMain.getTopSize().height
    local activeBarHeight = RechargeActiveMain.getBgWidth()
    local menuHeight = MenuLayer.getHeight()
    local height = g_winSize.height - bulletinHeight * g_fScaleX - activeBarHeight - menuHeight
    centerLayer:setContentSize(CCSizeMake(g_winSize.width, height))
    centerLayer:setPosition(ccp(g_winSize.width * 0.5, menuHeight))

    local flowerSprite = _layer:getMemberNodeByName("flowerSprite")
    flowerSprite:setScale(g_fScaleX)
    local titleSprite = _layer:getMemberNodeByName("titleSprite")
    titleSprite:setScale(MainScene.elementScale)
    local contentBgSprite = _layer:getMemberNodeByName("contentBgSprite")
    contentBgSprite:setScale(MainScene.elementScale)
    contentBgSprite:setHeight(centerLayer:getContentSize().height / MainScene.elementScale - 140)
end