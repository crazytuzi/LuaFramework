-- Filename：	MoonShopLayer.lua
-- Author：		bzx
-- Date：		2015-04-27
-- Purpose：		水月之镜商店兑换

module("MoonShopLayer", package.seeall)
btimport "script/ui/moon/MoonService"
require "script/ui/moon/MoonLayer"
btimport "script/ui/moon/STMoonShopLayer"

local _layer
local _touchPriority
local _zOrder
local _goodsTableView
local _addItemNum = 0
local _centerLayer = nil
local _centerSize = nil

function show(touchPriority, zOrder)
	local layer = create(touchPriority, zOrder)
	local curScene = MainScene:getOnRunningLayer()
	curScene:addChild(layer, _zOrder)
end

function create( touchPriority, zOrder )
	init(touchPriority, zOrder)
	require "script/ui/shopall/ShoponeLayer"
	_layer = STMoonShopLayer:create()
	_layer:setBgColor(ccc3(0, 0, 0))
	_layer:setBgOpacity(200)
	_layer:setSwallowTouch(true)
    _layer:setTouchPriority(_touchPriority)
    _layer:setTouchEnabled(true)
	_centerLayer = createCenterLayer(ShoponeLayer.getCenterSize(), touchPriority, zOrder, true)
	_layer:addChild(_centerLayer)
	_centerLayer:setAnchorPoint(ccp(0.5, 0.5))
	_centerLayer:setPosition(ccpsprite(0.5, 0.5, _layer))
	loadMenu()
	return _layer
end

function createCenterLayer(p_centerSize, p_touchPriority, p_zOrder, p_isShow)
	init(p_touchPriority, p_zOrder)
	_centerSize = p_centerSize
	_centerLayer = CCLayer:create()
	_centerLayer:setContentSize(_centerSize)
	if tolua.isnull(_layer) then
		_layer = STMoonShopLayer
	end
	if not p_isShow then
		local bgSprite = _layer:createBgSprite()
		_centerLayer:addChild(bgSprite)
		bgSprite:setAnchorPoint(ccp(0, 0))
		bgSprite:setPosition(ccp(0, 0))
		bgSprite:setContentSize(_centerSize)
	end

	local requestCallback = function ( ... )

		local layer = _layer:createCenterLayer(true)
		
		layer:setContentSize(_centerSize)
		layer:setAnchorPoint(ccp(0, 0))
		layer:setPosition(ccp(0, 0))
		loadGoodsTableView()
		loadBtn()
		refreshCurGodCardNum()
		refreshRemainBoxTimesLabel()
		refreshNumberLabel()
		adaptive()
		_centerLayer:addChild(layer)
	end
	MoonService.getShopInfo(requestCallback)
	_centerLayer:ignoreAnchorPointForPosition(false)
	return _centerLayer
end


function init( touchPriority, zOrder )
	_touchPriority = touchPriority or -700
	_zOrder = zOrder or 180
end

function loadBtn( ... )

	local openBoxBtn = _layer:getMemberNodeByName("openBoxBtn")
	openBoxBtn:setTouchPriority(_touchPriority - 20)
	openBoxBtn:setClickCallback(openBoxCallback)
	refreshOpenBoxBtn()

	local refreshBtn = _layer:getMemberNodeByName("refreshBtn")
	refreshBtn:setTouchPriority(_touchPriority - 20)
	refreshBtn:setClickCallback(refreshCallback)
	refreshRefreshBtn()

	local previewBtn = _layer:getMemberNodeByName("previewBtn")
	previewBtn:setTouchPriority(_touchPriority - 20)
	previewBtn:setClickCallback(previewCallback)
end

function loadMenu( ... )
    --menu层
    local bgMenu = CCMenu:create()
    bgMenu:setAnchorPoint(ccp(0,0))
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority - 10)
    _layer:addChild(bgMenu)

    --返回按钮
    local returnButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    returnButton:setScale(g_fElementScaleRatio)
    returnButton:setAnchorPoint(ccp(0.5,0.5))
    returnButton:setPosition(ccp(g_winSize.width*585/640,g_winSize.height*905/960))
    returnButton:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(returnButton)
