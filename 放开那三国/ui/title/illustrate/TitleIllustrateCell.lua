-- Filename: TitleIllustrateCell.lua
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号图鉴Cell

module("TitleIllustrateCell", package.seeall)

require "script/ui/title/TitleData"
require "script/ui/title/TitleUtil"
require "script/ui/item/ItemUtil"

--[[
	@desc 	: 创建称号图鉴Cell
	@param 	: pTitleData 称号信息
	@return : 
--]]
function createCell( pTitleData )
	local cell = CCTableViewCell:create()

	-- Cell背景
	local fullRect = CCRectMake(0,0,88,91)
	local insetRect = CCRectMake(40,42,6,4)
	local cellBg = CCScale9Sprite:create("images/common/bg/title_cell_bg_n.png",fullRect, insetRect)
	cellBg:setContentSize(CCSizeMake(574,104))
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(ccp(0,0))
	cell:addChild(cellBg)

	-- 称号特效
    local titleEffect = nil
    if (pTitleData.isGot == TitleDef.kTitleIllustrateHadGot) then
    	titleEffect = TitleUtil.createTitleNormalSpriteById(pTitleData.signid)
    else
    	-- 置灰
    	titleEffect = TitleUtil.createTitleGraySpriteById(pTitleData.signid)
    end
    titleEffect:setPosition(ccp(105,cellBg:getContentSize().height*0.5))
    titleEffect:setAnchorPoint(ccp(0.5,0.5))
    cellBg:addChild(titleEffect)

    -- 属性数值
    local attrInfo = TitleData.getTitleIllustrateAttrInfoById(pTitleData.signid)
    local i = 0
    for k,v in pairs(attrInfo) do
    	local row = math.floor(i/2)+1
		local col = i%2+1
    	local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(k,v)
    	local attrStr = affixDesc.sigleName .. "+" .. displayNum
    	local attrStrLabel = CCLabelTTF:create(attrStr,g_sFontName,25)
		attrStrLabel:setColor(ccc3(0x78,0x25,0x00))
		attrStrLabel:setAnchorPoint(ccp(0,1))
		attrStrLabel:setPosition(ccp(240+150*(col-1), cellBg:getContentSize().height-(20+30*(row-1))))
		cellBg:addChild(attrStrLabel)
    	i = i+1
    end

	return cell
end