-- Filename: CarryDialog.lua
-- Author: llp
-- Date: 2016-4-7
-- Purpose: 运送刷马

module("CarryDialog", package.seeall)

require "script/libs/LuaCCLabel"
require "script/ui/hero/HeroPublicLua"

local _layer
local _zOrder
local _touchPriority
local _bossTableView
local HERO_TAG = 12344
local kCarryTag = 100
local _armyIds
local _curIndex
local _refreshNode
local _refreshNodeMenu 
local _pointLabel
local _floorLabel
local _actLabel
local _hpLabel
local _hpProgress
local _actTitle 
local _hpBg
local _addActBtn
local _buyActCount
local _addHpBtn
local _buyActTotalGoldCount
local _topNameBg
local _topNameLabel
local _fightTip
local _starBg
local _curCostPointLabel
local _curGetPointLabel
local _drag_began_x
local _touch_began_x
local _cellSize
local _isWin
local _is_handle_touch
local _tableViewIsMoving
local _curIndexAtTouchBegan
local _buyHpGoldCount
local _closeCallback
local _menu
local _directWinItem
local _winGoldCount
local _bottomBg
local _leftCarryTimeNumLabel = nil
local _carryItem
local _pageInfo
local _leftGoldLabel 		= nil
local _canClick = true
local horseTable = {"images/horse/greenhorse.png","images/horse/bluehorse.png","images/horse/purplehorse.png","images/horse/orghorse.png"}
local horseNameTable = {GetLocalizeStringBy("llp_361"),GetLocalizeStringBy("llp_362"),GetLocalizeStringBy("llp_363"),GetLocalizeStringBy("llp_364")}
local horseColor = {ccc3(0,255,0),ccc3(0x51, 0xfb, 0xff),ccc3(255, 0, 0xe1),ccc3(255,127,0)}
local dbInfo = DB_Mnlm_rule.getDataById(1)
function show(touchPriority, zOrder, closeCallback)
	_layer = create(touchPriority, zOrder, closeCallback)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end
local _leftTimeLabel = nil
function init( ... )
	_canClick = true
	_leftGoldLabel 		= nil
	finalRewardData = {}
	_carryItem = nil
	_leftTimeLabel = nil
	_bottomBg = nil
	_layer = nil 
	_bossTableView = nil
	_eventId = 0
	_armyIds = {}
	_curIndex = 1
	_topNameLabel = nil
	_fightTip = nil
	_starBg = nil
	_curCostPointLabel = nil
	_curGetPointLabel = nil
	_tableViewIsMoving = false
	_pointLabel = nil
	_floorLabel = nil
	_actLabel = nil
	_hpLabel = nil
	_menu = nil   
	_directWinItem = nil
	_leftCarryTimeNumLabel = nil
	_winGoldCount = 0
	_pageInfo = nil
end

function initData(touchPriority, zOrder , closeCallback)
	_cellSize = CCSizeMake(math.ceil(g_winSize.width / 3), 700 * MainScene.elementScale)
	_closeCallback = closeCallback
	_touchPriority = -1550
	_zOrder = zOrder or 1000
end

function freshLabel( pNum )
	-- body
	if(not tolua.isnull(_layer) and _leftCarryTimeNumLabel~=nil)then
		_leftCarryTimeNumLabel:setString(pNum)
	end
end

function getLabel( ... )
	-- body
	return _leftCarryTimeNumLabel
end

function afterServerce( pData )
	-- body
	_pageInfo = pData
	loadRefreshNode()
	loadHorses(pData)
	loadBottom(pData)
	loadInviteFriend(pData)
end

function freshItem( ... )
	-- body
	if( tolua.isnull(_layer) )then
		return
	end
	_inviteMenu:removeChildByTag(1,true)
	local inviteItem = nil
	if(tonumber(_pageInfo.has_invited)~=0)then
		inviteItem  = CCMenuItemImage:create("images/horse/teaminfo.png", "images/horse/teaminfoh.png")
		inviteItem:registerScriptTapHandler(lookAction)
	else
		inviteItem  = CCMenuItemImage:create("images/horse/invitefriend.png", "images/horse/invitefriendh.png")	
		inviteItem:registerScriptTapHandler(inviteAction)
	end
	inviteItem:setAnchorPoint(ccp(0,0.5))
   	inviteItem:setPosition(ccp(0,_topNameBg:getContentSize().height*0.5))
   	_inviteMenu:addChild(inviteItem,1,1)
end

