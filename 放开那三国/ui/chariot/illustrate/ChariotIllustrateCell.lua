-- FileName: ChariotIllustrateCell.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车图鉴列表Cell

module("ChariotIllustrateCell", package.seeall)

require "script/ui/chariot/ChariotDef"
require "script/ui/chariot/ChariotUtil"
require "script/ui/chariot/illustrate/ChariotIllustrateData"
require "script/ui/chariot/illustrate/ChariotGetDialog"
require "script/ui/hero/HeroPublicLua"

--[[
	@desc 	: 创建Cell的UI
	@param 	: pCellValue 战车信息
    @return	: CCTableViewCell
--]]
function createCell( pCellValue )
	local cell = CCTableViewCell:create()

	local cellSize = CCSizeMake(296, 570)
	cell:setContentSize(cellSize)

	-- 背景
	local bg = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
	cell:addChild(bg)
	bg:setPreferredSize(CCSizeMake(292, 530))
	bg:setAnchorPoint(ccp(0.5, 0))
	bg:setPosition(ccpsprite(0.5, 0, cell))

	-- 名称
	local nameBg = CCScale9Sprite:create(CCRectMake(86, 30, 4, 8), "images/chariot/illustrate_title_bg.png")
	bg:addChild(nameBg, 10)
	-- nameBg:setPreferredSize(CCSizeMake(258, 68))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	nameBg:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 2))

	local name = CCLabelTTF:create(pCellValue.name, g_sFontPangWa, 30)
	nameBg:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.5))
	name:setPosition(ccpsprite(0.5, 0.5, nameBg))
	name:setColor(ccc3(0xff, 0xf6, 0x00))
	-- name:setColor(HeroPublicLua.getCCColorByStarLevel(pCellValue.quality))

	local bgSize = bg:getContentSize()

	-- 战车形象
	local isGary = not pCellValue.isGot
	local chariotBg = ChariotUtil.createChariotSpriteByTid(pCellValue.id,isGary,true)
	bg:addChild(chariotBg)
	chariotBg:setAnchorPoint(ccp(0.5, 1))
	chariotBg:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 7))

	-- 图鉴属性
	local attrInfo = ChariotIllustrateData.getChariotIllustrateAttrInfoByTid(pCellValue.id)
	if (not table.isEmpty(attrInfo)) then
		local textBg = ChariotUtil.createTextBgByTitleAndSize(GetLocalizeStringBy("key_8347"),CCSizeMake(255, 135),isGary)
		bg:addChild(textBg)
		textBg:setAnchorPoint(ccp(0.5, 0))
		textBg:setPosition(ccp(bgSize.width * 0.5, 30))

		local i = 1
		for k,v in pairs(attrInfo) do
			local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v)

			local affixName = CCRenderLabel:create(affixDesc.sigleName, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			textBg:addChild(affixName)
			affixName:setAnchorPoint(ccp(0, 0.5))
			affixName:setPosition(ccp(50 , textBg:getContentSize().height - 10 -  i * 27))

			local affixValue = CCRenderLabel:create("+"..tostring(displayNum), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			textBg:addChild(affixValue)
			affixValue:setColor(ccc3(0x00, 0xff, 0x18))
			affixValue:setAnchorPoint(ccp(0, 0.5))
			affixValue:setPosition(ccp(150, affixName:getPositionY()))

			if (pCellValue.isGot == false) then
				-- 未获得 置灰
				affixName:setColor(ccc3(0x82, 0x82, 0x82))
				affixValue:setColor(ccc3(0x54, 0x9c, 0x5b))
			end
			i = i+1
		end
	end

	if (pCellValue.isGot) then
		-- 已激活
		local activedTag = CCSprite:create("images/dress_room/activated.png")
		bg:addChild(activedTag, 20)
		activedTag:setAnchorPoint(ccp(0.5, 0.5))
		activedTag:setPosition(ccp(bgSize.width - 60, bg:getContentSize().height - 60))
	else
		-- 未获得
		local noTipSprite = CCSprite:create("images/dress_room/not_get.png")
		chariotBg:addChild(noTipSprite,20)
		noTipSprite:setAnchorPoint(ccp(0.5, 0.5))
		noTipSprite:setPosition(ccpsprite(0.5, 0.5, chariotBg))

		-- 去获取
		local menu = CCMenu:create()
		bg:addChild(menu)
		menu:setTouchPriority(-1500)
		menu:setPosition(ccp(0, 0))

		local gotoItem = CCMenuItemImage:create("images/common/btn/btn_title_get_n.png", "images/common/btn/btn_title_get_h.png")
		menu:addChild(gotoItem)
		gotoItem:setPosition(ccp(bgSize.width - 60, bg:getContentSize().height - 60))
		gotoItem:setAnchorPoint(ccp(0.5, 0.5))
		gotoItem:registerScriptTapHandler(goToItemCallback)
		gotoItem:setTag(pCellValue.id)
	end

	return cell
end

--[[
	@desc 	: 查看战车获得途径
	@param 	: pTag 战车Tid
    @return	: 
--]] 
function goToItemCallback( pTag )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local chariotTid = pTag
	ChariotGetDialog.showDialog(chariotTid, -2000, 2000)
end

