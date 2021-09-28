-- FileName: MissionGoldDialog.lua
-- Author: lcy
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("MissionGoldDialog", package.seeall)
require "script/ui/mission/gold/MissionGoldData"
require "script/ui/mission/gold/MissionGoldController"
local _goldPanel = nil

function init( ... )
	_goldPanel = nil
end

--[[
	@des:创建金币捐献按钮
--]]
function create( ... )
	local goldDataList = MissionGoldData.getDonationList()
	--子菜单背景
	_goldPanel = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
	_goldPanel:setAnchorPoint(ccp(0.2, 1))
	_goldPanel:setContentSize(CCSizeMake(#goldDataList*140 + 20,185))
	_goldPanel:setScale(0)

	local arrowSprite = CCSprite:create("images/common/arrow_panel.png")
	arrowSprite:setAnchorPoint(ccp(0.5, 0))
	arrowSprite:setPosition(ccpsprite(0.5, 0, _goldPanel))
	arrowSprite:setRotation(180)
	_goldPanel:addChild(arrowSprite)

 	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	_goldPanel:addChild(menu)
	menu:setTouchPriority(-500)

	local ox,oy = 30, 10
	local mw = 140
	for i,v in ipairs(goldDataList) do
		local norImage = string.format("images/mission/gold_btn/btn_%d_n.png", i)
		local higImage = string.format("images/mission/gold_btn/btn_%d_h.png", i)

		local item = CCMenuItemImage:create(norImage, higImage)
		item:setAnchorPoint(ccp(0, 0.5))
		item:setPosition(ox + (i-1)*mw, _goldPanel:getContentSize().height*0.6)
		item:registerScriptTapHandler(goldButtonCallback)
		menu:addChild(item, 1, tonumber(v))

		local goldBg = CCScale9Sprite:create("images/common/bg/9s_word.png")
		goldBg:setContentSize(CCSizeMake(105, 38))
		goldBg:setAnchorPoint(ccp(0.5, 1))
		goldBg:setPosition(ccpsprite(0.5, -0.08, item))
		item:addChild(goldBg)

		local nodeMapInfo = {}
		nodeMapInfo[1] = CCSprite:create("images/common/gold.png")
		nodeMapInfo[2] = CCRenderLabel:create(tostring(v), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		nodeMapInfo[2]:setColor(ccc3(0xff, 0xff, 0xff))
		local goldLabel = BaseUI.createHorizontalNode(nodeMapInfo)
		goldLabel:setAnchorPoint(ccp(0.5, 0.5))
		goldLabel:setPosition(ccpsprite(0.5, 0.5, goldBg))
		goldBg:addChild(goldLabel)
	end
	return _goldPanel
end

--[[
	@des:显示子菜单
--]]
function show()
	_goldPanel:stopAllActions()
	local action = CCScaleTo:create(0.2, 1)
	_goldPanel:runAction(action)
end

--[[
	@des:隐藏菜单
--]]
function hide( ... )
	_goldPanel:stopAllActions()
	local action = CCScaleTo:create(0.2, 0)
	_goldPanel:runAction(action)
end

--[[
	@des：金币捐献
--]]
function goldButtonCallback( pTag, pSender )
	local gold = pTag
	local fame = MissionGoldData.getFameByGold(gold)
	local richInfo = {
        lineAlignment = 2, 
        labelDefaultColor = ccc3(0xff, 0xff, 0xff),
        labelDefaultSize = 25,
        labelDefaultFont = g_sFontPangWa,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image ="images/common/gold.png",
            },
            {
                text = tostring(gold),
                color = ccc3(255, 255, 80),
            },
            {
                text = tostring(fame),
                color = ccc3(0xff, 0x00, 0xff),
            }
        }
    }
    require "script/ui/tip/TipByNode"
    local tipFontNode = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lcyx_1967"), richInfo)
	TipByNode.showLayer(tipFontNode,function ( ... )
		MissionGoldController.doMissionGold(gold, nil)
	end)
end