function create(touchPriority, zOrder, closeCallback )
	init()
	initData(touchPriority, zOrder, closeCallback)
	_layer = CCLayer:create()
	_layer:registerScriptHandler(onNodeEvent)
	HorseService.re_agree_help_changed()
	loadBg()
	loadTopNameBg()
	HorseController.enterShipPage(afterServerce)
	
	return _layer
end

function loadBg( ... )
	local bg = CCSprite:create("images/horse/carrybg.jpg")

	local xmlSprite = XMLSprite:create("images/horse/muniuliumafazhen/muniuliumafazhen")
	xmlSprite:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5))
	bg:addChild(xmlSprite)
	_layer:addChild(bg)
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPosition(ccpsprite(0.5, 0.5, _layer))
	bg:setScale(g_fBgScaleRatio)
end

function afterCarry( pData )
	-- body
	close()
	HorseController.lookZoneAndPageInfo(pData.stage_id,pData.page_id)
end

function sureCarryAction( ... )
	-- body
	local yesCarryCallBack = function ( ... )
		HorseController.beginShipping(_curIndex,afterCarry)
	end
	local tipNode = CCNode:create()
	tipNode:setContentSize(CCSizeMake(550,100))
	-- 第一行
    local textInfo1 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("llp_438"),
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font1 = LuaCCLabel.createRichLabel(textInfo1)
 	font1:setAnchorPoint(ccp(0.5, 0.5))
 	font1:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
 	tipNode:addChild(font1)
 	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesCarryCallBack,CCSizeMake(600,360),-2000)
end

function carryCallback( ... )
	-- body
	local horseInfo = HorseData.gethorseInfo()
    local totalNum = tonumber(horseInfo.rest_ship_num)
    if(totalNum==0)then
    	local itemNumArry = dbInfo.transport_item
    	local itemAndNum = string.split(itemNumArry,"|")
    	local num = ItemUtil.getCacheItemNumBy(itemAndNum[1])
    	if(num>=tonumber(itemAndNum[2]))then
        	if(tonumber(_pageInfo.has_invited)==0)then
		    	sureCarryAction()
		    else
				HorseController.beginShipping(_curIndex,afterCarry)
			end
        else
        	AnimationTip.showTip(GetLocalizeStringBy("llp_425"))
        	return
        end
    else
    	if(tonumber(_pageInfo.has_invited)==0)then
	    	sureCarryAction()
	    else
			HorseController.beginShipping(_curIndex,afterCarry)
		end
    end
end