end

function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if not tolua.isnull(_layer) then
        _layer:removeFromParentAndCleanup(true)
    end
end


function previewCallback( ... )
	btimport "script/ui/moon/MoonShopPreviewLayer"
	MoonShopPreviewLayer.show(_touchPriority - 100)
end

function loadGoodsTableView( ... )
	_goodsTableView = _layer:getMemberNodeByName("goodsTableView")
	local cell = _layer:getMemberNodeByName("goodsCell")
	cell:removeFromParent()
	local cellSize = cell:getContentSize()
	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return cellSize
		elseif functionName == "cellAtIndex" then
			return createGoodsCell(index)
		elseif functionName == "numberOfCells" then
			local shopInfo = MoonData.getShopInfo()
			return table.count(shopInfo.goods_list)
		end
	end
	_goodsTableView:setEventHandler(eventHandler)
	_goodsTableView:setTouchPriority(_touchPriority - 10)
	local goodsTableViewBg = _layer:getMemberNodeByName("goodsTableViewBg")
	goodsTableViewBg:setContentSize(CCSizeMake(goodsTableViewBg:getContentSize().width, _centerSize.height / MainScene.elementScale - 250))
	_goodsTableView:setViewSize(CCSizeMake(goodsTableViewBg:getContentSize().width, goodsTableViewBg:getContentSize().height - 10))
	refreshGoodsTableView()
end

