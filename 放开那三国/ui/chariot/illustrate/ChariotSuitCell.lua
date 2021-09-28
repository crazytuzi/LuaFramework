-- FileName: ChariotSuitCell.lua 
-- Author: lgx 
-- Date: 2016-06-30
-- Purpose: 战车套装套装Cell

module("ChariotSuitCell", package.seeall)

--[[
	@desc 	: 创建Cell的UI
	@param 	: pCellValue 战车信息
    @return	: CCTableViewCell
--]]
function createCell( pCellValue )
	local cell = CCTableViewCell:create()

	local cellSize = CCSizeMake(592, 570)
	cell:setContentSize(cellSize)

	-- 背景
	local bg = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
	cell:addChild(bg)
	bg:setPreferredSize(CCSizeMake(582, 530))
	bg:setAnchorPoint(ccp(0.5, 0))
	bg:setPosition(ccpsprite(0.5, 0, cell))

	-- 名称
	local nameBg = CCScale9Sprite:create(CCRectMake(129, 30, 1, 8), "images/chariot/illustrate_title_bg.png")
	bg:addChild(nameBg, 10)
	-- nameBg:setPreferredSize(CCSizeMake(258, 69))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	nameBg:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 2))

	local name = CCLabelTTF:create(pCellValue.name, g_sFontPangWa, 30)
	nameBg:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.5))
	name:setPosition(ccpsprite(0.5, 0.5, nameBg))
	name:setColor(ccc3(0xff, 0xf6, 0x00))
	-- name:setColor(HeroPublicLua.getCCColorByStarLevel(pCellValue.quality))

	local bgSize = bg:getContentSize()

	-- 战车形象1
	if (pCellValue.chariotOne) then
		local chariotBg = ChariotUtil.createChariotSuitSpriteByInfo(pCellValue.chariotOne)
		bg:addChild(chariotBg)
		chariotBg:setAnchorPoint(ccp(1, 1))
		chariotBg:setPosition(ccp(bg:getContentSize().width * 0.5 - 4, bg:getContentSize().height - 7))
	end

	-- 战车形象2
	if (pCellValue.chariotTwo) then
		local chariotBg = ChariotUtil.createChariotSuitSpriteByInfo(pCellValue.chariotTwo)
		bg:addChild(chariotBg)
		chariotBg:setAnchorPoint(ccp(0, 1))
		chariotBg:setPosition(ccp(bg:getContentSize().width * 0.5 + 4, bg:getContentSize().height - 7))
	end

	-- 套装属性
	local attrInfo = ChariotIllustrateData.getChariotSuitAttrInfoById(pCellValue.id)
	if (not table.isEmpty(attrInfo)) then
		local isGary = not pCellValue.isActivated
		local textBg = ChariotUtil.createTextBgByTitleAndSize(GetLocalizeStringBy("lgx_1088"),CCSizeMake(520, 135),isGary)
		bg:addChild(textBg)
		textBg:setAnchorPoint(ccp(0.5, 0))
		textBg:setPosition(ccp(bgSize.width * 0.5, 30))

		local i = 0
		for k,v in pairs(attrInfo) do
			local row = math.floor(i/2)+1
 			local col = i%2+1

			local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v)

			local affixName = CCRenderLabel:create(affixDesc.sigleName, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			textBg:addChild(affixName)
			affixName:setAnchorPoint(ccp(0, 0.5))
			affixName:setPosition(ccp(50 + (col-1) * textBg:getContentSize().width/2, textBg:getContentSize().height - 20 - row * 27))

			local affixValue = CCRenderLabel:create("+"..tostring(displayNum), g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			textBg:addChild(affixValue)
			affixValue:setColor(ccc3(0x00, 0xff, 0x18))
			affixValue:setAnchorPoint(ccp(0, 0.5))
			affixValue:setPosition(ccp(150 + (col-1) * textBg:getContentSize().width/2, textBg:getContentSize().height - 20 - row * 27))

			if (isGary) then
				-- 未激活 置灰
				affixName:setColor(ccc3(0x82, 0x82, 0x82))
				affixValue:setColor(ccc3(0x54, 0x9c, 0x5b))
			end
			i = i+1
		end
	end

	return cell
end