function createRewardCell( data )
	-- body
	local isDouble = HorseData.getDouble()
	_touchPriority = -1550
	local cell = CCTableViewCell:create()
	local rewardSprite = ItemUtil.createGoodsIcon(data[1],_touchPriority - 5,1234,_touchPriority - 5,nil,nil,false,true,false)
	local numLabel = CCRenderLabel:create(data[1].num, g_sFontName, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
		  numLabel:setAnchorPoint(ccp(1,0))
		  numLabel:setPosition(ccp(rewardSprite:getContentSize().width*0.95,5))
		  numLabel:setColor(ccc3(0x00,0xff,0x18))
	rewardSprite:addChild(numLabel)
	cell:addChild(rewardSprite)

	local finalExtraData = {}
	if(_curIndex>2)then
		local userLevel = UserModel.getAvatarLevel()
		local extraReward = DB_Mnlm_items.getDataById(_curIndex).special_reward
		local levelRewardDataExtra = string.split(extraReward,";")
		for k,v in pairs(levelRewardDataExtra) do
			local pdata = string.split(v,",")
			print(pdata[1])
			if(userLevel>=tonumber(pdata[1]))then
				finalExtraData = pdata
			end
		end
	end
	table.remove(finalExtraData,1)
	
	local extradata = string.split(finalExtraData[1],"|")

	if(data[1].tid~=nil and extradata[2]~=nil and isDouble and tonumber(data[1].tid)~=tonumber(extradata[2]))then
		local doubleSprite = CCSprite:create("images/horse/double.png")
			  doubleSprite:setAnchorPoint(ccp(0,1))
			  doubleSprite:setPosition(ccp(0,rewardSprite:getContentSize().height))
		rewardSprite:addChild(doubleSprite)
	elseif(data[1].tid~=nil and extradata[2]==nil and isDouble)then
		local doubleSprite = CCSprite:create("images/horse/double.png")
			  doubleSprite:setAnchorPoint(ccp(0,1))
			  doubleSprite:setPosition(ccp(0,rewardSprite:getContentSize().height))
		rewardSprite:addChild(doubleSprite)
	end
	return cell
end

function reFreshRewardCell( ... )
	_feedTableView:removeFromParentAndCleanup(true)
	_feedTableView = nil
	loadRewardTableView()
end

function loadRewardTableView( ... )
	require "db/DB_Mnlm_items"
	local rewardData = DB_Mnlm_items.getDataById(_curIndex).reward
	local levelRewardData = string.split(rewardData,";")
	local userLevel = UserModel.getAvatarLevel()
	
	for k,v in pairs(levelRewardData) do
		local data = string.split(v,",")
		if(userLevel>=tonumber(data[1]))then
			finalRewardData = data
		end
	end
	table.remove(finalRewardData,1)
	local finalExtraData = {}
	if(_curIndex>2)then
		local extraReward = DB_Mnlm_items.getDataById(_curIndex).special_reward
		local levelRewardDataExtra = string.split(extraReward,";")
		for k,v in pairs(levelRewardDataExtra) do
			local data = string.split(v,",")
			if(userLevel>=tonumber(data[1]))then
				finalExtraData = data
			end
		end
	end
	table.remove(finalExtraData,1)
	table.insert(finalRewardData,finalExtraData[1])

	if (not tolua.isnull(_feedTableView)) then
        _feedTableView:removeFromParentAndCleanup(true)
        _feedTableView = nil
    end
    
    local cellSize = CCSizeMake(128, 119)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize

        elseif fn == "cellAtIndex" then
        	local data = ItemUtil.getItemsDataByStr(finalRewardData[a1+1])
            a2 = createRewardCell(data)
            r = a2
        elseif fn == "numberOfCells" then
            local num = #finalRewardData
            r = num
        elseif fn == "cellTouched" then
        elseif (fn == "scroll") then
            
        end
        return r
    end)

    _feedTableView = LuaTableView:createWithHandler(h, CCSizeMake(630, 142))
    _feedTableView:setBounceable(true)
    _feedTableView:setTouchPriority(_touchPriority - 5)
    _feedTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _feedTableView:setPosition(ccp(10, 10))
    _feedTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _rewardBg:addChild(_feedTableView)
end

function setHaveFriend( ... )
	-- body
	_pageInfo.has_invited = 1
end

function afterFresh()
	-- body
	local horseInfo = HorseData.gethorseInfo()
	_pageInfo.refresh_num = _pageInfo.refresh_num+1
	_pageInfo.stage_id = horseInfo.stage_id
	loadHorses(_pageInfo)
	local container = _bossTableView:getContainer()
    local offset = _bossTableView:getContentOffset()
    offset.x = -(tonumber(horseInfo.stage_id) - 1) * _cellSize.width
    _tableViewIsMoving = true
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(0.5))
    local endCallFunc = function()
    	_canClick = true
    	-- _bossTableView:setContentOffset(offset)
    	-- refreshBossCell()
    	-- endRefreshBossCell()
     --    _tableViewIsMoving = false
    end
    array:addObject(CCCallFunc:create(endCallFunc))
    container:runAction(CCSequence:create(array))

    -- local arrayClick = CCArray:create()
    -- arrayClick:addObject(CCDelayTime:create(0.5))
    -- local endClickCallFunc = function()
   	-- 	 print("hehehehehe")
    --     _canClick = true
    --     _layer:stopAllActions()
    -- end
    -- arrayClick:addObject(CCCallFunc:create(endClickCallFunc))
    -- _layer:runAction(CCSequence:create(arrayClick))
	loadBottom(_pageInfo)
end

function playEffct( ... )
	local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/item/equipFixed/lizibaokai/lizibaokai"), -1,CCString:create(""));
    appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
    appearEffectSprite:setPosition(ccp(_layer:getContentSize().width/2, _layer:getContentSize().height/2));
    _layer:addChild(appearEffectSprite, 99999);

	appearEffectSprite:retain()
   	local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(function ( ... )
    	print(GetLocalizeStringBy("key_1037"))
    	appearEffectSprite:removeFromParentAndCleanup(true)
    	appearEffectSprite:autorelease()
    end)
    appearEffectSprite:setDelegate(delegate)
end

