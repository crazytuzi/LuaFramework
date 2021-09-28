-- FileName: TreasureRoomLayer.lua
-- Author: bzx
-- Date: 15-04-07
-- Purpose: 藏宝阁

module("TreasureRoomLayer", package.seeall)

kTodayBox = 1
kLastBox = 2

local _layer 
local _touchPriority = -600
local _zOrder = 10
local _boxTableView = nil
local _boxCellSize = CCSizeMake(640, 173)
local _receiveItem = nil
local _totalExploits = 0
local _boxBg = nil
local _closeTipLabel = nil
local _curBoxType = kTodayBox
local _radioData = nil

function show( ... )
	local getBoxInfoCallFunc = function ( ... )
		_layer = create()
		MainScene.changeLayer(_layer, "TreasureRoomLayer")
	end
	GuildBossCopyService.getLastBoxInfo()
	GuildBossCopyService.getBoxInfo(getBoxInfoCallFunc)
end

function init( ... )
	_boxTableView = nil
	_closeTipLabel = nil
end

function create( ... )
	init()
	_layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 0xff))
	loadBg()
	loadTop()
	loadBoxes()
	loadRadioItem()
	loadBottom()
	schedule(_boxBg, refreshBoxCloseTip, 1)
	refreshBoxCloseTip()
	return _layer
end

function loadBg( ... )
	local bg = CCSprite:create("images/guild_boss_copy/open_box_bg.jpg")
	_layer:addChild(bg)
	bg:setAnchorPoint(ccp(0.5, 0.5))
	bg:setPosition(ccps(0.5, 0.85))
	bg:setScale(MainScene.bgScale)
end

