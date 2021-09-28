-- FileName: ChariotEquipCell.lua
-- Author: lgx 
-- Date: 16-06-27
-- Purpose: 战车(装备)列表Cell

module("ChariotEquipCell", package.seeall)

require "script/ui/chariot/ChariotMainData"
require "script/ui/chariot/ChariotUtil"
require "script/ui/chariot/ChariotDef"

local _showType = nil -- 显示类型(在哪个界面显示)

--[[
	@desc 	: 创建Cell的UI
	@param	: pShowType 显示类型(在哪个界面显示)
	@param 	: pChariot 战车信息
	@param 	: pPos 战车位置
	@param 	: pCellSize cell大小
	@param 	: pTouchPriority 触摸优先级
    @return	: CCTableViewCell
--]]
function createCell( pShowType, pChariot, pPos, pCellSize, pTouchPriority )
	touchPriority = pTouchPriority or -700
	_showType = pShowType or ChariotDef.kCellShowTypeEquip
	local cell = CCTableViewCell:create()

	local cellSize = pCellSize or CCSizeMake(640, 860)
	cell:setContentSize(cellSize)

	-- Menu
	local btnMenu = BTSensitiveMenu:create()
	btnMenu:setPosition(ccp(0,0))
	cell:addChild(btnMenu,5)
	btnMenu:setTouchPriority(touchPriority-5)

	local chariotInfo = pChariot
	if (not table.isEmpty(chariotInfo)) then
		-- 已装备 创建战车信息
		local chariotTid = chariotInfo.item_template_id
		local chariotDB = chariotInfo.itemDesc
		local chariotItemId = tonumber(chariotInfo.item_id)

		local itemXP = (_showType == ChariotDef.kCellShowTypeEquip) and 0.5 or 0.5 -- 战车位置比例
		local itemScaleX = (_showType == ChariotDef.kCellShowTypeEquip) and g_fElementScaleRatio or 1 -- 战车缩放比
		-- 战车
		local chariotItem = ChariotUtil.createChariotBigItemByTid(chariotDB.id,false,chariotItemCallback,chariotItemId,touchPriority-4)
		chariotItem:setAnchorPoint(ccp(0.5,0.5))
		chariotItem:setPosition(ccp(cellSize.width/2,cellSize.height*itemXP+110*itemScaleX))
		-- 动起来
		-- ChariotUtil.runUpAndDownAction(chariotItem)
		chariotItem:setScale(itemScaleX)
		cell:addChild(chariotItem,1,pPos)

		-- 战车底座
		local shadowSprite = CCSprite:create("images/chariot/chariot_shadow.png")
		cell:addChild(shadowSprite)
		shadowSprite:setAnchorPoint(ccp(0.5, 0.5))
		shadowSprite:setScale(itemScaleX)
		shadowSprite:setPosition(ccp(chariotItem:getPositionX(),chariotItem:getPositionY()-chariotItem:getContentSize().height*itemScaleX*0.35))

		local namePx = 100 -- 名称向上的偏移量
		local proPx = 15 -- 属性偏移量
		local proScaleX = 1 -- 属性框缩放比
		if (_showType == ChariotDef.kCellShowTypeEquip) then
			-- 装备界面显示 强化按钮
			local enforceItem = CCMenuItemImage:create("images/chariot/btn_enforce_n.png","images/chariot/btn_enforce_h.png")
			enforceItem:setAnchorPoint(ccp(0.5,0.5))
			enforceItem:setPosition(ccp(cellSize.width/2+(chariotItem:getContentSize().width/2+10)*g_fElementScaleRatio,cellSize.height*0.55+(chariotItem:getContentSize().height/2+120)*g_fElementScaleRatio))
			enforceItem:registerScriptTapHandler(enforceItemCallback)
			-- 闪起来
			-- ChariotUtil.runArrowAction(enforceItem)
			enforceItem:setScale(g_fElementScaleRatio)
			btnMenu:addChild(enforceItem,1,chariotItemId)
			namePx = 140
			proPx = 25
			proScaleX = g_fScaleX
		end


		-- 等级 和 名称
		local curLv = tonumber(chariotInfo.va_item_text.chariotEnforce)
		-- local curDevelopLv = tonumber(chariotInfo.va_item_text.chariotDevelop)

		local nameBg = ChariotUtil.createChariotNameLabByNameAndLv("".. chariotDB.name,CCSizeMake(250, 40),chariotDB.quality,curLv)
		nameBg:setAnchorPoint(ccp(0.5, 0))
		nameBg:setPosition(ccp(cellSize.width*0.5,cellSize.height*itemXP+(chariotItem:getContentSize().height/2+namePx)*itemScaleX))
		nameBg:setScale(itemScaleX)
		cell:addChild(nameBg,10)

		-- 战车属性
		-- local proTitleStr = chariotDB.name..GetLocalizeStringBy("key_1141")
		local proTitleStr = GetLocalizeStringBy("lgx_1090")
	    local bottomBg = ChariotUtil.createChariotAttrUIByInfo(chariotInfo,touchPriority)
	    bottomBg:setPosition(cellSize.width/2, proPx*proScaleX)
		bottomBg:setAnchorPoint(ccp(0.5,0))
		bottomBg:setScale(proScaleX)
		cell:addChild(bottomBg,1)

		-- 弹出动画 策划说，加个缩放动画和强化界面统一
		ChariotUtil.runShowAction(bottomBg,proScaleX)

	else
		local proPx = 15 -- 属性偏移量
		local proScaleX = 1 -- 属性框缩放比
		-- + 按钮
		if (_showType == ChariotDef.kCellShowTypeEquip) then
			-- 装备界面显示 + 按钮
			local addMenuItem = CCMenuItemImage:create("images/common/add_new.png","images/common/add_new.png")
			addMenuItem:setAnchorPoint(ccp(0.5,0.5))
			addMenuItem:setPosition(ccp(cellSize.width/2,cellSize.height*0.5+100*g_fElementScaleRatio))
			addMenuItem:registerScriptTapHandler(addMenuItemCallback)
			-- 闪起来
			ChariotUtil.runArrowAction(addMenuItem)
			addMenuItem:setScale(g_fElementScaleRatio)
			btnMenu:addChild(addMenuItem,1,pPos)
			proPx = 25
			proScaleX = g_fScaleX
		else
			-- 对方阵容显示 提示文字
			local emptyLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1093"), g_sFontPangWa, 30,1, ccc3(0x00,0x00,0x00),type_stroke)
	        emptyLabel:setColor(ccc3(0x82,0x82,0x82))
	        emptyLabel:setAnchorPoint(ccp(0.5, 0.5))
	        emptyLabel:setPosition(cellSize.width*0.5, cellSize.height*0.5+50*g_fElementScaleRatio)
	        cell:addChild(emptyLabel,5)
		end

		-- 提示文字
		local bottomBg = ChariotUtil.createChariotAttrUIByInfo(nil,touchPriority)
	    bottomBg:setPosition(cellSize.width/2, proPx*proScaleX)
		bottomBg:setAnchorPoint(ccp(0.5,0))
		bottomBg:setScale(proScaleX)
		cell:addChild(bottomBg,1)

		-- 弹出动画 策划说，加个缩放动画和强化界面统一
		ChariotUtil.runShowAction(bottomBg,proScaleX)
	end

	return cell