function freshAction( tag,item )
	if(not _canClick)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_455"))
		return
	end

	if(tonumber(_pageInfo.stage_id)==4)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_382"))
		return
	end
	_canClick = false

	local freshData = dbInfo.refresh_item
	local itemAndNum = string.split(freshData,"|")
	local itemNum = ItemUtil.getCacheItemNumBy(itemAndNum[1])
	if(itemNum>=tonumber(itemAndNum[2]))then
		HorseController.refreshHorse(0,_pageInfo,afterFresh)
		return
	end
	if(tonumber(tag)>UserModel.getGoldNumber())then
        LackGoldTip.showTip(-5000)
        return
    end
	HorseController.refreshHorse(tonumber(tag),_pageInfo,afterFresh)
end

function buyCarryAction( ... )
	local horseInfo = HorseData.gethorseInfo()
    local totalNum = horseInfo.shipping_num + horseInfo.rest_ship_num-dbInfo.free_transport-dbInfo.pay_transport
    if(totalNum==0)then
        AnimationTip.showTip(GetLocalizeStringBy("llp_416"))
        return
    end
	-- body
	require "script/ui/horse/BuyCarryTimeDialog"
	BuyCarryTimeDialog.showBatchBuyLayer(kCarryTag)
end

function freshGoldNum( ... )
	-- body
	if( tolua.isnull(_layer) )then
		return
	end
	local goldNum = UserModel.getGoldNumber()
    _leftGoldLabel:setString(goldNum)
end