function loadBottom( ... )
	local bottomNode = CCScrollView:create()
	_layer:addChild(bottomNode)
	bottomNode:setViewSize(CCSizeMake(640, 140))
	bottomNode:setContentSize(CCSizeMake(640, 140))
	bottomNode:ignoreAnchorPointForPosition(false)
	bottomNode:setAnchorPoint(ccp(0.5, 0))
	bottomNode:setPosition(ccps(0.5, 0))
	bottomNode:setTouchEnabled(false)
	bottomNode:setScale(g_fScaleX)

	local bottomBg = CCSprite:create("images/guild_boss_copy/bottom_bg.png")
	bottomNode:addChild(bottomBg)
	bottomBg:setAnchorPoint(ccp(0.5, 0))
	bottomBg:setPosition(ccpsprite(0.5, 0, bottomNode))
	bottomBg:setScale(5)

	local tip1 = CCRenderLabel:create(GetLocalizeStringBy("key_10126"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	bottomNode:addChild(tip1)
	tip1:setAnchorPoint(ccp(0, 0.5))
	tip1:setPosition(ccp(50, 86))

	local richInfo = {
		lineAlignment = 2,
		labelDefaultColor = ccc3(0x00, 0xe4, 0xff),
		labelDefaultSize = 21,
		defaultType = "CCRenderLabel",
		defaultRenderType = type_shadow,
		elements = {
			{
 				text = GetLocalizeStringBy("key_10127")
			},
			{
				["type"] = "CCSprite",
				image = "images/guild_boss_copy/exploits_icon.png",
			},
			{
				text = GuildBossCopyData.getExtraReward()
			},
			{
				text = "+",
				color = ccc3(0xff, 0xff, 0xff)
			},
			{
				text = GuildBossCopyData.getRemainReward()
			},
			{
				text = GetLocalizeStringBy("key_10128"),
				size = 18,
				color = ccc3(0x00, 0xff, 0x18)
			}
		}
	}
	_totalExploits = GuildBossCopyData.getExtraReward() + GuildBossCopyData.getRemainReward()
	local tip2 = LuaCCLabel.createRichLabel(richInfo)
	bottomNode:addChild(tip2)
	tip2:setAnchorPoint(ccp(0, 0.5))
	tip2:setPosition(ccp(50, 40))

	local bottomMenu = CCMenu:create()
	bottomNode:addChild(bottomMenu)
	bottomMenu:setPosition(ccp(0, 0))
	bottomMenu:setContentSize(CCSizeMake(640, 140))
	bottomMenu:setTouchPriority(_touchPriority - 5)

    local normalRichInfo = {
    	labelDefaultColor = ccc3(0xff, 0xf6, 0x00),
   	 	defaultType = "CCRenderLabel",
   	 	labelDefaultFont = g_sFontPangWa,
    	labelDefaultSize = 30,
    	elements = {
    		{
    			text = GetLocalizeStringBy("key_10129")
    		}
    	}
	}
	local disabledRichInfo = table.hcopy(normalRichInfo, {})
	disabledRichInfo.labelDefaultColor = ccc3(0x88, 0x88, 0x88)
   	_receiveItem = LuaCC.create9ScaleMenuItemWithRichInfo("images/common/btn/btn_red_n.png","images/common/btn/btn_red_h.png","images/common/btn/btn1_g.png", CCSizeMake(150, 73), normalRichInfo, normalRichInfo, disabledRichInfo)
   	bottomMenu:addChild(_receiveItem)
    _receiveItem:setAnchorPoint(ccp(0.5, 0.5))
    _receiveItem:setPosition(ccp(547, bottomMenu:getContentSize().height * 0.5))
    _receiveItem:registerScriptTapHandler(receiveCallback)
	if GuildBossCopyData.getUserInfo().recv_pass_reward_time ~= "0" then
		_receiveItem:setEnabled(false)
	end
end

function refreshBoxCloseTip( ... )
	if _closeTipLabel ~= nil then
		_closeTipLabel:removeFromParentAndCleanup(true)
	end
	local time = TimeUtil.getIntervalByTime("240000")
	local curTime = TimeUtil.getSvrTimeByOffset()
	local remainTime = time - curTime
	local labelInfo = {
		labelDefaultSize = 18,
		defaultType = "CCRenderLabel",
		elements = {
			{
				text = TimeUtil.getTimeString(remainTime),
				color = ccc3(0x00, 0xff, 0x18)
			}
		}
	}
	_closeTipLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("key_10130"), labelInfo)
	_boxBg:addChild(_closeTipLabel)
	_closeTipLabel:setAnchorPoint(ccp(0.5, 0))
	_closeTipLabel:setPosition(ccp(_boxBg:getContentSize().width * 0.5, _boxBg:getContentSize().height + 40))
end

function tabSelectedCallback(tag, menuItem)
	if tag  == 2 then
		local lastBoxInfo = GuildBossCopyData.getLastBoxInfo()
		if table.isEmpty(lastBoxInfo) then
			AnimationTip.showTip(GetLocalizeStringBy("key_10213"))
			menuItem:setEnabled(true)
			_radioData.items[1]:setEnabled(false)
			return
		end
	end

	_curBoxType = tag
	_boxTableView:reloadData()
	_boxTableView:setContentOffset(ccp(0, _boxTableView:getViewSize().height - _boxTableView:getContentSize().height))
end

function loadRadioItem( ... )
	require "script/ui/guildBossCopy/DamageRankListLayer"
	local lastItem = DamageRankListLayer.createItem(GetLocalizeStringBy("key_10214"))
    local todayItem = DamageRankListLayer.createItem(GetLocalizeStringBy("key_10215"))

    _radioData = {
	    touch_priority   = _touchPriority - 3,   	-- 触摸优先级
	    space            = 14,   					-- 按钮间距
	    callback         = tabSelectedCallback,   	-- 按钮回调
	    direction        = 1,   					-- 方向 1为水平，2为竖直
	    defaultIndex     = 1,    					-- 默认选择的index
	    items = {
	    	todayItem,
	        lastItem,
	    }
	}
	local radioMenu = LuaCCSprite.createRadioMenuWithItems(_radioData)
	_boxBg:addChild(radioMenu)
	radioMenu:setAnchorPoint(ccp(0.5, 0))
	radioMenu:setPosition(ccp(_boxBg:getContentSize().width * 0.5, _boxBg:getContentSize().height - 13))
end

function loadBoxes( ... )
	_boxBg = CCScale9Sprite:create("images/guild_boss_copy/big_box.png")
	_layer:addChild(_boxBg)
	_boxBg:setAnchorPoint(ccp(0.5, 0))
	_boxBg:setPosition(ccp(g_winSize.width * 0.5, 140 * g_fScaleX))
	_boxBg:setScale(g_fScaleX)
	local height = g_winSize.height / g_fScaleX  - 330
	if height < 395 then
		height = 395
	end
	_boxBg:setContentSize(CCSizeMake(640, height))
	local cornerInfos = {
		{image = "images/guild_boss_copy/corner_up.png", scaleX = -1, position = ccp(0, height - 51), anchorPoint = ccp(1, 1)},
		{image = "images/guild_boss_copy/corner_up.png", scaleX = 1, position = ccp(640, height - 51), anchorPoint = ccp(1, 1)},
		{image = "images/guild_boss_copy/corner_down.png", scaleX = -1, position = ccp(0, 5), anchorPoint = ccp(1, 0)},
		{image = "images/guild_boss_copy/corner_down.png", scaleX = 1, position = ccp(640, 5), anchorPoint = ccp(1, 0)}
	}
	for i = 1, #cornerInfos do
		local cornerInfo = cornerInfos[i]
		local corner = CCSprite:create(cornerInfo.image)
		_boxBg:addChild(corner, 2)
		corner:setAnchorPoint(cornerInfo.anchorPoint)
		corner:setPosition(cornerInfo.position)
		corner:setScaleX(cornerInfo.scaleX)
	end
	
	local cellCount = math.ceil(getBoxCount() / 3)
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
        local r
        if (fn == "cellSize") then
            r = _boxCellSize
        elseif (fn == "cellAtIndex") then
           	r = createBoxCell(a1 + 1)
        elseif (fn == "numberOfCells") then
            r = cellCount
        elseif (fn == "cellTouched") then
        elseif (fn == "scroll") then
        else
        end
        return r
    end)

    _boxTableView = LuaTableView:createWithHandler(handler, CCSizeMake(_boxCellSize.width, height - 66))
    _boxBg:addChild(_boxTableView)
    _boxTableView:setAnchorPoint(ccp(0, 0))
    _boxTableView:setPosition(ccp(0, 10))
    _boxTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _boxTableView:setTouchPriority(_touchPriority - 2)
