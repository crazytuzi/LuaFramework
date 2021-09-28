-- Filename：	WorldButtonUtil.lua
-- Author：		chengliang
-- Date：		2015-1-16
-- Purpose：		跨服战按钮菜单

module("WorldButtonUtil" , package.seeall)


local _worldButton    = nil
local _worldPanel     = nil
local _worldMaksLayer = nil
local _worldMenu      = nil
local _itemSprite     = nil
local _mask_layer_tag = 20
function init( ... )
	_worldButton    = nil
	_worldButton    = nil
	_worldPanel     = nil
	_worldMaksLayer = nil
	_worldMenu      = nil
	_itemSprite     = nil
end

--[[
	@des: 跨服战，军团战，以及其他战斗一级菜单按钮
--]]
function createButton( ... )

	local normal = CCMenuItemImage:create("images/guild_war/world_btn_n.png", "images/guild_war/world_btn_n.png")
	local hight  = CCMenuItemImage:create("images/guild_war/world_btn_h.png", "images/guild_war/world_btn_h.png")
	hight:setAnchorPoint(ccp(0.5, 0.5))
	normal:setAnchorPoint(ccp(0.5, 0.5))

	_worldMenu = CCMenu:create()
	_worldMenu:setAnchorPoint(ccp(0, 0))
	_worldMenu:setPosition(ccp(0, 0))
	_worldMenu:setContentSize(normal:getContentSize())

	_worldButton = CCMenuItemToggle:create(normal)
	_worldButton:addSubItem(hight)
	_worldButton:setPosition(ccpsprite(0, 0, _worldMenu))
	_worldButton:setAnchorPoint(ccp(0,0))
	_worldButton:registerScriptTapHandler(worldButtonCallback)
	_worldButton:setSelectedIndex(0)
	_worldMenu:addChild(_worldButton)	
	_worldButton:setVisible(false)

	_itemSprite = CCSprite:create()
    _itemSprite:setContentSize(normal:getContentSize())
    _itemSprite:setAnchorPoint(ccp(0.5, 0.5))
    _itemSprite:addChild(_worldMenu, 10)

	createWorldSubMenu()

	local isHaveActivityOpen = false
	require "script/ui/lordWar/LordWarData"
	if( ActivityConfigUtil.isActivityOpen("lordwar") == true
		and LordWarData.getLordIsOk()
		and TimeUtil.getSvrTimeByOffset(0) >= LordWarData.getRoundStartTime( LordWarData.kRegister )
		and TimeUtil.getSvrTimeByOffset(0) <=  LordWarData.getRoundEndTime( LordWarData.kCross2To1 ) )then
			isHaveActivityOpen = true
	end

	print("ActivityConfigUtil.isActivityOpen",ActivityConfigUtil.isActivityOpen("guildwar"))
	print("GuildWarMainData.getIsOk()", GuildWarMainData.getIsOk())

	if( ActivityConfigUtil.isActivityOpen("guildwar") == true
		and GuildWarMainData.getIsOk()
		and TimeUtil.getSvrTimeByOffset(0) >= GuildWarMainData.getStartTime( GuildWarDef.SIGNUP )
		and TimeUtil.getSvrTimeByOffset(0) <=  GuildWarMainData.getEndTime( GuildWarDef.ADVANCED_2) )then
			isHaveActivityOpen = true
	end

	if isHaveActivityOpen then
		local buttonAnimSprite2 = XMLSprite:create("images/guild_war/effect/kuafuzhengba/kuafuzhengba")
		buttonAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
	    buttonAnimSprite2:setPosition(ccpsprite(0.5,0.2,_worldButton))
	    _worldButton:addChild(buttonAnimSprite2,2)
	end

	local redTipSprite = CCSprite:create("images/common/tip_2.png")
	redTipSprite:setPosition(ccpsprite(0.8, 0.8, _worldButton))
	redTipSprite:setAnchorPoint(ccp(0.5, 0.5))
	_worldButton:addChild(redTipSprite, 10)
	redTipSprite:setVisible(false)
	--小红点
	require "script/ui/guildWar/GuildWarMainData"
	require "script/ui/lordWar/LordWarData"
	require "script/ui/WorldArena/WorldArenaMainData"
	require "script/ui/countryWar/CountryWarMainData"
	if LordWarData.isShowRedTip() 
		or GuildWarMainData.isShowRedTip() 
		or WorldArenaMainData.isShowRedTip() 
		or CountryWarMainData.isShowRedTip() then
		redTipSprite:setVisible(true)
	end
	return _itemSprite
end

