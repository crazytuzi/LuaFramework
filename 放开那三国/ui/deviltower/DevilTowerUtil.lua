-- FileName: DevilTowerUtil.lua
-- Author: lgx
-- Date: 2016-07-29
-- Purpose: 试炼梦魇工具类(公共方法)

module("DevilTowerUtil", package.seeall)

require "script/ui/common/LuaMenuItem"
require "script/ui/deviltower/DevilTowerDef"

-- 模块局部变量 --


--[[
	@desc	: 显示黑闪一下动作
    @param	: 
    @return	: 
—-]]
function showBlackFadeAction()
	local blackLayer = CCLayerColor:create(ccc4(1,1,1,255))
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(blackLayer, 2000)

	local function removeSelf()
	   	blackLayer:removeFromParentAndCleanup(true)
	   	blackLayer = nil
	end

	local actionArr = CCArray:create()
    actionArr:addObject(CCFadeOut:create(1))
    actionArr:addObject(CCCallFuncN:create(removeSelf))
    local actions = CCSequence:create(actionArr)
    blackLayer:runAction(actions)
end


--[[
	@desc	: 创建怪物的形象
    @param	: pType 怪物显示类型（1 副本小图 ，其他 战斗大图）
    @param	: pPotential 怪物品质
    @param	: pFileName 怪物图片名
    @param 	: pTittle 怪物名
    @return	: LuaMenuItem 怪物的形象
—-]]
function createNpcItemSprite(pType, pPotential, pFileName, pTittle)
	local fileBg = nil
	local fileIcon = nil
	pPotential = tonumber(pPotential)
	local m_anchorPoint = nil
	local m_scaleY = nil
	-- 图片 
	local iconSprite = nil
	local iconSpriteH = nil
	if (tonumber(pType) == DevilTowerDef.kMonsterTypeHeadIcon) then
		-- 副本小图
		fileBg = "images/copy/ncopy/fortpotential/" .. pPotential .. ".png"

		fileIcon = "images/base/hero/head_icon/" .. pFileName
		iconSprite = CCSprite:create(fileIcon)
		iconSpriteH = CCSprite:create(fileIcon)

		m_anchorPoint = ccp(0.5, 0.5)
		m_scaleY = 0.53
	else
		-- 战斗大图
		local bgArr = {"tong_bg.png", "yin_bg.png", "jin_bg.png"}
		fileBg = "images/match/" .. bgArr[pPotential]

		require "script/battle/BattleCardUtil"
		iconSprite = BattleCardUtil.getFormationPlayerCard(111111111,nil, pFileName)
		iconSpriteH = BattleCardUtil.getFormationPlayerCard(111111111,nil, pFileName)

		m_anchorPoint = ccp(0.5, 0)
		m_scaleY = 35/191
	end
	local normalSprite		= CCSprite:create(fileBg)
	local highlightedSprite = CCSprite:create(fileBg)
	

	iconSprite:setAnchorPoint(m_anchorPoint)
	iconSprite:setPosition(ccp(normalSprite:getContentSize().width * 0.5,  normalSprite:getContentSize().height *m_scaleY))
	normalSprite:addChild(iconSprite)

	iconSpriteH:setAnchorPoint(m_anchorPoint)
	iconSpriteH:setPosition(ccp(normalSprite:getContentSize().width * 0.5,  normalSprite:getContentSize().height *m_scaleY))
	highlightedSprite:addChild(iconSpriteH)
	highlightedSprite:setScale(0.95)

	-- 按钮
	local menuItem = LuaMenuItem.createItemSprite(normalSprite, highlightedSprite)
	local menuItemSize = menuItem:getContentSize()
	
	-- 文字
	local titleLabel = CCRenderLabel:create(pTittle, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xff, 0xff))
    titleLabel:setAnchorPoint(ccp(0.5, 0))
    titleLabel:setPosition(ccp( menuItem:getContentSize().width/2 , menuItem:getContentSize().height))
    menuItem:addChild(titleLabel)

    return menuItem
end