function createGoodsCell(index)
	local shopInfo = MoonData.getShopInfo()
	local ids = table.allKeys(shopInfo.goods_list)
	local goodsId = ids[index]
	local cell = STTableViewCell:create()
	local goodsCell = STMoonShopLayer:createGoodsCell()
	cell:addChild(goodsCell)
	goodsCell:setAnchorPoint(ccp(0, 0))
	goodsCell:setPosition(ccp(0, 0))
	local treasureCopyitemDb = DB_Treasure_copyitem.getDataById(goodsId)
	local itemData = ItemUtil.getItemsDataByStr(treasureCopyitemDb.items)
	local icon,itemName,itemColor = ItemUtil.createGoodsIcon(itemData[1], _touchPriority - 1, _zOrder + 10, _touchPriority - 50, showDownMenu,nil,nil,false)
   	local infoBg = goodsCell:getChildByName("infoBg")
    local goodsIcon = infoBg:getChildByName("goodsIcon")
    local iconPosition = ccp(goodsIcon:getPositionX(), goodsIcon:getPositionY())
    local iconAnchorPoint = goodsIcon:getAnchorPoint()
    infoBg:addChild(icon)
    icon:setAnchorPoint(iconAnchorPoint)
    icon:setPosition(iconPosition)
   	goodsIcon:removeFromParent()

   	local goodsNameLabel = infoBg:getChildByName("goodsNameLabel")
   	goodsNameLabel:setString(itemName)
   	goodsNameLabel:setColor(itemColor)

   	local costNameLabel = infoBg:getChildByName("costNameLabel")
   	if treasureCopyitemDb.costType == 2 then
   		local richInfo = costNameLabel:getRichInfo()
   		local elements =
		{
			{
				text = GetLocalizeStringBy("key_1298")--"金币"
			},
   			{
   				["type"] = "CCSprite",
   				image = "images/common/gold.png",  --"金币图片"
   			},
   			{
   				text = treasureCopyitemDb.costNum
   			}
   		}
   		richInfo.elements = elements
   		costNameLabel:setRichInfo(richInfo)
   	elseif treasureCopyitemDb.costType == 3 then
   		local richInfo = costNameLabel:getRichInfo()
   		local elements =
		{
			{
				text = GetLocalizeStringBy("key_3341")  --”银币“
			},
   			{
   				["type"] = "CCSprite",
   				image = "images/common/coin_silver.png",  --"银币图片"
   			},
   			{
   				text = treasureCopyitemDb.costNum
   			}
   		}
   		richInfo.elements = elements
   		costNameLabel:setRichInfo(richInfo)
   	elseif treasureCopyitemDb.costType == 1 then
   		local richInfo = costNameLabel:getRichInfo()
   		local elements =
		{
			{
				text = GetLocalizeStringBy("key_10220")  --”天工令“
			},
   			{
   				["type"] = "CCSprite",
   				image = "images/moon/moon_icon.png",
   			},
   			{
   				text = treasureCopyitemDb.costNum,
   			}
   		}
   		richInfo.elements = elements
   		costNameLabel:setRichInfo(richInfo)
   	end

	local curCountLabel = infoBg:getChildByName("curCountLabel")
	if ItemUtil.isFragment(itemData[1].tid) then
		local itemInfo = ItemUtil.getItemById(itemData[1].tid)
		local curRichInfo = curCountLabel:getRichInfo()
		local itemCount = ItemUtil.getCacheItemNumBy(itemData[1].tid) + _addItemNum
		local needCount = itemInfo.need_part_num
		local textColor = nil
		if needCount > itemCount then
			textColor = ccc3(0xff, 0, 0)
		else
			textColor = ccc3(0x00, 0xff, 0x18)
		end
		curRichInfo.elements = {
			{
				color = textColor,
				text = string.format("%d/%d", itemCount, needCount),
			}
		}
		local newCurRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10221"), curRichInfo) --”文字当前拥有’
		curCountLabel:setRichInfo(newCurRichInfo)
	else
		curCountLabel:removeFromParent()
		costNameLabel:setPositionY(38)
	end
	_addItemNum = 0
	local restTimes = shopInfo.goods_list[goodsId]
	local restTimesLabel = goodsCell:getChildByName("restTimesLabel")
	restTimesLabel:setString(string.format(GetLocalizeStringBy("key_10222"), restTimes))  --“”兑换次数

	local exchangeBtn = goodsCell:getChildByName("exchangeBtn")
	exchangeBtn:setTag(index)
	exchangeBtn:setClickCallback(exchangeCallback)
	exchangeBtn:setScrollView(_goodsTableView)
	exchangeBtn:setTouchPriority(_touchPriority - 10)
	local buyBtn = goodsCell:getChildByName("buyBtn")
	buyBtn:setTag(index)
	buyBtn:setClickCallback(exchangeCallback)
	buyBtn:setScrollView(_goodsTableView)
	buyBtn:setTouchPriority(_touchPriority - 10)
	if treasureCopyitemDb.costType == 2 then
		exchangeBtn:setVisible(false)
		if(tonumber(restTimes) <= 0)then
			buyBtn:setVisible(false)
			 local hasReceiveItem = CCSprite:create("images/common/yigoumai.png")
            hasReceiveItem:setAnchorPoint(ccp(0,0.5))
            hasReceiveItem:setPosition(ccp(infoBg:getContentSize().width,infoBg:getContentSize().height*0.55))
            infoBg:addChild(hasReceiveItem)
		end
	else
		buyBtn:setVisible(false)
		if(tonumber(restTimes) <= 0)then
			exchangeBtn:setVisible(false)
			 local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
	        hasReceiveItem:setAnchorPoint(ccp(0,0.5))
	        hasReceiveItem:setPosition(ccp(infoBg:getContentSize().width,infoBg:getContentSize().height*0.55))
	        infoBg:addChild(hasReceiveItem)
		end
	end

	return cell
end

-- 刷新商品列表
function refreshGoodsTableView()
	_goodsTableView:reloadData()
end

