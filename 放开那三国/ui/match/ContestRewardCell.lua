-- Filename: ContestRewardCell.lua.
-- Author: zhz.
-- Date: 2013-11-11
-- Purpose: 该文件用与现实比武奖

module("ContestRewardCell", package.seeall)
require "script/model/user/UserModel"

function createCell( rewardData)

	local tCell = CCTableViewCell:create()

	local cellBg = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBg:setContentSize(CCSizeMake(563,201))
	tCell:addChild(cellBg)

	-- 描述文字：第1~N的文字
	local  descBg= CCSprite:create("images/sign/sign_bottom.png")
	descBg:setPosition(ccp(3,cellBg:getContentSize().height*0.72))
	cellBg:addChild(descBg)

	local rankLabel = CCRenderLabel:create("" .. rewardData.desc , g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
	rankLabel:setColor(ccc3(0xff,0xfb,0xd9)) -- 0xff,0xfb,0xd9
	rankLabel:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height*0.5+2))
	rankLabel:setAnchorPoint(ccp(0.5,0.5))
	descBg:addChild(rankLabel)

	--  显示物品的bg
	local itemsBg= CCScale9Sprite:create("images/reward/item_back.png")
	itemsBg:setContentSize(CCSizeMake(513,127))
	itemsBg:setPosition(ccp(cellBg:getContentSize().width/2 ,18))
	itemsBg:setAnchorPoint(ccp(0.5,0))
	cellBg:addChild(itemsBg)

	-- 创建物品的图标
	local goodTableView =  createGoodTableView(rewardData)
	itemsBg:addChild(goodTableView)

	return tCell
end



function createGoodTableView(rewardData)

	-- 把奖励改成需要的形式
	local all_good = {}
	all_good = getItemsData(rewardData)
	print("all good is : ")
	print_t(all_good)

	local cellSize = CCSizeMake(126, 121)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
           a2 = createRewardCell(all_good[a1+1])  --GoodsCell.createCell(all_good[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			local num = #all_good
			r = num
			print("num is : ", num)
		elseif fn == "cellTouched" then
			
		elseif (fn == "scroll") then
			
		end
		return r
	end)

	local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(477, 121))
	goodTableView:setBounceable(true)
	if(#all_good> 4) then
		goodTableView:setTouchPriority(-778)
	end
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setPosition(ccp(21, 2))

	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- rewardBg:addChild(goodTableView)
	return goodTableView
end

-- 处理奖励的数据
function getItemsData( rewardData)
	
	local items ={}
	if(rewardData.coin~= nil and tonumber(rewardData.coin) ~= 0 ) then
		local item = {}
		item.type= "sliver"
		item.num = tonumber(rewardData.coin)*UserModel.getHeroLevel()
		item.desc= GetLocalizeStringBy("key_1687")-- .. item.num
		--item.icon = ItemSprite.getSiliverIconSprite()
		table.insert(items,item)
	end
	if(rewardData.soul~= nil and tonumber(rewardData.soul)~=0 ) then
		local item= {}
		item.num = tonumber(rewardData.soul)*UserModel.getHeroLevel()
		item.type = "soul"
		item.desc = GetLocalizeStringBy("key_1616") --.. item.num 
	--	item.icon = ItemSprite.getSoulIconSprite()
		table.insert(items,item)
	end
	if(rewardData.gold ~= nil and tonumber(rewardData.gold)~=0 ) then
		local item = {}
		item.num = tonumber(rewardData.gold)
		item.type= "gold"
		item.desc= GetLocalizeStringBy("key_1491") --.. rewardData.gold
	--	item.icon = ItemSprite.getGoldIconSprite()
		table.insert(items,item)
	end
	if(rewardData.honor ~= nil and tonumber(rewardData.honor)~=0 ) then
		local item = {}
		item.num = tonumber(rewardData.honor)
		item.type= "honor"
		item.desc= GetLocalizeStringBy("lic_1084") --.. rewardData.gold
	--	item.icon = ItemSprite.getGoldIconSprite()
		table.insert(items,item)
	end

	----物品
	if(rewardData.items ~= nil) then
		local item_ids 	= string.split(rewardData.items, ",")
		for k,v in pairs(item_ids) do 
			local tempStrTable = string.split(v, "|")
			local item = {}
			item.tid  = tempStrTable[1]
			item.num = tempStrTable[2]
			item.type = "item"
			-- item.icon = ItemSprite.getItemSpriteByItemId(tonumber(tempStrTable[1]))
			local itemTableInfo = ItemUtil.getItemById(tonumber(item.tid))
			item.desc = itemTableInfo.name
			table.insert(items,item)
		end
	end
	return  items

end

function createRewardCell( cellValues )
	local tCell = CCTableViewCell:create()


	local iconBg --=  cellValues.icon --ItemSprite.getGoldIconSprite()
	if(cellValues.type == "sliver") then
		iconBg= ItemSprite.getSiliverIconSprite()
	elseif(cellValues.type == "soul") then
		iconBg= ItemSprite.getSoulIconSprite()
	elseif(cellValues.type == "gold") then
		iconBg= ItemSprite.getGoldIconSprite()
	elseif(cellValues.type == "honor") then
		iconBg= ItemSprite.getHonorIconSprite()
	elseif(cellValues.type == "item") then
		iconBg =  ItemSprite.getItemSpriteByItemId(tonumber(cellValues.tid))
	end
	iconBg:setPosition(ccp(0,115))
	iconBg:setAnchorPoint(ccp(0,1))
	tCell:addChild(iconBg)

	local numberLabel =  CCRenderLabel:create("" .. cellValues.num , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
	-- local numberLabel = CCLabelTTF:create("" .. cellValues.reward_values, g_sFontName,21)
	numberLabel:setColor(ccc3(0x00,0xff,0x18))
	numberLabel:setAnchorPoint(ccp(0,0))
	local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
	numberLabel:setPosition(ccp(width,5))
	iconBg:addChild(numberLabel)

	--- desc
	local descLabel = CCLabelTTF:create(cellValues.desc, g_sFontName,21)
	--local descLabel = CCRenderLabel:create(cellValues.desc, g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	descLabel:setColor(ccc3(0x78,0x25,0x00))
	descLabel:setAnchorPoint(ccp(0,1))
	-- local width = (iconBg:getContentSize().width - descLabel:getContentSize().width)/2 -2
	descLabel:setPosition(ccp(iconBg:getContentSize().width/2 ,3))
	descLabel:setAnchorPoint(ccp(0.5,0))
	tCell:addChild(descLabel)



	return tCell
end