--[[
	@desc	: 给怪物卡牌添加头部和脚部特效
    @param	: pType 怪物显示类型
    @param 	: pItem 怪物卡牌
    @return	: 
—-]]
function addNpcEffectWithItem( pType, pItem )
	if (pItem == nil) then
		return
	end

	local topEffectPath = nil
	local bottomEffectPath = nil
	local yScale = 1

	if (pType == DevilTowerDef.kMonsterTypeHeadIcon) then
		topEffectPath = "images/base/effect/copy/fubenkegongji02"
		bottomEffectPath = "images/base/effect/copy/fubenkegongji01"
		yScale = 1.1
	else
		topEffectPath = "images/base/effect/tower/guangbiao"
		bottomEffectPath = "images/base/effect/tower/yuanpan"
		yScale = 1.5
	end

	-- 头部特效
    local topEffectSprite = XMLSprite:create(topEffectPath)
    topEffectSprite:setPosition(pItem:getContentSize().width*0.5, pItem:getContentSize().height * yScale)
    pItem:addChild(topEffectSprite,1)

	-- 脚部特效
	local bottomEffectSprite = XMLSprite:create(bottomEffectPath)
    bottomEffectSprite:setPosition(pItem:getContentSize().width/2,0)
    pItem:addChild(bottomEffectSprite,-1)
end

--[[
	@desc	: 展示怪物卡牌下落动画
	@param	: pType 怪物显示类型
	@param	: pPotential 怪物品质
    @param	: pFileName 怪物图片名
    @param	: pEndCallback 动画结束回调
    @return	:  
—-]]
function createDropAnimationWithItem( pType, pPotential, pFileName, pEndCallback )
	if (pFileName == nil) then
		return
	end

	pType = tonumber(pType) or DevilTowerDef.kMonsterTypeHeadIcon
	pPotential = tonumber(pPotential) or 1

	local animationName  = nil
	local dropEffectName = nil
	local replaceXmlName = nil
	local replaceXmlTag  = nil
	if (pType == DevilTowerDef.kMonsterTypeHeadIcon) then
		if(pPotential == 1) then
			animationName = "fbjdmu"
		elseif(pPotential == 2) then
			animationName = "fbjdying"
		elseif(pPotential == 3) then
			animationName = "fbjdjin"
		end
		dropEffectName = "images/base/effect/copy/" .. animationName
		replaceXmlName = "images/base/hero/head_icon/" .. pFileName
		replaceXmlTag = 1002
	else
		if(pPotential == 1) then
			animationName = "tong_bg.png"
		elseif(pPotential == 2) then
			animationName = "yin_bg.png"
		elseif(pPotential == 3) then
			animationName = "jin_bg.png"
		end
		dropEffectName = "images/base/effect/tower/kapaixialuo"
		replaceXmlName = "images/match/" .. animationName
		replaceXmlTag = 1001
	end

	local dropEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(dropEffectName), -1, CCString:create(""))

    --替换头像
    local replaceXmlSprite = tolua.cast(dropEffectSprite:getChildByTag(replaceXmlTag), "CCXMLSprite")
    replaceXmlSprite:setReplaceFileName(CCString:create(replaceXmlName))

    -- 结束回调
    local animationEnd = function(actionName,xmlSprite)
    	dropEffectSprite:retain()
		dropEffectSprite:autorelease()
        dropEffectSprite:removeFromParentAndCleanup(true)

        if (pEndCallback ~= nil) then
        	pEndCallback()
        end
    end

    -- 每次回调
    local animationFrameChanged = function(frameIndex,xmlSprite)
        if (pType ~= DevilTowerDef.kMonsterTypeHeadIcon and frameIndex == 1) then
        	require "script/battle/BattleCardUtil"
		    local icon_sp_h = BattleCardUtil.getFormationPlayerCard(111111111,nil, pFileName)
		    icon_sp_h:setAnchorPoint(ccp(0.5, 0))
		    icon_sp_h:setPosition(ccp(82 ,35))
		    replaceXmlSprite:addChild(icon_sp_h)
        end
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    dropEffectSprite:setDelegate(delegate)

    return dropEffectSprite
end