function loadBottom( pData )
	-- body
	if(_bottomBg~=nil)then
		_bottomBg:removeFromParentAndCleanup(true)
		_bottomBg = nil
	end
	require "db/DB_Mnlm_rule"
    
	_bottomBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
	_layer:addChild(_bottomBg, 10)
	_bottomBg:setAnchorPoint(ccp(0.5, 0))
	_bottomBg:setPosition(ccpsprite(0.5, 0, _layer))
	_bottomBg:setPreferredSize(CCSizeMake(640, 170))
	_bottomBg:setScale(MainScene.elementScale)

	_menu = CCMenu:create()
	_bottomBg:addChild(_menu)
	_menu:setPosition(ccp(0, 0))
	_menu:setTouchPriority(_touchPriority - 5)

	local horseInfo = HorseData.gethorseInfo()
	local freshData = dbInfo.transport_item
	local itemAndNum = string.split(freshData,"|")
	local force_occupy_btn_info_carry = {}
    local leftNum = horseInfo.rest_ship_num
    local itemnum = ItemUtil.getCacheItemNumBy(itemAndNum[1])
	_carryItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180, 73), GetLocalizeStringBy("llp_365"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	if(tonumber(leftNum)==0 and (tonumber(itemnum)>=tonumber(itemAndNum[2])))then
		print("-=-=-=-=-=-=-")
		force_occupy_btn_info_carry = {
        normal = "images/common/btn/btn1_d.png",
        selected = "images/common/btn/btn1_n.png",
        size = CCSizeMake(180, 73),
        text_size = 30,
        icon = "images/base/props/yunsongling28.png",
        text = GetLocalizeStringBy("llp_365"),
        number = tostring(itemAndNum[2])
	    }
		_carryItem = LuaCCSprite.createNumberMenuItem(force_occupy_btn_info_carry)
	end
    _menu:addChild(_carryItem)
    _carryItem:setAnchorPoint(ccp(0.5, 0))
    _carryItem:setPosition(ccp(_bottomBg:getContentSize().width * 0.75, 10 * MainScene.elementScale))
    _carryItem:registerScriptTapHandler(carryCallback)

    local haveFreshNum = tonumber(pData.refresh_num)
    local freshCost = 0
    if(haveFreshNum>=tonumber(dbInfo.free_refresh))then
    	local data = string.split(dbInfo.money_refresh,",")
    	for k,v in pairs(data)do
    		local dataInfo = string.split(v,"|")
    		if(haveFreshNum+1>=tonumber(dataInfo[1]))then
    			freshCost = dataInfo[2]
    		end
    	end
	end
    local freshItem = nil
    if(haveFreshNum>=tonumber(dbInfo.free_refresh))then
    	local freshData = dbInfo.refresh_item
		local itemAndNum = string.split(freshData,"|")
		local itemNum = ItemUtil.getCacheItemNumBy(itemAndNum[1])
		local force_occupy_btn_info = {}
		if(itemNum>=tonumber(itemAndNum[2]))then
			force_occupy_btn_info = {
	        normal = "images/common/btn/btn1_d.png",
	        selected = "images/common/btn/btn1_n.png",
	        size = CCSizeMake(180, 73),
	        text_size = 30,
	        icon = "images/base/props/shuaxinling28.png",
	        text = GetLocalizeStringBy("key_1002"),
	        number = tostring(itemAndNum[2])
		    }
		else
			force_occupy_btn_info = {
	        normal = "images/common/btn/btn1_d.png",
	        selected = "images/common/btn/btn1_n.png",
	        size = CCSizeMake(180, 73),
	        text_size = 30,
	        icon = "images/common/gold.png",
	        text = GetLocalizeStringBy("key_1002"),
	        number = tostring(freshCost)
		    }
		end
	    freshItem = LuaCCSprite.createNumberMenuItem(force_occupy_btn_info)
    else
    	freshItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180, 73), GetLocalizeStringBy("lic_1164"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    end
       
    _menu:addChild(freshItem,1,freshCost)
    freshItem:setAnchorPoint(ccp(0.5, 0))
    freshItem:setPosition(ccp(_bottomBg:getContentSize().width * 0.25, 10 * MainScene.elementScale))
    freshItem:registerScriptTapHandler(freshAction)

    _leftTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_366"),g_sFontName,25)
    _leftTimeLabel:setAnchorPoint(ccp(0.5,0))
    _leftTimeLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.44,_carryItem:getPositionY()+_carryItem:getContentSize().height*1.35))
    -- _leftTimeLabel:setColor(horseColor[1])
    _bottomBg:addChild(_leftTimeLabel)

    _leftCarryTimeNumLabel = CCLabelTTF:create(leftNum.."/"..dbInfo.free_transport,g_sFontName,25)
    _leftCarryTimeNumLabel:setAnchorPoint(ccp(0,0))
    _leftCarryTimeNumLabel:setPosition(ccp(_leftTimeLabel:getPositionX()+_leftTimeLabel:getContentSize().width*0.5,_leftTimeLabel:getPositionY()))
    _bottomBg:addChild(_leftCarryTimeNumLabel)

    local buyCarryNumItem = CCMenuItemImage:create("images/forge/add_h.png", "images/forge/add_n.png")
    	  buyCarryNumItem:setAnchorPoint(ccp(0,0.5))
    	  buyCarryNumItem:setPosition(ccp(_leftCarryTimeNumLabel:getPositionX()+_leftCarryTimeNumLabel:getContentSize().width,_leftCarryTimeNumLabel:getPositionY()+_leftCarryTimeNumLabel:getContentSize().height*0.5))
   		  buyCarryNumItem:registerScriptTapHandler(buyCarryAction)
   	_menu:addChild(buyCarryNumItem)

   	local goldNum = UserModel.getGoldNumber()
    _leftGoldLabel = CCLabelTTF:create(goldNum,g_sFontName,25)
    _leftGoldLabel:setColor(ccc3(255,255,0))
    _leftGoldLabel:setAnchorPoint(ccp(1,0))
    _leftGoldLabel:setPosition(ccp(_leftTimeLabel:getPositionX()-_leftTimeLabel:getContentSize().width*0.5-20,freshItem:getPositionY()+freshItem:getContentSize().height))
    _bottomBg:addChild(_leftGoldLabel)

    local leftGoldWordLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_452"),g_sFontName,25)
    leftGoldWordLabel:setAnchorPoint(ccp(1,0))
    leftGoldWordLabel:setPosition(ccp(_leftGoldLabel:getPositionX()-_leftGoldLabel:getContentSize().width,freshItem:getPositionY()+freshItem:getContentSize().height))
    _bottomBg:addChild(leftGoldWordLabel)

   	_rewardBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
	_rewardBg:setContentSize(CCSizeMake(633,150))
	_rewardBg:setScale(g_fScaleX)
	_rewardBg:setPosition(_layer:getContentSize().width/2, _bottomBg:getContentSize().height*MainScene.elementScale)
	_rewardBg:setAnchorPoint(ccp(0.5,0))
	_layer:addChild(_rewardBg,11)
	loadRewardTableView()
	-- 创建天命属性sprite
	local destinyLabelBg= CCScale9Sprite:create("images/common/astro_labelbg.png")
	destinyLabelBg:setContentSize(CCSizeMake(183,40))
	destinyLabelBg:setAnchorPoint(ccp(0.5,0.5))
	destinyLabelBg:setPosition(_rewardBg:getContentSize().width/2, _rewardBg:getContentSize().height)
	_rewardBg:addChild(destinyLabelBg)

	local destinyLabel= CCLabelTTF:create(GetLocalizeStringBy("llp_376"), g_sFontPangWa, 24)
	destinyLabel:setColor(ccc3(0xff,0xf6,0x00))
	destinyLabel:setPosition(destinyLabelBg:getContentSize().width/2, destinyLabelBg:getContentSize().height/2)
	destinyLabel:setAnchorPoint(ccp(0.5,0.5))
	destinyLabelBg:addChild(destinyLabel)