-- 刷新当前剩余天工令数量
function refreshCurGodCardNum( ... )
	local curGodCardLabel = _layer:getMemberNodeByName("curGodCardLabel")
	local richInfo = curGodCardLabel:getRichInfo()
   		local elements =
		{
   			{
   				["type"] = "CCSprite",
   				image = "images/moon/moon_icon.png",
   			},
   			{
   				text = UserModel.getGodCardNum()
   			}
   		}
   	richInfo.elements = elements
   	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10223"), richInfo) --“当前天工令”
   	curGodCardLabel:setRichInfo(newRichInfo)
end

-- 刷新剩余开宝箱的次数
function refreshRemainBoxTimesLabel( ... )
	local remainBoxTimesLabel = _layer:getMemberNodeByName("remainBoxTimesLabel")
	local openBoxLimit = MoonData.getOpenBoxLimit()
	local shopInfo = MoonData.getShopInfo()
	local curCount = tonumber(shopInfo.buy_box_count)
	remainBoxTimesLabel:setString(string.format("%d/%d", curCount, openBoxLimit))
end

-- 打开宝箱回调
function openBoxCallback( ... )
	local openBoxLimit = MoonData.getOpenBoxLimit()
	local shopInfo = MoonData.getShopInfo()
	local curCount = tonumber(shopInfo.buy_box_count)
	if curCount == openBoxLimit then
		AnimationTip.showTip(GetLocalizeStringBy("key_10224"))  --“”该商品今日购买次数已用完，请主公明日再来
		return
	end
	local cost = MoonData.getOpenBoxCost()
	if cost > UserModel.getGoldNumber() then
		require "script/ui/tip/LackGoldTip"
	    LackGoldTip.showTip()
	    return
	end
	if ItemUtil.isBagFull() then
        return
    end
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
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10225"), richInfo) --“是否花费%s%s，购买1个天宫宝箱？”
	local alertCallback = function ( isConfirm, _argsCB )
		if not isConfirm then
			return
		end
		local requestCallback = function ( ... )
			UserModel.addGoldNumber(-cost)

			refreshOpenBoxBtn()
			refreshRemainBoxTimesLabel()
			showOpenBoxInfo()
		end
		MoonService.buyBox(requestCallback)
	end
	RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)  --确定
end

-- 展示打开宝箱所得物品
function showOpenBoxInfo( ... )
	local openBoxInfo = MoonData.getBuyBoxInfo()
	require "script/ui/item/ReceiveReward"
	local itemsData = ItemUtil.getServiceReward(openBoxInfo.drop)
	ReceiveReward.showRewardWindow(itemsData, nil, nil, _touchPriority - 50)
end

-- 刷新打开宝箱的按钮
function refreshOpenBoxBtn( ... )
	local openBoxBtn = _layer:getMemberNodeByName("openBoxBtn")
	openBoxBtn:setTouchPriority(_touchPriority - 10)
	local richInfo = openBoxBtn:getRichInfo()
	local elements = {
		{
			["type"] = "CCSprite",
			image = "images/common/gold.png",
		},
		{
			text = MoonData.getOpenBoxCost()
		}
	}
   	richInfo.elements = elements
   	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10226"), richInfo)
   	openBoxBtn:setRichInfo(newRichInfo)
end

-- 刷新刷新按钮
function refreshRefreshBtn( ... )
	local refreshBtn = _layer:getMemberNodeByName("refreshBtn")
	local richInfo = refreshBtn:getRichInfo()
	
	--判断条件，免费刷新次数用完的话，执行下面的
	if(MoonData.getNumberRef() ==0)then
	local elements = {
		{
			["type"] = "CCSprite",
			image = "images/common/gold.png",
		},
		{
			text = MoonData.getRefreshCost()
		}
	}
   	richInfo.elements = elements
   	   	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10227"), richInfo)  --刷新
   		refreshBtn:setRichInfo(newRichInfo)
   else
   refreshBtn:setString(GetLocalizeStringBy("zz_111"))
   end
end

