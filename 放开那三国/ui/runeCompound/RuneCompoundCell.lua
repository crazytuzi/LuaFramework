-- Filename: RuneCompoundCell.lua
-- Author: zhangqiang
-- Date: 2016-07-26
-- Purpose: 符印合成控制

module("RuneCompoundCell", package.seeall)

--[[
	@desc  : 创建cell
	@param :
	@return: 
--]]
function create( pTableView, pIndex, pCellData )
	local cell = STTableViewCell:create()
	-- local spCellBg = CCSprite:create("images/athena/compose_bg.png")
	local spCellBg = CCSprite:create("images/runecompound/page_bg_circle.png")
	spCellBg:setAnchorPoint(ccp(0.5, 0.5))
	spCellBg:setPosition(284, 295)
	cell:addChild(spCellBg)


	--闪电特效添加
	-- local ImagePath = "images/treasure/"
	-- local lightning = CCLayerSprite:layerSpriteWithName(CCString:create(ImagePath .. "effect/light"), -1,CCString:create(""))
 --    lightning:setAnchorPoint(ccp(0.5, 0.5))
 --    lightning:setPosition(cell:getContentSize().width/2,cell:getContentSize().height*0.5)
 --    cell:addChild(lightning,1)
	
	--被合成的图标
	local spCenterIcon = createCenterIcon(pCellData.product)
	spCenterIcon:setAnchorPoint(ccp(0.5, 0.5))
	spCenterIcon:setPosition(spCellBg:getContentSize().width*0.5, spCellBg:getContentSize().height*0.5+8)
	spCellBg:addChild(spCenterIcon, 5)
	cell.spCenterIcon = spCenterIcon


	--合成所需材料
	local tbAllMat = pCellData.cost_item
	local tbMatData = {
		[1] = {posx=242, posy=441, arrowx=242, arrowy=410, arrowrotate=0},   --中
		[2] = {posx=51, posy=88, arrowx=97, arrowy=149, arrowrotate=-120},    --左
		[3] = {posx=431, posy=88, arrowx=387, arrowy=149, arrowrotate=120},   --右
	}
	cell.tbSideIcon = {}
	for k, v in ipairs(tbMatData) do
		local tbMat = tbAllMat[k]
		if not table.isEmpty(tbMat) then
			local spMatIcon = createSideIcon(k, tbMat)
			spMatIcon:setAnchorPoint(ccp(0.5, 0.5))
			spMatIcon:setPosition(v.posx, v.posy)
			spCellBg:addChild(spMatIcon, 5)

			cell.tbSideIcon[k] = spMatIcon

			--箭头
			local spArrow = CCSprite:create("images/athena/arrow.png")
			spArrow:setAnchorPoint(ccp(0.5,1))
			spArrow:setPosition(v.arrowx, v.arrowy)
			spArrow:setRotation(v.arrowrotate)
			spCellBg:addChild(spArrow)
		end
	end


	return cell
end

--[[
	@desc  : 创建合成物品图标（即每个cell中的中心图标）
	@param :
	@return: 
--]]
function createCenterIcon( pProduct )
	-- pItemTid = pItemTid or 61201
	local spBg = CCSprite:create("images/athena/item_bg.png")

	--点击打开后的物品信息界面关闭时调用
	local fnCloseCb = function ( ... )
		print("RuneCompoundCell createCenterIcon fnCloseCb")
	end
	-- local spIcon = ItemSprite.getItemSpriteById(pItemTid or 61203, nil, fnCloseCb, RuneCompoundLayer._nBaseTouchPriority-10, 2, nil, nil ,nil ,nil, nil, nil, nil, nil, nil, true)
	local spIcon = ItemSprite.getItemSpriteById(pProduct.tid, nil , fnCloseCb, nil, RuneCompoundLayer._nBaseTouchPriority+RuneCompoundLayer.kBtnRelativeTouchPriority, 19001, RuneCompoundLayer._nBaseTouchPriority+RuneCompoundLayer.kItemInfoRelativeTouchPriority, nil, nil, nil, nil,nil,nil, nil,false)
	spIcon:setAnchorPoint(ccp(0.5, 0.5))
	spIcon:setPosition(spBg:getContentSize().width*0.5, spBg:getContentSize().height*0.5)
	spBg:addChild(spIcon)

	-- --数量
	-- -- local nHasNum = ItemUtil.getCacheItemNumBy(pProduct.tid)
	-- local sNum = string.format("%d", pProduct.hasNum)
	-- local lbNum = CCRenderLabel:create(sNum,g_sFontName,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	-- lbNum:setColor(ccc3(0x00,0xff,0x18))
	-- lbNum:setAnchorPoint(ccp(1,0))
	-- lbNum:setPosition(ccp(spBg:getContentSize().width-10,10))
	-- spBg:addChild(lbNum)

	local itemInfo = ItemUtil.getItemById(pProduct.tid)
	-- 名字
	local nameLabel = CCRenderLabel:create(itemInfo.name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.quality))
	nameLabel:setAnchorPoint(ccp(0.5,0.5))
	nameLabel:setPosition(ccp(spBg:getContentSize().width*0.5,-16))
	spBg:addChild(nameLabel)


	return spBg