end

function inviteAction( tag,item )
	-- body
	HorseInviteDialog.showInviteLayer( -2000, 1000)
end

function afterLookCallBack()
	-- body
	local uid = UserModel.getUserUid()
	require "script/ui/horse/HorseTeamInfoDialog"
	HorseTeamInfoDialog.showInviteLayer(-2000,1000,uid)
end

function lookAction( tag, item )
	-- body
	local uid = UserModel.getUserUid()
	HorseController.ChargeDartLook(afterLookCallBack,uid)
end

function loadInviteFriend( pData )
	-- body
	_inviteMenu = CCMenu:create()
	_inviteMenu:setPosition(ccp(0,0))
	_inviteMenu:setTouchPriority(_touchPriority - 5)
	_topNameBg:addChild(_inviteMenu)
	local inviteItem = nil
	if(tonumber(pData.assistance_uid)~=0)then
		inviteItem  = CCMenuItemImage:create("images/horse/teaminfo.png", "images/horse/teaminfoh.png")
		inviteItem:registerScriptTapHandler(lookAction)
	else
		inviteItem  = CCMenuItemImage:create("images/horse/invitefriend.png", "images/horse/invitefriendh.png")	
		inviteItem:registerScriptTapHandler(inviteAction)
	end
	inviteItem:setAnchorPoint(ccp(0,0.5))
   	inviteItem:setPosition(ccp(0,_topNameBg:getContentSize().height*0.5))
   	_inviteMenu:addChild(inviteItem,1,1)
end

function preAndRankAction( ... )
	-- body
	require "script/ui/horse/HorseRewardPreviewLayer"
    local layer = HorseRewardPreviewLayer.createLayer()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(layer,1999)
end

function loadTopNameBg( ... )
	_topNameBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
	_layer:addChild(_topNameBg, 10)
	_topNameBg:setAnchorPoint(ccp(0.5, 1))
	_topNameBg:setPosition(ccpsprite(0.5, 1, _layer))
	_topNameBg:setPreferredSize(CCSizeMake(640, 150))
	_topNameBg:setScale(MainScene.elementScale)

	local titleSprite = CCSprite:create("images/horse/carrytitle.png")
		  titleSprite:setAnchorPoint(ccp(0.5,0.5))
		  titleSprite:setPosition(ccp(_topNameBg:getContentSize().width*0.5,_topNameBg:getContentSize().height*0.5))
	_topNameBg:addChild(titleSprite)

	--按钮Menu
    local btnMenuBar = CCMenu:create()
          btnMenuBar:setTouchPriority(_touchPriority - 5)
          btnMenuBar:setPosition(ccp(0,0))
    _topNameBg:addChild(btnMenuBar)
    -- 关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
          closeBtn:setPosition(ccp(_topNameBg:getContentSize().width,_topNameBg:getContentSize().height*0.5))
          closeBtn:setAnchorPoint(ccp(1,0.5))
          closeBtn:registerScriptTapHandler(close)
    btnMenuBar:addChild(closeBtn)

    local preBoxMenuItem = CCMenuItemImage:create("images/match/reward_n.png","images/match/reward_h.png")
	preBoxMenuItem:setAnchorPoint(ccp(0,1))
	preBoxMenuItem:setPosition(ccp(0, 0))
	preBoxMenuItem:registerScriptTapHandler(preAndRankAction)
	btnMenuBar:addChild(preBoxMenuItem)

	local leftFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
	leftFlowerSprite:setAnchorPoint(ccp(1,0.5))
	leftFlowerSprite:setPosition(ccp(_topNameBg:getContentSize().width*0.5,0))
	_topNameBg:addChild(leftFlowerSprite)

	local rightFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
	rightFlowerSprite:setScaleX(-leftFlowerSprite:getScaleX())
	rightFlowerSprite:setAnchorPoint(ccp(1,0.5))
	rightFlowerSprite:setPosition(ccp(_topNameBg:getContentSize().width*0.5,0))
	_topNameBg:addChild(rightFlowerSprite)
end