-- 兑换回调
function exchangeCallback(tag)
	local goodsIndex = tag
	local shopInfo = MoonData.getShopInfo()
	local ids = table.allKeys(shopInfo.goods_list)
	local goodsId = ids[goodsIndex]
	local treasureCopyitemDb = DB_Treasure_copyitem.getDataById(goodsId)
	local costType = treasureCopyitemDb.costType
	if tonumber(shopInfo.goods_list[goodsId]) == 0 then
		if costType == 2 then
			AnimationTip.showTip(GetLocalizeStringBy("key_10228"))
		else
			AnimationTip.showTip(GetLocalizeStringBy("zz_123"))
		end
		return
	end
	if ItemUtil.isBagFull() then
        return
    end

	local itemsData = ItemUtil.getItemsDataByStr(treasureCopyitemDb.items)
    local sureCallBack = function ( p_buyNum )
        local cost = treasureCopyitemDb.costNum * p_buyNum
      	if costType == 1 then
    		if cost > UserModel.getGodCardNum() then
    			AnimationTip.showTip(GetLocalizeStringBy("key_10229"))
    			return
    		end
    	elseif costType == 2 then
    		if cost > UserModel.getGoldNumber() then
    			require "script/ui/tip/LackGoldTip"
	    		LackGoldTip.showTip()
	    		return
    		end
    	elseif costType == 3 then
    		if cost > UserModel.getSilverNumber() then
    			AnimationTip.showTip(GetLocalizeStringBy("zz_93"))
    		end
    	end
    	local iconAndNames = {}
    	iconAndNames[1] = {icon = "images/moon/moon_icon.png", name = GetLocalizeStringBy("lic_1561")}
    	iconAndNames[2] = {icon = "images/common/gold.png", name = GetLocalizeStringBy("key_10193")}
    	iconAndNames[3] = {icon = "images/common/coin_silver.png", name = GetLocalizeStringBy("lic_1509")}
    	local nameColor = nil
    	local name = nil
    	if itemsData[1].type == "tg_num" then
			local quality = ItemSprite.getTianGongLingQuality()
        	nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
			name = GetLocalizeStringBy("lic_1561")
		else
			local itemDb = ItemUtil.getItemById(itemsData[1].tid)
			nameColor = HeroPublicLua.getCCColorByStarLevel(itemDb.quality)
			name = ItemUtil.getItemNameByItmTid(itemsData[1].tid)
    	end
    	local richInfo = {
    		linespace = 10,
			elements = {
				{
					["type"] = "CCSprite",
	                image = iconAndNames[costType].icon
				},
				{
					text = cost
				},
				{
					font = g_sFontPangWa,
					text = string.format(GetLocalizeStringBy("key_10230"), p_buyNum * itemsData[1].num)
				},
				{
					type = "CCRenderLabel",
					font = g_sFontPangWa,
					text = name,
					color = nameColor,
				}
			}
		}
		local newRichInfo = nil
		if costType == 2 then
			newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10231"), richInfo)
		else
			newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10232"), richInfo)
		end
		local alertCallback = function ( isConfirm, _argsCB )
			if not isConfirm then
				return
			end
			local shopInfo = MoonData.getShopInfo()
			if shopInfo.goods_list[goodsId] == nil then
				AnimationTip.showTip(GetLocalizeStringBy("key_10233"))
				return
			end
	        local requestCallback = function (  )
	        	if costType == 1 then
	        		UserModel.addGodCardNum(-cost)
		    	elseif costType == 2 then
		    		UserModel.addGoldNumber(-cost)
		    	elseif costType == 3 then
		    		UserModel.addSilverNumber(-cost)
		    	end
		    	ItemUtil.addRewardByTable(itemsData)
		    	refreshCurGodCardNum()
	        	_addItemNum = p_buyNum * itemsData[1].num
	        	_goodsTableView:updateCellAtIndex(goodsIndex)
	            require "script/ui/item/ReceiveReward"
	            itemsData[1].num = _addItemNum
	        	ReceiveReward.showRewardWindow(itemsData, nil, nil, _touchPriority - 50)
	        end
	        MoonService.buyGoods(requestCallback, goodsId)
	    end
	    RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)
    end
    -- require "script/ui/common/BatchExchangeLayer"
    -- BatchExchangeLayer.showBatchLayer(paramTable, sureCallBack, _priority - 50)
    sureCallBack(1)
