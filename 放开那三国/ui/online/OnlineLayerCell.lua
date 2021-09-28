-- Filename: OnlineLayerCell.lua.
-- Author: zhz.
-- Date: 2013-07-24
-- Purpose: 该文件用于实现在线奖励cell

module ("OnlineLayerCell", package.seeall)
require "script/ui/item/ItemSprite"



local IMG_PATH = "images/online/" 

local status_display =nil


-- 通过奖励类型判断物品1、银币,2、将魂,3、金币,4、体力,5、耐力,6、物品,7、多个物品,8、等级*银币,9、等级*将魂
-- 获取物品的图片
function getItemSp(reward_type, reward_ID)
	reward_type = tonumber(reward_type)

	local itemSp 
	if(reward_type == 1) then
		itemSp = CCSprite:create("images/common/siliver_big.png")
	elseif(reward_type == 2) then
		itemSp = CCSprite:create("images/common/soul_big.png")
	elseif(reward_type == 3) then
		itemSp = CCSprite:create("images/common/gold_big.png")
	elseif(reward_type == 4) then
		itemSp = CCSprite:create("images/online/reward/energy_big.png")
	elseif(reward_type == 5) then
		itemSp = CCSprite:create("images/online/reward/stain_big.png")
	elseif(reward_type == 8) then
		itemSp = CCSprite:create("images/common/siliver_big.png")
	elseif(reward_type == 9 ) then
		itemSp =CCSprite:create("images/common/soul_big.png")
	elseif(reward_type == 10) then
        itemSp =   ItemSprite.getHeroIconItemByhtid( tonumber(reward_ID),-605)--HeroPublicCC.getCMISHeadIconByHtid(tonumber(reward_ID))
	end
	return itemSp
	
end

function createCell(rewardData)

	local tCell = CCTableViewCell:create()
	local cellBg
	local cellSp
	-- 情非得已呀
	if rewardData.reward_values ~= nil then
		if (tonumber(rewardData.reward_type) ~= 6 and tonumber(rewardData.reward_type) ~= 7)  then -- 数100随便设置的，
			-- 显示物品的品质背景
			cellBg = CCSprite:create(IMG_PATH .. "reward/itembg_" .. rewardData.reward_quality .. ".png")
			tCell:addChild(cellBg)
			-- 物品图片
			cellSp = getItemSp(rewardData.reward_type, rewardData.reward_ID ) --CCSprite:create(IMG_PATH .."reward/" .. rewardData.reward_type .. ".png")
			cellSp:setPosition(ccp(cellBg:getContentSize().width*0.5,cellBg:getContentSize().height*0.5))
			cellSp:setAnchorPoint(ccp(0.5,0.5))
			cellBg:addChild(cellSp)
		else

		  	cellBg = ItemSprite.getItemSpriteById(tonumber(rewardData.reward_ID), nil,itemDelegateAction, nil, -600,1000)
		   	tCell:addChild(cellBg)
		end
		if(tonumber(rewardData.reward_values) > 1) then
			local numLabel =  CCRenderLabel:create(rewardData.reward_values, g_sFontName, 21, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
			numLabel:setColor(ccc3(0x00,0xff,0x18))
			local width = cellBg:getContentSize().width - numLabel:getContentSize().width- 6
			numLabel:setPosition(ccp(width,cellBg:getContentSize().height*0.32))
			tCell:addChild(numLabel)
		end
		-- descBg
		-- local descBgLabel = CCSprite:create(IMG_PATH .. "bottom.png")
  --   	descBgLabel:setPosition(ccp(3,-30))
  --   	tCell:addChild(descBgLabel)
    		
    	local descLabel = CCLabelTTF:create(rewardData.reward_desc, g_sFontName,22)    	
    	descLabel:setColor(ccc3(0x78,0x25,0x00))
    	descLabel:setAnchorPoint(ccp(0.5,0.5))
    	descLabel:setPosition(ccp(cellBg:getContentSize().width*0.5,-15))
    	tCell:addChild(descLabel)    		
		

	 end
	

    return tCell 
end

function itemDelegateAction( )
    MainScene.setMainSceneViewsVisible(true, true, true)
end

function setCellValue(tCell,cellValue)
	-- 修改背景
	local cellBg = tolua.cast(tCell:getChildByTag(1),"CCSprite")
	if cellBg ~= nil then
		cellBg:setTexture(CCTextureCache:sharedTextureCache():addImage(IMG_PATH.. cellValue.reward_ID .. ".png"))
	end
	-- 修改数量
	-- local numLabel= tolua.cast(cellBg:getChildByTag(2), "CCRenderLabel")
 --   numLabel:setString("" .. cellValue.reward_values)
end