function loadHorses( pData )
	if(_bossTableView~=nil)then
		_bossTableView:removeFromParentAndCleanup(true)
		_bossTableView = nil
	end
	local cellSize = _cellSize
	local numberOfCells = 6
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize
        elseif fn == "cellAtIndex" then
            r = createHorsesCell(a1)
        elseif fn == "numberOfCells" then
            r = numberOfCells
        elseif fn == "cellTouched" then
        elseif (fn == "scroll") then
        	
        end
        return r
    end)
    _bossTableView = LuaTableView:createWithHandler(h, CCSizeMake(g_winSize.width, 600 * MainScene.elementScale))
    _layer:addChild(_bossTableView)
    _bossTableView:setAnchorPoint(ccp(0.5, 0.5))
    _bossTableView:setPosition(ccp(_layer:getContentSize().width * 0.5, g_winSize.height * 0.67))
    _bossTableView:ignoreAnchorPointForPosition(false)
    _bossTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _bossTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _bossTableView:setTouchPriority(_touchPriority - 10)
    _bossTableView:setTouchEnabled(false)
   
    _curIndex = tonumber(pData.stage_id)-1
    local offset = _bossTableView:getContentOffset()
    if _curIndex > 0 or _curIndex < 4 then
    	offset.x = -(_curIndex) * _cellSize.width
    	_bossTableView:setContentOffset(offset)
	end
    refreshBossCell()
end

function createHorsesCell(index)
	local cellSize = _cellSize
	local cell = CCTableViewCell:create()
	cell:setContentSize(cellSize)
	if index == 0 or index == 5 then
		return cell
	end
	--local node = CCLayerColor:create(ccc4(100, 0, 0, 100))
	local node = CCSprite:create()
	cell:addChild(node)
	node:setContentSize(CCSizeMake(213, 550))
	node:setAnchorPoint(ccp(0.5, 0.5))
	node:setPosition(ccpsprite(0.5, 0.5, cell))
	node:setTag(HERO_TAG)
	node:setScale(MainScene.elementScale)
	node:ignoreAnchorPointForPosition(false)
	node:setCascadeColorEnabled(true)

	local hero = CCSprite:create(horseTable[index])
	node:addChild(hero)
	hero:setAnchorPoint(ccp(0.5, 0))
	hero:setPosition(ccp(node:getContentSize().width * 0.5, 75))
	-- hero:setScale(0.8)

	local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	hero:addChild(nameBg)
	nameBg:setPreferredSize(CCSizeMake(180, 32))
	nameBg:setAnchorPoint(ccp(0.5, 1))
	nameBg:setPosition(ccp(hero:getContentSize().width * 0.4, 0))

	local name =  CCRenderLabel:create(horseNameTable[index], g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_shadow)
	nameBg:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.5))
	name:setPosition(ccp(nameBg:getContentSize().width * 0.5, nameBg:getContentSize().height * 0.5))
	name:setColor(horseColor[index])

	return cell
end

function close( ... )
	if _closeCallback ~= nil then
		_closeCallback()
	end
	if(_layer~=nil)then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
	end
end

function onNodeEvent(event)
    if (event == "enter") then
        _layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _layer:setTouchEnabled(true)
    elseif (event == "exit") then
    	HorseService.remove_agree_help_push()
		_layer:unregisterScriptTouchHandler()
		_layer = nil
	end
end