end

-- 刷新商品回调
function refreshCallback( ... )
	--添加一个判断，判断免费刷新次数是否用完
	if(MoonData.getNumberRef() <= 0)then
	local refreshLimit = MoonData.getRefreshLimit()
	local shopInfo = MoonData.getShopInfo()
	local curCount = tonumber(shopInfo.gold_refresh_num)  --获取金币刷新次数
	if curCount == refreshLimit then
		AnimationTip.showTip(GetLocalizeStringBy("key_10234"))  --金币刷新次数用完时，出来的提示  本日刷新次数已用完，请主公明日再来
		return
	end
	local cost = MoonData.getRefreshCost()
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
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10235"), richInfo)  --“是否消耗%s%s，刷新天工阁商店”
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
			refreshRefreshBtn()  --刷新按钮
			refreshGoodsTableView()  --刷新商品tableview
		end
		MoonService.refreshGoodsList(requestCallback)
	end
	RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)  --字是“确定”
	else
	local requestCallback = function ( ... )
	 	refreshRefreshBtn()  --刷新按钮
		refreshGoodsTableView()--刷新tableview
		refreshNumberLabel()
	end
	MoonService.refreshGoodsList(requestCallback)
	end

end

-- 开始刷新倒计时
-- function starRefreshTimeLabel( ... )
-- 	refreshTimeLabel()
-- 	schedule(_layer, refreshTimeLabel, 1)
-- end

-- 商品免费刷新次数的显示
function refreshNumberLabel( ... )
	local freeRefreshCountLabel = _layer:getMemberNodeByName("freeRefreshCountLabel")
	local richInfo = freeRefreshCountLabel:getRichInfo()
	richInfo.labelDefaultColor = ccc3(0xff,0xff,0xff)
	richInfo.elements = {
		{
			text = MoonData.getNumberRef(),
			color = ccc3(0.0,255.0,24.0)
	    }
	}
	local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("key_10284"),richInfo)
	freeRefreshCountLabel:setRichInfo(newRichInfo)
	freeRefreshCountLabel:setScale(MainScene.elementScale)
end
 
-- 返回回调
function backCallback( ... )
	MoonLayer.show()
end

-- 0点刷新
function refresh( ... )
	if tolua.isnull(_layer) then
		return
	end
	local automatic = function ( ... )
	MoonData.resetMoonShopInfo()
	refreshRefreshBtn()  --刷新刷新按钮
	refreshOpenBoxBtn()
	refreshRemainBoxTimesLabel()--刷新剩余开宝箱的次数
	refreshGoodsTableView()
	refreshNumberLabel()
	print("refreshNumberLabel()")
	print(refreshNumberLabel())
	end
	MoonService.getShopInfo(automatic)
end

-- 适配
function adaptive()
	local titleSprite = _layer:getMemberNodeByName("titleSprite")
	titleSprite:setScale(MainScene.elementScale)
	local boxLayer = _layer:getMemberNodeByName("boxLayer")
	boxLayer:setScale(MainScene.elementScale)
	local girlSprite = _layer:getMemberNodeByName("girlSprite")
	girlSprite:setScale(MainScene.elementScale)
	local refreshBtn = _layer:getMemberNodeByName("refreshBtn")
	refreshBtn:setScale(MainScene.elementScale)
	local goodsTableViewBg = _layer:getMemberNodeByName("goodsTableViewBg")
	goodsTableViewBg:setScale(MainScene.elementScale)
	local tipLabel = _layer:getMemberNodeByName("tipLabel")
	tipLabel:setScale(MainScene.elementScale)
	local freeRefreshCountLabel = _layer:getMemberNodeByName("freeRefreshCountLabel")
	freeRefreshCountLabel:setScale(MainScene.elementScale)
end