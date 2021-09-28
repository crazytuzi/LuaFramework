-- FileName: HorseRewardPreviewCell.lua 
-- Author: llp
-- Date: 14-1-7 
-- Purpose: function description of module 


module("HorseRewardPreviewCell", package.seeall)

require "script/model/user/UserModel"
local horseNameTable = {GetLocalizeStringBy("llp_361"),GetLocalizeStringBy("llp_362"),GetLocalizeStringBy("llp_363"),GetLocalizeStringBy("llp_364")}

function createCell( rewardData,pIndex)

	local tCell = CCTableViewCell:create()

	local cellBg = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBg:setContentSize(CCSizeMake(563,201))
	tCell:addChild(cellBg)

	local  descBg= CCSprite:create("images/sign/sign_bottom.png")
	descBg:setPosition(ccp(3,cellBg:getContentSize().height*0.72))
	cellBg:addChild(descBg)

	local rankLabel = CCRenderLabel:create( horseNameTable[pIndex] , g_sFontPangWa,24,1,ccc3(0xff,0xff,0xff),type_stroke)
	rankLabel:setColor(ccc3(0x75,0x38,0x01))
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
           a2 = createRewardCell(all_good[a1+1][1])  --GoodsCell.createCell(all_good[a1+1])
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
		goodTableView:setTouchPriority(-475)
	end
	goodTableView:setDirection(kCCScrollViewDirectionHorizontal)
	goodTableView:setPosition(ccp(21, 2))

	goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	return goodTableView
end

-- 处理奖励的数据
function getItemsData( rewardData)
	local items ={}
	----物品
	if(rewardData ~= nil) then
		local item_ids 	= string.split(rewardData, ",")
		for k,v in pairs(item_ids) do 
			local itemTableInfo = ItemUtil.getItemsDataByStr(v)
			table.insert(items,itemTableInfo)
		end
	end
	return  items
end

function createRewardCell( cellValues )
	local tCell = CCTableViewCell:create()
	local iconBg =  ItemUtil.createGoodsIcon(cellValues,-1555,1234,-1555,nil,nil,false,true,false)
	iconBg:setPosition(ccp(0,115))
	iconBg:setAnchorPoint(ccp(0,1))
	tCell:addChild(iconBg)

	if( tonumber(cellValues.num) > 1 )then
		local numberLabel =  CCRenderLabel:create("" .. cellValues.num , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
		numberLabel:setColor(ccc3(0x00,0xff,0x18))
		numberLabel:setAnchorPoint(ccp(0,0))
		local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
		numberLabel:setPosition(ccp(width,5))
		iconBg:addChild(numberLabel)
	end

	--- desc
	-- local descLabel = CCLabelTTF:create(cellValues.desc, g_sFontName,21)
	-- descLabel:setColor(ccc3(0x78,0x25,0x00))
	-- descLabel:setAnchorPoint(ccp(0,1))
	-- descLabel:setPosition(ccp(iconBg:getContentSize().width/2 ,3))
	-- descLabel:setAnchorPoint(ccp(0.5,0))
	-- tCell:addChild(descLabel)

	-- 越南版本
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" )then
		descLabel:setVisible(false)
	end

	return tCell
end
