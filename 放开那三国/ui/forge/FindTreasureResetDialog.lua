-- Filename: FindTreasureResetDialog.lua
-- Author: bzx
-- Date: 2014-12-18
-- Purpose: 选择进入寻龙探宝or寻龙试炼

module("FindTreasureResetDialog", package.seeall)

require "script/ui/tip/RichAlertTip"

local _layer 
local _zOrder = 600
local _touchPriority = -1024

local _normalItem

function show( ... )
	_layer = create()
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function create( ... )
	local dialogHeight = 510
	if FindTreasureData.getHightestPoint() > FindTreasureData.getHightModePoinCondition() then
		dialogHeight = 440
	end
	local dialogInfo = {
    	title = GetLocalizeStringBy("key_8435"),
    	size = CCSizeMake(541, dialogHeight),
    	priority = _touchPriority,
    	swallowTouch = true
	}
	_layer = LuaCCSprite.createDialog_1(dialogInfo)

	local dialog = dialogInfo.dialog
    local menu = CCMenu:create()
    dialog:addChild(menu)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touchPriority - 1)
    local normalItem = CCMenuItemImage:create("images/forge/normal_n.png", "images/forge/normal_h.png")
    local normalTitle = CCSprite:create("images/forge/normal_title.png")
    normalItem:addChild(normalTitle)
    normalTitle:setAnchorPoint(ccp(0.5, 0.5))
    normalTitle:setPosition(ccp(normalItem:getContentSize().width * 0.5, 250))
    menu:addChild(normalItem)
    normalItem:setAnchorPoint(ccp(0.5, 0.5))
    normalItem:setPosition(ccp(145, dialog:getContentSize().height - 240))
    normalItem:registerScriptTapHandler(normalCallback)
    _normalItem = normalItem
    local hightNormal = CCSprite:create("images/forge/hight_n.png")
    local hightTitleNormal = CCSprite:create("images/forge/hight_title.png")
    hightNormal:addChild(hightTitleNormal)
    hightTitleNormal:setAnchorPoint(ccp(0.5, 0.5))
    hightTitleNormal:setPosition(ccp(hightNormal:getContentSize().width * 0.5, 260))

    local hightSelected = CCSprite:create("images/forge/hight_h.png")
    local hightTitleSelected = CCSprite:create("images/forge/hight_title.png")
    hightSelected:addChild(hightTitleSelected)
    hightTitleSelected:setAnchorPoint(ccp(0.5, 0.5))
   	hightTitleSelected:setPosition(ccp(hightSelected:getContentSize().width * 0.5, 260))

   	local hightDisabled = BTGraySprite:createWithNodeAndItChild(hightNormal)

   	local hightItem = CCMenuItemSprite:create(hightNormal, hightSelected, hightDisabled)
   	menu:addChild(hightItem)
   	hightItem:setAnchorPoint(ccp(0.5, 0.5))
   	hightItem:setPosition(ccp(393, dialog:getContentSize().height - 240))
   	hightItem:registerScriptTapHandler(hightCallback)
   	if FindTreasureData.getHightestPoint() < FindTreasureData.getHightModePoinCondition() then
   		hightItem:setEnabled(false)
   		local richInfo = {}
		richInfo.labelDefaultColor = ccc3(0x78, 0x25, 0x00)
		richInfo.labelDefaultSize = 21
		richInfo.labelDefaultFont = g_sFontPangWa
		richInfo.width = 240
		richInfo.elements = {
			{
				text = FindTreasureData.getHightModePoinCondition(),
				color = ccc3(0x00, 0x6d, 0x2f)
			}
		}
	    local tip = GetLocalizeLabelSpriteBy_2("key_8437", richInfo)
	    dialog:addChild(tip, 2)
	    tip:setAnchorPoint(ccp(0.5, 1))
	    tip:setPosition(ccp(393, 85))
   	end
   	local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
   		addNewXunlongGuild()
 	end))
 	_layer:runAction(seq)
	return _layer
end

function normalCallback( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")


	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideFindDragon) then
        XunLongGuide.changLayer()
	end

	if FindTreasureData.isFirstTime() == true then
		selectNormal(true)
		return
	end
	local richInfo = {}
	richInfo.elements = {
		{
			text = GetLocalizeStringBy("key_8436")
		}
	}
    RichAlertTip.showAlert(richInfo, selectNormal, true, nil, GetLocalizeStringBy("key_8129"))
end

function getNormalItem( ... )
	return _normalItem
end


function selectNormal( isConfirm )
	if isConfirm == false then
		return
	end
	if FindTreasureData.isFirstTime() == true then
		FindTreasureLayer.show2()
		_layer:removeFromParentAndCleanup(true)
		FindTreasureData.setFirstTime(false)
	else
		FindTreasureService.dragonReset(handleDragonReset)
	end
end

function handleDragonReset( ... )
	handleDragonTrial()
end


function hightCallback( ... )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local richInfo = {}
	richInfo.elements = {
		{
			text = GetLocalizeStringBy("key_8438")
		}
	}
    RichAlertTip.showAlert(richInfo, selectHight, true, nil, GetLocalizeStringBy("key_8129"))
end

function selectHight( isConfirm )
	if isConfirm == false then
		return
	end
	FindTreasureService.dragonTrial(handleDragonTrial)
end

function handleDragonTrial( ... )
	local resetItemInfo = FindTreasureData.getResetItemInfo()
	FindTreasureData.addItemResetCount(-resetItemInfo[2])
	FindTreasureLayer.handleResetMap()
	_layer:removeFromParentAndCleanup(true)
end

--[[
	@des:寻龙新手引导
--]]
function addNewXunlongGuild( ... )

	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideFindDragon and XunLongGuide.stepNum == 2) then
		require "script/ui/forge/FindTreasureResetDialog"
		local touchRect   = getSpriteScreenRect(FindTreasureResetDialog.getNormalItem())
        XunLongGuide.show(2001, touchRect)
	end
end