end


function getBoxCount(dayTag)
	local boxRewardInfos = nil
	if _curBoxType == kTodayBox then
		boxRewardInfos = parseField(GuildBossCopyData.getChestData(), 2)
	elseif _curBoxType == kLastBox then
		boxRewardInfos = parseField(GuildBossCopyData.getLastChestData(), 2)
	end
	local boxCount = 0
	for i = 1, #boxRewardInfos do
		local boxRewardInfo = boxRewardInfos[i]
		boxCount = boxCount + boxRewardInfo[4]
	end
	return boxCount
end

function createBoxCell(p_index )
	local cell = CCTableViewCell:create()
	cell:setContentSize(_boxCellSize)
	local boxBar = CCSprite:create("images/guild_boss_copy/box_bar.png")
	cell:addChild(boxBar)
	boxBar:setAnchorPoint(ccp(0.5, 0))
	boxBar:setPosition(ccp(_boxCellSize.width * 0.5, 0))

	local boxMenu = BTSensitiveMenu:create()
	cell:addChild(boxMenu)
	boxMenu:setPosition(ccp(0, 0))
	boxMenu:setTouchPriority(_touchPriority - 1)
	boxMenu:setContentSize(_boxCellSize)
	local boxRewardInfos = nil
	local boxInfoes = nil
	if _curBoxType == kTodayBox then
		boxInfoes = GuildBossCopyData.getBoxInfo()
		boxRewardInfos = parseField(GuildBossCopyData.getChestData(), 2)
	elseif _curBoxType == kLastBox then
		boxInfoes = GuildBossCopyData.getLastBoxInfo().box
		boxRewardInfos = parseField(GuildBossCopyData.getLastChestData(), 2)
	end
	local boxCount = getBoxCount()
	for i = 1, 3 do
		local boxIndex = (p_index - 1) * 3 + i
		if boxIndex > boxCount then
			break
		end
		local boxInfo = boxInfoes[tostring(boxIndex)]
		local boxItem = nil
		if boxInfo == nil then
		 	boxItem = CCMenuItemImage:create("images/guild_boss_copy/box_close.png", "images/guild_boss_copy/box_close.png")
		 	boxItem:registerScriptTapHandler(openBoxCallback)
		else
			boxItem = CCMenuItemImage:create("images/guild_boss_copy/box_open.png", "images/guild_boss_copy/box_open.png")
			local boxRewardInfo = boxRewardInfos[tonumber(boxInfo.reward) + 1]
			local rewardInfo = string.format("%d|%d|%d", boxRewardInfo[1], boxRewardInfo[2], boxRewardInfo[3])
			local itemData = ItemUtil.getItemsDataByStr(rewardInfo)
			local showDownMenu = function()
        		MainScene.setMainSceneViewsVisible(false,false,false)
    		end
			local icon,itemName,itemColor = ItemUtil.createGoodsIcon(itemData[1], _touchPriority - 1, _zOrder + 10, nil,showDownMenu,nil,nil,false)
    		boxItem:addChild(icon)
			icon:setAnchorPoint(ccp(0.5, 0.5))
			icon:setPosition(ccpsprite(0.45, 0.6, boxItem))

			local nameBg = CCScale9Sprite:create("images/common/bg/bg2.png")
			boxItem:addChild(nameBg)
			nameBg:setAnchorPoint(ccp(0.5, 0))
			nameBg:setPosition(ccpsprite(0.4, 0, nameBg))
			nameBg:setScaleY(0.8)
			local nameLabel = CCRenderLabel:create(boxInfo.uname, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
			nameBg:addChild(nameLabel)
			nameLabel:setAnchorPoint(ccp(0.5, 0.5))
			nameLabel:setPosition(ccpsprite(0.5, 0.5, nameBg))
			nameLabel:setScaleY(1 / nameBg:getScaleY())
			local sex = HeroModel.getSex(tonumber(boxInfo.htid))
			local nameColor = nil
			if sex == 1 then
				nameColor = ccc3(0x00, 0xe4, 0xff)
			else
				nameColor = ccc3(0xf9, 0x59, 0xff)
			end
			nameLabel:setColor(nameColor)

		end
		boxMenu:addChild(boxItem)
		boxItem:setAnchorPoint(ccp(0.5, 0))
		boxItem:setPosition(ccp(135 + (i - 1) * 193, 10))
		boxItem:setTag(boxIndex)
	end
	return cell
end

function openBoxCallback(p_tag)
	if _curBoxType == kLastBox then
		AnimationTip.showTip(GetLocalizeStringBy("key_10216"))
		return
	end
	if ItemUtil.isBagFull() then
		return 
	end
	if tonumber(GuildBossCopyData.getUserInfo().recv_box_reward_time) ~= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_10131"))
		return
	end
	local _, currHp = GuildBossCopyData.getBossCopyHpInfo()
	if currHp > 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_10132"))
		return
	end
	local boxIndex = p_tag
	local openBoxCallFunc = function ( p_data )
		if p_data.ret == "after_pass" then
			AnimationTip.showTip(GetLocalizeStringBy("key_10133"))
			return
		elseif p_data.ret == "already" then
			AnimationTip.showTip(GetLocalizeStringBy("key_10134"))
		end
		local cellIndex = math.floor((boxIndex - 1) / 3)
		_boxTableView:updateCellAtIndex(cellIndex)
		if p_data.ret == "ok" then
			local rewardInfo = GuildBossCopyData.getBoxRewardInfo()
			local boxInfo = rewardInfo[tonumber(p_data.extra) + 1]
			local rewardInfo = string.format("%d|%d|%d", boxInfo[1], boxInfo[2], boxInfo[3])
			if boxInfo[1] == 1 then
				UserModel.addSilverNumber(boxInfo[3])
			elseif boxInfo[1] == 3 then
				UserModel.addGoldNumber(boxInfo[3])
			end
			require "script/ui/item/ReceiveReward"
        	ReceiveReward.showRewardWindow(ItemUtil.getItemsDataByStr(rewardInfo), nil, nil, _touchPriority - 20)
    	end
	end
	GuildBossCopyService.openBox(openBoxCallFunc, boxIndex)
end

function receiveCallback( ... )
	local _, currHp = GuildBossCopyData.getBossCopyHpInfo()
	if currHp > 0 then
		AnimationTip.showTip(GetLocalizeStringBy("key_10135"))
		return
	end
	local recvPassRewardCallFunc = function (p_data)
		if p_data == "after_pass" then
			AnimationTip.showTip(GetLocalizeStringBy("key_10133"))
			return
		end
		AnimationTip.showTip(string.format(GetLocalizeStringBy("key_10136"), _totalExploits))
		GuildDataCache.addExploitsCount(_totalExploits)
		_receiveItem:setEnabled(false)
	end
	GuildBossCopyService.recvPassReward(recvPassRewardCallFunc)
end

function loadTop( ... )
	local menu = CCMenu:create()
	_layer:addChild(menu)
	menu:setPosition(ccp(0, 0))

	local treasurePreviewItem = CCMenuItemImage:create("images/guild_boss_copy/preview_n.png", "images/guild_boss_copy/preview_h.png")
	menu:addChild(treasurePreviewItem)
	treasurePreviewItem:setAnchorPoint(ccp(0.5, 0.5))
	treasurePreviewItem:setPosition(ccps(0.1, 0.94))
	treasurePreviewItem:registerScriptTapHandler(treasurePreviewCallback)
	treasurePreviewItem:setScale(MainScene.elementScale)

	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	menu:addChild(backItem)
	backItem:setAnchorPoint(ccp(0.5, 0.5))
	backItem:setPosition(ccps(0.92, 0.94))
	backItem:registerScriptTapHandler(backCallback)
	backItem:setScale(MainScene.elementScale)

	local title = CCSprite:create("images/guild_boss_copy/box_title.png")
	_layer:addChild(title)
	title:setAnchorPoint(ccp(0.5, 0.5))
	title:setPosition(ccps(0.5, 0.93))
	title:setScale(MainScene.elementScale)
end

function treasurePreviewCallback( ... )
	require "script/ui/guildBossCopy/TreasureRoomPreviewLayer"
	TreasureRoomPreviewLayer.show(_touchPriority - 20, _zOrder + 10)
end

function backCallback( ... )
	local groupCopyId = tonumber(GuildBossCopyData.getUserInfo().curr)
	CopyPointLayer.show(groupCopyId)
end