end

--[[
	@desc 	: 点击战车按钮，进入战车信息界面
	@param 	: pTag 物品id
    @return	: 
--]]
function chariotItemCallback( pTag )
	print("chariotItemCallback 物品id => ",pTag)
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/chariot/ChariotInfoLayer"
    if (_showType == ChariotDef.kCellShowTypeEquip) then
    	ChariotInfoLayer.showLayer(ChariotDef.kChariotInfoTypeEquip, pTag, nil, -1000, 888)
    else
    	-- RivalInfoLayer zorder 是 19000 。。。
    	ChariotInfoLayer.showLayer(ChariotDef.kChariotInfoTypeRival, pTag, nil, -1100, 20000)
    end
end

--[[
	@desc 	: 点击强化按钮，进入战车强化界面
	@param 	: pTag 物品id
    @return	: 
--]]
function enforceItemCallback( pTag )
	print("enforceItemCallback 物品id => ",pTag)
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/chariot/ChariotEnforceLayer"
	ChariotEnforceLayer.showLayer(pTag,-1000,888)
end

--[[
	@desc 	: 点击 + 按钮，进入选择战车界面
	@param 	: pTag 位置
    @return	: 
--]]
function addMenuItemCallback( pTag )
	print("位置 => ",pTag)
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/chariot/ChariotChooseLayer"
	ChariotChooseLayer.showLayer(pTag,-1000,888)
end