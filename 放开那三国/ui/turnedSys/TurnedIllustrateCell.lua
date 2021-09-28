-- FileName: TurnedIllustrateCell.lua
-- Author: lgx
-- Date: 2016-09-13
-- Purpose: 武将幻化系统 幻化图鉴Cell

module("TurnedIllustrateCell", package.seeall)

require "script/ui/turnedSys/HeroTurnedData"
require "script/ui/turnedSys/HeroTurnedUtil"

--[[
	@desc 	: 创建幻化图鉴Cell
	@param 	: pTurnInfo 幻化武将信息
	@param 	: pTouchPriority 触摸优先级
	@return : CCTableViewCell 创建好的cell
--]]
function createCell( pTurnInfo, pTouchPriority )
	pTouchPriority = pTouchPriority or -600
	local cell = CCTableViewCell:create()

	-- Cell背景
	local fullRect = CCRectMake(0,0,88,91)
	local insetRect = CCRectMake(40,42,6,4)
	local cellBg = CCScale9Sprite:create("images/common/bg/title_cell_bg_n.png",fullRect, insetRect)
	cellBg:setContentSize(CCSizeMake(640,280))
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	cell:addChild(cellBg)

	local modelId = tonumber(pTurnInfo.modelId)
	-- 名字
	local nameBg = CCSprite:create("images/formation/newType.png")
	nameBg:setAnchorPoint(ccp(0,1))
	nameBg:setPosition(ccp(25,cellBg:getContentSize().height))
	cellBg:addChild(nameBg)

	local heroName = HeroTurnedData.getHeroNameAndQualityById(modelId)
	local textInfo = {
     		width = nameBg:getContentSize().width-25, 	-- 宽度
	        alignment = 1, 								-- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontPangWa, 			-- 默认字体
	        labelDefaultSize = 24, 						-- 默认字体大小
	        elements =
	        {	
	        	{
	            	type = "CCLabelTTF", 
	            	text = heroName,
	            	color = ccc3(0xff, 0xf6, 0x00)
	        	}
	        }
	 	}
 	local nameLabel = LuaCCLabel.createRichLabel(textInfo)
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    nameLabel:setPosition(nameBg:getContentSize().width*0.5, nameBg:getContentSize().height*0.5+10)
    nameBg:addChild(nameLabel)

    -- 进度
    local progressTab = {}
    progressTab[1] = CCLabelTTF:create(GetLocalizeStringBy("key_3092"), g_sFontName, 18)
    progressTab[1]:setColor(ccc3(0x78,0x25,0x00))
    local porStr = HeroTurnedData.getProgressStrByModelId(modelId)
    progressTab[2] = CCLabelTTF:create(porStr, g_sFontName, 18)
    progressTab[2]:setColor(ccc3(0x00,0x00,0x00))

    local progressFont = BaseUI.createHorizontalNode(progressTab)
    progressFont:setAnchorPoint(ccp(0,0))
	progressFont:setPosition(ccp(15,20))
	cellBg:addChild(progressFont)

	-- 形象列表
	local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local cardBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    cardBg:setContentSize(CCSizeMake(505,240))
    cardBg:setAnchorPoint(ccp(1,0.5))
    cardBg:setPosition(ccp(cellBg:getContentSize().width-35,cellBg:getContentSize().height*0.5))
    cellBg:addChild(cardBg)

    -- local allTurns = pTurnInfo.allTurns
    -- local contentWidth = table.count(allTurns)*200 + 80
    -- local width = cardBg:getContentSize().width*0.99
    -- local scrollView = CCScrollView:create()
    -- scrollView:setContentSize(CCSizeMake(contentWidth, cardBg:getContentSize().height))
    -- scrollView:setViewSize(CCSizeMake(width, cardBg:getContentSize().height + 20))
    -- scrollView:ignoreAnchorPointForPosition(false)
    -- scrollView:setAnchorPoint(ccp(0,0))
    -- scrollView:setPosition(ccp(cardBg:getContentSize().width*0.01,0))
    -- scrollView:setTouchPriority(pTouchPriority - 3)
    -- scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    -- cardBg:addChild(scrollView)

    -- for i,v in ipairs(allTurns) do
    -- 	local isUnlock = HeroTurnedData.isUnLockedByIdAndModelId(v,modelId)
    -- 	local cardSprite = HeroTurnedUtil.createHeroCardSpriteById(v,isUnlock)
    -- 	cardSprite:setPosition(ccp(200*(i-1)+cardSprite:getContentSize().width*0.3,cardBg:getContentSize().height*0.25))
    -- 	scrollView:addChild(cardSprite,2)
    -- end

	
	local allTurns = pTurnInfo.allTurns
	local tWidth = cardBg:getContentSize().width*0.99
	local tHeight = cardBg:getContentSize().height + 20

	local handler = function(fn, t_table, a1, a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(230, tHeight)
		elseif fn == "cellAtIndex" then
			a2 = createCardCell(allTurns[a1 + 1],modelId)
			r = a2
		elseif fn == "numberOfCells" then
			r = #allTurns
		elseif fn == "scroll" then
		end
		return r
	end

	local tableView = LuaTableView:createWithHandler(LuaEventHandler:create(handler), CCSizeMake(tWidth,tHeight))
	tableView:setBounceable(true)
	tableView:setDirection(kCCScrollViewDirectionHorizontal)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0,0))
	tableView:setPosition(ccp(cardBg:getContentSize().width*0.01,0))
	cardBg:addChild(tableView)
	tableView:reloadData()
	tableView:setTouchPriority(pTouchPriority-3)

	return cell
end

--[[
	@desc	: 创建卡牌Cell
    @param	: pTurnId 幻化id
    @param 	: pModelId 武将原型id
    @return	: CCTableViewCell 卡牌Cell
—-]]
function createCardCell( pTurnId, pModelId )
	local cell = CCTableViewCell:create()

	local isUnlock = HeroTurnedData.isUnLockedByIdAndModelId(pTurnId,pModelId)
	local cardSprite = HeroTurnedUtil.createHeroCardSpriteById(pTurnId,isUnlock)
	cardSprite:setAnchorPoint(ccp(0,0))
	cardSprite:setPosition(ccp(50,70))
	cell:addChild(cardSprite,2)

	if ( isUnlock == false ) then
		-- 去获取
		local menu = CCMenu:create()
		cardSprite:addChild(menu,5)
		menu:setTouchPriority(-650)
		menu:setPosition(ccp(0, 0))

		local gotoItem = CCMenuItemImage:create("images/common/btn/btn_title_get_n.png", "images/common/btn/btn_title_get_h.png")
		menu:addChild(gotoItem)
		gotoItem:setPosition(ccp(cardSprite:getContentSize().width - 10, cardSprite:getContentSize().height - 10))
		gotoItem:setAnchorPoint(ccp(0.5, 0.5))
		gotoItem:registerScriptTapHandler(goToItemCallback)
		gotoItem:setTag(pTurnId)
		gotoItem:setScale(0.9)
	end

	return cell
end

--[[
	@desc 	: 查看形象获得途径
	@param 	: pTag 幻化形象id
    @return	: 
--]] 
function goToItemCallback( pTag )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local turnId = pTag
	require "script/ui/turnedSys/TurnedGetDialog"
	TurnedGetDialog.showDialog(turnId, -700, 1000)
end
