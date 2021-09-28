-- Filename: GoodsCell.lua
-- Author: zhz
-- Date: 2013-8-29
-- Purpose: 该文件用于: 奖励物品的Cell

module("GoodsCell", package.seeall)
require "script/ui/item/ItemSprite"
require "script/ui/level_reward/LevelRewardUtil"
function createCell(cellValues)
	local tCell = CCTableViewCell:create()
	local iconBg = nil
	local iconSprite = nil
	-- print("=====================------------")
	-- print_t(cellValues)
	if( tonumber(cellValues.reward_type) == 6 or tonumber(cellValues.reward_type)  == 7) then

		iconBg = ItemSprite.getItemSpriteById(tonumber(cellValues.reward_ID), nil,itemDelegateAction, nil, -600,1000 )
		iconBg:setPosition(ccp(0,114))
		iconBg:setAnchorPoint(ccp(0,1))
		tCell:addChild(iconBg)
	else
		iconBg = CCSprite:create("images/base/potential/props_" .. cellValues.reward_quality .. ".png")
		iconBg:setPosition(ccp(0,116))
		iconBg:setAnchorPoint(ccp(0,1))
		tCell:addChild(iconBg)
		iconSprite = LevelRewardUtil.getItemSp(cellValues.reward_type,cellValues.reward_ID)
		iconSprite:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().width*0.5))
		iconSprite:setAnchorPoint(ccp(0.5,0.5))
		iconBg:addChild(iconSprite)
	end
	if(tonumber(cellValues.reward_values) ~= 1) then
		local numberLabel = CCRenderLabel:create(string.convertSilverUtilByInternational(cellValues.reward_values),g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)  -- modified by yangrui at 2015-12-03
		-- local numberLabel = CCLabelTTF:create("" .. cellValues.reward_values, g_sFontName,21)
		numberLabel:setColor(ccc3(0x00,0xff,0x18))
		numberLabel:setAnchorPoint(ccp(0,0))
		local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
		numberLabel:setPosition(ccp(width,5))
		iconBg:addChild(numberLabel)
	end

	-- desc
	-- local descLabel = CCLabelTTF:create(cellValues.reward_desc, g_sFontName,18)
	local descLabel = CCRenderLabel:create(cellValues.reward_desc, g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	descLabel:setColor(ccc3(0xff,0xff,0xff))
	descLabel:setAnchorPoint(ccp(0,0))
	local width = (iconBg:getContentSize().width - descLabel:getContentSize().width)/2 -2
	descLabel:setPosition(ccp(width,2))
	tCell:addChild(descLabel)
	
	return tCell
end

function itemDelegateAction( )
    MainScene.setMainSceneViewsVisible(true, true, true)
end