end

--[[
	@desc  : 创建合成材料图标（即每个cell中的边缘图标）
	@param :
	@return: 
--]]
function createSideIcon(pSerialNum, pMatData )
	-- pMatData.tid = pMatData.tid or 61201
	local spBg = CCSprite:create("images/athena/item_bg.png")

	--标题
	-- 名字底
	local noSprite = CCSprite:create("images/athena/name_bg.png")
	noSprite:setAnchorPoint(ccp(0.5,0))
	noSprite:setPosition(spBg:getContentSize().width*0.5-28,spBg:getContentSize().height)
	spBg:addChild(noSprite)

	local noSize = noSprite:getContentSize()
	-- 编号
	local noLabel = CCRenderLabel:create(tostring(pSerialNum),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	noLabel:setColor(ccc3(0xff,0xff,0xff))
	noLabel:setAnchorPoint(ccp(0.5,0.5))
	noLabel:setPosition(ccp(15,noSize.height*0.5))
	noSprite:addChild(noLabel)

	local itemInfo = ItemUtil.getItemById(pMatData.tid)
	-- 名字
	local nameLabel = CCRenderLabel:create(itemInfo.name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.quality))
	nameLabel:setAnchorPoint(ccp(0,0.5))
	nameLabel:setPosition(ccp(40,noSize.height*0.5))
	noSprite:addChild(nameLabel)

	--点击打开后的物品信息界面关闭时调用
	local fnCloseCb = function ( ... )
		print("RuneCompoundCell createSideIcon fnCloseCb")
	end
	-- local spIcon = ItemSprite.getItemSpriteById(pItemTid or 61203, nil, fnCloseCb, RuneCompoundLayer._nBaseTouchPriority-10, 2, nil, nil ,nil ,nil, nil, nil, nil, nil, nil, true)
	local spIcon = ItemSprite.getItemSpriteById(pMatData.tid, nil , fnCloseCb, nil, RuneCompoundLayer._nBaseTouchPriority+RuneCompoundLayer.kBtnRelativeTouchPriority, 19001, RuneCompoundLayer._nBaseTouchPriority+RuneCompoundLayer.kItemInfoRelativeTouchPriority, nil, nil, nil, nil,nil,nil, nil,false)
	spIcon:setAnchorPoint(ccp(0.5, 0.5))
	spIcon:setPosition(spBg:getContentSize().width*0.5, spBg:getContentSize().height*0.5)
	spBg:addChild(spIcon)

	--数量
	-- local nHasNum = ItemUtil.getCacheItemNumBy(pMatData.tid)
	local sNum = string.format("%d/%d", pMatData.hasNum, pMatData.needNum or 0)
	local lbNum = CCRenderLabel:create(sNum,g_sFontName,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	lbNum:setColor(ccc3(0x00,0xff,0x18))
	if pMatData.needNum ~= nil and pMatData.hasNum < pMatData.needNum then
		lbNum:setColor(ccc3(255, 0, 0))
	end
	lbNum:setAnchorPoint(ccp(1,0))
	lbNum:setPosition(ccp(spBg:getContentSize().width-10,10))
	spBg:addChild(lbNum)


	return spBg
end