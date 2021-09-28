-- FileName: BossRewardViewCell.lua 
-- Author: licong 
-- Date: 14-10-20 
-- Purpose: boos奖励预览cell


module("BossRewardViewCell", package.seeall)


function createCell( tCellValues)
	require "db/DB_BossRewardproview"
	local dbData = DB_BossRewardproview.getDataById(tCellValues)

	local tCell = CCTableViewCell:create()

	local rect = CCRectMake(0,0,116,124)
	local insert = CCRectMake(52,44,6,4)
	local cellBg = CCScale9Sprite:create("images/reward/cell_back.png",rect,insert)
	cellBg:setContentSize(CCSizeMake(563,211))
	tCell:addChild(cellBg)

	-- 描述文字
	local  descBg= CCSprite:create("images/sign/sign_bottom.png")
	descBg:setPosition(ccp(3,cellBg:getContentSize().height*0.72))
	cellBg:addChild(descBg)

	local rankLabel = CCRenderLabel:create(dbData.desc or " " , g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
	rankLabel:setColor(ccc3(0xff,0xfb,0xd9))
	rankLabel:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height*0.5+2))
	rankLabel:setAnchorPoint(ccp(0.5,0.5))
	descBg:addChild(rankLabel)

	-- 有几率掉落
	if(dbData.chance_drop ~= nil)then
		local font1 = CCLabelTTF:create(GetLocalizeStringBy("key_10005"), g_sFontPangWa,20)
		font1:setColor(ccc3(0x78,0x25,0x00))
		font1:setAnchorPoint(ccp(0,1))
		font1:setPosition(ccp(cellBg:getContentSize().width*0.5,cellBg:getContentSize().height-20))
		cellBg:addChild(font1)
		-- 物品名字
		local itemData = ItemUtil.getItemById(tonumber(dbData.chance_drop))
        local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
        local name = CCRenderLabel:create(itemData.name, g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
		name:setColor(nameColor)
		name:setAnchorPoint(ccp(0,1))
		name:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,font1:getPositionY()))
		cellBg:addChild(name)
	end

	--  显示物品的bg
	local rewardBg= CCScale9Sprite:create("images/reward/item_back.png")
	rewardBg:setContentSize(CCSizeMake(513,137))
	rewardBg:setPosition(ccp(cellBg:getContentSize().width/2 ,18))
	rewardBg:setAnchorPoint(ccp(0.5,0))
	cellBg:addChild(rewardBg)

	-- 创建goods列表
	require "script/ui/item/ItemUtil"
	local all_good = ItemUtil.getItemsDataByStr(dbData.reward)

	-- 概率掉落物品
	if( dbData.drop_item )then
		local dropItemTab = ItemUtil.getItemsDataByStr(dbData.drop_item)
		for k,v in pairs(dropItemTab) do
			v.isDrop = true
			table.insert(all_good,v)
		end
	end

	print("all_good++")
	print_t(all_good)
	local cellSize = CCSizeMake(126, 137)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
           	a2 = ItemUtil.createGoodListCell( all_good[a1+1], -652, 1010, -655 )
		 	r = a2
		elseif fn == "numberOfCells" then
			r = #all_good
		else	
		end
		return r
	end)
	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(513, 137))
	goodTableView:setBounceable(true)
	goodTableView:setTouchEnabled(false)
	if( table.count(all_good) > 4) then
		goodTableView:setTouchEnabled(true)
	end
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setPosition(ccp(10, 2))
	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	rewardBg:addChild(goodTableView)
	goodTableView:setTouchPriority(-653)

	return tCell
end































