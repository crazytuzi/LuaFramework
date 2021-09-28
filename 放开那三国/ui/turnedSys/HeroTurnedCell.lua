-- FileName: HeroTurnedCell.lua
-- Author: lgx
-- Date: 2016-09-14
-- Purpose: 武将幻化系统 幻化形象Cell

module("HeroTurnedCell", package.seeall)

require "script/ui/turnedSys/TurnedDef"
require "script/ui/turnedSys/HeroTurnedData"
require "script/ui/turnedSys/HeroTurnedUtil"

--[[
	@desc	: 创建武将幻化Cell
    @param	: pIndex 幻化形象索引
    @param 	: pTurnInfo 幻化武将信息
    @param 	: pSize cell大小
	@param 	: pMaxIdx 最大索引
	@param 	: pScale 视图缩放比
    @return	: CCTableViewCell 创建好的cell
—-]]
function createCell( pIndex, pHeroInfo, pSize, pMaxIdx, pScale )
	local cell = CCTableViewCell:create()
	local cellSize = pSize
	cell:setContentSize(cellSize)

	if pIndex == 0 or pIndex == pMaxIdx then
		-- 头和尾 返空cell
	else
		local node = CCSprite:create()
		cell:addChild(node)
		node:setCascadeColorEnabled(true)
		node:setTag(TurnedDef.kTagTurnSprite)
		node:setContentSize(cellSize)
		node:ignoreAnchorPointForPosition(false)
		node:setAnchorPoint(ccp(0.5, 0))
		node:setPosition(ccp( cell:getContentSize().width*0.5,cell:getContentSize().height*0))
		node:setScale(pScale*MainScene.elementScale * 1.2)

		-- 形象全身像
		local turnId = HeroTurnedData.getTurnIdByHidAndIndex(pHeroInfo.hid,pIndex)
		-- 默认形象
		if (pIndex == 1) then
			turnId = pHeroInfo.htid
		end
		-- print("hid =>",pHeroInfo.hid,"pIndex =>",pIndex,"turnId =>",turnId,"pScale =>",node:getScale())

		local bodyOffset = HeroTurnedUtil.getHeroBodyOffsetById(turnId)
		local isUnLock = HeroTurnedData.isUnLockedTurnId(turnId)
		local heroDress = HeroTurnedUtil.createHeroDressSpriteById(turnId,isUnLock)
		node:addChild(heroDress)
		heroDress:setAnchorPoint(ccp(0.5, 0))
		heroDress:setPosition(ccp(node:getContentSize().width * 0.5, node:getContentSize().height * 0.21 / node:getScale() - bodyOffset))
		heroDress:setScale(0.8)

		-- 形象名称
		local nameBg = HeroTurnedUtil.createTurnNameSpriteById(turnId,pIndex,isUnLock)
		nameBg:setAnchorPoint(ccp(0.5,1))
		nameBg:setPosition(ccp(node:getContentSize().width*0.5, heroDress:getPositionY()-10+bodyOffset))
		node:addChild(nameBg,1,TurnedDef.kTagTurnName)
		nameBg:setVisible(false)
	end

	return cell
end