function onTouchesHandler(event, x, y)
	if _tableViewIsMoving == true then
		_is_handle_touch = false
		return true
	end
	local position = _bossTableView:convertToNodeSpace(ccp(x, y))
    if event == "began" then
        -- local rect = _bossTableView:boundingBox()
        -- if rect:containsPoint(_bossTableView:getParent():convertToNodeSpace(ccp(x, y))) then
        --     _drag_began_x = _bossTableView:getContentOffset().x
        --     _touch_began_x = position.x
        --     _curIndexAtTouchBegan = _curIndex
        --     beginRefreshBossCell()
        --     _is_handle_touch = true
        -- else
        --     _is_handle_touch = false
        -- end
        -- local offset = _bossTableView:getContentOffset()
        return true
    elseif event == "moved" then
        -- if _is_handle_touch == true then
        --     local distance = position.x - _touch_began_x
        --     local offsetDistance = _bossTableView:getContentOffset().x - _drag_began_x
       	-- 	if offsetDistance > 0 and offsetDistance > _cellSize.width then
       	-- 		return
       	-- 	elseif offsetDistance < 0 and offsetDistance < -_cellSize.width then
       	-- 		return
       	-- 	end
       	-- 	local offset = _bossTableView:getContentOffset()
       	-- 	offset.x = _drag_began_x + distance
       	-- 	local minX = -(4 - 1) * _cellSize.width
        --     if offset.x < minX then
        --         offset.x = minX
        --     elseif offset.x > 0 then
        --     	offset.x = 0
        --     end
        --     _bossTableView:setContentOffset(offset)
        -- end
    elseif event == "ended" or event == "cancelled" then
        -- if _is_handle_touch == true then
        --     local drag_ended_x = _bossTableView:getContentOffset().x
        --     local touchEndPosition = _bossTableView:getParent():convertToNodeSpace(ccp(x, y))
        --     local drag_distance = touchEndPosition.x - _touch_began_x
        --     local offset = _bossTableView:getContentOffset()
        --     offset.x = -(_curIndex - 1) * _cellSize.width
        --     _tableViewIsMoving = true
        --     local array = CCArray:create()
        --     array:addObject(CCMoveTo:create(0.15, offset))
        --     local container = _bossTableView:getContainer()
        --     local endCallFunc = function()
        --     	_bossTableView:setContentOffset(offset)
        --     	refreshBossCell()
        --     	endRefreshBossCell()
            	
        --         _tableViewIsMoving = false
        --     end
        --     array:addObject(CCCallFunc:create(endCallFunc))
        --     container:runAction(CCSequence:create(array))
        --     reFreshRewardCell()
        --     if(_curIndex~=tonumber(_pageInfo.stage_id))then
        --     	_carryItem:setEnabled(false)
        --     else
        --     	_carryItem:setEnabled(true)
        --     end
        --     print("_curIndex ======", _curIndex)
        -- end
    end
end

function beginRefreshBossCell( ... )
	schedule(_layer, refreshBossCell, 1 / 60)
end

function endRefreshBossCell( ... )
	_layer:cleanup()
end

function refreshBossCell( ... )
	if _bossTableView ~= nil and _bossTableView:getContainer():getChildren():count() > 0  then
		local container = _bossTableView:getContainer()
		local cells = container:getChildren()
		local mainIndex = 0
		local maxScale = 0
		for i = 0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = cell:getChildByTag(HERO_TAG)
			if hero ~= nil then
				local position = cell:convertToWorldSpace(ccp(hero:getPositionX(), hero:getPositionY()))
				local scale = 1 - math.abs(g_winSize.width * 0.5 - position.x) / g_winSize.width
				hero:setScale(MainScene.elementScale * scale)
				if scale > maxScale then
					mainIndex = cell:getIdx()
					maxScale = scale
				end
				container:reorderChild(cell, hero:getScale() * 10)
			end
		end
		for i=0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = tolua.cast(cell:getChildByTag(HERO_TAG), "CCSprite")
			if hero ~= nil then
				if cell:getIdx() ~= mainIndex then
					hero:setColor(ccc3(0xad, 0xad, 0xad))
				else
					hero:setColor(ccc3(0xff, 0xff, 0xff))
				end
			end
		end
		if _curIndex ~= mainIndex and mainIndex ~= 0 and mainIndex ~= 4 + 1 then
    		_curIndex = mainIndex
		end
	end
end

function loadRefreshNode()
    _refreshNode = CCNode:create()
    _layer:addChild(_refreshNode, 10)
    _refreshNode:setAnchorPoint(ccp(0.5, 1))
    _refreshNode:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height - 15 * g_fScaleX))
    _refreshNode:setContentSize(CCSizeMake(640, 150))
    _refreshNodeMenu = CCMenu:create()
    _refreshNode:addChild(_refreshNodeMenu)
    _refreshNodeMenu:setPosition(ccp(0, 0))
    _refreshNodeMenu:setContentSize(_refreshNode:getContentSize())
    _refreshNodeMenu:setTouchPriority(_touchPriority - 10)
    _refreshNode:setScale(MainScene.elementScale)
end

function reloadData( ... )
	local contentOffset = _bossTableView:getContentOffset()
	_bossTableView:reloadData()
	if _isWin == true then
		contentOffset.x = contentOffset.x - _cellSize.width
		if contentOffset.x < -_bossTableView:getContentSize().width + _bossTableView:getViewSize().width then
        contentOffset.x = -_bossTableView:getContentSize().width + _bossTableView:getViewSize().width
    end
	end
	_bossTableView:setContentOffset(contentOffset)
	refreshBossCell()
end