--[[
	@des:创建world子菜单
--]]
function createWorldSubMenu( ... )

	local buttonArray = {}
	--子菜单背景
	_worldPanel = CCScale9Sprite:create("images/main/sub_icons/menu_bg.png")
	_worldPanel:setAnchorPoint(ccp(0.2, 1))
	_itemSprite:addChild(_worldPanel, 5)
	_worldPanel:setScale(0)


	--个人跨服赛按钮显示逻辑
	require "script/model/utils/ActivityConfigUtil"
	require "script/ui/lordWar/LordWarData"
	if(ActivityConfigUtil.isActivityOpen("lordwar") and LordWarData.getLordIsOk()) then
		local button= CCMenuItemImage:create("images/lord_war/battlenormal.png", "images/lord_war/battlehigh.png")
		button:registerScriptTapHandler(lordButtonCallback)
		-- 按钮特效
		require "script/ui/lordWar/LordWarData"
		if( TimeUtil.getSvrTimeByOffset(0) >= LordWarData.getRoundStartTime( LordWarData.kRegister ) and TimeUtil.getSvrTimeByOffset(0) <=  LordWarData.getRoundEndTime( LordWarData.kCross2To1 ) )then
		    local buttonAnimSprite2 = XMLSprite:create("images/base/effect/zhengbasaisg/zhengbasaisg")
		    buttonAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
		    buttonAnimSprite2:setPosition(ccpsprite(0.5,0.5,button))
		    button:addChild(buttonAnimSprite2,2)
		end
		table.insert(buttonArray, button)

	end
	--军团跨服赛
	require "script/ui/guildWar/GuildWarMainData"
	if(ActivityConfigUtil.isActivityOpen("guildwar") and GuildWarMainData.getIsOk()) then
		local button= CCMenuItemImage:create("images/guild_war/guild_war_n.png", "images/guild_war/guild_war_h.png")
		button:registerScriptTapHandler(guildWarButtonCallback)
		-- 按钮特效
		if( TimeUtil.getSvrTimeByOffset(0) >=  GuildWarMainData.getStartTime( GuildWarDef.SIGNUP)
			and TimeUtil.getSvrTimeByOffset(0) <=  GuildWarMainData.getEndTime( GuildWarDef.ADVANCED_2) )then

		    local buttonAnimSprite2 = XMLSprite:create("images/guild_war/effect/juntuanzhengba/juntuanzhengba")
		    buttonAnimSprite2:setAnchorPoint(ccp(0.5, 0.5))
		    buttonAnimSprite2:setPosition(ccpsprite(0.5,0.5,button))
		    button:addChild(buttonAnimSprite2,2)
		end
		table.insert(buttonArray, button)
	end
	--巅峰对决按钮
	require "script/ui/WorldArena/WorldArenaMainData"
	if WorldArenaMainData.isShowBtn() then
		local worldArenaButton= CCMenuItemImage:create("images/worldarena/world_n.png", "images/worldarena/world_h.png")
		worldArenaButton:registerScriptTapHandler(worldArenaCallback)
		-- 按钮特效
		local effect = XMLSprite:create("images/worldarena/effect/dianfengduijue/dianfengduijue",30,true)
		effect:setPosition(ccpsprite(0.5,0.5, worldArenaButton))
		worldArenaButton:addChild(effect)
		table.insert(buttonArray, worldArenaButton)
	end

	--country war
	require "script/ui/countryWar/CountryWarMainData"
	if CountryWarMainData.isOpen() then
		local countryWarButton= CCMenuItemImage:create("images/main/sub_icons/country_war_n.png", "images/main/sub_icons/country_war_h.png")
		countryWarButton:registerScriptTapHandler(countryWarButtonCallback)
		-- 按钮特效
		if CountryWarMainData.isShowQuickIcon() then
			local effect = XMLSprite:create("images/country_war/effect/kuafuguozhan/kuafuguozhan",30,true)
			effect:setPosition(ccpsprite(0.5,0.5, countryWarButton))
			countryWarButton:addChild(effect)
		end
		-- 如果玩家没有膜拜的话，入口图标加上红点提示  add by yangrui 
		if CountryWarMainData.isShowRedTip() then
			local redTipSprite = CCSprite:create("images/common/tip_2.png")
			redTipSprite:setPosition(ccpsprite(0.8,0.8,countryWarButton))
			redTipSprite:setAnchorPoint(ccp(0.5,0.5))
			countryWarButton:addChild(redTipSprite,10)
		end
		table.insert(buttonArray, countryWarButton)
	end
	_worldPanel:setContentSize(CCSizeMake(#buttonArray*140,147))
	_worldPanel:setPosition(ccpsprite(0.5, 0, _itemSprite))
	local arrowSprite = CCSprite:create("images/common/arrow_panel.png")
	arrowSprite:setAnchorPoint(ccp(0.5, 0))
	arrowSprite:setPosition(ccpsprite(0.2, 0.97, _worldPanel))
	_worldPanel:addChild(arrowSprite)

	if #buttonArray >= 1 then
		_worldButton:setVisible(true)
	end

	local menuNode = BaseUI.createHorizontalNode(buttonArray, -4000, nil, 15)
	menuNode:setPosition(ccpsprite(0.5, 0.5, _worldPanel))
	menuNode:setAnchorPoint(ccp(0.5, 0.5))
	_worldPanel:addChild(menuNode)

end

--[[
	@des:显示战场按钮子菜单
--]]
function showWorldMaskLayer( ... )
	local onRunningLayer = MainScene.getOnRunningLayer()
	local touchRect = getSpriteScreenRect(_worldPanel)
	local layer = CCLayer:create()
    layer:setPosition(ccp(0, 0))
    layer:setAnchorPoint(ccp(0, 0))
    layer:setTouchEnabled(true)
    layer:setTouchPriority(-3000)
    layer:registerScriptTouchHandler(function ( eventType,x,y )
        if(eventType == "began") then
            if(touchRect:containsPoint(ccp(x,y))) then
                return false
            else
                _worldPanel:stopAllActions()
				local action = CCScaleTo:create(0.2, 0)
				_worldPanel:runAction(action)
				layer:removeFromParentAndCleanup(true)
				_worldMaksLayer = nil
				_worldButton:setSelectedIndex(0)
				onRunningLayer:reorderChild(_worldMenu, 1)
                return true
            end
        end
    end,false, -3000, true)
	local gw,gh = g_winSize.width/MainScene.elementScale, g_winSize.height/MainScene.elementScale
    local layerColor = CCLayerColor:create(ccc4(0,0,0,layerOpacity or 150),gw*80,gh*80)
    layerColor:setPosition(ccp(0,0))
    layerColor:setAnchorPoint(ccp(0.5,0.5))
    layerColor:ignoreAnchorPointForPosition(false)
    layer:addChild(layerColor)
 	_worldMaksLayer = layer
 	_itemSprite:addChild(layer,4, _mask_layer_tag)end

--[[
	@des:wrold按钮回调事件
--]]
function worldButtonCallback(tag, sender)
	local toggleItem  = tolua.cast(sender, "CCMenuItemToggle")
	local selectIndex = toggleItem:getSelectedIndex()
	local onRunningLayer = MainScene.getOnRunningLayer()

	if(selectIndex == 0) then
		print("toogle 0 select index:", selectIndex)
		_worldPanel:stopAllActions()
		local action = CCScaleTo:create(0.2, 0)
		_worldPanel:runAction(action)
		if(_worldMaksLayer) then
			_worldMaksLayer:removeFromParentAndCleanup(true)
		end
		onRunningLayer:reorderChild(_worldMenu, 1)
	else
		print("toogle select index:",selectIndex)
		showWorldMaskLayer()
		_worldPanel:stopAllActions()
		local action = CCScaleTo:create(0.2, 1)
		_worldPanel:runAction(action)
		onRunningLayer:reorderChild(_worldMenu, 5000)
	end
end

--[[
	@des : 跨服赛入口回调
--]]
function lordButtonCallback( tag, sender )
	require "script/ui/lordWar/LordWarMainLayer"
	LordWarMainLayer.show()
end

--[[
	@des:巅峰对决入口
	@parm:parm1 描述
	@ret:ret 描述
--]]
function worldArenaCallback()
	print("worldArenaCallback")
	require "script/ui/WorldArena/WorldArenaMainLayer"
    WorldArenaMainLayer.showLayer()
end

--[[
	@des : 跨服军团战
--]]
function guildWarButtonCallback( ... )
	if GuildWarMainData.getIsOk() then
		require "script/ui/guildWar/GuildWarMainLayer"
		GuildWarMainLayer.show()
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_10049"))
		return
	end
end

--[[
	@des:国战按钮入口
--]]
function countryWarButtonCallback( ... )
	require "script/ui/countryWar/CountryWarMainLayer"
	CountryWarMainLayer.show()
end


function isShow()
	if not tolua.isnull(_worldButton) then
		if _worldButton:isVisible() then
			return true
		end
	end
	return false
end
